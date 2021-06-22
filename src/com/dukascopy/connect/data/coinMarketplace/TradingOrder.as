package com.dukascopy.connect.data.coinMarketplace 
{
	import com.dukascopy.connect.vo.users.UserVO;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class TradingOrder 
	{
		public var suboffers:Vector.<TradingOrder>;
		
		static public const BUY:String = "BUY";
		static public const SELL:String = "SELL";
		
		public var active:Boolean;
		public var coin:String;
		public var created:Number;
		public var currency:String;
		public var deadline:Date;
		public var deleted:Boolean;
		public var filled:Boolean;
		public var id:Number;
		public var own:Boolean;
		public var price:Number;
		public var priceString:String;
		public var publicOrder:Boolean = true;
		public var side:String;
		public var trades_count:Number;
		public var uid:String;
		public var updated:Number;
	//	public var min_trade:Number;
		public var max_trade:Number;
		public var quantity:Number;
		public var quantityString:String;
		public var userVO:UserVO;
		
		public var first:Boolean;
		public var last:Boolean;
		public var middle:Boolean;
		
		public var _min:Number;
		public var startValue:Number = 0;
		public var fillOrKill:Boolean;
		
		public function TradingOrder() 
		{
			
		}
		
		public function addSuboffer(tradingOrder:TradingOrder):void {
			if (suboffers == null)
				suboffers = new Vector.<TradingOrder>();
			suboffers.push(tradingOrder);
		}
		
		public function get avatar():String {
			return null;
		}
	}
}