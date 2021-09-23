package com.dukascopy.connect.data.escrow 
{
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class EscrowDealData 
	{
		public var price:Number;
		public var amount:Number;
		public var direction:TradeDirection;
		public var currency:String;
		public var instrument:String;
		public var accountNumber:String;
		public var isPercent:Boolean;
		
		public function EscrowDealData() 
		{
			
		}
	}
}