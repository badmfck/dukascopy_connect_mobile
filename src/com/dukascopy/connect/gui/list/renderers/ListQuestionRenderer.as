package com.dukascopy.connect.gui.list.renderers {
	
	import assets.SettingsMaskIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.HitZoneData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.gui.megaText.MegaText;
	import com.dukascopy.connect.gui.tabs.FilterTabs;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.questionsManager.QuestionsManager;
	import com.dukascopy.connect.sys.style.Style;
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
	
	public class ListQuestionRenderer extends BaseRenderer implements IListRenderer {
		private var permanentBanMark:Bitmap;
		private var banMark:Bitmap;
		protected var icon911BMD:ImageBitmapData;
		static protected var avatarSize:int = Config.FINGER_SIZE * .46;
		static protected var trueHeight:int = Config.FINGER_SIZE * 1.7;
		static protected var circleSize:int = Config.FINGER_SIZE * .22;
		static protected var onlineStatusROut:int = avatarSize * .22;
		static protected var onlineStatusRIn:int = onlineStatusROut * .8;
		
		static protected var avatarPosX:int = Config.MARGIN * 2;
		static protected var avatarPosY:int = (trueHeight - avatarSize * 2) * .5;
		
		protected var format1:TextFormat = new TextFormat();
		protected var format2:TextFormat = new TextFormat();
		protected var format3:TextFormat = new TextFormat();
		protected var format4:TextFormat = new TextFormat();
		protected var format5:TextFormat = new TextFormat();
		protected var format6:TextFormat = new TextFormat();
		protected var format7:TextFormat = new TextFormat();
		protected var format8:TextFormat = new TextFormat();
		
		protected var bg:Shape;
		protected var bgInfo:Shape;
		protected var bgHighlight:Shape;
		protected var bgGray:Shape;
		protected var bottomLine:Shape;
		protected var avatar:Shape;
		protected var avatarWithLetter:Sprite;
		protected var avatarLetterText:TextField;
		protected var avatarIncognito:Sprite;
		protected var onlineMark:Shape;
		protected var paidIcon:Sprite;
		//protected var iconNewbie:Sprite;
		protected var typeIcon:Sprite;
		protected var typeIconText:TextField;
		protected var missDCIcon:Sprite;
		protected var ratingIcon:MovieClip;
		protected var toadIcon:Sprite;
		protected var jailIcon:Sprite;
		protected var flag:Sprite;
		protected var flags:Object;
		protected var newMessages:Sprite;
		protected var tfNewMessagesCnt:TextField;
		
		protected var tfTitle:MegaText;
		protected var tfUsername:TextField;
		protected var tfQuestionTime:TextField;
		protected var tfAnswersNum:TextField;
		protected var tfTips:TextField;
		
		protected var maxTitleHeight:int;
		
		protected var avatar911PosY:int;
		
		private var extensions:Dictionary;
		
		protected var ct:ColorTransform = new ColorTransform();
		
		public function ListQuestionRenderer() {
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
			bgGray = new Shape();
				bgGray.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND_LIGHT));
				bgGray.graphics.drawRect(0, 0, 1, 1);
				bgGray.graphics.endFill();
			addChild(bgGray);
			bgHighlight = new Shape();
				bgHighlight.graphics.beginFill(Style.color(Style.COLOR_LIST_SELECTED), 1);
				bgHighlight.graphics.drawRect(0, 0, 10, 10);
				bgHighlight.graphics.endFill();
				bgHighlight.visible = false;
			bottomLine = new Shape();
				bottomLine.graphics.beginFill(Style.color(Style.COLOR_LINE_SSL));
				bottomLine.graphics.drawRect(0, 0, 1, 1);
				bottomLine.graphics.endFill();
			addChild(bottomLine);
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
			addChild(missDCIcon);
			
			ratingIcon = new SWFRatingStars_mc();
			ratingIcon.scaleX = ratingIcon.scaleY = scale;
			ratingIcon.x = avatar.x + avatarSize;
			ratingIcon.y = avatar.y + avatarSize;
			addChild(ratingIcon);
			
			toadIcon = new SWFFrog();
			toadIcon.scaleX = toadIcon.scaleY = scale;
			toadIcon.x = avatar.x + avatarSize;
			toadIcon.y = avatar.y + avatarSize;
			addChild(toadIcon);
			
			jailIcon = new (Style.icon(Style.ICON_JAILED));
			UI.colorize(jailIcon, Style.color(Style.COLOR_BACKGROUND));
			jailIcon.scaleX = jailIcon.scaleY = scale;
			jailIcon.x = avatar.x + avatarSize;
			jailIcon.y = avatar.y + avatarSize;
			addChild(jailIcon);
			
			onlineMark = new Shape();
				onlineMark.x = int(avatar.x + avatarSize * Math.cos(32 * Math.PI / 180) + avatarSize - onlineStatusROut);
				onlineMark.y = int(avatar.y + avatarSize * Math.sin(32 * Math.PI / 180) + avatarSize - onlineStatusROut);
				onlineMark.visible = false;
			addChild(onlineMark);
			tfTitle = new MegaText();
				tfTitle.x = int(avatar.x + avatarSize * 2 + Config.MARGIN);
			addChild(tfTitle);
			flag = new Sprite();
			flag.x = tfTitle.x + 2;
			addChild(flag);
			typeIcon = new Sprite();
				typeIconText = new TextField();
					typeIconText.defaultTextFormat = new TextFormat(Config.defaultFontName, Config.FINGER_SIZE * .18, Style.color(Style.COLOR_911_MARK_TEXT), 
																	true, Style.bold(Style.ITALIC_911_MARK_TEXT));
					typeIconText.multiline = false;
					typeIconText.wordWrap = false;
					typeIconText.text = Lang.textQuestionTypePublic.toUpperCase();
					typeIconText.width = typeIconText.textWidth + 4;
					typeIconText.height = typeIconText.textHeight + 4;
				typeIcon.addChild(typeIconText);
				typeIcon.graphics.beginFill(Style.color(Style.COLOR_911_MARK_BACK));
				var typeIconBGWidth:int = typeIconText.width + Config.FINGER_SIZE_DOT_25;
				typeIcon.graphics.drawRoundRect(0, 0, typeIconBGWidth, Config.FINGER_SIZE_DOT_25, Config.FINGER_SIZE_DOT_25, Config.FINGER_SIZE_DOT_25);
				typeIconText.x = int((typeIconBGWidth - typeIconText.width)  * .5);
				typeIconText.y = int(Config.FINGER_SIZE * .125 - typeIconText.height * .5);
			addChild(typeIcon);
			tfUsername = new TextField();
				tfUsername.defaultTextFormat = format4;
				tfUsername.wordWrap = true;
				tfUsername.multiline = true;
				tfUsername.x = tfTitle.x;
				tfUsername.text = "Pp";
				tfUsername.height = tfUsername.textHeight + 4;
				tfUsername.text = "";
			addChild(tfUsername);
			tfAnswersNum = new TextField();
				tfAnswersNum.defaultTextFormat = format3;
				tfAnswersNum.wordWrap = false;
				tfAnswersNum.multiline = false;
				tfAnswersNum.text = "Pp";
				tfAnswersNum.height = tfAnswersNum.textHeight + 4;
				tfAnswersNum.text = "";
				tfAnswersNum.backgroundColor = 0xFFFFFF;
			addChild(tfAnswersNum);
			tfQuestionTime = new TextField();
				tfQuestionTime.defaultTextFormat = format2;
				tfQuestionTime.autoSize = TextFieldAutoSize.LEFT;
				tfQuestionTime.wordWrap = false;
				tfQuestionTime.multiline = false;
				tfQuestionTime.y = Config.MARGIN;
				tfQuestionTime.x = tfTitle.x;
				tfQuestionTime.text = "Pp";
				tfQuestionTime.height = tfQuestionTime.textHeight + 4;
				tfQuestionTime.text = "";
			addChild(tfQuestionTime);
			tfTips = new TextField();
				tfTips.defaultTextFormat = format7;
				tfTips.autoSize = TextFieldAutoSize.LEFT;
				tfTips.wordWrap = false;
				tfTips.multiline = false;
				tfTips.text = "Pp";
				tfTips.height = tfQuestionTime.textHeight + 4;
				tfTips.text = "";
			addChild(tfTips);
				paidIcon = new SWFPaidStamp();
				paidIcon.alpha = .2;
			addChild(paidIcon);
				newMessages = new Sprite();
				newMessages.graphics.beginFill(MainColors.GREEN);
				newMessages.graphics.drawRoundRect(0, 0, circleSize * 1.65, circleSize * 1.65, circleSize * 1.3, circleSize * 1.3);
				newMessages.graphics.endFill();
					tfNewMessagesCnt = new TextField();
					tfNewMessagesCnt.width = newMessages.width;
					tfNewMessagesCnt.defaultTextFormat = format5;
					tfNewMessagesCnt.text = '`|q';
					tfNewMessagesCnt.height = tfNewMessagesCnt.textHeight + 1;
					tfNewMessagesCnt.y = int((newMessages.height - tfNewMessagesCnt.height) * .5) - 1;
				newMessages.addChild(tfNewMessagesCnt);
			addChild(newMessages);
			
			var bgInfoHeight:int = tfAnswersNum.height + Config.MARGIN;
			
			bgInfo.graphics.beginFill(Style.color(Style.COLOR_TIP_BACKGROUND));
			bgInfo.graphics.drawRoundRect(0, 0, bgInfoHeight * 2, bgInfoHeight, bgInfoHeight, bgInfoHeight);
			bgInfo.graphics.endFill();
			bgInfo.scale9Grid = new Rectangle(bgInfoHeight + 1, 1, 1, 1);
			
			avatar911PosY = (trueHeight - bgInfoHeight * .5) * .5 - avatarSize;
		}
		
		private function initTextFormats():void {
			format1.font = Config.defaultFontName;
			format1.color = Style.color(Style.COLOR_TITLE);
			format1.size = Config.FINGER_SIZE * .27;
			
			format2.font = Config.defaultFontName;
			format2.color = Style.color(Style.COLOR_SUBTITLE);
			format2.size = Config.FINGER_SIZE * .2;
			
			format3.font = Config.defaultFontName;
			format3.color = Style.color(Style.COLOR_SUBTITLE);
			format3.size = Config.FINGER_SIZE * .23;
			format3.align = TextFormatAlign.LEFT;
			format3.underline = false;
			
			format4.font = Config.defaultFontName;
			format4.color = Style.color(Style.COLOR_SUBTITLE);
			format4.size = Config.FINGER_SIZE * .27;
			
			format5.font = Config.defaultFontName;
			format5.align = TextFormatAlign.CENTER;
			format5.bold = true;
			format5.color = MainColors.WHITE;
			format5.size = circleSize;
			
			format6.font = Config.defaultFontName;
			format6.align = TextFormatAlign.LEFT;
			format6.color = Style.color(Style.COLOR_911_BRED);
			format6.size = Config.FINGER_SIZE * .23;
			format6.underline = true;
			
			format7.font = Config.defaultFontName;
			format7.align = TextFormatAlign.LEFT;
			format7.color = Style.color(Style.COLOR_TIPS);
			format7.size = Config.FINGER_SIZE * .27;
			
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
			return trueHeight;
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
		
		private function checkExtensions(userVO:UserVO):void 
		{
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
									UI.scaleToFit(source, itemSize*10, itemSize);
									
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
				//		break;
				//	}
				}
			}
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
			
			hideExtensions();
			
			tfTitle.setText(1, "");
			tfUsername.text = "";
			tfQuestionTime.text = "";
			tfNewMessagesCnt.text = "";
			tfAnswersNum.text = "";
			
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
			
			bgGray.visible = false;
			
			var lastTipsQUIDsExists:Boolean = (QuestionsManager.getLastTipsQUIDs() != null && QuestionsManager.getLastTipsQUIDs() != "");
			if (lastTipsQUIDsExists == true && (QuestionsManager.getShowTipsOnly() == true || QuestionsManager.getLastTipsQUIDs().indexOf(itemData.uid) != -1)) {
				bgGray.y = 0;
				bgGray.width = width;
				bgGray.height = height;
				bgGray.visible = true;
			}
			
			bottomLine.width = width;
			
			var newWidth:int = width - tfTitle.x - Config.MARGIN;
			
			tfUsername.visible = true;
			tfQuestionTime.visible = true;
			newMessages.visible = false;
			tfTips.visible = false;
			bgInfo.visible = false;
			flag.visible = false;
			missDCIcon.visible = false;
			ratingIcon.visible = false;
			toadIcon.visible = false;
			paidIcon.visible = false;
			typeIcon.visible = false;
			jailIcon.visible = false;
			
			if (itemData.isHeader == true) {
				tfUsername.visible = false;
				tfQuestionTime.visible = false;
				tfTitle.setText(newWidth, 
								Lang.askNewQuestion, 
								int(format1.color), 
								int(format1.size),
								"#FFFFFF",
								1.5, 1);
				tfTitle.y = int((trueHeight - bgInfo.height * .5 - tfTitle.height) * .5);
				
				bgInfo.visible = true;
				bgInfo.y = height - bgInfo.height;
				
				tfAnswersNum.defaultTextFormat = format3;
				
				//if (QuestionsManager.getCategoriesFilterNames() == "") {
					tfAnswersNum.text = Lang.answerGetRewards;
				/*} else {
					tfAnswersNum.text = QuestionsManager.getCategoriesFilterNames();
				}*/
				
				tfAnswersNum.width = tfAnswersNum.textWidth + 4;
				tfAnswersNum.x = int((width - tfAnswersNum.width) * .5);
				tfAnswersNum.y = bgInfo.y + Config.MARGIN * .5;
				
				bgInfo.width = tfAnswersNum.width + Config.DOUBLE_MARGIN;
				bgInfo.x = tfAnswersNum.x - Config.MARGIN;
				
				bottomLine.visible = true;
				bottomLine.y = bgInfo.y + bgInfo.height * .5;
				
				if (QuestionsManager.getLastTipsQUIDs() != "") {
					bgGray.y = bottomLine.y + bottomLine.height;
					bgGray.width = width;
					bgGray.height = height - bgGray.y;
					bgGray.visible = true;
					
					ct.color = 0xD8DBE0;
					bgInfo.transform.colorTransform = ct;
					tfAnswersNum.textColor = 0x3F4656;
				} else {
					ct.color = 0xEBF1F2;
					bgInfo.transform.colorTransform = ct;
					tfAnswersNum.textColor = 0x8C939D;
				}
				
				avatar.y = avatar911PosY;
				avatarWithLetter.y = avatar911PosY;
				
			} else if (itemData.uid != null && itemData.uid != "") {
				if (UsersManager.checkForToad(itemData.userUID) == true)
					toadIcon.visible = true;
				else if (itemData.user != null && itemData.user.missDC == true)
					missDCIcon.visible = true;
				typeIcon.visible = itemData.type == QuestionsManager.QUESTION_TYPE_PUBLIC;
				
				if (itemData.user != null && itemData.user.ban911VO != null && itemData.user.ban911VO.status != "buyout") {
					jailIcon.visible = true;
				}
				var hitZones:Vector.<HitZoneData>;
				bottomLine.y = trueHeight - 1;
				if (item.list != null) {
					bottomLine.visible = itemData != item.list.data[item.list.data.length - 1];
				} else {
					bottomLine.visible = false;
				}
				
				avatar.y = avatarPosY;
				avatarWithLetter.y = avatarPosY;
				
				if (itemData && itemData.isMine() && itemData.unread > 0 && itemData.status != "resolved") {
					newMessages.visible = true;
					tfNewMessagesCnt.text = "!";
				}
				
				if (itemData.user != null && "payRating" in itemData.user && itemData.user.payRating != 0) {
					ratingIcon.visible = true;
					ratingIcon.gotoAndStop(itemData.user.payRating);
				}
				
				newMessages.y = int((height / 2 - newMessages.height / 2));
				
				if (isNaN(itemData.tipsAmount) == false) {
					tfTips.text = "+" + itemData.tipsAmount + " " + itemData.tipsCurrencyDisplay;
					tfTips.visible = true;
					tfTips.y = int(newMessages.y + (newMessages.height -tfTips.height) * .5);
					tfTips.x = (newMessages.visible == true) ? int(newMessages.x - tfTips.width - Config.MARGIN) : int(width - tfTips.width - Config.FINGER_SIZE_DOT_25 + 2);
					
					hitZones = new Vector.<HitZoneData>();
					var hz:HitZoneData = new HitZoneData();
					hz.type = HitZoneType.TIPS;
					hz.x = tfTips.x;
					hz.y = tfTips.y;
					hz.width = tfTips.width;
					hz.height = tfTips.height;
					hitZones.push(hz);
					
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
							paidStampSettings.x = int( -rect.x + Math.random() * (width - tfTitle.x - paidIcon.width - Config.MARGIN) + tfTitle.x);
							paidStampSettings.y = int( -rect.y + Math.random() * (trueHeight - paidStampSettings.height - Config.MARGIN) + Config.MARGIN);
						}
						paidIcon.x = itemData.paidStampSettings.x;
						paidIcon.y = itemData.paidStampSettings.y;
					}
				} else if (itemData.newbie == true && itemData.user != null && "payRating" in itemData.user && itemData.user.payRating != 0) {
					tfTips.text = "NEW!";
					tfTips.visible = true;
					tfTips.y = int(newMessages.y + (newMessages.height -tfTips.height) * .5);
					tfTips.x = (newMessages.visible == true) ? int(newMessages.x - tfTips.width - Config.MARGIN) : int(width - tfTips.width - Config.MARGIN * 1.56);
				}
				
				tfAnswersNum.x = tfTitle.x;
				tfAnswersNum.background = false;
				
				tfQuestionTime.htmlText = getStatusText(itemData.createdTime);
				tfQuestionTime.x = int(width - tfQuestionTime.width - Config.FINGER_SIZE_DOT_25 + 2);
				
				if (tfTips.visible == true)
					newWidth = tfTips.x - tfTitle.x - Config.MARGIN;
				else
					newWidth -= tfQuestionTime.width + Config.MARGIN;
				
				var newWidthTemp:int = newWidth;
				
				if (typeIcon.visible == true)
					newWidth -= typeIcon.width + Config.MARGIN;
				
				tfUsername.visible = false;
				if (itemData.isMine() == true) {
					if (itemData.incognito == true) {
						tfUsername.visible = true;
						tfUsername.htmlText = Lang.secretTitle;
						tfUsername.setTextFormat(format8);
						tfUsername.width = newWidth;
					}
				} else {
					tfUsername.visible = true;
					if (itemData.incognito == true) {
						if (itemData.anonymData != null) {
							var s:String = "";
							if ("gender" in itemData.anonymData == true && itemData.anonymData.gender != null && itemData.user != null && itemData.user.gender != "") {
								s += itemData.anonymData.gender;
								s = s.substr(0, 1).toUpperCase() + s.substr(1);
							}
							tfUsername.htmlText = s;
						}
					} else
						tfUsername.htmlText = itemData.title;
					tfUsername.setTextFormat(format4);
					tfUsername.width = newWidth;
				}
				
				newWidth = newWidthTemp;
				
				tfTitle.setText(
					newWidth,
					itemData.text,
					int(format1.color),
					int(format1.size),
					"#FFFFFF",
					1.5,
					itemData.wasSmile
				);
				itemData.wasSmile = tfTitle.getWasSmile() ? 2 : 1;
				
				var msgString:String  = itemData.text;
				if (msgString != null && msgString.indexOf(Config.BOUNDS) == 0) {	
					var obj:Object;
					try {
						obj = JSON.parse(msgString.substr(Config.BOUNDS.length));
						msgString = obj.title;
					} catch (err:Error) { }					
				}							
				if (tfTitle.getTextField().numLines > 2) {
					tfTitle.setText(
									newWidth, 
									msgString.substr(0, tfTitle.getTextField().getLineLength(0) + tfTitle.getTextField().getLineLength(1) - 3) + "...", 
									int(format1.color), 
									int(format1.size),
									"#FFFFFF",
									1.5, itemData.wasSmile);
				}
				if (itemData.wasSmile)
					tfTitle.render();
				
				if (itemData.isMine() && itemData.answersCount > 0)
					tfAnswersNum.defaultTextFormat = format6;
				else
					tfAnswersNum.defaultTextFormat = format3;
				
				if (itemData.status == "resolved" || itemData.status == "closed") {
					tfAnswersNum.defaultTextFormat = format3;
					tfAnswersNum.text = Lang.alreadyAnswered;
				} else {
					var str:String;
					if (itemData.type == null || itemData.type == QuestionsManager.QUESTION_TYPE_PRIVATE) {
						str = LangManager.replace(Lang.regExtValue,Lang.alreadyAnsweringText,String(itemData.answersCount));
						str = LangManager.replace(Lang.regExtValue,str,String(itemData.answersMaxCount));
					} else if (itemData.type == QuestionsManager.QUESTION_TYPE_PUBLIC) {
						if (itemData.answersCount == 1)
							str = Lang.alreadyAnswering;
						else
							str = Lang.noAswersYet;
					}
					if (str == null)
						str = "";
					tfAnswersNum.text = str;
				}
				tfAnswersNum.width = newWidth;
				
				tfUsername.y = int((height - (tfTitle.height + tfQuestionTime.height + tfUsername.height)) * .5);
				typeIcon.y = tfUsername.y + tfUsername.height * .5 - typeIcon.height * .5;
				flag.y = tfUsername.y + 2;
				if (typeIcon.visible == true) {
					typeIcon.x = tfTitle.x;
					if (flag.visible == true) {
						flag.x = typeIcon.x + typeIcon.width + Config.MARGIN;
					}
				} else if (flag.visible == true) {
					flag.x = tfTitle.x;
				}
				if (flag.visible == true) {
					tfUsername.x = flag.x + flag.width + Config.MARGIN;
				} else if (typeIcon.visible == true) {
					tfUsername.x = typeIcon.x + typeIcon.width + Config.MARGIN;
				} else {
					tfUsername.x = tfTitle.x;
				}
				if (tfUsername.visible == true)
					tfTitle.y = tfUsername.y + tfUsername.height;
				else if (typeIcon.visible == true)
					tfTitle.y = typeIcon.y + typeIcon.height;
				else
					tfTitle.y = int((height - (tfTitle.height + tfQuestionTime.height)) * .5);
				tfAnswersNum.y = tfTitle.y + tfTitle.height;
			}
			
			if (itemData.user != null)
			{
				checkForUserBan(itemData.user);
				checkExtensions(itemData.user);
			}
			
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
		
		private function getFlagByqVO(qVO:QuestionVO, def:Boolean = false):void {
			flag.visible = true;
			var countryCode:String = "earth";
			if (def == false &&
				"country" in qVO.anonymData &&
				qVO.anonymData.country != null &&
				qVO.anonymData.country != "" &&
				qVO.anonymData.country != "XX")
					countryCode = qVO.anonymData.country.toLowerCase();
			if (flags != null && countryCode in flags && flags[countryCode] != null) {
				if (flag.getChildAt(0) == flags[countryCode])
					return;
				if (flag.numChildren == 1)
					flag.removeChildAt(0);
				flag.addChild(flags[countryCode]);
				return;
			}
			if (flags == null)
				flags = { };
			try {
				var cls:Class = getDefinitionByName("assets.LangFlag_" + countryCode) as Class;
			} catch (err:Error) {
				return getFlagByqVO(null , true);
			}
			if (cls == null)
				return getFlagByqVO(null , true);
			var countryFlag:Sprite = new cls(); 
			UI.scaleToFit(countryFlag, tfUsername.height * 2, tfUsername.height - 4);
			if (flag.numChildren == 1)
				flag.removeChildAt(0);
			flag.addChild(countryFlag);
			flags[countryCode] = countryFlag;
		}
		
		private function getStatusText(timestamp:Number):String {
			var date:Date = new Date(Number(timestamp * 1000));
			return "<font color=\u0022#" + AppTheme.GREY_MEDIUM.toString(16) + "\u0022>" + DateUtils.getComfortDateRepresentationWithMinutes(date) + "</font>";
		}
		
		override public function getSelectedHitzone(itemTouchPoint:Point, listItem:ListItem):HitZoneData
		{
			var h:int = getHeight(listItem, listItem.width);
			getView(listItem, h, listItem.width, false);
			
			if (listItem.data.uid == null || listItem.data.uid == "")
			{
				var result:HitZoneData = new HitZoneData();
			//	result.touchPoint = itemTouchPoint;
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
			format1 = null;
			format2 = null;
			format3 = null;
			format4 = null;
			format5 = null;
			format6 = null;
			format7 = null;
			format8 = null;
			
			graphics.clear();
			
			if (tfTitle != null)
				tfTitle.dispose();
			tfTitle = null;
			if (tfUsername)
				tfUsername.text = "";
			tfUsername = null;
			if (tfQuestionTime != null)
				tfQuestionTime.text = "";
			tfQuestionTime = null;
			if (tfAnswersNum)
				tfAnswersNum.text = "";
			tfAnswersNum = null;
			if (tfTips)
				tfTips.text = "";
			tfTips = null;
			
			UI.destroy(bg);
			bg = null;
			
			UI.destroy(bgHighlight);
			bgHighlight = null;
			
			UI.destroy(bottomLine);
			bottomLine = null;
			
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