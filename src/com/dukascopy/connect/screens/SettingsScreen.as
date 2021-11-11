package com.dukascopy.connect.screens {
	
	import assets.GalleryIcon;
	import assets.IconArrowRight;
	import assets.JailedIllustrationClip;
	import assets.PhotoShotIcon;
	import com.adobe.crypto.MD5;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.GiftData;
	import com.dukascopy.connect.data.PopupData;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.data.TradeNotesRequest;
	import com.dukascopy.connect.data.filter.FilterCategory;
	import com.dukascopy.connect.data.screenAction.BaseAction;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.customActions.OpenUnjailPopupAction;
	import com.dukascopy.connect.data.screenAction.customActions.SendTradeNotesRequestAction;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.renderers.ListLinkWithIcon;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.menuVideo.OptionSwitcher;
	import com.dukascopy.connect.gui.preloader.Preloader;
	import com.dukascopy.connect.gui.scrollPanel.ScrollPanel;
	import com.dukascopy.connect.gui.tools.ImagePreviewCrop;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.base.ScreenManager;
	import com.dukascopy.connect.screens.call.MRZScanScreen;
	import com.dukascopy.connect.screens.call.TalkScreenRecognition;
	import com.dukascopy.connect.screens.dialogs.CreateTemplateDialog;
	import com.dukascopy.connect.screens.dialogs.DevicesListScreen;
	import com.dukascopy.connect.screens.dialogs.QueuePopup;
	import com.dukascopy.connect.screens.dialogs.QueueUnderagePopup;
	import com.dukascopy.connect.screens.dialogs.UseFingerprintDialog;
	import com.dukascopy.connect.screens.dialogs.paymentDialogs.SendInvestmentByPhonePopup;
	import com.dukascopy.connect.screens.dialogs.paymentDialogs.SendMoneyByPhonePopup;
	import com.dukascopy.connect.screens.dialogs.x.base.bottom.AnimatedTitlePopup;
	import com.dukascopy.connect.screens.dialogs.x.base.bottom.ListSelectionPopup;
	import com.dukascopy.connect.screens.dialogs.x.base.content.ShareLinkPopup;
	import com.dukascopy.connect.screens.dialogs.x.base.content.TransactionFilterPopup;
	import com.dukascopy.connect.screens.dialogs.calendar.SelectDatePopup;
	import com.dukascopy.connect.screens.dialogs.gifts.FlowerSticker;
	import com.dukascopy.connect.screens.dialogs.paymentDialogs.FeedbackPopup;
	import com.dukascopy.connect.screens.payments.data.PaymentsScreenData;
	import com.dukascopy.connect.screens.payments.settings.PaymentsSettingsOneClickScreen;
	import com.dukascopy.connect.screens.payments.settings.PaymentsSettingsScreen;
	import com.dukascopy.connect.screens.promocodes.ReferralProgramScreen;
	import com.dukascopy.connect.screens.roadMap.RoadMapScreenNew;
	import com.dukascopy.connect.screens.serviceScreen.AppIntroScreen;
	import com.dukascopy.connect.screens.serviceScreen.BottomPopupScreen;
	import com.dukascopy.connect.screens.serviceScreen.BottomTimeSelectionScreen;
	import com.dukascopy.connect.screens.serviceScreen.FillUserInfoScreen;
	import com.dukascopy.connect.screens.settings.PrivacySettingsScreen;
	import com.dukascopy.connect.screens.shop.PaidChatsScreen;
	import com.dukascopy.connect.sys.applicationShop.Shop;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.configManager.ConfigManager;
	import com.dukascopy.connect.sys.crypter.Crypter;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.mrz.MrzResult;
	import com.dukascopy.connect.sys.nativeExtensionController.NativeExtensionController;
	import com.dukascopy.connect.sys.notificationManager.PushNotificationsNative;
	import com.dukascopy.connect.sys.payments.PayAPIManager;
	import com.dukascopy.connect.sys.payments.PayConfig;
	import com.dukascopy.connect.sys.payments.PayManager;
	import com.dukascopy.connect.sys.photoGaleryManager.PhotoGaleryManager;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.promocodes.ReferralProgram;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.settings.GlobalSettings;
	import com.dukascopy.connect.sys.socialManager.SocialManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.sys.usersManager.extensions.Extension;
	import com.dukascopy.connect.sys.usersManager.extensions.UserExtensionsManager;
	import com.dukascopy.connect.sys.usersManager.paidBan.PaidBan;
	import com.dukascopy.connect.sys.ws.WSClient;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.type.MainColors;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.connect.vo.CallVO;
	import com.dukascopy.connect.vo.users.UserVO;
	import com.dukascopy.langs.Lang;
	import com.dukascopy.langs.LangManager;
	import com.hurlant.util.Base64;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.JPEGEncoderOptions;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov, Telefision TEAM Riga.
	 */
	
	public class SettingsScreen extends BaseScreen {
		
		private var btnNotificationObject:Object =          { type:"switcher", iconL:Style.icon(Style.ICON_NOTIFICATIONS),   title:Lang.textNotifications,  callback:onNotificationTap, id:0 };
		private var btnPrivacyObject:Object =               { type:"button",   iconL:Style.icon(Style.ICON_SOUND_MESSAGES),  title:Lang.privacySettings, iconR:IconArrowRight,   callback:onPrivacyTap, id:21 };
		private var btnSoundMsgObject:Object =              { type:"switcher", iconL:Style.icon(Style.ICON_SOUND_MESSAGES),  title:Lang.soundsOnMessages,   callback:onSoundMsgTap, id:1 };
		private var btnSoundCallObject:Object =             { type:"switcher", iconL:Style.icon(Style.ICON_SOUND_CALL),     title:Lang.soundsOnCall,       callback:onSoundCallTap, id:2 };
		//private var btnSocialObject:Object =                { type:"switcher", iconL:Style.icon(Style.ICON_SOCIAL),                  title:Lang.socialOnCall,       callback:onSocialTap, id:19 };
		private var btn911SectionObject:Object =            { type:"button",   iconL:Style.icon(Style.ICON_STAT),          title:Lang.section911My,       callback:on911SectionTap, iconR:IconArrowRight, id:3 };
		private var btnReferralSectionObject:Object =       { type:"button",   iconL:Style.icon(Style.ICON_REFERRAL),              title:Lang.referralProgram,    callback:onReferralSectionTap, iconR:IconArrowRight, id:7 };
		private var btnReferralEnterCodeObject:Object =     { type:"button",   iconL:Style.icon(Style.ICON_REFERRAL),              title:Lang.enterReferralCode,  callback:onReferralEnterCodeTap, iconR:IconArrowRight, id:9 };
		private var btnFXCommObject:Object =                { type:"button",   iconL:Style.icon(Style.ICON_COMMUNITY),              title:Lang.communityProfile,   callback:onFXCommTap, iconR:IconArrowRight, id:4 };
		private var btnLanguageObject:Object =              { type:"button",   iconL:Style.icon(Style.ICON_LANGUAGE),               title:Lang.setLanguage,        callback:onLanguageTap, iconR:IconArrowRight, id:5 };
		private var btnUnbanObject:Object =                 { type:"button",   iconL:Style.icon(Style.ICON_JAIL),                  title:Lang.getOutOfJail,       callback:onUnbanPaidButtonTap, id:10, red:true };
		private var btnBuyProtectionObject:Object =         { type:"button",   iconL:Style.icon(Style.ICON_PROTECTION),                 title:Lang.buyBanProtection,   callback:onBuyProtectionButtonTap, id:11 };
		private var btnShowProtectionObject:Object =        { type:"button",   iconL:Style.icon(Style.ICON_PROTECTION),                 title:Lang.banProtection,      callback:onShowProtectionButtonTap, id:12 };
		private var btnShowMyBansObject:Object =            { type:"button",   iconL:Style.icon(Style.ICON_JAIL),                  title:Lang.myBans,             callback:onShowMyBansButtonTap, id:13 };
		private var btnLogoutObject:Object =                { type:"button",   iconL:Style.icon(Style.ICON_LOGOUT),         title:Lang.logout,             callback:onLogoutTap, id:6 };
		private var btnOneClickObject:Object =              { type:"button",   iconL:Style.icon(Style.ICON_ONE_CLICK),         title:Lang.oneClickPayments,   callback:onOneClickTap,iconR:IconArrowRight, id:8 };
		private var btnShowRatingObject:Object =            { type:"switcher", iconL:Style.icon(Style.ICON_RATING),             title:Lang.showRating,         callback:onShowRatingTap, id:14 };
		private var btnOpenAccountObject:Object =           { type:"button",   iconL:Style.icon(Style.ICON_BANK),                    title:Lang.openAccount,        callback:onAccountTap, id:15, red:true };
		private var btnMyAccountObject:Object =             { type:"button",   iconL:Style.icon(Style.ICON_BANK),                    title:Lang.myAccount,          callback:onAccountTap, id:16 };
		private var btnSubscriptionsObject:Object =         { type:"button",   iconL:Style.icon(Style.ICON_PAID_CHAT),                   title:Lang.myPaidChats,    	callback:onMyPaidChatsTap, id:17 };
		private var btnProductsObject:Object =              { type:"button",   iconL:Style.icon(Style.ICON_PAID_CHAT),                   title:Lang.myPaidChats,        callback:onMyProductsTap, id:19 };
		private var btnTestObject:Object =                  { type:"button",   iconL:Style.icon(Style.ICON_ATTACH),                       title:"Скопировать базу",        callback:onTestTap, id:18 };
		private var btnTestObject2:Object =                 { type:"button",   iconL:Style.icon(Style.ICON_ATTACH),                       title:"Forgot password",       callback:onTestTap2, id:18 };
		private var btnTestObject3:Object =                 { type:"button",   iconL:Style.icon(Style.ICON_ATTACH),                       title:"Queue popup",           callback:onTestTap3, id:19 };
		private var btnDevices:Object =                     { type:"button",   iconL:Style.icon(Style.ICON_TEXT),                       title:Lang.myDevices,           callback:devicesTap, id:20 };
		
		private var line_1:Object =                 		{ type:"line" };
		private var line_2:Object =                 		{ type:"line" };
		private var line_3:Object =                 		{ type:"line" };
		
		private const OPTION_LINE_HEIGHT:int = Config.FINGER_SIZE *.8;
		private const BTN_ICON_RIGHT_SIZE:int = Config.FINGER_SIZE * 0.3;
		private const BTN_ICON_LEFT_SIZE:int = Config.FINGER_SIZE * 0.36;
		private const AVATAR_SIZE:int = Config.FINGER_SIZE * 1.5 * 1.5;
		
		private static var LOADED_AVATAR_BMD:ImageBitmapData;
		private static var EMPTY_AVATAR_BMD:ImageBitmapData;
		
		private var FIT_WIDTH:Number;
		
		private var scrollPanel:ScrollPanel;
		
		private var avatarBox:Sprite;
		private var avatarBitmap:Bitmap;
		private var toad:Sprite;
		private var preloaderAvatar:Preloader;
		private var userNameEdit:BitmapButton;
		private var userNameEditButton:BitmapButton;
		private var userNameBitmap:Bitmap;
		private var phoneNumberBitmap:Bitmap;
		private var versionBitmap:Bitmap;
		
		private var buttons:Array;
		
		private var titleEditing:Boolean;
		private var avatarUploading:Boolean;
		private var changeAvatarRequest:String;
		private var imageCropper:ImagePreviewCrop;
		private var lastLoadedImageName:String;
		private var busyIndicator:Preloader;
		private var currentIndicatorHolder:BitmapButton;
		private var updateOnActivate:Boolean;
		private var enterReferralCodeButtonExist:Boolean;
		private var jail:Sprite;
		
		private var extensions:Vector.<Bitmap>;
		private var floweSticker:FlowerSticker;
		private var bottomClip:Sprite;
		
		/** @CONSTRUCTOR **/
		public function SettingsScreen() {
			super();
		}
		
		override protected function createView():void {
			super.createView();
			
			echo("SettingsScreen", "createView");
			
			// Scroll Panel 
			scrollPanel = new ScrollPanel();
			scrollPanel.background = true;
				var dummy:Shape = new Shape();
				dummy.graphics.beginFill(0, 0);
				dummy.graphics.drawRect(0, 0, 1, 1);
			scrollPanel.addObject(dummy);
			_view.addChild(scrollPanel.view);
				avatarBox = new Sprite();
					avatarBitmap = new Bitmap();
				avatarBox.addChild(avatarBitmap);
			scrollPanel.addObject(avatarBox);
				userNameEdit = new BitmapButton();
				userNameEdit.usePreventOnDown = false;
				userNameEdit.setStandartButtonParams();
				userNameEdit.setDownScale(1);
				userNameEdit.setDownColor(0xFFFFFF);
				userNameEdit.tapCallback = onTitleEditTap;
				userNameEdit.disposeBitmapOnDestroy = true;
			scrollPanel.addObject(userNameEdit);
				userNameEditButton = new BitmapButton();
				userNameEditButton.usePreventOnDown = false;
				userNameEditButton.setStandartButtonParams();
				userNameEditButton.setDownScale(1);
				userNameEditButton.setDownColor(0xFFFFFF);
				userNameEditButton.tapCallback = onTitleEditTap;
				userNameEditButton.disposeBitmapOnDestroy = true;
				var editicon:DisplayObject = new (Style.icon(Style.ICON_EDIT));
				UI.colorize(editicon, Style.color(Style.COLOR_ICON_LIGHT));
					var editIconIBMD:ImageBitmapData = UI.renderAsset(editicon, Config.FINGER_SIZE * .3, Config.FINGER_SIZE * .3, true, "SettingsScreen.userNameEditButton");
				userNameEditButton.setBitmapData(editIconIBMD, true);
				editicon = null;
				var btnOffset:int = (Config.FINGER_SIZE - userNameEditButton.width) * .5;
				userNameEditButton.setOverflow(btnOffset, btnOffset, btnOffset, btnOffset);
			scrollPanel.addObject(userNameEditButton);
				phoneNumberBitmap = new Bitmap();
			scrollPanel.addObject(phoneNumberBitmap);
				versionBitmap = new Bitmap();
			scrollPanel.addObject(versionBitmap);
			
			bottomClip = new Sprite();
			scrollPanel.addObject(bottomClip);
			bottomClip.graphics.beginFill(Style.color(Style.CHAT_BACKGROUND));
			bottomClip.graphics.drawRect(0, 0, 1, 1);
			bottomClip.graphics.endFill();
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			_params.title = Lang.textSettings;
			
			scrollPanel.setWidthAndHeight(_width, _height);
			
			FIT_WIDTH = _width - Config.DOUBLE_MARGIN * 2;
			
			EMPTY_AVATAR_BMD ||= UI.drawAssetToRoundRect(new SWFEmptyAvatar(), AVATAR_SIZE);
			
			avatarBox.y = Config.FINGER_SIZE * .35;
			avatarBox.x = (_width - AVATAR_SIZE) * .5;
			
			phoneNumberBitmap.bitmapData = UI.renderText("+" + String(Auth.phone) , FIT_WIDTH, 
											Config.FINGER_SIZE * .5, false, TextFormatAlign.CENTER, 
											TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .28, false, 
											Style.color(Style.COLOR_SUBTITLE), Style.color(Style.COLOR_BACKGROUND), true);
			phoneNumberBitmap.x = (_width - phoneNumberBitmap.width) * .5;
			
			drawVersion();
			
			updateAvatarBMD();
			
			if (Auth.avatar != null) {
				var path:String = Auth.getLargeAvatar(AVATAR_SIZE);
				var imageCache:ImageBitmapData = ImageManager.getImageFromCache(path);
				if (imageCache)
					onAvatarLoaded(path, imageCache);
			}
			
			drawFlowerClip();
			
			createButtonsData();
			createButtons();
			updateSettings();
			
			scrollPanel.update();
			
			Auth.S_AUTH_DATA_UPDATED.add(onAuthDataUpdated);
			Auth.S_PHAZE_CHANGE.add(onPhazeChanged);
			
			onPayAccountInfo();
			WSClient.S_PUSH_GLOBAL_STATUS.add(onNotofocationStatusChanged);
			UsersManager.S_TOAD_UPDATED.add(addToad);
			if (PaidBan.isAvaliable() == true) {
				PaidBan.S_USER_BAN_UPDATED.add(onPaidBanChanged);
			}
			
			addToad();
			addJail();
			checkExtensions();
			
		//	DialogManager.showPayPass(null);
			
			GlobalSettings.S_UPDATE.add(onSettingsChanged);
		//	MobileGui.changeMainScreen(PaymentsCreateCardScreen);
			/*ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, 
											ShareLinkPopup, 
												{url:"http://google.com", 
												title:Lang.requestMoney, 
												description:"20 EUR invoice, valid till 12 Jan 2020",
												subtitle:"Send the link to the contact to request money", 
												callback:function(result:String):void{}});*/
		}
		
		private function updateAvatar():void {
			if (isDisposed)
				return;
			if (Auth.avatar != null && lastLoadedImageName != null && Auth.avatar != lastLoadedImageName) {
				var path:String = Auth.getLargeAvatar(AVATAR_SIZE);
				var imageCache:ImageBitmapData = ImageManager.getImageFromCache(path);
				if (imageCache)
					onAvatarLoaded(path, imageCache);
				else
					ImageManager.loadImage(Auth.getLargeAvatar(AVATAR_SIZE), onAvatarLoaded);
			}
		}
		
		private function onPhazeChanged(realChange:Boolean = true):void {
			clearButtons();
			createButtonsData();
			createButtons();
			updateSettings();
			drawView();
			if (_isActivated == true)
				activateScreen();
		}
		
		private function onTestTap():void {
			
			var database:File = File.applicationStorageDirectory.resolvePath("tfc.db");
			
			if (database.exists)
			{
				NativeExtensionController.saveFileToDownloadFolder(database.nativePath);
			}
		}
		
		private function sendNotesRequest(request:TradeNotesRequest = null):void 
		{
			if (request != null)
			{
				var action:SendTradeNotesRequestAction = new SendTradeNotesRequestAction(request, null);
				action.execute();
			}
		}
		
		private function onSelectContact(user:UserVO, data:Object):void {
			
		}
		
		private function onMrz(r:MrzResult):void {
			
		}
		
		private function onTestTap2():void {
			//ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_DIALOG, TransactionPresetsPopup);
		}
		
		private function onTestTap3():void
		{
			ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_DIALOG, QueuePopup);
		}
		
		private function devicesTap():void
		{
			MobileGui.changeMainScreen(DevicesListScreen,  {
																	title:Lang.myDevices,
																	backScreen:MobileGui.centerScreen.currentScreenClass, 
																	backScreenData:MobileGui.centerScreen.currentScreen.data
																},
										ScreenManager.DIRECTION_RIGHT_LEFT);
		}
		
		private function drawFlowerClip():void {
			var userVO:UserVO = Auth.myProfile;
			if (userVO == null)
			{
				return;
			}
			if (userVO.gifts != null && userVO.gifts.items != null && userVO.gifts.items.length > 0) {
				if (floweSticker == null) {
					floweSticker = new FlowerSticker();
					scrollPanel.addObject(floweSticker);
				}
				PointerManager.removeTap(floweSticker, flowerStickerClicked);
				PointerManager.addTap(floweSticker, flowerStickerClicked);
				
				floweSticker.draw(userVO.gifts, _width);
				
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
		}
		
		private function flowerStickerClicked(e:Event = null):void 
		{
			var userVO:UserVO = Auth.myProfile;
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
		
		private function checkExtensions():void 
		{
			var userVO:UserVO = Auth.myProfile;
			var l:int;
			if (userVO != null && userVO.gifts != null && !userVO.gifts.empty())
			{
				extensions = new Vector.<Bitmap>();
				l = userVO.gifts.length;
				var item:Bitmap;
				var sourceClass:Class;
				var source:Sprite;
				var itemSize:int = AVATAR_SIZE * 1.05 * .5;
			//	for (var i:int = 0; i < l; i++) 
			//	{
					sourceClass = userVO.gifts.items[l - 1].getImage();
					if (sourceClass != null)
					{
						source = new sourceClass() as Sprite;
						UI.scaleToFit(source, itemSize, itemSize);
						
						item = new Bitmap();
						item.bitmapData = UI.getSnapshot(source, StageQuality.HIGH, "UserProfileScreen.extension");
						
						avatarBox.addChild(item);
						item.x = AVATAR_SIZE * 1.1 - item.width;
						item.y = AVATAR_SIZE * 1.1 - item.height;
						
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
					avatarBox.setChildIndex(extensions[j], avatarBox.numChildren - 1);
				}
			}
		}
		
		private function onSettingsChanged():void {
			updateSettings();
		}
		
		private function onPopupTap(e:Event = null):void
		{
			var popupData:PopupData = new PopupData();
			var action:IScreenAction = new OpenUnjailPopupAction();
			action.setData(Lang.getOutOfJail);
			popupData.action = action;
			popupData.illustration = JailedIllustrationClip;
			popupData.title = Lang.youInJail;
			popupData.text = Lang.youcantParticiparteInEventJailed;
			ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, BottomPopupScreen, popupData);
		}
		
		private function onPaidBanChanged(userUID:String):void {
			if (isDisposed)
				return;
			
			if (userUID == Auth.uid) {
				clearButtons();
				createButtonsData();
				createButtons();
				updateSettings();
				drawView();
				drawVersion();
				if (_isActivated)
					activateScreen();
				
				addJail();
			}
		}
		
		private function addJail():void {
			if (Auth.myProfile != null && Auth.myProfile.ban911VO != null) {
				jail = addAttackIcon(jail, Style.icon(Style.ICON_JAILED)) as Sprite;
			}
			else {
				if (jail != null && jail.parent != null) {
					jail.parent.removeChild(jail);
				}
			}
		}
		
		private function addToad():void {
			if (UsersManager.checkForToad(Auth.uid) == true)
				toad = addAttackIcon(toad, SWFFrog) as Sprite;
			else if (toad != null && toad.parent != null)
				toad.parent.removeChild(toad);
		}
		
		private function addAttackIcon(icon:Sprite, cls:Class, scale:Number = 1):DisplayObject {
			if (icon == null) {
				icon = new cls();
				icon.scaleX = icon.scaleY = AVATAR_SIZE / 100 * scale;
				if (scale != 1)
					icon.y = -(AVATAR_SIZE * (1 - scale));
				icon.mouseEnabled = false;
				icon.mouseChildren = false;
				icon.x = AVATAR_SIZE * .5;
				icon.y = AVATAR_SIZE * .5;
			}
			if (icon.parent == null)
				avatarBox.addChild(icon);
			return icon;
		}
		
		private function onNotofocationStatusChanged(result:Object):void {
			if (result != null && buttons != null)
			{
				if (btnNotificationObject != null && btnNotificationObject.uiComponent != null && isDisposed == false)
				{		
					if ("isSelected" in btnNotificationObject.uiComponent)
					{
						btnNotificationObject.uiComponent.isSelected = result.status;
					}
				}
			}
		}
		
		private function onReferralProgramUpdated(success:Boolean, errorMessage:String = null):void {
			if (success == true) {
				clearButtons();
				createButtonsData();
				createButtons();
				updateSettings();
				drawView();
				drawVersion();
				if (_isActivated)
					activateScreen();
			}
		}
		
		private function drawVersion():void {
			var version:String = Lang.textVersion + " " + Config.VERSION + Config.SERVER_NAME + " - " + PayConfig.VERSION;
			versionBitmap.bitmapData = UI.renderText(version , FIT_WIDTH, Config.FINGER_SIZE * .5, false , TextFormatAlign.CENTER, 
													TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .28, false, 
													Style.color(Style.COLOR_SUBTITLE), Style.color(Style.COLOR_BACKGROUND), true);
			versionBitmap.x = (_width - versionBitmap.width) * .5;
		}
		
		private function createButtonsData():void {
			buttons = new Array()
			
			if (Auth.bank_phase == "ACC_APPROVED")
				buttons.push(btnMyAccountObject);
			else
				buttons.push(btnOpenAccountObject);
			
			if ((Auth.myProfile != null && Auth.myProfile.gender != "") || (ReferralProgram.isAvaliable() == true && PayAPIManager.hasSwissAccount == true)) {
				buttons.push(btnOneClickObject);
			}
			
			buttons.push(line_1);
			
		//	buttons.push(btnPrivacyObject);
			buttons.push(btnNotificationObject);
			buttons.push(btnSoundCallObject);
			buttons.push(btnSoundMsgObject);
			if (LangManager.initialized)
				buttons.push(btnLanguageObject);
			
			buttons.push(line_2);
			
			//if (Config.socialAvailable == true && Auth.bank_phase == "ACC_APPROVED") {
				//buttons.push(btnSocialObject);
			//}
		//	buttons.push(btnShowRatingObject);
			
			//if (SocialManager.available == true) {
				//buttons.push(btn911SectionObject);
			//}
			
			enterReferralCodeButtonExist = false;
			var paidBanAvaliable:Boolean = false;
			if (Auth.myProfile != null && Auth.myProfile.gender != "") {
				buttons.push(btnReferralSectionObject);
				paidBanAvaliable = true;
			} else if (ReferralProgram.isAvaliable() == true) {
				if (PayAPIManager.hasSwissAccount == true) {
					buttons.push(btnReferralSectionObject);
					paidBanAvaliable = true;
				}
			}
			
			if (Auth.fxcommID > 0)
				buttons.push(btnFXCommObject);
			
			
			if (SocialManager.available == true) {
				if (paidBanAvaliable == true && PaidBan.isAvaliable() == true) {
					if (Auth.myProfile != null && Auth.myProfile.ban911VO != null)
						PaidBan.checkBanStatus(Auth.myProfile.ban911VO);
					if (Auth.myProfile != null && Auth.myProfile.ban911VO != null)
						buttons.push(btnUnbanObject);
					else {
						if (Auth.myProfile != null && Auth.myProfile.paidPanProtection != null)
							PaidBan.checkProtectionStatus(Auth.myProfile);
						if (Auth.myProfile != null && Auth.myProfile.paidPanProtection != null)
							buttons.push(btnShowProtectionObject);
						else
							buttons.push(btnBuyProtectionObject);
					}
					buttons.push(btnShowMyBansObject);
				}
				/*if (Shop.isPaidChannelsAvaliable()) {
					if (Auth.myProfile != null && Auth.myProfile.gender != "") {
						buttons.push(btnSubscriptionsObject);
						buttons.push(btnProductsObject);
					} else if (ReferralProgram.isAvaliable() == true) {
						buttons.push(btnSubscriptionsObject);
						buttons.push(btnProductsObject);
					}
				}*/
			}
		//	buttons.push(btnSubscriptionsObject);
			//buttons.push(btnDevices);
			buttons.push(line_3);
			buttons.push(btnLogoutObject);
			/*if (Config.isAdmin() == true) {
				buttons.push(btnTestObject);
				buttons.push(btnTestObject2);
				buttons.push(btnTestObject3);	
			}*/
			
			if (Config.isTF() == true && Config.PLATFORM_ANDROID == true) {
				buttons.push(btnTestObject);
			}
		}
		
		private function onReferralEnterCodeTap():void {
			return;
			ReferralProgram.enterCode();
		}
		
		private function onPayAccountInfo():void {
			if (Auth.bank_phase != "ACC_APPROVED") {
				ReferralProgram.S_UPDATED.add(onReferralProgramUpdated);
				ReferralProgram.checkEnterCodeAvaliability();
			}
		}
		
		private function createButtons():void {
			var l:int = buttons.length;
			for (var i:int = 0; i < l; i++) {
				var iconL:DisplayObject;
				var iconR:DisplayObject;
				if (buttons[i].iconL != undefined && buttons[i].iconL != null)
					iconL = new buttons[i].iconL();
					UI.colorize(iconL, Style.color(Style.COLOR_ICON_SETTINGS))
				if (buttons[i].iconR != undefined && buttons[i].iconR != null)
					iconR = new buttons[i].iconR();
					UI.colorize(iconR, Style.color(Style.ICON_RIGHT_COLOR))
				if (buttons[i].type == "switcher") {
					var iconLIBMD:ImageBitmapData = UI.renderAsset(iconL, BTN_ICON_LEFT_SIZE, BTN_ICON_LEFT_SIZE, true, "SettingsScreen.notificationIcon");
					buttons[i].uiComponent = new OptionSwitcher();
					(buttons[i].uiComponent as OptionSwitcher).create(_width, OPTION_LINE_HEIGHT, iconLIBMD, buttons[i].title, false, true, Style.color(Style.COLOR_TEXT));
					buttons[i].uiComponent.onSwitchCallback = buttons[i].callback;
				} else if (buttons[i].type == "line") {
					buttons[i].uiComponent = new Sprite();
					(buttons[i].uiComponent as Sprite).graphics.lineStyle(UI.getLineThickness(), Style.color(Style.COLOR_SEPARATOR));
					(buttons[i].uiComponent as Sprite).graphics.moveTo(-Config.DIALOG_MARGIN, Config.MARGIN*1.2);
					(buttons[i].uiComponent as Sprite).graphics.lineTo(_width, Config.MARGIN * 1.2);
				//	(buttons[i].uiComponent as Sprite).x = -Config.DIALOG_MARGIN;
				} else if (buttons[i].type == "button") {
					if (iconL != null) {
						UI.scaleToFit(iconL, BTN_ICON_LEFT_SIZE, BTN_ICON_LEFT_SIZE);
						if (buttons[i].red == true)
							UI.colorize(iconL, MainColors.RED);
					}
					if (iconR != null) {
						UI.scaleToFit(iconR, BTN_ICON_RIGHT_SIZE, BTN_ICON_RIGHT_SIZE);
						if (buttons[i].red == true)
							UI.colorize(iconR, MainColors.RED);
					}
					buttons[i].uiComponent = new BitmapButton(buttons[i].title);
					buttons[i].uiComponent.usePreventOnDown = false;
					buttons[i].uiComponent.setDownScale(1);
					buttons[i].uiComponent.setDownColor(0x000000);
					buttons[i].uiComponent.setOverlay(HitZoneType.MENU_MIDDLE_ELEMENT);
					var ibmd:BitmapData = UI.renderSettingsTextAdvanced(
						buttons[i].title,
						_width,
						OPTION_LINE_HEIGHT,
						false,
						TextFormatAlign.LEFT,
						TextFieldAutoSize.NONE,
						Config.FINGER_SIZE * 0.34,
						false,
						(buttons[i].red == true) ? MainColors.RED : Style.color(Style.COLOR_TEXT),
						0,
						0,
						iconL,
						iconR
					);
					UI.destroy(iconL);
					UI.destroy(iconR);
					iconL = null;
					iconR = null;
					buttons[i].uiComponent.setBitmapData(ibmd);
					buttons[i].uiComponent.tapCallback = buttons[i].callback;
					buttons[i].uiComponent.show(0);
				}
				buttons[i].uiComponent.x = 0;
				scrollPanel.addObject(buttons[i].uiComponent);
			}
		}
		
		private function updateSettings():void {
			if ("uiComponent" in btnNotificationObject == true &&
				btnNotificationObject.uiComponent != null)
					btnNotificationObject.uiComponent.isSelected = Auth.getPushNitificationsAllowed();
			if ("uiComponent" in btnSoundMsgObject == true &&
				btnSoundMsgObject.uiComponent != null)
					btnSoundMsgObject.uiComponent.isSelected = GlobalSettings.soundOnMessages;
			if ("uiComponent" in btnSoundCallObject == true &&
				btnSoundCallObject.uiComponent != null)
					btnSoundCallObject.uiComponent.isSelected = GlobalSettings.soundOnCalls;
			if ("uiComponent" in btnShowRatingObject == true &&
				btnShowRatingObject.uiComponent != null)
					btnShowRatingObject.uiComponent.isSelected = Auth.showRating == 1;
			/*if ("uiComponent" in btnSocialObject == true &&
				btnSocialObject.uiComponent != null) {
					if (SocialManager.getCheckerState() == 0)
						btnSocialObject.uiComponent.isSelected = SocialManager.available;
					else if (SocialManager.getCheckerState() == 1)
						btnSocialObject.uiComponent.isSelected = true;
					else
						btnSocialObject.uiComponent.isSelected = false;
			}*/
		}
		
		override protected function drawView():void {
			echo("SettingsScreen", "drawView", "");
			var s:String = Auth.hasFXName() ? Auth.getFXName() : Auth.username;
			var ibmd:ImageBitmapData = TextUtils.createTextFieldData(
				Auth.hasFXName() ? Auth.getFXName() : Auth.username,
				FIT_WIDTH - userNameEditButton.width * 2 - Config.MARGIN * 2,
				10,
				false,
				TextFormatAlign.LEFT,
				TextFieldAutoSize.LEFT,
				Config.FINGER_SIZE * .4,
				false,
				Style.color(Style.COLOR_TEXT),
				Style.color(Style.COLOR_BACKGROUND),
				true
			);
			userNameEdit.setBitmapData(ibmd, true);
			userNameEdit.y = avatarBox.y + AVATAR_SIZE + Config.MARGIN * 2;
			userNameEdit.x = int(_width * .5 - userNameEdit.width * .5);
			
			userNameEditButton.x = int(userNameEdit.x + userNameEdit.width + Config.MARGIN*2);
			userNameEditButton.y = int(userNameEdit.y + userNameEdit.height * .5 - userNameEditButton.height * .5);
			
			if (Auth.hasFXName() == true && Auth.fxcommID != 0) {
				if (userNameBitmap == null) {
					userNameBitmap = new Bitmap();
					userNameBitmap.bitmapData = UI.renderText(Auth.login, FIT_WIDTH, 10, false, TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .3, false, AppTheme.RED_MEDIUM, 0xffcccc, true);
					userNameBitmap.x = int(_width * .5 - userNameBitmap.width * .5);
					userNameBitmap.y = userNameEditButton.y + userNameEditButton.height + Config.MARGIN*.3;
					scrollPanel.addObject(userNameBitmap);
				}
			} else {
				if (userNameBitmap != null) {
					scrollPanel.removeObject(userNameBitmap);
					UI.destroy(userNameBitmap);
					userNameBitmap = null;
				}
			}
			
			var trueY:int;
			if (userNameBitmap == null)
				trueY = userNameEditButton.y + userNameEditButton.height + Config.MARGIN*.3;
			else
				trueY = userNameBitmap.y + userNameBitmap.height + Config.MARGIN*.3;
			
			if (phoneNumberBitmap.x == trueY)
				return;
			
			phoneNumberBitmap.y = trueY;
			trueY += phoneNumberBitmap.height + Config.MARGIN;
			
			if (floweSticker != null)
			{
				floweSticker.y = trueY;
				floweSticker.x = int(_width * .5 - floweSticker.width * .5);
				trueY += Config.FINGER_SIZE * 1.4 + Config.MARGIN;
			}
			
			trueY += Config.MARGIN;
			
			if (buttons != null)
			{
				var l:int = buttons.length;
				for (var i:int = 0; i < l; i++) {
					if (buttons[i] != null && buttons[i].uiComponent != null)
					{
						buttons[i].uiComponent.y = trueY;
						if ("viewHeight" in buttons[i].uiComponent)
						{
							trueY += buttons[i].uiComponent.viewHeight;
						}
						else
						{
							trueY += Config.MARGIN * 2 * 1.2;
						}
					}
				}
			}
			
			trueY += Config.MARGIN;
			versionBitmap.y = trueY;
			bottomClip.y = versionBitmap.y + versionBitmap.height + Config.MARGIN * 1.5;
			
			scrollPanel.setWidthAndHeight(_width, _height);
			
			scrollPanel.update();
		}
		
		override public function activateScreen():void {
			if (_isDisposed)
				return;
			if (ReferralProgram.isAvaliable() == true && 
				ReferralProgram.canEnerCodeStatus == false && 
				enterReferralCodeButtonExist == true) {
					clearButtons();
					createButtonsData();
					createButtons();
					updateSettings();
					drawView();
					drawVersion();
			}
			super.activateScreen();
			var btnsLength:int = 0;
			if (buttons != null)
				btnsLength = buttons.length;
			for (var i:int = 0; i < btnsLength; i++)
			{
				if ("activate" in buttons[i].uiComponent)
				{
					buttons[i].uiComponent.activate();
				}
			}
			
			userNameEdit.activate();
			userNameEditButton.activate();
			scrollPanel.enable();
			PointerManager.addTap(avatarBox, onAvatarTap);
			if (!lastLoadedImageName && Auth.avatar != null)
				ImageManager.loadImage(Auth.getLargeAvatar(AVATAR_SIZE), onAvatarLoaded);
			if (updateOnActivate == true)
				onAuthDataUpdated();
		}
		
		private function onAuthDataUpdated():void {
			
			updateAvatar();
			
			if (_isActivated == false) {
				updateOnActivate = true;
				return;
			}
			updateOnActivate = false;
			if (buttons == null || buttons.length < 4)
				return;
			if (btnShowRatingObject != null && btnShowRatingObject.uiComponent != null)
			{
				btnShowRatingObject.uiComponent.isSelected = Auth.showRating == 1;
			}
		}
		
		override public function deactivateScreen():void {
			if (_isDisposed)
				return;
			super.deactivateScreen();
			var btnsLength:int = 0;
			if (buttons != null)
				btnsLength = buttons.length;
			for (var i:int = 0; i < btnsLength; i++)
			{
				if ("deactivate" in buttons[i].uiComponent)
				{
					buttons[i].uiComponent.deactivate();
				}
			}
			userNameEdit.deactivate();
			userNameEditButton.deactivate();
			scrollPanel.disable();
			PointerManager.removeTap(avatarBox, onAvatarTap);
		}
		
		private function lockScreen():void {
			echo("SettingsScreen", "lockScreen");
			displayPreloader();
			deactivateScreen();
		}
		
		private function unlockScreen():void {
			echo("SettingsScreen", "unlockScreen");
			hidePreloader();
			activateScreen();
		}
		
		private function displayPreloader():void {
			if (preloaderAvatar == null) {
				preloaderAvatar = new Preloader();
				preloaderAvatar.x = _width * .5;
				preloaderAvatar.y = avatarBox.y + AVATAR_SIZE * .5;
				scrollPanel.addObject(preloaderAvatar);
			}
			preloaderAvatar.show();
		}
		
		private function hidePreloader():void {
			preloaderAvatar.hide();
		}
		
		private function onTitleEditTap():void {
			echo("SettingsScreen", "editTitle");
			
			ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, FillUserInfoScreen, {defaultName:(Auth.getFirstName() + " " + Auth.getLastName())});
			
			/*MobileGui.changeMainScreen(EditUserInfoScreen, {
				backScreen: SettingsScreen,
				backScreenData: data
			}, ScreenManager.DIRECTION_RIGHT_LEFT);*/
		}
		
		private function onAvatarTap(e:Event = null):void {
			changeAvatar();
		}
		
		private function changeAvatar():void {
			echo("SettingsScreen", "changeAvatar");
			if (avatarUploading)
				return;
			var menuItems:Array = [];
			menuItems.push( { fullLink:Lang.selectFromGallery, id:0, icon:GalleryIcon } );
			menuItems.push( { fullLink:Lang.makePhoto, id:1, icon:PhotoShotIcon } );
			DialogManager.showSelectItemDialog( { callBack:onAvatarChangeMethod, itemClass:ListLinkWithIcon, listData:menuItems, title:Lang.changeAvatar } );
		}
		
		private function onAvatarChangeMethod(val:int):void {
			if (val == -1)
				return;
			if (val == 0) {
				PhotoGaleryManager.S_GALLERY_IMAGE_LOADED.add(onAvatarSelected);
				lockScreen();
				PhotoGaleryManager.takeImage(false);
				return;
			}
			if (val == 1) {
				PhotoGaleryManager.S_GALLERY_IMAGE_LOADED.add(onAvatarSelected);
				lockScreen();
				PhotoGaleryManager.takeCamera(false);
				return;
			}
		}
		
		private function onAvatarSelected(success:Boolean, image:ImageBitmapData, message:String):void {
			echo("SettingsScreen", "onAvatarFromDeviceImageSelected");
			PhotoGaleryManager.S_GALLERY_IMAGE_LOADED.remove(onAvatarSelected);
			if (success && image && !isNaN(image.width)) {
				showImagePreview(image);
			} else { //!TODO: добавить отправку сообщения об ошибке?;
				unlockScreen();
				avatarUploading = false;
				if (message)
					DialogManager.alert(Lang.textWarning, message);
			}
		}
		
		private function showImagePreview(image:ImageBitmapData):void {
			echo("SettingsScreen", "showImagePreview");
			var currentImage:ImageBitmapData = new ImageBitmapData("SettingsScreen.previewImg", image.width, image.height);
			currentImage.copyPixels(image, image.rect, new Point(0, 0));
			image.dispose();
			image = null;
			if (currentImage.width > Config.BITMAP_SIZE_MAX || currentImage.height > Config.BITMAP_SIZE_MAX)
				currentImage = ImageManager.resize(currentImage, Config.BITMAP_SIZE_MAX, Config.BITMAP_SIZE_MAX, ImageManager.SCALE_INNER_PROP);
			deactivateScreen();
			if (imageCropper == null)
				imageCropper = new ImagePreviewCrop();
			imageCropper.display(currentImage, onCropDone, onCropCancel);
		}
		
		private function onCropDone(imageData:ImageBitmapData):void {
			echo("SettingsScreen", "onCropDone");
			activateScreen();
			imageCropper.clearCurrent();
			updateAvatarWithBitmapData(imageData);
		}
		
		private function onCropCancel():void {
			echo("SettingsScreen", "onCropCancel");
			imageCropper.clearCurrent();
			unlockScreen();
		}
		
		private function updateAvatarWithBitmapData(image:ImageBitmapData):void {
			echo("SettingsScreen", "updateAvatarWithBitmapData");
			if (image.isDisposed)
				return;
			
			avatarUploading = true;
			
			if (image.width > Config.USER_AVATAR_SIZE_MAX || image.height > Config.USER_AVATAR_SIZE_MAX) {
				image = ImageManager.resize(image, Config.USER_AVATAR_SIZE_MAX, Config.USER_AVATAR_SIZE_MAX, ImageManager.SCALE_INNER_PROP, false, false);
			}
			
			var imageToSave:ImageBitmapData = new ImageBitmapData("SettingsScreen.avatarSaveServerImageData", image.width, image.height);
			imageToSave.copyPixels(image, image.rect, new Point(0, 0));
			
			uploadAvatarImage(imageToSave);
			imageToSave = null;
			onAvatarLoaded("custom", ImageManager.resize(image, AVATAR_SIZE, AVATAR_SIZE, ImageManager.SCALE_NONE, false, false));
			image.dispose();
			image = null;
		}
		
		private function uploadAvatarImage(image:ImageBitmapData):void {
			echo("SettingsScreen", "uploadAvatarImage");
			changeAvatarRequest = createRequestId();
			encodeAvatar(image);
		}
		
		private function createRequestId():String {
			return MD5.hash(getTimer().toString());
		}
		
		private function encodeAvatar(image:ImageBitmapData):void {
			echo("SettingsScreen", "encodeAvatar");
			var pngImage:ByteArray = image.encode(image.rect, new JPEGEncoderOptions(87));
			image.dispose();
			image = null;
			var imageString:String = "data:image/jpeg;base64," + Base64.encodeByteArray(pngImage);
			avatarUploading = true;
			Auth.S_PROFILE_CHANGE.add(onAvatarImageChanged);
			Auth.changeAvatar(imageString, changeAvatarRequest);
			imageString = null;
			pngImage = null;
		}
		
		private function onAvatarImageChanged(result:Object):void {
			echo("SettingsScreen", "onAvatarImageChanged");
			if (result.requestId != changeAvatarRequest)
				return;
			unlockScreen();
			changeAvatarRequest = null;
			Auth.S_PROFILE_CHANGE.remove(onAvatarImageChanged);
			ChatManager.S_LATEST.invoke();
			avatarUploading = false;
		}
		
		private function onAvatarLoaded(url:String, bmd:ImageBitmapData):void {
			echo("SettingsScreen", "onAvatarLoaded", "");
			if (isDisposed)
				return;
			if (!bmd)
				return;
			LOADED_AVATAR_BMD ||= new ImageBitmapData("SettingsScreen.LOADED_AVATAR_BMD", AVATAR_SIZE, AVATAR_SIZE);
			lastLoadedImageName = url;
			ImageManager.drawCircleImageToBitmap(LOADED_AVATAR_BMD, bmd, 0, 0, AVATAR_SIZE * .5);
			
			bmd = null;
			updateAvatarBMD();
		}
		
		private function updateAvatarBMD():void {
			echo("SettingsScreen", "updateAvatarBMD");
			if (avatarBitmap == null)
				return;
			if (LOADED_AVATAR_BMD != null) {
				UI.disposeBMD(EMPTY_AVATAR_BMD);
				EMPTY_AVATAR_BMD = null;
				avatarBitmap.bitmapData = LOADED_AVATAR_BMD;
			} else{
				avatarBitmap.bitmapData = getEmptyAvatar();
			}
			scrollPanel.updateObjects();
		}
		
		private function getEmptyAvatar():BitmapData {
			EMPTY_AVATAR_BMD ||= UI.drawAssetToRoundRect(new SWFEmptyAvatar(), AVATAR_SIZE);//UI.getEmptyAvatarBitmapData(AVATAR_SIZE, AVATAR_SIZE);
			return EMPTY_AVATAR_BMD;
		}
		
		private function onNotificationTap(value:Boolean):void {
			Auth.changeNotifications(value);
		}
		
		private function onSoundMsgTap(value:Boolean):void {
			GlobalSettings.setSoundOnMessages(value);
		}
		
		private function onSoundCallTap(value:Boolean):void {
			GlobalSettings.setSoundOnCalls(value);
		}
		
		/*private function onSocialTap(value:Boolean):void {
			SocialManager.changeState(value);
		}*/
		
		private function onShowRatingTap(value:Boolean):void {
			Auth.setShowRating(value, onRatingSaved);
			btnShowRatingObject.uiComponent.deactivate();
			btnShowRatingObject.uiComponent.isLoading = true;
		}
		
		private function onRatingSaved():void {
			btnShowRatingObject.uiComponent.activate();
			btnShowRatingObject.uiComponent.isLoading = false;
		}
		
		private function onMySubscriptionsTap():void {
			Shop.showMySubscriptions();
		}
		
		private function onMyProductsTap():void {
			Shop.showMyProducts();
		}
		
		private function onMyPaidChatsTap():void {
			MobileGui.changeMainScreen(PaidChatsScreen);
		}
		private function onPrivacyTap():void {
			MobileGui.changeMainScreen(PrivacySettingsScreen);
		}
		
		private function onAccountTap():void {
			MobileGui.openMyAccountIfExist();
		}
		
		private function onFXCommTap():void {
			var nativeAppExist:Boolean = false;
			if (Config.PLATFORM_ANDROID == true && MobileGui.androidExtension != null)
				nativeAppExist = MobileGui.androidExtension.launchFXComm("profile", Auth.login);
			else if (Config.PLATFORM_APPLE == true && MobileGui.dce != null)
				nativeAppExist = MobileGui.dce.launchFXComm("profile", Auth.login);
			if (nativeAppExist == false)
				navigateToURL(new URLRequest(Config.URL_FXCOMM_PROFILE + Auth.login));
		}
		
		private function on911SectionTap():void {
			MobileGui.changeMainScreen(UserQuestionsStatScreen);
		}
		
		private function onReferralSectionTap():void {
			MobileGui.changeMainScreen(ReferralProgramScreen);
		}
		
		private function onLanguageTap():void {
			
			/*(new OpenOtherApplicationsAction()).execute();
			
			return;*/
			
			var langs:Array = LangManager.getAvailableLanguages();
			if (langs == null || langs.length == 0)
				DialogManager.alert(Lang.textAlert, Lang.pleaseTryLater);
			else
			{
				DialogManager.showDialog(
					ListSelectionPopup,
					{
						items:langs,
						title:Lang.setLanguage,
						renderer:ListLinkWithIcon,
						callback:onNewLanguage
					}, DialogManager.TYPE_SCREEN
				);
			//	DialogManager.showSelectItemDialog( { callBack:onNewLanguage, itemClass:ListLinkWithIcon, listData:langs, title:Lang.setLanguage } );
			}
		}
		
		private function onUnbanPaidButtonTap():void {
			PaidBan.paidUnbanUser(Auth.myProfile);
		}
		
		private function onBuyProtectionButtonTap():void {
			PaidBan.buyProtection();
		}
		
		private function onShowProtectionButtonTap():void {
			PaidBan.showProtection(Auth.myProfile);
		}
		
		private function onShowMyBansButtonTap():void {
			PaidBan.showMyBans();
		}
		
		private function onShowFlowersButtonTap():void {
			UserExtensionsManager.showExtensionsList();
		}
		
		private function onNewLanguage(selectedLang:Object, val:int):void {
			if (val == -1)
				return;
			showLanguagePreloader();
			LangManager.selectLangByIndex(val, onLanguageChanged);
		}
		
		private function showLanguagePreloader():void {
			var buttonData:Object;
			if (buttons != null) {
				var l:int = buttons.length;
				for (var i:int = 0; i < l; i++) {
					if (buttons[i] != null && ("id" in buttons[i]) && buttons[i].id == 5) {
						if (buttons[i].uiComponent != null && (buttons[i].uiComponent is BitmapButton)) {
							buttonData = buttons[i];
							break;
						}
					}
				}
			}
			if (buttonData != null)	{
				var iconL:DisplayObject;
				if (buttonData.iconL != undefined && buttonData.iconL != null)
					iconL = new buttonData.iconL();
				if (buttonData.type == "button") {
					if (iconL != null)
						UI.scaleToFit(iconL, BTN_ICON_LEFT_SIZE, BTN_ICON_LEFT_SIZE);
					var ibmd:BitmapData = UI.renderSettingsTextAdvanced(
						buttonData.title,
						FIT_WIDTH,
						OPTION_LINE_HEIGHT,
						false,
						TextFormatAlign.LEFT,
						TextFieldAutoSize.NONE,
						Config.FINGER_SIZE * 0.34,
						false,
						AppTheme.GREY_DARK,
						0,
						0,
						iconL,
						null
					);
					UI.destroy(iconL);
					iconL = null;
					(buttonData.uiComponent as BitmapButton).setBitmapData(ibmd, true);
				}
			}
			
			currentIndicatorHolder = buttonData.uiComponent as BitmapButton;				
			if (busyIndicator == null) {
				busyIndicator = new Preloader(Config.FINGER_SIZE * .4);
			}			
			if (currentIndicatorHolder != null) {
				busyIndicator.y = currentIndicatorHolder.height * .5;
				busyIndicator.x = currentIndicatorHolder.width - Config.FINGER_SIZE * .2;
				currentIndicatorHolder.addChild(busyIndicator);
				busyIndicator.show();
			}
		}
		
		override public function drawViewLang():void {
			onLanguageChanged();
		}
		
		private function onLanguageChanged():void {
			if (_isDisposed == true)
				return;
			hideLanguagePreloader();
			
			btnNotificationObject.title = Lang.textNotifications;
			btnSoundMsgObject.title = Lang.soundsOnMessages;
			btnSoundCallObject.title = Lang.soundsOnCall;
			btn911SectionObject.title = Lang.section911My;
			btnReferralSectionObject.title = Lang.referralProgram;
			btnReferralEnterCodeObject.title = Lang.enterReferralCode;
			btnFXCommObject.title = Lang.communityProfile;
			btnLanguageObject.title = Lang.setLanguage;
			btnUnbanObject.title = Lang.getOutOfJail;
			btnBuyProtectionObject.title = Lang.buyBanProtection;
			btnShowProtectionObject.title = Lang.banProtection;
			btnShowMyBansObject.title = Lang.myBans;
			btnLogoutObject.title = Lang.logout;
			btnOneClickObject.title = Lang.oneClickPayments;
			btnShowRatingObject.title = Lang.showRating;
			btnOpenAccountObject.title = Lang.openAccount;
			btnMyAccountObject.title = Lang.myAccount;
			
			clearButtons();
			createButtonsData();
			createButtons();
			updateSettings();
			drawView();
			drawVersion();
			if (_isActivated) {
				activateScreen();
			}
		}
		
		private function hideLanguagePreloader():void {
			if (busyIndicator != null) {
				busyIndicator.hide(true);
				busyIndicator = null;
			}
			currentIndicatorHolder = null;
		}
		
		private function clearButtons():void {
			if (buttons != null) {
				while (buttons.length > 0) {
					if ("uiComponent" in buttons[0] && buttons[0].uiComponent != null) {
						if (buttons[0].uiComponent is Sprite == true)
						{
							UI.destroy(buttons[0].uiComponent);
						}
						else
						{
							buttons[0].uiComponent.dispose();
						}
					}
					
					buttons.shift();
				}
			}
		}
		
		private function onLogoutTap():void {
			DialogManager.alert(Lang.textWarning, Lang.areYouSureLogout, onLogoutDialogClose, Lang.logout, Lang.textCancel);
		}
		
		private function onTimeSelected(val:int, data:Object, timeData:Object):void 
		{
			trace(timeData.startTime, timeData.endTime);
		}
		
		private function onOneClickTap():void {
			echo("SettingsScreen", "onOneClickTap");

			// а если блять счёта нет, че делать?
			if(Auth.bank_phase!=null && Auth.bank_phase.toLowerCase()!="acc_approved")
				return;

			var backScreenData:PaymentsScreenData =	new PaymentsScreenData();
			backScreenData.backScreen = RootScreen;
			backScreenData.backScreenData = data;
			backScreenData.autofillData.invokedFromMainSetting = true;
			MobileGui.changeMainScreen(
				PaymentsSettingsOneClickScreen,
				backScreenData,
				ScreenManager.DIRECTION_RIGHT_LEFT
			);
		}
		
		private function onLogoutDialogClose(val:int):void {
			if (val != 1)
				return;
			Auth.clearAuthorization();
		}
		
		override public function dispose():void {
			if (_isDisposed)
				return;
			super.dispose();
			if (floweSticker != null) {
				PointerManager.removeTap(floweSticker, flowerStickerClicked);
				floweSticker.dispose();
				floweSticker = null;
			}
			UI.destroy(bottomClip);
			bottomClip = null;
			if (scrollPanel != null) 
				scrollPanel.dispose();
			scrollPanel = null;
			UI.destroy(avatarBitmap);
			avatarBitmap = null;
			UI.destroy(userNameBitmap);
			userNameBitmap = null;
			UI.destroy(phoneNumberBitmap);
			phoneNumberBitmap = null;
			UI.destroy(versionBitmap);
			versionBitmap = null;
			UI.destroy(avatarBox);
			avatarBox = null;
			if (preloaderAvatar != null)
				preloaderAvatar.dispose();
			preloaderAvatar = null;
			if (imageCropper != null)
				imageCropper.dispose();
			imageCropper = null;
			if (userNameEdit != null)
				userNameEdit.dispose();
			userNameEdit = null;
			if (userNameEditButton != null)
				userNameEditButton.dispose();
			userNameEditButton = null;
			if (toad != null && toad.parent != null)
				toad.parent.removeChild(toad);
			toad = null;
			if (LOADED_AVATAR_BMD && avatarBitmap && avatarBitmap.bitmapData == LOADED_AVATAR_BMD)
				avatarBitmap.bitmapData = null;
			if (LOADED_AVATAR_BMD)
				LOADED_AVATAR_BMD = null;
			UI.disposeBMD(EMPTY_AVATAR_BMD);
			EMPTY_AVATAR_BMD = null;
			hideLanguagePreloader();
			clearButtons();
			if (extensions != null) {
				var l:int = extensions.length;
				for (var i:int = 0; i < l; i++) {
					UI.destroy(extensions[i]);
				}
				extensions = null;
			}
			_data = null;
			Auth.S_PROFILE_CHANGE.remove(onAvatarImageChanged);
			Auth.S_AUTH_DATA_UPDATED.remove(onAuthDataUpdated);
			Auth.S_PHAZE_CHANGE.remove(onPhazeChanged);
			PhotoGaleryManager.S_GALLERY_IMAGE_LOADED.remove(onAvatarSelected);
			ReferralProgram.S_UPDATED.remove(onReferralProgramUpdated);
			WSClient.S_PUSH_GLOBAL_STATUS.remove(onNotofocationStatusChanged);
			PaidBan.S_USER_BAN_UPDATED.remove(onPaidBanChanged);
			GlobalSettings.S_UPDATE.remove(onSettingsChanged);
			UsersManager.S_TOAD_UPDATED.remove(addToad);
		}
	}
}