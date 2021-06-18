package com.dukascopy.connect.screens.dialogs.paymentDialogs 
{
	import assets.ArrowDown;
	import assets.IconAttention2;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.GiftData;
	import com.dukascopy.connect.data.SelectorItemData;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.gui.button.DDAccountButton;
	import com.dukascopy.connect.gui.button.DDFieldButton;
	import com.dukascopy.connect.gui.components.CirclePreloader;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.List;
	import com.dukascopy.connect.gui.list.renderers.ListPayCurrency;
	import com.dukascopy.connect.gui.list.renderers.ListPayWalletItem;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.preloader.Preloader;
	import com.dukascopy.connect.gui.tools.HorizontalPreloader;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.dialogs.ScreenPayDialog;
	import com.dukascopy.connect.screens.dialogs.bottom.ListSelectionPopup;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.payments.PayManager;
	import com.dukascopy.connect.sys.payments.PaymentsManager;
	import com.dukascopy.connect.sys.payments.advancedPayments.vo.PayTaskVO;
	import com.dukascopy.connect.sys.paymentsManagerNew.PaymentsManagerNew;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.softKeyboard.SoftKeyboard;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import fl.motion.Color;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	
	public class MoneyExchangePopup extends BaseScreen {
		
		protected var container:Sprite;
		private var bg:Shape;
		private var text:Bitmap;
		private var acceptButton:BitmapButton;
		private var accountText:Bitmap;
		private var backButton:BitmapButton;
		private var selectorDebitAccont:DDAccountButton;
		private var preloader:CirclePreloader;
		private var _lastCommissionCallID:String;
		private var screenLocked:Boolean;
		private var finishImage:Bitmap;
		private var finishImageMask:Sprite;
		private var verticalMargin:Number;
		private var walletSelected:Boolean;
		private var debitAmount:Input;
		private var payId:String;
		private var currentCommision:Number = 0;
		private var preloaderShown:Boolean = false;
		private var icon:Bitmap;
		private var avatarSize:int;
		private var creditAmount:Input;
		private var title:Bitmap;
		private var titleDebit:Bitmap;
		private var titleCredit:Bitmap;
		private var rateCallID:String;
		private var latestCommissionData:Object;
		private var _hasLoadedCommission:Boolean;
		private var targetDebitAccount:Boolean;
		private var _isLoadingCommission:Boolean = false; // in process 
		private var giftData:GiftData;
		private var timeout:Number = 30;
		private var selectorCreditAccont:DDAccountButton;
		
		static private var c:int = 0;
		private var selectorDebitCurrency:DDFieldButton;
		private var selectorCreditCurrency:DDFieldButton;
		private var arrowClip:assets.ArrowDown;
		private var accountsPreloader:HorizontalPreloader;
		private var dataReady:Boolean;
		private var selectedDebitAccount:Object;
		private var selectedCreditAccount:Object;
		private var costValue:flash.display.Bitmap;
		private var iconAttention:IconAttention2;
		private var attentionText:Bitmap;

		private static function generateCallID(prefix:String):String {c++; return c +"" + prefix as String; }

		protected var componentsWidth:int;
		
		public function MoneyExchangePopup() {
			
		}
		
		override protected function createView():void {
			super.createView();
			container = new Sprite();
			
			avatarSize = Config.FINGER_SIZE * 1.5;
			
			bg = new Shape();
			bg.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			var round:int = Config.FINGER_SIZE * .3;
			var round3:int = round * 3;
			bg.graphics.drawRect(0, 0, round3, round3);
			bg.scale9Grid = new Rectangle(round, round, round, round);
			container.addChild(bg);
			
			accountText = new Bitmap();
			container.addChild(accountText);
			
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
			
			selectorDebitAccont = new DDAccountButton(openDebitWalletSelector, null, true, com.dukascopy.connect.sys.style.presets.Color.RED);
			container.addChild(selectorDebitAccont);
			
			selectorCreditAccont = new DDAccountButton(openWalletCreditSelector, null, true, Style.color(Style.COLOR_TEXT));
			container.addChild(selectorCreditAccont);
			
			selectorDebitCurrency = new DDFieldButton(selectDebitCurrencyTap);
			selectorDebitCurrency.setValue(getCurrencyText());
			container.addChild(selectorDebitCurrency);
			
			selectorCreditCurrency = new DDFieldButton(selectCreditCurrencyTap);
			selectorCreditCurrency.setValue(getCurrencyText());
			container.addChild(selectorCreditCurrency);
			
			_view.addChild(container);
			
			debitAmount = new Input(Input.MODE_DIGIT_DECIMAL);
			debitAmount.setParams(Lang.textAmount, Input.MODE_DIGIT_DECIMAL);
			debitAmount.S_CHANGED.add(onChangeInputValue);
			debitAmount.setRoundBG(false);
			//debitAmount.getTextField().textColor = AppTheme.GREY_MEDIUM;
			debitAmount.getTextField().textColor = com.dukascopy.connect.sys.style.presets.Color.RED;
			debitAmount.setRoundRectangleRadius(0);
			debitAmount.inUse = true;
			container.addChild(debitAmount.view);
			
			creditAmount = new Input(Input.MODE_DIGIT_DECIMAL);
			creditAmount.setParams(Lang.textAmount, Input.MODE_DIGIT_DECIMAL);
			creditAmount.S_CHANGED.add(onChangeInputValueCurrency);
			creditAmount.setRoundBG(false);
			//creditAmount.getTextField().textColor = AppTheme.GREY_MEDIUM;
			creditAmount.getTextField().textColor = com.dukascopy.connect.sys.style.presets.Color.GREEN;
			creditAmount.setRoundRectangleRadius(0);
			creditAmount.inUse = true;
			container.addChild(creditAmount.view);
			
			costValue = new Bitmap();
			container.addChild(costValue);
			
			title = new Bitmap();
			container.addChild(title);
			
			titleDebit = new Bitmap();
			container.addChild(titleDebit);

			titleCredit = new Bitmap();
			container.addChild(titleCredit);

			arrowClip = new ArrowDown();
			container.addChild(arrowClip);
			UI.scaleToFit(arrowClip, Config.FINGER_SIZE * .35, Config.FINGER_SIZE * .35);
			
			accountsPreloader = new HorizontalPreloader();
			container.addChild(accountsPreloader);

			iconAttention = new IconAttention2();
			container.addChild(iconAttention);

			var iconSize:int = Config.FINGER_SIZE * .25;
			UI.scaleToFit(iconAttention, iconSize, iconSize);

			attentionText = new Bitmap();
			container.addChild(attentionText);

			attentionText.visible = false;
			iconAttention.visible = false;
		}

		private function getCurrencyText():String
		{
			return Lang.currency;
		}
		
		private function selectCreditCurrencyTap(e:Event = null):void {
			
			var currencies:Array;

			var existingCurrencies:Array = getCurrencies();
			if (existingCurrencies != null && existingCurrencies.length > 0)
			{
				currencies = existingCurrencies;
			}
			else
			{
				currencies = new Array();
				
				var exist:Object = new Object();
				
				var wallets:Array = getCreditAccounts();
				var l:int = wallets.length;
				var walletItem:Object;
				for (var i:int = 0; i < l; i++)
				{
					walletItem = wallets[i];
					currencies.push(walletItem.CURRENCY);
					if (exist[walletItem.CURRENCY] != null)
					{
						return;
					}
					exist[walletItem.CURRENCY] = walletItem.CURRENCY;
				}
			}
			
			DialogManager.showDialog(
					ListSelectionPopup,
					{
						items:currencies,
						title:Lang.selectCurrency,
						renderer:ListPayCurrency,
						callback:callBackSelectCreditCurrency
					}, ServiceScreenManager.TYPE_SCREEN
				);
		//	DialogManager.showDialog(ScreenPayDialog, {callback: callBackSelectCreditCurrency, data: getCurrencies(), itemClass: ListPayCurrency, label: Lang.selectCurrency});
		}

		/*private function onCreditCurrencySelected(selectedValue:SelectorItemData):void
		{
			if (selectedValue != null)
			{
				callBackSelectCreditCurrency(selectedValue.data);
			}
		}*/

		private function getCurrencies():Array
		{
			if (data != null && "giftData" in data && data.giftData != null && "currencies" in data.giftData && data.giftData.currencies != null && data.giftData.currencies is Array)
			{
				return data.giftData.currencies as Array;
			}
			else
			{
			//	ApplicationErrors.add();
				return new Array();
			}
		}
		
		private function callBackSelectCreditCurrency(currency:String):void {
			if (selectorCreditCurrency != null && currency != null) {
				selectorCreditCurrency.setValue(currency);
				selectCreditAccount(currency);
				checkCommision();
			}
		}
		
		private function selectCreditAccount(currency:String):void 
		{
			var account:Object;
			var currencyNeeded:String = currency;
			var wallets:Array = getCreditAccounts();
			var l:int = wallets.length;
			var walletItem:Object;
			for (var i:int = 0; i < l; i++)
			{
				walletItem = wallets[i];
				if (currencyNeeded == walletItem.CURRENCY)
				{
					account = walletItem;
					break;
				}
			}
			if (account == null)
			{
				account = {CURRENCY:currency, ACCOUNT_NUMBER:currency};
			}
			if (account != null)
			{
				selectedCreditAccount = account;
				selectorCreditAccont.setValue(account);
			}
			else{
				selectorCreditAccont.setValue(currency);
			}
			
		//	targetDebitAccount = false;
			startLoadRate();
			
			updateButtonsState();
		}
		
		private function selectDebitCurrencyTap(e:Event = null):void {
			var currencies:Array = new Array();
			
			var wallets:Array = getDebitAccounts();
			var l:int = wallets.length;
			var walletItem:Object;
			var exist:Object = new Object();
			for (var i:int = 0; i < l; i++)
			{
				walletItem = wallets[i];
				currencies.push(walletItem.CURRENCY)
				if (exist[walletItem.CURRENCY] != null)
				{
					return;
				}
				exist[walletItem.CURRENCY] = walletItem.CURRENCY;
			}
			
			DialogManager.showDialog(
					ListSelectionPopup,
					{
						items:currencies,
						title:Lang.selectCurrency,
						renderer:ListPayCurrency,
						callback:callBackSelectDebitCurrency
					}, ServiceScreenManager.TYPE_SCREEN
				);

		//	DialogManager.showDialog(ScreenPayDialog, {callback: callBackSelectDebitCurrency, data: currencies, itemClass: ListPayCurrency, label: Lang.selectCurrency});
		}
		
		private function callBackSelectDebitCurrency(currency:String):void {
			if (selectorDebitCurrency != null && currency != null) {
				selectorDebitCurrency.setValue(currency);
				selectDebitAccount(currency);
				checkCommision();
			}
			startLoadRate();
			updateButtonsState();
		//	onChangeInputValue();
		}
		
		private function selectDebitAccount(currency:String):void 
		{
			var account:Object;
			var currencyNeeded:String = currency;
			var wallets:Array = getDebitAccounts();
			var l:int = wallets.length;
			var walletItem:Object;
			for (var i:int = 0; i < l; i++)
			{
				walletItem = wallets[i];
				if (currencyNeeded == walletItem.CURRENCY)
				{
					account = walletItem;
					break;
				}
			}
			if (account != null)
			{
				selectedDebitAccount = account;
				selectorDebitAccont.setValue(account);
			}
			updateButtonsState();
		}
		
		private function openWalletCreditSelector(e:Event = null):void {
			SoftKeyboard.closeKeyboard();
			if (creditAmount != null)
				creditAmount.forceFocusOut();
			if (debitAmount != null)
				debitAmount.forceFocusOut();

			var currencies:Array = getCurrencies();
			var newCurrencies:Array = new Array();
			var l:int = currencies.length;
			var walletItem:Object;
			var currencyAccount:Object;
			for (var i:int = 0; i < l; i++)
			{
				var exist:Boolean = false;
				var accounts:Array = getCreditAccounts();
				for (var j:int = 0; j < accounts.length; j++)
				{
					walletItem = accounts[j];
					if (currencies[i] == walletItem.CURRENCY)
					{
						exist = true;
					}
				}
				if (!exist)
				{
					currencyAccount = new Object();

					currencyAccount.ACCOUNT_NUMBER = currencies[i];
					currencyAccount.CURRENCY = currencies[i];

					newCurrencies.push(currencyAccount);
				}
			}

			var accountsFinal:Array = getCreditAccounts().concat(newCurrencies);

			DialogManager.showDialog(
					ListSelectionPopup,
					{
						items:accountsFinal,
						title:Lang.TEXT_SELECT_ACCOUNT,
						renderer:ListPayWalletItem,
						callback:onWalletCreditSelect
					}, ServiceScreenManager.TYPE_SCREEN
				);
		}
		
		private function onWalletCreditSelect(account:Object):void
		{
			if (account == null)
				return;
			
		//	selectorCreditAccont.setValue(account);
			selectedCreditAccount = account;
			updateButtonsState();
			
			selectorCreditCurrency.setValue(account.CURRENCY);
			selectorCreditAccont.setValue(account);
			
			updateButtonsState();
			
		//	targetDebitAccount = false;
			startLoadRate();
			loadCommision();
		}
		
		private function updateButtonsState():void 
		{
			var avaliable:Boolean = false;
			if (targetDebitAccount)
			{
				if (!isNaN(Number(debitAmount.value)) && Number(debitAmount.value) > 0)
				{
					avaliable = true;
				}
			}
			else{
				if (!isNaN(Number(creditAmount.value)) && Number(creditAmount.value) > 0)
				{
					avaliable = true;
				}
			}
			
			if (isCurrrencySelected() == false)
			{
				avaliable = false;
			}
			
			if (avaliable)
			{
				acceptButton.activate();
				acceptButton.alpha = 1;
			}
			else{
				acceptButton.deactivate();
				acceptButton.alpha = 0.5;
			}
		}
		
		private function onShowMoreCurrenciesTapped(list:List):void {
			
			if (list == null)
			{
				return;
			}
			var currencies:Array = getCurrencies();
			var newCurrencies:Array = new Array();
			var l:int = currencies.length;
			var walletItem:Object;
			var currencyAccount:Object;
			for (var i:int = 0; i < l; i++)
			{
				var exist:Boolean = false;
				var accounts:Array = getCreditAccounts();
				for (var j:int = 0; j < accounts.length; j++)
				{
					walletItem = accounts[j];
					if (currencies[i] == walletItem.CURRENCY)
					{
						exist = true;
					}
				}
				if (!exist)
				{
					currencyAccount = new Object();

					currencyAccount.ACCOUNT_NUMBER = currencies[i];
					currencyAccount.CURRENCY = currencies[i];

					newCurrencies.push(currencyAccount);
				}
			}
			for (var k:int = 0; k < newCurrencies.length; k++)
			{
				list.appendItem(newCurrencies[k], ListPayWalletItem);
			}
		}
		
		private function openDebitWalletSelector(e:Event = null):void {
			SoftKeyboard.closeKeyboard();
			if (debitAmount != null)
				debitAmount.forceFocusOut();
			if (creditAmount != null)
				creditAmount.forceFocusOut();

			DialogManager.showDialog(
					ListSelectionPopup,
					{
						items:getDebitAccounts(),
						title:Lang.TEXT_SELECT_ACCOUNT,
						renderer:ListPayWalletItem,
						callback:onDebitWalletSelect
					}, ServiceScreenManager.TYPE_SCREEN
				);

			/*DialogManager.showDialog(
				ScreenPayDialog,
				{
					callback: onDebitWalletSelect,
					data: getDebitAccounts(),
					itemClass: ListPayWalletItem,
					label: Lang.TEXT_SELECT_ACCOUNT
				}
			);*/
		}
		
		static private function createPaymentsAccount(val:int):void {
			if (val != 1) {
				return;
			}
			MobileGui.showRoadMap();
		}
		
		private function onDebitWalletSelect(account:Object):void
		{
			if (account == null)
				return;
			
			selectorDebitCurrency.setValue(account.CURRENCY);
			selectorDebitAccont.setValue(account);
			
			selectedDebitAccount = account;
			
			updateButtonsState();
			
			startLoadRate();
			loadCommision();
		}
		
		private function showPreloader():void
		{
			preloaderShown = true;
			
			var color:fl.motion.Color = new fl.motion.Color();
			color.setTint(0xFFFFFF, 0.7);
			container.transform.colorTransform = color;
			
			if (preloader == null)
			{
				preloader = new CirclePreloader();
			}
			preloader.x = _width * .5;
			preloader.y = _height * .5;
			view.addChild(preloader);
		}
		
		private function loadCommision():void
		{
			_lastCommissionCallID = new Date().getTime().toString() + "commodity";
		}
		
		override public function onBack(e:Event = null):void {
			if (screenLocked == false) {
				ServiceScreenManager.closeView();
			}
		}
		
		private function backClick():void {
			onBack();
		}
		
		private function nextClick():void {
			SoftKeyboard.closeKeyboard();
			if (debitAmount != null)
				debitAmount.forceFocusOut();
			if (creditAmount != null)
				creditAmount.forceFocusOut();
			
			if (giftData != null && giftData.callback != null) {
				giftData.accountNumber = selectedDebitAccount.ACCOUNT_NUMBER;
				giftData.accountNumberIBAN = selectedDebitAccount.IBAN;
				giftData.credit_account_number = selectedCreditAccount.ACCOUNT_NUMBER;
				giftData.credit_account_numberIBAN = selectedCreditAccount.IBAN;

				giftData.debit_account_currency = selectedDebitAccount.CURRENCY;
				giftData.credit_account_currency = selectedCreditAccount.CURRENCY;
				
				if (targetDebitAccount)
				{
					giftData.customValue = Number(debitAmount.value);
					giftData.currency = selectorDebitCurrency.value;
				}
				else{
					giftData.customValue = Number(creditAmount.value);
					giftData.currency = selectorCreditCurrency.value;
				}
				
				giftData.callback(giftData);
			}
			
			ServiceScreenManager.closeView();
		}
		
		override public function clearView():void
		{
			super.clearView();
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
		
		private function drawIcon():void
		{
			if (icon != null)
			{
				UI.disposeBMD(icon.bitmapData);
			}

			var flagAsset:Sprite = getIon();
			if (flagAsset != null)
			{
				if (icon == null)
				{
					icon = new Bitmap();
					container.addChild(icon);
				}

				icon.bitmapData = UI.renderAsset(flagAsset, avatarSize, avatarSize, false, "BuyCommodityPopup.icon");
				icon.x = int(_width * .5 - icon.width * .5);
			}
		}

		private function getIon():Sprite
		{
			if (data != null && "icon" in data && data.icon != null && data.icon is Class)
			{
				try{
					var instance:Sprite = new (data.icon as Class)();
					return instance;
				}
				catch (e:Error)
				{
					ApplicationErrors.add();
				}
			}
			return null;
		}

		override public function initScreen(data:Object = null):void
		{
			super.initScreen(data);
			
			if (data != null && "giftData" in data && data.giftData is GiftData) {
				giftData = data.giftData as GiftData;
			}
			
			componentsWidth = _width - Config.DIALOG_MARGIN * 2;
			
			drawTitle();
			drawTitleDebit();
			drawTitleCredit();
			drawIcon();
			
			drawCostValue();
			drawAtentionText();

			drawAcceptButton(Lang.textNext);
			acceptButton.deactivate();
			acceptButton.alpha = 0.5;
			
			drawBackButton();
			
			var itemWidth:int = (componentsWidth - Config.MARGIN) * .5;
			
			debitAmount.width = itemWidth;
			debitAmount.view.x = Config.DIALOG_MARGIN;
			
			creditAmount.width = itemWidth;
			creditAmount.view.x = Config.DIALOG_MARGIN;
			
			
			selectorDebitCurrency.x = debitAmount.view.x + itemWidth + Config.MARGIN;
			selectorDebitCurrency.setSize(itemWidth, Config.FINGER_SIZE * .8);
			
			selectorCreditCurrency.x = creditAmount.view.x + itemWidth + Config.MARGIN;
			selectorCreditCurrency.setSize(itemWidth, Config.FINGER_SIZE * .8);

			selectorDebitAccont.setSize(componentsWidth, Config.FINGER_SIZE * .8);
			selectorDebitAccont.setValue(Lang.from);
			selectorDebitAccont.x = debitAmount.view.x;
			
			selectorCreditAccont.setSize(componentsWidth, Config.FINGER_SIZE * .8);
			selectorCreditAccont.setValue(Lang.to);
			selectorCreditAccont.x = creditAmount.view.x;
			
			accountsPreloader.setSize(componentsWidth, int(Config.FINGER_SIZE * .05));
			accountsPreloader.x = Config.DIALOG_MARGIN;
			
			arrowClip.x = int(_width * .5 - arrowClip.width * .5);
			
			PaymentsManager.activate();

			activatePayments();
		}

		private function activatePayments():void
		{
			if (PaymentsManager.activate() == false)
			{
				onDataReady();
			}
			else
			{
				PaymentsManager.S_ACCOUNT.add(onAccountInfo);
				PaymentsManager.S_ERROR.add(onPayError);
			}
		}

		private function onAccountInfo():void
		{
			PaymentsManager.S_ACCOUNT.remove(onAccountInfo);
			PaymentsManager.S_ERROR.remove(onPayError);

			onDataReady();
		}

		private function onPayError(code:String = null, message:String = null):void {
			PaymentsManager.S_ACCOUNT.remove(onAccountInfo);
			PaymentsManager.S_ERROR.remove(onPayError);
			ToastMessage.display(message);
			onCloseTap();
		}
		
		private function drawCostValue(value:String = " "):void 
		{
			if (costValue.bitmapData)
			{
				costValue.bitmapData.dispose();
				costValue.bitmapData = null;
			}
			costValue.bitmapData = TextUtils.createTextFieldData(value, componentsWidth, 10, false, TextFormatAlign.LEFT, 
																	TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .24, false, 0x777E8A, 0xFFFFFF, false, true);
			costValue.x = int(_width * .5 - costValue.width * .5);
		}
		
		public function get isLoadingCommission():Boolean {return _isLoadingCommission;}		
		public function set isLoadingCommission(value:Boolean):void {
			if (value == _isLoadingCommission) return;
			_isLoadingCommission = value;
			onCommissionLoadingStateChange();
		}

		private function onDataReady():void 
		{
			dataReady = true;
			activateControls();
			updateButtonsState();
			accountsPreloader.stop();

			PayManager.S_CURRENCY_RATE_RECEIVE.add(onRateRespond);
			PayManager.S_CURRENCY_RATE_ERROR.add(onRateRespondError);
			
			targetDebitAccount = true;
			
			if (giftData != null)
			{
				if (giftData.accountNumber != null)
				{
					selectDebitAccountByNumber(giftData.accountNumber);
				}
				if (giftData.credit_account_number != null)
				{
					selectCreditAccountByNumber(giftData.credit_account_number);
				}
				if (selectedDebitAccount != null)
				{
					var debitCurtrency:String;
					if (selectedDebitAccount.CURRENCY == giftData.currency)
					{
						targetDebitAccount = true;
					}
					else
					{
						targetDebitAccount = false;
					}
				}
				if (!isNaN(giftData.customValue))
				{
					if (targetDebitAccount)
					{
						if (giftData.customValue != 0)
						{
							debitAmount.value = giftData.customValue.toString();
						}
					}
					else{
						if (giftData.customValue != 0)
						{
							creditAmount.value = giftData.customValue.toString();
						}
					}
				}
				updateButtonsState();
			}
			
			startLoadRate();
		}
		
		private function selectCreditAccountByNumber(accountNumber:String):void 
		{
			var account:Object;
			
			var wallets:Array = getCreditAccounts();
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
				selectedCreditAccount = account;
				selectorCreditAccont.setValue(account);
				selectorCreditCurrency.setValue(account.CURRENCY);
			}
		}
		
		private function getCreditAccounts():Array
		{
			if (data != null && "giftData" in data && data.giftData != null && "toAccounts" in data.giftData && data.giftData.toAccounts != null && data.giftData.toAccounts is Array)
			{
				return data.giftData.toAccounts as Array;
			}
			else
			{
				ApplicationErrors.add();
				return new Array();
			}
		}

		private function getDebitAccounts():Array
		{
			if (data != null && "giftData" in data && data.giftData != null && "fromAccounts" in data.giftData && data.giftData.fromAccounts != null && data.giftData.fromAccounts is Array)
			{
				return data.giftData.fromAccounts as Array;
			}
			else
			{
				ApplicationErrors.add();
				return new Array();
			}
		}

		private function selectDebitAccountByNumber(accountNumber:String):void
		{
			var account:Object;
			
			var wallets:Array = getDebitAccounts();
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
				selectedDebitAccount = account;
				selectorDebitAccont.setValue(account);
				selectorDebitCurrency.setValue(account.CURRENCY);
			}
		}
		
		// Rate Loaded 
		private function onRateRespond(callID:String, data:Object):void 
		{
			if (isDisposed == true)
			{
				return;
			}
			latestCommissionData = data;
			_hasLoadedCommission = true;
			isLoadingCommission = false;
		}
		
		private function onRateRespondError(errorMessage:String = null):void 
		{
			if (isDisposed == true)
			{
				return;
			}
			
			if (errorMessage != null)
			{
				ToastMessage.display(errorMessage);
			}
			
			hidePreloader();
			_hasLoadedCommission = false;
			latestCommissionData = null;
		}
		
		private function activateControls():void 
		{
			if (isActivated && !isDisposed && dataReady)
			{
				selectorCreditAccont.activate();
				selectorDebitAccont.activate();
				
				selectorCreditCurrency.activate();
				selectorDebitCurrency.activate();
			}
		}
		
		private function startLoadRate():void 
		{
			if (targetDebitAccount)
			{
				creditAmount.value = "";
				debitAmount.selectBorder();
				creditAmount.unselectBorder();
			}
			else{
				debitAmount.value = "";
				creditAmount.selectBorder();
				debitAmount.unselectBorder();
			}
			
			TweenMax.killDelayedCallsTo(startLoadRate);
			
			TweenMax.killDelayedCallsTo(loadRate);
			TweenMax.delayedCall(1, loadRate);
		}
		
		private function loadRate():void 
		{
			var avaliable:Boolean = false;
			if (targetDebitAccount)
			{
				if (!isNaN(Number(debitAmount.value)) && Number(debitAmount.value) > 0)
				{
					avaliable = true;
				}
			}
			else{
				if (!isNaN(Number(creditAmount.value)) && Number(creditAmount.value) > 0)
				{
					avaliable = true;
				}
			}
			
			if (isCurrrencySelected() == false)
			{
				avaliable = false;
			}
			
			if (avaliable == false)
			{
				return;
			}
			
			showPreloader();
			rateCallID = generateCallID("_INVEST_RATE_popup");
			isLoadingCommission = true;
			latestCommissionData = null;
			_hasLoadedCommission = false;
			
			var amount:Number;
			if (targetDebitAccount == true) {
				amount = Number(debitAmount.value);
			}else{			
				amount  = Number(creditAmount.value);
			}
			
			var currency:String;
			if (targetDebitAccount == true) {
				currency  = selectorDebitCurrency.value;			
			}else{				
				currency = selectorCreditCurrency.value;
			}	
			
			PayManager.callGetCurrencyTransferRate(selectorDebitCurrency.value, selectorCreditCurrency.value, amount, currency, rateCallID);
		}
		
		private function isCurrrencySelected():Boolean 
		{
			if (selectorCreditCurrency != null && 
				selectorCreditCurrency.value != null && 
				selectorCreditCurrency.value != Lang.currency && 
				selectorCreditCurrency.value != selectorCreditCurrency.placeholder && 
				selectorCreditCurrency.value != "" &&
				selectorDebitCurrency != null && 
				selectorDebitCurrency.value != Lang.currency && 
				selectorDebitCurrency.value != null && 
				selectorDebitCurrency.value != selectorDebitCurrency.placeholder && 
				selectorDebitCurrency.value != "")
			{
				return true;
			}
			return false;
		}

		private function onCommissionLoadingStateChange():void{
			if (_isLoadingCommission == true)
				return;
			if (latestCommissionData != null) {
				hidePreloader();
				if (targetDebitAccount == true) {
					creditAmount.value = latestCommissionData.credit_amount;
				} else {
					debitAmount.value = latestCommissionData.debit_amount;
				}
				var value:String;
				if (targetDebitAccount) {
					if ("credit_rate" in latestCommissionData != false && !isNaN(Number(latestCommissionData.credit_rate))) {
						if (!latestCommissionData.credit_reverse) {
							if (Math.floor(Number(1 / latestCommissionData.credit_rate)) > 0)
								value = ((Math.floor(1 / latestCommissionData.credit_rate * 1000)) / 1000).toString();
							else
								value = ((Math.floor(1 / latestCommissionData.credit_rate * 1000000)) / 1000000).toString();
						} else {
							if (Math.floor(Number(latestCommissionData.credit_rate)) > 0)
								value = ((Math.floor(latestCommissionData.credit_rate * 1000)) / 1000).toString();
							else
								value = ((Math.floor(latestCommissionData.credit_rate * 1000000)) / 1000000).toString();
						}
						drawCostValue("1 " + selectorDebitCurrency.value + " = " + value + " " + selectorCreditCurrency.value);
					} else {
						drawCostValue("");
					}
				} else {
					if ("debit_rate" in latestCommissionData != false && !isNaN(Number(latestCommissionData.debit_rate))) {
						if (!latestCommissionData.debit_reverse) {
							if (Math.floor(Number(1 / latestCommissionData.debit_rate)) > 0)
								value = ((Math.floor((1 / latestCommissionData.debit_rate) * 1000)) / 1000).toString();
							else
								value = ((Math.floor((1 / latestCommissionData.debit_rate) * 1000000)) / 1000000).toString();
						} else {
							if (Math.floor(Number(latestCommissionData.debit_rate)) > 0)
								value = ((Math.floor((latestCommissionData.debit_rate) * 1000)) / 1000).toString();
							else
								value = ((Math.floor((latestCommissionData.debit_rate) * 1000000)) / 1000000).toString();
						}
						drawCostValue("1 " + selectorCreditCurrency.value + " = " + value + " " + selectorDebitCurrency.value);
					} else {
						drawCostValue("");
					}
				}
				TweenMax.delayedCall(timeout, startLoadRate);
			}
			updateButtonsState();
		}
		
		private function drawTitle():void 
		{
			if (title.bitmapData)
			{
				title.bitmapData.dispose();
				title.bitmapData = null;
			}
			title.bitmapData = TextUtils.createTextFieldData("<b>" + getTitle() + "</b>", componentsWidth, 10, false,
															TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, FontSize.BODY, false,
															Style.color(Style.COLOR_SUBTITLE), Style.color(Style.COLOR_BACKGROUND), false, true);
			title.x = int(_width * .5 - title.width * .5);
		}
		
		private function getTitle():String
		{
			if (data != null && "titleText" in data && data.titleText != null)
			{
				return data.titleText;
			}
			return Lang.TEXT_EXCHANGE;
		}

		private function drawTitleDebit():void
		{
			if (titleDebit.bitmapData)
			{
				titleDebit.bitmapData.dispose();
				titleDebit.bitmapData = null;
			}
			titleDebit.bitmapData = TextUtils.createTextFieldData("<b>" + getFromTitle() + "</b>", componentsWidth, 10, false,
															TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, FontSize.BODY, false,
															Style.color(Style.COLOR_SUBTITLE), Style.color(Style.COLOR_BACKGROUND), false, true);
			titleDebit.x = int(_width * .5 - titleDebit.width * .5);
		}

		private function getFromTitle():String
		{
			if (data != null && "fromText" in data && data.fromText != null)
			{
				return data.fromText;
			}
			return Lang.exchangeDebit;
		}
		
		private function getToTitle():String
		{
			if (data != null && "toText" in data && data.toText != null)
			{
				return data.toText;
			}
			return Lang.exchangeCredit;
		}
		
		private function drawTitleCredit():void
		{
			if (titleCredit.bitmapData)
			{
				titleCredit.bitmapData.dispose();
				titleCredit.bitmapData = null;
			}
			titleCredit.bitmapData = TextUtils.createTextFieldData("<b>" + getToTitle() + "</b>", componentsWidth, 10, false,
															TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, FontSize.BODY, false,
															Style.color(Style.COLOR_SUBTITLE), Style.color(Style.COLOR_BACKGROUND), false, true);
			titleCredit.x = int(_width * .5 - titleCredit.width * .5);
		}
		
		private function showToastMessage():void {
			ToastMessage.display(Lang.connectionError);
		}
		
		private function onChangeInputValue():void {
			
		//	checkCommision();
			
			updateButtonsState();
			
			targetDebitAccount = true;
			startLoadRate();
		}
		
		private function onChangeInputValueCurrency():void {
			
		//	checkCommision();
			
			updateButtonsState();
			
			targetDebitAccount = false;
			startLoadRate();
		}
		
		private function checkCommision(immidiate:Boolean = false):void {

			updateRateText();
			currentCommision = 0;
			TweenMax.killDelayedCallsTo(checkCommision);
			
			var needUpdate:Boolean = true;
			
			//!TODO:;
			
			if (debitAmount != null && 
				debitAmount.value != null && 
				debitAmount.value != "" && 
				!isNaN(Number(debitAmount.value)) && 
				Number(debitAmount.value) > 0)
			{
				needUpdate = true;
			}
			
			if (walletSelected == false)
			{
				needUpdate = false;
			}
			
			if (needUpdate)
			{
			//	drawAccountText(Lang.commisionWillBe + "...");
				
				if (immidiate)
				{
					loadCommision();
				}
				else
				{
					TweenMax.delayedCall(1, checkCommision, [true]);
				}
			}
		}
		
		private function updateRateText():void
		{
			if (isDisposed == true)
			{
				return;
			}
			if (selectorCreditCurrency != null && selectorDebitAccont != null &&
				selectorCreditCurrency.value != selectorDebitCurrency.value &&
				selectorCreditCurrency.value != getCurrencyText() &&
				selectorDebitCurrency.value != getCurrencyText())
			{
				attentionText.visible = true;
				iconAttention.visible = true;
			}
			else
			{
				attentionText.visible = false;
				iconAttention.visible = false;
			}
		}
		
		private function hidePreloader():void
		{
			if (isDisposed == true)
			{
				return;
			}
			preloaderShown = false;
			container.transform.colorTransform = new ColorTransform();
			
			if (preloader != null)
			{
				if (preloader.parent != null)
				{
					preloader.parent.removeChild(preloader);
				}
				preloader.dispose();
				preloader = null;
			}
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
			accountText.bitmapData = TextUtils.createTextFieldData(text, componentsWidth, 10, true, TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .3, true, 0xABB8C1, 0xffffff, false);
			
			accountText.x = int(_width * .5 - accountText.width * .5);
		}
		
		override protected function drawView():void
		{
			if (_isDisposed == true)
				return;
			
			bg.width = _width;
			
			verticalMargin = Config.MARGIN * 1.2;
			
			var position:int;
			
			if (icon != null)
			{
				position = verticalMargin + avatarSize;
			}
			else
			{
				position = Config.FINGER_SIZE * .5;
			}
			
			title.y = position;
			position += title.height + verticalMargin * .6;
			
			costValue.y = position;
			position += costValue.height + verticalMargin * 1;

			iconAttention.x = int(_width * .5 - (iconAttention.width + attentionText.width + Config.MARGIN) * .5);
			attentionText.x = int(iconAttention.x + iconAttention.width + Config.MARGIN);
			attentionText.y = position;
			iconAttention.y = int(attentionText.y + attentionText.height * .5 - iconAttention.height * .5);
			position += attentionText.height + verticalMargin * 1.5;

			titleDebit.y = position;
			position += titleDebit.height;
			
			debitAmount.view.y = position;
			selectorDebitCurrency.y = position;
			position += debitAmount.height;
			
			selectorDebitAccont.y = position;
			position += selectorDebitAccont.height + verticalMargin * 2;
			
			arrowClip.y = position;
			position += arrowClip.height + verticalMargin * 2;
			
			titleCredit.y = position;
			position += titleCredit.height;

			creditAmount.view.y = position;
			selectorCreditCurrency.y = position;
			position += creditAmount.height;
			
			selectorCreditAccont.y = position;
			position += selectorCreditAccont.height + verticalMargin * 4;
			
			acceptButton.y = position;
			backButton.y = position;
			position += acceptButton.height + verticalMargin * 1.8;

			accountsPreloader.y = selectorDebitAccont.y + selectorDebitAccont.height;
			var backHeight:int;
			if (icon != null)
			{
				backHeight = position - avatarSize / 2;
				bg.y = avatarSize / 2;
			}
			else
			{
				backHeight = position;
				bg.y = 0;
			}
			bg.height = backHeight;
			
			container.y = _height - position;
		}
		
		override public function activateScreen():void
		{
			if (_isDisposed == true)
				return;
			
			super.activateScreen();
			
			//!TODO: не активировать если не получили аккаунт
			
			updateButtonsState();
			activateControls();
			backButton.activate();
			debitAmount.activate();
			creditAmount.activate();
		}
		
		override public function deactivateScreen():void
		{
			if (_isDisposed == true)
				return;
			
			super.deactivateScreen();
			
			selectorCreditCurrency.deactivate();
			selectorDebitCurrency.deactivate();
			acceptButton.deactivate();
			backButton.deactivate();
			selectorDebitAccont.deactivate();
			selectorCreditAccont.deactivate();
			debitAmount.deactivate();
			creditAmount.deactivate();
		}
		
		protected function onCloseTap():void
		{
			DialogManager.closeDialog();
		}
		
		private function drawAtentionText():void
		{
			if (attentionText.bitmapData != null)
			{
				attentionText.bitmapData.dispose();
				attentionText.bitmapData = null;
			}
			attentionText.bitmapData = TextUtils.createTextFieldData(Lang.indicativeRates, componentsWidth - iconAttention.width - Config.MARGIN, 10, true, TextFormatAlign.LEFT,
																	TextFieldAutoSize.LEFT, FontSize.CAPTION_1, true, Style.color(Style.COLOR_SUBTITLE), Style.color(Style.COLOR_BACKGROUND), false, true);

			iconAttention.x = Config.DOUBLE_MARGIN;
			attentionText.x = int(iconAttention.x + iconAttention.width + Config.MARGIN);
		}

		override public function dispose():void
		{
			if (_isDisposed == true)
				return;
			super.dispose();
			
			PaymentsManager.S_ACCOUNT.remove(onAccountInfo);
			PaymentsManager.S_ERROR.remove(onPayError);
			
			PayManager.S_CURRENCY_RATE_RECEIVE.remove(onRateRespond);
			PayManager.S_CURRENCY_RATE_ERROR.remove(onRateRespondError);
			
			PaymentsManager.deactivate();

			if (iconAttention != null){
				UI.destroy(iconAttention);
				iconAttention = null;
			}
			if (attentionText != null){
				UI.destroy(attentionText);
				attentionText = null;
			}
			if (accountsPreloader != null){
				accountsPreloader.dispose();
				accountsPreloader = null;
			}
			if (selectorCreditCurrency != null){
				selectorCreditCurrency.dispose();
				selectorCreditCurrency = null;
			}
			if (selectorDebitCurrency != null){
				selectorDebitCurrency.dispose();
				selectorDebitCurrency = null;
			}	
			if (arrowClip != null){
				UI.destroy(arrowClip);
				arrowClip = null;
			}
			if (title != null){
				UI.destroy(title);
				title = null;
			}
			if (creditAmount != null){
				creditAmount.dispose();
				creditAmount = null;
			}
			if (text != null){
				UI.destroy(text);
				text = null;
			}
			if (icon != null){
				UI.destroy(icon);
				icon = null;
			}
			if (titleCredit != null){
				UI.destroy(titleCredit);
				titleCredit = null;
			}
			if (titleDebit != null){
				UI.destroy(titleDebit);
				titleDebit = null;
			}
			if (debitAmount != null){
				debitAmount.dispose();
				debitAmount = null;
			}
			if (selectorCreditAccont != null){
				selectorCreditAccont.dispose();
				selectorCreditAccont = null;
			}
			if (preloader != null){
				preloader.dispose();
				preloader = null;
			}
			if (selectorDebitAccont != null){
				selectorDebitAccont.dispose();
				selectorDebitAccont = null;
			}
			if (backButton != null){
				backButton.dispose();
				backButton = null;
			}
			if (accountText != null){
				UI.destroy(accountText);
				accountText = null;
			}
			if (costValue != null){
				UI.destroy(costValue);
				costValue = null;
			}
			if (acceptButton != null){
				acceptButton.dispose();
				acceptButton = null;
			}
			if (bg != null){
				UI.destroy(bg);
				bg = null;
			}
			if (container != null){
				UI.destroy(container);
				container = null;
			}
			TweenMax.killDelayedCallsTo(startLoadRate);
			TweenMax.killDelayedCallsTo(loadRate);
		}
	}
}