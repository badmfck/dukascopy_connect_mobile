package com.dukascopy.connect.data.paidBan 
{
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class PaidBanReason 
	{
		public var id:int;
		public var label:String;
		
		public function PaidBanReason(id:int, label:String) {
			this.id = id;
			this.label = label;
		}
	}
}