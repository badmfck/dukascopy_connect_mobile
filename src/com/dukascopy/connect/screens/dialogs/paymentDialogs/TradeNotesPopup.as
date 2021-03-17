package com.dukascopy.connect.screens.dialogs.paymentDialogs {
	
	import assets.QrIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.OrderScreenData;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.data.TradeNotesRequest;
	import com.dukascopy.connect.data.coinMarketplace.PaymentsAccountsProvider;
	import com.dukascopy.connect.data.coinMarketplace.TradingOrder;
	import com.dukascopy.connect.data.screenAction.customActions.SendTradeNotesRequestAction;
	import com.dukascopy.connect.gui.button.DDAccountButton;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.renderers.ListLink;
	import com.dukascopy.connect.gui.list.renderers.ListPayCurrency;
	import com.dukascopy.connect.gui.list.renderers.ListPayWalletItem;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.preloader.Preloader;
	import com.dukascopy.connect.gui.tools.HorizontalPreloader;
	import com.dukascopy.connect.screens.dialogs.ScreenLinksDialog;
	import com.dukascopy.connect.screens.dialogs.ScreenPayDialog;
	import com.dukascopy.connect.screens.dialogs.newDialogs.DialogBaseScreen;
	import com.dukascopy.connect.screens.dialogs.paymentDialogs.elements.InputField;
	import com.dukascopy.connect.screens.dialogs.paymentDialogs.elements.InputFieldSelector;
	import com.dukascopy.connect.screens.serviceScreen.Overlay;
	import com.dukascopy.connect.sys.bankManager.BankBotController;
	import com.dukascopy.connect.sys.bankManager.BankManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.softKeyboard.SoftKeyboard;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	
	public class TradeNotesPopup extends DialogBaseScreen {
		
		private const OPTION_LINE_HEIGHT:int = Config.FINGER_SIZE * .8;
		
		private var backButton:BitmapButton;
		private var nextButton:BitmapButton;
		
		private var padding:int;
		
		private var inputWallet:InputField;
		private var inputQantity:InputFieldSelector;
		
		private var screenData:OrderScreenData;
		private var accounts:PaymentsAccountsProvider;
		private var locked:Boolean;
		private var horizontalLoader:HorizontalPreloader;
		private var descriptionText:Bitmap;
		private var cryptoCurrencies:Array;
		private var selectedCurrency:String;
		private var selectorCreditAccont:DDAccountButton;
		private var selectedCreditAccount:Object;
		private var qrButton:BitmapButton;
		
		private var preloader:Preloader;
		private var preloaderBG:Shape;
		
		public function TradeNotesPopup() {
			
		}
		
		override protected function createView():void {
			super.createView();
			
			scrollPanel.background = true;
			
			backButton = new BitmapButton();
			backButton.setStandartButtonParams();
			backButton.setDownScale(1);
			backButton.setDownColor(0);
			backButton.tapCallback = backClick;
			backButton.disposeBitmapOnDestroy = true;
			backButton.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
			container.addChild(backButton);
			
			nextButton = new BitmapButton();
			nextButton.setStandartButtonParams();
			nextButton.setDownScale(1);
			nextButton.setDownColor(0);
			nextButton.tapCallback = nextClick;
			nextButton.disposeBitmapOnDestroy = true;
			nextButton.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
			container.addChild(nextButton);
			
			inputWallet = new InputField(-1, Input.MODE_INPUT);
			inputWallet.onSelectedFunction = onInputSelected;
			inputWallet.onChangedFunction = onChangeInputPrice;
			inputWallet.onLongTapFunction = onLongClick;
			//scrollPanel.addObject(inputWallet);


			
			inputQantity = new InputFieldSelector();
			inputQantity.onSelectedFunction = onInputSelected;
			inputQantity.onChangedFunction = onChangeInputPrice;
			inputQantity.onValueSelectedFunction = selectCurrency;
			scrollPanel.addObject(inputQantity);
			
			horizontalLoader = new HorizontalPreloader(0xF6951D);
			container.addChild(horizontalLoader);
			
			descriptionText = new Bitmap();
			scrollPanel.addObject(descriptionText);
			
			selectorCreditAccont = new DDAccountButton(openWalletCreditSelector);
		
			qrButton = new BitmapButton();
			qrButton.setStandartButtonParams();
			qrButton.setDownScale(1);
			qrButton.setDownColor(0);
			qrButton.tapCallback = openQrClick;
			qrButton.disposeBitmapOnDestroy = true;
			qrButton.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
			//

			
			var icon:QrIcon = new QrIcon();
			UI.scaleToFit(icon, Config.FINGER_SIZE * .6, Config.FINGER_SIZE * .6);
			
			qrButton.setBitmapData(UI.getSnapshot(icon, StageQuality.HIGH, "qr_1"));
		}
		
		private function openQrClick():void 
		{
			ToastMessage.display(Lang.avaliableSoon);
		}
		
		private function openWalletCreditSelector(e:Event = null):void
		{
			SoftKeyboard.closeKeyboard();
			
			if (inputQantity != null)
			{
				inputQantity.forceFocusOut();
			}
			
			if (inputWallet != null)
			{
				inputWallet.forceFocusOut();
			}
			
			if (accounts != null && accounts.ready)
			{
				var accountsList:Array = new Array();
				if (accounts.moneyAccounts != null)
				{
					accountsList = accountsList.concat(accounts.moneyAccounts);
				}
				if (accounts.coinsAccounts != null)
				{
					accountsList = accountsList.concat(accounts.coinsAccounts);
				}
				
				DialogManager.showDialog(ScreenPayDialog, {
														callback: onWalletCreditSelect, 
														data: accountsList, 
														itemClass: ListPayWalletItem, 
														label: Lang.TEXT_SELECT_ACCOUNT});
			}
		}
		
		private function onWalletCreditSelect(account:Object):void
		{
			if (account == null)
			{
				return;
			}
			
			selectedCreditAccount = account;
			selectorCreditAccont.setValue(account);
			
			checkDataValid();
		}
		
		private function selectCurrency():void 
		{
			DialogManager.showDialog(ScreenPayDialog, {callback: callBackSelectCurrency, data: cryptoCurrencies, itemClass: ListPayCurrency, label: Lang.selectCurrency});
		}
		
		private function callBackSelectCurrency(currency:String):void
		{
			if (currency != null)
			{
				selectedCurrency = currency;
				updateQuantity();
			}
		}
		
		private function updateQuantity():void 
		{
			inputQantity.draw(componentsWidth, Lang.amount, inputQantity.value, Lang.minimum + ": " + Config.minimumNotesAmount.toString(), selectedCurrency);
		}
		
		override public function isModal():Boolean 
		{
			return locked;
		}
		
		private function onLongClick():void {
			var menuItems:Array = [];
			var clipboardString:String = String(Clipboard.generalClipboard.getData(ClipboardFormats.TEXT_FORMAT));
			
			if (clipboardString == null || clipboardString == "") return;
			
			menuItems.push({fullLink: Lang.pastFromClipboard, id: 0, disabled: clipboardString == ""});
			
			DialogManager.showDialog(ScreenLinksDialog, {
				callback: function (data:Object):void {
					if (data.id == 0 && data.disabled == false) {
						inputWallet.valueString = clipboardString;
					}
				}, data: menuItems, itemClass: ListLink, title: Lang.TEXT_CLIPBOARD, multilineTitle: false
			});
		}
		
		private function onInputSelected():void {
			
		}
		
		private function onChangeInputPrice():void {
			checkDataValid();
		}
		
		private function checkDataValid():void {
			var valid:Boolean = true;
			if (screenData.type == TradingOrder.SELL) {
				if (isNaN(inputQantity.value) || inputQantity.value < Config.minimumNotesAmount) {
					valid = false;
					inputQantity.invalid();
				} else {
					inputQantity.valid();
				}
			} else if (screenData.type == TradingOrder.BUY) {
				if (isNaN(inputQantity.value) || inputQantity.value < Config.minimumNotesAmount) {
					valid = false;
					inputQantity.invalid();
				} else {
					inputQantity.valid();
				}
				if (selectedCreditAccount == null) {
					valid = false;
				}
			}
			if (valid == false) {
				nextButton.deactivate();
				nextButton.alpha = 0.5;
			} else if (isActivated) {
				nextButton.activate();
				nextButton.alpha = 1;
			}
		}
		
		private function nextClick():void {
			var request:TradeNotesRequest = new TradeNotesRequest();
			request.side = screenData.type;
			request.currency = selectedCurrency;
			request.amount = inputQantity.value;
			request.wallet = inputWallet.valueString;
			
			if (screenData.type == TradingOrder.BUY) {
				request.creditAccount = selectedCreditAccount;
				/*if (Number(selectedCreditAccount.BALANCE) < request.amount) {
					DialogManager.alert(Lang.information, Lang.notEnoughAssets);
					return;
				}*/
			} else {
				deactivateScreen();
				showPreloader();
			}
			SendTradeNotesRequestAction.S_SUCCESS.add(closeView);
			SendTradeNotesRequestAction.S_COMPLETED.add(hidePreloaderAndActivate);
			if (data.callback != null && data.callback is Function && (data.callback as Function).length == 1) {
				data.callback(request);
			}
		}
		
		private function hidePreloaderAndActivate():void {
			activateScreen();
			hidePreloader();
		}
		
		private function hidePreloader():void {
			if (preloader != null)
				preloader.hide();
			if (preloaderBG != null && preloaderBG.parent != null)
				container.removeChild(preloaderBG);
		}
		
		private function showPreloader():void {
			if (preloaderBG == null) {
				preloaderBG = new Shape();
				preloaderBG.graphics.beginFill(0, .3);
				preloaderBG.graphics.drawRect(0, 0, 1, 1);
			}
			preloaderBG.width = _width;
			preloaderBG.height = bg.height - topBar.trueHeight;
			preloaderBG.y = topBar.trueHeight;
			container.addChild(preloaderBG);
			
			preloader ||= new Preloader();
			preloader.x = _width * .5;
			preloader.y = (bg.height - topBar.trueHeight) * .5 + topBar.trueHeight;
			container.addChild(preloader);
			preloader.show();
		}
		
		private function closeView():void {
			ServiceScreenManager.closeView();
		}
		
		private function backClick():void
		{
			rejectPopup();
		}
		
		private function rejectPopup():void 
		{
			ServiceScreenManager.closeView();
		}
		
		override public function onBack(e:Event = null):void
		{
			rejectPopup();
		}
		
		override public function clearView():void
		{
			super.clearView();
		}
		
		override public function initScreen(data:Object = null):void
		{
			var titleValue:String;
			if (data != null && data.data != null && data.data is OrderScreenData)
			{
				screenData = data.data as OrderScreenData;
				if (screenData.type == TradingOrder.SELL)
				{
					titleValue = Lang.sellNotes;
				}
				else if (screenData.type == TradingOrder.BUY)
				{
					titleValue = Lang.buyNotes;
				}
			}
			if (titleValue != null && data != null)
			{
				data.title = titleValue;
			}
			
			super.initScreen(data);
			
			padding = Config.DIALOG_MARGIN;
			
			horizontalLoader.setSize(_width, int(Config.FINGER_SIZE * .07));
			horizontalLoader.y = topBar.y + topBar.trueHeight;
			
			accounts = new PaymentsAccountsProvider(onAccountsDataReady);
			
			inputWallet.draw(componentsWidth - qrButton.width - Config.MARGIN, Lang.cryptoWallet, null, null, null);
			inputWallet.valueString = "";
			
			cryptoCurrencies = getCryptoCurrencies();
			
			selectedCurrency = cryptoCurrencies[0];
			updateQuantity();
			
			drawDescription();
			
			drawNextButton(Lang.textProceed);
			drawBackButton();
			
			if (screenData.type == TradingOrder.BUY) {
				scrollPanel.addObject(selectorCreditAccont);
			}else if(screenData.type==TradingOrder.SELL){
				scrollPanel.addObject(inputWallet);
				scrollPanel.addObject(qrButton);
			}
			
			updatePositions();
			
			if (accounts.ready == true)
			{
				construct();
			}
			else
			{
				horizontalLoader.start();
				accounts.getData();
			}
			
			checkDataValid();
		}
		
		private function getCryptoCurrencies():Array {
			if (BankBotController.cashContracts == null || BankBotController.cashContracts.length == 0)
				return [];
			var res:Array = [];
			for (var i:int = 0; i < BankBotController.cashContracts.length; i++) {
				res.push(BankBotController.cashContracts[i].title.toUpperCase() + "+");
			}
			return res;
		}
		
		private function drawDescription():void 
		{
			var description:String;
			if (screenData.type == TradingOrder.BUY)
			{
				description = Lang.buyNotesDescription;
			}
			else
			{
				description = Lang.sellNotesDescription;
			}
			
			
			descriptionText.bitmapData = TextUtils.createTextFieldData(
																	description, 
																	componentsWidth, 
																	10, 
																	true, 
																	TextFormatAlign.LEFT, 
																	TextFieldAutoSize.LEFT, 
																	Config.FINGER_SIZE * .28, 
																	true, 
																	0x47515B, 
																	0xD9E5F0, false, false, true);
		}
		
		private function onAccountsDataReady():void 
		{
			horizontalLoader.stop();
			construct();
		}
		
		private function construct():void 
		{
			updatePositions();
			drawView();
			
			horizontalLoader.y = topBar.y + topBar.trueHeight;
		}
		
		private function updatePositions():void 
		{
			var position:int = 0;
			
			inputWallet.x = hPadding;
			inputQantity.x = hPadding;
			
			descriptionText.x = hPadding;
			
			descriptionText.y = position;
			position += descriptionText.height + Config.FINGER_SIZE * .5;

			if (screenData.type == TradingOrder.SELL) {
				inputWallet.y = position;
				position += inputWallet.getHeight() + Config.FINGER_SIZE * .5;
			}
			
			inputQantity.y = position;
			position += inputQantity.getHeight() + Config.FINGER_SIZE * .5;
			
			if (screenData.type == TradingOrder.BUY)
			{
				selectorCreditAccont.setSize(componentsWidth, Config.FINGER_SIZE * .8);
				selectorCreditAccont.setValue(Lang.fromAccount);
				selectorCreditAccont.x = hPadding;
				selectorCreditAccont.y = position;
				position += selectorCreditAccont.height + Config.FINGER_SIZE * .5;
			}
			
			backButton.x = Config.DIALOG_MARGIN;
			nextButton.x = backButton.x + backButton.width + Config.MARGIN;
			
			qrButton.x = int(hPadding + componentsWidth - qrButton.width);
			qrButton.y = int(inputWallet.y + inputWallet.height - qrButton.height);
		}
		
		override protected function getMaxContentHeight():int {
			return _height - scrollPanel.view.y - vPadding * 2 - nextButton.height;
		}
		
		override protected function calculateBGHeight():int {
			var value:int = scrollPanel.view.y + scrollPanel.height + vPadding * 2 + nextButton.height;
			return value;
		}
		
		private function drawNextButton(text:String):void
		{
			var textSettings:TextFieldSettings = new TextFieldSettings(text, 0xFFFFFF, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, Color.GREEN, 1, Config.FINGER_SIZE * .8, NaN, (componentsWidth - Config.MARGIN) * .5);
			nextButton.setBitmapData(buttonBitmap, true);
		}
		
		private function drawBackButton():void
		{
			var textSettings:TextFieldSettings = new TextFieldSettings(Lang.textBack, 0x657280, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, 0xFFFFFF, 1, Config.FINGER_SIZE * .8, NaN, (componentsWidth - Config.MARGIN) * .5);
			backButton.setBitmapData(buttonBitmap, true);
		}
		
		override protected function drawView():void
		{
			if (_isDisposed == true)
				return;
			super.drawView();
			horizontalLoader.y = topBar.y + topBar.trueHeight;
			backButton.y = nextButton.y = scrollPanel.view.y + scrollPanel.height + vPadding;
			
			if (preloader != null)
				preloader.y = (bg.height - topBar.trueHeight) * .5 + topBar.trueHeight;
			if (preloaderBG != null) {
				preloaderBG.width = _width;
				preloaderBG.height = bg.height - topBar.trueHeight;
			}
		}
		
		override public function activateScreen():void
		{
			if (_isDisposed == true)
				return;
			
			if (locked)
			{
				return;
			}
			super.activateScreen();
			
			backButton.activate();
			nextButton.activate();
			
			inputWallet.activate();
			inputQantity.activate();
			qrButton.activate();
			
			if (screenData.type == TradingOrder.BUY)
			{
				selectorCreditAccont.activate();
			}
			
			checkDataValid();
		}
		
		override public function deactivateScreen():void
		{
			if (_isDisposed == true)
				return;
			
			super.deactivateScreen();
			
			backButton.deactivate();
			nextButton.deactivate();
			
			inputWallet.deactivate();
			inputQantity.deactivate();
			qrButton.deactivate();
			
			if (screenData.type == TradingOrder.BUY)
			{
				selectorCreditAccont.deactivate();
			}
		}
		
		override public function dispose():void
		{
			if (_isDisposed == true)
				return;
			super.dispose();
			SendTradeNotesRequestAction.S_SUCCESS.remove(closeView);
			SendTradeNotesRequestAction.S_COMPLETED.remove(hidePreloaderAndActivate);
			if (accounts != null)
			{
				accounts.dispose();
				accounts = null;
			}
			
			Overlay.removeCurrent();
			
			if (qrButton != null)
			{
				qrButton.dispose();
				qrButton = null;
			}
			if (descriptionText != null)
			{
				selectorCreditAccont.dispose();
				selectorCreditAccont = null;
			}
			if (descriptionText != null)
			{
				UI.destroy(descriptionText);
				descriptionText = null;
			}
			if (horizontalLoader != null)
			{
				horizontalLoader.dispose();
				horizontalLoader = null;
			}
			if (backButton != null)
			{
				backButton.dispose();
				backButton = null;
			}
			if (nextButton != null)
			{
				nextButton.dispose();
				nextButton = null;
			}
			if (nextButton != null)
			{
				nextButton.dispose();
				nextButton = null;
			}
			if (inputWallet != null)
			{
				inputWallet.dispose();
				inputWallet = null;
			}
			if (inputQantity != null)
			{
				inputQantity.dispose();
				inputQantity = null;
			}
			
			hidePreloader();
			if (preloader != null)
				preloader.dispose();
			preloader = null;
			if (preloaderBG != null)
				preloaderBG.graphics.clear();
			preloaderBG = null;
			
			screenData = null;
		}
		
		override protected function onCloseTap():void {
			if (_isDisposed == true)
				return;
			if (data.callback != null)
				data.callback(null);
			rejectPopup();
		}
	}
}