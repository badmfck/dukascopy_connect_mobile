package com.dukascopy.connect.sys.applicationShop.serverTask 
{
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class PaidBanRequestData 
	{
		public var incognito:Boolean;
		public var reason:int;
		public var days:int;
		public var userUID:String;
		
		public function PaidBanRequestData(userUID:String, days:int, reason:int, incognito:Boolean) 
		{
			this.userUID = userUID;
			this.days = days;
			this.reason = reason;
			this.incognito = incognito;
		}
	}
}