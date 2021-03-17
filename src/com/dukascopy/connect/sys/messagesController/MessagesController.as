package com.dukascopy.connect.sys.messagesController {
	
	import com.dukascopy.connect.data.MessageData;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.connectionManager.NetworkManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.errors.ApplicationError;
	import com.dukascopy.connect.sys.sqlite.SQLRespond;
	import com.dukascopy.connect.sys.sqlite.SQLite;
	import com.dukascopy.connect.sys.video.VideoUploader;
	import com.dukascopy.connect.sys.ws.WS;
	import com.dukascopy.connect.sys.ws.WSClient;
	import com.dukascopy.connect.vo.ChatVO;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class MessagesController {
		
		static private const MESSAGES_UPDATE_INTERVAL:int = 10000;
		
		static private var pendingMessagesMids:Array;
		static private var sendPendingMessagesTimer:Timer;
		static private var inited:Boolean;
		static private var needSendPendingMessages:Boolean;
		
		public function MessagesController() { }
		
		static public function init():void {
			if (inited == false)
				inited = true;
			setup();
			
			Auth.S_NEED_AUTHORIZATION.add(clear);
			WS.S_CONNECTED.add(sendPendingMessagesFromSQL);
			WSClient.S_DUPLICATED_MESSAGE.add(onMessageSentDuplicateError);
			WSClient.S_BLOCKED_MESSAGE.add(onMessageSentBlockedError);
			WSClient.S_REMOVE_MESSAGE.add(onMessageSentBlockedError);
			WSClient.S_BLOCKED_NO_SLOTS_MESSAGE.add(onMessageSentBlockedNOSlotsError);
		}
		
		static private function setup():void {
			pendingMessagesMids = new Array();
			
			if (sendPendingMessagesTimer == null) {
				sendPendingMessagesTimer = new Timer(MESSAGES_UPDATE_INTERVAL);
				sendPendingMessagesTimer.addEventListener(TimerEvent.TIMER, onTimer);
				sendPendingMessagesTimer.start();
			}
		}
		
		static private function clear():void {
			setup();
		}
		
		static private function checkInit():Boolean {
			if (inited == false) {
				throw new ApplicationError(ApplicationError.MESSAGE_CONTROLLER_NOT_INITIALIZED);
				return false;
			}
			return true;
		}
		
		static public function newLocalMessage(backMessageObject:Object):void {
			if (backMessageObject == null)
				return;
			var chatUID:String;
			if ("chatUID" in backMessageObject == false)
				return;
			chatUID = backMessageObject.chatUID;
			if (chatUID == null || chatUID.length == 0)
				return;
			if (chatUID.indexOf(ChatVO.LOCAL_CHAT_FLAG) != -1) {
				var cVO:ChatVO = ChatManager.getChatByUID(chatUID);
				if (cVO != null)
					cVO.accessed = backMessageObject.created;
				return;
			}
			if (checkInit() == true)
				pendingMessagesMids[backMessageObject.mid] = backMessageObject;
		}
		
		static public function newRemoteMessage(messageMid:Number):void {
			if (checkInit() == true) {
				if (messageMid in pendingMessagesMids == true) {
					pendingMessagesMids[messageMid] = null;
					delete pendingMessagesMids[messageMid];
				}
			}
		}
		
		static private function onTimer(e:TimerEvent):void {
			sendNextPendingMessage();
		}
		
		static private function sendNextPendingMessage():void {
			if (Auth.key == "web")
			{
				return;
			}
			if (NetworkManager.isConnected == true && WS.connected == true) {
				for (var mid:String in pendingMessagesMids) {
					WSClient.call_sendTextMessage(pendingMessagesMids[mid].chatUID, pendingMessagesMids[mid].text, pendingMessagesMids[mid].mid);
					return;
				}
			}
		}
		
		static private function onMessageSentBlockedNOSlotsError(messageData:MessageData):void {
			if (Auth.key == "web")
			{
				return;
			}
			if (pendingMessagesMids != null) {
				if (messageData.mid in pendingMessagesMids == true) {
					pendingMessagesMids[messageData.mid] = null;
					delete pendingMessagesMids[messageData.mid];
				}
			}
			SQLite.call_removeMessage(null, -messageData.mid);
		}
		
		static private function onMessageSentBlockedError(messageData:MessageData):void {
			if (Auth.key == "web")
			{
				return;
			}
			if (pendingMessagesMids != null) {
				if (messageData.mid in pendingMessagesMids == true) {
					pendingMessagesMids[messageData.mid] = null;
					delete pendingMessagesMids[messageData.mid];
				}
				sendNextPendingMessage();
			}
		}
		
		static private function onMessageSentDuplicateError(messageData:MessageData):void {
			if (Auth.key == "web")
			{
				return;
			}
			if (pendingMessagesMids != null) {
				if (messageData.mid in pendingMessagesMids == true) {
					pendingMessagesMids[messageData.mid] = null;
					delete pendingMessagesMids[messageData.mid];
				}
				sendNextPendingMessage();
			}
		}
		
		static public function sendPendingMessagesFromSQL():void {
			if (Auth.key == "web")
			{
				return;
			}
			/*DialogManager.alert("", SQLite.isReady.toString());*/
			if (SQLite.isReady)
			{
				if (checkInit() == true) {
					pendingMessagesMids.length = 0;
					SQLite.sendPendingMessages();
				}
			}
			else
			{
				needSendPendingMessages = true;
				SQLite.S_READY.add(onDatabase);
			}
		}
		
		static private function onDatabase():void 
		{
			SQLite.S_READY.remove(onDatabase);
			if (needSendPendingMessages)
			{
				sendPendingMessagesFromSQL();
			}
		}
		
		private static function validateMessages(value:Array):void {
			if (value == null || value.length == 0)
				return;
			var result:Array = new Array();
			var removedMessage:Boolean;
			var index:int;
			for (var i:int = value.length; i != 0; i--) {
				index = i - 1;
				if (value[index].id < 0 && value[index].text != null && value[index].text != "" && value[index].text.charAt(0) == "|") {
					if (VideoUploader.existUploaderWithId(value[index].id) == false) {
						SQLite.call_removeMessage(null, value[index].id);
						value.splice(index, 1);
					}
				}
			}
			return;
		}
		
		static public function sendTextMessages(chatUID:String, messages:Array):void {
			validateMessages(messages);
			if (messages != null && messages.length > 0)
				WSClient.call_sendTextMessages(chatUID, messages);
		}
	}
}