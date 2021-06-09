package com.dukascopy.connect.utils 
{
	import com.dukascopy.connect.sys.payments.CurrencyHelpers;
	import com.dukascopy.connect.sys.payments.PayManager;
	import com.dukascopy.langs.Lang;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class NumberFormat 
	{
		
		public function NumberFormat() 
		{
			
		}
		
		static public function formatAmount(amount:Number, currency:String):String 
		{
			if (isNaN(amount))
			{
				amount = 0;
			}
			var decimals:int = 2;
			if (PayManager.systemOptions != null && PayManager.systemOptions.currencyDecimalRules != null && PayManager.systemOptions.currencyDecimalRules[currency] != null)
			{
				decimals = PayManager.systemOptions.currencyDecimalRules[currency];
			}
			else
			{
				decimals = CurrencyHelpers.getMaxDecimalCount(currency);
			}
			
			var resultCurrency:String = currency;
			if (Lang[resultCurrency] != null)
			{
				resultCurrency = Lang[resultCurrency];
			}
			return amount.toFixed(decimals) + " " + resultCurrency;
		}
	}
}