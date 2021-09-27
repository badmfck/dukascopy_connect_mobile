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
		public var countries:Array;
		
		public function EscrowAdsFilterVO() { }
		
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