package com.dukascopy.connect.sys.payments {
	
	import com.dukascopy.langs.Lang;
	
	/**
	 * ...
	 * @author Alexey Skuryat
	 */
	
	public class PayInvestmentsManager {
		
		public function PayInvestmentsManager() {}
		
		public static function getInvestmentNameByInstrument(currency:String):String{
			return Lang.investmentsTitles[currency];
		}
	}
}