package com.dukascopy.connect.sys.applicationShop 
{
	import com.dukascopy.connect.sys.applicationShop.commodity.Commodity;
	import com.dukascopy.connect.sys.applicationShop.commodity.CommodityType;
	import com.telefision.sys.signals.Signal;
	/**
	 * ...
	 * @author ...
	 */
	public class CommodityShop 
	{
		static public var S_COMMODITIES:Signal = new Signal("CommodityShop.S_COMMODITIES");
		
		static private var commodities:Vector.<Commodity>;
		
		public function CommodityShop() 
		{
			
		}
		
		public static function getCommodities():Vector.<Commodity>
		{
			if (commodities == null)
			{
				loadCommodities();
			}
			
			return commodities;
		}
		
		static public function buyCommodity(type:String):void 
		{
			
		}
		
		static private function loadCommodities():void 
		{
			onCommoditiesLoaded();
		}
		
		static private function onCommoditiesLoaded():void 
		{
			commodities = getFakeCommodities();
		}
		
		static private function getFakeCommodities():Vector.<Commodity>
		{
			var data:Vector.<Commodity> = new Vector.<Commodity>();
			
			data.push(new Commodity(new CommodityType(CommodityType.TYPE_OIL)));
			data.push(new Commodity(new CommodityType(CommodityType.TYPE_GOLD)));
			data.push(new Commodity(new CommodityType(CommodityType.TYPE_BTC)));
			
			return data;
		}
	}
}