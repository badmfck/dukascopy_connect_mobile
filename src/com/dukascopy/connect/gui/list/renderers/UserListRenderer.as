package com.dukascopy.connect.gui.list.renderers {
	
	import assets.LogoRectangle;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.customActions.OpenSupportChatAction;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.sys.usersManager.OnlineStatus;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.type.MainColors;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.connect.vo.DepartmentVO;
	import com.dukascopy.connect.vo.EntryPointVO;
	import com.dukascopy.connect.vo.users.UserVO;
	import com.dukascopy.connect.vo.users.adds.ChatUserVO;
	import com.dukascopy.connect.vo.users.adds.ContactVO;
	import com.dukascopy.connect.vo.users.adds.MemberVO;
	import com.dukascopy.connect.vo.users.adds.PhonebookUserVO;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.display.IBitmapDrawable;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.geom.ColorTransform;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Dictionary;

	/**
	 * ...
	 * @author IgorBloom
	 */
	
	public class UserListRenderer extends BaseRenderer implements IListRenderer {
		
		private var avatarSupport:Bitmap;
		private var avatarWithLetter:Sprite;
		private var avatarLettertext:TextField;
		private var emptyAvatarBD:ImageBitmapData;
		private var permanentBanMark:Bitmap;
		private var banMark:Bitmap;
		private var line:Sprite;
		private var extensions:Dictionary;
	//	private var avatarSupportBD:ImageBitmapData;
		public var customBitmaps:Array;
		
		protected var avatarSize:int;
		protected var format1:TextFormat = new TextFormat();
		protected var format2:TextFormat = new TextFormat();
		
		protected var nme:TextField;
		protected var fxnme:TextField;
		protected var avatar:Shape;
		protected var avatarEmpty:Shape;
		protected var missDCIcon:Sprite;
		protected var ratingIcon:MovieClip;
		protected var toadIcon:Sprite;
		protected var jailIcon:Sprite;
		protected var bg:Shape;
		protected var bgHighlight:Shape;
		private var bgBank:Sprite;
		
		protected var fxnmeY:int;
		
		protected var onlineMark:Sprite;
		
		public function UserListRenderer() {
			create();
		}
		
		protected function create():void {
			initTextFormats();
				bg = new Shape();
				bg.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
				bg.graphics.drawRect(0, 0, 10, 10);
				bg.graphics.endFill();
			addChild(bg);
			bgBank = new Sprite();
			addChild(bgBank);
			line = new Sprite();
			addChild(line);
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
			
		//	avatarSupport = UI.renderAsset(new LogoRectangle(), avatarSize * 2, avatarSize * 2);
			
			avatarSupport = new Bitmap();
			avatarSupport.bitmapData = UI.drawAssetToRoundRect(new LogoRectangle(), avatarSize * 2);
		//	avatarSupport.x = int(Config.MARGIN * 1.58);
			addChild(avatarSupport);
			
		//	avatarSupportBD = UI.renderAsset(new LogoRectangle(), avatarSize * 2, avatarSize * 2);
			
				avatar = new Shape();
				avatarWithLetter.x = avatar.x = avatarSupport.x = avatarEmpty.x;
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
				jailIcon.scaleX = jailIcon.scaleY = scale;
				jailIcon.x = avatar.x + avatarSize;
			addChild(jailIcon);
			
				nme = new TextField();
				nme.selectable = false;
				format1.size = Config.FINGER_SIZE * .3;
				nme.defaultTextFormat = format1;
				nme.text = "Pp";
				nme.height = nme.textHeight + 4;
				nme.text = "";
				nme.x = int(avatar.x + avatarSize * 2 + Config.MARGIN * 1.58);
				nme.wordWrap = false;
				nme.multiline = false;
			addChild(nme);
			
				fxnme = new TextField();
				format1.size = Config.FINGER_SIZE * .24;
				fxnme.defaultTextFormat = format1;
				fxnme.text = "Pp";
				fxnme.height = fxnme.textHeight + 4;
				fxnme.text = "";
				fxnme.x = nme.x;
				fxnmeY = Config.FINGER_SIZE * .55;
				fxnme.wordWrap = false;
				fxnme.multiline = false;
			addChild(fxnme);
			
			onlineMark = new Sprite();
				onlineMark.visible = false;
			addChild(onlineMark);
			
			customBitmaps = new Array();
		}
		
		protected function setHitZones(item:ListItem):void { }
		
		private function initTextFormats():void {
			format1.font = Config.defaultFontName;
			format2.font = Config.defaultFontName;
			
			format1.color = Style.color(Style.COLOR_TITLE);
			
			format2.size = Config.FINGER_SIZE * .28;
			format2.color = Style.color(Style.COLOR_SUBTITLE);
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
			if (getItemData(item.data) is PhonebookUserVO || 
				getItemData(item.data) is ContactVO ||
				getItemData(item.data) is EntryPointVO ||
				getItemData(item.data) is MemberVO ||
				getItemData(item.data) is UserVO ||
				getItemData(item.data) is IScreenAction)
					return Config.FINGER_SIZE * 1.35;
			if (getItemData(item.data) == null)
			{
				return 0;
			}
			return int(Config.FINGER_SIZE * .7);
		}
		
		public function getView(item:ListItem, height:int, width:int, highlight:Boolean = false):IBitmapDrawable {
			bg.width = width;
			bg.height = height;
			
			bgHighlight.width = width;
			bgHighlight.height = height;
			
			bg.visible = true;
			
			line.visible = false;
			onlineMark.visible = false;
			avatarSupport.visible = false;
			avatarWithLetter.visible = false;
			missDCIcon.visible = false;
			ratingIcon.visible = false;
			toadIcon.visible = false;
			jailIcon.visible = false;
			bgBank.visible = false;
			
			if (extensions != null)
			{
				for each (var extensionClip:Sprite in extensions) 
				{
					extensionClip.visible = false;
					if (contains(extensionClip))
					{
						setChildIndex(extensionClip, numChildren - 1);
					}
				}
			}
			
			if (permanentBanMark != null)
			{
				permanentBanMark.visible = false;
			}
			if (banMark != null)
			{
				banMark.visible = false;
			}
			
			var itemData:Object = getItemData(item.data);
			
			fxnme.x = nme.x;
			
			if (itemData is PhonebookUserVO || itemData is ContactVO || itemData is ChatUserVO || itemData is UserVO || itemData is IScreenAction)
			{
				avatar.visible = true;
				avatarEmpty.visible = true;
				nme.visible = true;
				fxnme.autoSize = TextFieldAutoSize.LEFT;
			}
			else if (itemData is EntryPointVO || itemData is MemberVO)
			{
				avatar.visible = true;
				avatarEmpty.visible = true;
				nme.visible = true;
				fxnme.visible = false;
			}
			else if(itemData is String)
			{
				fxnme.x = int(Config.MARGIN * 1.58);
				fxnme.visible = true;
				fxnme.width = width - Config.MARGIN * 1.58 * 2;
				fxnme.autoSize = TextFieldAutoSize.LEFT;
				fxnme.text = itemData as String;
				fxnme.setTextFormat(format2);
				fxnme.y = int((height - fxnme.height) * .5);
				avatar.visible = false;
				avatarEmpty.visible = false;
				nme.visible = false;
				line.visible = true;
				line.graphics.clear();
				line.graphics.lineStyle(UI.getLineThickness(), Style.color(Style.COLOR_SEPARATOR));
				line.graphics.moveTo(0, 0);
				line.graphics.lineTo(width, 0);
				line.y = height - 1;
				return this;
			}
			
			avatarEmpty.y = int((height - avatarSize*2)*.5);
			avatarWithLetter.y = avatar.y = avatarEmpty.y;
			avatarSupport.y = avatarEmpty.y;
			
			toadIcon.y = avatarEmpty.y + avatarSize;
			missDCIcon.y = avatarEmpty.y + avatarSize + Config.FINGER_SIZE*.015;
			ratingIcon.y = avatarEmpty.y + avatarSize;
			jailIcon.y = avatarEmpty.y + avatarSize;
			
			if (highlight == true)
				bg.visible = false;
			bgHighlight.visible = highlight;
			
			if (itemData != null && ("uid" in itemData && itemData.uid != "") || itemData is EntryPointVO || (itemData is ContactVO && (itemData as ContactVO).action != null))
				item.addImageFieldForLoading("avatarURL");
			
			avatar.visible = false;
			avatarEmpty.visible = false;
			
			var avatarImage:ImageBitmapData = item.getLoadedImage("avatarURL");
			var showBankBG:Boolean = false;
			if (itemData != null && itemData is ContactVO && 
				(itemData as ContactVO).action != null && 
				((itemData as ContactVO).action is OpenSupportChatAction) && 
				((itemData as ContactVO).action as OpenSupportChatAction).pid == Config.EP_VI_DEF) {
					avatarSupport.visible = true;
					avatar.visible = false;
					showBankBG = true;
			} else if (itemData != null && itemData is OpenSupportChatAction && 
				(itemData as OpenSupportChatAction).pid == Config.EP_VI_DEF) {
				avatarSupport.visible = true;
				avatar.visible = false;
				showBankBG = true;
			} else if (avatarImage != null && avatarImage.isDisposed == false) {
				avatar.visible = true;
				avatar.graphics.clear();
				ImageManager.drawGraphicCircleImage(avatar.graphics, avatarSize, avatarSize, avatarSize, avatarImage, ImageManager.SCALE_PORPORTIONAL);
			} else {
				if (itemData != null && itemData is EntryPointVO) {
					avatarSupport.visible = true;
				} else {
					var actionIcon:Sprite;
					var bitmapName:String;
					var customBD:ImageBitmapData;
					if (itemData != null && itemData is IScreenAction && (itemData as IScreenAction).getIconClass() != null) {
						actionIcon = new ((itemData as IScreenAction).getIconClass())();
						if (isNaN(itemData.getIconColor()) == false) {
							var ct:ColorTransform = new ColorTransform();
							ct.color = itemData.getIconColor();
							actionIcon.transform.colorTransform = ct;
						}
						avatar.visible = true;
						bitmapName = "UserListRenderer." + (itemData as IScreenAction).getIconClass().toString();
						if (customBitmaps[bitmapName]) {
							customBD = customBitmaps[bitmapName];
						} else {
							if (actionIcon) {
								UI.scaleToFit(actionIcon, avatarSize * 2, avatarSize * 2);
							}
							customBD = UI.getSnapshot(actionIcon, StageQuality.HIGH, bitmapName);
							customBitmaps[bitmapName] = customBD;
						}
						ImageManager.drawGraphicCircleImage(avatar.graphics, avatarSize, avatarSize, avatarSize, customBD, ImageManager.SCALE_PORPORTIONAL);
						customBD = null;
					}
					else if (itemData != null && ("action" in itemData) && itemData.action != null && (itemData.action as IScreenAction).getIconClass() != null) {
						actionIcon = new ((itemData.action as IScreenAction).getIconClass())();
						avatar.visible = true;
						
						bitmapName = "UserListRenderer." + (itemData.action as IScreenAction).getIconClass().toString();
						if (customBitmaps[bitmapName]) {
							customBD = customBitmaps[bitmapName];
						} else {
							if (actionIcon) {
								UI.scaleToFit(actionIcon, avatarSize*2, avatarSize*2);
							}
							customBD = UI.getSnapshot(actionIcon, StageQuality.HIGH, bitmapName);
							customBitmaps[bitmapName] = customBD;
						}
						ImageManager.drawGraphicCircleImage(avatar.graphics, avatarSize, avatarSize, avatarSize, customBD, ImageManager.SCALE_PORPORTIONAL);
						customBD = null;
					} else if (itemData != null && "name" in itemData && itemData.name != null && String(itemData.name).length > 0 && AppTheme.isLetterSupported(String(itemData.name).charAt(0))) {
						avatarLettertext.text = String(itemData.name).charAt(0).toUpperCase();
						
						//avatarWithLetter.graphics.clear();
						//avatarWithLetter.graphics.beginFill(AppTheme.getColorFromPallete(String(itemData.name)));
						//avatarWithLetter.graphics.drawCircle(avatarSize, avatarSize, avatarSize);
						//avatarWithLetter.graphics.endFill();
						UI.drawElipseSquare(avatarWithLetter.graphics, avatarSize*2,avatarSize,AppTheme.getColorFromPallete(String(itemData.name)));
						avatarWithLetter.visible = true;
						avatarEmpty.visible = false;
					} else {
						avatarEmpty.visible = true;
					}
				}
			}
			
			if (showBankBG == true)
			{
				bgBank.graphics.clear();
				
				bgBank.graphics.beginFill(Style.color(Style.COLOR_LIST_SPECIAL));
				bgBank.graphics.drawRect(0, 0, width, height)
				bgBank.graphics.endFill();
				
				bgBank.graphics.beginFill(0x5DC269);
				bgBank.graphics.drawRect(0, 0, int(Config.FINGER_SIZE * .1), height);
				bgBank.graphics.endFill();
				bgBank.visible = true;
			}
			
			if (itemData != null && itemData is IScreenAction) {
				nme.visible = true;
				if (itemData.getData() != null)
				{
					nme.text = itemData.getData() as String;
				}
			} else {
				if (itemData != null && itemData is ChatUserVO && (itemData as ChatUserVO).secretMode == true) {
					nme.text = Lang.textIncognito;
				}
				else {
					if (itemData != null && itemData is UserVO && (itemData as UserVO).getDisplayName() != null) {
						nme.text = (itemData as UserVO).getDisplayName();
					} 
					else if(itemData != null && (itemData is String)==false && "name" in itemData && itemData.name != null) {
						nme.text = itemData.name;
					}
					else{
						nme.text = "";
					}
				}
			}
			if (item.data != null && item.data is ChatUserVO && (item.data as ChatUserVO).secretMode)
			{
				nme.text = Lang.textIncognito;
			}
			nme.y = int((height - nme.height)*.5);
			
			fxnme.visible = false;
			if (itemData != null && itemData is PhonebookUserVO) {
				if ((itemData as PhonebookUserVO).uid) {
					checkOnlineStatus((itemData as PhonebookUserVO).uid);
				}
				//!TODO: old code. is it possible to have fxID in PhonebookUserVO?
				if (itemData.fxID != 0) {
					fxnme.visible = true;
					fxnme.textColor = MainColors.RED;
					fxnme.text = itemData.fxName;
					nme.y = int((height - (nme.height + fxnme.height)) * .5);
					fxnme.y = int(nme.y + nme.height);
				}
			} else if (itemData != null && itemData is MemberVO) {
				if ((itemData as MemberVO).userUID) {
					checkOnlineStatus((itemData as MemberVO).userUID);
				}
				if (itemData != null && itemData.name != itemData.fxName){
					fxnme.visible = true;
					fxnme.textColor = MainColors.RED;
					var depVO:DepartmentVO=itemData.getDepartment();
					fxnme.text = (((depVO != null)?depVO.short + ", ":"") + itemData.city).toUpperCase();
					nme.y = int((height - (nme.height + fxnme.height)) * .5);
					fxnme.y = int(nme.y + nme.height);
				}	
			}
			else if (itemData != null && itemData is ContactVO ) {
				if ((itemData as ContactVO).uid != null) {
					checkOnlineStatus((itemData as ContactVO).uid);
				}
				if (itemData.name != itemData.fxName && itemData.fxName != null){
					fxnme.visible = true;
					fxnme.textColor = MainColors.RED;
					fxnme.text = itemData.fxName;
					nme.y = int((height - (nme.height + fxnme.height)) * .5);
					fxnme.y = int(nme.y + nme.height);
				}
			} else if (itemData != null && itemData is EntryPointVO) {
				nme.y = int((height - (nme.height)) * .5);
			}
			
			if(itemData != null && "uid" in itemData && itemData.uid != null && itemData.uid != "" && itemData.uid != "0") {
				nme.textColor = Style.color(Style.COLOR_TITLE);
			} else {
				if (itemData != null && itemData is EntryPointVO) {
					nme.textColor = Style.color(Style.COLOR_TITLE);
				} else {
					nme.textColor = Style.color(Style.COLOR_SUBTITLE);
				}
			}
			
			var userVO:UserVO;
			if (itemData != null && itemData is UserVO)
			{
				userVO = itemData as UserVO;
			}
			else if (itemData != null && "userVO" in itemData == true && itemData.userVO != null)
			{
				userVO = itemData.userVO as UserVO;
			}
			
			if (userVO) {
				if (UsersManager.checkForToad(userVO.uid) == true)
				{
					toadIcon.visible = true;
					if (contains(toadIcon))
					{
						setChildIndex(toadIcon, numChildren - 1);
					}
				}
				else if (userVO.missDC == true)
					missDCIcon.visible = true;
				if (userVO.payRating != 0) {
					ratingIcon.visible = true;
					ratingIcon.gotoAndStop(userVO.payRating);
				}
				if (userVO.ban911VO != null && userVO.ban911VO.status != "buyout") {
					jailIcon.visible = true;
					if (contains(jailIcon))
					{
						setChildIndex(jailIcon, numChildren - 1);
					}
				}
			}
			
			checkForUserBan(itemData);
			checkExtensions(itemData);
			
			nme.autoSize = TextFieldAutoSize.NONE;
			fxnme.width = nme.width = getTitleWidth();
			TextUtils.truncate(nme);
			
			setHitZones(item);
			
			return this;
		}
		
		private function checkExtensions(itemData:Object):void 
		{
			if (itemData != null)
			{
				var userVO:UserVO;
				if (itemData is ContactVO && (itemData as ContactVO).userVO != null)
				{
					userVO = (itemData as ContactVO).userVO;
				}
				else if (itemData is UserVO)
				{
					userVO = itemData as UserVO
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
		
		protected function getTitleWidth():int {
			var titleWidth:Number = width - nme.x - Config.MARGIN;
			return titleWidth;
		}
		
		protected function getItemData(itemData:Object):Object {
			if (itemData is ChatUserVO)
			{
				return (itemData as ChatUserVO).userVO;
			}
			
			return itemData;
		}
		
		protected function checkOnlineStatus(uid:String):void {
			var onlineStatus:OnlineStatus = UsersManager.isOnline(uid);
			if (onlineStatus != null)
				showOnlineMark(onlineStatus.online, onlineStatus.status);
		}
		
		public function dispose():void {
			format1 = null;
			format2 = null;
			graphics.clear();
			if (nme != null)
				nme.text = "";
			nme = null;
			if (fxnme != null)
				fxnme.text = "";
			fxnme = null;
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
			/*if (avatarSupportBD != null)
				avatarSupportBD.dispose();
			avatarSupportBD = null;*/
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
			if (bgBank != null) {
				UI.destroy(bgBank);
				bgBank = null;
			}
			if (customBitmaps) {
				for each(var bd:ImageBitmapData in customBitmaps) {
					bd.dispose();
				}
				customBitmaps = null;
			}
			
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