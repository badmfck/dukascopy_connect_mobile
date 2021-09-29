package com.dukascopy.connect.managers.escrow.vo {
	import com.dukascopy.connect.sys.auth.Auth;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class EscrowAdsFilterVO {
		
		static public const SORT_DATE:String = "sortDate";
		static public const SORT_PRICE:String = "sortPrice";
		static public const SORT_AMOUNT:String = "sortAmount";
		static public const SORT_BUY_SELL:String = "sortBuySell";
		
		private var _side:String;
		private var _instrument:EscrowInstrument;
		private var _currency:String;
		private var _sort:String;
		private var _hideBlocked:Boolean;
		private var _hideNoobs:Boolean;
		private var _countries:Array;
		
		public var changed:Boolean;
		
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
			if (hideNoobs == true)
				res.hideNoobs = hideNoobs;
			return res;
		}
		
		public function get side():String { return _side; }
		public function set side(value:String):void {
			if (_side != value)
				changed = true;
			_side = value;
		}
		
		public function get instrument():EscrowInstrument { return _instrument; }
		public function set instrument(value:EscrowInstrument):void {
			if (_instrument != value)
				changed = true;
			_instrument = value;
		}
		
		public function get currency():String { return _currency; }
		public function set currency(value:String):void {
			if (_currency != value)
				changed = true;
			_currency = value;
		}
		
		public function get hideBlocked():Boolean { return _hideBlocked; }
		public function set hideBlocked(value:Boolean):void {
			if (_hideBlocked != value)
				changed = true;
			_hideBlocked = value;
		}
		
		public function get hideNoobs():Boolean { return _hideNoobs; }
		public function set hideNoobs(value:Boolean):void {
			if (_hideNoobs != value)
				changed = true;
			_hideNoobs = value;
		}
		
		public function get countries():Array { return _countries; }
		public function set countries(value:Array):void {
			if (_countries != value)
				changed = true;
			_countries = value;
		}
		
		public function get sort():String { return _sort; }
		public function set sort(value:String):void {
			_sort = value;
		}
	}
}