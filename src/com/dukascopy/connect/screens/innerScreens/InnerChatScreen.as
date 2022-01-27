package com.dukascopy.connect.screens.innerScreens {
	
	import assets.NumericKeyboardIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.ChatVOAction;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.customActions.CreateChatAction;
	import com.dukascopy.connect.data.screenAction.customActions.Open911ScreenAction;
	import com.dukascopy.connect.data.screenAction.customActions.SendTradeNotesRequestAction;
	import com.dukascopy.connect.gui.components.StatusClip;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.List;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.gui.list.renderers.ListCallRenderer;
	import com.dukascopy.connect.gui.list.renderers.ListConversation;
	import com.dukascopy.connect.gui.list.renderers.ListLink;
	import com.dukascopy.connect.gui.menuVideo.HidableButton;
	import com.dukascopy.connect.gui.tabs.FilterTabs;
	import com.dukascopy.connect.gui.tools.HorizontalPreloader;
	import com.dukascopy.connect.screens.ChatScreenBankInfo;
	import com.dukascopy.connect.screens.EscrowAdsCreateScreen;
	import com.dukascopy.connect.screens.QuestionCreateUpdateScreen;
	import com.dukascopy.connect.screens.RootScreen;
	import com.dukascopy.connect.screens.SearchChannelCategoryScreen;
	import com.dukascopy.connect.screens.UserProfileScreen;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.base.ScreenManager;
	import com.dukascopy.connect.screens.channel.CreateChannelDisclaimerScreen;
	import com.dukascopy.connect.screens.dialogs.ScreenLinksDialog;
	import com.dukascopy.connect.screens.userProfile.StartChatByPhoneScreen;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.bankManager.BankManager;
	import com.dukascopy.connect.sys.callManager.CallManager;
	import com.dukascopy.connect.sys.callManager.CallsHistoryManager;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.chatManager.typesManagers.AnswersManager;
	import com.dukascopy.connect.sys.chatManager.typesManagers.ChannelsManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.notifier.NewMessageNotifier;
	import com.dukascopy.connect.sys.payments.PayAPIManager;
	import com.dukascopy.connect.sys.questionsManager.QuestionsManager;
	import com.dukascopy.connect.sys.socialManager.SocialManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.sys.usersManager.OnlineStatus;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.sys.usersManager.paidBan.PaidBan;
	import com.dukascopy.connect.sys.ws.WS;
	import com.dukascopy.connect.type.ChatInitType;
	import com.dukascopy.connect.type.ChatRoomType;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.vo.CallsHistoryItemVO;
	import com.dukascopy.connect.vo.ChatVO;
	import com.dukascopy.connect.vo.screen.ChatScreenData;
	import com.dukascopy.connect.vo.users.adds.ChatUserVO;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import flash.desktop.NativeApplication;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision AG.
	 */
	
	public class InnerChatScreen extends BaseScreen {
		
		static public const TAB_CHATS:String = "chat";
		static public const TAB_CHANNELS:String = "channels";
		static public const TAB_911:String = "911";
		static public const TAB_HELP:String = "help";
		static public const TAB_PRIVATE:String = "tabPrivate";
		static public const TAB_GROUP:String = "tabGroup";
		static public const TAB_CALLS:String = "calls";
		
		private var tabs:FilterTabs;
		private var list:List;
		
		private var allData:Array;
		private var privateData:Array;
		private var groupData:Array;
		private var helpData:Array;
		private var queData:Array;
		private var channelsData:Array;
		
		private var _messagesLoaded:Boolean = false;
		private var selectedFilter:String = TAB_CHATS;
		
		private var doLoadLatests:Boolean = true;
		private var doLoadChannels:Boolean = true;
		private var doLoadAnswers:Boolean = true;
		private var doLoadCalls:Boolean = true;
		
		private var emptyClip:Bitmap;
		private var listPosition:int;
		
		private var createChatButton:HidableButton;
		private var phoneIcon:NumericKeyboardIcon;
		private var searchIcon:SWFSearchChannelButton;
		private var addQuestionIcon:Sprite;
		
		private static var needToRefreshAfterScrollStoped:Boolean = false;
		private var statusClip:StatusClip;
		
		private var callsData:Vector.<CallsHistoryItemVO>;
		private var num:int = 0;
		static private var storedTabListPosition:Object = {};
		static private var storedTabListPositionCreated:Boolean;
		private var lastSelectedFilter:String;
		private var needToScrollTop:Boolean;
		private var i:int = 0;
		private var messagePreloader:HorizontalPreloader;
		
		public function InnerChatScreen() { }
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			_params.title = 'Inner chat screen';
			_params.actions = getScreenActions();
			_params.doDisposeAfterClose = false;
			Auth.S_AUTH_DATA_UPDATED.add(onEntrypointsUpdated);
			
			createChatButton.setPosition(_width - Config.FINGER_SIZE - Config.MARGIN * 2,  _height - Config.FINGER_SIZE - Config.MARGIN * 2);
			createChatButton.setOffset(Config.TOP_BAR_HEIGHT * 2 + Config.APPLE_TOP_OFFSET);
			
			lastSelectedFilter = selectedFilter;
			
			if (PaidBan.isAvaliable()) {
				PaidBan.S_USER_BAN_UPDATED.add(onUserBanChange);
			}
			
			//!TODO:;
			SendTradeNotesRequestAction.S_SUCCESS.add(onLatestLoaded);
			NewMessageNotifier.S_UPDATE.add(onChatNewMessagesUpdate);
			NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, onActivateApplication);
			
			ChatManager.S_SERVER_DATA_LOAD_START.add(onServerDataLoadStart);
			ChatManager.S_SERVER_DATA_LOAD_END.add(onServerDataLoadEnd);
			
			messagePreloader.setSize(_width, int(Config.FINGER_SIZE * .06));
		}
		
		private function onChatNewMessagesUpdate(chatUIDs:Array = null):void {
			updateUnreaded();
		}
		
		private function onUserBanChange(userUID:String = null):void {
			refreshList();
		}
		
		private function refreshList():void {
			if (_isDisposed == true)
				return;
			if (list != null)
				list.refresh();
		}
		
		private function updateCreateChatButtonPosition(time:Number = 0):void {
			
		}
		
		private function onEntrypointsUpdated():void {
		//	onLatestLoaded();
		}
		
		private function getScreenActions():Vector.<IScreenAction> {
			var array:Vector.<IScreenAction> = new Vector.<IScreenAction>();
			
			var createGroupChatAction:IScreenAction = new CreateChatAction();
			array.push(createGroupChatAction);
			
			var open911ScreenAction:IScreenAction = new Open911ScreenAction();
			array.push(open911ScreenAction);
			
			return array;
		}
		
		override protected function createView():void {
			super.createView();	
			echo("InnerChatScreen", "createView", "");
			list = new List("Chat");
			list.setContextAvaliable(true);
			list.backgroundColor = Style.color(Style.COLOR_BACKGROUND);
			list.background = true;
			_view.addChild(list.view);
			createTabs ();
			createChatButton = new HidableButton();
			createChatButton.tapCallback = onBottomButtonTap;
			_view.addChild(createChatButton);
			
			if (storedTabListPositionCreated == false) {
				storedTabListPositionCreated = true;
				storedTabListPosition[TAB_CHATS] = {};
				storedTabListPosition[TAB_CHANNELS] = {};
				storedTabListPosition[TAB_911] = {};
				storedTabListPosition[TAB_HELP] = {};
				storedTabListPosition[TAB_PRIVATE] = {};
				storedTabListPosition[TAB_GROUP] = {};
				storedTabListPosition[TAB_CALLS] = {};
			}
			
			messagePreloader = new HorizontalPreloader(Color.BLUE_LIGHT);
			_view.addChild(messagePreloader);
		}
		
		private function createTabs ():void {
			tabs = new FilterTabs();
			tabs.add(Lang.textChats, TAB_CHATS, true, "l");
			tabs.add(Lang.calls, TAB_CALLS);
			if (SocialManager.available == true)
				tabs.add(Lang.title_911, TAB_911);
			tabs.add(Lang.textHelp, TAB_HELP, false, "r");
			_view.addChild(tabs.view);
		}
		
		override public function drawViewLang():void {
			tabs.dispose();
			createTabs();
			tabs.setWidthAndHeight(_width, Config.TOP_BAR_HEIGHT);
			if (tabs != null) {
				if (tabs.S_ITEM_SELECTED != null)
					tabs.S_ITEM_SELECTED.add(onTabItemSelected);
				tabs.activate();
			}
			tabs.setSelection(selectedFilter);
		}
		
		private function onActivateApplication(e:Event):void {
			if (selectedFilter == TAB_CHATS && isActivated)
			{
				setListData();
			}
		}
		
		private function onBottomButtonTap():void {			
			// if current seection
			if (selectedFilter == TAB_CHATS) { // start chat with user
				MobileGui.changeMainScreen(StartChatByPhoneScreen, { data:null, backScreen:RootScreen, backScreenData:null } );
				return;
			}			
			if (selectedFilter == TAB_CHANNELS) {// search channel		
				MobileGui.changeMainScreen(SearchChannelCategoryScreen, { data:null, backScreen:RootScreen, backScreenData:null } );
				return;
			}
			if (selectedFilter == TAB_911) {// ask question		
				//MobileGui.changeMainScreen(SearchChannelScreen, { data:null, backScreen:RootScreen, backScreenData:null } );
				//return;
				if (QuestionsManager.checkForUnsatisfiedQuestions() == true) {
					DialogManager.alert(Lang.information, Lang.limitQuestionExists);
					echo("InnerChatScreen", "onBottomButtonTap", "START QUESTION FAIL LIMIT");
					return;
				}
				MobileGui.changeMainScreen(EscrowAdsCreateScreen, {
						backScreen:RootScreen,
						title:Lang.escrow_create_your_ad, 
						backScreenData:null,
						data:null
					}, ScreenManager.DIRECTION_RIGHT_LEFT
				);
				return;
			}
			if (selectedFilter == TAB_HELP) {				
				return;
			}
		}
		
		private function setButtonDesign(id:String):void{
			if (id == TAB_CHATS) {
				phoneIcon ||= new NumericKeyboardIcon();
				createChatButton.setDesign(phoneIcon);	
				createChatButton.visible = true;
				return;
			}			
			if (id == TAB_CHANNELS) {	
				searchIcon ||= new SWFSearchChannelButton();
				createChatButton.setDesign(searchIcon);	
				createChatButton.visible = true;
				return;
			}
			if (id == TAB_911) {
				addQuestionIcon ||= new CreateButtonIcon();
				createChatButton.setDesign(addQuestionIcon);
				createChatButton.visible = true;
				return;
			}
			if (id == TAB_HELP) {
				createChatButton.visible = false;
				return;
			}
			if (id == TAB_CALLS) {
				createChatButton.visible = false;
				return;
			}
		}
		
		private function disposeIcons():void {
			phoneIcon = null;
			searchIcon = null;
			addQuestionIcon = null;			
		}
		
		override protected function drawView():void {
			echo("InnerChatScreen", "drawView", "");
			
			if (statusClip != null) {
				statusClip.setSize(_width, Config.FINGER_SIZE * .6);
				statusClip.y = _height;
			}
			
			tabs.setWidthAndHeight(_width, Config.TOP_BAR_HEIGHT);
			list.view.y = tabs.height;
			messagePreloader.y = tabs.height;
			
			list.setWidthAndHeight(_width, _height - list.view.y);
			
			createChatButton.setPosition(_width - Config.FINGER_SIZE - Config.MARGIN * 2,  _height - Config.FINGER_SIZE - Config.MARGIN * 2);
			createChatButton.setOffset(MobileGui.stage.stageHeight - _height);
			
			//updateUnreaded();
		}
		
		private function updateUnreaded(refreshList:Boolean = true):void {
			if (tabs == null || list == null)
			{
				return;
			}
			
			num++;
			var exist:Boolean = false;
			var newMessagesChats:int = NewMessageNotifier.getUnreaded(NewMessageNotifier.type_LATEST, ChatRoomType.PRIVATE + "," + ChatRoomType.GROUP);
			if (newMessagesChats > 0) {
				exist = true;
				tabs.selectNotification(TAB_CHATS, true);
			} else {
				tabs.selectNotification(TAB_CHATS, false);
			}
			if (SocialManager.available == true) {
				var newMessages911:int = NewMessageNotifier.getUnreaded(NewMessageNotifier.type_911);
				if (newMessages911 > 0) {
					exist = true;
					tabs.selectNotification(TAB_911, true);
				} else {
					tabs.selectNotification(TAB_911, false);
				}
			}
			var newMessagesHelp:int = NewMessageNotifier.getUnreaded(NewMessageNotifier.type_LATEST, ChatRoomType.COMPANY);
			if (newMessagesHelp > 0) {
				exist = true;
				tabs.selectNotification(TAB_HELP, true);
			} else {
				tabs.selectNotification(TAB_HELP, false);
			}
			if (refreshList == true && list != null)
			{
				list.refresh();
			}
			
			NewMessageNotifier.S_UPDATE_EXIST.invoke(exist);
		}
		
		override public function clearView():void {
			super.clearView();
			if (tabs != null)
				tabs.dispose();
			tabs = null;
			
			if (list != null) {
				if (list.getBoxY() < 0) {
					storedTabListPosition[selectedFilter].listBoxY = list.getBoxY();
					var fli:ListItem = list.getFirstVisibleItem();
					if (fli != null) {
						storedTabListPosition[selectedFilter].item = list.getFirstVisibleItem().data;
						storedTabListPosition[selectedFilter].offset = fli.y + storedTabListPosition[selectedFilter].listBoxY;
					}
					list.dispose();
				} else if ("item" in storedTabListPosition[selectedFilter] == true) {
					delete storedTabListPosition[selectedFilter].item;
					delete storedTabListPosition[selectedFilter].offset;
					delete storedTabListPosition[selectedFilter].listBoxY;
				}
			}
			
			if (list != null)
				list.dispose();
			list = null;
			if (createChatButton)
				createChatButton.dispose();
			createChatButton = null;
			if (statusClip != null)
				statusClip.destroy();
			statusClip = null;
			
			if (messagePreloader != null)
				messagePreloader.dispose();
			messagePreloader = null;
		}
		
		override public function dispose():void {
			echo("InnerChatScreen", "dispose", "");	
			
			super.dispose();
			
			NativeApplication.nativeApplication.removeEventListener(Event.ACTIVATE, onActivateApplication);
			selectedFilter = "all";
			lastSelectedFilter = selectedFilter;
			ChatManager.S_LATEST.remove(onLatestLoaded);
			ChatManager.S_LATEST_OVERRIDE.remove(onLatestLoaded);
			ChatManager.S_LATEST_REPOSITION.remove(onLatestLoaded);
			ChatManager.S_CHAT_UPDATED.remove(onChatUpdated);
			ChatManager.S_CHAT_UNREADED_UPDATED.remove(onChatUpdated);
			ChannelsManager.S_CHANNELS.remove(onChannelsUpdated);
			ChannelsManager.S_CHANNEL_UPDATED.remove(onChatUpdated);
			AnswersManager.S_ANSWERS.remove(onAnswersUpdated);
			//WS.S_CONNECTED.remove(onWSConnected);
			Auth.S_NEED_AUTHORIZATION.remove(onAuthNeedAuthorization);
			UsersManager.S_OFFLINE_ALL.remove(onAllUsersOffline);
			UsersManager.S_ONLINE_STATUS_LIST.remove(onUserlistOnlineStatusChanged);
			UsersManager.S_ONLINE_CHANGED.remove(onUserOnlineStatusChanged);
			PaidBan.S_USER_BAN_UPDATED.remove(onUserBanChange);
			CallsHistoryManager.S_CALLS.remove(onCallsUpdated);
			NewMessageNotifier.S_UPDATE.remove(onChatNewMessagesUpdate);
			SendTradeNotesRequestAction.S_SUCCESS.remove(onLatestLoaded);
			Auth.S_AUTH_DATA_UPDATED.remove(onEntrypointsUpdated);
			
			ChatManager.S_SERVER_DATA_LOAD_START.remove(onServerDataLoadStart);
			ChatManager.S_SERVER_DATA_LOAD_END.remove(onServerDataLoadEnd);
			TweenMax.killDelayedCallsTo(onServerDataLoadEnd);
		}
		
		private function onCallsUpdated():void {
			echo("InnerChatScreen", "onChannelsUpdated", "");
			if (_isDisposed || !_isActivated) {
				doLoadCalls = true;
				return;
			}
			doLoadCalls = false;
			callsData = null;
			if (selectedFilter == TAB_CALLS)
				setListData();
		}
		
		private function onChannelsUpdated():void {
			echo("InnerChatScreen", "onChannelsUpdated", "");
			if (_isDisposed || !_isActivated) {
				doLoadChannels = true;
				return;
			}
			doLoadChannels = false;
			channelsData = null;
			if (selectedFilter == TAB_CHANNELS)
				setListData();
		}
		
		private function onAnswersUpdated():void {
			echo("InnerChatScreen", "onAnswersUpdated", "");
			if (_isDisposed || !_isActivated) {
				doLoadAnswers = true;
				return;
			}
			doLoadAnswers = false;
			queData = null;
			if (selectedFilter == TAB_911)
				setListData();
		}
		
		override public function activateScreen():void {
			echo("InnerChatScreen", "activateScreen", "");
			super.activateScreen();
			if (_isDisposed)
				return;
			if (list != null) {
				list.activate();
				list.S_ITEM_HOLD.add(onItemHold);
				list.S_ITEM_TAP.add(onItemTap);
				//updating read/unread states on renderers
				list.S_STOPED.add(onScrollStopped);
			}
			if (tabs != null) {
				if (tabs.S_ITEM_SELECTED != null)
					tabs.S_ITEM_SELECTED.add(onTabItemSelected);
				tabs.activate();
			}
			
			if (createChatButton != null)
				createChatButton.activate();
			
			UsersManager.S_OFFLINE_ALL.add(onAllUsersOffline);
			UsersManager.S_ONLINE_STATUS_LIST.add(onUserlistOnlineStatusChanged);
			UsersManager.S_ONLINE_CHANGED.add(onUserOnlineStatusChanged);
			
			ChatManager.S_LATEST.add(onLatestLoaded);
			ChatManager.S_LATEST_OVERRIDE.add(onLatestLoaded);
			ChatManager.S_LATEST_REPOSITION.add(resetPrivateData);
			ChatManager.S_CHAT_UPDATED.add(onChatUpdated);
			ChatManager.S_CHAT_UNREADED_UPDATED.add(onChatUpdated);
			ChannelsManager.S_CHANNELS.add(onChannelsUpdated);
			ChannelsManager.S_CHANNEL_UPDATED.add(onChatUpdated);
			AnswersManager.S_ANSWERS.add(onAnswersUpdated);
			//WS.S_CONNECTED.add(onWSConnected);
			Auth.S_NEED_AUTHORIZATION.add(onAuthNeedAuthorization);
			
			CallsHistoryManager.activate();
			CallsHistoryManager.S_CALLS.add(onCallsUpdated);
			
			var listRefreshed:Boolean = false;
			
			if (selectedFilter == TAB_CHATS && doLoadLatests)
				ChatManager.getChats();
			else if (selectedFilter == TAB_CHANNELS && doLoadChannels)
				ChannelsManager.getChannels();
			else if (selectedFilter == TAB_911 && doLoadAnswers)
				AnswersManager.getAnswers();
			else if (selectedFilter == TAB_CALLS && doLoadCalls)
			{
				CallsHistoryManager.getCalls();
				CallsHistoryManager.markNewAsSeen();
			}
			else if (list != null)
			{
				listRefreshed = true;
				list.refresh();
			}
			
			if (NewMessageNotifier.needUpdate == true)
			{
				NewMessageNotifier.needUpdate = false;
				updateUnreaded(!listRefreshed);
			}
		}
		
		private function resetPrivateData():void {
			privateData = null;
			hardListUpdate();
		}
		
		private function onServerDataLoadStart():void {
			messagePreloader.start();
		//	showLoading();
			TweenMax.killDelayedCallsTo(onServerDataLoadEnd);
			TweenMax.delayedCall(10, onServerDataLoadEnd);
		}
		
		private function showLoading():void {
			if (statusClip == null) {
				statusClip = new StatusClip();
				view.addChild(statusClip);
				statusClip.setSize(_width, Config.FINGER_SIZE * .6);
				statusClip.y = _height;
				if (createChatButton != null && view.contains(createChatButton)) {
					view.setChildIndex(createChatButton, view.numChildren - 1);
				}
			}
			statusClip.show(Lang.updatingConversations);
		}
		
		private function showEmptyClip():void {
			if (emptyClip == null) {
				emptyClip = new Bitmap(new ImageBitmapData("InnerChatScreen.emptyClip", _width, _height - tabs.height, false, 0xFFFFFFFF));
				emptyClip.y = tabs.height;
				var txtSnapshot:BitmapData = UI.renderText(Lang.textChatsNull, _width, 1, true, TextFormatAlign.CENTER, TextFieldAutoSize.CENTER, Config.FINGER_SIZE_DOT_35, true, 0x666666);
				var srcBMD:BitmapData = new SWFChatImage();
				var destScale:Number = UI.getMinScale(srcBMD.width, srcBMD.height, emptyClip.bitmapData.rect.width - Config.FINGER_SIZE, emptyClip.bitmapData.rect.height - Config.FINGER_SIZE * 3 - txtSnapshot.height);
				var img:BitmapData = UI.scaleManual( srcBMD,destScale,true);
				var rect:Rectangle = new Rectangle(0, Config.FINGER_SIZE, txtSnapshot.width, txtSnapshot.height);
				ImageManager.drawImageToBitmap(emptyClip.bitmapData, txtSnapshot, rect, 1);
				emptyClip.bitmapData.copyPixels(img, img.rect, new Point(int((_width - img.rect.width ) * .5), Config.FINGER_SIZE * 2 + txtSnapshot.rect.height));
				srcBMD = null;
				img.dispose();
				img = null;
			}
			if (emptyClip.parent == null)
				view.addChild(emptyClip);
				
			if (createChatButton != null) {
				view.addChild(createChatButton);
			}
		}
		
		private function hideEmptyClip():void {
			if (emptyClip == null)
				return;
			if (emptyClip.parent != null)
				emptyClip.parent.removeChild(emptyClip);
			if (emptyClip.bitmapData != null)
				emptyClip.bitmapData.dispose();
			emptyClip.bitmapData = null;
			emptyClip = null;
		}
		
		private function onAuthNeedAuthorization():void {
			echo("InnerChatScreen", "onAuthNeedAuthorization");
			if (list != null)
				list.setData(null, null);
			doLoadLatests = false;
			doLoadChannels = false;
			doLoadAnswers = false;
			doLoadCalls = false;
			allData = null;
			privateData = null;
			groupData = null;
			helpData = null;
			queData = null;
			channelsData = null;
			doLoadLatests = true;
			if (emptyClip != null && emptyClip.parent != null)
				emptyClip.parent.removeChild(emptyClip);
		}
		
		private function onWSConnected():void {
			if (_isDisposed)
				return;
			if (_isActivated == false) {
				doLoadLatests = true;
				doLoadChannels = true;
				doLoadCalls = true;
				doLoadAnswers = true;
				return;
			}
			if (selectedFilter != TAB_CHANNELS)
				ChatManager.getChats();
			if (selectedFilter == TAB_CHANNELS)
				ChannelsManager.getChannels();
			if (selectedFilter == TAB_911)
				AnswersManager.getAnswers();
			else if (selectedFilter == TAB_CALLS) {
				CallsHistoryManager.getCalls();
				CallsHistoryManager.markNewAsSeen();
			}
		}
		
		override public function deactivateScreen():void {
			echo("InnerChatScreen", "deactivateScreen", "");
			super.deactivateScreen();
			if (_isDisposed)
				return;
			if (list != null) {
				list.deactivate();
				list.S_ITEM_HOLD.remove(onItemHold);
				list.S_ITEM_TAP.remove(onItemTap);
				list.S_STOPED.remove(onScrollStopped);
			}
			if (tabs != null) {
				if (tabs.S_ITEM_SELECTED != null)
					tabs.S_ITEM_SELECTED.remove(onTabItemSelected);
				tabs.deactivate();
			}
			if (createChatButton != null){				
				createChatButton.deactivate();
			}
			
			UsersManager.S_OFFLINE_ALL.remove(onAllUsersOffline);
			UsersManager.S_ONLINE_STATUS_LIST.remove(onUserlistOnlineStatusChanged);
			UsersManager.S_ONLINE_CHANGED.remove(onUserOnlineStatusChanged);
			
			hideStatusClip();
		}
		
		private function onServerDataLoadEnd():void {
			messagePreloader.stop(false);
			TweenMax.killDelayedCallsTo(onServerDataLoadEnd);
		//	hideStatusClip();
		}
		
		private function onUserlistOnlineStatusChanged():void {
			if (list)
				list.refresh();
		}
		
		private function onUserOnlineStatusChanged(status:OnlineStatus, method:String):void {
			if (isDisposed || list == null)
				return;
			var itemData:ChatVO;
			var itemDataCall:CallsHistoryItemVO;
			var needUpdateItem:Boolean;
			if (method == UsersManager.METHOD_OFFLINE_STATUS || method == UsersManager.METHOD_ONLINE_STATUS) {
				var item:ListItem;
				var l:int = list.getStock().length;
				
				for (var j:int = list.getFirstVisibleItemIndex(); j < l; j++) {
					item = list.getItemByNum(j);
					needUpdateItem = false;
					if (item && item.liView && item.liView.visible) {
						if (item.data is ChatVO) {
							itemData = item.data as ChatVO;
							if (itemData.type == ChatRoomType.QUESTION && itemData.getQuestionUserUID() == status.uid)
								needUpdateItem = true;
							else if (itemData.type == ChatRoomType.PRIVATE && itemData.getUser(status.uid) != null)
								needUpdateItem = true;
						}
						if (needUpdateItem) {
							if (list.getScrolling())
								list.refresh();
							else
								item.draw(list.width, !list.getScrolling());
							break;
						}
					} else if (item != null && item.data is CallsHistoryItemVO) {
						itemDataCall = item.data as CallsHistoryItemVO;
						if (itemDataCall.userUID == status.uid) {
							if (list.getScrolling())
								list.refresh();
							else
								item.draw(list.width, !list.getScrolling());
							break;
						}
					}
					break;
				}
				itemData = null;
				item = null;
			}
		}
		
		private function onAllUsersOffline():void {
			if (list)
				list.refresh();
		}
		
		private function onItemTap(data:Object, n:int):void {
			echo("InnerChatScreen", "onItemTap", "");
			
			var item:ListItem = list.getItemByNum(n);
			var itemHitZone:String;
			if (item)
				itemHitZone = item.getLastHitZone();
			
			var chatScreenData:ChatScreenData;
			
			if (data is CallsHistoryItemVO)
			{
				var chiVO:CallsHistoryItemVO = data as CallsHistoryItemVO;
				
				if (itemHitZone == HitZoneType.CALL_USER) {
					if (chiVO.pid > 0) {
						chatScreenData = new ChatScreenData();
						chatScreenData.pid = (data as CallsHistoryItemVO).pid;
						chatScreenData.type = ChatInitType.SUPPORT;
						chatScreenData.backScreen = MobileGui.centerScreen.currentScreenClass;
						MobileGui.showChatScreen(chatScreenData);
						return;
					}
					if (WS.connected == false) {
						DialogManager.alert(Lang.textAttention, Lang.checkNetworkStatus);
						return;
					}
					CallManager.place(chiVO.userUID, RootScreen, data, chiVO.title, chiVO.avatarURL);				
				} else {
					if (chiVO.pid > 0) {
						chatScreenData = new ChatScreenData();
						chatScreenData.pid = (data as CallsHistoryItemVO).pid;
						chatScreenData.type = ChatInitType.SUPPORT;
						chatScreenData.backScreen = MobileGui.centerScreen.currentScreenClass;
						MobileGui.showChatScreen(chatScreenData);
						return;
					}
					
					MobileGui.changeMainScreen(UserProfileScreen, { data:(data as CallsHistoryItemVO).user, backScreen:RootScreen, backScreenData:data } );	
				}
				return;
			}
			
			if (data is ChatVOAction && (data as ChatVOAction).action != null)
			{
				(data as ChatVOAction).action.execute();
				return;
			}
			
			if (!(data is ChatVO))
				return;
			if (itemHitZone) {
				if (itemHitZone == HitZoneType.CALL) {
					var user:ChatUserVO = UsersManager.getInterlocutor(data as ChatVO);
					if (user)
						CallManager.place(user.uid, RootScreen, data, (user.name != null) ? user.name: "", UsersManager.getAvatarImage(user, user.avatarURL, Config.FINGER_SIZE * 1.54));
					return;
				}
				if (itemHitZone == HitZoneType.DELETE) {
					DialogManager.alert(Lang.textConfirm, Lang.alertConfirmLeaveConversation, function(val:int):void {
						if (val != 1)
							return;
						ChatManager.removeUser((data as ChatVO).uid);
					}, Lang.textDelete.toUpperCase(), Lang.textCancel.toUpperCase());
					return;
				}
			}
			
			if (data.type == ChatRoomType.CHANNEL) {
				if (data.uid == null) {
					MobileGui.changeMainScreen(
						CreateChannelDisclaimerScreen,
						{
							backScreen: RootScreen, 
							backScreenData: this.data, 
							data: null
						}
					);
					//ChannelsManager.startNewChannel();
					return;
				}
			}
			/*if (data.type == ChatRoomType.PRIVATE && data.ownerUID == Config.DUKASCOPY_INFO_SERVICE_UID) {
				if (Auth.bank_phase == "ACC_APPROVED" && Config.BANKBOT == true || Auth.companyID == "08A29C35B3") {
					if (PayAPIManager.hasSwissAccount == true) {
						MobileGui.changeMainScreen(MyAccountScreen);
						return
					}
				}
			}*/
			
			// bank info chat///////
			
			if ((data as ChatVO).type == ChatRoomType.PRIVATE && (data as ChatVO).getUser(Config.DUKASCOPY_INFO_SERVICE_UID) != null)
			{
				MobileGui.changeMainScreen(ChatScreenBankInfo, data);
				return;
			}
			
			////////////////////////
			
			chatScreenData = new ChatScreenData();
			chatScreenData.type = ChatInitType.CHAT;
			if (data.uid != null) {
				chatScreenData.chatVO = data as ChatVO;
			} else {
				if ((data as ChatVO).type == ChatRoomType.COMPANY) {
					if (data.pid == -1) {
						MobileGui.openMyAccountIfExist();
						return;
					} else if (data.pid == -2) {
						PayAPIManager.openSwissRTO();
						return;
					} else if (data.pid == -3) {
						MobileGui.openBankBot();
						return;
					} else if (data.pid == -4) {
						BankManager.openMarketPlace();
						return;
					} else if (data.pid == -5) {
						MobileGui.changeMainScreen(StartChatByPhoneScreen, { data: { payCard:true }, backScreen:RootScreen, backScreenData:null } );
						return;
					}
					chatScreenData.pid = (data as ChatVO).pid;
					chatScreenData.type = ChatInitType.SUPPORT;
				}
			}
			
			chatScreenData.backScreen = RootScreen;
			MobileGui.showChatScreen(chatScreenData);
		}
		
		private function onTabItemSelected(id:String):void {
			echo("InnerChatScreen", "onTabItemSelected", "");
			needToRefreshAfterScrollStoped = false;
			
			lastSelectedFilter = selectedFilter;
			
			var otherID:Boolean = lastSelectedFilter != "" && lastSelectedFilter != selectedFilter;
			if (otherID == false && list.getScrolling() == true) {
				needToRefreshAfterScrollStoped = true;
				return;
			}
			
			var listBoxY:int = list.getBoxY();
			
			if (listBoxY < 0) {
				storedTabListPosition[selectedFilter].listBoxY = list.getBoxY();
				var fli:ListItem = list.getFirstVisibleItem();
				if (fli != null) {
					storedTabListPosition[selectedFilter].item = list.getFirstVisibleItem().data;
					storedTabListPosition[selectedFilter].offset = fli.y + storedTabListPosition[selectedFilter].listBoxY;
				}
			} else if ("item" in storedTabListPosition[selectedFilter] == true) {
				delete storedTabListPosition[selectedFilter].item;
				delete storedTabListPosition[selectedFilter].offset;
				delete storedTabListPosition[selectedFilter].listBoxY;
			}
			
			needToScrollTop = !otherID && listBoxY > 0;
			
			selectedFilter = id;
			setButtonDesign(id);
			listPosition = 0;
			if (selectedFilter != TAB_CHANNELS && doLoadLatests) {
				ChatManager.getChats();
				return;
			}
			if (selectedFilter == TAB_CHANNELS && doLoadChannels) {
				list.setData(null, null);
				ChannelsManager.getChannels();
				return;
			}
			if (selectedFilter == TAB_911 && doLoadAnswers) {
				list.setData(null, null);
				AnswersManager.getAnswers();
				return;
			}
			if (selectedFilter == TAB_CALLS && doLoadCalls) {
				list.setData(null, null);
				CallsHistoryManager.getCalls();
				CallsHistoryManager.markNewAsSeen();
				return;
			}
			setListData();
		}
		
		private function onChatUpdated(cvo:ChatVO):void {
			echo("InnerChatScreen", "onChatUpdated", "");
			if (!_isActivated) {
				if (cvo.type == ChatRoomType.CHANNEL)
					doLoadChannels = true
				else if (cvo.type == ChatRoomType.QUESTION)
					doLoadAnswers = true;
				else
					doLoadLatests = true;
				return;
			}
			if (list != null)
				list.updateItem(cvo);
		}
		
		private function onLatestLoaded():void {
			echo("InnerChatScreen", "onLatestLoaded", "");
			if (_isDisposed || !_isActivated) {
				doLoadLatests = true;
				return;
			}
			
			doLoadLatests = false;
			
			hardListUpdate();
		}
		
		private function hardListUpdate():void 
		{
			allData = null;
			privateData = null;
			groupData = null;
			helpData = null;
			queData = null;
			
			updateUnreaded();
			if (selectedFilter != TAB_CHANNELS)
				setListData();
		}
		
		private function onItemHold(data:Object, n:int):void {
			echo("InnerChatScreen", "onItemHold", "");
			if (!(data is ChatVO))
				return;
			var user:ChatUserVO
			var menuItems:Array = [];
			var chatVO:ChatVO = data as ChatVO;
			if (chatVO.type == ChatRoomType.CHANNEL)
				return;
			if (chatVO.type != ChatRoomType.COMPANY)
				menuItems.push( { fullLink:Lang.deleteChat, id:0 } );
			if (chatVO.type == ChatRoomType.PRIVATE)
			{
				user = UsersManager.getInterlocutor(chatVO);
				if (user.uid != Config.NOTEBOOK_USER_UID)
				{
					menuItems.push( { fullLink:Lang.startVideoChat, id:1 } );
				}
			}
			if (menuItems.length == 0)
				return;
			DialogManager.showDialog(ScreenLinksDialog, { callback:function(data:Object):void {
				if (data.id == 1) {
					user = UsersManager.getInterlocutor(chatVO);
					if (user) {
						CallManager.place(
									user.uid, 
									MobileGui.centerScreen.currentScreenClass, 
									data, 
									(user.name != null) ? user.name:"", 
									UsersManager.getAvatarImage(user, user.avatarURL, Config.FINGER_SIZE * 1.54));
					}
					
					return;
				}
				if (data.id == 0) {
					DialogManager.alert(Lang.textConfirm, Lang.alertConfirmLeaveConversation, function(val:int):void {
						if (val != 1)
							return;
						
						ChatManager.removeUser(chatVO.uid);
							
					}, Lang.textDelete.toUpperCase(), Lang.textCancel.toUpperCase());
					return;
				}
			}, data:menuItems, itemClass:ListLink, title:chatVO.title, multilineTitle:false } );
		}
		
		private function onScrollStopped(val:Number):void {
			if (isActivated == false)
				return;
			if (needToRefreshAfterScrollStoped == false)
				return;
			needToRefreshAfterScrollStoped = false;
			setListData();
		}
		
		private function setListData():void {
			if (list == null)
			{
				return;
			}
			
			i++;
			echo("InnerChatScreen", "setListData", "");
			if (list.getScrolling() == true) {
				needToRefreshAfterScrollStoped = true;
				return;
			}
			if (lastSelectedFilter == selectedFilter) {
				var otherID:Boolean = lastSelectedFilter != "" && lastSelectedFilter != selectedFilter;
				if (otherID == false && list.getScrolling() == true) {
					needToRefreshAfterScrollStoped = true;
					return;
				}
				var listBoxY:int = list.getBoxY();
				if (listBoxY < 0) {
					storedTabListPosition[selectedFilter].listBoxY = list.getBoxY();
					var fli:ListItem = list.getFirstVisibleItem();
					if (fli != null && list.getFirstVisibleItem() != null) {
						storedTabListPosition[selectedFilter].item = list.getFirstVisibleItem().data;
						storedTabListPosition[selectedFilter].offset = fli.y + storedTabListPosition[selectedFilter].listBoxY;
					}
				} else if ("item" in storedTabListPosition[selectedFilter] == true) {
					delete storedTabListPosition[selectedFilter].item;
					delete storedTabListPosition[selectedFilter].offset;
					delete storedTabListPosition[selectedFilter].listBoxY;
				}
			}
			if (list != null) {
				if (selectedFilter == "all") {
					if (allData == null)
						allData = ChatManager.getLatestChatsAndDatesFilter(ChatRoomType.ALL);
					list.setData(allData, ListConversation, ['avatarURL'], null);
				} else if (selectedFilter == TAB_CHATS) {
					if (privateData == null)
						privateData = ChatManager.getLatestChatsAndDatesFilter(ChatRoomType.PRIVATE + "," + ChatRoomType.GROUP + "," + ChatRoomType.CHANNEL + "," + ChatRoomType.BANK);
					list.setData(privateData, ListConversation, ['avatarURL'], null);
				} else if (selectedFilter == TAB_PRIVATE) {
					if (privateData == null)
						privateData = ChatManager.getLatestChatsAndDatesFilter(ChatRoomType.PRIVATE);
					list.setData(privateData, ListConversation, ['avatarURL'], null);
				} else if (selectedFilter == TAB_GROUP) {
					if (groupData == null)
						groupData = ChatManager.getLatestChatsAndDatesFilter(ChatRoomType.GROUP);
					list.setData(groupData, ListConversation, ['avatarURL'], null);
				} else if (selectedFilter == TAB_HELP) {
					if (helpData == null)
						helpData = ChatManager.getLatestChatsAndDatesFilter(ChatRoomType.COMPANY);
					list.setData(helpData, ListConversation, ['avatarURL'], null);
				} else if (selectedFilter == TAB_911) {
					if (queData == null)
						queData = AnswersManager.getAllAnswers();
					list.setData(queData, ListConversation, ['avatarURL'], null);
				} else if (selectedFilter == TAB_CHANNELS) {
					if (channelsData == null)
						channelsData = ChannelsManager.getAllChannels();
					list.setData(channelsData, ListConversation, ['avatarURL'], null);
				} else if (selectedFilter == TAB_CALLS) {
					if (callsData == null)
						callsData = CallsHistoryManager.getAllCalls();
					list.setData(callsData, ListCallRenderer, ['avatarURL'], null);
				}
			}
		//	list.setBoxY(listPosition);
			
			if (needToScrollTop == false)
				if (storedTabListPosition[selectedFilter] != null && "item" in storedTabListPosition[selectedFilter] == true && storedTabListPosition[selectedFilter].item != null)
					if (list.scrollToItem(null, storedTabListPosition[selectedFilter].item, storedTabListPosition[selectedFilter].offset) == false)
						if ("listBoxY" in storedTabListPosition[selectedFilter] == true)
							list.setBoxY(storedTabListPosition[selectedFilter].listBoxY);
			
			TweenMax.killDelayedCallsTo(checkForEmptyClipNeed);
			if (list.data != null && list.data.length != 0) {
				checkForEmptyClipNeed();
				return;
			}
			TweenMax.delayedCall(1, checkForEmptyClipNeed);
		}
		
		private function hideStatusClip():void {
			if (statusClip) {
				statusClip.hide();
			}
		}
		
		private function addFakeChatButton(model:ChatVO, array:Array):Array {
			if (!array)
				array = new Array();
			array.unshift(model);
			return array;
		}
		
		private function checkForEmptyClipNeed():void {
			return;
			echo("InnerChatScreen", "checkForEmptyClipNeed");
			if (list.data == null || list.data.length == 0) {
				showEmptyClip();
				return;
			}
			hideEmptyClip();
		}
		
		public function saveListPosition():void {
			listPosition = list.getBoxY();
		}
		
		override public function getAdditionalDebugInfo():String {
			return "InnerChatScreen > " + selectedFilter;
		}
	}
}