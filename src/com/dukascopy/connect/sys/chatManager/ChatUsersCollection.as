package com.dukascopy.connect.sys.chatManager {
	
	import com.dukascopy.connect.sys.ws.WSClient;
	import com.dukascopy.connect.vo.ChatVO;
	import com.dukascopy.connect.vo.users.adds.ChatUserVO;
	import com.telefision.sys.signals.Signal;
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class ChatUsersCollection {
		
		private var chatModel:ChatVO;
		private var users:Dictionary;
		private var onlineNum:int;
		
		static public var S_USERLIST_CHANGED:Signal = new Signal('ChatUsersCollection.S_USERLIST_CHANGED');
		
		public function ChatUsersCollection() {
			WSClient.S_CHAT_USER_ENTER.add(onUserChatEnter);
			WSClient.S_CHAT_USER_EXIT.add(removeUser);
		}
		
		public function getOnlineUsersNum(chatUID:String):int {
			return Math.max(onlineNum, 1);
		}
		
		public function setChat(value:ChatVO):void {
			if (value != chatModel) {
				clear();
				chatModel = value;
				if (chatModel)
					users = new Dictionary();
			}
		}
		
		public function getUsersArray(chatUID:String = null):Array {
			var usersArray:Array = new Array();
			if (chatUID && chatModel && chatModel.uid != chatUID) {
				//TODO: запрашивается список онлайн юзеров не у текущего чата, архитектурная ошибка, выкинуть эксепшен и обработать в отчёте ошибок;
				return usersArray;
			} else if(!chatModel) {
				//TODO: запрашивается список онлайн юзеров, текущий чат не установлен, архитектурная ошибка, выкинуть эксепшен и обработать в отчёте ошибок;
				return usersArray;
			}
			for (var uid:String in users) {
				usersArray.push(users[uid]);
			}
			return usersArray;
		}
		
		public function removeUser(data:Object):void {
			if (chatModel == null)
				return;
			if (data && ("chatUID" in data) && data.chatUID == chatModel.uid && ("userUid" in data) && data.userUid) {
				if (data.userUid in users) {
					users[data.userUid] = null;
					delete users[data.userUid];
					onlineNum--;
					if (onlineNum < 0) {
						onlineNum = 0;
					}
					S_USERLIST_CHANGED.invoke();
				}
			}
		}
		
		public function onUserChatEnter(data:Object):void {
			if (!chatModel) {
				return;
			}
			if (data && ("chatUID" in data) && data.chatUID == chatModel.uid && ("users" in data) && (data.users is Array) && (data.users as Array).length > 0) {
				var l:int = (data.users as Array).length;
				var userData:ChatUserVO;
				for (var i:int = 0; i < l; i++) {
					addUser((data.users as Array)[i]);
				}
			} else if(("userUid" in data) && ("chatUID" in data) && data.chatUID == chatModel.uid) {
				data.uid = data.userUid;
				addUser(data);
			}
		}
		
		public function getUser(userUID:String):ChatUserVO {
			if (users && users[userUID])
				return users[userUID];
			return null;
		}
		
		private function addUser(userData:Object):void {
			var userModel:ChatUserVO = new ChatUserVO(userData, false);
			if (userModel.uid && !(userModel.uid in users)) {
				onlineNum ++;
				users[userModel.uid] = userModel;
				S_USERLIST_CHANGED.invoke();
			}
		}
		
		private function clear():void {
			onlineNum = 0;
			users = null;
		}
		
		public function get chatUID():String {
			if (chatModel != null)
				return chatModel.uid;
			return null;
		}
	}
}