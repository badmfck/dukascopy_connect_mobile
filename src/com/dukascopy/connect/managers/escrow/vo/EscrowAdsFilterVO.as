package com.dukascopy.connect.managers.escrow.vo {
	
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
	}
}