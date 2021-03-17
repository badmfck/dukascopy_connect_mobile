package com.dukascopy.connect.data.coinMarketplace 
{
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class TradingResponse 
	{
		public var quantity:Number;
		public var complete:Boolean;
		public var wasSuccess:Boolean;
		
		public var debit_currency:String;
		public var debit_amount:Number = 0;
		public var credit_amount:Number = 0;
		public var credit_currency:String;
		public var price:Number = 0;
		
		public function TradingResponse() 
		{
			
		}
	}
}