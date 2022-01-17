package com.dukascopy.connect.screens {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.GD;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.AlertScreenData;
	import com.dukascopy.connect.data.SelectorItemData;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.customActions.Create911QuestionAction;
	import com.dukascopy.connect.data.screenAction.customActions.CreateChatAction;
	import com.dukascopy.connect.data.screenAction.customActions.Open911FaqAction;
	import com.dukascopy.connect.data.screenAction.customActions.Open911GeolocationAction;
	import com.dukascopy.connect.data.screenAction.customActions.Open911InfoAction;
	import com.dukascopy.connect.data.screenAction.customActions.Open911ScreenAction;
	import com.dukascopy.connect.data.screenAction.customActions.Open911SupportAction;
	import com.dukascopy.connect.data.screenAction.customActions.ShowFilterEscrowAction;
	import com.dukascopy.connect.gui.components.ratesPanel.RatesPanel;
	import com.dukascopy.connect.gui.lightbox.LightBox;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.tabs.TabBar;
	import com.dukascopy.connect.gui.tools.ImagePreviewCrop;
	import com.dukascopy.connect.gui.topBar.TopBar;
	import com.dukascopy.connect.managers.escrow.vo.EscrowAdsFilterVO;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.base.ScreenManager;
	import com.dukascopy.connect.screens.dialogs.x.base.float.FloatAlert;
	import com.dukascopy.connect.screens.innerScreens.InnerCallsScreen;
	import com.dukascopy.connect.screens.innerScreens.InnerChatScreen;
	import com.dukascopy.connect.screens.innerScreens.InnerContactScreen;
	import com.dukascopy.connect.screens.innerScreens.InnerEscrowInstrumentScreen;
	import com.dukascopy.connect.screens.innerScreens.InnerEscrowScreen;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.callManager.CallsHistoryManager;
	import com.dukascopy.connect.sys.configManager.ConfigManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.nativeExtensionController.NativeExtensionController;
	import com.dukascopy.connect.sys.notificationManager.InnerNotificationManager;
	import com.dukascopy.connect.sys.notifier.NewMessageNotifier;
	import com.dukascopy.connect.sys.questionsManager.QuestionsManager;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.socialManager.SocialManager;
	import com.dukascopy.connect.sys.store.Store;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.swiper.Swiper;
	import com.dukascopy.connect.type.BankPhaze;
	import com.dukascopy.connect.vo.screen.ScreenData;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Roman Kulyk
	 */
	
	public class RootScreen extends BaseScreen {
		
		public static const CHATS_SCREEN_ID:String = "chats";
		public static const CALLS_SCREEN_ID:String = "calls";
		public static const CHANNELS_SCREEN_ID:String = "channels";
		public static const CONTACTS_SCREEN_ID:String = "contacts";
		public static const PAYMENTS_SCREEN_ID:String = "payments";
		public static const QUESTIONS_SCREEN_ID:String = "questions";
		public static const SETTINGS_SCREEN_ID:String = "other";
		public static const PROMO_SCREEN_ID:String = "promo";
		public static const BOT_SCREEN_ID:String = "bot";
		public static const ESCROW_INSTRUMENT_SCREEN_ID:String = "instrument";
		
		private var questionTabObject:Object = {
			id: QUESTIONS_SCREEN_ID,
			title: Lang.escrow_title,
			screenClass: InnerEscrowInstrumentScreen,
			hasSearchBar: false
		};
		
		private var instrumentTabObject:Object = {
			id: ESCROW_INSTRUMENT_SCREEN_ID,
			title: Lang.escrow_title,
			screenClass: InnerEscrowScreen,
			hasSearchBar: false
		};
		
		private var screensArray:Array = [
			{
				id: CHATS_SCREEN_ID,
				title: Lang.textChats,
				screenClass: InnerChatScreen,
				selectedIcon: new (Style.icon(Style.MENU_CHATS_SELECTED)),
				notSelectedIcon: new (Style.icon(Style.MENU_CHATS)),
				hasSearchBar: false,
				scaleIndex:1
			}, {
				id: CONTACTS_SCREEN_ID,
				title: Lang.textContacts,
				screenClass: InnerContactScreen,
				selectedIcon: new (Style.icon(Style.MENU_CONTACTS_SELECTED)),
				notSelectedIcon: new (Style.icon(Style.MENU_CONTACTS)),
				hasSearchBar: true,
				scaleIndex:1
			}, {
				id: QUESTIONS_SCREEN_ID,
				title: Lang.escrow_title,
				screenClass: InnerEscrowInstrumentScreen,
				selectedIcon: new (Style.icon(Style.MENU_P2P_SELECTED)),
				notSelectedIcon: new (Style.icon(Style.MENU_P2P)),
				hasSearchBar: false,
				scaleIndex:1
			}, {
				id: PAYMENTS_SCREEN_ID,
				title: Lang.textPayments,
				screenClass: null,
				selectedIcon: new (Style.icon(Style.MENU_BANK_SELECTED)),
				notSelectedIcon: new (Style.icon(Style.MENU_BANK)),
				hasSearchBar: false,
				scaleIndex:1
			}, {
				id: BOT_SCREEN_ID,
				title: Lang.bankBot,
				screenClass: null,
				selectedIcon: new (Style.icon(Style.MENU_BOT_SELECTED)),
				notSelectedIcon: new (Style.icon(Style.MENU_BOT)),
				hasSearchBar: false,
				scaleIndex:1
			}, {
				id: SETTINGS_SCREEN_ID,
				title: Lang.textSettings,
				screenClass: SettingsScreen,
				selectedIcon: new (Style.icon(Style.MENU_SETTINGS_SELECTED)),
				notSelectedIcon: new (Style.icon(Style.MENU_SETTINGS)),
				hasSearchBar: false,
				scaleIndex:1
			}
		];
		
		private var actionOpen911:Open911ScreenAction;
		private var actionCreateQuestion:Create911QuestionAction;
		private var actionOpen911Support:Open911SupportAction;
		private var actionOpen911FAQ:Open911FaqAction;
		private var actionOpen911Geolocation:Open911GeolocationAction;
		private var actionOpen911Info:Open911InfoAction;
		private var filter911:IScreenAction;
		private var actionCreateGroupChat:CreateChatAction;
		
		private var topBar:TopBar;
		private var innerScreenManager:ScreenManager;
		private var bottomTabs:TabBar;
		private var swiper:Swiper;
		private var currentTabIndex:int = -1;
		private var currentTabID:String = "";
		private var currentScreen:Class = null;
		
		private var drawViewWidth:int = -1;
		private var drawViewHeight:int = -1;
		
		private var firstTime:Boolean;
		private var BLINK_CHECK_INTERVAL:int = 60 * 4;
		private var selectedinstrument:String;
		private var ratesPanel:RatesPanel;
		
		/**
		 * @CONSTRUCTOR
		 */
		public function RootScreen() { }
		
		override protected function createView():void {
			echo("RootScreen", "createView");
			super.createView();
			innerScreenManager = new ScreenManager("RootScreenInner");
			if (MobileGui.centerScreen.isActive == false)
				innerScreenManager.deactivate();
			innerScreenManager.ingnoreBackSignal();
			_view.addChild(innerScreenManager.view);
			topBar = new TopBar();
			topBar.onBack = onTopBarBack;
			topBar.setSearchBarVisibility(false);
			_view.addChild(topBar.view);
			bottomTabs = new TabBar(Style.color(Style.BOTTOM_BAR_COLOR), Style.color(Style.BOTTOM_BAR_TEXT_COLOR), 1, Style.color(Style.BOTTOM_BAR_TEXT_SELECTED_COLOR), false, Style.boolean(Style.BOTTOM_BAR_LINE), Style.color(Style.BOTTOM_BAR_SELECTED_BACKGROUND));
			var tabScale:Number;
			for (var i:int = 0; i < screensArray.length; i++) {
				if (SocialManager.available == false) {
					if (screensArray[i].id == QUESTIONS_SCREEN_ID ||
						screensArray[i].id == CHANNELS_SCREEN_ID)
							continue;
				}
				tabScale = UI.getMaxScale(screensArray[i].selectedIcon.width, screensArray[i].selectedIcon.height, Config.TOP_BAR_HEIGHT * .55, Config.TOP_BAR_HEIGHT * .55);
				tabScale *= screensArray[i].scaleIndex;
				if (Config.PLATFORM_APPLE && Config.isRetina() > 0)
					tabScale *= 0.9;
				bottomTabs.add("", screensArray[i].id, screensArray[i].selectedIcon, screensArray[i].notSelectedIcon, null, false, tabScale, false);
			}
			_view.addChild(bottomTabs.view);
			swiper = new Swiper("RootScreen");
			firstTime = true;
		}
		
		private function onTopBarBack():void {
			if (currentTabID == ESCROW_INSTRUMENT_SCREEN_ID) {
				onIstrumentSelected();
			}
		}
		
		private function needNotification(display:Boolean):void {
			if (bottomTabs != null) {
				bottomTabs.selectNotification(CHATS_SCREEN_ID, display);
			}
		}
		
		private function blinkBankButton(realChange:Boolean = true):void {
			if (Auth.tradingPhazeInVidid()) {
				return;
			}
			if (Auth.bank_phase != BankPhaze.ACC_APPROVED) {
				if (bottomTabs != null)
					bottomTabs.selectBlink(PAYMENTS_SCREEN_ID);
				TweenMax.delayedCall(BLINK_CHECK_INTERVAL, blinkBankButton);
			} else {
				if (bottomTabs != null)
					bottomTabs.selectBlink(PAYMENTS_SCREEN_ID, false);	
			}
		}
		
		/**
		 * Init Screen
		 * Sizes and data are ready here
		 * @param    data
		 */
		override public function initScreen(data:Object = null):void {
			echo("RootScreen", "initScreen");
			super.initScreen(data);
			_params.title = 'Root screen';
			_params.doDisposeAfterClose = false;
			
			if (firstTime == false) {
				if (data != null && "selectedTab" in data && data.selectedTab != null) {
					currentTabID = data.selectedTab;
					onBottomTabsClick(currentTabID, false, 0);
				}
				if (currentTabID != "" && bottomTabs != null) {
					/*if (currentTabID == QUESTIONS_SCREEN_ID)
						bottomTabs.selectTap(null);
					else*/
						bottomTabs.selectTap(currentTabID);
				}
				QuestionsManager.setInOut(currentTabIndex == 2);
				return;
			}
			firstTime = false;
			
			// TODO init screens here emajo
			Auth.S_NEED_AUTHORIZATION.add(onLogout);
			
			if (innerScreenManager.S_COMPLETE_SHOW != null)
				innerScreenManager.S_COMPLETE_SHOW.add(onInnerScreenShowComplete);
			Store.load(Store.VAR_ROOT_SCREEN_TAB, onStoreRootScreenTab);
			
			TweenMax.delayedCall(BLINK_CHECK_INTERVAL, blinkBankButton);
			Auth.S_PHAZE_CHANGE.add(blinkBankButton);
			
			NewMessageNotifier.S_UPDATE_EXIST.add(needNotification);
			
			GD.S_SHOW_ESCROW_ADS.add(onIstrumentSelected);
			
			Auth.S_PHAZE_CHANGE.add(onPhaseChanged);
		}
		
		private function onPhaseChanged(...rest):void {
			var tabIndex:int = getTabIndexById(currentTabID);
			if (tabIndex == -1)
				return;
			var tabObject:Object;
			if (tabIndex == 10) {
				tabObject = questionTabObject;
			} else if (tabIndex == 11) {
				tabObject = instrumentTabObject;
			} else {
				tabObject = screensArray[tabIndex];
			}
			topBar.setSearchBarVisibility(tabObject.hasSearchBar);
			topBar.setActions(getActions(tabObject.id), (currentTabID == QUESTIONS_SCREEN_ID) ? .7 : 1);
			topBar.updateUnderline(currentTabID == SETTINGS_SCREEN_ID);
			if ("titleIcon" in tabObject == true && tabObject.titleIcon != null)
				topBar.setTitleIcon(tabObject.titleIcon);
			else
				topBar.setTitle(tabObject.title);
			
			if (Auth.bank_phase != BankPhaze.ACC_APPROVED && (currentTabID == QUESTIONS_SCREEN_ID || currentTabID == ESCROW_INSTRUMENT_SCREEN_ID))
			{
				onBottomTabsClick(CHATS_SCREEN_ID);
			}
		}
		
		private function onIstrumentSelected(instrument:EscrowAdsFilterVO = null):void {
			if (isDisposed)
				return;
			if (instrument != null) {
				selectedinstrument = instrument.instrument.code;
			} else {
				selectedinstrument = null;
			}
			if (selectedinstrument != null) {
				if (instrumentTabObject != null) {
					var code:String = instrument.instrument.code;
					if (code == "DCO")
						code = "DUK+";
					var name:String = "";
					name=instrument.instrument.name;
					var text:String = String(name + " (" + code + ")").toUpperCase();
					instrumentTabObject.title = text;
				} else {
					ApplicationErrors.add();
				}
				onBottomTabsClick(RootScreen.ESCROW_INSTRUMENT_SCREEN_ID, false);
			} else {
				onBottomTabsClick(RootScreen.QUESTIONS_SCREEN_ID, true);
			}
		}
		
		override protected function drawView():void {
			echo("RootScreen", "drawView");
			if (_isDisposing == true || _isDisposed == true)
				return;
			if (drawViewWidth == _width && drawViewHeight == _height)
				return;
			if (ratesPanel != null) {
				topBar.topPadding = ratesPanel.getHeight();
			} else {
				topBar.topPadding = 0;
			}
			
		//	topBar.topPadding+=Config.APPLE_TOP_OFFSET;
			
			topBar.setSize(_width, Config.TOP_BAR_HEIGHT);
			topBar.show();
			bottomTabs.setWidthAndHeight(_width, Config.TOP_BAR_HEIGHT * 1.1, Config.APPLE_BOTTOM_OFFSET);
			
			bottomTabs.view.y = _height - bottomTabs.height;
			innerScreenManager.view.y = topBar.view.y + topBar.getHeight();
			
			innerScreenManager.setSize(_width, _height - innerScreenManager.view.y - bottomTabs.height + bottomTabs.getCurrentOffset());
			swiper.setBounds(_width, innerScreenManager.view.height, innerScreenManager.view, 0, innerScreenManager.view.y);
		}
		
		private function onStoreRootScreenTab(data:Object, err:Boolean):void {
			if (err == true || data == null) {
				currentTabID = CHATS_SCREEN_ID;
			} else if (data == QUESTIONS_SCREEN_ID || data == CHANNELS_SCREEN_ID) {
				currentTabID = CHATS_SCREEN_ID;
			} else {
				currentTabID = data as String;
			}
			onBottomTabsClick(currentTabID, false, 0);
		}
		
		override public function drawViewLang():void {
			var scr:BaseScreen = innerScreenManager.getScreenByClass(InnerChatScreen);
			if (scr != null)
				scr.drawViewLang();
			scr = innerScreenManager.getScreenByClass(InnerCallsScreen);
			if (scr != null)
				scr.drawViewLang();
			scr = innerScreenManager.getScreenByClass(InnerContactScreen);
			if (scr != null)
				scr.drawViewLang();
			scr = innerScreenManager.getScreenByClass(SettingsScreen);
			if (scr != null)
				scr.drawViewLang();
			setTitles();
			if (currentTabIndex > 0 && currentTabIndex < screensArray.length)
				topBar.setTitle(screensArray[currentTabIndex].title);
		}
		
		private function setTitles():void {
			if (screensArray != null && screensArray.length > 0) {
				screensArray[0].title = Lang.textChats;
				screensArray[1].title = Lang.textContacts;
				screensArray[3].title = Lang.textPayments;
				screensArray[4].title = Lang.textSettings;
			}
		}
		
		public function isCurrentTab(screenType:String):Boolean {
			if (currentTabID == screenType)
				return true;
			return false;
		}
		
		override public function onBack(e:Event = null):void {
			if (innerScreenManager &&
				innerScreenManager.currentScreen &&
				innerScreenManager.currentScreen.data &&
				(innerScreenManager.currentScreen.data as ScreenData).backScreen) {
					if (bottomTabs.busy)
						return;
					var tabId:String = getTabIdByScreenClass((innerScreenManager.currentScreen.data as ScreenData).backScreen);
					var tabIndex:int = getTabIndexById(tabId);
					if (tabIndex == -1)
						return;
					if (currentTabIndex == tabIndex)
						return;
					var dir:int = 0;
					if (tabIndex < currentTabIndex)
						dir = 1;
					onBottomTabsClick(tabId, true)
			} else
				DialogManager.alert(Lang.textWarning, Lang.areYouSureQuitApplication, MobileGui.onQuitDialogCallback, Lang.textQuit, Lang.textCancel);
		}
		
		private function getTabIdByScreenClass(screenClass:Class):String {
			for (var i:int = 0; i < screensArray.length; i++)
				if (screensArray[i].screenClass == screenClass)
					return screensArray[i].id;
			return null;
		}
		
		override public function clearView():void {
			echo("RootScreen", "clearView");
			super.clearView();
			
			if (bottomTabs != null)
				bottomTabs.dispose();
			bottomTabs = null;
			
			if (topBar != null)
				topBar.dispose();
			topBar = null;
			
			if (innerScreenManager != null)
				innerScreenManager.dispose();
			innerScreenManager = null;
			
			removeRatesPanel();
		}
		
		override public function dispose():void {
			super.dispose();
			echo("RootScreen", "dispose");
			if (swiper != null)
				swiper.dispose();
			swiper = null;
			TweenMax.killDelayedCallsTo(blinkBankButton);
			Auth.S_PHAZE_CHANGE.remove(blinkBankButton);
			currentTabIndex = -1;
			currentTabID = "";
			currentScreen = null;
			
			GD.S_SHOW_ESCROW_ADS.remove(onIstrumentSelected);
			InnerNotificationManager.S_NOTIFICATION_NEED.remove(needNotification);
			NewMessageNotifier.S_UPDATE_EXIST.remove(needNotification);
		}
		
		override public function activateScreen():void {
			if (_isDisposing == true || _isDisposed == true)
				return;
			echo("RootScreen", "activateScreen");
			super.activateScreen();
			if (innerScreenManager != null) {
				if (innerScreenManager.S_COMPLETE_SHOW != null)
					innerScreenManager.S_COMPLETE_SHOW.add(onInnerScreenShowComplete);
				innerScreenManager.activate();
			}
			if (bottomTabs != null) {
				if (bottomTabs.S_ITEM_SELECTED != null)
					bottomTabs.S_ITEM_SELECTED.add(onBottomTabsClick);
				bottomTabs.busy = false;
				bottomTabs.activate();
			}
			if (topBar != null)
				topBar.activate();
			updateMissedCallsNum(CallsHistoryManager.getMissedNum());
			CallsHistoryManager.S_MISSED_NUM.add(updateMissedCallsNum);
			
			if(topBar != null)
			{
				if (currentTabID == ESCROW_INSTRUMENT_SCREEN_ID)
				{
					topBar.addBackButton();
				}
				else
				{
					topBar.removeBackButton();
				}
			}
			
			if (ratesPanel != null)
			{
				ratesPanel.activate();
			}
		}
		
		private function updateMissedCallsNum(missedNum:int):void {
			if (currentTabID != CALLS_SCREEN_ID) {
				bottomTabs.selectNotification(CALLS_SCREEN_ID);
			} else {
				bottomTabs.selectNotification(CALLS_SCREEN_ID, false);
			}
		}
		
		override public function deactivateScreen():void {
			if (_isDisposed)
				return;
			
			if (data != null && "additionalData" in data)
			{
				data.additionalData = null;
			}
			echo("RootScreen", "deactivateScreen", '');
			super.deactivateScreen();
			if (innerScreenManager != null) {
				if (innerScreenManager.S_COMPLETE_SHOW != null)
					innerScreenManager.S_COMPLETE_SHOW.remove(onInnerScreenShowComplete);
				innerScreenManager.deactivate();
			}
			
			if (bottomTabs != null) {
				if (bottomTabs.S_ITEM_SELECTED != null)
					bottomTabs.S_ITEM_SELECTED.remove(onBottomTabsClick);
				bottomTabs.deactivate();
			}
			if (topBar != null)
				topBar.deactivate();
			if (swiper != null) {
				swiper.deactivate();
				swiper.S_ON_SWIPE.remove(onSwipe);
			}
			CallsHistoryManager.S_MISSED_NUM.remove(updateMissedCallsNum);
			
			if (ratesPanel != null)
			{
				ratesPanel.activate();
			}
		}

		private function onInnerScreenShowComplete(clc:Class):void {
			echo("RootScreen", "onInnerScreenShowComplete", '');
			if (_isDisposed == true)
				return;
			/*if (currentTabIndex == 10)
				return;*/
			if (currentTabIndex == 11)
				return;
			if (bottomTabs != null) {
				bottomTabs.busy = false;
				bottomTabs.selectTap(screensArray[currentTabIndex].id);
			}
		}

		override protected function onSwipe(d:String):void{
			echo("RootScreen", "onSwipe", d);
			if (LightBox.isShowing || ImagePreviewCrop.isShowing) {
				return;
			}
			if (MobileGui.serviceScreen.isActive || MobileGui.dialogScreen.isActive)
			{
				return;
			}
			var tapIndex:int = currentTabIndex;

			if(tapIndex<0 || tapIndex>=screensArray.length)
				return;
			

			if (d == Swiper.DIRECTION_RIGHT) {
				if (tapIndex == 0)
					return;
				tapIndex--;
			} else if (d == Swiper.DIRECTION_LEFT) {
				if (tapIndex == screensArray.length - 1)
					return;
				tapIndex++;
			} else
				return;
			
			return;
			
			onBottomTabsClick(screensArray[tapIndex].id);
		}
		
		private function onBottomTabsClick(tabId:String, back:Boolean = false, time:Number = 0.3):void {
			echo("RootScreen", "onBottomTabsClick", tabId);
			if (bottomTabs != null && bottomTabs.busy)
				return;
			var tabIndex:int = getTabIndexById(tabId);
			if (tabIndex == -1)
				return;
			if (ConfigManager.config.disableP2P == true) {
				if (tabIndex == 2) {
					showGoodbyePopup();
					return;
				} else if (tabIndex == 11) {
					showGoodbyePopup();
					return;
				}
			}
			if(topBar != null)
			{
				if (tabId == ESCROW_INSTRUMENT_SCREEN_ID)
				{
					topBar.addBackButton();
				}
				else
				{
					topBar.removeBackButton();
				}
			}
			
			if (currentTabIndex == tabIndex)
			{
				if (data != null && "additionalData" in data && data.additionalData != null && tabId == CONTACTS_SCREEN_ID && innerScreenManager.currentScreen is InnerContactScreen)
				{
					(innerScreenManager.currentScreen as InnerContactScreen).setAddditionalData(data.additionalData);
					data.additionalData = null;
				}
				
				if (data != null && "additionalData" in data)
				{
					data.additionalData = null;
				}
				
				return;
			}
			
			bottomTabs.busy = true;
			var dir:int = 0;
			if (tabIndex < currentTabIndex)
				dir = 1;
			
			if (tabId == PAYMENTS_SCREEN_ID) {
				MobileGui.openMyAccountIfExist();
				bottomTabs.busy = false;
				return;
			}
			if (tabId == BOT_SCREEN_ID) {
				MobileGui.openBankBot();
				bottomTabs.busy = false;
				return;
			}
			currentTabID = tabId;
			currentTabIndex = tabIndex;
			var tabObject:Object;
			if (tabIndex == 10) {
				tabObject = questionTabObject;
			} else if (tabIndex == 11) {
				tabObject = instrumentTabObject;
			} else {
				tabObject = screensArray[tabIndex];
			}
			
			showInnerScreen(tabObject.screenClass, dir, time);
			topBar.setSearchBarVisibility(tabObject.hasSearchBar);
			topBar.setActions(getActions(tabObject.id), (currentTabID == QUESTIONS_SCREEN_ID) ? .7 : 1);
			topBar.updateUnderline(currentTabID == SETTINGS_SCREEN_ID);
			if ("titleIcon" in tabObject == true && tabObject.titleIcon != null)
				topBar.setTitleIcon(tabObject.titleIcon);
			else
				topBar.setTitle(tabObject.title);
			if (tabIndex != 11) {
				Store.save(Store.VAR_ROOT_SCREEN_TAB, currentTabID);
			}
		}
		
		private function showGoodbyePopup():void 
		{
			var alertScreenData:AlertScreenData = new AlertScreenData();
			
			alertScreenData.text = Lang.goodbye_911;
			alertScreenData.icon = ExchangeIcon2;
			alertScreenData.button = Lang.textOk.toUpperCase();
			alertScreenData.link = new SelectorItemData(Lang.aboutService, Lang.escrow_about_service_url);
			ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, FloatAlert, alertScreenData);
		}
		
		private function showInnerScreen(screenClass:Class, dir:int = 0, time:Number = 0.3):void {
			if (screenClass == innerScreenManager.currentScreenClass)
				return;
			var screenData:ScreenData = new ScreenData();
			if (innerScreenManager.currentScreen != null) {
				screenData.backScreen = innerScreenManager.currentScreenClass;
				screenData.backScreenData = innerScreenManager.currentScreen.data;
			}
			
			if (data != null && "additionalData" in data && data.additionalData != null && screenClass == InnerContactScreen)
			{
				screenData.additionalData = data.additionalData;
			}
			else
			{
				if (innerScreenManager.currentScreen is InnerContactScreen)
				{
					(innerScreenManager.currentScreen as InnerContactScreen).setAddditionalData(null);
				}
			}
			if (data != null && "additionalData" in data)
			{
				data.additionalData = null;
			}
			if (currentTabID == ESCROW_INSTRUMENT_SCREEN_ID)
			{
				screenData.additionalData = selectedinstrument;
			}
			
			innerScreenManager.show(screenClass, screenData, dir, time);
			
			if (screenClass == InnerEscrowInstrumentScreen) {
				bottomTabs.busy = false;
				bottomTabs.selectTap(null);
				addRatesPanel();
			} else if (screenClass == InnerEscrowScreen) {
				bottomTabs.busy = false;
				bottomTabs.selectTap(null);
				addRatesPanel();
			} else 
			{
				removeRatesPanel();
			}
		}
		
		private function removeRatesPanel():void 
		{
			NativeExtensionController.setStatusBarColor(Style.color(Style.COLOR_BACKGROUND));
			if (ratesPanel != null)
			{
				ratesPanel.dispose();
				if (view != null && ratesPanel != null)
				{
					view.removeChild(ratesPanel);
				}
				ratesPanel = null;
			}
			drawView();
		}
		
		private function addRatesPanel():void 
		{
			NativeExtensionController.setStatusBarColor(Style.color(Style.COLOR_ACCENT_PANEL));
			if (ratesPanel == null)
			{
				ratesPanel = new RatesPanel(_width);
				view.addChild(ratesPanel);
			}
			drawView();
		}
		
		private function getActions(id:String):Vector.<IScreenAction> {
			var array:Vector.<IScreenAction> = new Vector.<IScreenAction>();
			if (id == QUESTIONS_SCREEN_ID) {
				actionOpen911Info ||= new Open911InfoAction();
				array.push(actionOpen911Info);
				
				actionCreateQuestion ||= new Create911QuestionAction();
				array.push(actionCreateQuestion);
				
				return array;
			}
			if (id == ESCROW_INSTRUMENT_SCREEN_ID) {
				filter911 ||= new ShowFilterEscrowAction();
				array.push(filter911);
				
				actionCreateQuestion ||= new Create911QuestionAction();
				array.push(actionCreateQuestion);
				
				return array;
			}
			if (SocialManager.available == true) {
				if (actionOpen911 == null) {
					actionOpen911 = new Open911ScreenAction();
					actionOpen911.setAdditionalData(onBottomTabsClick);
				}
				array.push(actionOpen911);
			}
			if (id == CHATS_SCREEN_ID) {
				actionCreateGroupChat = new CreateChatAction();
				array.push(actionCreateGroupChat);
			}
			return array;
		}
		
		private function getTabIndexById(id:String):int {
			if (id == ESCROW_INSTRUMENT_SCREEN_ID)
				return 11;
			for (var i:int = 0; i < screensArray.length; i++)
				if (screensArray[i].id == id)
					return i;
			return -1;
		}
		
		/**
		 * On Need Authorization /Logout
		 */
		private function onLogout():void {
			echo("RootScreen", "onLogout", "");
			Auth.S_NEED_AUTHORIZATION.remove(onLogout);
			TweenMax.killDelayedCallsTo(blinkBankButton);
			Auth.S_PHAZE_CHANGE.remove(blinkBankButton); 
			currentTabID = CHATS_SCREEN_ID; // Force to change current tab 
			currentTabIndex = -1;
			if (bottomTabs != null)
				bottomTabs.busy = false;
			if (innerScreenManager != null)
				innerScreenManager.disposeCurentScreen();
		}
		
		public function onHide():void {
			if (innerScreenManager == null || innerScreenManager.currentScreen == null)
				return;
			if ("saveListPosition" in innerScreenManager.currentScreen)
				innerScreenManager.currentScreen["saveListPosition"]();
		}
		
		override public function getAdditionalDebugInfo():String {
			if (innerScreenManager == null)
				return "null";
			if (innerScreenManager.currentScreen == null)
				return "empty";
			return innerScreenManager.currentScreen.getAdditionalDebugInfo();
		}
	}
}