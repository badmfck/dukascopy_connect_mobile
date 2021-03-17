package com.dukascopy.connect.sys 
{
	import assets.Gift_1;
	import assets.Gift_10;
	import assets.Gift_25;
	import assets.Gift_5;
	import assets.Gift_50;
	import assets.Gift_x;
	import assets.MoneyManyIcon;
	import assets.WinnerIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.GiftData;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.chatManager.typesManagers.ChannelsManager;
	import com.dukascopy.connect.sys.crypter.Crypter;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.sys.questionsManager.QuestionsManager;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.store.Store;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.type.ChatRoomType;
	import com.dukascopy.connect.type.GiftType;
	import com.dukascopy.connect.vo.ChatSystemMsgVO;
	import com.dukascopy.connect.vo.ChatVO;
	import com.dukascopy.connect.vo.users.UserVO;
	import com.dukascopy.connect.vo.users.adds.ChatUserVO;
	import com.telefision.sys.signals.Signal;
	import flash.display.Sprite;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author ...
	 */
	public class Gifts 
	{
		static public const GIFT_VALUE_1:Number = 1;
		static public const GIFT_VALUE_5:Number = 5;
		static public const GIFT_VALUE_10:Number = 10;
		static public const GIFT_VALUE_25:Number = 25;
		static public const GIFT_VALUE_50:Number = 50;
		static public var tuturialShown:Boolean = false;
		
		static private var colors:Dictionary;
		static private var currentGiftType:int;
		static private var pendingMessages:Array;
		private var serviceScreenLayer:Sprite;
		
		static public const S_MONEY_SEND_SUCCESS:Signal = new Signal("Gifts.S_MONEY_SEND_SUCCESS");
		
		public function Gifts() 
		{
			
		}
		
		static public function init():void
		{
			colors = new Dictionary();
			colors[GiftType.GIFT_1] = [0xFDCF17, 0xC87203];
			colors[GiftType.GIFT_5] = [0x93EBF5, 0x2A84B6];
			colors[GiftType.GIFT_10] = [0xA9BF5B, 0x3B5E1E];
			colors[GiftType.GIFT_25] = [0xF8BB01, 0xBD2033];
			colors[GiftType.GIFT_50] = [0xE58DE1, 0x73276F];
			colors[GiftType.GIFT_X] = [0xEB3F57, 0x8E2029];
			colors[GiftType.MONEY_TRANSFER] = [0xFDCF17, 0xC87203];
			colors[GiftType.FIXED_TIPS] = [0xFDCF17, 0xC87203];
			
			ChatManager.S_CHAT_READY.add(onChatReady);
		}
		
		static private function onChatReady(chatVO:ChatVO):void {
			if (chatVO != null && pendingMessages != null) {
				if (chatVO.users != null && chatVO.users.length == 1) {
					if (pendingMessages[chatVO.users[0].uid] != null) {
						var l:int = pendingMessages[chatVO.users[0].uid].length;
						for (var i:int = 0; i < l; i++) 
						{
							sendToChat(pendingMessages[chatVO.users[0].uid][i], chatVO);
						}
						
						pendingMessages[chatVO.users[0].uid] = null;
						delete pendingMessages[chatVO.users[0].uid];
					}
				}
			}
		}
		
		static public function startGift(giftType:int, predefinedGift:GiftData = null):void 
		{
			var receiverSecret:Boolean = false;
			if (predefinedGift == null) {
				var userModel:UserVO;
				
				if (ChatManager.getCurrentChat() != null && (ChatManager.getCurrentChat().type == ChatRoomType.PRIVATE || ChatManager.getCurrentChat().type == ChatRoomType.QUESTION))
				{
					var chatUser:ChatUserVO = UsersManager.getInterlocutor(ChatManager.getCurrentChat());
					if (chatUser != null){
						receiverSecret = chatUser.secretMode;
						userModel = chatUser.userVO;
					}
				}
				
				if (userModel != null) {
					ServiceScreenManager.showNewGiftDialog(userModel, giftType, null, receiverSecret);
				}
				else {
					ApplicationErrors.add("empty userModel");
				}
			}
			else{
				ServiceScreenManager.showNewGiftDialog(predefinedGift.user, predefinedGift.type, predefinedGift);
			}
		}
		
		static public function showTutorial():void 
		{
			ServiceScreenManager.showGiftsTutorialScreen();
			tuturialShown = true;
			Store.save(Store.VAR_GIFTS_TUTORIAL_SHOWN, true);
		}
		
		static public function getGiftImage(giftType:int):Sprite 
		{
			switch(giftType)
			{
				case GiftType.GIFT_1:
				{
					return new Gift_1();
					break;
				}
				case GiftType.GIFT_5:
				{
					return new Gift_5();
					break;
				}
				case GiftType.GIFT_10:
				{
					return new Gift_10();
					break;
				}
				case GiftType.GIFT_25:
				{
					return new Gift_25();
					break;
				}
				case GiftType.GIFT_50:
				{
					return new Gift_50();
					break;
				}
				case GiftType.GIFT_X:
				{
					return new Gift_x();
					break;
				}
				/*case GiftType.MONEY_TRANSFER:
				{
					return new MoneyManyIcon();
					break;
				}*/
				case GiftType.FIXED_TIPS:
				{
					return new WinnerIcon();
					break;
				}
			}
			
			return null;
		}
		
		static public function getColors(type:int):Array 
		{
			if (type in colors)
				return colors[type];
			else
				return colors[GiftType.GIFT_1];
		}
		
		static public function onGiftSend(giftData:GiftData):void {
			var chatVO:ChatVO;
			
			if (giftData.type == GiftType.FIXED_TIPS) {
				if (ChatManager.getCurrentChat() != null &&	ChatManager.getCurrentChat().uid == giftData.chatUID) {
					chatVO = ChatManager.getCurrentChat();
				}
				
				if (chatVO == null) {
					chatVO = ChannelsManager.getChannel(giftData.chatUID);
				}
				
				if (chatVO != null) {
					if (chatVO.type == ChatRoomType.CHANNEL) {
						ChannelsManager.updateChannelMode(chatVO.uid, ChannelsManager.CHANNEL_MODE_NONE);
						
						if (chatVO.getQuestion() != null)
							QuestionsManager.closePublicAnswer(chatVO, giftData.user.uid, QuestionsManager.STATUS_ACCEPTED);
						
						sendTipsPaidMessage(giftData, chatVO);
					}
					else if (chatVO.type == ChatRoomType.QUESTION && chatVO.getQuestion() != null) {
						sendTipsPaidMessage(giftData, chatVO);
					}
				}
				
				if (chatVO.type == ChatRoomType.CHANNEL) {
					var isIncognito:Boolean = false;
					// сообщение в приватный чат получателю перевода;
					if (chatVO.questionID != null && chatVO.questionID != "" && chatVO.getQuestion() != null && chatVO.getQuestion().incognito == true) {
						isIncognito = true;
					}
					if (isIncognito == false) {
						sendMoneyTransferMessage(giftData);
					}
				}
				
			} else if(giftData.type == GiftType.MONEY_TRANSFER) {
				sendMoneyTransferMessage(giftData);
			} else {
				if (giftData.chatUID != null) {
					chatVO = ChatManager.getChatByUID(giftData.chatUID);
					if (chatVO == null){
						chatVO = ChannelsManager.getChannel(giftData.chatUID);
					}
					if (chatVO != null && chatVO.type == ChatRoomType.GROUP || chatVO != null && chatVO.type == ChatRoomType.CHANNEL){
						sendSystemToGroupChat(giftData, chatVO);
					}
				}
				sendGiftMessage(giftData);
			}
			S_MONEY_SEND_SUCCESS.invoke();
		}
		
		static private function sendSystemToGroupChat(giftData:GiftData, chatVO:ChatVO):void 
		{
			var data:Object = new Object();
			data.senderUID = Auth.uid;
			data.senderName = Auth.login;
			data.toUID = giftData.user.uid;
			data.toUsername = giftData.user.login;
			
			var messageObject:Object = new Object();
			messageObject.additionalData = data;
			messageObject.type = ChatSystemMsgVO.TYPE_CHAT_SYSTEM;
			messageObject.method = ChatSystemMsgVO.METHOD_GIFT_IN_GROUP_CHAT;
			
			sendToChat(messageObject, chatVO);
		}
		
		static public function sendTipsPaidMessage(giftData:GiftData, chatVO:ChatVO):void 
		{
			var data:Object = new Object();
			data.type = giftData.type;
			data.customValue = giftData.customValue;
			data.currency = giftData.currency;
			data.comment = giftData.comment;
			data.recieverSecret = giftData.recieverSecret;
			
			if (giftData.user != null) {
				var rawUserData:Object = { };
				rawUserData.uid = giftData.user.uid;
				rawUserData.avatar = giftData.user.getAvatarURL();
				rawUserData.name = giftData.user.getDisplayName();
				
				data.user = rawUserData;
			}
			
			var messageObject:Object = new Object();
			messageObject.additionalData = data;
			messageObject.type = ChatSystemMsgVO.TYPE_CHAT_SYSTEM;
			messageObject.method = ChatSystemMsgVO.METHOD_TIPS_PAID;
			
			sendToChat(messageObject, chatVO);
		}
		
		static public function sendMoneyTransferMessage(giftData:GiftData):void {
			var data:Object = new Object();
			data.userUid = giftData.user.uid;
			data.comment = giftData.comment;
			data.currency = giftData.currency;
			data.amount = giftData.customValue;
			if (giftData.pass != null)
				data.pass = true;
			preSendMessage(data);
		}
		
		static public function preSendMessage(data:Object):void {
			var chatVO:ChatVO;
			if (ChatManager.getCurrentChat() != null && 
				ChatManager.getCurrentChat().users != null && 
				ChatManager.getCurrentChat().type != ChatRoomType.CHANNEL && 
				ChatManager.getCurrentChat().users.length > 0 && 
				ChatManager.getCurrentChat().users[0].uid == data.userUid) {
				chatVO = ChatManager.getCurrentChat();
			} else {
				chatVO = ChatManager.getChatWithUsersList([data.userUid]);
			}
			
			var messageObject:Object = new Object();
			messageObject.additionalData = data;
			messageObject.type = ChatSystemMsgVO.TYPE_MONEY;
			messageObject.method = ChatSystemMsgVO.METHOD_MONEY_TRANSFER;
			
			if (chatVO != null) {
				sendToChat(messageObject, chatVO);
			} else {
				if (data.userUid != null && (data.userUid as String) != null && (data.userUid as String).length > 0 && (data.userUid as String).charAt(0) == "+") {
					addToPendingMessages(messageObject, data.userUid);
					var cryptedPhone:String = Crypter.getBaseNumber(data.userUid);
					PHP.getUserByPhone(Crypter.getBaseNumber(data.userUid), onUserByPhoneLoaded);
					addToPendingMessages(messageObject, cryptedPhone);
				} else {
					addToPendingMessages(messageObject, data.userUid);
					getChatWithUser(data.userUid);
				}
			}
		}
		
		static private function onUserByPhoneLoaded(phpRespond:PHPRespond):void {
			if (phpRespond.error == false) {
				if (phpRespond.data != null) {
					if (pendingMessages != null && pendingMessages[phpRespond.additionalData.phone] != null) {
						pendingMessages[phpRespond.data.uid] = pendingMessages[phpRespond.additionalData.phone];
						delete pendingMessages[phpRespond.additionalData.phone];
						getChatWithUser(phpRespond.data.uid);
					}
				}
			}
			phpRespond.dispose();
		}
		
		static private function getChatWithUser(userUID:String):void {
			ChatManager.openChatByUserUIDs([userUID], true, "gifts");
		}
		
		static private function addToPendingMessages(messageObject:Object, userUID:String):void {
			if (pendingMessages == null) {
				pendingMessages = new Array();
			}
			if (pendingMessages[userUID] == null) {
				pendingMessages[userUID] = new Array();
			}
			(pendingMessages[userUID] as Array).push(messageObject);
		}
		
		static private function sendToChat(messageObject:Object, chatVO:ChatVO):void 
		{
			var anon:Boolean = false;
			if (ChatManager.isAnon(chatVO.uid) == true)
				anon = true;
			
			ChatManager.sendMessageToOtherChat(Config.BOUNDS + JSON.stringify(messageObject), chatVO.uid, chatVO.securityKey, anon);
		}
		
		static private function sendGiftMessage(giftData:GiftData):void {
			var chatVO:ChatVO;
			
			if (ChatManager.getCurrentChat() != null && 
				ChatManager.getCurrentChat().users != null && 
				ChatManager.getCurrentChat().users.length > 0 &&
				(ChatManager.getCurrentChat().type == ChatRoomType.PRIVATE || ChatManager.getCurrentChat().type == ChatRoomType.QUESTION) &&
				ChatManager.getCurrentChat().users[0].uid == giftData.user.uid) {
					chatVO = ChatManager.getCurrentChat();
			} else {
				chatVO = ChatManager.getChatWithUsersList([giftData.user.uid]);
			}
			
			var data:Object = new Object();
			data.userUid = giftData.user.uid;
			data.type = giftData.type;
			data.comment = giftData.comment;
			data.currency = giftData.currency;
			data.customValue = giftData.customValue;
			
			var messageObject:Object = new Object();
			messageObject.title = "gift";
			messageObject.additionalData = data;
			messageObject.type = ChatSystemMsgVO.TYPE_GIFT;
			messageObject.method = "giftSent";
			
			if (chatVO != null) {
				sendToChat(messageObject, chatVO);
			} else {
				addToPendingMessages(messageObject, giftData.user.uid);
				getChatWithUser(giftData.user.uid);
			}
		}
		
		static public function showGiftInfo(giftData:GiftData):void 
		{
			ServiceScreenManager.showGiftInfoScreen(giftData);
		}
		
		static public function startSendMoney(predefinedGiftData:GiftData = null):void 
		{
			var userModel:UserVO;
			var userSecret:Boolean = false;
			
			if (predefinedGiftData != null && predefinedGiftData.user != null) {
				userModel = predefinedGiftData.user;
				if (predefinedGiftData.recieverSecret == true) {
					userSecret = true;
				}
			} 
			else if (ChatManager.getCurrentChat() != null && (ChatManager.getCurrentChat().type == ChatRoomType.PRIVATE || ChatManager.getCurrentChat().type == ChatRoomType.QUESTION))
			{
				var chatUser:ChatUserVO = UsersManager.getInterlocutor(ChatManager.getCurrentChat());
				if (chatUser != null){
					userModel = chatUser.userVO;
					userSecret = chatUser.secretMode;
				}
			}
			
			var giftType:int;
			if (predefinedGiftData != null) {
				giftType = predefinedGiftData.type;
			}
			else {
				giftType = GiftType.MONEY_TRANSFER;
			}
			
			if (userModel != null)
			{
				ServiceScreenManager.showNewGiftDialog(userModel, giftType, predefinedGiftData, userSecret);
			}
			else
			{
				ApplicationErrors.add("empty userModel");
			}
		}
		
		static public function onGiftPopupSuccess():void {
		//	S_MONEY_SEND_SUCCESS.invoke();
		}
	}
}