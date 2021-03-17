package com.dukascopy.connect.sys.permissionsManager {
	
	/**
	 * ...
	 * @author David Gnatkivskij. Telefision TEAM Kiev.
	 */
	
	public class AskPermissionsStateVO {
		
		private var _isAbleToRequestContacts:Boolean = true;
		private var _isAbleToRequestNotificatioins:Boolean = true;
		
		public function AskPermissionsStateVO(data:Object = null) {
			if (data == null)
				return;
			setData(data);
		}
		
		public function getData():Object {
			var res:Object = {};
			res.isAbleToRequestContacts = _isAbleToRequestContacts;
			res.isAbleToRequestNotificatioins = _isAbleToRequestNotificatioins;
			return res;
		}
		
		private function setData(data:Object):void {
			if ("isAbleToRequestContacts" in data)
				_isAbleToRequestContacts = data.isAbleToRequestContacts;
			if ("isAbleToRequestNotificatioins" in data)
				_isAbleToRequestNotificatioins = data.isAbleToRequestNotificatioins;
		}
		
		public function get isAbleToRequestNotificatioins():Boolean { return _isAbleToRequestNotificatioins; }
		public function set isAbleToRequestNotificatioins(value:Boolean):void {
			_isAbleToRequestNotificatioins = value;
		}
		
		public function get isAbleToRequestContacts():Boolean { return _isAbleToRequestContacts; }
		public function set isAbleToRequestContacts(value:Boolean):void {
			_isAbleToRequestContacts = value;
		}
	}
}