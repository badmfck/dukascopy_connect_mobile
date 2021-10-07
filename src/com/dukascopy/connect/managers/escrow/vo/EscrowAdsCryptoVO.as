package com.dukascopy.connect.managers.escrow.vo {
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class EscrowAdsCryptoVO {
		
		private var _instrument:EscrowInstrument;
		private var _mcaCurrency:String = "All";
		private var _side:String = "Both";
		private var _maxID:int = 0;
		private var _count:int = 0;
		private var _volume:Number = 0;
		
		public function EscrowAdsCryptoVO(data:Object) {
			if ("instrument" in data == true)
				_instrument = data["instrument"];
			if ("mca_ccy" in data == true)
				_mcaCurrency = data["mca_ccy"];
			if ("side" in data == true)
				_side = data["side"];
			if ("maxId" in data == true)
				_maxID = data["maxId"];
			if ("cnt" in data == true)
				_count = data["cnt"];
			if ("volume" in data == true)
				_volume = data["volume"];
		}
		
		public function get instrument():EscrowInstrument { return _instrument; }
		public function get mcaCurrency():String { return _mcaCurrency; }
		public function get side():String { return _side; }
		public function get maxID():int { return _maxID; }
		public function get count():int { return _count; }
		public function get volume():Number { return _volume; }
		public function get instrumentCode():String { return (_instrument != null) ? _instrument.code : null; }
		
		public function dispose():void {
			_instrument = null;
			_mcaCurrency = null;
			_side = null;
			_maxID = 0;
			_count = 0;
			_volume = 0;
		}
	}
}