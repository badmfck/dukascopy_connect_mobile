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
			"USA": "contract",
			"CHE": "contract",
			"GBR": "contract",
			"FRA": "contract",
			"DEU": "contract",
			"JPN": "contract",
			"US5": "contract",
			"UST": "contract",
			"BTC": "Ƀ",
			"ETH": "Ξ",
			"DCO": "DUK+",
			"AMZ": "share",
			"FBU": "share",
			"MSF": "share",
			"GOO": "share",
			"NFL": "share",
			"TSL": "share",
			"AAP": "share",
			"NVD": "share",
			"ADS": "share",
			"AIR": "share",
			"BAR": "share",
			"BMW": "share",
			"BOS": "share",
			"BPG": "share",
			"CAR": "share",
			"ORF": "share",
			"MCF": "share",
			"DAI": "share",
			"NES": "share",
			"RNO": "share",
			"SAE": "share",
			"129": "share",
			"070": "share",
			"675": "share",
			"450": "share",
			"720": "share",
			"LTC": "coin"
		};
		
		private static var fromLang:Array = ["coin", "contract", "share", "barrel", "ounce"];
		
		private static var supportedCardsCurrencies:Array = ["EUR","USD","GBP","CHF"];
		
		static public function updateDecimalsRulesAndSymbols(dr:Object, cs:Object = null):void {
			for (var n:String in dr)
				decimalRules[n] = dr[n];
			for (n in cs)
				currencySymbols[n] = cs[n];
		}
		
		static public function getCurrencyByKey(key:String):String {
			if (key == null)
				return "";
			if (key == "BTC")
				return "Ƀ";
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
		static public function isValidDecimalForCurrency(currency:String, value:String):Boolean {
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
		
		
		static public function isAllowedDigitsCount(currency:String, value:String):Boolean
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
		
		static public function getMaxDecimalCount(currency:String):int{
			if (currency in decimalRules) {
				return  decimalRules[currency];
			} else {
				return 2;
			}
		}
		
		static public function getZerosForCurrency(currency:String ):String {
			var numDecimal:int  = getMaxDecimalCount(currency);
			var resultStr:String = "";
			for (var i:int = 0; i < numDecimal; i++) {
				resultStr += "0";
			}
			return resultStr;
		}
		
		static public function isCurrencySupportedInDukascopCards(currency:String):Boolean {
			return supportedCardsCurrencies.indexOf(currency) != -1;
		}
	}
}