package com.dukascopy.connect.screens.dialogs.newDialogs {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.gui.button.DDAccountButton;
	import com.dukascopy.connect.gui.button.DDFieldButton;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.renderers.ListPayCurrency;
	import com.dukascopy.connect.gui.list.renderers.ListPayWalletItem;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.tools.HorizontalPreloader;
	import com.dukascopy.connect.screens.dialogs.ScreenPayDialog;
	import com.dukascopy.connect.screens.serviceScreen.Overlay;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.payments.PayLimits;
	import com.dukascopy.connect.sys.payments.PayManager;
	import com.dukascopy.connect.sys.payments.PaymentsManager;
	import com.dukascopy.connect.sys.questionsManager.QuestionsManager;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.softKeyboard.SoftKeyboard;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	/**
	 * Класс полностью завершен! Не трогать без спроса!!!
	 * @author Ilya Shcherbakov. Telefision Team RIGA.
	 */
	
	public class ScreenExtraTipsPopup extends DialogBaseScreen {
		
		private var labelAmount:Bitmap;
		private var inputAmount:Input;
		private var labelCurrency:Bitmap;
		private var inputCurrency:DDFieldButton;
		
		private var btnOk:BitmapButton;
		
		private var selectorDebitAccont:DDAccountButton;
		private var accountsPreloader:HorizontalPreloader;
		
		private var inputWidth:int;
		private var type:String = QuestionsManager.QUESTION_TYPE_PRIVATE;
		
		private var walletSelected:Boolean;
		private var selectedAccount:Object;
		private var dataReady:Boolean;
		
		public function ScreenExtraTipsPopup() {
			super();
		}
		
		override protected function createView():void {
			super.createView();
			
			labelAmount = new Bitmap();
			scrollPanel.addObject(labelAmount);
			labelAmount.x = hPadding;
			
			inputAmount = new Input(Input.MODE_DIGIT_DECIMAL);
			inputAmount.setParams(Lang.textAmount, Input.MODE_DIGIT_DECIMAL);
			inputAmount.setDecimals(2);
			inputAmount.setRoundBG(false);
			inputAmount.setTextColor(0x5D6A77);
			inputAmount.setRoundRectangleRadius(0);
			inputAmount.inUse = true;
			scrollPanel.addObject(inputAmount.view);
			
			labelCurrency = new Bitmap();
			scrollPanel.addObject(labelCurrency);
			
			inputCurrency = new DDFieldButton(selectCurrency);
			scrollPanel.addObject(inputCurrency);
			
			btnOk = new BitmapButton();
			btnOk.setStandartButtonParams();
			btnOk.cancelOnVerticalMovement = true;
			btnOk.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
			btnOk.setDownScale(1);
			btnOk.setDownColor(0);
			btnOk.alpha = .6;
			btnOk.hide();
			btnOk.tapCallback = onOK;
			btnOk.disposeBitmapOnDestroy = true;
			container.addChild(btnOk);
			
			selectorDebitAccont = new DDAccountButton(openWalletSelector);
			scrollPanel.addObject(selectorDebitAccont);
			
			accountsPreloader = new HorizontalPreloader();
			scrollPanel.addObject(accountsPreloader);
		}
		
		private function checkData():void {
			PaymentsManager.S_ACCOUNT.add(onDataReady);
			if (PaymentsManager.activate() == false && PayManager.accountInfo != null)
				onDataReady();
		}
		
		private function onDataReady():void {
			if (_isDisposed)
				return;
			PaymentsManager.S_ACCOUNT.remove(onDataReady);
			dataReady = true;
			accountsPreloader.stop();
			if (isActivated == true)
				selectorDebitAccont.activate();
			selectBigAccount();
		}
		
		private function drawAccountSelector():void {
			selectorDebitAccont.setSize(componentsWidth, Config.FINGER_SIZE * .8);
			selectorDebitAccont.setValue(Lang.TEXT_SELECT_ACCOUNT);
			selectorDebitAccont.x = hPadding;
		}
		
		private function selectBigAccount():void {
			if (PayManager.accountInfo == null)
				return;
			var wallets:Array = PayManager.accountInfo.accounts;
			var l:int = wallets.length;
			var bigAccount:Object;
			if (wallets != null && wallets.length > 0)
				bigAccount = wallets[0];
			for (var i:int = 0; i < l; i++) {
				if (Number(bigAccount.BALANCE) < Number(wallets[i].BALANCE))
					bigAccount = wallets[i];
			}
			if (bigAccount != null)
				onWalletSelect(bigAccount);
		}
		
		private function checkDataValid():void {
			var tipsLimitMax:int = PayLimits.getTipsLimitMaxForCurrency(inputCurrency.value, type);
			var tipsLimitMin:Number = PayLimits.getTipsLimitMinForCurrency(inputCurrency.value, type);
			var tipsAmount:Number = Number(inputAmount.value);
			if (isNaN(tipsAmount) == true)
				inputAmount.setIncorrect(true);
			else if (tipsAmount > tipsLimitMax)
				inputAmount.setIncorrect(true);
			else if (tipsAmount < tipsLimitMin) 
				inputAmount.setIncorrect(true);
			else
				inputAmount.setIncorrect(false);
			if (_isActivated == true && 
				selectedAccount != null &&
				inputAmount.getIncorrect() == false) {
					btnOk.activate();
					btnOk.alpha = 1;
			} else {
				btnOk.deactivate();
				btnOk.alpha = 0.5;
			}
		}
		
		private function openWalletSelector(e:Event = null):void {
			
			if (PayManager.accountInfo == null)
			{
				//trace("NO ACCOUNT!");
				return;
			}
			var accounts:Array = new Array();
			if (PayManager.accountInfo.coins != null)
			{
				accounts = accounts.concat(PayManager.accountInfo.coins)
			}
			if (PayManager.accountInfo.accounts != null)
			{
				accounts = accounts.concat(PayManager.accountInfo.accounts);
			}
			
			SoftKeyboard.closeKeyboard();
			if (inputAmount != null)
				inputAmount.forceFocusOut();
			if (dataReady == true) {
				DialogManager.showDialog(
					ScreenPayDialog, 
					{
						callback: onWalletSelect, 
						data: accounts, 
						itemClass: ListPayWalletItem, 
						label: Lang.TEXT_SELECT_ACCOUNT
					}
				);
			} else {
				checkData();
				accountsPreloader.start();
			}
		}
		
		private function onWalletSelect(account:Object, cleanCurrent:Boolean = false):void {
			if (account == null) {
				if (cleanCurrent == true) {
					selectedAccount = account;
					walletSelected = false;
				}	
			} else {
				selectedAccount = account;
				if ("CURRENCY" in account)
				{
					inputCurrency.setValue(account.CURRENCY);
				}
				else
				{
					inputCurrency.setValue(account.COIN);
				}
			}
			if (account != null || cleanCurrent == true) {
				selectorDebitAccont.setValue(account);
				checkDataValid();
			}
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			if ("type" in data == true && data.type != null)
				type = data.type;
			
			inputWidth = (componentsWidth - Config.MARGIN) * .5;
			
			if (labelAmount.bitmapData == null)
				labelAmount.bitmapData = createLabel(Lang.textAmount);
			if (labelCurrency.bitmapData == null)
				labelCurrency.bitmapData = createLabel(Lang.textCurrency);
			
			if (isNaN(QuestionsManager.getTipsAmount()) == false && QuestionsManager.getTipsAmount() != 0) {
				inputAmount.value = QuestionsManager.getTipsAmount().toString();
				inputAmount.setIncorrect(false);
			}
			inputAmount.width = inputWidth;
			inputAmount.view.x = labelAmount.x;
			inputAmount.view.y = int(labelAmount.y + labelAmount.height + Config.MARGIN);
			
			labelCurrency.x = labelAmount.x + inputWidth + Config.MARGIN;
			
			inputCurrency.setSize(inputWidth, inputAmount.height);
			inputCurrency.x = labelCurrency.x;
			inputCurrency.y = inputAmount.view.y;
			if (data.currency != null)
				localSelectCurrency(data.currency);
			else if (QuestionsManager.getTipsCurrency())
				localSelectCurrency(QuestionsManager.getTipsCurrency());
			else
				localSelectCurrency("EUR");
			
			var tipsLimitMax:int = PayLimits.getTipsLimitMaxForCurrency(inputCurrency.value, type);
			var tipsLimitMin:Number = PayLimits.getTipsLimitMinForCurrency(inputCurrency.value, type);
			inputAmount.setMaxValue(tipsLimitMax);
			inputAmount.setMinValue(tipsLimitMin);
			if (QuestionsManager.getTipsAmount() > tipsLimitMax) {
				QuestionsManager.saveTipsForCurrentQuestion(tipsLimitMax, inputCurrency.value);
				inputAmount.value = QuestionsManager.getTipsAmount().toString();
				inputAmount.setIncorrect(false);
			} else if (QuestionsManager.getTipsAmount() < tipsLimitMin) {
				QuestionsManager.saveTipsForCurrentQuestion(tipsLimitMin, inputCurrency.value);
				inputAmount.value = QuestionsManager.getTipsAmount().toString();
				inputAmount.setIncorrect(false);
			}
			
			drawAccountSelector();
			accountsPreloader.setSize(componentsWidth, int(Config.FINGER_SIZE * .05));
			
			selectorDebitAccont.y = int(inputCurrency.y + inputCurrency.height + Config.FINGER_SIZE * .3);
			selectorDebitAccont.x = inputAmount.view.x;
			accountsPreloader.y = selectorDebitAccont.y + selectorDebitAccont.height;
			accountsPreloader.x = selectorDebitAccont.x;
			
			var textSettings_ok:TextFieldSettings = new TextFieldSettings(Lang.textOk.toUpperCase(), 0xFFFFFF, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			var buttonBitmap_ok:ImageBitmapData = TextUtils.createbutton(textSettings_ok, Color.GREEN, 1);
			btnOk.setBitmapData(buttonBitmap_ok, true);
			btnOk.x = int(_width * .5 - btnOk.width * .5);
			
			checkData();
		}
		
		override protected function drawView():void {
			super.drawView();
			btnOk.y = scrollPanel.view.y + scrollPanel.height + vPadding;
		}
		
		private function createLabel(val:String):ImageBitmapData {
			var ibmd:ImageBitmapData = UI.renderTextShadowed(
				val,
				inputWidth,
				Config.FINGER_SIZE,
				false,
				false,
				TextFormatAlign.LEFT,
				TextFieldAutoSize.LEFT,
				Config.FINGER_SIZE * .23,
				false,
				0xFFFFFF,
				0x000000,
				AppTheme.GREY_MEDIUM,
				true,
				1,
				false
			);
			return ibmd;
		}
		
		override protected function getMaxContentHeight():int {
			return _height - scrollPanel.view.y - vPadding * 2 - btnOk.height;
		}
		
		override protected function calculateBGHeight():int {
			return scrollPanel.view.y + scrollPanel.height + vPadding * 2 + btnOk.height;
		}
		
		override public function activateScreen():void {
			if (_isDisposed == true)
				return;
			super.activateScreen();
			if (inputAmount != null) {
				inputAmount.activate();
				if (inputAmount.S_CHANGED != null)
					inputAmount.S_CHANGED.add(onChangeInputValue);
			}
			selectorDebitAccont.activate();
			if (inputCurrency != null)
					inputCurrency.activate();
			if (btnOk.getIsShown() == false)
				btnOk.show(.3, .15, true, 0.9, 0);
			SoftKeyboard.S_KEY.add(changeBtnOKState);
			checkDataValid();
		}
		
		override public function deactivateScreen():void {
			if (_isDisposed == true)
				return;
			super.deactivateScreen();
			if (inputAmount != null) {
				if (inputAmount.value == "")
					inputAmount.forceFocusOut();
				if (inputAmount.S_CHANGED != null)
					inputAmount.S_CHANGED.remove(onChangeInputValue);
				inputAmount.deactivate();
			}
			if (inputCurrency != null)
				inputCurrency.deactivate();
			SoftKeyboard.S_KEY.remove(changeBtnOKState);
		}
		
		private function changeBtnOKState(...rest):void {
			if (_isDisposed == true)
				return;
			checkDataValid();
		}
		
		private function localSelectCurrency(currency:String):void {
			if (inputCurrency != null)
				inputCurrency.setValue(currency);
		}
		
		private function onChangeInputValue():void {
			checkDataValid();
		}
		
		private function selectCurrency():void {
			if (PayManager.systemOptions == null)
			{
				return;
			}
			
			var currencies:Array = new Array();
			currencies.push("DCO");
			if (PayManager.systemOptions.currencyList != null)
			{
				currencies = currencies.concat(PayManager.systemOptions.currencyList);
			}
			
			QuestionsManager.saveTipsForCurrentQuestion(Number(inputAmount.value), inputCurrency.value);
			DialogManager.showDialog(ScreenPayDialog, { callback:callBackSelectCurrency, data:currencies, itemClass:ListPayCurrency, label:Lang.selectCurrency } );
		}
		
		private function callBackSelectCurrency(currency:String):void {
			if (!isDisposed)
				inputCurrency.setValue(currency);
			if (currency == "DCO")
			{
				if (PayManager.accountInfo != null && PayManager.accountInfo.coins != null && PayManager.accountInfo.coins.length > 0)
				{
					for (var i:int = 0; i < PayManager.accountInfo.coins.length; i++) 
					{
						if (PayManager.accountInfo.coins[i].COIN == "DCO")
						{
							onWalletSelect(PayManager.accountInfo.coins[i], true);
							break;
						}
					}
				}
			}
		}
		
		private function onOK():void {
			if (selectedAccount == null)
				return;
			var queT:Number = Number(inputAmount.value);
			var accB:Number = Number(selectedAccount.BALANCE);
			if (isNaN(queT) == true || isNaN(accB) == true)
				return;
			if (accB - queT < 0)
				return;
			QuestionsManager.setWalletForCurrentQuestion(selectedAccount.ACCOUNT_NUMBER);
			
			var currency:String = inputCurrency.value;
			if (currency == "DUK+")
			{
				currency = "DCO";
			}
			
			QuestionsManager.saveTipsForCurrentQuestion(Number(inputAmount.value), currency, true);
			if (QuestionsManager.getCurrentQuestion() != null)
				QuestionsManager.editQuestion(QuestionsManager.getCurrentQuestion().uid, null);
			onCloseTap();
		}
		
		override protected function onCloseTap():void {
			if (QuestionsManager.getTipsSetted() != true)
				QuestionsManager.resetTips();
			if (_isDisposed == true)
				return;
			if (data.callback != null)
				data.callback(0);
			ServiceScreenManager.closeView();
		}
		
		override public function dispose():void {
			super.dispose();
			PaymentsManager.S_ACCOUNT.remove(onDataReady);
			PaymentsManager.deactivate();
			UI.destroy(labelAmount);
			labelAmount = null;
			if (inputAmount != null)
				inputAmount.dispose();
			inputAmount = null;
			UI.destroy(labelCurrency);
			if (inputCurrency != null)
				inputCurrency.dispose();
			inputCurrency = null;;
			if (btnOk != null)
				btnOk.dispose();
			btnOk = null;
			
			Overlay.removeCurrent();
		}
	}
}