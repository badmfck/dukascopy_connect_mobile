package com.dukascopy.connect.data.coinMarketplace {
	
	import com.telefision.sys.signals.Signal;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class MarketplaceScreenData {
		
		public var dataProvider:Function;
		public var resreshFunction:Function;
		public var updateSignal:Signal;
		public var tradeFunction:Function;
		public var tradeSignal:Signal;
		public var createLotFunction:Function;
		public var type:int;
		public var myOrders:Function;
		public var bestPrice:Number;
		
		public function MarketplaceScreenData() {
			
		}
	}
}