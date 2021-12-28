package com.dukascopy.connect.gui.list.renderers 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.HitZoneData;
	import com.dukascopy.connect.data.LabelItem;
	import com.dukascopy.connect.data.paidBan.PaidBanProtectionData;
	import com.dukascopy.connect.data.paidBan.PaidBanReasons;
	import com.dukascopy.connect.gui.chat.CircleAvatar;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.sys.applicationShop.serverTask.ShopServerTask;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.sys.usersManager.OnlineStatus;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.sys.usersManager.paidBan.PaidBan;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.type.MainColors;
	import com.dukascopy.connect.utils.DateUtils;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.connect.vo.users.adds.UserBan911VO;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.display.IBitmapDrawable;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class ListBanUserRenderer extends BaseRenderer implements IListRenderer
	{
		private var avatarSupport:Bitmap;
		private var avatarWithLetter:Sprite;
		private var avatarLettertext:TextField;
		private var emptyAvatarBD:ImageBitmapData;
		private var banStatus:TextField;
		private var banCost:TextField;
		private var banEndTime:TextField;
		private var rightPadding:int;
		private var placeholderAvatarBD:ImageBitmapData;
		private var avatarPlaceholder:Shape;
		private var placeholderClip:Sprite;
		private var namePosition:Number;
		private var userNameYpositionBan:int;
		private var banReasonYpositionBan:int;
	//	private var userNameYpositionProtection:int;
	//	private var banReasonYpositionProtection:int;
		private var payerTitle:TextField;
		private var payerName:TextField;
		private var payerPositionBanActive:int;
		private var payerPositionProtection:int;
		private var payerAvatar:CircleAvatar;
		private var payerAvatarSize:int;
		
		protected var avatarSize:int;
		
		protected var reasontextFormat:TextFormat = new TextFormat();
		protected var userNameTextFormat:TextFormat = new TextFormat();
		protected var banStatusTextFormat:TextFormat = new TextFormat();
		protected var banStatusInactiveTextFormat:TextFormat = new TextFormat();
		protected var banCosttextFormat:TextFormat = new TextFormat();
		protected var banCostUnactivetextFormat:TextFormat = new TextFormat();
		protected var banEndTimetextFormat:TextFormat = new TextFormat();
		protected var payerNametextFormat:TextFormat = new TextFormat();
		protected var payerTitletextFormat:TextFormat = new TextFormat();
		protected var labelButtontextFormat:TextFormat = new TextFormat();
		
		protected var userName:TextField;
		protected var banReason:TextField;
		protected var avatar:Shape;
		protected var avatarEmpty:Shape;
		protected var missDCIcon:Sprite;
		protected var ratingIcon:MovieClip;
		protected var toadIcon:Sprite;
		protected var jailIcon:Sprite;
		protected var bg:Shape;
		protected var bgHighlight:Shape;
		
		protected var onlineMark:Sprite;
		
		public function ListBanUserRenderer() {
			create();
		}
		
		protected function create():void {
			initTextFormats();
				bg = new Shape();
				bg.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
				bg.graphics.drawRect(0, 0, 10, 10);
				bg.graphics.endFill();
			addChild(bg);
				bgHighlight = new Shape();
				bgHighlight.graphics.beginFill(Style.color(Style.COLOR_LIST_SELECTED), 1);
				bgHighlight.graphics.drawRect(0, 0, 10, 10);
				bgHighlight.graphics.endFill();
				bgHighlight.visible = false;
			addChild(bgHighlight);
				avatarSize = Config.FINGER_SIZE * .46;
				
			avatarEmpty = new Shape();
				emptyAvatarBD = UI.getEmptyAvatarBitmapData(avatarSize * 2, avatarSize * 2);
				ImageManager.drawGraphicCircleImage(avatarEmpty.graphics, 
													avatarSize, 
													avatarSize, 
													avatarSize, 
													emptyAvatarBD, 
													ImageManager.SCALE_PORPORTIONAL);
				avatarEmpty.x = Config.DOUBLE_MARGIN;
			addChild(avatarEmpty);
			
			avatarPlaceholder = new Shape();
				placeholderAvatarBD = UI.drawBitmapSqare(0xEEEEEE, avatarSize * 2, avatarSize * 2);
				ImageManager.drawGraphicCircleImage(avatarPlaceholder.graphics, 
													avatarSize, 
													avatarSize, 
													avatarSize, 
													placeholderAvatarBD, 
													ImageManager.SCALE_PORPORTIONAL);
				avatarPlaceholder.x = Config.DOUBLE_MARGIN;
			addChild(avatarPlaceholder);
			
			avatarWithLetter = new Sprite();
			avatarLettertext = new TextField();
			avatarWithLetter.addChild(avatarLettertext);
			var textFormat:TextFormat = new TextFormat();
			textFormat.font = Config.defaultFontName;
			textFormat.color = MainColors.WHITE;
			textFormat.size = Config.FINGER_SIZE*.36;
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
			//avatarWithLetter.graphics.endFill();
			UI.drawElipseSquare(avatarWithLetter.graphics, avatarSize*2,avatarSize,AppTheme.GREY_MEDIUM);			
			addChild(avatarWithLetter);
			avatarWithLetter.visible = false;
			
			avatarSupport = new Bitmap();
			avatarSupport.bitmapData = UI.drawAssetToRoundRect(new SWFSupportAvatar(), avatarSize * 2);
			avatarSupport.x = int(Config.MARGIN * 1.58);
			addChild(avatarSupport);	
			
				avatar = new Shape();
				avatarWithLetter.x = avatar.x = avatarEmpty.x;
			addChild(avatar);
			
			var scale:Number = avatarSize * 2 / 100;
				toadIcon = new SWFFrog();
				toadIcon.scaleX = scale;
				toadIcon.scaleY = scale;
				toadIcon.x = avatar.x + avatarSize;
			addChild(toadIcon);
				missDCIcon = new SWFCrownIcon();
				missDCIcon.scaleX = missDCIcon.scaleY = scale;
				missDCIcon.x = avatar.x + avatarSize;
			addChild(missDCIcon);
				ratingIcon = new SWFRatingStars_mc();
				ratingIcon.scaleX = ratingIcon.scaleY = scale;
				ratingIcon.x = avatar.x + avatarSize;
			addChild(ratingIcon);
				jailIcon = new (Style.icon(Style.ICON_JAILED));
				UI.colorize(jailIcon, Style.color(Style.COLOR_BACKGROUND));
				jailIcon.scaleX = jailIcon.scaleY = scale;
				jailIcon.x = avatar.x + avatarSize;
			addChild(jailIcon);
			
			userName = new TextField();
				userName.defaultTextFormat = userNameTextFormat;
				userName.text = "Pp";
				userName.height = userName.textHeight + 4;
				userName.text = "";
				userName.x = int(avatar.x + avatarSize * 2 + Config.MARGIN * 1.58);
				userName.wordWrap = false;
				userName.multiline = false;
			addChild(userName);
			
			namePosition = userName.x;
			
			banReason = new TextField();
				banReason.defaultTextFormat = reasontextFormat;
				banReason.text = "Pp";
				banReason.height = banReason.textHeight + 4;
				banReason.text = "";
				banReason.x = userName.x;
				banReason.wordWrap = false;
				banReason.multiline = false;
			addChild(banReason);
			
			banStatus = new TextField();
				banStatus.defaultTextFormat = banStatusTextFormat;
				banStatus.text = "Pp";
				banStatus.height = banStatus.textHeight + 4;
				banStatus.text = "";
				banStatus.x = userName.x;
				banStatus.wordWrap = false;
				banStatus.multiline = false;
			addChild(banStatus);
			
			banCost = new TextField();
				banCost.defaultTextFormat = banCosttextFormat;
				banCost.text = "Pp";
				banCost.height = banCost.textHeight + 4;
				banCost.text = "";
				banCost.x = userName.x;
				banCost.wordWrap = false;
				banCost.multiline = false;
			addChild(banCost);
			
			banEndTime = new TextField();
				banEndTime.defaultTextFormat = banEndTimetextFormat;
				banEndTime.text = "Pp";
				banEndTime.height = banEndTime.textHeight + 4;
				banEndTime.text = "";
				banEndTime.x = userName.x;
				banEndTime.wordWrap = false;
				banEndTime.multiline = false;
			addChild(banEndTime);
			
			payerTitle = new TextField();
				payerTitle.defaultTextFormat = payerTitletextFormat;
				payerTitle.text = Lang.banProtectionSetBy;
				payerTitle.height = payerTitle.textHeight + 4;
				payerTitle.width = payerTitle.textWidth + 4;
			//	payerTitle.text = "";
				payerTitle.x = userName.x;
				payerTitle.wordWrap = false;
				payerTitle.multiline = false;
			addChild(payerTitle);
			
			payerName = new TextField();
				payerName.defaultTextFormat = payerNametextFormat;
				payerName.text = "Pp";
				payerName.height = payerName.textHeight + 4;
				payerName.text = "";
				payerName.x = userName.x;
				payerName.wordWrap = false;
				payerName.multiline = false;
			addChild(payerName);
			
			onlineMark = new Sprite();
				onlineMark.visible = false;
			addChild(onlineMark);
			
			avatarPlaceholder.y = avatarSupport.y = avatarWithLetter.y = avatar.y = avatarEmpty.y = int((Config.FINGER_SIZE * 1.35 - avatarSize * 2) * .5);
			toadIcon.y = avatarEmpty.y + avatarSize;
			missDCIcon.y = avatarEmpty.y + avatarSize;
			ratingIcon.y = avatarEmpty.y + avatarSize;
			jailIcon.y = avatarEmpty.y + avatarSize;
			
			userNameYpositionBan = int(Config.FINGER_SIZE * .16);
			banReasonYpositionBan = int(userNameYpositionBan + banCost.height - Config.FINGER_SIZE * .054);
			
			
		//	userNameYpositionProtection = int((Config.FINGER_SIZE * 1.35) * .5 - (userName.height + banReason.height - Config.FINGER_SIZE * .054) * .5);
		//	banReasonYpositionProtection = int(userNameYpositionProtection + userName.height - Config.FINGER_SIZE * .054);
			
			userName.y = banCost.y = userNameYpositionBan;
			banReason.y = banEndTime.y = banReasonYpositionBan;
			banStatus.y = int(banReason.y + banReason.height - Config.FINGER_SIZE * .054);
			
			payerPositionBanActive = int(banStatus.y + banStatus.height + Config.FINGER_SIZE * .0);
			payerPositionProtection = int(banReasonYpositionBan + banReason.height + Config.FINGER_SIZE*.03);
			
			rightPadding = Config.MARGIN;
			
			placeholderClip = new Sprite();
			addChild(placeholderClip);
			
			placeholderClip.graphics.beginFill(0xEEEEEE);
			var pos:int = userName.y + Config.FINGER_SIZE * .18;
			placeholderClip.graphics.drawRect(userName.x, pos, Config.FINGER_SIZE * 2.4, Config.FINGER_SIZE * .21);
		//	pos += Config.FINGER_SIZE * .21 + Config.FINGER_SIZE * .1;
		//	placeholderClip.graphics.drawRect(banReason.x, pos, Config.FINGER_SIZE * 3, Config.FINGER_SIZE * .13);
		//	pos += Config.FINGER_SIZE * .13 + Config.FINGER_SIZE * .1;
		//	placeholderClip.graphics.drawRect(banStatus.x, pos, Config.FINGER_SIZE * 1.3, Config.FINGER_SIZE*.13);
			placeholderClip.graphics.endFill();
			
			payerAvatar = new CircleAvatar(false);
			addChild(payerAvatar);
			
			payerAvatarSize = int(Config.FINGER_SIZE * .17);
			payerAvatar.x = int(payerTitle.x + payerTitle.width + Config.FINGER_SIZE * .1);
			
			payerName.x = int(payerAvatar.x + avatarSize - Config.MARGIN * 0.3);
		}
		
		protected function setHitZones(item:ListItem):void {
			if (item.data is LabelItem && (item.data as LabelItem).action != null) {
				var hitZones:Vector.<HitZoneData> = new Vector.<HitZoneData>
				var hz:HitZoneData = new HitZoneData();
						hz.type = HitZoneType.SIMPLE_ACTION;
						hz.x = banReason.x - Config.FINGER_SIZE*.3 + x;
						hz.y = banReason.y -  Config.FINGER_SIZE*.1 + y;
						hz.width = (Config.FINGER_SIZE * .6 + banReason.width);
						hz.height = (Config.FINGER_SIZE * .2 + banReason.height);
						hitZones.push(hz);
				hitZones.push(hz);
				item.setHitZones(hitZones);
			}
		}
		
		private function initTextFormats():void {
			
			var textSize:Number = Config.FINGER_SIZE * .29;
			
			userNameTextFormat.font = Config.defaultFontName;
			userNameTextFormat.size = textSize;
			userNameTextFormat.color = Style.color(Style.COLOR_TITLE);
			
			reasontextFormat.font = Config.defaultFontName;
			reasontextFormat.size = textSize * .8;
			reasontextFormat.color = Style.color(Style.COLOR_SUBTITLE);
			
			banStatusTextFormat.font = Config.defaultFontName;
			banStatusTextFormat.size = textSize * .7;
			banStatusTextFormat.color = Color.GREEN;
			
			banStatusInactiveTextFormat.font = Config.defaultFontName;
			banStatusInactiveTextFormat.size = textSize * .7;
			banStatusInactiveTextFormat.color = Style.color(Style.COLOR_SUBTITLE);
			
			banCosttextFormat.font = Config.defaultFontName;
			banCosttextFormat.size = textSize;
			banCosttextFormat.color = Style.color(Style.COLOR_SUBTITLE);
			
			banCostUnactivetextFormat.font = Config.defaultFontName;
			banCostUnactivetextFormat.size = textSize;
			banCostUnactivetextFormat.color = Style.color(Style.COLOR_SUBTITLE);
			
			banEndTimetextFormat.font = Config.defaultFontName;
			banEndTimetextFormat.size = textSize * .8;
			banEndTimetextFormat.color = Style.color(Style.COLOR_SUBTITLE);
			
			payerTitletextFormat.font = Config.defaultFontName;
			payerTitletextFormat.size = textSize * .7;
			payerTitletextFormat.color = Style.color(Style.COLOR_SUBTITLE);
			
			payerNametextFormat.font = Config.defaultFontName;
			payerNametextFormat.size = textSize * .7;
			payerNametextFormat.color = Style.color(Style.COLOR_SUBTITLE);
			
			labelButtontextFormat.font = Config.defaultFontName;
			labelButtontextFormat.size = textSize * .9;
			labelButtontextFormat.color = Style.color(Style.COLOR_TIP_TEXT);
		}
		
		private function showOnlineMark(value:Boolean, status:String):void {
			onlineMark.visible = value;
			if (value) {
				drawOnlineStatus(status);
				onlineMark.x = int(avatar.x  + avatarSize * Math.cos(Math.PI / 4) + avatarSize - onlineMark.width / 2);
				onlineMark.y = int(avatar.y  + avatarSize * Math.sin(Math.PI / 4) + avatarSize - onlineMark.width / 2);
			}
		}
		
		private function drawOnlineStatus(status:String):void {
			onlineMark.graphics.clear();
			var mainColor:uint = MainColors.GREEN_LIGHT;
			if (status == OnlineStatus.STATUS_AWAY)
				mainColor = MainColors.YELLOW_LIGHT;
			if (status == OnlineStatus.STATUS_DND)
				mainColor = MainColors.RED_LIGHT;
			onlineMark.graphics.beginFill(MainColors.WHITE);
			onlineMark.graphics.drawCircle(avatarSize / 4.2, avatarSize / 4.2, avatarSize / 4.2);
			onlineMark.graphics.endFill();
			onlineMark.graphics.beginFill(mainColor);
			onlineMark.graphics.drawCircle(avatarSize / 4.2, avatarSize / 4.2, avatarSize / 5.9);
			onlineMark.graphics.endFill();
		}
		
		/* INTERFACE com.dukascopy.connect.gui.list.renderers.IListRenderer */
		public function getHeight(item:ListItem, width:int):int {
			if (item.data is UserBan911VO || item.data is PaidBanProtectionData) {
				if (item.data is UserBan911VO && PaidBan.isBanActive(item.data as UserBan911VO))
				{
					return Config.FINGER_SIZE * 1.55;
				}
				return Config.FINGER_SIZE * 1.35;
			}
			return Config.FINGER_SIZE * .7;
		}
		
		public function getView(item:ListItem, height:int, width:int, highlight:Boolean = false):IBitmapDrawable {
			bg.width = width;
			bg.height = height;
			
			bgHighlight.width = width;
			bgHighlight.height = height;
			bg.visible = true;
			
			onlineMark.visible = false;
			avatarSupport.visible = false;
			avatarPlaceholder.visible = false;
			avatarWithLetter.visible = false;
			missDCIcon.visible = false;
			ratingIcon.visible = false;
			toadIcon.visible = false;
			jailIcon.visible = false;
			avatar.visible = false;
			avatarEmpty.visible = false;
			payerName.visible = false;
			payerTitle.visible = false;
			
			userName.visible = false;
			banReason.visible = false;
			banStatus.visible = false;
			banCost.visible = false;
			banEndTime.visible = false;
			placeholderClip.visible = false;
			payerAvatar.visible = false;
			alpha = 1;
			
			if (item.data is LabelItem) {
				userName.y = userNameYpositionBan;
				graphics.clear();
				graphics.beginFill(Style.color(Style.COLOR_SUBTITLE));
				graphics.drawRect(0, 0, width, height);
				graphics.endFill();
				
				bg.visible = false;
				
				userName.text = (item.data as LabelItem).label;
				userName.textColor = Style.color(Style.COLOR_BACKGROUND);
				userName.visible = true;
				userName.width = width - Config.DOUBLE_MARGIN;
				userName.x = Config.DOUBLE_MARGIN;
				
				if ((item.data as LabelItem).action != null)
				{
					banReason.visible = true;
					banReason.text = (item.data as LabelItem).action.getData() as String;
					banReason.setTextFormat(labelButtontextFormat);
					banReason.height = banReason.textHeight + 4;
					banReason.width = banReason.textWidth + 4;
					banReason.x = int(width - banReason.width - Config.FINGER_SIZE * .4);
					banReason.y = int(Config.FINGER_SIZE * .35 - banReason.height * .5);
					
					
					graphics.beginFill(Style.color(Style.COLOR_TIP_BACKGROUND));
					graphics.drawRoundRect(banReason.x - Config.FINGER_SIZE * .3, 
											Config.FINGER_SIZE * .1, 
											banReason.width + Config.FINGER_SIZE * .6, 
											height - Config.FINGER_SIZE * .2, 
											height - Config.FINGER_SIZE * .2, 
											height - Config.FINGER_SIZE * .2);
					graphics.endFill();
					
					setHitZones(item);
				}
				
				return this;
			}
			
			userName.x = namePosition;
			banReason.x = userName.x;
			
			var avatarImage:ImageBitmapData;
			var date:Date;
			
			banReason.y = banReasonYpositionBan;
			
			if (item.data is PaidBanProtectionData)
			{
			//	userName.y = userNameYpositionProtection;
			//	banReason.y = banReasonYpositionProtection;
				payerTitle.y = payerName.y = payerPositionProtection;
				var protectionData:PaidBanProtectionData = item.data as PaidBanProtectionData;
				
				if (protectionData != null)
				{
					graphics.clear();
					banEndTime.visible = true;
					banReason.visible = true;
					banCost.visible = true;
					
					if (protectionData.user != null && protectionData.user.getDisplayName() != null) {
						userName.textColor = Style.color(Style.COLOR_TITLE);
						var userNameValue:String = protectionData.user.getDisplayName();
						if (userNameValue != null) {
							userName.text = userNameValue;
							userName.width = width - avatar.x - avatarSize - Config.DOUBLE_MARGIN - Config.FINGER_SIZE * 1.5;
						} 
						else {
							userName.text = "";
						}
						userName.visible = true;
						
						if (protectionData.user.uid != "") {
							checkOnlineStatus(protectionData.user.uid);
							item.addImageFieldForLoading("avatarURL");
						}
						
						if (UsersManager.checkForToad(protectionData.user.uid) == true)
								toadIcon.visible = true;
						else if (protectionData.user.missDC == true)
							missDCIcon.visible = true;
						if (protectionData.user.payRating != 0) {
							ratingIcon.visible = true;
							ratingIcon.gotoAndStop(protectionData.user.payRating);
						}
						
						avatarImage = item.getLoadedImage("avatarURL");
						if (avatarImage != null && avatarImage.isDisposed == false) {
							avatar.visible = true;
							avatar.graphics.clear();
							ImageManager.drawGraphicCircleImage(avatar.graphics, avatarSize, avatarSize, avatarSize, avatarImage, ImageManager.SCALE_PORPORTIONAL);
						} else {
							if (userNameValue != null && userNameValue.length > 0 && AppTheme.isLetterSupported(userNameValue)) {
								avatarLettertext.text = userNameValue.charAt(0).toUpperCase();
									
								UI.drawElipseSquare(avatarWithLetter.graphics, avatarSize * 2, avatarSize, AppTheme.getColorFromPallete(userNameValue));
								avatarWithLetter.visible = true;
								avatarEmpty.visible = false;
							} else {
								avatarEmpty.visible = true;
							}
						}
						TextUtils.truncate(userName);
					}
					else{
						placeholderClip.visible = true;
						avatarPlaceholder.visible = true;
					}
					
					if (protectionData.payer != null && protectionData.payer.getDisplayName() != null)
					{
						payerTitle.visible = true;
						payerAvatar.visible = true;
						payerName.visible = true;
						payerName.text = protectionData.payer.getDisplayName();
						payerName.width = payerName.textWidth + 4;
						payerAvatar.setData(protectionData.payer, payerAvatarSize, false);
						payerAvatar.y = int(payerTitle.y + payerTitle.height*.5 - payerAvatarSize);
					}
					
					if (!isNaN(protectionData.canceled)) {
						date = new Date();
					//	var difference:Number = itemData.canceled * 1000 - date.getTime();
						
						date.setTime(protectionData.canceled * 1000);
						banEndTime.text = Lang.textTill + " " + DateUtils.getComfortDateRepresentation(date, false);
						banEndTime.width = banEndTime.textWidth + 4;
						banEndTime.x = width - banEndTime.width - rightPadding;
					}
					else {
						banEndTime.text = "";
					}
					
					
					if (!isNaN(PaidBan.getProtectionCost(protectionData))) {
						var cur:String=PaidBan.getCurrency(ShopServerTask.BUY_PROTECTION);
						if(cur.toLowerCase()=="dco")
							cur="DUK+";
						banCost.text = PaidBan.getProtectionCost(protectionData) + " " + cur;
						banCost.setTextFormat(banCosttextFormat);
						banCost.width = banCost.textWidth + 4;
						banCost.x = width - banCost.width - rightPadding;
					}else {
						banCost.text = "";
					}

					banReason.text = Lang.underProtection;
					banReason.height = banReason.textHeight + 4;
					banReason.width = userName.width = getTitleWidth();
					banStatus.text = "";
				}
				return this;
			}
			
			var itemData:UserBan911VO = item.data as UserBan911VO;
			
			if (itemData != null) {
				payerTitle.y = payerName.y = payerPositionBanActive;
				userName.y = userNameYpositionBan;
				
				graphics.clear();
				banReason.visible = true;
				banStatus.visible = true;
				banCost.visible = true;
				banEndTime.visible = true;
				
				if (itemData.user != null && itemData.user.getDisplayName() != null) {
					userName.textColor = Style.color(Style.COLOR_TITLE);
					var userNameText:String = itemData.user.getDisplayName();
					if (userNameText != null) {
						userName.text = userNameText;
						userName.width = width - avatar.x - avatarSize - Config.DOUBLE_MARGIN - Config.FINGER_SIZE * 1.5;
					} 
					else {
						userName.text = "";
					}
					userName.visible = true;
					
					if (itemData.user.uid != "") {
						checkOnlineStatus(itemData.user.uid);
						item.addImageFieldForLoading("avatarURL");
					}
					
					if (UsersManager.checkForToad(itemData.user.uid) == true)
							toadIcon.visible = true;
					else if (itemData.user.missDC == true)
						missDCIcon.visible = true;
					if (itemData.user.payRating != 0) {
						ratingIcon.visible = true;
						ratingIcon.gotoAndStop(itemData.user.payRating);
					}
					
					if (itemData.user.ban911VO != null && PaidBan.isBanActive(itemData.user.ban911VO)) {
						jailIcon.visible = true;
					}
					
					avatarImage = item.getLoadedImage("avatarURL");
					if (avatarImage != null && avatarImage.isDisposed == false) {
						avatar.visible = true;
						avatar.graphics.clear();
						ImageManager.drawGraphicCircleImage(avatar.graphics, avatarSize, avatarSize, avatarSize, avatarImage, ImageManager.SCALE_PORPORTIONAL);
					} else {
						if (userNameValue != null && userNameValue.length > 0 && AppTheme.isLetterSupported(userNameValue)) {
							avatarLettertext.text = userNameValue.charAt(0).toUpperCase();
								
							UI.drawElipseSquare(avatarWithLetter.graphics, avatarSize * 2, avatarSize, AppTheme.getColorFromPallete(userNameValue));
							avatarWithLetter.visible = true;
							avatarEmpty.visible = false;
						} else {
							avatarEmpty.visible = true;
						}
					}
					TextUtils.truncate(userName);
				}
				else{
					placeholderClip.visible = true;
					avatarPlaceholder.visible = true;
				}
					
				var banReasonValue:String;
				if (itemData.reason != -1) {
					banReasonValue = PaidBanReasons.getReason(itemData.reason);
				}
				if (banReasonValue != null) {
					banReason.text = banReasonValue;
					banReason.height = banReason.textHeight + 4;
				}
				else {
					banReason.text = "";
				}
				
				var banActive:Boolean;
				if (!isNaN(itemData.canceled)) {
					date = new Date();
					var difference:Number = itemData.canceled * 1000 - date.getTime();
					banActive = difference > 0;
					if (itemData.status == "buyout")
					{
						banActive = false;
					}
					if (banActive == true) {
						banStatus.text = Lang.banActiveStatus;
						banStatus.setTextFormat(banStatusTextFormat);
					}
					else {
						banStatus.text = Lang.banOverStatus;
						banStatus.setTextFormat(banStatusInactiveTextFormat);
						//alpha = 0.5;
					}
					banStatus.width = banStatus.textWidth + 4;
					
					date.setTime(itemData.canceled * 1000);
					banEndTime.text = Lang.textTill + " " + DateUtils.getComfortDateRepresentation(date, false);
					banEndTime.width = banEndTime.textWidth + 4;
					banEndTime.x = width - banEndTime.width - rightPadding;
				}
				else {
					banEndTime.text = "";
					banStatus.text = "";
				}
				
				if (banActive == true && itemData.payer != null && itemData.payer.getDisplayName() != null)
				{
					payerTitle.visible = true;
					payerAvatar.visible = true;
					payerName.visible = true;
					payerName.text = itemData.payer.getDisplayName();
					payerName.width = payerName.textWidth + 4;
					payerAvatar.setData(itemData.payer, payerAvatarSize, false);
					payerAvatar.y = int(payerTitle.y + payerTitle.height*.5 - payerAvatarSize);
				}
				
				if (!isNaN(PaidBan.getBanCost(itemData, ShopServerTask.BUY_BAN))) {

					var cur2:String=PaidBan.getCurrency(ShopServerTask.BUY_PROTECTION);
					if(cur2.toLowerCase()=="dco")
						cur2="DUK+";

					banCost.text = PaidBan.getBanCost(itemData, ShopServerTask.BUY_BAN) + " " + cur2;
					if (banActive == true) {
						banCost.setTextFormat(banCosttextFormat);
					}
					else {
						banCost.setTextFormat(banCostUnactivetextFormat);
					}
					banCost.width = banCost.textWidth + 4;
					banCost.x = width - banCost.width - rightPadding;
				}
				else {
					banCost.text = "";
				}
				
				banReason.width = userName.width = getTitleWidth();
				TextUtils.truncate(banReason);
			}
			
			if (highlight == true)
				bg.visible = false;
			bgHighlight.visible = highlight;
			
			return this;
		}
		
		protected function getTitleWidth():int {
			var titleWidth:Number = width - userName.x - Config.MARGIN;
			return titleWidth;
		}
		
		protected function checkOnlineStatus(uid:String):void {
			var onlineStatus:OnlineStatus = UsersManager.isOnline(uid);
			if (onlineStatus != null)
				showOnlineMark(onlineStatus.online, onlineStatus.status);
		}
		
		public function dispose():void {
			reasontextFormat = null;
			userNameTextFormat = null;
			banStatusTextFormat = null;
			banStatusInactiveTextFormat = null;
			banCostUnactivetextFormat = null;
			banCosttextFormat = null;
			banEndTimetextFormat = null;
			payerNametextFormat = null;
			payerTitletextFormat = null;
			labelButtontextFormat = null;
			
			if (placeholderClip != null) {
				UI.destroy(placeholderClip);
				placeholderClip = null;
			}
			if (avatarPlaceholder != null) {
				UI.destroy(avatarPlaceholder);
				avatarPlaceholder = null;
			}
			if (banStatus != null)
				banStatus.text = "";
			banStatus = null;
			if (banCost != null)
				banCost.text = "";
			banCost = null;
			if (banEndTime != null)
				banEndTime.text = "";
			banEndTime = null;
			graphics.clear();
			if (userName != null)
				userName.text = "";
			userName = null;
			if (banReason != null)
				banReason.text = "";
			banReason = null;
			if (avatar != null)
				avatar.graphics.clear();
			UI.destroy(avatar);
			UI.destroy(bgHighlight);
			avatar = null;
			if (avatarEmpty != null)
				avatarEmpty.graphics.clear();
			UI.destroy(avatarEmpty);
			avatarEmpty = null;
			if (bg != null)
				bg.graphics.clear();
			UI.destroy(bg);
			bg = null;
			if (avatarSupport) {
				UI.destroy(avatarSupport);
				avatarSupport = null;
			}
			if (avatarLettertext) {
				avatarLettertext.text = "";
				avatarLettertext = null;
			}
			if (avatarWithLetter) {
				UI.destroy(avatarWithLetter);
				avatarWithLetter = null;
			}
			if (jailIcon != null) {
				UI.destroy(jailIcon);
				jailIcon = null;
			}
			if (toadIcon != null) {
				UI.destroy(toadIcon);
				toadIcon = null;
			}
			if (ratingIcon != null) {
				UI.destroy(ratingIcon);
				ratingIcon = null;
			}
			if (missDCIcon != null) {
				UI.destroy(missDCIcon);
				missDCIcon = null;
			}
			if (onlineMark != null)
				onlineMark.graphics.clear();
			UI.destroy(onlineMark);
			onlineMark = null;
			if (parent) {
				parent.removeChild(this);
			}
			if (emptyAvatarBD) {
				emptyAvatarBD.dispose();
				emptyAvatarBD = null;
			}
			if (placeholderAvatarBD) {
				placeholderAvatarBD.dispose();
				placeholderAvatarBD = null;
			}
			if (payerTitle != null) {
				UI.destroy(payerTitle);
				payerTitle = null;
			}
			if (payerName != null) {
				UI.destroy(payerName);
				payerName = null;
			}
			if (payerAvatar != null) {
				payerAvatar.dispose();
				payerAvatar = null;
			}
		}
		
		/* INTERFACE com.dukascopy.connect.gui.list.renderers.IListRenderer */
		public function get isTransparent():Boolean {
			return true;
		}
	}
}