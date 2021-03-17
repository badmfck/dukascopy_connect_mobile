package com.dukascopy.connect.data 
{
	/**
	 * ...
	 * @author SergeyDobarin
	 */
	public class OrederScreenData 
	{
		static public const TYPE_SELL_COINS:String = "typeSellCoins";
		static public const TYPE_BUY_COINS:String = "typeBuyCoins";
		
		public var type:String
		public var moneyAccounts:Array;
		public var coinsAccounts:Array;
		public var order:Object;
		public var title:String;
		public var callback:Function;
		public var additionalData:Object;
		
		public function OrederScreenData() 
		{
			
		}
	}
}