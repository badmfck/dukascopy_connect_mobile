package com.dukascopy.connect.screens {
	
	import assets.HelpIcon;
	import assets.IconInfoClip;
	import assets.SupportAvatar;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.BackgroundModel;
	import com.dukascopy.connect.data.ChatBackgroundCollection;
	import com.dukascopy.connect.data.filter.FilterCategory;
	import com.dukascopy.connect.data.screenAction.customActions.OpenOtherApplicationsAction;
	import com.dukascopy.connect.data.screenAction.customActions.OpenScreenAction;
	import com.dukascopy.connect.gui.chatInput.BankBotInput;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.List;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.gui.list.renderers.bankAccountElements.ListBankAccount;
	import com.dukascopy.connect.gui.list.renderers.bankAccountElements.ListBankAccountBalance;
	import com.dukascopy.connect.gui.list.renderers.bankAccountElements.ListBankAccountCards;
	import com.dukascopy.connect.gui.list.renderers.bankAccountElements.ListBankAccountCryptoWallets;
	import com.dukascopy.connect.gui.list.renderers.bankAccountElements.ListBankAccountInvestments;
	import com.dukascopy.connect.gui.list.renderers.bankAccountElements.ListBankAccountOther;
	import com.dukascopy.connect.gui.list.renderers.bankAccountElements.ListBankAccountSaving;
	import com.dukascopy.connect.gui.list.renderers.bankAccountElements.ListBankAccountWallets;
	import com.dukascopy.connect.gui.list.renderers.bankAccountElements.ListBankEmpty;
	import com.dukascopy.connect.gui.menuVideo.HidableButton;
	import com.dukascopy.connect.gui.topBar.TopBarScreen;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.base.ScreenManager;
	import com.dukascopy.connect.screens.dialogs.HeaderAlert;
	import com.dukascopy.connect.screens.dialogs.bottom.TransactionFilterPopup;
	import com.dukascopy.connect.screens.dialogs.paymentDialogs.BlockedAccountScreen;
	import com.dukascopy.connect.screens.dialogs.paymentDialogs.PaymentsUnavaliableScreen;
	import com.dukascopy.connect.screens.payments.settings.PaymentsSettingsScreen;
	import com.dukascopy.connect.screens.roadMap.RoadMapScreenNew;
	import com.dukascopy.connect.screens.serviceScreen.BankTutorialScreen;
	import com.dukascopy.connect.sys.assets.Assets;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.bankManager.BankManager;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.payments.PayAPIManager;
	import com.dukascopy.connect.sys.payments.PayServer;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.store.Store;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.type.BankPhaze;
	import com.dukascopy.connect.type.ChatInitType;
	import com.dukascopy.connect.type.FinanceFilterCategoryType;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.DateUtils;
	import com.dukascopy.connect.vo.BankMessageVO;
	import com.dukascopy.connect.vo.ChatVO;
	import com.dukascopy.connect.vo.screen.ChatScreenData;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.display.Bitmap;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class MyAccountScreen extends BaseScreen {
		
		private var infoAction:Object = { id:"infoBtn", img:IconInfoClip, callback:showAccOrCardInfo, imgColor:0xFFFFFF };
		
		private var actions:Array = [
			{ id:"filtersBtn", img:Style.icon(Style.ICON_FILTERS), callback:onFiltersButtonTap, imgColor:Style.color(Style.TOP_BAR_ICON_COLOR) },
			{ id:"settingsBtn", img:Style.icon(Style.ICON_SETTINGS), callback:onBottomButtonTap, imgColor:Style.color(Style.TOP_BAR_ICON_COLOR) },
			{ id:"refreshBtn", img:Style.icon(Style.ICON_REFRESH), callback:onRefresh1, imgColor:Style.color(Style.TOP_BAR_ICON_COLOR) }
		];
		
		private var topBar:TopBarScreen;
		private var list:List;
		private var input:BankBotInput;
		
		private var currentAccount:String;
		
		private var _waiting:Boolean;
		private var openedNum:int = -1;
		
		private var walletItemIndex:int = -1;
		private var investmentsItemIndex:int = -1;
		private var totalItemIndex:int = -1;
		private var totalSavingsItemIndex:int = -1;
		private var cardsItemIndex:int = -1;
		private var cryptoItemIndex:int = -1;
		private var otherItemIndex:int = -1;
		private var savingsItemIndex:int = -1;
		
		private var needToActivate:Boolean = false;
		
		private var tutorialButton:HidableButton;
		private var backgroundImage:Bitmap;
		private var backgroundBitmapData:ImageBitmapData;
		
		private var storedFilters:Vector.<FilterCategory>;
		private var storedFiltersForLoading:Object;
		private var headerAlert:HeaderAlert;
		private var coinStatIndex:int = -1;
		
		private var openedItems:Array;
		
		public function MyAccountScreen() {
			topBar = new TopBarScreen();
			
			backgroundImage = new Bitmap();
			_view.addChild(backgroundImage);
			
			list = new List("bankAccountList");
			list.background = false;
			list.backgroundColor = 0XC4DEF1;
			list.view.y = topBar.trueHeight;
			list.setStickToBottom(true);
			
			input = new BankBotInput(Lang.startChatWithConsultant, false, true, false, false);
			input.sendCallback = onInputSend;
			input.menuCallback = onMenuSend;
			input.homeCallback = onBack;
			input.mpCallback = BankManager.openMarketPlace;
			
			_view.addChild(list.view);
			_view.addChild(topBar);
			_view.addChild(input);
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			_params.doDisposeAfterClose = true;
			
			topBar.setData(Lang.myAccount, true, actions);
			redrawTopBar();
			
			drawView();
			
			if (BankManager.needToShowMenu == true)
				input.startBlinkMenu();
			
			BankManager.S_HISTORY.add(onHistoryLoaded);
			BankManager.S_HISTORY_MORE.add(onHistoryMoreLoaded);
			BankManager.S_HISTORY_TRADES.add(onHistoryTradesLoaded);
			BankManager.S_HISTORY_TS_ERROR.add(onTSError);
			BankManager.S_WALLETS.add(onWalletsLoaded);
			BankManager.S_INVESTMENTS.add(onInvestmentsLoaded);
			BankManager.S_TOTAL.add(onTotalLoaded);
			BankManager.S_CARDS.add(onCardsLoaded);
			BankManager.S_ALL_DATA.add(onAllDataLoaded);
			BankManager.S_CRYPTO.add(onCryptoLoaded);
			BankManager.S_ERROR.add(onError);
			BankManager.S_PAYMENT_ERROR.add(onError);
			BankManager.S_CRYPTO_EXISTS.add(onCryptoExist);
			PayAPIManager.S_SWISS_API_CHECKED.add(onSwissAPIChecked);
			
			if (PayAPIManager.hasSwissAccount == true)
				onRefresh(true);
			
			loadTutorialStatus();
			
			addBackgroundImage();
		}
		
		private function addBackgroundImage():void {
			var backId:String = "7";
			var backgroundModel:BackgroundModel = ChatBackgroundCollection.getBackground(backId);
			if (backgroundModel == null)
				return;
			if (backgroundImage.bitmapData) {
				backgroundImage.bitmapData.dispose();
				backgroundImage.bitmapData = null;
			}
			backgroundBitmapData = Assets.getBackground(backgroundModel.big);
			backgroundImage.bitmapData = UI.drawAreaCentered(backgroundBitmapData, _width, _height);
		}
		
		private function onMenuSend():void {
			BankManager.openChatBotScreen( { bankBot:true } );
		}
		
		private function onInputSend():void {
			var chatScreenData:ChatScreenData = new ChatScreenData();
			chatScreenData.pid = Config.EP_VI_DEF;
			chatScreenData.type = ChatInitType.SUPPORT;
			chatScreenData.backScreen = MobileGui.centerScreen.currentScreenClass;
			chatScreenData.backScreenData = MobileGui.centerScreen.currentScreen.data;
			MobileGui.showChatScreen(chatScreenData);
		}
		
		private function loadTutorialStatus():void {
			Store.load(Store.BANK_TUTORIAL, onTutorialStatusLoaded);
		}
		
		private function onTutorialStatusLoaded(data:String, error:Boolean):void {
			if (error == true || data == null) {
				showTutorial();
			} else if (data != null && !isNaN(Number(data))) {
				if ((new Date()).getTime() - Number(data) < 1000 * 60 * 60 * 24 * 3) {
					showTutorialButton();
				}
				checkTradingPhaze();
			}
		}
		
		private function checkTradingPhaze():void {
			var needTradingAccountAlert:Boolean;
			var alertText:String;
			if (Auth.ch_phase == BankPhaze.VIDID || Auth.ch_phase == BankPhaze.VIDID_PROGRESS || Auth.ch_phase == BankPhaze.VIDID_READY || Auth.ch_phase == BankPhaze.VI_FAIL) {
				needTradingAccountAlert = true;
				alertText = Lang.trading_ch_opening_reminder;
			}
			if (Auth.eu_phase == BankPhaze.VIDID || Auth.eu_phase == BankPhaze.VIDID_PROGRESS || Auth.eu_phase == BankPhaze.VIDID_READY || Auth.eu_phase == BankPhaze.VI_FAIL) {
				needTradingAccountAlert = true;
				alertText = Lang.trading_eu_opening_reminder;
			}
			if (needTradingAccountAlert) {
				var action:OpenScreenAction = new OpenScreenAction(RoadMapScreenNew);
				action.setData(Lang.openAccount);
				headerAlert = HeaderAlert.show(view, 0, topBar.trueHeight, _width, alertText, action);
				if (_isActivated) {
					headerAlert.activate();
				}
			}
		}
		
		private function showTutorial():void {
			Store.save(Store.BANK_TUTORIAL, (new Date()).getTime().toString());
			ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, BankTutorialScreen);
		}
		
		private function showTutorialButton():void {
			if (tutorialButton == null) {
				tutorialButton = new HidableButton();
				tutorialButton.tapCallback = onTutorialButtonTap;
				tutorialButton.setDesign(new SupportAvatar());
				_view.addChild(tutorialButton);
				
				tutorialButton.setPosition(_width - Config.FINGER_SIZE - Config.MARGIN * 2,  _height - Config.FINGER_SIZE * 2 - Config.MARGIN * 2);
				tutorialButton.setOffset(MobileGui.stage.stageHeight - _height);
			}
		}
		
		private function onSwissAPIChecked():void {
			onRefresh(true);
			if (needToActivate == true)
				activateScreen();
		}
		
		private function onCryptoExist():void {
			if (BankManager.cryptoExists == true) {
				if (currentAccount == null || currentAccount == "all" || currentAccount == "")
					input.setButtonsState(false, true, false);
				else
					input.setButtonsState(true, true, false);
			}
		}
		
		private function onTSError():void {
			_waiting = false;
			topBar.hideAnimation();
		}
		
		private function onError(val:Object = null):void {
			if (val is BankMessageVO) {
				if (val.text == BankManager.PWP_NOT_ENTERED) {
					if (MobileGui.serviceScreen.currentScreen != null &&
						MobileGui.serviceScreen.currentScreenClass == BankTutorialScreen)
							ServiceScreenManager.closeView();
					onBack();
					return;
				}
				else if (val.text == BankManager.ACCOUNT_NOT_APPROVED)
				{
					if (MobileGui.serviceScreen.currentScreen != null &&
						MobileGui.serviceScreen.currentScreenClass == BankTutorialScreen)
							ServiceScreenManager.closeView();
					
					MobileGui.changeMainScreen(BlockedAccountScreen);
					return;
				}
				if (val.text != "@@1")
					ToastMessage.display("Server is busy, please try later.");
				else
					ToastMessage.display("val.text");
			} else if (val != BankManager.PWP_NOT_ENTERED) {
				ToastMessage.display("Server is busy, please try later.");
			} else {
				onBack();
				return;
			}
			_waiting = false;
			if (topBar != null)
			{
				topBar.hideAnimation();
			}
		}
		
		private function onBottomButtonTap():void {
			var bdata:Object = {
				backScreen:MobileGui.centerScreen.currentScreenClass,
				backScreenData:MobileGui.centerScreen.currentScreen.data
			}
			MobileGui.changeMainScreen(PaymentsSettingsScreen, bdata, ScreenManager.DIRECTION_RIGHT_LEFT);
		}
		
		private function onFiltersButtonTap():void {
			ServiceScreenManager.showScreen(
				ServiceScreenManager.TYPE_SCREEN,
				TransactionFilterPopup,
				{
					filters:storedFilters,
					callback:onFiltersSetted
				}
			);
		}
		
		private function onFiltersSetted(result:Vector.<FilterCategory>):void {
			if (result == null || result.length == 0) {
				storedFilters = null;
				storedFiltersForLoading = null;
				resetIndexes();
				topBar.showAnimationOverButton("refreshBtn", false);
				_waiting = true;
				BankManager.getPaymentHistory(
					1,
					50,
					null,
					false,
					false,
					null,
					null,
					null,
					0,
					0,
					true
				);
				redrawTopBar();
				return;
			}
			storedFilters = result;
			var l1:int = result.length;
			var l2:int;
			var i:int;
			var j:int;
			var filters:Object = {
				type: null,
				status: null,
				historyAccount: null,
				currency: null,
				tsFrom: null,
				tsTo: null
			}
			for (i = 0; i < l1; i++) {
				if (result[i].type.type == FinanceFilterCategoryType.ACCOUNT) {
					if (result[i].filters == null || result[i].filters.length == 0)
						continue;
					filters.historyAccount = "";
					l2 = result[i].filters.length;
					for (j = 0; j < l2; j++) {
						filters.historyAccount = result[i].filters[j].type.type + ",";
						filters.currency = result[i].filters[j].text + ",";
					}
					filters.historyAccount = filters.historyAccount.substr(0, filters.historyAccount.length - 1);
					filters.currency = filters.currency.substr(0, filters.currency.length - 1);
				}
				if (result[i].type.type == FinanceFilterCategoryType.TYPE) {
					if (result[i].filters == null || result[i].filters.length == 0)
						continue;
					filters.type = "";
					l2 = result[i].filters.length;
					for (j = 0; j < l2; j++) {
						filters.type = result[i].filters[j].type.type + ",";
					}
					filters.type = filters.type.substr(0, filters.type.length - 1);
				}
				if (result[i].type.type == FinanceFilterCategoryType.STATUS) {
					if (result[i].filters == null || result[i].filters.length == 0)
						continue;
					filters.status = "";
					l2 = result[i].filters.length;
					for (j = 0; j < l2; j++) {
						filters.status = result[i].filters[j].type.type + ",";
					}
					filters.status = filters.status.substr(0, filters.status.length - 1);
				}
				if (result[i].type.type == FinanceFilterCategoryType.DATE) {
					if (result[i].filters == null || result[i].filters.length != 2)
						continue;
					filters.tsFrom = result[i].filters[0].type.type;
					filters.tsTo = result[i].filters[1].type.type;
				}
			}
			storedFiltersForLoading = filters;
			resetIndexes();
			topBar.showAnimationOverButton("refreshBtn", false);
			_waiting = true;
			BankManager.getPaymentHistory(
				1,
				50,
				filters.historyAccount,
				false,
				false,
				filters.currency,
				filters.type,
				filters.status,
				filters.tsFrom,
				filters.tsTo,
				true
			);
			redrawTopBar();
		}
		
		private function onTutorialButtonTap():void {
			showTutorial();
		}
		
		private function showAccOrCardInfo():void {
			
		}
		
		private function onRefresh(init:Boolean = false):void {
			if (_waiting == true)
				return;
			resetIndexes();
			topBar.showAnimationOverButton("refreshBtn", false);
			_waiting = true;
			if (BankManager.getIsCardHistory() == true)
				BankManager.getCardHistory(BankManager.getHistoryAccount(), BankManager.getCardMasked());
			else if (BankManager.getIsInvestmentHistory() == true)
				BankManager.showInvestmentItemHistory(BankManager.getHistoryAccount());
			else
				BankManager.getPaymentHistory(1, 50, (init == true) ? "all" : null, init, init);
		}
		
		private function onRefresh1(init:Boolean = false):void {
			if (storedFiltersForLoading == null) {
				BankManager.getPaymentHistory(
					2,
					50,
					"all",
					false,
					true,
					null,
					null,
					null,
					0,
					0,
					true
				);
				return;
			}
			BankManager.getPaymentHistory(
				2,
				50,
				storedFiltersForLoading.historyAccount,
				false,
				true,
				storedFiltersForLoading.currency,
				storedFiltersForLoading.type,
				storedFiltersForLoading.status,
				storedFiltersForLoading.tsFrom,
				storedFiltersForLoading.tsTo,
				true
			);
		}
		
		private function resetIndexes():void {
			walletItemIndex = -1;
			totalItemIndex = -1;
			totalSavingsItemIndex = -1;
			cardsItemIndex = -1;
			investmentsItemIndex = -1;
			cryptoItemIndex = -1;
			otherItemIndex = -1;
			savingsItemIndex = -1;
		}
		
		private function onHistoryLoaded(history:Array, local:Boolean):void {
			setListData(history);
			if (isNaN(BankManager.getTimeForHistory()) == false) {
				var dt:Date = new Date();
				dt.setTime(BankManager.getTimeForHistory());
				topBar.updateAdditional(DateUtils.getTimeString(dt, false, 0, false));
				dt = null;
			}
			if (local == false) {
				if (history == null || history.length == 0)
					list.appendItem(null, ListBankEmpty);
			}
			list.scrollBottom();
			resetIndexes();
			BankManager.getAllData(local, !local);
		}
		
		private function onHistoryMoreLoaded(history:Array, local:Boolean):void {
			var listData:Array = list.data as Array;
			var index:int = history.length;
			if (Number(listData[0].transactionID) <= Number(history[history.length - 1].transactionID))
				trace();
			history = history.concat(listData);
			setListData(history);
			list.scrollToIndex(index, Config.MARGIN, 0, false);
			resetIndexes();
			BankManager.getAllData(local, !local);
		}
		
		private function onHistoryTradesLoaded(history:Array):void {
			if (coinStatIndex == -1)
				return;
			list.getStock()[coinStatIndex].data.opened = true;
			openedItems ||= [];
			openedItems.push(list.getStock()[coinStatIndex].data);
			list.updateItemByIndex(coinStatIndex);
			var l:int = history.length;
			if (l == 0)
				return;
			if (l > 1) {
				history[0].first = true;
				history[l - 1].last = true;
				history[int((l - 1) * .5)].showPrice = list.getStock()[coinStatIndex].data.raw.CUSTOM_DATA.avg_price;
			} else {
				history[0].onlyOne = true;
			}
			for (var i:int = 0; i < l; i++) {
				list.appendItem(history[i], ListBankAccount, null, false, false, coinStatIndex + i + 1);
			}
			if (walletItemIndex != -1)
				walletItemIndex += l;
			if (totalItemIndex != -1)
				totalItemIndex += l;
			if (totalSavingsItemIndex != -1)
				totalSavingsItemIndex += l;
			if (cardsItemIndex != -1)
				cardsItemIndex += l;
			if (investmentsItemIndex != -1)
				investmentsItemIndex += l;
			if (cryptoItemIndex != -1)
				cryptoItemIndex += l;
			if (otherItemIndex != -1)
				otherItemIndex += l;
			if (savingsItemIndex != -1)
				savingsItemIndex += l;
			list.refresh(true);
			coinStatIndex = -1;
		}
		
		private function onAllDataLoaded(error:Boolean = false, local:Boolean = true):void {
			BankManager.getCards(true);
			if (local == false) {
				_waiting = false;
				topBar.hideAnimation();
			}
		}
		
		private function onCardsLoaded(data:Array, local:Boolean):void {
			if (data == null) {
				BankManager.getWallets(local);
				return;
			}
			if (data != null && data.length != 0) {
				if (cardsItemIndex != -1) {
					list.updateItemByIndex(cardsItemIndex, list.getStock()[cardsItemIndex].data.opened);
				} else {
					var toBottom:Boolean = checkScrollToBottom();
					list.appendItem( { opened:false, cards:data }, ListBankAccountCards);
					cardsItemIndex = list.getStock().length - 1;
					if (toBottom == true)
						list.scrollBottom(true);
				}
			}
			BankManager.getWallets(true);
		}
		
		private function onWalletsLoaded(data:Array, local:Boolean):void {
			if (data == null) {
				BankManager.getInvestments(local);
				return;
			}
			if (data.length != 0) {
				if (walletItemIndex != -1) {
					list.getStock()[walletItemIndex].data.accounts = data;
					list.updateItemByIndex(walletItemIndex, list.getStock()[walletItemIndex].data.opened);
				} else {
					var toBottom:Boolean = checkScrollToBottom();
					list.appendItem( { opened:false, accounts:data }, ListBankAccountWallets);
					walletItemIndex = list.getStock().length - 1;
					if (toBottom == true)
						list.scrollBottom(true);
				}
			}
			BankManager.getInvestments(true);
		}
		
		private function onInvestmentsLoaded(data:Array, local:Boolean):void {
			if (data == null) {
				BankManager.getCrypto(local);
				return;
			}
			if (data.length != 0) {
				if (investmentsItemIndex != -1) {
					list.getStock()[investmentsItemIndex].data.accounts = data;
					list.updateItemByIndex(investmentsItemIndex, list.getStock()[investmentsItemIndex].data.opened);
				} else {
					var toBottom:Boolean = checkScrollToBottom();
					list.appendItem( { opened:false, accounts:data }, ListBankAccountInvestments);
					investmentsItemIndex = list.getStock().length - 1;
					if (toBottom == true)
						list.scrollBottom(true);
				}
			}
			BankManager.getCrypto(true);
		}
		
		private function onCryptoLoaded(data:Array, local:Boolean):void {
			if (data == null) {
				BankManager.getTotalServer(local);
				return;
			}
			if (data.length != 0) {
				if (cryptoItemIndex != -1) {
					list.getStock()[cryptoItemIndex].data.accounts = data;
					list.updateItemByIndex(cryptoItemIndex, list.getStock()[cryptoItemIndex].data.opened);
				} else {
					var toBottom:Boolean = checkScrollToBottom();
					list.appendItem( { opened:false, accounts:data }, ListBankAccountCryptoWallets);
					cryptoItemIndex = list.getStock().length - 1;
					if (toBottom == true)
						list.scrollBottom(true);
				}
			}
			onCryptoExist();
			BankManager.getTotalServer(true);
		}
		
		private function onTotalLoaded(data:Object, local:Boolean):void {
			var total:Object = BankManager.getTotal();
			if (total != null) {
				if (totalItemIndex != -1) {
					list.updateItemByIndex(totalItemIndex, false);
				} else {
					var toBottom:Boolean = checkScrollToBottom();
					list.appendItem(BankManager.getTotal(), ListBankAccountBalance);
					totalItemIndex = list.getStock().length - 1;
					if (toBottom == true)
						list.scrollBottom(true);
				}
			}
			onSavingsLoaded();
		}
		
		private function onSavingsLoaded():void {
			var data:Array = BankManager.getSavingsAccounts();
			var toBottom:Boolean;
			if (data != null && data.length != 0) {
				if (savingsItemIndex != -1) {
					list.updateItemByIndex(savingsItemIndex, false);
				} else {
					toBottom = checkScrollToBottom();
					list.appendItem( { opened:false, accounts:data }, ListBankAccountSaving);
					savingsItemIndex = list.getStock().length - 1;
				}
			}
			var total:Object = BankManager.totalSavingAccounts;
			if (total != null) {
				if (totalSavingsItemIndex != -1) {
					list.updateItemByIndex(totalSavingsItemIndex, false);
				} else {
					toBottom = checkScrollToBottom();
					list.appendItem(total, ListBankAccountBalance);
					totalSavingsItemIndex = list.getStock().length - 1;
				}
			}
			if (toBottom == true)
				list.scrollBottom(true);
			onOtherLoaded();
		}
		
		private function onOtherLoaded():void {
			var data:Array = BankManager.getOtherAccounts();
			if (data != null && data.length != 0) {
				if (otherItemIndex != -1) {
					list.updateItemByIndex(otherItemIndex, false);
				} else {
					var toBottom:Boolean = checkScrollToBottom();
					list.appendItem( { opened:false, otherAcc:data }, ListBankAccountOther);
					otherItemIndex = list.getStock().length - 1;
					if (toBottom == true)
						list.scrollBottom(true);
				}
			}
		}
		
		override protected function drawView():void {
			if (_isDisposed == true)
				return;
			if (topBar != null)
				topBar.drawView(_width);
			if (input != null) {
				input.setWidth(_width);
				input.y = _height - input.getHeight();
			}
			if (list != null)
				list.setWidthAndHeight(_width, _height - topBar.trueHeight - input.getHeight());
			
			if (tutorialButton != null) {
				tutorialButton.setPosition(_width - Config.FINGER_SIZE - Config.MARGIN * 2,  _height - Config.FINGER_SIZE * 2 - Config.MARGIN * 2);
				tutorialButton.setOffset(MobileGui.stage.stageHeight - _height);
			}
		}
		
		override public function activateScreen():void {
			if (_isDisposed == true)
				return;
			if (PayAPIManager.hasSwissAccount == false) {
				if (topBar != null)
					topBar.activate(.15, true);
				needToActivate = true;
				return;
			}
			super.activateScreen();
			if (topBar != null) {
				topBar.activate();
				if (_waiting == true)
					topBar.showAnimationOverButton("refreshBtn", false);
			}
			if (input != null)
				input.activate();
			if (list != null) {
				list.activate();
				list.S_ITEM_TAP.add(onItemTap);
				list.S_ITEM_HOLD.add(onItemHold);
				list.S_MOVING.add(onListMove);
				list.S_UP.add(onListTouchUp);
			}
			if (headerAlert != null) {
				headerAlert.activate();
			}
			if (tutorialButton != null) {
				tutorialButton.activate();
			}
		}
		
		private function onItemHold(data:Object, n:int):void {
			if ("transactionID" in data == false)
				return;
			Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, data.desc);
			ToastMessage.display(Lang.copied);
		}
		
		private function onItemTap(data:Object, n:int):void {
			var selectedItem:ListItem = list.getItemByNum(n);
			var lastHitzoneObject:Object;
			var lhz:String;
			var needToScrollBottom:Boolean;
			if (list.getStock()[n].renderer is ListBankAccountCards == true) {
				lastHitzoneObject = selectedItem.getLastHitZoneObject();
				if (lastHitzoneObject == null) {
                    return;
				}
				lhz = lastHitzoneObject.type;
				if (lhz == null)
					return;
				if (lhz == HitZoneType.WALLETS_MORE) {
					if (data.opened == false) {
						if (openedNum != -1 &&
							openedNum != n &&
							list.getItemByNum(openedNum) != null &&
							list.getItemByNum(openedNum).data.opened == true) {
								list.getItemByNum(openedNum).data.opened = false;
								list.updateItemByIndex(openedNum, true, true);
						}
						openedNum = n;
					}
					data.opened = !data.opened;
					needToScrollBottom = checkScrollToBottom();
					list.updateItemByIndex(n, true, true);
					if (needToScrollBottom == false)
						needToScrollBottom = checkScrollToBottom();
					if (needToScrollBottom == true)
						list.scrollBottom(true);
					return;
				}
				if (data.cards[lastHitzoneObject.param].programme == "linked")
                    return;
				if ("number" in data.cards[lastHitzoneObject.param] == true && data.cards[lastHitzoneObject.param].number != null) {
					if (BankManager.getHistoryAccount() == data.cards[lastHitzoneObject.param].number) {
						BankManager.openChatBotScreen( { bankBot:true }, true);
						return;
					}
					BankManager.getCardHistory(data.cards[lastHitzoneObject.param].number, data.cards[lastHitzoneObject.param].masked);
					redrawTopBar();
					topBar.showAnimationOverButton("refreshBtn", false);
					_waiting = true;
					return;
				}
				return;
			}
			if (list.getStock()[n].renderer is ListBankAccountWallets == true ||
				list.getStock()[n].renderer is ListBankAccountCryptoWallets == true ||
				list.getStock()[n].renderer is ListBankAccountSaving == true) {
				lastHitzoneObject = selectedItem.getLastHitZoneObject();
				if (lastHitzoneObject == null)
					return;
				lhz = lastHitzoneObject.type;
				if (lhz == null)
					return;
				if (lhz == HitZoneType.WALLETS_MORE) {
					if (data.opened == false) {
						if (openedNum != -1 &&
							openedNum != n &&
							list.getItemByNum(openedNum) != null &&
							list.getItemByNum(openedNum).data.opened == true) {
								list.getItemByNum(openedNum).data.opened = false;
								list.updateItemByIndex(openedNum, true, true);
						}
						openedNum = n;
					}
					data.opened = !data.opened;
					needToScrollBottom = checkScrollToBottom();
					list.updateItemByIndex(n, true, true);
					if (needToScrollBottom == false)
						needToScrollBottom = checkScrollToBottom();
					if (needToScrollBottom == true)
						list.scrollBottom(true);
					return;
				}
				if ("ACCOUNT_NUMBER" in data.accounts[lastHitzoneObject.param] == true && data.accounts[lastHitzoneObject.param].ACCOUNT_NUMBER != null) {
					if (BankManager.getHistoryAccount() == data.accounts[lastHitzoneObject.param].ACCOUNT_NUMBER) {
						BankManager.openChatBotScreen( { bankBot:true }, true);
						return;
					}
					var currency:String;
					if ("CURRENCY" in data.accounts[lastHitzoneObject.param] == true)
						currency = data.accounts[lastHitzoneObject.param].CURRENCY;
					else if ("COIN" in data.accounts[lastHitzoneObject.param] == true)
						currency = data.accounts[lastHitzoneObject.param].COIN;
					BankManager.getPaymentHistory(1, 50, data.accounts[lastHitzoneObject.param].ACCOUNT_NUMBER, true, false, currency);
					redrawTopBar();
					topBar.showAnimationOverButton("refreshBtn", false);
					_waiting = true;
					return;
				}
				return;
			}
			if (list.getStock()[n].renderer is ListBankAccountInvestments == true) {
				lastHitzoneObject = selectedItem.getLastHitZoneObject();
				if (lastHitzoneObject == null)
					return;
				lhz = lastHitzoneObject.type;
				if (lhz == null)
					return;
				if (lhz == HitZoneType.WALLETS_MORE) {
					if (data.opened == false) {
						if (openedNum != -1 &&
							openedNum != n &&
							list.getItemByNum(openedNum) != null &&
							list.getItemByNum(openedNum).data.opened == true) {
								list.getItemByNum(openedNum).data.opened = false;
								list.updateItemByIndex(openedNum, true, true);
						}
						openedNum = n;
					}
					data.opened = !data.opened;
					needToScrollBottom = checkScrollToBottom();
					list.updateItemByIndex(n, true, true);
					if (needToScrollBottom == false)
						needToScrollBottom = checkScrollToBottom();
					if (needToScrollBottom == true)
						list.scrollBottom(true);
					return;
				}
				if ("ACCOUNT_NUMBER" in data.accounts[lastHitzoneObject.param] == true && data.accounts[lastHitzoneObject.param].ACCOUNT_NUMBER != null) {
					if (BankManager.getHistoryAccount() == data.accounts[lastHitzoneObject.param].INSTRUMENT) {
						BankManager.openChatBotScreen( { bankBot:true }, true);
						return;
					}
					if ("CONSOLIDATE_BALANCE" in data == false) {
						BankManager.openChatBotScreen( { investmentDisclaimer: true }, true);
						return;
					}
					BankManager.showInvestmentItemHistory(data.accounts[lastHitzoneObject.param].INSTRUMENT);
					redrawTopBar();
					topBar.showAnimationOverButton("refreshBtn", false);
					_waiting = true;
					return;
				}
				return;
			}
			if (list.getStock()[n].renderer is ListBankAccountBalance == true) {
				lastHitzoneObject = selectedItem.getLastHitZoneObject();
				if (lastHitzoneObject == null)
					return;
				lhz = lastHitzoneObject.type;
				if (lhz == HitZoneType.WALLETS_MORE) {
					if (data.opened == false) {
						if (openedNum != -1 &&
							openedNum != n &&
							list.getItemByNum(openedNum) != null &&
							list.getItemByNum(openedNum).data.opened == true) {
								list.getItemByNum(openedNum).data.opened = false;
								list.updateItemByIndex(openedNum, true, true);
						}
						openedNum = n;
					}
					data.opened = !data.opened;
					needToScrollBottom = checkScrollToBottom();
					list.updateItemByIndex(n, true, true);
					if (needToScrollBottom == false)
						needToScrollBottom = checkScrollToBottom();
					if (needToScrollBottom == true)
						list.scrollBottom(true);
					return;
				}
				topBar.showAnimationOverButton("refreshBtn", false);
				_waiting = true;
				BankManager.getPaymentHistory(1, 50, "all");
				redrawTopBar();
				return;
			}
			if (list.getStock()[n].renderer is ListBankAccountOther == true) {
				lastHitzoneObject = selectedItem.getLastHitZoneObject();
				if (lastHitzoneObject == null)
					return;
				lhz = lastHitzoneObject.type;
				if (lhz == HitZoneType.LAUNCH_PLATFORM) {
					(new OpenOtherApplicationsAction()).execute();
					return;
				}
				if (lhz == HitZoneType.WALLETS_MORE) {
					if (data.opened == false) {
						if (openedNum != -1 &&
							openedNum != n &&
							list.getItemByNum(openedNum) != null &&
							list.getItemByNum(openedNum).data.opened == true) {
								list.getItemByNum(openedNum).data.opened = false;
								list.updateItemByIndex(openedNum, true, true);
						}
						openedNum = n;
					}
					data.opened = !data.opened;
					needToScrollBottom = checkScrollToBottom();
					list.updateItemByIndex(n, true, true);
					if (needToScrollBottom == false)
						needToScrollBottom = checkScrollToBottom();
					if (needToScrollBottom == true)
						list.scrollBottom(true);
					return;
				}
				return;
			}
			if (BankManager.getIsCardHistory() == true)
				return;
			lastHitzoneObject = selectedItem.getLastHitZoneObject();
			lhz = lastHitzoneObject != null ? lastHitzoneObject.type : null;
			if (lhz == HitZoneType.AVATAR) {
				if ("bankBot" in data && data.bankBot) {
					BankManager.openChatBotScreen( { bankBot:true }, true);
					return;
				}
				var cVO:ChatVO = ChatManager.getChatWithUsersList([data.user.uid]);
				if (cVO != null) {
					var chatScreenData:ChatScreenData = new ChatScreenData();
					chatScreenData.chatVO = cVO;
					chatScreenData.type = ChatInitType.CHAT;
					chatScreenData.backScreen = MobileGui.centerScreen.currentScreenClass;
					chatScreenData.backScreenData = data;
					MobileGui.showChatScreen(chatScreenData);
					return;
				} else {
					MobileGui.changeMainScreen(UserProfileScreen, {
						backScreen: MobileGui.centerScreen.currentScreenClass, 
						backScreenData: data, 
						data: data.user
					} );
					return;
				}
				return;
			}
			if (data.type == "coinTrade") {
				if (lhz == HitZoneType.CIRCLE) {
					return;
				}
				if (BankManager.loadCoinTrades(data, n) == true) {
					coinStatIndex = n;
					return;
				}
			}
			BankManager.openChatBotScreen(data, true);
		}
		
		private function redrawTopBar():void {
			if (currentAccount != BankManager.getHistoryAccount()) {
				currentAccount = BankManager.getHistoryAccount();
				if (currentAccount == null || currentAccount == "all" || currentAccount == "") {
					if (actions[0].id == "infoBtn") {
						actions.shift();
						topBar.setActions(actions);
					}
					topBar.updateTitle(Lang.myAccount);
					input.setButtonsState(false, true, false);
				} else {
					input.setButtonsState(true, true, false);
					if (BankManager.getIsCardHistory() == true)
						topBar.updateTitle("VISA " + BankManager.getCardMasked());
					else if (BankManager.getIsInvestmentHistory() == true)
						topBar.updateTitle("Acc «" + currentAccount + "»");
					else
						topBar.updateTitle("Acc «" + BankManager.getAccountCurrency() + "»");
				}
			}
		}
		
		private function checkScrollToBottom():Boolean {
			var needScrollToBottom:Boolean = true;
			if (list.height < list.innerHeight) {
				needScrollToBottom = Math.abs(list.getBoxY()) + list.height >= list.innerHeight;
				if (needScrollToBottom == false)
					needScrollToBottom = list.scrolledToBottom;
			}
			return needScrollToBottom;
		}
		
		override public function deactivateScreen():void {
			if (_isDisposed == true)
				return;
			super.deactivateScreen();
			if (input != null)
				input.deactivate();
			topBar.deactivate();
			if (list != null) {
				list.deactivate();
				list.S_ITEM_TAP.remove(onItemTap);
				list.S_ITEM_HOLD.remove(onItemHold);
				list.S_MOVING.remove(onListMove);
				list.S_UP.remove(onListTouchUp);
			}
			if (tutorialButton != null) {
				tutorialButton.deactivate();
			}
		}
		
		private function onListMove(position:Number):void {
			/*if (position > 0) {
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
			if (-position < list.itemsHeight - list.height - Config.FINGER_SIZE * 3) {
				scrollBottomButton.alpha = 1;
				if (_isActivated) {
					scrollBottomButton.activate();
				}
				scrollBottomButton.x = int(_width - scrollBottomButton.width - Config.DIALOG_MARGIN * 0.7);
			} else {
				scrollBottomButton.alpha = 0;
				scrollBottomButton.deactivate();
			}*/
		}
		
		private function onListTouchUp():void {
			/*if (loadHistoryOnMouseUp) {
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
			} else {
				if (historyLoadingScroller != null)
					historyLoadingScroller.hide();
			}
			if (questionPanel != null) {
				questionPanel.collapse();
			}*/
		}
		
		private function setListData(data:Array):void {
			list.setData(data, ListBankAccount, ["userAvatar"]);
		}
		
		override public function onBack(e:Event = null):void {
			if (BankManager.getHistoryAccount() != null && 
				BankManager.getHistoryAccount() != "" && 
				BankManager.getHistoryAccount() != "all") {
					BankManager.getPaymentHistory(1, 50, "all");
					redrawTopBar();
					topBar.showAnimationOverButton("refreshBtn", false);
					_waiting = true;
					return;
			}
			BankManager.closeBankChatBotSession();
			super.onBack(e);
			BankManager.stopPayments();
		}
		
		override public function dispose():void {
			super.dispose();
			if (list != null)
				TweenMax.killTweensOf(list);
			BankManager.S_HISTORY.remove(onHistoryLoaded);
			BankManager.S_HISTORY_MORE.remove(onHistoryMoreLoaded);
			BankManager.S_HISTORY_TS_ERROR.remove(onTSError);
			BankManager.S_WALLETS.remove(onWalletsLoaded);
			BankManager.S_CARDS.remove(onCardsLoaded);
			BankManager.S_ALL_DATA.remove(onAllDataLoaded);
			BankManager.S_ERROR.remove(onError);
			BankManager.S_PAYMENT_ERROR.remove(onError);
			BankManager.S_CRYPTO_EXISTS.remove(onCryptoExist);
			BankManager.S_INVESTMENTS.remove(onInvestmentsLoaded);
			BankManager.S_CRYPTO.remove(onCryptoLoaded);
			BankManager.S_TOTAL.remove(onTotalLoaded);
			PayAPIManager.S_SWISS_API_CHECKED.remove(onSwissAPIChecked);
			Assets.removeBackground(backgroundBitmapData);
			UI.disposeBMD(backgroundBitmapData);
			backgroundBitmapData = null;
			if (openedItems != null && openedItems.length != 0) {
				while (openedItems.length) {
					delete openedItems.shift().opened;
				}
			}
			if (headerAlert != null)
				headerAlert.dispose();
			headerAlert = null;
			if (backgroundImage)
				UI.destroy(backgroundImage);
			backgroundImage = null;
			infoAction = null;
			actions = null;
			storedFilters = null;
			storedFiltersForLoading = null;
			if (topBar != null)
				topBar.dispose();
			topBar = null
			if (list != null)
				list.dispose();
			list = null
			if (input != null)
				input.dispose();
			input = null
			if (tutorialButton != null)
				tutorialButton.dispose();
			tutorialButton = null
		}
	}
}