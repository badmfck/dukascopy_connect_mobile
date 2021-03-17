package com.dukascopy.connect.sys.sqlite {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.MessageData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.connectionManager.NetworkManager;
	import com.dukascopy.connect.sys.echo.EchoParser;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.messagesController.MessagesController;
	import com.dukascopy.connect.sys.nativeExtensionController.NativeExtensionController;
	import com.dukascopy.connect.sys.notifier.ChatLastMessageData;
	import com.dukascopy.connect.sys.notifier.HandlerType;
	import com.dukascopy.connect.sys.notifier.NewMessageNotifier;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.store.Store;
	import com.dukascopy.connect.sys.ws.WS;
	import com.dukascopy.connect.sys.ws.WSClient;
	import com.dukascopy.connect.vo.ChatVO;
	import com.greensock.TweenMax;
	import com.telefision.sys.signals.Signal;
	import flash.data.SQLColumnSchema;
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLSchemaResult;
	import flash.data.SQLStatement;
	import flash.data.SQLTableSchema;
	import flash.errors.SQLError;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SQLErrorEvent;
	import flash.events.SQLEvent;
import flash.events.UncaughtErrorEvent;
import flash.filesystem.File;
	import flash.system.Capabilities;
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov, Telefision Team
	 */
	public class SQLite {
		
		private static const MAX_UNION:int = 499;
		
		public static var S_READY:Signal = new Signal("SIGNAL SQLite -> S_READY");
		public static var S_CREATE_FINISH:Signal = new Signal("SIGNAL SQLite -> S_CREATE_FINISH");
		public static var S_CLEARED:Signal = new Signal("SIGNAL SQLite -> S_CLEARED");
		public static var S_DATABASE_CREATED:Signal = new Signal("SIGNAL SQLite -> S_DATABASE_CREATED");
		
		private static var sqlConnection:SQLConnection;
		private static var sqlRespond:SQLRespond;
		static private var sqlStatement:SQLStatement;
		
		private static var queries:Array = [];
		
		static private var clearing:Boolean = false;
		
		private static var messagesCreated:Boolean = false;
		static private var latestsCreated:Boolean=false;
		
		static private var _isReady:Boolean = false;
		
		static private var _unreadCreated:Array = new Array();
		
		public function SQLite() { }
		
//////////////////////////////////////////////////////////////////////////////////////////////////
//  ->  MESSAGES  ////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////
		public static function call_makeMessage(callBack:Function, messageData:Object):void {
			if (("mid" in messageData) && 
				!isNaN(messageData.mid) &&
				Number(messageData.id) >= 0)
					call_removeMessage(onMessageRemoved, -(Number(messageData.mid)));
			if (messageData.id == 0)
				return;
			call(callBack, "INSERT OR REPLACE INTO `messages` " +
			"(`chat_uid`, `msg_id`, `msg_num`, `msg_created`, `msg_text`, `user_uid`, `user_name`, `user_avatar`, `msg_reaction`) values (" +
			"'" + messageData.chat_uid + "', " +
			"" + messageData.id + ", " +
			"" + messageData.num + ", " +
			"" + messageData.created + ", " +
			"'" + messageData.text.replace(/'/g,"''") + "', " +
			"'" + messageData.user_uid + "', " +
			"'" + messageData.user_name.replace(/'/g,"''") + "', " +
			"'" + messageData.user_avatar + "'," +
			"'" + JSON.stringify(messageData.reaction) + "'" +
			");", "call_makeMessage");
		}
		
		private static function onMessageRemoved(response:SQLRespond):void {
			
		}
		
		static public function call_saveChatItem(uid:String, data:String):void {
			call(null, "INSERT OR REPLACE INTO `latests` (`chat_uid`, `data`) values ('" + uid + "','" +data + "');", "call_saveChatItem");
		}
		
		public static function call_makeMessages(callBack:Function, messageData:Array):void {
			if (messageData == null)
				return;
			var length:int = messageData.length;
			if (length == 0) {
				if (callBack != null)
					callBack(null);
				return;
			}
			var cleanedMessages:Array;
			var n:int;
			for (var j:int = messageData.length; j > 0; j--) {
				n = j - 1;
				if (messageData[n].status.toLowerCase() == "cleaned") {
					cleanedMessages ||= [];
					cleanedMessages.push(messageData.removeAt(n));
				}
			}
			
			var midsArray:Array = [];
			
			addCleanedMessages(cleanedMessages, midsArray);
			if (cleanedMessages != null)
				cleanedMessages.length = 0;
			cleanedMessages = null;
			
			length = messageData.length;
			
			var steps:int = Math.ceil(length / MAX_UNION);
			var pos:int;
			var stepMessages:Array;
			var callbackFunction:Function;
			for (var step:int = 0; step < steps; step++) {
				if (step == steps - 1)
					callbackFunction = callBack;
				pos = step * MAX_UNION;
				stepMessages = messageData.slice(pos, Math.min(pos + MAX_UNION, messageData.length));
				saveMessagesToDatabase(stepMessages, "REPLACE", callbackFunction, midsArray, "call_makeMessages.step=" + step);
			}
			deleteMessagesList(midsArray);
			if (callbackFunction == null && callBack != null)
				callBack(null);
		}
		
		static private function addCleanedMessages(messageData:Array, midsArray:Array):void {
			if (messageData == null || messageData.length == 0)
				return;
			var length:int = messageData.length;
			var steps:int = Math.ceil(length / MAX_UNION);
			var pos:int;
			var stepMessages:Array;
			for (var step:int = 0; step < steps; step++) {
				pos = step * MAX_UNION;
				stepMessages = messageData.slice(pos, Math.min(pos + MAX_UNION, messageData.length));
				saveMessagesToDatabase(stepMessages, "IGNORE", null, midsArray, "addCleanedMessages.step=" + step);
			}
		}
		
		static private function saveMessagesToDatabase(stepMessages:Array, sqlInsertType:String, callback:Function, midsArray:Array, caller:String):void {
			var queryString:String = "";
			var message:Object;
			var isFirstMessage:Boolean = true;
			var length:int = stepMessages.length;
			var reactionFieldValue:String;
			for (var j:int = 0; j < length; j++) {
				message = stepMessages[j];
				if (prepareMessageForDatabase(message) == false)
					continue;
				try {
					reactionFieldValue = JSON.stringify(message.reaction)
				} catch (err:Error) {
					echo("SQLite", "saveMessagesToDatabase", err.errorID + ": " + err.message);
					reactionFieldValue = "";
				}
				
				if (isFirstMessage == true) {
					isFirstMessage = false;
					
					queryString += "INSERT OR " + sqlInsertType + " INTO `messages` SELECT ";
					queryString += "'" + message.chat_uid + "' AS `chat_uid`, ";
					queryString +=       message.id + " AS `msg_id`, ";
					queryString +=       message.num + " AS `msg_num`, ";
					queryString +=       message.created + " AS `msg_created`, ";
					queryString += "'" + message.text.replace(/'/g,"''") + "' AS `msg_text`, ";
					queryString += "'" + message.user_uid + "' AS `user_uid`, ";
					queryString += "'" + message.user_name.replace(/'/g,"''") + "' AS `user_name`, ";
					queryString += "'" + message.user_avatar + "' AS `user_avatar`, ";
					queryString += "'" + reactionFieldValue + "' AS `msg_reaction`";
				} else {
					queryString += " UNION SELECT ";
					queryString += "'" + message.chat_uid + "', ";
					queryString +=       message.id + ", ";
					queryString +=       message.num + ", ";
					queryString +=       message.created + ", ";
					queryString += "'" + message.text.replace(/'/g,"''") + "', ";
					queryString += "'" + message.user_uid + "', ";
					queryString += "'" + message.user_name.replace(/'/g,"''") + "', ";
					queryString += "'" + message.user_avatar + "', ";
					queryString += "'" + reactionFieldValue + "'";
				}
				if (("mid" in message) && message.mid != null && message.mid.toString() != "" && !isNaN(Number(message.mid)))
					midsArray.push(-Number(message.mid));
			}
			queryString = queryString + ";";
			call(callback, queryString, caller + ".saveMessagesToDatabase");
		}
		
		static private function prepareMessageForDatabase(message:Object):Boolean {
			var valid:Boolean = true;
			if (message == null)
				valid = false;
			if ("chat_uid" in message == false)
				valid = false;
			if ("num" in message == false)
				valid = false;
			if ("text" in message == false)
				valid = false;
			if ("user_uid" in message == false)
				valid = false;
				
			if (valid == false)
			{
				echo("SQLite", "prepareMessageForDatabase", String(message));
				return false;
			}
			
			if ("id" in message == false)
				message.id = 0;
			if ("created" in message == false)
				message.created = 0;
			if ("user_name" in message == false)
				message.user_name = "user";
			if ("user_avatar" in message == false)
				message.user_avatar = "";
			if ("reaction" in message == false)
				message.reaction = "";
			
			return true;
		}
		
		static public function call_limitMessagesInChat(callBack:Function, chatUid:String, messagesCount:Number = 100):void {
			call(callBack, "DELETE FROM `messages` WHERE `chat_uid` = '" + chatUid + "' AND `msg_id` NOT IN (SELECT `msg_id` FROM `messages` WHERE `chat_uid` = '" + chatUid + "' ORDER BY `msg_created` DESC, `msg_num` DESC " + "LIMIT " + messagesCount + ");", "call_limitMessagesInChat");
		}
		
		static private function deleteMessagesList(midsArray:Array):void {
			if (!midsArray || midsArray.length == 0)
				return;
			var queryString:String = "DELETE FROM `messages` WHERE `msg_id` IN (" + midsArray.join(", ") + ");";
			
			//!TODO: прокинуть с каллбеком;
			call(function onResult(sqlRespond:SQLRespond):void
			{
				
			}, queryString, "deleteMessagesList");
		}
		
		public static function call_getLatest(callBack:Function):void {
			call(callBack, "SELECT * FROM `latests` LIMIT 200", "call_getLatest");
		}
		
		public static function call_removeMessage(callBack:Function, messageUID:Number, chatUID:String = null, requestId:String = ""):void {
			//!TODO: сделать проверку на chatUID если !null;
			call(callBack, "DELETE FROM `messages` WHERE `msg_id` = '" + messageUID + "';", requestId + ".call_removeMessage");
		}
		
		public static function call_getMessages(callBack:Function, convUID:String, messageFromID:Number = -1, messagesCount:Number = 100):void {
			call(callBack, "SELECT chat_uid, msg_id AS id, msg_num AS num, msg_reaction AS reaction, msg_created AS created, msg_text AS text, user_uid , user_name, user_avatar FROM `messages` " +
				"WHERE chat_uid = '" + convUID + "'" + ((messageFromID != -1) ? " AND msg_id < " + messageFromID : "") + " ORDER BY msg_created DESC, msg_num DESC " + "LIMIT " + messagesCount, "call_getMessages");
		}
		
		public static function call_updateMessageStatus(callBack:Function, msgUID:String):void {
			call(callBack, "UPDATE messages " +
				"SET status = '1' " +
				"WHERE msg_uid = '" + msgUID + "';", "call_updateMessageStatus");
		}
		
		static public function call_updateMessage(callBack:Function, id:Number, value:String):void {
			call(callBack, "UPDATE messages " +
				"SET msg_text = '" + value.replace(/'/g,"''") + "' " +
				"WHERE msg_id = " + id + ";", "call_updateMessage");
		}
		
		static public function call_makeSendedMessage(callBack:Function, messageTS:Number, msg:String, convUID:String):void {
			call(callBack,
				"INSERT OR REPLACE INTO `messages_sended` " +
				"(`message_time`, `text`, `conv_uid`) values (" +
				"'" + messageTS + "', " +
				"'" + msg.replace(/'/g,"''") + "', " +
				"'" + convUID +
				"');", "call_makeSendedMessage");
		}
		
		public static function call_removeSendedMessage(callBack:Function, messageTS:String):void {
			call(callBack, "DELETE FROM `messages_sended` WHERE `message_time` = '" + messageTS + "';", "call_removeSendedMessage");
		}
		
		public static function call_removeSendedMessages(callBack:Function, messageTSs:Array):void {
			var queryString:String = "DELETE FROM `messages_sended` WHERE `message_time` IN (" + messageTSs.join(", ") + ")";
			call(callBack, queryString, "call_removeSendedMessages");
		}
		
		public static function call_getSendedMessages(callBack:Function):void {
			call(callBack, "SELECT `text` AS msg, `message_time` AS mbMsgId, `conv_uid` AS convUid FROM `messages_sended`", "call_getSendedMessages");
		}
		
		static public function call_getSendedMessagesByConvUID(callBack:Function, convUID:String):void {
			call(callBack, "SELECT `text` AS msg, `message_time` AS mbMsgId FROM `messages_sended` WHERE conv_uid = '" + convUID + "'", "call_getSendedMessagesByConvUID");
		}
		
		static public function sendPendingMessages():void {
			call(pendingMessagesLoadedFromDB, "SELECT * FROM `messages` WHERE `msg_id`< 0 ORDER BY msg_id DESC", "sendPendingMessages");
		}
		
		static public function resendMessage(messageId:Number, chatUID:String):void {
			call(pendingMessagesLoadedFromDB, "SELECT * FROM `messages` WHERE `msg_id`= " + messageId + " ORDER BY msg_id DESC", "resendMessage");
		}
		
		private static function pendingMessagesLoadedFromDB(sqlRespond:SQLRespond):void {
			//TODO: отсылать не чаще заданного времени, если был запрос в этот интервал - откладывать;
			if (sqlRespond.error) {
				//!TODO;
				return;
			}
			if (sqlRespond.data && (sqlRespond.data is Array)) {
				var l:int = sqlRespond.data.length;
				var messageData:Object;
				var chatsArray:Dictionary = new Dictionary();
				for (var i:int = 0; i < l; i++) {
					if ((sqlRespond.data[i].chat_uid as String).indexOf(ChatVO.LOCAL_CHAT_FLAG) == -1 &&
						(sqlRespond.data[i].msg_text as String).charAt(0) != "|") {
						if (chatsArray[sqlRespond.data[i].chat_uid.toString()] == null) {
							chatsArray[sqlRespond.data[i].chat_uid.toString()] = new Array();
						}
						
						messageData = new Object();
						messageData.text = sqlRespond.data[i].msg_text;
						messageData.mid = -(Number(sqlRespond.data[i].msg_id));
						chatsArray[sqlRespond.data[i].chat_uid.toString()].push(messageData);
					} else {
						
					}
				}
				for (var chatUID:String in chatsArray) {
					(chatsArray[chatUID] as Array).sortOn("mid");
					
					MessagesController.sendTextMessages(chatUID, chatsArray[chatUID]);
				}
				chatsArray = null;
			}
		}
		
		static public function updateChatUidInMessages(callBack:Function, oldChatId:String, newChatId:String):void {
			call(callBack, "SELECT * FROM `messages` WHERE chat_uid = '" + oldChatId + "';", "updateChatUidInMessages");
		}
		
		static public function call_updateMessages_chatUid_text(callBack:Function, messages:Array):void {
			var l:int = messages.length;
			var request:String = "";
			request += "UPDATE messages ";
			request += 	  "SET chat_uid = CASE msg_id";
			for (var i:int = 0; i < l; i++) {
				request += 	  " WHEN " + messages[i].id + " THEN '" + messages[i].chat_uid + "'";
			}
			request += 	" END, "
			request += 	  "msg_text = CASE msg_id";
			for (var j:int = 0; j < l; j++) {
				request += 	  " WHEN " + messages[j].id + " THEN '" + messages[j].text + "'";
			}
			request += 	" END ";
			request += "WHERE msg_id IN (";
			for (var k:int = 0; k < l; k++) {
				request += messages[k].id;
				if (k < l-1) {
					request += ", "
				}
			}
			request += ");";
			call(callBack, request, "call_updateMessages_chatUid_text");
		}
		
		static private function sendPendingMessage(chatUID:String, text:String, mid:Number):void {
			WSClient.call_sendTextMessage(chatUID, text, mid);
		}
		
		static public function call_getUnreadMessages(handlerType:HandlerType, callback:Function):void {
			call(callback, "SELECT * FROM `" + handlerType.value + "`", "call_getUnreadMessages");
		}
		
//////////////////////////////////////////////////////////////////////////////////////////////////
//  MESSAGES <- ->  START SQL  ///////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////
		public static function init():void {
			if (sqlConnection && sqlConnection.connected) {
				S_CREATE_FINISH.invoke();
				return;
			}
			Store.save("sqliteVersion", Config.VERSION_SQL);

			sqlConnection = new SQLConnection();
			sqlConnection.addEventListener(SQLEvent.OPEN, openHandler);
			sqlConnection.addEventListener(SQLErrorEvent.ERROR, openErrorHandler);
			sqlStatement = new SQLStatement();
			sqlStatement.sqlConnection = sqlConnection;
			
			var dbFile:File = File.applicationStorageDirectory.resolvePath("tfc.db");
			sqlConnection.openAsync(dbFile);
			
			WSClient.S_DUPLICATED_MESSAGE.add(onMessageSentDuplicateError);
			WSClient.S_BLOCKED_MESSAGE.add(onMessageSentBlockedError);
			WSClient.S_REMOVE_MESSAGE.add(onMessageSentRemoveError);
		}
		
		static private function onMessageSentRemoveError(messageData:MessageData):void {
			SQLite.call_removeMessage(null, -messageData.mid, messageData.chatUID);
		}
		
		static private function onMessageSentBlockedError(messageData:MessageData):void {
			//SQLite.call_removeMessage(null, -messageData.mid, messageData.chatUID);
		}
		
		static private function onMessageSentDuplicateError(messageData:MessageData):void 
		{
			SQLite.call_removeMessage(null, -messageData.mid, messageData.chatUID);
		}
		
		private static function openHandler(e:SQLEvent):void {
			if (e.type == 'open') {
				sqlConnection.removeEventListener(SQLEvent.OPEN, openHandler);
				sqlConnection.removeEventListener(SQLErrorEvent.ERROR, openErrorHandler);
				sqlConnection.addEventListener(SQLEvent.SCHEMA, checkTables);
				sqlConnection.addEventListener(SQLErrorEvent.ERROR, checkTables);
				sqlConnection.loadSchema(SQLTableSchema);
			}
		}
		
		private static function openErrorHandler(e:SQLErrorEvent):void {
			sendError("SQL Error "+e.errorID,"Can't opened DB file");
			S_CREATE_FINISH.invoke();
		}
		
		private static function checkTables(e:Event):void {
			sqlConnection.removeEventListener(SQLEvent.SCHEMA, checkTables);
			sqlConnection.removeEventListener(SQLErrorEvent.ERROR, checkTables);
			var shemaResult:SQLSchemaResult = sqlConnection.getSchemaResult();
			if (shemaResult != null) {
				var i:int = shemaResult.tables.length;
				while (i--) {
					if (shemaResult.tables[i].name == "messages")
					{
						var messageReactionColumnExist:Boolean = false;
						if ((shemaResult.tables[i] as SQLTableSchema).columns != null){
							var l:int = (shemaResult.tables[i] as SQLTableSchema).columns.length;
							for (var j:int = 0; j < l; j++) 
							{
								if (((shemaResult.tables[i] as SQLTableSchema).columns[j] as SQLColumnSchema).name == "msg_reaction"){
									messageReactionColumnExist = true;
								}
							}
						}
						messagesCreated = true;
					}
					else if (shemaResult.tables[i].name == "latests")
						latestsCreated = true;
					else if (shemaResult.tables[i].name == HandlerType.LATEST || 
						shemaResult.tables[i].name == HandlerType.CHANNELS || 
						shemaResult.tables[i].name == HandlerType.CHANNELS_TRASH || 
						shemaResult.tables[i].name == HandlerType.CHAT_911)
							_unreadCreated[shemaResult.tables[i].name] = true;
					else
						call(null, "DROP TABLE IF EXISTS " + shemaResult.tables[i].name + ";", "drop" + shemaResult.tables[i].name);
				}
			}
			
			var allTablesFound:Boolean = true;
			
			if (!messagesCreated){
				createMessages();
				allTablesFound = false;
			}
			
			if (!latestsCreated) {
				createLatests()
				allTablesFound = false;
			}
			
			if (!allTablesFound)
				return;
			
			if (messageReactionColumnExist == false)
				checkMessagesTable();
			else
				databaseReady();
		}
		
		static private function checkMessagesTable():void {
			call(onMessagesTableChecked, "ALTER TABLE messages ADD COLUMN msg_reaction TEXT;", "checkMessagesTable");
		}
		
		static private function onMessagesTableChecked(r:SQLRespond):void {
			databaseReady();
		}
		
		private static function databaseReady():void {
			var lastReadyStatus:Boolean = _isReady;
			_isReady = true;
			S_READY.invoke();
			if (lastReadyStatus == false)
			{
				S_CREATE_FINISH.invoke();
			}
		}
		
//////////////////////////////////////////////////////////////////////////////////////////////////
//  ->  REMOVE DATABASE  /////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////
		static public function clear():void {
			if (!sqlConnection) {
				removeDBFile();
				return;
			}
			TweenMax.killDelayedCallsTo(sendPendingMessage);
			
			messagesCreated = false;
			latestsCreated = false;
			_unreadCreated = new Array();
			
			clearing = true;
			
			sqlConnection.removeEventListener(SQLEvent.OPEN, openHandler);
			sqlConnection.removeEventListener(SQLErrorEvent.ERROR, openErrorHandler);
			sqlConnection.removeEventListener(SQLEvent.SCHEMA, checkTables);
			sqlConnection.removeEventListener(SQLErrorEvent.ERROR, checkTables);
			
			sqlConnection.close();
			sqlConnection.addEventListener(SQLEvent.CLOSE, closeHandler);
			
			WSClient.S_DUPLICATED_MESSAGE.remove(onMessageSentDuplicateError);
			WSClient.S_BLOCKED_MESSAGE.remove(onMessageSentBlockedError);
		}
		
		static public function call_storeChatsUnredData(handlerType:HandlerType, chatsToStore:Vector.<ChatLastMessageData>, callback:Function):void 
		{
			if (chatsToStore != null && chatsToStore.length > 0)
			{
				var queryString:String = "";
				var l:int = chatsToStore.length;
				
				
				queryString = "";
				queryString += "INSERT OR REPLACE INTO `" + handlerType.value + "` SELECT ";
				queryString += "'" + chatsToStore[0].chatUid + "' AS `chat_uid`, ";
				queryString += "'" + chatsToStore[0].lastReaded + "' AS `msg_num` ";
				
				
				for (var i:int = 1; i < l; i++) {
					queryString += "UNION SELECT ";
					queryString += "'" + chatsToStore[i].chatUid + "', ";
					queryString += "'" + chatsToStore[i].lastReaded + "' ";
				}
				
				if (queryString.charAt(queryString.length - 1) == " ")
				{
					queryString = queryString.substr(0, queryString.length - 1);
				}
				queryString = queryString + ";";
				
				call(callback, queryString, "call_storeChatsUnredData");
			}
			else
			{
				//!TODO:;
			}
		}
		
		static public function call_storeChatUnredData(handlerType:HandlerType, value:ChatLastMessageData, callback:Function):void 
		{
			call(callback,
				"INSERT OR REPLACE INTO `" + handlerType.value + "` " +
				"(`chat_uid`, `msg_num`) values (" +
				"'" + value.chatUid + "', " +
				"'" + value.lastReaded + 
				"');", "call_storeChatUnredData");
		}
		
		static public function createUnreadedDatabase(handlerType:HandlerType):void 
		{
			createUnread(handlerType.value);
		}
		
		static public function isUnreadedDatabaseExist(value:String):Boolean 
		{
			return _unreadCreated[value];
		}
		
		static private function closeHandler(e:SQLEvent):void {
			sqlConnection.removeEventListener(SQLEvent.CLOSE, closeHandler);
			sqlConnection = null;
			removeDBFile();
		}
		
		private static function removeDBFile():void {
			var __dbFileDeleteHandler:Function = function(e:Event):void {
				dbFile.removeEventListener(Event.COMPLETE, __dbFileDeleteHandler);
				dbFile.removeEventListener(IOErrorEvent.IO_ERROR, __dbFileDeleteHandler);
				dbFile = null;
				if (e is IOErrorEvent) {
					trace("SQLite::removeDBFile -> Can't remove DB file.");
					return;
				}
				clearingFinished();
			}
			var dbFile:File = File.applicationStorageDirectory.resolvePath("tfc.db");
			dbFile.addEventListener(Event.COMPLETE, __dbFileDeleteHandler);
			dbFile.addEventListener(IOErrorEvent.IO_ERROR, __dbFileDeleteHandler);
			if (dbFile.exists)
				dbFile.deleteFileAsync();
			else
				clearingFinished();
		}
		
		static private function clearingFinished():void {
			_isReady = false;
			clearing = false;
			if (queries)
				queries.length = 0;
			S_CLEARED.invoke();
			
		//	createMessages();
		}
		
//////////////////////////////////////////////////////////////////////////////////////////////////
//  ->  CREATE TABLES  ///////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////
		private static function createMessages():void {
			call(createTableHandler,
				"CREATE TABLE IF NOT EXISTS `messages` (" +
				"`chat_uid` TEXT(32), " +
				"`msg_id` REAL, " +
				"`msg_num` REAL, " +
				"`msg_created` REAL, " +
				"`msg_text` TEXT, " +
				"`user_uid` TEXT, " +
				"`user_name` TEXT, " +
				"`user_avatar` TEXT, " +
				"`msg_reaction` TEXT, " +
				"PRIMARY KEY (`msg_id`));",
				"createMessages"
			);
		}
		
		private static function createLatests():void {
			call(createTableHandler,
				"CREATE TABLE IF NOT EXISTS `latests` (" +
				"`chat_uid` TEXT(32), " +
				"`data` TEXT, " +
				"UNIQUE(chat_uid) ON CONFLICT REPLACE);",
				"createLatests"
			);
		}
		
		private static function createUnread(unreadedType:String):void {
			call(createTableHandler,
				"CREATE TABLE IF NOT EXISTS `" + unreadedType + "` (" +
				"`chat_uid` TEXT(32), " +
				"`msg_num` REAL, " +
				"UNIQUE(chat_uid) ON CONFLICT REPLACE);",
				unreadedType
			);
		}
		
		static private function createTableHandler(sqlRespond:SQLRespond):void {
			if (sqlRespond.error) {
				if (sqlRespond.id == "createMessages")
					createMessages();
				if (sqlRespond.id == "createLatests")
					createLatests();
				return;
			}
			if (sqlRespond.id == "createMessages")
				messagesCreated = true;
				
			if (sqlRespond.id == "createLatests")
				latestsCreated = true;
			
			// unreaded messages tables handler
			if (sqlRespond.id == HandlerType.LATEST || sqlRespond.id == HandlerType.CHANNELS || sqlRespond.id == HandlerType.CHANNELS_TRASH || sqlRespond.id == HandlerType.CHAT_911)
			{
				_unreadCreated[sqlRespond.id] = true;
				S_DATABASE_CREATED.invoke(sqlRespond.id);
			}
			else
			{
				if (messagesCreated && latestsCreated)
					databaseReady();
			}
		}
		
//////////////////////////////////////////////////////////////////////////////////////////////////
//  ->  CALL  ////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////
		/**
		 * Execute sql query in sqlite database
		 * @param	callBack
		 * @param	query
		 * @param	id
		 */
		private static function call(callBack:Function, query:String, id:String):void {
			if (clearing)
				return;
			if (!sqlConnection || !sqlConnection.connected) {
				echo("SQLite", "call", "Something happened with DB (sqlConnection is null or not connected).");
				var reason:String= (sqlConnection == null) ? "SQL Connection is null" : "SQL Connection not connected";
				sendError("SQL Error - no connection, method (call)", reason);
				// TODO: callback invoke
				
				if (callBack != null)
					callBack(sqlRespond);
				if (queries.length > 0) {
					var nextCall:Array = queries.shift();
					call(nextCall[0], nextCall[1], nextCall[2]);
				}
				return;
			}
			if (sqlStatement.executing) {
				queries[queries.length] = [callBack, query, id];
				return;
			}
			var __resultHandler:Function = function(e:Event):void {
				if (clearing)
					return;
				sqlRespond ||= new SQLRespond();
				sqlRespond.id = id;
				sqlRespond.query = query;
				if (e is SQLErrorEvent) {
					sqlRespond.error = true;
					sqlRespond.errorMessage = "function: " + id + "\n" + getSQLErrorText(SQLErrorEvent(e).error) + "\nSQLErrorEvent(e).text:\n" + SQLErrorEvent(e).text + "\nSQLError.details:\n" + SQLErrorEvent(e).error.details + "\nQuery:\n" + query;
					sqlRespond.data = [];
					sendError("SQL Error " + SQLErrorEvent(e).errorID + ": " + SQLErrorEvent(e).type, sqlRespond.errorMessage);
				} else {
					var result:SQLResult = sqlStatement.getResult();
					if (result == null) {
						sqlRespond.error = true;
						sqlRespond.errorMessage = "SQLResult is null";
						sqlRespond.data = [];
						sendError("SQL Error ...: ..." + SQLErrorEvent(e).type, sqlRespond.errorMessage);
					} else {
						sqlRespond.error = false;
						sqlRespond.errorMessage = "";
						sqlRespond.data = result.data as Array;
						if (sqlRespond.data == null)
							sqlRespond.data = [];
					}
				}
				sqlStatement.removeEventListener(SQLEvent.RESULT, __resultHandler);
				sqlStatement.removeEventListener(SQLErrorEvent.ERROR, __resultHandler);
				if (callBack != null)
					callBack(sqlRespond);
				if (queries.length > 0) {
					var nextCall:Array = queries.shift();
					call(nextCall[0], nextCall[1], nextCall[2]);
				}
			}
			sqlStatement.addEventListener(SQLEvent.RESULT, __resultHandler);
			sqlStatement.addEventListener(SQLErrorEvent.ERROR, __resultHandler);
			sqlStatement.text = query;
			sqlStatement.execute();
		}
		
		static private function sendError(message:String,reason:String):void {
			Main.sendError(message,reason);
		}
		
		static public function get isReady():Boolean {
			return _isReady;
		}
		
		static private function getSQLErrorText(error:SQLError):String {
			var res:String = "Error text not found.";
			if (error == null)
				return res;
			if (error.detailID == 1001)
				res = "Connection closed.";
			else if (error.detailID == 1002)
				res = "Database must be open to perform this operation.";
			else if (error.detailID == 1003)
				res = "%s [,|and %s] parameter name(s) found in parameters property but not in the SQL specified.";
			else if (error.detailID == 1004)
				res = "Mismatch in parameter count. Found %s in SQL specified and %s value(s) set in parameters property. Expecting values for %s [,|and %s].";
			else if (error.detailID == 1005)
				res = "Auto compact could not be turned on.";
			else if (error.detailID == 1006)
				res = "The pageSize value could not be set.";
			else if (error.detailID == 1007)
				res = "The schema object with name '%s' of type '%s' in database '%s' was not found.";
			else if (error.detailID == 1008)
				res = "The schema object with name '%s' in database '%s' was not found.";
			else if (error.detailID == 1009)
				res = "No schema objects with type '%s' in database '%s' were found.";
			else if (error.detailID == 1010)
				res = "No schema objects in database '%s' were found.";
			else if (error.detailID == 2001)
				res = "Parser stack overflow.";
			else if (error.detailID == 2002)
				res = "Too many arguments on function '%s'.";
			else if (error.detailID == 2003)
				res = "near '%s': syntax error.";
			else if (error.detailID == 2004)
				res = "there is already another table or index with this name: '%s'.";
			else if (error.detailID == 2005)
				res = "PRAGMA is not allowed in SQL.";
			else if (error.detailID == 2006)
				res = "Not a writable directory.";
			else if (error.detailID == 2007)
				res = "Unknown or unsupported join type: '%s %s %s'.";
			else if (error.detailID == 2008)
				res = "RIGHT and FULL OUTER JOINs are not currently supported.";
			else if (error.detailID == 2009)
				res = "A NATURAL join may not have an ON or USING clause.";
			else if (error.detailID == 2010)
				res = "Cannot have both ON and USING clauses in the same join.";
			else if (error.detailID == 2011)
				res = "Cannot join using column '%s' - column not present in both tables.";
			else if (error.detailID == 2012)
				res = "Only a single result allowed for a SELECT that is part of an expression.";
			else if (error.detailID == 2013)
				res = "No such table: '[%s.]%s'.";
			else if (error.detailID == 2014)
				res = "No tables specified.";
			else if (error.detailID == 2015)
				res = "Too many columns in result set|too many columns on '%s'.";
			else if (error.detailID == 2016)
				res = "%s ORDER|GROUP BY term out of range - should be between 1 and %s.";
			else if (error.detailID == 2017)
				res = "Too many terms in ORDER BY clause.";
			else if (error.detailID == 2018)
				res = "%s ORDER BY term out of range - should be between 1 and %s.";
			else if (error.detailID == 2019)
				res = "%r ORDER BY term does not match any column in the result set.";
			else if (error.detailID == 2020)
				res = "ORDER BY clause should come after '%s' not before.";
			else if (error.detailID == 2021)
				res = "LIMIT clause should come after '%s' not before.";
			else if (error.detailID == 2022)
				res = "SELECTs to the left and right of '%s' do not have the same number of result columns.";
			else if (error.detailID == 2023)
				res = "A GROUP BY clause is required before HAVING.";
			else if (error.detailID == 2024)
				res = "Aggregate functions are not allowed in the GROUP BY clause.";
			else if (error.detailID == 2025)
				res = "DISTINCT in aggregate must be followed by an expression.";
			else if (error.detailID == 2026)
				res = "Too many terms in compound SELECT.";
			else if (error.detailID == 2027)
				res = "Too many terms in ORDER|GROUP BY clause.";
			else if (error.detailID == 2028)
				res = "Temporary trigger may not have qualified name.";
			else if (error.detailID == 2030)
				res = "Trigger '%s' already exists.";
			else if (error.detailID == 2032)
				res = "Cannot create BEFORE|AFTER trigger on view: '%s'.";
			else if (error.detailID == 2033)
				res = "Cannot create INSTEAD OF trigger on table: '%s'.";
			else if (error.detailID == 2034)
				res = "No such trigger: '%s'.";
			else if (error.detailID == 2035)
				res = "Recursive triggers not supported ('%s').";
			else if (error.detailID == 2036)
				res = "No such column: %s[.%s[.%s]].";
			else if (error.detailID == 2037)
				res = "VACUUM is not allowed from SQL.";
			else if (error.detailID == 2043)
				res = "Table '%s': indexing function returned an invalid plan.";
			else if (error.detailID == 2044)
				res = "At most %s tables in a join.";
			else if (error.detailID == 2046)
				res = "Cannot add a PRIMARY KEY column.";
			else if (error.detailID == 2047)
				res = "Cannot add a UNIQUE column.";
			else if (error.detailID == 2048)
				res = "Cannot add a NOT NULL column with default value NULL.";
			else if (error.detailID == 2049)
				res = "Cannot add a column with non-constant default.";
			else if (error.detailID == 2050)
				res = "Cannot add a column to a view.";
			else if (error.detailID == 2051)
				res = "ANALYZE is not allowed in SQL.";
			else if (error.detailID == 2052)
				res = "Invalid name: '%s'.";
			else if (error.detailID == 2053)
				res = "ATTACH is not allowed from SQL.";
			else if (error.detailID == 2054)
				res = "%s '%s' cannot reference objects in database '%s'.";
			else if (error.detailID == 2055)
				res = "Access to '[%s.]%s.%s' is prohibited.";
			else if (error.detailID == 2056)
				res = "Not authorized.";
			else if (error.detailID == 2058)
				res = "No such view: '[%s.]%s'.";
			else if (error.detailID == 2060)
				res = "Temporary table name must be unqualified.";
			else if (error.detailID == 2061)
				res = "Table '%s' already exists.";
			else if (error.detailID == 2062)
				res = "There is already an index named: '%s'.";
			else if (error.detailID == 2064)
				res = "Duplicate column name: '%s'.";
			else if (error.detailID == 2065)
				res = "Table '%s' has more than one primary key.";
			else if (error.detailID == 2066)
				res = "AUTOINCREMENT is only allowed on an INTEGER PRIMARY KEY.";
			else if (error.detailID == 2067)
				res = "No such collation sequence: '%s'.";
			else if (error.detailID == 2068)
				res = "Parameters are not allowed in views.";
			else if (error.detailID == 2069)
				res = "View '%s' is circularly defined.";
			else if (error.detailID == 2070)
				res = "Table '%s' may not be dropped.";
			else if (error.detailID == 2071)
				res = "Use DROP VIEW to delete view '%s'.";
			else if (error.detailID == 2072)
				res = "Use DROP TABLE to delete table '%s'.";
			else if (error.detailID == 2073)
				res = "Foreign key on '%s' should reference only one column of table '%s'.";
			else if (error.detailID == 2074)
				res = "Number of columns in foreign key does not match the number of columns in the referenced table.";
			else if (error.detailID == 2075)
				res = "Unknown column '%s' in foreign key definition.";
			else if (error.detailID == 2076)
				res = "Table '%s' may not be indexed.";
			else if (error.detailID == 2077)
				res = "Views may not be indexed.";
			else if (error.detailID == 2080)
				res = "Conflicting ON CONFLICT clauses specified.";
			else if (error.detailID == 2081)
				res = "No such index: '%s'.";
			else if (error.detailID == 2082)
				res = "Index associated with UNIQUE or PRIMARY KEY constraint cannot be dropped.";
			else if (error.detailID == 2083)
				res = "BEGIN is not allowed in SQL.";
			else if (error.detailID == 2084)
				res = "COMMIT is not allowed in SQL.";
			else if (error.detailID == 2085)
				res = "ROLLBACK is not allowed in SQL.";
			else if (error.detailID == 2086)
				res = "Unable to open a temporary database file for storing temporary tables.";
			else if (error.detailID == 2087)
				res = "Unable to identify the object to be reindexed.";
			else if (error.detailID == 2088)
				res = "Table '%s' may not be modified.";
			else if (error.detailID == 2089)
				res = "Cannot modify '%s' because it is a view.";
			else if (error.detailID == 2090)
				res = "Variable number must be between ?0 and ?%s<.";
			else if (error.detailID == 2092)
				res = "Misuse of aliased aggregate '%s'.";
			else if (error.detailID == 2093)
				res = "Ambiguous column name: '[%s.[%s.]]%s'.";
			else if (error.detailID == 2094)
				res = "No such function: '%s'.";
			else if (error.detailID == 2095)
				res = "Wrong number of arguments to function '%s'.";
			else if (error.detailID == 2096)
				res = "Subqueries prohibited in CHECK constraints.";
			else if (error.detailID == 2097)
				res = "Parameters prohibited in CHECK constraints.";
			else if (error.detailID == 2098)
				res = "Expression tree is too large (maximum depth %s).";
			else if (error.detailID == 2099)
				res = "RAISE() may only be used within a trigger-program.";
			else if (error.detailID == 2100)
				res = "Table '%s' has %s columns but %s values were supplied.";
			else if (error.detailID == 2101)
				res = "Database schema is locked: '%s'.";
			else if (error.detailID == 2102)
				res = "Statement too long.";
			else if (error.detailID == 2103)
				res = "Unable to delete/modify collation sequence due to active statements.";
			else if (error.detailID == 2104)
				res = "Too many attached databases - max %s.";
			else if (error.detailID == 2105)
				res = "Cannot ATTACH database within transaction.";
			else if (error.detailID == 2106)
				res = "Database '%s' is already in use.";
			else if (error.detailID == 2108)
				res = "Attached databases must use the same text encoding as main database.";
			else if (error.detailID == 2200)
				res = "Out of memory.";
			else if (error.detailID == 2201)
				res = "Unable to open database.";
			else if (error.detailID == 2202)
				res = "Cannot DETACH database within transaction.";
			else if (error.detailID == 2203)
				res = "Cannot detach database: '%s'.";
			else if (error.detailID == 2204)
				res = "Database '%s' is locked.";
			else if (error.detailID == 2205)
				res = "Unable to acquire a read lock on the database.";
			else if (error.detailID == 2206)
				res = "[column|columns] '%s'[,'%s'] are not [unique|is] not unique.";
			else if (error.detailID == 2207)
				res = "Malformed database schema.";
			else if (error.detailID == 2208)
				res = "Unsupported file format.";
			else if (error.detailID == 2209)
				res = "Unrecognized token: '%s'.";
			else if (error.detailID == 2300)
				res = "Could not convert text value to numeric value.";
			else if (error.detailID == 2301)
				res = "Could not convert string value to date.";
			else if (error.detailID == 2302)
				res = "Could not convert floating point value to integer without loss of data.";
			else if (error.detailID == 2303)
				res = "Cannot rollback transaction - SQL statements in progress.";
			else if (error.detailID == 2304)
				res = "Cannot commit transaction - SQL statements in progress.";
			else if (error.detailID == 2305)
				res = "Database table is locked: '%s'.";
			else if (error.detailID == 2306)
				res = "Read-only table.";
			else if (error.detailID == 2307)
				res = "String or blob too big.";
			else if (error.detailID == 2309)
				res = "Cannot open indexed column for writing.";
			else if (error.detailID == 2400)
				res = "Cannot open value of type %s.";
			else if (error.detailID == 2401)
				res = "No such rowid: %s<.";
			else if (error.detailID == 2402)
				res = "Object name reserved for internal use: '%s'.";
			else if (error.detailID == 2403)
				res = "View '%s' may not be altered.";
			else if (error.detailID == 2404)
				res = "Default value of column '%s' is not constant.";
			else if (error.detailID == 2405)
				res = "Not authorized to use function '%s'.";
			else if (error.detailID == 2406)
				res = "Misuse of aggregate function '%s'.";
			else if (error.detailID == 2407)
				res = "Misuse of aggregate: '%s'.";
			else if (error.detailID == 2408)
				res = "No such database: '%s'.";
			else if (error.detailID == 2409)
				res = "Table '%s' has no column named '%s'.";
			else if (error.detailID == 2501)
				res = "No such module: '%s'.";
			else if (error.detailID == 2508)
				res = "No such savepoint: '%s'.";
			else if (error.detailID == 2510)
				res = "Cannot rollback - no transaction is active.";
			else if (error.detailID == 2511)
				res = "Cannot commit - no transaction is active.";
			var paramIndex:int = res.indexOf("%s");
			var index:int = 0;
			while (paramIndex != -1) {
				if (error.detailArguments != null && error.detailArguments.length > index)
					res = res.replace("%s", error.detailArguments[index]);
				paramIndex = res.indexOf("%s");
				index++;
			}
			return "SQLError " + error.detailID + ":\n" + res;
		}
	}
}