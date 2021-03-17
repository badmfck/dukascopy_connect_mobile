package com.dukascopy.connect.screens.chat.selectAdressee {
	
	import com.dukascopy.connect.sys.usersManager.OnlineStatus;
	import com.dukascopy.connect.vo.ChatVO;
	import com.dukascopy.connect.type.UserStatusType;
	
	/**
	 * ...
	 * @author David Gnatkivskij. Telefision TEAM Kiev.
	 */
	
	public class ListChatsItemModel implements IContactsChatsSelectionListItem {		
		private var _chatVO:ChatVO;
		public function get chatVO():ChatVO{return _chatVO; }
		
		private var _status:int = UserStatusType.UNSELECTED;
		public function get status():int{return _status; }
		
		private var _isListSelectable:Boolean;
		public function get isListSelectable():Boolean { return _isListSelectable; }
		
		public function set status(value:int):void
		{
			_status = value; 
		}
		
		public function ListChatsItemModel(chatInfo:ChatVO, isListSelectable:Boolean)
		{
			_isListSelectable = isListSelectable;
			_chatVO = chatInfo;
		}
		
		public function get avatarURL():Object 
		{ 
			if (chatVO)
			{
				return chatVO.avatarURL; 
			}
			return null;
		}
		
		public function get title():String
		{
			if (chatVO != null)
			{
				if (chatVO.title != null)
				{
					return chatVO.title;
				}
			}
			return "";
		}
		
		public function get titleFirstLetter():String
		{
			if (title.length>0)
			{
				return title.charAt(0).toUpperCase();
			}
			return "";
		}
		
		public function get isBlocked():Boolean
		{
			return false;
		}
		
		public function get isEmpty():Boolean
		{
			return chatVO == null;
		}
		
		public function get onlineStatus():OnlineStatus
		{
			return null;
		}
		public function get statusText():String
		{
			return "";
		}
		
		public function dispose():void {
			_chatVO = null;
		}
	}
}