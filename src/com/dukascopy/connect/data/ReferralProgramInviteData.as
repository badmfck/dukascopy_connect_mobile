package com.dukascopy.connect.data {
	
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.vo.users.UserVO;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class ReferralProgramInviteData {
		
		public var user:UserVO;
		public var created:Number;
		public var updated:Number;
		public var status:String;
		public var reminded:Boolean = false;
		
		public function ReferralProgramInviteData(rawData:Object = null) {
			if (rawData != null)
				parse(rawData);
		}
		
		public function get avatarURL():String {
			if (user != null)
				return user.getAvatarURL();
			return null;
		}
		
		private function parse(data:Object):void {
			if (data != null) {
				if ("status" in data && data.status != null)
					status = data.status;
				if ("updated" in data)
					updated = Number(data.updated);
				if ("created" in data)
					created = Number(data.created);
				if ("user" in data && data.user != null)
					user = UsersManager.getUserByContactObject(data.user);
			}
		}
	}
}