package com.dukascopy.connect.data.escrow 
{
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class TradeDirection 
	{
		private var _type:String;
		private static const BUY_TYPE:String = "buy";
		private static const SELL_TYPE:String = "sell";
		
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
		
		static public function getDirection(value:String):TradeDirection 
		{
			switch(value)
			{
				case BUY_TYPE:
				{
					return buy;
					break;
				}
				case SELL_TYPE:
				{
					return sell;
					break;
				}
			}
			return null;
		}
	}
}