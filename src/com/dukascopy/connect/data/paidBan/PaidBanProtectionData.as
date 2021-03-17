package com.dukascopy.connect.data.paidBan 
{
	import com.dukascopy.connect.vo.users.UserVO;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class PaidBanProtectionData 
	{
		public var canceled:Number;
		public var id:int;
		public var payer_uid:String;
		public var user:UserVO;
		public var name:String;
		public var user_uid:String;
		public var created:Number;
		public var avatar:String;
		public var days:int = -1;
		public var payer:UserVO;
		
		public function PaidBanProtectionData() 
		{
			
		}
		
		public function dispose():void 
		{
			
		}
		
		public function get avatarURL():String {
			if (user != null) {
				return user.getAvatarURL();
			}
			return null;
		}
	}
}