package com.dukascopy.connect.sys.applicationShop.serverTask 
{
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class PaidBanProtectionRequestData 
	{
		public var userUID:String;
		public var days:int;
		
		public function PaidBanProtectionRequestData(userUID:String, weeks:int) {
			this.userUID = userUID;
			this.days = weeks;
		}
	}
}