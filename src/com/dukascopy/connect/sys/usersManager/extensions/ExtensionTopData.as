package com.dukascopy.connect.sys.usersManager.extensions 
{
	import com.dukascopy.connect.vo.users.UserVO;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class ExtensionTopData 
	{
		public var amount:Number;
		public var code:int;
		public var days:int;
		public var requests:int;
		public var user_uid:String;
		public var user:UserVO;
		
		public function ExtensionTopData() 
		{
			
		}
		
		public function get avatarURL():String
		{
			if (user != null)
			{
				return user.avatarURL;
			}
			return null;
		}
		
		public function dispose():void
		{
			
		}
	}
}