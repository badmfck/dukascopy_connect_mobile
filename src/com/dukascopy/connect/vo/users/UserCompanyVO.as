package com.dukascopy.connect.vo.users {
	import com.dukascopy.connect.vo.StandartVO;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class UserCompanyVO extends StandartVO {
		
		private var _name:String;
		private var _companyInternalPhone:String;
		
		public function UserCompanyVO() { }
		
		public function setData(data:Object):Boolean {
			return true;
		}
		
		public function setDataFromChatUser(data:Object):Boolean {
			changed = false;
			_name = fillFieldObject(_name, data, "username") as String;
			_companyInternalPhone = fillFieldObject(_companyInternalPhone, data, "company_phone") as String;
			return changed;
		}
		
		public function dispose():void {
			_name = null;
			_companyInternalPhone = null;
		}
		
		public function get name():String { return (_name == null) ? "" : _name }
		public function get companyInternalPhone():String { return (_companyInternalPhone == null) ? "" : _companyInternalPhone }
	}
}