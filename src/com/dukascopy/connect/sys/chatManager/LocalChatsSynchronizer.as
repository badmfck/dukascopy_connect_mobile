package com.dukascopy.connect.sys.chatManager {
	
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.connectionManager.NetworkManager;
	import com.dukascopy.connect.sys.crypter.Crypter;
	import com.dukascopy.connect.sys.messagesController.MessagesController;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.sys.sqlite.SQLite;
	import com.dukascopy.connect.sys.sqlite.SQLRespond;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.sys.ws.WS;
	import com.dukascopy.connect.type.ChatRoomType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.connect.vo.ChatVO;
	import com.dukascopy.connect.vo.users.UserVO;
	import com.telefision.sys.signals.Signal;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class LocalChatsSynchronizer {
		
		private var localChats:Array/*ChatVO*/;
		private var busy:Boolean;
		private var uploadTimer:Timer;
		private var uploadTimeInterval:int = 10000;
		private var needUpdateMessage:Boolean = false;
		
		public var S_CHAT_UPDATED:Signal = new Signal('LocalChatsSynchronizer.S_CHAT_UPDATED');
		static public const LOCAL_INCOME_CHAT_FLAG:String = "$---$";
		
		public function LocalChatsSynchronizer() {
			localChats = new Array();
			Auth.S_NEED_AUTHORIZATION.add(clear);
			WS.S_CONNECTED.add(socketConnected);
			needUpdateMessage = false;
			startUploadTimer();
		}
		
		private function startUploadTimer():void {
			uploadTimer = new Timer(uploadTimeInterval);
			uploadTimer.addEventListener(TimerEvent.TIMER, tryUpload);
			uploadTimer.start();
		}
		
		public function getLocalChats():Array/*ChatVO*/ {
			return localChats;
		}
		
		private function tryUpload(e:TimerEvent):void {
			if (localChats.length > 0) {
				syncNextChat();
			}
		}
		
		private function socketConnected():void {
			if (localChats.length > 0) {
				syncNextChat();
			}
		}
		
		public function addLocalChat(userUID:String):ChatVO {
			var cVO:ChatVO = getLocalChatByUserUID(userUID);
			if (cVO == null)
				cVO = createLocalChat(userUID);
			localChats.push(cVO);
			if (WS.connected && NetworkManager.isConnected == true) {
				if (localChats.length > 0) {
					syncNextChat();
				}
			}
			return cVO;
		}
		
		private function getLocalChatByUserUID(userUID:String):ChatVO {
			if (localChats == null || localChats.length == 0)
				return null;
			var l:int = localChats.length;
			for (var i:int = 0; i < l; i++)
				if (localChats[i].users != null && localChats[i].users.length == 1 && localChats[i].users[0].uid == userUID)
					return localChats[i];
			return null;
		}
		
		static private function createLocalChat(userUID:String):ChatVO {
			var userModel:UserVO = UsersManager.getFullUserData(userUID, false);
			var avatar:String = "";
			var userName:String = "User";
			if (userModel) {
				avatar = userModel.getAvatarURL();
				userName = userModel.getDisplayName();
			}
			
			var chatData:Object = new Object();
			chatData.uid = ChatVO.LOCAL_CHAT_FLAG + (new Date()).getTime().toString();
			chatData.avatar = avatar;
			chatData.unreaded = 0;
			
			chatData.created = chatData.accessed = (new Date()).getTime() / 1000;
			chatData.securityKey = TextUtils.generateRandomString(32);
			chatData.type = ChatRoomType.PRIVATE;
			chatData.ownerID = Auth.uid;
			chatData.pushAllowed = true;
			chatData.users = new Array();
				var userData:Object = new Object();
				userData.avatar = avatar;
				userData.name = userName;
				userData.uid = userUID;
			chatData.users.push(userData);
			
			return new ChatVO(chatData);
		}
		
		private function syncNextChat():void {
			if (!WS.connected || !NetworkManager.isConnected)
				return;
			if (!ChatManager.latestsResponded)
				return;
			if (busy)
				return;
			if (localChats.length > 0) {
				needUpdateMessage = true;
				busy = true;
				var chatToSync:ChatVO = localChats.shift() as ChatVO;
				PHP.chat_startOffline(function(respond:PHPRespond):void {
					if (respond.error) {
						if (respond.errorMsg.toLowerCase() == PHP.NETWORK_ERROR) {
							//no network, return chat model to pending list;
							localChats.push(chatToSync);
							busy = false;
						} else {
							//!TODO: handle errors;
							syncNextChat();
						}
					} else {
						if (("data" in respond) && respond.data && ("securityKey" in respond.data) && ("uid" in respond.data)) {
							if (respond.data.securityKey == chatToSync.securityKey) {
								//new chat, just update chatUID in messages;
								SQLite.updateChatUidInMessages(function(r:SQLRespond):void {
									if (r.error) {
										//!TODO: handle error;
									}
									finishUpdateChat(chatToSync, respond);
								}, chatToSync.uid, respond.data.uid);
							} else {
								//existing chat, need to update message crypt, chatUID;
								SQLite.call_getMessages(function(r:SQLRespond):void {
									if (r.error) {
										//!TODO: handle error;
										finishUpdateChat(chatToSync, respond);
									} else if(r.data && (r.data is Array) && (r.data as Array).length > 0) {
										var messages:Array = r.data;
										var l:int = messages.length;
										for (var i:int = 0; i < l; i++) {
											messages[i].chat_uid = respond.data.uid;
											messages[i].text = Crypter.crypt(Crypter.decrypt(messages[i].text, chatToSync.securityKey), respond.data.securityKey);
										}
										SQLite.call_updateMessages_chatUid_text(function(r:SQLRespond):void {
											if (r.error) {
												//!TODO: handle error;
												finishUpdateChat(chatToSync, respond);
											} else {
												finishUpdateChat(chatToSync, respond);
											}
										}, messages);
									} else {
										//no messages in chat;
										finishUpdateChat(chatToSync, respond);
									}
								}, chatToSync.uid, -1, 400);
							}
						} else {
							//!TODO: error;
							syncNextChat();
						}
					}
					
				}, chatToSync.users[0].uid, chatToSync.securityKey);
			} else {
				busy = false;
				if (needUpdateMessage) {
					needUpdateMessage = false;
					MessagesController.sendPendingMessagesFromSQL();
				}
			}
		}
		
		private function finishUpdateChat(chatToSync:ChatVO, respond:PHPRespond):void {
			//update chat model;
			updateLocalChatModel(chatToSync, respond.data);
			
			//update latests in Store;
			S_CHAT_UPDATED.invoke(chatToSync);
			if (ChatManager.getCurrentChat() && ChatManager.getCurrentChat().uid == chatToSync.uid)
				ChatManager.openChatByUID(chatToSync.uid);
			busy = false;
			
			syncNextChat();
			respond.dispose();
		}
		
		private function updateLocalChatModel(chatToSync:ChatVO, data:Object):void {
			if ("uid" in data)
				chatToSync.uid = data.uid;
			else { /*crit error*/ }
			if ("created" in data)
				chatToSync.created = data.created * 1000;
			else { /*crit error*/ }
			if ("accessed" in data)
				chatToSync.accessed = data.accessed;
			else { /*crit error*/ }
			if ("securityKey" in data)
				chatToSync.updateSecurityKey(data.securityKey);
			else { /*crit error*/ }
			if ("ownerID" in data)
				chatToSync.ownerUID = data.ownerID;
			else { /*crit error*/ }
		}
		
		private function clear():void {
			busy = false;
			localChats = null;
			localChats = new Array();
		}
		
		private function stopUploadTimer():void {
			if (uploadTimer) {
				uploadTimer.removeEventListener(TimerEvent.TIMER, tryUpload);
				uploadTimer.stop();
				uploadTimer = null;
			}
		}
		
		public function destroy():void {
			localChats = null;
		}
		
		public function removeChat(chatVO:ChatVO):void 
		{
			if (localChats != null && localChats.length > 0)
			{
				var index:int = localChats.indexOf(chatVO);
				if (index != -1)
				{
					localChats.removeAt(index);
				}
			}
			//!TODO: удалить сообщения;
		}
		
		public function getLocalChatFromMessage(messageData:Object):ChatVO 
		{
			var chat:ChatVO;
			if (localChats != null)
			{
				var l:int = localChats.length;
				for (var i:int = 0; i < l; i++)
				{
					if (localChats[i].uid == messageData.chatUID)
					{
						return localChats[i];
					}
				}
			}
			if (chat == null)
			{
				var userModel:UserVO = UsersManager.getFullUserData(messageData.user_uid, false);
				var avatar:String = "";
				var userName:String = "User";
				if (userModel) {
					avatar = messageData.user_avatar;
					userName = messageData.user_name;
				}
				
				var chatData:Object = new Object();
				chatData.uid = messageData.chat_uid;
				chatData.avatar = avatar;
				chatData.unreaded = 0;
				
				chatData.created = chatData.accessed = (new Date()).getTime() / 1000;
				chatData.securityKey = LOCAL_INCOME_CHAT_FLAG + TextUtils.generateRandomString(32 - LOCAL_INCOME_CHAT_FLAG.length);
				chatData.type = ChatRoomType.PRIVATE;
				chatData.pushAllowed = true;
				chatData.ownerID = messageData.user_uid;
				chatData.users = new Array();
				
				var userData:Object = new Object();
				if (avatar != "")
				{
					userData.avatar = avatar;
				}
				if (userName != "User")
				{
					userData.name = userName;
				}
					
				userData.uid = messageData.user_uid;
				chatData.users.push(userData);
				chat = new ChatVO(chatData);
			//	localChats.push(chat);
				chat.incomeLocal = true;
				ChatManager.addChatToLatest(chat);
				ChatManager.S_LATEST.invoke();
			}
			return chat;
		}
		
		public function getLocalChatByUID(chatUID:String):ChatVO 
		{
			if (localChats == null || localChats.length == 0)
				return null;
			var l:int = localChats.length;
			for (var i:int = 0; i < l; i++)
			{
				if (localChats[i].uid == chatUID)
					return localChats[i];
			}
			return null;
		}
	}
}