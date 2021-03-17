package com.dukascopy.connect.screens.chat.selectAdressee {
	
	import com.dukascopy.connect.sys.usersManager.OnlineStatus;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.type.UserStatusType;
	
	/**
	 * ...
	 * @author David Gnatkivskij. Telefision TEAM Kiev.
	 */
	
	public class ListUsersItemModel implements IContactsChatsSelectionListItem {
		
		private var _contact:Object;
		private var _statusText:String;
		private var _status:int;
		private var _isListSelectable:Boolean;
		
		public function ListUsersItemModel(obj:Object, isListSelectable:Boolean) {
			_isListSelectable = isListSelectable;
			_contact = obj;
		}
		
		public function get statusText():String { return _statusText; }
		public function set statusText(value:String):void {
			_statusText = value;
		}
		
		public function get status():int { return _status; }
		public function set status(value:int):void {
			_status = value;
		}
		
		public function get contact():Object { return _contact; }
		public function get isListSelectable():Boolean { return _isListSelectable; }
		
		public function get avatarURL():Object { 
			if (contact)
				return contact.avatarURL; 
			return null;
		}
		
		public function get title():String {
			if (contact == null)
				return "";
			if (contact.name != null)
				return contact.name;
			return "";
		}
		
		public function get titleFirstLetter():String {
			if (title.length > 0)
				return title.charAt(0).toUpperCase();
			return "";
		}
		
		public function get isBlocked():Boolean {
			return status != UserStatusType.BLOCKED;
		}
		
		public function get isEmpty():Boolean {
			if (contact == null || !("uid" in contact) || contact.uid == null || contact.uid == "")
				return true;
			return false;
		}
		
		public function get onlineStatus():OnlineStatus {
			var res:OnlineStatus = UsersManager.isOnline(contact.uid);
			return res;
		}
		
		public function dispose():void{
			_contact = null;
			_statusText = null;
		}
	}
}