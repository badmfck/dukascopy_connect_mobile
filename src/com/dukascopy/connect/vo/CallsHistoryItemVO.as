package com.dukascopy.connect.vo {
	
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.type.CallHistoryType;
	import com.dukascopy.connect.utils.*;
	import com.dukascopy.connect.vo.users.UserVO;
	import com.dukascopy.langs.Lang;
	import gibberishAES.AESCrypter;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class CallsHistoryItemVO {
		
		private var _id:String;
		private var _type:Boolean;
		private var _state:String;
		private var _view:Boolean;
		private var _sTime:Number;
		private var _uTime:Number;
		private var _data:Object;
		private var _userVO:UserVO;
		private var _title:String;
		
		public function CallsHistoryItemVO(data:Object = null) {
			if (data != null)
				fillData(data);
		}
		
		private function fillData(data:Object):void {
			if ("cID" in data == true)
				_id = data.cID;
			if ("type" in data == true)
				_type = data.type;
			if ("state" in data == true)
				_state = data.state;
			if ("view" in data == true)
				_view = data.view;
			if ("sTime" in data == true)
				_sTime = data.sTime;
			if ("uTime" in data == true)
				_uTime = data.uTime;
			if ("data" in data == true && data.data != null && data.data.length > 0) {
				try {
					_data = JSON.parse(AESCrypter.dec(data.data, Auth.uid));
				} catch (err:Error) {
					echo("CallsHistoryItemVO", "fillData", err.message);
				}
			}
			if ("users" in data == true && data.users.length != 0 && data.users[0] != null) {
				_userVO = UsersManager.getUserByCallUserObject(data.users[0]);
				_userVO.incUseCounter();
			}
		}
		
		public function dispose():void {
			_id = null;
			_sTime = NaN;
			_uTime = NaN;
			_state = null;
			_data = null;
			_title = null;
			
			UsersManager.removeUser(_userVO);
			_userVO = null;
		}
		
		public function setViewed():void {
			_view = true;
		}
		
		public function unsetViewed():void {
			_view = false;
		}
		
		public function setUser(user:UserVO):void {
			if (_userVO != null) {
				if (_userVO == user)
					return;
				_userVO.dispose();
			}
			_userVO = user;
			if (_userVO != null)
				_userVO.incUseCounter();
		}
		
		public function setState(val:String):void {
			_state = val;
		}
		
		public function setData(data:Object):void {
			_data = data;
		}
		
		public function get id():String { return _id; }
		public function get type():Boolean { return _type; }
		public function get state():String { return _state; }
		public function get view():Boolean { return _view; }
		public function get sTime():Number { return _sTime; }
		public function get uTime():Number { return _uTime; }
		public function get data():Object{ return _data; }
		public function get pid():int { return (_data != null && "pid" in _data) ? _data.pid : 0; }
		public function get user():UserVO { return _userVO; }
		public function get userUID():String { return (_userVO != null) ? _userVO.uid : null; }
		public function get avatarURL():String { return (_userVO != null) ? _userVO.getAvatarURL() : null; }
		
		public function get title():String {
			if (_title != null)
				return _title;
			_title = Lang.unknownName;
			if (_data != null && "pidTitle" in data == true && data.pidTitle != null && data.pidTitle.length != 0) {
				_title = _data.pidTitle;
				return _title;
			}
			if (_userVO != null && _userVO.uid != "") {
				_title = _userVO.getDisplayName();
				return _title;
			}
			return _title;
		}
	}
}