package com.dukascopy.connect.screens {
	
	import assets.BlockUserIcon;
	import assets.ButtonCallContent;
	import assets.ButtonChatContent;
	import assets.ButtonInviteContent;
	import assets.ButtonPayContent;
	import assets.ButtonPayInactiveContent;
	import assets.CommunityIconGrey;
	import assets.DesktopOnlineButton;
	import assets.IconArrowRight;
	import assets.IconOnlineStatusWeb;
	import assets.MobileOnlineButton;
	import assets.PhotoShotIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.customActions.OpenFxProfileAction;
	import com.dukascopy.connect.gui.components.Counter;
	import com.dukascopy.connect.gui.image.ImageFrames;
	import com.dukascopy.connect.gui.lightbox.LightBox;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.scrollPanel.ScrollPanel;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.base.ScreenManager;
	import com.dukascopy.connect.screens.payments.PaymentsScreen;
	import com.dukascopy.connect.screens.payments.PaymentsSendMoneyScreen;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.callManager.CallManager;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.connectionManager.NetworkManager;
	import com.dukascopy.connect.sys.contactsManager.UserProfileManager;
	import com.dukascopy.connect.sys.contentProvider.FXImagesListContentProvider;
	import com.dukascopy.connect.sys.contentProvider.IContentProvider;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.phonebookManager.PhonebookManager;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.sys.usersManager.OnlineStatus;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.sys.ws.WS;
	import com.dukascopy.connect.sys.ws.WSClient;
	import com.dukascopy.connect.type.ChatInitType;
	import com.dukascopy.connect.type.ChatRoomType;
	import com.dukascopy.connect.type.ImageContextMenuType;
	import com.dukascopy.connect.type.MainColors;
	import com.dukascopy.connect.type.UserBlockStatusType;
	import com.dukascopy.connect.vo.ChatVO;
	import com.dukascopy.connect.vo.UserProfileVO;
	import com.dukascopy.connect.vo.screen.ChatScreenData;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.LineScaleMode;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.text.TextLineMetrics;
	
	/**
	 * ...
	 * @author Dobarin Sergey
	 */
	
	public class UserProfileScreenOld extends BaseScreen {
		
		private const OFFLINE:String = "off";
		private const ONLINE:String = "on";
		
		private var title:Bitmap;
		private var phoneTextField:Bitmap;
		private var statusTxt:Bitmap;
		private var bgHeader:Bitmap;
		private var backButton:BitmapButton;
		private var max_text_width:int;
		private var bgRect:Rectangle;
		private var status:Sprite;
		private var bgBMD:BitmapData;
		private var avatarSize:Number;
		private var avatarBox:Sprite;
		private var avatar:Bitmap;
		private var iconSystem:Bitmap;
		private var fxnme:Bitmap;
		private var serviceTextField:TextField;
		private var buttonChat:BitmapButton;
		private var buttonCall:BitmapButton;
		private var buttonPay:BitmapButton;
		private var buttonInvite:BitmapButton;
		private var circleButtonsSize:int;
		private var scrollPanel:ScrollPanel;
		
		private var LOADED_AVATAR_BMD:ImageBitmapData;
		private var EMPTY_AVATAR_BMD:ImageBitmapData;
		private var headerSize:int;
		
		private var OPTION_LINE_HEIGHT:int = Config.FINGER_SIZE *.8;
		private var iconSize:Number;
		private var openCommunityPageButton:BitmapButton;
		private var questionsStatButton:BitmapButton;
		private var iconArrowSize:Number;
		private var lineDelimiter:Sprite;
		//private var deviceText:Bitmap;
		private var iconDesktop:ImageFrames;
		private var iconMobile:ImageFrames;
		private var phoneContainer:Sprite;
		//private var onlineStatusContainer:Sprite;
		private var iconSystemContainer:Sprite;
		private var buttonChatContainer:Sprite;
		private var buttonCallContainer:Sprite;
		private var buttonPayContainer:Sprite;
		private var buttonInviteContainer:Sprite;
		private var lineDelimiterContainer:Sprite;
		private var openCommunityPageButtonContainer:Sprite;
		private var questionsStatButtonContainer:Sprite;
		
		private var invitedButton:BitmapButton;
		private var buttonInvitedContainer:Sprite;
		
		private var blockUserButton:BitmapButton;
		private var blockUserButtonContainer:Sprite;
		private var isUserblocked:Boolean;
		
		private var banUserButton:BitmapButton;
		private var banUserButtonContainer:Sprite;
		
		private var zeroRatingButton:BitmapButton;
		private var zeroRatingButtonContainer:Sprite;
		
		private var buttonPaddingLeft:int;
		private var FIT_WIDTH:int;
		private var lineDelimiter2:Sprite;
		private var lineDelimiter2Container:Sprite;
		private var iconDesktopContainer:Sprite;
		private var iconMobileContainer:Sprite;
		private var iconWeb:ImageFrames;
		private var iconWebContainer:Sprite;
		private var buttonPayWithoutPhone:BitmapButton;
		private var buttonPayWithoutPhoneContainer:Sprite;
		private var dataLoadingState:Boolean;
		private var userModel:UserProfileVO;
		private var validAvatarURL:String;
		private var imageCounter:Bitmap;
		private var fxPhotos:FXImagesListContentProvider;
		
		public function UserProfileScreenOld() { }
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			_params.title = "User profile screen";
			_params.doDisposeAfterClose = true;
			
			dataLoadingState = false;
			
			userModel = UserProfileManager.getUserData(data.data);
			
			if (userModel == null || userModel.uid == null)
			{
				//!TODO: ошибка;
				onBack();
				return;
			}
			
			LightBox.S_LIGHTBOX_OPENED.add(onLightboxOpen);
			LightBox.S_LIGHTBOX_CLOSED.add(onLightboxClose);
			
			if (userModel.fxId != 0)
			{
				fxPhotos = new FXImagesListContentProvider();
				fxPhotos.setData(userModel);
				fxPhotos.S_COMPLETE.add(onFxPhotosLoaded);
				fxPhotos.S_ERROR.add(onFxPhotosLoadError);
				fxPhotos.execute();
			}
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
		
		private function onFxPhotosLoaded():void {
			if (isDisposed == false) {
				if (fxPhotos != null)
				{
					var images:Array = fxPhotos.getResult();
					
					if (images != null && images.length > 0 && imageCounter != null)
					{
						imageCounter.bitmapData = Counter.draw(PhotoShotIcon, "+" + images.length.toString());
						imageCounter.x = int(_width * .5 - imageCounter.width * .5);
						imageCounter.y = int(Config.MARGIN * 1.95 + avatarSize * 2 - imageCounter.height * .7);
						imageCounter.visible = true;
						imageCounter.alpha = 0;
						
						if (isActivated)
						{
							TweenMax.to(imageCounter, 0.5, { alpha:1, delay:0.5 } );
						}
					}
				}
			}
			clearFxPhotos();
		}
		
		override public function onBack(e:Event = null):void
		{
			if (data.backScreen != undefined && data.backScreen != null) {
				MobileGui.changeMainScreen(data.backScreen, data.backScreenData, ScreenManager.DIRECTION_LEFT_RIGHT);
				return;
			}
			MobileGui.changeMainScreen(RootScreen, null, ScreenManager.DIRECTION_LEFT_RIGHT);
		}
		
		override protected function createView():void
		{
			super.createView();
			//size variables;
			headerSize = int(Config.FINGER_SIZE * .85);
			avatarSize = int(Config.FINGER_SIZE * 1.54);
			iconSize = Config.FINGER_SIZE * 0.36;
			iconArrowSize = Config.FINGER_SIZE * 0.30;
			buttonPaddingLeft = Config.MARGIN * 3;
			var btnSize:int = headerSize * .38;
			var btnY:int = (headerSize - btnSize) * .5;
			var btnOffset:int = (Config.FINGER_SIZE - btnSize) * .5;
			
			bgRect = new Rectangle(0, 0, 1, Config.APPLE_TOP_OFFSET);
			
			//header background;
			bgHeader = new Bitmap();
			_view.addChild(bgHeader);
			
			//scroller component;
			scrollPanel = new ScrollPanel();
			scrollPanel.background = true;
			scrollPanel.backgroundColor = MainColors.WHITE;
			_view.addChild(scrollPanel.view);
			
			status = new Sprite();
			_view.addChild(status);
			statusTxt = new Bitmap(null, "auto", true);
			status.addChild(statusTxt);
			
			//back header button;
			backButton = new BitmapButton();
			backButton.setStandartButtonParams();
			backButton.setDownScale(1.3);
			backButton.setDownColor(0xFFFFFF);
			backButton.tapCallback = onBack;
			backButton.disposeBitmapOnDestroy = true;
			backButton.show();
			_view.addChild(backButton);
			var icoBack:IconBack = new IconBack();
			icoBack.width = icoBack.height = btnSize;
			backButton.setBitmapData(UI.getSnapshot(icoBack, StageQuality.HIGH, "UserProfileScreen.buttonBack"), true);
			backButton.x = btnOffset;
			backButton.y = btnY + Config.APPLE_TOP_OFFSET;
			backButton.setOverflow(btnOffset, btnOffset, Config.FINGER_SIZE, btnOffset + Config.FINGER_SIZE*.3);
			UI.destroy(icoBack);
			icoBack = null;
			
			//header title;
			title = new Bitmap(null, "auto", true);
			_view.addChild(title);
			
			//user phone text;
			phoneTextField = new Bitmap(null, "auto", true);
			phoneContainer = new Sprite();
			phoneContainer.addChild(phoneTextField);
			scrollPanel.addObject(phoneContainer);
			
			//community name;
			fxnme = new Bitmap(null, "auto", true);
			
			//community avatar;
			avatarBox = new Sprite();
			avatar = new Bitmap();
			avatarBox.addChild(avatar);
			scrollPanel.addObject(avatarBox);
			
			//community icon;
			
			var communityIcon:IconLogoCircle = new IconLogoCircle();
			communityIcon.width = communityIcon.height = int(Config.FINGER_SIZE * 0.25);
			iconSystem = new Bitmap();
			iconSystem.bitmapData = UI.getSnapshot(communityIcon, StageQuality.HIGH, "UserProfileScreen.iconSystem");
			UI.destroy(communityIcon);
			communityIcon = null;
			
			iconSystemContainer = new Sprite();
			iconSystemContainer.addChild(iconSystem);
			iconSystemContainer.addChild(fxnme);
			scrollPanel.addObject(iconSystemContainer);
			
			//used for custom textfields rendering;
			serviceTextField = new TextField();
			
			//main circle buttons
			circleButtonsSize = Config.FINGER_SIZE*1.3;
			
			//main circle buttons;
			buttonChat = addCircleButton(new ButtonChatContent());
			buttonCall = addCircleButton(new ButtonCallContent());
			buttonPay = addCircleButton(new ButtonPayContent());
			buttonPayWithoutPhone = addCircleButton(new ButtonPayInactiveContent());
			buttonInvite = addCircleButton(new ButtonInviteContent());
			buttonChatContainer = new Sprite();
			buttonPayWithoutPhoneContainer = new Sprite();
			buttonCallContainer = new Sprite();
			buttonPayContainer = new Sprite();
			buttonInviteContainer = new Sprite();
			buttonInvitedContainer = new Sprite();
			buttonChatContainer.addChild(buttonChat);
			buttonCallContainer.addChild(buttonCall);
			buttonPayContainer.addChild(buttonPay);
			buttonInviteContainer.addChild(buttonInvite);
			buttonPayWithoutPhoneContainer.addChild(buttonPayWithoutPhone);
			scrollPanel.addObject(buttonChatContainer);
			scrollPanel.addObject(buttonCallContainer);
			scrollPanel.addObject(buttonPayContainer);
			scrollPanel.addObject(buttonInviteContainer);
			scrollPanel.addObject(buttonPayWithoutPhoneContainer);
			
			//invited button;
			var invitedButtonContent:Sprite = new Sprite();
			invitedButtonContent.graphics.beginFill(MainColors.GREY_LIGHT2);
			invitedButtonContent.graphics.drawCircle(circleButtonsSize/2, circleButtonsSize/2, circleButtonsSize / 2);
			invitedButtonContent.graphics.endFill();
			var inviteButtonText:TextField = new TextField();
					var format:TextFormat = new TextFormat()
					format.color = MainColors.WHITE;
					format.size = 50;
					format.font = Config.defaultFontName;
					inviteButtonText.defaultTextFormat = format;
					inviteButtonText.autoSize = TextFieldAutoSize.LEFT;
					inviteButtonText.text = Lang.textInvited;
					inviteButtonText.scaleX = ((circleButtonsSize - Config.MARGIN * 2) / inviteButtonText.width);
					inviteButtonText.scaleY = inviteButtonText.scaleX;
					inviteButtonText.y = int((circleButtonsSize - inviteButtonText.height) * .5);
					inviteButtonText.x = int((circleButtonsSize - inviteButtonText.width) * .5)
			invitedButtonContent.addChild(inviteButtonText);
			
			invitedButton = addCircleButton(invitedButtonContent);
		//	invitedButton = new Bitmap();				
		//	invitedButton.bitmapData = UI.getSnapshot(invitedButtonContent);
			
			inviteButtonText.text = "";
			inviteButtonText = null;
			invitedButtonContent.graphics.clear();
			invitedButtonContent = null;
			format = null;
			
			buttonInvitedContainer.addChild(invitedButton);
			scrollPanel.addObject(buttonInvitedContainer);
			//end invited button;
			
			buttonChat.tapCallback = onChatButtonTap;
			buttonCall.tapCallback = onCallButtonTap;
			buttonPay.tapCallback = onPayButtonTap;
			buttonPayWithoutPhone.tapCallback = onPayButtonTap;
			buttonInvite.tapCallback = onInviteButtonTap;
			invitedButton.tapCallback = onInviteButtonTap;
			
			openCommunityPageButton = new BitmapButton();				
			openCommunityPageButton.setDownScale(1);
			openCommunityPageButton.setDownColor(0x000000);
			openCommunityPageButton.show(0);
			openCommunityPageButton.tapCallback = onCommunityButtonTap;
			openCommunityPageButtonContainer = new Sprite();
			openCommunityPageButtonContainer.addChild(openCommunityPageButton);
			scrollPanel.addObject(openCommunityPageButtonContainer);
			
			questionsStatButtonContainer = new Sprite();
			scrollPanel.addObject(questionsStatButtonContainer);
			
			//horizontal line;
			lineDelimiter = new Sprite();
			lineDelimiterContainer = new Sprite();
			lineDelimiterContainer.addChild(lineDelimiter);
			scrollPanel.addObject(lineDelimiterContainer);
			
			lineDelimiter2 = new Sprite();
			lineDelimiter2Container = new Sprite();
			lineDelimiter2Container.addChild(lineDelimiter2);
			scrollPanel.addObject(lineDelimiter2Container);
			
			//online status object;
			iconDesktop = new ImageFrames();
			iconWeb = new ImageFrames();
			iconMobile = new ImageFrames();
			var desktopOnline:DesktopOnlineButton = new DesktopOnlineButton();
			var mobileOnline:MobileOnlineButton = new MobileOnlineButton();
			var webOnline:IconOnlineStatusWeb = new IconOnlineStatusWeb();
			
			desktopOnline.height = int(Config.FINGER_SIZE * 0.35);
			mobileOnline.height = int(Config.FINGER_SIZE * 0.35);
			webOnline.height = int(Config.FINGER_SIZE * 0.35);
			
			desktopOnline.width = int(desktopOnline.scaleY*desktopOnline.width);
			mobileOnline.width = int(mobileOnline.scaleY * mobileOnline.width);
			webOnline.width = int(webOnline.scaleY*webOnline.width);
			
			iconDesktop.addFrame(desktopOnline, ONLINE);
			iconMobile.addFrame(mobileOnline, ONLINE);
			iconWeb.addFrame(webOnline, ONLINE);
			UI.destroy(desktopOnline);
			UI.destroy(mobileOnline);
			UI.destroy(webOnline);
			desktopOnline = null;
			mobileOnline = null;
			webOnline = null;
		
			iconMobile.toFrame(ONLINE);
			iconDesktop.toFrame(ONLINE);
			iconWeb.toFrame(ONLINE);
			
			iconDesktopContainer = new Sprite();
			iconDesktopContainer.addChild(iconDesktop);
			iconMobileContainer = new Sprite();
			iconMobileContainer.addChild(iconMobile);
			iconWebContainer = new Sprite();
			iconWebContainer.addChild(iconWeb);
			
			scrollPanel.addObject(iconDesktopContainer);
			scrollPanel.addObject(iconMobileContainer);
			scrollPanel.addObject(iconWebContainer);
			
			blockUserButton = new BitmapButton();
			blockUserButton.setDownScale(1);
			blockUserButton.setDownColor(0x000000);
			blockUserButton.show(0);
			blockUserButton.tapCallback = onBlockButtonTap;
			
			blockUserButtonContainer = new Sprite();
			blockUserButtonContainer.addChild(blockUserButton);
			scrollPanel.addObject(blockUserButtonContainer);
			
			imageCounter = new Bitmap();
			scrollPanel.addObject(imageCounter);
		}
		
		private function onQuestionsStatButtonTap():void {
			MobileGui.changeMainScreen(UserQuestionsStatScreen, { 
				userUID:userModel.uid, 
				backScreen:MobileGui.centerScreen.currentScreenClass, 
				backScreenData:MobileGui.centerScreen.currentScreen.data
			} );
		}
		
		//buttons hendlers
		private function onCallButtonTap():void{
			
			if (NetworkManager.isConnected == false){
				DialogManager.alert(Lang.textAlert, Lang.alertProvideInternetConnection);
				return;
			}
			
			if(WS.connected==false){
				DialogManager.alert(Lang.textAttention, Lang.checkNetworkStatus);
				return;
			}
			CallManager.place(userModel.uid, MobileGui.centerScreen.currentScreenClass, data, userModel.name, 
								UsersManager.getAvatarImage(userModel, userModel.avatarLargeURL, avatarSize*2));
		}
		
		private function onPayButtonTap():void
		{	
			if (userModel.hasPhone())
			{
				MobileGui.changeMainScreen(PaymentsScreen, {destinationScreen:PaymentsSendMoneyScreen, destinationPhone: userModel.phone, backScreen:MobileGui.centerScreen.currentScreenClass, backScreenData:data});
			}
			else
			{
				DialogManager.alert(null, Lang.userHasNoPhoneForPayment, function(val:int):void
				{
					if (val == 1)
						MobileGui.changeMainScreen(PaymentsScreen, {destinationScreen:PaymentsSendMoneyScreen,backScreen:MobileGui.centerScreen.currentScreenClass, backScreenData:data});
				},  Lang.textOk, Lang.textCancel.toUpperCase());
			}
		}
		
		private function onInviteButtonTap():void
		{
			if (userModel.hasPhone())
			{
				buttonInvite.deactivate();
				PhonebookManager.S_USER_INVITED.add(onInvitesUpdated);
				//!TODO: переделать на phoneModel;
				PhonebookManager.invite(userModel.phonebookData);
			}
		}
		
		private function onCommunityButtonTap():void {
			
			var nativeAppExist:Boolean = false;
			
			if (Config.PLATFORM_ANDROID == true && MobileGui.androidExtension != null)
			{
				nativeAppExist = MobileGui.androidExtension.launchFXComm(userModel.fxName);
			}
			else if (Config.PLATFORM_APPLE == true && MobileGui.dce != null)
			{
				nativeAppExist = MobileGui.dce.launchFXComm(userModel.fxName);
			}
			if (nativeAppExist == false)
			{
				if (userModel.fxId != 0)
					navigateToURL(new URLRequest(Config.URL_FXCOMM_PROFILE + userModel.fxId + "&fromdcc=1&mob=1"));
				else if(userModel.fxName != null)
					navigateToURL(new URLRequest(Config.URL_FXCOMM_PROFILE + userModel.fxName + "&fromdcc=1&mob=1"));
			}
		}
		
		private function onChatButtonTap():void {
			var chatScreenData:ChatScreenData = new ChatScreenData();
			var cVO:ChatVO = ChatManager.getChatWithUsersList([userModel.uid]);
			if (cVO != null) {
				chatScreenData.chatVO = cVO;
				chatScreenData.type = ChatInitType.CHAT;
			} else {
				chatScreenData.usersUIDs = [userModel.uid];
				chatScreenData.type = ChatInitType.USERS_IDS;
			}
			chatScreenData.backScreen = MobileGui.centerScreen.currentScreenClass;
			chatScreenData.backScreenData = data;
			MobileGui.showChatScreen(chatScreenData);
		}
		
		private function onInvitesUpdated(result:Object = null):void {
			if (isDisposed)
				return;
			if (!result || !result.success)
				buttonInvite.activate();
			if (result && result.data == userModel.uid)
				PhonebookManager.S_USER_INVITED.remove(onInvitesUpdated);
			if (result && result.success)
				updateInviteState();
		}
		
		private function updateInviteState():void {
			if (userModel.hasPhone() && !userModel.uidExist()) {
				invitedButton.visible = userModel.invited;
				buttonInvite.visible = !userModel.invited;
			} else {
				//!TODO: not possible situation when user have no uid but data type is  ContactVO?;
				invitedButton.visible = false;
				buttonInvite.visible = false;
			}
		}
		
		private function addCircleButton(content:Sprite):BitmapButton {
			content.height = int(circleButtonsSize);
			content.width = int(content.width*content.scaleY);
			
			var button:BitmapButton = new BitmapButton();				
			button.setDownScale(1);
			button.setDownColor(0x000000);
			button.show(0);
			button.setBitmapData(UI.getSnapshot(content, StageQuality.HIGH, "UserProfileScreen.circleButton"), true);
			return button;
		}
		
		private function onBlockButtonTap():void 
		{
			blockUserButton.deactivate();
			UsersManager.USER_BLOCK_CHANGED.add(onUserBlockStatusChanged);
			UsersManager.changeUserBlock(userModel.uid, isUserblocked?UserBlockStatusType.UNBLOCK:UserBlockStatusType.BLOCK);
		}
		
		private function onUserBlockStatusChanged(data:Object):void
		{
			UsersManager.USER_BLOCK_CHANGED.remove(onUserBlockStatusChanged);
			if (_isDisposed)
			{
				return;
			}
			//!TODO: need to know if button not already activated, better to implement in button component;
			blockUserButton.activate();
			
			if (data.status == UserBlockStatusType.BLOCK)
			{
				isUserblocked = true;
				createBlockUserButton();
			}
			else if (data.status == UserBlockStatusType.UNBLOCK)
			{
				isUserblocked = false;
				createBlockUserButton();
			}
		}
		
		private function onAvatarLoaded(url:String, bmd:ImageBitmapData, success:Boolean):void
		{
			if (isDisposed)
				return;		
			
			if (!success)
			{
				return;
			}
			
			validAvatarURL = url;
			
			if (LOADED_AVATAR_BMD != null) {
				LOADED_AVATAR_BMD.dispose();
				LOADED_AVATAR_BMD = null;
			}
			if (bmd)
			{
				LOADED_AVATAR_BMD ||= new ImageBitmapData("UserProfileScreen.LOADED_AVATAR_BMD", avatarSize * 2, avatarSize * 2);
				ImageManager.drawCircleImageToBitmap(LOADED_AVATAR_BMD, bmd, 0, 0, int(avatarSize));
			}
			
			updateAvatarBMD();
		}
		
		private function updateAvatarBMD():void
		{
			if (avatar == null) return;				
			if (LOADED_AVATAR_BMD != null) {	
				UI.disposeBMD(EMPTY_AVATAR_BMD);
				EMPTY_AVATAR_BMD = null;
				avatar.bitmapData = LOADED_AVATAR_BMD;
			}else {				
		//		avatar.bitmapData = getEmptyAvatar();
			}
			avatar.smoothing = true;
			
			/*if (avatar.alpha < 1)
			{
				TweenMax.to(avatar, 1, {alpha:1, ease: Power0.easeNone});
			}*/
		}
		
		private function getEmptyAvatar():BitmapData
		{
			EMPTY_AVATAR_BMD ||= UI.getEmptyAvatarBitmapData(avatarSize*2, avatarSize*2);
			return EMPTY_AVATAR_BMD;
		}
		//!TODO: use existing from TextUtils or UI;
		private function createTextFieldData(text:String = "", width:int = 100, height:int = 10, multiline:Boolean = true, align:String =  TextFormatAlign.CENTER, 
												autoSize:String = TextFieldAutoSize.LEFT, fontSize:int = 26, wordWrap:Boolean = false, 
												textColor:uint = 0x686868, backgroundColor:uint = 0xffffff, isTransparent:Boolean = false):BitmapData 
		{
			if (width < 1) width = 1;
			if (height < 1) height = 1;
		
			serviceTextField ||= new TextField();
			var textFormat:TextFormat = new TextFormat();		
			textFormat.font = Config.defaultFontName;
			textFormat.size = fontSize;
			textFormat.align = align;
			textFormat.italic = false;
			serviceTextField.autoSize = autoSize;
			serviceTextField.multiline = multiline;
			serviceTextField.wordWrap = wordWrap;
			serviceTextField.textColor = textColor;
			serviceTextField.border = false;
			serviceTextField.defaultTextFormat = textFormat;
			serviceTextField.text = text;
			serviceTextField.width = width;
			
			serviceTextField.height = serviceTextField.textHeight;
			
			var textFieldWidth:Number;
			if (autoSize == TextFieldAutoSize.LEFT)
			{
				textFieldWidth = Math.min(serviceTextField.width, width);
			}
			else
			{
				textFieldWidth = width;
			}
			
			var newBmd:ImageBitmapData =  new ImageBitmapData("", textFieldWidth, serviceTextField.height, isTransparent, backgroundColor);
			newBmd.draw(serviceTextField);
			return newBmd;
		}
		
		override protected function drawView():void {
			if (dataLoadingState) {
				return;
			}
			if (userModel == null || userModel.uid == null)
			{
				//!TODO: ошибка;
				onBack();
				return;
			}
			
			if (validAvatarURL == null)
			{
				setDefaultAvatarImage();
			}
			
			FIT_WIDTH = _width - buttonPaddingLeft*2;
			EMPTY_AVATAR_BMD ||= UI.getEmptyAvatarBitmapData(avatarSize*2, avatarSize*2);
			
			bgRect.width = _width;
			
			var currentYDrawPosition:int = 0;
			
			if (bgHeader.bitmapData) {
				UI.disposeBMD(bgHeader.bitmapData);
				bgHeader.bitmapData = null;
			}
			
			bgHeader.bitmapData = UI.getTopBarLayeredBitmapData(_width, Config.FINGER_SIZE * .85, Config.APPLE_TOP_OFFSET,0, AppTheme.RED_MEDIUM,AppTheme.RED_DARK,  AppTheme.RED_LIGHT);
			
			currentYDrawPosition += Config.MARGIN * 1.95;
			
			title.visible = true;
			if (title.bitmapData != null) {
				title.bitmapData.dispose();
				title.bitmapData = null;
			}
			var titleText:String = userModel.name;
			title.bitmapData = createTextFieldData(titleText, _width - Config.FINGER_SIZE - Config.MARGIN*2, 1, false, 
													TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
													headerSize * .45, false, 0xFFFFFF, 0, true);
			title.x = int(Config.FINGER_SIZE);
			
			avatarBox.y = int(currentYDrawPosition);
			avatarBox.x = int((_width - avatarSize * 2) * .5);
			
			currentYDrawPosition += avatarSize * 2 + Config.MARGIN * 1.7;
			
			if (phoneTextField.bitmapData != null)
			{
				phoneTextField.bitmapData.dispose();
				phoneTextField.bitmapData = null;
			}
			phoneTextField.visible = false;
			
			var userPhone:String = userModel.phone;
			if (userPhone && userPhone != "" && userPhone.length > 5)
			{
				phoneTextField.bitmapData = createTextFieldData("+" + userPhone, _width - Config.MARGIN*4, 1, false, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, headerSize * .5, false, MainColors.DARK_BLUE, 0, true);
				phoneContainer.x = int((_width - phoneTextField.width) * 0.5);
				phoneContainer.y = currentYDrawPosition;
				phoneTextField.visible = true;
				
				currentYDrawPosition += phoneTextField.height;
			}
			else
			{
				phoneTextField.visible = false;
			}
			
			if (userModel.fxId != 0 || (userModel.fxName != null && userModel.fxName != "")) 
			{
				iconSystem.visible = true;
				
				if (fxnme.bitmapData != null)
				{
					fxnme.bitmapData.dispose();
					fxnme.bitmapData = null;
				}
				fxnme.visible = true;
				var value:String;
				if (userModel.isCompanyMember() && userModel.departmentInfo) {
				
					value = userModel.departmentInfo;
					
					iconSystem.visible = false;
				}
				else
				{
					value = userModel.fxName;
				}
				
				if (!value)
				{
					iconSystem.visible = false;
					fxnme.visible = false;
				}
				else
				{
					fxnme.bitmapData = createTextFieldData(value,
																_width - iconSystem.width - Config.MARGIN * 2.5, 
																1, 
																false, 
																TextFormatAlign.LEFT, 
																TextFieldAutoSize.LEFT, 
																Config.FINGER_SIZE * .25, 
																false, 
																MainColors.RED, 
																0, 
																true);
				
					iconSystemContainer.x = int((_width - (iconSystem.width + fxnme.width + Config.MARGIN*.5)) * .5);
					fxnme.x = int(iconSystem.width + Config.MARGIN*.5);
					
					iconSystemContainer.y = currentYDrawPosition;
					iconSystem.y = int(fxnme.y + fxnme.height / 2 - iconSystem.height / 2);
					
					currentYDrawPosition += fxnme.height + Config.MARGIN*3;
				}
			}
			else
			{
				iconSystem.visible = false;
				fxnme.visible = false;
				
				currentYDrawPosition += Config.MARGIN*3;
			}
			
			updateMainButtonsState(currentYDrawPosition);
			
			currentYDrawPosition += circleButtonsSize + Config.MARGIN*3;
			
			lineDelimiter.graphics.clear();
			lineDelimiter2.graphics.clear();
			
			iconMobile.visible = false;
			iconDesktop.visible = false;
			iconWeb.visible = false;
			
			if (userModel.uidExist())
			{
				lineDelimiter.visible = true;
				lineDelimiter2.visible = true;
				lineDelimiter.graphics.lineStyle(1, MainColors.GREY_LIGHT, 1, true, LineScaleMode.HORIZONTAL);
				lineDelimiter.graphics.moveTo(0, 0);
				lineDelimiter.graphics.lineTo(_width, 0);
				lineDelimiterContainer.y = currentYDrawPosition;
				
				currentYDrawPosition += Config.MARGIN * 1.4;
				
				if (questionsStatButton == null) {
					questionsStatButton = createButtons( { iconL:SWFSettingsIcon_stats, title:Lang.text911statistic, callback:onQuestionsStatButtonTap, iconR:IconArrowRight } );
					questionsStatButtonContainer.addChild(questionsStatButton);
					questionsStatButtonContainer.x = buttonPaddingLeft;
				}
				
				if (userModel.fxId != 0 || (userModel.fxName != null && userModel.fxName != ""))
				{
					var communityIcon:CommunityIconGrey = new CommunityIconGrey();
					var arrowIcon:IconArrowRight = new IconArrowRight();
					UI.scaleToFit(communityIcon, iconSize, iconSize);
					UI.scaleToFit(arrowIcon, iconArrowSize, iconArrowSize);
					var communityButtonBitmapData:BitmapData = UI.renderSettingsTextAdvanced(Lang.communityProfile,
																	FIT_WIDTH, 
																	OPTION_LINE_HEIGHT ,
																	false,
																	TextFormatAlign.LEFT,
																	TextFieldAutoSize.NONE,
																	Config.FINGER_SIZE * 0.34,
																	false,
																	AppTheme.GREY_DARK,
																	0,
																	0, 
																	communityIcon, arrowIcon);
					UI.destroy(communityIcon);
					UI.destroy(arrowIcon);
					communityIcon = null;
					arrowIcon = null;
					openCommunityPageButton.setBitmapData(communityButtonBitmapData);
					openCommunityPageButtonContainer.x = buttonPaddingLeft;
					openCommunityPageButtonContainer.y = int(currentYDrawPosition + OPTION_LINE_HEIGHT * 0.5 - communityButtonBitmapData.height * 0.5);
					communityButtonBitmapData = null;     
					currentYDrawPosition += OPTION_LINE_HEIGHT;
					openCommunityPageButton.visible = true;
				}
				else {
					openCommunityPageButton.visible = false;
				}
				
				questionsStatButtonContainer.y = int(currentYDrawPosition + OPTION_LINE_HEIGHT * 0.5 - questionsStatButton.currentBitmapData.height * 0.5);
				currentYDrawPosition += OPTION_LINE_HEIGHT;
				
				var onlineStatus:OnlineStatus = UsersManager.isOnline(userModel.uid);
				if (!onlineStatus)
					UsersManager.registrateUserUID(userModel.uid);
				else
					updateOnlineStatus(onlineStatus);
				
				isUserblocked = isUserBlocked();
				createBlockUserButton();
				blockUserButtonContainer.x = buttonPaddingLeft;
				blockUserButtonContainer.y = int(currentYDrawPosition + OPTION_LINE_HEIGHT*0.5 - blockUserButtonContainer.height*0.5);
				
				currentYDrawPosition += OPTION_LINE_HEIGHT + Config.MARGIN*1.4;
				
				lineDelimiter2.graphics.lineStyle(1, MainColors.GREY_LIGHT, 1, true, LineScaleMode.HORIZONTAL);
				lineDelimiter2.graphics.moveTo(0, 0);
				lineDelimiter2.graphics.lineTo(_width, 0);
				lineDelimiter2Container.y = currentYDrawPosition;
				
				status.visible = true;
				
				var space:int;
				
				space = (Config.FINGER_SIZE * .85 - title.height - status.height) * .33;
				title.y = Config.APPLE_TOP_OFFSET + space;
				status.y = title.y + title.height - space;
				
				status.x = title.x + 4;
				statusTxt.x = Config.MARGIN + Config.FINGER_SIZE * 0.11;
				
				blockUserButton.visible = true;
			}
			else
			{
				title.y = int(Config.APPLE_TOP_OFFSET + (headerSize - title.height) * .5);
				
			//	deviceText.visible = false;
				openCommunityPageButton.visible = false;
				status.visible = false;
				
				lineDelimiter.visible = false;
				lineDelimiter2.visible = false;
				blockUserButton.visible = false;
			}
			
			scrollPanel.view.y =  headerSize + Config.APPLE_TOP_OFFSET;
			scrollPanel.setWidthAndHeight(_width, _height - headerSize - Config.APPLE_TOP_OFFSET, false);
			
			scrollPanel.update();
			
			var avatarUrl:String = userModel.avatarLargeURL;
			if (avatarUrl != null && avatarUrl != "" && validAvatarURL == null)
			{
				var path:String;
				
				//!TODO: можно складывать все загруженные на данный момент аватарки относящиеся к пользователю в один менеджер и выбирать наиболее подходящую;
				var smallAvatarImage:ImageBitmapData;
				
				if (!smallAvatarImage)
				{
					//берём маленькую аватарку из списка контактов;
					path = UsersManager.getAvatarImage(userModel, avatarUrl, int(Config.FINGER_SIZE * .7), 3);
					smallAvatarImage = ImageManager.getImageFromCache(path);
				}
				
				if (!smallAvatarImage)
				{
					path = userModel.avatarLargeURL;
					smallAvatarImage = ImageManager.getImageFromCache(path);
				}
				
				if (!smallAvatarImage)
				{
					path = userModel.avatarURL;
					smallAvatarImage = ImageManager.getImageFromCache(path);
				}
				
				if (!smallAvatarImage)
				{
					//берём маленькую аватарку из списка чатов;
					if (userModel.uidExist())
					{
						var chat:ChatVO = ChatManager.getFirstChatWithUser(userModel.uid);
						if (chat && chat.type == ChatRoomType.PRIVATE)
						{
							path = UsersManager.getAvatarImage(userModel, chat.avatarURL, int(Config.FINGER_SIZE * .92), 3);
							smallAvatarImage = ImageManager.getImageFromCache(path);
						}
					}
				}
				validAvatarURL = path;
				if (!smallAvatarImage)
				{
					//берём маленькую аватарку по умолчанию (размер 60px если она из коммуны);
					smallAvatarImage = ImageManager.getImageFromCache(avatarUrl);
					validAvatarURL = avatarUrl;
				}
				
				
				if (smallAvatarImage)
				{
					if (LOADED_AVATAR_BMD)
					{
						LOADED_AVATAR_BMD.dispose();
						LOADED_AVATAR_BMD = null;
					}
					
					
					LOADED_AVATAR_BMD = new ImageBitmapData("UserProfileScreen.LOADED_AVATAR_BMD", avatarSize * 2, avatarSize * 2);
					ImageManager.drawCircleImageToBitmap(LOADED_AVATAR_BMD, smallAvatarImage, 0, 0, int(avatarSize));
					avatar.bitmapData = LOADED_AVATAR_BMD;
				}
				
				path = UsersManager.getAvatarImage(userModel, avatarUrl, avatarSize * 2, 3, false);
				ImageManager.loadImage(path, onAvatarLoaded);
			}
			
			if (userModel.uid == Auth.uid)
			{
				invitedButton.visible = false;
				buttonInvite.visible = false;
				buttonCall.visible = false;
				buttonChat.visible = false;
				blockUserButton.visible = false;
				buttonPay.visible = false;
				buttonPayWithoutPhone.visible = false;
			}
		}
		
		private function createButtons(obj:Object):BitmapButton {
			var iconL:DisplayObject;
			var iconR:DisplayObject;
			if (obj.iconL != undefined && obj.iconL != null)
				iconL = new obj.iconL();
			if (obj.iconR != undefined && obj.iconR != null)
				iconR = new obj.iconR();
			
			if (iconL != null)
				UI.scaleToFit(iconL, iconSize, iconSize);
			if (iconR != null)
				UI.scaleToFit(iconR, iconArrowSize, iconArrowSize);
			var btn:BitmapButton = new BitmapButton();
			btn.usePreventOnDown = false;
			btn.setDownScale(1);
			btn.setDownColor(0x000000);
			var ibmd:BitmapData = UI.renderSettingsTextAdvanced(
				obj.title,
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
				iconR
			);
			UI.destroy(iconL);
			UI.destroy(iconR);
			iconL = null;
			iconR = null;
			btn.setBitmapData(ibmd);
			btn.tapCallback = obj.callback;
			btn.show(0);
			
			return btn;
		}
		
		private function setDefaultAvatarImage():void 
		{
			if (avatar.bitmapData)
			{
				if (avatar.bitmapData != EMPTY_AVATAR_BMD)
				{
					UI.disposeBMD(avatar.bitmapData);
				}
				
				avatar.bitmapData = null;
			}
			avatar.bitmapData = getEmptyAvatar();
		}
		
		private function getOnlineStatusText(status:OnlineStatus):String 
		{
			var text:String = "";
			if (!status || !status.online)
			{
				return Lang.userOffline;
			}
			else{
				text += status.mob>0?Lang.textMobile:"";
				text += status.desk>0?(((text.length > 0)?", ":"") + Lang.textDesktop):"";
				text += status.web>0?(((text.length > 0)?", ":"") + Lang.textWeb):"";
			}
			
			return text;
		}
		
		private function updateMainButtonsState(yPos:int):void 
		{
			if (userModel.hasPhone())
			{
				buttonPay.visible = true;
				buttonPayWithoutPhone.visible = false;
			}
			else {
				buttonPay.visible = false;
				buttonPayWithoutPhone.visible = true;
			}
			
			var buttonPadding:Number;
			
			if (userModel.uidExist())
			{
				buttonChat.visible = true;
				buttonCall.visible = true;
				
				invitedButton.visible = false;
				buttonInvite.visible = false;
				
				if (buttonPay.visible)
				{
					buttonPadding = Math.max((_width - circleButtonsSize * 3) / 5, 0);
					buttonChatContainer.x = int(_width * 0.5 - circleButtonsSize * 1.5 - buttonPadding * 1.5);
					buttonCallContainer.x = int(_width * 0.5 - circleButtonsSize * .5);
					buttonPayContainer.x = int(_width * 0.5 + circleButtonsSize * 0.5 + buttonPadding * 1.5);
				}
				else {
					buttonPadding = Math.max((_width - circleButtonsSize * 3) / 5, 0);
					buttonChatContainer.x = int(_width * 0.5 - circleButtonsSize * 1.5 - buttonPadding * 1.5);
					buttonCallContainer.x = int(_width * 0.5 - circleButtonsSize * .5);
					buttonPayWithoutPhoneContainer.x = int(_width * 0.5 + circleButtonsSize * 0.5 + buttonPadding * 1.5);
				}
				
				buttonChatContainer.y = yPos;
				buttonCallContainer.y = yPos;
				buttonPayContainer.y = yPos;
				buttonPayWithoutPhoneContainer.y = yPos;
			}
			else
			{
				buttonChat.visible = false;
				buttonCall.visible = false;
				
				updateInviteState();
				
				if (buttonPay.visible)
				{
					buttonPadding = (_width - circleButtonsSize * 2)/4;
					buttonInviteContainer.x = int(_width * 0.5 - circleButtonsSize - buttonPadding * 0.5);
					buttonPayContainer.x = int(_width * 0.5 + buttonPadding * 0.5);
					buttonInvitedContainer.x = buttonInviteContainer.x;
				}
				else {
					buttonPadding = (_width - circleButtonsSize * 2)/4;
					buttonInviteContainer.x = int(_width * 0.5 - circleButtonsSize - buttonPadding * 0.5);
					buttonPayWithoutPhoneContainer.x = int(_width * 0.5 + buttonPadding * 0.5);
					buttonInvitedContainer.x = buttonInviteContainer.x;
				}
				
				buttonPayContainer.y = yPos;
				buttonInviteContainer.y = yPos;
				buttonInvitedContainer.y = yPos;
				buttonPayWithoutPhoneContainer.y = yPos;
			}
		}
		
		private function updateOnlineStatus(status:OnlineStatus):void 
		{
			if (status.online)
			{
				drawStatus(true, Lang.textOnline);
				
				iconDesktop.visible = status.desk > 0;
				iconMobile.visible = status.mob > 0;
				iconWeb.visible = status.web > 0;
				
				var padding:int = Config.MARGIN;
				var position:int;
				if (userModel.fxId != 0) 
				{
					position = iconSystemContainer.x;
					if (iconMobile.visible)
					{
						iconMobile.height = iconSystem.height;
						iconMobile.scaleX = iconMobile.scaleY;
						
						position = int(position - padding - iconMobile.getWidth())
						
						iconMobileContainer.x = position;
						iconMobileContainer.y = iconSystemContainer.y + iconSystem.y;	
					}
					if (iconDesktop.visible)
					{
						iconDesktop.height = iconSystem.height;
						iconDesktop.scaleX = iconDesktop.scaleY;
						
						position = int(position - padding - iconDesktop.getWidth())
						
						iconDesktopContainer.x = position;
						iconDesktopContainer.y = iconSystemContainer.y + iconSystem.y;
					}
					if (iconWeb.visible)
					{
						iconWeb.height = iconSystem.height;
						iconWeb.scaleX = iconWeb.scaleY;
						
						position = int(position - padding - iconWeb.getWidth())
						
						iconWebContainer.x = position;
						iconWebContainer.y = iconSystemContainer.y + iconSystem.y;
					}
				}
				else if (phoneTextField.visible)
				{
					position = phoneContainer.x;
					if (iconMobile.visible)
					{
						iconMobile.height = Config.FINGER_SIZE*.3;
						iconMobile.scaleX = iconMobile.scaleY;
						
						position = int(position - padding - iconMobile.getWidth())
						
						iconMobileContainer.x = position;
						iconMobileContainer.y = int(phoneContainer.y + phoneTextField.height * .5 - iconMobile.getHeight()*.5 );
					}
					if (iconDesktop.visible)
					{
						iconDesktop.height = Config.FINGER_SIZE*.3;
						iconDesktop.scaleX = iconMobile.scaleY;
						
						position = int(position - padding - iconDesktop.getWidth())
						
						iconDesktopContainer.x = position;
						iconDesktopContainer.y = int(phoneContainer.y + phoneTextField.height * .5 - iconDesktop.getHeight()*.5 );
					}
					if (iconWeb.visible)
					{
						iconWeb.height = Config.FINGER_SIZE*.3;
						iconWeb.scaleX = iconWeb.scaleY;
						
						position = int(position - padding - iconWeb.getWidth())
						
						iconWebContainer.x = position;
						iconWebContainer.y = int(phoneContainer.y + phoneTextField.height * .5 - iconWeb.getHeight()*.5 );
					}
				}
				
				if (userModel.fxId == 0 || (userModel.fxName == null && userModel.phone == null))
				{
					iconMobile.visible = false;
					iconDesktop.visible = false;
					iconWeb.visible = false;
				}
			}
			else
			{
				drawStatus(false, Lang.textOffline);
				
				iconDesktop.visible = false;
				iconMobile.visible = false;
				iconWeb.visible = false;
			}
		}
		
		private function createBlockUserButton():void 
		{
			var blockIcon:BlockUserIcon = new BlockUserIcon();
			UI.scaleToFit(blockIcon, iconSize, iconSize);
			var blockUserButtonBitmapData:BitmapData = UI.renderSettingsText(isUserblocked?Lang.unblockUser:Lang.blockUser,
															FIT_WIDTH, 
															OPTION_LINE_HEIGHT ,
															false,
															TextFormatAlign.LEFT,
															TextFieldAutoSize.LEFT,
															Config.FINGER_SIZE * 0.34,
															false,
															AppTheme.GREY_DARK,
															0,
															0, 
															blockIcon,
															"UserProfileScreen.blockUserButton");
			UI.destroy(blockIcon);
			blockIcon = null;
			blockUserButton.setBitmapData(blockUserButtonBitmapData, true);
		}
		
		private function isUserBlocked():Boolean 
		{
			var blockedUsers:Array = Auth.blocked;
			var l:int = blockedUsers.length;
			for (var i:int = 0; i < l; i++){
				if (blockedUsers[i] == userModel.uid){
					return true;
				}
			}
			return false;
		}
		
		private function drawStatus(val:Boolean, txt:String):void
		{
			var onlineCircleSize:int =  Config.FINGER_SIZE * .85 * 0.11;
			
			if (statusTxt.bitmapData != null)
			{
				statusTxt.bitmapData.dispose();
				statusTxt.bitmapData = null;
			}
			statusTxt.bitmapData = UI.renderText(txt, _width - Config.FINGER_SIZE - Config.MARGIN*3 - onlineCircleSize, Config.FINGER_SIZE_DOT_25, false, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
													headerSize * .25, false, 0xFFFFFF, 0, true);
			var metrics:TextLineMetrics = UI.getTextField().getLineMetrics(0);
			var _circleCenterY:Number = UI.getTextField().textHeight - metrics.descent - onlineCircleSize + 2;
			
			metrics = null;
			status.graphics.clear();
			status.graphics.beginFill((val) ? 0x65BF37 : 0xFFFFFF);
			status.graphics.drawCircle(onlineCircleSize, _circleCenterY, onlineCircleSize);
			status.graphics.endFill();
		}
		
		private function onUserOnlineStatusChanged(status:OnlineStatus, method:String):void 
		{
			if (userModel.uidExist() && status.uid == userModel.uid)
			{
				updateOnlineStatus(status);
			//	updateOnlineStatusText(status);
			}
		}
		
		override public function clearView():void
		{
			super.clearView();
		}
		
		override public function dispose():void
		{
			super.dispose();
			dataLoadingState = false;
			UI.destroy(title);
			UI.destroy(phoneTextField);
			UI.destroy(statusTxt);
			UI.destroy(bgHeader);
			UI.destroy(status);
			UI.destroy(avatar);
			UI.destroy(fxnme);
			UI.destroy(lineDelimiter);
			UI.destroy(lineDelimiter2);
		//	UI.destroy(deviceText);
			
			if (serviceTextField)
				serviceTextField.text = "";
			serviceTextField = null;
			if (iconDesktop)
				iconDesktop.dispose();
			iconDesktop = null;
			
			if (invitedButton)
				invitedButton.dispose();
			invitedButton = null;
			
			if (iconMobile)
				iconMobile.dispose();
			iconMobile = null;
			
			if (iconWeb)
				iconWeb.dispose();
			iconWeb = null;
			
			if (scrollPanel)
				scrollPanel.dispose();
			scrollPanel = null;
			
			if (backButton != null) 
				backButton.dispose();
			backButton = null;
			
			if (buttonChat != null) 
				buttonChat.dispose();
			buttonChat = null;
			
			if (buttonCall != null) 
				buttonCall.dispose();
			buttonCall = null;
			
			if (buttonPay != null) 
				buttonPay.dispose();
			buttonPay = null;
			
			if (openCommunityPageButton != null) 
				openCommunityPageButton.dispose();
			openCommunityPageButton = null;
			
			if (questionsStatButton != null) 
				questionsStatButton.dispose();
			questionsStatButton = null;
			
			if (buttonInvite != null) 
				buttonInvite.dispose();
			buttonInvite = null;
			
			if (blockUserButton != null) 
				blockUserButton.dispose();
			blockUserButton = null;
			
			if (buttonPayWithoutPhone != null) 
				buttonPayWithoutPhone.dispose();
			buttonPayWithoutPhone = null;
				
			if (bgBMD)
				UI.disposeBMD(bgBMD);
			bgBMD = null;
			
			if (LOADED_AVATAR_BMD)
				UI.disposeBMD(LOADED_AVATAR_BMD);
			LOADED_AVATAR_BMD = null;
			bgBMD = null;
			
			if (EMPTY_AVATAR_BMD)
				UI.disposeBMD(EMPTY_AVATAR_BMD);
			EMPTY_AVATAR_BMD = null;
			
			if (iconSystem)
				UI.destroy(iconSystem);
			iconSystem = null;
			
			if (imageCounter != null)
			{
				TweenMax.killTweensOf(imageCounter);
				UI.destroy(imageCounter);
			}
			
			bgRect = null;
			phoneContainer = null;
			phoneContainer = null;
		//	onlineStatusContainer = null;
			iconSystemContainer = null;
			buttonChatContainer = null;
			buttonCallContainer = null;
			buttonPayContainer = null;
			buttonInviteContainer = null;
			lineDelimiterContainer = null;
			buttonPayWithoutPhoneContainer = null;
			openCommunityPageButtonContainer = null;
			lineDelimiter2Container = null;
			blockUserButtonContainer = null;
			buttonInvitedContainer = null;
			openCommunityPageButtonContainer = null;
			openCommunityPageButtonContainer = null;
			openCommunityPageButtonContainer = null;
			title = null;
			phoneTextField = null;
			statusTxt = null;
			bgHeader = null;
			status = null;
			avatar = null;
			fxnme = null;
			lineDelimiter = null;
			lineDelimiter2 = null;
			imageCounter = null;
			
			LightBox.S_LIGHTBOX_OPENED.remove(onLightboxOpen);
			LightBox.S_LIGHTBOX_CLOSED.remove(onLightboxClose);
			
			clearFxPhotos();
			
			if (validAvatarURL != null)
			{
				ImageManager.unloadImage(validAvatarURL);
			}
		}
		
		override public function activateScreen():void
		{
			if (_isDisposed)
				return;
			super.activateScreen();
			if (backButton != null)
			backButton.activate();
			scrollPanel.enable();
			invitedButton.activate();
			blockUserButton.activate();
			openCommunityPageButton.activate();
			if (questionsStatButton != null)
				questionsStatButton.activate();
			buttonPayWithoutPhone.activate();
			buttonInvite.activate();
			buttonCall.activate();
			buttonChat.activate();
			buttonPay.activate();
			
			PointerManager.addTap(avatarBox, onAvatarTapped);
			WSClient.S_USER_BLOCK_STATUS.add(onBlockuserChangeByWS);
			UsersManager.S_ONLINE_CHANGED.add(onUserOnlineStatusChanged);
			
			if (imageCounter != null && imageCounter.alpha == 0 && imageCounter.bitmapData != null)
			{
				TweenMax.to(imageCounter, 0.5, { alpha:1, delay:0.5 } );
			}
		}
		
		private function onBlockuserChangeByWS(dataObject:Object):void 
		{
			if (userModel.uid && userModel.uid == dataObject.uid)
			{
				if (dataObject.block)
				{
					isUserblocked = true;
					createBlockUserButton();
				}
				else{
					isUserblocked = false;
					createBlockUserButton();
				}
			}
		}
		
		private function onAvatarTapped(e:Event = null):void 
		{
			showAvatarInLightbox();
		}
		
		private function showAvatarInLightbox(e:Event = null):void {
			LightBox.disposeVOs();
			var lnk:String = UsersManager.getAvatarImage(userModel, userModel.avatarLargeURL, MobileGui.stage.stageWidth * 2, 6, false);
			if (lnk != null || (userModel.media != null && userModel.media.fxGallery != null && userModel.media.fxGallery.length > 0))
			{
				var fxContent:IContentProvider;
				if (userModel.fxId != 0)
				{
					fxContent = new FXImagesListContentProvider();
					fxContent.setData(userModel);
				}
				
				var imageActions:Vector.<IScreenAction>;
				if (userModel.fxId != 0 && userModel.fxName != null)
				{
					imageActions = new Vector.<IScreenAction>();
					
					var openFxProfileAction:OpenFxProfileAction = new OpenFxProfileAction(userModel.fxName);
					openFxProfileAction.setData(ImageContextMenuType.OPEN_FX_PROFILE);
					imageActions.push(openFxProfileAction);
				}
				
				if (lnk != null)
				{
					LightBox.add(lnk, false, null, null, null, null, imageActions);
				}
				
				//!TODO: плохо в просмотрщик картинок передавать так, инкапсулировать.
				if (userModel.fxId != 0 && userModel.fxName != null)
				{
					LightBox.showCommunityLink(userModel.fxName);
				}
				
				LightBox.show(lnk, userModel.name, true, fxContent);
				deactivateScreen();
			}
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed)
				return;
				
			if (backButton != null)
			scrollPanel.disable();
			backButton.deactivate();
			blockUserButton.deactivate();
			invitedButton.deactivate();
			buttonPayWithoutPhone.deactivate();
			openCommunityPageButton.deactivate();
			if (questionsStatButton != null)
				questionsStatButton.deactivate();
			buttonInvite.deactivate();
			buttonCall.deactivate();
			
			buttonCall.deactivate();
			
			buttonChat.deactivate();
			buttonPay.deactivate();
			UsersManager.S_ONLINE_CHANGED.remove(onUserOnlineStatusChanged);
			UsersManager.USER_BLOCK_CHANGED.remove(onUserBlockStatusChanged);
			PhonebookManager.S_USER_INVITED.remove(onInvitesUpdated);
			WSClient.S_USER_BLOCK_STATUS.remove(onBlockuserChangeByWS);
			PointerManager.removeTap(avatarBox, onAvatarTapped);
		}
		
		private function onLightboxClose():void {
			if (isDisposed)
				return;
			activateScreen();
		}
		
		private function onLightboxOpen():void {					
			if (isDisposed)
				return;
			deactivateScreen();
		}
	}
}