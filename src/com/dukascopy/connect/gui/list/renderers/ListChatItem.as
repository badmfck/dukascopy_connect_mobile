package com.dukascopy.connect.gui.list.renderers {
	
	import assets.DefaultAvatar;
	import assets.HeartIcon;
	import assets.LogoRectangle;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.HitZoneData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.gui.list.renderers.chatMessageElements.ChatMessageRendererAction;
	import com.dukascopy.connect.gui.list.renderers.chatMessageElements.ChatMessageRendererAdditionalQuestionsSettings;
	import com.dukascopy.connect.gui.list.renderers.chatMessageElements.ChatMessageRendererBotCommand;
	import com.dukascopy.connect.gui.list.renderers.chatMessageElements.ChatMessageRendererBotMenu;
	import com.dukascopy.connect.gui.list.renderers.chatMessageElements.ChatMessageRendererCall;
	import com.dukascopy.connect.gui.list.renderers.chatMessageElements.ChatMessageRendererChatSystemMessage;
	import com.dukascopy.connect.gui.list.renderers.chatMessageElements.ChatMessageRendererFile;
	import com.dukascopy.connect.gui.list.renderers.chatMessageElements.ChatMessageRendererGift;
	import com.dukascopy.connect.gui.list.renderers.chatMessageElements.ChatMessageRendererImage;
	import com.dukascopy.connect.gui.list.renderers.chatMessageElements.ChatMessageRendererInvoice;
	import com.dukascopy.connect.gui.list.renderers.chatMessageElements.ChatMessageRendererMoney;
	import com.dukascopy.connect.gui.list.renderers.chatMessageElements.ChatMessageRendererNews;
	import com.dukascopy.connect.gui.list.renderers.chatMessageElements.ChatMessageRendererSticker;
	import com.dukascopy.connect.gui.list.renderers.chatMessageElements.ChatMessageRendererSystemMessage;
	import com.dukascopy.connect.gui.list.renderers.chatMessageElements.ChatMessageRendererText;
	import com.dukascopy.connect.gui.list.renderers.chatMessageElements.ChatMessageRendererTipsWinner;
	import com.dukascopy.connect.gui.list.renderers.chatMessageElements.ChatMessageRendererVoice;
	import com.dukascopy.connect.gui.list.renderers.chatMessageElements.IMessageRenderer;
	import com.dukascopy.connect.gui.list.renderers.chatMessageElements.MessageStatusClip;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.phonebookManager.PhonebookManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.type.ChatMessageReactionType;
	import com.dukascopy.connect.type.ChatMessageType;
	import com.dukascopy.connect.type.ChatRoomType;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.vo.AnimatedZoneVO;
	import com.dukascopy.connect.vo.ChatMessageVO;
	import com.dukascopy.connect.vo.ChatSystemMsgVO;
	import com.dukascopy.connect.vo.ChatVO;
	import com.dukascopy.connect.vo.chat.ChatMessagesStickingManager;
	import com.dukascopy.connect.vo.users.UserVO;
	import com.dukascopy.connect.vo.users.adds.ChatUserVO;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.display.IBitmapDrawable;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class ListChatItem extends BaseRenderer implements IListRenderer
	{
		static public const MESSAGE_TYPE_VOICE:String = "messageTypeVoice";
		static public const MESSAGE_TYPE_INVOICE:String = "messageTypeInvoice";
		static public const MESSAGE_TYPE_STICKER:String = "messageTypeSticker";
		static public const MESSAGE_TYPE_ACTION:String = "messageTypeAction";
		static public const MESSAGE_TYPE_BOT_MENU:String = "messageTypeBotMenu";
		static public const MESSAGE_TYPE_BOT_COMMAND:String = "messageTypeBotCommand";
		static public const MESSAGE_TYPE_SYSTEM_MESSAGE:String = "messageTypeSystemMessage";
		static public const MESSAGE_TYPE_UPDLOAD_IMAGE:String = "messageTypeUpdloadImage";
		static public const MESSAGE_TYPE_TEXT:String = "messageTypeText";
		static public const MESSAGE_TYPE_FILE:String = "messageTypeFile";
		static public const MESSAGE_TYPE_EXTRA_REWARDS:String = "messageTypeExtraRewards";
		static public const MESSAGE_TYPE_CHAT_SYSTEM_MESSAGE:String = "messageTypeChatSystemMessage";
		static public const MESSAGE_TYPE_GIFT:String = "messageTypeGift";
		static public const MESSAGE_TYPE_MONEY:String = "messageTypeMoney";
		static public const MESSAGE_TYPE_TIPS_WINNER:String = "messageTypeTipsWinner";
		static public const MESSAGE_TYPE_NEWS:String = "messageTypeNews";
		static public const MESSAGE_TYPE_CALL:String = "messageTypeCall";
		
		static private var COLOR_BG_WHITE:uint = 0xFFFFFF;
		
		private var tfUsername:TextField;
		private var birdMine:Shape;
		private var birdUser:Shape;
		private var tfDate:TextField;
		
		private var avatar:Sprite;
		private var avatarWithLetter:Sprite;
		private var avatarLettertext:TextField;
		private var avatarSupport:Bitmap;
		private var avatarDefault:Bitmap;
		
		private var _chatMessageInvoiceRenderer:ChatMessageRendererInvoice;
		private var _chatMessageVoiceRenderer:ChatMessageRendererVoice;
		private var _chatMessageTextRenderer:ChatMessageRendererText;
		private var _chatMessageBotMenuRenderer:ChatMessageRendererBotMenu;
		private var _chatMessageBotCommandRenderer:ChatMessageRendererBotCommand;
		private var _chatMessageButtonRenderer:ChatMessageRendererAction;
		private var _chatMessageUploadingImageRenderer:ChatMessageRendererImage;
		private var _chatMessageStickerRenderer:ChatMessageRendererSticker;
		private var _chatMessageSystemMessageRenderer:ChatMessageRendererSystemMessage;
		private var _chatMessageFileRenderer:ChatMessageRendererFile;
		private var _questionSettingRenderer:ChatMessageRendererAdditionalQuestionsSettings;
		private var _chatMessageChatSystemRenderer:ChatMessageRendererChatSystemMessage;
		private var _chatMessageGiftRenderer:ChatMessageRendererGift;
		private var _chatMessageMoneyRenderer:ChatMessageRendererMoney;
		private var _chatMessageTipsWinnerRenderer:ChatMessageRendererTipsWinner;
		private var _chatMessageNewsRenderer:ChatMessageRendererNews;
		private var _chatMessageCallRenderer:ChatMessageRendererCall;
		
		private var avatarSize:int = 50;
		private var minHeight:int = 50;
		
		private var sideMargin:int = 10;
		private var minTextWidth:int = 0;
		
		private var dateFormat:TextFormat;
		private var likesFormat:TextFormat;
		private var mainFormat:TextFormat;
		
		private var avatarDoubleSize:int;
		
		private var timeMargin:int;
		private var securityIconSize:int;
		private var dt:Date;
		
		private var fwdCommentH:int;
		private var usernameH:int;
		private var tfDateWidth:int;
		
		private var fontSize:int;
		
		private var txtColorFile:uint = 0x000000;
		
		private var birdSize:int;
		
		private var serviceSprite:Sprite;
		private var birdRadius:Number;
		private var messageStatusClip:MessageStatusClip;
		private var statusRadius:int;
		
		private var colorTransform:ColorTransform;
		private var lastBackgroundBrightness:Number = NaN;
		private var likeClip:HeartIcon;
		private var likeClipSelected:heartIconRed;
		private var tfLikesNum:TextField;
		private var lastRenderer:IMessageRenderer;
		private var payRating:MovieClip;
		private var permanentBanMark:Bitmap;
		private var banMark:Bitmap;
		
		private var missDCIcon:Sprite;
		private var avatarPosition:Rectangle;
		
		public function ListChatItem() {
			colorTransform = new ColorTransform();
			
			dt = new Date();
			// set constants
			securityIconSize = Config.FINGER_SIZE * .25;
			avatarSize = Config.FINGER_SIZE * .33;
			avatarDoubleSize = avatarSize * 2;
			
			fontSize = Math.ceil(Config.FINGER_SIZE * .25);
			
			birdRadius = Math.ceil(Config.FINGER_SIZE * .25);
			
			sideMargin = Config.FINGER_SIZE * .23;
			minHeight = avatarSize;
			birdSize = fontSize * .9;
			timeMargin = sideMargin * .5
			minTextWidth = Config.FINGER_SIZE * 2;
			
			if (fontSize < 9)
				fontSize = 9;
			
			mainFormat = new TextFormat("Tahoma", fontSize);
			
			var smallFontSize:int = Config.FINGER_SIZE * .22;
			if (smallFontSize < 9)
				smallFontSize = 9;
			dateFormat = new TextFormat("Tahoma", smallFontSize, 0xFFFFFF);
			
			birdMine = new Shape();
			addChild(birdMine);
			birdUser = new Shape();
			addChild(birdUser);
			
			mainFormat.size = Config.FINGER_SIZE * .26;
		//	mainFormat.bold = true;
			mainFormat.color = 0x999999;
			
			tfUsername = new TextField();
			tfUsername.autoSize = TextFieldAutoSize.LEFT;
			tfUsername.defaultTextFormat = mainFormat;
			tfUsername.multiline = false;
			tfUsername.wordWrap = false;
			tfUsername.text = "Q";
			usernameH = tfUsername.height;
			addChild(tfUsername);
			
			var tf:TextFormat = new TextFormat();
			tf.font = Config.defaultFontName;
			tf.color = AppTheme.GREY_MEDIUM;
			tf.size = smallFontSize;
			
			serviceSprite = new Sprite();
			addChild(serviceSprite);
			
			avatar = new Sprite();
			addChild(avatar);
			
			tfDate = new TextField();
			tfDate.autoSize = TextFieldAutoSize.LEFT;
			tfDate.defaultTextFormat = dateFormat;
			tfDate.multiline = false;
			tfDate.wordWrap = false;
			tfDate.text = "00:00";
			tfDate.height = tfDate.textHeight + 4;
			tfDateWidth = tfDate.textWidth + 4;
			addChild(tfDate);
			
			avatarSupport = new Bitmap();		
			avatarSupport.bitmapData = UI.drawAssetToRoundRect(new LogoRectangle(), avatarSize * 2, true, "ListChatItem.avatarSupport");
			addChild(avatarSupport);		
			
			avatarWithLetter = new Sprite();
			avatarLettertext = new TextField();
			avatarWithLetter.addChild(avatarLettertext);
			var textFormat:TextFormat = new TextFormat();
			textFormat.font = Config.defaultFontName;
			textFormat.color = Color.WHITE;
			textFormat.size = avatarSize * 1.4;
			textFormat.align = TextFormatAlign.CENTER;
			avatarLettertext.defaultTextFormat = textFormat;
			avatarLettertext.selectable = false;
			avatarLettertext.width = avatarSize * 2;
			avatarLettertext.multiline = false;
			avatarLettertext.text = "A";
			avatarLettertext.height = avatarLettertext.textHeight + 4;
			avatarLettertext.y = int(avatarSize - (avatarLettertext.textHeight + 4) * .5);
			avatarLettertext.text = "";
			//avatarWithLetter.graphics.beginFill(AppTheme.GREY_MEDIUM);
			//avatarWithLetter.graphics.drawCircle(avatarSize, avatarSize, avatarSize);
			UI.drawElipseSquare(avatarWithLetter.graphics, avatarSize*2,avatarSize,AppTheme.GREY_MEDIUM);
								
			avatarWithLetter.graphics.endFill();
			addChild(avatarWithLetter);
			avatarWithLetter.visible = false;
			
			avatarDefault = new Bitmap();
			avatarDefault.bitmapData = UI.drawAssetToRoundRect(new DefaultAvatar(),avatarSize*2, true, "ListChatItem.avatarDefault");
			addChild(avatarDefault);			
			
			avatarDefault.visible = false;
			avatarSupport.visible = false;
			
			birdMine.graphics.beginFill(0x77C043);
			birdMine.graphics.moveTo(birdRadius * .8, 0);
			birdMine.graphics.curveTo(birdRadius * .9, birdSize, birdRadius * 1.7, birdRadius);
			birdMine.graphics.curveTo(birdRadius*1.5, birdRadius*1.4, birdSize*.8, birdSize*1.5);
			birdMine.graphics.lineTo(birdRadius * .8, 0);
			
			birdUser.graphics.beginFill(COLOR_BG_WHITE);
			birdUser.graphics.moveTo(birdSize, 0);
			birdUser.graphics.curveTo(birdRadius * .8, birdSize, 0, birdRadius);
			birdUser.graphics.curveTo(birdRadius * .6, birdRadius * 1.6, birdRadius * 1.3, birdSize);
			birdUser.graphics.lineTo(birdSize, 0);
			
			// SET COORDS
			
			avatar.x = sideMargin;
			avatarWithLetter.x = sideMargin;
			avatarSupport.x = sideMargin;
			avatarDefault.x = sideMargin;
			
			messageStatusClip = new MessageStatusClip();
			addChild(messageStatusClip);
			
			statusRadius = Config.FINGER_SIZE * .15;
			
			likeClip = new HeartIcon();
			UI.scaleToFit(likeClip, Config.FINGER_SIZE * .3, Config.FINGER_SIZE * .3);
			addChild(likeClip);
			
			likeClipSelected = new heartIconRed();
			UI.scaleToFit(likeClipSelected, Config.FINGER_SIZE * .3, Config.FINGER_SIZE * .3);
			addChild(likeClipSelected);
			
			likesFormat = new TextFormat("Tahoma", Config.FINGER_SIZE * .28, 0xFFFFFF);
			tfLikesNum = new TextField();
			tfLikesNum.autoSize = TextFieldAutoSize.LEFT;
			tfLikesNum.defaultTextFormat = likesFormat;
			tfLikesNum.multiline = false;
			tfLikesNum.wordWrap = false;
			tfLikesNum.text = "00";
			tfLikesNum.height = tfLikesNum.textHeight + 4;
			tfDateWidth = tfLikesNum.textWidth + 4;
			addChild(tfLikesNum);
			
			var scaleIcon:Number = 1;
			payRating = new SWFRatingStars_mc();
			payRating.scaleX = payRating.scaleY = avatarSize * 2 / 100 * scaleIcon;
			if (scaleIcon != 1)
				payRating.y = -(avatarSize * (1 - scaleIcon));
			payRating.mouseEnabled = false;
			payRating.mouseChildren = false;
			payRating.visible = false;
			payRating.x = avatarSize*2 - Config.FINGER_SIZE*.1;
			
			addChild(payRating);
			
			var scale:Number = avatarSize * 2 / 100;
			
			missDCIcon = new SWFCrownIcon();
			missDCIcon.scaleX = missDCIcon.scaleY = scale;
			missDCIcon.x = avatar.x + avatarSize;
		//	addChild(missDCIcon);
			
			missDCIcon.y = avatar.y + avatarSize;
		}
		
		private static function parseMessage(messageData:ChatMessageVO):void {
			if (messageData.crypted == false)
				return;
			if (ChatManager.getCurrentChat() == null) {
				messageData.decrypt(null);
				return;
			}
			messageData.decrypt(ChatManager.getCurrentChat().chatSecurityKey, ChatManager.getCurrentChat().pin);
		}
		
		override public function getSelectedHitzone(itemTouchPoint:Point, listItem:ListItem):HitZoneData {
			if (listItem.data is ChatMessageVO) {
				var messageData:ChatMessageVO = listItem.data as ChatMessageVO;
				var messageType:String = getMessageType(messageData);
				var renderer:IMessageRenderer = getRenderer(messageType);
				
				var h:int;
				
				if (renderer != null && renderer is ChatMessageRendererAdditionalQuestionsSettings) {
					h = getHeight(listItem, listItem.width);
					getView(listItem, h, listItem.width, false);
					return renderer.getSelectedHitzone(itemTouchPoint, listItem);
				} else if (renderer != null && renderer is ChatMessageRendererText) {
					h = getHeight(listItem, listItem.width);
					getView(listItem, h, listItem.width, false);
					return renderer.getSelectedHitzone(itemTouchPoint, listItem);
				}
			}
			return null;
		}
		
		public function getHeight(listItem:ListItem, width:int):int {
			if (!(listItem.data is ChatMessageVO)) {
				if (!listItem.data)
					return Config.FINGER_SIZE * .5;
				if (listItem.data.title == "button")
					return Config.FINGER_SIZE;				
					
				listItem.elementYPosition = Config.FINGER_SIZE * 0.3;
				return Config.FINGER_SIZE * .5 + listItem.elementYPosition;
			}
			var messageData:ChatMessageVO = listItem.data as ChatMessageVO;
			parseMessage(messageData);
			if (messageData.systemMessageVO != null &&
				messageData.systemMessageVO.type != null) {
					if (messageData.systemMessageVO.method != null && messageData.systemMessageVO.method.toLowerCase() == "vi") {
						if (messageData.systemMessageVO.type == "calendar" || messageData.systemMessageVO.type == "fasttrack") {
							return 0;
						}
					}
					if (messageData.systemMessageVO.type.indexOf("supporter") !=-1)
						return 0;
					if (messageData.systemMessageVO.method == ChatSystemMsgVO.METHOD_BOT_COMMAND) {
						if (messageData.systemMessageVO.title == null || messageData.systemMessageVO.title == "")
							return 0;
					}
					if (messageData.systemMessageVO.type == ChatSystemMsgVO.TYPE_911 &&
						messageData.systemMessageVO.method == ChatSystemMsgVO.METHOD_911_GEO)
							ChatManager.initGeo(messageData);
				
			}
			if (messageData.stiking == ChatMessageVO.STICKING_NOT_DEFINED) {
				if (listItem.num > 0) {
					if (listItem.list != null && listItem.list.data != null && 
						(listItem.list.data is Array) && (listItem.list.data as Array).length >= listItem.num - 1 &&
						(listItem.list.data[listItem.num - 1] is ChatMessageVO)) {
						var prewMessageData:ChatMessageVO = listItem.list.data[listItem.num - 1];
						if (prewMessageData != null) {
							parseMessage(prewMessageData);
							ChatMessagesStickingManager.updateMessagesStickingByIndex(messageData, prewMessageData);
						} else
							messageData.stiking = ChatMessageVO.STICKING_NO;
					} else
						messageData.stiking = ChatMessageVO.STICKING_NO;
				} else
					messageData.stiking = ChatMessageVO.STICKING_NO;
			}
			listItem.addImageFieldForLoading('avatarForChat');
			if (messageData.systemMessageVO != null && messageData.systemMessageVO.imageThumbURL != null)
				listItem.addImageFieldForLoading('imageThumbURLWithKey');
			var messageType:String = getMessageType(messageData);
			var maxItemWidth:int = getMaxItemWidth(width, messageType);
			var renderer:IMessageRenderer = getRenderer(messageType);
			setChildIndex(avatar, numChildren - 1);
			setChildIndex(avatarDefault, numChildren - 1);
			setChildIndex(avatarWithLetter, numChildren - 1);
			setChildIndex(avatarWithLetter, numChildren - 1);
			var h:int = minHeight;
			var smallGap:int;
			if (renderer) {
				smallGap = renderer.getSmallGap(listItem);
				h = renderer.getHeight(messageData, maxItemWidth, listItem);
			} else
				smallGap = Config.FINGER_SIZE * .06;
			if (needShowUsername(messageData, listItem) && 
				messageType != MESSAGE_TYPE_CHAT_SYSTEM_MESSAGE && 
				messageType != MESSAGE_TYPE_ACTION && 
				messageType != MESSAGE_TYPE_SYSTEM_MESSAGE && 
				messageType != MESSAGE_TYPE_CALL && 
				messageType != MESSAGE_TYPE_TIPS_WINNER)
					h += usernameH + Config.FINGER_SIZE * .04;
			if (messageData.stiking == ChatMessageVO.STICKING_YES) {
				listItem.elementYPosition = smallGap * 1;
				h += smallGap * 1;
			} else {
				if (h != 0)
				{
					listItem.elementYPosition = smallGap * 5;
					h += smallGap * 5;
				}
			}
			
			/*if (listItem.list.data!=null && listItem.num == listItem.list.data.length - 1)
				h += smallGap * 5;*/
			return Math.min(8000, h);
		}
		
		private function needShowUsername(messageData:ChatMessageVO, listItem:ListItem):Boolean{
			
			var result:Boolean = false;
			
			//для системных сообщений в 911 нужно отображать имя 911, нужно переделать на явный признак а не идентифицировать только первое;
			if (messageData.name == "911" && messageData.isEntryMessage && listItem.num == 0)
				result = true;
			
			if (ChatManager.getCurrentChat() != null && 
				(ChatManager.getCurrentChat().type == ChatRoomType.GROUP || 
				ChatManager.getCurrentChat().type == ChatRoomType.CHANNEL) && 
				messageData.userUID != Auth.uid)
			{
				result = true;
				if (listItem.num > 0 && listItem.list.getStock()[listItem.num - 1].data is ChatMessageVO && listItem.list.getStock()[listItem.num - 1].data.userUID == listItem.data.userUID)
				{
					result = false;
				}
			}
			
			return result;
		}
		
		private function getMessageType(messageData:ChatMessageVO):String {
			if (messageData.action)
				return MESSAGE_TYPE_ACTION;
			if (messageData.systemMessage)
				return MESSAGE_TYPE_SYSTEM_MESSAGE;
			if (messageData.systemMessageVO == null)
				return MESSAGE_TYPE_TEXT;
			if (messageData.typeEnum == ChatMessageType.FORWARDED) {
				messageData = messageData.systemMessageVO.forwardVO;
				if (messageData.crypted == true)
					parseMessage(messageData);
				if (messageData.systemMessageVO == null)
					return MESSAGE_TYPE_TEXT;
			}
			if (messageData.typeEnum == ChatMessageType.STICKER)
				return MESSAGE_TYPE_STICKER;
			if (messageData.typeEnum == ChatSystemMsgVO.TYPE_LOCAL_QUESTION)
				return MESSAGE_TYPE_EXTRA_REWARDS;
			if (messageData.typeEnum == ChatSystemMsgVO.TYPE_VOICE)
				return MESSAGE_TYPE_VOICE;
			if (messageData.typeEnum == ChatSystemMsgVO.TYPE_911 || messageData.typeEnum == ChatSystemMsgVO.TYPE_COMPLAIN)
				return MESSAGE_TYPE_TEXT;
			if (messageData.typeEnum == ChatSystemMsgVO.TYPE_FILE) {
				if (messageData.systemMessageVO.fileType == ChatSystemMsgVO.FILETYPE_IMG || messageData.systemMessageVO.fileType == ChatSystemMsgVO.FILETYPE_IMG_CRYPTED)
					return MESSAGE_TYPE_UPDLOAD_IMAGE;
				else if (messageData.systemMessageVO.fileType == ChatSystemMsgVO.FILETYPE_VIDEO)
				{
					return MESSAGE_TYPE_UPDLOAD_IMAGE;
				}
				else if (messageData.systemMessageVO.fileType == ChatSystemMsgVO.FILETYPE_PUZZLE_CRYPTED)
				{
					return MESSAGE_TYPE_UPDLOAD_IMAGE;
				}
				return MESSAGE_TYPE_FILE;
			}
			if (messageData.typeEnum == ChatSystemMsgVO.TYPE_INVOICE)
				return MESSAGE_TYPE_INVOICE;
			if (messageData.typeEnum == ChatSystemMsgVO.TYPE_CHAT_SYSTEM) {
				if (messageData.systemMessageVO != null && messageData.systemMessageVO.method == ChatSystemMsgVO.METHOD_NEWS) {
					return MESSAGE_TYPE_NEWS;
				}
				if (messageData.systemMessageVO != null && messageData.systemMessageVO.method == ChatSystemMsgVO.METHOD_CALL) {
					return MESSAGE_TYPE_CALL;
				}
				if (messageData.systemMessageVO != null && messageData.systemMessageVO.method == ChatSystemMsgVO.METHOD_CALL_VIDID) {
					return MESSAGE_TYPE_CALL;
				}
				if (messageData.systemMessageVO != null && messageData.systemMessageVO.method == ChatSystemMsgVO.METHOD_TIPS_PAID) {
					return MESSAGE_TYPE_TIPS_WINNER;
				}
				if (messageData.systemMessageVO != null && messageData.systemMessageVO.method == ChatSystemMsgVO.METHOD_BOT_MENU) {
					return MESSAGE_TYPE_BOT_MENU;
				}
				if (messageData.systemMessageVO != null && messageData.systemMessageVO.method == ChatSystemMsgVO.METHOD_BOT_COMMAND){
					return MESSAGE_TYPE_BOT_COMMAND;
				}
				if (messageData.systemMessageVO != null && messageData.systemMessageVO.method == ChatSystemMsgVO.METHOD_BOT_COMMAND){
					return MESSAGE_TYPE_BOT_COMMAND;
				}
				return MESSAGE_TYPE_CHAT_SYSTEM_MESSAGE;
			}
			if (messageData.typeEnum == ChatSystemMsgVO.TYPE_GIFT)
				return MESSAGE_TYPE_GIFT;
			if (messageData.typeEnum == ChatSystemMsgVO.TYPE_MONEY)
				return MESSAGE_TYPE_MONEY;
			return null;
		}
		
		private function getMaxItemWidth(widthValue:int, messageType:String):int {
			var result:int;
			if (messageType == MESSAGE_TYPE_SYSTEM_MESSAGE || messageType == MESSAGE_TYPE_CALL)
				result = widthValue * .8 - sideMargin * 2;
			else if (messageType == MESSAGE_TYPE_NEWS)
				result = (widthValue * 1.0 - tfDateWidth) - (avatarDoubleSize + sideMargin * 3.5) - birdSize;
			else
				result = (widthValue * .9 - tfDateWidth) - (avatarDoubleSize + sideMargin * 2) - birdSize;
			return result;
		}
		
		private function getRenderer(messageType:String):IMessageRenderer {
			switch (messageType) {
				case MESSAGE_TYPE_ACTION: {
					return chatMessageButtonRenderer;
				}
				case MESSAGE_TYPE_BOT_MENU: {
					return chatMessageBotMenuRenderer;
				}		
				case MESSAGE_TYPE_BOT_COMMAND: {
					return chatMessageBotCommandRenderer;
				}				
				case MESSAGE_TYPE_INVOICE: {
					return chatMessageInvoiceRenderer;
				}
				case MESSAGE_TYPE_STICKER: {
					return chatMessageStickerRenderer;
				}
				case MESSAGE_TYPE_SYSTEM_MESSAGE: {
					return chatMessageSystemMessageRenderer;
				}
				case MESSAGE_TYPE_TEXT: {
					return chatMessageTextRenderer;
				}
				case MESSAGE_TYPE_FILE: {
					return chatMessageFileRenderer;
				}
				case MESSAGE_TYPE_UPDLOAD_IMAGE: {
					return chatMessageUploadingImageRenderer;
				}
				case MESSAGE_TYPE_VOICE: {
					return chatMessageVoiceRenderer;
				}
				case MESSAGE_TYPE_EXTRA_REWARDS: {
					return chatMessageExtraRewardsRenderer;
				}
				case MESSAGE_TYPE_CHAT_SYSTEM_MESSAGE: {
					return chatMessageChatSystemRenderer;
				}
				case MESSAGE_TYPE_GIFT: {
					return chatMessageGiftRenderer;
				}
				case MESSAGE_TYPE_MONEY: {
					return chatMessageMoneyRenderer;
				}
				case MESSAGE_TYPE_TIPS_WINNER: {
					return chatMessageTipsWinnerRenderer;
				}
				case MESSAGE_TYPE_NEWS: {
					return chatMessageNewsRenderer;
				}
				case MESSAGE_TYPE_CALL: {
					return chatMessageCallRenderer;
				}
				default: {
					return chatMessageTextRenderer;
				}
			}
			return null;
		}
		
		private function getInvoiceItemWidth(itemWidth:int):int
		{
			return Math.min(itemWidth - sideMargin * 2 - avatarSize * 2 - int(Config.FINGER_SIZE * .26) - tfDateWidth, Config.FINGER_SIZE * 5);
		}
		
		public function getView(data:ListItem, height:int, width:int, highlight:Boolean = false):IBitmapDrawable
		{
			hideRenderers();
			
			tfDate.text = "";
			tfDate.filters = null;
			tfDate.visible = true;
			avatarSupport.visible = false;
			avatarDefault.visible = false;
			avatar.visible = false;
			avatarWithLetter.visible = false;
			
			birdMine.visible = false;
			birdUser.visible = false;
			tfUsername.visible = false;
			likeClip.visible = false;
			likeClipSelected.visible = false;
			tfLikesNum.visible = false;
			
			messageStatusClip.visible = false;
			payRating.visible = false;
			
			serviceSprite.graphics.clear();
			
			if (avatar != null)
				avatar.graphics.clear();
			
			if (height == 0){
				return this;
			}
			
			if (permanentBanMark != null)
				permanentBanMark.visible = false;
			if (banMark != null)
				banMark.visible = false;
				
			if (data.data == null)
				return this;
			
			if (data.data is Date) {
				var date:Date = new Date();
				if (date.getFullYear() == data.data.getFullYear() && date.getMonth() == data.data.getMonth() && date.getDate() == data.data.getDate())
					tfDate.text = Lang.textToday.toUpperCase(); //"TODAY";
				else {
					date.setTime(date.getTime() - 86400000);
					if (date.getFullYear() == data.data.getFullYear() && date.getMonth() == data.data.getMonth() && date.getDate() == data.data.getDate())
						tfDate.text = Lang.textYesterday.toUpperCase(); //"YESTERDAY";
					else
						tfDate.text = Lang.getMonthTitleByIndex(data.data.getMonth()) + " " + data.data.getDate() + ", " + data.data.getFullYear();
				}
				
				var radius:int = Config.MARGIN * 2.5;
				var hPadding:int = Config.MARGIN * 4;
				var vPadding:int = int((height - tfDate.height - data.elementYPosition) * .5);
				
				tfDate.x = int((width - tfDate.width) * .5);
				tfDate.y = vPadding + data.elementYPosition;
				tfDate.textColor = Style.color(Style.MESSAGE_DATE_COLOR);
				serviceSprite.graphics.beginFill(0, Style.value(Style.MESSAGE_DATE_BACK_ALPHA));
				serviceSprite.graphics.drawRoundRect(0, 0, tfDate.width + hPadding, height - data.elementYPosition, radius, radius);
				serviceSprite.graphics.endFill();
				serviceSprite.visible = true;
				serviceSprite.x = int(tfDate.x - hPadding / 2);
				serviceSprite.y = data.elementYPosition;
				
				return this;
			}
			tfDate.textColor = Style.color(Style.MESSAGE_DATE_COLOR);
			
			var messageData:ChatMessageVO = data.data as ChatMessageVO;
			
			if (messageData == null)
				return this;
			
			parseMessage(messageData);
			
			var isMine:Boolean = Auth.uid === messageData.userUID;
			var messageType:String = getMessageType(messageData);
			
			var maxItemWidth:int = getMaxItemWidth(width, messageType);
			
			var renderer:IMessageRenderer = getRenderer(messageType);
			lastRenderer = renderer;
			var needUpdateHitzones:Boolean = true;
			if (data.drawnHeight == height && data.drawnWidth == width)
				needUpdateHitzones = false;
			
			data.drawnHeight = height;
			data.drawnWidth = width;
			
			if (messageType == MESSAGE_TYPE_UPDLOAD_IMAGE) {
				if (messageData.systemMessageVO != null && 
					messageData.systemMessageVO.fileType == ChatSystemMsgVO.FILETYPE_VIDEO)
				{
					needUpdateHitzones = true;
				}
			}
			
			if (needUpdateHitzones) {
				var hitZones:Array = data.getHitZones();
				if (hitZones == null)
				{
					hitZones = new Array();
				}
				else
				{
					hitZones.length = 0;
				}
			}
			
			tfUsername.y = 0;
			
			if (renderer) {
				renderer.visible = true;
				var imageKey:Array;
				if (ChatManager.getCurrentChat() != null)
				{
					imageKey = ChatManager.getCurrentChat().imageKey;
				}
				renderer.draw(messageData, maxItemWidth, data, imageKey);
				
				if (messageType == MESSAGE_TYPE_SYSTEM_MESSAGE || messageType == MESSAGE_TYPE_CHAT_SYSTEM_MESSAGE || messageType == MESSAGE_TYPE_TIPS_WINNER || messageType == MESSAGE_TYPE_CALL)
				{
					renderer.x = int(width * .5 - renderer.getWidth() * .5);
				}
				else {
					if (isMine)
						renderer.x = int(width - sideMargin - int(Config.FINGER_SIZE * .26) - renderer.getWidth());
					else
						renderer.x = int(sideMargin + avatarSize * 2 + int(Config.FINGER_SIZE * .26));
				}
				
				if (needShowUsername(messageData, data) && 
					messageType != MESSAGE_TYPE_CHAT_SYSTEM_MESSAGE && 
					messageType != MESSAGE_TYPE_ACTION && 
					messageType != MESSAGE_TYPE_SYSTEM_MESSAGE && 
					messageType != MESSAGE_TYPE_CALL && 
					messageType != MESSAGE_TYPE_TIPS_WINNER)
				{
					tfUsername.visible = true;
					checkUsernameColor();
					
					var userName:String;
					
					if (messageData.userVO != null && messageData.userVO.getDisplayName() != null) {
						userName = messageData.userVO.getDisplayName();
					}
					else {
						userName = data.data.name;
					}
					
					if ("phonebookName" in data.data && data.data.phonebookName != null && data.data.phonebookName != "") {
						userName = data.data.phonebookName;
					}
					else {
						var phoneBookname:String = PhonebookManager.getUsernameByUserUID(data.data.userUID);
						if (phoneBookname && phoneBookname != "") {
							data.data.phonebookName = phoneBookname;
						}
						else {
							data.data.phonebookName = "";
						}
						
						if (data.data.phonebookName != null && data.data.phonebookName != "") {
							userName = data.data.phonebookName;
						}
					}
					var chat:ChatVO = ChatManager.getCurrentChat();
					if (ChatManager.getCurrentChat() != null && ChatManager.getCurrentChat().users != null)
					{
						var user:ChatUserVO = ChatManager.getCurrentChat().getUser(messageData.userUID);
						if (user != null && user.secretMode == true)
						{
							userName = Lang.textIncognito;
						}
					}
					if (userName != null)
					{
						tfUsername.text = userName;
					}
					renderer.y = tfUsername.y + usernameH + Config.FINGER_SIZE * .04 + data.elementYPosition;
					tfUsername.x = renderer.x;
				}
				else
				{
					renderer.y = data.elementYPosition;
				}
				
				tfUsername.y = data.elementYPosition;
				
				if (messageData.created == 0 || messageType == MESSAGE_TYPE_SYSTEM_MESSAGE || messageType == MESSAGE_TYPE_ACTION || messageType == MESSAGE_TYPE_BOT_MENU)
				{
					tfDate.visible = false;
				}
				else
				{
					if (data.drawTime)
					{
						dt.setTime(data.data.created * 1000);
						var h:int = dt.getHours();
						var m:int = dt.getMinutes();
						
						tfDate.visible = true;
						tfDate.text = ((h < 10) ? '0' + h : h) + ':' + ((m < 10) ? '0' + m : m);
						if (isMine)
						{
							tfDate.y = int(renderer.y + renderer.getContentHeight() - (tfDate.textHeight + 4) - Config.FINGER_SIZE * .05);
							tfDate.x = int(renderer.x - tfDate.width - Config.FINGER_SIZE * .05);
						}
						else
						{
							tfDate.y = int(renderer.y + renderer.getContentHeight() - (tfDate.textHeight + 4) - Config.FINGER_SIZE * .05);
							tfDate.x = int(renderer.x + renderer.getWidth() + Config.FINGER_SIZE * .05);
						}
					}
					
					// reactions;
					if (messageData.id != 0 && 
						messageType != MESSAGE_TYPE_TIPS_WINNER && 
						messageType != MESSAGE_TYPE_CHAT_SYSTEM_MESSAGE && 
						messageType != MESSAGE_TYPE_BOT_MENU && 
						messageType != MESSAGE_TYPE_CALL && 
						messageType != MESSAGE_TYPE_NEWS) {
						var reactionsClip:Sprite;
						var mineReactionExist:Boolean = false;
						
						if (messageData.reactions != null) {
							var l:int = messageData.reactions.length;
							var likes:int = 0;
							for (var i:int = 0; i < l; i++) 
							{
								if (messageData.reactions[i].userUID == Auth.uid) {
									mineReactionExist = true;
								}
								if (messageData.reactions[i].reaction == ChatMessageReactionType.LIKE) {
									likes ++;
								}
							}
						}
						
						if (mineReactionExist == true)
							reactionsClip = likeClipSelected;
						else {
							if (isMine && likes == 0) {
								
							}
							else {
								reactionsClip = likeClip;
							}
						}
						
						if (reactionsClip != null) {
							var reactionClipYPos:int = renderer.y + renderer.getContentHeight() * .5 - reactionsClip.height * .5;
							if (tfDate.visible == true && tfDate.text != "" && reactionClipYPos + reactionsClip.height > tfDate.y) {
								reactionClipYPos = Math.max(0, int(tfDate.y - reactionsClip.height));
							}
							reactionsClip.y = reactionClipYPos;
							
							reactionsClip.visible = true;
							if (isMine) {
								if (likes > 0) {
									tfLikesNum.text = likes.toString();
									reactionsClip.x = int(renderer.x - reactionsClip.width - Config.FINGER_SIZE * .2 - tfLikesNum.width - Config.FINGER_SIZE * .05);
								}
								else {
									reactionsClip.x = int(renderer.x - reactionsClip.width - Config.FINGER_SIZE * .2);
								}
							}
							else {
								reactionsClip.x = int(renderer.x + renderer.getWidth() + Config.FINGER_SIZE * .2);
								
								var tapPadding:int = (Config.FINGER_SIZE - reactionsClip.height) * .5;
								
								if (needUpdateHitzones) {
									if (mineReactionExist == true) {
										hitZones.push(
											{
												type: HitZoneType.REMOVE_REACTION_LIKE,
												x: reactionsClip.x - tapPadding,
												y: reactionClipYPos - tapPadding, 
												width: reactionsClip.width + Config.FINGER_SIZE,
												height: reactionsClip.height + Config.FINGER_SIZE
											}
										);
									} else {
										hitZones.push(
											{
												type: HitZoneType.ADD_REACTION_LIKE,
												x: reactionsClip.x - tapPadding,
												y: reactionClipYPos - tapPadding, 
												width: reactionsClip.width + Config.FINGER_SIZE,
												height: reactionsClip.height + Config.FINGER_SIZE
											}
										);
									}
									
								}
							}
							
							if (likes > 0)	{
								tfLikesNum.visible = true;
								tfLikesNum.text = likes.toString();
								
								if (isMine) {
									tfLikesNum.y = int(reactionsClip.y + reactionsClip.height * .5 - tfLikesNum.height * .5);
									tfLikesNum.x = int(reactionsClip.x + reactionsClip.width + Config.FINGER_SIZE * .05);
								}
								else {
									
									tfLikesNum.y = int(reactionsClip.y + reactionsClip.height * .5 - tfLikesNum.height * .5);
									tfLikesNum.x = int(reactionsClip.x + reactionsClip.width + Config.FINGER_SIZE * .05);
									
									if (tfLikesNum.x + tfLikesNum.width > width)
									{
										tfLikesNum.x = int(reactionsClip.x + reactionsClip.width * .5 - tfLikesNum.width * .5);
										if (tfLikesNum.x < renderer.x + renderer.getWidth() + Config.FINGER_SIZE * .06)
										{
											tfLikesNum.x = reactionsClip.x;
										}
										tfLikesNum.y = int(reactionsClip.y + reactionsClip.height + Config.FINGER_SIZE * .06);
									}
								}
							}
						}
					}
				}
				
				var imageWasExist:Boolean = false;
				var maxTextWidth:int = (width * .8 - tfDateWidth) - (avatarDoubleSize + sideMargin * 2) - birdSize;
				
				var isLastMessage:Boolean = isLastUserMessageInStack(data);
				
				if (isLastMessage && 
						messageType != MESSAGE_TYPE_ACTION && 
						messageType != MESSAGE_TYPE_SYSTEM_MESSAGE && 
						messageType != MESSAGE_TYPE_EXTRA_REWARDS &&
						messageType != MESSAGE_TYPE_CALL &&
						messageType != MESSAGE_TYPE_CHAT_SYSTEM_MESSAGE && 
						messageType != MESSAGE_TYPE_TIPS_WINNER)
				{
					var customContentHeight:Number = renderer.getContentHeight();					
					if ("getCustomContentHeight" in renderer){
						var overrideHeight:Number = renderer['getCustomContentHeight']();
						if(overrideHeight>0){
							customContentHeight = overrideHeight;
 						}
					}					
					var avatarY:int = renderer.y + customContentHeight;
					
					displayAvatar(data, avatarSize, avatarY, -1, null, true, renderer);
					
					if (needUpdateHitzones)
					{											
						hitZones.push( { type: HitZoneType.AVATAR, x: avatar.x - Config.MARGIN, y: avatar.y - Config.MARGIN, 
										width: avatarDoubleSize + Config.MARGIN * 2, height: avatarDoubleSize + Config.MARGIN * 2 } );						
					}
					
					if (messageType == MESSAGE_TYPE_TEXT || messageType == MESSAGE_TYPE_UPDLOAD_IMAGE || 
						messageType == MESSAGE_TYPE_VOICE || messageType == MESSAGE_TYPE_GIFT || 						
						messageType == MESSAGE_TYPE_MONEY || messageType == MESSAGE_TYPE_NEWS)
					{
						if (renderer.isReadyToDisplay)
						{
							birdUser.visible = true;
							colorTransform.color = renderer.getBackColor();
							birdUser.transform.colorTransform = colorTransform;
							birdUser.y = renderer.y + renderer.getContentHeight() - birdUser.height - Config.FINGER_SIZE * .1;
							birdUser.x = sideMargin + avatarSize * 2 + int(Config.FINGER_SIZE * .03);
						}
					}
					
					if (messageType == MESSAGE_TYPE_BOT_MENU)
					{
						if (renderer.isReadyToDisplay) {
							birdUser.visible = true;
							colorTransform.color = renderer.getBackColor();							
							birdUser.transform.colorTransform = colorTransform;
							birdUser.y = avatarY-birdUser.height-  Config.FINGER_SIZE * .1;// customContentHeight -  Config.FINGER_SIZE * .1;							
							birdUser.x = sideMargin + avatarSize * 2 + int(Config.FINGER_SIZE * .03);
							
							if ("selectedMenuIndex" in data.data){
								
								var isLastMenuItemSelected:Boolean = data.data.selectedMenuIndex == data.data.numMenuItems-1;
								var isBirdOverMenu:Boolean = renderer["birdOverMenu"];
								var menuSelected:Boolean = data.data.selectedMenuIndex != -1
								if (menuSelected){
									birdUser.alpha = isBirdOverMenu && !isLastMenuItemSelected ? 0.4:1; // -> esli naprotiv menu
								}else{
									birdUser.alpha = 1;
								}
							}else{
								birdUser.alpha = 1;
							}	
						}
					}
					
					if (messageType == MESSAGE_TYPE_BOT_COMMAND){
						if (renderer.isReadyToDisplay) {
							birdUser.visible = false;		
							birdMine.visible = false;
							//messageStatusClip.visible = true;
							
						}
					}
				}
				else if (messageType == MESSAGE_TYPE_TIPS_WINNER)
				{
					displayAvatar(data, avatarSize * 2, renderer.y + avatarSize * 4, renderer.x + renderer.getWidth() * .5 - avatarSize * 2, null, false);
					
					if (needUpdateHitzones)
					{
						hitZones.push( { type: HitZoneType.AVATAR, x: avatar.x - Config.MARGIN, y: avatar.y - Config.MARGIN, 
										width: avatarDoubleSize*2 + Config.MARGIN * 2, height: avatarDoubleSize*2 + Config.MARGIN * 2 } );
					}
				}
				else if (messageType == MESSAGE_TYPE_CALL)
				{
					displayAvatar(data, avatarSize, 
									renderer.y + Config.FINGER_SIZE * .1 + avatarSize * 2, 
									renderer.x + avatarSize * .5, 
									null, false, null, true);
					
					if (needUpdateHitzones)
					{
						hitZones.push( { type: HitZoneType.AVATAR, x: avatar.x - Config.MARGIN, y: avatar.y - Config.MARGIN, 
										width: avatarDoubleSize * 2 + Config.MARGIN * 2, height: avatarDoubleSize * 2 + Config.MARGIN * 2 } );
						if (data != null && data.data != null && (data.data is ChatMessageVO) && (data.data as ChatMessageVO).systemMessageVO.callVO != null && (data.data as ChatMessageVO).systemMessageVO.callVO.vidid == false)
						{
							hitZones.push( { type: HitZoneType.CALL, 
												x: renderer.x + renderer.getWidth() - Config.FINGER_SIZE * .2 - Config.FINGER_SIZE * .2 - Config.MARGIN, 
												y: renderer.y + Config.FINGER_SIZE*.1 - Config.MARGIN, 
										width: Config.FINGER_SIZE * .4 + Config.MARGIN * 2, 
										height: Config.FINGER_SIZE * .4 + Config.MARGIN * 2 } );
						}
						
					}
				}
				
				if (renderer != null)
				{
					renderer.alpha = 1;
				}
				tfUsername.alpha = 1;
				if (data != null && data.data != null && (data.data is ChatMessageVO) && renderer != null)
				{
					checkForUserBan(UsersManager.getUserByMessageObject(data.data as ChatMessageVO), renderer, isLastMessage);
				}
				
				if (isLastSelfMessageInStack(data))
				{
					if (messageType == MESSAGE_TYPE_TEXT || messageType == MESSAGE_TYPE_UPDLOAD_IMAGE || 
						messageType == MESSAGE_TYPE_VOICE || messageType == MESSAGE_TYPE_GIFT || messageType == MESSAGE_TYPE_MONEY)
					{
						if (renderer.isReadyToDisplay)
						{
							birdMine.visible = true;
							colorTransform.color = renderer.getBackColor();
							birdMine.transform.colorTransform = colorTransform;
							//birdMine.y = renderer.y + renderer.getContentHeight() - birdMine.height - Config.FINGER_SIZE * .1;
							birdMine.y = renderer.y + renderer.getContentHeight() - birdMine.height - Config.FINGER_SIZE /5;
							birdMine.x = renderer.x + renderer.getWidth() - int(Config.FINGER_SIZE * .23);
						}
					}
				}
				
				var animatedZone:AnimatedZoneVO = renderer.animatedZone;
				
				if (animatedZone != null)
				{
					if (birdMine.visible)
					{
						animatedZone.rect.width += birdMine.width;
					}
					else if (birdUser.visible)
					{
						animatedZone.rect.width += birdMine.width;
						animatedZone.rect.x -= birdUser.width;
					}
					if (animatedZone.isAnimateImmeliately)
					{
						data.animateImage(animatedZone.name, animatedZone.rect);
					}
					else
					{
						data.setAnimatedZone(animatedZone.name, animatedZone.rect);
					}
				}
				
				if (messageType != MESSAGE_TYPE_CHAT_SYSTEM_MESSAGE && messageType != MESSAGE_TYPE_CALL)
				{
					updateMessageStatus(messageData, renderer, isMine);
				}
				
				if (needUpdateHitzones)
				{
					renderer.updateHitzones(hitZones);
					
					if (data.getHitZones() == null)
					{
						data.setHitZones(hitZones);
					}
				}
			}
			
			return this;
		}
		
		private function checkUsernameColor():void 
		{
			if (ChatManager.getCurrentChat() != null && ChatManager.getCurrentChat().settings != null && 
				(isNaN(lastBackgroundBrightness) || ChatManager.getCurrentChat().settings.backgroundBrightness != lastBackgroundBrightness))
			{
				lastBackgroundBrightness = ChatManager.getCurrentChat().settings.backgroundBrightness;
				tfUsername.alpha = 0.75;
				if (lastBackgroundBrightness > 0.5)
				{
					tfUsername.textColor = 0;
				}
				else {
					tfUsername.textColor = 0xFFFFFF;
				}
			}
		}
		
		private function updateMessageStatus(messageData:ChatMessageVO, renderer:IMessageRenderer, isMine:Boolean):void
		{
			if (ChatManager.getCurrentChat() != null && ChatManager.getCurrentChat().users != null && ChatManager.getCurrentChat().users.length > 0 &&
				ChatManager.getCurrentChat().users[0].uid == Config.NOTEBOOK_USER_UID){
				return;
			}
			
			if (isMine)
			{
				var cVO:ChatVO = ChatManager.getCurrentChat();
				
				if (cVO && cVO.type != ChatRoomType.GROUP)
				{
					var status:String = cVO.getMsgStatusCode(messageData.id);
					if (status == ChatMessageVO.STATUS_READ && cVO.getLastReadMessageId() != messageData.id)
						status = null;
					if (status != null) {
						messageStatusClip.visible = true;
						messageStatusClip.setStatus(status);
						
						messageStatusClip.x = renderer.x - messageStatusClip.width - Config.FINGER_SIZE * .1;
						messageStatusClip.y = renderer.y + renderer.getContentHeight() - messageStatusClip.height - Config.FINGER_SIZE * .07;
						
						if (tfDate.visible)
						{
							tfDate.x -= messageStatusClip.width + Config.FINGER_SIZE * .1;
						}
					}
				}
				
				if (messageData != null){
					if (messageData.systemMessageVO != null && messageData.systemMessageVO.method == ChatSystemMsgVO.METHOD_BOT_COMMAND ){
							messageStatusClip.visible = false;
					}
				}
			}
		}
		
		private function displayAvatar(data:ListItem, size:int, yPosition:int, xPosition:int = -1, userName:String = null, showLetterAvatar:Boolean = true, renderer:IMessageRenderer = null, hideStars:Boolean = false):void
		{
			var avatarBmp:ImageBitmapData = data.getLoadedImage('avatarForChat');
			var user:UserVO;
			
			if (ChatManager.getCurrentChat() && ChatManager.getCurrentChat().type == ChatRoomType.COMPANY) {
				setChildIndex(avatarSupport, numChildren - 1);
				avatarSupport.visible = true;
			}
			else if (avatarBmp != null && avatarBmp.isDisposed == false)
			{
				avatar.visible = true;
				var scaleMode:int;
				if (avatarBmp.width == size * 2 && avatarBmp.height == size * 2)
					scaleMode = ImageManager.SCALE_NONE;
				else
					scaleMode = ImageManager.SCALE_PORPORTIONAL;
					
				ImageManager.drawGraphicCircleImage(avatar.graphics, size, size, size, avatarBmp, scaleMode);
			}
			else
			{
				if (ChatManager.getCurrentChat() && ChatManager.getCurrentChat().type == ChatRoomType.COMPANY) {
					avatarSupport.visible = true;
				} else if(showLetterAvatar == true) {
					var title:String;
					if (userName != null && userName != "") {
						title = userName;
					} else {
						user = UsersManager.getUserByMessageObject(data.data as ChatMessageVO);
						if (user) {
							title = user.getDisplayName();
						}
						else if ("name" in data.data && data.data.name != null && String(data.data.name).length > 0) {
							title = data.data.name;
						}
					}
					
					if (title && AppTheme.isLetterSupported(title.charAt(0))) {
						avatarLettertext.text = title.charAt(0).toUpperCase();
						avatarWithLetter.graphics.clear();
						UI.drawElipseSquare(avatarWithLetter.graphics, size*2,size,AppTheme.getColorFromPallete(String(data.data.name)));
						
						avatarWithLetter.visible = true;
						avatar.visible = false;
						avatarDefault.visible = false;
					} else {
						showDefaultAvatar(size);
					}
				} else {
					showDefaultAvatar(size);
				}
			}
			
			var yPos:int = yPosition - size * 2;
			avatarWithLetter.y = yPos;
			
			if (xPosition != -1)
			{
				avatar.x = xPosition;
				avatarSupport.x = xPosition;
				avatarDefault.x = xPosition;
			}
			else
			{
				
				avatar.x = sideMargin;
				avatarSupport.x = sideMargin;
				avatarDefault.x = sideMargin;
			}
			
			avatar.y = yPos;
			avatarSupport.y = yPos;
			avatarDefault.y = yPos;
			
			if (hideStars == true || data.data == null || !(data.data is ChatMessageVO) || ((data.data as ChatMessageVO).userVO == null) || 
				(data.data as ChatMessageVO).userVO.payRating == -1 || (data.data as ChatMessageVO).userVO.payRating == 0) {
				payRating.visible = false;
			} else {
				payRating.visible = true;
				payRating.x = avatar.x + size;
				setChildIndex(payRating, numChildren - 1);
				payRating.scaleX = payRating.scaleY = size * 2 / 100 * 1;
				payRating.y = yPos + size;
				payRating.gotoAndStop((data.data as ChatMessageVO).userVO.payRating);
			}
		}
		
		private function checkForUserBan(userVO:UserVO, renderer:IMessageRenderer, isLastMessage:Boolean):void 
		{
			if (userVO != null)
			{
				var needPermanentBanMark:Boolean = false;
				var needBanMark:Boolean = false;
				
				if (userVO.sysBan == true)
				{
					needPermanentBanMark = true;
				}
				else if (userVO.ban911 == true)
				{
					needBanMark = true;
				}
				
				if (needPermanentBanMark == true)
				{
					if (isLastMessage == true)
					{
						if (permanentBanMark == null)
						{
							permanentBanMark = UI.createBannedMark(avatarSize * 1.3, Lang.permanentBaned);
							addChild(permanentBanMark);
						}
						permanentBanMark.x = (avatar.x + avatarSize - permanentBanMark.width * .5);
						permanentBanMark.y = (avatar.y + avatarSize - permanentBanMark.height * .5);
						permanentBanMark.visible = true;
						setChildIndex(permanentBanMark, numChildren - 1);
					}
					
					if (renderer != null)
					{
						renderer.alpha = 0.2;
					}
					birdUser.visible = false;
					tfUsername.alpha = 0.2;
				}
				else if (needBanMark == true)
				{
					if (isLastMessage == true)
					{
						if (banMark == null)
						{
							banMark = UI.createBannedMark(avatarSize*1.3, Lang.banned);
							addChild(banMark);
						}
						banMark.x = (avatar.x + avatarSize - banMark.width * .5);
						banMark.y = (avatar.y + avatarSize - banMark.height * .5);
						banMark.visible = true;
						setChildIndex(banMark, numChildren - 1);
					}
					
					if (renderer != null)
					{
						renderer.alpha = 0.2;
					}
					birdUser.visible = false;
					tfUsername.alpha = 0.2;
				}
			}
		}
		
		private function showDefaultAvatar(size:int):void 
		{
			avatar.visible = false;
			avatarDefault.visible = true;
			
			if (avatarDefault.bitmapData == null || avatarDefault.bitmapData.width != size * 2) {
				if (avatarDefault.bitmapData == null) {
					avatarDefault.bitmapData.dispose();
					avatarDefault.bitmapData = null;
				}
				
				avatarDefault.bitmapData = UI.drawAssetToRoundRect(new DefaultAvatar(),size*2, true, "ListChatItem.avatarDefault");
			
				//var avatarDefaultIcon:DefaultAvatar = new DefaultAvatar();
				//UI.scaleToFit(avatarDefaultIcon, size * 2, size * 2);
				//avatarDefault.bitmapData = UI.getSnapshot(avatarDefaultIcon, StageQuality.HIGH, "ListChatItem.avatarDefault");
				//UI.destroy(avatarDefaultIcon);
				//avatarDefaultIcon = null;
			}
		}
		
		private function hideRenderers():void
		{
			if (_chatMessageStickerRenderer != null)
				_chatMessageStickerRenderer.visible = false;
			
			if (_chatMessageTextRenderer != null)
				_chatMessageTextRenderer.visible = false;
				
			if (_chatMessageBotMenuRenderer != null)
				_chatMessageBotMenuRenderer.visible = false;
				
			if (_chatMessageBotCommandRenderer != null)
				_chatMessageBotCommandRenderer.visible = false;
			
			if (_chatMessageUploadingImageRenderer != null)
				_chatMessageUploadingImageRenderer.visible = false;
			
			if (_chatMessageInvoiceRenderer != null)
				_chatMessageInvoiceRenderer.visible = false;
			
			if (_chatMessageVoiceRenderer != null)
				_chatMessageVoiceRenderer.visible = false;
			
			if (_chatMessageSystemMessageRenderer != null)
				_chatMessageSystemMessageRenderer.visible = false;
			
			if (_chatMessageButtonRenderer != null)
				_chatMessageButtonRenderer.visible = false;
			
			if (_chatMessageFileRenderer != null)
				_chatMessageFileRenderer.visible = false;
			
			if (_questionSettingRenderer != null)
				_questionSettingRenderer.visible = false;
			
			if (_chatMessageChatSystemRenderer != null)
				_chatMessageChatSystemRenderer.visible = false;
			
			if (_chatMessageGiftRenderer != null)
				_chatMessageGiftRenderer.visible = false;
			
			if (_chatMessageMoneyRenderer != null)
				_chatMessageMoneyRenderer.visible = false;
			
			if (_chatMessageTipsWinnerRenderer != null)
				_chatMessageTipsWinnerRenderer.visible = false;
			
			if (_chatMessageCallRenderer != null)
				_chatMessageCallRenderer.visible = false;
			
			if (_chatMessageNewsRenderer != null)
				_chatMessageNewsRenderer.visible = false;
		}
		
		public function isLastSelfMessageInStack(listItem:ListItem):Boolean
		{
			if (listItem.data is ChatMessageVO && (listItem.data as ChatMessageVO).userUID == Auth.uid)
			{
				if (existNextMessage(listItem))
				{
					if (listItem.list.data[listItem.num + 1].userUID != listItem.data.userUID)
						return true;
					else
						return false;
				} else {
					return true;
				}
			} else {
				return false;
			}
		}
		
		public function isLastUserMessageInStack(listItem:ListItem):Boolean {
			if (listItem.data is ChatMessageVO && (listItem.data as ChatMessageVO).name == "911") {
				if ((listItem.data as ChatMessageVO).num == 0)
					return true;
				else
					return false;
			}
			if (listItem.data is ChatMessageVO && (listItem.data as ChatMessageVO).userUID != Auth.uid)	{
				if (existNextMessage(listItem))	{
					if (listItem.list.data[listItem.num + 1].userUID != listItem.data.userUID)
						return true;
					else
						return false;
				} else {
					return true;
				}
			} else {
				return false;
			}
		}
		
		private function existNextMessage(listItem:ListItem):Boolean {
			if (listItem.list.data == null)
				return false;
			return listItem.num <= listItem.list.data.length && listItem.list.data[listItem.num + 1] is ChatMessageVO;
		}
		
		public function dispose():void {
			if (avatar != null)
				avatar.graphics.clear();
			avatar = null;
			
			if (tfDate != null)
				tfDate.text = '';
			
			if (avatarLettertext) {
				avatarLettertext.text = "";
				avatarLettertext = null;
			}
			if (avatarWithLetter) {
				UI.destroy(avatarWithLetter);
				avatarWithLetter = null;
			}
			
			if (serviceSprite){
				UI.destroy(serviceSprite);
				serviceSprite = null;
			}
			
			if (_chatMessageVoiceRenderer != null) {
				_chatMessageVoiceRenderer.dispose();
				_chatMessageVoiceRenderer = null;
			}
			if (_chatMessageButtonRenderer != null) {
				_chatMessageButtonRenderer.dispose();
				_chatMessageButtonRenderer = null;
			}
			if (_chatMessageFileRenderer != null) {
				_chatMessageFileRenderer.dispose();
				_chatMessageFileRenderer = null;
			}
			if (_chatMessageInvoiceRenderer != null) {
				_chatMessageInvoiceRenderer.dispose();
				_chatMessageInvoiceRenderer = null;
			}
			if (_chatMessageStickerRenderer != null) {
				_chatMessageStickerRenderer.dispose();
				_chatMessageStickerRenderer = null;
			}
			if (_chatMessageSystemMessageRenderer != null) {
				_chatMessageSystemMessageRenderer.dispose();
				_chatMessageSystemMessageRenderer = null;
			}
			if (_chatMessageTextRenderer != null) {
				_chatMessageTextRenderer.dispose();
				_chatMessageTextRenderer = null;
			}			
			if (_chatMessageBotMenuRenderer != null) {
				_chatMessageBotMenuRenderer.dispose();
				_chatMessageBotMenuRenderer = null;
			}
			if (_chatMessageBotCommandRenderer != null) {
				_chatMessageBotCommandRenderer.dispose();
				_chatMessageBotCommandRenderer = null;
			}
			if (_chatMessageUploadingImageRenderer != null) {
				_chatMessageUploadingImageRenderer.dispose();
				_chatMessageUploadingImageRenderer = null;
			}
			if (_questionSettingRenderer != null) {
				_questionSettingRenderer.dispose();
				_questionSettingRenderer = null;
			}
			if (_chatMessageChatSystemRenderer != null) {
				_chatMessageChatSystemRenderer.dispose();
				_chatMessageChatSystemRenderer = null;
			}
			if (_chatMessageGiftRenderer != null) {
				_chatMessageGiftRenderer.dispose();
				_chatMessageGiftRenderer = null;
			}
			if (_chatMessageMoneyRenderer != null) {
				_chatMessageMoneyRenderer.dispose();
				_chatMessageMoneyRenderer = null;
			}
			if (_chatMessageTipsWinnerRenderer != null) {
				_chatMessageTipsWinnerRenderer.dispose();
				_chatMessageTipsWinnerRenderer = null;
			}
			if (_chatMessageCallRenderer != null) {
				_chatMessageCallRenderer.dispose();
				_chatMessageCallRenderer = null;
			}
			if (_chatMessageNewsRenderer != null) {
				_chatMessageNewsRenderer.dispose();
				_chatMessageNewsRenderer = null;
			}
			
			if (permanentBanMark != null)
				UI.destroy(permanentBanMark);
			permanentBanMark = null;
			if (banMark != null)
				UI.destroy(banMark);
			banMark = null;
			
			lastRenderer = null;
			
			if (likeClip != null) {
				UI.destroy(likeClip);
				likeClip = null;
			}
			if (payRating != null) {
				UI.destroy(payRating);
				payRating = null;
			}
			if (likeClipSelected != null) {
				UI.destroy(likeClipSelected);
				likeClipSelected = null;
			}
			
			dateFormat = null;
			mainFormat = null;
			likesFormat = null;
			avatarDoubleSize = 0;
			
			if (avatarDefault) {
				UI.destroy(avatarDefault);
				avatarDefault = null;
			}
			if (avatarSupport) {
				UI.destroy(avatarSupport);
				avatarSupport = null;
			}
		}
		
		public function getMessageHitzone(listItem:ListItem):HitZoneData {
			var messageType:String = getMessageType(listItem.data as ChatMessageVO);
			if (messageType != null) {
				var hitZoneType:String;
				if (messageType == MESSAGE_TYPE_TEXT) {
					hitZoneType = HitZoneType.MESSAGE_TEXT;
				}
				else if (messageType == MESSAGE_TYPE_UPDLOAD_IMAGE) {
					hitZoneType = HitZoneType.MESSAGE_IMAGE;
				}
				else if (messageType == MESSAGE_TYPE_CHAT_SYSTEM_MESSAGE) {
					hitZoneType = HitZoneType.MESSAGE_TEXT;
				}
				
				else if (messageType == MESSAGE_TYPE_FILE) {
					hitZoneType = HitZoneType.MESSAGE_TEXT;
				}
				else if (messageType == MESSAGE_TYPE_INVOICE) {
					hitZoneType = HitZoneType.MESSAGE_IMAGE;
				}
				else if (messageType == MESSAGE_TYPE_MONEY) {
					hitZoneType = HitZoneType.MESSAGE_TEXT;
				}
				else if (messageType == MESSAGE_TYPE_NEWS) {
					hitZoneType = HitZoneType.MESSAGE_TEXT;
				}
				else if (messageType == MESSAGE_TYPE_CALL) {
					hitZoneType = HitZoneType.MESSAGE_TEXT;
				}
				else if (messageType == MESSAGE_TYPE_STICKER) {
					hitZoneType = HitZoneType.MESSAGE_TEXT;
				}
				else if (messageType == MESSAGE_TYPE_SYSTEM_MESSAGE) {
					hitZoneType = HitZoneType.MESSAGE_TEXT;
				}
				else if (messageType == MESSAGE_TYPE_VOICE) {
					hitZoneType = HitZoneType.MESSAGE_IMAGE;
				}
				
				
				if (hitZoneType != null) {
					var height:int = getHeight(listItem, listItem.width);
					getView(listItem, height, listItem.width);
					
					var hitzone:HitZoneData = new HitZoneData();
					if (lastRenderer != null) {
						hitzone.x = lastRenderer.x;
						hitzone.y = lastRenderer.y;
						hitzone.width = lastRenderer.getWidth();
						hitzone.height = lastRenderer.getContentHeight();
						hitzone.type = hitZoneType;
						
						return hitzone;
					}
				}
			}
			return null;
		}
		
		private function get chatMessageStickerRenderer():ChatMessageRendererSticker
		{
			if (_chatMessageStickerRenderer == null)
			{
				_chatMessageStickerRenderer = new ChatMessageRendererSticker();
				addChild(_chatMessageStickerRenderer);
			}
			return _chatMessageStickerRenderer;
		}
		
		private function get chatMessageInvoiceRenderer():ChatMessageRendererInvoice
		{
			if (_chatMessageInvoiceRenderer == null)
			{
				_chatMessageInvoiceRenderer = new ChatMessageRendererInvoice();
				addChild(_chatMessageInvoiceRenderer);
			}
			return _chatMessageInvoiceRenderer;
		}
		
		private function get chatMessageSystemMessageRenderer():ChatMessageRendererSystemMessage
		{
			if (_chatMessageSystemMessageRenderer == null)
			{
				_chatMessageSystemMessageRenderer = new ChatMessageRendererSystemMessage();
				addChild(_chatMessageSystemMessageRenderer);
			}
			return _chatMessageSystemMessageRenderer;
		}
		
		private function get chatMessageVoiceRenderer():ChatMessageRendererVoice
		{
			if (_chatMessageVoiceRenderer == null)
			{
				_chatMessageVoiceRenderer = new ChatMessageRendererVoice();
				addChild(_chatMessageVoiceRenderer);
			}
			return _chatMessageVoiceRenderer;
		}
		
		private function get chatMessageButtonRenderer():ChatMessageRendererAction
		{
			if (_chatMessageButtonRenderer == null)
			{
				_chatMessageButtonRenderer = new ChatMessageRendererAction();
				addChild(_chatMessageButtonRenderer);
			}
			return _chatMessageButtonRenderer;
		}
		
		private function get chatMessageTextRenderer():ChatMessageRendererText
		{
			if (_chatMessageTextRenderer == null)
			{
				_chatMessageTextRenderer = new ChatMessageRendererText();
				addChild(_chatMessageTextRenderer);
			}
			return _chatMessageTextRenderer;
		}
		
		private function get chatMessageBotMenuRenderer():ChatMessageRendererBotMenu
		{
			if (_chatMessageBotMenuRenderer == null)
			{
				_chatMessageBotMenuRenderer = new ChatMessageRendererBotMenu();
				addChild(_chatMessageBotMenuRenderer);
			}
			return _chatMessageBotMenuRenderer;
		}
				
		private function get chatMessageBotCommandRenderer():ChatMessageRendererBotCommand
		{
			if (_chatMessageBotCommandRenderer == null)
			{
				_chatMessageBotCommandRenderer = new ChatMessageRendererBotCommand();
				addChild(_chatMessageBotCommandRenderer);
			}
			return _chatMessageBotCommandRenderer;
		}
		
		private function get chatMessageExtraRewardsRenderer():ChatMessageRendererAdditionalQuestionsSettings
		{
			if (_questionSettingRenderer == null)
			{
				_questionSettingRenderer = new ChatMessageRendererAdditionalQuestionsSettings();
				addChild(_questionSettingRenderer);
			}
			return _questionSettingRenderer;
		}
		
		private function get chatMessageChatSystemRenderer():ChatMessageRendererChatSystemMessage
		{
			if (_chatMessageChatSystemRenderer == null)
			{
				_chatMessageChatSystemRenderer = new ChatMessageRendererChatSystemMessage();
				addChild(_chatMessageChatSystemRenderer);
			}
			return _chatMessageChatSystemRenderer;
		}
		
		private function get chatMessageGiftRenderer():ChatMessageRendererGift
		{
			if (_chatMessageGiftRenderer == null)
			{
				_chatMessageGiftRenderer = new ChatMessageRendererGift();
				addChild(_chatMessageGiftRenderer);
			}
			return _chatMessageGiftRenderer;
		}
		
		private function get chatMessageMoneyRenderer():ChatMessageRendererMoney
		{
			if (_chatMessageMoneyRenderer == null)
			{
				_chatMessageMoneyRenderer = new ChatMessageRendererMoney();
				addChild(_chatMessageMoneyRenderer);
			}
			return _chatMessageMoneyRenderer;
		}
		
		private function get chatMessageTipsWinnerRenderer():ChatMessageRendererTipsWinner
		{
			if (_chatMessageTipsWinnerRenderer == null)
			{
				_chatMessageTipsWinnerRenderer = new ChatMessageRendererTipsWinner();
				addChild(_chatMessageTipsWinnerRenderer);
			}
			return _chatMessageTipsWinnerRenderer;
		}
		
		private function get chatMessageCallRenderer():ChatMessageRendererCall
		{
			if (_chatMessageCallRenderer == null)
			{
				_chatMessageCallRenderer = new ChatMessageRendererCall();
				addChild(_chatMessageCallRenderer);
			}
			return _chatMessageCallRenderer;
		}
		
		private function get chatMessageNewsRenderer():ChatMessageRendererNews
		{
			if (_chatMessageNewsRenderer == null)
			{
				_chatMessageNewsRenderer = new ChatMessageRendererNews();
				addChild(_chatMessageNewsRenderer);
			}
			return _chatMessageNewsRenderer;
		}
		
		private function get chatMessageFileRenderer():ChatMessageRendererFile
		{
			if (_chatMessageFileRenderer == null)
			{
				_chatMessageFileRenderer = new ChatMessageRendererFile();
				addChild(_chatMessageFileRenderer);
			}
			return _chatMessageFileRenderer;
		}
		
		private function get chatMessageUploadingImageRenderer():ChatMessageRendererImage
		{
			if (_chatMessageUploadingImageRenderer == null)
			{
				_chatMessageUploadingImageRenderer = new ChatMessageRendererImage();
				addChild(_chatMessageUploadingImageRenderer);
			}
			return _chatMessageUploadingImageRenderer;
		}
		
		/* INTERFACE com.dukascopy.connect.gui.list.renderers.IListRenderer */
		public function get isTransparent():Boolean
		{
			return true;
		}
		
		override public function getOverlayPosition():Rectangle
		{
			if (avatar.visible == true || avatarWithLetter.visible == true)
			{
				if (avatarPosition == null)
				{
					avatarPosition = new Rectangle();
				}
				avatarPosition.x = avatar.x;
				avatarPosition.y = avatar.y;
				avatarPosition.width = avatarSize;
				avatarPosition.height = avatarSize;
				
				return avatarPosition;
			}
			return null;
		}
	}
}