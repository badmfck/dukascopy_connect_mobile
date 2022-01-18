package com.dukascopy.connect.utils 
{
	import com.dukascopy.connect.screens.payments.card.TypeCurrency;
	import com.dukascopy.connect.sys.payments.CurrencyHelpers;
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
		
		static public function formatAmount(amount:Number, currency:String, removeCurrency:Boolean = false, addDecimals:Boolean = false):String 
		{
			if (currency == "DUK+")
			{
				currency = TypeCurrency.DCO;
			}
			if (isNaN(amount))
			{
				amount = 0;
			}
			var decimals:int = 2;
			decimals = CurrencyHelpers.getMaxDecimalCount(currency);
			
			var result:String = amount.toFixed(decimals);
			if (!addDecimals)
			{
				result = parseFloat(result).toString();
			}
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