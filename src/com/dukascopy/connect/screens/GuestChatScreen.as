package com.dukascopy.connect.screens {

	import com.adobe.utils.StringUtil;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.GiftData;
	import com.dukascopy.connect.data.HitZoneData;
	import com.dukascopy.connect.data.ListRenderInfo;
	import com.dukascopy.connect.data.LocalAvatars;
	import com.dukascopy.connect.data.LocalSoundFileData;
	import com.dukascopy.connect.data.MediaFileData;
	import com.dukascopy.connect.data.SoundStatusData;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.customActions.DownloadFileAction;
	import com.dukascopy.connect.data.screenAction.customActions.RemoveImageAction;
	import com.dukascopy.connect.data.screenAction.customActions.chatMessageAction.CopyMessageAction;
	import com.dukascopy.connect.data.screenAction.customActions.chatMessageAction.EditMessageAction;
	import com.dukascopy.connect.data.screenAction.customActions.chatMessageAction.EnlargeMessageAction;
	import com.dukascopy.connect.data.screenAction.customActions.chatMessageAction.ForwardMessageAction;
	import com.dukascopy.connect.data.screenAction.customActions.chatMessageAction.MinimizeMessageAction;
	import com.dukascopy.connect.data.screenAction.customActions.chatMessageAction.RemoveMessageAction;
	import com.dukascopy.connect.data.screenAction.customActions.chatMessageAction.ResendMessageAction;
	import com.dukascopy.connect.data.screenAction.customActions.chatMessageAction.SendGiftMessageAction;
	import com.dukascopy.connect.gui.button.ChatNewMessagesButton;
	import com.dukascopy.connect.gui.chat.ConnectionIndicator;
	import com.dukascopy.connect.gui.chat.UploadFilePanel;
	import com.dukascopy.connect.gui.chatInput.ChatInputAndroid;
	import com.dukascopy.connect.gui.chatInput.ChatInputIOS;
	import com.dukascopy.connect.gui.chatInput.IChatInput;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.imagesUploaderStatus.ImagesUploaderStatus;
	import com.dukascopy.connect.gui.lightbox.LightBox;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.List;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.gui.list.renderers.ListChatItem;
	import com.dukascopy.connect.gui.list.renderers.ListLink;
	import com.dukascopy.connect.gui.preloader.Preloader;
	import com.dukascopy.connect.gui.puzzle.Puzzle;
	import com.dukascopy.connect.gui.topBar.TopBarGuestChat;
	import com.dukascopy.connect.gui.userWriting.UserWriting;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.base.ScreenManager;
	import com.dukascopy.connect.screens.context.ContextMenuScreen;
	import com.dukascopy.connect.screens.dialogs.ScreenLinksDialog;
	import com.dukascopy.connect.screens.serviceScreen.Overlay;
	import com.dukascopy.connect.sys.DocumentUploader;
	import com.dukascopy.connect.sys.Gifts;
	import com.dukascopy.connect.sys.GlobalDate;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.chatManager.ForwardingManager;
	import com.dukascopy.connect.sys.connectionManager.NetworkManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.errors.ErrorLocalizer;
	import com.dukascopy.connect.sys.imageManager.FileUploader;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.imageManager.ImageUploader;
	import com.dukascopy.connect.sys.nativeExtensionController.NativeExtensionController;
	import com.dukascopy.connect.sys.payments.InvoiceManager;
	import com.dukascopy.connect.sys.photoGaleryManager.PhotoGaleryManager;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.questionsManager.QuestionsManager;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.sound.PlaySoundTicket;
	import com.dukascopy.connect.sys.sound.SoundController;
	import com.dukascopy.connect.sys.store.Store;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.sys.video.VideoUploader;
	import com.dukascopy.connect.sys.videoStreaming.VideoStreaming;
	import com.dukascopy.connect.sys.ws.WS;
	import com.dukascopy.connect.sys.ws.WSClient;
	import com.dukascopy.connect.type.ActionType;
	import com.dukascopy.connect.type.ChatInitType;
	import com.dukascopy.connect.type.ChatItemContextMenuItemType;
	import com.dukascopy.connect.type.ChatMessageType;
	import com.dukascopy.connect.type.ChatRoomType;
	import com.dukascopy.connect.type.ErrorCode;
	import com.dukascopy.connect.type.GiftType;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.type.ImageContextMenuType;
	import com.dukascopy.connect.vo.ChatMessageVO;
	import com.dukascopy.connect.vo.ChatSystemMsgVO;
	import com.dukascopy.connect.vo.ChatVO;
	import com.dukascopy.connect.vo.chat.VoiceMessageVO;
	import com.dukascopy.connect.vo.screen.ChatScreenData;
	import com.dukascopy.connect.vo.users.UserVO;
	import com.dukascopy.connect.vo.users.adds.ChatUserVO;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import com.greensock.easing.Quint;
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.AudioPlaybackMode;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	/**
	 * @author Igor Bloom
	 */
	
	public class GuestChatScreen extends BaseScreen {
		
		protected var chatTop:TopBarGuestChat;
		private var noConnectionIndicator:ConnectionIndicator;
		protected var list:List;
		protected var chatInput:IChatInput;
		private var preloader:Preloader;
		private var iuBox:Sprite;
		
		private var imagesUploaders/*ImagesUploaderStatus*/:Array;
		private var userWritings:UserWriting;
		
		private var _messagesLoaded:Boolean = false;
		private var editingMsgID:int = -1;
		private var needToOpenChat:Boolean = false;
		
		// Colors for text and backgrounds is inside ChatBackgroundCollections
		private var DEFAULT_BACKGROUND_COLOR:uint = Style.color(Style.CHAT_BACKGROUND);
		private var DEFAULT_OVER_BACKGROUND_COLOR:uint = 0xffffff;
		private var textOverBackgroundColor:uint = 0xffffff;
		
		private var disposing:Boolean = false;
		
		private var bottomY:int; // Y до которого доходит чат
		private var lastMessagesHash:String;
		private var historyLoadingState:Boolean;
		private var historyLoadingScroller:Preloader;
		private var loadHistoryOnMouseUp:Boolean;
		private var currentType:String;
		
		private var savedText:String;
		private var bottomInputClip:Sprite;
		private var messageAdded:Boolean = false;
		private var scrollBottomButton:ChatNewMessagesButton;
		private var uploadFilePanel:UploadFilePanel;
		private var unreadedMessages:int = 0;
		private var lastReadedIndex:Number;
		private var chatready:Boolean;
		private var nameEntered:Boolean;
		private var emailEntered:Boolean;
		private var userEmail:String;
		private var userName:String;
		private var systemMessageShown:Boolean;
		private var needEnterName:Boolean;
		private var introMessageSent:Boolean;
		protected var backColorClip:Sprite;
		
		public static const MAX_MESSAGE_LENGHT:int = 2000;
		
		public function GuestChatScreen() { }
		
		
		override protected function createView():void {
			super.createView();
			
			backColorClip = new Sprite();
			view.addChild(backColorClip);
			
			list = new List("Chat");
			list.setAdditionalBottomHeight(Config.FINGER_SIZE * .5);
			list.setMask(true);
			list.setOverlayReaction(false);
			_view.addChild(list.view);
			chatTop = new TopBarGuestChat();
			chatTop.setChatScreen(this);
			_view.addChild(chatTop.view);
			
			bottomInputClip = new Sprite();
			
			chatInput = (Config.PLATFORM_APPLE) ? new ChatInputIOS(Lang.typeMessage) : new ChatInputAndroid();
			if (chatInput && chatInput.getView())
				_view.addChild(chatInput.getView());
			
			iuBox = new Sprite();
			_view.addChild(iuBox);
			
			createButtomButton();
		}
		
		private function createButtomButton():void 
		{
			scrollBottomButton = new ChatNewMessagesButton();
			scrollBottomButton.tapCallback = scrollToBottom;
			view.addChild(scrollBottomButton);
			scrollBottomButton.remove();
		}
		
		private function scrollToBottom():void 
		{
			if (list != null)
			{
				list.scrollBottom(true);
				clearUnreaded();
			}
		}
		
		/**
		 * @param	data - Object with initialized params (for exaple - list of searched conversations or etc..)
		 */
		override public function initScreen(data:Object = null):void {
			echo("ChatScreen", "initScreen", "");
			super.initScreen(data);
			_params.title = Lang.textChats;
			
			ChatManager.S_CHAT_OPENED.add(onChatOpened);
			ChatManager.S_USER_WRITING.add(onUserWriting);
			UserWriting.S_USER_WRITING_DISPOSED.add(onUWDisposed);
			ChatManager.S_CHAT_STAT_CHANGED.add(onChatUpdated);
			ChatManager.S_MESSAGES.add(onMessagesLoaded);
			ChatManager.S_HISTORICAL_MESSAGES.add(onHistoricalMessagesLoaded);
			ChatManager.S_MESSAGE.add(onNewMessage);
			ChatManager.S_MESSAGE_UPDATED.add(onMessageUpdated);
			ChatManager.S_MESSAGES_LOADING_FROM_PHP.add(sMessagesStartLoadFromPHP);
			ChatManager.S_REMOTE_MESSAGES_STOP_LOADING.add(onRemoteMessagesStopLoading);
			ChatManager.S_ERROR_CANT_OPEN_CHAT.add(onChatError);
			ChatManager.S_EDIT_MESSAGE.add(editMessage);
			GlobalDate.S_NEW_DATE.add(refreshList);
			LightBox.S_LIGHTBOX_OPENED.add(onLightboxOpen);
			LightBox.S_LIGHTBOX_CLOSED.add(onLightboxClose);
			Puzzle.S_PUZZLE_OPENED.add(onLightboxOpen);
			Puzzle.S_PUZZLE_CLOSED.add(onLightboxClose);
			ImageUploader.S_FILE_UPLOAD_STATUS.add(onFileUploadedStatus);
			VideoUploader.S_FILE_UPLOAD_STATUS.add(onFileUploadedStatus);
			PhotoGaleryManager.S_GALLERY_IMAGE_LOADED.add(onImageUploadReady);
			PhotoGaleryManager.S_GALLERY_MEDIA_LOADED.add(onMediaUploadReady);
			
			ChatManager.S_LOAD_START.add(showPreloader);
			ChatManager.S_LOAD_STOP.add(hidePreloader);
			
			NetworkManager.S_CONNECTION_CHANGED.add(onNetworkChanged);
			
			updateChatBackground();
			
			needToOpenChat = true;
			
			chatTop.setWidthAndHeight(_width, Config.FINGER_SIZE * .85 + Config.APPLE_TOP_OFFSET);
			
			uploadFilePanel = new UploadFilePanel(view, 0, chatTop.view.y + chatTop.height, _width);
			
			list.view.y = chatTop.view.y + chatTop.height;
			
			if (Config.PLATFORM_APPLE) {
				ChatInputIOS.S_INPUT_POSITION.add(onInputPositionChange);
				if (chatInput) {
					var num:Number = Config.DOUBLE_MARGIN + chatTop.height + Config.MARGIN + ((noConnectionIndicator == null || noConnectionIndicator.parent == null) ? 0 : noConnectionIndicator.height) + Config.FINGER_SIZE;
					if (!isNaN(num) && num > 0  && num < 3000) {
						chatInput.setMaxTopY(num);
					}
				}
			} else {
				ChatInputAndroid.S_INPUT_HEIGHT_CHANGED.add(onInputPositionChange);
				chatInput.setWidth(_width);
			}
			
			backColorClip.graphics.beginFill(DEFAULT_BACKGROUND_COLOR);
			backColorClip.graphics.drawRect(0, 0, _width, _height);
			backColorClip.graphics.endFill();
			
			if (VideoStreaming.isOnAir() && VideoStreaming.currentChat != null && ChatManager.getCurrentChat() != null && ChatManager.getCurrentChat().uid == VideoStreaming.currentChat)
			{
				backColorClip.alpha = 0;
				chatTop.hide(0);
			}
			
			onCloseChatKeyboard();
			
			if (chatTop != null){
				chatTop.redrawTitle();
			}
			
			updateChatInput();
		}
		
		private function hidePreloader():void 
		{
			if (preloader != null)
			{
				preloader.hide();
			}
		}
		
		private function showPreloader():void 
		{
			preloader ||= new Preloader();
			preloader.x = _width * .5;
			preloader.y = _height * .5;
			view.addChild(preloader);
			preloader.show();
		}
		
		private function editMessage(messageVO:ChatMessageVO):void {
			if (messageVO != null && ChatManager.getCurrentChat() != null && messageVO.chatUID == ChatManager.getCurrentChat().uid && chatInput != null) {
				chatInput.setValue(messageVO.text);
				editingMsgID = messageVO.id;
			}
		}
		
		private function dellayedActivate():void {
			if (_isDisposed)
				return;
			
			activateScreen();
			updateChatInput();
		}
		
		private function hideInput(showFakeInput:Boolean = false):void {
			if (chatInput != null)
				chatInput.hide();
			if (!showFakeInput) {
				list.setWidthAndHeight(MobileGui.stage.stageWidth, MobileGui.stage.stageHeight - list.view.y);
				chatInput.hideBackground();
			}
		}
		
		static private function onImageUploadReady(success:Boolean, ibd:ImageBitmapData, title:String):void {
			echo("ChatScreen", "onImageUploadReady", "start");
			if (success && ibd != null && ChatManager.getCurrentChat() != null) {
				if (ibd.width >  Config.MAX_UPLOAD_IMAGE_SIZE || ibd.height > Config.MAX_UPLOAD_IMAGE_SIZE)
				ibd = ImageManager.resize(ibd, Config.MAX_UPLOAD_IMAGE_SIZE, Config.MAX_UPLOAD_IMAGE_SIZE, ImageManager.SCALE_INNER_PROP);
				ImageUploader.uploadChatImage(ibd, ChatManager.getCurrentChat().uid, title, ChatManager.getCurrentChat().getImageString());
				//CachedImagesUploader.addImageToUpoloadingStack(ChatManager.getCurrentChat().uid,ibd)
			}
			echo("ChatScreen", "onImageUploadReady", "end");
		}
		
		private function updateChatBackground():void {
			if (_isDisposed == true)
				return;
			
			textOverBackgroundColor = DEFAULT_OVER_BACKGROUND_COLOR;
		}
		
		public function getTitleValue():String {
			return Lang.suportChat;
		}
		
		override public function startRenderingBitmap():void {
			if (chatInput != null)
			{
				chatInput.showBG();
			}
		}
		
		// TODO - show alert
		private function onChatError(message:String = null):void {
			echo("ChatScreen", "onChatError", "");
			if (message == ActionType.CHAT_CLOSE_ON_ERROR)
				onBack();
			else if (message != null && message.indexOf("io") == 0) {
				ToastMessage.display(Lang.textConnectionError);
				onBack();
			}
			else if (message != null && message.indexOf("chat.22") == 0) {
				ToastMessage.display(Lang.accessDenied);
				onBack();
			}
			else if (message == "") {
				ToastMessage.display(Lang.somethingWentWrong);
				onBack();
			}
			else if (message == null) {
				onBack();
			} else {
				ToastMessage.display(message);
				onBack();
			}
			_messagesLoaded = true;
			// REMOVE SPINNER
			TweenMax.killDelayedCallsTo(addPreloader);
			if (preloader != null)
				preloader.hide();
		}
		
		/**
		 * Вызываем из ChatTop!!
		 */
		override public function onBack(e:Event = null):void {
			echo("ChatScreen", "closeChat", "");
			
			if (Config.PLATFORM_APPLE && chatInput != null) {
				(chatInput as ChatInputIOS).redrawScreenshot();
				(chatInput as ChatInputIOS).y = (MobileGui.stage.stageHeight - (chatInput as ChatInputIOS).height);
			} else if (Config.PLATFORM_ANDROID && chatInput != null) {
				if (chatInput != null) {
					(chatInput as ChatInputAndroid).setY(MobileGui.stage.stageHeight - (chatInput as ChatInputAndroid).height);
				}
			}

			WS.disableGuestConnection();
			Auth.clearAuthorization("", true);

			MobileGui.changeMainScreen(LoginScreen, {state:LoginScreen.STATE_CODE, phone:data.phone, currentPhone:data.currentPhone, country:data.country}, ScreenManager.DIRECTION_LEFT_RIGHT, 0);
		}
		
		private function onUWDisposed(uw:UserWriting):void {
			echo("ChatScreen", "onUWDisposed", "");
			userWritings = null;
			if (!Config.PLATFORM_APPLE)
				iuBox.y = chatInput.getView().y - iuBox.height;
		}
		
		private function onUserWriting(obj:Object):void {
			echo("ChatScreen", "onUserWriting", "");
			if (InvoiceManager.isProcessingInvoice) return; 
			userWritings ||= new UserWriting(ChatManager.getCurrentChat().uid);
			userWritings.textColor = textOverBackgroundColor;
			userWritings.addUser(obj.userUID, obj.userName);
			userWritings.getView().mouseEnabled = userWritings.getView().mouseChildren = false;
			if (userWritings.view.parent == null) {
				if (Config.PLATFORM_APPLE) {
					if (chatInput)
						userWritings.view.y = bottomY - userWritings.getHeight() - Config.MARGIN;
				} else
					userWritings.view.y = bottomY - userWritings.getHeight() - Config.MARGIN;
				userWritings.setWidth(_width);
				view.addChild(userWritings.view);
			}
			iuBox.y = userWritings.view.y - iuBox.height - Config.MARGIN;
		}
		
		private function onMediaUploadReady(mediaData:MediaFileData):void {
			if (mediaData.type == MediaFileData.MEDIA_TYPE_VIDEO) {
				VideoUploader.uploadVideo(mediaData, ChatManager.getCurrentChat().uid, "", ChatManager.getCurrentChat().getImageString(), "123");
			}
			else if (mediaData.type == MediaFileData.MEDIA_TYPE_FILE) {
				DocumentUploader.upload(mediaData, ChatManager.getCurrentChat().uid);
			}
		}
		
		private function onChatUpdated(chatVO:ChatVO):void {
			echo("ChatScreen", "onChatUpdated", "");
			if (chatVO != ChatManager.getCurrentChat())
				return;
			if (list == null)
				return;
			if (_isDisposed)
				return;
			list.refresh();
		}
		
		private function onMessageUpdated(msgVO:ChatMessageVO):void {
			echo("ChatScreen", "onMessageUpdated", "");
			if (list != null)
				list.updateItem(msgVO);
		}
		
		private function refreshList(date:int):void {
			echo("ChatScreen", "refreshList", "");
			if (list != null)
				list.refresh();
		}
		
		override protected function drawView():void {
			echo("ChatScreen", "drawView", "");
			if (disposing || _isDisposed)
				return;
			if (Config.PLATFORM_ANDROID)
				chatInput.setY(MobileGui.stage.stageHeight - (chatInput as ChatInputAndroid).getHeight());
			setChatListSize();
			updateChatInput();
			if (preloader != null) {
				preloader.x = _width * .5;
				preloader.y = _height * .5;
			}
			
			bottomInputClip.width = _width;
			bottomInputClip.height = Config.APPLE_BOTTOM_OFFSET;
			bottomInputClip.y = _height - Config.APPLE_BOTTOM_OFFSET;
			
			updateChatBackground();
		}
		
		override public function activateScreen():void {
			echo("ChatScreen", "activateScreen", "");
			if (isDisposed)
				return;
			if (_isActivated)
				return;
			
			if (uploadFilePanel != null)
			{
				uploadFilePanel.activate();
			}
			
			super.activateScreen();
			if (noConnectionIndicator != null && noConnectionIndicator.visible == true && noConnectionIndicator.parent != null)
			{
				PointerManager.addTap(noConnectionIndicator, tryReconnect);
			}
			if (scrollBottomButton != null && scrollBottomButton.isVisible())
			{
				scrollBottomButton.activate();
			}
			if (needToOpenChat == true) {
				needToOpenChat = false;
				
				openChat();
				
			}
			
			// Если вопрос был закрыт, во время нахождения на скрине с которого вызван back
			if (_isDisposed == true)
				return;
			
			SoundController.S_SOUND_PLAY_START.add(onSoundPlayStart);
			SoundController.S_SOUND_PLAY_STOP.add(onSoundPlayStop);
			SoundController.S_SOUND_PLAY_LOADING.add(onSoundLoading);
			SoundController.S_SOUND_PLAY_PROGRESS.add(onSoundPlayProgress);
			
			TweenMax.delayedCall(1.5, addPreloader);
			
			if (list != null) {
				list.activate();
			} else {
				return;
			}
			
			chatTop.activate()
			
			list.S_ITEM_TAP.add(onItemTap);
			list.S_ITEM_HOLD.add(onItemHold);
			list.S_ITEM_DOUBLE_CLICK.add(onItemDoubleClick);
			list.S_MOVING.add(onListMove);
			list.S_UP.add(onListTouchUp);
			
			if (chatInput)
				chatInput.setCallBack(onChatSend);
			
			setChatListSize();
			
			WSClient.S_MSG_ADD_ERROR.add(onErrorSendMessage);
			onNetworkChanged();
			updateChatInput();
		}
		
		private function openChat():void 
		{
			loadCurrentUID();
		}
		
		private function loadCurrentUID():void 
		{
			Store.load(Store.GUEST_UID, onGuestUidLoaded);
		}
		
		private function onGuestUidLoaded(data:String, error:Boolean):void 
		{
			if (_isDisposed == true)
			{
				return;
			}
			if (error == true || data == null || data == "")
			{
				requestGuestUid();
			}
			else
			{
				Auth.setGuestUID(data);
				
				Store.load(Store.GUEST_NAME, onGuestNameLoaded);
			}
		}
		
		private function onGuestNameLoaded(data:String, error:Boolean):void 
		{
			if (_isDisposed == true)
			{
				return;
			}
			if (error == true || data == null || data == "")
			{
				needEnterName = true;
				startGuestChat(Auth.uid);
			}
			else
			{
				userName = data;
				Store.load(Store.GUEST_MAIL, onGuestMailLoaded);
			}
		}
		
		private function onGuestMailLoaded(data:String, error:Boolean):void 
		{
			if (_isDisposed == true)
			{
				return;
			}
			if (error == true || data == null || data == "")
			{
				needEnterName = true;
				startGuestChat(Auth.uid);
			}
			else
			{
				userEmail = data;
				startGuestChat(Auth.uid);
			}
		}
		
		private function startGuestChat(guestUID:String):void 
		{
			startSocketConnection();
		}
		
		private function startSocketConnection():void 
		{
			WS.S_CONNECTED.add(onSocketReady);
			WS.connectAsGuest();
		}
		
		private function onSocketReady():void 
		{
			if (_isDisposed == true)
			{
				return;
			}
			WS.S_CONNECTED.remove(onSocketReady);
			ChatManager.openGuestSupportChat(Auth.uid, Config.EP_CONNECT);
		}
		
		private function requestGuestUid():void 
		{
			PHP.requestGuestAuth(onGuestAuthRespond);
		}
		
		private function onGuestAuthRespond(respond:PHPRespond):void 
		{
			if (_isDisposed == true)
			{
				respond.dispose();
				return;
			}
			
			if (respond.error == true)
			{
				ToastMessage.display(ErrorLocalizer.getText(respond.errorMsg));
				respond.dispose();
				onBack();
			}
			else
			{
				Auth.setGuestAuthData(respond.data);
			//	Auth.uid = respond.data;
				saveGuestUID(Auth.uid);
				startGuestChat(Auth.uid);
				respond.dispose();
			}
		}
		
		private function saveGuestUID(uid:String):void 
		{
			Store.save(Store.GUEST_UID, uid);
		}
		
		private function addPreloader():void {
			if (_messagesLoaded == false) {
				preloader ||= new Preloader();
				preloader.x = _width * .5;
				preloader.y = _height * .5;
				view.addChild(preloader);
				preloader.show();
			}
		}
		
		private function onListTouchUp():void {
			if (loadHistoryOnMouseUp) {
				loadHistoryOnMouseUp = false;
				
				if (ChatManager.getCurrentChat().messages.length > 0 && ChatManager.getCurrentChat().messages[0].num == 1) {
					historyLoadingState = false;
					if (historyLoadingScroller != null)
						historyLoadingScroller.hide();
				} else {
					historyLoadingState = true;
					if (historyLoadingScroller != null)
						historyLoadingScroller.startAnimation();
					ChatManager.loadChatHistorycalMessages();
				}
			}
			else
			{
				if (historyLoadingScroller != null)
					historyLoadingScroller.hide();
			}
		}
		
		private function showChatInput():void
		{
			var showPayButtons:Boolean = true;
			if (ChatManager.getCurrentChat()) {
				if (ChatManager.getCurrentChat().type == ChatRoomType.GROUP || 
					ChatManager.getCurrentChat().type == ChatRoomType.COMPANY || 
					ChatManager.getCurrentChat().type == ChatRoomType.CHANNEL) 
					showPayButtons = false;
				
				if (ChatManager.getCurrentChat().type == ChatRoomType.PRIVATE &&
					ChatManager.getCurrentChat().users != null &&
					ChatManager.getCurrentChat().users.length > 0 &&
					ChatManager.getCurrentChat().users[0] != null &&
					ChatManager.getCurrentChat().users[0].uid == Config.NOTEBOOK_USER_UID)
					showPayButtons = false;
					
			} else {
				if (chatData && chatData.type == ChatInitType.SUPPORT)
					showPayButtons = false;
				if (chatData && chatData.type == ChatInitType.USERS_IDS && 
					chatData.usersUIDs != null && 
					chatData.usersUIDs.length > 0 && 
					chatData.usersUIDs[0] == Config.NOTEBOOK_USER_UID)
					showPayButtons = false;
			}
			if (chatInput && !chatInput.isShown()) {
				chatInput.initButtons(showPayButtons);
				chatInput.show(Lang.typeMessage);
			}
			chatInput.activate();
		}
		
		private function onErrorSendMessage(errorCode:String):void {
			if (errorCode == ErrorCode.YOU_BLOCKED_IN_CHAT)
				ToastMessage.display(Lang.youBeenBlocked);
			else if (errorCode == ErrorCode.YOU_BANNED)
				ToastMessage.display(Lang.youWereBanned);
		}
		
		private function onItemHold(data:Object, n:int):void {
			echo("ChatScreen", "onItemHold", "");
			return;

			if (!Config.PLATFORM_APPLE && (chatInput as ChatInputAndroid).softKeyboardActivated)
				return;
			if (!(data is ChatMessageVO))
				return;
			var msgVO:ChatMessageVO = data as ChatMessageVO;
			if (msgVO.id == 0)
				return;
			if (msgVO.typeEnum == ChatMessageType.SYSTEM || msgVO.typeEnum == ChatMessageType.MESSAGE_911 || msgVO.typeEnum == ChatMessageType.COMPLAIN)
				return;
			
			var selectedItem:ListItem;
			
			if (msgVO.typeEnum == ChatMessageType.TEXT && msgVO.text == "")
				return;
			var isMine:Boolean = (msgVO.userUID == Auth.uid);
			var editable:Boolean = (msgVO.created * 1000 > new Date().getTime() - 1800000);
			var menuItems:Array = new Array();
			
			//pending massages
			if (msgVO.id < 0) {
				if (msgVO.typeEnum == ChatMessageType.TEXT && isMine) {
					menuItems.push( { fullLink:Lang.textCopy, id:ChatItemContextMenuItemType.COPY } );
					menuItems.push( { fullLink:Lang.resendMessage, id:ChatItemContextMenuItemType.RESEND } );
				}
				else if (msgVO.typeEnum == ChatMessageType.FILE && isMine) {
					if (msgVO.systemMessageVO != null && msgVO.systemMessageVO.fileType == ChatSystemMsgVO.FILETYPE_VIDEO) {
						menuItems.push( { fullLink:Lang.textRemove, id:ChatItemContextMenuItemType.REMOVE } );
					}
				}
			} else {
				if (msgVO.typeEnum == ChatMessageType.TEXT) {
					
					if (msgVO.linksArray == null || (msgVO.linksArray.length > 0 && canOpenLink(msgVO)))
					{
						menuItems.push( { fullLink:Lang.textCopy, id:ChatItemContextMenuItemType.COPY } );
					}
					
					if (isMine && editable)
						menuItems.push( { fullLink:Lang.textEdit, id:ChatItemContextMenuItemType.EDIT } );
				}
				
				var removeExist:Boolean = false;
				
				if (isMine) {
					if (Config.ADMIN_UIDS.indexOf(Auth.uid) != -1)
					{
						removeExist = true;
						menuItems.push( { fullLink:Lang.textRemove, id:ChatItemContextMenuItemType.REMOVE } );
					}
					else if (editable && msgVO.typeEnum != ChatSystemMsgVO.TYPE_CHAT_SYSTEM) {
						removeExist = true;
						menuItems.push( { fullLink:Lang.textRemove, id:ChatItemContextMenuItemType.REMOVE } );
					}
					if (msgVO.id < 0)
						menuItems.push( { fullLink:Lang.resendMessage, id:ChatItemContextMenuItemType.RESEND } );
				} else if (Config.ADMIN_UIDS.indexOf(Auth.uid) != -1) {
					removeExist = true;
					menuItems.push( { fullLink:Lang.textRemove, id:ChatItemContextMenuItemType.REMOVE } );
				}
				
					//public
				if (removeExist == false && ChatManager.getCurrentChat() != null && ChatManager.getCurrentChat().type == ChatRoomType.CHANNEL && 
					(ChatManager.getCurrentChat().isOwner(Auth.uid) || ChatManager.getCurrentChat().isModerator(Auth.uid)))
				{
					removeExist = true;
					menuItems.push( { fullLink:Lang.textRemove, id:ChatItemContextMenuItemType.REMOVE } );
				}
				
				//GIFT
				if (ChatManager.getCurrentChat() != null && ChatManager.getCurrentChat().type == ChatRoomType.CHANNEL &&
					ChatManager.getCurrentChat().questionID != null && ChatManager.getCurrentChat().questionID != "" &&
					ChatManager.getCurrentChat().getQuestion() != null && ChatManager.getCurrentChat().getQuestion().isPaid == false &&
					isMine == false && ChatManager.getCurrentChat().getQuestion().userUID == Auth.uid &&
					msgVO.userVO != null)
				{
					menuItems.push( { fullLink:Lang.sendGift, id:ChatItemContextMenuItemType.SEND_GIFT } );
				}
				
				if (msgVO.typeEnum == ChatMessageType.INVOICE || 
					msgVO.typeEnum == ChatMessageType.TEXT || 
					msgVO.typeEnum == ChatMessageType.STICKER || 
					
					(msgVO.typeEnum == ChatSystemMsgVO.TYPE_FILE && 
					msgVO.systemMessageVO != null && 
					(msgVO.systemMessageVO.fileType == ChatSystemMsgVO.FILETYPE_IMG || msgVO.systemMessageVO.fileType == ChatSystemMsgVO.FILETYPE_IMG_CRYPTED)))
				{
					menuItems.push({fullLink:Lang.forwardMessage, id:ChatItemContextMenuItemType.FORWARD});
				}
			}
			if (msgVO.renderInfo == null || msgVO.renderInfo.renderInforenderBigFont == false)
			{
				menuItems.push({fullLink:Lang.enlargeText, id:ChatItemContextMenuItemType.ENLARGE});
			}
			else
			{
				menuItems.push({fullLink:Lang.reduceText, id:ChatItemContextMenuItemType.MINIMIZE});
			}
			
			if (menuItems.length == 0)
				return;
			
			TweenMax.delayedCall(0.3, NativeExtensionController.vibrate);
			
			var actionsTap:Vector.<IScreenAction> = convertMessageMenuToActions(msgVO, menuItems);
			
			selectedItem = list.getItemByNum(n);
			var messageContentHitzone:HitZoneData = (selectedItem.renderer as ListChatItem).getMessageHitzone(selectedItem);
			if (messageContentHitzone != null) {
				var screenDataContext:Object = new Object();
				var globalPointTap:Point = selectedItem.liView.parent.localToGlobal(new Point(selectedItem.liView.x, selectedItem.liView.y));
				messageContentHitzone.x = globalPointTap.x + messageContentHitzone.x;
				messageContentHitzone.y = globalPointTap.y + messageContentHitzone.y;
				messageContentHitzone.visibilityRect = new Rectangle(0, list.view.y, _width, list.view.height);
				
				if (messageContentHitzone.y < list.view.y) {
					messageContentHitzone.height -= list.view.y - messageContentHitzone.y;
					messageContentHitzone.y = list.view.y;
				}
				if (messageContentHitzone.y + messageContentHitzone.height > list.view.y + list.height) {
					messageContentHitzone.height -= messageContentHitzone.y + messageContentHitzone.height - (list.view.y + list.height);
				}
				
				screenDataContext.hitzone = messageContentHitzone;
				
				screenDataContext.actions = actionsTap;
				ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, ContextMenuScreen, {
																										backScreen:MobileGui.centerScreen.currentScreen, 
																										backScreenData:MobileGui.centerScreen.currentScreen.data, 
																										data:screenDataContext}, 0, 0);
				return;
			}
			
			DialogManager.showDialog(ScreenLinksDialog, { callback:function(data:Object):void {
				switch(data.id) {
					case ChatItemContextMenuItemType.COPY: {
						if (msgVO.text != null)
						{
							Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, msgVO.text);
						}
						
						break;
					}
					case ChatItemContextMenuItemType.EDIT:{
						chatInput.setValue(msgVO.text);
						editingMsgID = msgVO.id;
						break;
					}
					case ChatItemContextMenuItemType.REMOVE:{
						DialogManager.alert(Lang.textConfirm, Lang.alertConformDeleteMessage, function(val:int):void {
							if (val != 1)
								return;
							ChatManager.removeMessage(msgVO);
						}, Lang.textDelete.toUpperCase(), Lang.textCancel);
						break;
					}
					case ChatItemContextMenuItemType.FORWARD:{
						ForwardingManager.openSelectAdresseeScreenForForwardingMessage(msgVO,data);
						break;
					}
					case ChatItemContextMenuItemType.RESEND: {
						ChatManager.resendMessage(msgVO);
						break;
					}
					case ChatItemContextMenuItemType.ENLARGE: {
						
						if (msgVO != null)
						{
							if (msgVO.renderInfo == null)
							{
								msgVO.renderInfo = new ListRenderInfo();
								
							}
							msgVO.renderInfo.renderInforenderBigFont = !msgVO.renderInfo.renderInforenderBigFont;
						}
						list.updateItemByIndex(n);
						
						break;
					}
					case ChatItemContextMenuItemType.MINIMIZE: {
						
						if (msgVO != null)
						{
							if (msgVO.renderInfo == null)
							{
								msgVO.renderInfo = new ListRenderInfo();
								
							}
							msgVO.renderInfo.renderInforenderBigFont = !msgVO.renderInfo.renderInforenderBigFont;
						}
						list.updateItemByIndex(n);
						
						break;
					}
					case ChatItemContextMenuItemType.SEND_GIFT: {
						var gift:GiftData = new GiftData();
						gift.chatUID = ChatManager.getCurrentChat().uid;
						gift.type = GiftType.GIFT_X;
						gift.user = msgVO.userVO;
						Gifts.startGift(-1 ,gift);
						break;
					}
				}
			}, data:menuItems, itemClass:ListLink, title:Lang.textMenu} );
		}
		
		private function convertMessageMenuToActions(msgVO:ChatMessageVO, menuItems:Array):Vector.<IScreenAction> {
			if (menuItems == null) {
				return null;
			}
			
			var actions:Vector.<IScreenAction> = new Vector.<IScreenAction>();
			var l:int = menuItems.length;
			
			var action:IScreenAction;
			for (var i:int = 0; i < l; i++) {
				action = null;
				switch(menuItems[i].id)
				{
					case ChatItemContextMenuItemType.FORWARD:
					{
						action = new ForwardMessageAction(msgVO);
						break;
					}
					case ChatItemContextMenuItemType.COPY:
					{
						action = new CopyMessageAction(msgVO);
						break;
					}
					case ChatItemContextMenuItemType.REMOVE:
					{
						action = new RemoveMessageAction(msgVO);
						break;
					}
					case ChatItemContextMenuItemType.EDIT:
					{
						action = new EditMessageAction(msgVO);
						break;
					}
					case ChatItemContextMenuItemType.RESEND:
					{
						action = new ResendMessageAction(msgVO);
						break;
					}
					case ChatItemContextMenuItemType.SEND_GIFT:
					{
						action = new SendGiftMessageAction(msgVO);
						break;
					}
					case ChatItemContextMenuItemType.ENLARGE:
					{
						action = new EnlargeMessageAction(msgVO, list);
						break;
					}
					case ChatItemContextMenuItemType.MINIMIZE:
					{
						action = new MinimizeMessageAction(msgVO, list);
						break;
					}
				}
				if (action != null) {
					actions.push(action);
				}
			}
			
			return actions;
		}
		
		override public function deactivateScreen():void {
			echo("ChatScreen", "deactivateScreen", "");
			if (!_isActivated)
				return;
			_isActivated = false;
			
			list.deactivate();
			
			if (uploadFilePanel != null)
			{
				uploadFilePanel.deactivate();
			}
			
			if (Config.PLATFORM_APPLE) {
				chatInput.hide();
			} else {
				if (chatInput != null)
				{
					chatInput.setCallBack(null);
					chatInput.deactivate();
					chatInput.hide();
				}
			}
			if (scrollBottomButton != null)
			{
				scrollBottomButton.deactivate();
			}
			if (noConnectionIndicator != null)
			{
				PointerManager.removeTap(noConnectionIndicator, tryReconnect);
			}
			
			chatTop.deactivate();
			list.S_ITEM_TAP.remove(onItemTap);
			list.S_ITEM_DOUBLE_CLICK.remove(onItemDoubleClick);
			list.S_ITEM_HOLD.remove(onItemHold);
			list.S_MOVING.remove(onListMove);
			list.S_UP.remove(onListTouchUp);
			
			if (ChatManager.getCurrentChat())
				SoundController.stopSoundsByChat(ChatManager.getCurrentChat().uid);
			
			SoundController.S_SOUND_PLAY_START.remove(onSoundPlayStart);
			SoundController.S_SOUND_PLAY_STOP.remove(onSoundPlayStop);
			SoundController.S_SOUND_PLAY_LOADING.remove(onSoundLoading);
			SoundController.S_SOUND_PLAY_PROGRESS.remove(onSoundPlayProgress);
		}
		
		private function onListMove(position:Number):void {
			if (position > 0) {
				if (!historyLoadingState) {
					var positionScroller:int = Config.FINGER_SIZE*.85 + Config.APPLE_TOP_OFFSET + position - Config.FINGER_SIZE;
					
					if (positionScroller > Config.FINGER_SIZE * 2.5) {
						loadHistoryOnMouseUp = true;
						positionScroller = Config.FINGER_SIZE * 2.5;
					} else {
						loadHistoryOnMouseUp = false;
					}
					
					if (ChatManager.getCurrentChat() != null &&
						ChatManager.getCurrentChat().type == ChatRoomType.PRIVATE &&
						ChatManager.getCurrentChat().users != null &&
						ChatManager.getCurrentChat().users.length > 0) {
							var cuVO:ChatUserVO = UsersManager.getInterlocutor(ChatManager.getCurrentChat());
							if (cuVO != null &&
								cuVO.userVO != null &&
								cuVO.userVO.uid != Auth.uid &&
								cuVO.userVO.type.toLowerCase() == "bot")
									return;
					}
					
					if (historyLoadingScroller == null) {
						var loaderSize:int = Config.FINGER_SIZE * 0.6;
						if (loaderSize%2 == 1)
							loaderSize ++;
						
						historyLoadingScroller = new Preloader(loaderSize, ListLoaderShape);
						_view.addChild(historyLoadingScroller);
						if (chatTop != null && chatTop.view != null && _view.contains(chatTop.view))
						{
							_view.setChildIndex(chatTop.view, _view.numChildren - 1);
						}
					}
					
					historyLoadingScroller.y = Config.FINGER_SIZE * .85 + Config.APPLE_TOP_OFFSET - Config.FINGER_SIZE * .5;
					historyLoadingScroller.x = int(_width * .5);
					
					
					historyLoadingScroller.show(true, false);
					
					historyLoadingScroller.rotation = positionScroller * 100 / Config.FINGER_SIZE;
					historyLoadingScroller.y = positionScroller;
				}
			}
			
			if ( -position < list.itemsHeight - list.height - Config.FINGER_SIZE * 2)
			{
				scrollBottomButton.add();
				if (_isActivated)
				{
					scrollBottomButton.activate();
				}
				scrollBottomButton.x = int(_width - scrollBottomButton.width - Config.DIALOG_MARGIN * 0.7);
				if (unreadedMessages > 0)
				{
					if (list != null && list.data != null)
					{
						var firstVisibleIndex:int = list.getFirstVisibleItemIndex();
						if (list.data is Array && (list.data as Array).length > firstVisibleIndex)
						{
							var l:int = (list.data as Array).length;
							var unreadedUpdated:int = 0;
							
							for (var i:int = firstVisibleIndex; i < l; i++) 
							{
								if (list.getItemByNum(i).y > -position + list.height - Config.FINGER_SIZE * .5 && (list.data as Array)[i] is ChatMessageVO && ((list.data as Array)[i] as ChatMessageVO).userUID != Auth.uid)
								{
									unreadedUpdated ++;
								}
							}
							if (unreadedMessages != unreadedUpdated && unreadedUpdated < unreadedMessages)
							{
								unreadedMessages = unreadedUpdated;
								if (scrollBottomButton != null)
								{
									scrollBottomButton.setUnreded(unreadedMessages);
								}
							}
							
						}
					}
				}
			}
			else
			{
				clearUnreaded();
				scrollBottomButton.remove();
				scrollBottomButton.deactivate();
			}
		}
		
		private function sMessagesStartLoadFromPHP():void {
			if (preloader != null)
				preloader.show();
		}
		
		private function onRemoteMessagesStopLoading():void {
			TweenMax.killDelayedCallsTo(addPreloader);
			if (preloader != null)
				preloader.hide();
			
			hideHistoryLoader();
		}
		
		private function onItemDoubleClick(data:Object, n:int):void {
			if (!(data is ChatMessageVO)) {
				return;
			}
			var cmsgVO:ChatMessageVO = data as ChatMessageVO;
			if (cmsgVO != null)
			{
				if (cmsgVO.renderInfo == null)
				{
					cmsgVO.renderInfo = new ListRenderInfo();
					
				}
				cmsgVO.renderInfo.renderInforenderBigFont = !cmsgVO.renderInfo.renderInforenderBigFont;
			}
			list.updateItemByIndex(n);
		}
		
		private function onItemTap(data:Object, n:int):void {
			echo("ChatScreen", "onItemTap", "");
			
			if (!Config.PLATFORM_APPLE) {
				if ((chatInput as ChatInputAndroid).softKeyboardActivated)
					return;
				if ((chatInput as ChatInputAndroid).mediaScreenActivated)
					return;
			}
			if (!(data is ChatMessageVO)) {
				return;
			}
			var cmsgVO:ChatMessageVO = data as ChatMessageVO;
			
			var displayingMessage:ChatMessageVO = cmsgVO;
			if (cmsgVO.typeEnum == ChatMessageType.FORWARDED) {
				displayingMessage = cmsgVO.systemMessageVO.forwardVO;
			}
			
			var selectedItem:ListItem = list.getItemByNum(n);
			
			var lastHitzoneObject:Object =  selectedItem.getLastHitZoneObject();
			var lhz:String = lastHitzoneObject!=null?lastHitzoneObject.type:null;// selectedItem.getLastHitZone();
			
			var overlayTouch:HitZoneData;
			
			if (cmsgVO.systemMessage)
			{
				if (lhz)
				{
					if (lhz.indexOf(HitZoneType.SYSTEM_MESSAGE_INDEX_) != -1)
					{
						if (lhz == HitZoneType.SYSTEM_MESSAGE_INDEX_ + "avatar")
						{
							lhz = HitZoneType.AVATAR;
						}
					}					
				}
			}
			if (lhz == HitZoneType.OPEN_LINK) {
				var urlLink:String = lastHitzoneObject.text;
				if (urlLink != null) {
					navigateToURL(new URLRequest(urlLink));
				}
			}
			if (lhz == HitZoneType.BOT_MENU_IMAGE && cmsgVO!=null && cmsgVO.imageThumbURLWithKey != null) {
				LightBox.disposeVOs();
				LightBox.add(cmsgVO.imageThumbURLWithKey, false, null, null, null, cmsgVO.imageThumbURLWithKey);
				LightBox.show(cmsgVO.imageThumbURLWithKey, getTitleValue(), true);
				deactivateScreen();			
			}
			var updateItemTime:Boolean = true;
			if (lhz == HitZoneType.BALLOON) {
				if (cmsgVO.systemMessageVO != null && cmsgVO.systemMessageVO.fileType == ChatSystemMsgVO.FILETYPE_VIDEO) {
					NativeExtensionController.showVideo(cmsgVO.systemMessageVO.videoVO, getTitleValue());
				} else if (cmsgVO.systemMessageVO != null && cmsgVO.systemMessageVO.fileType == ChatSystemMsgVO.FILETYPE_GENERAL) {
					downloadFile(cmsgVO.systemMessageVO);
				}
				else if (cmsgVO.systemMessageVO != null && cmsgVO.systemMessageVO.imageURL != null) {
					LightBox.disposeVOs();
					
					var actions2:Vector.<IScreenAction> = new Vector.<IScreenAction>();
					
					var isMine2:Boolean = (cmsgVO.userUID == Auth.uid);
					var editable2:Boolean = (cmsgVO.created * 1000 > new Date().getTime() - 1800000);
					if (isMine2 == true && editable2 == true) {
						var removeImageAction2:RemoveImageAction = new RemoveImageAction(cmsgVO);
						removeImageAction2.setData(ImageContextMenuType.REMOVE_MESSAGE)
						actions2.push(removeImageAction2);
					}
					
					LightBox.add(cmsgVO.imageURLWithKey, true, null, null, null, cmsgVO.imageThumbURLWithKey, actions2);
					LightBox.show(cmsgVO.imageURLWithKey, getTitleValue(), true);
					deactivateScreen();
				} else if ((cmsgVO.linksArray != null && cmsgVO.linksArray.length > 0) || (cmsgVO.systemMessageVO != null && cmsgVO.systemMessageVO.forwardVO != null && cmsgVO.systemMessageVO.forwardVO.linksArray != null && cmsgVO.systemMessageVO.forwardVO.linksArray.length > 0)) {
					if ((cmsgVO.linksArray != null && cmsgVO.linksArray.length > 1) || (cmsgVO.systemMessageVO != null && cmsgVO.systemMessageVO.forwardVO != null && cmsgVO.systemMessageVO.forwardVO.linksArray != null && cmsgVO.systemMessageVO.forwardVO.linksArray.length > 1)) {
						
						if (canOpenLink(cmsgVO) == false)
						{
							return;
						}
						
						DialogManager.showDialog(ScreenLinksDialog, { callback:function(data:Object):void {
							if (data.id == -1)
								return;
							
							openLink(data.shortLink);
						}, data:getMessageLinks(cmsgVO), itemClass:ListLink, title:Lang.chooseLinkToOpen } );
					} else {
						var links:Array = getMessageLinks(cmsgVO);
						if(links != null)
						{
							var linkObj:Object = links[0];
							
							if (canOpenLink(cmsgVO) == false)
							{
								return;
							}
							
							if (linkObj != null)
								openLink(linkObj.shortLink);
						}
					}
				}
			}
			else if (lhz == HitZoneType.AVATAR) {
				if (cmsgVO != null && cmsgVO.userVO != null &&  cmsgVO.userVO.type == UserVO.TYPE_BOT){ 
					var botAvatarCommand:String =  "bot:" +  cmsgVO.userVO.getDisplayName().toLowerCase() + " menu";					
					ChatManager.sendBotActionMessage(botAvatarCommand, Lang.botMenuText, null, ChatManager.getCurrentChat().uid, cmsgVO.userUID);
					return;
				}		
				
				if (ChatManager.getCurrentChat().type == ChatRoomType.COMPANY)
					return;
				var userVO:UserVO;
				if (cmsgVO.typeEnum == ChatSystemMsgVO.TYPE_CHAT_SYSTEM && 
					cmsgVO.systemMessageVO != null && 
					cmsgVO.systemMessageVO.method == ChatSystemMsgVO.METHOD_TIPS_PAID) {
						if (cmsgVO.systemMessageVO.giftVO != null && cmsgVO.systemMessageVO.giftVO.user != null) {
							userVO = cmsgVO.systemMessageVO.giftVO.user;
						}
				} else if (cmsgVO.typeEnum == ChatSystemMsgVO.TYPE_CHAT_SYSTEM && 
					cmsgVO.systemMessageVO != null && 
					cmsgVO.systemMessageVO.method == ChatSystemMsgVO.METHOD_CALL)
				{
					userVO = UsersManager.getInterlocutor(ChatManager.getCurrentChat()).userVO;
				} else {
					userVO = cmsgVO.userVO;
					var cuVO:ChatUserVO;
					if (userVO == null && chatData != null && chatData.chatVO != null && chatData.chatVO.users != null && chatData.chatVO.users[0] != null)
					{
						userVO = chatData.chatVO.users[0].userVO;
					}
					cuVO = ChatManager.getCurrentChat().getUser(userVO.uid);
					if (cuVO != null && cuVO.secretMode == true)
						return;
				}
				var profileScreenClass:Class;
				if (userVO.type == UserVO.TYPE_BOT || userVO.uid == Config.SERVICE_INFO_USER_UID || userVO.uid == Auth.uid)
					return;
				profileScreenClass = UserProfileScreen;
				MobileGui.changeMainScreen(profileScreenClass, {
					backScreen: ChatScreen, 
					backScreenData: chatData, 
					data: userVO
				} );
			} else if (lhz == HitZoneType.PLAY_SOUND) {
				updateItemTime = false;
				playSound(cmsgVO);
			} else if (lhz == HitZoneType.SWITCH_SOUND_SPEAKER) {
				updateItemTime = false;
				switchSoundOnCurrentAudio(cmsgVO);
			} else if (lhz == HitZoneType.CHAT_FILE) {
			}  
			else if (lhz == HitZoneType.CANCEL) {
				updateItemTime = false;
				if (cmsgVO.systemMessageVO != null && cmsgVO.systemMessageVO.fileType == ChatSystemMsgVO.FILETYPE_VIDEO) {
					VideoUploader.cancelUploadVideo(cmsgVO.id);
				}
			} else if (lhz == HitZoneType.RESEND) {
				updateItemTime = false;
				if (cmsgVO.systemMessageVO != null && cmsgVO.systemMessageVO.fileType == ChatSystemMsgVO.FILETYPE_VIDEO) {
					VideoUploader.resendVideo(cmsgVO);
				}
			} else if (lhz == HitZoneType.SAVE) {
				updateItemTime = false;
				if (cmsgVO.systemMessageVO != null && cmsgVO.systemMessageVO.fileType == ChatSystemMsgVO.FILETYPE_VIDEO) {
					NativeExtensionController.saveVideo(cmsgVO.systemMessageVO.videoVO);
					list.updateItem(cmsgVO);
				}
			}
			
			// SHOW/HIDE time on item;
			if (updateItemTime == true) {
				if (list != null && selectedItem != null) {
					selectedItem.drawTime = !selectedItem.drawTime;
					list.updateItemByIndex(n);
				}
			}
			
			if (overlayTouch != null)
			{
				Overlay.displayTouch(overlayTouch);
			}
		}
		
		private function getMessageLinks(cmsgVO:ChatMessageVO):Array 
		{
			if (cmsgVO.linksArray != null && cmsgVO.linksArray.length > 0)
			{
				return cmsgVO.linksArray;
			}
			else if (cmsgVO.systemMessageVO != null && cmsgVO.systemMessageVO.forwardVO != null && cmsgVO.systemMessageVO.forwardVO.linksArray != null && cmsgVO.systemMessageVO.forwardVO.linksArray.length > 0)
			{
				return cmsgVO.systemMessageVO.forwardVO.linksArray;
			}
			
			return null;
		}
		
		private function downloadFile(systemMessageVO:ChatSystemMsgVO):void 
		{
			if (systemMessageVO != null && systemMessageVO.fileVO != null)
			{
				var action:DownloadFileAction = new DownloadFileAction(new URLRequest(systemMessageVO.fileVO.getFileUrl()), systemMessageVO.fileVO);
				action.execute();
			}
		}
		
		private function canOpenLink(cmsgVO:ChatMessageVO):Boolean 
		{
			return true;
		}
		
		private function openLink(link:String):void {
			var nativeAppExist:Boolean = false;
			var appLink:String;
			if (link.indexOf("http://www.dukascopy.com/fxcomm/") == 0 ||
				link.indexOf("http://www.dukascopy.com/tradercontest/") == 0 ||
				link.indexOf("http://www.dukascopy.com/strategycontest/") == 0) {
					appLink = link.substr(25);
					if (Config.PLATFORM_ANDROID == true && MobileGui.androidExtension != null)
						nativeAppExist = MobileGui.androidExtension.launchFXComm("url", appLink);
					else if (Config.PLATFORM_APPLE == true && MobileGui.dce != null)
						nativeAppExist = MobileGui.dce.launchFXComm("url", appLink);
			}
			if (link.indexOf("https://www.dukascopy.com/fxcomm/") == 0 ||
				link.indexOf("https://www.dukascopy.com/tradercontest/") == 0 ||
				link.indexOf("https://www.dukascopy.com/strategycontest/") == 0) {
					appLink = link.substr(26);
					if (Config.PLATFORM_ANDROID == true && MobileGui.androidExtension != null)
						nativeAppExist = MobileGui.androidExtension.launchFXComm("url", appLink);
					else if (Config.PLATFORM_APPLE == true && MobileGui.dce != null)
						nativeAppExist = MobileGui.dce.launchFXComm("url", appLink);
			}
			
			if (nativeAppExist == false)
				navigateToURL(new URLRequest(link));
		}
		
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		//  SOUND MESSAGE  ->  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		private function switchSoundOnCurrentAudio(cmsgVO:ChatMessageVO):void {
			if (cmsgVO.systemMessageVO == null)
				return;
			if (cmsgVO.systemMessageVO.voiceVO == null)
				return;
			var vmVO:VoiceMessageVO = cmsgVO.systemMessageVO.voiceVO;
			var ticket:PlaySoundTicket = new PlaySoundTicket();
			ticket.type = PlaySoundTicket.TYPE_REMOTE_UID;
			ticket.soundLink = vmVO.uid;
			
			ticket.action = PlaySoundTicket.ACTION_SWITCH_SPEAKER;
			
			if (vmVO.speakerMode == AudioPlaybackMode.MEDIA) {
				vmVO.speakerMode = AudioPlaybackMode.VOICE;
			} else if (vmVO.speakerMode == AudioPlaybackMode.VOICE) {
				vmVO.speakerMode = AudioPlaybackMode.MEDIA;
			}
			list.updateItem(cmsgVO);
			
			ticket.speakerType = vmVO.speakerMode;
			ticket.caller = PlaySoundTicket.CALLER_CHAT;
			ticket.chatUID = ChatManager.getCurrentChat().uid;
			ticket.messageUID = cmsgVO.id;
			SoundController.playTicket(ticket);
		}
		
		private function playSound(cmsgVO:ChatMessageVO):void {
			if (cmsgVO.systemMessageVO == null)
				return;
			if (cmsgVO.systemMessageVO.voiceVO == null)
				return;
			var vmVO:VoiceMessageVO = cmsgVO.systemMessageVO.voiceVO;
			var ticket:PlaySoundTicket = new PlaySoundTicket();
			ticket.type = PlaySoundTicket.TYPE_REMOTE_UID;
			ticket.duration = vmVO.duration;
			ticket.format = vmVO.codec;
			ticket.soundLink = vmVO.uid;
			if (vmVO.isPlaying) {
				vmVO.isPlaying = false;
				ticket.action = PlaySoundTicket.ACTION_PAUSE;
			}
			else if (vmVO.isLoading) {
				vmVO.currentTime = 0;
				ticket.action = PlaySoundTicket.ACTION_STOP;
			} else {
				ticket.action = PlaySoundTicket.ACTION_PLAY;
			}
			
			list.updateItem(cmsgVO);
			
			ticket.speakerType = vmVO.speakerMode;
			ticket.caller = PlaySoundTicket.CALLER_CHAT;
			ticket.chatUID = ChatManager.getCurrentChat().uid;
			ticket.messageUID = cmsgVO.id;
			SoundController.playTicket(ticket);
		}
		
		private function onSoundLoading(ticket:PlaySoundTicket):void {
			if (ticket.caller == PlaySoundTicket.CALLER_CHAT && ticket.chatUID == ChatManager.getCurrentChat().uid) {
				var msgVO:ChatMessageVO = getMessage(ticket.messageUID);
				if (msgVO == null)
					return;
				if (msgVO.systemMessageVO == null)
					return;
				if (msgVO.systemMessageVO.voiceVO == null)
					return;
				var vmVO:VoiceMessageVO = msgVO.systemMessageVO.voiceVO;
				vmVO.isLoading = true;
			//	vmVO.currentTime = vmVO.duration;
				if (list != null)
					list.updateItem(msgVO);
			}
		}
		
		private function onSoundPlayStop(ticket:PlaySoundTicket):void {
			if (ticket.caller == PlaySoundTicket.CALLER_CHAT && ticket.chatUID == ChatManager.getCurrentChat().uid) {
				var msgVO:ChatMessageVO = getMessage(ticket.messageUID);
				if (msgVO == null)
					return;
				if (msgVO.systemMessageVO == null)
					return;
				if (msgVO.systemMessageVO.voiceVO == null)
					return;
				var vmVO:VoiceMessageVO = msgVO.systemMessageVO.voiceVO;
				vmVO.isLoading = false;
				vmVO.isPlaying = false;
				vmVO.currentTime = 0;
				if (list != null)
					list.updateItem(msgVO);
			}
		}
		
		private function onSoundPlayStart(ticket:PlaySoundTicket):void {
			if (ticket.caller == PlaySoundTicket.CALLER_CHAT && ticket.chatUID == ChatManager.getCurrentChat().uid) {
				var msgVO:ChatMessageVO = getMessage(ticket.messageUID);
				if (msgVO == null)
					return;
				if (msgVO.systemMessageVO == null)
					return;
				if (msgVO.systemMessageVO.voiceVO == null)
					return;
				var vmVO:VoiceMessageVO = msgVO.systemMessageVO.voiceVO;
				vmVO.isLoading = false;
				vmVO.isPlaying = true;
				if (list != null)
					list.updateItem(msgVO);
			}
		}
		
		private function onSoundPlayProgress(ticket:PlaySoundTicket):void {
			if (ticket.caller == PlaySoundTicket.CALLER_CHAT && ticket.chatUID == ChatManager.getCurrentChat().uid) {
				var msgVO:ChatMessageVO = getMessage(ticket.messageUID);
				if (msgVO == null)
					return;
				if (msgVO.systemMessageVO == null)
					return;
				if (msgVO.systemMessageVO.voiceVO == null)
					return;
				var vmVO:VoiceMessageVO = msgVO.systemMessageVO.voiceVO;
				vmVO.currentTime = vmVO.duration - ticket.currentPlayed;
				if (list != null)
					list.updateItem(msgVO);
			}
		}
		
		private function updateSounds():void {
			var currentSoundTicket:PlaySoundTicket = SoundController.getCurrentSoundTicket();
			if (currentSoundTicket == null)
				return;
			if (currentSoundTicket.caller == PlaySoundTicket.CALLER_CHAT && currentSoundTicket.chatUID == ChatManager.getCurrentChat().uid) {
				var msgVO:ChatMessageVO = getMessage(currentSoundTicket.messageUID);
				if (msgVO == null || msgVO.systemMessageVO == null || msgVO.systemMessageVO.voiceVO == null) {
					currentSoundTicket.action = PlaySoundTicket.ACTION_STOP;
					SoundController.playTicket(currentSoundTicket);
					return;
				}
				var vmVO:VoiceMessageVO = msgVO.systemMessageVO.voiceVO;
				var soundStatus:SoundStatusData = SoundController.getSoundStatus(currentSoundTicket);
				if (soundStatus != null) {
					vmVO.isLoading = soundStatus.isLoading;
					vmVO.isPlaying = soundStatus.isPlaying;
					vmVO.currentTime = vmVO.duration - currentSoundTicket.currentPlayed;
				}
				if (list != null)
					list.updateItem(msgVO);
				return;
			}
			currentSoundTicket.action = PlaySoundTicket.ACTION_STOP;
			SoundController.playTicket(currentSoundTicket);
		}
		
		private function getMessage(messageUID:int):ChatMessageVO {
			if (ChatManager.getCurrentChat() && ChatManager.getCurrentChat().messages) {
				var length:int = ChatManager.getCurrentChat().messages.length;
				for (var i:int = 0; i < length; i++) {
					if (ChatManager.getCurrentChat().messages[i].id == messageUID) {
						return ChatManager.getCurrentChat().messages[i];
					}
				}
			}
			return null;
		}
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		//  <-  SOUND MESSAGE  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		private function onLightboxClose():void {
			echo("ChatScreen", "onLightboxClose", "");
			if (_isDisposed == true)
				return;
			if (isActivated)
			{
				updateChatInput();
			}
			if (LightBox.isShowing) // Beacuse we use same handler on PuzzleClose
			return;
			
			activateScreen();
		}
		
		override protected function onSwipe(d:String):void {
			return;
		}
		
		private function updateChatInput():void {
			if (InvoiceManager.isProcessingInvoice){
				hideInput(true);
				return;
			}
			if (LightBox.isShowing) {
				hideInput(true);
				return;
			}
			if (!isActivated) {
				hideInput(true);
				return;
			}
			
			showChatInput();
			setChatListSize(false);
		}
		
		private function onLightboxOpen():void {
			if (chatInput)
			{
				chatInput.hide();
			}
			echo("ChatScreen", "onLightboxOpen", "");
			if (isDisposed)
				return;
			deactivateScreen();
		}
		
		private function onNewMessage(data:ChatMessageVO):void {
			if (ChatManager.getCurrentChat() == null)
				return;
			if (data.chatUID != ChatManager.getCurrentChat().uid)
				return;
			if (list == null)
				return;
			echo("ChatScreen", "onNewMessage", data);
			
			var doScrollToBottom:Boolean;
			if (data.userUID == Auth.uid)
				doScrollToBottom = true;
			else
				doScrollToBottom = checkScrollToBottom();
			var lastMsgDate:Date = null;
			if (ChatManager.getCurrentChat().messages.length > 1)
				lastMsgDate = ChatManager.getCurrentChat().messages[ChatManager.getCurrentChat().messages.length - 2].date;
			var currentMsgDate:Date = data.date;
			if (lastMsgDate == null || (lastMsgDate.getFullYear() != currentMsgDate.getFullYear() || lastMsgDate.getMonth() != currentMsgDate.getMonth() || lastMsgDate.getDate() != currentMsgDate.getDate())) {
				list.refresh();
				list.appendItem(currentMsgDate, ListChatItem, ['avatarForChat', 'imageThumbURLWithKey'], true);
			}
			
			if (data.userUID != Auth.uid && scrollBottomButton.isVisible())
			{
				unreadedMessages ++;
			}
			else
			{
				unreadedMessages = 0;
			}
			
			if (scrollBottomButton != null)
			{
				scrollBottomButton.setUnreded(unreadedMessages);
			}
			list.appendItem(data, ListChatItem, ['avatarForChat', 'imageThumbURLWithKey'], true);
			updatePrewChatMessage(data);
			if (doScrollToBottom){
				clearUnreaded();
				list.scrollBottom(true);
			}
			if (userWritings != null)
				userWritings.removeUser(data.userUID);
			
			if (data.typeEnum == ChatSystemMsgVO.TYPE_911 && (data.systemMessageVO.method == ChatSystemMsgVO.METHOD_911_SATISFY || data.systemMessageVO.method == ChatSystemMsgVO.METHOD_911_SATISFY_USER)) {
				if (ChatManager.getCurrentChat().users == null || ChatManager.getCurrentChat().users.length == 0)
					return;
			}
		}
		
		private function clearUnreaded():void 
		{
			unreadedMessages = 0;
			if (list != null)
			{
				lastReadedIndex = list.length - 1;
			}
			
			if (scrollBottomButton != null)
			{
				scrollBottomButton.setUnreded(unreadedMessages);
			}
		}
		
		private function updatePrewChatMessage(newMessage:ChatMessageVO):void {
			var lastItemNum:int;
			if (list != null && 
				newMessage != null && 
				list.data != null && 
				list.data is Array && 
				(list.data as Array).length > 1) {
					lastItemNum = (list.data as Array).length - 2;
					if (((list.data as Array)[lastItemNum] is ChatMessageVO) && 
						((list.data as Array)[lastItemNum] as ChatMessageVO).userUID == newMessage.userUID) {
							list.updateItemByIndex(list.getStock().length - 2);
					}
			}
		}
		
		private function onCloseChatKeyboard():void {
			echo("ChatScreen", "onCloseChatKeyboard", "");
			if (!Config.PLATFORM_APPLE) {
				var openChatY:int = _height - (chatInput as ChatInputAndroid).height;
				chatInput.setY(openChatY);
			}
		}
		
		private function checkScrollToBottom():Boolean {
			if (list == null)
				return false;
			if (list.getScrolling() == true) {
				if (Math.abs(list.getBoxY()) + list.height > list.innerHeight)
					return true;
				return false;
			}
			if (Math.abs(list.getBoxY()) + list.height > list.innerHeight)
				return true;
			return false;
		}
		
		private function onChatOpened():void {
			echo("ChatScreen", "onChatOpened", "");
			
			chatready = true;
			chatTop.update();
			
			var chat:ChatVO = ChatManager.getCurrentChat();
			
			updateChatInput();
			
			if (chatInput)
				chatInput.initButtons(false);
			if (userWritings == null) {
				if (Config.PLATFORM_APPLE) {
					if (chatInput)
						iuBox.y = (chatInput as ChatInputIOS).y - iuBox.height;
				} else {
					iuBox.y = chatInput.getView().y - iuBox.height;
				}
			} else {
				userWritings.view.y = chatInput.getView().y - userWritings.getHeight() - Config.MARGIN;
				iuBox.y = userWritings.view.y - iuBox.height;	
			}
			
			var imgToUpload:Array;
			
			var images:Array = ImageUploader.getProcessingImages();
			if (images != null && images.length > 0)
			{
				if (imgToUpload == null)
				{
					imgToUpload = new Array();
				}
				imgToUpload = imgToUpload.concat(images);
			}
			
			var videos:Array = VideoUploader.getProcessingVideos();
			if (videos != null && videos.length > 0)
			{
				if (imgToUpload == null)
				{
					imgToUpload = new Array();
				}
				imgToUpload = imgToUpload.concat(videos);
			}
			if (imgToUpload == null || imgToUpload.length == 0)
				return;
			
			var l:int = imgToUpload.length;
			imagesUploaders ||= [];
			for (var i:int = 0; i < l; i++) {
				imagesUploaders.push(new ImagesUploaderStatus(imgToUpload[i]));
				imagesUploaders[imagesUploaders.length - 1].update("", null);
				iuBox.addChild(imagesUploaders[imagesUploaders.length - 1]);
				imagesUploaders[imagesUploaders.length - 1].x = Config.MARGIN;
			}
			repositionImageUploaders();
		}
		
		private function addStartSystemMessage():Boolean
		{
			if (list.data && list.data.length > 0 && needEnterName == false)
				return false;
			
			if (systemMessageShown)
			{
				return true;
			}
			systemMessageShown = true;
			var userVO:UserVO = new UserVO();
			userVO.setData({name:Lang.textSupport, avatar:LocalAvatars.SUPPORT})
			
			var messageStart:ChatMessageVO = new ChatMessageVO();
			messageStart.userVO = userVO;
			messageStart.usePlainText = true;
			messageStart.updateText(Lang.supportStartMessage);
			
			var messageName:ChatMessageVO = new ChatMessageVO();
			messageName.usePlainText = true;
			messageName.userVO = userVO;
			messageName.updateText(Lang.enterYourName);
			
			if (list) {
				list.appendItem(messageStart, ListChatItem);
				list.appendItem(messageName, ListChatItem);
				list.scrollBottom();
				clearUnreaded();
			}
			return true;
		}
		
		private function onFileUploadedStatus(status:String, imgUploader:FileUploader, data:Object = null):void {
			echo("ChatScreen", "onFileUploadedStatus");
			if (ChatManager.getCurrentChat() == null)
				return;
			if (imgUploader.getChatUID() != ChatManager.getCurrentChat().uid)
				return;
			if (status == ImageUploader.STATUS_START || status == VideoUploader.STATUS_START) {
				imagesUploaders ||= [];
				imagesUploaders.push(new ImagesUploaderStatus(imgUploader));
				imagesUploaders[imagesUploaders.length - 1].y = ((imagesUploaders.length - 1) * Config.FINGER_SIZE);
				imagesUploaders[imagesUploaders.length - 1].x = Config.MARGIN;
				imagesUploaders[imagesUploaders.length - 1].update(status, data);
				iuBox.addChild(imagesUploaders[imagesUploaders.length - 1]);
				
				if (userWritings == null || userWritings.view.parent == null)
					iuBox.y = bottomY - iuBox.height - Config.MARGIN;
				else
					iuBox.y = userWritings.view.y - iuBox.height - Config.MARGIN;
				return;
			}
			var l:int = imagesUploaders.length
			for (var i:int = 0; i < l; i++) {
				if (imagesUploaders[i].getImgUploader() == imgUploader) {
					imagesUploaders[i].update(status, data);
					if (status == ImageUploader.STATUS_COMPLETED || status == ImageUploader.STATUS_ERROR ||
						status == VideoUploader.STATUS_COMPLETED || status == VideoUploader.STATUS_ERROR) {
						var iu:ImagesUploaderStatus = imagesUploaders[i];
						TweenMax.to(iu, 30, { useFrames:true, alpha:0, onComplete:function():void {
							echo("ChatScreen","onFileUploadedStatus","TweenMax.to");
							if (_isDisposed) {
								return;
							}
							
							iuBox.removeChild(iu);
							repositionImageUploaders();
							if (userWritings == null || userWritings.view.parent == null)
								iuBox.y = bottomY - iuBox.height - Config.MARGIN;
							else
								iuBox.y = userWritings.getView().y - iuBox.height - Config.MARGIN;
						} } );
						imagesUploaders.splice(i, 1);
						var l1:int = imagesUploaders.length;
						for (var j:int = i; j < l1; j++) {
							TweenMax.killTweensOf(imagesUploaders[j]);
							
							if (Config.PLATFORM_APPLE) {
								if (chatInput) {
									TweenMax.to(imagesUploaders[j], 25, { useFrames:true, y:((chatInput as ChatInputIOS).y - (j + 1) * Config.FINGER_SIZE), ease:Quint.easeOut} );
								}
							} else {
								TweenMax.to(imagesUploaders[j], 25, { useFrames:true, y:(chatInput.getView().y - (j + 1) * Config.FINGER_SIZE), ease:Quint.easeOut} );
							}
						}
						return;
					}
					return;
				}
			}
		}
		
		private function repositionImageUploaders():void {
			echo("ChatScreen", "repositionImageUploaders");
			if (imagesUploaders == null)
				return;
			var l:int = imagesUploaders.length;
			var trueY:int = 0;
			for (var i:int = 0; i < l; i++) {
				trueY = i * Config.FINGER_SIZE;
				imagesUploaders[i].y = trueY;
			}
		}
		
		private function onMessagesLoaded():void {
			echo("ChatScreen", "onMessagesLoaded");
			TweenMax.killDelayedCallsTo(addPreloader);
			if (preloader != null)
				preloader.hide();
			
			if (_messagesLoaded == false){
				list.view.alpha = 0;
				TweenMax.killTweensOf(list.view);
				TweenMax.to(list.view, 0.7, { alpha:1 } );
			}
			_messagesLoaded = true;
			var needUpdateMessages:Boolean = true;
			if (ChatManager.getCurrentChat().lastMessagesHash != null && ChatManager.getCurrentChat().lastMessagesHash == lastMessagesHash)
				needUpdateMessages = false;
			if (needUpdateMessages) {
				lastMessagesHash = ChatManager.getCurrentChat().lastMessagesHash;
				var messages:Vector.<ChatMessageVO> = ChatManager.getCurrentChat().messages;
				var listData:Array = [];
				if (messages != null && messages.length > 0) {
					
					var currentDate:Date;
					var oldDate:Date;
					oldDate = messages[0].date;
					listData.push(oldDate);
					listData.push(messages[0]);
					for (var i:int = 1; i < messages.length; i++) {
						if (isNaN(messages[i].id) || messages[i].id == 0) {
							listData.push(messages[i]);
							continue;
						}
						currentDate = messages[i].date;
						if (currentDate.getTime() != oldDate.getTime()) {
							listData.push(currentDate);
							oldDate = currentDate;
						}
						listData.push(messages[i]);
					}
				}
				
				list.setData(listData, ListChatItem, ['avatarForChat', 'imageThumbURLWithKey'], null, ['imageThumbURLWithKey']);
				list.scrollBottom();
				clearUnreaded();
			}
			updateSounds();
			
			if (addStartSystemMessage() == false)
			{
				systemMessageShown = false;
			}
		}
		
		private function hideHistoryLoader():void 
		{
			if (historyLoadingState)
			{
				historyLoadingState = false;
				if (historyLoadingScroller != null)
				{
					historyLoadingScroller.hide();
				}
			}
		}
		
		private function chatHasMessagesFromAnotherSide(listData:Array):Boolean {
			var l:int = listData.length;
			for (var i:int = 0; i < l; i++) {
				if ((listData[i] is ChatMessageVO) && 
					(listData[i] as ChatMessageVO).userUID != Auth.uid && 
					(listData[i] as ChatMessageVO).userUID != null && 
					(listData[i] as ChatMessageVO).userUID != "0")
						return true;
			}
			return false;
		}
		
		private function onHistoricalMessagesLoaded():void {
			echo("ChatScreen", "onHistoricalMessagesLoaded", "");
			TweenMax.killDelayedCallsTo(addPreloader);
			if (preloader != null)
				preloader.hide();
			
			hideHistoryLoader();
			
			_messagesLoaded = true;
			var listPositionY:int = list.innerHeight;
			var messages:Vector.<ChatMessageVO> = ChatManager.getCurrentChat().messages;
			var listData:Array = [];
			/*if (messages[0].num > 1)
				listData.push( { title: "button" } );*/
			if (messages != null && messages.length > 0) {
				var currentDate:Date;
				var oldDate:Date;
				oldDate = messages[0].date;
				listData.push(oldDate);
				listData.push(messages[0]);
				for (var i:int = 1; i < messages.length; i++) {
					currentDate = messages[i].date;
					if (currentDate.getTime() != oldDate.getTime()) {
						listData.push(currentDate);
						oldDate = currentDate;
					}
					listData.push(messages[i]);
				}
			}
			list.setData(listData, ListChatItem, ['avatarForChat', 'imageThumbURLWithKey'], null, ['imageThumbURLWithKey']);
			list.setBoxY(-(list.innerHeight - listPositionY));
		}
		
		private function setChatListSize(needScrollToBottom:Boolean = false):void {
			if (_isDisposed == true)
				return;
			if (list == null || list.view == null)
				return;
			var inBotomPosition:Boolean = true;
			if (list.innerHeight + list.getBoxY() > list.height)
				inBotomPosition = false;
			bottomY = chatInput.getView().y;
			
			updateButtonsPositions(bottomY);
			
			var listHeightNew:int = bottomY - list.view.y;
			if (listHeightNew == list.height)
				return;
			list.setWidthAndHeight(MobileGui.stage.stageWidth, listHeightNew, !(needScrollToBottom || inBotomPosition));
			
			if (needScrollToBottom || inBotomPosition){
				clearUnreaded();
				list.scrollBottom();
			}
			if (preloader)
				preloader.y = int((listHeightNew - preloader.height) * .5) + list.view.y;
			if (userWritings == null || userWritings.getView().parent == null) {
				iuBox.y = bottomY - iuBox.height - Config.MARGIN;
			} else {
				userWritings.view.y = bottomY - userWritings.getHeight() - Config.MARGIN;
				iuBox.y = userWritings.view.y - iuBox.height - Config.MARGIN;
			}
		}
		
		private function updateButtonsPositions(bottomY:int):void 
		{
			if (scrollBottomButton != null)
			{
				scrollBottomButton.y = (bottomY - scrollBottomButton.height - Config.DIALOG_MARGIN * 0.7);
			}
		}
		
		private function onChatSend(value:*, type:String = ChatMessageType.TEXT):Boolean {
			if (ChatManager.getCurrentChat() != null && ChatManager.getCurrentChat().isIncomingLocalChat()) {
				ToastMessage.display(Lang.alertProvideInternetConnection, false, chatInput.getHeight());
				return false;
			}
			
			if (chatready == false)
			{
				return false;
			}
			
			if (type == ChatMessageType.LOCAL) {
				if (value is String)
				{
					if (value != null && StringUtil.trim(value).length == 0)
					{
						return true;
					}
				}
				
				ChatManager.sendMessage(value as String, null, null, true, -1);
			}
			
			
			if (introInfoReady() == false || needEnterName)
			{
				if (type == ChatMessageType.TEXT)
				{
					processIntroInfo(value);
				}
				return true;
			}
			
			if (introMessageSent == false && userName != null && userEmail != null)
			{
				sendSystemIntroMessage(userName, userEmail);
			}
			
			savedText = null;
			if (value is String) {
				var tmp:int = (value as String).length;
				if ((value as String).length > MAX_MESSAGE_LENGHT) {
					DialogManager.alert("", Lang.textMessageIsTooLong + MAX_MESSAGE_LENGHT + Lang.textCurrentMessageLength + (value as String).length);
					return false;
				}
			}
			if (type == ChatMessageType.TEXT) {
				if (value is String)
				{
					if (value != null && StringUtil.trim(value).length == 0)
					{
						return true;
					}
				}
				if (editingMsgID != -1) {
					var res:Boolean = ChatManager.updateMessage(value as String, editingMsgID);
					editingMsgID = -1;
					return res;
				}
				if (String(value).indexOf(Config.BOUNDS) == -1)
					savedText = value;
				ChatManager.sendMessage(value as String, null, null, false, -1, setSavedTextToInput);
			} else if (type == ChatMessageType.VOICE)
				ChatManager.sendVoice(value as LocalSoundFileData);
			return true;
		}
		
		private function introInfoReady():Boolean 
		{
			if (list == null)
			{
				return false;
			}
			if (list.data != null)
			{
				if (list.data.length > 0)
				{
					return true;
				}
				else
				{
					if (nameEntered == true)
					{
						if (emailEntered == true)
						{
							return true;
						}
						else
						{
							return false;
						}
					}
					else
					{
						return false;
					}
				}
			}
			return true;
		}
		
		private function processIntroInfo(message:String):void 
		{
			var userVO:UserVO = new UserVO();
			if (nameEntered == false)
			{
				nameEntered = true;
				userName = message;
				
				var messageMyName:ChatMessageVO = new ChatMessageVO();
				messageMyName.usePlainText = true;
				messageMyName.userUID = Auth.uid;
				messageMyName.userVO = Auth.myProfile;
				messageMyName.updateText(message);
				
				userVO.setData({name:Lang.textSupport, avatar:LocalAvatars.SUPPORT})
				var messageEmail:ChatMessageVO = new ChatMessageVO();
				messageEmail.usePlainText = true;
				messageEmail.userVO = userVO;
				messageEmail.updateText(Lang.enterYourEmail);
				
				if (list) {
					list.appendItem(messageMyName, ListChatItem);
					list.appendItem(messageEmail, ListChatItem);
					list.scrollBottom();
					clearUnreaded();
				}
			}
			else if (emailEntered == false)
			{
				var messageMyEmail:ChatMessageVO = new ChatMessageVO();
				messageMyEmail.usePlainText = true;
				messageMyEmail.userVO = Auth.myProfile;
				messageMyEmail.userUID = Auth.uid;
				messageMyEmail.updateText(message);
				
				var mailPattern:RegExp = /([a-z0-9._-]+)@([a-z0-9.-]+)\.([a-z]{2,4})/g;
				if (mailPattern.test(message))
				{
					userVO.setData({name:Lang.textSupport, avatar:LocalAvatars.SUPPORT})
					var messageHowHelp:ChatMessageVO = new ChatMessageVO();
					messageHowHelp.userVO = userVO;
					messageHowHelp.updateText(Lang.howCanWeHelpYou);
					messageHowHelp.usePlainText = true;
					
					if (list) {
						list.appendItem(messageMyEmail, ListChatItem);
						list.appendItem(messageHowHelp, ListChatItem);
						list.scrollBottom();
						clearUnreaded();
					}
					
					emailEntered = true;
					userEmail = message;
					
					needEnterName = false;
					sendSystemIntroMessage(userName, userEmail);
				}
				else
				{
					var messageWrongEmail:ChatMessageVO = new ChatMessageVO();
					messageWrongEmail.userVO = userVO;
					messageWrongEmail.updateText(Lang.enter_valid_email);
					messageWrongEmail.usePlainText = true;
					
					if (list) {
						list.appendItem(messageMyEmail, ListChatItem);
						list.appendItem(messageWrongEmail, ListChatItem);
						list.scrollBottom();
						clearUnreaded();
					}
				}
			}
		}
		
		private function sendSystemIntroMessage(user:String, mail:String):void 
		{
			if (introMessageSent == true)
			{
				return;
			}
			introMessageSent = true;
			
			var phone:String = "";
			if (data != null && data.phone != null)
			{
				phone = data.phone;
				phone = phone.replace("p", "+");
			}
			
			Store.save(Store.GUEST_NAME, user);
			Store.save(Store.GUEST_MAIL, mail);
			
			var message:Object = new Object();
			message.title = userName + ", " + userEmail;
			message.additionalData = new Object();
			message.additionalData.name = user;
			message.additionalData.mail = mail;
			message.additionalData.phone = phone;
			message.additionalData.uid = Auth.uid;
			message.type = "credentials";
			message.method = "credentials";
			
			onChatSend(Config.BOUNDS + JSON.stringify(message));
		}
		
		private function setSavedTextToInput():void {
			if (savedText == null || savedText == "")
				return;
			TweenMax.delayedCall(1, setSavedTextToInputContinue, null, true);
		}
		
		private function setSavedTextToInputContinue():void {
			if (savedText == null || savedText == "")
				return;
			if (chatInput == null)
				return;
			chatInput.setValue(savedText);
		}
		
		override public function clearView():void {
			echo("ChatScreen", "clearView", "");
			lastMessagesHash = null;
			if (noConnectionIndicator)
				noConnectionIndicator.dispose();
			noConnectionIndicator = null;
			if (scrollBottomButton != null)
				scrollBottomButton.dispose();
			scrollBottomButton = null;
			if (preloader != null)
				preloader.dispose();
			preloader = null;
			if (userWritings != null)
				userWritings.dispose();
			userWritings = null;
			if (list != null)
				list.dispose();
			list = null;
			if (bottomInputClip != null)
				UI.destroy(bottomInputClip);
			bottomInputClip = null;
			
			if (chatTop != null)
				chatTop.dispose();
			chatTop = null;
			if (iuBox != null)
				iuBox.graphics.clear();
			iuBox = null;
			if (imagesUploaders != null)
				while (imagesUploaders.length)
					imagesUploaders.shift().dispose();
			imagesUploaders = null;
			super.clearView();
			
			if (historyLoadingScroller) {
				historyLoadingScroller.dispose();
				historyLoadingScroller = null;
			}
			
			if (LightBox.isShowing) {
				LightBox.isShowing = false;
			}
			
			TweenMax.killDelayedCallsTo(addPreloader);
		}
		
		protected function onInputPositionChange():void {
			setChatListSize();
		}
		
		override public function dispose():void {
			echo("ChatScreen", "dispose", "");
			if (_isDisposed == true)
				return;
			disposing = true;
			WS.S_CONNECTED.remove(onSocketReady);
			
			TweenMax.killTweensOf(backColorClip);
			ChatManager.clearLocalChats();
			ChatManager.setCurrentChat(null);
			
			if (uploadFilePanel != null)
			{
				uploadFilePanel.dispose();
				uploadFilePanel = null;
			}
			if (noConnectionIndicator != null)
			{
				PointerManager.removeTap(noConnectionIndicator, tryReconnect);
			}
			
			ChatManager.S_MESSAGES_LOADING_FROM_PHP.remove(sMessagesStartLoadFromPHP);
			ChatManager.S_USER_WRITING.remove(onUserWriting);
			UserWriting.S_USER_WRITING_DISPOSED.remove(onUWDisposed);
			ChatManager.S_CHAT_OPENED.remove(onChatOpened);
			ChatManager.S_CHAT_STAT_CHANGED.remove(onChatUpdated);
			ChatManager.S_MESSAGES.remove(onMessagesLoaded);
			ChatManager.S_HISTORICAL_MESSAGES.remove(onHistoricalMessagesLoaded);
			ChatManager.S_MESSAGE.remove(onNewMessage);
			ChatManager.S_MESSAGE_UPDATED.remove(onMessageUpdated);
			ChatManager.S_ERROR_CANT_OPEN_CHAT.remove(onChatError);
			ChatManager.S_EDIT_MESSAGE.remove(editMessage);
			ChatManager.S_REMOTE_MESSAGES_STOP_LOADING.remove(onRemoteMessagesStopLoading);
			GlobalDate.S_NEW_DATE.remove(refreshList);
			LightBox.S_LIGHTBOX_OPENED.remove(onLightboxOpen);
			LightBox.S_LIGHTBOX_CLOSED.remove(onLightboxClose);
			ImageUploader.S_FILE_UPLOAD_STATUS.remove(onFileUploadedStatus);
			VideoUploader.S_FILE_UPLOAD_STATUS.remove(onFileUploadedStatus);
		//	WSClient.S_LOYALTY_CHANGE.remove(onLoyaltyChanged);
			
			NetworkManager.S_CONNECTION_CHANGED.remove(onNetworkChanged);
			
			WSClient.S_MSG_ADD_ERROR.remove(onErrorSendMessage);
			NetworkManager.S_CONNECTION_CHANGED.remove(onNetworkChanged);
			PhotoGaleryManager.S_GALLERY_IMAGE_LOADED.remove(onImageUploadReady);
			PhotoGaleryManager.S_GALLERY_MEDIA_LOADED.remove(onMediaUploadReady);
			ChatManager.onExitChat();
			
			ChatManager.S_LOAD_START.remove(showPreloader);
			ChatManager.S_LOAD_STOP.remove(hidePreloader);
				
			if (chatInput != null)
			{
				if (Config.PLATFORM_APPLE)
				{
					ChatInputIOS.S_INPUT_POSITION.remove(onInputPositionChange);
				}
				else
				{
					chatInput.setY(MobileGui.stage.stageHeight - (chatInput as ChatInputAndroid).height);
					ChatInputAndroid.S_INPUT_HEIGHT_CHANGED.remove(onInputPositionChange);
				}
				chatInput.dispose();
			}
			chatInput = null;
			
			_data = null;
			//в функции dispose нужно добавить
			NativeExtensionController.onChatScreenClosed();
			super.dispose();
		}
		
		// NO CONNECTION INDICATOR -> //
		private function onNetworkChanged():void {
			if (NetworkManager.isConnected)
			{
				
				if (ChatManager.getCurrentChat() != null && ChatManager.getCurrentChat().type == ChatRoomType.CHANNEL &&
					ChatManager.getCurrentChat().questionID != "" && ChatManager.getCurrentChat().questionID != null && ChatManager.getCurrentChat().getQuestion() == null)
				{
					QuestionsManager.getQuestionByUID(ChatManager.getCurrentChat().questionID);
				}
				hideNoConnectionIndicator();
			}
			else
				showNoConnectionIndicator();
		}
		
		private function hideNoConnectionIndicator():void {
			if (noConnectionIndicator == null || noConnectionIndicator.parent == null)
				return;
			PointerManager.removeTap(noConnectionIndicator, tryReconnect);
			noConnectionIndicator.parent.removeChild(noConnectionIndicator);
		}
		
		private function showNoConnectionIndicator():void {
			if (noConnectionIndicator == null) {
				noConnectionIndicator = new ConnectionIndicator();
				noConnectionIndicator.draw(_width, Config.FINGER_SIZE * .5);
				noConnectionIndicator.y = chatTop.height;
				noConnectionIndicator.y = chatTop.height;
			}
			_view.addChild(noConnectionIndicator);
			
			PointerManager.addTap(noConnectionIndicator, tryReconnect);
		}
		
		private function tryReconnect(e:Event = null):void 
		{
			NetworkManager.reconnect();
		}
		
		// GETTERS -> //
		private function get chatData():ChatScreenData {
			return data as ChatScreenData;
		}
		
		private function updateAppVersion():void{
			var url:URLRequest=null;
			if(Config.PLATFORM_APPLE)
				url=new URLRequest("https://apps.apple.com/app/apple-store/id830583192");
					else
						url=new URLRequest("https://play.google.com/store/apps/details?id=air.com.iswfx.connect");
			navigateToURL(url);
		}
	}
}