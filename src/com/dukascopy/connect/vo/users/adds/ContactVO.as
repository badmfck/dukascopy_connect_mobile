package com.dukascopy.connect.vo.users.adds {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.customActions.StartChatWithNotebookAction;
	import com.dukascopy.connect.data.screenAction.customActions.StartChatWithUidAction;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.vo.users.UserVO;
	import com.dukascopy.langs.Lang;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision AG.
	 */
	
	public class ContactVO {
		
		private var _userVO:UserVO;
		private var _action:IScreenAction;
		
		public function ContactVO(data:Object) {
			if (data == null)
				return;
			if (data.uid == Config.NOTEBOOK_USER_UID && Auth.myProfile != null) {
				_action = new StartChatWithNotebookAction();
				_action.setAdditionalData(data.uid);
				data.avatar = Auth.myProfile.getAvatarURL();
			}
			_userVO = UsersManager.getUserByContactObject(data);
			_userVO.incUseCounter();
		}
		
		public function getRawAvatar():String {
			if (_userVO != null)
				return _userVO.getAvatarURL();
			return "";
		}
		
		public function getPhone():Number {
			if (_userVO != null)
				return Number(_userVO.phone);
			return NaN;
		}
		
		public function dispose():void {
			UsersManager.removeUser(_userVO);
			_userVO = null;
			if (_action != null)
				_action.dispose();
			_action = null;
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
		
		public function get avatarURL():String {
			if (_userVO != null)
				return _userVO.getAvatarURL();
			return "";
		}
		
		public function get fxID():uint {
			if (_userVO != null)
				return _userVO.fxID;
			return 0;
		}
		
		public function get fxName():String {
			if (_action != null)
				return "";
			if (_userVO != null)
				return _userVO.login;
			return "";
		}
		
		public function get fxcommFN():String {
			if (_userVO != null)
				return _userVO.fxFN;
			return "";
		}
		
		public function get fxcommLN():String {
			if (_userVO != null)
				return _userVO.fxLN;
			return "";
		}
		
		public function get name():String {
			if (_action != null)
				return _action.getData() as String;
			if (_userVO != null)
				return _userVO.getDisplayName();
			return "";
		}
		
		public function get payRating():int {
			if (_userVO != null)
				return _userVO.payRating;
			return 0;
		}
		
		public function get action():IScreenAction { return _action; }
		
		public function set action(value:IScreenAction):void 
		{
			_action = value;
		}
		
		public function get userVO():UserVO {
			return _userVO;
		}
	}
}