package com.dukascopy.connect.data.coinMarketplace 
{
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class TradingOrderRequest 
	{
		public var requestID:String;
		public var orders:Array;
		public var quantity:Number;
		
		public function TradingOrderRequest() 
		{
			requestID = (new Date()).getTime().toString();
		}
		
		public function dispose():void 
		{
			orders = null;
		}
	}
}