package com.dukascopy.connect.screens {

	import assets.ContectDeleteIcon;
	import assets.HandStop;
	import assets.ScrollBottomIcon;
	import com.adobe.utils.StringUtil;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.GD;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.BackgroundModel;
	import com.dukascopy.connect.data.ButtonActionData;
	import com.dukascopy.connect.data.ChatBackgroundCollection;
	import com.dukascopy.connect.data.ChatSettingsModel;
	import com.dukascopy.connect.data.ChatSystemMessageData;
	import com.dukascopy.connect.data.GiftData;
	import com.dukascopy.connect.data.HitZoneData;
	import com.dukascopy.connect.data.ListRenderInfo;
	import com.dukascopy.connect.data.LocalSoundFileData;
	import com.dukascopy.connect.data.MediaFileData;
	import com.dukascopy.connect.data.RateBotData;
	import com.dukascopy.connect.data.ScanPassportResult;
	import com.dukascopy.connect.data.SoundStatusData;
	import com.dukascopy.connect.data.TestHelper;
	import com.dukascopy.connect.data.UserBanData;
	import com.dukascopy.connect.data.escrow.EscrowScreenNavigation;
	import com.dukascopy.connect.data.escrow.EscrowStatus;
	import com.dukascopy.connect.data.escrow.TradeDirection;
	import com.dukascopy.connect.data.location.Location;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.customActions.AddInvoiceAction;
	import com.dukascopy.connect.data.screenAction.customActions.AddUserToContactsAction;
	import com.dukascopy.connect.data.screenAction.customActions.BlockUserAction;
	import com.dukascopy.connect.data.screenAction.customActions.BotReactionAction;
	import com.dukascopy.connect.data.screenAction.customActions.CallGetEuroAction;
	import com.dukascopy.connect.data.screenAction.customActions.CreateCoinTradeAction;
	import com.dukascopy.connect.data.screenAction.customActions.DownloadFileAction;
	import com.dukascopy.connect.data.screenAction.customActions.OpenFxProfileAction;
	import com.dukascopy.connect.data.screenAction.customActions.PayByCardAction;
	import com.dukascopy.connect.data.screenAction.customActions.PreviewMessagesAction;
	import com.dukascopy.connect.data.screenAction.customActions.RemoveImageAction;
	import com.dukascopy.connect.data.screenAction.customActions.ShowBanInfoAction;
	import com.dukascopy.connect.data.screenAction.customActions.chatMessageAction.CopyMessageAction;
	import com.dukascopy.connect.data.screenAction.customActions.chatMessageAction.EditMessageAction;
	import com.dukascopy.connect.data.screenAction.customActions.chatMessageAction.EnlargeMessageAction;
	import com.dukascopy.connect.data.screenAction.customActions.chatMessageAction.ForwardMessageAction;
	import com.dukascopy.connect.data.screenAction.customActions.chatMessageAction.MinimizeMessageAction;
	import com.dukascopy.connect.data.screenAction.customActions.chatMessageAction.RemoveMessageAction;
	import com.dukascopy.connect.data.screenAction.customActions.chatMessageAction.ReplyMessageAction;
	import com.dukascopy.connect.data.screenAction.customActions.chatMessageAction.ResendMessageAction;
	import com.dukascopy.connect.data.screenAction.customActions.chatMessageAction.SendGiftMessageAction;
	import com.dukascopy.connect.data.screenAction.customActions.test.SendEscrowTestAction;
	import com.dukascopy.connect.gui.button.ChatNewMessagesButton;
	import com.dukascopy.connect.gui.button.InfoButtonPanel;
	import com.dukascopy.connect.gui.button.LoadingRectangleButton;
	import com.dukascopy.connect.gui.chat.BubbleButton;
	import com.dukascopy.connect.gui.chat.ConnectionIndicator;
	import com.dukascopy.connect.gui.chat.QuestionPanel;
	import com.dukascopy.connect.gui.chat.ReplyMessagePanel;
	import com.dukascopy.connect.gui.chat.UploadFilePanel;
	import com.dukascopy.connect.gui.chatInput.ChatInputAndroid;
	import com.dukascopy.connect.gui.chatInput.ChatInputIOS;
	import com.dukascopy.connect.gui.chatInput.IChatInput;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.imagesUploaderStatus.ImagesUploaderStatus;
	import com.dukascopy.connect.gui.invoiceProcess.InvoiceProcessView;
	import com.dukascopy.connect.gui.lightbox.LightBox;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.List;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.gui.list.renderers.ListChatItem;
	import com.dukascopy.connect.gui.list.renderers.ListLink;
	import com.dukascopy.connect.gui.list.renderers.ListPayWalletItem;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.menuVideo.HidableButton;
	import com.dukascopy.connect.gui.preloader.Preloader;
	import com.dukascopy.connect.gui.puzzle.Puzzle;
	import com.dukascopy.connect.gui.topBar.TopBarChat;
	import com.dukascopy.connect.gui.userWriting.UserWriting;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.base.ScreenManager;
	import com.dukascopy.connect.screens.call.CallScreen;
	import com.dukascopy.connect.screens.call.TalkScreen;
	import com.dukascopy.connect.screens.context.ContextMenuScreen;
	import com.dukascopy.connect.screens.dialogs.QueuePopup;
	import com.dukascopy.connect.screens.dialogs.QueueUnderagePopup;
	import com.dukascopy.connect.screens.dialogs.ScanPassportPopup;
	import com.dukascopy.connect.screens.dialogs.ScreenLinksDialog;
	import com.dukascopy.connect.screens.dialogs.ScreenQuestionReactionsDialog;
	import com.dukascopy.connect.screens.dialogs.calendar.RecognitionDateRemindPopup;
	import com.dukascopy.connect.screens.dialogs.calendar.SelectRecognitionDatePopup;
	import com.dukascopy.connect.screens.dialogs.paymentDialogs.FeedbackPopup;
	import com.dukascopy.connect.screens.serviceScreen.Overlay;
	import com.dukascopy.connect.sys.DocumentUploader;
	import com.dukascopy.connect.sys.Gifts;
	import com.dukascopy.connect.sys.GlobalDate;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.assets.Assets;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.calendar.Calendar;
	import com.dukascopy.connect.sys.callManager.CallManager;
	import com.dukascopy.connect.sys.chat.DraftMessage;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.chatManager.ForwardingManager;
	import com.dukascopy.connect.sys.chatManager.typesManagers.AnswersManager;
	import com.dukascopy.connect.sys.chatManager.typesManagers.ChannelsManager;
	import com.dukascopy.connect.sys.configManager.ConfigManager;
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
	import com.dukascopy.connect.sys.payments.PayAPIManager;
	import com.dukascopy.connect.sys.payments.advancedPayments.vo.PayTaskVO;
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
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.sys.video.VideoUploader;
	import com.dukascopy.connect.sys.videoStreaming.VideoStreaming;
	import com.dukascopy.connect.sys.ws.WSClient;
	import com.dukascopy.connect.type.ActionType;
	import com.dukascopy.connect.type.BankPhaze;
	import com.dukascopy.connect.type.ChatInitType;
	import com.dukascopy.connect.type.ChatItemContextMenuItemType;
	import com.dukascopy.connect.type.ChatMessageReactionType;
	import com.dukascopy.connect.type.ChatMessageType;
	import com.dukascopy.connect.type.ChatRoomType;
	import com.dukascopy.connect.type.ChatSystemMessageValueType;
	import com.dukascopy.connect.type.ErrorCode;
	import com.dukascopy.connect.type.GiftType;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.type.ImageContextMenuType;
	import com.dukascopy.connect.type.InvoiceStatus;
	import com.dukascopy.connect.type.QuestionChatActionType;
	import com.dukascopy.connect.type.UserBlockStatusType;
	import com.dukascopy.connect.utils.ColorUtils;
	import com.dukascopy.connect.vo.ChatMessageVO;
	import com.dukascopy.connect.vo.ChatSystemMsgVO;
	import com.dukascopy.connect.vo.ChatVO;
	import com.dukascopy.connect.vo.QuestionVO;
	import com.dukascopy.connect.vo.chat.VoiceMessageVO;
	import com.dukascopy.connect.vo.screen.ChatScreenData;
	import com.dukascopy.connect.vo.users.UserVO;
	import com.dukascopy.connect.vo.users.adds.ChatUserVO;
	import com.dukascopy.langs.Lang;
	import com.dukascopy.langs.LangManager;
	import com.greensock.TweenMax;
	import com.greensock.easing.Quint;
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.AudioPlaybackMode;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextFormatAlign;
	import com.dukascopy.connect.sys.chat.RichMessageDetector;
	import com.dukascopy.connect.sys.chat.RichMessageDetector;
	import com.greensock.TweenLite;
	
	/**
	 * @author Igor Bloom
	 */
	
	public class ChatScreen extends BaseScreen {
		
		protected var chatTop:TopBarChat;
		private var noConnectionIndicator:ConnectionIndicator;
		protected var list:List;
		protected var chatInput:IChatInput;
		private var lockButton:BitmapButton;
		private var preloader:Preloader;
		private var iuBox:Sprite;
		protected var backgroundImage:Bitmap;
		private var questionLinkButton:BubbleButton;
		private var basketButton:BitmapButton;
		private var answersCountButton:BubbleButton;
		private var questionButtonBG:Bitmap;
		
		private var unlockBMD:BitmapData;
		private var backgroundBitmapData:ImageBitmapData;
		
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
		
		private var forwardMessageButton:InfoButtonPanel;
		private var lastBckgroundUrl:String;
		private var animateBackgroundShow:Boolean;
		private var needLoadBackground:Boolean;
		private var bannedInThisChat:Boolean = false;
		private var lastMessagesHash:String;
		private var historyLoadingState:Boolean;
		private var historyLoadingScroller:Preloader;
		private var loadHistoryOnMouseUp:Boolean;
		private var invoiceProcessView:InvoiceProcessView;
		private var currentComplainReason:String;
		private var currentType:String;
		private var questionPanel:QuestionPanel;
		private var satisfyPublicAnswerButton:HidableButton;
		private var reportButton:HidableButton;
		
		private var addToContactsAction:IScreenAction;
		private var blockUserAction:IScreenAction;
		private var savedText:String;
		private var bottomInputClip:Sprite;
		private var verificationButton:LoadingRectangleButton;
		private var vididBusy:Boolean;
		private var streamContainer:Sprite;
		private var stream:VideoStreaming;
		private var previewMessagesAction:PreviewMessagesAction;
		private var currentQueue:int;
		private var lastLoyaltyStatus:String;
		private var messageAdded:Boolean = false;
		private var currentBotRateMessage:RateBotData;
		private var scrollBottomButton:ChatNewMessagesButton;
		private var uploadFilePanel:UploadFilePanel;
		private var unreadedMessages:int = 0;
		private var lastReadedIndex:Number;
		private var currentInvoiceAction:AddInvoiceAction;
		private var cachedChatImages:Vector.<ChatMessageVO>;
		private var lastFirstMessageNum:int;
		private var replyPanel:ReplyMessagePanel;
		private var payByCardAction:PayByCardAction;
		protected var backColorClip:Sprite;
		static public var scannPassTime:Number = 0;
		
		public static const MAX_MESSAGE_LENGHT:int = 2000;
		static public const EVENTS_CHANNEL:String = "WgWwW2WDWZWdW8Wp";
		
		public function ChatScreen() { }
		
		private function addForwardMessageButton():void {
			if (forwardMessageButton == null) {
				forwardMessageButton = new InfoButtonPanel();
				forwardMessageButton.tapCallback = onForwardMessageButtonClick;
				view.addChild(forwardMessageButton);
				forwardMessageButton.viewWidth = _width;
				forwardMessageButton.setText(Lang.forwardMessage);
			}
			forwardMessageButton.y = chatTop.height;
			_view.addChild(forwardMessageButton);
		}
		
		private function showForwardMessageButton():void {
			addForwardMessageButton();
			forwardMessageButton.activate();
			forwardMessageButton.show();
			forwardMessageButton.updateViewport();
			if (noConnectionIndicator != null) {
				noConnectionIndicator.y = forwardMessageButton.y + forwardMessageButton.height;
			}
		}
		
		private function onForwardMessageButtonClick(isCancelForwarding:Boolean):void {
			hideForwardMessageButton();
			if (ForwardingManager.currentForwardingMessage == null)
				return;
			if (!isCancelForwarding)
				ForwardingManager.forwardForwardingMessageToCurrentChat();
			ForwardingManager.clearForwardingMessage();
		}
		
		private function hideForwardMessageButton():void {
			if (forwardMessageButton != null) {
				forwardMessageButton.hide();
				if (noConnectionIndicator != null)
					noConnectionIndicator.y = chatTop.height;
			}
		}
		
		override protected function createView():void {
			super.createView();
			
			backColorClip = new Sprite();
			view.addChild(backColorClip);
			
			list = new List("Chat");
			list.setContextAvaliable(true);
			list.setAdditionalBottomHeight(Config.FINGER_SIZE * .5);
			list.setMask(true);
			list.setOverlayReaction(false);
			_view.addChild(list.view);
			chatTop = new TopBarChat();
			chatTop.setChatScreen(this);
			_view.addChild(chatTop.view);
			
			bottomInputClip = new Sprite();
			
			chatInput = (Config.PLATFORM_APPLE) ? new ChatInputIOS(Lang.typeMessage) : new ChatInputAndroid();
			if (chatInput && chatInput.getView())
				_view.addChild(chatInput.getView());
			
			iuBox = new Sprite();
			_view.addChild(iuBox);
			
			// invoice processing view
			invoiceProcessView = new InvoiceProcessView();
			invoiceProcessView.initialize(view);
			
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
			
			Auth.S_PHAZE_CHANGE.add(checkForPhase);
			ChatManager.S_CHAT_OPENED.add(onChatOpened);
			ChatManager.S_USER_WRITING.add(onUserWriting);
			UserWriting.S_USER_WRITING_DISPOSED.add(onUWDisposed);
			ChatManager.S_CHAT_STAT_CHANGED.add(onChatUpdated);
			ChatManager.S_MESSAGES.add(onMessagesLoaded);
			ChatManager.S_HISTORICAL_MESSAGES.add(onHistoricalMessagesLoaded);
			ChatManager.S_MESSAGE.add(onNewMessage);
			ChatManager.S_MESSAGE_UPDATED.add(onMessageUpdated);
			ChatManager.S_PIN.add(onPinChange);
			ChatManager.S_MESSAGES_LOADING_FROM_PHP.add(sMessagesStartLoadFromPHP);
			ChatManager.S_REMOTE_MESSAGES_STOP_LOADING.add(onRemoteMessagesStopLoading);
			ChatManager.S_ERROR_CANT_OPEN_CHAT.add(onChatError);
			ChatManager.S_BANNED_IN_CHAT.add(onBannedInChat);
			ChatManager.S_UNBANNED_IN_CHAT.add(onUnbannedInChat);
			ChatManager.S_EDIT_MESSAGE.add(editMessage);
			GlobalDate.S_NEW_DATE.add(refreshList);
			LightBox.S_LIGHTBOX_OPENED.add(onLightboxOpen);
			LightBox.S_LIGHTBOX_CLOSED.add(onLightboxClose);
			LightBox.S_REQUEST_PREW_CONTENT.add(requestPrewMessages);
			Puzzle.S_PUZZLE_OPENED.add(onLightboxOpen);
			Puzzle.S_PUZZLE_CLOSED.add(onLightboxClose);
			ImageUploader.S_FILE_UPLOAD_STATUS.add(onFileUploadedStatus);
			VideoUploader.S_FILE_UPLOAD_STATUS.add(onFileUploadedStatus);
			QuestionsManager.S_QUESTION.add(onQuestion);
			QuestionsManager.S_QUESTION_NEW.add(onQuestion);
			QuestionsManager.S_QUESTION_CLOSED.remove(onQuestionClosed);
			
			PhotoGaleryManager.S_GALLERY_IMAGE_LOADED.add(onImageUploadReady);
			PhotoGaleryManager.S_GALLERY_MEDIA_LOADED.add(onMediaUploadReady);
			ChannelsManager.S_CHANNEL_SETTINGS_UPDATED.add(onChannelChanged);
			ChannelsManager.S_CHANNEL_MODERATORS_UPDATED.add(onChannelModeratorsChanged);
			
			InvoiceManager.S_START_PROCESS_INVOICE.add(onStartProcessInvoice);
			InvoiceManager.S_STOP_PROCESS_INVOICE.add(onStopProcessInvoice);
			
			ChatManager.S_LOAD_START.add(showPreloader);
			ChatManager.S_LOAD_STOP.add(hidePreloader);
			
			NetworkManager.S_CONNECTION_CHANGED.add(onNetworkChanged);
			
			/*Calendar.S_APPOINTMENT_BOOK.add(updateViAppointment);
			Calendar.S_APPOINTMENT_BOOK_CANCEL.add(updateViAppointment);
			Calendar.S_APPOINTMENT_BOOK_FAIL.add(updateViAppointment);
			Calendar.S_APPOINTMENT_DATA.add(updateViAppointment);
			Calendar.S_START_VI.add(callStartVI);
			WSClient.S_LOYALTY_CHANGE.add(onLoyaltyChanged);*/
			
			if (invoiceProcessView != null)
			{
				invoiceProcessView.setSizes(_width, _height);
			}

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
			if (ForwardingManager.currentForwardingMessage != null)
				showForwardMessageButton();
			
			if (chatTop != null){
				chatTop.redrawTitle();
			}
			
			updateChatInput();
			
			NativeExtensionController.S_LOCATION.add(onMyLocation);
			WSClient.S_LOCATION_UPDATE.add(onUserLocation);
		}

		private function hidePreloader():void 
		{
			if (preloader != null)
			{
				preloader.hide();
			}
			if (satisfyPublicAnswerButton)
			{
				satisfyPublicAnswerButton.activate();
			}
		}
		
		private function showPreloader():void 
		{
			preloader ||= new Preloader();
			preloader.x = _width * .5;
			preloader.y = _height * .5;
			view.addChild(preloader);
			preloader.show();
			if (satisfyPublicAnswerButton)
			{
				satisfyPublicAnswerButton.deactivate();
			}
		}
		
		private function editMessage(messageVO:ChatMessageVO):void {
			if (messageVO != null && ChatManager.getCurrentChat() != null && messageVO.chatUID == ChatManager.getCurrentChat().uid && chatInput != null) {
				chatInput.setValue(messageVO.text);
				editingMsgID = messageVO.id;
			}
		}
		
		private function onUserLocation(data:Object):void 
		{
			if (data != null && ChatManager.getCurrentChat() != null && data.chatUID == ChatManager.getCurrentChat().uid)
			{
				NativeExtensionController.onUserLocation(UsersManager.getInterlocutor(ChatManager.getCurrentChat()), data.location as Location);
			}
		}
		
		private function onMyLocation(location:Location):void 
		{
			if (ChatManager.getCurrentChat() != null && ChatManager.getCurrentChat().type == ChatRoomType.PRIVATE)
			{
				WSClient.sendLocationUpdate(UsersManager.getInterlocutor(ChatManager.getCurrentChat()).uid, location);
			}
		}
		
		private function onQuestionClosed(qUID:String):void {
			if (ChatManager.getCurrentChat() == null)
				return;
			if (ChatManager.getCurrentChat().questionID != qUID)
				return;
			if (preloader != null)
				preloader.hide();
			answersButtonShowHide();
		}
		
		private function onQuestion(qVO:QuestionVO):void {
			var currentChat:ChatVO = ChatManager.getCurrentChat();
			if (currentChat == null)
				return;
			var currentQVO:QuestionVO = currentChat.getQuestion();
			if (currentQVO == null)
				return;
			if (currentQVO != qVO)
				return;
			if (currentChat.type == ChatRoomType.QUESTION) {
				checkQuestionButtons();
			}
			
			var msgVO:ChatMessageVO = ChatManager.getCurrentChat().getEuroActionMessageVO();
			if (list != null && msgVO != null)
				list.updateItem(msgVO);
			if (questionPanel != null) {
				questionPanel.update();
			}
			if (qVO.isPaid == true && satisfyPublicAnswerButton != null) {
				satisfyPublicAnswerButton.deactivate();
				satisfyPublicAnswerButton.visible = false;
			}
			if (chatTop != null) {
				chatTop.redrawTitle();
			}
			updateChatInput();
		}
		
		private function checkQuestionButtons():void 
		{
			var qVO:QuestionVO = ChatManager.getCurrentChat().getQuestion();
			
			if (qVO.userUID == Auth.uid)
			{
				createQuestionButtons();
				questionButtonShowHide();
				answersButtonShowHide(true);
			}
			else
			{
				if (questionButtonBG == null)
				{
					createQuestionPanelBack();
					createMakeOfferButton();
				}
				
				if (questionLinkButton != null)
				{
					var action:Boolean = true;
					
					if (qVO.type != QuestionsManager.QUESTION_TYPE_PUBLIC)
					{
						if (qVO == null)
							action = false;
						else if (qVO.status == "closed" || qVO.status == "resolved" || qVO.status == "archived")
							action = false;
						else if (ChatManager.getCurrentChat().queStatus == true)
							action = false;
						if (questionLinkButton.getIsShown() != action)
						{
							if (action == true) {
								questionLinkButton.show();
								questionLinkButton.activate();
								if (basketButton != null) {
									basketButton.show();
									basketButton.activate();
								}	
							} else {
								questionLinkButton.hide();
								questionLinkButton.deactivate();
								if (basketButton != null) {
									basketButton.hide();
									basketButton.deactivate();
								}
								disableEscrowButtons();
							}
							questionButtonBG.visible = (action);
						}
					}
				}
			}
		}
		
		private function createQuestionPanelBack():void 
		{
			questionButtonBG ||= new Bitmap(new BitmapData(10, 10, false, Style.color(Style.COLOR_SEPARATOR_TOP_BAR)));
			questionButtonBG.visible = false;
			_view.addChild(questionButtonBG);
		}
		
		private function createAnswersButton():void 
		{
			var o0:int = Config.MARGIN;
			var o1:int = Config.MARGIN * .5;
			
			answersCountButton ||= new BubbleButton();
			answersCountButton.setParams(Style.color(Style.COLOR_TEXT), Style.color(Style.COLOR_SEPARATOR_TOP_BAR), 1, Style.color(Style.COLOR_LINE_LIGHT), 1, TextFormatAlign.CENTER);
			answersCountButton.setStandartButtonParams();
				
			var buttonWidth:int;
			if (basketButton != null)
			{
				buttonWidth = (_width - Config.FINGER_SIZE * .15 * 3) * 5;
			}
			else
			{
				buttonWidth = (_width - Config.FINGER_SIZE * .15 * 2);
			}
			answersCountButton.setText("Pp", buttonWidth);
			
			answersCountButton.setDownScale(1);
			answersCountButton.setDownAlpha(0);
			answersCountButton.setOverflow(o0, o0, o0, o0);
			answersCountButton.tapCallback = openOtherAnswers;
			answersCountButton.hide();
			_view.addChild(answersCountButton);
		}
		
		private function createRemoveButton():void 
		{
			var o0:int = Config.MARGIN;
			var o1:int = Config.MARGIN * .5;
			
			if (ChatManager.getCurrentChat().complainStatus == null || ChatManager.getCurrentChat().complainStatus == "") {
				basketButton ||= createButton(ContectDeleteIcon, "basket_button");
				basketButton.setStandartButtonParams();
				basketButton.setDownScale(1);
				basketButton.setDownAlpha(0);
				basketButton.setOverflow(o0, o1, o0, o0);
				basketButton.tapCallback = deleteAnswer;
				basketButton.hide();
				_view.addChild(basketButton);
			}
		}
		
		private function createMakeOfferButton():void 
		{
			var o0:int = Config.MARGIN;
			var o1:int = Config.MARGIN * .5;
			
			questionLinkButton ||= new BubbleButton();
			questionLinkButton.setParams(Color.WHITE, Color.GREEN, 1, NaN, 0, TextFormatAlign.CENTER);
			questionLinkButton.setStandartButtonParams();
			
			var buttonWidth:int;
			if (basketButton != null)
			{
				buttonWidth = (_width - Config.FINGER_SIZE * .15 * 3 - basketButton.width) * .5;
			}
			else
			{
				buttonWidth = (_width - Config.FINGER_SIZE * .15 * 2);
			}
			
			questionLinkButton.setText(Lang.make_offer, buttonWidth);
			questionLinkButton.setDownScale(1);
			questionLinkButton.setDownAlpha(0);
			questionLinkButton.setOverflow(o0, o0, o1, o0);
			questionLinkButton.tapCallback = createOffer;
			questionLinkButton.hide();
			_view.addChild(questionLinkButton);
		}
		
		private function createOffer():void 
		{
			var tradeAction:CreateCoinTradeAction = new CreateCoinTradeAction();
			tradeAction.chat = ChatManager.getCurrentChat();
			
			var direction:TradeDirection;
			var question:QuestionVO = ChatManager.getCurrentChat().getQuestion();
			if (question != null)
			{
				if (question.subtype == "sell")
				{
					if (question.userUID == Auth.uid)
					{
						direction = TradeDirection.sell;
					}
					else
					{
						direction = TradeDirection.buy;
					}
				}
				else
				{
					if (question.userUID == Auth.uid)
					{
						direction = TradeDirection.buy;
					}
					else
					{
						direction = TradeDirection.sell;
					}
				}
			}
			
			tradeAction.direction = direction;
			tradeAction.currency = question.priceCurrency;
			tradeAction.price = question.price;
			tradeAction.instrument = question.tipsCurrency;
			tradeAction.amount = question.tipsAmount;
			
			tradeAction.setData(Lang.escrow);
			tradeAction.execute();
		}
		
		// Start Process invoice 
		private function onStartProcessInvoice():void {
			TweenMax.killDelayedCallsTo(dellayedActivate);
			deactivateScreen();
			updateChatInput();
		}
		
		// Stop Process Invoice 
		private function onStopProcessInvoice():void {
			TweenMax.killDelayedCallsTo(dellayedActivate);
			if (InvoiceManager.getCurrentInvoiceData() != null && InvoiceManager.getCurrentInvoiceData().handleInCustomScreenName == "")
			{
				TweenMax.delayedCall(.4,dellayedActivate);
			}
		}
		
		private function dellayedActivate():void {
			if (_isDisposed)
				return;
			
			activateScreen();
			updateChatInput();
		}
		
		private function checkApproveStatus():void {
			var chat:ChatVO;
			if (chatData != null)
			{
				chat = chatData.chatVO;
			}
			if (chat == null)
				chat = ChatManager.getCurrentChat();
			if (chat == null || chat.users == null)
				return;
			if (ChatManager.currentChatApproveStatus == true && chat.users != null && chat.users.length > 0) {
				if (list.data && list.data.length > 0)
					return;
				var userModel:ChatUserVO = new ChatUserVO(chat.users[0]);
				var newUserMessageModel:ChatMessageVO = new ChatMessageVO();
				addToContactsAction = new AddUserToContactsAction();
				addToContactsAction.getSuccessSignal().add(onUserAdded);
				addToContactsAction.getFailSignal().add(onUserAddFailed);
				addToContactsAction.setData(userModel);
				
				blockUserAction = new BlockUserAction();
				blockUserAction.getSuccessSignal().add(onUserBlocked);
				blockUserAction.getFailSignal().add(onUserBlockFailed);
				blockUserAction.setData(userModel);
				
				previewMessagesAction = new PreviewMessagesAction();
				previewMessagesAction.getSuccessSignal().add(previewMessages);
				
				var systemMessage:ChatSystemMessageData = new ChatSystemMessageData();
				systemMessage.type = ChatSystemMessageValueType.NOT_IN_CONTACTS;
				systemMessage.title = userModel.name;
				var warning:String = "";
				if (ChatManager.getCurrentChat() != null && ChatManager.getCurrentChat().reports > 0)
				{
					warning = Lang.userWarning;
					warning = "\n" + LangManager.replace(Lang.regExtValue, warning, ChatManager.getCurrentChat().reports.toString());
				}
				
				systemMessage.message = Lang.contactNotInList + warning + "\n\n" +  Lang.newChatWarning;
				
				var buttonAdd:ButtonActionData = new ButtonActionData();
				buttonAdd.text = Lang.addToContacts;
				buttonAdd.backColor = 0x78C043;
				buttonAdd.outlineColor = 0x78C043;
				buttonAdd.textColor = 0xFFFFFF;
				buttonAdd.action = addToContactsAction;
				
				var buttonBlock:ButtonActionData = new ButtonActionData();
				buttonBlock.text = Lang.textBlock;
				buttonBlock.backColor = 0x3E4756;
				buttonBlock.outlineColor = 0x94A2AF;
				buttonBlock.textColor = 0xFFFFFF;
				buttonBlock.action = blockUserAction;
				
				var buttonPreview:ButtonActionData = new ButtonActionData();
				buttonPreview.text = Lang.preview;
				buttonPreview.backColor = 0x3E4756;
				buttonPreview.outlineColor = 0x94A2AF;
				buttonPreview.textColor = 0xFFFFFF;
				buttonPreview.action = previewMessagesAction;
				
				systemMessage.addButton(buttonAdd);
				systemMessage.addButton(buttonBlock);
				systemMessage.addButton(buttonPreview);
				
				newUserMessageModel.systemMessage = systemMessage;
				
				if (list) {
					list.appendItem(newUserMessageModel, ListChatItem);
					list.scrollBottom();
					clearUnreaded();
				}
			}
		}
		
		private function previewMessages():void {
			if (messageAdded == true)
				return;
			messageAdded = true;
			var cVO:ChatVO = ChatManager.getCurrentChat();
			if (cVO == null)
				return;
			if (cVO.messageVO != null) {
				list.appendItem(cVO.messageVO, ListChatItem);
				list.scrollBottom();
				clearUnreaded();
			}
		}
		
		private function onUserBlockFailed():void {
			if (preloader != null)
				preloader.hide();
			ToastMessage.display(Lang.somethingWentWrong);
		}
		
		private function onUserBlocked():void {
			//dispose экшена или в самом экшене;
			if (preloader != null)
				preloader.hide();
			onBack();
		}
		
		private function onUserAddFailed():void {
			//dispose экшена или в самом экшене;
			if (preloader != null)
				preloader.hide();
			ToastMessage.display(Lang.somethingWentWrong);
		}
		
		private function onUserAdded():void {
			//dispose экшена или в самом экшене;
			if (preloader != null)
				preloader.hide();
			ChatManager.activateChat();
		}
		
		private function onChannelChanged(eventType:String, channelUID:String):void {
			var currentChatUID:String;
			if ((data as ChatScreenData).chatVO)
				currentChatUID = (data as ChatScreenData).chatVO.uid;
			else if (ChatManager.getCurrentChat())
				currentChatUID = ChatManager.getCurrentChat().uid;
			if (currentChatUID != channelUID)
				return;
			switch(eventType) {
				case ChannelsManager.EVENT_BACKGROUND_CHANGED: {
					updateChatBackground();
					break;
				}
				case ChannelsManager.EVENT_TITLE_CHANGED: {
					chatTop.redrawTitle();
					break;
				}
				case ChannelsManager.EVENT_MODE_CHANGED: {
					updateChatInput();
					break;
				}
			}
		}
		
		private function hideInput(showFakeInput:Boolean = false):void {
			if (chatInput != null)
				chatInput.hide();
			if (!showFakeInput) {
				list.setWidthAndHeight(MobileGui.stage.stageWidth, MobileGui.stage.stageHeight - list.view.y);
				chatInput.hideBackground();
			}
		}
		
		private function onUnbannedInChat(chatUID:String):void {
			if (isDisposed)
				return;
			if (ChatManager.getCurrentChat() && ChatManager.getCurrentChat().uid == chatUID)
				removeBannedMessage();
		}
		
		private function removeBannedMessage():void {
			if (list) {
				var unbannedMessage:ChatMessageVO = new ChatMessageVO();
				var systemMessage:ChatSystemMessageData = new ChatSystemMessageData();
				systemMessage.backAlpha = 0.7;
				systemMessage.message = Lang.youUnbanned;
				unbannedMessage.systemMessage = systemMessage;
				list.appendItem(unbannedMessage, ListChatItem);
				list.scrollBottom();
				unreadedMessages = 0;
			}
			bannedInThisChat = false;
			activateScreen();
			updateChatInput();
		}
		
		private function onBannedInChat(chatUID:String, banData:UserBanData):void {
			if (isDisposed)
				return;
			if (ChatManager.getCurrentChat() && ChatManager.getCurrentChat().uid == chatUID)
				addBannedMessage(banData);
		}
		
		private function addBannedMessage(banData:UserBanData):void {
			if (!bannedInThisChat && banData) {
				bannedInThisChat = true;
				
				chatInput.hide();
				
				var bannedModel:ChatMessageVO = new ChatMessageVO();
				var showBanInfoAction:IScreenAction = new ShowBanInfoAction();
				showBanInfoAction.setData(banData);
				
				var systemMessage:ChatSystemMessageData = new ChatSystemMessageData();
				systemMessage.message = Lang.youBanned;
				systemMessage.backAlpha = 0.7;
				var buttonDetails:ButtonActionData = new ButtonActionData();
				buttonDetails.text = Lang.textDetails;
				buttonDetails.action = showBanInfoAction;
				buttonDetails.textColor = 0x723E44;
				systemMessage.addButton(buttonDetails);
				systemMessage.type = ChatSystemMessageData.YOU_BANNED;
				bannedModel.systemMessage = systemMessage;
				
				if (list) {
					list.appendItem(bannedModel, ListChatItem);
					list.scrollBottom();
					clearUnreaded();
				}
			}
		}
		
		static private function onImageUploadReady(success:Boolean, ibd:ImageBitmapData, title:String):void {
			echo("ChatScreen", "onImageUploadReady", "start");
			/*if (currentChat == null ||
				currentChat.uid == null ||
				currentChat.uid == "") {
					return;
			}*/
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
			var chat:ChatVO = ChatManager.getCurrentChat();
			if (chat != null && chat.settings != null && chat.settings.backgroundURL != null && chat.settings.backgroundURL != "") {
				loadChatBackground(chat.settings.backgroundURL);
			} else {
				// Get background Average color for button outline
				if (chatData != null && chatData.settings != null) {
					var backgroundID:String = chatData.settings.chatBackId;
					if (backgroundID == null) {
						textOverBackgroundColor = DEFAULT_OVER_BACKGROUND_COLOR;
					} else {
						var backgroundModel:BackgroundModel = ChatBackgroundCollection.getBackground(backgroundID);
						textOverBackgroundColor = backgroundModel.invertedColor;
					}
					updateBackground((chatData.settings as ChatSettingsModel).chatBackId);
				} else {
					textOverBackgroundColor = DEFAULT_OVER_BACKGROUND_COLOR;
				}
			}
		}
		
		public function getTitleValue():String {
			var userModel:UserVO;
			var titleText:String;
			if (chatData != null) {
				var chatModel:ChatVO;
				if (ChatManager.getCurrentChat() != null) {
					chatModel = ChatManager.getCurrentChat();
				} else if (chatData.chatVO != null) {
					chatModel = chatData.chatVO;
				} else {
					if (chatData.chatUID != null) {
						chatModel = ChatManager.getChatByUID(chatData.chatUID);
					}
				}
				if (chatModel != null && 
					(chatModel.type == ChatRoomType.PRIVATE || chatModel.type == ChatRoomType.QUESTION) && 
					chatModel.users != null && chatModel.users.length > 0) {
						var user:ChatUserVO = chatModel.users[0];
						if (user != null) {
							if (user.secretMode == true)
								return Lang.textIncognito;
							userModel = user.userVO;
							if (userModel != null)
								titleText = userModel.getDisplayName();
							else
								titleText = chatModel.title;
						}
				}
				if (chatModel != null && 
					chatModel.type == ChatRoomType.CHANNEL && 
					chatModel.questionID != null && chatModel.questionID != "") {
						if (chatModel.getQuestion() != null && chatModel.getQuestion().user != null) {
							if (chatModel.getQuestion().incognito)
								return Lang.textIncognito;
							return chatModel.getQuestion().user.getDisplayName();
						} else
							return Lang.question;
				}
				if (chatData.type == ChatInitType.CHAT || chatData.type == ChatInitType.QUESTION) {
					if (chatModel != null) {
						if (chatModel.type == ChatRoomType.PRIVATE || chatModel.type == ChatRoomType.QUESTION) {
							if (chatModel.users && chatModel.users.length > 0) {
								userModel = chatModel.users[0].userVO;
								if (userModel != null)
									titleText = userModel.getDisplayName();
								else
									titleText = chatModel.title;
							} else
								titleText = chatModel.title;
						} else
							titleText = chatModel.title;
					} else {
						if (chatData.type == ChatInitType.QUESTION && chatData.question != null) {
							if (chatData.question.incognito == true)
								titleText = Lang.textIncognito;
							else
								titleText = chatData.question.title;
						}
					}
				} else if (chatData.type == ChatInitType.USERS_IDS) {
					if (chatData.usersUIDs) {
						if (chatData.usersUIDs.length == 1) {
							userModel = UsersManager.getFullUserData(chatData.usersUIDs[0]);
							
							if (userModel && userModel.getDisplayName() != "" && userModel.getDisplayName() != null) {
								titleText = userModel.getDisplayName();
							} else {
								if (chatModel) {
									titleText = chatModel.title;
								}
							}
						} else {
							//group chat;
							if (chatModel) {
								titleText = chatModel.title;
							} else {
								titleText = '';
								var userProfile:UserVO;
								for (var i:int = 0; i < chatData.usersUIDs.length; i++) {
									userProfile = UsersManager.getFullUserData(chatData.usersUIDs[i], false);
									if (userProfile && userProfile.getDisplayName() != null) {
										if (i > 0)
											titleText+= ', ';
										titleText += userProfile.getDisplayName();
									}
								}
							}
						}
					}
				} else if (chatData.type == ChatInitType.SUPPORT) {
					var pid:int = (chatData!=null && "pid" in chatData)?chatData.pid:-1;
					if (pid ==-1 && chatModel != null)
						pid = chatModel.pid;
					if (pid ==-1)
						titleText = Lang.standartSupportTitle;
					else if (pid == Config.EP_VI_DEF)
						titleText = Lang.chatWithBankTitle;
					else if (pid == Config.EP_VI_EUR)
						titleText = Lang.chatWithBankEUTitle;	
					else if (pid == Config.EP_VI_PAY)
						titleText = Lang.chatWithPayEUTitle;
					else if (chatModel != null)
						titleText = chatModel.title;
				}
			}
			
			if (titleText == null){
				titleText = "";
			}
			
			return titleText;
		}
		
		override public function startRenderingBitmap():void {
			if (checkWritingAvaliablity() == true){
				if (chatInput != null)
				{
					chatInput.showBG();
				}
			}
		}
		
		// TODO - show alert
		private function onChatError(message:String = null):void {
			echo("ChatScreen", "onChatError", "");
			if (message == ActionType.CHAT_CLOSE_ON_ERROR)
				onBack();
			else if (message != null && message.indexOf("que..09") == 0)
				onBack();
			else if (message != null && message.indexOf("io") == 0) {
				ToastMessage.display(Lang.textConnectionError);
				onBack();
			}
			else if (message != null && message.indexOf("que..16") == 0) {
				ToastMessage.display(Lang.questionYouAreBanned);
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
			else if (message == "chat.04 No access - user want to chat only with friends") {
				var systemMessage:ChatSystemMessageData = new ChatSystemMessageData();
				systemMessage.message = Lang.onlyFriendsAllowed;
				if (data != null && data is ChatScreenData && (data as ChatScreenData).usersUIDs != null && (data as ChatScreenData).usersUIDs.length > 0){
					
				}
				var user:UserVO = UsersManager.getFullUserData((data as ChatScreenData).usersUIDs[0], false)
				if (user != null){
					var button:ButtonActionData = new ButtonActionData();
					button.backColor = 0x3B4452;
					button.text = Lang.openProfile;
					var action:OpenFxProfileAction = new OpenFxProfileAction(user.login);
					button.action = action;
					button.textColor = 0xFFFFFF;
					button.outlineColor = 0x8497B6;
					systemMessage.addButton(button);
				}
				
				var messageAlert:ChatMessageVO = new ChatMessageVO();
				messageAlert.systemMessage = systemMessage;
				if (list.data == null){
					list.setData([messageAlert], ListChatItem);
				} else {
					list.data.push(messageAlert);
				}
				list.refresh();
			} else if (message == null) {
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
			
			if (currentBotRateMessage != null) {
				
				var action:BotReactionAction = new BotReactionAction(currentBotRateMessage, ChatManager.getCurrentChat().uid, currentBotRateMessage.botUID);
				action.execute();
				
				currentBotRateMessage = null;
				return;
			}
			
			/*if (needToRateBot == true && rateBot != null) {
				ServiceScreenManager.showScreen(
					ServiceScreenManager.TYPE_DIALOG,
					FeedbackPopup,
					{
						text:Lang[rateBot.desc], 
						textFeedback:Lang[rateBot.desc1], 
						button_1:Lang[rateBot.buttons[0].label], 
						button_2:Lang[rateBot.buttons[1].label], 
						button_3:Lang[rateBot.buttons[2].label],
						button_4:Lang[rateBot.buttons[3].label],
						callback:function(val:int, text:String = null):void {
							if (val == 0)
								return;
							if (ChatManager.getCurrentChat() == null)
								return;
							if (rateBot == null || rateBot.buttons == null || rateBot.buttons.length < val)
								return;
							PHP.call_statVI("SPR_" + rateBot.buttons[val - 1].statAction, ChatManager.getCurrentChat().uid);
							ChatManager.sendBotActionMessage(
								rateBot.buttons[val - 1].botAction,
								null,
								(rateBot.buttons[val - 1].feedback != true) ? null : JSON.stringify( { feedback:text } ),
								ChatManager.getCurrentChat().uid,
								botUID
							);
							needToRateBot = false;
							rateBot = null;
						}
					}
				);
				return;
			}*/
			
			if (Config.PLATFORM_APPLE && chatInput != null) {
				(chatInput as ChatInputIOS).redrawScreenshot();
				(chatInput as ChatInputIOS).y = (MobileGui.stage.stageHeight - (chatInput as ChatInputIOS).height);
			} else if (Config.PLATFORM_ANDROID && chatInput != null) {
				if (chatInput != null) {
					(chatInput as ChatInputAndroid).setY(MobileGui.stage.stageHeight - (chatInput as ChatInputAndroid).height);
				}
			}
			if (chatData != null) {
				if (chatData.backScreen != null) {
				// Если backscreen - экран чата, но нет данных, то такой экран открывать нельзя
					if (!(chatData.backScreen == ChatScreen && chatData.backScreenData == null)) {
						// Не открывать call screen - если уже нет звонка
						if (chatData.backScreen == CallScreen || chatData.backScreen == TalkScreen) {
							if (!CallManager.isActive()) {
								chatData.backScreen = RootScreen;
								chatData.backScreenData = null;
							}
						}
						MobileGui.changeMainScreen(chatData.backScreen, chatData.backScreenData, ScreenManager.DIRECTION_LEFT_RIGHT);
						return;
					}
				}
				chatData.dispose();
			}
			MobileGui.changeMainScreen(RootScreen, null, ScreenManager.DIRECTION_LEFT_RIGHT);
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
				echo("ChatScreen","onMediaUploadReady",mediaData.path);
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
			{
				list.updateItem(msgVO, true, true);
				if (ChatManager.getCurrentChat().messageID == msgVO.id && msgVO.systemMessageVO != null)
				{
					if (msgVO.systemMessageVO.method == ChatSystemMsgVO.METHOD_NEWS || 
						msgVO.typeEnum == ChatSystemMsgVO.TYPE_INVOICE)
					{
						list.scrollBottom(false);
					}
				}
			}
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
			
			if (stream == null)
			{
				TweenMax.killTweensOf(backColorClip);
				backColorClip.alpha = 1;
				backColorClip.graphics.beginFill(DEFAULT_BACKGROUND_COLOR);
				backColorClip.graphics.drawRect(0, 0, _width, _height);
				backColorClip.graphics.endFill();
			}
			if (VideoStreaming.isOnAir() && VideoStreaming.currentChat != null && ChatManager.getCurrentChat() != null && ChatManager.getCurrentChat().uid == VideoStreaming.currentChat)
			{
				backColorClip.alpha = 0;
				chatTop.hide(0);
			}
			
			bottomInputClip.width = _width;
			bottomInputClip.height = Config.APPLE_BOTTOM_OFFSET;
			bottomInputClip.y = _height - Config.APPLE_BOTTOM_OFFSET;
			
			updateChatBackground();
		}
		
		private function updateBackground(backId:String):void {
			if (_isDisposed == true)
				return;
			if (backId) {
				var backgroundModel:BackgroundModel = ChatBackgroundCollection.getBackground(backId);
				if (backgroundModel == null)
					return;
				textOverBackgroundColor = backgroundModel.invertedColor;
				clearCurrentBackroundImage();
				backgroundBitmapData = Assets.getBackground(backgroundModel.big);
				if (backgroundImage == null) {
					backgroundImage = new Bitmap();
					_view.addChildAt(backgroundImage, 1);
				}
				else
				{
					
				}
				
				if (backgroundImage.bitmapData) {
					backgroundImage.bitmapData.dispose();
					backgroundImage.bitmapData = null;
				}
				backgroundImage.bitmapData = UI.drawAreaCentered(backgroundBitmapData, _width, _height);
				if (ChatManager.getCurrentChat() != null && ChatManager.getCurrentChat().settings != null)
				{
					ChatManager.getCurrentChat().settings.backgroundBrightness = ColorUtils.getAverageColorBrightness(backgroundImage);
					if (list != null)
					{
						list.refresh();
					}
				}
			} else
				clearCurrentBackroundImage();
			}
		
		private function onChatBackgroundLoaded(url:String, bmd:ImageBitmapData, success:Boolean):void {
			if (_isDisposed == true)
				return;
			if (bmd && success) {
				if (backgroundImage == null) {
					backgroundImage = new Bitmap();
					_view.addChildAt(backgroundImage, 1);
				}
				drawBackground(bmd, 0);
			}
		}
		
		private function loadChatBackground(imageURL:String):void {
			if (lastBckgroundUrl != imageURL) {
				if (lastBckgroundUrl)
					ImageManager.unloadImage(lastBckgroundUrl);
				var imageData:ImageBitmapData = ImageManager.getImageFromCache(imageURL);
				if (imageData) {
					lastBckgroundUrl = imageURL;
					drawBackground(imageData, 1);
				} else {
					lastBckgroundUrl = imageURL;
					animateBackgroundShow = true;
					ImageManager.loadImage(lastBckgroundUrl, onChatBackgroundLoaded);
				}
			}
		}
		
		private function drawBackground(imageData:ImageBitmapData, alphaValue:Number):void {
			if (backgroundImage == null) {
				backgroundImage = new Bitmap();
				_view.addChildAt(backgroundImage, 1);
			}
			backgroundImage.alpha = alphaValue;
			if (animateBackgroundShow == true) {
				animateBackgroundShow = false;
				TweenMax.to(backgroundImage, 0.5, {alpha:1});
			}
			if (list != null){
				backgroundImage.y = list.view.y;
			}
			backgroundImage.bitmapData = UI.drawAreaCentered(imageData, _width, _height);
			
			ChatManager.getCurrentChat().settings.backgroundBrightness = ColorUtils.getAverageColorBrightness(backgroundImage);
			if (list != null)
			{
				list.refresh();
			}
		}
		
		private function clearCurrentBackroundImage():void {
			echo("ChatScreen", "clearCurrentBackroundImage", "");
			Assets.removeBackground(backgroundBitmapData);
			UI.disposeBMD(backgroundBitmapData);
			backgroundBitmapData = null;
			if (backgroundImage) {
				TweenMax.killTweensOf(backgroundImage);
				UI.destroy(backgroundImage);
				backgroundImage = null;
			}
		}
		
		override public function activateScreen():void {
			echo("ChatScreen", "activateScreen", "");
			if (isDisposed)
				return;
			
			if (uploadFilePanel != null)
			{
				uploadFilePanel.activate();
			}
			if (ChatManager.getCurrentChat() != null)
			{
				NativeExtensionController.markChatRead(ChatManager.getCurrentChat());
			}
			
			if (Puzzle.isOpened) 
				return;
			if (InvoiceManager.isProcessingInvoice)
				return;
			if (_isActivated)
				return;
			super.activateScreen();
			if (noConnectionIndicator != null && noConnectionIndicator.visible == true && noConnectionIndicator.parent != null)
			{
				PointerManager.addTap(noConnectionIndicator, tryReconnect);
			}
			if (questionLinkButton) {
				questionLinkButton.activate();
			}
			if (answersCountButton) {
				answersCountButton.activate();
			}
			if (questionPanel != null) {
				questionPanel.activate();
			}
			if (basketButton != null) {
				basketButton.activate();
			}
			if (satisfyPublicAnswerButton != null) {
				satisfyPublicAnswerButton.activate();
			}
			if (reportButton != null) {
				reportButton.activate();
			}
			if (verificationButton != null) {
				verificationButton.activate();
			}
			if (scrollBottomButton != null && scrollBottomButton.isVisible())
			{
				scrollBottomButton.activate();
			}
			if (needToOpenChat == true) {
				needToOpenChat = false;
				
				if (chatData == null) {
					echo("ChatScreen", "activatScreen", "Data is null!!", true);
					if (ChatManager.getCurrentChat() != null) {
						_data = ChatManager.getCurrentChat();
					}
					if (chatData == null) {
						MobileGui.centerScreen.show(RootScreen);
						return;
					}
				}
				
				if (chatData.type == ChatInitType.CHAT) {
					if (chatData.chatVO != null)
						ChatManager.openChatByVO(chatData.chatVO);
					else
						ChatManager.openChatByUID(chatData.chatUID);
				} else if (chatData.type == ChatInitType.USERS_IDS)
					ChatManager.openChatByUserUIDs(chatData.usersUIDs, false, "chatscreen.activate");
				else if (chatData.type == ChatInitType.SUPPORT)
					ChatManager.openChatByPID(chatData.pid);
				else if (chatData.type == ChatInitType.FXID)
					ChatManager.openChatByFXID(chatData.fxid);
				else if(chatData.type == ChatInitType.QUESTION) {
					if (chatData.question != null)
						ChatManager.openChatByQuestionUID(chatData.question.uid);
					else if (chatData.escrow_ad_uid != null)
						ChatManager.openChatByQuestionUID(chatData.escrow_ad_uid);
					else
						ChatManager.openChatByUID(chatData.chatUID);
				}
			}
			
			// Если вопрос был закрыт, во время нахождения на скрине с которого вызван back
			if (_isDisposed == true)
				return;
			
			SoundController.S_SOUND_PLAY_START.add(onSoundPlayStart);
			SoundController.S_SOUND_PLAY_STOP.add(onSoundPlayStop);
			SoundController.S_SOUND_PLAY_LOADING.add(onSoundLoading);
			SoundController.S_SOUND_PLAY_PROGRESS.add(onSoundPlayProgress);
			
			TweenMax.delayedCall(1.5, addPreloader);
			
		//	editingMsgID = -1;
			
			if (list != null) {
				list.activate();
			} else {
				return;
			}
			
			if (ChatManager.getCurrentChat() && ChatManager.getCurrentChat().locked) {
				showLockButton();
			}
			
			
			chatTop.activate()
			chatTop.setCallCallback(ChatManager.callToChatUser);
			chatTop.setStartStreamCallback(startStream);
			
			list.S_ITEM_TAP.add(onItemTap);
			list.S_ITEM_SWIPE.add(onItemSwipe);
			list.S_ITEM_HOLD.add(onItemHold);
			list.S_ITEM_DOUBLE_CLICK.add(onItemDoubleClick);
			list.S_MOVING.add(onListMove);
			list.S_UP.add(onListTouchUp);
			
			if (chatInput)
				chatInput.setCallBack(onChatSend);
			
			setChatListSize();
			
			if (chatData.chatVO && chatData.chatVO.settings && chatData.chatVO.settings.backgroundURL && needLoadBackground)
			{
				loadChatBackground(chatData.chatVO.settings.backgroundURL);
			}
			else if (ChatManager.getCurrentChat() != null && ChatManager.getCurrentChat().settings != null && 
					ChatManager.getCurrentChat().settings.backgroundURL != null && needLoadBackground)
			{
				updateChatBackground();
			}
			else if (animateBackgroundShow && backgroundImage)
			{
				animateBackgroundShow = false;
				TweenMax.to(backgroundImage, 0.5, {alpha:1});
			}
			
			//WSClient.S_CHAT_USER_ENTER.add(onUserEnterChat);
			WSClient.S_MSG_ADD_ERROR.add(onErrorSendMessage);
			onNetworkChanged();
			updateChatInput();
			
			UsersManager.S_USERS_FULL_DATA.add(onUserInfoUpdated);
		}
		
		public function onItemSwipe(item:ListItem):void 
		{
			addReplyPanel(item.data as ChatMessageVO);
		}
		
		private function addReplyPanel(chatMessageVO:ChatMessageVO):void 
		{
			if (replyPanel == null)
			{
				replyPanel = new ReplyMessagePanel(onReplyPanelRemove, replayMessageSelect, onReplayResize);
				replyPanel.setPosition(chatInput.getView().y);
				if (replyPanel.draw(chatMessageVO, _width))
				{
					view.addChild(replyPanel);
					NativeExtensionController.vibrate();
				}
				else
				{
					replyPanel.dispose();
					replyPanel = null;
				}
			//	replyPanel.y = chatInput.getView().y - replyPanel.height;
				
			}
			else
			{
				replyPanel.draw(chatMessageVO, _width, false);
				onReplayResize();
			}
		}
		
		private function onReplayResize():void 
		{
			if (isDisposed == false && list != null)
			{
				setChatListSize();
			}
		}
		
		private function replayMessageSelect(message:ChatMessageVO):void 
		{
			if (message != null && isDisposed == false && list != null && list.data != null && list.data is Array)
			{
				var index:int = (list.data as Array).indexOf(message);
				if (index != -1)
				{
					list.scrollToIndex(index, Config.FINGER_SIZE * 2, 0, true);
				}
			}
		}
		
		private function onReplyPanelRemove():void 
		{
			if (isDisposed || replyPanel == null)
			{
				return;
			}
			replyPanel.dispose();
			if (view.contains(replyPanel))
			{
				view.removeChild(replyPanel);
			}
			replyPanel = null;
		}
		
		private function startStream():void {
			if (streamContainer == null) {
				streamContainer = new Sprite();
				view.addChild(streamContainer);
				stream = new VideoStreaming(streamContainer, new Rectangle(0, 0, _width, chatInput.getView().y), onStreamEnd, list.view, ChatManager.getCurrentChat().uid);
				chatTop.hide();
				if (backgroundImage != null)
					backgroundImage.visible = false;
				TweenMax.to(backColorClip, 0.5, {alpha:0, delay:2});
				setChatListSize();
			}
		}
		
		private function onStreamEnd():void {
			list.setAlphaFading(false);
			view.removeChild(streamContainer);
			streamContainer = null;
			stream.close();
			stream = null;
			list.view.y = chatTop.view.y + chatTop.height;
			if (backgroundImage != null)
				backgroundImage.visible = true;
			list.view.alpha = 1;
			chatTop.show();
			setChatListSize();
			drawView();
		}
		
		private function onUserInfoUpdated():void {
			if (isDisposed == false && list != null)
				list.refresh(false);
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
					loadHistoricalMessages();
				}
			} else {
				if (historyLoadingScroller != null)
					historyLoadingScroller.hide();
			}
			if (questionPanel != null) {
				questionPanel.collapse();
			}
		}
		
		private function loadHistoricalMessages():void
		{
			ChatManager.loadChatHistorycalMessages();
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
			else if (errorCode == ErrorCode.NO_FREE_SLOTS_IN_QUESTION)
				ToastMessage.display(Lang.questionToManyAnswers);
			else if (errorCode == ErrorCode.QUESTION_CLOSED)
				ToastMessage.display(Lang.questionAlreadyClosed);
			else if (errorCode == ErrorCode.NO_RIGHTS_SEND_IN_CHANNEL)
				ToastMessage.display(Lang.cantWriteInChat);
			else if (errorCode == ErrorCode.NO_RIGHTS_SEND_IN_CHANNEL_BLOCKED)
				ToastMessage.display(Lang.cantWriteInChat);
			else if (errorCode == ErrorCode.YOU_BANNED)
				ToastMessage.display(Lang.youWereBanned);
		}
		
		/*private function onUserEnterChat(data:Object):void {
			echo("ChatScreen", "onUserEnterChat", "");
			if (data && data.userUid != Auth.uid) {
				if (ChatManager.currentChat!=null && data.chatUID == ChatManager.currentChat.uid) {
					if (list) {
						echo("ChatScreen", "onUserEnterChat", data);
					}
				}
			}
		}*/
		
		private function onItemHold(data:Object, n:int):void {
			echo("ChatScreen", "onItemHold", "");
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
			
			/*var currentChat:ChatVO = ChatManager.getCurrentChat();
			if (isMine == false && currentChat != null && currentChat.type == ChatRoomType.CHANNEL && (currentChat.questionID == null || currentChat.questionID == "")){
				selectedItem = list.getItemByNum(n);
				var lhz:Object;
				var hzs:Array = selectedItem.getHitZones();
				if (hzs != null) {
					var touchPoint:Point = new Point(selectedItem.liView.mouseX, selectedItem.liView.mouseY);
					for (var j2:int = 0; j2 < hzs.length; j2++) {
						lhz = hzs[j2];
						if (touchPoint.x >= lhz.x && 
							touchPoint.x <= lhz.x + lhz.width && 
							touchPoint.y >= lhz.y && 
							touchPoint.y <= lhz.y + lhz.height) {
								if (lhz.type == HitZoneType.AVATAR){
									var screenData:Object = new Object();
									var tapZone:HitZoneData = new HitZoneData();
									screenData.hitzone = tapZone;
									var globalPoint:Point = selectedItem.liView.parent.localToGlobal(new Point(selectedItem.liView.x, selectedItem.liView.y));
									tapZone.x = globalPoint.x + lhz.x + lhz.width * .5 - Config.FINGER_SIZE * .33;
									tapZone.y = globalPoint.y + lhz.y + lhz.height * .5 - Config.FINGER_SIZE * .33;
									tapZone.width = Config.FINGER_SIZE * .33;
									tapZone.height = Config.FINGER_SIZE * .33;
									tapZone.type = HitZoneType.AVATAR;
									
									var actions:Vector.<IScreenAction> = new Vector.<IScreenAction>();
									var actionBanUser:BanUserInChannelAction = new BanUserInChannelAction(null, null);
									var actionMakeModerator:MakeModeratorInChannelAction = new MakeModeratorInChannelAction(null, null);
									actions.push(actionBanUser);
									actions.push(actionMakeModerator);
									screenData.actions = actions;
									ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, ContextMenuScreen, {backScreen:MobileGui.centerScreen.currentScreen, backScreenData:MobileGui.centerScreen.currentScreen.data, data:screenData}, 0, 0);
									return;
								}
								break;
						}
					}
				}
			}*/
			
			var messageType:String = msgVO.typeEnum;
			if (messageType == ChatMessageType.REPLY)
			{
				messageType = ChatMessageType.TEXT;
			}
			
			if (messageType == ChatMessageType.TEXT && msgVO.text == "")
				return;
			var isMine:Boolean = (msgVO.userUID == Auth.uid);
			var editable:Boolean = (msgVO.created * 1000 > new Date().getTime() - 1800000);
			var menuItems:Array = new Array();
			
			if (messageType == ChatSystemMsgVO.TYPE_ESCROW_OFFER)
			{
				if (!Config.isTest())
					menuItems.push( { fullLink:Lang.escrow_copy_transaction, id:ChatItemContextMenuItemType.COPY } );
				if (Config.isTest())
				{
					var escrowStatus:EscrowStatus = msgVO.systemMessageVO.escrow.status;
					if (escrowStatus == EscrowStatus.offer_accepted || 
						escrowStatus == EscrowStatus.offer_cancelled ||
						escrowStatus == EscrowStatus.offer_created ||
						escrowStatus == EscrowStatus.offer_expired ||
						escrowStatus == EscrowStatus.offer_rejected)
					{
						menuItems.push( { fullLink:"offer ACCEPT", id:ChatItemContextMenuItemType.OFFER_ACCEPT } );
						menuItems.push( { fullLink:"offer ACCEPT 2 раза", id:ChatItemContextMenuItemType.OFFER_ACCEPT_2 } );
						menuItems.push( { fullLink:"offer REJECT", id:ChatItemContextMenuItemType.OFFER_REJECT } );
						menuItems.push( { fullLink:"offer REJECT 2 раза", id:ChatItemContextMenuItemType.OFFER_REJECT_2 } );
						menuItems.push( { fullLink:"offer CANCEL", id:ChatItemContextMenuItemType.OFFER_CANCEL } );
						menuItems.push( { fullLink:"offer CANCEL 2 раза", id:ChatItemContextMenuItemType.OFFER_CANCEL_2 } );
					}
					else if (escrowStatus == EscrowStatus.deal_claimed ||
							escrowStatus == EscrowStatus.deal_completed ||
							escrowStatus == EscrowStatus.deal_created ||
							escrowStatus == EscrowStatus.deal_crypto_send_fail ||
							escrowStatus == EscrowStatus.deal_mca_hold_fail ||
							escrowStatus == EscrowStatus.deal_crypto_send_wait_investigation ||
							escrowStatus == EscrowStatus.deal_mca_hold ||
							escrowStatus == EscrowStatus.paid_crypto)
					{
						menuItems.push( { fullLink:"set money hold status", id:ChatItemContextMenuItemType.DEAL_MONEY_HOLD } );
						menuItems.push( { fullLink:"send crypto id", id:ChatItemContextMenuItemType.DEAL_SEND_ID } );
						menuItems.push( { fullLink:"accept crypto", id:ChatItemContextMenuItemType.DEAL_ACCEPT_CRYPTO } );
						menuItems.push( { fullLink:"claim", id:ChatItemContextMenuItemType.DEAL_CLAIM } );
						menuItems.push( { fullLink:"set hold money fail", id:ChatItemContextMenuItemType.DEAL_FAIL_HOLD } );
					}
				}
			}
			else{
				
				
				//pending massages
				if (msgVO.id < 0) {
					if (messageType == ChatMessageType.TEXT && isMine) {
						menuItems.push( { fullLink:Lang.textCopy, id:ChatItemContextMenuItemType.COPY } );
						menuItems.push( { fullLink:Lang.resendMessage, id:ChatItemContextMenuItemType.RESEND } );
					}
					else if (messageType == ChatMessageType.FILE && isMine) {
						if (msgVO.systemMessageVO != null && msgVO.systemMessageVO.fileType == ChatSystemMsgVO.FILETYPE_VIDEO) {
							menuItems.push( { fullLink:Lang.textRemove, id:ChatItemContextMenuItemType.REMOVE } );
						}
					}
				} else {
					if (messageType == ChatMessageType.TEXT) {
						
						menuItems.push( { fullLink:Lang.reply, id:ChatItemContextMenuItemType.REPLY } );
						
						if (msgVO.linksArray == null || (msgVO.linksArray.length > 0 && canOpenLink(msgVO)))
						{
							menuItems.push( { fullLink:Lang.textCopy, id:ChatItemContextMenuItemType.COPY } );
						}
						
						if (isMine && editable)
							menuItems.push( { fullLink:Lang.textEdit, id:ChatItemContextMenuItemType.EDIT } );
					}
					else if (msgVO.typeEnum == ChatMessageType.FORWARDED)
					{
						menuItems.push( { fullLink:Lang.textCopy, id:ChatItemContextMenuItemType.COPY } );
					}

					if (messageType == ChatSystemMsgVO.TYPE_CHAT_SYSTEM) {
						menuItems.push( { fullLink:Lang.textCopy, id:ChatItemContextMenuItemType.COPY } );
					}
					
					var removeExist:Boolean = false;
					
					if (isMine) {
						if (Config.ADMIN_UIDS.indexOf(Auth.uid) != -1)
						{
							removeExist = true;
							menuItems.push( { fullLink:Lang.textRemove, id:ChatItemContextMenuItemType.REMOVE } );
						}
						else if (editable && messageType != ChatSystemMsgVO.TYPE_CHAT_SYSTEM) {
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
					
					if (messageType == ChatMessageType.INVOICE || 
						messageType == ChatMessageType.TEXT || 
						messageType == ChatMessageType.STICKER || 
						
						(messageType == ChatSystemMsgVO.TYPE_FILE && 
						msgVO.systemMessageVO != null && 
						(msgVO.systemMessageVO.fileType == ChatSystemMsgVO.FILETYPE_IMG || msgVO.systemMessageVO.fileType == ChatSystemMsgVO.FILETYPE_IMG_CRYPTED)))
					{
						menuItems.push({fullLink:Lang.forwardMessage, id:ChatItemContextMenuItemType.FORWARD});
					}
				}
				if (messageType != ChatSystemMsgVO.TYPE_FILE)
				{
					if (msgVO.renderInfo == null || msgVO.renderInfo.renderInforenderBigFont == false)
					{
						menuItems.push({fullLink:Lang.enlargeText, id:ChatItemContextMenuItemType.ENLARGE});
					}
					else
					{
						menuItems.push({fullLink:Lang.reduceText, id:ChatItemContextMenuItemType.MINIMIZE});
					}
				}
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
					case ChatItemContextMenuItemType.REPLY:
					{
						action = new ReplyMessageAction(msgVO, addReplyPanel);
						break;
					}
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
					
					case ChatItemContextMenuItemType.OFFER_ACCEPT:
					{
						action = new SendEscrowTestAction(msgVO.systemMessageVO.escrow, ChatItemContextMenuItemType.OFFER_ACCEPT, msgVO.id, menuItems[i].fullLink);
						break;
					}
					case ChatItemContextMenuItemType.OFFER_ACCEPT_2:
					{
						action = new SendEscrowTestAction(msgVO.systemMessageVO.escrow, ChatItemContextMenuItemType.OFFER_ACCEPT_2, msgVO.id, menuItems[i].fullLink);
						break;
					}
					case ChatItemContextMenuItemType.OFFER_CANCEL:
					{
						action = new SendEscrowTestAction(msgVO.systemMessageVO.escrow, ChatItemContextMenuItemType.OFFER_CANCEL, msgVO.id, menuItems[i].fullLink);
						break;
					}
					case ChatItemContextMenuItemType.OFFER_CANCEL_2:
					{
						action = new SendEscrowTestAction(msgVO.systemMessageVO.escrow, ChatItemContextMenuItemType.OFFER_CANCEL_2, msgVO.id, menuItems[i].fullLink);
						break;
					}
					case ChatItemContextMenuItemType.OFFER_REJECT:
					{
						action = new SendEscrowTestAction(msgVO.systemMessageVO.escrow, ChatItemContextMenuItemType.OFFER_REJECT, msgVO.id, menuItems[i].fullLink);
						break;
					}
					case ChatItemContextMenuItemType.OFFER_REJECT_2:
					{
						action = new SendEscrowTestAction(msgVO.systemMessageVO.escrow, ChatItemContextMenuItemType.OFFER_REJECT_2, msgVO.id, menuItems[i].fullLink);
						break;
					}
					case ChatItemContextMenuItemType.DEAL_ACCEPT_CRYPTO:
					{
						action = new SendEscrowTestAction(msgVO.systemMessageVO.escrow, ChatItemContextMenuItemType.DEAL_ACCEPT_CRYPTO, msgVO.id, menuItems[i].fullLink);
						break;
					}
					case ChatItemContextMenuItemType.DEAL_CLAIM:
					{
						action = new SendEscrowTestAction(msgVO.systemMessageVO.escrow, ChatItemContextMenuItemType.DEAL_CLAIM, msgVO.id, menuItems[i].fullLink);
						break;
					}
					case ChatItemContextMenuItemType.DEAL_SEND_ID:
					{
						action = new SendEscrowTestAction(msgVO.systemMessageVO.escrow, ChatItemContextMenuItemType.DEAL_SEND_ID, msgVO.id, menuItems[i].fullLink);
						break;
					}
					case ChatItemContextMenuItemType.DEAL_MONEY_HOLD:
					{
						action = new SendEscrowTestAction(msgVO.systemMessageVO.escrow, ChatItemContextMenuItemType.DEAL_MONEY_HOLD, msgVO.id, menuItems[i].fullLink);
						break;
					}
					case ChatItemContextMenuItemType.DEAL_FAIL_HOLD:
					{
						action = new SendEscrowTestAction(msgVO.systemMessageVO.escrow, ChatItemContextMenuItemType.DEAL_FAIL_HOLD, msgVO.id, menuItems[i].fullLink);
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
			if (lockButton)
				lockButton.deactivate();
			list.deactivate();
			if (uploadFilePanel != null)
			{
				uploadFilePanel.deactivate();
			}
			
			if (Config.PLATFORM_APPLE) {
				chatInput.hide();
			} else {
				if (chatInput != null) {
					chatInput.setCallBack(null);
					chatInput.deactivate();
					chatInput.hide();
				}
			}
			if (scrollBottomButton != null) {
				scrollBottomButton.deactivate();
			}
			if (noConnectionIndicator != null) {
				PointerManager.removeTap(noConnectionIndicator, tryReconnect);
			}
			if (questionPanel != null) {
				questionPanel.deactivate();
			}
			if (satisfyPublicAnswerButton != null) {
				satisfyPublicAnswerButton.deactivate();
			}
			if (reportButton != null) {
				reportButton.deactivate();
			}
			if (questionLinkButton)
				questionLinkButton.deactivate();			
			if (basketButton)
				basketButton.deactivate();			
			if (answersCountButton)
				answersCountButton.deactivate();
			if (verificationButton != null)
				verificationButton.deactivate();
			chatTop.deactivate();
			list.S_ITEM_TAP.remove(onItemTap);
			list.S_ITEM_SWIPE.remove(onItemSwipe);
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
			UsersManager.S_USERS_FULL_DATA.remove(onUserInfoUpdated);
		}
		
		private function onListMove(position:Number):void {
			if (position > 0) {
				if (!historyLoadingState) {
					var positionScroller:int = Config.FINGER_SIZE * .85 + Config.APPLE_TOP_OFFSET + position - Config.FINGER_SIZE;
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
						if (loaderSize % 2 == 1)
							loaderSize ++;
						historyLoadingScroller = new Preloader(loaderSize, ListLoaderShape);
						_view.addChild(historyLoadingScroller);
						if (chatTop != null && chatTop.view != null && _view.contains(chatTop.view)) {
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
			if (-position < list.itemsHeight - list.height - Config.FINGER_SIZE * 2) {
				scrollBottomButton.add();
				if (_isActivated) {
					scrollBottomButton.activate();
				}
				scrollBottomButton.x = int(_width - scrollBottomButton.width - Config.DIALOG_MARGIN * 0.7);
				if (unreadedMessages > 0) {
					if (list != null && list.data != null) {
						var firstVisibleIndex:int = list.getFirstVisibleItemIndex();
						if (list.data is Array && (list.data as Array).length > firstVisibleIndex) {
							var l:int = (list.data as Array).length;
							var unreadedUpdated:int = 0;
							for (var i:int = firstVisibleIndex; i < l; i++) {
								if (list.getItemByNum(i).y > -position + list.height - Config.FINGER_SIZE * .5 && (list.data as Array)[i] is ChatMessageVO && ((list.data as Array)[i] as ChatMessageVO).userUID != Auth.uid) {
									unreadedUpdated ++;
								}
							}
							if (unreadedMessages != unreadedUpdated && unreadedUpdated < unreadedMessages) {
								unreadedMessages = unreadedUpdated;
								if (scrollBottomButton != null) {
									scrollBottomButton.setUnreded(unreadedMessages);
								}
							}

						}
					}
				}
			} else {
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
		
		private function onPinChange(pinExists:Boolean):void {
			echo("ChatScreen", "onPinChange", "");
			if (list != null)
				list.refresh(true);
		}
		
		private function onItemDoubleClick(data:Object, n:int):void {
			if (!(data is ChatMessageVO)) {
				return;
			}
			var cmsgVO:ChatMessageVO = data as ChatMessageVO;
			if (cmsgVO != null) {
				if (cmsgVO.renderInfo == null) {
					cmsgVO.renderInfo = new ListRenderInfo();
				}
				cmsgVO.renderInfo.renderInforenderBigFont = !cmsgVO.renderInfo.renderInforenderBigFont;
			}
			list.updateItemByIndex(n);
		}
		
		private function onItemTap(data:Object, n:int):void {
			echo("ChatScreen", "onItemTap", "");
			if (questionPanel != null) {
				questionPanel.collapse();
			}
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
			if (ChatManager.getCurrentChat() != null &&
				ChatManager.getCurrentChat().type == ChatRoomType.PRIVATE &&
				ChatManager.getCurrentChat().ownerUID == Config.DUKASCOPY_INFO_SERVICE_UID) {
					if (cmsgVO.userUID == Config.DUKASCOPY_INFO_SERVICE_UID) {
						MobileGui.openMyAccountIfExist();
						return;
					}
			}
			if (cmsgVO.userUID != Auth.uid &&
				cmsgVO.systemMessageVO != null &&
				cmsgVO.systemMessageVO.method == ChatSystemMsgVO.METHOD_MONEY_TRANSFER) {
					MobileGui.openMyAccountIfExist();
					return;
			}
			var displayingMessage:ChatMessageVO = cmsgVO;
			if (cmsgVO.typeEnum == ChatMessageType.FORWARDED) {
				displayingMessage = cmsgVO.systemMessageVO.forwardVO;
			}
			if (cmsgVO.action) {
				if (cmsgVO.action is CallGetEuroAction) {
					QuestionsManager.showRules();
					return;
				}
				showInfo();
				return;
			}
			/*if (cmsgVO.typeEnum == ChatSystemMsgVO.TYPE_COMPLAIN) {
				showInfo();
				return;
			}*/
			var selectedItem:ListItem = list.getItemByNum(n);
			var lastHitzoneObject:Object =  selectedItem.getLastHitZoneObject();
			var lhz:String = lastHitzoneObject!=null?lastHitzoneObject.type:null;// selectedItem.getLastHitZone();
			var overlayTouch:HitZoneData;
			if (cmsgVO.systemMessage) {
				if (lhz) {
					if (lhz.indexOf(HitZoneType.SYSTEM_MESSAGE_INDEX_) != -1) {
						if (lhz == HitZoneType.SYSTEM_MESSAGE_INDEX_ + "avatar") {
							lhz = HitZoneType.AVATAR;
						} else {
							var arr:Array = lhz.split(HitZoneType.SYSTEM_MESSAGE_INDEX_);
							if (arr && arr.length == 2) {
								var actionIndex:int = arr[1];
								if (cmsgVO.systemMessage.buttons && cmsgVO.systemMessage.buttons.length > actionIndex && 
									cmsgVO.systemMessage.buttons[actionIndex] && cmsgVO.systemMessage.buttons[actionIndex].action) {
										if (cmsgVO.systemMessage.buttons[actionIndex].action is BlockUserAction ||
											cmsgVO.systemMessage.buttons[actionIndex].action is AddUserToContactsAction) {
												preloader ||= new Preloader();
												preloader.x = _width * .5;
												preloader.y = _height * .5;
												view.addChild(preloader);
												preloader.show();
										}
										overlayTouch = new HitZoneData();
										var point:Point = new Point(view.mouseX, view.mouseY);
										point = view.localToGlobal(point);
										overlayTouch.touchPoint = point;
										overlayTouch.type = HitZoneType.MENU_SIMPLE_ELEMENT;
										var hzStart:Point = new Point(lastHitzoneObject.x, lastHitzoneObject.y);
										hzStart = list.view.localToGlobal(hzStart);
										overlayTouch.x = hzStart.x - Config.FINGER_SIZE * .15;
										overlayTouch.y = hzStart.y - Config.FINGER_SIZE * .15;
										overlayTouch.width = lastHitzoneObject.width + Config.FINGER_SIZE * .3;
										overlayTouch.height = lastHitzoneObject.height + Config.FINGER_SIZE * .3;
										overlayTouch.radius = overlayTouch.height * .5;
										overlayTouch.color = 0xFFFFFF;
										overlayTouch.alpha = 0.15;
										cmsgVO.systemMessage.buttons[actionIndex].action.execute();
								}
							}
						}
					}
				}
			}
			if (lhz == HitZoneType.REPLY_MESSAGE && cmsgVO.systemMessageVO != null && cmsgVO.systemMessageVO.replayMessage != null && cmsgVO.systemMessageVO.replayMessage.target != -1) {
				if (list != null)
				{
					list.scrollToItem("num", cmsgVO.systemMessageVO.replayMessage.target, Config.FINGER_SIZE, true);
					list.blinkItem("num", cmsgVO.systemMessageVO.replayMessage.target);
				}
			}
			if (lhz == HitZoneType.BOT_MENU_ACTION) {
				var botAction:String = lastHitzoneObject.action;
				//!TODO:;
				/*if (needToRateBot == true) {
					needToRateBot = false;
					rateBot = null;
					PHP.call_statVI("SPR_" + lastHitzoneObject.statAction, ChatManager.getCurrentChat().uid);
				}*/
				if (botAction != null) {
					if (cmsgVO.isMenuPressed == false) {
						var readableText:String = lastHitzoneObject.text != null ? lastHitzoneObject.text : "";					 
						ChatManager.sendBotActionMessage(botAction, readableText, null, ChatManager.getCurrentChat().uid, cmsgVO.userUID);
						cmsgVO.isMenuPressed = true;
						cmsgVO.selectedMenuIndex = lastHitzoneObject.index;
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
				if (cmsgVO.paranoic && cmsgVO.crypted) {
					chatTop.onLockButtonTap();
				} else if (cmsgVO.systemMessageVO != null && cmsgVO.systemMessageVO.fileType == ChatSystemMsgVO.FILETYPE_VIDEO) {
					NativeExtensionController.showVideo(cmsgVO.systemMessageVO.videoVO, getTitleValue());
				} else if (cmsgVO.systemMessageVO != null && cmsgVO.systemMessageVO.fileType == ChatSystemMsgVO.FILETYPE_GENERAL) {
					downloadFile(cmsgVO.systemMessageVO);
				} else if (cmsgVO.systemMessageVO != null && cmsgVO.systemMessageVO.type == ChatSystemMsgVO.TYPE_ESCROW_OFFER) {
					
					EscrowScreenNavigation.showScreen(cmsgVO.systemMessageVO.escrow, cmsgVO.created, UsersManager.getInterlocutor(ChatManager.getCurrentChat()).userVO, ChatManager.getCurrentChat(), cmsgVO.id);
				}
				else if (cmsgVO.systemMessageVO != null && cmsgVO.systemMessageVO.fileType == ChatSystemMsgVO.FILETYPE_PUZZLE_CRYPTED && cmsgVO.systemMessageVO.puzzleVO != null) {
					var url:String = cmsgVO.imageURLWithKey;
					var isMine:Boolean = (cmsgVO.userUID == Auth.uid);					
					LightBox.disposeVOs();						
					if(cmsgVO.systemMessageVO.puzzleVO.isPaid == true || isMine==true ) {	
						var actions:Vector.<IScreenAction> = new Vector.<IScreenAction>();			
						
						var editable:Boolean = (cmsgVO.created * 1000 > new Date().getTime() - 1800000);
						if (isMine == true && editable == true)	{
							var removeImageAction:RemoveImageAction = new RemoveImageAction(cmsgVO);
							removeImageAction.setData(ImageContextMenuType.REMOVE_MESSAGE)
							actions.push(removeImageAction);
						}

						LightBox.add(cmsgVO.imageURLWithKey, true, null, null, null, cmsgVO.imageThumbURLWithKey, actions);
						LightBox.show(cmsgVO.imageURLWithKey, getTitleValue(), true);
						deactivateScreen();
					} else {
						/** Pay Puzzle By UID **/
						var puzzleInvoice:PayTaskVO = new PayTaskVO(PayTaskVO.TASK_TYPE_PAY_PUZZLE_BY_UID);
							puzzleInvoice.customDialogTitle = Lang.buyImageDialogTitle;// "Processing locked image";
							puzzleInvoice.amount      =   displayingMessage.systemMessageVO.puzzleVO.amount;
							puzzleInvoice.currency    =  displayingMessage.systemMessageVO.puzzleVO.currency;
							puzzleInvoice.messageText = Lang.puzzleImage + " pzl:"+displayingMessage.id;			
							puzzleInvoice.from_uid    = Auth.uid;
							puzzleInvoice.handleInCustomScreenName = "";				
							puzzleInvoice.to_uid 	    = displayingMessage.userUID;		
							puzzleInvoice.messageVO   = displayingMessage;				
							Puzzle.openPuzzle();					
							Puzzle.add(puzzleInvoice, displayingMessage.imageURLWithKey, true,getTitleValue(), null, null, displayingMessage.imageThumbURLWithKey, null);
							deactivateScreen();
					}
				} else if (cmsgVO.systemMessageVO != null && cmsgVO.systemMessageVO.imageURL != null) {
					LightBox.disposeVOs();
					
					var actions2:Vector.<IScreenAction> = new Vector.<IScreenAction>();
					
					var isMine2:Boolean = (cmsgVO.userUID == Auth.uid);
					var editable2:Boolean = (cmsgVO.created * 1000 > new Date().getTime() - 1800000);
					if (isMine2 == true && editable2 == true) {
						var removeImageAction2:RemoveImageAction = new RemoveImageAction(cmsgVO);
						removeImageAction2.setData(ImageContextMenuType.REMOVE_MESSAGE)
						actions2.push(removeImageAction2);
					}
					
					var chatImages:Vector.<ChatMessageVO> = getChatImages();
					var l:int = chatImages.length;
					for (var i:int = 0; i < l; i++)
					{
						LightBox.add(chatImages[i].imageURLWithKey, true, null, null, null, chatImages[i].imageThumbURLWithKey, actions2);
					}
					if (ChatManager.getCurrentChat().messages != null && ChatManager.getCurrentChat().messages.length > 0 && ChatManager.getCurrentChat().messages[0].num > 1)
					{
						LightBox.allowPrewButton();
					}

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
				} else if (cmsgVO.systemMessageVO != null && 
							cmsgVO.systemMessageVO.method == ChatSystemMsgVO.METHOD_NEWS && 
							cmsgVO.systemMessageVO.newsVO != null)
				{
					if (cmsgVO.systemMessageVO.newsVO.original != null) {
						if (cmsgVO.systemMessageVO.newsVO.link != null && cmsgVO.systemMessageVO.newsVO.link != "") {
							LightBox.showLink(cmsgVO.systemMessageVO.newsVO.link, Lang.openInInstagram);
						}
						
						LightBox.add(cmsgVO.systemMessageVO.newsVO.original, false, null, null, null, cmsgVO.systemMessageVO.newsVO.image, null);
						LightBox.show(cmsgVO.systemMessageVO.newsVO.original, cmsgVO.systemMessageVO.newsVO.title, true);
					}
					else {
						openLink(cmsgVO.systemMessageVO.newsVO.link);
					}
				}
			} else if (lhz == HitZoneType.CALL) {
				ChatManager.callToChatUser();
			} else if (lhz == HitZoneType.AVATAR) {
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
			} else if (lhz == HitZoneType.SHOW_GIFT_INFO) {
				updateItemTime = false;
				if (cmsgVO.systemMessageVO != null && cmsgVO.systemMessageVO.giftVO != null) {
					if (cmsgVO.userUID == Auth.uid) {
						Gifts.showGiftInfo(cmsgVO.systemMessageVO.giftVO);
					} else {
						MobileGui.openMyAccountIfExist();
						//MobileGui.changeMainScreen(PaymentsScreen, null, ScreenManager.DIRECTION_LEFT_RIGHT);
					}
				}
				return;
			} else if (lhz == HitZoneType.PLAY_SOUND) {
				updateItemTime = false;
				playSound(cmsgVO);
			} else if (lhz == HitZoneType.SWITCH_SOUND_SPEAKER) {
				updateItemTime = false;
				switchSoundOnCurrentAudio(cmsgVO);
			} else if (lhz == HitZoneType.CHAT_FILE) {
			} else if (lhz == HitZoneType.INVOICE_CANCELLED) {
				updateItemTime = false;
				displayingMessage.systemMessageVO.invoiceVO.status = InvoiceStatus.CANCELLED;
				ChatManager.updateInvoce(Config.BOUNDS + JSON.stringify(displayingMessage.systemMessageVO.invoiceVO.getData()), displayingMessage.id);
			} else if (lhz == HitZoneType.INVOICE_REJECT) {
				updateItemTime = false;
				displayingMessage.systemMessageVO.invoiceVO.status = InvoiceStatus.REJECTED;
				ChatManager.updateInvoce(Config.BOUNDS + JSON.stringify(displayingMessage.systemMessageVO.invoiceVO.getData()), displayingMessage.id);
			} else if (lhz == HitZoneType.INVOICE_RETRY || lhz == HitZoneType.INVOICE_ACCEPT) {
				updateItemTime = false;
				if (displayingMessage.userUID != Auth.uid)
				{
					if (PayAPIManager.hasSwissAccount == true)
					{
						var invoice:PayTaskVO = new PayTaskVO(PayTaskVO.TASK_TYPE_PAY_INVOICE_BY_UID);
						invoice.amount      = displayingMessage.systemMessageVO.invoiceVO.amount;
						invoice.currency    = displayingMessage.systemMessageVO.invoiceVO.currency;
						invoice.messageText = displayingMessage.systemMessageVO.invoiceVO.message;				
						invoice.from_uid    = Auth.uid;
						invoice.handleInCustomScreenName = "";
						invoice.to_uid 	    = displayingMessage.systemMessageVO.invoiceVO.fromUserUID;	
						if (invoice.to_uid == null || invoice.to_uid == ""){
							invoice.to_uid = displayingMessage.userUID;
						}
						invoice.destinationUserName = displayingMessage.systemMessageVO.invoiceVO.fromUserName;				
						invoice.messageVO   = displayingMessage;
						invoice.showNoAccountAlert = false;
						invoice.allowCardPayment = true;
						InvoiceManager.preProcessInvoce(invoice);
					}
					else
					{
						if (payByCardAction == null)
						{
							showPreloader();
							payByCardAction = new PayByCardAction(
																		displayingMessage.systemMessageVO.invoiceVO.fromUserUID, 
																		displayingMessage.systemMessageVO.invoiceVO.currency, 
																		displayingMessage.systemMessageVO.invoiceVO.amount,
																		displayingMessage, displayingMessage.systemMessageVO.invoiceVO.message, PayAPIManager.hasSwissAccount);
							payByCardAction.getSuccessSignal().add(onPayActionSuccess);
							payByCardAction.getFailSignal().add(onPayActionFail);
							payByCardAction.execute();
						}
					}
				}
			} else if (lhz == HitZoneType.CANCEL) {
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
			} else if (lhz == HitZoneType.ADD_REACTION_LIKE) {
				list.getItemByNum(n).drawnHeight = -1;
				updateItemTime = false;
				if (cmsgVO.userUID != Auth.uid) {
					ChatManager.addMessageReaction(cmsgVO, Auth.uid, ChatMessageReactionType.LIKE);
				}
			} else if (lhz == HitZoneType.REMOVE_REACTION_LIKE) {
				list.getItemByNum(n).drawnHeight = -1;
				updateItemTime = false;
				if (cmsgVO.userUID != Auth.uid) {
					ChatManager.removeMessageReaction(cmsgVO, Auth.uid, ChatMessageReactionType.LIKE);
				}
			} else if (lhz == HitZoneType.SHOW_REACTIONS) {
				selectedItem.drawTime = !selectedItem.drawTime;
				
				if (ChatManager.getCurrentChat() != null && 
					ChatManager.getCurrentChat().getQuestion() != null)
				{
					ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_DIALOG, ScreenQuestionReactionsDialog, { label:Lang.topLikes, qUID:ChatManager.getCurrentChat().questionID, chatUID:ChatManager.getCurrentChat().uid });
				}
			} else if (lhz == HitZoneType.OPEN_NEWS) {
				if (cmsgVO.systemMessageVO != null && cmsgVO.systemMessageVO.newsVO != null && cmsgVO.systemMessageVO.newsVO.link != null){
					navigateToURL(new URLRequest(cmsgVO.systemMessageVO.newsVO.link));
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
		
		private function onPayActionFail():void 
		{
			hidePreloader();
			removePayAction();
		}
		
		private function removePayAction():void 
		{
			if (payByCardAction != null)
			{
				if (payByCardAction.getSuccessSignal())
				{
					payByCardAction.getSuccessSignal().remove(onPayActionSuccess);
				}
				if (payByCardAction.getFailSignal())
				{
					payByCardAction.getFailSignal().remove(onPayActionFail);
				}
				payByCardAction.dispose();
				payByCardAction = null;
			}
		}
		
		private function onPayActionSuccess():void 
		{
			hidePreloader();
			removePayAction();
		}
		
		private function getChatImages():Vector.<ChatMessageVO>
		{
			/*if (cachedChatImages != null)
			{
				return cachedChatImages;
			}*/
			var result:Vector.<ChatMessageVO> = new Vector.<ChatMessageVO>();
			if (ChatManager.getCurrentChat() != null)
			{
				var messages:Vector.<ChatMessageVO> = ChatManager.getCurrentChat().messages;
				if (messages != null)
				{
					var l:int = messages.length;
					for (var i:int = 0; i < l; i++)
					{
						if (messages[i].systemMessageVO != null && (messages[i].systemMessageVO.fileType == ChatSystemMsgVO.FILETYPE_IMG || messages[i].systemMessageVO.fileType == ChatSystemMsgVO.FILETYPE_IMG_CRYPTED))
						{
							result.push(messages[i]);
						}
					}
				}
				cachedChatImages = result;
			}
			return result;
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
			var chat:ChatVO = ChatManager.getCurrentChat();
			
			if (chat != null && chat.type == ChatRoomType.CHANNEL && chat.questionID != null && chat.questionID != "")
			{
				var allowOpenLink:Boolean = false;
				var user:UserVO = UsersManager.getUserByMessageObject(cmsgVO);
				if (user != null && ((Config.ADMIN_UIDS != null && Config.ADMIN_UIDS.indexOf(user.uid) != -1) || (user.payRating > 4)))
				{
					allowOpenLink = true;
				}
				return allowOpenLink;
			}
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
			if (LightBox.isShowing) // Beacuse we use same handler on PuzzleClose
				return;
			super.onSwipe(d);
		}
		
		private function updateChatInput():void {
			var showFakeInput:Boolean = checkWritingAvaliablity();
			
			if (InvoiceManager.isProcessingInvoice){
				hideInput(showFakeInput);
				return;
			}
			if (LightBox.isShowing) {
				hideInput(showFakeInput);
				return;
			}
			if (!isActivated) {
				hideInput(showFakeInput);
				return;
			}
			if (checkWritingAvaliablity()) {
				showChatInput();
				setChatListSize(false);
			} else {
				hideInput(showFakeInput);
			}
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
		
		private function onBackClicked(e:Event = null):void{
			MobileGui.changeMainScreen(RootScreen,null,ScreenManager.DIRECTION_LEFT_RIGHT);
		}
		
		private function onNewMessage(data:ChatMessageVO):void {
			if (ChatManager.getCurrentChat() == null)
				return;
			if (data.chatUID != ChatManager.getCurrentChat().uid)
				return;
			if (ChatManager.getCurrentChat().getQuestion() != null && ChatManager.getCurrentChat().getQuestion().userUID != Auth.uid) {
				questionButtonShowHide();
			}
			if (list == null)
				return;
			echo("ChatScreen", "onNewMessage", data);
			if (data.checkForImmediatelyMessage == true) {
				data.checkForImmediatelyMessage = false;
				data.decrypt(ChatManager.getCurrentChat().chatSecurityKey);
				if (data.systemMessageVO != null && data.systemMessageVO.rateBotWebView != null) {
					if (data.systemMessageVO.rateBotWebView.immediately) {
						currentBotRateMessage = null;
						var action:BotReactionAction = new BotReactionAction(data.systemMessageVO.rateBotWebView, ChatManager.getCurrentChat().uid, data.userUID);
						action.execute();
					} else if (data.systemMessageVO != null && data.systemMessageVO.rateBotWebView != null) {
						currentBotRateMessage = data.systemMessageVO.rateBotWebView;
						currentBotRateMessage.botUID = data.userUID;
					}
				}
			}
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
		
		static private function openPrivateChatDialogResponse(val:int):void {
			if (val != 1)
				return;
			if (ChatManager.getCurrentChat() == null || ChatManager.getCurrentChat().users == null || ChatManager.getCurrentChat().users.length == 0)
				return;
			var chatScreenData:ChatScreenData = new ChatScreenData();
			var cVO:ChatVO = ChatManager.getChatWithUsersList([ChatManager.getCurrentChat().users[0].uid]);
			if (cVO != null) {
				chatScreenData.chatVO = cVO;
				chatScreenData.type = ChatInitType.CHAT;
			} else {
				chatScreenData.usersUIDs = [ChatManager.getCurrentChat().users[0].uid];
				chatScreenData.type = ChatInitType.USERS_IDS;
			}
			chatScreenData.backScreen = MobileGui.centerScreen.currentScreenClass;
			chatScreenData.backScreenData = MobileGui.centerScreen.currentScreen.data;
			MobileGui.showChatScreen(chatScreenData);
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
			/*var needScrollToBottom:Boolean  = false;
			var allowedBottomOffset:int = 100;
			if (list.height < list.innerHeight)
				needScrollToBottom = Math.abs(list.getBoxY() - allowedBottomOffset) >= list.innerHeight - list.height;
			return needScrollToBottom;*/
		}
		
		private function onChatSettingsLoaded(model:ChatSettingsModel):void {
			if (isDisposed)
				return;
			chatData.settings = model;
			updateChatBackground();
			chatTop.update();
			list.refresh();
		}
		
		private function onChatOpened():void {
			echo("ChatScreen", "onChatOpened", "");
			if (VideoStreaming.isOnAir() && VideoStreaming.currentChat == ChatManager.getCurrentChat().uid)
				returnToStream();
			chatTop.update();
			if (chatData && chatData.settings == null && ChatManager.getCurrentChat())
				ChatManager.getChatSettingsModel(ChatManager.getCurrentChat().uid, onChatSettingsLoaded);
			if (ChatManager.getCurrentChat().settings != null && (backgroundImage == null || backgroundImage.visible == false))
				ChatManager.getCurrentChat().settings.backgroundBrightness = ColorUtils.getColorBrightness(DEFAULT_BACKGROUND_COLOR);
			if (chatData != null &&
				chatData.type == ChatInitType.USERS_IDS &&
				ChatManager.getCurrentChat() != null &&
				ChatManager.getCurrentChat().type == ChatRoomType.GROUP) {
					chatData.chatVO = ChatManager.getCurrentChat();
					chatData.chatUID = chatData.chatVO.uid;
					chatData.usersUIDs = null;
					chatData.type = ChatInitType.CHAT;
			}
			if (chatData != null && chatData.unfinishedPayTask != null) {
				InvoiceManager.preProcessInvoce(chatData.unfinishedPayTask);
				chatData.unfinishedPayTask = null;
			}
			if (data.pendingInvoice != null)
				ChatManager.sendInvoiceByData(data.pendingInvoice);
			if (ChatManager.getCurrentChat().type == ChatRoomType.CHANNEL && 
				ChatManager.getCurrentChat().questionID != null && 
				ChatManager.getCurrentChat().questionID != "") {
				if (questionPanel == null) {
					questionPanel = new QuestionPanel();
					questionPanel.S_HEIGHT_CHANGE.add(onQuestionPanelSizeChanged);
					view.addChild(questionPanel);
					questionPanel.y = Math.floor(chatTop.view.y + chatTop.height);
					if (isActivated) {
						if (questionPanel != null) {
							questionPanel.activate();
						}
					}
				}
				var chatOwner:UserVO;
				var ownerIncognito:Boolean = false;
				
				if (ChatManager.getCurrentChat().getQuestion() == null) {
					var chatOwnerModel:ChatUserVO = ChatManager.getCurrentChat().getUser(ChatManager.getCurrentChat().ownerUID);
					if (chatOwnerModel != null){
						chatOwner = chatOwnerModel.userVO;
						ownerIncognito = chatOwnerModel.secretMode;
					}
				}
				var panelHeight:int = chatInput.getView().y - questionPanel.y - Config.FINGER_SIZE * 2;
				if (chatInput.isShown() == false)
				{
					panelHeight = _height - questionPanel.y - Config.FINGER_SIZE * 2;
				}
				questionPanel.draw(
									ChatManager.getCurrentChat().getQuestion(), _width, 
									ChatManager.getCurrentChat().title, chatOwner, 
									ownerIncognito, 
									panelHeight);
				
				list.view.y = Math.min(questionPanel.y + questionPanel.getHeight(), questionPanel.y + questionPanel.minHeight);
				
				list.setActivityPadding(questionPanel.getHeight() - list.view.y + questionPanel.y, "top");
				var c:ChatVO = ChatManager.getCurrentChat();
				if (satisfyPublicAnswerButton == null && 
					ChatManager.getCurrentChat() != null &&
					ChatManager.getCurrentChat().getQuestion() != null &&
					ChatManager.getCurrentChat().getQuestion().userUID == Auth.uid && 
					ChatManager.getCurrentChat().getQuestion().isPaid == false) {
						satisfyPublicAnswerButton = new HidableButton();
						
						var iconStop:buttonSatisfyIcon = new buttonSatisfyIcon();
						UI.scaleToFit(iconStop, Config.FINGER_SIZE * 1.5, Config.FINGER_SIZE * 1.5);
						satisfyPublicAnswerButton.setDesign(iconStop, Config.FINGER_SIZE * 1.5);
						UI.destroy(iconStop);
						iconStop = null;
						satisfyPublicAnswerButton.tapCallback = onSatisfyButtonTap;
						
						_view.addChild(satisfyPublicAnswerButton);
						
						satisfyPublicAnswerButton.setPosition( _width - Config.FINGER_SIZE*1.5 - Config.MARGIN * 2,  bottomY - satisfyPublicAnswerButton.height - Config.MARGIN);
						satisfyPublicAnswerButton.activate();
				}
				preShowQuestionRulesPopup();
			}
			var chat:ChatVO = ChatManager.getCurrentChat();
			if (ChatManager.getCurrentChat().type == ChatRoomType.CHANNEL && (ChatManager.getCurrentChat().questionID == null || ChatManager.getCurrentChat().questionID == "") &&
				Lang.channelDescs != null && (ChatManager.getCurrentChat().uid in Lang.channelDescs) &&	Lang.channelDescs[ChatManager.getCurrentChat().uid] != null) {
				if (questionPanel == null) {
					questionPanel = new QuestionPanel();
					questionPanel.S_HEIGHT_CHANGE.add(onQuestionPanelSizeChanged);
					view.addChild(questionPanel);
					questionPanel.y = Math.floor(chatTop.view.y + chatTop.height);
					if (isActivated) {
						if (questionPanel != null) {
							questionPanel.activate();
						}
					}
				}
				var chatUser:ChatUserVO = ChatManager.getCurrentChat().getUser(ChatManager.getCurrentChat().ownerUID);
				var chatOwnerChannel:UserVO;
				if (chatUser != null) {
					chatOwnerChannel = chatUser.userVO;
				}
				var panelHeightChannel:int = chatInput.getView().y - questionPanel.y - Config.FINGER_SIZE * 2;
				if (chatInput.isShown() == false) {
					panelHeight = _height - questionPanel.y - Config.FINGER_SIZE * 2;
				}
				var descriptionText:String = Lang.channelDescs[ChatManager.getCurrentChat().uid];
				questionPanel.draw(
									null, _width,
									descriptionText, chatOwnerChannel,
									false,
									panelHeightChannel);
				
				list.view.y = Math.min(questionPanel.y + questionPanel.getHeight(), questionPanel.y + questionPanel.minHeight);
				
				list.setActivityPadding(questionPanel.getHeight() - list.view.y + questionPanel.y, "top");
			}
			var showPayButtons:Boolean = true;
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
			
			updateChatInput();
			hideVerificationButton();
			checkForPhase();

			checkForPayCard();
			checkForInvoice();

			updateReportButton();
			
			if (chatInput)
				chatInput.initButtons(showPayButtons);
			if (ChatManager.getCurrentChat().type == ChatRoomType.QUESTION)
			{
				if (ChatManager.getCurrentChat().getQuestion() != null)
				{
					checkQuestionButtons();
					updateChatInput();
				}
				else
				{
					if (ChatManager.getCurrentChat().queStatus)
					{
						disableEscrowButtons();
					}
				}
			}
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
			
			if (ChatManager.getCurrentChat().type == ChatRoomType.CHANNEL && (ChatManager.getCurrentChat().questionID == null || ChatManager.getCurrentChat().questionID == "")){
				ChannelsManager.setInOut(true);
			}
			
			// SETUP LOCATION
			if (ChatManager.getCurrentChat().type == ChatRoomType.COMPANY){
				var location:String = "UNKNOWN";
				if (Auth.countryISO != null && Auth.countryISO != "")
					location = Auth.countryISO;
				PHP.call_statVI("chatLocation", location);
			}
			
			// AUTO Message to BOT PRIVATE
			if (ChatManager.getCurrentChat().type == ChatRoomType.PRIVATE ) {
				var user:ChatUserVO = UsersManager.getInterlocutor(ChatManager.getCurrentChat());	
				if ( user != null && user.userVO != null && user.userVO.type == UserVO.TYPE_BOT){
					TweenMax.killDelayedCallsTo(sendInitialBotCommand);
					TweenMax.delayedCall(1,sendInitialBotCommand);					
				}
			}
			
			
			// AUTO Message to BOT GROUP
			if (ChatManager.getCurrentChat().type == ChatRoomType.GROUP || 
				ChatManager.getCurrentChat().type == ChatRoomType.COMPANY || 
				ChatManager.getCurrentChat().type == ChatRoomType.CHANNEL)	{
					TweenMax.killDelayedCallsTo(sendInitialBotCommand);
					TweenMax.delayedCall(1,sendInitialBotCommand);	
			}
			
			if (ChatManager.currentChatApproveStatus == false &&
				chatData.additionalData != null &&
				"openSendMoney" in chatData.additionalData == true &&
				chatData.additionalData.openSendMoney == true){

					TweenLite.delayedCall(
						.5,function():void{
							Gifts.startSendMoney();
						}
					)
					
				}
			if (ChatManager.currentChatApproveStatus == false &&
				chatData.additionalData != null &&
				"openSendInvoice" in chatData.additionalData == true &&
				chatData.additionalData.openSendInvoice == true) {
					TweenLite.delayedCall(
						.5,function():void{
							var invA:AddInvoiceAction = new AddInvoiceAction();
							invA.execute();
						}
					)
					
				}
		
			checkDraftMessage();
				
			//------visual iploaders
			
			updateChatBackground();
			
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
		
		private function disableEscrowButtons():void 
		{
			if (questionLinkButton != null)
			{
				questionLinkButton.hide();
				questionLinkButton.deactivate();
			}
			
			if (basketButton != null) {
				basketButton.hide();
				basketButton.deactivate();
			}
			
			if (questionButtonBG != null)
			{
				questionButtonBG.visible = false;
			}
		}
		
		private function checkDraftMessage():void 
		{
			if (chatInput != null)
			{
				var draft:String = DraftMessage.getValue(ChatManager.getCurrentChat().uid, ChatManager.getCurrentChat().chatSecurityKey);
				if (draft != null && draft != "")
				{
					chatInput.setValue(draft);
				}
			}
		}
		
		private function updateReportButton():void 
		{
			if (ChatManager.getCurrentChat() != null && UsersManager.getInterlocutor(ChatManager.getCurrentChat()) != null && UsersManager.getInterlocutor(ChatManager.getCurrentChat()).uid == Config.NOTEBOOK_USER_UID)
			{
				return;
			}
			
			
			if (reportButton == null &&
				ChatManager.getCurrentChat() != null && 
				ChatManager.getCurrentChat().isLocalIncomeChat() == false && 
				ChatManager.getCurrentChat().type == ChatRoomType.PRIVATE && 
				ChatManager.getCurrentChat().messageVO != null && 
				ChatManager.getCurrentChat().messageVO.num > 0 &&
				(
					ChatManager.getCurrentChat().messageVO.num < ConfigManager.config.hideReportButtonMinMessagesInNewChat || 
					((new Date()).getTime() - ChatManager.getCurrentChat().created) / (1000 * 60 * 60) < ConfigManager.config.hideReportButtonMinChatAge)
				)
			{
						reportButton = new HidableButton();
						reportButton.unhide();
						var icon:HandStop = new HandStop();
						UI.scaleToFit(icon, Config.FINGER_SIZE * 1, Config.FINGER_SIZE * 1);
						reportButton.setDesign(icon, Config.FINGER_SIZE * 1);
						UI.destroy(icon);
						icon = null;
						reportButton.tapCallback = onReportTap;
						
						_view.addChild(reportButton);
						
						reportButton.setPosition( _width - Config.FINGER_SIZE * 1 - Config.MARGIN * 2,  bottomY - reportButton.height - Config.MARGIN);
						reportButton.activate();
				
			}
		}
		
		private function onReportTap():void 
		{
			DialogManager.alert(Lang.suspiciousChat, Lang.suspiciousChatDescription, onReportChatRequest, Lang.report, Lang.textBack);
		}
		
		private function onReportChatRequest(code:int):void 
		{
			if (code == 1)
			{
				UsersManager.complain(ChatManager.getCurrentChat(), onRepostResult);
			}
		}
		
		private function onRepostResult(success:Boolean):void
		{
			if (success == true)
			{
				if (reportButton != null)
					reportButton.dispose();
				reportButton = null;
			}
		}
		
		private function returnToStream():void {
			if (streamContainer == null) {
				streamContainer = new Sprite();
				view.addChild(streamContainer);
				
				stream = VideoStreaming.getCurrent();
				stream.attachTo(streamContainer, new Rectangle(0, 0, _width, chatInput.getView().y), onStreamEnd, list.view);
				chatTop.hide(0);
				
				if (backgroundImage != null)
					backgroundImage.visible = false;
				backColorClip.alpha = 0;
				setChatListSize();
			}
		}
		
		private function checkForPhase(realChange:Boolean = true):void {
			if (ChatManager.getCurrentChat() != null && ChatManager.getCurrentChat().type == ChatInitType.SUPPORT) {
				if (ChatManager.getCurrentChat().pid == Config.EP_VI_DEF){
					if (Auth.bank_phase.toLowerCase() == "vidid_queue") {
						showVerificationButton("viAppointment");
						return;
					} 
					if (Auth.bank_phase.toLowerCase() == "vidid" || Auth.bank_phase.toLowerCase() == "vi_fail") {
						showVerificationButton();
						return;
					} else if (Auth.bank_phase.toLowerCase() == "vidid_ready") {
						showVerificationButton("suspend");
						return;
					}
					/*else if(Auth.bank_phase.toLocaleLowerCase()=="notary") {
						showVerificationButton("notary");
						return;
					}*/
				}
				if (ChatManager.getCurrentChat().pid == Config.EP_VI_EUR) {
					if (Auth.eu_phase.toLowerCase() == "vidid") {
						showVerificationButton();
						return;
					} else if (Auth.eu_phase.toLowerCase() == "vidid_ready") {
						showVerificationButton("suspend");
						return;
					}
				}
				if (ChatManager.getCurrentChat().pid == Config.EP_VI_PAY) {
					if (Auth.ch_phase.toLowerCase() == "vidid") {
						showVerificationButton();
						return;
					} else if (Auth.ch_phase.toLowerCase() == "vidid_ready") {
						showVerificationButton("suspend");
						return;
					}
				}
			}


			if (ChatManager.getCurrentChat() != null && ChatManager.getCurrentChat().type == ChatInitType.SUPPORT && ChatManager.getCurrentChat().pid == Config.EP_VI_DEF)
			{
				if (Auth.bank_phase == BankPhaze.CARD ||
					Auth.bank_phase == BankPhaze.EMPTY ||
					Auth.bank_phase == BankPhaze.ZBX ||
					Auth.bank_phase == BankPhaze.DOCUMENT_SCAN ||
					Auth.bank_phase == BankPhaze.DONATE ||
					Auth.bank_phase == BankPhaze.SOLVENCY_CHECK ||
					Auth.bank_phase == BankPhaze.NOTARY ||
					Auth.bank_phase == BankPhaze.WIRE_DEPOSIT ||
					Auth.bank_phase == BankPhaze.RTO_STARTED)
				{
					showVerificationButton("show_phaze");
					return;
				}
			}
			
			hideVerificationButton();
		}
		
		private function checkForPayCard():void {
			if (data.payCard == false)
				return;
			showVerificationButton("payCard");
		}
		
		private function checkForInvoice():void {
			if (data != null && "additionalData" in data && data.additionalData && isAutoInvoice(data.additionalData))
				showVerificationButton("invoice");
		}

		private function isAutoInvoice(value:Object):Boolean
		{
			if (value != null && "amount" in value && "currency" in value)
			{
				return true;
			}
			return false;
		}

		private function sendInitialBotCommand():void {
			var currentChat:ChatVO = ChatManager.getCurrentChat();
			if (currentChat == null) return;
			
			//PRIVATE
			if (currentChat.type == ChatRoomType.PRIVATE) {
				var user:ChatUserVO = UsersManager.getInterlocutor(ChatManager.getCurrentChat());	
				if ( user != null && user.userVO != null && user.userVO.type == UserVO.TYPE_BOT){
					//var botAvatarCommand:String =  "bot:" +  user.userVO.getDisplayName().toLowerCase() + " start";					
					var botAvatarCommand:String = "start";					
					var actionData:Object = {};
					actionData.lang = LangManager.model.getCurrentLanguageID();
					//actionData.userUID = Auth.uid;
					actionData.userName = Auth.username;
					ChatManager.sendBotActionMessage(botAvatarCommand, "", actionData, ChatManager.getCurrentChat().uid, user.userVO.uid);
				}
			}
			
			
			// GROUP
			if (ChatManager.getCurrentChat().type == ChatRoomType.GROUP || 
				ChatManager.getCurrentChat().type == ChatRoomType.COMPANY || 
				ChatManager.getCurrentChat().type == ChatRoomType.CHANNEL)	{					
					if (ChatManager.getCurrentChat().users != null && ChatManager.getCurrentChat().users.length > 0){
						var userBot:ChatUserVO;
						for (var j:int = 0; j < ChatManager.getCurrentChat().users.length; j++){
							userBot = ChatManager.getCurrentChat().users[j];
							if (userBot != null && userBot.userVO != null && userBot.userVO.type  == UserVO.TYPE_BOT){
									var botAvatarCommandGroup:String = "start";					
									var actionDataGroup:Object = {};
									actionDataGroup.lang = LangManager.model.getCurrentLanguageID();
									//actionDataGroup.userUID = Auth.uid;
									actionDataGroup.userName = Auth.username;
									ChatManager.sendBotActionMessage(botAvatarCommandGroup, "", actionDataGroup, ChatManager.getCurrentChat().uid, userBot.uid);
							}
						}
				}
			}	
			
		}
		
		private function preShowQuestionRulesPopup():void {
			if ((Auth.myProfile != null && Auth.myProfile.newbie == true) &&
				ChatManager.getCurrentChat() != null && 
				ChatManager.getCurrentChat().getQuestion() != null && 
				ChatManager.getCurrentChat().getQuestion().rulesShown == false && 
				ChatManager.getCurrentChat().getQuestion().userUID != Auth.uid) {
					ChatManager.getCurrentChat().getQuestion().rulesShown = true;
					Store.load(Store.VAR_DO_NOT_SHOW_QUESTION_RULES, onStoreShowQuestionRules);
			}
		}
		
		private function onStoreShowQuestionRules(data:Object, err:Boolean):void {
			if (data == true && isDisposed == false)
				return;
			var text:String;
			if (ChatManager.getCurrentChat() != null && ChatManager.getCurrentChat().getQuestion() != null) {
				text = Lang.publicQuestionIntroText;
				var amount:String = ChatManager.getCurrentChat().getQuestion().tipsAmount.toString();
				var currency:String = ChatManager.getCurrentChat().getQuestion().tipsCurrencyDisplay;
				text = LangManager.replace(Lang.regExtValue, text, amount + " " + currency);
			}
			DialogManager.showQuestionRulesDialog(onQuestionRulesDialogCallback, Lang.information, text);
		}
		
		private function onQuestionRulesDialogCallback(data:Object):void {
			if (data.doNotShowAgain == true)
				Store.save(Store.VAR_DO_NOT_SHOW_QUESTION_RULES, true);
			if (data.id == -1)
				return;
			TweenMax.delayedCall(0.5, show911Rules);
		}
		
		private function show911Rules():void {
			DialogManager.show911Rules( { title:Lang.textRules } );
		}
		
		private function onSatisfyButtonTap():void {
			if (ChatManager.getCurrentChat() != null && 
				ChatManager.getCurrentChat().getQuestion() != null && 
				ChatManager.getCurrentChat().getQuestion().busy == false && 
				ChatManager.getCurrentChat().getQuestion().isPaid == false) {
					ServiceScreenManager.showScreen(
						ServiceScreenManager.TYPE_DIALOG,
						ScreenQuestionReactionsDialog,
						{
							label:Lang.selectWinner,
							qUID:ChatManager.getCurrentChat().questionID,
							chatUID:ChatManager.getCurrentChat().uid
						}
					);
			}
		}
		
		private function onQuestionPanelSizeChanged():void {
			if (list != null && questionPanel != null) {
				list.setActivityPadding(questionPanel.getHeight() - list.view.y + questionPanel.y, "top");
			}
		}
		
		private function checkWritingAvaliablity():Boolean {
			if (Config.isAdmin() == true)
				return true;
			if (ChatManager.getCurrentChat() != null && Auth.isBanned(ChatManager.getCurrentChat().uid))
				return false;
			if (ChatManager.getCurrentChat() && ChatManager.getCurrentChat().type == ChatRoomType.CHANNEL) {
				if (ChatManager.getCurrentChat().questionID != null && 
					ChatManager.getCurrentChat().questionID != "" && 
					ChatManager.getCurrentChat().getQuestion() != null && 
					ChatManager.getCurrentChat().getQuestion().userUID != Auth.uid &&
					ChatManager.getCurrentChat().getQuestion().status == QuestionsManager.QUESTION_STATUS_RESOLVED) {
						return false;
				}
				if (ChatManager.getCurrentChat().settings.writeMode == "all") {
					return true;
				} else if (ChatManager.getCurrentChat().settings.writeMode == "stars") {
					if (Auth.myProfile.payRating < ConfigManager.config.channelStars)
						return false;
					return true;
				} else {
					var channelMode:String = ChatManager.getCurrentChat().settings.mode;
					if (channelMode == ChannelsManager.CHANNEL_MODE_ALL) {
						return true;
					} else if (channelMode == ChannelsManager.CHANNEL_MODE_MODERATORS) {
						if (!ChatManager.getCurrentChat().isModerator(Auth.uid) && !ChatManager.getCurrentChat().isOwner(Auth.uid))
							return false;
					} else if (channelMode == ChannelsManager.CHANNEL_MODE_NONE) {
						if (!ChatManager.getCurrentChat().isOwner(Auth.uid))
							return false;
					}
				}
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
			if (ChatManager.getCurrentChat().type == ChatRoomType.QUESTION) {
				var changed1:Boolean = questionButtonShowHide();
				var changed2:Boolean = answersButtonShowHide();
				if (changed1 || changed2)
					setChatListSize();
			}
			updateSounds();
			if (Auth.isBanned(ChatManager.getCurrentChat().uid)) {
				var bannedMessageExist:Boolean = false;
				if (list.data && (list.data is Array) && ((list.data as Array).length > 0)
					&& ((list.data as Array)[0] is ChatMessageVO) && ((list.data as Array)[0] as ChatMessageVO).action
					&& (((list.data as Array)[0] as ChatMessageVO).action is ShowBanInfoAction))
						bannedMessageExist = true;
				if (!bannedMessageExist)
					addBannedMessage(Auth.getBanData(ChatManager.getCurrentChat().uid));
			}
			checkApproveStatus();
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
			var oldContentHeight:int = list.innerHeight;
			if (LightBox.isShowing)
			{
				listPositionY = -list.getBoxY();
			}

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

			if (LightBox.isShowing)
			{
				list.setBoxY( -(list.innerHeight - oldContentHeight + listPositionY));
			}
			else
			{
				list.setBoxY( -(list.innerHeight - listPositionY));
			}


			if (LightBox.isShowing)
			{
				if (messages != null && messages.length > 0 && messages[0].num < 2)
				{
					LightBox.disablePrewButton();
				}
				else
				{
					updateLightboxDataset();
				}
			}
		}
		
		private function updateLightboxDataset():void
		{
			cachedChatImages = null;
			var chatImages:Vector.<ChatMessageVO> = getChatImages();
			cachedChatImages = chatImages;
			chatImages.reverse();
			var l:int = chatImages.length;
			for (var i:int = 0; i < l; i++)
			{
				LightBox.unshift(chatImages[i].imageURLWithKey, true, null, null, null, chatImages[i].imageThumbURLWithKey, null);
			}
			LightBox.checkPendingCalls();
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
			
			if (replyPanel != null)
			{
				replyPanel.setPosition(chatInput.getView().y);
				bottomY -= replyPanel.getHeight();
			}
			
			bottomY -= getAnswersOffset(bottomY);
			
			bottomY = updateButtonsPositions(bottomY);
			
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

		private function updateButtonsPositions(bottomY: int): int {
			if (satisfyPublicAnswerButton != null) {
				satisfyPublicAnswerButton.setPosition(_width - Config.FINGER_SIZE * 1.5 - Config.MARGIN * 2, bottomY - satisfyPublicAnswerButton.height - Config.MARGIN);
			}

			if (verificationButton != null) {
				bottomY -= verificationButton.height;
				verificationButton.y = chatInput.getView().y - verificationButton.height;
			}

			var position: int = bottomY;
			if (reportButton != null) {
				reportButton.setPosition(_width - Config.FINGER_SIZE * 1 - Config.MARGIN * 2, bottomY - reportButton.height - Config.MARGIN);
				position -= reportButton.height - Config.FINGER_SIZE * .2;
			}

			if (scrollBottomButton != null) {
				scrollBottomButton.y = (position - scrollBottomButton.height - Config.DIALOG_MARGIN * 0.7);
			}

			return bottomY;
		}

		/*private function updateButtonsPositions(bottomY:int):int
		{
			if (satisfyPublicAnswerButton != null) {
				satisfyPublicAnswerButton.setPosition(_width - Config.FINGER_SIZE * 1.5 - Config.MARGIN * 2, bottomY - satisfyPublicAnswerButton.height - Config.MARGIN);
			}
			
			if (verificationButton != null) {
				bottomY -= verificationButton.height;
				verificationButton.y = chatInput.getView().y - verificationButton.height;
			}
			
			var position:int = bottomY;
			if (reportButton != null) {
				reportButton.setPosition(_width - Config.FINGER_SIZE * 1 - Config.MARGIN * 2, bottomY - reportButton.height - Config.MARGIN);
				position -= reportButton.height - Config.FINGER_SIZE * .2;
			}
			
			if (scrollBottomButton != null)
			{
				scrollBottomButton.y = (position - scrollBottomButton.height - Config.DIALOG_MARGIN * 0.7);
			}
			
			return bottomY;
		}*/
		
		private function getAnswersOffset(bottomY:int):int {
			var chat:ChatVO = ChatManager.getCurrentChat();
			if (chat == null ||	chat.type != ChatRoomType.QUESTION)
					return 0;
			var lastY:Number = 0;
			if (questionLinkButton != null) {
				questionLinkButton.y = bottomY - questionLinkButton.height - Config.MARGIN;
				questionLinkButton.x = Config.MARGIN;
				if (questionLinkButton.getIsShown())
					lastY = questionLinkButton.height + Config.MARGIN * 2;
			}
			if (basketButton != null) {
				basketButton.y = questionLinkButton.y;
				basketButton.x = questionLinkButton.width + Config.MARGIN * 2;
			}
			if (answersCountButton != null) {
				answersCountButton.y = int(bottomY - answersCountButton.height - Config.MARGIN - (questionLinkButton.height - answersCountButton.height) * .5);
				answersCountButton.x = _width * .6 ;
				if (answersCountButton.getIsShown() && questionLinkButton != null &&  lastY<answersCountButton.height )
					lastY = answersCountButton.height + Config.MARGIN * 2;
			}
			if (questionButtonBG != null) {
				questionButtonBG.width = _width;
				questionButtonBG.height = lastY;
				questionButtonBG.y =  bottomY - questionButtonBG.height;
			}
			return lastY;
		}
		
		private function onChatSend(value:*, type:String = ChatMessageType.TEXT):Boolean {
			currentBotRateMessage = null;
			if (ChatManager.getCurrentChat() != null && ChatManager.getCurrentChat().isIncomingLocalChat()) {
				ToastMessage.display(Lang.alertProvideInternetConnection, false, chatInput.getHeight());
				return false;
			}
			
			if (ChatManager.getCurrentChat() != null && ChatManager.getCurrentChat().uid == EVENTS_CHANNEL) {
				if (Config.isAdmin() == false && Auth.myProfile.payRating < 3) {
					return false;
				}
			}
			//!TODO:;
			/*if (currentBotRateMessage != null) {
				
				var action:BotReactionAction = new BotReactionAction(currentBotRateMessage, ChatManager.getCurrentChat().uid, Auth.uid);
				action.execute();
				
				currentBotRateMessage = null;
				/*if (rateBot.buttons != null && rateBot.buttons.length == 4) {
					ServiceScreenManager.showScreen(
						ServiceScreenManager.TYPE_DIALOG,
						FeedbackPopup,
						{
							text:Lang[rateBot.desc], 
							textFeedback:Lang[rateBot.desc1], 
							button_1:Lang[rateBot.buttons[0].label], 
							button_2:Lang[rateBot.buttons[1].label], 
							button_3:Lang[rateBot.buttons[2].label],
							button_4:Lang[rateBot.buttons[3].label],
							callback:function(val:int, text:String = null):void {
								if (val == 0)
									return;
								if (ChatManager.getCurrentChat() == null)
									return;
								if (rateBot == null || rateBot.buttons == null || rateBot.buttons.length < val)
									return;
								PHP.call_statVI("SPR_" + rateBot.buttons[val - 1].statAction, ChatManager.getCurrentChat().uid);
								ChatManager.sendBotActionMessage(
									rateBot.buttons[val - 1].botAction,
									null,
									(rateBot.buttons[val - 1].feedback != true) ? null : JSON.stringify( { feedback:text } ),
									ChatManager.getCurrentChat().uid,
									botUID
								);
								needToRateBot = false;
								rateBot = null;
							}
						}
					);
				}
			}*/
			echo("ChatScreen", "onChatSend", "");
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
				
				if (replyPanel != null && replyPanel.getMessage() != null)
				{
					value = addReplay(value);
					replyPanel.removePanel();
				}
				
				var messageId:Number = ChatManager.sendMessage(value as String, null, null, false, -1, setSavedTextToInput);
				
				if (RichMessageDetector.detectLink(value))
				{
					RichMessageDetector.lastSentMessage = messageId;
				}
			} else if (type == ChatMessageType.VOICE)
				ChatManager.sendVoice(value as LocalSoundFileData);
			return true;
		}
		
		private function addReplay(text:String):String 
		{
			if (text != null)
			{
				var result:String = ChatSystemMsgVO.REPLAY_START_BOUND + 'quote-type=\" \" author=\"' + replyPanel.getUser() + '\" target="' + replyPanel.getReplayNum() + '"}' + replyPanel.getMessage() + ChatSystemMsgVO.REPLAY_END_BOUND + "\n" + text;
				return result;
			}
			return "";
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
			clearCurrentBackroundImage();
			UI.destroy(questionButtonBG);
			questionButtonBG = null;
			if (questionLinkButton)
				questionLinkButton.dispose();
			questionLinkButton = null;
			if (basketButton)
				basketButton.dispose();
			basketButton = null;
			if (answersCountButton)
				answersCountButton.dispose();
			answersCountButton = null;
			if (noConnectionIndicator)
				noConnectionIndicator.dispose();
			noConnectionIndicator = null;
			if (lockButton != null)
				lockButton.dispose();
			lockButton = null;
			if (scrollBottomButton != null)
				scrollBottomButton.dispose();
			scrollBottomButton = null;
			if (verificationButton != null)
				verificationButton.dispose();
			verificationButton = null;
			if (preloader != null)
				preloader.dispose();
			preloader = null;
			if (userWritings != null)
				userWritings.dispose();
			userWritings = null;
			UI.disposeBMD(unlockBMD);
			unlockBMD = null;
			if (list != null)
				list.dispose();
			list = null;
			if (bottomInputClip != null)
				UI.destroy(bottomInputClip);
			bottomInputClip = null;
			
			if (questionPanel != null) {
				if (questionPanel.S_HEIGHT_CHANGE != null) {
					questionPanel.S_HEIGHT_CHANGE.remove(onQuestionPanelSizeChanged);
				}
				questionPanel.dispose();
				questionPanel = null;
			}
			if (satisfyPublicAnswerButton != null)
				satisfyPublicAnswerButton.dispose();
			satisfyPublicAnswerButton = null;
			
			if (reportButton != null)
				reportButton.dispose();
			reportButton = null;
			
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
			TweenMax.killTweensOf(backgroundImage);
			
			if (historyLoadingScroller) {
				historyLoadingScroller.dispose();
				historyLoadingScroller = null;
			}
			
			if (LightBox.isShowing) {
				LightBox.isShowing = false;
			}
			
			TweenMax.killDelayedCallsTo(addPreloader);
			TweenMax.killDelayedCallsTo(show911Rules);
			TweenMax.killDelayedCallsTo(enableVididButton);
		}
		
		protected function onInputPositionChange():void {
			if (questionPanel != null)
				questionPanel.collapse();
			setChatListSize();
		}
		
		override public function dispose():void {
			echo("ChatScreen", "dispose", "");
			if (_isDisposed == true)
				return;
			disposing = true;
			removePayAction();
			cachedChatImages = null;
		//	clearWaitingTimeout();
			TweenMax.killTweensOf(backColorClip);
			
			NativeExtensionController.onChatScreenClosed();
			
			GD.S_STOP_LOAD.invoke();
			
			if (replyPanel != null)
			{
				replyPanel.dispose();
				replyPanel = null;
			}
			if (currentInvoiceAction != null)
			{
				currentInvoiceAction.S_ACTION_SUCCESS.remove(invoiceSent);
				currentInvoiceAction.S_ACTION_FAIL.remove(invoiceSentFail);
				currentInvoiceAction.dispose();
				currentInvoiceAction = null;
			}
			if (uploadFilePanel != null)
			{
				uploadFilePanel.dispose();
				uploadFilePanel = null;
			}
			if (stream)
			{
				stream.cutDownStream();
			}
			if (noConnectionIndicator != null)
			{
				PointerManager.removeTap(noConnectionIndicator, tryReconnect);
			}
			if (invoiceProcessView != null)
				invoiceProcessView.dispose();
			invoiceProcessView = null;
			Auth.S_PHAZE_CHANGE.remove(checkForPhase);
		//	WSClient.S_IDENTIFICATION_QUEUE.remove(onQueueLoaded);
			ChatManager.S_MESSAGES_LOADING_FROM_PHP.remove(sMessagesStartLoadFromPHP);
			InvoiceManager.S_START_PROCESS_INVOICE.remove(onStartProcessInvoice);
			InvoiceManager.S_STOP_PROCESS_INVOICE.remove(onStopProcessInvoice);
			ChatManager.S_USER_WRITING.remove(onUserWriting);
			UserWriting.S_USER_WRITING_DISPOSED.remove(onUWDisposed);
			ChatManager.S_CHAT_OPENED.remove(onChatOpened);
			ChatManager.S_CHAT_STAT_CHANGED.remove(onChatUpdated);
			ChatManager.S_MESSAGES.remove(onMessagesLoaded);
			ChatManager.S_HISTORICAL_MESSAGES.remove(onHistoricalMessagesLoaded);
			ChatManager.S_MESSAGE.remove(onNewMessage);
			ChatManager.S_MESSAGE_UPDATED.remove(onMessageUpdated);
			ChatManager.S_ERROR_CANT_OPEN_CHAT.remove(onChatError);
			ChatManager.S_BANNED_IN_CHAT.remove(onBannedInChat);
			ChatManager.S_UNBANNED_IN_CHAT.remove(onUnbannedInChat);
			ChatManager.S_EDIT_MESSAGE.remove(editMessage);
			ChatManager.S_PIN.remove(onPinChange);
			ChatManager.S_REMOTE_MESSAGES_STOP_LOADING.remove(onRemoteMessagesStopLoading);
			GlobalDate.S_NEW_DATE.remove(refreshList);
			LightBox.S_LIGHTBOX_OPENED.remove(onLightboxOpen);
			LightBox.S_LIGHTBOX_CLOSED.remove(onLightboxClose);
			LightBox.S_REQUEST_PREW_CONTENT.remove(requestPrewMessages);
			Puzzle.S_PUZZLE_OPENED.remove(onLightboxOpen);
			Puzzle.S_PUZZLE_CLOSED.remove(onLightboxClose);
			ImageUploader.S_FILE_UPLOAD_STATUS.remove(onFileUploadedStatus);
			VideoUploader.S_FILE_UPLOAD_STATUS.remove(onFileUploadedStatus);
			QuestionsManager.S_QUESTION.remove(onQuestion);
			QuestionsManager.S_QUESTION_NEW.remove(onQuestion);
			QuestionsManager.S_QUESTION_CLOSED.remove(onQuestionClosed);
		//	WSClient.S_LOYALTY_CHANGE.remove(onLoyaltyChanged);
			
			NetworkManager.S_CONNECTION_CHANGED.remove(onNetworkChanged);
			
			/*Calendar.S_APPOINTMENT_BOOK.remove(updateViAppointment);
			Calendar.S_APPOINTMENT_BOOK_CANCEL.remove(updateViAppointment);
			Calendar.S_APPOINTMENT_BOOK_FAIL.remove(updateViAppointment);
			Calendar.S_APPOINTMENT_DATA.remove(updateViAppointment);*/
			
			WSClient.S_MSG_ADD_ERROR.remove(onErrorSendMessage);
			NetworkManager.S_CONNECTION_CHANGED.remove(onNetworkChanged);
			PhotoGaleryManager.S_GALLERY_IMAGE_LOADED.remove(onImageUploadReady);
			PhotoGaleryManager.S_GALLERY_MEDIA_LOADED.remove(onMediaUploadReady);
			ChannelsManager.S_CHANNEL_SETTINGS_UPDATED.remove(onChannelChanged);
			ChannelsManager.S_CHANNEL_MODERATORS_UPDATED.remove(onChannelModeratorsChanged);
			Gifts.S_MONEY_SEND_SUCCESS.remove(onMoneyTransferSuccess);
			ChannelsManager.setInOut(false);
			ChatManager.onExitChat();
			
			ChatManager.S_LOAD_START.remove(showPreloader);
			ChatManager.S_LOAD_STOP.remove(hidePreloader);
			
			TweenMax.killDelayedCallsTo(sendInitialBotCommand);
			
		//	Calendar.S_START_VI.remove(callStartVI);
				
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
			
			if (addToContactsAction != null)
				addToContactsAction.dispose();
			addToContactsAction = null;
			if (blockUserAction != null)
				blockUserAction.dispose();
			blockUserAction = null;
			if (previewMessagesAction != null)
				previewMessagesAction.dispose();
			previewMessagesAction = null;

			if (forwardMessageButton != null)
				forwardMessageButton.dispose();
			forwardMessageButton = null;

			_data = null;
			//в функции dispose нужно добавить
			NativeExtensionController.onChatScreenClosed();
			super.dispose();
		}
		
		private function requestPrewMessages():void
		{
			var nextNum:int = 0;
			if (ChatManager.getCurrentChat() != null && ChatManager.getCurrentChat().messages != null && ChatManager.getCurrentChat().messages.length > 0)
			{
				nextNum = ChatManager.getCurrentChat().messages[0].num;
			}
			if (lastFirstMessageNum == nextNum)
			{
				if (LightBox.isShowing)
				{
					LightBox.clearPending();
				}
				return;
			}
			lastFirstMessageNum = nextNum;
			loadHistoricalMessages();
		}

		private function onChannelModeratorsChanged(eventType:String, channelUID:String):void {
			var currentChatUID:String;
			if ((data as ChatScreenData).chatVO) {
				currentChatUID = (data as ChatScreenData).chatVO.uid;
			} else if (ChatManager.getCurrentChat()) {
				currentChatUID = ChatManager.getCurrentChat().uid;
			}
			
			if (currentChatUID != channelUID)
			{
				return;
			}
			
			switch(eventType)
			{
				case ChannelsManager.EVENT_REMOVED_FROM_MODERATORS:
				{
					updateChatInput();
					chatTop.update();
					
					break;
				}
				case ChannelsManager.EVENT_ADDED_TO_MODERATORS:
				{
					updateChatInput();
					chatTop.update();
					
					break;
				}
			}
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
			if (lockButton != null)
				lockButton.y = chatTop.height + Config.FINGER_SIZE * .5;
		}
		
		private function showNoConnectionIndicator():void {
			if (noConnectionIndicator == null) {
				noConnectionIndicator = new ConnectionIndicator();
				noConnectionIndicator.draw(_width, Config.FINGER_SIZE * .5);
				noConnectionIndicator.y = chatTop.height;
				if (forwardMessageButton != null && forwardMessageButton.parent != null)
				{
					noConnectionIndicator.y = forwardMessageButton.y + forwardMessageButton.height;
				}
				else
				{
					noConnectionIndicator.y = chatTop.height;
				}
			}
			_view.addChild(noConnectionIndicator);
			
			PointerManager.addTap(noConnectionIndicator, tryReconnect);
			
			if (lockButton != null)
				lockButton.y = chatTop.height + Config.FINGER_SIZE * .5 + noConnectionIndicator.height;
		}
		
		private function tryReconnect(e:Event = null):void 
		{
			NetworkManager.reconnect();
		}
		
		// LOCK BUTTON -> //
		public function showLockButton():void {
			if (lockButton == null) { 
				lockButton = new BitmapButton();
				lockButton.setStandartButtonParams();
				lockButton.setDownScale(1.3);
				lockButton.setOverflow(20, 20, 20, 20);
				//lockButton.tapCallback = chatTop.onLockButtonTap;
				lockButton.tapCallback = chatTop.onLockButtonTap;
				
				lockButton.x = _width - Config.FINGER_SIZE - Config.DOUBLE_MARGIN;
				lockButton.y = chatTop.height + Config.MARGIN + ((noConnectionIndicator == null || noConnectionIndicator.parent == null) ? 0 : noConnectionIndicator.height);
				lockButton.setBitmapData(getUnlockBMD());
				lockButton.hide();
				_view.addChild(lockButton);
			}
			lockButton.activate();
			lockButton.show(.3);
		}
		
		public function hideLockButton():void {
			if (lockButton != null)
				lockButton.hide(.3);
		}
		
		private function getUnlockBMD():BitmapData {
			if (unlockBMD == null)
				unlockBMD = UI.renderLockButtonRound(Config.FINGER_SIZE, Config.FINGER_SIZE);
			return unlockBMD;
		}
		
		// QUESTIONS -> //
		private function createQuestionButtons():void {
			if (questionButtonBG != null)
				return;
			createQuestionPanelBack();
			createRemoveButton();
			createMakeOfferButton();
			createAnswersButton();
		}
		
		private function createButton (img:Class, id:String):BitmapButton {
			var btn:BitmapButton = new BitmapButton();
			var ss:Sprite = new Sprite();
			ss.graphics.beginFill(Style.color(Style.COLOR_ICON_SETTINGS));
			ss.graphics.drawRoundRect(0, 0, Config.FINGER_SIZE * .9, Config.FINGER_SIZE * .9, Style.size(Style.SIZE_BUTTON_CORNER), Style.size(Style.SIZE_BUTTON_CORNER));
			var ico:Sprite = new img() as Sprite;
			UI.colorize(ico, Color.WHITE);
			ico.width = int(Config.FINGER_SIZE * .35);
			ico.scaleY *= ico.scaleX;
			ss.addChild(ico);
			ico.x = Math.round((Config.FINGER_SIZE * .9 - ico.width) * .5);
			ico.y = Math.round((Config.FINGER_SIZE * .9 - ico.height) * .5);
			btn.setBitmapData(UI.getSnapshot(ss, StageQuality.HIGH, id), true);
			return btn;
		} 
		
		private function deleteAnswer():void {
			if (ChatManager.getCurrentChat() == null)
				return;
			var qVO:QuestionVO = QuestionsManager.getQuestionByUID(ChatManager.getCurrentChat().questionID, false);
			if (qVO == null)
				return;
			ChatManager.getCurrentChat().setStoped();
			var incognito:Boolean = (qVO.userUID == Auth.uid && qVO.incognito == true);
			QuestionsManager.complain(qVO.uid, ChatManager.getCurrentChat().uid, ChatManager.getCurrentChat().chatSecurityKey, QuestionsManager.COMPLAIN_STOP, "chat", incognito, isNaN(qVO.tipsAmount) == false);
			var cVO:ChatVO = AnswersManager.getNextAnswer(ChatManager.getCurrentChat().questionID, ChatManager.getCurrentChat().uid);
			if (cVO == null) {
				onBack();
				return;
			}
			var chatScreenData:ChatScreenData = new ChatScreenData();
			chatScreenData.chatVO = cVO;
			chatScreenData.type = ChatInitType.CHAT;
			chatScreenData.backScreen = data.backScreen;
			chatScreenData.backScreenData = data.backScreenData;
			MobileGui.showChatScreen(chatScreenData);
		}
		
		private function questionButtonShowHide():Boolean {
			if (questionLinkButton == null)
				return false;
			var action:Boolean = true;
			var qVO:QuestionVO = ChatManager.getCurrentChat().getQuestion();
			if (qVO.type == QuestionsManager.QUESTION_TYPE_PUBLIC)
				return false;
			if (qVO == null)
				action = false;
			else if (qVO.status == "closed" || qVO.status == "resolved" || qVO.status == "archived")
				action = false;
			else if (ChatManager.getCurrentChat().queStatus == true)
				action = false;
			if (questionLinkButton.getIsShown() == action)
				return false;
			if (action == true) {
				questionLinkButton.show();
				questionLinkButton.activate();
				if (basketButton != null) {
					basketButton.show();
					basketButton.activate();
				}	
			} else {
				questionLinkButton.hide();
				questionLinkButton.deactivate();
				if (basketButton != null) {
					basketButton.hide();
					basketButton.deactivate();
				}
			}
			questionButtonBG.visible = (action || (answersCountButton != null && answersCountButton.getIsShown()));
			return true;
		}
		
		private function answersButtonShowHide(obligatory:Boolean = false):Boolean {
			if (answersCountButton == null)
				return false;
			var action:Boolean = true;
			var qVO:QuestionVO = ChatManager.getCurrentChat().getQuestion();
			if (qVO == null)
				action = false;
			else if (qVO.userUID != Auth.uid)
				action = false;
			else if (qVO.answersCount == 0)
				action = false;
			else if (ChatManager.getCurrentChat().queStatus == false && qVO.answersCount == 1)
				action = false;
			if (obligatory == false && answersCountButton.getIsShown() == action)
				return false;
			if (qVO.status == "resolved")
				return false;
			if (action) {
				var textAnswer:String;
				
				if (ChatManager.getCurrentChat().type == ChatRoomType.CHANNEL) {
					textAnswer = Lang.openAnswer;
				}
				else {
					if (ChatManager.getCurrentChat().queStatus == true) {
						textAnswer = (qVO.answersCount == 1) ? Lang.escrow_chat : Lang.escrow_chats;
						answersCountButton.setText("+" + (qVO.answersCount) + " " + textAnswer, _width * .4 - Config.MARGIN);
					} else {
						textAnswer = (qVO.answersCount == 2) ? Lang.escrow_chat : Lang.escrow_chats;
						answersCountButton.setText("+" + (qVO.answersCount - 1) + " " + textAnswer, _width * .4 - Config.MARGIN);
					}
				}
				
				answersCountButton.show();
				answersCountButton.activate();
			} else {
				answersCountButton.hide();
				answersCountButton.deactivate();
			}
			questionButtonBG.visible = (action || (questionLinkButton != null && questionLinkButton.getIsShown()));
			return true;
		}
		
		private function openOtherAnswers():void {
			if (ChatManager.getCurrentChat().type == ChatRoomType.CHANNEL) {
				AnswersManager.answer(ChatManager.getCurrentChat().getQuestion());
			} else {
				AnswersManager.getAnswersByQuestionUID(ChatManager.getCurrentChat().questionID);
			}
		}
		
		private function openQuestionInfo():void {
			// TODO put in Lang.as
			var currentChat:ChatVO = ChatManager.getCurrentChat();
			
			var bodyText:String = Lang.questionInfoDukascopy;
			
			var ownerIsPaying:Boolean = QuestionsManager.isPaying(currentChat.ownerUID);
			if (ownerIsPaying)
				bodyText =Lang.questionInfoUser;
			
			if (isNaN(currentChat.getQuestion().tipsAmount) == false && currentChat.getQuestion().needPayBeforeClose == true) {
				var giftData:GiftData = new GiftData();
				giftData.currency = currentChat.getQuestion().tipsCurrency;
				giftData.customValue = currentChat.getQuestion().tipsAmount;
				giftData.type = GiftType.FIXED_TIPS;
				giftData.chatUID = currentChat.uid;
				giftData.commentAvaliable = false;
				var chatUser:ChatUserVO = UsersManager.getInterlocutor(currentChat);
				if (chatUser != null) {
					giftData.user = chatUser.userVO;
					giftData.recieverSecret = chatUser.secretMode;
				}
				Gifts.S_MONEY_SEND_SUCCESS.add(onMoneyTransferSuccess);
				Gifts.startSendMoney(giftData);
			} else {
				QuestionsManager.acceptQuestionAnswer(currentChat);
			}
			addPreloader();
		}
		
		private function onMoneyTransferSuccess():void {
			Gifts.S_MONEY_SEND_SUCCESS.remove(onMoneyTransferSuccess);
			
			QuestionsManager.acceptQuestionAnswer(ChatManager.getCurrentChat());
		}
		
		private function satisfyAlertResponse():void {
			TweenMax.delayedCall(1, showRules, null, true);
		}
		
		private function showRules():void {
			QuestionsManager.showRules();
		}
		
		public function showInfo():void {
			if (ChatManager.getCurrentChat() == null)
				return;
			
			if (ChatManager.getCurrentChat().type == ChatRoomType.QUESTION || 
				(ChatManager.getCurrentChat().type == ChatRoomType.CHANNEL && ChatManager.getCurrentChat().questionID != null && ChatManager.getCurrentChat().questionID != ""))
			{
				var qVO:QuestionVO = ChatManager.getCurrentChat().getQuestion();
				if (qVO == null)
					return;
				var user:UserVO;
				if (qVO.userUID == Auth.uid) {
					var chatUser:ChatUserVO = UsersManager.getInterlocutor(ChatManager.getCurrentChat());
					if (chatUser == null)
						return;
					user = chatUser.userVO;
				} else {
					if (qVO == null || qVO.user == null)
						return;
					user = qVO.user;
				}
				var chatData:Object = this.data;
				DialogManager.showQuestionInfoDialog(user, infoDialogResponse, Lang.controlPanel.toUpperCase());
			}
		}
		
		private function infoDialogResponse(val:int):void {
			var chatUser:ChatUserVO;
			var answerId:String;
			if (val == QuestionChatActionType.CLOSE_DIALOG)
				return;
			var alertTitle:String =  Lang.information;
			var alertText:String;
			var reason:String;
			
			if (val == QuestionChatActionType.STOP) {
				alertText = Lang.chatClosed;
				reason = QuestionsManager.COMPLAIN_STOP;
			} else if (val == QuestionChatActionType.SPAM) {
				alertText = Lang.alertChatScreenSpam;
				reason = QuestionsManager.COMPLAIN_SPAM;
			} else if (val == QuestionChatActionType.ABUSE) {
				alertTitle =  Lang.textConfirm;
				//alertText = "Abuse report is sent, the user is blocked, chat is closed";
				alertText = Lang.alertChatScreenAbuse;
				reason = QuestionsManager.COMPLAIN_ABUSE;
			} else if (val == QuestionChatActionType.BLOCK) {
				alertTitle = Lang.textConfirm;
				//alertText = "The user is blocked, chat is closed";
				alertText = Lang.alertChatScreenBlock;
				reason = QuestionsManager.COMPLAIN_BLOCK;
			} else if (val == QuestionChatActionType.MORE_INFO) {
				TweenMax.delayedCall(1, showRules, null, true);
				return;
			} else if (val == QuestionChatActionType.START_CHAT) {
				chatUser = UsersManager.getInterlocutor(ChatManager.getCurrentChat());
				if (chatUser && chatUser.uid) {
					var chatScreenData:ChatScreenData = new ChatScreenData();
						chatScreenData.usersUIDs = [chatUser.uid];
						chatScreenData.type = ChatInitType.USERS_IDS;
						chatScreenData.backScreen = ChatScreen;
						chatScreenData.backScreenData = chatData;
					MobileGui.showChatScreen(chatScreenData);
				}
				return;
			} else if (val == QuestionChatActionType.TIPS) {
				chatUser = UsersManager.getInterlocutor(ChatManager.getCurrentChat());
				if (chatUser != null){
					var giftData:GiftData = new GiftData();
					giftData.user = chatUser.userVO;
					giftData.recieverSecret = chatUser.secretMode;
					giftData.type = GiftType.MONEY_TRANSFER;
					Gifts.startSendMoney(giftData);
				}
				
			//	MobileGui.changeMainScreen(PaymentsScreen, { destinationScreen:PaymentsSendMoneyScreen, backScreen:MobileGui.centerScreen.currentScreenClass, backScreenData:data } );
				return;
			} else if (val == QuestionChatActionType.SHOW_USER_INFO) {
				chatUser = UsersManager.getInterlocutor(ChatManager.getCurrentChat());
				if (chatUser) {
					if (chatUser.secretMode == true)
						return;
					MobileGui.changeMainScreen(UserProfileScreen, { backScreen: ChatScreen, 
						backScreenData: chatData, 
						data: chatUser.userVO
					} );
				}
				return;
			} else if (val == QuestionChatActionType.UNBLOCK) {
				chatUser = UsersManager.getInterlocutor(ChatManager.getCurrentChat());
				if (chatUser) {
					UsersManager.changeUserBlock(chatUser.uid, UserBlockStatusType.UNBLOCK);
				}
				return;
			}
			var type:String = "que";
			var qVO:QuestionVO = ChatManager.getCurrentChat().getQuestion();
			if (qVO == null  || qVO.user == null)
				return;
			if (qVO.userUID == Auth.uid)
				type = "chat";
			if (val == QuestionChatActionType.STOP || val == QuestionChatActionType.SPAM) {
				var incognito:Boolean = (qVO.userUID == Auth.uid && qVO.incognito == true);
				QuestionsManager.complain(qVO.uid, ChatManager.getCurrentChat().uid, ChatManager.getCurrentChat().chatSecurityKey, reason, type, incognito);
				TweenMax.delayedCall(1, showConfirmStopDialog, [alertTitle, alertText], true);
			} else {
				TweenMax.delayedCall(1, showConfirmComplainDialog, [alertTitle, alertText, reason, type], true);
			}
		}
		
		private function showConfirmComplainDialog(alertTitle:String, alertText:String, reason:String, type:String):void {
			currentComplainReason = reason;
			currentType = type;
			DialogManager.alert(alertTitle, alertText, confirmComplainDialogResponse, Lang.textOk, Lang.textCancel);
		}
		
		private function confirmComplainDialogResponse(value:int):void {
			if (value != 1)
				return;
			var qVO:QuestionVO = ChatManager.getCurrentChat().getQuestion();
			if (qVO == null  || qVO.user == null) {
				return;
			} else {
				var incognito:Boolean = (qVO.userUID == Auth.uid && qVO.incognito == true);
				QuestionsManager.complain(qVO.uid, ChatManager.getCurrentChat().uid, ChatManager.getCurrentChat().chatSecurityKey, currentComplainReason, currentType, incognito);
				ChatManager.closeChat();
				onBack();
			}
			currentComplainReason = null;
			currentType = null;
		}
		
		private function showConfirmStopDialog(alertTitle:String, alertText:String):void {
			DialogManager.alert(alertTitle, alertText, confirmStopDialogResponse, Lang.textOk, null, null, TextFormatAlign.LEFT, false, .3, false, null, 4);
		}
		
		private function confirmStopDialogResponse(value:int):void {
			ChatManager.closeChat();
			onBack();
		}
		
		public function subscribe():void {
			if (ChatManager.getCurrentChat() != null && ChatManager.getCurrentChat().type == ChatRoomType.CHANNEL) {
				ChannelsManager.subscribe(ChatManager.getCurrentChat().uid, onSubscribeResult);
			}
		}
		
		private function onSubscribeResult(success:Boolean, uid:String, message:String = null):void {
			if (success) {
				message = Lang.channelSubscribeSuccess;
			}
			ToastMessage.display(message);
		}
		
		public function unsubscribe():void {
			if (ChatManager.getCurrentChat() != null && ChatManager.getCurrentChat().type == ChatRoomType.CHANNEL) {
				ChannelsManager.unsubscribe(ChatManager.getCurrentChat().uid, onUnsubscribeResult);
			}
		}
		
		private function onUnsubscribeResult(success:Boolean, uid:String, message:String = null):void {
			if (success) {
				message = Lang.channelUnsubscribeSuccess;
			}
			ToastMessage.display(message);
		}
		
		// GETTERS -> //
		private function get chatData():ChatScreenData {
			return data as ChatScreenData;
		}
		
		public function hideVerificationButton():void
		{
			if (verificationButton != null)
			{
				view.removeChild(verificationButton);
				verificationButton.dispose();
				verificationButton = null;
			}
			setChatListSize();
		}
		

		public function setVerificationButtonProgress():void{
			if (verificationButton != null)
			{
				verificationButton.animateProgress();
			}
		}
		
		public function showVerificationButton(type:String = "ready", stepsLoaded:Boolean = false, needBirthdate:Boolean = false):void {
			if (stepsLoaded == false && type!="payCard" && type!="invoice") {
				loadSteps(type);
				return;
			} else {
				/*if (needBirthdate == true) {
					type = "show_phaze";
				}*/
			}
			var text:String = "";
			var buttonColor:Number = AppTheme.RED_MEDIUM;
			switch(type) {
				case "ready": {
					text = Lang.pressToStartVerification;
					break;
				}
				case "suspend": {
					buttonColor = AppTheme.GREY_MEDIUM;
					text = Lang.letsDoVerificationLater;
					break;
				}
				case "payCard": {
					buttonColor = AppTheme.GREEN_MEDIUM;
					text = Lang.makeACardPayment;
					break;
				}
				case "invoice": {
					buttonColor = AppTheme.GREEN_MEDIUM;
					text = data.additionalData.buttonText;
					break;
				}
				case "notary": {
					text = Lang.pressToStartVerification;
					break;
				}
				case "viAppointment": {
					if (Calendar.viAppointmentData != null && Calendar.viAppointmentData.date != null && Calendar.viAppointmentData.success) {
						var current:Date = new Date();
						var vi:Date = Calendar.viAppointmentData.date;
						buttonColor = AppTheme.GREEN_MEDIUM;
						var dateString:String = Calendar.viAppointmentData.date.getDate().toString() + " " + Lang.getMonthTitleByIndex(Calendar.viAppointmentData.date.getMonth()) + " " + Calendar.viAppointmentData.date.getFullYear().toString() + ", ";
						var minutes:String = Calendar.viAppointmentData.date.getMinutes().toString();
						if (minutes.length == 1) {
							minutes = "0" + minutes;
						}
						var hours:String = Calendar.viAppointmentData.date.getHours().toString();
						if (hours.length == 1) {
							hours = "0" + hours;
						}
						var timeString:String = hours + ":" + minutes;
						text = Lang.appointmentTime + " " + dateString + timeString;
					} else {
						if (Calendar.viAppointmentData == null || Calendar.viAppointmentData.date == null || Calendar.viAppointmentData.success == false) {
							if (Calendar.viAppointmentData != null && Calendar.viAppointmentData.success == true && Calendar.viAppointmentData.exist == false) {
								text = Lang.phazeError;
								//!TODO: check phaze on server;
							} else {
								Calendar.loadAppointmentData();
							}
						}
					}
					break;
				}
			}
			var tmp:int=parseInt(Config.VERSION.replace(/\D/gi,""));
			var updateVersion:Boolean=false;
			if(tmp<Config.MIN_VERSION) {
				text=Lang.pleaseUpdateVersion;
				updateVersion=true;
			}
			if (verificationButton == null) {
				verificationButton = new LoadingRectangleButton(Lang.textOk, buttonColor, type);
				verificationButton.setStandartButtonParams();
				verificationButton.setDownScale(1);
				verificationButton.setDownColor(0);
				if(updateVersion) {
					verificationButton.tapCallback = updateAppVersion;
				} else {
					verificationButton.tapCallback = onVerificationButtonTap;
				}
				verificationButton.disposeBitmapOnDestroy = true;
				verificationButton.show();
				_view.addChild(verificationButton);
				verificationButton.setWidth(_width);
				if (chatInput != null) {
					verificationButton.y = chatInput.getView().y - verificationButton.height;
				} else {
					verificationButton.y = Config.FINGER_SIZE - verificationButton.height;
				}
				if (_isActivated) {
					verificationButton.activate();
				}
			}
			verificationButton.type = type;
			verificationButton.setColor(buttonColor);
			verificationButton.setValue(text);
			if (type == "show_phaze") {
				var phaze:String = Auth.bank_phase;
				if (needBirthdate == true) {
					phaze = BankPhaze.DOCUMENT_SCAN;
				}
				verificationButton.showPhaze(phaze);
			}
			setChatListSize();
		}
		
		private function loadSteps(type:String):void 
		{
			PHP.getRegistrationSteps(onRegistrationStepsLoaded, type);
		}
		
		private function onRegistrationStepsLoaded(respond:PHPRespond):void 
		{
			if (isDisposed == true)
			{
				respond.dispose();
				return;
			}
			if (respond.error == true)
			{
				ToastMessage.display(ErrorLocalizer.getText(respond.errorMsg));
			}
			else
			{
				var needBirthDate:Boolean;
				/*if ("needBirthDate" in respond.data && respond.data.needBirthDate == true)
				{
					needBirthDate = true;
				}
				else
				{
					needBirthDate = false;
				}*/

				if (respond.additionalData != null && "type" in respond.additionalData)
				{
					showVerificationButton(respond.additionalData.type, true, needBirthDate);
				}
			}
			respond.dispose();
		}
		
		private function updateAppVersion():void{
			var url:URLRequest=null;
			if(Config.PLATFORM_APPLE)
				url=new URLRequest("https://apps.apple.com/app/apple-store/id830583192");
					else
						url=new URLRequest("https://play.google.com/store/apps/details?id=air.com.iswfx.connect");
			navigateToURL(url);
		}
		
		/*private function clearWaitingTimeout():void {
			TweenMax.killDelayedCallsTo(showFastTrackProposal);
		}*/
		
		/*private function startWaitingTimeout():void {
			if (Config.FAST_TRACK == true && lastLoyaltyStatus != "gold" && lastLoyaltyStatus != "fast" && Auth.bank_phaseData != null && Auth.bank_phaseData.toUpperCase() == "MCA") {
				TweenMax.delayedCall(Config.FAST_TRACK_PROPOSAL_DELAY * 60, showFastTrackProposal);
			}
		}*/
		
		/*private function showFastTrackProposal():void {
			Store.load(Store.NOT_SHOW_FAST_TRACK_PROPOSAL, onFastTrackNotShowLoaded);
		}*/
		
		/*private function onFastTrackNotShowLoaded(data:String, error:Boolean):void {
			if (data == null || error == true || data != "true") {
				DialogManager.showDialog(QueuePopup, {queueLength:currentQueue, queueTime:currentQueue * 5, startVI:null});
			}
		}*/
		
		/*private function onFastTrackProposal(val:int, doNotShowAgain:Boolean):void {
			if (val == 1 && Auth.bank_phase.toLowerCase() == "vidid_ready" && lastLoyaltyStatus != "gold" && lastLoyaltyStatus != "fast") {
				TweenMax.delayedCall(1, showFastTrack, null, true);
			}
			if (doNotShowAgain == true) {
				Store.save(Store.NOT_SHOW_FAST_TRACK_PROPOSAL, "true");
			}
		}*/
		
		//private function showFastTrack():void {
			//if (isDisposed == true)
				//return;
			//DialogManager.showDialog(QueuePopup, {queueLength:currentQueue, queueTime:currentQueue * 5, startVI:readyForVIDID } );
		//}
		
		private function enableVididButton():void
		{
			TweenMax.killDelayedCallsTo(enableVididButton);
			if (verificationButton != null)
			{
				verificationButton.activate();
			}
		}
		
		private function onVerificationButtonTap():void {
			TweenMax.killDelayedCallsTo(enableVididButton);
			if (verificationButton != null)
			{
				verificationButton.deactivate();
				TweenMax.delayedCall(1, enableVididButton);
			}
			/*if (Config.isAdmin()){
				MobileGui.changeMainScreen(VideoidentificationChatScreen, {chatUID:ChatManager.getCurrentChat().uid});
				return;
			}*/
			if (verificationButton.type == "payCard") {
				var giftData:GiftData = new GiftData();
				giftData.type = GiftType.MONEY_TRANSFER;
				giftData.addConfirmDialog = true;
				Gifts.startSendMoney(giftData);
				//data.payCard = false;
				//hideVerificationButton();
				return;
			}
			
			if (verificationButton.type == "invoice") {
				if (data != null && "additionalData" in data && data.additionalData != null)
				{
					var addInvoiceAction:AddInvoiceAction = new AddInvoiceAction();
					var invoiceData:Object = data.additionalData;
					if ("amount" in invoiceData)
					{
						addInvoiceAction.amount = invoiceData.amount;
					}
					if ("currency" in invoiceData)
					{
						addInvoiceAction.currency = invoiceData.currency;
					}
					if ("comment" in invoiceData)
					{
						addInvoiceAction.comment = invoiceData.comment;
					}
					if ("confirm" in invoiceData)
					{
						addInvoiceAction.confirm = invoiceData.confirm;
					}

					currentInvoiceAction = addInvoiceAction;
					currentInvoiceAction.disposeAction = false;
					currentInvoiceAction.blockInputs = true;
					addInvoiceAction.setData(Lang.sendInvoice);
					addInvoiceAction.S_ACTION_SUCCESS.add(invoiceSent);
					addInvoiceAction.S_ACTION_FAIL.add(invoiceSentFail);
					addInvoiceAction.execute();


				}
				else
				{
					ApplicationErrors.add();
				}

				return;
			}

			if (verificationButton.type=="show_phaze")
			{
				MobileGui.showRoadMap();
				return;
			}
			
			/*if(verificationButton.type=="notary"){
				// ask for notary
				if (Config.FAST_TRACK == true) {
					DialogManager.showDialog(QueueUnderagePopup);
					return;
				}
			}*/
			
			if (verificationButton.type == "viAppointment") {
				if (Auth.bank_phase.toLocaleLowerCase() == "vidid_queue" &&
					Calendar.viAppointmentData != null &&
					Calendar.viAppointmentData.date != null &&
					Calendar.viAppointmentData.success) {
						var current:Date = new Date();
						var vi:Date = Calendar.viAppointmentData.date;
						if (Math.abs(vi.getTime() - current.getTime()) < 10 * 60 * 1000 && vi.getTime() - current.getTime() < 0) {
							tryReadyForVDID();
							return;
						}
				}
				DialogManager.showDialog(RecognitionDateRemindPopup, null);
				return;
			}
			if (verificationButton.type == "suspend"){
				setVerificationButtonProgress();
				ChatManager.cancelVIDID(
					function(val:Boolean):void {
						vididBusy = false;
						if (val == true)
							showVerificationButton();
					}
				);
				return;
			}
			/*if (Config.BARABAN == true) {
				loadQueue();
			} else {
				tryReadyForVDID();
			}*/
			
			readyForVIDID();
		}
		
		private function invoiceSent():void
		{
			if (data != null)
			{
				data.additionalData = null;
			}
			hideVerificationButton();
			if (currentInvoiceAction != null)
			{
				currentInvoiceAction.S_ACTION_SUCCESS.remove(invoiceSent);
				currentInvoiceAction.S_ACTION_FAIL.remove(invoiceSentFail);
				currentInvoiceAction.dispose();
				currentInvoiceAction = null;
			}
		}

		private function invoiceSentFail():void
		{
			if (currentInvoiceAction != null)
			{
				currentInvoiceAction.S_ACTION_SUCCESS.remove(invoiceSent);
				currentInvoiceAction.S_ACTION_FAIL.remove(invoiceSentFail);
				currentInvoiceAction.dispose();
				currentInvoiceAction = null;
			}
		}

		/*private function loadQueue():void {
			if (Calendar.viAppointmentData != null && Calendar.viAppointmentData.date != null && Calendar.viAppointmentData.success) {
				var current:Date = new Date();
				var vi:Date = Calendar.viAppointmentData.date;
				if (Math.abs(vi.getTime() - current.getTime()) < 10 * 60 * 1000){
					tryReadyForVDID();
				} else {
					DialogManager.showDialog(RecognitionDateRemindPopup, null);
				}
			} else {
				showPreloader();
				WSClient.S_IDENTIFICATION_QUEUE.add(onQueueLoaded);
				WSClient.call_getIdentificationQueue();
			}
		}*/
		
		/*private function onQueueLoaded(current:int):void {
			hidePreloader();
			currentQueue = current;
			if (vididBusy == true)
				return;
			vididBusy = true;
			WSClient.S_IDENTIFICATION_QUEUE.remove(onQueueLoaded);
			if (Calendar.appointmentUnavaliable) {
				tryReadyForVDID();
				return;
			}
			if (Auth.bank_phaseData != null && Auth.bank_phaseData.toUpperCase() == "MCA") {
				checkVipStatus();
			} else {
				readyForVIDID();
			}
		}*/
		
		/*private function checkVipStatus():void {
			showPreloader();
			PHP.call_loyaltyCheck(onLoyaltyCheck);
		}*/
		
		/*private function onLoyaltyCheck(respond:PHPRespond):void {
			hidePreloader();
			vididBusy = false;
			if (isDisposed == true) {
				respond.dispose();
				return;
			}
			if (respond.error == true) {
				Store.load(Store.LOYALTY_PENDING, onLoyaltyLocalLoaded);
			} else {
				lastLoyaltyStatus = respond.data as String;
				if (respond.data == "gold") {
					tryReadyForVDID();
				} else if(respond.data == "fast") {
					tryReadyForVDID();
				} else {
					Store.load(Store.LOYALTY_PENDING, onLoyaltyLocalLoaded);
				}
			}
			respond.dispose();
		}*/
		
		/*private function onLoyaltyLocalLoaded(data:String = null, error:Boolean = false):void {
			if (isDisposed == true)
				return;
			if (error == false && data != null) {
				if (!isNaN(Number(data)) && (new Date()).getTime() - Number(data) < 5 * 60 * 1000) {
					DialogManager.alert(Lang.fastTrack, Lang.fastTrackInProgress);
				} else {
					checkQueue();
				}
			} else {
				checkQueue();
			}
		}*/
		
		/*private function checkQueue():void {
			if (Config.FAST_TRACK == true && lastLoyaltyStatus != "gold" && lastLoyaltyStatus != "fast" && Auth.bank_phase.toLocaleLowerCase() == "notary") {
				DialogManager.showDialog(QueueUnderagePopup);
				vididBusy = false;
				return;
			}
			ChatManager.checkForQueueMax(currentQueue, onMaxChecked);
		}*/
		
		/*private function onMaxChecked(val:Boolean):void {
			if (val == true) {
				readyForVIDID();
				return;
			}
			vididBusy = false;
			tryFastTrack();
		}*/
		
		/*private function tryFastTrack():void {
			if (Config.FAST_TRACK == true) {
				DialogManager.showDialog(QueuePopup, { queueLength:currentQueue, queueTime:currentQueue * 5, startVI:readyForVIDID } );
			} else {
				openCalendar();
			}
		}*/
		
		/*private function openCalendar():void {
			DialogManager.showDialog(SelectRecognitionDatePopup, null);
		}*/
		
		private function tryReadyForVDID():void {
			if (Config.PASS_PHOTO == false && Config.isAdmin() == false) {
				tryReadyForVDID();
				return;
			}
			/*var tme:Number = new Date().getTime();
			if (tme - scannPassTime > 5 * 60 * 1000) {
				scannPassTime = tme;
				scanPassport();	
				return;
			}*/
			readyForVIDID();
		}
		
		private function readyForVIDID():void {
			setVerificationButtonProgress();
			ChatManager.readyForVIDID(
				function(val:Boolean):void {
					vididBusy = false;
					if (val == true)
						showVerificationButton("suspend");
				}
			);
		}
		
		protected function scanPassport():void {
			DialogManager.showDialog(ScanPassportPopup, { callback:onScanResult } );
		}
		
		protected function onScanResult(result:ScanPassportResult):void {
			vididBusy = false;
			if (result.success == true) {
				onImageUploadReady(true, result.photo, "Passport_photo");
				tryReadyForVDID();
			}
		}
	}
}