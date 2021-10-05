package com.dukascopy.connect.data.escrow {
	
	import com.dukascopy.langs.Lang;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class EscrowSide {
		
		public static const BUY:EscrowSide = new EscrowSide("textQuestionSideBuy", "buy");
		public static const SELL:EscrowSide = new EscrowSide("textQuestionSideSell", "sell");
		
		public static const COLLECTION:Vector.<EscrowSide> = new <EscrowSide>[BUY, SELL];
		
		private var _name:String;
		private var _value:String;
		
		public function EscrowSide(name:String, value:String) {
			_name = name;
			_value = value;
		}
		
		public function get name():String { return Lang[_name]; }
		public function get lang():String { return _name; }
		public function get value():String { return _value; }
		
		public function toString():String {
			return _value;
		}
	}
}