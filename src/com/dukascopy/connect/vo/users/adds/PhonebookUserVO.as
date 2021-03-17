package com.dukascopy.connect.vo.users.adds {
	
	import com.adobe.crypto.MD5;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.sys.phonebookManager.PhonebookManager;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.type.UserType;
	import com.dukascopy.connect.vo.users.UserVO;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision AG.
	 */
	
	public class PhonebookUserVO {
		
		private var _userVO:UserVO;
		
		private var _hash:String;
		private var _additionalInfo:Boolean = false;
		private var _invited:Boolean = false;
		
		public function PhonebookUserVO(data:Object) {
			_hash = MD5.hash(data.phone + data.name);
			_userVO = UsersManager.getUserByPhonebookObject(data, _hash);
			_userVO.incUseCounter();
		}
		
		public function addInfo(data:Object):void {
			var userVO:UserVO = UsersManager.addContactObjectToUser(data, _hash);
			if (userVO == null)
				return;
			if (_userVO != userVO) {
				_userVO = userVO;
				_userVO.incUseCounter();
			}
			_hash = null;
		}
		
		public function collectInfo():void {
			_additionalInfo = true;
			PhonebookManager.updatePUVO(this);
		}
		
		public function get invited():Boolean { return _invited; }
		public function set invited(val:Boolean):void {
			if (val == false)
				return;
			_invited = val;
		}
		
		public function get hash():String { return _hash; }
		public function get additionalInfo():Boolean { return _additionalInfo; }
		
		public function get phone():String {
			if (_userVO != null)
				return _userVO.phone;
			return "";
		}
		
		public function get avatarURL():String {
			if (_userVO != null)
				return _userVO.getAvatarURL();
			return "";
		}
		
		public function get uid():String {
			if (_userVO != null)
				return _userVO.uid;
			return "";
		}
		
		public function get type():String {
			if (_userVO != null)
				return _userVO.type;
			return "";
		}
		
		public function get fxID():uint {
			if (_userVO != null)
				return _userVO.fxID;
			return 0;
		}
		
		public function get fxName():String {
			if (_userVO != null)
				return _userVO.login;
			return "";
		}
		
		public function get name():String {
			if (_userVO != null)
				return _userVO.getDisplayName();
			return "";
		}
		
		public function get phonebookName():String {
			if (_userVO != null)
				return _userVO.phoneName;
			return "";
		}
		
		public function get payRating():int {
			if (_userVO != null)
				return _userVO.payRating;
			return 0;
		}
		
		public function get userVO():UserVO {
			return _userVO;
		}
		
		public function dispose():void {
			UsersManager.removeUser(_userVO);
			_userVO = null;
			_hash = null;
		}
	}
}