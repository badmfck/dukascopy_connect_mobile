package com.dukascopy.connect.screens.dialogs.paymentDialogs 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.GiftData;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.gui.button.DDAccountButton;
	import com.dukascopy.connect.gui.button.DDFieldButton;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.renderers.ListPayCurrency;
	import com.dukascopy.connect.gui.list.renderers.ListPayWalletItem;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.menuVideo.OptionSwitcher;
	import com.dukascopy.connect.gui.preloader.Preloader;
	import com.dukascopy.connect.gui.tools.HorizontalPreloader;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.dialogs.ScreenPayDialog;
	import com.dukascopy.connect.screens.payments.card.TypeCurrency;
	import com.dukascopy.connect.screens.serviceScreen.Overlay;
	import com.dukascopy.connect.sys.bankManager.BankBotController;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.payments.InvoiceManager;
	import com.dukascopy.connect.sys.payments.PayManager;
	import com.dukascopy.connect.sys.payments.PayRespond;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.softKeyboard.SoftKeyboard;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import com.dukascopy.langs.LangManager;
	import com.greensock.TweenMax;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	
	public class RewardsDepositPopup extends BaseScreen {
		
		protected var container:Sprite;
		private var bg:Shape;
		private var text:Bitmap;
		private var acceptButton:BitmapButton;
		private var accountText:Bitmap;
		private var backButton:BitmapButton;
		private var selectorDebitAccont:DDAccountButton;
		private var preloader:Preloader;
		private var screenLocked:Boolean;
		private var verticalMargin:Number;
		private var walletSelected:Boolean;
		private var selectedAccount:Object;
		private var currentCommision:Number = 0;
		private var preloaderShown:Boolean = false;
		private var iAmountCurrency:Input;
		private var selectorCurrency:DDFieldButton;
		private var sendSectionTitle:Bitmap;
		private var accountsPreloader:HorizontalPreloader;
		private var giftData:GiftData;
		private var _lastCommissionCallID:String;
		protected var componentsWidth:int;
		private var accounts:Array;
		private var title:Bitmap;
		private var expirationTitle:Bitmap;
		private var rewardTitle:Bitmap;
		private var priceLimitSwitch:OptionSwitcher;
		//private var description:Bitmap;
		
		public function RewardsDepositPopup() {
			
		}
		
		override protected function createView():void {
			super.createView();
			container = new Sprite();
			
			bg = new Shape();
			bg.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			var round:int = Config.FINGER_SIZE * .3;
			var round3:int = round * 3;
			bg.graphics.drawRect(0, 0, round3, round3);
			bg.scale9Grid = new Rectangle(round, round, round, round);
			container.addChild(bg);
			
			accountText = new Bitmap();
			container.addChild(accountText);
			
			title = new Bitmap();
			container.addChild(title);
			
			/*description = new Bitmap();
			container.addChild(description);*/
			
			acceptButton = new BitmapButton();
			acceptButton.setStandartButtonParams();
			acceptButton.setDownScale(1);
			acceptButton.setDownColor(0);
			acceptButton.tapCallback = nextClick;
			acceptButton.disposeBitmapOnDestroy = true;
			acceptButton.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
			container.addChild(acceptButton);
			
			backButton = new BitmapButton();
			backButton.setStandartButtonParams();
			backButton.setDownScale(1);
			backButton.setDownColor(0);
			backButton.tapCallback = backClick;
			backButton.disposeBitmapOnDestroy = true;
			backButton.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
			container.addChild(backButton);
			
			priceLimitSwitch = new OptionSwitcher();
			priceLimitSwitch.onSwitchCallback = switchLimit;
			container.addChild(priceLimitSwitch);
			
			selectorDebitAccont = new DDAccountButton(openWalletSelector, null, DDAccountButton.STYLE_1, false);
			container.addChild(selectorDebitAccont);
			
			_view.addChild(container);
			
			iAmountCurrency = new Input(Input.MODE_DIGIT_DECIMAL);
			iAmountCurrency.setParams(Lang.textAmount, Input.MODE_DIGIT_DECIMAL);
			iAmountCurrency.S_CHANGED.add(onChangeInputValueCurrency);
			iAmountCurrency.S_FOCUS_IN.add(onInputSelected);
			iAmountCurrency.setRoundBG(false);
			iAmountCurrency.getTextField().textColor = Style.color(Style.COLOR_TEXT);
			iAmountCurrency.setRoundRectangleRadius(0);
			iAmountCurrency.inUse = true;
			container.addChild(iAmountCurrency.view);
			
			selectorCurrency = new DDFieldButton(selectCurrencyTap, "", false);
			container.addChild(selectorCurrency);
			
			sendSectionTitle = new Bitmap();
			container.addChild(sendSectionTitle);
			
			accountsPreloader = new HorizontalPreloader();
			container.addChild(accountsPreloader);
			
			expirationTitle = new Bitmap();
			container.addChild(expirationTitle);
			
			rewardTitle = new Bitmap();
			container.addChild(rewardTitle);
		}
		
		private function switchLimit(value:Boolean):void 
		{
			
		}
		
		private function onInputSelected():void 
		{
			
		}
		
		private function checkDataValid():void {
			
			var valid:Boolean = true;
			
			if (isActivated && 
				selectedAccount != null && 
				iAmountCurrency.value != null && 
				iAmountCurrency.value != "" && 
				!isNaN(Number(iAmountCurrency.value)) && 
				Number(iAmountCurrency.value) >= giftData.minAmount)
			{
				if (giftData.maxAmount > 0)
				{
					if (Number(iAmountCurrency.value) <= giftData.maxAmount)
					{
						valid = true;
					}
					else
					{
						valid = false;
					}
				}
				else
				{
					valid = true;
				}
			}
			else
			{
				valid = false;
			}
			
			if (valid == true)
			{
				acceptButton.activate();
				acceptButton.alpha = 1;
				iAmountCurrency.unselectBorder();
			}
			else
			{
				acceptButton.deactivate();
				acceptButton.alpha = 0.5;
				iAmountCurrency.selectBorder();
			}
		}
		
		private function selectCurrencyTap():void 
		{
			var currencies:Array = new Array();
			
			var wallets:Array = getAccounts();
			if (wallets != null && wallets.length > 0)
			{
				var l:int = wallets.length;
				var walletItem:Object;
				var value:String;
				for (var i:int = 0; i < l; i++)
				{
					walletItem = wallets[i];
					if ("COIN" in walletItem)
					{
						value = walletItem.COIN;
						if (Lang[value] != null)
						{
							value = Lang[value];
						}
						currencies.push(walletItem.COIN);
					}
				}
				
				DialogManager.showDialog(ScreenPayDialog, {callback: callBackSelectCurrency, data: currencies, itemClass: ListPayCurrency, label: Lang.selectCurrency});
			}
		}
		
		private function getAccounts():Array 
		{
			if (giftData != null)
			{
				return giftData.wallets;
			}
			return null;
		}
		
		private function openWalletSelector(e:Event = null):void
		{
			SoftKeyboard.closeKeyboard();
			if (iAmountCurrency != null)
			{
				iAmountCurrency.forceFocusOut();
			}
			
			showWalletsDialog();
		}
		
		private function showWalletsDialog():void
		{
			var wallets:Array = getAccounts();
			if (wallets != null && wallets.length > 0)
			{
				DialogManager.showDialog(ScreenPayDialog, {callback: onWalletSelect, data: wallets, itemClass: ListPayWalletItem/*ListPayAccount*/, label: Lang.TEXT_SELECT_ACCOUNT});
			}
		}
		
		private function onWalletSelect(account:Object, cleanCurrent:Boolean = false):void
		{
			if (account == null)
			{
				if (cleanCurrent == true)
				{
					selectedAccount = account;
				//	selectorCurrency.setValue();
					walletSelected = false;
				}	
			}
			else{
				selectedAccount = account;
				selectorCurrency.setValue(account.COIN);
			}
			if (account != null || cleanCurrent == true)
			{
				selectorDebitAccont.setValue(account);
			}
		}
		
		override public function onBack(e:Event = null):void {
			if (screenLocked == false) {
				InvoiceManager.stopProcessInvoice();
				ServiceScreenManager.closeView();
			}
		}
		
		private function backClick():void {
			onBack();
		}
		
		private function nextClick():void {
			SoftKeyboard.closeKeyboard();
			if (iAmountCurrency != null)
			{
				iAmountCurrency.forceFocusOut();
			}
			
			if (giftData != null)
			{
				giftData.accountNumber = selectedAccount.ACCOUNT_NUMBER;
				giftData.currency = selectedAccount.COIN;
				giftData.customValue = Number(iAmountCurrency.value);
				giftData.fiatReward = priceLimitSwitch.isSelected;
				
				if (giftData.callback != null)
				{
					giftData.callback(giftData);
				}
			}
			
			ServiceScreenManager.closeView();
		}
		
		override public function clearView():void
		{
			super.clearView();
			InvoiceManager.stopProcessInvoice();
		}
		
		private function activateButtons():void
		{
			activateBackButton();
			activateAcceptButton();
		}
		
		private function activateBackButton():void
		{
			if (isDisposed)
			{
				return;
			}
			
			if (backButton != null && isActivated)
			{
				backButton.activate();
			}
		}
		
		private function activateAcceptButton():void
		{
			if (isDisposed)
			{
				return;
			}
			
			if (acceptButton != null && isActivated)
			{
				acceptButton.activate();
				acceptButton.alpha = 1;
			}
		}
		
		private function drawTitle(text:String, maxWidth:Number = NaN):void
		{
			var maxTextWidth:Number = maxWidth;
			if (isNaN(maxTextWidth))
			{
				maxTextWidth = componentsWidth;
			}
			
			if (title.bitmapData != null)
			{
				title.bitmapData.dispose();
				title.bitmapData = null;
			}
			
			title.bitmapData = TextUtils.createTextFieldData(
															text, maxTextWidth, 10, true, 
															TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
															Config.FINGER_SIZE * .34, true, 0x47515B, 0xFFFFFF, true);
			
			/*var bdDrawPosition:int = title.y + title.height + Config.FINGER_SIZE * .3;
			
			var h:int = bg.height;
			
			bg.graphics.clear();
			bg.graphics.beginFill(0xD9E5F0);
			bg.graphics.drawRect(0, 0, _width, bdDrawPosition);
			bg.graphics.endFill();
			
			bg.graphics.beginFill(Style.color(Style.COLOR_BACKGRIUND));
			bg.graphics.drawRect(0, bdDrawPosition, _width, h - bdDrawPosition);
			bg.graphics.endFill();*/
		}
		
		override public function initScreen(data:Object = null):void
		{
			super.initScreen(data);
			
			if (data != null && "giftData" in data && data.giftData is GiftData) {
				giftData = data.giftData as GiftData;
			}
			
			componentsWidth = _width - Config.DIALOG_MARGIN * 2;
			
			drawTitle(Lang.rewardsDeposit);
			
			drawSendTitle();
			drawAccountSelector();
		//	drawAccountText(Lang.chooseAccount);
			drawAcceptButton(Lang.textNext);
			acceptButton.deactivate();
			acceptButton.alpha = 0.5;
			drawExpirationTitle();
			drawRewardTitle();
		//	drawDescription();
			
			drawBackButton();
			
			priceLimitSwitch.create(componentsWidth, Config.FINGER_SIZE * .8, null, Lang.fiatReward, false, true, 0x47515B, Config.FINGER_SIZE * .3, 0);
			priceLimitSwitch.x = Config.DIALOG_MARGIN;
			priceLimitSwitch.visible = false;
			
			var itemWidth:int = (componentsWidth - Config.MARGIN) / 2;
			
			title.x = Config.DIALOG_MARGIN;
			
			iAmountCurrency.width = itemWidth;
			iAmountCurrency.view.x = Config.DIALOG_MARGIN;
			
			selectorCurrency.x = iAmountCurrency.view.x + itemWidth + Config.MARGIN;
			selectorCurrency.setSize(itemWidth, Config.FINGER_SIZE * .8);
			
			accountsPreloader.setSize(componentsWidth, int(Config.FINGER_SIZE * .05));
			
			selectInitialData();
			
			if (getAccounts() != null && getAccounts().length == 1)
			{
				selectorCurrency.deactivate();
				selectorDebitAccont.deactivate();
			}
		}
		
	/*	private function drawDescription():void 
		{
			description.bitmapData = TextUtils.createTextFieldData(Lang.amountAvaliable, componentsWidth, 10, false, 
															TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .28, false, 0x999999, 0xFFFFFF, false, true);
			description.x = componentsWidth - description.width + Config.DIALOG_MARGIN;
		}*/
		
		private function selectInitialData():void 
		{
			if (giftData != null && giftData.currency != null)
			{
				callBackSelectCurrency(giftData.currency);
			}
			else{
				selectBigAccount();
			}
			
			if (giftData != null && giftData.customValue != 0)
			{
				iAmountCurrency.value = giftData.customValue.toString();
			}
		}
		
		private function selectAccount(currency:String):void {
			
			var defaultAccount:Object;
			var currencyNeeded:String = currency;
			var wallets:Array = getAccounts();
			if (wallets != null && wallets.length > 0)
			{
				var l:int = wallets.length;
				var walletItem:Object;
				for (var i:int = 0; i < l; i++) {
					walletItem = wallets[i];
					if (currencyNeeded == walletItem.COIN) {
						defaultAccount = walletItem;
						break;
					}
				}
				if (defaultAccount != null) {
					onWalletSelect(defaultAccount);
				} else {
					//drawNoAccountMessage();
					onWalletSelect(null, true);
				}
			}
		}
		
		private function selectBigAccount():void 
		{
			var wallets:Array = getAccounts();
			if (wallets != null && wallets.length > 0)
			{
				var l:int = wallets.length;
			
				if (giftData != null && giftData.accountNumber != null)
				{
					selectDebitAccountByNumber(giftData.accountNumber);
				}
				else{
					var bigAccount:Object;
					if (wallets != null && wallets.length > 0)
					{
						bigAccount = wallets[0];
					}
					for (var i:int = 0; i < l; i++)
					{
						if (Number(bigAccount.BALANCE) < Number(wallets[i].BALANCE))
						{
							bigAccount = wallets[i];
						}
					}
					if (bigAccount != null)
					{
						onWalletSelect(bigAccount);
					}
				}
			}
		}
		
		private function selectDebitAccountByNumber(accountNumber:String):void 
		{
			var account:Object;
			
			var wallets:Array = PayManager.accountInfo.accounts;
			var l:int = wallets.length;
			var walletItem:Object;
			for (var i:int = 0; i < l; i++)
			{
				walletItem = wallets[i];
				if (accountNumber == walletItem.IBAN)
				{
					account = walletItem;
					break;
				}
			}
			if (account != null)
			{
				selectedAccount = account;
				selectorDebitAccont.setValue(account);
				selectorCurrency.setValue(account.COIN);
			}
		}
		
		private function drawSendTitle():void {
			if (sendSectionTitle.bitmapData) {
				sendSectionTitle.bitmapData.dispose();
				sendSectionTitle.bitmapData = null;
			}
			var value:String = Lang.rewardsDepositMinAmount;
			value = LangManager.replace(Lang.regExtValue, value, giftData.minAmount.toString());
			
			var value2:String = Lang.rewardsDepositMaxAmount;
			value2 = LangManager.replace(Lang.regExtValue, value2, giftData.maxAmount.toString());
			if (giftData.maxAmount == 0 || isNaN(giftData.maxAmount))
			{
				value2 = "";
			}
			
			sendSectionTitle.bitmapData = TextUtils.createTextFieldData(
				value + "\n" + value2,
				componentsWidth,
				10,
				false,
				TextFormatAlign.LEFT,
				TextFieldAutoSize.LEFT,
				Config.FINGER_SIZE * .28,
				true,
				0x777E8A,
				0xFFFFFF,
				true,
				true
			);
			sendSectionTitle.x = Config.DIALOG_MARGIN;
			drawView();
		}
		
		private function drawExpirationTitle():void {
			if (expirationTitle.bitmapData) {
				expirationTitle.bitmapData.dispose();
				expirationTitle.bitmapData = null;
			}
			var date:Date = new Date();
			date.setFullYear(date.getFullYear() + 1);
			var month:String = (date.getMonth() + 1).toString();
			if (month.length == 1)
			{
				month = "0" + month;
			}
			var day:String = date.getDate().toString();
			if (day.length == 1)
			{
				day = "0" + day;
			}
			var hours:String = date.getHours().toString();
			if (hours.length == 1)
			{
				hours = "0" + hours;
			}
			var minutes:String = date.getMinutes().toString();
			if (minutes.length == 1)
			{
				minutes = "0" + minutes;
			}
			
			var value:String = Lang.estimatedExpirationDate + ": " + date.getFullYear().toString() + "." + month + "." + day + " " + hours + ":" + minutes/* + "\n\n" + Lang.rewardDescription*/;
			
			expirationTitle.bitmapData = TextUtils.createTextFieldData(value, componentsWidth, 10, true, 
															TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .27, true, 0x777E8A, 0xFFFFFF, false, true);
			expirationTitle.x = Config.DIALOG_MARGIN;
			
			drawView();
		}
		
		private function drawRewardTitle():void {
			if (rewardTitle.bitmapData) {
				rewardTitle.bitmapData.dispose();
				rewardTitle.bitmapData = null;
			}
			var value:String = Lang.depositReward + ": ";
			if (iAmountCurrency.value != iAmountCurrency.getDefValue() && iAmountCurrency.value != "") {
				var val:Number = Number(iAmountCurrency.value);
				if (giftData.fiatReward == true) {
					value += parseFloat((val * BankBotController.rewardFiat).toFixed(2)).toString() + " EUR";
				} else {
					value += parseFloat((BankBotController.getReward(val) * val / 100).toFixed(4)).toString() + " DUK+";
				}
			}
			
			rewardTitle.bitmapData = TextUtils.createTextFieldData(
				value,
				componentsWidth,
				10,
				true,
				TextFormatAlign.LEFT,
				TextFieldAutoSize.LEFT,
				Config.FINGER_SIZE * .27,
				true,
				0x777E8A,
				0xFFFFFF,
				false,
				true
			);
			rewardTitle.x = Config.DIALOG_MARGIN;
			drawView();
		}
		
		private function localSelectCurrency(currency:String):void {
			selectorCurrency.setValue(currency);
			selectorCurrency.activate();
		}
		
		private function callBackSelectCurrency(currency:String):void {
			if (currency == null)
			{
				return;
			}
			if (selectorCurrency != null && currency != null) {
				selectorCurrency.setValue(currency);
				
			//	selectAccount(currency);
			//	checkCommision();
			}
			
			selectAccount(currency);
		}
		
		private function showToastMessage():void {
			ToastMessage.display(Lang.connectionError);
		}
		
		private function onChangeInputValueCurrency():void {
			drawRewardTitle();
			checkDataValid();
		}
		
		private function setDefaultWallet():void 
		{
			if (PayManager.accountInfo == null) return;
			var defaultAccount:Object;
			
			var currencyNeeded:String = TypeCurrency.DCO;
			var wallets:Array = PayManager.accountInfo.accounts;
			var l:int = wallets.length;
			var walletItem:Object;
			for (var i:int = 0; i < l; i++)
			{
				walletItem = wallets[i];
				defaultAccount = walletItem;
				break;
			}
			if (defaultAccount != null)
			{
				onWalletSelect(defaultAccount);
			}
		}
		
		private function drawAccountSelector():void 
		{
			selectorDebitAccont.setSize(componentsWidth, Config.FINGER_SIZE * .8);
			selectorDebitAccont.setValue(Lang.TEXT_SELECT_ACCOUNT);
			selectorDebitAccont.x = Config.DIALOG_MARGIN;
		}
		
		private function drawAcceptButton(text:String):void 
		{
			var textSettings:TextFieldSettings = new TextFieldSettings(text, 0xFFFFFF, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, 0x78C043, 1, Config.FINGER_SIZE * .8, NaN, (componentsWidth - Config.DIALOG_MARGIN) * .5);
			acceptButton.setBitmapData(buttonBitmap, true);
			acceptButton.x = int(acceptButton.width + Config.DIALOG_MARGIN * 2);
		}
		
		private function drawBackButton():void
		{
			var textSettings:TextFieldSettings = new TextFieldSettings(Lang.textBack, 0, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, 0x78C043, 0, Config.FINGER_SIZE * .8, NaN, (componentsWidth - Config.DIALOG_MARGIN) * .5);
			backButton.setBitmapData(buttonBitmap);
			backButton.x = Config.DIALOG_MARGIN;
		}
		
		private function drawAccountText(text:String):void 
		{
			accountText.bitmapData = TextUtils.createTextFieldData(text, componentsWidth, 10, true, TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .24, true, 0xABB8C1, 0xffffff, false);
			accountText.x = int(_width * .5 - accountText.width * .5);
		}
		
		override protected function drawView():void 
		{
			if (_isDisposed == true)
				return;
			
		//	bg.width = _width;
			
			verticalMargin = Config.MARGIN * 1.5;
			
			var position:int = Config.FINGER_SIZE * .35;
			
			title.y = position;
			position += title.height + Config.FINGER_SIZE * .75;
			
			// SEND
			sendSectionTitle.y = position;
			position += sendSectionTitle.height + verticalMargin * 1.5;
		//	sendSectionTitle.x = int(_width * .5 - sendSectionTitle.width * .5);
			
			// AMOUNT
			iAmountCurrency.view.y = position;
			selectorCurrency.y = position;
			position += iAmountCurrency.height + verticalMargin * 1.5;
			
			// ACCOUNT
			selectorDebitAccont.y = position;
			position += selectorDebitAccont.height + Config.FINGER_SIZE * .0;
			
			
			/*description.y = position;
			position += description.height + verticalMargin * 2.2;*/
			
			accountsPreloader.y = selectorDebitAccont.y + selectorDebitAccont.height;
			accountsPreloader.x = selectorDebitAccont.x;
			
			priceLimitSwitch.y = position;
			position += priceLimitSwitch.height + Config.FINGER_SIZE * .4;
			
			expirationTitle.x = int(Config.DIALOG_MARGIN);
			expirationTitle.y = int(position);
			position += expirationTitle.height + Config.FINGER_SIZE * .3;
			
			rewardTitle.x = int(Config.DIALOG_MARGIN);
			rewardTitle.y = int(position);
			position += rewardTitle.height + Config.FINGER_SIZE * .3;
			
			acceptButton.y = position;
			backButton.y = position;
			position += acceptButton.height + verticalMargin * 1.8;
			
			var bdDrawPosition:int = title.y + title.height + Config.FINGER_SIZE * .3;
			
			bg.graphics.clear();
			bg.graphics.beginFill(0xD9E5F0);
			bg.graphics.drawRect(0, 0, _width, bdDrawPosition);
			bg.graphics.endFill();
			
			bg.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			bg.graphics.drawRect(0, bdDrawPosition, _width, position - bdDrawPosition);
			bg.graphics.endFill();
			
			container.y = _height - position;
		}
		
		override public function activateScreen():void 
		{
			if (_isDisposed == true)
				return;
			
			super.activateScreen();
			
			iAmountCurrency.activate();
			priceLimitSwitch.activate();
			checkDataValid();
			
			backButton.activate();
			
			if (getAccounts() != null && getAccounts().length > 1)
			{
				selectorDebitAccont.activate();
				selectorCurrency.activate();
			}
		}
		
		override public function deactivateScreen():void 
		{
			if (_isDisposed == true)
				return;
			
			super.deactivateScreen();
			
			priceLimitSwitch.deactivate();
			iAmountCurrency.deactivate();
			acceptButton.deactivate();
			backButton.deactivate();
			selectorDebitAccont.deactivate();
			selectorCurrency.deactivate();
		}
		
		protected function onCloseTap():void 
		{
			DialogManager.closeDialog();
		}
		
		override public function dispose():void 
		{
			if (_isDisposed == true)
				return;
			super.dispose();
			
			Overlay.removeCurrent();
			
			if (sendSectionTitle != null)
			{
				UI.destroy(sendSectionTitle);
				sendSectionTitle = null;
			}
			if (priceLimitSwitch != null)
			{
				priceLimitSwitch.dispose();
				priceLimitSwitch = null;
			}
			if (selectorCurrency != null)
			{
				selectorCurrency.dispose();
				selectorCurrency = null;
			}
			if (iAmountCurrency != null)
			{
				iAmountCurrency.dispose();
				iAmountCurrency = null;
			}
			if (title != null)
			{
				UI.destroy(title);
				title = null;
			}
			if (text != null)
			{
				UI.destroy(text);
				text = null;
			}
			if (preloader != null)
			{
				preloader.dispose();
				preloader = null;
			}
			if (selectorDebitAccont != null)
			{
				selectorDebitAccont.dispose();
				selectorDebitAccont = null;
			}
			if (backButton != null)
			{
				backButton.dispose();
				backButton = null;
			}
			if (accountText != null)
			{
				UI.destroy(accountText);
				accountText = null;
			}
			if (acceptButton != null)
			{
				acceptButton.dispose();
				acceptButton = null;
			}
			if (bg != null)
			{
				UI.destroy(bg);
				bg = null;
			}
			/*if (description != null)
			{
				UI.destroy(description);
				description = null;
			}*/
			if (container != null)
			{
				UI.destroy(container);
				container = null;
			}
			if (expirationTitle != null)
			{
				UI.destroy(expirationTitle);
				expirationTitle = null;
			}
			if (rewardTitle != null)
			{
				UI.destroy(rewardTitle);
				expirationTitle = null;
			}
			if (accountsPreloader != null)
			{
				accountsPreloader.dispose();
				accountsPreloader = null;
			}
			
			giftData = null;
		}
	}
}