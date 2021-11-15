package com.dukascopy.connect.data 
{
	import com.telefision.sys.signals.Signal;
	/**
	 * ...
	 * @author SergeyDobarin
	 */
	public class OrderScreenData 
	{
		public var type:String
		public var orders:Array;
		public var title:String;
		public var callback:Function;
		public var additionalData:Object;
		public var resultSignal:Signal;
		public var localProcessing:Boolean;
		public var refresh:Function;
		public var bestPrice:Number;
		public var bestSellPrice:Number;
		public var bestBuyPrice:Number;
		public var reservedCoin:Number = 0;
		public var reservedFiat:Number = 0;
		
		public function OrderScreenData() 
		{
			
		}
	}
}