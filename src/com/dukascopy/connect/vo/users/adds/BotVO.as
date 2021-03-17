package com.dukascopy.connect.vo.users.adds {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.LocalAvatars;
	import com.dukascopy.connect.data.paidBan.PaidBanProtectionData;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.vo.ChatMessageVO;
	import com.dukascopy.connect.vo.users.UserVO;
	import flash.utils.getDefinitionByName;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class BotVO extends UserVO {
		
		private var _chatCnt:int;
		private var _description:String;
		private var _botType:String;
		private var _schema:String;
		private var _status:String;
		private var _owner:UserVO;
		private var _additionalDataAdded:Boolean = false;
		private var generatedAvatar:String;
		private var sourceAvatarBig:String;
		private var generatedAvatarIndex:int;
		
		private var _action:IScreenAction;
		private var _group:String;
		
		public function BotVO() {
			
		}
		
		override public function setData(data:Object):void {
			super.setData(data);
			setBotData(data);
		}
		
		private function setBotData(data:Object):void 
		{
			if ("owner" in data && data.owner != null) {
				_owner = UsersManager.getUserByContactObject(data.owner);
				_owner.incUseCounter();
			}
			if ("chatCnt" in data)
				_chatCnt = data.chatCnt;
			
			if ("grp" in data)
				_group = data.grp;
		}
		
		override public function setDataFromPhonebookVO(puVO:PhonebookUserVO):void {
			super.setDataFromPhonebookVO(puVO);
		}
		
		override public function setDataFromPhonebookObject(data:Object):Boolean {
			return super.setDataFromPhonebookObject(data);
		}
		
		override public function setDataFromMessageObject(data:ChatMessageVO):void {
			super.setDataFromMessageObject(data);
		}
		
		override public function setDataFromBanObject(data:UserBan911VO):void {
			super.setDataFromBanObject(data);
		}
		
		override public function setDataFromBanPayerObject(data:UserBan911VO):void {
			super.setDataFromBanPayerObject(data);
		}
		
		override public function setDataFromBanProtectionObject(data:PaidBanProtectionData):void {
			super.setDataFromBanProtectionObject(data);
		}
		
		override public function setDataFromContactObject(data:Object):Boolean {
			setBotData(data);
			return super.setDataFromContactObject(data);
		}
		
		override public function setDataFromQuestionUserObject(data:Object):Boolean {
			return super.setDataFromQuestionUserObject(data);
		}
		
		override public function setDataFromChatUserObject(data:Object):Boolean {
			setBotData(data);
			return super.setDataFromChatUserObject(data);
		}
		
		override public function setDataFromCallUserObject(data:Object):Boolean {
			return setDataFromChatUserObject(data);
		}
		
		public function addAdditional(data:Object):void {
			_description = data.description;
			_botType = data.type;
			_schema = data.schema;
			_status = data.status;
			_additionalDataAdded = true;
		}
		
		public function get bigAvatarURL():String {
			var sourceAvatar:String = super.avatarURL;
			
			if (LocalAvatars.isLocal(sourceAvatar))
			{
				sourceAvatar = null;
			}
			
			if (sourceAvatar == null || sourceAvatar == "")
			{
				if (sourceAvatarBig == null)
				{
					if (generatedAvatarIndex == 0)
					{
						generatedAvatarIndex = Math.round(Math.random() * 4) + 1;
					//	generatedAvatarIndex = 1;
					}
					
					sourceAvatarBig = "###botAvatarBig_" + generatedAvatarIndex;
				}
				if (sourceAvatarBig != null)
				{
					sourceAvatar = sourceAvatarBig;
				}
			}
			
			if (LocalAvatars.isLocal(sourceAvatar))
				return sourceAvatar;
			else if (sourceAvatar != null && sourceAvatar != "")
				return Config.URL_PHP_CORE_SERVER_FILE + "?method=files.get&key=web&uid=" + sourceAvatar + "&type=image";
			return null;
		}
		
		override public function getAvatarURL():String {
			var sourceAvatar:String = super.getAvatarURL();
			
			if (sourceAvatar == null || sourceAvatar == "")
			{
				if (generatedAvatar == null)
				{
					if (generatedAvatarIndex == 0)
					{
						generatedAvatarIndex = Math.round(Math.random() * 4) + 1;
					//	generatedAvatarIndex = 1;
					}
					
					generatedAvatar = "###botAvatar_" + generatedAvatarIndex;
				}
				if (generatedAvatar != null)
				{
					sourceAvatar = generatedAvatar;
				}
			}
			
			if (LocalAvatars.isLocal(sourceAvatar))
				return sourceAvatar;
			else if (sourceAvatar != null && sourceAvatar != "")
				return Config.URL_PHP_CORE_SERVER_FILE + "?method=files.get&key=web&uid=" + sourceAvatar + "&type=image";
			return null;
		}
		
		public function get ownerAvatarURL():String {
			if (_owner != null)
				return _owner.getAvatarURL();
			return null;
		}
		
		public function get chatCnt():int { return _chatCnt; }
		public function get description():String { return (_description == "") ? null : _description; }
		public function get botType():String { return _botType; }
		public function get schema():String { return _schema; }
		public function get status():String { return _status; }
		public function get owner():UserVO { return _owner; }
		public function get additionalDataAdded():Boolean { return _additionalDataAdded; }
		
		override public function dispose(imedeately:Boolean = false):Boolean {
			
			return false;
			
			/*disposed = true;
			
			if (super.dispose(imedeately) == true)
			{
				if (_action != null)
					_action.dispose();
				_action = null;
				
				if (_owner != null)
					UsersManager.removeUser(_owner);
				_owner = null;
				
				return true;
			}
			return false;*/
		}
		
		public function update(botRawData:Object):void 
		{
			setBotData(botRawData);
			//!TODO;
		}
		
		public function get action():IScreenAction { return _action; }
		
		public function get group():String 
		{
			return _group;
		}
		
		public function set action(value:IScreenAction):void 
		{
			_action = value;
		}
	}
}