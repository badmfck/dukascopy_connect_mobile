package com.dukascopy.connect.gui.list.renderers {
	
	import assets.SettingsMaskIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.HitZoneData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.gui.megaText.MegaText;
	import com.dukascopy.connect.gui.tabs.FilterTabs;
	import com.dukascopy.connect.managers.escrow.EscrowDealManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.questionsManager.QuestionsManager;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.sys.usersManager.OnlineStatus;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.type.MainColors;
	import com.dukascopy.connect.utils.DateUtils;
	import com.dukascopy.connect.vo.QuestionVO;
	import com.dukascopy.connect.vo.users.UserVO;
	import com.dukascopy.connect.vo.users.adds.ChatUserVO;
	import com.dukascopy.connect.vo.users.adds.ContactVO;
	import com.dukascopy.langs.Lang;
	import com.dukascopy.langs.LangManager;
	import flash.display.Bitmap;
	import flash.display.IBitmapDrawable;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class ListEscrowRenderer extends BaseRenderer implements IListRenderer {
		private var permanentBanMark:Bitmap;
		private var banMark:Bitmap;
		protected var icon911BMD:ImageBitmapData;
		static protected var avatarSize:int = Config.FINGER_SIZE * .4;
		static protected var trueHeight:int = Config.FINGER_SIZE * 1.7;
		static protected var circleSize:int = Config.FINGER_SIZE * .22;
		static protected var onlineStatusROut:int = avatarSize * .22;
		static protected var onlineStatusRIn:int = onlineStatusROut * .8;
		
		static protected var avatarPosX:int = Config.FINGER_SIZE * .18;
		static protected var avatarPosY:int = Config.FINGER_SIZE * .2;
		
		protected var format_amount:TextFormat = new TextFormat();
		protected var format_time:TextFormat = new TextFormat();
		protected var format_status:TextFormat = new TextFormat();
		protected var format_username:TextFormat = new TextFormat();
		protected var format_new_messages:TextFormat = new TextFormat();
		protected var format6:TextFormat = new TextFormat();
		protected var format_price:TextFormat = new TextFormat();
		protected var format8:TextFormat = new TextFormat();
		
		protected var bg:Shape;
		protected var bgInfo:Shape;
		protected var bgHighlight:Shape;
		protected var avatar:Shape;
		protected var avatarWithLetter:Sprite;
		protected var avatarLetterText:TextField;
		protected var avatarIncognito:Sprite;
		protected var onlineMark:Shape;
		protected var paidIcon:Sprite;
		//protected var iconNewbie:Sprite;
		protected var missDCIcon:Sprite;
		protected var ratingIcon:MovieClip;
		protected var toadIcon:Sprite;
		protected var jailIcon:Sprite;
		protected var newMessages:Sprite;
		protected var tfNewMessagesCnt:TextField;
		
		protected var textFieldAmount:TextField;
		protected var tfUsername:TextField;
		protected var tfQuestionTime:TextField;
		protected var textFieldStatus:TextField;
		protected var textFieldPrice:TextField;
		
		protected var maxTitleHeight:int;
		
		protected var avatar911PosY:int;
		
		private var extensions:Dictionary;
		
		protected var ct:ColorTransform = new ColorTransform();
		
		public function ListEscrowRenderer() {
			initTextFormats();
			
			var icon:Sprite;
			if (icon911BMD == null) {
				icon = new SWF911Avatar();
				UI.scaleToFit(icon, avatarSize * 2, avatarSize * 2);
				icon911BMD = UI.getSnapshot(icon, StageQuality.HIGH, "ListConversation.actionAvatar");
				UI.destroy(icon);
				icon = null;
			}
			
			bg = new Shape();
				bg.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
				bg.graphics.drawRect(0, 0, 1, 1);
				bg.graphics.endFill();
			addChild(bg);
			bgHighlight = new Shape();
				bgHighlight.graphics.beginFill(Style.color(Style.COLOR_LIST_SELECTED), 1);
				bgHighlight.graphics.drawRect(0, 0, 10, 10);
				bgHighlight.graphics.endFill();
				bgHighlight.visible = false;
		//	addChild(bgHighlight);
			bgInfo = new Shape();
				bgInfo.visible = false;
			addChild(bgInfo);
			avatar = new Shape();
				avatar.x = avatarPosX;
				avatar.y = avatarPosY;
			addChild(avatar);
			avatarWithLetter = new Sprite();
				avatarWithLetter.x = avatarPosX;
				avatarWithLetter.y = avatarPosY;
				avatarLetterText = new TextField();
					var textFormat:TextFormat = new TextFormat();
						textFormat.font = Config.defaultFontName;
						textFormat.color = MainColors.WHITE;
						textFormat.size = Config.FINGER_SIZE*.5;
						textFormat.align = TextFormatAlign.CENTER;
					avatarLetterText.defaultTextFormat = textFormat;
					avatarLetterText.selectable = false;
					avatarLetterText.width = avatarSize * 2;
					avatarLetterText.multiline = false;
					avatarLetterText.text = "|";
					avatarLetterText.height = avatarLetterText.textHeight + 4;
					avatarLetterText.y = int((avatarSize * 2 - avatarLetterText.height) * .5);
					avatarLetterText.text = "";
				avatarWithLetter.addChild(avatarLetterText);
					avatarIncognito = new SettingsMaskIcon();
					var ct:ColorTransform = new ColorTransform();
					ct.color = 0xFFFFFF;
					avatarIncognito.transform.colorTransform = ct;
					UI.scaleToFit(avatarIncognito, avatarSize * 1.4, avatarSize * 1.4);
					avatarIncognito.x = int(avatarSize - avatarIncognito.width * .5);
					avatarIncognito.y = int(avatarSize - avatarIncognito.height * .5);
				avatarWithLetter.addChild(avatarIncognito);
			addChild(avatarWithLetter);
			
			var scale:Number = avatarSize * 2 / 100;
			
			missDCIcon = new SWFCrownIcon();
			missDCIcon.scaleX = missDCIcon.scaleY = scale;
			missDCIcon.x = avatar.x + avatarSize;
			missDCIcon.y = avatar.y + avatarSize;
		//	addChild(missDCIcon);
			
			ratingIcon = new SWFRatingStars_mc();
			ratingIcon.scaleX = ratingIcon.scaleY = scale;
			ratingIcon.x = avatar.x + avatarSize;
			ratingIcon.y = avatar.y + avatarSize;
			addChild(ratingIcon);
			
			toadIcon = new SWFFrog();
			toadIcon.scaleX = toadIcon.scaleY = scale;
			toadIcon.x = avatar.x + avatarSize;
			toadIcon.y = avatar.y + avatarSize;
		//	addChild(toadIcon);
			
			jailIcon = new (Style.icon(Style.ICON_JAILED));
			UI.colorize(jailIcon, Style.color(Style.COLOR_BACKGROUND));
			jailIcon.scaleX = jailIcon.scaleY = scale;
			jailIcon.x = avatar.x + avatarSize;
			jailIcon.y = avatar.y + avatarSize;
		//	addChild(jailIcon);
			
			var textPosition:int = int(avatar.x + avatarSize * 2 + Config.FINGER_SIZE * .28);
			
			onlineMark = new Shape();
				onlineMark.x = int(avatar.x + avatarSize * Math.cos(32 * Math.PI / 180) + avatarSize - onlineStatusROut);
				onlineMark.y = int(avatar.y + avatarSize * Math.sin(32 * Math.PI / 180) + avatarSize - onlineStatusROut);
				onlineMark.visible = false;
			addChild(onlineMark);
			
			textFieldAmount = new TextField();
				textFieldAmount.defaultTextFormat = format_amount;
				textFieldAmount.wordWrap = false;
				textFieldAmount.multiline = false;
				textFieldAmount.x = textPosition;
			//	textFieldAmount.y = int(Config.FINGER_SIZE * .2 + FontSize.SUBHEAD_14 + Config.FINGER_SIZE * .1);
				textFieldAmount.y = int(Config.FINGER_SIZE * .2);
				textFieldAmount.text = "Pp";
				textFieldAmount.height = textFieldAmount.textHeight + 4;
				textFieldAmount.text = "";;
			addChild(textFieldAmount);
			
			tfUsername = new TextField();
				tfUsername.defaultTextFormat = format_username;
				tfUsername.wordWrap = true;
				tfUsername.multiline = true;
				tfUsername.x = textPosition;
				tfUsername.y = Config.FINGER_SIZE * .2;
				tfUsername.text = "Pp";
				tfUsername.height = tfUsername.textHeight + 4;
				tfUsername.text = "";
		//	addChild(tfUsername);
			
			tfQuestionTime = new TextField();
				tfQuestionTime.defaultTextFormat = format_time;
				tfQuestionTime.autoSize = TextFieldAutoSize.LEFT;
				tfQuestionTime.wordWrap = false;
				tfQuestionTime.multiline = false;
				tfQuestionTime.y = int(Config.FINGER_SIZE * .2);
				tfQuestionTime.x = textPosition;
				tfQuestionTime.text = "Pp";
				tfQuestionTime.height = tfQuestionTime.textHeight + 4;
				tfQuestionTime.text = "";
			addChild(tfQuestionTime);
			
			textFieldPrice = new TextField();
				textFieldPrice.defaultTextFormat = format_price;
				textFieldPrice.wordWrap = false;
				textFieldPrice.multiline = false;
				textFieldPrice.text = "Pp";
				textFieldPrice.x = textPosition;
				textFieldPrice.y = int(textFieldAmount.y + FontSize.BODY + Config.FINGER_SIZE * .1);
				textFieldPrice.height = textFieldPrice.textHeight + 4;
				textFieldPrice.text = "";
			addChild(textFieldPrice);
			
			textFieldStatus = new TextField();
				textFieldStatus.defaultTextFormat = format_status;
				textFieldStatus.wordWrap = false;
				textFieldStatus.multiline = false;
				textFieldStatus.text = "Pp";
				textFieldStatus.height = textFieldStatus.textHeight + 4;
				textFieldStatus.text = "";
				textFieldStatus.x = textPosition;
				textFieldStatus.y = int(textFieldPrice.y + FontSize.BODY + Config.FINGER_SIZE * .1);
			addChild(textFieldStatus);
			
			
				paidIcon = new SWFPaidStamp();
				paidIcon.alpha = .2;
			addChild(paidIcon);
				newMessages = new Sprite();
				newMessages.graphics.beginFill(MainColors.GREEN);
				newMessages.graphics.drawRoundRect(0, 0, circleSize * 1.65, circleSize * 1.65, circleSize * 1.3, circleSize * 1.3);
				newMessages.graphics.endFill();
					tfNewMessagesCnt = new TextField();
					tfNewMessagesCnt.width = newMessages.width;
					tfNewMessagesCnt.defaultTextFormat = format_new_messages;
					tfNewMessagesCnt.text = '`|q';
					tfNewMessagesCnt.height = tfNewMessagesCnt.textHeight + 1;
					tfNewMessagesCnt.y = int((newMessages.height - tfNewMessagesCnt.height) * .5) - 1;
				newMessages.addChild(tfNewMessagesCnt);
			addChild(newMessages);
		}
		
		//6n5dpefg4fv7ebev
		
		private function initTextFormats():void {
			format_amount.font = Config.defaultFontName;
			format_amount.color = Style.color(Style.COLOR_TEXT);
			format_amount.size = FontSize.BODY;
			
			format_time.font = Config.defaultFontName;
			format_time.color = Style.color(Style.COLOR_SUBTITLE);
			format_time.size = FontSize.CAPTION_1;
			
			format_status.font = Config.defaultFontName;
			format_status.color = Style.color(Style.COLOR_SUBTITLE);
			format_status.size = FontSize.CAPTION_1;
			format_status.align = TextFormatAlign.LEFT;
			
			format_username.font = Config.defaultFontName;
			format_username.color = Style.color(Style.COLOR_SUBTITLE);
			format_username.size = FontSize.SUBHEAD;
			
			format_new_messages.font = Config.defaultFontName;
			format_new_messages.align = TextFormatAlign.CENTER;
			format_new_messages.bold = true;
			format_new_messages.color = MainColors.WHITE;
			format_new_messages.size = circleSize;
			
			format6.font = Config.defaultFontName;
			format6.align = TextFormatAlign.LEFT;
			format6.color = Color.GREEN;
			format6.size = FontSize.CAPTION_1;
			
			format_price.font = Config.defaultFontName;
			format_price.align = TextFormatAlign.LEFT;
			format_price.color = Style.color(Style.COLOR_TEXT);
			format_price.size = FontSize.BODY;
			
			format8.font = Config.defaultFontName;
			format8.color = Style.color(Style.COLOR_SUBTITLE);
			format8.size = Config.FINGER_SIZE * .27;
			format8.italic = true;
		}
		
		private function drawOnlineStatus(status:String):void {
			onlineMark.graphics.clear();
			var mainColor:uint = MainColors.GREEN_LIGHT;
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
		
		/* INTERFACE com.dukascopy.connect.gui.list.renderers.IListRenderer */
		public function getHeight(item:ListItem, width:int):int {
			return int(textFieldStatus.y + textFieldStatus.height + Config.FINGER_SIZE * .2);
		}
		
		public function getView(item:ListItem, height:int, width:int, highlight:Boolean = false):IBitmapDrawable {
			var itemData:QuestionVO = item.data as QuestionVO;
			
			if (permanentBanMark != null)
				permanentBanMark.visible = false;
			if (banMark != null)
				banMark.visible = false;
			
			avatarWithLetter.visible = false;
			avatar.graphics.clear();
			avatar.visible = true;
			avatarIncognito.visible = false;
			
			textFieldAmount.text = "";
			tfUsername.text = "";
			tfQuestionTime.text = "";
			tfNewMessagesCnt.text = "";
			textFieldStatus.text = "";
			
			if (itemData.isHeader == true) {
				ImageManager.drawGraphicCircleImage(avatar.graphics, avatarSize, avatarSize, avatarSize, icon911BMD, ImageManager.SCALE_PORPORTIONAL);
			} else if (itemData.uid != null && itemData.uid != "") {
				if (itemData.isMine() == false && itemData.incognito == true) {
					UI.drawElipseSquare(avatarWithLetter.graphics, avatarSize * 2, avatarSize, AppTheme.GREY_MEDIUM_LIGHT);
					avatarWithLetter.visible = true;
					avatarLetterText.visible = false;
					avatarIncognito.visible = true;
				} else {
					var a:ImageBitmapData = item.getLoadedImage('avatarURL');
					if (a != null) {
						ImageManager.drawGraphicCircleImage(avatar.graphics, avatarSize, avatarSize, avatarSize, a, ImageManager.SCALE_PORPORTIONAL);
					} else {
						if (itemData.title && itemData.title.length > 0 && AppTheme.isLetterSupported(itemData.title.charAt(0))) {
							avatarIncognito.visible = false;
							avatarLetterText.visible = true;
							avatarLetterText.text = String(itemData.title).charAt(0).toUpperCase();
							UI.drawElipseSquare(avatarWithLetter.graphics, avatarSize * 2, avatarSize, AppTheme.getColorFromPallete(itemData.title));		
							avatarWithLetter.visible = true;
							avatar.visible = false;
						} else {
							ImageManager.drawGraphicCircleImage(
								avatar.graphics,
								avatarSize,
								avatarSize,
								avatarSize,
								UI.getEmptyAvatarBitmapData(avatarSize * 2, avatarSize * 2),
								ImageManager.SCALE_PORPORTIONAL
							);
						}
					}
				}
			}
			
			newMessages.x = int(width - newMessages.width - Config.FINGER_SIZE_DOT_25);
			
			bg.width = width;
			bg.height = height;
			bg.visible = !highlight;
			
			bgHighlight.width = width;
			bgHighlight.height = height;
			bgHighlight.visible = highlight;
			
			var newWidth:int = width - textFieldAmount.x - Config.MARGIN;
			
			var maxTextWidth:int = width - textFieldAmount.x - Config.FINGER_SIZE * .2;
			textFieldAmount.width = maxTextWidth;
			tfUsername.width = maxTextWidth;
			textFieldPrice.width = maxTextWidth;
			textFieldStatus.width = maxTextWidth;
			
			tfUsername.visible = true;
			tfQuestionTime.visible = true;
			newMessages.visible = false;
			textFieldPrice.visible = false;
			bgInfo.visible = false;
			missDCIcon.visible = false;
			ratingIcon.visible = false;
			toadIcon.visible = false;
			paidIcon.visible = false;
			jailIcon.visible = false;
			
			if (itemData.isHeader == true) {
				tfUsername.visible = false;
				tfQuestionTime.visible = false;
				textFieldAmount.text = Lang.askNewQuestion;
				
				bgInfo.visible = true;
				bgInfo.y = height - bgInfo.height;
			} else if (itemData.uid != null && itemData.uid != "") {
				var hitZones:Vector.<HitZoneData>;
				
				if (itemData && itemData.isMine() && itemData.unread > 0 && itemData.status != "resolved") {
					newMessages.visible = true;
					tfNewMessagesCnt.text = "!";
				}
				newMessages.y = int((height / 2 - newMessages.height / 2));
				tfUsername.htmlText = itemData.title;
				
				
				if (isNaN(itemData.tipsAmount) == false) {
					
					if (itemData.isMine() == true && itemData.isPaid == true) {
						paidIcon.visible = true;
						paidIcon.x = 0;
						paidIcon.y = 0;
						var continueCalc:Boolean = false;
						if (itemData.paidStampSettings == null) {
							continueCalc = true;
							var paidStampSettings:Object = { };
							itemData.paidStampSettings = paidStampSettings;
							paidStampSettings.rotation = Math.random() * 90 - 45;
							paidStampSettings.height = int((trueHeight - Config.DOUBLE_MARGIN) * .8);
						}
						paidIcon.rotation = itemData.paidStampSettings.rotation;
						paidIcon.height = itemData.paidStampSettings.height;
						paidIcon.scaleX = paidIcon.scaleY;
						if (continueCalc == true) {
							var rect:Rectangle = paidIcon.getBounds(this);
							paidStampSettings.x = int( -rect.x + Math.random() * (width - textFieldAmount.x - paidIcon.width - Config.MARGIN) + textFieldAmount.x);
							paidStampSettings.y = int( -rect.y + Math.random() * (trueHeight - paidStampSettings.height - Config.MARGIN) + Config.MARGIN);
						}
						paidIcon.x = itemData.paidStampSettings.x;
						paidIcon.y = itemData.paidStampSettings.y;
					}
				}
				
				tfQuestionTime.htmlText = getStatusText(itemData, itemData.createdTime);
				tfQuestionTime.x = int(width - tfQuestionTime.width - Config.FINGER_SIZE_DOT_25 + 2);
				
				
				textFieldPrice.visible = true;
				textFieldPrice.text = getPrice(itemData);
				textFieldAmount.htmlText = getAmount(itemData);
				if (itemData.isMine() == true) {
					textFieldAmount.htmlText = textFieldAmount.htmlText + " (" + Lang.mine.toUpperCase() + ")";
				}
				
				var msgString:String  = itemData.text;
				if (msgString != null && msgString.indexOf(Config.BOUNDS) == 0) {	
					var obj:Object;
					try {
						obj = JSON.parse(msgString.substr(Config.BOUNDS.length));
						msgString = obj.title;
					} catch (err:Error) { }					
				}							
				
				if (itemData.isMine() && itemData.answersCount > 0)
					textFieldStatus.defaultTextFormat = format6;
				else
					textFieldStatus.defaultTextFormat = format_status;
				
				if (itemData.status == "resolved" || itemData.status == "closed") {
					textFieldStatus.defaultTextFormat = format_status;
					textFieldStatus.text = Lang.escrow_offer_closed;
				} else {
					var str:String;
					if (itemData.type == null || itemData.type == QuestionsManager.QUESTION_TYPE_PRIVATE) {
						str = LangManager.replace(Lang.regExtValue,Lang.escrow_already_participate, String(itemData.answersCount));
						str = LangManager.replace(Lang.regExtValue,str,String(itemData.answersMaxCount));
					} else if (itemData.type == QuestionsManager.QUESTION_TYPE_PUBLIC) {
						if (itemData.answersCount == 1)
							str = Lang.alreadyAnswering;
						else
							str = Lang.noAswersYet;
					}
					if (str == null)
						str = "";
					textFieldStatus.text = str;
				}
			}
			
			/*if (itemData.user != null)
			{
				checkForUserBan(itemData.user);
				checkExtensions(itemData.user);
			}*/
			
			item.setHitZones(hitZones);
			
			onlineMark.visible = false;
			var onlineStatus:OnlineStatus = null;
			if (itemData.userUID)
				onlineStatus = UsersManager.isOnline(itemData.userUID);
			if (onlineStatus != null) {
				if (onlineStatus.online == true)
					drawOnlineStatus(onlineStatus.status);
				onlineMark.visible = onlineStatus.online;
			}
			
			if (itemData.isRemoving == true)
				alpha = .5;
			else
				alpha = 1;
			
			return this;
		}
		
		private function getPrice(itemData:QuestionVO):String 
		{
			var result:String = "";
			if (itemData.price != null)
			{
				if (itemData.price.indexOf("%") != -1)
				{
					var realPrice:Number = parseFloat(itemData.price.replace("%", ""));
					
					if (!isNaN(EscrowDealManager.getPrice(itemData.tipsCurrency, itemData.priceCurrency)))
					{
						result += "@" + EscrowDealManager.getPrice(itemData.tipsCurrency, itemData.priceCurrency);
						if (itemData.priceCurrency != null)
						{
							result += " " + itemData.priceCurrency;
						}
						result += " ";
						
						if (realPrice != 0)
						{
							if (realPrice > 0)
							{
								result += "+";
							}
							result += itemData.price;
						}
					}
					else
					{
						result += "@MKT" + " ";
						if (realPrice != 0)
						{
							if (realPrice > 0)
							{
								result += "+";
							}
							result += itemData.price;
						}
					}
				}
				else
				{
					result = "@" + itemData.price;
					if (itemData.priceCurrency != null)
					{
						result += " " + itemData.priceCurrency;
					}
				}
			}
			
			return result;
		}
		
		private function getTime(itemData:QuestionVO, timeValue:String):String 
		{
			var result:String = "";
			if (itemData.subtype == "buy")
			{
				result += "<font color=\u0022#" + Color.GREEN.toString(16) + "\u0022>" + timeValue + "</font>";
			//	result += Lang.BUY.toUpperCase();
			}
			else
			{
				result += "<font color=\u0022#" + Color.RED.toString(16) + "\u0022>" + timeValue + "</font>";
			//	result += Lang.sell.toUpperCase();
			}
			
			return result;
		}
		
		private function getAmount(itemData:QuestionVO):String 
		{
			var result:String = "";
			if (itemData.subtype == "buy")
			{
				result += "<font color=\u0022#" + Color.GREEN.toString(16) + "\u0022>" + Lang.BUY.toUpperCase() + " " + itemData.cryptoAmount + " " + itemData.tipsCurrencyDisplay + "</font>";
			//	result += Lang.BUY.toUpperCase();
			}
			else
			{
				result += "<font color=\u0022#" + Color.RED.toString(16) + "\u0022>" + Lang.sell.toUpperCase() + " " + itemData.cryptoAmount + " " + itemData.tipsCurrencyDisplay + "</font>";
			//	result += Lang.sell.toUpperCase();
			}
		//	result += " ";
		//	result += itemData.cryptoAmount;
		//	result += " ";
		//	result += itemData.tipsCurrencyDisplay;
			
			return result;
		}
		
		private function getStatusText(q:QuestionVO, timestamp:Number):String {
			var date:Date = new Date(Number(timestamp * 1000));
			return getTime(q, DateUtils.getComfortDateRepresentationWithMinutes(date));
			return "<font color=\u0022#" + AppTheme.GREY_MEDIUM.toString(16) + "\u0022>" + DateUtils.getComfortDateRepresentationWithMinutes(date) + "</font>";
		}
		
		override public function getSelectedHitzone(itemTouchPoint:Point, listItem:ListItem):HitZoneData
		{
			var h:int = getHeight(listItem, listItem.width);
			getView(listItem, h, listItem.width, false);
			
			if (listItem.data.uid == null || listItem.data.uid == "")
			{
				var result:HitZoneData = new HitZoneData();
				result.type = HitZoneType.MENU_MIDDLE_ELEMENT;
				result.x = 0;
				result.y = 0;
				result.width = listItem.width;
				result.height = h - bgInfo.height * .5;
				return result;
			}
			else
			{
				return null;
			}
		}
		
		public function dispose():void {
			format_amount = null;
			format_time = null;
			format_status = null;
			format_username = null;
			format_new_messages = null;
			format6 = null;
			format_price = null;
			format8 = null;
			
			graphics.clear();
			
			if (textFieldAmount != null)
				UI.destroy(textFieldAmount);
			textFieldAmount = null;
			if (tfUsername)
				tfUsername.text = "";
			tfUsername = null;
			if (tfQuestionTime != null)
				tfQuestionTime.text = "";
			tfQuestionTime = null;
			if (textFieldStatus)
				textFieldStatus.text = "";
			textFieldStatus = null;
			if (textFieldPrice)
				textFieldPrice.text = "";
			textFieldPrice = null;
			
			UI.destroy(bg);
			bg = null;
			
			UI.destroy(bgHighlight);
			bgHighlight = null;
			
			UI.destroy(avatar);
			avatar = null;
			
			if (jailIcon != null) {
				UI.destroy(jailIcon);
				jailIcon = null;
			}
			
			if (permanentBanMark != null)
				UI.destroy(permanentBanMark);
			permanentBanMark = null;
			if (banMark != null)
				UI.destroy(banMark);
			banMark = null;
			
			UI.destroy(avatarWithLetter);
			avatarWithLetter = null;
			
			if (tfNewMessagesCnt != null)
				tfNewMessagesCnt.text = "";
			tfNewMessagesCnt = null;
			
			UI.destroy(newMessages);
			newMessages = null;
			
			if (avatarLetterText != null)
				avatarLetterText.text = "";
			avatarLetterText = null;
			
			UI.destroy(onlineMark);
			onlineMark = null;
			
			if (parent) {
				parent.removeChild(this);
			}
			
			icon911BMD.dispose();
			icon911BMD = null;
			
			if (extensions != null)
			{
				for (var key:String in extensions) 
				{
					UI.destroy(extensions[key]);
					delete extensions[key];
				}
				extensions = null;
			}
		}
		
		/* INTERFACE com.dukascopy.connect.gui.list.renderers.IListRenderer */
		public function get isTransparent():Boolean {
			return true;
		}
	}
}