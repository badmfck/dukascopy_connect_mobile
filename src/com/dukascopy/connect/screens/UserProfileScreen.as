package com.dukascopy.connect.screens {
	
	import assets.ButtonCallContent;
	import assets.ButtonChatContent;
	import assets.ButtonInviteContent;
	import assets.ButtonPayContent;
	import assets.ButtonPayInactiveContent;
	import assets.DesktopOnlineButton;
	import assets.IconArrowRight;
	import assets.IconOnlineStatusWeb;
	import assets.JailedIllustrationClip;
	import assets.MobileOnlineButton;
	import assets.PhotoShotIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.GiftData;
	import com.dukascopy.connect.data.PopupData;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.lightbox.LightBox;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.renderers.ListQuestionType;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.preloader.Preloader;
	import com.dukascopy.connect.gui.scrollPanel.ScrollPanel;
	import com.dukascopy.connect.gui.topBar.TopBarProfile;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.dialogs.gifts.FlowerSticker;
	import com.dukascopy.connect.screens.dialogs.paidBan.PaidBanSticker;
	import com.dukascopy.connect.screens.serviceScreen.BottomPopupScreen;
	import com.dukascopy.connect.sys.Gifts;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.callManager.CallManager;
	import com.dukascopy.connect.sys.connectionManager.NetworkManager;
	import com.dukascopy.connect.sys.contentProvider.FXImagesListContentProvider;
	import com.dukascopy.connect.sys.contentProvider.IContentProvider;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.phonebookManager.PhonebookManager;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.socialManager.SocialManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.sys.usersManager.OnlineStatus;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.sys.usersManager.extensions.Extension;
	import com.dukascopy.connect.sys.usersManager.extensions.UserExtensionsManager;
	import com.dukascopy.connect.sys.usersManager.paidBan.PaidBan;
	import com.dukascopy.connect.sys.ws.WS;
	import com.dukascopy.connect.type.ChatInitType;
	import com.dukascopy.connect.type.GiftType;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.type.MainColors;
	import com.dukascopy.connect.type.UserBlockStatusType;
	import com.dukascopy.connect.vo.screen.ChatScreenData;
	import com.dukascopy.connect.vo.users.UserVO;
	import com.dukascopy.connect.vo.users.adds.PhonebookUserVO;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class UserProfileScreen extends BaseScreen {
		
		private var statusIconsSize:int = Config.FINGER_SIZE * .25;
		private var circleButtonsSize:int = Config.FINGER_SIZE * 1.1;
		private var iconSize:int = Config.FINGER_SIZE * 0.36;
		private var iconArrowSize:int = Config.FINGER_SIZE * 0.30;
		private var buttonPaddingLeft:int = Config.MARGIN * 3;
		private var optionLineHeight:int = Config.FINGER_SIZE * .8;
		private var fitWidth:int;
		
		private var avatarExists:Boolean = false;
		private var avatarSize:int;
		private var avatarBMD:ImageBitmapData;
		//  VIEW  //
		private var topBar:TopBarProfile;
		private var scrollPanel:ScrollPanel;
			private var first:Shape;
			private var avatar:Sprite;
				private var crown:Sprite;
				private var avatarShape:Shape;
				private var avatarPreloader:Preloader;
				private var payRating:MovieClip;
				private var toad:Sprite;
				private var jail:Sprite;
				private var extensions:Vector.<Bitmap>;
				private var atack:MovieClip;
			private var photos:Sprite;
				private var photosIcon:PhotoShotIcon;
				private var photosTF:TextField;
			private var phoneTF:TextField;
			private var status:Sprite;
				private var iconNetworkW:Sprite;
				private var iconNetworkD:Sprite;
				private var iconNetworkM:Sprite;
				private var iconFXComm:Sprite;
				private var fxName:TextField;
			private var banSticker:PaidBanSticker;
			private var floweSticker:FlowerSticker;
			private var mainActions:Sprite;
		//  MAIN ACTIONS  //
		private var actionChat:Object =                { icon:ButtonChatContent, callback:onChatButtonTap };
		private var actionCall:Object =                { icon:ButtonCallContent, callback:onCallButtonTap };
		private var actionPay:Object =                 { icon:ButtonPayContent, callback:onPayButtonTap };
		private var actionPayInactive:Object =         { icon:ButtonPayInactiveContent, callback:onPayButtonTap };
		private var actionInvite:Object =              { icon:ButtonInviteContent, callback:onInviteButtonTap };
		//  OTHER ACTIONS  //
		private var actionQuestionsStat:Object =       { iconL:Style.icon(Style.ICON_STAT), title:Lang.text911statistic, callback:onQuestionsStatButtonTap, iconR:IconArrowRight };
		private var actionFXCommunity:Object =         { iconL:Style.icon(Style.ICON_COMMUNITY), title:Lang.communityProfile, callback:onCommunityButtonTap, iconR:IconArrowRight };
		private var actionBlockUser:Object =           { iconL:Style.icon(Style.ICON_BLOCK_USER), title:"", callback:onBlockButtonTap };
		private var actionBanUserPaid:Object =         { iconL:Style.icon(Style.ICON_JAIL), title:Lang.putInJail, callback:onBanPaidButtonTap };
		private var actionUnbanUserPaid:Object =       { iconL:Style.icon(Style.ICON_JAIL), title:Lang.getOutOfJail, callback:onUnbanPaidButtonTap };
		private var btnShowProtectionObject:Object =   { iconL:Style.icon(Style.ICON_PROTECTION), title:Lang.banProtection, callback:onShowProtectionButtonTap};
		
		private var actionSendFlower:Object =          { iconL:Style.icon(Style.ICON_FLOWER), title:Lang.sendFlower, callback:onFlowerButtonTap };
		
		//  ACTIONS ONLY FOR ADMIN  //
		private var actionBanUser:Object =             { iconL:Style.icon(Style.ICON_BAN), title:Lang.textBanUser, callback:onBanButtonTap, red:true };
		private var actionBanForeverUser:Object =      { iconL:Style.icon(Style.ICON_BAN_FOREVER), title:Lang.textBanForeverUser, callback:onBanForeverButtonTap, red:true };
		private var actionZeroRating:Object =          { iconL:Style.icon(Style.ICON_ZERO_RATING), title:Lang.textZeroRating, callback:onZeroRatingButtonTap, red:true };
		
		private var userVO:UserVO;
		
		private var fxPhotos:FXImagesListContentProvider;
		
		private var mainButtons:Array/*BitmapButton*/;
		private var otherButtons:Array/*BitmapButton*/;
		
		private var avatarsToDispose:Array/*ImageBitmapData*/;
		
		private var firstTime:Boolean = true;
		private var controlsPosition:int;
		private var banMark:Bitmap;
		private var permanentBanMark:Bitmap;
		private var scrollPanelAddSizeForAppleX:Sprite;
		
		static public const banReasons:Array = [
			{ label:"Link spam", desk:"link spam" },
			{ label:"Referal spam", desk:"Referal code spam" },
			{ label:"Scam", desk:"Scam" },
			{ label:"Fraud", desk:"Fraud" },
			{ label:"Corruption", desk:"Corruption" },
			{ label:"Bad lexic", desk:"Bad lexic" },
			{ label:"Avatar/Name incorrect", desk:"Avatar/Name incorrect" },
			{ label:"Other", desk:"You are banned, please contact support team for any questions." }
		];
		
		private var actions:Array = [
			{ id:"refreshBtn", img:Style.icon(Style.ICON_REFRESH), callback:onRefresh , imgColor:Style.color(Style.TOP_BAR_ICON_COLOR)}
		];
		
		//private var firstTimeUserVO:Boolean = true;
		
		public function UserProfileScreen() { }
		
		override protected function createView():void {
			super.createView();
			topBar = new TopBarProfile();
			_view.addChild(topBar);
			scrollPanel = new ScrollPanel();
			scrollPanel.background = true;
			scrollPanel.backgroundColor = Style.color(Style.COLOR_BACKGROUND);
				first = new Shape();
				first.graphics.beginFill(0, 0);
				first.graphics.drawRect(0, 0, 1, 1);
				first.graphics.endFill();
			scrollPanel.addObject(first);
				avatar = new Sprite();
			scrollPanel.addObject(avatar);
			avatarShape = new Shape();
			avatar.addChild(avatarShape);
			
			_view.addChildAt(scrollPanel.view, 0);
			
			if (Config.PLATFORM_APPLE == true)
			{
				scrollPanelAddSizeForAppleX = new Sprite();
				scrollPanelAddSizeForAppleX.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
				scrollPanelAddSizeForAppleX.graphics.drawRect(0, 0, 1, 1);
				scrollPanelAddSizeForAppleX.graphics.endFill();
				scrollPanel.addObject(scrollPanelAddSizeForAppleX);
			}
		}
		
		override protected function drawView():void {
			scrollPanel.setWidthAndHeight(_width, _height - scrollPanel.view.y);
		}
		
		private function onRefresh():void
		{
			topBar.showAnimationOverButton("refreshBtn", false);
			
		//	UsersManager.S_USERS_FULL_DATA.add(updateProfileScreen);
			
			UsersManager.update(userVO);
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			_params.title = "User profile screen";
			_params.doDisposeAfterClose = true;
			
			if (data.data is UserVO) {
				userVO = data.data;
			} else if ("userVO" in data.data) {
				userVO = data.data.userVO;
			}
			
			if (userVO.disposed == true) {
				MobileGui.S_BACK_PRESSED.invoke();
				return;
			}
			
			UsersManager.addToMain(userVO);
			
			fitWidth = _width - buttonPaddingLeft * 2;
			
			scrollPanel.view.y = topBar.trueHeight;
			scrollPanel.setWidthAndHeight(_width, _height - scrollPanel.view.y);
			avatarSize = Config.FINGER_SIZE * 1.6 * .5 * 1.5;
			avatar.x = int(_width * .5) /*-avatarSize*/;
			avatar.y = avatarSize + Config.FINGER_SIZE * .35;
			if (Auth.blocked != null && Auth.blocked.indexOf(userVO.uid) != -1)
				actionBlockUser.title = Lang.unblockUser;
			else
				actionBlockUser.title = Lang.blockUser;
			topBar.setStatusUserUID(userVO.uid);
			var displayName:String = userVO.getDisplayName();
			topBar.setData(displayName, true, actions);
			topBar.drawView(_width);
			update(avatar.y + avatarSize + Config.DOUBLE_MARGIN * 2);
			
			var avatarURL:String = userVO.getAvatarURL();
			onAvatarLoaded(null, ImageManager.getImageFromCache(avatarURL), true);
			if (avatarExists == false)
				onAvatarLoaded(null, getEmptyAvatar(), true);
			
			UsersManager.S_USERS_FULL_DATA.add(updateProfileScreen);
			UsersManager.S_USER_FULL_DATA.remove(onProfileUpdate);
			LightBox.S_LIGHTBOX_OPENED.add(onLightboxOpen);
			LightBox.S_LIGHTBOX_CLOSED.add(onLightboxClose);
			
			if (PaidBan.isAvaliable() == true) {
				PaidBan.S_USER_BAN_UPDATED.add(onPaidBanChanged);
			}
			
			if (userVO.ban911VO != null)
				PaidBan.checkBanStatus(userVO.ban911VO);
			if (userVO.ban911VO != null) {
				PaidBan.getBanFullData(userVO.ban911VO.id);
			}
			
			if (userVO.sysBan == true)
			{
				permanentBanMark = UI.createBannedMark(avatarSize, Lang.permanentBaned);
				avatar.addChild(permanentBanMark);
				permanentBanMark.x = -int(permanentBanMark.width * .5);
				permanentBanMark.y = -int(permanentBanMark.height * .5);
			}
			else if (userVO.ban911 == true)
			{
				banMark = UI.createBannedMark(avatarSize, Lang.banned);
				avatar.addChild(banMark);
				banMark.x = -int(banMark.width * .5);
				banMark.y = -int(banMark.height * .5);
			}
			
			UserExtensionsManager.S_USER_UPDATE.add(onExtensionsUpdate);
		}
		
		private function onExtensionsUpdate(userUID:String):void 
		{
			if(userVO != null && userVO.uid == userUID)
			{
				updatePositions();
			}
		}
		
		private function update(componentY:int = -1):void {
			var phone:String = userVO.phone;
			if (phone != null && phone.length > 0) {
				if (phoneTF == null) {
					phoneTF = createNewTF();
					scrollPanel.addObject(phoneTF);
				}
				phoneTF.defaultTextFormat = new TextFormat(Config.defaultFontName, Config.FINGER_SIZE_DOT_5, MainColors.DARK_BLUE);
				phoneTF.text = "+" + phone;
				phoneTF.width = _width - Config.DOUBLE_MARGIN;
				phoneTF.height = phoneTF.textHeight + 4;
				phoneTF.width = phoneTF.textWidth + 4;
				phoneTF.x = int((_width - phoneTF.width) * .5);
				phoneTF.y = componentY;
				componentY += phoneTF.height + Config.MARGIN;
			}
			if (userVO.uid != null && userVO.uid.length > 0) {
				if (status == null) {
					status = new Sprite();
					scrollPanel.addObject(status);
				}
				status.y = componentY;
				updateUserStatus();
			}
			
			var gender:String = "";
			
			if (Auth.myProfile != null){
				if (userVO != null && userVO.gender != null && userVO.gender != ""){
					if (userVO.gender == "male"){
						gender = " ♂ ";
					}
					else if (userVO.gender == "female"){
						gender = " ♀ ";
					}
				}
			}
			if (status != null) {
				if (fxName == null) {
					fxName = createNewTF();
					status.addChild(fxName);
				}
				fxName.defaultTextFormat = new TextFormat(Config.defaultFontName, statusIconsSize, Color.RED);
				var fxid:int = userVO.fxID;
				if (fxid != 0) {
					fxName.text = userVO.login;
					fxName.width = fxName.textWidth + 4;
					fxName.height = fxName.textHeight + 4;
					if (iconFXComm == null) {
						iconFXComm = new IconLogoCircle();
						iconFXComm.height = int(statusIconsSize);
						iconFXComm.width = iconFXComm.width * iconFXComm.scaleY;
						status.addChild(iconFXComm);
					}
					iconFXComm.y = int((status.height - iconFXComm.height) * .5);
					if (fxPhotos == null) {
						fxPhotos = new FXImagesListContentProvider();
						fxPhotos.setData(userVO);
						fxPhotos.S_COMPLETE.add(onFxPhotosLoaded);
						fxPhotos.S_ERROR.add(onFxPhotosLoadError);
						fxPhotos.execute();
					}
				} else {
					fxName.text = "user " + userVO.md5sum;
					fxName.width = fxName.textWidth + 4;
					fxName.height = fxName.textHeight + 4;
				}
				if (Config.ADMIN_UIDS.indexOf(Auth.uid) != -1) {
					if (fxName.text != "")
						fxName.text += "\n";
					fxName.text += userVO.uid;
					fxName.height = fxName.textHeight + 4;
					fxName.width = fxName.textWidth + 4;
				}
				
				if (gender != "")
				{
					fxName.text += " " + gender;
					fxName.height = fxName.textHeight + 4;
					fxName.width = fxName.textWidth + 4;
				}
			}
			
			repositionsStatusElements();
			
			if (status != null)
				componentY += status.height + Config.FINGER_SIZE * 0.6;
			
			controlsPosition = componentY;
			
			componentY = drawPaidBanClip(componentY);
			componentY = drawFlowerClip(componentY);
			
			createMainActions(componentY);
			if (mainActions != null)
				componentY += mainActions.height + Config.DOUBLE_MARGIN * 2;
			createOtherActions(componentY);
			scrollPanel.updateObjects();
			setAtacksAndToad();
		}
		
		private function onShowProtectionButtonTap():void {
			PaidBan.showProtection(userVO);
		}
		
		private function updateProfileScreen():void {
			if (_isDisposed == true)
				return;
			if (userVO.setted == true) {
			//	UsersManager.S_USERS_FULL_DATA.remove(updateProfileScreen);
				update(avatar.y + avatarSize + Config.DOUBLE_MARGIN * 2);
				onPaidBanChanged(userVO.uid);
				
				if (userVO.sysBan == true)
				{
					if (permanentBanMark == null)
					{
						permanentBanMark = UI.createBannedMark(avatarSize, Lang.permanentBaned);
						avatar.addChild(permanentBanMark);
						permanentBanMark.x = -int(permanentBanMark.width * .5);
						permanentBanMark.y = -int(permanentBanMark.height * .5);
					}
				}
				else
				{
					if (permanentBanMark != null)
					{
						avatar.removeChild(permanentBanMark);
						UI.destroy(permanentBanMark);
						permanentBanMark = null;
					}
				}
				if (userVO.ban911 == true)
				{
					if (banMark == null)
					{
						banMark = UI.createBannedMark(avatarSize, Lang.banned);
						avatar.addChild(banMark);
						banMark.x = -int(banMark.width * .5);
						banMark.y = -int(banMark.height * .5);
					}
				}
				else
				{
					if (banMark != null)
					{
						avatar.removeChild(banMark);
						UI.destroy(banMark);
						banMark = null;
					}
				}
			}
			topBar.hideAnimation();
		}
		
		private function drawPaidBanClip(componentY:int):int {
			if (userVO.ban911VO != null) {
				if (userVO.ban911VO.fullData == false) {
					PaidBan.getBanFullData(userVO.ban911VO.id);
				}
				if (banSticker == null) {
					banSticker = new PaidBanSticker();
					if (isActivated == true) {
						banSticker.alpha = 0;
						TweenMax.to(banSticker, 0.3, {alpha:1});
					}
					scrollPanel.addObject(banSticker);
				}
				PointerManager.removeTap(banSticker, banStickerClicked);
				PointerManager.addTap(banSticker, banStickerClicked);
				
				banSticker.draw(userVO.ban911VO, _width - Config.DOUBLE_MARGIN * 4);
				componentY -= Config.DOUBLE_MARGIN;
				banSticker.y = componentY;
				componentY += banSticker.height + Config.DOUBLE_MARGIN;
				banSticker.x = Config.DOUBLE_MARGIN * 2;
			}
			else {
				if (banSticker != null) {
					PointerManager.removeTap(banSticker, banStickerClicked);
					TweenMax.killTweensOf(banSticker);
					banSticker.dispose();
					scrollPanel.removeObject(banSticker);
					banSticker = null;
				}
			}
			return componentY;
		}
		
		private function drawFlowerClip(componentY:int):int {
			if (userVO.gifts != null && userVO.gifts.items != null && userVO.gifts.items.length > 0) {
				if (floweSticker == null) {
					floweSticker = new FlowerSticker();
					scrollPanel.addObject(floweSticker);
				}
				PointerManager.removeTap(floweSticker, flowerStickerClicked);
				PointerManager.addTap(floweSticker, flowerStickerClicked);
				
				floweSticker.draw(userVO.gifts, _width);
				if (banSticker != null)
				{
					componentY -= Config.MARGIN;
				}
				else{
					componentY -= Config.MARGIN * 2.5;
				}
				
				floweSticker.y = componentY;
				componentY += Config.FINGER_SIZE * 1.3 + Config.DOUBLE_MARGIN;
				floweSticker.x = _width * .5 - floweSticker.width * .5;
			}
			else {
				if (floweSticker != null) {
					PointerManager.removeTap(floweSticker, flowerStickerClicked);
					floweSticker.dispose();
					scrollPanel.removeObject(floweSticker);
					floweSticker = null;
				}
			}
			return componentY;
		}
		
		private function flowerStickerClicked(e:Event = null):void 
		{
			if (userVO.gifts != null)
			{
				var extension:Extension;
				if (userVO.gifts.items != null && userVO.gifts.items.length > 0)
				{
					extension = userVO.gifts.items[userVO.gifts.items.length - 1];
					if (extension.incognito == false)
					{
						var user:UserVO = UsersManager.getUserByUID(extension.payer_uid);
						if (user != null && user.uid != Auth.uid)
						{
							MobileGui.changeMainScreen(UserProfileScreen, {data: user, 
																		backScreen:MobileGui.centerScreen.currentScreenClass, 
																		backScreenData:MobileGui.centerScreen.currentScreen.data});
						}
					}
				}
			}
		}
		
		private function banStickerClicked(e:Event = null):void 
		{
			if (userVO.ban911VO != null && userVO.ban911VO.incognito == false && userVO.ban911VO.payer_uid != null && userVO.ban911VO.payer_uid != Auth.uid)
			{
				var user:UserVO = UsersManager.getFullUserData(userVO.ban911VO.payer_uid);
				if (user != null)
				{
					MobileGui.changeMainScreen(UserProfileScreen, {data: user, 
																backScreen:MobileGui.centerScreen.currentScreenClass, 
																backScreenData:MobileGui.centerScreen.currentScreen.data});
				}
			}
		}
		
		private function onPaidBanChanged(userUID:String):void {
			if (isDisposed)
				return;
			
			if (userVO.uid == userUID) {
				
				updatePositions();
			}
			setAtacksAndToad();
		}
		
		private function updatePositions():void 
		{
			var position:int = drawPaidBanClip(controlsPosition);
			position = drawFlowerClip(position);
			if (mainActions != null) {
				mainActions.y = position;
				position += mainActions.height + Config.DOUBLE_MARGIN * 2;
			}
			
			if (otherButtons != null) {
				var button:BitmapButton;
				while (otherButtons.length != 0) {
					button = otherButtons.shift()
					scrollPanel.removeObject(button);
					button.dispose();
				}
				otherButtons = null;
			}
			
			createOtherActions(position);
			
			if (otherButtons != null) {
				var l:int = otherButtons.length;
				for (var i:int = 0; i < l; i++) {
					otherButtons[i].show();
					otherButtons[i].activate();
				}
			}
			
			scrollPanel.update();
			setAtacksAndToad();
		}
		
		private function setAtacksAndToad():void {
			var avatarIconExist:Boolean = false;
			if (UsersManager.checkForToad(userVO.uid) == true) {
				toad = addAttackIcon(toad, SWFFrog) as Sprite;
				avatarIconExist = true;
			} else
				removeAttackIcon(toad);
			if (userVO == null)
				return;
			if (userVO.payRating == -1 || userVO.payRating == 0) {
				removeAttackIcon(payRating);
			} else {
				payRating = addAttackIcon(payRating, SWFRatingStars_mc) as MovieClip;
				payRating.gotoAndStop(userVO.payRating);
			}
			if (userVO.missDC == false)
				removeAttackIcon(crown);
			else if (avatarIconExist == false)
				crown = addAttackIcon(crown, SWFCrownIcon, .4) as Sprite;
			if (userVO.ban911VO != null) {
				jail = addAttackIcon(jail, Style.icon(Style.ICON_JAILED), 1) as Sprite;
				
				if (isActivated == true) {
					jail.alpha = 0;
					TweenMax.to(jail, 0.3, {alpha:1});
				}
			}
			else if (jail != null) {
				TweenMax.killTweensOf(jail);
				removeAttackIcon(jail);
			}
			
			checkExtensions();
			
			if (photos != null) {
				avatar.setChildIndex(photos, avatar.numChildren - 1);
			}
		}
		
		private function checkExtensions():void 
		{
			if (isDisposed == true)
			{
				return;
			}
			var l:int;
			if (userVO != null && userVO.gifts != null && !userVO.gifts.empty())
			{
				if (extensions != null && avatar != null)
				{
					l = extensions.length;
					for (var i:int = 0; i < l; i++) 
					{
						try
						{
							avatar.removeChild(extensions[i]);
						}
						catch (e:Error)
						{
							
						}
						UI.destroy(extensions[i]);
					}
					extensions = null;
				}
				
				extensions = new Vector.<Bitmap>();
				l = userVO.gifts.length;
				var item:Bitmap;
				var sourceClass:Class;
				var source:Sprite;
				var itemSize:int = avatarSize * 1.05;
			//	for (var i:int = 0; i < l; i++) 
			//	{
					sourceClass = userVO.gifts.items[l - 1].getImage();
					if (sourceClass != null)
					{
						source = new sourceClass() as Sprite;
						UI.scaleToFit(source, itemSize, itemSize);
						
						item = new Bitmap();
						item.bitmapData = UI.getSnapshot(source, StageQuality.HIGH, "UserProfileScreen.extension");
						
						avatar.addChild(item);
						item.x = avatarSize * 1.3 - item.width;
						item.y = avatarSize * 1.2 - item.height;
						
						extensions.push(item);
					}
					//!TODO:;
			//		break;
			//	}
			}
			if (extensions != null)
			{
				l = extensions.length;
				for (var j:int = 0; j < l; j++) 
				{
					avatar.setChildIndex(extensions[j], avatar.numChildren - 1);
				}
			}
		}
		
		private function addAttackIcon(icon:Sprite, cls:Class, scale:Number = 1):DisplayObject {
			if (icon == null) {
				icon = new cls();
				icon.scaleX = icon.scaleY = avatarSize * 2 / 100 * scale;
				if (scale != 1)
					icon.y = -(avatarSize * (1 - scale));
				icon.mouseEnabled = false;
				icon.mouseChildren = false;
			}
			if (icon.parent == null)
				avatar.addChild(icon);
			return icon;
		}
		
		private function removeAttackIcon(icon:Sprite):void {
			if (icon != null) {
				if (icon.parent != null)
					icon.parent.removeChild(icon);
				icon = null;
			}
		}
		
		private function loadLargeAvatar():void {
			var avatarURL:String = userVO.getAvatarURLProfile(avatarSize * 2);
			if (avatarURL != userVO.getAvatarURL()) {
				showAvatarPreloader();
				ImageManager.loadImage(avatarURL, onAvatarLoaded);
			}
			avatarURL = null;
		}
		
		private function updateUserStatus():void {
			if (userVO.uid == null || userVO.uid.length == 0)
				return;
			UsersManager.S_ONLINE_CHANGED.add(onUserOnlineStatusChanged);
			onUserOnlineStatusChanged(UsersManager.isOnline(userVO.uid), null);
		}
		
		private function onUserOnlineStatusChanged(m:OnlineStatus, method:String):void {
			if (m == null)
				return;
			if (m.uid != userVO.uid)
				return;
			if (m.online == false) {
				if (iconNetworkD != null && iconNetworkD.parent != null)
					iconNetworkD.parent.removeChild(iconNetworkD);
				if (iconNetworkW != null && iconNetworkW.parent != null)
					iconNetworkW.parent.removeChild(iconNetworkW);
				if (iconNetworkM != null && iconNetworkM.parent != null)
					iconNetworkM.parent.removeChild(iconNetworkM);
				repositionsStatusElements();
				return;
			}
			if (m.desk > 0) {
				if (iconNetworkD == null) {
					iconNetworkD = new DesktopOnlineButton();
					iconNetworkD.height = statusIconsSize;
					iconNetworkD.width = iconNetworkD.width * iconNetworkD.scaleY;
				}
				if (iconNetworkD.parent == null)
					status.addChild(iconNetworkD);
			} else if (iconNetworkD != null && iconNetworkD.parent != null)
				iconNetworkD.parent.removeChild(iconNetworkD);
			if (m.mob > 0) {
				if (iconNetworkM == null) {
					iconNetworkM = new MobileOnlineButton();
					iconNetworkM.height = statusIconsSize;
					iconNetworkM.width = iconNetworkM.width * iconNetworkM.scaleY;
				}
				if (iconNetworkM.parent == null)
					status.addChild(iconNetworkM);
			} else if (iconNetworkM != null && iconNetworkM.parent != null)
				iconNetworkM.parent.removeChild(iconNetworkM);
			if (m.web > 0) {
				if (iconNetworkW == null) {
					iconNetworkW = new IconOnlineStatusWeb();
					iconNetworkW.height = statusIconsSize;
					iconNetworkW.width = iconNetworkW.width * iconNetworkW.scaleY;
				}
				if (iconNetworkW.parent == null)
					status.addChild(iconNetworkW);
			} else if (iconNetworkW != null && iconNetworkW.parent != null)
				iconNetworkW.parent.removeChild(iconNetworkW);
			repositionsStatusElements();
		}
		
		private function repositionsStatusElements():void {
			var xPos:int = 0;
			var iconsY:int = (iconFXComm != null) ? iconFXComm.y : 0;
			if (iconNetworkD != null && iconNetworkD.parent != null) {
				iconNetworkD.x = xPos;
				iconNetworkD.y = iconsY;
				xPos += iconNetworkD.width + Config.MARGIN;
			}
			if (iconNetworkW != null && iconNetworkW.parent != null) {
				iconNetworkW.x = xPos;
				iconNetworkW.y = iconsY;
				xPos += iconNetworkW.width + Config.MARGIN;
			}
			if (iconNetworkM != null && iconNetworkM.parent != null) {
				iconNetworkM.x = xPos;
				iconNetworkM.y = iconsY;
				xPos += iconNetworkM.width + Config.MARGIN;
			}
			if (iconFXComm != null && iconFXComm.parent != null) {
				iconFXComm.x = xPos;
				xPos += iconFXComm.width + Config.MARGIN;
			}
			if (fxName != null && fxName.parent != null) {
				fxName.x = xPos;
				fxName.y = statusIconsSize - fxName.getLineMetrics(0).ascent - 2;
				if (fxName.numLines > 1 && xPos == 0)
					fxName.setTextFormat(new TextFormat(Config.defaultFontName, statusIconsSize, MainColors.RED, null, null, null, null, null, TextFormatAlign.CENTER));
			}
			if (status != null)
				status.x = int((_width - status.width) * .5);
		}
		
		private function createMainActions(yPos:int):void {
			var actions:Array = [];
			if (userVO.uid == null || userVO.uid.length == 0) {
				actions.push(actionInvite);
				if (userVO.phone != null && userVO.phone.length != 0)
					actions.push(actionPay);
				createMainActionsButtons(actions, yPos);
				return;
			}
			actions.push(actionChat);
			if (userVO.type != UserVO.TYPE_BOT){
				actions.push(actionCall);
			}			
			if (userVO.phone != null && userVO.phone.length != 0)
				actions.push(actionPay);
			else
				actions.push(actionPayInactive);
			createMainActionsButtons(actions, yPos);
		}
		
		private function createMainActionsButtons(actions:Array, yPos:int):void {
			if (actions == null || actions.length == 0)
				return;
			if (mainActions == null) {
				mainButtons = [];
				mainActions = new Sprite();
				mainActions.y = yPos;
				scrollPanel.addObject(mainActions);
			}
			mainActions.y = yPos;
			var btnX:int = 0;
			var btn:BitmapButton;
			var cnt:Sprite;
			var l:int = actions.length;
			for (var i:int = 0; i < l; i++) {
				cnt = new actions[i].icon();
				cnt.height = circleButtonsSize;
				cnt.width = cnt.width * cnt.scaleY;
				btn = new BitmapButton();
				btn.setDownScale(1);
				btn.setDownColor(0x000000);
				btn.setBitmapData(UI.getSnapshot(cnt, StageQuality.HIGH, "UserProfileScreen.circleButton"), true);
				btn.tapCallback = actions[i].callback;
				btn.hide();
				btn.x = btnX;
				btnX += int(btn.width + Config.FINGER_SIZE * .5);
				mainActions.addChild(btn);
				mainButtons.push(btn);
			}
			mainActions.x = int((_width - mainActions.width) * .5);
		}
		
		private function createOtherActions(yPos:int):void {
			if (userVO.uid == null || userVO.uid.length == 0)
				return;
			var actions:Array = [];
			if (userVO.fxID != 0)
				actions.push(actionFXCommunity);
			if (SocialManager.available == true) {
				/*if (userVO.type != "bot")
					actions.push(actionQuestionsStat);*/
				actions.push(actionBlockUser);
				/*if (PaidBan.isAvaliable() == true) {
					if (userVO.paidPanProtection != null)
						PaidBan.checkProtectionStatus(userVO);
					if (userVO.paidPanProtection != null)
						actions.push(btnShowProtectionObject);
					else if (userVO.ban911VO != null) {
						PaidBan.checkBanStatus(userVO.ban911VO);
						if (userVO.ban911VO != null)
							actions.push(actionUnbanUserPaid);
						else
							actions.push(actionBanUserPaid);
					} else {
						actions.push(actionBanUserPaid);
					}
				}
				actions.push(actionSendFlower);*/
			} else
				actions.push(actionBlockUser);
			
			if (Config.ADMIN_UIDS.indexOf(Auth.uid) != -1) {
				actions.push(actionBanUser);
				actions.push(actionBanForeverUser);
				actions.push(actionZeroRating);
			}
			createOtherActionsButtons(actions, yPos);
		}
		
		private function createOtherActionsButtons(actions:Array, yPos:int):void {
			var btn:BitmapButton;
			if (otherButtons != null)
			{
				while (otherButtons.length != 0)
				{
					btn = otherButtons.shift()
					scrollPanel.removeObject(btn);
					btn.dispose();
				}
			}
			
			if (actions == null || actions.length == 0)
				return;
			otherButtons ||= [];
			var obj:Object;
			var iconL:DisplayObject;
			var iconR:DisplayObject;
			var l:int = actions.length;
			for (var i:int = 0; i < l; i++) {
				obj = actions[i];
				if (obj.iconL != undefined && obj.iconL != null) {
					iconL = new obj.iconL();
					if (obj.red == true)
						UI.colorize(iconL, MainColors.RED);
					else
						UI.colorize(iconL, Style.color(Style.COLOR_ICON_SETTINGS));
					UI.scaleToFit(iconL, iconSize, iconSize);
				}
				if (obj.iconR != undefined && obj.iconR != null) {
					iconR = new obj.iconR();
					if (obj.red == true)
						UI.colorize(iconR, MainColors.RED);
					else
						UI.colorize(iconR, Style.color(Style.ICON_RIGHT_COLOR));
					UI.scaleToFit(iconR, iconArrowSize, iconArrowSize);
				}
				btn = new BitmapButton();
				btn.usePreventOnDown = false;
				btn.setDownScale(1);
				btn.setDownColor(0x000000);
				btn.setOverlay(HitZoneType.MENU_MIDDLE_ELEMENT);
				var ibmd:ImageBitmapData = UI.renderSettingsTextAdvanced(
					obj.title,
					_width,
					optionLineHeight,
					false,
					TextFormatAlign.LEFT,
					TextFieldAutoSize.NONE,
					Config.FINGER_SIZE * 0.34,
					false,
					(obj.red == true) ? MainColors.RED : Style.color(Style.COLOR_TEXT),
					0,
					0,
					iconL,
					iconR
				);
				UI.destroy(iconL);
				UI.destroy(iconR);
				iconL = null;
				iconR = null;
				btn.setBitmapData(ibmd);
				btn.tapCallback = obj.callback;
				btn.x = 0;
				btn.y = yPos;
				btn.hide();
				scrollPanel.addObject(btn);
				obj.button = btn;
				otherButtons.push(btn);
				yPos += btn.height + Config.MARGIN;
			}
			
			if (scrollPanelAddSizeForAppleX != null)
			{
				scrollPanelAddSizeForAppleX.y = yPos + Config.APPLE_BOTTOM_OFFSET;
			}
		}
		
		private function getEmptyAvatar():ImageBitmapData {
			return UI.getEmptyAvatarBitmapData(avatarSize * 2, avatarSize * 2);
		}
		
		private function onAvatarLoaded(url:String, bmd:ImageBitmapData, success:Boolean):void {
			if (_isDisposed == true)
				return;
			if (success == false)
				return;
			if (avatarExists == true && avatarBMD == null)
				return;
			if (url != null) {
				var needToPush:Boolean = false;
				avatarsToDispose ||= [];
				var l:int = avatarsToDispose.length;
				for (var i:int = 0; i < l; i++)
					if (avatarsToDispose[i] == bmd)
						break;
				if (needToPush == true)
					avatarsToDispose.push(bmd);
			}
			if (avatarBMD == bmd)
				return;
			avatarBMD = bmd;
			if (avatarBMD == null)
				return;
			avatarShape.graphics.clear();
			ImageManager.drawGraphicCircleImage(avatarShape.graphics, 0 , 0, avatarSize, avatarBMD, ImageManager.SCALE_INNER_PROP);
			avatarShape.x = -avatarSize;
			avatarShape.y = -avatarSize;
			
			avatarExists = true;
			hideAvatarPreloader();
		}
		
		public function showAvatarPreloader():void {
			if (avatarPreloader == null)
				avatarPreloader = new Preloader();
			if (avatarPreloader.parent == null)
				avatar.addChild(avatarPreloader);
			avatarPreloader.show();
		}
		
		private function hideAvatarPreloader():void {
			if (avatarPreloader == null)
				return;
			if (avatarPreloader.parent == null)
				return;
			avatarPreloader.hide(true);
			avatarPreloader = null;
		}
		
		private function onFxPhotosLoaded():void {
			if (_isDisposed == true)
				return;
			if (fxPhotos == null)
				return;
			var images:Array = fxPhotos.getResult();
			if (images == null || images.length == 0)
				return;
			// CREATE ADDITIONAL PHOTOS COMPONENT
			var iconFit:int = Config.FINGER_SIZE * .3;
			var offset:int = Config.FINGER_SIZE * .1;
			var fontSize:int = Config.FINGER_SIZE * .2;
			var trueHeight:int = fontSize + offset * 2;
			photos = new Sprite();
				photosIcon = new PhotoShotIcon();
				UI.colorize(photosIcon, Style.color(Style.COLOR_ICON_SPECIAL));
				UI.scaleToFit(photosIcon, iconFit, iconFit);
				photosIcon.x = Config.MARGIN;
				photosIcon.y = int((trueHeight - photosIcon.height) * .45);
			photos.addChild(photosIcon);
				photosTF = createNewTF();
				photosTF.defaultTextFormat = new TextFormat(Config.defaultFontName, Config.FINGER_SIZE * .22, Style.color(Style.COLOR_ICON_SPECIAL));
				photosTF.text = "+" + images.length;
				photosTF.width = photosTF.textWidth + 4;
				photosTF.height = photosTF.textHeight + 4;
				photosTF.x = photosIcon.x + photosIcon.width + Config.MARGIN * .4;
				photosTF.y = int((trueHeight - photosTF.height) * .48);
			photos.addChild(photosTF);
			photos.graphics.beginFill(Style.color(Style.COLOR_TIP_BACKGROUND_SPECIAL));
			photos.graphics.drawRoundRect(0, 0, photosTF.x + photosTF.width + Config.MARGIN, trueHeight, trueHeight, trueHeight);
			photos.graphics.endFill();
			photos.x = -int(photos.width * .5);
			photos.y = int(avatarSize - photos.height * .5);
			photos.alpha = 0;
			avatar.addChild(photos);
			TweenMax.to(photos, .5, { alpha:1, delay:0.1 } );
			scrollPanel.updateObjects();
			clearFxPhotos();
		}
		
		private function onFxPhotosLoadError():void {
			clearFxPhotos();
		}
		
		private function clearFxPhotos():void {
			if (fxPhotos != null) {
				fxPhotos.S_COMPLETE.remove(onFxPhotosLoaded);
				fxPhotos.S_ERROR.remove(onFxPhotosLoadError);
				fxPhotos.dispose();
				fxPhotos = null;
			}
		}
		
		override public function activateScreen():void {
			if (_isActivated == true)
				return;
			if (LightBox.isShowing == true)
				return;
			super.activateScreen();
			if (_isDisposed == true)
				return;
			topBar.activate();
			scrollPanel.enable();
			if (firstTime == true) {
				loadLargeAvatar();
				/*if (userVO == null)
					getFullUserData();*/
			}
			var i:int;
			var l:int;
			var count:int = 2;
			if (mainButtons != null) {
				l = mainButtons.length;
				for (i = 0; i < l; i++) {
					if (firstTime == true)
						mainButtons[i].show(.3, count * .05, true, .9, 0);
					mainButtons[i].activate();
					count++;
				}
			}
			if (otherButtons != null) {
				l = otherButtons.length;
				for (i = 0; i < l; i++) {
					if (firstTime == true)
						otherButtons[i].show(.3, count * .05, true, .9, 0);
					otherButtons[i].activate();
					count++;
				}
			}
			PointerManager.addTap(avatar, onAvatarTapped);
			if (phoneTF != null)
				PointerManager.addTap(phoneTF, onPhoneTap);
			updateUserStatus();
			firstTime = false;
			
			if (Config.ADMIN_UIDS.indexOf(Auth.uid) != -1)
				if (status != null && status.parent != null)
					PointerManager.addTap(status, copyToClipboard);
		}
		
		private function copyToClipboard(e:Event = null):void {
			Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, userVO.uid + ";" + userVO.md5sum);
			ToastMessage.display("copied");
		}
		
		/*private function getFullUserData(needServer:Boolean = false, onlyCache:Boolean = false):void {
			userVO = UsersManager.getFullUserData(userModel.uid, needServer, !needServer);
		}
		
		private function updateProfileScreen(userUID:String, userVO:UserVO = null):void {
			if (userUID != userModel.uid)
				return;
			var needToUpdateScreen:Boolean = true;
			firstTimeUserVO = false;
			if (userVO == null)
				return;
			this.userVO = userVO;
			if (needToUpdateScreen == true)
				updateScreen();
		}
		
		private function updateScreen():void {
			
		}*/
		
		override public function deactivateScreen():void {
			if (_isActivated == false)
				return;
			super.deactivateScreen();
			if (_isDisposed == true)
				return;
			topBar.deactivate();
			scrollPanel.disable();
			var l:int;
			var i:int;
			if (mainButtons != null) {
				l = mainButtons.length;
				for (i = 0; i < l; i++)
					mainButtons[i].deactivate();
			}
			if (otherButtons != null) {
				l = otherButtons.length;
				for (i = 0; i < l; i++)
					otherButtons[i].deactivate();
			}
			PointerManager.removeTap(avatar, onAvatarTapped);
			if (phoneTF != null)
				PointerManager.removeTap(phoneTF, onPhoneTap);
			UsersManager.S_ONLINE_CHANGED.remove(onUserOnlineStatusChanged);
			
			if (status != null)
				PointerManager.removeTap(status, copyToClipboard);
		}
		
		private function createNewTF():TextField {
			var tf:TextField = new TextField();
			tf.selectable = false;
			tf.mouseEnabled = false;
			tf.wordWrap = false;
			tf.multiline = false;
			return tf;
		}
		
		private function onPhoneTap(e:Event = null):void {
			if (userVO == null)
				return;
			if (userVO.phone == null || userVO.phone.length == 0)
				return;
			navigateToURL(new URLRequest("tel:" + userVO.phone));
		}
		
		private function onAvatarTapped(e:Event = null):void {
			var lnk:String = userVO.getAvatarURLProfile(MobileGui.stage.height * 2);
			if (lnk == null && (userVO.media == null || userVO.media.fxGallery == null || userVO.media.fxGallery.length == 0))
				return;
			var fxContent:IContentProvider;
			if (userVO.fxID != 0) {
				fxContent = new FXImagesListContentProvider();
				fxContent.setData(userVO);
			}
			var imageActions:Vector.<IScreenAction>;
			if (userVO.fxID != 0 && userVO.login != null) {
				imageActions = new Vector.<IScreenAction>();
				/*var openFxProfileAction:OpenFxProfileAction = new OpenFxProfileAction(userVO.login);
				openFxProfileAction.setData(ImageContextMenuType.OPEN_FX_PROFILE);
				imageActions.push(openFxProfileAction);*/
				LightBox.showCommunityLink(userVO.login);
			}
			if (lnk != null)
				LightBox.add(lnk, false, null, null, null, null, imageActions);
			LightBox.show(lnk, userVO.getDisplayName(), true, fxContent);
		}
		
		private function onChatButtonTap():void {
			var chatScreenData:ChatScreenData = new ChatScreenData();
			chatScreenData.usersUIDs = [userVO.uid];
			chatScreenData.type = ChatInitType.USERS_IDS;
			chatScreenData.backScreen = MobileGui.centerScreen.currentScreenClass;
			chatScreenData.backScreenData = data;
			MobileGui.showChatScreen(chatScreenData);
		}
		
		private function onCallButtonTap():void {
			if (NetworkManager.isConnected == false) {
				DialogManager.alert(Lang.textAlert, Lang.alertProvideInternetConnection);
				return;
			}
			if (WS.connected == false) {
				DialogManager.alert(Lang.textAttention, Lang.checkNetworkStatus);
				return; 
			}
			
			CallManager.place(
				userVO.uid,
				MobileGui.centerScreen.currentScreenClass,
				data,
				userVO.getDisplayName(),
				userVO.getAvatarURLProfile(avatarSize * 2)
			);
		}
		
		private function onPayButtonTap():void {
			if (userVO.type == "bot")
				return;
			
			var giftData:GiftData = new GiftData();
			giftData.user = userVO;
			giftData.type = GiftType.MONEY_TRANSFER;
			Gifts.startSendMoney(giftData);
		}
		
		private function onInviteButtonTap():void {
			if ("data" in data == false || data.data == null || data.data is PhonebookUserVO == false)
				return;
			if (data.data.phone != null && data.data.phone.length > 0)
				PhonebookManager.invite(data.data);
		}
		
		private function onQuestionsStatButtonTap():void {
			MobileGui.changeMainScreen(UserQuestionsStatScreen, { 
				userUID:userVO.uid, 
				backScreen:MobileGui.centerScreen.currentScreenClass, 
				backScreenData:MobileGui.centerScreen.currentScreen.data
			} );
		}
		
		private function onCommunityButtonTap():void {
			var nativeAppExist:Boolean = false;
			if (Config.PLATFORM_ANDROID == true && MobileGui.androidExtension != null)
				nativeAppExist = MobileGui.androidExtension.launchFXComm("profile", userVO.login);
			else if (Config.PLATFORM_APPLE == true && MobileGui.dce != null)
				nativeAppExist = MobileGui.dce.launchFXComm("profile", userVO.login);
			if (nativeAppExist == false) {
				if (userVO.fxID != 0)
					navigateToURL(new URLRequest(Config.URL_FXCOMM_PROFILE + userVO.fxID + "&fromdcc=1&mob=1"));
			}
		}
		
		private function onBlockButtonTap():void {
			var btn:BitmapButton;
			if (actionBlockUser.button != undefined)
				btn = actionBlockUser.button;
			if (btn != null)
				btn.deactivate();
			UsersManager.USER_BLOCK_CHANGED.add(onUserBlockStatusChanged);
			UsersManager.changeUserBlock(userVO.uid, (Auth.blocked != null && Auth.blocked.indexOf(userVO.uid) != -1) ? UserBlockStatusType.UNBLOCK : UserBlockStatusType.BLOCK);
		}
		
		private function onUserBlockStatusChanged(data:Object):void {
			UsersManager.USER_BLOCK_CHANGED.remove(onUserBlockStatusChanged);
			if (_isDisposed == true)
				return;
			var btn:BitmapButton;
			if (actionBlockUser.button != undefined)
				btn = actionBlockUser.button;
			if (btn == null)
				return;
			if (_isActivated == true)
				btn.activate();
			actionBlockUser.title = (data.status == UserBlockStatusType.BLOCK) ? Lang.unblockUser : actionBlockUser.title = Lang.blockUser;
			
			var iconL:DisplayObject;
			var iconR:DisplayObject;
			if (actionBlockUser.iconL != undefined && actionBlockUser.iconL != null) {
				iconL = new actionBlockUser.iconL();
				UI.scaleToFit(iconL, iconSize, iconSize);
			}
			if (actionBlockUser.iconR != undefined && actionBlockUser.iconR != null) {
				iconR = new actionBlockUser.iconR();
				UI.scaleToFit(iconR, iconArrowSize, iconArrowSize);
			}
			var ibmd:ImageBitmapData = UI.renderSettingsTextAdvanced(
				actionBlockUser.title,
				fitWidth,
				optionLineHeight,
				false,
				TextFormatAlign.LEFT,
				TextFieldAutoSize.NONE,
				Config.FINGER_SIZE * 0.34,
				false,
				AppTheme.GREY_DARK,
				0,
				0,
				iconL,
				iconR
			);
			UI.destroy(iconL);
			UI.destroy(iconR);
			iconL = null;
			iconR = null;
			btn.setBitmapData(ibmd, true);
		}
		
		private function onBanPaidButtonTap():void {
			PaidBan.paidBanUser(userVO);
		}
		
		private function onFlowerButtonTap():void {
			UserExtensionsManager.buyFlower(userVO);
		}
		
		private function onUnbanPaidButtonTap():void {
			PaidBan.paidUnbanUser(userVO);
		}
		
		private function onBanButtonTap():void {
			DialogManager.showSelectItemDialog( { callBack:onReasonSelected, itemClass:ListQuestionType, listData:banReasons, title:"Ban Reasons" } );
		}
		
		private function onReasonSelected(val:int):void {
			if (val == -1)
				return;
			PHP.admin911_ban(onBanResponse, userVO.uid, banReasons[val].desk);
		}
		
		private function onBanResponse(phpRespod:PHPRespond):void {
			if (phpRespod.error == true) {
				ToastMessage.display("User not banned");
				phpRespod.dispose();
			}
			ToastMessage.display("User banned");
			phpRespod.dispose();
		}
		
		private function onBanForeverButtonTap():void {
			DialogManager.showSelectItemDialog( { callBack:onReasonSelected1, itemClass:ListQuestionType, listData:banReasons, title:"Ban Reasons" } );
			
		}
		
		private function onReasonSelected1(val:int):void {
			if (val == -1)
				return;
			PHP.admin911_banForever(onBanResponse, userVO.uid, banReasons[val].desk);
		}
		
		private function onBanForeverResponse(phpRespod:PHPRespond):void {
			if (phpRespod.error == true) {
				ToastMessage.display("User not banned");
				phpRespod.dispose();
			}
			ToastMessage.display("User banned forever");
			phpRespod.dispose();
		}
		
		private function onZeroRatingButtonTap():void {
			PHP.admin911_changeRating(onRatingResponse, userVO.uid);
		}
		
		private function onRatingResponse(phpRespod:PHPRespond):void {
			if (phpRespod.error == true) {
				ToastMessage.display("Rating not setted");
				phpRespod.dispose();
			}
			ToastMessage.display("Rating setted");
			phpRespod.dispose();
		}
		
		private function onLightboxOpen():void {
			if (_isDisposed == true)
				return;
			deactivateScreen();
		}
		
		private function onLightboxClose():void {
			if (_isDisposed == true)
				return;
			if (LightBox.isShowing == true)
				return;
			activateScreen();
		}
		
		override public function dispose():void {
			if (_isDisposed == true)
				return;
			
			super.dispose();
			
			LightBox.S_LIGHTBOX_OPENED.remove(onLightboxOpen);
			LightBox.S_LIGHTBOX_CLOSED.remove(onLightboxClose);
			
			UsersManager.USER_BLOCK_CHANGED.remove(onUserBlockStatusChanged);
			UsersManager.S_ONLINE_CHANGED.remove(onUserOnlineStatusChanged);
			UsersManager.S_USERS_FULL_DATA.remove(updateProfileScreen);
			UsersManager.S_USER_FULL_DATA.remove(onProfileUpdate);
			
			PointerManager.removeTap(avatar, onAvatarTapped);
			
			UserExtensionsManager.S_USER_UPDATE.remove(onExtensionsUpdate);
			
			if (floweSticker != null)
			{
				PointerManager.removeTap(floweSticker, flowerStickerClicked);
				floweSticker.dispose();
				floweSticker = null;
			}
			
			if (extensions != null)
			{
				var l:int = extensions.length;
				for (var i:int = 0; i < l; i++) 
				{
					UI.destroy(extensions[i]);
				}
				extensions = null;
			}
			
			if (banMark != null)
			{
				UI.destroy(banMark);
				banMark = null;
			}
			if (permanentBanMark != null)
			{
				UI.destroy(permanentBanMark);
				permanentBanMark = null;
			}
			if (scrollPanelAddSizeForAppleX != null)
			{
				UI.destroy(scrollPanelAddSizeForAppleX);
				scrollPanelAddSizeForAppleX = null;
			}
			
			if (mainButtons != null)
				while (mainButtons.length != 0)
					mainButtons.shift().dispose();
			if (otherButtons != null)
				while (otherButtons.length != 0)
					otherButtons.shift().dispose();
			
			actionBanUser.button = null;
			actionBanUser = null;
			actionBanForeverUser.button = null;
			actionBanForeverUser = null;
			actionBlockUser.button = null;
			actionBlockUser = null;
			actionFXCommunity.button = null;
			actionFXCommunity = null;
			actionQuestionsStat.button = null;
			actionQuestionsStat = null;
			actionZeroRating.button = null;
			actionZeroRating = null;
			
			actionBanUserPaid.button = null;
			actionBanUserPaid = null;
			
			clearFxPhotos();
			
			userVO = null;
			
			topBar.dispose();
			topBar = null;
			scrollPanel.dispose();
			scrollPanel = null;
			
			hideAvatarPreloader();
			
			payRating = null;
			toad = null;
			atack = null;
			iconNetworkW = null;
			iconNetworkD = null;
			iconNetworkM = null;
			iconFXComm = null;
			
			photos = null;
			photosIcon = null;
			if (phoneTF != null) {
				PointerManager.removeTap(phoneTF, onPhoneTap);
				phoneTF.text = "";
			}
			if (jail != null) {
				TweenMax.killTweensOf(jail);
			}
			
			if (banSticker != null) {
				PointerManager.removeTap(banSticker, banStickerClicked);
				TweenMax.killTweensOf(banSticker);
				banSticker.dispose();
				banSticker = null;
			}
			photosTF = null;
			
			status = null;
			if (fxName != null)
				fxName.text = "";
			fxName = null;
			
			mainActions = null;
			
			if (avatarsToDispose != null)
				while (avatarsToDispose.length != 0)
					avatarsToDispose.shift().dispose();
			avatarsToDispose = null;
		}
		
		private function onProfileUpdate(userUID:String = null):void 
		{
			if (userUID != null && userVO != null && userUID == userVO.uid)
			{
				updateProfileScreen();
			}
		}
	}
}