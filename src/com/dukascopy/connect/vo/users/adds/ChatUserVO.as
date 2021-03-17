package com.dukascopy.connect.vo.users.adds {
	
	import com.dukascopy.connect.data.LocalAvatars;
	import com.dukascopy.connect.data.UserBanData;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.vo.users.UserVO;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class ChatUserVO {
		
		static public const ROLE_OWNER:String = "owner";
		static public const ROLE_MODERATOR:String = "moderator";
		static public const ROLE_USER:String = "user";
		
		private var _role:String;
		private var _secretMode:Boolean = false;
		
		private var _userVO:UserVO;
		
		public var banned:Boolean;
		public var banData:UserBanData;
		
		public function ChatUserVO(data, needObserve:Boolean = true) {
			_userVO = UsersManager.getUserByChatUserObject(data, needObserve);
			_userVO.incUseCounter();
			if ("role" in data && data.role != null)
				_role = data.role;
			if ("anonym" in data && data.anonym == true)
				_secretMode = true;
		}
		
		public function get uid():String {
			if (_userVO != null)
				return _userVO.uid;
			return "";
		}
		
		public function get name():String {
			if (_userVO != null)
				return _userVO.getDisplayName();
			return "";
		}
		
		public function get avatarURL():String {
			if (_secretMode == true) {
				return LocalAvatars.SECRET;
			}
			if (_userVO)
				return _userVO.getAvatarURL();
			return "";
		}
		
		public function get fxName():String {
			if (_userVO != null)
				return _userVO.login;
			return "";
		}
		
		public function get fxId():uint {
			if (_userVO != null)
				return _userVO.fxID;
			return 0;
		}
		
		public function get role():String { return _role; }
		public function get secretMode():Boolean { return _secretMode; }
		public function get userVO():UserVO { return _userVO; }
		
		public function setRole(roleValue:String):void {
			_role = roleValue;
		}
		
		public function setSecret(secretValue:Boolean):void {
			_secretMode = secretValue;
		}
		
		public function isChatOwner():Boolean { return role == ROLE_OWNER; }
		public function isChatModerator():Boolean { return role == ROLE_MODERATOR; }
		
		public function dispose():void {
			UsersManager.removeUser(_userVO);
			_userVO = null;
			banData = null;
		}
		
		public function update(rawData:Object):void {
			if (rawData != null && _userVO != null && "paidBan" in rawData && rawData.paidBan != null) {
				_userVO.fillPaidBanData(rawData.paidBan);
			}
		}
		
		public function getRawData():Object 
		{
			var raw:Object = new Object();
			
			if (_role != null)
			{
				raw.role = _role;
			}
			if (_secretMode == true)
			{
				raw.anonym = true;
			}
			if (userVO != null)
			{
				raw.uid = userVO.uid;
				if (userVO.login != null)
				{
					raw.username = userVO.login;
				}
				if (userVO.type != null)
				{
					raw.type = userVO.type;
				}
				if (userVO.getDisplayName() != null)
				{
					raw.name = userVO.getDisplayName();
				}
				if (userVO.avatarURL != null)
				{
					raw.avatar = userVO.avatarURL;
				}
				if (userVO.fxID != 0)
				{
					raw.fxid = userVO.fxID;
				}
			}
			return raw;
		}
	}
}