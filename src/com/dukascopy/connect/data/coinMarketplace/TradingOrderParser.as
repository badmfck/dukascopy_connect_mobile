package com.dukascopy.connect.data.coinMarketplace 
{
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class TradingOrderParser 
	{
		public function TradingOrderParser() 
		{
			
		}
		
		public function parse(raw:Object):TradingOrder 
		{
			if (isValid(raw))
			{
				var result:TradingOrder = new TradingOrder();
				
				result.active = raw.active;
				result.coin = raw.coin;
				result.created = raw.created;
				result.currency = raw.currency;
				//!TODO: type;
				if (!isNaN(Number(raw.deadline)))
				{
					if (Number(raw.deadline) > 0)
					{
						var date:Date = new Date();
						date.setTime(raw.deadline * 1000);
						result.deadline = date;
					}
				}
				result.deleted = raw.deleted;
				result.filled = raw.filled;
				result.id = raw.id;
				result.fillOrKill = raw.fill_or_kill;
				result.max_trade = raw.max_trade;
			//	result.min_trade = raw.min_trade;
				result.own = raw.own;
				result.price = parseFloat(raw.price);
				result.priceString = raw.price;
				result.publicOrder = raw["public"];
				result.quantity = parseFloat(raw.quantity);
				result.quantityString = raw.quantity;
				result.side = raw.side;  //side : "BUY" 
				result.trades_count = raw.trades_count;
				result.uid = raw.uid;
				result.updated = raw.updated;
				
				return result;
			}
			
			return null;
		}
		
		private function isValid(raw:Object):Boolean 
		{
			//!TODO:;
			
			return true;
		}
	}
}