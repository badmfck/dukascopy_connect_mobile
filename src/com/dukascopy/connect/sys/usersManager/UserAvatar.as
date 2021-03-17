package com.dukascopy.connect.sys.usersManager {
	
	import com.dukascopy.connect.gui.avatar.UserAvatarView;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class UserAvatar {
		
		private var _view:UserAvatarView;
		private var _userUID:String;
		
		public function UserAvatar(userUID:String) {
			_userUID = userUID;
			
			_view = new UserAvatarView();
		}
		
		public function update():Boolean {
			
		}
		
		public function dispose():void {
			
		}
		
		public function get view():UserAvatarView { return _view; }
		public function get userUID():String { return _userUID; }
	}
}