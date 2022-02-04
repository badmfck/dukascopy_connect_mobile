package com.dukascopy.connect.data.coinMarketplace 
{
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class CoinTradeEstimate 
	{
		public var coin_amount_value:Number;
		public var fiat_amount_before_fee:Number;
		public var fiat_amount_after_fee:Number;
		public var avg_price:Number;
		public var best_price:Number;
		public var worst_price:Number;
		public var currency:String;
		public var coin:String;
		public var low_liquidity_eur_per_coin:Number;
		public var low_liquidity_price_limit:Number;
		public var coin_amount:String;
		public var low_liquidity_fee:String;
		public var main_fee:String;
		public var total_fee:String;
		public var first_transaction_fee:String;
		
		public function CoinTradeEstimate() 
		{
			
		}
		
		static public function parse(data:Object):CoinTradeEstimate 
		{
			var result:CoinTradeEstimate;
			
			if (data != null)
			{
				result = new CoinTradeEstimate();
				
				if ("avg_price" in data)
					result.avg_price = Number(data.avg_price);
				
				if ("best_price" in data)
					result.best_price = Number(data.best_price);
				
				if ("worst_price" in data)
					result.worst_price = Number(data.worst_price);
				
				if ("currency" in data)
					result.currency = data.currency;
				
				if ("coin" in data)
					result.coin = data.coin;
				
				if ("low_liquidity_eur_per_coin" in data)
					result.low_liquidity_eur_per_coin = Number(data.low_liquidity_eur_per_coin);
				
				if ("low_liquidity_price_limit" in data)
					result.low_liquidity_price_limit = Number(data.low_liquidity_price_limit);
				
				if ("coin_amount" in data && data.coin_amount != null && "readable" in data.coin_amount)
					result.coin_amount = data.coin_amount.readable;
				
				if ("coin_amount" in data && data.coin_amount != null && "amount" in data.coin_amount)
					result.coin_amount_value = Number(data.coin_amount.amount);
				
				if ("low_liquidity_eur_per_coin" in data)
					result.low_liquidity_eur_per_coin = Number(data.low_liquidity_eur_per_coin);
				
				if ("fee" in data && data.fee != null)
				{
					if ("low_liquidity" in data.fee && data.fee.low_liquidity != null && "readable" in data.fee.low_liquidity)
					{
						result.low_liquidity_fee = data.fee.low_liquidity.readable;
					}
					if ("main" in data.fee && data.fee.main != null && "readable" in data.fee.main)
					{
						result.main_fee = data.fee.main.readable;
					}
					if ("total" in data.fee && data.fee.total != null && "readable" in data.fee.total)
					{
						result.total_fee = data.fee.total.readable;
					}
					if ("first_transaction" in data.fee && data.fee.first_transaction != null && "readable" in data.fee.first_transaction)
					{
						result.first_transaction_fee = data.fee.first_transaction.readable;
					}
				}
				
				if ("fiat_amount_after_fee" in data && data.fiat_amount_after_fee != null && "amount" in data.fiat_amount_after_fee)
					result.fiat_amount_after_fee = Number(data.fiat_amount_after_fee.amount);
				
				if ("fiat_amount_before_fee" in data && data.fiat_amount_before_fee != null && "amount" in data.fiat_amount_before_fee)
					result.fiat_amount_before_fee = Number(data.fiat_amount_before_fee.amount);
			}
			
			return result;
			
			
					/*fiat_amount_after_fee : Object {
						amount : "94.49" 
						ccy_code : "EUR" 
						ccy_name : "EUR" 
						ccy_symbol : "€" 
						readable : "94.49 EUR" 
					}
					fiat_amount_before_fee : Object {
						amount : "102.50" 
						ccy_code : "EUR" 
						ccy_name : "EUR" 
						ccy_symbol : "€" 
						readable : "102.50 EUR" 
					}*/

		}
		
		public function fillCommission(data:Object):void 
		{
			if ("low_liquidity" in data && data.low_liquidity != null && "readable" in data.low_liquidity)
			{
				low_liquidity_fee = data.low_liquidity.readable;
			}
			if ("main" in data && data.main != null && "readable" in data.main)
			{
				main_fee = data.main.readable;
			}
			if ("total" in data && data.total != null && "readable" in data.total)
			{
				total_fee = data.total.readable;
			}
			if ("first_transaction" in data && data.first_transaction != null && "readable" in data.first_transaction)
			{
				first_transaction_fee = data..first_transaction.readable;
			}
		}
	}
}