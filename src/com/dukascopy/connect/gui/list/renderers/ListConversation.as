package com.dukascopy.connect.gui.list.renderers {
	
	import assets.ButtonChatContent;
	import assets.ContectDeleteIcon;
	import assets.IconCard;
	import assets.IconCardBG;
	import assets.IconInvoice;
	import assets.LogoChat;
	import assets.LogoChat2;
	import assets.LogoRectangle;
	import assets.MicGreyIcon;
	import assets.OwnerIcon;
	import assets.PlusAvatar;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.ChatVOAction;
	import com.dukascopy.connect.data.HitZoneData;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.gui.megaText.MegaText;
	import com.dukascopy.connect.sys.assets.Assets;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.chat.DraftMessage;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.notifier.NewMessageNotifier;
	import com.dukascopy.connect.sys.questionsManager.QuestionsManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.sys.usersManager.OnlineStatus;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.type.ChatRoomType;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.type.MainColors;
	import com.dukascopy.connect.utils.DateUtils;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.connect.vo.ChatMessageVO;
	import com.dukascopy.connect.vo.ChatSystemMsgVO;
	import com.dukascopy.connect.vo.ChatVO;
	import com.dukascopy.connect.vo.users.UserVO;
	import com.dukascopy.connect.vo.users.adds.ChatUserVO;
	import com.dukascopy.connect.vo.users.adds.ContactVO;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.display.Graphics;
	import flash.display.IBitmapDrawable;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class ListConversation extends BaseRenderer implements IListRenderer {
		
		static protected var trueHeight:int = Config.FINGER_SIZE * 1.6;
		static protected var avatarSize:int = Config.FINGER_SIZE * .46;
		static protected var onlineStatusROut:int = avatarSize * .22;
		static protected var onlineStatusRIn:int = onlineStatusROut * .8;
		
		private var bg:Shape;
		private var bgHighlight:Shape;
		private var bgActive:Shape;
		private var avatar:Shape;
		private var avatarWithLetter:Sprite;
		private var avatarWithLetterTF:TextField;
		private var missDCIcon:Sprite;
		private var ratingIcon:MovieClip;
		private var toadIcon:Sprite;
		private var jailIcon:Sprite;
		private var onlineMark:Sprite;
		private var tfTitle:TextField;
		private var tfLastMessage:MegaText; 
		private var tfLastMessageTime:TextField;
		private var newMessages:Sprite;
		private var tfNewMessagesCnt:TextField;
		
		private var iconGroupChat:Sprite;
		private var fileAttachIcon:Sprite;
		private var invoiceIcon:IconInvoice;
		private var voiceIcon:MicGreyIcon;
		private var iconMessageType:Sprite;
		private var trashIcon:Sprite;
		private var nineOneOneIcon:Sprite;
		private var nineOneOnePublicIcon:Sprite;
		private var channelSubscriptionIcon:OwnerIcon;
		
		private var format1:TextFormat = new TextFormat(Config.defaultFontName);
		private var format2:TextFormat = new TextFormat(Config.defaultFontName);
		private var format3:TextFormat = new TextFormat(Config.defaultFontName);
		private var format4:TextFormat = new TextFormat(Config.defaultFontName);
		private var format5:TextFormat = new TextFormat(Config.defaultFontName);
		private var format6:TextFormat = new TextFormat(Config.defaultFontName);
		
		private var avatarGroup:ImageBitmapData;
		private var avatarChannel:ImageBitmapData;
		private var avatarSupport:ImageBitmapData;
		private var avatarAccount:ImageBitmapData;
		private var avatarBankBot:ImageBitmapData;
		private var avatarMarketplace:ImageBitmapData;
		private var avatarTrading:ImageBitmapData;
		private var avatarPayCard:ImageBitmapData;
		private var avatarIncognito:ImageBitmapData;
		private var avatarEmpty:ImageBitmapData;
		
		private var cachedLastMessageIconSize:int = -1;
		
		private var leftTextAlignX:int;
		private var avatarChat:ImageBitmapData;
		private var outline:Sprite;
		private var priceField:TextField;
		private var permanentBanMark:Bitmap;
		private var banMark:Bitmap;
		private var extensions:Dictionary;
		private var bgBank:Sprite;
		private var bankLogo:LogoChat;
		private var bankLogo2:LogoChat2;
		private var officialIcon:Sprite;
		private var customAvatarBitmap:ImageBitmapData;
		private var avatarColor:ColorTransform;
		
		public function ListConversation() {
				bg = new Shape();
				bg.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
				bg.graphics.drawRect(0, 0, 1, 1);
				bg.graphics.endFill();
			addChild(bg);
			
				bgHighlight = new Shape();
				bgHighlight.graphics.beginFill(Style.color(Style.COLOR_LIST_SELECTED));
				bgHighlight.graphics.drawRect(0, 0, 1, 1);
				bgHighlight.graphics.endFill();
			addChild(bgHighlight);
			
				bgBank = new Sprite();
				/*var mark:ChatMark = new ChatMark();
				UI.scaleToFit(mark, Config.FINGER_SIZE*.5, Config.FINGER_SIZE*.5);
				bgBank.addChild(mark);
				mark.y = 1*/;
			addChild(bgBank);
			
				bgActive = new Shape();
				bgActive.graphics.beginFill(0xF4F4F4);
				bgActive.graphics.drawRect(0, 0, 1, 1);
				bgActive.graphics.endFill();
			addChild(bgActive);
				var circleSize:int = (Config.FINGER_SIZE * .4) * .55;
				newMessages = new Sprite();
				newMessages.graphics.beginFill(MainColors.GREEN);
				newMessages.graphics.drawRoundRect(0, 0, circleSize * 1.65, circleSize * 1.65, circleSize * 1.3, circleSize * 1.3);
				newMessages.graphics.endFill();
					tfNewMessagesCnt = new TextField();
					tfNewMessagesCnt.width = newMessages.width;
					format3.align = TextFormatAlign.CENTER;
					format3.bold = true;
					format3.color = MainColors.WHITE;
					format3.size = circleSize;
					tfNewMessagesCnt.defaultTextFormat = format3;
					tfNewMessagesCnt.text = '`|q';
					tfNewMessagesCnt.height = tfNewMessagesCnt.textHeight + 1;
					tfNewMessagesCnt.y = int((newMessages.height - tfNewMessagesCnt.height) * .5) - 1;
				newMessages.addChild(tfNewMessagesCnt);
			addChild(newMessages);
			trashIcon = new ContectDeleteIcon();
			UI.colorize(trashIcon, Style.color(Style.ICON_SETTINGS));
			UI.scaleToFit(trashIcon, int(Config.FINGER_SIZE * .4), int(Config.FINGER_SIZE * .4));
			addChild(trashIcon);
				avatar = new Shape();
				avatar.x = int(Config.DOUBLE_MARGIN);
			addChild(avatar);
			avatarWithLetter = new Sprite();
				avatarWithLetter.x = avatar.x;
			avatarWithLetterTF = new TextField();
			var textFormat:TextFormat = new TextFormat();
			textFormat.font = Config.defaultFontName;
			textFormat.color = MainColors.WHITE;
			textFormat.size = Config.FINGER_SIZE*.5;
			textFormat.align = TextFormatAlign.CENTER;
			avatarWithLetterTF.defaultTextFormat = textFormat;
			avatarWithLetterTF.selectable = false;
			avatarWithLetterTF.width = avatarSize * 2;
			avatarWithLetterTF.multiline = false;
			avatarWithLetterTF.text = "|";
			avatarWithLetterTF.height = avatarWithLetterTF.textHeight + 4;
			avatarWithLetterTF.y = int(avatarSize - (avatarWithLetterTF.textHeight + 4) * .5);
			avatarWithLetterTF.text = "";
				avatarWithLetter.addChild(avatarWithLetterTF);
			avatarWithLetter.graphics.beginFill(AppTheme.GREY_MEDIUM);
			//avatarWithLetter.graphics.drawCircle(avatarSize, avatarSize, avatarSize);				
			UI.drawElipseSquare(avatarWithLetter.graphics, avatarSize*2,avatarSize,AppTheme.GREY_MEDIUM);				
			avatarWithLetter.graphics.endFill();
				avatarWithLetter.visible = false;
			addChild(avatarWithLetter);
			
			var scale:Number = avatarSize * 2 / 100;
			
			missDCIcon = new SWFCrownIcon();
			missDCIcon.scaleX = missDCIcon.scaleY = scale;
			missDCIcon.x = avatar.x + avatarSize;
			addChild(missDCIcon);
			
			ratingIcon = new SWFRatingStars_mc();
			ratingIcon.scaleX = ratingIcon.scaleY = scale;
			ratingIcon.x = avatar.x + avatarSize;
			addChild(ratingIcon);
			
			toadIcon = new SWFFrog();
			toadIcon.scaleX = toadIcon.scaleY = scale;
			toadIcon.x = avatar.x + avatarSize;
			addChild(toadIcon);
			
			jailIcon = new (Style.icon(Style.ICON_JAILED));
			UI.colorize(jailIcon, Style.color(Style.COLOR_BACKGROUND));
			jailIcon.scaleX = jailIcon.scaleY = scale;
			jailIcon.x = avatar.x + avatarSize;
			addChild(jailIcon);
			
			nineOneOneIcon = new SWFNineOneOne();
			var destScale:Number  = UI.getMinScale(nineOneOneIcon.width, nineOneOneIcon.height, 300, Config.FINGER_SIZE * .3);
			nineOneOneIcon.scaleX = nineOneOneIcon.scaleY = destScale;
			addChild(nineOneOneIcon);
			
			nineOneOnePublicIcon = new SWFNineOneOnePublic();
			destScale  = UI.getMinScale(nineOneOnePublicIcon.width, nineOneOnePublicIcon.height, 300, Config.FINGER_SIZE * .3);
			nineOneOnePublicIcon.scaleX = nineOneOnePublicIcon.scaleY = destScale;
			addChild(nineOneOnePublicIcon);
				tfTitle = new TextField();
				format1.size = Config.FINGER_SIZE * .3;
				format1.align = TextFormatAlign.LEFT;
				format1.color = Style.color(Style.COLOR_TITLE);// 0x363E4E;
				tfTitle.defaultTextFormat = format1;
				tfTitle.wordWrap = false;
				tfTitle.multiline = false;
				tfTitle.text = "|";
				var titleTextHeight:int = tfTitle.textHeight + 4;
				tfTitle.text = "";
			addChild(tfTitle);
				tfLastMessageTime = new TextField();
				format5.size = circleSize * 1;
				format5.align = TextFormatAlign.LEFT;
				format5.color = Style.color(Style.COLOR_SUBTITLE);
				tfLastMessageTime.defaultTextFormat = format5;
			addChild(tfLastMessageTime);
			tfLastMessageTime.y = int(Config.FINGER_SIZE * .2);
				tfLastMessage = new MegaText();
				format2.size = Config.FINGER_SIZE * .28;
			addChild(tfLastMessage);
			//avatarGroup = Assets.getAsset(Assets.AVATAR_GROUP);
			avatarGroup = UI.renderAsset(new SWFEmptyGroupAvatar(), avatarSize * 2, avatarSize * 2);// Assets.getAsset(Assets.AVATAR_GROUP);
			//avatarEmpty = UI.getEmptyAvatarBitmapData(avatarSize * 2, avatarSize * 2);
			avatarEmpty =  UI.drawAssetToRoundRect(new SWFEmptyAvatar(), avatarSize * 2);
			
			avatarColor = new ColorTransform();
			
			avatarPayCard = UI.renderAsset(new IconCardBG(), avatarSize * 2, avatarSize * 2);
			avatarColor.color = AppTheme.GREEN_LIGHT;
			avatarPayCard.colorTransform(avatarPayCard.rect, avatarColor);
			avatarIncognito =  UI.renderAsset(new SWFIncognitoAvatar(), avatarSize * 2, avatarSize * 2);
			
			avatarColor.color = 0x6e92af;
			
			avatarSupport = UI.renderAsset(new LogoRectangle(), avatarSize * 2, avatarSize * 2);
			avatarAccount = UI.renderAsset(new SWFAccountAvatar(), avatarSize * 2, avatarSize * 2);
			avatarAccount.colorTransform(avatarAccount.rect, avatarColor);
			avatarBankBot = UI.renderAsset(new AvatarBot(), avatarSize * 2, avatarSize * 2);
			avatarBankBot.colorTransform(avatarBankBot.rect, avatarColor);
			avatarMarketplace = UI.renderAsset(new SWFUpDownArrows(), avatarSize * 2, avatarSize * 2);
			avatarMarketplace.colorTransform(avatarMarketplace.rect, avatarColor);
			avatarTrading = UI.renderAsset(new SWFBars(), avatarSize * 2, avatarSize * 2);
			avatarTrading.colorTransform(avatarTrading.rect, avatarColor);
			
			var tmp:Sprite = new PlusAvatar();
			tmp.width = tmp.height = avatarSize * 2;
			avatarChannel = UI.getSnapshot(tmp, StageQuality.HIGH, "iconNewChannel");
			tmp = null;
			
			tmp = new ButtonChatContent();
			tmp.width = tmp.height = avatarSize * 2;
			avatarChat = UI.getSnapshot(tmp, StageQuality.HIGH, "avatarChat");
			tmp = null;
			
			format4.align = TextFormatAlign.CENTER;
			format4.size = Config.FINGER_SIZE * .3;
			
			var iconSize:int = avatarSize * .8;
			
			fileAttachIcon = new (Style.icon(Style.ICON_FILE));
			fileAttachIcon.height = iconSize;
			fileAttachIcon.scaleX = fileAttachIcon.scaleY;
			fileAttachIcon.x = avatar.x + avatarSize * 2 + Config.MARGIN;
			fileAttachIcon.visible = false;
			addChild(fileAttachIcon);
			
			invoiceIcon = new IconInvoice();
			invoiceIcon.height = iconSize;
			invoiceIcon.scaleX = invoiceIcon.scaleY;
			invoiceIcon.x = avatar.x + avatarSize * 2 + Config.MARGIN;
			invoiceIcon.visible = false;
			addChild(invoiceIcon);
			
			voiceIcon = new MicGreyIcon();
			voiceIcon.height = iconSize;
			voiceIcon.scaleX = voiceIcon.scaleY;
			voiceIcon.x = avatar.x + avatarSize * 2 + Config.MARGIN;
			voiceIcon.visible = false;
			addChild(voiceIcon);
			
			iconGroupChat = new (Style.icon(Style.ICON_GROUP_CHAT));
			iconGroupChat.visible = false;
			addChild(iconGroupChat);
			UI.colorize(iconGroupChat,Style.color(Style.ICON_COLOR));
			
			onlineMark = new Sprite();
				onlineMark.x = int(avatar.x  + avatarSize * Math.cos(32 * Math.PI / 180) + avatarSize - onlineStatusROut);
				onlineMark.visible = false;
			addChild(onlineMark);
			
			channelSubscriptionIcon = new OwnerIcon();
			var ct2:ColorTransform = new ColorTransform();
			ct2.color = 0xCD3F43;
			channelSubscriptionIcon.transform.colorTransform = ct2;
			UI.scaleToFit(channelSubscriptionIcon, Config.FINGER_SIZE * .3, Config.FINGER_SIZE * .3);
			addChild(channelSubscriptionIcon);
			
			avatar.y = int((trueHeight - avatarSize * 2) * .5);
			avatarWithLetter.y = avatar.y;
			onlineMark.y = int(avatar.y  + avatarSize * Math.sin(32 * Math.PI / 180) + avatarSize - onlineStatusROut);
			missDCIcon.y = avatar.y + avatarSize;
			ratingIcon.y = avatar.y + avatarSize;
			toadIcon.y = avatar.y + avatarSize;
			jailIcon.y = avatar.y + avatarSize;
			
			leftTextAlignX = avatar.x + avatarSize * 2 + Config.MARGIN;
			
			iconGroupChat.height = Config.FINGER_SIZE * .33;
			iconGroupChat.scaleX = iconGroupChat.scaleY;
			
			outline = new Sprite();
			addChild(outline);
			
			
				priceField = new TextField();
				format6.size = Config.FINGER_SIZE * .20;
				format6.align = TextFormatAlign.LEFT;
				format6.color = 0xFFFFFF;
				priceField.defaultTextFormat = format6;
			addChild(priceField);
		}
		
		private function drawOnlineStatus(status:String):void {
			onlineMark.graphics.clear();
			var mainColor:uint = Color.GREEN;
			if (status == OnlineStatus.STATUS_AWAY)
				mainColor = MainColors.YELLOW_LIGHT;
			if (status == OnlineStatus.STATUS_DND)
				mainColor = MainColors.RED_LIGHT;
			onlineMark.graphics.beginFill(MainColors.WHITE);
			onlineMark.graphics.drawCircle(onlineStatusROut, onlineStatusROut, onlineStatusROut);
			onlineMark.graphics.endFill();
			onlineMark.graphics.beginFill(mainColor);
			onlineMark.graphics.drawCircle(onlineStatusROut, onlineStatusROut, onlineStatusRIn);
			onlineMark.graphics.endFill();
		}
		
		// INITIALIZATION HEIGHT
		public function getHeight(data:ListItem, width:int):int {
			if (!(data.data is ChatVO))
				return Config.FINGER_SIZE_DOT_75;
			return trueHeight;
		}
		
		private function setText(cVO:ChatVO, w:int):int {
			
			if (cVO.isDisposed == true)
				return 10;
			// TIME //////////////////////////////////////////////////////////////////////////////////
			var time:Number = cVO.getTime();
			if (cVO.getTime() == -1 || cVO.getTime() == 0)
			{
				if (tfLastMessageTime.text != "")
				{
					tfLastMessageTime.text = "";
				}
			}
			else if (cVO.type == ChatRoomType.CHANNEL && cVO.uid == null)
			{
				if (tfLastMessageTime.text != "")
				{
					tfLastMessageTime.text = "";
				}
			}
			else
			{
				var dateText:String = DateUtils.getComfortDateRepresentation(cVO.getPrecenceDate());
				if (tfLastMessageTime.text != dateText)
				{
					tfLastMessageTime.text = dateText;
				}
			}
			tfLastMessageTime.width = tfLastMessageTime.textWidth + 4;
			tfLastMessageTime.height = tfLastMessageTime.textHeight + 4;
			tfLastMessageTime.x = int(w - tfLastMessageTime.textWidth - Config.MARGIN * 1.56);
			tfLastMessageTime.visible = true;
			// TRASH /////////////////////////////////////////////////////////////////////////////////
			trashIcon.visible = false;
			if (QuestionsManager.answersDialogOpened == true && (cVO.type == ChatRoomType.QUESTION || (cVO.questionID != null && cVO.questionID != ""))) {
				trashIcon.visible = true;
				trashIcon.x = w - trashIcon.width - Config.MARGIN;
			}
			// UNREAD ////////////////////////////////////////////////////////////////////////////////
			newMessages.visible = false;
			var unreadedNum:int = 0;
		//	var lastReaded:int = 0;
			if (cVO.messageVO != null) {
				unreadedNum = NewMessageNotifier.getChatUnreaded(cVO.messageVO.num, cVO);
			//	lastReaded = NewMessageNotifier.getChatLastReaded(cVO.messageVO.num, cVO);
			}
			
			if (unreadedNum > 0) {
				
				format1.bold = false;
				tfTitle.defaultTextFormat = format1;
				var numNew:String = Math.min(unreadedNum, 99).toString();
				if (tfNewMessagesCnt.text != numNew)
				{
					tfNewMessagesCnt.text = numNew;
				}
				
				newMessages.visible = true;
			} else {
				format1.bold = false;
				newMessages.visible = false;
				tfTitle.defaultTextFormat = format1;
			}
			// LEFT ICONS ////////////////////////////////////////////////////////////////////////////
			var offsetLeft:int;
			channelSubscriptionIcon.visible = false;
			nineOneOneIcon.visible = false;
			nineOneOnePublicIcon.visible = false;
			if (cVO.type == ChatRoomType.QUESTION) {
				nineOneOneIcon.x = int(avatar.x + avatarSize * 2 + Config.MARGIN * 1.2);
				nineOneOneIcon.visible  = true;
				offsetLeft = nineOneOneIcon.width + Config.MARGIN;
			}
			if (cVO.type == ChatRoomType.CHANNEL) {
				if (cVO.channelData != null && cVO.channelData.subscribed == true && (cVO.questionID == null || cVO.questionID == "")) {
					channelSubscriptionIcon.x = int(avatar.x + avatarSize * 2 + Config.MARGIN * 1.2);
					channelSubscriptionIcon.visible = true;
					offsetLeft = channelSubscriptionIcon.width + Config.MARGIN;
				}
				if (cVO.questionID != null && cVO.questionID != "") {
					nineOneOnePublicIcon.x = int(avatar.x + avatarSize * 2 + Config.MARGIN * 1.2 + offsetLeft);
					nineOneOnePublicIcon.visible  = true;
					offsetLeft += nineOneOnePublicIcon.width + Config.MARGIN;
				}
			}
			// RIGHT ICONS ///////////////////////////////////////////////////////////////////////////
			var offsetRight:int;
			iconGroupChat.visible = false;
			if (cVO.type == ChatRoomType.GROUP) {
				iconGroupChat.visible = true;
				offsetRight = iconGroupChat.width + Config.MARGIN * 2;
			}
			// CHECK FOR ADDING UNREAD WIDTH TO RIGHT OFFSET /////////////////////////////////////////
			var repositionUnreadIcon:Boolean = false;
			if (newMessages.visible == true && trashIcon.visible == true) {
				repositionUnreadIcon = true;
				offsetRight = newMessages.width + Config.MARGIN * 2;
			}
			
			// MAX FIELD WIDTH ///////////////////////////////////////////////////////////////////////
			var maxFieldWidth:int = tfLastMessageTime.x - leftTextAlignX;
			if (cVO.type == ChatRoomType.CHANNEL && cVO.subscription != null)
			{
				priceField.text = cVO.subscription.cost.value + " " + cVO.subscription.cost.currency;
				priceField.width = priceField.textWidth + 4;
				maxFieldWidth = Math.min(tfLastMessageTime.x, w - priceField.width - Config.MARGIN * 3) - leftTextAlignX;
			}
			// TF TITLE //////////////////////////////////////////////////////////////////////////////
			var maxTitleWidth:int = maxFieldWidth - offsetLeft - offsetRight;
			tfTitle.visible = true;
			tfTitle.x = leftTextAlignX + offsetLeft;
			
			if (cVO.title != null)
			{
				if (tfTitle.text != cVO.title)
				{
					tfTitle.text = cVO.title;
				}
			}
			else{
				if (cVO.getQuestion() != null && cVO.type == ChatRoomType.CHANNEL && cVO.getQuestion().text != null) {
					tfTitle.text = cVO.getQuestion().text;
				}
				else{
					tfTitle.text = "- no title -";
				}
			}
			tfTitle.width = maxTitleWidth;
			if (tfTitle.width != maxTitleWidth) {
				tfTitle.autoSize = TextFieldAutoSize.NONE;
				tfTitle.width = maxTitleWidth;
			}
			tfTitle.height = tfTitle.textHeight + 4;
			var truncatedTitle:String;
			if (cVO.type == ChatRoomType.QUESTION || (cVO.questionID != null && cVO.questionID != ""))
				truncatedTitle = cVO.getTruncatedTitle(tfTitle.width);
			else
				truncatedTitle = cVO.truncatedTitle;
			if (cVO.truncatedTitle == null || cVO.truncatedTitle == "") {
				tfTitle.autoSize = TextFieldAutoSize.NONE;
				TextUtils.truncate(tfTitle);
				if (cVO.type == ChatRoomType.QUESTION || (cVO.questionID != null && cVO.questionID != ""))
					cVO.setTruncatedTitle(tfTitle.text, tfTitle.width);
				else
					cVO.truncatedTitle = tfTitle.text;
			} else {
				tfTitle.text = truncatedTitle;
			}
			tfTitle.autoSize = TextFieldAutoSize.LEFT;
			tfTitle.width = int(Math.min(tfTitle.textWidth + 4, maxTitleWidth));
			// MOVE RIGHT ICONS TO RIGHT OF THE TITLE ////////////////////////////////////////////////
			if (iconGroupChat.visible == true)
				iconGroupChat.x = tfTitle.x + tfTitle.width + Config.MARGIN;
			if (repositionUnreadIcon == true)
				newMessages.x = tfTitle.x + tfTitle.width + Config.MARGIN;
			else if (newMessages.visible == true)
				newMessages.x = w - newMessages.width - Config.MARGIN;
			// ICON LAST MESSAGE /////////////////////////////////////////////////////////////////////
			var msgVO:ChatMessageVO = cVO.messageVO;
			if (msgVO != null) {
				msgVO.decrypt(cVO.chatSecurityKey, cVO.pin);
				setIconForMessage(msgVO.typeEnum);
			} else
				setIconForMessage("");
			var offsetMessageIcon:int;
			if (iconMessageType != null)
				offsetMessageIcon = iconMessageType.width + Config.MARGIN;
			// LAST MESSAGE //////////////////////////////////////////////////////////////////////////
			var message:String = null;
			if (msgVO != null)
				message = msgVO.textSmall;
			else if (cVO.type == ChatRoomType.COMPANY && cVO.pid > 0 && cVO.pid != Config.EP_TRADING) {
				message = Lang.howMayIHelpYou;
			}
			// TF LAST MESSAGE ///////////////////////////////////////////////////////////////////////
			tfLastMessage.visible = false;
			
			var draft:String = DraftMessage.getValue(cVO.uid, cVO.chatSecurityKey);
			var isHTML:Boolean = false;
			if (draft != null && draft != "")
			{
				isHTML = true;
				message = "<FONT COLOR=\"#" + Color.RED.toString(16) + "\">" + Lang.draft + "</FONT>" + draft;
			}
			
			if (message != null && message != "") {
				
				/*if (Config.isAdmin() && msgVO != null)
				{
					message = "[" + msgVO.num + " : " + lastReaded + "] " + message;
				}*/
				
				tfLastMessage.visible = true;
				var maxMessageWidth:int = maxFieldWidth - offsetMessageIcon;
				tfLastMessage.x = leftTextAlignX + offsetMessageIcon;
				tfLastMessage.setText(
					maxMessageWidth, 
					message, 
					(unreadedNum > 0) ? Style.color(Style.COLOR_TITLE) : (Auth.uid == cVO.messageWriterUID) ? Style.color(Style.COLOR_SUBTITLE) : Style.color(Style.COLOR_SUBTITLE), 
					/*0x8ca7bc, */
					int(format2.size),
					"#FFFFFF",
					1.5,
					cVO.wasSmile, isHTML
				);
				cVO.wasSmile = tfLastMessage.getWasSmile() ? 2 : 1;
				
				var messageLines:int = 2;
				if (cVO.pid == Config.EP_VI_DEF)
					messageLines = 1;
				
				if (tfLastMessage.getTextField().numLines > messageLines) {
					if (messageLines == 1)
					{
						var newMessage:String;
						if (tfLastMessage.getTextField().getLineLength(0) - 3 > 0)
						{
							newMessage = message.substr(0, tfLastMessage.getTextField().getLineLength(0) - 3) + "...";
						}
						else
						{
							newMessage = message.substr(0, tfLastMessage.getTextField().getLineLength(0));
						}
						
						tfLastMessage.setText(
						maxMessageWidth, 
						newMessage, 
						(unreadedNum > 0) ? Style.color(Style.COLOR_TITLE) : (Auth.uid == cVO.messageWriterUID) ? Style.color(Style.COLOR_SUBTITLE) : Style.color(Style.COLOR_SUBTITLE), 
						/*0x8ca7bc, */
						int(format2.size),
						"#FFFFFF",
						1.5,
						cVO.wasSmile, isHTML
						);
					}
					else
					{
						tfLastMessage.setText(
						maxMessageWidth, 
						message.substr(0, tfLastMessage.getTextField().getLineLength(0) + tfLastMessage.getTextField().getLineLength(messageLines - 1) - 3) + "...", 
						(unreadedNum > 0) ? Style.color(Style.COLOR_TITLE) : (Auth.uid == cVO.messageWriterUID) ? Style.color(Style.COLOR_SUBTITLE) : Style.color(Style.COLOR_SUBTITLE), 
						/*0x8ca7bc, */
						int(format2.size),
						"#FFFFFF",
						1.5,
						cVO.wasSmile, isHTML
						);
					}
				}
			}
			// SET Y /////////////////////////////////////////////////////////////////////////////////
			var inHeight:int;
			if (tfLastMessage.visible == false) {
				tfTitle.y = int((trueHeight - tfTitle.height) * .5);
				if (nineOneOneIcon.visible == true)
					nineOneOneIcon.y = int((trueHeight - nineOneOneIcon.height) * .5);
				if (nineOneOnePublicIcon.visible == true)
					nineOneOnePublicIcon.y = int((trueHeight - nineOneOnePublicIcon.height) * .5);
				if (iconGroupChat.visible == true)
					iconGroupChat.y = int((trueHeight - iconGroupChat.height) * .5);
				if (channelSubscriptionIcon.visible == true)
					channelSubscriptionIcon.y = int((trueHeight - channelSubscriptionIcon.height) * .5);
				if (trashIcon.visible == true) {
					inHeight = trueHeight - tfLastMessageTime.height;
					trashIcon.y = int((inHeight - trashIcon.height) * .5 + tfLastMessageTime.height);
				}
				if (repositionUnreadIcon == true) {
					newMessages.y = int((trueHeight - newMessages.height) * .5);
				} else if (newMessages.visible == true) {
					inHeight = trueHeight - tfLastMessageTime.height;
					newMessages.y = int((inHeight - newMessages.height) * .5 + tfLastMessageTime.height);
				}
			} else {
				var iconHeight:Boolean = false;
				var minMessageHeight:int = tfLastMessage.height;
				if (iconMessageType != null) {
					if (iconMessageType.height > tfLastMessage.height) {
						minMessageHeight = iconMessageType.height;
						iconHeight = true;
					} else
						minMessageHeight = tfLastMessage.height;
				}
				tfTitle.y = int(trueHeight - (tfTitle.height + minMessageHeight + Config.MARGIN * .3)) * .5;
				if (nineOneOneIcon.visible == true)
					nineOneOneIcon.y = int((tfTitle.height - nineOneOneIcon.height) * .5 + tfTitle.y);
				if (nineOneOnePublicIcon.visible == true)
					nineOneOnePublicIcon.y = int((tfTitle.height - nineOneOnePublicIcon.height) * .5 + tfTitle.y);
				if (iconGroupChat.visible == true)
					iconGroupChat.y = int((tfTitle.height - iconGroupChat.height) * .5 + tfTitle.y);
				if (channelSubscriptionIcon.visible == true)
					channelSubscriptionIcon.y = int((tfTitle.height - channelSubscriptionIcon.height) * .5 + tfTitle.y);
				if (trashIcon.visible == true) {
					inHeight = trueHeight - tfLastMessageTime.height;
					trashIcon.y = int((inHeight - trashIcon.height) * .5 + tfLastMessageTime.height);
				}
				if (repositionUnreadIcon == true) {
					newMessages.y = int((tfTitle.height - newMessages.height) * .5 + tfTitle.y);
				} else if (newMessages.visible == true) {
					inHeight = trueHeight - tfLastMessageTime.height;
					newMessages.y = int(tfLastMessageTime.height + inHeight * .5 - newMessages.height * .5);
				}
				if (iconHeight == true) {
					iconMessageType.y = tfTitle.y + tfTitle.height + Config.MARGIN * .3;
					tfLastMessage.y = int((iconMessageType.height - tfLastMessage.height) * .5 + iconMessageType.y);
				} else {
					tfLastMessage.y = tfTitle.y + tfTitle.height + Config.MARGIN * .3;
					if (iconMessageType != null)
						iconMessageType.y = int((tfLastMessage.height - iconMessageType.height) * .5 + tfLastMessage.y);
				}
			}
			return 0;
		}
		
		private function setIconForMessage(messageType:String):void {
			var icon:Sprite = null;
			switch (messageType) {
				case ChatSystemMsgVO.TYPE_FILE: {
					icon = fileAttachIcon;
					break;
				}
				case ChatSystemMsgVO.TYPE_INVOICE: {
					icon = invoiceIcon;
					break;
				}
				case ChatSystemMsgVO.TYPE_VOICE: {
					icon = voiceIcon;
					break;
				}
			}
			if (icon == null) {
				if (iconMessageType != null)
					iconMessageType.visible = false;
				iconMessageType = icon;
			} else {
				if (iconMessageType == null) {
					iconMessageType = icon;
				} else if (iconMessageType != icon) {
					iconMessageType.visible = false;
					iconMessageType = icon;
				}
				iconMessageType.visible = true;
			}
		}
		
		private function showOnlineMark(value:Boolean, status:String):void {
			drawOnlineStatus(status);
			onlineMark.visible = value;
		}
		
		public function getView(li:ListItem, h:int, w:int, highlight:Boolean = false):IBitmapDrawable {
			if (li.data == null || li.data is ChatVO == false || li.data.isDisposed == true) {
				echo("ListConversation", "getView", "Data is empty");
				if (bg != null)
					bg.visible = false;
				if (bgHighlight != null)
					bgHighlight.visible = false;
				if (bgActive != null)
					bgActive.visible = false;
				if (tfTitle != null)
					tfTitle.visible = false;
				if (tfLastMessageTime != null)
					tfLastMessageTime.visible = false;
				if (tfLastMessage != null)
					tfLastMessage.visible = false;
				if (onlineMark != null)
					onlineMark.visible = false;
				if (avatarWithLetter != null)
					avatarWithLetter.visible = false;
				if (avatar != null)
					avatar.visible = false;
				if (iconGroupChat != null)
					iconGroupChat.visible = false;
				if (fileAttachIcon != null)
					fileAttachIcon.visible = false;
				if (invoiceIcon != null)
					invoiceIcon.visible = false;
				if (voiceIcon != null)
					voiceIcon.visible = false;
				if (trashIcon != null)
					trashIcon.visible = false;
				if (nineOneOneIcon != null)
					nineOneOneIcon.visible = false;
				if (nineOneOnePublicIcon != null)
					nineOneOnePublicIcon.visible = false;
				if (channelSubscriptionIcon != null)
					channelSubscriptionIcon.visible = false;
				if (missDCIcon != null)
					missDCIcon.visible = false;
				if (ratingIcon != null)
					ratingIcon.visible = false;
				if (toadIcon != null)
					toadIcon.visible = false;
				if (jailIcon != null)
					jailIcon.visible = false;
				if (outline != null)
					outline.visible = false;
				if (priceField != null)
					priceField.visible = false;
				if (permanentBanMark != null)
					permanentBanMark.visible = false;
				if (banMark != null)
					banMark.visible = false;
				
				hideExtensions();
				
				return this;
			}
			
			bg.width = w;
			bg.height = h;
			
			bgHighlight.width = w;
			bgHighlight.height = h;
			
			bgActive.width = w;
			bgActive.height = h;
			
			bg.visible = false;
			bgHighlight.visible = false;
			bgActive.visible = false;
			priceField.visible = false;
			outline.graphics.clear();
			outline.visible = false;
			
			hideExtensions();
			
			if (permanentBanMark != null)
				permanentBanMark.visible = false;
			if (banMark != null)
				banMark.visible = false;
			
			var cVO:ChatVO = li.data as ChatVO;
			
			if ((cVO.type == ChatRoomType.QUESTION || (cVO.questionID != null && cVO.questionID != "")) && ChatManager.getCurrentChat() == cVO)
				bgActive.visible = true;
			else if (highlight == true)
				bgHighlight.visible = true;
			else
				bg.visible = true;
			
			setText(cVO, w);
			
			tfLastMessage.render();
			tfLastMessage.getTextField().height += 4;
			
			var userAvatar:Boolean;
			var user:ChatUserVO = null;
			if (cVO.type == ChatRoomType.PRIVATE || cVO.type == ChatRoomType.QUESTION || (cVO.questionID != null && cVO.questionID != "")) {
				userAvatar = true;
				user = UsersManager.getInterlocutor(cVO);
				var userUID:String = "";
				if (user != null)
					userUID = user.uid;
				var onlineStatus:OnlineStatus = null;
				if (userUID != "")
					onlineStatus = UsersManager.isOnline(userUID);
				if (onlineStatus != null)
					showOnlineMark(onlineStatus.online, onlineStatus.status);
			} else
				onlineMark.visible = false;
			
			/*if (DateUtils.isToday(cVO.getDate()))
				format5.color = Style;// 0x363E4E;
			else
				format5.color = 0x8ca7bc;// 0xA4AFB9;*/
			tfLastMessageTime.setTextFormat(format5);
			
			avatarWithLetter.visible = false;
			avatar.visible = false;
			avatar.graphics.clear();
		//	UI.decolorize(avatar, 0);
			if (cVO.type == ChatRoomType.COMPANY) {
				
				if (cVO.pid == -1 || cVO.pid == -2)
					ImageManager.drawGraphicCircleImage(avatar.graphics, avatarSize, avatarSize, avatarSize, avatarAccount, ImageManager.SCALE_PORPORTIONAL);
				else if (cVO.pid == -3)
					ImageManager.drawGraphicCircleImage(avatar.graphics, avatarSize, avatarSize, avatarSize, avatarBankBot, ImageManager.SCALE_PORPORTIONAL);
				else if (cVO.pid == -4)
					ImageManager.drawGraphicCircleImage(avatar.graphics, avatarSize, avatarSize, avatarSize, avatarMarketplace, ImageManager.SCALE_PORPORTIONAL);
				else if (cVO.pid == -5)
					ImageManager.drawGraphicCircleImage(avatar.graphics, avatarSize, avatarSize, avatarSize, avatarPayCard, ImageManager.SCALE_PORPORTIONAL);
				else if (cVO.pid == Config.EP_TRADING)
					ImageManager.drawGraphicCircleImage(avatar.graphics, avatarSize, avatarSize, avatarSize, avatarTrading, ImageManager.SCALE_PORPORTIONAL);
				else if (cVO is ChatVOAction && (cVO as ChatVOAction).action != null && (cVO as ChatVOAction).action.getIconClass() != null)
				{
					if (customAvatarBitmap != null)
					{
						customAvatarBitmap.dispose();
					}
					var icon:Sprite = new ((cVO as ChatVOAction).action.getIconClass())();
					UI.scaleToFit(icon, int(Config.FINGER_SIZE * .55), int(Config.FINGER_SIZE * .55));
					UI.colorize(icon, Color.WHITE);
					var container:Sprite = new Sprite();
					
					var color:Number = avatarColor.color;
					if (cVO.pid == Config.EP_VI_DEF)
					{
						color = Color.RED;
					}
					
					container.graphics.beginFill(color);
					container.graphics.drawRect(0, 0, avatarSize * 2, avatarSize * 2);
					container.graphics.endFill();
					container.addChild(icon);
					icon.x = int(avatarSize - icon.width * .5);
					icon.y = int(avatarSize - icon.height * .5);
					customAvatarBitmap = UI.renderAsset(container, avatarSize * 2, avatarSize * 2);
					icon = null;
					container = null;
					ImageManager.drawGraphicCircleImage(avatar.graphics, avatarSize, avatarSize, avatarSize, customAvatarBitmap, ImageManager.SCALE_PORPORTIONAL);
				}
				else
					ImageManager.drawGraphicCircleImage(avatar.graphics, avatarSize, avatarSize, avatarSize, avatarSupport, ImageManager.SCALE_PORPORTIONAL);
				avatar.visible = true;
			} else if (cVO.type == ChatRoomType.CHANNEL && cVO.uid == null) {
				ImageManager.drawGraphicCircleImage(avatar.graphics, avatarSize, avatarSize, avatarSize, avatarChannel, ImageManager.SCALE_PORPORTIONAL);
				avatar.visible = true;
			} else if (userAvatar == true && user == null) {
				ImageManager.drawGraphicCircleImage(avatar.graphics, avatarSize, avatarSize, avatarSize, avatarEmpty, ImageManager.SCALE_PORPORTIONAL);
				avatar.visible = true;
			} else if (user != null && user.secretMode == true) {
				//avatar.graphics.beginFill(AppTheme.GREY_MEDIUM);
				//avatar.graphics.drawCircle(avatarSize, avatarSize, avatarSize);
				//avatar.graphics.endFill();
				ImageManager.drawGraphicCircleImage(avatar.graphics, avatarSize, avatarSize, avatarSize, avatarIncognito, ImageManager.SCALE_PORPORTIONAL);
				//ImageManager.drawGraphicImage(
					//avatar.graphics,
					//int(avatarSize - avatarIncognito.width * .5),
					//int(avatarSize - avatarIncognito.height * .5),
					//avatarIncognito.width,
					//avatarIncognito.height,
					//avatarIncognito,
					//ImageManager.SCALE_PORPORTIONAL
				//);
				avatar.visible = true;
			} else {
				var a:ImageBitmapData = li.getLoadedImage('avatarURL');
				if (a != null) {
					ImageManager.drawGraphicCircleImage(avatar.graphics, avatarSize, avatarSize, avatarSize, a, ImageManager.SCALE_PORPORTIONAL);
					avatar.visible = true;
				} else {
					if (cVO.type == ChatRoomType.GROUP) {
						ImageManager.drawGraphicCircleImage(avatar.graphics, avatarSize, avatarSize, avatarSize, avatarGroup, ImageManager.SCALE_PORPORTIONAL);
						avatar.visible = true;
					} else if (cVO.title != null && cVO.title.length > 0 && AppTheme.isLetterSupported(cVO.title.charAt(0))) {
						avatarWithLetterTF.text = String(li.data.title).charAt(0).toUpperCase();
						//avatarWithLetter.graphics.clear();
						//avatarWithLetter.graphics.beginFill(AppTheme.getColorFromPallete(String(li.data.title)));
						//avatarWithLetter.graphics.drawCircle(avatarSize, avatarSize, avatarSize);
						//avatarWithLetter.graphics.drawRoundRect(0,0,avatarSize*2, avatarSize*2, avatarSize*1.8,avatarSize*1.8);
						//avatarWithLetter.graphics.endFill();
						UI.drawElipseSquare(avatarWithLetter.graphics, avatarSize*2,avatarSize,AppTheme.getColorFromPallete(String(li.data.title)));		
						avatarWithLetter.visible = true;				
						
					} else if (cVO.type == ChatRoomType.CHANNEL){
						ImageManager.drawGraphicCircleImage(avatar.graphics, avatarSize, avatarSize, avatarSize, avatarChat, ImageManager.SCALE_PORPORTIONAL);
						avatar.visible = true;
					} 
					else
					{
						ImageManager.drawGraphicCircleImage(avatar.graphics, avatarSize, avatarSize, avatarSize, avatarEmpty, ImageManager.SCALE_PORPORTIONAL);
						avatar.visible = true;
					}
				}
			}
			
			missDCIcon.visible = false;
			ratingIcon.visible = false;
			toadIcon.visible = false;
			jailIcon.visible = false;
			
			if (user != null) {
				if (UsersManager.checkForToad(user.uid) == true)
					toadIcon.visible = true;
				else if (user.userVO.missDC == true)
					missDCIcon.visible = true;
				if (user.userVO.payRating != 0) {
					ratingIcon.visible = true;
					ratingIcon.gotoAndStop(user.userVO.payRating);
				}
				if (user.userVO.ban911VO != null && user.userVO.ban911VO.status != "buyout") {
					jailIcon.visible = true;
				}
				
				checkForUserBan(user);
				checkExtensions(user);
			}
			
			if (cVO.type == ChatRoomType.CHANNEL && cVO.subscription != null)
			{
				outline.visible = true;
				var matr:Matrix = new Matrix();
					matr.createGradientBox( w, h - 2, 0, 0, 0 );
				var g:Graphics = outline.graphics;
				//	g.beginGradientFill( GradientType.LINEAR, [ 0x99B7D7, 0x99B7D7 ], [ 0, 0.2 ], [ 90, 255 ], matr, SpreadMethod.PAD );
				//	g.drawRect( 0, 0, w, h - 2 );
				
				priceField.visible = true;
				priceField.text = cVO.subscription.cost.value + " " + cVO.subscription.cost.currency;
				priceField.width = priceField.textWidth + 4;
				priceField.height = priceField.textHeight + 4;
				priceField.x = int(w - Config.MARGIN - priceField.width - Config.MARGIN);
				
				var priceWidth:int;
				priceWidth = priceField.width + Config.DOUBLE_MARGIN;
				g.beginFill(0x4CBA21, 1);
				
				var yPos:int = (height - tfLastMessageTime.y - tfLastMessageTime.height + 4 - priceField.height - Config.MARGIN - Config.MARGIN) * .5 + tfLastMessageTime.y + tfLastMessageTime.height - 4;
				
				g.drawRoundRect(w - priceWidth - Config.MARGIN, yPos, priceWidth, priceField.height + Config.MARGIN, priceField.height + Config.MARGIN, priceField.height + Config.MARGIN);
				g.endFill();
				priceField.y = int(yPos + Config.MARGIN * .5);
			}
			
			if (cVO.pid == Config.EP_VI_DEF)
			{
				/*tfTitle.visible = false;
				var m:Matrix = new Matrix();
				m.createGradientBox(width, height, -(Math.PI/180)*90, 0, 00);*/
				bgBank.graphics.clear();
				
				/*bgBank.graphics.beginGradientFill(GradientType.LINEAR, [0xF1F2F1, 0xFFFFFF], [1, 1], [0, 255], m);
				bgBank.graphics.drawRect(0, 0, width, height);
				bgBank.graphics.endFill();*/
				
				bgBank.graphics.beginFill(Style.color(Style.COLOR_LIST_SPECIAL));
				bgBank.graphics.drawRect(0, 0, width, height)
				bgBank.graphics.endFill();
				
				bgBank.graphics.beginFill(0x5DC269);
				bgBank.graphics.drawRect(0, 0, int(Config.FINGER_SIZE * .1), height);
				bgBank.graphics.endFill();
				
				/*bgBank.graphics.lineStyle(1, 0xDDDEDA);
				bgBank.graphics.moveTo(0, height - 1);
				bgBank.graphics.lineTo(width, height - 1);
				bgBank.graphics.moveTo(0, 1);
				bgBank.graphics.lineTo(width, 1);*/
				bgBank.visible = true;
				
				if (officialIcon == null && !(cVO is ChatVOAction))
				{
					officialIcon = new Sprite();
					
							var textField:TextField = new TextField();
							var textFormat:TextFormat = new TextFormat();
							textFormat.size = Config.FINGER_SIZE * .21;
							textFormat.align = TextFormatAlign.LEFT;
							textFormat.color = Style.color(Style.COLOR_TIP_TEXT);// 0x363E4E;
							textFormat.font = Config.defaultFontName;
							textFormat.bold = true;
							textField.defaultTextFormat = textFormat;
							
							textField.wordWrap = false;
							textField.multiline = false;
							textField.text = Lang.official;
							textField.width = textField.textWidth + 4;
							textField.height = textField.textHeight + 4;
							officialIcon.addChild(textField);
							
							officialIcon.graphics.beginFill(Style.color(Style.COLOR_TIP_BACKGROUND));
							var itemHeight:int = textField.height + Config.FINGER_SIZE * .07;
							officialIcon.graphics.drawRoundRect(0, 0, textField.width + Config.FINGER_SIZE * .12 * 2, itemHeight, itemHeight, itemHeight);
							officialIcon.graphics.endFill();
							textField.x = int(Config.FINGER_SIZE * .12);
							textField.y = int(itemHeight * .5 - textField.height * .5);
					
					addChild(officialIcon);
					officialIcon.x = tfTitle.x;
				//	officialIcon.y = int(tfTitle.y + tfTitle.height * .5 - officialIcon.height * .5);
				}
				tfTitle.autoSize = TextFieldAutoSize.NONE;
			//	TextUtils.truncate(tfTitle);
			//	tfTitle.border = true;
				
				if (officialIcon != null)
				{
					tfTitle.width = Math.max(Config.FINGER_SIZE, width - officialIcon.x - officialIcon.width - Config.MARGIN * 2);;
					tfTitle.x = int(officialIcon.x + officialIcon.width + Config.FINGER_SIZE * .1);
					
					officialIcon.visible = true;
					officialIcon.y = int(tfTitle.y + tfTitle.height * .5 - officialIcon.height * .5);
				}
				
				/*if (bankLogo == null)
				{
					bankLogo = new LogoChat();
					addChild(bankLogo);
					UI.scaleToFit(bankLogo, avatarSize * 2, avatarSize * 2);
					bankLogo.x = avatar.x;
					bankLogo.y = avatar.y;
				}
				else
				{
					bankLogo.visible = true;
					avatar.visible = false;
				}
				if (bankLogo2 == null)
				{
					bankLogo2 = new LogoChat2();
					addChild(bankLogo2);
					UI.scaleToFit(bankLogo2, Config.FINGER_SIZE * 10, Config.FINGER_SIZE * .35);
					bankLogo2.x = tfTitle.x + int(Config.MARGIN);
					bankLogo2.y = tfTitle.y;
				}
				else
				{
					bankLogo2.visible = true;
				}
				tfLastMessage.x = bankLogo2.x - 2;*/
			}
			else
			{
				if (officialIcon != null)
				{
					officialIcon.visible = false;
				}
				
				/*if (bankLogo != null)
				{
					bankLogo.visible = false;
				}
				if (bankLogo2 != null)
				{
					bankLogo2.visible = false;
				}*/
				bgBank.visible = false;
			}
			
			if (trashIcon.visible == true)
			{
				var hzs:Vector.<HitZoneData> = new Vector.<HitZoneData>();
				var hz:HitZoneData = new HitZoneData();
				hz.type = HitZoneType.DELETE;
				hz.x = width - Config.FINGER_SIZE;
				hz.y = 0;
				hz.width = Config.FINGER_SIZE;
				hz.height = height;
				hzs.push(hz);
				li.setHitZones(hzs);
			}
			return this;
		}
		
		private function hideExtensions():void 
		{
			if (extensions != null)
			{
				for each (var extensionClip:Sprite in extensions) 
				{
					extensionClip.visible = false;
				}
			}
		}
		
		private function checkExtensions(itemData:ChatUserVO):void 
		{
			if (itemData != null)
			{
				var userVO:UserVO;
				if (itemData.userVO != null)
				{
					userVO = itemData.userVO;
				}
				
				if (userVO != null)
				{
					var l:int;
					if (userVO != null && userVO.gifts != null && !userVO.gifts.empty())
					{
						if (extensions == null)
						{
							extensions = new Dictionary();
						}
						
						l = userVO.gifts.length;
						var item:Bitmap;
						var sourceClass:Class;
						var source:Sprite;
						var itemSize:int = avatarSize * 1.5;
					//	for (var i:int = 0; i < l; i++) 
					//	{
							sourceClass = userVO.gifts.items[l - 1].getSmallImage();
							if (sourceClass != null)
							{
								if (extensions[sourceClass.toString()] == null)
								{
									source = new sourceClass() as Sprite;
									UI.scaleToFit(source, itemSize * 10, itemSize);
									
									addChild(source);
									if(onlineMark != null)
									{
										try
										{
											setChildIndex(onlineMark, numChildren - 1);
										}
										catch (e:Error)
										{
											
										}
									}
									source.x = avatar.x + avatarSize - source.width * .5;
									source.y = avatar.y + avatarSize * 2 - source.height * .65;
									
									extensions[sourceClass.toString()] = source;
								}
								else
								{
									extensions[sourceClass.toString()].visible = true;
								}
							}
							//!TODO:;
						//	break;
					//	}
					}
				}
			}
		}
		
		private function checkForUserBan(itemData:Object):void 
		{
			if (itemData != null)
			{
				var needPermanentBanMark:Boolean = false;
				var needBanMark:Boolean = false;
				if (itemData is ContactVO && (itemData as ContactVO).userVO != null)
				{
					if ((itemData as ContactVO).userVO.sysBan == true)
					{
						needPermanentBanMark = true;
					}
					else if ((itemData as ContactVO).userVO.ban911 == true)
					{
						needBanMark = true;
					}
				}
				else if (itemData is UserVO)
				{
					if ((itemData as UserVO).sysBan == true)
					{
						needPermanentBanMark = true;
					}
					else if ((itemData as UserVO).ban911 == true)
					{
						needBanMark = true;
					}
				}
				else if (itemData is ChatUserVO && (itemData as ChatUserVO).userVO != null)
				{
					if ((itemData as ChatUserVO).userVO.sysBan == true)
					{
						needPermanentBanMark = true;
					}
					else if ((itemData as ChatUserVO).userVO.ban911 == true)
					{
						needBanMark = true;
					}
				}
				
				if (needPermanentBanMark == true)
				{
					if (permanentBanMark == null)
					{
						permanentBanMark = UI.createBannedMark(avatarSize, Lang.permanentBaned);
						addChild(permanentBanMark);
						permanentBanMark.x = (avatar.x + avatarSize - permanentBanMark.width * .5);
						permanentBanMark.y = (avatar.y + avatarSize - permanentBanMark.height * .5);
					}
					permanentBanMark.visible = true;
				}
				else if (needBanMark == true)
				{
					if (banMark == null)
					{
						banMark = UI.createBannedMark(avatarSize, Lang.banned);
						addChild(banMark);
						banMark.x = (avatar.x + avatarSize - banMark.width * .5);
						banMark.y = (avatar.y + avatarSize - banMark.height * .5);
					}
					banMark.visible = true;
				}
			}
		}
		
		public function dispose():void {
			graphics.clear();
			avatarColor = null;
			
			if (bg != null)
				bg.graphics.clear();
			bg = null;
			if (bgHighlight != null)
				bgHighlight.graphics.clear();
			bgHighlight = null;
			if (bgActive != null)
				bgActive.graphics.clear();
			bgActive = null;
			if (tfTitle != null)
				tfTitle.text = "";
			tfTitle = null;
			if (tfLastMessageTime != null)
				tfLastMessageTime.text = "";
			tfLastMessageTime = null;
			if (tfLastMessage != null)
				tfLastMessage.dispose();
			tfLastMessage = null;
			if (priceField != null)
				priceField.text = "";
			priceField = null;
			if (tfNewMessagesCnt != null)
				tfNewMessagesCnt.text = "";
			tfNewMessagesCnt = null;
			if (onlineMark != null)
				UI.destroy(onlineMark);
			onlineMark = null;
			if (avatarWithLetterTF)
				avatarWithLetterTF.text = "";
			avatarWithLetterTF = null;
			if (avatarWithLetter)
				UI.destroy(avatarWithLetter);
			avatarWithLetter = null;
			if (avatar != null)
				UI.destroy(avatar);
			avatar = null;
			if (avatarGroup != null)
				avatarGroup.dispose();
			avatarGroup = null;
			if (avatarChannel != null)
				avatarChannel.dispose();
			avatarChannel = null;
			if (avatarChat != null)
				avatarChat.dispose();
			avatarChat = null;
			if (avatarSupport != null)
				avatarSupport.dispose();
			avatarSupport = null;
			if (avatarAccount != null)
				avatarAccount.dispose();
			avatarAccount = null;
			if (avatarMarketplace != null)
				avatarMarketplace.dispose();
			avatarMarketplace = null;
			if (avatarTrading != null)
				avatarTrading.dispose();
			avatarTrading = null;
			if (avatarBankBot != null)
				avatarBankBot.dispose();
			avatarBankBot = null;
			if (avatarIncognito != null)
				avatarIncognito.dispose();
			avatarIncognito = null;
			if (avatarEmpty != null)
				avatarEmpty.dispose();
			avatarEmpty = null;
			if (iconGroupChat != null)
				UI.destroy(iconGroupChat);
			iconGroupChat = null;
			if (fileAttachIcon != null)
				UI.destroy(fileAttachIcon);
			fileAttachIcon = null;
			if (invoiceIcon != null)
				UI.destroy(invoiceIcon);
			invoiceIcon = null;
			if (voiceIcon != null)
				UI.destroy(voiceIcon);
			voiceIcon = null;
			if (trashIcon != null)
				UI.destroy(trashIcon);
			trashIcon = null;
			if (nineOneOneIcon != null)
				UI.destroy(nineOneOneIcon);
			nineOneOneIcon = null;
			if (nineOneOnePublicIcon != null)
				UI.destroy(nineOneOnePublicIcon);
			nineOneOnePublicIcon = null;
			if (channelSubscriptionIcon != null)
				UI.destroy(channelSubscriptionIcon);
			channelSubscriptionIcon = null;
			if (jailIcon != null)
				UI.destroy(jailIcon);
			jailIcon = null;
			if (permanentBanMark != null)
				UI.destroy(permanentBanMark);
			permanentBanMark = null;
			if (banMark != null)
				UI.destroy(banMark);
			banMark = null;
			if (customAvatarBitmap != null)
				customAvatarBitmap.dispose();
			customAvatarBitmap = null;
			
			if (bankLogo != null)
				UI.destroy(bankLogo);
			bankLogo = null;
			if (bankLogo2 != null)
				UI.destroy(bankLogo2);
			bankLogo2 = null;
			if (officialIcon != null)
				UI.destroy(officialIcon);
			officialIcon = null;
			if (bgBank != null)
				UI.destroy(bgBank);
			bgBank = null;
			
			if (extensions != null)
			{
				for (var key:String in extensions) 
				{
					UI.destroy(extensions[key]);
					delete extensions[key];
				}
				extensions = null;
			}
			
			iconMessageType = null;
			
			format1 = null;
			format2 = null;
			format3 = null;
			format4 = null;
			format5 = null;
			format6 = null;
			
			if (parent != null)
				parent.removeChild(this);
		}
		
		/* INTERFACE com.dukascopy.connect.gui.list.renderers.IListRenderer */
		
		public function get isTransparent():Boolean {
			return false;
		}
		
		public function updateUnreadMessagesDisplaying():void { }
	}
}