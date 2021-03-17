package com.dukascopy.connect.vo.users {
	
	import com.dukascopy.connect.vo.StandartVO;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class UserFXCommVO extends StandartVO {
		
		// SERVER DATA
		private var _id:int
		private var _firstname:String;
		private var _lastname:String;
		private var _role:String;
		private var _friendsOnly:int = int.MIN_VALUE;
		private var _hideName:Boolean;
		private var _ignoreGuest:Boolean;
		private var _languages:Array; // [String, ..., n]
		// GENERATED DATA
		private var _name:String;
		// SETTED FLAGS
		private var _hideNameSetted:Boolean;
		private var _ignoreGuestSetted:Boolean;
		
		public function UserFXCommVO(id:int = 0) {
			_id = id;
		}
		
		public function setData(data:Object, replace:Boolean = false):Boolean {
			changed = false;
			
			var clearGeneratedName:Boolean = replace;
			var savedField:String;
			
			savedField = _firstname;
			_firstname = fillFieldObject(_firstname, data, "firstname", replace) as String;
			clearGeneratedName = savedField != _firstname;
			
			savedField = _lastname;
			_lastname = fillFieldObject(_lastname, data, "lastname", replace) as String;
			clearGeneratedName = savedField != _lastname;
			
			_role = fillFieldObject(_role, data, "role", replace) as String;
			_friendsOnly = fillFieldINT(_friendsOnly, data, "friends_only", replace);
			_languages = fillFieldObject(_languages, data, "spoken_languages", replace) as Array;
			var res:int;
			res = fillFieldBoolean(_hideName, data, "hide_profile_name", replace, _hideNameSetted);
			if (res != -1) {
				_hideNameSetted = true;
				_hideName = res == 1;
			}
			res = fillFieldBoolean(_ignoreGuest, data, "ignore_guests", replace, _ignoreGuestSetted);
			if (res != -1) {
				_ignoreGuestSetted = true;
				_ignoreGuest = res == 1;
			}
			res = 0;
			
			if (clearGeneratedName)
				_name = null;
			
			return changed;
		}
		
		public function dispose():void {
			_id = 0;
			_firstname = null;
			_lastname = null;
			_name = null;
			_role = null;
			_friendsOnly = 0;
			_hideName = 0;
			_ignoreGuest = 0;
			_languages = null;
			_hideNameSetted = false;
			_ignoreGuestSetted = false;
		}
		
		public function get id():int { return _id; }
		public function get firstname():String { return (_firstname == null) ? "" : _firstname; }
		public function get lastname():String { return (_lastname == null) ? "" : _lastname; }
		public function get role():String { return (_role == null) ? "" : _role; }
		public function get friendsOnly():int { return _friendsOnly; }
		public function get hideName():Boolean { return _hideName; }
		public function get ignoreGuest():Boolean { return _ignoreGuest; }
		public function get languages():Array { return _languages; }
		
		public function get name():String {
			if (_name != null) {
				if (_name == "")
					return null;
				return _name;
			}
			_name = "";
			if (_firstname != null)
				_name = _firstname;
			if (_lastname != null) {
				if (_name != "")
					_name += " ";
				_name += _lastname;
			}
			if (_name == "")
				return null;
			return _name;
		}
	}
}