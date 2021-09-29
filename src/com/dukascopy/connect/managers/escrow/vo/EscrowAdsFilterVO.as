package com.dukascopy.connect.managers.escrow.vo {
	import com.dukascopy.connect.sys.auth.Auth;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class EscrowAdsFilterVO {
		
		public var side:String;
		public var instrument:EscrowInstrument;
		public var currency:String;
		public var sort:String;
		public var hideBlocked:Boolean;
		public var hideNoobs:Boolean;
		public var countries:Array;
		
		static public const SORT_DATE:String = "sortDate";
		static public const SORT_PRICE:String = "sortPrice";
		static public const SORT_AMOUNT:String = "sortAmount";
		static public const SORT_BUY_SELL:String = "sortBuySell";
		
		
		public function EscrowAdsFilterVO() { }
		
		public function clone():EscrowAdsFilterVO 
		{
			var result:EscrowAdsFilterVO = new EscrowAdsFilterVO();
			result.side = side;
			result.instrument = instrument;
			result.currency = currency;
			result.sort = sort;
			result.hideBlocked = hideBlocked;
			result.hideNoobs = hideNoobs;
			if (countries != null)
			{
				result.countries = new Array();
				var l:int = countries.length;	
				for (var i:int = 0; i < l; i++) 
				{
					result.countries.push(countries[i]);
				}
			}
			return result;
		}
		
		public function get filter():Object {
			var res:Object = {};
			if (side != null && side != "")
				res.side = side;
			if (instrument != null)
				res.instrument = instrument.code;
			if (currency != null && currency != "")
				res.mca_ccy = currency;
			if (countries != null && countries.length != 0)
				res.countriesExclude = countries;
			if (hideBlocked == true) {
				if (Auth.blocked != null && Auth.blocked.length != 0)
					res.usersExclude = Auth.blocked;
			}
			return res;
		}
	}
}