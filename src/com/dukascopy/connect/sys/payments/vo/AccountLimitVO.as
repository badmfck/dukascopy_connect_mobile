package com.dukascopy.connect.sys.payments.vo {
	
	import com.dukascopy.langs.Lang;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class AccountLimitVO {
		
		private var _type:String = "";
		private var _current:Number = 0;
		private var _maxLimit:Number = 0;
		private var _currency:String = "";
		private var _percent:Number;
		private var _marginBottom:Boolean = false;
		private var _resetDate:String = "";
		
		public function AccountLimitVO(data:Array) {
			if (data == null)
				return;
			_type = String(data[0]);
			_current = Number(data[1]);
			_maxLimit = Number(data[2]);
			if (data.length > 3)
				_currency = String(data[3]);
			if (data.length > 4)
				_marginBottom = String(data[4]);
			setResetDate();
		}
		
		private function setResetDate():void {
			var date:Date = new Date();
			if (date.getMonth() > 8)
				_resetDate = Lang.resetDate1Jan + " " + (date.getFullYear() + 1);
			else if (date.getMonth() > 5)
				_resetDate = Lang.resetDate1Oct + " " + date.getFullYear();
			else if (date.getMonth() > 2)
				_resetDate = Lang.resetDate1Jul + " " + date.getFullYear();
			else
				_resetDate = Lang.resetDate1Apr + " " + date.getFullYear();
		}
		
		public function dispose():void {
			_type = "";
			_current = 0;
			_maxLimit = 0;
			_currency = "";
			_resetDate = "";
		}
		
		public function get type():String { return _type; }
		public function get current():Number { return _current; }
		public function get maxLimit():Number { return _maxLimit; }
		public function get currency():String { return _currency; }
		public function get marginBottom():Boolean { return _marginBottom; }
		public function get resetDate():String { return _resetDate; }
		public function get percent():Number {
			if (isNaN(_percent) == true)
				_percent = current * 100 / maxLimit;
			return _percent;
		}
	}
}