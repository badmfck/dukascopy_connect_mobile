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
		// Decimals loaded
		private var currencyDecimalRulesLoaded:Boolean=false;

		public function NumberFormat(){}
		
		static public function formatAmount(amount:Number, currency:String, removeCurrency:Boolean = false):String 
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
			
			var result:String = amount.toFixed(decimals);
			result = parseFloat(result).toString();
			if (currency != null && !removeCurrency)
			{
				var resultCurrency:String = currency;
				if (Lang[resultCurrency] != null)
				{
					resultCurrency = Lang[resultCurrency];
				}
				result += " " + resultCurrency;
			}
			
			return result;
		}
	}
}