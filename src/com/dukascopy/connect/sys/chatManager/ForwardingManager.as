package com.dukascopy.connect.sys.chatManager {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.screens.chat.selectAdressee.SelectAdresseeResultVO;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.screens.ChatScreen;
	import com.dukascopy.connect.screens.base.ScreenManager;
	import com.dukascopy.connect.screens.chat.selectAdressee.SelectAdresseeResultVO;
	import com.dukascopy.connect.screens.chat.selectAdressee.SelectAdresseeScreen;
	import com.dukascopy.connect.screens.chat.selectAdressee.SelectAresseeScreenDataVO;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.crypter.Crypter;
	import com.dukascopy.connect.sys.errors.ErrorLocalizer;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.type.ChatInitType;
	import com.dukascopy.connect.type.ChatMessageType;
	import com.dukascopy.connect.utils.DateUtils;
	import com.dukascopy.connect.utils.FilesSaveUtility;
	import com.dukascopy.connect.vo.ChatSystemMsgVO;
	import com.dukascopy.connect.vo.users.adds.ChatUserVO;
	import com.dukascopy.connect.vo.ChatMessageVO;
	import com.dukascopy.connect.vo.chat.ChatMessageInvoiceData;
	import com.dukascopy.connect.vo.ChatVO;
	import com.dukascopy.connect.vo.screen.ChatScreenData;
	import com.dukascopy.langs.Lang;
	import com.dukascopy.connect.vo.ChatVO;
	import com.dukascopy.langs.Lang;
	
	/**
	 * ...
	 * @author David Gnatkivskij. Telefision TEAM Kiev.
	 */
	
	public class ForwardingManager {
		
		private static var _currentForwardingMessage:ChatMessageVO;
		private static var _forwardingMessageChatKey:String;
		
		public static function get currentForwardingMessage():ChatMessageVO {
			return _currentForwardingMessage;
		}
		
		static public function startMessageForwarding(messageToForward:ChatMessageVO):void {
			_currentForwardingMessage = messageToForward.getClone();
			
			var chatVO:ChatVO;
			var t:Object;
			
			_forwardingMessageChatKey = ChatManager.getCurrentChat().chatSecurityKey;
			_currentForwardingMessage.decrypt(_forwardingMessageChatKey, ChatManager.getCurrentChat().pin);
			
			if (_currentForwardingMessage.chatUID != null)
			{
				if (ChatManager.getCurrentChat() != null && ChatManager.getCurrentChat().uid == _currentForwardingMessage.chatUID)
				{
					chatVO = ChatManager.getCurrentChat();
				}
				else {
					chatVO = ChatManager.getChatByUID(_currentForwardingMessage.chatUID);
				}
				
				if (chatVO != null)
				{
					var user:ChatUserVO = chatVO.getUser(_currentForwardingMessage.userUID);
					if (chatVO.type == ChatInitType.SUPPORT) {
						t = _currentForwardingMessage.rawObject;
						_currentForwardingMessage.rawObject.user_name = Lang.textSupport;
					}
					if (user != null && user.secretMode == true)
					{
						t = _currentForwardingMessage.rawObject;
						_currentForwardingMessage.rawObject.user_name = Lang.textIncognito;
					}
				}
			}
		}
		
		static public function clearForwardingMessage():void {
			_currentForwardingMessage = null;
		}
		
		static public function forwardForwardingMessageToCurrentChat():void {
			if (currentForwardingMessage == null) {
				return;
			}
			if (_currentForwardingMessage.typeEnum == ChatMessageType.INVOICE) {
				var stringToParce:String = _currentForwardingMessage.unparsedText.substr(Config.BOUNDS.length);
				var dataToSend:ChatMessageInvoiceData = ChatMessageInvoiceData.createFromString(stringToParce);
				dataToSend.forwardedFromUserID = Auth.uid;
				dataToSend.forwardedFromUserName = Auth.username;
				dataToSend.id = ChatManager.getCurrentChat().messageID.toString();
				
				var date:Date = _currentForwardingMessage.datePrecence;
				dataToSend.forwardedMessageDate = DateUtils.toString(date);
				ChatManager.sendInvoiceByData(dataToSend);
			}
			else if (currentForwardingMessage.typeEnum == ChatSystemMsgVO.TYPE_FILE && currentForwardingMessage.systemMessageVO != null && 
					(currentForwardingMessage.systemMessageVO.fileType == ChatSystemMsgVO.FILETYPE_IMG || currentForwardingMessage.systemMessageVO.fileType == ChatSystemMsgVO.FILETYPE_IMG_CRYPTED)) {
				
				requestNewImageForChat(currentForwardingMessage, ChatManager.getCurrentChat());
			}
			else {
				var messageObject:Object = new Object();
				messageObject.title = "forwardedMessage";
				var rawData:Object = _currentForwardingMessage.rawObject;
				
				var text:String  = Crypter.crypt(currentForwardingMessage.unparsedText, ChatManager.getCurrentChat().chatSecurityKey);
				var objectToSend:Object = new Object();
				objectToSend.text = text;
				objectToSend.created = rawData.created;
				objectToSend.user_name = rawData.user_name;
				objectToSend.user_uid = rawData.user_uid;
				
				messageObject.additionalData = objectToSend;
				messageObject.type = ChatMessageType.FORWARDED;
				messageObject.text = "fwd";
				var jsonifyed:String = Config.BOUNDS + JSON.stringify(messageObject);
				ChatManager.sendMessage(jsonifyed);
			}
		}
		
		static private function requestNewImageForChat(currentForwardingMessage:ChatMessageVO, currentChat:ChatVO):void {
			var fromChat:ChatVO = ChatManager.getChatByUID(_currentForwardingMessage.chatUID);
			if (fromChat != null) {
				var objectToSend:Object = new Object();
				var rawData:Object = _currentForwardingMessage.rawObject;
				objectToSend.created = rawData.created;
				objectToSend.user_name = rawData.user_name;
				objectToSend.user_uid = rawData.user_uid;
				objectToSend.width = currentForwardingMessage.systemMessageVO.imageWidth;
				objectToSend.height = currentForwardingMessage.systemMessageVO.imageHeight;
				var key:String = Crypter.crypt(fromChat.securityKey + "~" + currentChat.securityKey, Auth.key);
				PHP.files_forwardImage(onImageConverted, currentForwardingMessage.systemMessageVO.imageUID, key, currentChat.uid, objectToSend);
			}
			else {
				//!TODO:
			}
		}
		
		static private function onImageConverted(respond:PHPRespond):void {
			if (respond.error == true) {
				ToastMessage.display(ErrorLocalizer.getText(respond.errorMsg));
			}
			else if("data" in respond && respond.data != null) {
				var toChat:ChatVO = ChatManager.getChatByUID(respond.additionalData.targetChat);
				if (toChat != null) {
					var msg:String = JSON.stringify( {
						method:ChatSystemMsgVO.METHOD_FILE_SENDED,
						type:ChatSystemMsgVO.TYPE_FILE,
						title:respond.data.desc,
						fileType:ChatSystemMsgVO.FILETYPE_IMG_CRYPTED,
						additionalData:respond.data.uid + ',' + respond.additionalData.messageData.width + ',' + respond.additionalData.messageData.height + "," + 
						respond.additionalData.messageData.created + "," + respond.additionalData.messageData.user_name + "" + respond.additionalData.messageData.user_uid
						} );
					ChatManager.sendMessageToOtherChat(Config.BOUNDS + msg, toChat.uid, toChat.securityKey, false);
				}
				else {
					ApplicationErrors.add();
				}
			}
			
			respond.dispose();
		}
		
		public static function openSelectAdresseeScreenForForwardingMessage(msgVO:ChatMessageVO, chatScreenBackData:Object):void
		{
			startMessageForwarding(msgVO);
			_chatScreenBackData = chatScreenBackData;
			var selectAdresseeData:SelectAresseeScreenDataVO = new SelectAresseeScreenDataVO(selectAdresseeCallback, ChatScreen, ChatManager.getCurrentChat().uid, true, Lang.forwardMessageScreenTitle);
			MobileGui.changeMainScreen(SelectAdresseeScreen, selectAdresseeData, ScreenManager.DIRECTION_RIGHT_LEFT);
			
		}
		
		private static var _chatScreenBackData:Object;
		
		private static function selectAdresseeCallback(res:SelectAdresseeResultVO):void
		{
			if (res.isAnyAdresseeSelected)
			{
				var chatScreenData: ChatScreenData = new ChatScreenData();
				if (res.selectedChatIDs.length > 0)
				{
					chatScreenData.chatUID = res.selectedChatIDs[0];
					chatScreenData.type = ChatInitType.CHAT;
				}
				else
				{
					var uidArray:Array = new Array();
					for each(var currUid:String in res.selectedUserIDs)
					{
						uidArray.push(currUid)
					}
					chatScreenData.usersUIDs = uidArray;
					chatScreenData.type = ChatInitType.USERS_IDS;
				}
				chatScreenData.backScreen = ChatScreen;
				chatScreenData.backScreenData =  _chatScreenBackData;//this.data;
				MobileGui.showChatScreen(chatScreenData);
			}
		}
	}
}