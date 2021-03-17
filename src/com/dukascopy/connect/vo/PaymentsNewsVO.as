package com.dukascopy.connect.vo {
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class PaymentsNewsVO {
		
		private const CONFIRMATION_REQUIRED:String = "confirmation required";
		
		private var _id:int;
		private var _header:String;
		private var _body:String;
		private var _type:String;
		
		private var _htmlString:String;
		
		private var confirmationRequired:Boolean;
		
		public function PaymentsNewsVO(data:Object) {
			_id = data.id;
			_header = data.header;
			_body = data.body;
			_type = data.type;
			
			confirmationRequired = (_type.toLowerCase() == CONFIRMATION_REQUIRED);
		}
		
		public function get id():int { return _id; }
		public function get isRequiredConfirmation():Boolean { return confirmationRequired; }
		public function get htmlString():String {
			if (_htmlString != null)
				return _htmlString;
			_htmlString = "<h4>" + _header + "</h4><hr>" + _body;
			return _htmlString;
		}
		
		public function dispose():void {
			_id = 0;
			_header = null;
			_body = null;
			_type = null;
			
			_htmlString = null;
			
			confirmationRequired = false;
		}
	}
}