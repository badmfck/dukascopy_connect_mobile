package com.dukascopy.connect.data.escrow 
{
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class TradeDirection 
	{
		private var _type:String;
		public static const BUY_TYPE:String = "buy";
		public static const SELL_TYPE:String = "buy";
		
		public static const buy:TradeDirection = new TradeDirection(TradeDirection.BUY_TYPE);
		public static const sell:TradeDirection = new TradeDirection(TradeDirection.SELL_TYPE);
		
		public function get type():String 
		{
			return _type;
		}
		
		public function TradeDirection(type:String) 
		{
			this._type = type;
		}
	}
}