package com.dukascopy.connect.screens.dialogs.paymentDialogs 
{
	import assets.IconGroupChat;
	import assets.PhoneNumbersIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.CoinTradeOrder;
	import com.dukascopy.connect.data.CountriesData;
	import com.dukascopy.connect.data.OrderScreenData;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.data.coinMarketplace.PaymentsAccountsProvider;
	import com.dukascopy.connect.data.coinMarketplace.TradingOrder;
	import com.dukascopy.connect.data.coinMarketplace.TradingOrderParser;
	import com.dukascopy.connect.gui.components.ComissionView;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.input.InputWithPrompt;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.renderers.ListLink;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.menuVideo.OptionSwitcher;
	import com.dukascopy.connect.gui.tools.HorizontalPreloader;
	import com.dukascopy.connect.screens.dialogs.ScreenCountryPicker;
	import com.dukascopy.connect.screens.dialogs.ScreenLinksDialog;
	import com.dukascopy.connect.screens.dialogs.calendar.SelectDatePopup;
	import com.dukascopy.connect.screens.dialogs.calendar.SelectTimePopup;
	import com.dukascopy.connect.screens.dialogs.newDialogs.DialogBaseScreen;
	import com.dukascopy.connect.screens.dialogs.paymentDialogs.elements.InputField;
	import com.dukascopy.connect.screens.dialogs.paymentDialogs.elements.UserSelectClip;
	import com.dukascopy.connect.screens.payments.card.TypeCurrency;
	import com.dukascopy.connect.screens.serviceScreen.Overlay;
	import com.dukascopy.connect.screens.serviceScreen.SelectContactScreen;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.bankManager.BankManager;
	import com.dukascopy.connect.sys.configManager.ConfigManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.payments.CoinComissionChecker;
	import com.dukascopy.connect.sys.payments.CurrencyHelpers;
	import com.dukascopy.connect.sys.payments.PayManager;
	import com.dukascopy.connect.sys.payments.PayRespond;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.NumberFormat;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.connect.vo.users.UserVO;
	import com.dukascopy.langs.Lang;
	import com.dukascopy.langs.LangManager;
	import com.greensock.TweenMax;
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.display.Bitmap;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	public class TradeCoinPopup extends DialogBaseScreen
	{
		private const OPTION_LINE_HEIGHT:int = Config.FINGER_SIZE * .8;
		private var inptCodeAndPhone:InputWithPrompt;
		
		private var backButton:BitmapButton;
		private var nextButton:BitmapButton;
		
		private var padding:int;
		private var inputQuantity:InputField;
		private var inputPrice:InputField;
		
		private var fullOrderSwitch:OptionSwitcher;
		private var expirationTimeSwitch:OptionSwitcher;
		private var privateOrderSwitch:OptionSwitcher;
		
		private var dateSelectButton:DateButton;
		private var timeSelectButton:TimeButton;
		private var screenData:OrderScreenData;
		private var currentExpirationDate:Date;
		private var btnSearchUser:BitmapButton;
		static private var currentSelectedUser:UserVO;
		private var userItem:UserSelectClip;
		private var selectPhoneButton:BitmapButton;
		private var orderToEdit:TradingOrder;
		private var accounts:PaymentsAccountsProvider;
		private var locked:Boolean;
		private var horizontalLoader:HorizontalPreloader;
		private var commisionText:ComissionView;
		private var comission:CoinComissionChecker;
		private var _lastCommissionCallID:String;
		private var incomeText:Bitmap;
		private var lastOrder:CoinTradeOrder;
		private var maxEurosAvaliable:Number;

		public function TradeCoinPopup()
		{
			
		}
		
		override protected function createView():void
		{
			super.createView();
			
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
			
			inputPrice = new InputField();
			inputPrice.onSelectedFunction = onInputSelected;
			inputPrice.onChangedFunction = onChangeInputPrice;
			scrollPanel.addObject(inputPrice);
			
			inputQuantity = new InputField();
			inputQuantity.align = InputField.ALIGN_LEFT;
			inputQuantity.onSelectedFunction = onInputSelected;
			inputQuantity.onChangedFunction = onChangeInputPrice;
			scrollPanel.addObject(inputQuantity);
			
			fullOrderSwitch = new OptionSwitcher();
			fullOrderSwitch.onSwitchCallback = switchFullOrder;
			scrollPanel.addObject(fullOrderSwitch);
			
			expirationTimeSwitch = new OptionSwitcher();
			expirationTimeSwitch.onSwitchCallback = switchExpirationTime;
			expirationTimeSwitch.isSelected = true;
			scrollPanel.addObject(expirationTimeSwitch);
			
			privateOrderSwitch = new OptionSwitcher();
			privateOrderSwitch.onSwitchCallback = switchPrivateDeal;
			scrollPanel.addObject(privateOrderSwitch);
			
			dateSelectButton = new DateButton();
			dateSelectButton.setStandartButtonParams();
			dateSelectButton.setDownScale(1);
			dateSelectButton.setDownColor(0);
			dateSelectButton.tapCallback = selectDate;
			dateSelectButton.disposeBitmapOnDestroy = true;
			scrollPanel.addObject(dateSelectButton);
			
			timeSelectButton = new TimeButton();
			timeSelectButton.setStandartButtonParams();
			timeSelectButton.setDownScale(1);
			timeSelectButton.setDownColor(0);
			timeSelectButton.tapCallback = selectTime;
			timeSelectButton.disposeBitmapOnDestroy = true;
			scrollPanel.addObject(timeSelectButton);
			
			inptCodeAndPhone = new InputWithPrompt(Input.MODE_BUTTON);//Pool.getItem(Input) as Input;
			//inptCodeAndPhone.setMode(Input.MODE_DIGIT);
			inptCodeAndPhone.S_TAPPED.add(onInptCodeAndPhoneTap);
			inptCodeAndPhone.S_INFOBOX_TAPPED.add(onInptCodeAndPhoneTap);
			inptCodeAndPhone.S_LONG_TAPPED.add(onLongClick);
			inptCodeAndPhone.S_CHANGED.add(onChangeInputValueCurrency);
			inptCodeAndPhone.toMaterialStyle();
			
			inptCodeAndPhone.setInfoBox(Lang.textCode);
			inptCodeAndPhone.setLabelText(Lang.enterDestinationPhone);
			inptCodeAndPhone.activate();
			
			btnSearchUser = new BitmapButton();
			btnSearchUser.setStandartButtonParams();
			btnSearchUser.setDownScale(1);
			btnSearchUser.setDownColor(0x000000);
			btnSearchUser.show(0);
			btnSearchUser.activate();
			btnSearchUser.setOverflow(Config.DOUBLE_MARGIN, Config.DOUBLE_MARGIN, Config.DOUBLE_MARGIN, Config.DOUBLE_MARGIN);
			btnSearchUser.tapCallback = onSearchUserButtonTap;
			createSearchUserButton();
			
			selectPhoneButton = new BitmapButton();
			selectPhoneButton.setStandartButtonParams();
			selectPhoneButton.setDownScale(1);
			selectPhoneButton.setDownColor(0x000000);
			selectPhoneButton.show(0);
			selectPhoneButton.activate();
			selectPhoneButton.setOverflow(Config.DOUBLE_MARGIN, Config.DOUBLE_MARGIN, Config.DOUBLE_MARGIN, Config.DOUBLE_MARGIN);
			selectPhoneButton.tapCallback = selectPhone;
			createPhoneButton();
			
			userItem = new UserSelectClip();
			
			horizontalLoader = new HorizontalPreloader(0xF6951D);
			container.addChild(horizontalLoader);
			
			commisionText = new ComissionView();
			scrollPanel.addObject(commisionText);
			
			incomeText = new Bitmap();
			scrollPanel.addObject(incomeText);
		}
		
		private function createPhoneButton():void {
			var iconSize:int = Config.FINGER_SIZE * 0.36;
			var searchIcon:PhoneNumbersIcon = new PhoneNumbersIcon();
			UI.scaleToFit(searchIcon, iconSize, iconSize);
			var searchUserButtonBitmapData:ImageBitmapData = UI.getSnapshot(searchIcon, StageQuality.HIGH, Lang.TEXT_SEARCH_ICON);
			UI.destroy(searchIcon);
			searchIcon = null;
			selectPhoneButton.setBitmapData(searchUserButtonBitmapData);
		}
		
		override public function isModal():Boolean 
		{
			return locked;
		}
		
		private function selectPhone():void 
		{
			scrollPanel.addObject(inptCodeAndPhone.view);
			scrollPanel.addObject(btnSearchUser);
			
			scrollPanel.removeObject(userItem);
			scrollPanel.removeObject(selectPhoneButton);
			
			currentSelectedUser = null;
			PointerManager.removeTap(userItem, onSearchUserButtonTap);
		}
		
		private function onSearchUserButtonTap(e:Event = null):void 
		{
			ToastMessage.display(Lang.avaliableSoon);
			return;
			
			DialogManager.showDialog(SelectContactScreen, { title:Lang.selectContacts, callback:onSelectContact, searchText:Lang.TEXT_SEARCH_CONTACT }, ServiceScreenManager.TYPE_SCREEN );
		}
		
		private function onSelectContact(user:UserVO, data:Object):void {
			currentSelectedUser = user;
			scrollPanel.removeObject(inptCodeAndPhone.view);
			scrollPanel.removeObject(btnSearchUser);
			
			scrollPanel.addObject(userItem);
			scrollPanel.addObject(selectPhoneButton);
			
			userItem.draw(user, inptCodeAndPhone.width, inptCodeAndPhone.height, Config.FINGER_SIZE * .3);
			userItem.x = inptCodeAndPhone.view.x;
			userItem.y = inptCodeAndPhone.view.y;
			
			PointerManager.addTap(userItem, onSearchUserButtonTap);
		}
		
		private function createSearchUserButton():void {
			var iconSize:int = Config.FINGER_SIZE * 0.36;
			var searchIcon:IconGroupChat = new IconGroupChat();
			UI.scaleToFit(searchIcon, iconSize, iconSize);
			var searchUserButtonBitmapData:ImageBitmapData = UI.getSnapshot(searchIcon, StageQuality.HIGH, Lang.TEXT_SEARCH_ICON);
			UI.destroy(searchIcon);
			searchIcon = null;
			btnSearchUser.setBitmapData(searchUserButtonBitmapData);
		}
		
		private function onChangeInputValueCurrency():void {
			
		}
		
		private function onLongClick():void {
			var menuItems:Array = [];
			var clipboardString:String = String(Clipboard.generalClipboard.getData(ClipboardFormats.TEXT_FORMAT));
			
			if (clipboardString == null || clipboardString == "") return;
			
			clipboardString = validatePhone(clipboardString);
			menuItems.push({fullLink: "PASTE FROM CLIPBOARD", id: 0, disabled: clipboardString == ""});
			
			DialogManager.showDialog(ScreenLinksDialog, {
				callback: function (data:Object):void {
					
					if (data.id == 0 && data.disabled == false) {
						var arr:Array = CountriesData.getCountryByPhoneNumber(clipboardString);
						inptCodeAndPhone.setInfoBox('+' + arr[3]);
						inptCodeAndPhone.value = clipboardString.substring(arr[3].length);
						inptCodeAndPhone.setMode(Input.MODE_DIGIT);
					}
				}, data: menuItems, itemClass: ListLink, title: Lang.TEXT_CLIPBOARD, multilineTitle: false
			});
		}
		
		private function validatePhone(value:String):String {
			if (value.length < 6) {
				return Auth.countryCode + value;
			} else if (value.charAt(0) == "0") {
				return Auth.countryCode + value.substr(1);
			}
			
			var arr:Array = CountriesData.getCountryByPhoneNumber(value);
			if (arr == null) {
				return "";
			}
			return value;
		}
		
		private function onCountrySelected(country:Array):void {
			if (country == null)
				return;
			inptCodeAndPhone.setInfoBox('+' + country[3]);
			inptCodeAndPhone.setMode(Input.MODE_DIGIT);
		}
		
		private function onInptCodeAndPhoneTap():void {
			DialogManager.showDialog(ScreenCountryPicker, {onCountrySelected: onCountrySelected});
		}
		
		private function switchPrivateDeal(selected:Boolean):void 
		{
			privateOrderSwitch.isSelected = selected;
			
			if (!selected)
			{
				scrollPanel.addObject(inptCodeAndPhone.view);
				scrollPanel.addObject(btnSearchUser);
			}
			else
			{
				currentSelectedUser = null;
				
				scrollPanel.removeObject(inptCodeAndPhone.view);
				scrollPanel.removeObject(selectPhoneButton);
				
				scrollPanel.removeObject(userItem);
				scrollPanel.removeObject(btnSearchUser);
			}
			updatePositions();
			scrollPanel.update();
			scrollPanel.scrollToPosition(inptCodeAndPhone.view.y + inptCodeAndPhone.view.height + Config.MARGIN, true);
			drawView();
		}
		
		private function switchExpirationTime(selected:Boolean):void{
			expirationTimeSwitch.isSelected = selected;
			if (selected == false)
			{
				expirationTimeSwitch.setLabel(Lang.goodTill);
				if (currentExpirationDate == null)
				{
					currentExpirationDate = new Date();
				}
				scrollPanel.addObject(dateSelectButton);
				scrollPanel.addObject(timeSelectButton);
				drawDate();
				
			}
			else
			{
				expirationTimeSwitch.setLabel(Lang.goodTillCancel);
				scrollPanel.removeObject(dateSelectButton);
				scrollPanel.removeObject(timeSelectButton);
			}
			updatePositions();
			scrollPanel.update();
			scrollPanel.scrollToPosition(dateSelectButton.y + dateSelectButton.height + Config.MARGIN, true);
			
			if (selectPhoneButton != null)
			{
				selectPhoneButton.x = int(inptCodeAndPhone.view.x + inptCodeAndPhone.width + Config.FINGER_SIZE * .2);
				selectPhoneButton.y = int(inptCodeAndPhone.view.y + inptCodeAndPhone.height * .5 - selectPhoneButton.height * .5);
			}
			if (userItem != null)
			{
				userItem.x = inptCodeAndPhone.view.x;
				userItem.y = inptCodeAndPhone.view.y;
			}
			drawView();
		}
		
		private function switchFullOrder(selected:Boolean):void 
		{
			
		}
		
		private function selectTime():void 
		{
			if (currentExpirationDate == null){
				ToastMessage.display(Lang.selectDateFirst);
				return;
			}
			DialogManager.showDialog(SelectTimePopup, {currentExpirationDate:currentExpirationDate, callback:onTimeSelected});
		}
		
		private function onTimeSelected(date:Date):void 
		{
			drawDate();
			updatePositions();
			scrollPanel.update();
		}
		
		private function selectDate():void 
		{
			DialogManager.showDialog(SelectDatePopup, {currentExpirationDate:currentExpirationDate, callback:onDaySelected});
		}
		
		private function onDaySelected(date:Date):void 
		{
			currentExpirationDate = date;
			drawDate();
			updatePositions();
			scrollPanel.update();
		}
		
		private function onInputSelected():void 
		{
			
		}
		
		private function onChangeInputPrice():void 
		{
		//	drawCommision();
			updateMaxCoins();

			if (checkDataValid() == true)
			{
				loadComission();
			}
		}
		
		private function updateMaxCoins():void
		{
			if (!isNaN(maxEurosAvaliable))
			{
				if (!isNaN(inputPrice.value) && inputPrice.value > 0)
				{
					var value:Number = maxEurosAvaliable/inputPrice.value;
					inputQuantity.drawUnderlineValue(Lang.max + ": " + NumberFormat.formatAmount(value, TypeCurrency.DCO));
				}
				else
				{
					inputQuantity.drawUnderlineValue(Lang.max + ": ...");
				}
			}
		}

		private function loadComission():void
		{
			if (screenData.type == TradingOrder.SELL && inputQuantity.value > 0 && inputPrice.value > 0)
			{
				_lastCommissionCallID = new Date().getTime().toString() + "sell";
				
				drawCommision();
				horizontalLoader.start();
				
				if (comission == null)
				{
					comission = new CoinComissionChecker(onComission);
				}
				var order:TradingOrder = new TradingOrder();
				order.quantity = inputQuantity.value;
				order.price = inputPrice.value;
				comission.execute([order], inputQuantity.value);
			}
		}
		
		private function onComission(commissionData:Object):void 
		{
			if (isDisposed == true) {
				return;
			}
			horizontalLoader.stop();
			
			if (commissionData is String)
			{
				ToastMessage.display(commissionData as String);
			}
			else
			{
				drawCommision(commissionData);
			}
		}
		
		private function drawCommision(commissionData:Object = null):void 
		{
			commisionText.draw(componentsWidth, commissionData);
			
			if (comission != null && !isNaN(comission.getValue()))
			{
				drawIncome(getIncome(comission.getValue()) + " EUR");
			}
			drawView();
		}
		
		private function drawIncome(text:String = null):void 
		{
			var displayText:String = Lang.totalEstimatedEarn + ": ";
			if (text != null)
			{
				displayText += text;
			}
			
			incomeText.bitmapData = TextUtils.createTextFieldData(
																	displayText, 
																	_width - Config.DIALOG_MARGIN*2, 
																	10, 
																	true, 
																	TextFormatAlign.LEFT, 
																	TextFieldAutoSize.LEFT, 
																	FontSize.BODY, 
																	true, 
																	Style.color(Style.COLOR_TEXT), 
																	Style.color(Style.COLOR_BACKGROUND), false, false, true);
			incomeText.x = hPadding;
			drawView();
		}
		
		private function getIncome(commissionValue:Number):Number
		{
			return Math.round((inputPrice.value * inputQuantity.value - commissionValue) * 100) / 100;
		}
		
		private function checkDataValid():Boolean 
		{
			var valid:Boolean = true;
			if (screenData.type == TradingOrder.SELL)
			{
				var maxAmount:Number = 0;
				
				if (accounts.coinsAccounts != null && accounts.coinsAccounts.length > 0)
				{
					maxAmount = parseFloat(accounts.coinsAccounts[0].BALANCE);
				}
				
				if (isNaN(inputQuantity.value) || inputQuantity.value > maxAmount || inputQuantity.value == 0)
				{
					inputQuantity.invalid();
					valid = false;
				}
				else
				{
					inputQuantity.valid();
				}
				if (isNaN(inputPrice.value) || inputQuantity.value == 0)
				{
					inputPrice.invalid();
					valid = false;
				}
				else
				{
					inputPrice.valid();
				}
			}
			else if (screenData.type == TradingOrder.BUY)
			{
				maxEurosAvaliable = 0;
				if (accounts.moneyAccounts != null && accounts.moneyAccounts.length > 0)
				{
					var euroAcc:Object;
					var length:int = accounts.moneyAccounts.length;
					for (var i:int = 0; i < length; i++) 
					{
						if (accounts.moneyAccounts[i] != null && accounts.moneyAccounts[i].CURRENCY == TypeCurrency.EUR)
						{
							euroAcc = accounts.moneyAccounts[i];
							break;
						}
					}
					if (euroAcc != null)
					{
						maxEurosAvaliable = parseFloat(euroAcc.BALANCE);
					}	
				}
				
				if (isNaN(inputPrice.value) || isNaN(inputQuantity.value) || maxEurosAvaliable < inputPrice.value * inputQuantity.value || inputQuantity.value == 0)
				{
					inputPrice.invalid();
					inputQuantity.invalid();
					valid = false;
				}
				else
				{
					inputPrice.valid();
					inputQuantity.valid();
				}
			}
			
			if (valid == false)
			{
				nextButton.deactivate();
				nextButton.alpha = 0.5;
			}
			else
			{
				nextButton.activate();
				nextButton.alpha = 1;
			}
			return valid;
		}
		
		private function nextClick():void {
			
			PayManager.callGetSystemOptions(function():void {
				if (isDisposed)
				{
					return;
				}
				if (screenData.type == TradingOrder.SELL && !isNaN(inputPrice.value) && !isNaN(inputQuantity.value) && PayManager.systemOptions != null && !isNaN(PayManager.systemOptions.coinMinFiatValue) && inputPrice.value * inputQuantity.value < PayManager.systemOptions.coinMinFiatValue)
				{
					var text:String = Lang.minimumLotAmount;
					text = LangManager.replace(Lang.regExtValue, text, PayManager.systemOptions.coinMinFiatValue.toString());
					ToastMessage.display(text);
				}
				else
				{
					nextClickContinue();
				}
			} );
		}
		
		private function nextClickContinue():void 
		{
			var description:String;
			if (screenData.type == TradingOrder.SELL)
			{
				if (!isNaN(screenData.bestPrice) && screenData.bestPrice != 0 && screenData.bestPrice != Number.POSITIVE_INFINITY &&
					screenData.bestPrice > inputPrice.value)
				{
					description = Lang.badPriceSellDescription;
					description = LangManager.replace(Lang.regExtValue, description, inputPrice.value.toString());
					description = LangManager.replace(Lang.regExtValue, description, screenData.bestPrice.toString());
					DialogManager.alert(Lang.textAttention, description, onBadTransactionResponse, Lang.textOk, Lang.CANCEL);
				}
				else
				{
					processOrder();
				}
			}
			else
			{
				if (!isNaN(screenData.bestPrice) && screenData.bestPrice != 0 && screenData.bestPrice != Number.POSITIVE_INFINITY &&
					screenData.bestPrice < inputPrice.value)
				{
					description = Lang.badPriceBuyDescription;
					description = LangManager.replace(Lang.regExtValue, description, inputPrice.value.toString());
					description = LangManager.replace(Lang.regExtValue, description, screenData.bestPrice.toString());
					DialogManager.alert(Lang.textAttention, description, onBadTransactionResponse, Lang.textOk, Lang.CANCEL);
				}
				else
				{
					processOrder();
				}
			}
		}
		
		private function onBadTransactionResponse(val:int):void 
		{
			if (val == 1)
			{
				TweenMax.delayedCall(1, processOrder, null, true);
			}
		}
		
		private function processOrder():void {
			
			var price:Number = inputPrice.value;
			var needShowAlert:Boolean = true;
			if (!isNaN(screenData.bestPrice) && screenData.bestPrice != 0 && screenData.bestPrice != Number.POSITIVE_INFINITY && screenData.bestPrice <= PayManager.systemOptions.coin_llf_price_limit)
			{
				needShowAlert = false;
			}
			if (!isNaN(price) && price <= PayManager.systemOptions.coin_llf_price_limit && screenData.type == TradingOrder.BUY && needShowAlert)
			{
				var text:String = Lang.coinBuyLowPriceWarning.replace("%@1", PayManager.systemOptions.coin_llf_price_limit);
				text = text.replace("%@2", PayManager.systemOptions.coin_llf_eur_per_coin);
				text = text.replace("%@3", (PayManager.systemOptions.coin_llf_price_limit + 0.01).toString());
				DialogManager.alert(Lang.information, text, onCommissionPopup, Lang.confirmMyOrder, Lang.textBack);
			}
			else
			{
				continueTransaction();
			}
		}
		
		private function onCommissionPopup(val:int):void 
		{
			if (val != 1)
				return;
			continueTransaction();
		}
		
		private function continueTransaction():void 
		{
			var order:CoinTradeOrder = new CoinTradeOrder();
			order.price = inputPrice.value;
			order.quantity = inputQuantity.value;
			order.fullOrder = fullOrderSwitch.isSelected;
			if (expirationTimeSwitch.isSelected == false) {
				order.expirationTime = currentExpirationDate;
			}
			if (privateOrderSwitch.isSelected == false) {
				if (currentSelectedUser != null) {
					order.reciever = currentSelectedUser;
				} else {
					if (inptCodeAndPhone.value != "" && inptCodeAndPhone.value != null) {
						order.privateOrderReciever = UI.isEmpty(inptCodeAndPhone.getInfoBoxValue()) ? inptCodeAndPhone.value : inptCodeAndPhone.getInfoBoxValue() + inptCodeAndPhone.value;
					}
				}
			}
			order.action = screenData.type;
			lastOrder = order;
			
			if (order.action == TradingOrder.SELL) {
				
				if (comission != null && comission.lowLoquidityComission != null)
				{
					var lowCommissionText:String =  Lang.coinCommistionM2New.replace("%@1", String(comission.low_liquidity_eur_per_coin));
					lowCommissionText = lowCommissionText.replace("%@2", String(comission.low_liquidity_price_limit));
					lowCommissionText = lowCommissionText.replace("%@3", String(comission.lowLoquidityComission));
					DialogManager.alert(Lang.information, lowCommissionText, onCommissionPopup2, Lang.iAgreeCreateOrder, Lang.iDontAgree);
				}
				else
				{
					onClose(1);
				}
			} else {
				onClose(1);
			}
		}
		
		private function onClose(val:int):void 
		{
			if (val != 1)
				return;
			if (screenData.additionalData != null)
				lastOrder.additionalData = screenData.additionalData;
			screenData.callback(1, lastOrder);
			if (screenData.localProcessing == true) {
				horizontalLoader.start();
				locked = true;
				deactivateScreen();
				BankManager.S_OFFER_CREATED.add(onResponse);
				BankManager.S_PAYMENT_ERROR.add(onError);
				BankManager.S_ERROR.add(onError);
			} else {
				ServiceScreenManager.closeView();
			}
		}
		
		private function onCommissionPopup2(val:int):void 
		{
			if (val != 1)
				return;
			onClose(1);
		}
		
		private function onError(error:Object = null):void 
		{
			horizontalLoader.stop(false);
			BankManager.S_OFFER_CREATED.remove(onResponse);
			BankManager.S_PAYMENT_ERROR.remove(onError);
			BankManager.S_ERROR.remove(onError);
			
			if (error != null && "text" in error && error.text != null)
			{
				ToastMessage.display(error.text);
			}
			
			locked = false;
			activateScreen();
		}
		
		private function onResponse(data:Object):void 
		{
			horizontalLoader.stop();
			locked = false;
			activateScreen();
			BankManager.S_OFFER_CREATED.remove(onResponse);
			BankManager.S_PAYMENT_ERROR.remove(onError);
			BankManager.S_ERROR.remove(onError);
			
			ToastMessage.display(Lang.success);
			ServiceScreenManager.closeView();
		}
		
		private function backClick():void {
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
			PointerManager.removeTap(userItem, onSearchUserButtonTap);
			
			super.clearView();
		}
		
		override public function initScreen(data:Object = null):void 
		{
			var titleValue:String;
			if (data != null && data is OrderScreenData)
			{
				screenData = data as OrderScreenData;
				if (screenData.type == TradingOrder.SELL)
				{
					titleValue = Lang.lotForSale;
				}
				else if (screenData.type == TradingOrder.BUY)
				{
					titleValue = Lang.lotForBuy;
				}
				
				if (screenData.orders != null && screenData.orders.length == 1)
				{
					var parser:TradingOrderParser = new TradingOrderParser();
					orderToEdit = parser.parse(screenData.orders[0]);
				}
			}
			if (titleValue != null && data != null)
			{
				data.title = titleValue;
			}
			
			super.initScreen(data);
			
			if (screenData.type == TradingOrder.SELL)
			{
			//	drawCommision();
			}
			
			padding = Config.DIALOG_MARGIN;
			
			horizontalLoader.setSize(_width, int(Config.FINGER_SIZE * .07));
			horizontalLoader.y = topBar.y + topBar.trueHeight;
			
			accounts = new PaymentsAccountsProvider(onAccountsDataReady);
			
			drawDate();
			
			var startPriceValue:Number = NaN;
			var startQuantityValue:Number = NaN;
			if (orderToEdit != null)
			{
				startPriceValue = orderToEdit.price;
				startQuantityValue = orderToEdit.quantity;
			}
			
			var priceWidth:int = (componentsWidth - hPadding) * 0.4;
			var quantityWidth:int = (componentsWidth - hPadding) * 0.6;
			
			inputPrice.draw(priceWidth, Lang.pricePerCoin, startPriceValue, null, "€");
			inputQuantity.draw(quantityWidth, Lang.textQuantity, startQuantityValue, null, "DUK+");
			
			if (screenData.type == TradingOrder.BUY)
			{
				inputQuantity.x = hPadding;
				inputPrice.x = int(inputQuantity.x + quantityWidth + hPadding);
			}
			else
			{
				/*inputPrice.x = hPadding;
				inputQuantity.x = int(inputPrice.x + itemWidth + hPadding);*/
				
				inputQuantity.x = hPadding;
				inputPrice.x = int(inputQuantity.x + quantityWidth + hPadding);
			}
			
			drawNextButton(Lang.create);
			drawBackButton();
			
			var expirationSelection:Boolean = true;
			var fullOrderSelection:Boolean = false;
			var privateOrderSelection:Boolean = true;
			
			if (orderToEdit != null)
			{
				expirationSelection = orderToEdit.deadline == null;
				fullOrderSelection = orderToEdit.max_trade == orderToEdit.quantity;
				privateOrderSelection = orderToEdit.publicOrder;
			}
			
			expirationTimeSwitch.create(componentsWidth, OPTION_LINE_HEIGHT, null, Lang.goodTillCancel, expirationSelection, true, 0x47515B, Config.FINGER_SIZE * .3, 0);
			fullOrderSwitch.create(componentsWidth, OPTION_LINE_HEIGHT, null, Lang.executeFullOrder, fullOrderSelection, true, 0x47515B, Config.FINGER_SIZE * .3, 0);
			privateOrderSwitch.create(componentsWidth, OPTION_LINE_HEIGHT, null, Lang.publicOffer, privateOrderSwitch, true, 0x47515B, Config.FINGER_SIZE * .3, 0);
			
			updatePositions();
			
			if (accounts.ready == true)
			{
				construct();
			}
			else
			{
				accounts.getData();
			}
		}
		
		private function onAccountsDataReady():void 
		{
			construct();
		}
		
		private function construct():void 
		{
			var maxCoinsAvaliable:String;
			if (screenData.type == TradingOrder.SELL && accounts.coinsAccounts != null && accounts.coinsAccounts.length > 0)
			{
				var currency:String = accounts.coinsAccounts[0].COIN;
				if (Lang[currency] != null)
				{
					currency = Lang[currency];
				}
				
				var balance:Number = 0;
				var reserved:Number = 0;
				var account:Object = accounts.coinsAccounts[0];
				if ("BALANCE" in account && account.BALANCE != null)
				{
					balance = parseFloat(account.BALANCE);
				}
				if ("RESERVED" in account && account.RESERVED != null)
				{
					reserved = parseFloat(account.RESERVED);
				}
				var resultSum:Number = balance - reserved;
				
				maxCoinsAvaliable = Lang.avaliable + ": " + NumberFormat.formatAmount(resultSum, account.COIN);
			}
			
			var maxEurosAvaliable:String;
			if (screenData.type == TradingOrder.BUY && accounts.moneyAccounts != null && accounts.moneyAccounts.length > 0)
			{
				var euroAcc:Object;
				var length:int = accounts.moneyAccounts.length;
				for (var i:int = 0; i < length; i++) 
				{
					if (accounts.moneyAccounts[i] != null && accounts.moneyAccounts[i].CURRENCY == TypeCurrency.EUR)
					{
						euroAcc = accounts.moneyAccounts[i];
						break;
					}
				}
				if (euroAcc != null)
				{
					maxEurosAvaliable = Lang.avaliable + ": " + euroAcc.BALANCE + " " + euroAcc.CURRENCY;
				}
			}
			
			var itemWidth:int = (componentsWidth - hPadding) / 2;
			
			var startPriceValue:Number = NaN;
			var startQuantityValue:Number = NaN;
			if (orderToEdit != null)
			{
				startPriceValue = orderToEdit.price;
				startQuantityValue = orderToEdit.quantity;
			}
			if (screenData.type == TradingOrder.SELL)
			{
				maxEurosAvaliable = null;
			}
			
			var priceWidth:int = (componentsWidth - hPadding) * 0.4;
			var quantityWidth:int = (componentsWidth - hPadding) * 0.6;
				
			inputPrice.draw(priceWidth, Lang.pricePerCoin, startPriceValue, maxEurosAvaliable, "€");
			inputQuantity.draw(quantityWidth, Lang.textQuantity, startQuantityValue, maxCoinsAvaliable, "DUK+");
			
			updatePositions();
			drawView();
			
			horizontalLoader.y = topBar.y + topBar.trueHeight;
		}
		
		private function drawDate():void 
		{
			if (orderToEdit != null)
			{
				currentExpirationDate = orderToEdit.deadline;
			}
			if (currentExpirationDate != null)
			{
				dateSelectButton.draw(currentExpirationDate);
				timeSelectButton.draw(currentExpirationDate);
			}
		}
		
		private function updatePositions():void 
		{
			var position:int = 0;
			
			inputPrice.y = inputQuantity.y = position;
			position += Math.max(inputPrice.getHeight(), inputQuantity.getHeight()) + Config.FINGER_SIZE * .3;
			
			var lineHeight:int = Config.FINGER_SIZE * .75;
			
			expirationTimeSwitch.y = position;
		//	position += expirationTimeSwitch.height;
			position += lineHeight;
			
			if (expirationTimeSwitch.isSelected == false)
			{
				position += Config.FINGER_SIZE * .1;
				dateSelectButton.y = position;
				timeSelectButton.y = position;
				position += dateSelectButton.height + Config.FINGER_SIZE * .15;
			}
			
			fullOrderSwitch.y = position;
		//	position += fullOrderSwitch.height;
			position += lineHeight;
			
			privateOrderSwitch.y = position;
		//	position += privateOrderSwitch.height;
			position += lineHeight;
			
			if (privateOrderSwitch.isSelected == false)
			{
				position += Config.FINGER_SIZE * .1;
				inptCodeAndPhone.view.y = position;
				inptCodeAndPhone.view.x = vPadding;
				inptCodeAndPhone.width = int(componentsWidth - btnSearchUser.width - Config.FINGER_SIZE * .2);
				btnSearchUser.x = int(inptCodeAndPhone.view.x + inptCodeAndPhone.width + Config.FINGER_SIZE * .2);
				btnSearchUser.y = int(inptCodeAndPhone.view.y + inptCodeAndPhone.height * .5 - btnSearchUser.height * .5);
				
				selectPhoneButton.x = int(inptCodeAndPhone.view.x + inptCodeAndPhone.width + Config.FINGER_SIZE * .2);
				selectPhoneButton.y = int(inptCodeAndPhone.view.y + inptCodeAndPhone.height * .5 - selectPhoneButton.height * .5);
				
				position += inptCodeAndPhone.view.height + Config.FINGER_SIZE * .15;
			}
			else
			{
			//	position += Config.FINGER_SIZE * .2;
			}
			
			if (commisionText.height > 0)
			{
				position += Config.FINGER_SIZE * .2;
				commisionText.x = hPadding;
				commisionText.y = position;
				position += commisionText.height + Config.FINGER_SIZE * .3;
			}
			
			if (screenData.type == TradingOrder.SELL)
			{
				position += vPadding;
				incomeText.x = vPadding;
				incomeText.y = position;
				position += incomeText.height + Config.FINGER_SIZE * .2;
			}
			
			backButton.x = Config.DIALOG_MARGIN;
			nextButton.x = backButton.x + backButton.width + Config.MARGIN;
			
			dateSelectButton.x = hPadding;
			timeSelectButton.x = int(dateSelectButton.x + dateSelectButton.width + hPadding);
			
			expirationTimeSwitch.x = vPadding;
			fullOrderSwitch.x = vPadding;
			privateOrderSwitch.x = vPadding;
			
			userItem.x = inptCodeAndPhone.view.x;
			userItem.y = inptCodeAndPhone.view.y;
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
			updatePositions();
			horizontalLoader.y = topBar.y + topBar.trueHeight;
			backButton.y = nextButton.y = scrollPanel.view.y + scrollPanel.height + vPadding;
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
			
			inputPrice.activate();
			inputQuantity.activate();
			
			fullOrderSwitch.activate();
			expirationTimeSwitch.activate();
			privateOrderSwitch.activate();
			
			dateSelectButton.activate();
			timeSelectButton.activate();
			btnSearchUser.activate();
			selectPhoneButton.activate();
			
			checkDataValid();
		}
		
		override public function deactivateScreen():void
		{
			if (_isDisposed == true)
				return;
			
			super.deactivateScreen();
			
			backButton.deactivate();
			nextButton.deactivate();
			
			inputPrice.deactivate();
			inputQuantity.deactivate();
			
			fullOrderSwitch.deactivate();
			expirationTimeSwitch.deactivate();
			privateOrderSwitch.deactivate();
			
			dateSelectButton.deactivate();
			timeSelectButton.deactivate();
			btnSearchUser.deactivate();
			selectPhoneButton.deactivate();
		}
		
		override public function dispose():void
		{
			if (_isDisposed == true)
				return;
			super.dispose();
			
			if (accounts != null)
			{
				accounts.dispose();
				accounts = null;
			}
			
			BankManager.S_OFFER_CREATED.remove(onResponse);
			BankManager.S_PAYMENT_ERROR.remove(onError);
			BankManager.S_ERROR.remove(onError);
			
			Overlay.removeCurrent();
			
			if (incomeText != null)
			{
				UI.destroy(incomeText);
				incomeText = null;
			}
			if (comission != null)
			{
				comission.dispose();
				comission = null;
			}
			if (commisionText != null)
			{
				commisionText.dispose();
				commisionText = null;
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
			if (fullOrderSwitch != null)
			{
				fullOrderSwitch.dispose();
				fullOrderSwitch = null;
			}
			if (inputQuantity != null)
			{
				inputQuantity.dispose();
				inputQuantity = null;
			}
			if (btnSearchUser != null)
			{
				btnSearchUser.dispose();
				btnSearchUser = null;
			}
			if (userItem != null)
			{
				userItem.dispose();
				userItem = null;
			}
			if (inputPrice != null)
			{
				inputPrice.dispose();
				inputPrice = null;
			}
			if (selectPhoneButton != null)
			{
				selectPhoneButton.dispose();
				selectPhoneButton = null;
			}
			if (expirationTimeSwitch != null)
			{
				expirationTimeSwitch.dispose();
				expirationTimeSwitch = null;
			}
			if (privateOrderSwitch != null)
			{
				privateOrderSwitch.dispose();
				privateOrderSwitch = null;
			}
			if (dateSelectButton != null)
			{
				dateSelectButton.dispose();
				dateSelectButton = null;
			}
			if (timeSelectButton != null)
			{
				timeSelectButton.dispose();
				timeSelectButton = null;
			}
			if (inptCodeAndPhone != null)
			{
				inptCodeAndPhone.dispose();
				inptCodeAndPhone = null;
			}
			
			screenData = null;
		}
		
		override protected function onCloseTap():void {
			if (_isDisposed == true)
				return;
			if (data.callback != null)
				data.callback(0);
			rejectPopup();
		}
	}
}