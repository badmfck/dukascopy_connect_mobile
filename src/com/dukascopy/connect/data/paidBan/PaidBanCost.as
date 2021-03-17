package com.dukascopy.connect.data.paidBan 
{
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class PaidBanCost 
	{
		public var value:Number;
		public var currency:String;
		
		public function PaidBanCost(value:Number, currency:String) {
			this.value = value;
			this.currency = currency;
		}
	}
}