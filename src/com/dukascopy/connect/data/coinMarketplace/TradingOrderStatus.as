package com.dukascopy.connect.data.coinMarketplace 
{
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class TradingOrderStatus 
	{
		static public const STATUS_NEW:String = "statusNew";
		static public const STATUS_PROCESS:String = "statusProcess";
		static public const STATUS_FAILED:String = "statusFailed";
		static public const STATUS_SUCCESS:String = "statusSuccess";
		
		public var order:TradingOrder;
		public var status:String;
		public var errorText:String;
		public var money:String = "0.00 EUR";
		public var quantity:String = "0.0000 DUK+";
		
		public function TradingOrderStatus(order:TradingOrder) 
		{
			this.order = order;
			status = STATUS_NEW;
		}
	}
}