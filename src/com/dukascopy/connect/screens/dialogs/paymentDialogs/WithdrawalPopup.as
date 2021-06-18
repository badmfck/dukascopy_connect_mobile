package com.dukascopy.connect.screens.dialogs.paymentDialogs 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.GiftData;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.gui.button.DDAccountButton;
	import com.dukascopy.connect.gui.button.DDCardButtonExtended;
	import com.dukascopy.connect.gui.button.DDFieldButton;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.renderers.ListCardItem;
	import com.dukascopy.connect.gui.list.renderers.ListPayCurrency;
	import com.dukascopy.connect.gui.list.renderers.ListPayWalletItem;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.preloader.Preloader;
	import com.dukascopy.connect.gui.tools.HorizontalPreloader;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.dialogs.bottom.ListSelectionPopup;
	import com.dukascopy.connect.screens.payments.card.CardStatic;
	import com.dukascopy.connect.screens.payments.card.TypeCurrency;
	import com.dukascopy.connect.sys.applicationShop.commodity.Commodity;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.payments.PayManager;
	import com.dukascopy.connect.sys.payments.PayRespond;
	import com.dukascopy.connect.sys.payments.PaymentsManager;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.softKeyboard.SoftKeyboard;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
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
	
	public class WithdrawalPopup extends BaseScreen {
		
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
		private var currentCommision:Number = 0;
		private var preloaderShown:Boolean = false;
		private var commodity:Commodity;
		private var iAmountCurrency:Input;
		private var selectorCurrency:DDFieldButton;
		private var amountSectionTitle:Bitmap;
		private var cardSectionTitle:Bitmap;
		private var accountTitle:Bitmap;
		private var selectorCard:DDCardButtonExtended;
		private var receivedCards:Array;
		private var id:String;
		private var accountsPreloader:HorizontalPreloader;
		private var cardsPreloader:HorizontalPreloader;
		private var noCardsMessage:Bitmap;
		private var cardId:String;
		private var noAccountMessage:Bitmap;
		private var giftData:GiftData;
		private var dataRedy:Boolean;
		private var needShowCurrencies:Boolean;
		private var _lastComissionCallID:String;
		private var _lastComissionData:Object;
		private var commission:Bitmap;
		protected var componentsWidth:int;
		
		public static var CARD_LINKED:int = 1;
		public static var CARD_DUKASCOPY:int = 2;
		
		public function WithdrawalPopup() {
			
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
			container.addChild(acceptButton);
			
			backButton = new BitmapButton();
			backButton.setStandartButtonParams();
			backButton.setDownScale(1);
			backButton.setDownColor(0);
			backButton.tapCallback = backClick;
			backButton.disposeBitmapOnDestroy = true;
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
		}
		
		private function selectCurrencyTap():void {
			needShowCurrencies = true;
			selectCurrency();
		}
		
		private function selectCurrency(e:Event = null):void {
			if (PayManager.accountInfo == null) {
				return;
			} else {
				/*var currencies:Array = new Array();
				var wallets:Array = receivedCards;
				var l:int = wallets.length;
				var walletItem:Object;
				for (var i:int = 0; i < l; i++) {
					walletItem = wallets[i];
					var field:String;
					if ("currency" in walletItem) {
						field = "currency";
					}
					else if ("CURRENCY" in walletItem)
					{
						field = "CURRENCY";
					}
					var exist:Boolean = false;
					for (var j:int = 0; j < currencies.length; j++) {
						if (currencies[j] == walletItem[field]) {
							exist = true;
						}
					}
					if (exist == false) {
						currencies.push(walletItem[field]);
					}
				}*/
				
				var currencies:Array = getCurrencies();
				
				DialogManager.showDialog(
					ListSelectionPopup,
					{
						items:currencies,
						title:Lang.selectCurrency,
						renderer:ListPayCurrency,
						callback:callBackSelectCurrency
					}, ServiceScreenManager.TYPE_SCREEN
				);
				
			//	DialogManager.showDialog(ScreenPayDialog, { callback: callBackSelectCurrency, data: getCurrencies(), itemClass: ListPayCurrency, label: Lang.selectCurrency } );
			}
		}
		
		private function getCurrencies():Array 
		{
			if (giftData != null && giftData.currencies != null)
			{
				return giftData.currencies;
			}
			return new Array();
		}
		
		private function callbackSelectCard(card:Object):void {
			if (card == null)
				return;
			selectorCard.visible = true;
			selectorCard.setValue(card);
			noCardsMessage.visible = false;
			
			selectorCurrency.setValue(card.currency);
			
			checkDataValid();
		}
		
		private function checkDataValid():void
		{
			if (isActivated && selectorCard.getValue() != null && selectedAccount != null && iAmountCurrency.value != null && iAmountCurrency.value != "" && !isNaN(Number(iAmountCurrency.value)) && Number(iAmountCurrency.value) != 0)
			{
				acceptButton.activate();
				acceptButton.alpha = 1;
			}
			else{
				acceptButton.deactivate();
				acceptButton.alpha = 0.5;
			}
		}
		
		private function onMoneyCardsReceived(cards:Array):void {
			if (_isDisposed) {
				return;
			}
			
			if (receivedCards == null)
			{
				receivedCards = new Array();
			}
			
			if (cards != null) {
				
				receivedCards = receivedCards.concat(cards);
			}
			
			dataRedy = true;
			if (isActivated == true)
			{
				selectorCurrency.activate();
				selectorCard.activate();
				selectorDebitAccont.activate();
			}
			
			cardsPreloader.stop();
			autofillCard(cardId);
			var card:Object = selectorCard.getValue();
			if (card != null) {
				
				var field:String;
				
				var currency:String;
				if (("currency" in card == true))
				{
					currency = card.currency;
				}
				
				selectAccount(currency, false, true);
			}
		}
		
		private function autofillCard(preselectedCardId:String = null):void {
			var arr:Array;
			var cardSelected:Object;
			var card:Object;
			if (preselectedCardId != null) {
				arr = getCardsDataCommon("", "", receivedCards);
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
				if (selectedAccount != null) {
					arr = getCardsDataCommon(selectedAccount.CURRENCY, "", receivedCards);
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
				} else {
					arr = getCardsDataCommon("", "", receivedCards);
					
					if (arr != null && arr.length > 0) {
						
						var newSelectedCard:Object;
						if (giftData != null)
						{
							if (giftData.cardType == CARD_LINKED)
							{
								for (var j:int = 0; j < arr.length; j++) 
								{
									if ("linked" in arr[j] && arr[j].linked == true)
									{
										newSelectedCard = arr[j];
										break;
									}
								}
							}
							else if (giftData.cardType == CARD_DUKASCOPY)
							{
								for (var j2:int = 0; j2 < arr.length; j2++) 
								{
									if ("linked" in arr[j2] == false || arr[j2].linked == false)
									{
										newSelectedCard = arr[j2];
										break;
									}
								}
							}
						}
						
						if (newSelectedCard == null)
						{
							callbackSelectCard(arr[0]);
						}
						else{
							callbackSelectCard(newSelectedCard);
						}
					} else {
						drawNoCard();
					}
				}
			}
		}
		
		private function drawNoCard():void {
			drawNoCardsMessage();
			selectorCard.visible = false;
			selectorCard.setValue();
			
			checkDataValid();
		}
		
		private function openCardSelector(e:Event = null):void {
			if (receivedCards == null)
				return;
				
			var cards:Array;
			
			cards = getCardsDataCommon("", CardStatic.TYPE_ACTIVE, receivedCards)
			
			DialogManager.showDialog(
					ListSelectionPopup,
					{
						items:cards,
						title:Lang.selectCard,
						renderer:ListCardItem,
						callback:callbackSelectMYCard
					}, ServiceScreenManager.TYPE_SCREEN
				);
			
			/*DialogManager.showDialog(ScreenPayDialog, {
				callback: callbackSelectMYCard,
				data: cards,
				itemClass: ListCardItem,
				label: Lang.TEXT_SELECT_ACCOUNT
			});*/
		}
		
		private function callbackSelectMYCard(obj:Object):void {
			if (obj == null) return;
			selectorCard.setValue(obj);
			var currency:String;
			if ("currency" in obj && obj.currency != null)
			{
				currency = obj.currency;
			}
			selectAccount(currency, false);
			checkCommision();
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
			
			if (PayManager.accountInfo == null)
			{
				return;
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
			var accounts:Array = PayManager.accountInfo.accounts;
			var nonZeroAccounts:Array = new Array();
			
			if (accounts != null)
			{
				for (var i:int = 0; i < accounts.length; i++) 
				{
					if ("BALANCE" in accounts[i] && Number(accounts[i].BALANCE) > 0)
					{
						nonZeroAccounts.push(accounts[i]);
					}
				}
			}
			
			DialogManager.showDialog(
				ListSelectionPopup,
				{
					items:nonZeroAccounts,
					title:Lang.TEXT_SELECT_ACCOUNT,
					renderer:ListPayWalletItem,
					callback:onWalletSelect
				}, ServiceScreenManager.TYPE_SCREEN
			);
			
		//	DialogManager.showDialog(ScreenPayDialog, {callback: onWalletSelect, data: PayManager.accountInfo.accounts, itemClass: ListPayWalletItem/*ListPayAccount*/, label: Lang.TEXT_SELECT_ACCOUNT});
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
		
		private function onWalletSelect(account:Object, updateCards:Boolean = true, cleanCurrent:Boolean = false):void
		{
			if (account == null)
			{
				if (cleanCurrent == true)
				{
					selectedAccount = account;
					selectorCurrency.setValue();
					walletSelected = false;
				}	
			}
			else{
				selectedAccount = account;
				
				var field:String;
				if ("currency" in account) {
					field = "currency";
				}
				else if ("CURRENCY" in account)
				{
					field = "CURRENCY";
				}
				
				var targetCurrency:String = account[field];
				targetCurrency = validate(targetCurrency);
				
				selectorCurrency.setValue(targetCurrency);
			}
			if (account != null || cleanCurrent == true)
			{
				selectorDebitAccont.setValue(account);
			}
			
			if (updateCards)
			{
			//	autofillCard();
			}
			checkCommision();
		}
		
		private function validate(targetCurrency:String):String 
		{
			var avaliable:Array = getCurrencies();
			if (avaliable != null)
			{
				var valid:Boolean = false;
				for (var i:int = 0; i < avaliable.length; i++) 
				{
					if (avaliable[i] == targetCurrency)
					{
						valid = true;
						break;
					}
				}
				if (valid)
				{
					return targetCurrency;
				}
				else if(avaliable.length > 0)
				{
					for (var j:int = 0; j < avaliable.length; j++) 
					{
						var prefCurrency:String = TypeCurrency.USD;
						if (selectorCard.getValue() != null && selectorCard.getValue().currency != null)
						{
							prefCurrency = selectorCard.getValue().currency;
						}
						
						if (avaliable[j] == prefCurrency) 
						{
							return prefCurrency;
						}
					}
					return avaliable[0];
				}
			}
			return targetCurrency;
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
			
			var strValue:String = LangManager.replace(Lang.regExtValue, Lang.noCardsInCurrency, currency);
			if(currency.toLowerCase().indexOf("choose")>-1){
				strValue = 'Please select account first';
			}
			
			noCardsMessage.bitmapData = TextUtils.createTextFieldData(strValue, componentsWidth, 10, true, 
															TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .28, true, 0x777E8A, 0xFFFFFF, false, true);
			noCardsMessage.x = int(_width * .5 - noCardsMessage.width * .5);
			noCardsMessage.visible = true;
			selectorCard.visible = false;
			drawView();
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
			if (selectorCurrency.value == selectorCurrency.placeholder)
			{
				ToastMessage.display(Lang.selectCurrency);
				return;
			}
			if (iAmountCurrency != null)
			{
				iAmountCurrency.forceFocusOut();
			}
			if (giftData != null)
			{
				giftData.accountNumber = selectedAccount.ACCOUNT_NUMBER;
				giftData.currency = selectorCurrency.value;
				giftData.customValue = Number(iAmountCurrency.value);
				giftData.credit_account_currency = selectedAccount.CURRENCY;
				if (selectorCard.getValue() != null)
				{
					if ("linked" in selectorCard.getValue() && selectorCard.getValue().linked == true && "uid" in selectorCard.getValue())
					{
						giftData.credit_account_number = selectorCard.getValue().uid;
					}
					else if ("number" in selectorCard.getValue() && "number" in selectorCard.getValue())
					{
						giftData.credit_account_number = selectorCard.getValue().number;
					}
					else{
						giftData.credit_account_number = selectorCard.getValue().id;
					}
					giftData.masked = selectorCard.getMasked();
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
			
			checkData();
		}
		
		private function drawAccountSectionTitle():void 
		{
			if (accountTitle.bitmapData)
			{
				accountTitle.bitmapData.dispose();
				accountTitle.bitmapData = null;
			}
			accountTitle.bitmapData = TextUtils.createTextFieldData("<b>" + Lang.fromAccount + "</b>", componentsWidth, 10, false, TextFormatAlign.LEFT, 
																	TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .3, false, 0x777E8A, 0xFFFFFF, false, true);
		}
		
		private function checkData():void {
			PaymentsManager.S_ACCOUNT.add(onAccountInfo);
			PaymentsManager.S_ERROR.add(onPayError);
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
		
		private function selectAccount(currency:String, updateCards:Boolean = true, selectCard:Boolean = false):void 
		{
			if (PayManager.accountInfo && PayManager.accountInfo.accounts)
			{
				var defaultAccount:Object;
				
				var currencyNeeded:String = currency;
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
				if (defaultAccount == null && wallets.length > 0)
				{
					defaultAccount = wallets[0];
				}
				
				if (defaultAccount != null)
				{
					onWalletSelect(defaultAccount, updateCards, selectCard);
				}
				else{
				//	drawNoAccountMessage();
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
			if (PayManager.accountInfo == null)
				return;
			
			accountsPreloader.stop();
			
			onMoneyCardsReceived(giftData.cards);
		}
		
		private function drawAmountTitle():void{
			if (amountSectionTitle.bitmapData){
				amountSectionTitle.bitmapData.dispose();
				amountSectionTitle.bitmapData = null;
			}
			amountSectionTitle.bitmapData =
				TextUtils.createTextFieldData("<b>" + Lang.withdraw + "</b>",
				componentsWidth,
				10,
				false,
				TextFormatAlign.LEFT,
				TextFieldAutoSize.LEFT,
				Config.FINGER_SIZE * .3,
				false,
				0x777E8A,
				0xFFFFFF,
				false,
				true
			);
			
			amountSectionTitle.x = int(_width * .5 - amountSectionTitle.width * .5);
			
			drawView();
		}
		
		private function drawCardSectionTitle():void{
			if (cardSectionTitle.bitmapData)
			{
				cardSectionTitle.bitmapData.dispose();
				cardSectionTitle.bitmapData = null;
			}
			cardSectionTitle.bitmapData = TextUtils.createTextFieldData("<b>" + Lang.toCard + "</b>", componentsWidth, 10, false, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
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
				checkCommision();
			}
			
		//	selectAccount(currency);
		}
		
		// Call Load Commission 
		private function callLoadComission():void{
		//	accountsPreloader.start();
			_lastComissionCallID = new Date().time + "_withdrawal_commission";
			
			var amount:Number = Number(iAmountCurrency.value);
			var currency:String = selectorCurrency.value;
			var withdrawalType:String = getCurrentWithdrawalType();
			
			if (withdrawalType != null)
			{
				var swift:String = "";
				setCommissionText("...");
				PayManager.S_WITHDRAWAL_COMMISSION_RESPOND.add(onCommissionRespond);
				var debitCurrrency:String;
				if (selectedAccount != null && currency != selectedAccount.CURRENCY)
				{
					debitCurrrency = selectedAccount.CURRENCY;
				}
				var card:Object = selectorCard.getValue();
				if (card != null)
					swift = card.number;
				PayManager.callGetWithdrawalCommission(amount, currency, withdrawalType, swift, _lastComissionCallID, debitCurrrency);
			}
		}
		
		private function getCurrentWithdrawalType():String 
		{
			var card:Object = selectorCard.getValue();
			if (card != null)
			{
				if (card.programme == "linked")
				{
					return "CARD";
				}
				else
				{
					return "PPCARD";
				}
				
			}
			
			return null;
		}
		
		private function onCommissionRespond(respond:PayRespond):void{
		//	accountsPreloader.stop();
			if (respond.savedRequestData.callID == _lastComissionCallID){
				
				if (respond.error == false){
					// show commission
					_lastComissionData = respond.data;
					//setCommissionText("Commission loaded");
					updateCommissionText();
					
				}else{
					// has error 
					setCommissionText("");
				}
			}			
		}
		
		private function setCommissionText(value:String):void 
		{
			drawAccountText(value);
		}
		
		private function updateCommissionText():void{
				
			//if(_lastComissionData==null)
			/*if (paramsObj.currency != ""){						
				for (var i:int = 0; i < _lastComissionData.length; i++) {
					var arr:Array = _lastComissionData[i];		
					
					if (arr != null && arr.length == 2) {
						if (arr[1] == paramsObj.currency) {
							//labelTextFieldCommission.text = 
							setCommissionText(Lang.textCommission + ": " + arr[0] + " " + arr[1]);
						}
					}
				}			
			}else{*/
				if (selectedAccount != null && selectedAccount.CURRENCY != selectorCurrency.value && _lastComissionData.length > 0 && _lastComissionData[0][1] != _lastComissionData[1][1])
				{
					setCommissionText(Lang.textCommission + ": " + _lastComissionData[0][0] + " " + _lastComissionData[0][1] + " (" + _lastComissionData[1][0] + " " + _lastComissionData[1][1] + ")");		
				}
				else
				{
					setCommissionText(Lang.textCommission + ": " + _lastComissionData[0][0] + " " + _lastComissionData[0][1]);		
				}
		//	}
		}
		
		private function checkCommision():void 
		{
			callLoadComission();
		}
		
		private function showToastMessage():void {
			ToastMessage.display(Lang.connectionError);
		}
		
		private function onChangeInputValueCurrency():void {
			checkDataValid();
			checkCommision();
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
			selectorDebitAccont.setValue(Lang.walletToCharge);
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
			if (accountText.bitmapData != null)
			{
				accountText.bitmapData.dispose();
				accountText.bitmapData = null;
			}
			accountText.visible = true;
			accountText.bitmapData = TextUtils.createTextFieldData(text, componentsWidth, 10, true, TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, FontSize.SUBHEAD, true, Style.color(Style.COLOR_SUBTITLE), Style.color(Style.COLOR_BACKGROUND), false);
			accountText.x = int(_width * .5 - accountText.width * .5);
		}
		
		override protected function drawView():void
		{
			if (_isDisposed == true)
				return;
			
			bg.width = _width;
			
			verticalMargin = Config.MARGIN * 1.5;
			
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
			position += iAmountCurrency.height + verticalMargin * 2.5;
			
			// FROM ACCOUNT
			accountTitle.y = position;
			accountTitle.x = int(_width * .5 - accountTitle.width * .5);
			position += accountTitle.height + verticalMargin * .6;
			
			// ACCOUNT
			selectorDebitAccont.y = position;
			position += selectorDebitAccont.height + verticalMargin * 3;
			accountsPreloader.y = selectorDebitAccont.y + selectorDebitAccont.height;
			accountsPreloader.x = selectorDebitAccont.x;
			
			// TO
			cardSectionTitle.y = position;
			cardSectionTitle.x = int(_width * .5 - cardSectionTitle.width * .5);
			position += cardSectionTitle.height + verticalMargin * .6;
			
			// CARD
			selectorCard.y = position;
			
			cardsPreloader.y = selectorCard.y + selectorCard.height;
			cardsPreloader.x = selectorCard.x;
			position += selectorCard.height + verticalMargin;
			
			noCardsMessage.y = selectorCard.y + Config.MARGIN;
			
			accountText.y = position;
			position += accountText.height + verticalMargin * 3;
		//	accountText.visible = false;
			
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
				selectorCurrency.activate();
				selectorDebitAccont.activate();
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
			selectorCurrency.deactivate();
			selectorCard.deactivate();
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
			
			PayManager.S_WITHDRAWAL_COMMISSION_RESPOND.remove(onCommissionRespond);
			
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
			
			giftData = null;
		}
	}
}