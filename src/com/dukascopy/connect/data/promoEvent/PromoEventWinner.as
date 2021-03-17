package com.dukascopy.connect.data.promoEvent 
{
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.vo.users.UserVO;
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev
	 */
	public class PromoEventWinner 
	{
		public var user:UserVO;
		public var amount:Number;
		public var currency:String;
		public var userUID:String;
		public var id:String;
		public var win_time:Number;
		
		public function PromoEventWinner(rawData:Object) 
		{
			if (rawData != null)
			{
				parse(rawData);
			}
		}
		
		public function dispose():void 
		{
			UsersManager.removeUser(user);
		}
		
		public function get avatarURL():String
		{
			if (user != null)
			{
				return user.avatarURL;
			}
			return null;
		}
		
		private function parse(rawData:Object):void 
		{
			if ("lotto_id" in rawData)
			{
				id = rawData.lotto_id;
			}
			if ("user" in rawData && rawData.user != null && "uid" in rawData.user)
			{
				userUID = rawData.user.uid;
				user = UsersManager.getUserByContactObject(rawData.user);
			}
			if ("win_time" in rawData)
			{
				win_time = rawData.win_time;
			}
			if ("currency" in rawData)
			{
				currency = rawData.currency;
			}
			if ("amount" in rawData)
			{
				amount = rawData.amount;
			}
		}
	}
}