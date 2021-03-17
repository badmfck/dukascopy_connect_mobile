package com.dukascopy.connect.screens.chat {
	
		import assets.EditIcon;
		import assets.EmptyChatAvatar;
		import assets.GalleryIcon;
		import assets.IconArrowRight;
		import assets.PhotoShotIcon;
		import assets.UsersListIcon;
		import com.adobe.crypto.MD5;
		import com.dukascopy.connect.Config;
		import com.dukascopy.connect.MobileGui;
		import com.dukascopy.connect.data.BackgroundModel;
		import com.dukascopy.connect.data.ChatBackgroundCollection;
		import com.dukascopy.connect.data.ChatSettingsModel;
		import com.dukascopy.connect.data.LocalAvatars;
		import com.dukascopy.connect.data.TextFieldSettings;
		import com.dukascopy.connect.gui.input.Input;
		import com.dukascopy.connect.gui.lightbox.UI;
		import com.dukascopy.connect.gui.list.renderers.ListLinkWithIcon;
		import com.dukascopy.connect.gui.menuVideo.BitmapButton;
		import com.dukascopy.connect.gui.menuVideo.OptionSwitcherCustomLayout;
		import com.dukascopy.connect.gui.preloader.Preloader;
		import com.dukascopy.connect.gui.scrollPanel.ScrollPanel;
		import com.dukascopy.connect.gui.topBar.TopBarScreen;
		import com.dukascopy.connect.screens.RootScreen;
		import com.dukascopy.connect.screens.UserProfileScreen;
		import com.dukascopy.connect.screens.base.BaseScreen;
		import com.dukascopy.connect.screens.base.ScreenManager;
		import com.dukascopy.connect.screens.dialogs.ScreenLinksDialog;
		import com.dukascopy.connect.sys.assets.Assets;
		import com.dukascopy.connect.sys.auth.Auth;
		import com.dukascopy.connect.sys.chatManager.ChatManager;
		import com.dukascopy.connect.sys.dialogManager.DialogManager;
		import com.dukascopy.connect.sys.echo.echo;
		import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
		import com.dukascopy.connect.sys.imageManager.ImageManager;
		import com.dukascopy.connect.sys.photoGaleryManager.PhotoGaleryManager;
		import com.dukascopy.connect.sys.style.Style;
		import com.dukascopy.connect.sys.style.presets.Color;
		import com.dukascopy.connect.sys.theme.AppTheme;
		import com.dukascopy.connect.sys.usersManager.OnlineStatus;
		import com.dukascopy.connect.sys.usersManager.UsersManager;
		import com.dukascopy.connect.type.ChatInitType;
		import com.dukascopy.connect.type.ChatRoomType;
		import com.dukascopy.connect.type.MainColors;
		import com.dukascopy.connect.utils.TextUtils;
		import com.dukascopy.connect.vo.ChatVO;
		import com.dukascopy.connect.vo.screen.ChatScreenData;
		import com.dukascopy.connect.vo.users.UserVO;
		import com.dukascopy.connect.vo.users.adds.ChatUserVO;
		import com.dukascopy.langs.Lang;
		import com.greensock.TweenMax;
		import com.hurlant.util.Base64;
		import flash.display.Bitmap;
		import flash.display.BitmapData;
		import flash.display.DisplayObject;
		import flash.display.PNGEncoderOptions;
		import flash.display.Shape;
		import flash.display.Sprite;
		import flash.display.StageQuality;
		import flash.events.Event;
		import flash.events.KeyboardEvent;
		import flash.geom.Matrix;
		import flash.text.TextFieldAutoSize;
		import flash.text.TextFormatAlign;
		import flash.utils.ByteArray;
		import flash.utils.getTimer;

	/**
	 * ...
	 * @author Dobarin Sergey
	 */
	
	public class ChatSettingsScreen extends BaseScreen {
		private var topBar:TopBarScreen;
		private var scrollPanel:ScrollPanel;
		
		private var OPTION_LINE_HEIGHT:int = Config.FINGER_SIZE *.8;
		private var iconSize:Number;
		private var iconArrowSize:Number;
		
		private var buttonPaddingLeft:int;
		private var FIT_WIDTH:int;
		private var changeBitmap:BitmapButton;
		private var option1:OptionSwitcherCustomLayout;
		private var backgroundIconHeight:Number;
		private var currentChatBackgroundId:String;
		private var chatModel:ChatVO;
		private var settingsTextPosition:int;
		private var settingsIconPosition:int;
		
		private var line0:Bitmap;
		private var line1:Bitmap;
		private var line2:Bitmap;
		private var line3:Bitmap;
		private var line4:Bitmap;
		private var line5:Bitmap;
		private var line6:Bitmap;
		
		private var textUsers:Bitmap;
		private var selfUserButton:BitmapButton;
		private var userAvatarContainer:Sprite;
		private var onlineMark:Sprite;
		private var avatar:Shape;
		private var avatarSize:int;
		private var firstUserButton:BitmapButton;
		private var secondUserButton:BitmapButton;
		private var addUsersButton:BitmapButton;
		private var allusersButton:BitmapButton;
		private var leaveChatButton:BitmapButton;
		private var chatTitle:Input;
		private var editTitleButton:BitmapButton;
		private var lastTitleValue:String;
		private var editTitleButtonContainer:Sprite;
		private var chartTitleContailer:Sprite;
		private var allusersButtonContainer:Sprite;
		private var firstUserButtonContainer:Sprite;
		private var line0Container:Sprite;
		private var titleEditing:Boolean = false;
		private var chatAvatar:BitmapButton;
		private var chatAvatarContainer:Sprite;
		private var deleteAvatarRequest:String;
		private var changeAvatarRequest:String;
		private var isChatOwnerSelf:Boolean;
		private var currentLoadedAvatar:String;
		private var line6Container:Sprite;
		private var avatarUploading:Boolean;
		private var avatarPreloader:Preloader;
		private var avatarPreloaderContainer:Sprite;
		private var acceptTitleButton:BitmapButton;
		private var acceptTitleButtonContainer:Sprite;
		private var optionNotifications:OptionSwitcherCustomLayout;
		private var avatarWithLetterBD:ImageBitmapData;
		private var lockIcon:ImageBitmapData;
		private var notificationIcon:ImageBitmapData;
		private var secondUserButtonContainer:Sprite;
		private var firstUserAvatarBD:ImageBitmapData;
		private var firstUser:UserVO;
		private var secondUser:UserVO;
		private var secondUserAvatarBD:ImageBitmapData;
		private var chatType:String;
		private var chatUID:String;
		private var addBotButton:BitmapButton;
		
		public function ChatSettingsScreen() { }
		
		override public function initScreen(data:Object = null):void {
			topBar.setData(Lang.chatSettingsScreenTitle, true);
			lastTitleValue = null;
			var uid:String = null;
			if (data is String)
				uid = data as String;
			if (uid == null) {
				if ("data" in data && "chatId" in data.data)
					uid = data.data.chatId;
			}
			if (uid == null && ChatManager.getCurrentChat()!=null)
				uid = ChatManager.getCurrentChat().uid;
			if (uid == null) {
				MobileGui.centerScreen.show(RootScreen);
				return;
			}
			
			chatModel = ChatManager.getChatByUID(uid);
			
			if (chatModel != null)
			{
				currentLoadedAvatar = null;
				super.initScreen(data);
				avatarUploading = false;
				_params.title = 'Chat settings screen';
				_params.doDisposeAfterClose = true;
				
				lastTitleValue = chatModel.title;
				
				acceptTitleButton.visible = false;
				acceptTitleButton.deactivate();
				if (chatModel.type == ChatRoomType.GROUP)
				{
					editTitleButton.visible = true;
					editTitleButton.activate();
				}
				
				if (chatModel.type == ChatRoomType.QUESTION)
				{
					changeBitmap.alpha = 0.5;
				}
				
				ChatManager.S_CHAT_USERS_CHANGED.add(onChatChanged);
			}
			else
			{
				MobileGui.changeMainScreen(RootScreen, null, ScreenManager.DIRECTION_LEFT_RIGHT);
			}
		}
		
		private function onChatChanged(chatUID:String):void 
		{
			if (isDisposed == true)
			{
				return;
			}
			if (chatModel != null && chatUID == chatModel.uid)
			{
				drawView();
			}
		}
		
		override public function onBack(e:Event = null):void {
			// Какого хуя data вдруг string ?
			
			if (data is String){
				//if (ChatManager.currentChat.uid == data as String){
					var chatScreenData:ChatScreenData= new ChatScreenData();
					chatScreenData.chatUID = data as String;
					chatScreenData.type = ChatInitType.CHAT;
					MobileGui.showChatScreen(chatScreenData);
					return;
				//}
			}
			
			if (!(data is String) && data.backScreen != undefined && data.backScreen != null) {
				MobileGui.changeMainScreen(data.backScreen, data.backScreenData, ScreenManager.DIRECTION_LEFT_RIGHT);
				return;
			}
			MobileGui.changeMainScreen(RootScreen, null, ScreenManager.DIRECTION_LEFT_RIGHT);
		}
		
		override protected function createView():void {
			super.createView();
			//size variables;
			avatarSize = Config.FINGER_SIZE * .35;
			iconSize = Config.FINGER_SIZE * 0.4;
			iconArrowSize = Config.FINGER_SIZE * 0.30;
			buttonPaddingLeft = Config.MARGIN * 2;
			
			//scroller component;
			scrollPanel = new ScrollPanel();
			scrollPanel.background = true;
			scrollPanel.backgroundColor = Style.color(Style.COLOR_BACKGROUND);
			_view.addChild(scrollPanel.view);

			topBar = new TopBarScreen();
			_view.addChild(topBar);
			
			lockIcon = UI.renderAsset(UI.colorize(new (Style.icon(Style.ICON_LOCK)), Style.color(Style.COLOR_ICON_SETTINGS)), iconSize, iconSize, true, "ChatSettingsScreen.PinControlIcon");
			notificationIcon = UI.renderAsset(UI.colorize(new (Style.icon(Style.ICON_NOTIFICATIONS)), Style.color(Style.COLOR_ICON_SETTINGS)), iconSize, iconSize, true, "ChatSettingsScreen.NotificationsControlIcon");
			
			changeBitmap = new BitmapButton();
			changeBitmap.setStandartButtonParams();
			changeBitmap.setDownScale(1);
			changeBitmap.setDownColor(0xFFFFFF);
			changeBitmap.tapCallback = changeBackground;
			changeBitmap.disposeBitmapOnDestroy = true;
			changeBitmap.usePreventOnDown = false;
			changeBitmap.cancelOnVerticalMovement = true;
			changeBitmap.show();
			scrollPanel.addObject(changeBitmap);
			
			option1 = new OptionSwitcherCustomLayout();
			scrollPanel.addObject(option1);
			option1.onSwitchCallback = changeChatLock;
			
			
			optionNotifications = new OptionSwitcherCustomLayout();
			scrollPanel.addObject(optionNotifications);
			optionNotifications.onSwitchCallback = changePushNotifications;
			
			var hLineBitmapData:ImageBitmapData = new ImageBitmapData("ChatSettingsScreen.hLine", 1, UI.getLineThickness(), false, Style.color(Style.COLOR_SEPARATOR));
			line0 = new Bitmap(hLineBitmapData);
			line1 = new Bitmap(hLineBitmapData);
			line2 = new Bitmap(hLineBitmapData);
			line3 = new Bitmap(hLineBitmapData);
			line4 = new Bitmap(hLineBitmapData);
			line5 = new Bitmap(hLineBitmapData);
			line6 = new Bitmap(hLineBitmapData);
			
			line0Container = new Sprite();
			line0Container.addChild(line0);
			
			line6Container = new Sprite();
			line6Container.addChild(line6);
			
			textUsers = new Bitmap();
			scrollPanel.addObject(textUsers);
			
			firstUserButton = new BitmapButton();
			firstUserButton.setStandartButtonParams();
			firstUserButton.setDownScale(1);
			firstUserButton.setDownColor(0xFFFFFF);
			firstUserButton.tapCallback = openFirstUserProfile;
			firstUserButton.disposeBitmapOnDestroy = true;
			firstUserButton.show();
			firstUserButton.usePreventOnDown = false;
			firstUserButton.cancelOnVerticalMovement = true;
			firstUserButtonContainer = new Sprite();
			firstUserButtonContainer.addChild(firstUserButton);
			scrollPanel.addObject(firstUserButtonContainer);
			
			secondUserButton = new BitmapButton();
			secondUserButton.setStandartButtonParams();
			secondUserButton.setDownScale(1);
			secondUserButton.setDownColor(0xFFFFFF);
			secondUserButton.tapCallback = openSecondUserProfile;
			secondUserButton.disposeBitmapOnDestroy = true;
			secondUserButton.show();
			secondUserButton.usePreventOnDown = false;
			secondUserButton.cancelOnVerticalMovement = true;
			secondUserButtonContainer = new Sprite();
			secondUserButtonContainer.addChild(secondUserButton);
			scrollPanel.addObject(secondUserButtonContainer);
			
			addUsersButton = new BitmapButton();
			addUsersButton.setStandartButtonParams();
			addUsersButton.setDownScale(1);
			addUsersButton.setDownColor(0xFFFFFF);
			addUsersButton.tapCallback = onAdduserCalled;
			addUsersButton.disposeBitmapOnDestroy = true;
			addUsersButton.usePreventOnDown = false;
			addUsersButton.cancelOnVerticalMovement = true;
			addUsersButton.show();
			scrollPanel.addObject(addUsersButton);
			
			addBotButton = new BitmapButton();
			addBotButton.setStandartButtonParams();
			addBotButton.setDownScale(1);
			addBotButton.setDownColor(0xFFFFFF);
			addBotButton.tapCallback = onAddBotCalled;
			addBotButton.disposeBitmapOnDestroy = true;
			addBotButton.usePreventOnDown = false;
			addBotButton.cancelOnVerticalMovement = true;
			addBotButton.show();
			scrollPanel.addObject(addBotButton);
			
			leaveChatButton = new BitmapButton();
			leaveChatButton.setStandartButtonParams();
			leaveChatButton.setDownScale(1);
			leaveChatButton.setDownColor(0xFFFFFF);
			leaveChatButton.tapCallback = leaveChat;
			leaveChatButton.disposeBitmapOnDestroy = true;
			leaveChatButton.usePreventOnDown = false;
			leaveChatButton.cancelOnVerticalMovement = true;
			leaveChatButton.show();
			scrollPanel.addObject(leaveChatButton);
			
			allusersButton = new BitmapButton();
			allusersButton.setStandartButtonParams();
			allusersButton.setDownScale(1);
			allusersButton.setDownColor(0xFFFFFF);
			allusersButton.tapCallback = openUsersList;
			allusersButton.disposeBitmapOnDestroy = true;
			allusersButton.usePreventOnDown = false;
			allusersButton.cancelOnVerticalMovement = true;
			allusersButton.show();
			
			allusersButtonContainer = new Sprite();
			allusersButtonContainer.addChild(allusersButton);
			scrollPanel.addObject(allusersButtonContainer);
			
			userAvatarContainer = new Sprite();
			avatar = new Shape();
			userAvatarContainer.addChild(avatar);
			onlineMark = new Sprite();
				onlineMark.graphics.beginFill(0xf9fbf6);
				onlineMark.graphics.drawCircle(Config.FINGER_SIZE * .46 / 4.2, Config.FINGER_SIZE * .46 / 4.2, Config.FINGER_SIZE * .46 / 4.2);
				onlineMark.graphics.endFill();
				onlineMark.graphics.beginFill(0x88c927);
				onlineMark.graphics.drawCircle(Config.FINGER_SIZE * .46/4.2, Config.FINGER_SIZE * .46/4.2, Config.FINGER_SIZE * .46/5.9);
				onlineMark.graphics.endFill();
				onlineMark.visible = false;
			userAvatarContainer.addChild(onlineMark);
			onlineMark.x = int(avatar.x  + avatarSize * Math.cos(Math.PI/4) + avatarSize - onlineMark.width/2);
			onlineMark.y = int(avatar.y  + avatarSize * Math.sin(Math.PI / 4) + avatarSize - onlineMark.width / 2);
			
			chatTitle = new Input();
			chatTitle.view.x = buttonPaddingLeft;
			chatTitle.setBorderVisibility(false);
			chatTitle.setRoundBG(false);
			chatTitle.backgroundColor = Style.color(Style.COLOR_BACKGROUND);
			chatTitle.getTextField().textColor = Style.color(Style.COLOR_TEXT);
			chatTitle.setMode(Input.MODE_INPUT);
			chatTitle.S_FOCUS_OUT.add(discardTitleChange);
			chatTitle.S_DONE.add(saveTitle);
			chatTitle.S_TAPPED.add(editTitle);
			chatTitle.S_FOCUS_IN.add(onTitleFocusIn);
			chatTitle.S_CHANGED.add(onTitleEditChange);
			chatTitle.setRoundRectangleRadius(0);
			chatTitle.inUse = true;
			
			chartTitleContailer = new Sprite();
			chartTitleContailer.addChild(chatTitle.view);
			scrollPanel.addObject(chartTitleContailer);
			
			editTitleButton = new BitmapButton();
			editTitleButton.setStandartButtonParams();
			editTitleButton.setDownScale(1);
			editTitleButton.setDownColor(0xFFFFFF);
			editTitleButton.tapCallback = editTitle;
			editTitleButton.disposeBitmapOnDestroy = true;
			editTitleButton.show();
			
			editTitleButtonContainer = new Sprite();
			editTitleButtonContainer.addChild(editTitleButton);
			scrollPanel.addObject(editTitleButtonContainer);
			
			acceptTitleButton = new BitmapButton();
			acceptTitleButton.setStandartButtonParams();
			acceptTitleButton.setDownScale(1);
			acceptTitleButton.setDownColor(0xFFFFFF);
			acceptTitleButton.tapCallback = saveTitle;
			acceptTitleButton.disposeBitmapOnDestroy = true;
			acceptTitleButton.show();
			
			acceptTitleButtonContainer = new Sprite();
			acceptTitleButtonContainer.addChild(acceptTitleButton);
			scrollPanel.addObject(acceptTitleButtonContainer);
			
			var editIcon:EditIcon = new EditIcon();
			UI.colorize(editIcon, Style.color(Style.COLOR_ICON_SETTINGS));
			UI.scaleToFit(editIcon, Config.FINGER_SIZE * .35, Config.FINGER_SIZE * .35);
			editTitleButton.setBitmapData(UI.getSnapshot(editIcon, StageQuality.HIGH, "ChatSettingsScreen.editTitleButton"), true);
			
			var acceptIcon:acceptButtonIcon = new acceptButtonIcon();
			UI.colorize(acceptIcon, Style.color(Style.COLOR_ICON_SETTINGS));
			UI.scaleToFit(acceptIcon, Config.FINGER_SIZE * .35, Config.FINGER_SIZE * .35);
			acceptTitleButton.setBitmapData(UI.getSnapshot(acceptIcon, StageQuality.HIGH, "ChatSettingsScreen.acceptTitleButton"), true);
			
			var horizontalOverflow:int = Math.max(0, (Config.FINGER_SIZE - editTitleButton.width) * .5);
			var verticalOverflow:int = Math.max(0, (Config.FINGER_SIZE - editTitleButton.height) * .5);
			editTitleButton.setHitZone(editTitleButton.width, editTitleButton.height);
			editTitleButton.setOverflow(verticalOverflow, horizontalOverflow, horizontalOverflow, verticalOverflow);
			
			acceptTitleButton.setHitZone(acceptTitleButton.width, acceptTitleButton.height);
			acceptTitleButton.setOverflow(verticalOverflow, horizontalOverflow, horizontalOverflow, verticalOverflow);
			
			UI.destroy(editIcon);
			editIcon = null;
			
			chatAvatar = new BitmapButton();
			chatAvatar.setStandartButtonParams();
			chatAvatar.setDownScale(1);
			chatAvatar.setDownColor(0);
			chatAvatar.tapCallback = changeAvatar;
			chatAvatar.disposeBitmapOnDestroy = true;
			chatAvatar.usePreventOnDown = false;
			chatAvatar.cancelOnVerticalMovement = true;
			chatAvatar.show();
			
			chatAvatarContainer = new Sprite();
			chatAvatarContainer.addChild(chatAvatar);
			scrollPanel.addObject(chatAvatarContainer);
			
			avatarPreloader = new Preloader();
			avatarPreloader.visible = false;
			avatarPreloader.hide();
			avatarPreloaderContainer = new Sprite();
			avatarPreloaderContainer.addChild(avatarPreloader);
			scrollPanel.addObject(avatarPreloaderContainer);
			
			scrollPanel.addObject(line0Container);
			scrollPanel.addObject(line6Container);
			scrollPanel.addObject(line1);
			scrollPanel.addObject(line2);
			scrollPanel.addObject(line3);
			scrollPanel.addObject(line4);
			scrollPanel.addObject(line5);
		}
		
		private function changePushNotifications(value:Boolean):void {
			ChatManager.changeChatPushNotificationsStatus(chatModel.uid, value);
		}
		
		private function onTitleFocusIn():void {
			chatTitle.getTextField().setSelection(0, chatTitle.getTextField().length);
			editTitleButton.visible = false;
			acceptTitleButton.visible = true;
			
			acceptTitleButton.activate();
			editTitleButton.deactivate();
		}
		
		private function saveTitle():void {
			TweenMax.killDelayedCallsTo(onTitleEditCancel);
			editTitleButton.visible = true;
			acceptTitleButton.visible = false;
			
			acceptTitleButton.deactivate();
			editTitleButton.activate();
			
			if (chatTitle.value == "")
			{
				chatTitle.value = lastTitleValue;
			}
			if (chatTitle.value != lastTitleValue)
			{
				lastTitleValue = chatTitle.value;
				changeChatTitle();
			}
		}
		
		private function changeAvatar():void {
			if (avatarUploading)
			{
				return;
			}
			
			var menuItems:Array = [];
			
			menuItems.push( { fullLink:Lang.selectFromGallery, id:0, icon:GalleryIcon } );
			menuItems.push( { fullLink:Lang.makePhoto, id:1, icon:PhotoShotIcon } );
		//	menuItems.push( { fullLink:Lang.deleteAvatar, id:2 } );
			
			deleteAvatarRequest = createRequestId();
			
			DialogManager.showDialog(ScreenLinksDialog, { callback:function(data:Object):void {
				
				if (data.id == 0) {
					
					PhotoGaleryManager.S_GALLERY_IMAGE_LOADED.add(onAvatarFromDeviceImageSelected);
					lockScreen();
					PhotoGaleryManager.takeImage(false);
					return;
				}
				if (data.id == 1) {
					PhotoGaleryManager.S_GALLERY_IMAGE_LOADED.add(onAvatarFromDeviceImageSelected);
					lockScreen();
					PhotoGaleryManager.takeCamera(false);
					return;
				}
				if (data.id == 2) {
					DialogManager.alert(Lang.textConfirm, Lang.alertConfirmDeleteAvatar, function(val:int):void {
						if (val != 1)
							return;
						
						ChatManager.changeChatAvatar(chatModel.uid, null, deleteAvatarRequest);
							
					}, Lang.textDelete.toUpperCase(), Lang.textCancel.toUpperCase());
					return;
				}
			}, data:menuItems, itemClass:ListLinkWithIcon, title:Lang.changeAvatar, multilineTitle:true } );
		}
		
		private function lockScreen():void 
		{
			
		}
		
		private function onAvatarFromDeviceImageSelected(success:Boolean, image:ImageBitmapData, message:String):void {
			PhotoGaleryManager.S_GALLERY_IMAGE_LOADED.remove(onAvatarFromDeviceImageSelected);
			unlockScreen();
			
			if (success)
			{
				uploadAvatarImage(image);
			}
			else {
				avatarUploading = false;
				if (message)
				{
					DialogManager.alert(Lang.textWarning, message);
				}
			}
		}
		
		private function uploadAvatarImage(image:ImageBitmapData):void {
			if (image.width > Config.CHAT_AVATAR_SIZE_MAX || image.height > Config.CHAT_AVATAR_SIZE_MAX)
			{
				image = ImageManager.resize(image, Config.CHAT_AVATAR_SIZE_MAX, Config.CHAT_AVATAR_SIZE_MAX, ImageManager.SCALE_INNER_PROP);
			}
			changeAvatarRequest = createRequestId();
			
			encodeAvatar(image);
		}
		
		private function onAvatarCrypted(res:ImageBitmapData):void {
			TweenMax.delayedCall(1, encodeAvatar[res], null, true);
		}
		
		private function encodeAvatar(image:ImageBitmapData):void {
			echo("ChatSettingsScreen", "encodeAvatar");
			var pngImage:ByteArray = image.encode(image.rect, new PNGEncoderOptions(true));
			
			var imageString:String = "data:image/png;base64," + Base64.encodeByteArray(pngImage);
			avatarUploading = true;
			ChatManager.S_AVATAR_CHANGE.add(onAvatarImageChanged);
			ChatManager.changeChatAvatar(chatModel.uid, imageString, changeAvatarRequest);
			imageString = null;
			pngImage = null;
		}
		
		private function onAvatarImageChanged(result:Object):void {
			
			if (isDisposed)
			{
				return;
			}
			
			ChatManager.S_AVATAR_CHANGE.remove(onAvatarImageChanged);
			avatarUploading = false;
			
			if (result.success == true)
			{
				drawChatAvatar();
			}
			else {
				
			}
		}
		
		private function unlockScreen():void {
			
		}
		
		private function createRequestId():String
		{
			return MD5.hash(getTimer().toString());
		}
		
		private function onTitleEditChange():void 
		{
			
		}
		
		private function discardTitleChange():void 
		{
		//	return;
			TweenMax.killDelayedCallsTo(onTitleEditCancel);
			TweenMax.delayedCall(30, onTitleEditCancel,[], true);
		}
		
		private function onTitleEditCancel():void {
			
			if (isDisposed)
			{
				return;
			}
			
			echo("chatSettingsScreen", "onTitleEditCancel");
			titleEditing = false;
			if (lastTitleValue)
			{
				chatTitle.value = lastTitleValue;
			}
			
			editTitleButton.visible = true;
			acceptTitleButton.visible = false;
			
			acceptTitleButton.deactivate();
			editTitleButton.activate();
		}
		
		private function editTitle():void
		{
			lastTitleValue = chatTitle.value;
			chatTitle.setFocus();
			chatTitle.getTextField().setSelection(0, chatTitle.getTextField().length);
			chatTitle.getTextField().requestSoftKeyboard();
			editTitleButton.visible = false;
			acceptTitleButton.visible = true;
			
			acceptTitleButton.activate();
			editTitleButton.deactivate();
		}
		
		private function onTitleKeyboard(e:KeyboardEvent):void 
		{
			
		}
		
		private function changeChatTitle():void 
		{
			ChatManager.S_TITLE_CHANGE.add(onChatTitleChange);
			ChatManager.changeChatTitle(chatModel.uid, chatTitle.value, chatModel.securityKey);
		}
		
		private function onChatTitleChange(data:Object):void 
		{
			ChatManager.S_TITLE_CHANGE.remove(onChatTitleChange);
			if (isDisposed)
			{
				return;
			}
			if (data.success)
			{
				lastTitleValue = chatTitle.value;
			}
			else {
				chatTitle.value = lastTitleValue;
			}
		}
		
		private function leaveChat():void 
		{
			chatType = chatModel.type;
			chatUID = chatModel.uid;
			
			DialogManager.alert(Lang.textConfirm, Lang.alertConfirmLeaveConversation, 
					function(val:int):void {
						if (val != 1)
							return;
						leaveChatButton.deactivate();
						ChatManager.removeUser(chatModel.uid);
						ChatManager.S_USER_REMOVED_FROM_CHAT.add(onChatClosed);
					}, Lang.textExit, Lang.textCancel.toUpperCase());
		}
		
		private function onChatClosed(data:Object):void 
		{
			if (isDisposed)	{
				return;
			}
			
			if (data.chatUID == chatUID) {
				ChatManager.S_USER_REMOVED_FROM_CHAT.remove(onChatClosed);
				if (data.success) {
					var backScreen:Class = RootScreen;
					var backScreenData:Object;
					
					if (this.data != null && ("backScreenData" in this.data) && this.data.backScreenData != null ) {
						if (("backScreen" in this.data.backScreenData) && this.data.backScreenData.backScreen != null)
						{
							backScreen = this.data.backScreenData.backScreen;
							
							if (("backScreenData" in this.data.backScreenData) && this.data.backScreenData.backScreenData != null) {
								backScreenData = this.data.backScreenData.backScreenData;
							}
						}
					}
					
					MobileGui.changeMainScreen(backScreen, backScreenData);
				}
				else if (isActivated) {
					leaveChatButton.activate();
				}
			}
		}
		
		private function openUsersList():void 
		{
			MobileGui.changeMainScreen(ChatUsersScreen, { data:{users:chatModel.users, chatUid:chatModel.uid}, 
															backScreen:MobileGui.centerScreen.currentScreenClass, 
															backScreenData:data }, 
										ScreenManager.DIRECTION_RIGHT_LEFT);
		}
		
		private function onAdduserCalled():void 
		{
			if (chatModel != null && (chatModel.type == ChatRoomType.PRIVATE || chatModel.type == ChatRoomType.QUESTION))
			{
				var user:ChatUserVO = UsersManager.getInterlocutor(chatModel);
				if (user != null && user.secretMode == true)
				{
					return;
				}
			}
			
			MobileGui.changeMainScreen(SelectContactsScreen, { data:chatModel.uid, 
															title:Lang.addUserToChat,
															backScreen:MobileGui.centerScreen.currentScreenClass, 
															backScreenData:data },
										ScreenManager.DIRECTION_RIGHT_LEFT);
		}
		
		private function onAddBotCalled():void 
		{
			MobileGui.changeMainScreen(SelectBotScreen, { 	chatModel:chatModel, 
															title:Lang.addBot,
															backScreen:MobileGui.centerScreen.currentScreenClass, 
															backScreenData:data },
										ScreenManager.DIRECTION_RIGHT_LEFT);
		}
		
		private function openFirstUserProfile():void 
		{
			if (chatModel != null)
			{
				var user:ChatUserVO = chatModel.getUser(firstUser.uid);
				if (user != null && user.secretMode == true)
				{
					return;
				}
			}
			
			if (firstUser && firstUser.uid != Auth.uid)
			{
				MobileGui.changeMainScreen(UserProfileScreen, {data:firstUser, 
															backScreen:MobileGui.centerScreen.currentScreenClass, 
															backScreenData:data});
			}
		}
		
		private function openSecondUserProfile():void 
		{
			if (chatModel != null)
			{
				var user:ChatUserVO = chatModel.getUser(secondUser.uid);
				if (user != null && user.secretMode == true)
				{
					return;
				}
			}
			
			if (secondUser && secondUser.uid != Auth.uid)
			{
				MobileGui.changeMainScreen(UserProfileScreen, {data:secondUser, 
															backScreen:MobileGui.centerScreen.currentScreenClass, 
															backScreenData:data});
			}
		}
		
		private function changeChatLock(value:Boolean):void 
		{
			if (chatModel) {
				var locked:Boolean = chatModel.locked;
				//chatInput.closeKeyboard();
				if (locked)
					showDoUnlockAlert();
				else {
					showDoLockAlert();
				}
			}
		}
		
		private function showDoUnlockAlert():void {
			DialogManager.alert(Lang.textAlert, Lang.areYouSureRemovePin, function(val:int):void {
				if (val != 1)
				{
					option1.isSelected = true;
					return;
				}
				ChatManager.removePin(chatModel);
				option1.isSelected = false;
			}, Lang.textYes.toUpperCase(), Lang.textCancel.toUpperCase());
		}
		
		private function showDoLockAlert():void	{
			DialogManager.showPin(function(val:int, pin:String):void {
				if (val != 1) {
					option1.isSelected = false;
					return;
				}
				if (pin.length == 0) {
					option1.isSelected = false;
					return;
				}
				TweenMax.delayedCall(1, function():void {
					echo("ChatSettingsScreen","showDoLockAlert", "TweenMax.delayedCall");
					ChatManager.addPin(pin, chatModel);
					option1.isSelected = true;
				}, null, true);
			});
		}
		
		private function changeBackground():void
		{
			MobileGui.changeMainScreen(SelectBackgroundScreen, { data:{chatId:chatModel.uid, currentBackgroundId:currentChatBackgroundId}, 
															backScreen:MobileGui.centerScreen.currentScreenClass, 
															backScreenData:data }, 
										ScreenManager.DIRECTION_RIGHT_LEFT);
		}
		
		override protected function drawView():void
		{
			if (chatModel == null)
			{
				MobileGui.changeMainScreen(RootScreen, null, ScreenManager.DIRECTION_LEFT_RIGHT);
				return;
			}
			
			var iconSize:int = Config.FINGER_SIZE * 0.36;
			backgroundIconHeight = Config.FINGER_SIZE * .7;
			settingsIconPosition = int(backgroundIconHeight * .5);
			settingsTextPosition = int(backgroundIconHeight + Config.MARGIN*1.5);
			FIT_WIDTH = _width - buttonPaddingLeft*2;
			
			var currentYDrawPosition:int = Config.FINGER_SIZE * .3;
			topBar.drawView(_width);
			
			cleanChatAvatar();
			
			if (chatModel.type == ChatRoomType.GROUP)
			{
				chatAvatar.visible = true;
				drawChatAvatar();
				currentYDrawPosition += chatAvatar.height;
				line6Container.y = currentYDrawPosition + 1;
				drawChatTitle(currentYDrawPosition);
				currentYDrawPosition += chatTitle.view.height;
				line0.width = _width;
				line6.width = _width;
				line0.visible = true;
				line6.visible = true;
				line0Container.y = currentYDrawPosition;
			}
			else {
				chatAvatar.visible = false;
				chatTitle.view.visible = false;
				editTitleButton.visible = false;
				line0.visible = false;
				line6.visible = false;
			}
			
			currentYDrawPosition += Config.MARGIN;
			
			if (chatModel.type != ChatRoomType.QUESTION)
			{
				drawBackgroundControl(currentYDrawPosition);
				currentYDrawPosition += OPTION_LINE_HEIGHT;
				
				drawPinControl(currentYDrawPosition);
				currentYDrawPosition += OPTION_LINE_HEIGHT + Config.MARGIN;
			}
			else
			{
				option1.visible = false;
			}
			
			drawNotificationsControl(currentYDrawPosition);
			currentYDrawPosition += OPTION_LINE_HEIGHT + Config.MARGIN;
			
			line1.width = _width;
			line1.y = currentYDrawPosition;
			currentYDrawPosition += Config.MARGIN*1.5;
			
			drawUsersText(currentYDrawPosition);
			
			currentYDrawPosition += textUsers.height;
			currentYDrawPosition += Config.MARGIN*1.5;
			
			line2.width = _width;
			line2.y = currentYDrawPosition;
			
			currentYDrawPosition += Config.MARGIN;
			if (chatModel.type == ChatRoomType.PRIVATE || chatModel.type == ChatRoomType.QUESTION)
			{
				//selfUserButton.visible = true;
				firstUserButton.visible = true;
				secondUserButton.visible = true;
				allusersButton.visible = false;
				addUsersButton.visible = true;
				
				var firstUserData:ChatUserVO = UsersManager.getInterlocutor(chatModel);
				if (firstUserData) {
					firstUser = firstUserData.userVO;
				}
				
				/*var secondUserData:Object = new Object();
				secondUserData.uid = Auth.uid;
				secondUserData.type = Auth.type;
				secondUserData.avatar = Auth.avatar;
				secondUserData.fxid = Auth.fxcommID;
				secondUserData.name = Auth.username;
				secondUserData.fxcomm = new Object();
				secondUserData.fxcomm.firstname = "";
				secondUserData.fxcomm.lastname = "";
				var secondUserSource:ContactVO = new ContactVO(secondUserData);*/
				
				secondUser = Auth.myProfile;
				
				if (firstUser && firstUser.uid != Config.NOTEBOOK_USER_UID) {
					drawFirstUser(currentYDrawPosition);
					currentYDrawPosition += OPTION_LINE_HEIGHT;
				}
				if (secondUser && secondUser.uid != Config.NOTEBOOK_USER_UID) {
					drawSecondUser(currentYDrawPosition);
					currentYDrawPosition += OPTION_LINE_HEIGHT;
				}
			} else if (chatModel.type == ChatRoomType.GROUP) {
				firstUserButton.visible = true;
				secondUserButton.visible = false;
				allusersButton.visible = true;
				addUsersButton.visible = true;
				
				if (chatModel.ownerUID == Auth.uid) {
					/*var selfUserData:Object = new Object();
					selfUserData.uid = Auth.uid;
					selfUserData.type = Auth.type;
					selfUserData.avatar = Auth.avatar;
					selfUserData.fxid = Auth.fxcommID;
					selfUserData.name = Auth.username;
					selfUserData.fxcomm = new Object();
					selfUserData.fxcomm.firstname = "";
					selfUserData.fxcomm.lastname = "";
					var selfUserSource:ContactVO = new ContactVO(selfUserData);*/
					
					firstUser = Auth.myProfile;
				} else {
					var chatOwner:Object = UsersManager.getChatOwner(chatModel);
					if (chatOwner) {
						firstUser = UsersManager.getFullUserData(chatOwner.uid);
					}
				}
				
				if (firstUser) {
					drawFirstUser(currentYDrawPosition);
					currentYDrawPosition += OPTION_LINE_HEIGHT;
				} else {
					firstUserButton.visible = false;
				}
				
				drawUserlistButton(currentYDrawPosition);
				currentYDrawPosition += OPTION_LINE_HEIGHT;
			}
			
			if (chatModel.type != ChatRoomType.QUESTION)
			{
				var user:ChatUserVO = UsersManager.getInterlocutor(chatModel);
				if (user != null && user.uid == Config.NOTEBOOK_USER_UID)
				{
					addUsersButton.visible = false;
				}
				else
				{
					drawAddUserButton(currentYDrawPosition);
					currentYDrawPosition += OPTION_LINE_HEIGHT;
				}
				drawAddBotButton(currentYDrawPosition);
				currentYDrawPosition += OPTION_LINE_HEIGHT;
			}
			else
			{
				addBotButton.visible = false;
				addUsersButton.visible = false;
			}
			
			currentYDrawPosition += Config.MARGIN;
			line3.width = _width;
			line3.y = currentYDrawPosition;
			currentYDrawPosition += Config.FINGER_SIZE*.6;
			line4.width = _width;
			line4.y = currentYDrawPosition;
			
			currentYDrawPosition += Config.MARGIN*1.5;
			drawLeaveButton(currentYDrawPosition);
			currentYDrawPosition += OPTION_LINE_HEIGHT;
			currentYDrawPosition += Config.MARGIN * 1.5;
			line5.width = _width;
			line5.y = currentYDrawPosition;
			
			scrollPanel.view.y =  topBar.trueHeight;
			scrollPanel.setWidthAndHeight(_width, _height - topBar.trueHeight - Config.APPLE_TOP_OFFSET, false);
			
			if (!scrollPanel.fitInScrollArea())
			{
				if (!scrollPanel.isItemVisible(chartTitleContailer))
				{
					scrollPanel.scrollToPosition(scrollPanel.itemsHeight - chartTitleContailer.y + Config.MARGIN + chatTitle.view.height - scrollPanel.height);
				}
				
				scrollPanel.enable();
			}
			else {
				scrollPanel.disable();
			}
			
			scrollPanel.update();
		}
		
		private function cleanChatAvatar():void 
		{
			
		}
		
		private function drawLeaveButton(position:int):void 
		{
			var icon:Sprite = new (Style.icon(Style.ICON_LOGOUT));
			UI.colorize(icon, Style.color(Style.COLOR_ICON_SETTINGS));
			UI.scaleToFit(icon, iconSize, iconSize);
			leaveChatButton.setBitmapData(UI.renderSettingsButtonCustomPositions(
																			FIT_WIDTH, 
																			OPTION_LINE_HEIGHT, 
																			new TextFieldSettings(Lang.leaveChat, Style.color(Style.COLOR_TEXT), Config.FINGER_SIZE * .34, TextFormatAlign.LEFT),
																			null,
																			null,
																			settingsIconPosition, 
																			settingsTextPosition, 
																			icon), true);
			leaveChatButton.x = buttonPaddingLeft;
			leaveChatButton.y = position;
			
			UI.destroy(icon);;
			icon = null;
		}
		
		private function drawAddUserButton(position:int):void {
			var icon:DisplayObject = new (Style.icon(Style.ICON_ADD_USER));
			var icon2:IconArrowRight = new IconArrowRight();
			
			UI.scaleToFit(icon, iconSize, iconSize);
			UI.scaleToFit(icon2, iconArrowSize, iconArrowSize);
			UI.colorize(icon, Style.color(Style.COLOR_ICON_SETTINGS));
			UI.colorize(icon2, Style.color(Style.ICON_RIGHT_COLOR));
			addUsersButton.setBitmapData(UI.renderSettingsButtonCustomPositions(
																			FIT_WIDTH, 
																			OPTION_LINE_HEIGHT, 
																			new TextFieldSettings(Lang.addUsersToChat, Style.color(Style.COLOR_TEXT), Config.FINGER_SIZE * .34, TextFormatAlign.LEFT),
																			null,
																			null, 
																			settingsIconPosition, 
																			settingsTextPosition, 
																			icon, 
																			icon2), true);
			addUsersButton.x = buttonPaddingLeft;
			addUsersButton.y = position;
			
			UI.destroy(icon);
			UI.destroy(icon2);
			icon = null;
			icon2 = null;
		}
		
		private function drawAddBotButton(position:int):void {
			var icon:DisplayObject = new (Style.icon(Style.ICON_ADD_USER));
			var icon2:IconArrowRight = new IconArrowRight();
			
			UI.scaleToFit(icon, iconSize, iconSize);
			UI.scaleToFit(icon2, iconArrowSize, iconArrowSize);
			UI.colorize(icon, Style.color(Style.COLOR_ICON_SETTINGS));
			UI.colorize(icon2, Style.color(Style.ICON_RIGHT_COLOR));
			addBotButton.setBitmapData(UI.renderSettingsButtonCustomPositions(
																			FIT_WIDTH, 
																			OPTION_LINE_HEIGHT, 
																			new TextFieldSettings(Lang.addBotToChat, Style.color(Style.COLOR_TEXT), Config.FINGER_SIZE * .34, TextFormatAlign.LEFT),
																			null,
																			null, 
																			settingsIconPosition, 
																			settingsTextPosition, 
																			icon, 
																			icon2), true);
			addBotButton.x = buttonPaddingLeft;
			addBotButton.y = position;
			
			UI.destroy(icon);
			UI.destroy(icon2);
			icon = null;
			icon2 = null;
		}
		
		private function drawUserlistButton(position:int):void 	{
			var icon:UsersListIcon = new UsersListIcon();
			var icon2:IconArrowRight = new IconArrowRight();			
			UI.scaleToFit(icon, iconSize, iconSize);
			UI.scaleToFit(icon2, iconArrowSize, iconArrowSize);
			UI.colorize(icon, Style.color(Style.COLOR_ICON_SETTINGS));
			UI.colorize(icon2, Style.color(Style.COLOR_ICON_SETTINGS));
			allusersButton.setBitmapData(UI.renderSettingsButtonCustomPositions(
																			FIT_WIDTH, 
																			OPTION_LINE_HEIGHT, 
																			new TextFieldSettings(Lang.usersInChat, Style.color(Style.COLOR_TEXT), Config.FINGER_SIZE * .34, TextFormatAlign.LEFT),
																			null,
																			new TextFieldSettings((chatModel.users.length).toString(), Style.color(Style.COLOR_TEXT), Config.FINGER_SIZE * .40, TextFormatAlign.LEFT),
																			settingsIconPosition, 
																			settingsTextPosition, 
																			icon, 
																			icon2), true);
			allusersButtonContainer.x = buttonPaddingLeft;
			allusersButtonContainer.y = position;
			
			UI.destroy(icon);
			UI.destroy(icon2);
			icon = null;
			icon2 = null;
		}
		
		private function drawFirstUser(position:int, avatarBD:ImageBitmapData = null, avatarLoadingSuccess:Boolean = true):void 
		{
			if (_isDisposed)
			{
				return;
			}
			
			firstUserButtonContainer.x = buttonPaddingLeft;
			firstUserButtonContainer.y = position;
			
			if (avatarBD)
			{
				if (firstUserAvatarBD && firstUserAvatarBD != avatarBD)
				{
					firstUserAvatarBD.dispose();
				}
				firstUserAvatarBD = avatarBD;
			}
			
			var avatarURL:String = firstUser.getAvatarURL();
			var userName:String = firstUser.getDisplayName();
			
			if (chatModel != null)
			{
				var user:ChatUserVO = chatModel.getUser(firstUser.uid);
				if (user != null && user.secretMode == true)
				{
					avatarURL = LocalAvatars.SECRET;
					userName = Lang.textIncognito;
				}
			}
			
			if (avatarBD)
			{
				avatar.graphics.clear();
				
				ImageManager.drawGraphicCircleImage(
											avatar.graphics, 
											avatarSize, 
											avatarSize, 
											avatarSize, 
											avatarBD, 
											ImageManager.SCALE_PORPORTIONAL);
				
				onlineMark.visible = false;
				var onlineStatus:OnlineStatus = UsersManager.isOnline(firstUser.uid);
				if (!onlineStatus)
				{
					UsersManager.registrateUserUID(firstUser.uid);
				}
				else
				{
					onlineMark.visible = onlineStatus.online;
				}
				
				var iconRightArrow:Sprite;
				
				if (firstUser.uid != Auth.uid)
				{
					iconRightArrow = new IconArrowRight();							
					UI.scaleToFit(iconRightArrow, iconArrowSize, iconArrowSize);
					UI.colorize(iconRightArrow, Style.color(Style.ICON_RIGHT_COLOR));	
				}
				
				var ownerText:TextFieldSettings;
				if (firstUser.uid == chatModel.ownerUID)
				{
					ownerText = new TextFieldSettings(Lang.textOwner, Color.GREEN, Config.FINGER_SIZE * .24, TextFormatAlign.LEFT);
				}
				
				firstUserButton.setBitmapData(UI.renderSettingsButtonCustomPositions(
																				FIT_WIDTH, 
																				OPTION_LINE_HEIGHT, 
																				new TextFieldSettings(userName, Style.color(Style.COLOR_TEXT), Config.FINGER_SIZE * .34, TextFormatAlign.LEFT),
																				ownerText,
																				null,
																				settingsIconPosition, 
																				settingsTextPosition, 
																				userAvatarContainer,
																				iconRightArrow), true);
				if (iconRightArrow)
				{
					UI.destroy(iconRightArrow);
					iconRightArrow = null;
				}
				
				return;
			}
			
			if (avatarURL && avatarLoadingSuccess)
			{
				var cachedAvatarBD:ImageBitmapData = ImageManager.getImageFromCache(avatarURL);
				
				if (cachedAvatarBD)
				{
					drawFirstUser(position, cachedAvatarBD);
				}
				else
				{
					ImageManager.loadImage(avatarURL, onFirstUserAvatarLoaded);
				}
				return;
			}
			
			if (userName != null && String(userName).length > 0 && AppTheme.isLetterSupported(String(userName).charAt(0)) )
			{
				var letterAvatarBD:ImageBitmapData = UI.renderLetterAvatar(String(userName).charAt(0).toUpperCase(), Config.FINGER_SIZE*.4, avatarSize, AppTheme.getColorFromPallete(String(firstUser.getDisplayName())))
				
				drawFirstUser(position, letterAvatarBD);
				letterAvatarBD.dispose();
			}
			else {
				
				var emptyAvatarBD:ImageBitmapData = UI.getEmptyAvatarBitmapData(avatarSize*2, avatarSize*2)
				
				drawFirstUser(position, emptyAvatarBD);
				emptyAvatarBD.dispose();
			}
		}
		
		private function onFirstUserAvatarLoaded(url:String, bmd:ImageBitmapData, success:Boolean):void
		{
			if (!isDisposed)
			{
				if (bmd && success)
				{
					drawFirstUser(firstUserButtonContainer.y, bmd);
				}
				else
				{
					drawFirstUser(firstUserButtonContainer.y, null, false);
				}
			}
		}
		
		private function drawSecondUser(position:int, avatarBD:ImageBitmapData = null, avatarLoadingSuccess:Boolean = true):void 
		{
			if (_isDisposed)
			{
				return;
			}
			
			secondUserButtonContainer.x = buttonPaddingLeft;
			secondUserButtonContainer.y = position;
			
			if (avatarBD)
			{
				if (secondUserAvatarBD && secondUserAvatarBD != avatarBD)
				{
					secondUserAvatarBD.dispose();
				}
				secondUserAvatarBD = avatarBD;
			}
			
			var avatarURL:String = secondUser.getAvatarURL();
			var userName:String = secondUser.getDisplayName();

			if (chatModel != null)
			{
				var user:ChatUserVO = chatModel.getUser(secondUser.uid);
				if (user != null && user.secretMode == true)
				{
					avatarURL = LocalAvatars.SECRET;
					userName = Lang.textIncognito;
				}
			}
			
			if (avatarBD)
			{
				avatar.graphics.clear();
				
				ImageManager.drawGraphicCircleImage(
											avatar.graphics, 
											avatarSize, 
											avatarSize, 
											avatarSize, 
											avatarBD, 
											ImageManager.SCALE_PORPORTIONAL);
				
				onlineMark.visible = false;
				var onlineStatus:OnlineStatus = UsersManager.isOnline(secondUser.uid);
				if (!onlineStatus)
				{
					UsersManager.registrateUserUID(secondUser.uid);
				}
				else
				{
					onlineMark.visible = onlineStatus.online;
				}
				
				var iconRightArrow:Sprite;
				
				if (secondUser.uid != Auth.uid)
				{
					iconRightArrow = new IconArrowRight();							
					UI.scaleToFit(iconRightArrow, iconArrowSize, iconArrowSize);
					UI.colorize(iconRightArrow, Style.color(Style.ICON_RIGHT_COLOR));	
				}
				
				var ownerText:TextFieldSettings;
				if (secondUser.uid == chatModel.ownerUID)
				{
					ownerText = new TextFieldSettings(Lang.textOwner, Color.GREEN, Config.FINGER_SIZE * .24, TextFormatAlign.LEFT);
				}
				
				secondUserButton.setBitmapData(UI.renderSettingsButtonCustomPositions(
																				FIT_WIDTH, 
																				OPTION_LINE_HEIGHT, 
																				new TextFieldSettings(userName, Style.color(Style.COLOR_TEXT), Config.FINGER_SIZE * .34, TextFormatAlign.LEFT),
																				ownerText,
																				null,
																				settingsIconPosition, 
																				settingsTextPosition, 
																				userAvatarContainer,
																				iconRightArrow), true);
				if (iconRightArrow)
				{
					UI.destroy(iconRightArrow);
					iconRightArrow = null;
				}
				
				return;
			}
			
			if (avatarURL && avatarLoadingSuccess)
			{
				var cachedAvatarBD:ImageBitmapData = ImageManager.getImageFromCache(avatarURL);
				
				if (cachedAvatarBD)
				{
					drawSecondUser(position, cachedAvatarBD);
				}
				else
				{
					ImageManager.loadImage(avatarURL, onSecondUserAvatarLoaded);
				}
				return;
			}
			
			if (userName != null && String(userName).length > 0 && AppTheme.isLetterSupported(String(userName).charAt(0)) )
			{
				var letterAvatarBD:ImageBitmapData = UI.renderLetterAvatar(String(userName).charAt(0).toUpperCase(), Config.FINGER_SIZE*.4, avatarSize, AppTheme.getColorFromPallete(String(userName)))
				
				drawSecondUser(position, letterAvatarBD);
				letterAvatarBD.dispose();
			}
			else {
				
				var emptyAvatarBD:ImageBitmapData = UI.getEmptyAvatarBitmapData(avatarSize*2, avatarSize*2)
				
				drawSecondUser(position, emptyAvatarBD);
				emptyAvatarBD.dispose();
			}
		}
		
		private function onSecondUserAvatarLoaded(url:String, bmd:ImageBitmapData, success:Boolean):void
		{
			if (!isDisposed)
			{
				if (bmd && success)
				{
					drawSecondUser(secondUserButtonContainer.y, bmd);
				}
				else
				{
					drawSecondUser(secondUserButtonContainer.y, null, false);
				}
			}
		}
		
		private function onUserOnlineStatusChanged(status:OnlineStatus, method:String):void 
		{
			if (firstUser && status.uid == firstUser.uid)
			{
				drawFirstUser(firstUserButtonContainer.y, firstUserAvatarBD);
			}
			else if (secondUser && status.uid == secondUser.uid)
			{
				drawSecondUser(secondUserButtonContainer.y, secondUserAvatarBD);
			}
		}
		
		private function drawUsersText(position:int):void
		{
			//this update should be only on width update(this checking should be done in BaseScreen?);
			if (textUsers.bitmapData)
			{
				UI.disposeBMD(textUsers.bitmapData);
				textUsers.bitmapData = null;
			}
			
			var textUsersBD:BitmapData = TextUtils.createTextFieldData(
												Lang.textUsers, 
												_width, 
												10, 
												false, 
												TextFormatAlign.LEFT, 
												TextFieldAutoSize.LEFT, 
												Config.FINGER_SIZE * .26, 
												false, 
												Style.color(Style.COLOR_SUBTITLE), 
												Style.color(Style.COLOR_BACKGROUND), 
												true);
			textUsers.bitmapData = textUsersBD;
			textUsers.y = position;
			textUsers.x = buttonPaddingLeft;
		}
		
		private function drawPinControl(position:int):void
		{
			option1.iconPosition = settingsIconPosition;
			option1.textPosition = settingsTextPosition;
			option1.create(FIT_WIDTH, OPTION_LINE_HEIGHT, lockIcon, Lang.setSecurityMode, chatModel.locked, true, Style.color(Style.COLOR_TEXT));
			option1.y = position;
			option1.x = buttonPaddingLeft;
		}
		
		private function drawNotificationsControl(position:int):void
		{
			
			optionNotifications.iconPosition = settingsIconPosition;
			optionNotifications.textPosition = settingsTextPosition;
			optionNotifications.create(FIT_WIDTH, OPTION_LINE_HEIGHT, notificationIcon, Lang.textNotifications, chatModel.getPushAllowed(), true, Style.color(Style.COLOR_TEXT));
			optionNotifications.y = position;
			optionNotifications.x = buttonPaddingLeft;
		}
		
		private function drawBackgroundControl(position:int):void
		{
			var bitmapDataSolid:ImageBitmapData = new ImageBitmapData("", backgroundIconHeight, backgroundIconHeight, false, MainColors.GREY_LIGHT);
			drawBackgroundCircle(bitmapDataSolid);
			bitmapDataSolid = null;
			
			changeBitmap.y = position;
			changeBitmap.x = buttonPaddingLeft;
			
			var uid:String = null;
			if (data is String)
				uid = data as String;
			
			if (uid == null){
				if ("data" in data && "chatSettings" in data.data && data.data.chatSettings is ChatSettingsModel){
					uid=(data.data.chatSettings as ChatSettingsModel).chatBackId;
				}
			}
			
			currentChatBackgroundId = uid;
			if (currentChatBackgroundId){
				var backgroundModel:BackgroundModel = ChatBackgroundCollection.getBackground(currentChatBackgroundId);
				if (backgroundModel){
					drawBackgroundCircle(Assets.getBackground(backgroundModel.small));
				}
			}else {
				bitmapDataSolid = new ImageBitmapData("", backgroundIconHeight, backgroundIconHeight, false, MainColors.CHAT_COLOR_1);
				drawBackgroundCircle(bitmapDataSolid);
				bitmapDataSolid = null;
			}
		}
		
		//!TODO: move this logic to component;
		private function drawBackgroundCircle(bmd:ImageBitmapData):void 
		{
			if (isDisposed)
			{
				return;
			}
			
			var bitmapDataCircle:ImageBitmapData = new ImageBitmapData("ChatSettingsScreen.chatBackgroundImage", backgroundIconHeight, backgroundIconHeight, true)
			ImageManager.drawCircleImageToBitmap(bitmapDataCircle, bmd, 0, 0, backgroundIconHeight*.5);
			
			var backImageIcon:Bitmap = new Bitmap(bitmapDataCircle);
			backImageIcon.smoothing = true;
			var changeBitmapBitmapData:BitmapData = UI.renderSettingsButtonCustomPositions(
															FIT_WIDTH, 
															OPTION_LINE_HEIGHT,
															new TextFieldSettings(Lang.backgroundImage, Style.color(Style.COLOR_TEXT), Config.FINGER_SIZE * 0.34, TextFormatAlign.LEFT), 
															null,
															null,
															settingsIconPosition,
															settingsTextPosition,
															backImageIcon);
			UI.destroy(backImageIcon);
			UI.disposeBMD(bitmapDataCircle);
			bitmapDataCircle = null;
			backImageIcon = null;
			UI.disposeBMD(bmd);
			bmd = null;
			changeBitmap.setBitmapData(changeBitmapBitmapData, true);
		}
		
		private function drawChatTitle(position:int):void 
		{
			chatTitle.view.visible = true;
			chatTitle.value = (lastTitleValue == null)?chatModel.title:lastTitleValue;
			chartTitleContailer.y = position;
			
			chatTitle.width = _width - buttonPaddingLeft*2 - Config.MARGIN - editTitleButton.width;
			
			editTitleButtonContainer.x = int(chatTitle.width + chatTitle.view.x + Config.MARGIN);
			editTitleButtonContainer.y = int(chartTitleContailer.y + chatTitle.view.height * .5 - editTitleButton.height * .5);
			
			acceptTitleButtonContainer.x = int(chatTitle.width + chatTitle.view.x + Config.MARGIN);
			acceptTitleButtonContainer.y = int(chartTitleContailer.y + chatTitle.view.height * .5 - editTitleButton.height * .5);
		}
		
		private function drawChatAvatar():void 
		{
			if (chatModel.avatar == currentLoadedAvatar && chatModel.avatar != null)
			{
				return;
			}
			
			if (!currentLoadedAvatar)
			{
				setDefaultChatAvatar();
			}
			
			if (chatModel.avatar)
			{
				var imageUrl:String = getChatAvatarUrl();
				displayAvatarPreloader();
				ImageManager.loadImage(imageUrl, onAvatarLoaded);
			}
        }
		
		private function displayAvatarPreloader():void {
			avatarPreloaderContainer.x = chatAvatar.x + chatAvatar.width * .5;
			avatarPreloaderContainer.y = chatAvatarContainer.y + chatAvatar.height * .5;
			avatarPreloader.visible = true;
			avatarPreloader.show();
		}
		
		private function hideAvatarPreloader():void {
			avatarPreloader.hide();
		}
		
		private function getChatAvatarUrl():String {
			if (chatModel.avatar == null || chatModel.avatar == "")
			{
				return null;
			}
			return Config.URL_PHP_CORE_SERVER_FILE + "?method=files.get&key=" + Auth.key + "&uid=" + chatModel.avatar + "&type=image";
		}
		
		private function onAvatarLoaded(url:String, bitmapData:ImageBitmapData, success:Boolean):void {
			
			if (isDisposed)
			{
				return;
			}
			
			hideAvatarPreloader();
			if (success) {
				currentLoadedAvatar = chatModel.avatar;
				chatAvatar.setBitmapData(getCircleImage(bitmapData), true);
				updatelayout();
			}
		}
		
		private function getCircleImage(bitmapData:BitmapData):ImageBitmapData {
			//var newAvatar:ImageBitmapData = new ImageBitmapData("ChatSettingsScreen.chatAvatarImage", _width, (Config.FINGER_SIZE*3 + Config.MARGIN*3), false, 0xFF0000);
			var avatarSide:int = (Config.FINGER_SIZE * 3 + Config.MARGIN * 3);
			var newAvatar:ImageBitmapData = new ImageBitmapData("ChatSettingsScreen.chatAvatarImage", avatarSide,avatarSide , true, 0xFF0000);
			//ImageManager.drawCircleImageToBitmap(newAvatar, bitmapData, int(_width*.5 - Config.FINGER_SIZE*1.5), int(Config.MARGIN*2), int(Config.FINGER_SIZE*1.5));
			ImageManager.drawCircleImageToBitmap(newAvatar, bitmapData, avatarSide, avatarSide, avatarSide*.5);
			
			return newAvatar;
		}
		
		private function updatelayout():void 
		{
			var currentYDrawPosition:int = 0;
			if (chatModel.type == ChatRoomType.GROUP)
			{
				currentYDrawPosition += chatAvatar.height;
				line6Container.y = currentYDrawPosition + 1;
				chartTitleContailer.y = currentYDrawPosition;
				editTitleButtonContainer.y = int(chartTitleContailer.y + chatTitle.view.height*.5 - editTitleButton.height*.5);
				currentYDrawPosition += chatTitle.view.height;
				line0Container.y = currentYDrawPosition;
			}
			
			currentYDrawPosition += Config.MARGIN;
			changeBitmap.y = currentYDrawPosition;
			currentYDrawPosition += OPTION_LINE_HEIGHT;
			option1.y = currentYDrawPosition;
			currentYDrawPosition += OPTION_LINE_HEIGHT + Config.MARGIN;
			optionNotifications.y = currentYDrawPosition;
			currentYDrawPosition += OPTION_LINE_HEIGHT + Config.MARGIN;
			line1.y = currentYDrawPosition;
			currentYDrawPosition += Config.MARGIN*1.5;
			textUsers.y = currentYDrawPosition;
			currentYDrawPosition += textUsers.height;
			currentYDrawPosition += Config.MARGIN*1.5;
			line2.y = currentYDrawPosition;
			currentYDrawPosition += Config.MARGIN;
			if (chatModel.type == ChatRoomType.PRIVATE)
			{
				firstUserButtonContainer.y = currentYDrawPosition;
				currentYDrawPosition += OPTION_LINE_HEIGHT;
			}
			else if (chatModel.type == ChatRoomType.GROUP)
			{
				if (UsersManager.getChatOwner(chatModel))
				{
					firstUserButtonContainer.y = currentYDrawPosition;
					currentYDrawPosition += OPTION_LINE_HEIGHT;
				}
				allusersButtonContainer.y = currentYDrawPosition;
				currentYDrawPosition += OPTION_LINE_HEIGHT;
			}
			addUsersButton.y = currentYDrawPosition;
			currentYDrawPosition += OPTION_LINE_HEIGHT;
			
			if (chatModel.type != ChatRoomType.QUESTION)
			{
				currentYDrawPosition += OPTION_LINE_HEIGHT;
			}
			
			currentYDrawPosition += Config.MARGIN;
			line3.y = currentYDrawPosition;
			currentYDrawPosition += Config.FINGER_SIZE*.6;
			line4.y = currentYDrawPosition;
			currentYDrawPosition += Config.MARGIN*1.5;
			leaveChatButton.y = currentYDrawPosition;
			currentYDrawPosition += OPTION_LINE_HEIGHT;
			currentYDrawPosition += Config.MARGIN * 1.5;
			line5.y = currentYDrawPosition;
			
			if (chatAvatar != null){
				chatAvatar.x = (_width - chatAvatar.width) * .5;
			}
			scrollPanel.view.y =  topBar.trueHeight;
			scrollPanel.setWidthAndHeight(_width, _height - topBar.trueHeight - Config.APPLE_TOP_OFFSET, false);
			
			if (!scrollPanel.fitInScrollArea())
			{
				scrollPanel.scrollToPosition(chartTitleContailer.y - Config.MARGIN);
				scrollPanel.enable();
			}
			else {
				scrollPanel.disable();
			}
			
			scrollPanel.update();
		}
		
		private function resizeImageToAvatar(bitmapData:BitmapData):BitmapData 
		{
			var avatarHeight:int;
			var maxAvatarHeight:int = Config.FINGER_SIZE * 4;
			var minAvatarHeight:int = Config.FINGER_SIZE * 2;
			var resultImageWidth:int;
			var resultImageHeight:int;
			
			var widthScale:Number = 1;
			resultImageWidth = bitmapData.width;
			resultImageHeight = bitmapData.height;
			
			if (bitmapData.width > _width)
			{
				resultImageWidth = _width;
				widthScale = _width / bitmapData.width;
			}
			
			resultImageHeight = Math.ceil(bitmapData.height * widthScale);
			
			if (resultImageHeight > maxAvatarHeight)
			{
				resultImageHeight = maxAvatarHeight;
				avatarHeight = maxAvatarHeight;
				widthScale = avatarHeight / bitmapData.height;
				resultImageWidth = bitmapData.width * widthScale;
			}
			else if (resultImageHeight < minAvatarHeight)
			{
				avatarHeight = minAvatarHeight;
			}
			else {
				avatarHeight = resultImageHeight;
			}
			
			var newAvatar:BitmapData = new ImageBitmapData("ChatSettingsScreen.chatAvatarImage", _width, avatarHeight, false, 0x444444);
			var xPos:int = _width * .5 - resultImageWidth * .5;
			var yPos:int = avatarHeight * .5 - resultImageHeight * .5;
			
			var matrix:Matrix = new Matrix();
			matrix.scale(widthScale, widthScale);
			matrix.tx = xPos;
			matrix.ty = yPos;
			newAvatar.draw(bitmapData, matrix);
			
			return newAvatar;
		}
		
		private function setDefaultChatAvatar():void 
		{
			var emptyAvatar:EmptyChatAvatar = new EmptyChatAvatar();
			emptyAvatar.width = _width;
			emptyAvatar.scaleY = emptyAvatar.scaleX;
			chatAvatar.setBitmapData(UI.getSnapshot(emptyAvatar, StageQuality.HIGH, "ChatSettingsScreen.emptyAvatar"), true);
			UI.destroy(emptyAvatar);
			emptyAvatar = null;
		}
		
		private function addChatAvatar():void 
		{
			cleanChatAvatar();
		}
		
		override public function clearView():void
		{
			super.clearView();
		}
		
		override public function dispose():void
		{
			super.dispose();
			lastTitleValue = null;
			if (chatTitle)
			{
				chatTitle.forceFocusOut();
				chatTitle.S_FOCUS_OUT.remove(discardTitleChange);
				chatTitle.S_TAPPED.remove(editTitle);
				chatTitle.S_CHANGED.remove(onTitleEditChange);
				
				chatTitle.dispose();
				
				chatTitle = null;
			}
			
			if (lockIcon)
			{
				lockIcon.dispose();
				lockIcon = null;
			}
			
			if (notificationIcon)
			{
				notificationIcon.dispose();
				notificationIcon = null;
			}
			
			if (avatarWithLetterBD)
			{
				avatarWithLetterBD.dispose();
				avatarWithLetterBD = null
			}
			
			if (chatAvatar)
			{
				chatAvatar.dispose();
				chatAvatar = null;
			}
			if (chatAvatarContainer)
			{
				UI.destroy(chatAvatarContainer);
				chatAvatarContainer = null;
			}
			
			if (optionNotifications)
			{
				optionNotifications.dispose();
				optionNotifications = null;
			}
			
			chatModel = null;
			
			if (topBar != null)
				topBar.dispose();
			topBar = null;
			
			if (changeBitmap)
				changeBitmap.dispose();
			changeBitmap = null;
			if (option1)
			{
				option1.dispose();
				option1 = null;
			}
			if (scrollPanel)
				scrollPanel.dispose();
			scrollPanel = null;
			if (selfUserButton != null) 
				selfUserButton.dispose();
			selfUserButton = null;
			if (firstUserButton != null) 
				firstUserButton.dispose();
			firstUserButton = null;
			if (secondUserButton != null) 
				secondUserButton.dispose();
			secondUserButton = null;
			if (addBotButton != null) 
				addBotButton.dispose();
			addBotButton = null;
			if (addUsersButton != null) 
				addUsersButton.dispose();
			addUsersButton = null;
			if (allusersButton != null) 
				allusersButton.dispose();
			allusersButton = null;
			if (leaveChatButton != null) 
				leaveChatButton.dispose();
			leaveChatButton = null;
			
			if (editTitleButton != null) 
				editTitleButton.dispose();
			editTitleButton = null;
			
			chatModel = null;
			
			UI.destroy(line0);
			UI.destroy(line1);
			UI.destroy(line2);
			UI.destroy(line3);
			UI.destroy(line4);
			UI.destroy(line5);
			UI.destroy(line6);
			UI.destroy(textUsers);
			UI.destroy(userAvatarContainer);
			UI.destroy(onlineMark);
			UI.destroy(avatar);
			line0 = null;
			line1 = null;
			line2 = null;
			line3 = null;
			line4 = null;
			line5 = null;
			line6 = null;
			textUsers = null;
			userAvatarContainer = null;
			onlineMark = null;
			avatar = null;
			
			firstUser = null;
			secondUser = null;
			
			UI.destroy(editTitleButtonContainer);
			UI.destroy(chartTitleContailer);
			UI.destroy(allusersButtonContainer);
			UI.destroy(firstUserButtonContainer);
			UI.destroy(secondUserButtonContainer);
			UI.destroy(line0Container);
			
			editTitleButtonContainer = null;
			chartTitleContailer = null;
			allusersButtonContainer = null;
			firstUserButtonContainer = null;
			line0Container = null;
			
			if (avatarPreloader)
			{
				avatarPreloader.dispose();
				avatarPreloader = null;
			}
			if (avatarPreloaderContainer)
			{
				UI.destroy(avatarPreloaderContainer);
				avatarPreloaderContainer = null;
			}
			
			if (acceptTitleButton)
			{
				acceptTitleButton.dispose();
				acceptTitleButton = null;
			}
			if (acceptTitleButtonContainer)
			{
				UI.destroy(acceptTitleButtonContainer);
				acceptTitleButtonContainer = null;
			}
			
			Assets.clearBackgrounds();
			
			PhotoGaleryManager.S_GALLERY_IMAGE_LOADED.remove(onAvatarFromDeviceImageSelected);
			ChatManager.S_TITLE_CHANGE.remove(onChatTitleChange);
			ChatManager.S_AVATAR_CHANGE.remove(onAvatarImageChanged);
			TweenMax.killDelayedCallsTo(onTitleEditCancel);
			ChatManager.S_CHAT_USERS_CHANGED.remove(onChatChanged);
		}
		
		override public function activateScreen():void
		{
			if (_isDisposed)
				return;
			super.activateScreen();
			if (topBar != null)
				topBar.activate();
			option1.activate();
			
			if (chatModel.type != ChatRoomType.QUESTION)
			{
				changeBitmap.activate();
			}
			
			optionNotifications.activate();
			scrollPanel.enable();
			chatAvatar.activate();
			leaveChatButton.activate();
			if (chatModel)
			{
				if (chatModel.type == ChatRoomType.PRIVATE)
				{
				//	selfUserButton.activate();
				}
				else if (chatModel.type == ChatRoomType.GROUP)
				{
					allusersButton.activate();
				}
			}
			firstUserButton.activate();
			secondUserButton.activate();
			chatTitle.activate();
			editTitleButton.activate();
			addUsersButton.activate();
			addBotButton.activate();
			UsersManager.S_ONLINE_CHANGED.add(onUserOnlineStatusChanged);
			
			if (editTitleButton.visible)
			{
				editTitleButton.activate();
			}
			
			if (acceptTitleButton.visible)
			{
				acceptTitleButton.activate();
			}
		}
		
		override public function deactivateScreen():void
		{
			super.deactivateScreen();
			if (_isDisposed)
				return;

			if (topBar != null)
				topBar.deactivate();		
			scrollPanel.disable();
			optionNotifications.deactivate();
			chatTitle.deactivate();
			editTitleButton.deactivate();
			option1.deactivate();
			chatAvatar.deactivate();
			leaveChatButton.deactivate();
			changeBitmap.deactivate();
			secondUserButton.deactivate();
			addUsersButton.deactivate();
			addBotButton.deactivate();
			allusersButton.deactivate();
			firstUserButton.deactivate();
			UsersManager.S_ONLINE_CHANGED.remove(onUserOnlineStatusChanged);
			
			editTitleButton.deactivate();
			acceptTitleButton.deactivate();
		}
	}
}