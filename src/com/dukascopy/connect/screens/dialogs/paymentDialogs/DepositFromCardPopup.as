package com.dukascopy.connect.screens.dialogs.paymentDialogs 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.GiftData;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.gui.button.DDAccountButton;
	import com.dukascopy.connect.gui.button.DDCardButton;
	import com.dukascopy.connect.gui.button.DDCardButtonExtended;
	import com.dukascopy.connect.gui.button.DDFieldButton;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.List;
	import com.dukascopy.connect.gui.list.renderers.ListCardItem;
	import com.dukascopy.connect.gui.list.renderers.ListPayCurrency;
	import com.dukascopy.connect.gui.list.renderers.ListPayWalletItem;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.preloader.Preloader;
	import com.dukascopy.connect.gui.tools.HorizontalPreloader;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.dialogs.ScreenPayDialog;
	import com.dukascopy.connect.screens.dialogs.bottom.ListSelectionPopup;
	import com.dukascopy.connect.screens.payments.card.CardStatic;
	import com.dukascopy.connect.screens.payments.card.TypeCurrency;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.applicationShop.commodity.Commodity;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.payments.InvoiceManager;
	import com.dukascopy.connect.sys.payments.PayAPIManager;
	import com.dukascopy.connect.sys.payments.PayManager;
	import com.dukascopy.connect.sys.payments.PaymentsManager;
	import com.dukascopy.connect.sys.payments.advancedPayments.vo.PayTaskVO;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.softKeyboard.SoftKeyboard;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import com.dukascopy.langs.LangManager;
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
	
	public class DepositFromCardPopup extends BaseScreen {
		
		protected var container:Sprite;
		private var bg:Shape;
		private var text:Bitmap;
		private var acceptButton:BitmapButton;
		private var accountText:Bitmap;
		private var backButton:BitmapButton;
		private var selectorDebitAccont:DDAccountButton;
		private var preloader:Preloader;
		private var screenLocked:Boolean;
		private var finishImage:Bitmap;
		private var finishImageMask:Sprite;
		private var verticalMargin:Number;
		private var walletSelected:Boolean;
		private var selectedAccount:Object;
		private var payId:String;
		private var resultAccount:String;
		private var newAmount:Number;
		private var preloaderShown:Boolean = false;
		private var commodity:Commodity;
		private var iAmountCurrency:Input;
		private var selectorCurrency:DDFieldButton;
		private var amountSectionTitle:Bitmap;
		private var cardSectionTitle:Bitmap;
		private var accountTitle:Bitmap;
		private var selectorCard:DDCardButton;
		private var receivedCards:Array;
		private var id:String;
		private var accountsPreloader:HorizontalPreloader;
		private var cardsPreloader:HorizontalPreloader;
		private var noCardsMessage:Bitmap;
		private var cardId:String;
		private var noAccountMessage:Bitmap;
		private var giftData:GiftData;
		private var dataRedy:Boolean;
		private var needCloseScreen:Boolean;
		private var cvvInput:Input;
		private var cvvText:Bitmap;
		protected var componentsWidth:int;
		private var commissionText:Bitmap;
		private var _lastCommissionCallID:String;
		private var currentCommission:Number;
		
		public function DepositFromCardPopup() {
			
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
			
			selectorDebitAccont = new DDAccountButton(openWalletSelector);
			container.addChild(selectorDebitAccont);
			
			selectorCard = new DDCardButtonExtended(openCardSelector);
			container.addChild(selectorCard);
			
			_view.addChild(container);
			
			iAmountCurrency = new Input(Input.MODE_DIGIT_DECIMAL);
			iAmountCurrency.setParams(Lang.textAmount, Input.MODE_DIGIT_DECIMAL);
			iAmountCurrency.S_CHANGED.add(onChangeInputValueCurrency);
			iAmountCurrency.setRoundBG(false);
			iAmountCurrency.getTextField().textColor = Style.color(Style.COLOR_TEXT);
			iAmountCurrency.setRoundRectangleRadius(0);
			iAmountCurrency.inUse = true;
			container.addChild(iAmountCurrency.view);
			
			selectorCurrency = new DDFieldButton(selectCurrencyTap, "", true);
			container.addChild(selectorCurrency);
			
			amountSectionTitle = new Bitmap();
			container.addChild(amountSectionTitle);
			
			cardSectionTitle = new Bitmap();
			container.addChild(cardSectionTitle);
			
			accountTitle = new Bitmap();
			container.addChild(accountTitle);
			
			accountsPreloader = new HorizontalPreloader();
			container.addChild(accountsPreloader);
			
			cardsPreloader = new HorizontalPreloader();
			container.addChild(cardsPreloader);
			
			noCardsMessage = new Bitmap();
			container.addChild(noCardsMessage);
			
			noAccountMessage = new Bitmap();
			container.addChild(noAccountMessage);
			
			commissionText = new Bitmap();
			container.addChild(commissionText);
		}
		
		private function drawCommision(commissionValue:String = null, updateView:Boolean = true):void 
		{
			var text:String = Lang.currentCommission + ": " + Lang.loading + "...";
			
			if (commissionValue != null)
			{
				text = Lang.currentCommission + ": " + commissionValue;
			}
			
			
			if (commissionText.bitmapData != null)
			{
				commissionText.bitmapData.dispose();
				commissionText.bitmapData = null;
			}
			
			commissionText.bitmapData = TextUtils.createTextFieldData(text, 
																	_width - Config.DIALOG_MARGIN*2, 
																	10, 
																	true, 
																	TextFormatAlign.LEFT, 
																	TextFieldAutoSize.LEFT, 
																	Config.FINGER_SIZE * .28, 
																	true, 
																	0x47515B, 
																	0xD9E5F0, false, false, true);
			if (updateView == true)
			{
				drawView();
			}
		}
		
		private function loadComission():void 
		{
			if (getAmount() == 0)
			{
				return;
			}
			currentCommission = NaN;
			_lastCommissionCallID = new Date().getTime().toString() + "sell";
			if (PayManager.S_DEPOSITE_COMMISSION_RECEIVED != null)
			{
				PayManager.S_DEPOSITE_COMMISSION_RECEIVED.add(onCommissionRespond);
			}
			
			if (PayManager.S_DEPOSITE_COMMISSION_RECEIVED_ERROR != null)
			{
				PayManager.S_DEPOSITE_COMMISSION_RECEIVED_ERROR.add(onCommissionError);
			}
			
			cardsPreloader.start();
			PayManager.callGetDepositCommission(Number(iAmountCurrency.value), selectorCurrency.value, "MCARD", _lastCommissionCallID);
		}
		
		private function getAmount():Number 
		{
			if (iAmountCurrency != null && iAmountCurrency.value != null && iAmountCurrency.value != "" && !isNaN(Number(iAmountCurrency.value)))
			{
				return Number(iAmountCurrency.value);
			}
			return 0;
		}
		
		private function onCommissionError(callId:String, message:String = null):void 
		{
			currentCommission = NaN;
			if (isDisposed == true) {
				return;
			}
			if (callId == _lastCommissionCallID)
			{
				cardsPreloader.stop();
			}
			if (message != null)
			{
				ToastMessage.display(message);
			}
		}
		
		private function onCommissionRespond(callId:String, data:Array):void {
			if (isDisposed == true) {
				return;
			}
			if (callId == _lastCommissionCallID)
			{
				cardsPreloader.stop();
				if (data != null && data.length > 1 && data[1] != null && (data[1] is Array) && (data[1] as Array).length > 1) {
					currentCommission = data[1][0];
					drawCommision(data[1][0] + " " + data[1][1]);
					checkDataValid();
				}
			}
		}
		
		private function callbackSelectCard(card:Object):void {
			if (card == null)
				return;
			selectorCard.visible = true;
			selectorCard.setValue(card);
			noCardsMessage.visible = false;
			
			var currency:String;
			if ("currency" in card && card.currency != null)
			{
				currency = card.currency;
			}
			
			onCardUpdate();
			
			selectorCurrency.setValue(currency);
			checkDataValid();
		}
		
		private function checkDataValid():void
		{
			var valid:Boolean = true;
			
			if (isActivated && selectorCard.getValue() != null && selectedAccount != null && iAmountCurrency.value != null && iAmountCurrency.value != "" && !isNaN(Number(iAmountCurrency.value)))
			{
				valid = true;
			}
			else{
				valid = false;
			}
			
			if (cvvInput != null)
			{
				if (cvvInput.value == null || cvvInput.value.length != 3)
				{
					valid = false;
				}
				if (isNaN(currentCommission))
				{
					valid = false;
				}
			}
			
			if (valid == true)
			{
				acceptButton.activate();
				acceptButton.alpha = 1;
			}
			else{
				acceptButton.deactivate();
				acceptButton.alpha = 0.5;
			}
		}
		
		private function getCurrencies():Array 
		{
			if (data != null && "giftData" in data && data.giftData != null && "currencies" in data.giftData && data.giftData.currencies != null && data.giftData.currencies is Array)
			{
				return data.giftData.currencies as Array;
			}
			else
			{
				ApplicationErrors.add();
				return new Array();
			}
		}
		
		private function selectCurrencyTap(e:Event = null):void 
		{
			var currencies:Array = getCurrencies();
			
			DialogManager.showDialog(
					ListSelectionPopup,
					{
						items:currencies,
						title:Lang.selectCurrency,
						renderer:ListPayCurrency,
						callback:callBackSelectDebitCurrency
					}, ServiceScreenManager.TYPE_SCREEN
				);
		}
		
		private function callBackSelectDebitCurrency(currency:String):void {
			if (isDisposed == true)
			{
				return;
			}
			if (currency != null) {
				selectorCurrency.setValue(currency);
				selectAccount(currency, false);
			}
			
			var card:Object = selectorCard.getValue();
			if (card != null && "programme" in card && card.programme == "linked")
			{
				drawCommision();
				loadComission();
			}
		}
		
		private function onCardsReceived(cardsArray:Array):void {
			if (_isDisposed) {
				return;
			}
			
			receivedCards = cardsArray;
			
			dataRedy = true;
			if (isActivated == true)
			{
				selectorCard.activate();
				selectorDebitAccont.activate();
			}
			
			cardsPreloader.stop();
			autofillCard(cardId);
			var card:Object = selectorCard.getValue();
			if (card != null) {
				selectAccount(("currency" in card == true) ? card.currency : null, false);
			}
		}
		
		private function autofillCard(preselectedCardId:String = null):void {
			var arr:Array;
			var cardSelected:Object;
			var card:Object;
			if (preselectedCardId != null) {
				arr = getCardsDataCommon("", "", receivedCards);
			//	arr = getCardsDataCommon("", CardStatic.TYPE_ACTIVE, receivedCards);
				if (arr != null && arr.length > 0) {
					for (var i:int = 0; i < arr.length; i++) {
						card = arr[i];
						if ("id" in card == true) {
							if (card.id == preselectedCardId) {
								cardSelected = card;
								break;
							}
						} else if ("uid" in card == true && card.uid == preselectedCardId) {
							cardSelected = card;
							break;
						} else if ("number" in card == true && card.number == preselectedCardId) {
							cardSelected = card;
							break;
						}
					}
				}
				if (cardSelected) {
					callbackSelectCard(card);
				} else {
					drawNoCard();
				//	ApplicationErrors.add("card not found");
				}
			} else {
				/*if (selectedAccount != null) {
					arr = getCardsDataCommon(selectedAccount.CURRENCY, CardStatic.TYPE_ACTIVE, receivedCards);
					if (arr != null && arr.length > 0) {
						for (var i2:int = 0; i2 < arr.length; i2++) {
							card = arr[i2];
							
							if (card.currency == selectedAccount.CURRENCY) {
								cardSelected = card;
								break;
							}
						}
					}
					if (cardSelected) {
						callbackSelectCard(card);
					} else {
						drawNoCard();
					}
				} else {*/
					arr = getCardsDataCommon("", CardStatic.TYPE_ACTIVE, receivedCards);
					if (arr != null && arr.length > 0) {
						callbackSelectCard(arr[0]);
					} else {
						drawNoCard();
					}
				/*}*/
			}
		}
		
		private function drawNoCard():void {
			drawNoCardsMessage();
			selectorCard.visible = false;
			selectorCard.setValue();
			
			checkDataValid();
		}
		
		private function onPPCardsReceived(data:Object):void {
			if (_isDisposed)
				return;
			if (data != null) {
				if (data.cards != null) {
					receivedCards = data.cards as Array;
				} else {
					receivedCards = data as Array;
				}
			}
		}
		
		private function openCardSelector(e:Event = null):void {
			if (receivedCards == null)
				return;
				
			var cards:Array = getCardsDataCommon("", "", receivedCards);
			
			DialogManager.showDialog(
					ListSelectionPopup,
					{
						items:cards,
						title:Lang.selectCard,
						renderer:ListCardItem,
						callback:callbackSelectMYCard
					}, ServiceScreenManager.TYPE_SCREEN
				);
		}
		
		private function callbackSelectMYCard(obj:Object):void {
			if (obj == null) return;
			selectorCard.setValue(obj);
			var currency:String;
			if ("currency" in obj && obj.currency != null)
			{
				currency = obj.currency;
			}
			if (currency != null)
			{
				selectorCurrency.setValue(currency);
				selectAccount(currency, false);
				selectorCurrency.deactivate();
			}
			else if ("programme" in obj && obj.programme == "linked")
			{
				selectorCurrency.activate();
				selectorCurrency.setValue(null);
			}
			
			onCardUpdate();
		}
		
		private function onCardUpdate():void 
		{
			var card:Object = selectorCard.getValue();
			if (card != null && "programme" in card && card.programme == "linked")
			{
				addCvvinput();
				selectorCurrency.activate();
			}
			else
			{
				removeCvvInput();
			}
			
			onChangeInputValueCurrency();
		}
		
		private function removeCvvInput():void 
		{
			if (cvvInput != null)
			{
				cvvInput.S_CHANGED.remove(onChangeInputValueCurrency);
				if (container.contains(cvvInput.view))
				{
					container.removeChild(cvvInput.view);
				}
				cvvInput.dispose();
				cvvInput = null;
			}
			if (cvvText != null)
			{
				if (container.contains(cvvText))
				{
					container.removeChild(cvvText);
				}
				UI.destroy(cvvText);
				cvvText = null;
			}
			drawView();
		}
		
		private function addCvvinput():void 
		{
			if (cvvInput == null)
			{
				cvvInput = new Input(Input.MODE_DIGIT);
				cvvInput.setParams(Lang.textCVV, Input.MODE_DIGIT_DECIMAL);
				cvvInput.S_CHANGED.add(onChangeCvv);
				cvvInput.setRoundBG(false);
				cvvInput.getTextField().textColor = Style.color(Style.COLOR_TEXT);
				cvvInput.setRoundRectangleRadius(0);
				cvvInput.inUse = true;
				container.addChild(cvvInput.view);
				cvvInput.activate();
				
				cvvText = new Bitmap();
				container.addChild(cvvText);
				cvvText.bitmapData = TextUtils.createTextFieldData(Lang.enterCVV, int((componentsWidth - Config.MARGIN) / 2), 10, false, TextFormatAlign.LEFT, 
																	TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .3, false, 0x777E8A, 0xFFFFFF, false);
			}
			drawView();
			checkDataValid();
		}
		
		private function onChangeCvv():void 
		{
			checkDataValid();
		}
		
		private function getCardsDataCommon(currencyFilter:String = "", statusFilter:String = "", arr:Array = null):Array {
			if (arr == null) {
				return [];
			}
			var filteredCards:Array;
			var cardData:Object;
			var sameCurrency:Boolean = false;
			var sameStatus:Boolean = false;
			var i:int;
			var currency:String;
			if (currencyFilter != "" && statusFilter != "") {
				filteredCards = [];
				for (i = 0; i < arr.length; i++) {
					cardData = arr[i];
					currency = cardData.currency;
					sameCurrency = currency == currencyFilter;
					if ("status_name" in cardData && cardData.status_name != null)
					{
						sameStatus = (cardData.status_name as String).toLowerCase() == statusFilter.toLowerCase();
					}
					else{
						//!TODO: ask Alex;
						sameStatus = true;
					}
					
					//sameStatus = (cardData.status as String).toLowerCase() == statusFilter.toLowerCase();
					if (sameCurrency && sameStatus) {
						filteredCards[filteredCards.length] = cardData;
					}
				}
				
				return filteredCards;
			} else if (currencyFilter != "" && statusFilter == "") {
				filteredCards = [];
				for (i = 0; i < arr.length; i++) {
					cardData = arr[i];
					currency = cardData.currency;
					sameCurrency = currency == currencyFilter;
					if (sameCurrency) {
						filteredCards[filteredCards.length] = cardData;
					}
				}
				
				return filteredCards;
			} else if (currencyFilter == "" && statusFilter != "") {
				filteredCards = [];
				for (i = 0; i < arr.length; i++) {
					cardData = arr[i];
					if ("status_name" in cardData && cardData.status_name != null)
					{
						sameStatus = (cardData.status_name as String).toLowerCase() == statusFilter.toLowerCase();
					}
					else{
						sameStatus = true;
					}
					if (sameStatus) {
						filteredCards[filteredCards.length] = cardData;
					}
				}
				
				return filteredCards;
			} else {
				return arr;
			}
		}
		
		private function openWalletSelector(e:Event = null):void
		{
			SoftKeyboard.closeKeyboard();
			if (iAmountCurrency != null)
			{
				iAmountCurrency.forceFocusOut();
			}
			if (cvvInput != null)
			{
				cvvInput.forceFocusOut();
			}
			if (PayAPIManager.hasSwissAccount == false)
			{
				DialogManager.alert(Lang.information, Lang.featureNoPaments, createPaymentsAccount, Lang.registrate, Lang.textCancel);
				return;
			}
			
			if (PayManager.accountInfo == null)
			{
				showPreloader();
				deactivateScreen();
				var preGiftModel:PayTaskVO = new PayTaskVO(PayTaskVO.TASK_TYPE_PAY_GIFT_BY_UID);
				preGiftModel.from_uid = Auth.uid;
				preGiftModel.handleInCustomScreenName = "CreateGiftPopup";
				InvoiceManager.preProcessInvoce(preGiftModel);
			} else
				showWalletsDialog();
		}
		
		static private function createPaymentsAccount(val:int):void {
			if (val != 1) {
				return;
			}
			MobileGui.showRoadMap();
		}
		
		private function showWalletsDialog():void
		{
			DialogManager.showDialog(
					ListSelectionPopup,
					{
						items:PayManager.accountInfo.accounts,
						title:Lang.TEXT_SELECT_ACCOUNT,
						renderer:ListPayWalletItem,
						callback:onWalletSelectChange
					}, ServiceScreenManager.TYPE_SCREEN
				);
		}
		
		private function showPreloader():void
		{
			preloaderShown = true;
			
			var color:Color = new Color();
			color.setTint(0xFFFFFF, 0.7);
			container.transform.colorTransform = color;
			
			if (preloader == null)
			{
				preloader = new Preloader();
			}
			preloader.x = _width * .5;
			preloader.y = _height * .5;
			view.addChild(preloader);
			preloader.show();
		}		
		
		
		private function onWalletSelectChange(account:Object):void
		{
			onWalletSelect(account, false);
		}
		
		private function onWalletSelect(account:Object, updateCards:Boolean = true, cleanCurrent:Boolean = false):void
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
			//	selectorCurrency.setValue(account.CURRENCY);
			}
			if (account != null || cleanCurrent == true)
			{
				selectorDebitAccont.setValue(account);
			}
			
			if (updateCards)
			{
				autofillCard();
			}
		}
		
		private function drawNoCardsMessage():void 
		{
			if (noCardsMessage.bitmapData)
			{
				noCardsMessage.bitmapData.dispose();
				noCardsMessage.bitmapData = null;
			}
			
			var currency:String = Lang.currency;
			if (selectorCurrency.value != selectorCurrency.placeholder)
			{
				currency = selectorCurrency.value;
			}
			
			var strValue:String = LangManager.replace(Lang.regExtValue, Lang.TEXT_NO_ACTIVE_YOUR_CARDS, currency);
			noCardsMessage.bitmapData = TextUtils.createTextFieldData(strValue, componentsWidth, 10, true, 
															TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .28, true, 0x777E8A, 0xFFFFFF, false, true);
			noCardsMessage.x = int(_width * .5 - noCardsMessage.width * .5);
			noCardsMessage.visible = true;
			selectorCard.visible = false;
			drawView();
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
			if (cvvInput != null)
			{
				cvvInput.forceFocusOut();
			}
			if (giftData != null)
			{
				giftData.credit_account_number = selectedAccount.ACCOUNT_NUMBER;
				giftData.currency = selectorCurrency.value;
				if (!isNaN(currentCommission) && cvvInput != null && cvvInput.view.visible == true)
				{
					giftData.customValue = Number(iAmountCurrency.value) + currentCommission;
				}
				else
				{
					giftData.customValue = Number(iAmountCurrency.value);
				}
				
				if (selectorCard.getValue() != null)
				{
					if ("linked" in selectorCard.getValue() && selectorCard.getValue().linked == true && "uid" in selectorCard.getValue())
					{
						giftData.accountNumber = selectorCard.getValue().uid;
					}
					else if("number" in selectorCard.getValue()) {
						giftData.accountNumber = selectorCard.getValue().number;
					}
					giftData.masked = selectorCard.getMasked();
				}
				
				if (cvvInput != null)
				{
					giftData.cvv = cvvInput.value;
				}
				
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
		
		override public function initScreen(data:Object = null):void
		{
			super.initScreen(data);
			
			if (data != null && "giftData" in data && data.giftData is GiftData) {
				giftData = data.giftData as GiftData;
				if (giftData.currency != null)
				{
					cardId = giftData.currency;
				}
			}
			
			componentsWidth = _width - Config.DIALOG_MARGIN * 2;
			
			drawAmountTitle();
			drawCardSectionTitle();
			drawAccountSectionTitle();
			
			drawAccountSelector();
			drawCardSelector();
		//	drawAccountText(Lang.chooseAccount);
			drawAcceptButton(Lang.textNext);
			acceptButton.deactivate();
			acceptButton.alpha = 0.5;
			
			drawBackButton();
			
			var itemWidth:int = (componentsWidth - Config.MARGIN) / 2;
			
			iAmountCurrency.width = itemWidth;
			iAmountCurrency.view.x = Config.DIALOG_MARGIN;
			
			selectorCurrency.x = iAmountCurrency.view.x + itemWidth + Config.MARGIN;
			selectorCurrency.setSize(itemWidth, Config.FINGER_SIZE * .8);
			
			accountsPreloader.setSize(componentsWidth, int(Config.FINGER_SIZE * .05));
			cardsPreloader.setSize(componentsWidth, int(Config.FINGER_SIZE * .05));
			
			PaymentsManager.S_ACCOUNT.add(onAccountInfo);
			PaymentsManager.S_ERROR.add(onPayError);
			accountsPreloader.start();
			if (PaymentsManager.activate() == false && PayManager.accountInfo != null)
				onAccountInfo();
		}
		
		private function onPayError(code:String = null, message:String = null):void {
			if (code == PaymentsManager.NO_ACC) {
				TweenMax.delayedCall(1, function():void {
					DialogManager.alert(
						Lang.information,
						Lang.needPaymentsAccount,
						createPaymentsAccount,
						Lang.textOk,
						Lang.textCancel
					);
				});
			}
		}
		
		private function drawAccountSectionTitle():void 
		{
			if (accountTitle.bitmapData)
			{
				accountTitle.bitmapData.dispose();
				accountTitle.bitmapData = null;
			}
			accountTitle.bitmapData = TextUtils.createTextFieldData("<b>" + Lang.toAccount + "</b>", componentsWidth, 10, false, TextFormatAlign.LEFT, 
																	TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .3, false, 0x777E8A, 0xFFFFFF, false, true);
		}
		
		private function selectAccount(currency:String, updateCards:Boolean = true):void {
			if (PayManager.accountInfo && PayManager.accountInfo.accounts) {
				var defaultAccount:Object;
				var currencyNeeded:String = currency;
				var wallets:Array = PayManager.accountInfo.accounts;
				var l:int = wallets.length;
				var walletItem:Object;
				for (var i:int = 0; i < l; i++) {
					walletItem = wallets[i];
					if (currencyNeeded == walletItem.CURRENCY) {
						defaultAccount = walletItem;
						break;
					}
				}
				if (defaultAccount != null) {
					onWalletSelect(defaultAccount, updateCards);
				} else {
					//drawNoAccountMessage();
					onWalletSelect(null, updateCards, true);
				}
			}
		}
		
		private function drawNoAccountMessage():void 
		{
			if (noAccountMessage.bitmapData)
			{
				noAccountMessage.bitmapData.dispose();
				noAccountMessage.bitmapData = null;
			}
			var strValue:String = LangManager.replace(Lang.regExtValue, Lang.TEXT_NO_ACTIVE_YOUR_CARDS, selectorCurrency.value);
			noAccountMessage.bitmapData = TextUtils.createTextFieldData(strValue, componentsWidth, 10, true, 
															TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .28, true, 0x777E8A, 0xFFFFFF, false, true);
			noAccountMessage.x = int(_width * .5 - noAccountMessage.width * .5);
			noAccountMessage.visible = true;
			selectorDebitAccont.visible = false;
			drawView();
		}
		
		private function onAccountInfo():void {
			PaymentsManager.S_ACCOUNT.remove(onAccountInfo);
			if (isDisposed == true)
				return;
			if (PayManager.accountInfo == null)
				return;
			
			accountsPreloader.stop();
			
			onCardsReceived(giftData.cards);
			
			checkDataValid();
		}
		
		private function drawAmountTitle():void 
		{
			if (amountSectionTitle.bitmapData)
			{
				amountSectionTitle.bitmapData.dispose();
				amountSectionTitle.bitmapData = null;
			}
			amountSectionTitle.bitmapData = TextUtils.createTextFieldData("<b>" + Lang.TEXT_DEPOSIT + "</b>", componentsWidth, 10, false, 
															TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .3, false, 0x777E8A, 0xFFFFFF, false, true);
			amountSectionTitle.x = int(_width * .5 - amountSectionTitle.width * .5);
			
			drawView();
		}
		
		private function drawCardSectionTitle():void 
		{
			if (cardSectionTitle.bitmapData)
			{
				cardSectionTitle.bitmapData.dispose();
				cardSectionTitle.bitmapData = null;
			}
			cardSectionTitle.bitmapData = TextUtils.createTextFieldData("<b>" + Lang.fromCard + "</b>", componentsWidth, 10, false, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
																Config.FINGER_SIZE * .3, false, 0x777E8A, 0xFFFFFF, false, true);
		}
		
		private function localSelectCurrency(currency:String):void {
			selectorCurrency.setValue(currency);
		//	selectorCurrency.activate();
		}
		
		private function callBackSelectCurrency(currency:String):void {
			if (selectorCurrency != null && currency != null) {
				selectorCurrency.setValue(currency);
				
			//	selectAccount(currency);
			//	checkCommision();
			}
			
			selectAccount(currency);
		}
		
		private function callBackGetConfig():void
		{
			PayManager.callGetSystemOptions();
		}
		
		private function showToastMessage():void {
			ToastMessage.display(Lang.connectionError);
		}
		
		private function onChangeInputValueCurrency():void {
			
			if (isActivated && selectorCard.getValue() != null && iAmountCurrency.value != null && iAmountCurrency.value != "" && !isNaN(Number(iAmountCurrency.value)))
			{
				var card:Object = selectorCard.getValue();
				if (card != null && "programme" in card && card.programme == "linked" && selectorCurrency.value != selectorCurrency.placeholder && selectorCurrency.value != null)
				{
					drawCommision();
					loadComission();
				}
				else
				{
					checkDataValid();
				}
			}
			else if(selectedAccount != null)
			{
				checkDataValid();
			}
		}
		
		private function onWalletsReady():void {
			if (isDisposed)
				return;
			
			activateScreen();
			hidePreloader();
			//!TODO:;
			setDefaultWallet();
			
			InvoiceManager.S_ACCOUNT_READY.remove(onWalletsReady);
		}
		
		private function hidePreloader():void
		{
			preloaderShown = false;
			container.transform.colorTransform = new ColorTransform();
			
			if (preloader != null)
			{
				preloader.hide();
				if (preloader.parent)
				{
					preloader.parent.removeChild(preloader);
				}
			}
		}
		
		private function setDefaultWallet():void
		{
			if (PayManager.accountInfo == null) return;
			var defaultAccount:Object;
			
			var currencyNeeded:String = TypeCurrency.EUR;
			var wallets:Array = PayManager.accountInfo.accounts;
			var l:int = wallets.length;
			var walletItem:Object;
			for (var i:int = 0; i < l; i++)
			{
				walletItem = wallets[i];
				if (currencyNeeded == walletItem.CURRENCY)
				{
					defaultAccount = walletItem;
					break;
				}
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
		
		private function drawCardSelector():void
		{
			selectorCard.setSize(componentsWidth, Config.FINGER_SIZE * .8);
		//	selectorCard.setValue(Lang.textChoose);
			selectorCard.x = Config.DIALOG_MARGIN;
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
			
			verticalMargin = Config.MARGIN * 1;
			
			var position:int;
			
			position = verticalMargin;
			
			position += verticalMargin * 1.5;
			
			// WITHDRAW
			amountSectionTitle.y = position;
			position += amountSectionTitle.height + verticalMargin * 1.5;
			amountSectionTitle.x = int(_width * .5 - amountSectionTitle.width * .5);
			
			// AMOUNT
			iAmountCurrency.view.y = position;
			selectorCurrency.y = position;
			position += iAmountCurrency.height + verticalMargin * 2;
			
			var card:Object = selectorCard.getValue();
			if (card != null && "programme" in card && card.programme == "linked")
			{
				if (selectorCurrency.value == selectorCurrency.placeholder || selectorCurrency.value == null)
				{
					drawCommision(null, false);
				}
				commissionText.visible = true;
				commissionText.x = Config.DIALOG_MARGIN;
				commissionText.y = position + Config.FINGER_SIZE * .4 - commissionText.height;
				position += Config.FINGER_SIZE * .4 + verticalMargin * 2.5;
			}
			else
			{
				commissionText.visible = false;
				position += verticalMargin * 0.5;
			}
			
			
			// FROM
			cardSectionTitle.y = position;
			cardSectionTitle.x = int(_width * .5 - cardSectionTitle.width * .5);
			position += cardSectionTitle.height + verticalMargin * .6;
			
			// CARD
			selectorCard.y = position;
			
			cardsPreloader.y = selectorCard.y + selectorCard.height;
			cardsPreloader.x = selectorCard.x;
			
			if (cvvInput != null)
			{
				position += selectorCard.height + verticalMargin;
				cvvInput.view.x = Config.DIALOG_MARGIN + int((componentsWidth - Config.MARGIN) / 2) + Config.MARGIN;
				cvvInput.view.y = position;
				cvvInput.width = int((componentsWidth - Config.MARGIN) / 2);
				position += cvvInput.height + verticalMargin * 3;
				
				cvvText.x = Config.DIALOG_MARGIN;
				cvvText.y = int(cvvInput.view.y + cvvInput.height * .5 - cvvText.height * .5);
			}
			else
			{
				position += selectorCard.height + verticalMargin * 3;
			}
			
			// TO ACCOUNT
			accountTitle.y = position;
			accountTitle.x = int(_width * .5 - accountTitle.width * .5);
			position += accountTitle.height + verticalMargin * .6;
			
			// ACCOUNT
			selectorDebitAccont.y = position;
			position += selectorDebitAccont.height + verticalMargin * 2;
			accountsPreloader.y = selectorDebitAccont.y + selectorDebitAccont.height;
			accountsPreloader.x = selectorDebitAccont.x;
			
			noCardsMessage.y = selectorCard.y + Config.MARGIN;
			
			//	accountText.y = position;
			//	position += accountText.height + verticalMargin * 1.8;
			accountText.visible = false;
			
			acceptButton.y = position;
			backButton.y = position;
			position += acceptButton.height + verticalMargin * 1.8;
			
			bg.height = position;
			
			container.y = _height - position;
		}
		
		override public function activateScreen():void
		{
			if (_isDisposed == true)
				return;
			
			super.activateScreen();
			
			iAmountCurrency.activate();
			
			checkDataValid();
			
			backButton.activate();
			
			if (dataRedy == true)
			{
				selectorCard.activate();
				selectorDebitAccont.activate();
			}
			
			if (needCloseScreen == true)
			{
				ToastMessage.display(Lang.pleaseTryLater);
				onBack();
			}
			
			if (cvvInput != null)
			{
				cvvInput.activate();
			}
		}
		
		override public function deactivateScreen():void
		{
			if (_isDisposed == true)
				return;
			
			super.deactivateScreen();
			
			iAmountCurrency.deactivate();
			acceptButton.deactivate();
			backButton.deactivate();
			selectorDebitAccont.deactivate();
			selectorCard.deactivate();
			
			if (cvvInput != null)
			{
				cvvInput.deactivate();
			}
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
			
			PaymentsManager.S_ACCOUNT.remove(onAccountInfo);
			PaymentsManager.S_ERROR.remove(onPayError);
			PaymentsManager.deactivate();
			
			if (PayManager.S_DEPOSITE_COMMISSION_RECEIVED != null)
			{
				PayManager.S_DEPOSITE_COMMISSION_RECEIVED.remove(onCommissionRespond);
			}
			
			if (PayManager.S_DEPOSITE_COMMISSION_RECEIVED_ERROR != null)
			{
				PayManager.S_DEPOSITE_COMMISSION_RECEIVED_ERROR.remove(onCommissionError);
			}
			
			if (cvvInput != null)
			{
				cvvInput.S_CHANGED.remove(onChangeInputValueCurrency);
				cvvInput.dispose();
				cvvInput = null;
			}
			if (cvvText != null)
			{
				UI.destroy(cvvText);
				cvvText = null;
			}
			
			if (amountSectionTitle != null)
			{
				UI.destroy(amountSectionTitle);
				amountSectionTitle = null;
			}
			if (cardSectionTitle != null)
			{
				UI.destroy(cardSectionTitle);
				cardSectionTitle = null;
			}
			if (accountTitle != null)
			{
				UI.destroy(accountTitle);
				accountTitle = null;
			}
			if (iAmountCurrency != null)
			{
				iAmountCurrency.dispose();
				iAmountCurrency = null;
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
			if (container != null)
			{
				UI.destroy(container);
				container = null;
			}
			if (accountsPreloader != null)
			{
				accountsPreloader.dispose();
				accountsPreloader = null;
			}
			if (cardsPreloader != null)
			{
				cardsPreloader.dispose();
				cardsPreloader = null;
			}
			
			if (noCardsMessage != null)
			{
				UI.destroy(noCardsMessage);
				noCardsMessage = null;
			}
			if (noAccountMessage != null)
			{
				UI.destroy(noAccountMessage);
				noAccountMessage = null;
			}
			if (commissionText != null)
			{
				UI.destroy(commissionText);
				commissionText = null;
			}
			
			giftData = null;
		}
	}
}