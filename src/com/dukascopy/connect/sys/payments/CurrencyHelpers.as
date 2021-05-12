package com.dukascopy.connect.sys.payments {
	import com.dukascopy.langs.Lang;
	
	/**
	 * ...
	 * @author Alexey Skuryat
	 */

	public class CurrencyHelpers {
		
		private static var decimalRules:Object = {
			"JPY": 0,
			"JPN": 5,
			"CHE": 6,
			"XAG": 4,
			"XAU": 6,
			"GAS": 3,
			"OIL": 4,
			"USA": 7,
			"CHE": 6,
			"GBR": 6,
			"FRA": 6,
			"DEU": 7,
			"JPN": 5,
			"BTC": 8,
			"ETH": 8,
			"LTC": 8,
			"DCO": 4,
			"MSF": 5,
			"GOO": 6,
			"NFL": 5,
			"TSL": 5,
			"AAP": 5,
			"NVD": 5,
			"AMZ": 6,
			"FBU": 5,
			"UST": 6,
			"US5": 6
		};
		
		private static var currencySymbols:Object =	{
			"EUR": "€",
			"CHF": "Fr",
			"USD": "$",
			"GBP": "£",
			"AUD": "A$",
			"CAD": "C$",
			"PLN": "zł",
			"RUB": "RUB",
			"JPY": "¥",
			"CNH": "CNH",
			"DKK": "kr",
			"SEK": "kr",
			"NOK": "kr",
			"SGD": "S$",
			"HKD": "HK$",
			"MXN": "$",
			"NZD": "NZ$",
			"TRY": "₺",
			"ZAR": "R",
			"CZK": "Kč",
			"HUF": "Ft",
			"ILS": "₪",
			"RON": "lei",
			"XAG": "ounce",
			"XAU": "ounce",
			"GAS": "MMBTU",
			"OIL": "barrel",
			"USA": "contracts",
			"CHE": "contracts",
			"GBR": "contracts",
			"FRA": "contracts",
			"DEU": "contracts",
			"JPN": "contracts",
			"US5": "contracts",
			"UST": "contracts",
			"BTC": "Ƀ",
			"ETH": "Ξ",
			"DCO": "DUK+",
			"AMZ": "shares",
			"FBU": "shares",
			"MSF": "shares",
			"GOO": "shares",
			"NFL": "shares",
			"TSL": "shares",
			"AAP": "shares",
			"NVD": "shares",
			"ADS": "shares",
			"AIR": "shares",
			"BAR": "shares",
			"BMW": "shares",
			"BOS": "shares",
			"BPG": "shares",
			"CAR": "shares",
			"ORF": "shares",
			"MCF": "shares",
			"DAI": "shares",
			"NES": "shares",
			"RNO": "shares",
			"SAE": "shares",
			"129": "shares",
			"070": "shares",
			"675": "shares",
			"450": "shares",
			"720": "shares",
			"LTC": "coins"
		};
		
		private static var fromLang:Array = ["coins", "contracts", "shares", "barrel", "ounce"];
		
		private static var supportedCardsCurrencies:Array = ["EUR","USD","GBP","CHF"];
		
		public function CurrencyHelpers() { }
		
		public static function getCurrencyByKey(key:String):String {
			if (key == null)
				return "";			
			var result:String = currencySymbols[key];
			if (result == null)
				result = key;
			if (fromLang.indexOf(result) != -1)
				result = Lang.investmentsCurrency[result];
			return result;
		}
		
		/**
		 * Check if currency is supporting decimal 
		 * @param	currency
		 * @param	value
		 * @return
		 */
		public static function isValidDecimalForCurrency(currency:String, value:String):Boolean {
			if (currency == null || currency == "") return false;
			if (value == null) return false;
			var nr:Number = Number(value);
			if (isNaN(nr)) return false;
			
			var dotIndex:int = value.indexOf(".");
			if (dotIndex !=-1){// Decimal number  		
					var leftPart:String = "";
					var rightPart:String = "";		
					var maxDecimalSymbols:int = getMaxDecimalCount(currency);									
					var rightPartLength:int  = value.length - dotIndex;					
					leftPart = value.substring(0, dotIndex);
					rightPart = value.substr(dotIndex + 1, rightPartLength);			
					var rightPartAsNumber:Number = Number(rightPart);
					if (rightPartAsNumber == 0){
						return true;
					}else{
						return  rightPart.length <= maxDecimalSymbols;
					}
					
				}else{ // Full number 
					leftPart = value;
					rightPart = "";
					return true;
				}
		}
		
		
		public static function isAllowedDigitsCount(currency:String, value:String):Boolean
		{
			if (value == "") return false;
			var dotIndex:int = value.indexOf(".");
			if (dotIndex !=-1){
				if (dotIndex == 0) return false;// do not allow .55 kind values, without 0 or other digit before dot 
				var maxDecimalSymbols:int = getMaxDecimalCount(currency);	
				var rightPartLength:int  = value.length - dotIndex;
				var rightPart:String = value.substr(dotIndex + 1, rightPartLength);
				return  rightPart.length <= maxDecimalSymbols;
			}else{
				return true;
			}
		}
		
		public static function getMaxDecimalCount(currency:String):int{
			if (currency in decimalRules) {
				return  decimalRules[currency];
			} else {
				return 2;
			}
		}
		
		public static function getZerosForCurrency(currency:String ):String {
			var numDecimal:int  = getMaxDecimalCount(currency);
			var resultStr:String = "";
			for (var i:int = 0; i < numDecimal; i++) {
				resultStr += "0";
			}
			return resultStr;
		}
		
		public static function isCurrencySupportedInDukascopCards(currency:String):Boolean {
			return supportedCardsCurrencies.indexOf(currency) != -1;
		}
	}

}