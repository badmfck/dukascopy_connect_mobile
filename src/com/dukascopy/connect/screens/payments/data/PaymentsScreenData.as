package com.dukascopy.connect.screens.payments.data {
	
	public class PaymentsScreenData extends Object {
		
		public var title:String;
		private var _backScreen:Class;
		private var _backScreenData:Object = {};
		private var _autofillData:Object= {};
		
		public function PaymentsScreenData() {
			super();
		}
		
		public function get backScreen():Class {
			return _backScreen;
		}
		
		public function set backScreen(value:Class):void {
			_backScreen = value;
		}
		
		public function get autofillData():Object {
			return _autofillData;
		}
		
		public function set autofillData(value:Object):void {
			_autofillData = value;
		}
		
		public function get backScreenData():Object {
			return _backScreenData;
		}
		
		public function set backScreenData(value:Object):void {
			_backScreenData = value;
		}
	}
}