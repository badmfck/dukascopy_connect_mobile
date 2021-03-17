package com.dukascopy.connect.sys.usersManager {
	
	import com.dukascopy.connect.sys.usersManager.UserAvatar;
	import com.dukascopy.connect.vo.users.UserVO;
	import com.telefision.sys.signals.Signal;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class AvatarsManager {
		
		static public var S_AVATAR_CHANGED:Signal = new Signal("UserManager.S_USER_FULL_DATA");
		
		static private var avatars:Object;
		
		public function AvatarsManager() { }
		
		static public function init():void {
			UsersManager.S_USER.add(onUserCreated);
			UsersManager.S_USER_UPDATED(onUserUpdated);
			UsersManager.S_USER_REMOVED(onUserRemoved);
		}
		
		static private function onUserCreated(userVO:UserVO):void {
			avatars ||= { };
			avatars[userVO.uid] = new UserAvatar();
		}
		
		static private function onUserUpdated(userVO:UserVO):void {
			if (avatars == null)
				return;
			if (userVO.uid in avatars == false)
				return;
			if (avatars[userVO.uid].update(userVO) == true)
				S_AVATAR_CHANGED.invoke(avatars[userVO.uid]);
		}
		
		static private function onUserRemoved():void {
			if (avatars == null)
				return;
			if (userVO.uid in avatars == false)
				return;
			avatars[userVO.uid].dispose(userVO);
		}
	}
}