package com.dukascopy.connect.sys.chatManager {
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.store.Store;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class ChatUsersManager {
		
		static private var chatUsers:Array;
		
		public function ChatUsersManager() { }
		
		static public function init():void {
			onLoad(Auth.getItem(Store.VAR_CHAT_USERS_APPROVED));
			Auth.S_NEED_AUTHORIZATION.add(clear);
		}
		
		static private function clear():void {
			Auth.removeItem(Store.VAR_CHAT_USERS_APPROVED);
		}
		
		static private function onLoad(data:String = null):void {
			if (data == null)
				return;
			chatUsers = data.split(",");
		}
		
		static public function checkForApproved(uid:String):Boolean {
			if (chatUsers == null || chatUsers.length == 0)
				return false;
			var l:int = chatUsers.length;
			for (var i:int = 0; i < l; i++) {
				if (chatUsers[i] == uid)
					return true;
			}
			return false;
		}
		
		static public function addUserApproved(uid:String):void {
			if (checkForApproved(uid) == true)
				return;
			chatUsers ||= [];
			chatUsers.push(uid);
			saveToStore();
		}
		
		static private function saveToStore():void {
			if (chatUsers == null || chatUsers.length == 0)
				return;
			var tmp:String = "";
			var l:int = chatUsers.length;
			for (var i:int = 0; i < l; i++) {
				if (tmp != "")
					tmp += ",";
				tmp += chatUsers[i];
			}
			Auth.setItem(Store.VAR_CHAT_USERS_APPROVED, tmp)
		}
	}
}