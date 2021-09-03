package com.dukascopy.connect.screens.dialogs.paymentDialogs 
{
	import assets.IconAttention2;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.GiftData;
	import com.dukascopy.connect.data.SelectorItemData;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.gui.button.DDAccountButton;
	import com.dukascopy.connect.gui.button.DDFieldButton;
	import com.dukascopy.connect.gui.components.PercentSeletor;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.renderers.ListLinkWithIcon;
	import com.dukascopy.connect.gui.list.renderers.ListPayCurrency;
	import com.dukascopy.connect.gui.list.renderers.ListPayWalletItem;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.preloader.Preloader;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.dialogs.paymentDialogs.elements.InputField;
	import com.dukascopy.connect.screens.dialogs.x.base.bottom.ListSelectionPopup;
	import com.dukascopy.connect.screens.dialogs.x.base.float.FloatPopup;
	import com.dukascopy.connect.screens.payments.card.TypeCurrency;
	import com.dukascopy.connect.sys.applicationShop.commodity.Commodity;
	import com.dukascopy.connect.sys.applicationShop.commodity.CommodityType;
	import com.dukascopy.connect.sys.bankManager.BankManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.payments.CurrencyHelpers;
	import com.dukascopy.connect.sys.payments.PayAPIManager;
	import com.dukascopy.connect.sys.payments.PayManager;
	import com.dukascopy.connect.sys.payments.PayRespond;
	import com.dukascopy.connect.sys.payments.PaymentsManager;
	import com.dukascopy.connect.sys.payments.advancedPayments.vo.PayTaskVO;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.softKeyboard.SoftKeyboard;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.utils.NumberFormat;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import com.telefision.sys.signals.Signal;
	import fl.motion.Color;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	
	public class SellCommodityPopup extends FloatPopup {
		
		private var text:Bitmap;
		private var acceptButton:BitmapButton;
		private var backButton:BitmapButton;
		private var selectorDebitAccont:DDAccountButton;
		private var preloader:Preloader;
		private var screenLocked:Boolean;
		private var verticalMargin:Number;
		private var walletSelected:Boolean;
		private var iAmount:InputField;
		private var selectorCommodity:DDFieldButton;
		private var selectedAccount:Object;
		private var currentPayTask:PayTaskVO;
		private var payId:String;
		private var preloaderShown:Boolean = false;
		private var commodity:Commodity;
		private var icon:Bitmap;
		private var avatarSize:int;
		private var neeedShowCommodityList:Boolean;
		private var iAmountCurrency:InputField;
		private var selectorCurrency:com.dukascopy.connect.gui.button.DDFieldButton;
		private var needShowCurrencies:Boolean;
		private var title:flash.display.Bitmap;
		private var payFrom:flash.display.Bitmap;
		private var commodities:Vector.<Commodity>;
		
		private var rateCallID:String;
		private var latestCommissionData:Object;
		private var _hasLoadedCommission:Boolean;
		private var targetInvestment:Boolean;
		static private var c:int = 0;
		private var _isLoadingCommission:Boolean = false; // in process 
		private var giftData:GiftData;
		private var accountTitle:Bitmap;
		private var timeout:Number = 30;
		private var currentBalance:Number;
		private var costValue:Bitmap;
		private var iconAttention2:IconAttention2;
		private var attentionText:Bitmap;
		private var workHoursText:Bitmap;
		private var priceSelector:PercentSeletor;
		private var needCallback:Boolean;
		
		public function SellCommodityPopup() {
			
		}
		
		override protected function createView():void {
			super.createView();
			
			verticalMargin = Config.FINGER_SIZE * .2;
			contentPadding = Config.FINGER_SIZE * .3;
			avatarSize = Config.FINGER_SIZE * 1.3;
			
			acceptButton = new BitmapButton();
			acceptButton.setStandartButtonParams();
			acceptButton.setDownScale(1);
			acceptButton.setDownColor(0);
			acceptButton.tapCallback = onNextClick;
			acceptButton.disposeBitmapOnDestroy = true;
			addItem(acceptButton);
			
			backButton = new BitmapButton();
			backButton.setStandartButtonParams();
			backButton.setDownScale(1);
			backButton.setDownColor(0);
			backButton.tapCallback = onBack;
			backButton.disposeBitmapOnDestroy = true;
			addItem(backButton);
			
			icon = new Bitmap();
			container.addChild(icon);
			
			selectorDebitAccont = new DDAccountButton(openWalletSelector, null, false, -1, NaN, Lang.toAccount);
			addItem(selectorDebitAccont);
		//	selectorDebitAccont.ena
			
			iAmount = new InputField( -1, Input.MODE_DIGIT_DECIMAL);
			iAmount.onChangedFunction = onChangeInputValue;
			iAmount.setPadding(0);
			addItem(iAmount);
			var tf:TextFormat = new TextFormat();
			tf.size = FontSize.AMOUNT;
			tf.align = TextFormatAlign.LEFT;
			tf.color = Style.color(Style.COLOR_TEXT);
			tf.font = Config.defaultFontName;
			iAmount.updateTextFormat(tf);
			
			selectorCommodity = new DDFieldButton(selectCommodityTap, "", false, NaN, Lang.instrument);
			addItem(selectorCommodity);
			
			iAmountCurrency = new InputField( -1, Input.MODE_DIGIT_DECIMAL);
			iAmountCurrency.onChangedFunction = onChangeInputValueCurrency;
			iAmountCurrency.setPadding(0);
			addItem(iAmountCurrency);
			var tfAmountCurrency:TextFormat = new TextFormat();
			tfAmountCurrency.size = FontSize.AMOUNT;
			tfAmountCurrency.align = TextFormatAlign.LEFT;
			tfAmountCurrency.color = com.dukascopy.connect.sys.style.presets.Color.GREEN;
			tfAmountCurrency.font = Config.defaultFontName;
			iAmountCurrency.updateTextFormat(tfAmountCurrency);
			
			selectorCurrency = new DDFieldButton(selectCurrencyTap, "", false);
			addItem(selectorCurrency);
			
			title = new Bitmap();
			addItem(title);
			
			payFrom = new Bitmap();
			addItem(payFrom);
			
			accountTitle = new Bitmap();
			addItem(accountTitle);
			
			costValue = new Bitmap();
			addItem(costValue);
			
			iconAttention2 = new IconAttention2();
			addItem(iconAttention2);
			
			var iconSize:int = Config.FINGER_SIZE * .25;
			UI.scaleToFit(iconAttention2, iconSize, iconSize);
			
			iconAttention2.alpha = 0;
			
			attentionText = new Bitmap();
			addItem(attentionText);
			
			priceSelector = new PercentSeletor();
			addItem(priceSelector)
		}
		
		override public function onBack(e:Event = null):void {
			close();
		}
		
		private function onNextClick():void 
		{
			SoftKeyboard.closeKeyboard();
			if (iAmount != null)
			{
				iAmount.forceFocusOut();
			}
			if (targetInvestment)
			{
				giftData.customValue = Number(iAmount.value);
			}
			else{
				giftData.customValue = Number(iAmountCurrency.value);
			}
			giftData.fixedCommodityValue = targetInvestment;
			
			giftData.accountNumber = selectedAccount.ACCOUNT_NUMBER;
			giftData.currency = selectorCurrency.value;
			giftData.credit_account_currency = commodity.type.value;
			giftData.debit_account_currency = selectedAccount.CURRENCY;
			
			needCallback = true;
			close();
		}
		
		override public function initScreen(data:Object = null):void
		{
			if (data != null && "giftData" in data && data.giftData is GiftData) {
				giftData = data.giftData as GiftData;
				if (giftData.currency != null)
				{
					commodity = new Commodity(new CommodityType(giftData.currency));
				}
			}
			
			super.initScreen(data);
			
			PaymentsManager.activate();
			PayManager.S_CANCEL_AUTH.add(cancelAuth);
			
			checkData();
		}
		
		override protected function drawContent():void 
		{
			drawControls();
			
			updatePositions();
		}
		
		override protected function getBottomPadding():int 
		{
			var result:int = 0;
			if (acceptButton != null)
			{
				result = acceptButton.height + contentPadding * 2;
			}
			return result;
		}
		
		override protected function updateContentPositions():void 
		{
			updatePositions();
		}
		
		private function updatePositions():void 
		{
			icon.y = int(-avatarSize * .5);
			
			var position:int = verticalMargin * 2;
			
			title.y = position;
			position += title.height + verticalMargin * 1;
			
			costValue.y = position;
			position += costValue.height + verticalMargin * 1;
			
			attentionText.y = position;
			position += attentionText.height + verticalMargin * 3;
			
			if (workHoursText != null)
			{
				position -= verticalMargin * 2;
				workHoursText.y = position;
				iconAttention2.y = int(workHoursText.y);
				position += workHoursText.height + verticalMargin * 3;
			}
			attentionText.x = int((getWidth() - attentionText.width) * .5);
			
			title.x = int(getWidth() * .5 - title.width * .5);
			
			iAmount.x = contentPadding;
			iAmount.y = position;
			selectorCommodity.y = int(iAmount.y + iAmount.linePosition() - selectorCommodity.linePosition())
			position += iAmount.height + verticalMargin * 1.5;
			
			priceSelector.x = contentPadding;
			priceSelector.y = position;
			position += priceSelector.height + verticalMargin * 2;
			
			payFrom.y = position;
			payFrom.x = int(getWidth() * .5 - payFrom.width * .5);
			position += payFrom.height + verticalMargin * 0;
			
			iAmountCurrency.x = contentPadding;
			iAmountCurrency.y = position;
			selectorCurrency.y = int(iAmountCurrency.y + iAmountCurrency.linePosition() - selectorCurrency.linePosition())
			position += iAmountCurrency.height + verticalMargin * 2;
			
			selectorDebitAccont.x = contentPadding;
			selectorDebitAccont.y = position;
			position += selectorDebitAccont.height + verticalMargin * 2;
			
			acceptButton.x = int(getWidth() - acceptButton.width - contentPadding);
			acceptButton.y = position;
			
			backButton.x = contentPadding;
			backButton.y = position;
		}
		
		private function drawPriceSelector():void 
		{
			priceSelector.draw(onPriceSelector, getPriceSelectorItems(), getWidth() - contentPadding * 2);
		}
		
		private function onPriceSelector(percent:Number):void 
		{
			if (selectedAccount != null)
			{
				var balance:Number = currentBalance;
				if (!isNaN(balance))
				{
					balance = parseFloat(NumberFormat.formatAmount(percent * balance / 100, commodity.type.value, true));
					if (!isNaN(balance))
					{
						iAmount.value = balance;
						updateOnCryptoChange();
					}
				}
			}
		}
		
		private function getPriceSelectorItems():Vector.<SelectorItemData> 
		{
			var result:Vector.<SelectorItemData> = new Vector.<SelectorItemData>();
			result.push(new SelectorItemData("10%", 10));
			result.push(new SelectorItemData("25%", 25));
			result.push(new SelectorItemData("50%", 50));
			result.push(new SelectorItemData("100%", 100));
			return result;
		}
		
		private function drawControls():void
		{
			drawTitle();
			drawTitle2();
			drawAtentionText();
			
			drawCommodityIcon();
			drawAccountSelector();
			drawAcceptButton(Lang.sell.toUpperCase());
			acceptButton.deactivate();
			acceptButton.alpha = 0.5;
			drawCostValue();
			drawPriceSelector();
			
			drawBackButton();
			
			iAmount.draw(getInputWidth(), Lang.amount, 1, null);
			iAmountCurrency.draw(getInputWidth(), null, 0, null);
			
			if (!isNaN(currentBalance) && currentBalance < 1)
			{
				iAmount.value = currentBalance;
			}
			
			var itemWidth:int =  getWidth() - contentPadding * 3 - getInputWidth();
			
			selectorCommodity.x = iAmount.x + iAmount.width + contentPadding;
			selectorCommodity.setSize(itemWidth, Config.FINGER_SIZE * .8);
			
			selectorCurrency.x = iAmountCurrency.x + iAmountCurrency.width + contentPadding;
			selectorCurrency.setSize(itemWidth, Config.FINGER_SIZE * .8);
			
			if (commodity)
			{
				selectorCommodity.setValue(commodity.getName());
			}
		}
		
		private function getInputWidth():int 
		{
			return ((getWidth() - contentPadding * 3) / 1.7);
		}
		
		private function openWalletSelector(e:Event = null):void
		{
			SoftKeyboard.closeKeyboard();
			if (iAmount != null)
			{
				iAmount.forceFocusOut();
			}
			
			if (PayAPIManager.hasSwissAccount == true)
			{
				DialogManager.alert(Lang.information, Lang.featureNoPaments, createPaymentsAccount, Lang.registrate, Lang.textCancel);
				return;
			}
			
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
					callback:onWalletSelect
				}, ServiceScreenManager.TYPE_SCREEN
			);
		}
		
		private function showPreloader():void
		{
			preloaderShown = true;
			
			if (preloader == null)
			{
				preloader = new Preloader();
			}
			preloader.x = getWidth() * .5;
			preloader.y = _height * .5;
			view.addChild(preloader);
			preloader.show();
		}
		
		private function onWalletSelect(account:Object):void
		{
			if (account == null) return;
			walletSelected = true;
			
			selectedAccount = account;
			selectorDebitAccont.setValue(account);
			
			if (iAmount != null)
			{
				if (!isNaN(iAmount.value) && selectorCommodity != null && selectorCommodity.value != null)
				{
					acceptButton.activate();
					acceptButton.alpha = 1;
				}
			}
			else
			{
				acceptButton.activate();
				acceptButton.alpha = 1;
			}
			
			selectorCurrency.setValue(account.CURRENCY);
			
			if (targetInvestment)
			{
				iAmountCurrency.value = 0;
			}
			else{
				iAmount.value = 0;
			}
			
			startLoadRate();
		}
		
		override protected function onRemove():void 
		{
			if (needCallback == true)
			{
				
				if (giftData.callback != null)
				{
					giftData.callback(giftData);
				}
				giftData = null;
				
				needCallback = false;
			}
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
		
		private function drawCommodityIcon():void
		{
			if (commodity == null)
			{
				return;
			}
			
			UI.disposeBMD(icon.bitmapData);
			var flagAsset:Sprite = commodity.getIcon();
			if (flagAsset != null)
			{
				icon.bitmapData = UI.renderAsset(flagAsset, avatarSize, avatarSize, false, "BuyCommodityPopup.flagIcon");
			}
			icon.x = int(getWidth() * .5 - icon.width * .5);
		}
		
		private function cancelAuth():void 
		{
			onBack();
		}
		
		private function drawAtentionText():void 
		{
			if (attentionText.bitmapData != null)
			{
				attentionText.bitmapData.dispose();
				attentionText.bitmapData = null;
			}
			attentionText.bitmapData = TextUtils.createTextFieldData(Lang.indicativeRates, getWidth() - contentPadding * 2, 10, true, TextFormatAlign.LEFT, 
																	TextFieldAutoSize.LEFT, FontSize.CAPTION_1, true, Style.color(Style.COLOR_SUBTITLE), Style.color(Style.COLOR_BACKGROUND), false, true);
		}
		
		private function drawCostValue(value:String = " "):void 
		{
			if (costValue.bitmapData)
			{
				costValue.bitmapData.dispose();
				costValue.bitmapData = null;
			}
			costValue.bitmapData = TextUtils.createTextFieldData(value, getWidth() - contentPadding * 2, 10, true, TextFormatAlign.CENTER, 
																	TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .24, true, Style.color(Style.COLOR_SUBTITLE), Style.color(Style.COLOR_BACKGROUND), false, true);
			costValue.x = int(getWidth() * .5 - costValue.width * .5);
		}
		
		// Rate Loaded 
		private function onRateRespond(respond:PayRespond):void 
		{
			if (respond.savedRequestData.callID == rateCallID){// 				
				if (!respond.error){
					latestCommissionData  = respond.data;
					_hasLoadedCommission = true;
					
				}else{
					hidePreloader();
					_hasLoadedCommission = false;
					latestCommissionData = null;
					// remember unsucessfull operation? 
					// can be called from callAgainInsidePayManager
				}
				
				isLoadingCommission = false;
			}
		}
		
		public function get isLoadingCommission():Boolean {return _isLoadingCommission;}		
		public function set isLoadingCommission(value:Boolean):void {
			if (value == _isLoadingCommission) return;
			_isLoadingCommission = value;
			onCommissionLoadingStateChange();
		}
		
		private function checkData():void {
			
			if (PayManager.accountInfo != null) {
				if (PayManager.systemOptions != null) {
					onDataReady();
				} else {
					blockInputs();
					getSystemOptions();
				}
			} else {
				blockInputs(); 
				PayManager.init();
				PayManager.S_ACCOUNT.add(onAccountInfo);
				PayManager.callGetAccountInfo();
			}
		}
		
		private function onSwissApiChecked():void 
		{
			if (PayAPIManager.hasSwissAccount){
				checkData();
			}else{
				//!TODO:;
			}
		}
		
		private function selectAccount(currency:String):void 
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
				if (defaultAccount != null)
				{
					onWalletSelect(defaultAccount);
				}
			}
		}
		
		private function onDataReady():void 
		{
			PayManager.S_INVESTMENTS_RATE_RESPOND.add(onRateRespond);
			targetInvestment = true;
			var currency:String = PayManager.accountInfo.investmentReferenceCurrency
			if (PayManager.accountInfo.investmentReferenceCurrency == null)
			{
				currency = TypeCurrency.EUR;
			}
			
			selectAccount(currency);
			
			if (currency)
			{
				selectorCurrency.setValue(currency);
				
				commodities = new Vector.<Commodity>;
				var commodityItem:Commodity;
				if (PayManager.systemOptions.investmentCurrencies)
				{
					for (var i:int = 0; i < PayManager.systemOptions.investmentCurrencies.length; i++) 
					{
						commodityItem = new Commodity(new CommodityType(PayManager.systemOptions.investmentCurrencies[i]));
						commodities.push(commodityItem);
					}
				}
				if (commodities.length > 0)
				{
					if (commodity == null)
					{
						commodity = commodities[0];
						selectorCommodity.setValue(commodity.getName());
						drawTitle();
						drawCommodityIcon();
					}
					drawMaxInvestments();
				}
			}
			else{
				setReferenceCurrency();
			}
			
			if (giftData != null && giftData.accountNumber != null)
			{
				selectAccountByNumber(giftData.accountNumber);
				if (selectedAccount != null && selectedAccount.CURRENCY == giftData.currency)
				{
					targetInvestment = false;
					iAmountCurrency.value = giftData.customValue;
				}
				else{
					targetInvestment = true;
					if (giftData.customValue != 0)
					{
						iAmount.value = giftData.customValue;
					}
					
					if (commodities != null)
					{
						var selectedCommodity:Commodity;
						for (var j:int = 0; j < commodities.length; j++) 
						{
							if (commodities[j].type.value == giftData.currency)
							{
								callBackSelectCommodity(commodities[j]);
								break;
							}
						}
					}
				}
			}
			
			startLoadRate();
		}
		
		private function selectAccountByNumber(accountNumber:String):void 
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
				selectorCurrency.setValue(account.CURRENCY);
			}
		}
		
		private function startLoadRate():void 
		{
			if (targetInvestment)
			{
			//	iAmount.selectBorder();
			//	iAmountCurrency.unselectBorder();
			}
			else{
			//	iAmountCurrency.selectBorder();
			//	iAmount.unselectBorder();
			}
			
			TweenMax.killDelayedCallsTo(loadRate);
			TweenMax.delayedCall(1, loadRate);
		}
		
		private static function generateCallID(prefix:String):String {c++; return c +"" + prefix as String; }
		
		private function loadRate():void 
		{
			var avaliable:Boolean = false;
			if (targetInvestment)
			{
				if (!isNaN(Number(iAmount.value)) && Number(iAmount.value) > 0)
				{
					avaliable = true;
				}
			}
			else{
				if (!isNaN(Number(iAmountCurrency.value)) && Number(iAmountCurrency.value) > 0)
				{
					avaliable = true;
				}
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
			var requestObject:Object = generateCommissionRequest();
			//trace("Laod Rates "+ UI.tracedObj(requestObject));
			PayManager.callGetInvestmentRate(requestObject, rateCallID);
		}
		
		private function generateCommissionRequest():Object {
			var requestObj:Object = {};
			
			
			/*var currency:String = PayManager.accountInfo.investmentReferenceCurrency;
			if (PayManager.accountInfo.investmentReferenceCurrency == null)
			{
				currency = TypeCurrency.EUR;
			}*/
			
			requestObj.currency = selectorCurrency.value;
			requestObj.instrument = commodity.type.value;
			requestObj.direction  = "sell";
			
			if (targetInvestment == false){ // euro 
				requestObj.amount  = Number(iAmountCurrency.value);				
			}else{ // 				
				requestObj.quantity = Number(iAmount.value);
			}			
			return requestObj;
		}
		
		private function onCommissionLoadingStateChange():void {
			
			if (_isLoadingCommission){
				
			}else{		
				
				if (latestCommissionData != null){
					
					var additionalWarning:String = "";
					if ("offmarket_warning" in latestCommissionData && latestCommissionData.offmarket_warning != null)
					{
					//	additionalWarning = "<br/><br/><font color='#FF0000'>" + latestCommissionData.offmarket_warning + "</font>";
						drawWarning(latestCommissionData.offmarket_warning);
					}
					else
					{
						removeWarning();
					}
					
					hidePreloader();
					if (targetInvestment == false)
					{
						iAmount.value = latestCommissionData.debit;
					}
					else{
						iAmountCurrency.value = latestCommissionData.credit;
					}
					
					if (commodity != null)
					{
						var value:String = ((Math.floor(latestCommissionData.rate_used * 100)) / 100).toString();
						drawCostValue("1 " + commodity.getMeasurmentName() + " = " + value + " " + selectorCurrency.value + additionalWarning);
					}
					drawView();
					
					TweenMax.delayedCall(timeout, startLoadRate);
				}
			}
		}
		
		private function drawWarning(text:String):void 
		{
			if (workHoursText == null)
			{
				workHoursText = new Bitmap()
				addItem(workHoursText);
				
				workHoursText.bitmapData = TextUtils.createTextFieldData(text, getWidth() - contentPadding * 3 - iconAttention2.width, 10, true, TextFormatAlign.LEFT, 
																	TextFieldAutoSize.LEFT, FontSize.CAPTION_1, true, Style.color(Style.COLOR_SUBTITLE), Style.color(Style.COLOR_BACKGROUND), false, true);
				
				iconAttention2.x = contentPadding;
				iconAttention2.alpha = 1;
				workHoursText.x = int(iconAttention2.x + iconAttention2.width + contentPadding);
			}
			updatePositions();
		}
		
		private function removeWarning():void 
		{
			if (workHoursText != null)
			{
				removeItem(workHoursText);
				UI.destroy(workHoursText);
				workHoursText = null;
			}
			if (iconAttention2 != null)
			{
				iconAttention2.alpha = 0;
			}
			updatePositions();
		}
		
		private function setReferenceCurrency():void 
		{
			//!TODO:;
		}
		
		private function onAccountInfo():void {
			
			if (PayManager.systemOptions != null)
			{
				onDataReady();
			}
			else{
				blockInputs();
				
				getSystemOptions();
			}
		}
		
		private function blockInputs():void 
		{
			
		}
		
		private function drawTitle():void 
		{
			if (commodity == null)
			{
				return;
			}
			
			if (title.bitmapData)
			{
				title.bitmapData.dispose();
				title.bitmapData = null;
			}
			title.bitmapData = TextUtils.createTextFieldData(Lang.sell + " " + commodity.getName(), getWidth() - contentPadding * 2, 10, false, 
															TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, FontSize.TITLE_2, false, Style.color(Style.COLOR_TEXT), Style.color(Style.COLOR_BACKGROUND), false, true);
			title.x = int(getWidth() * .5 - title.width * .5);
			
			drawView();
		}
		
		private function drawTitle2():void 
		{
			if (payFrom.bitmapData)
			{
				payFrom.bitmapData.dispose();
				payFrom.bitmapData = null;
			}
			payFrom.bitmapData = TextUtils.createTextFieldData(Lang.textGet, getWidth() - contentPadding * 2, 10, false, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
																FontSize.TITLE_2, false, Style.color(Style.COLOR_TEXT), Style.color(Style.COLOR_BACKGROUND), false, true);
		}
		
		private function selectCurrencyTap():void {
			needShowCurrencies = true;
			selectCurrency();
		}
		
		private function selectCurrency(e:Event = null):void {
			
			if (PayAPIManager.hasSwissAccount == false)
			{
				DialogManager.alert(Lang.information, Lang.featureNoPaments, createPaymentsAccount, Lang.registrate, Lang.textCancel);
				return;
			}				
			var currencies:Array = new Array();
			
			var wallets:Array = PayManager.accountInfo.accounts;
			var l:int = wallets.length;
			var walletItem:Object;
			for (var i:int = 0; i < l; i++)
			{
				walletItem = wallets[i];
				currencies.push(walletItem.CURRENCY);
			}			
			DialogManager.showDialog(
				ListSelectionPopup,
				{
					items:currencies,
					title:Lang.selectCurrency,
					renderer:ListPayCurrency,
					callback:callBackSelectCurrency
				}, ServiceScreenManager.TYPE_SCREEN
			);
		}
		
		private function getSystemOptions():void 
		{
			if(PayManager.S_SYSTEM_OPTIONS_READY == null)
			{
				PayManager.S_SYSTEM_OPTIONS_READY = new Signal("PayManager.S_SYSTEM_OPTIONS_READY");
			}
			if (PayManager.S_SYSTEM_OPTIONS_ERROR == null)
			{
				PayManager.S_SYSTEM_OPTIONS_ERROR = new Signal("PayManager.S_SYSTEM_OPTIONS_ERROR");
			}
			PayManager.S_SYSTEM_OPTIONS_READY.add(onSystemOptions);
			PayManager.S_SYSTEM_OPTIONS_ERROR.add(onSystemOptions);
			
			callBackGetConfig();
		}
		
		private function onSystemOptions():void
		{
			onDataReady();
		}
		
		private function localSelectCurrency(currency:String):void {
			selectorCurrency.setValue(currency);
		}
		
		private function callBackSelectCurrency(currency:String):void {
			if (selectorCurrency != null && currency != null) {
				selectorCurrency.setValue(currency);
			}
			
			selectAccount(currency);
			
			iAmountCurrency.value = 0;
			targetInvestment = true;
			startLoadRate();
		}
		
		private function onCommoditiesReady():void 
		{
			if (neeedShowCommodityList)
			{
				neeedShowCommodityList = false;
				selectCommodityTap();
			}
		}
		
		private function callBackGetConfig():void
		{
			PayManager.callGetSystemOptions();
		}
		
		private function selectCommodityTap():void {
			if (commodities != null)
			{
				DialogManager.showDialog(
					ListSelectionPopup,
					{
						items:getCommoditiesArray(),
						title:Lang.selectCommodity,
						renderer:ListLinkWithIcon,
						callback:callBackSelectCommodity
					}, ServiceScreenManager.TYPE_SCREEN
				);
			}
			else{
				neeedShowCommodityList = true;
			}
		}
		
		private function getCommoditiesArray():Array
		{
			var result:Array = new Array();
			if (commodities != null)
			{
				var l:int = commodities.length;
				for (var i:int = 0; i < l; i++) 
				{
					result.push(commodities[i]);
				}
			}
			return result;
		}
		
		private function callBackSelectCommodity(commodity:Object):void {
			if (commodity is Commodity)
			{
				if (selectorCommodity != null && commodity != null) {
					this.commodity = commodity as Commodity;
					selectorCommodity.setValue(this.commodity.getName());
				}
			}
			drawMaxInvestments();
			drawCommodityIcon();
			drawTitle();
			
			iAmountCurrency.value = 0;
			targetInvestment = true;
			startLoadRate();
		}
		
		private function drawMaxInvestments():void 
		{
			var investmentNum:String = "";
			var investments:Array = BankManager.getInvestmentsArray();
			if (investments != null && commodity != null)
			{
				var l:int = investments.length;
				for (var i:int = 0; i < l; i++) 
				{
					if (investments[i]["INSTRUMENT"] == commodity.type.value)
					{
						investmentNum = investments[i]["BALANCE"];
					}
				}
			}
			currentBalance = Number(investmentNum);
			
			if (!isNaN(currentBalance))
			{
				if (!isNaN(currentBalance) && currentBalance < 1)
				{
					iAmount.value = currentBalance;
				}
				var amountText:String = NumberFormat.formatAmount(Number(investmentNum), commodity.type.value, true);
				amountText += " " + CurrencyHelpers.getCurrencyByKey(commodity.type.value);
				iAmount.drawUnderlineValue(Lang.youHave + " " + amountText);
			}
		}
		
		private function showToastMessage():void {
			ToastMessage.display(Lang.connectionError);
		}
		
		private function onChangeInputValue():void {
			updateOnCryptoChange();
			drawPriceSelector();
		}
		
		private function updateOnCryptoChange():void 
		{
			if (iAmount != null && selectorCommodity != null && selectorCommodity.value != null && !isNaN(iAmount.value) && iAmount.value > 0)
			{
				if (acceptButton != null && walletSelected == true)	{
					acceptButton.activate();
					acceptButton.alpha = 1;
				}
			}
			
			iAmountCurrency.value = 0;
			targetInvestment = true;
			startLoadRate();
		}
		
		private function onChangeInputValueCurrency():void {
			updateOnFiatChange();
			drawPriceSelector();
		}
		
		private function updateOnFiatChange():void 
		{
			if (iAmount != null && selectorCommodity != null && selectorCommodity.value != null && !isNaN(iAmount.value) && iAmount.value > 0)
			{
				if (acceptButton != null && walletSelected == true)	{
					acceptButton.activate();
					acceptButton.alpha = 1;
				}
			}
			iAmount.value = 0;
			targetInvestment = false;
			startLoadRate();
		}
		
		private function hidePreloader():void
		{
			preloaderShown = false;
			
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
			selectorDebitAccont.setSize(getWidth() - contentPadding * 2, Config.FINGER_SIZE * .8);
			selectorDebitAccont.setValue(Lang.loading);
			
			selectorDebitAccont.x = contentPadding;
		}
		
		private function drawAcceptButton(text:String):void
		{
			var textSettings:TextFieldSettings = new TextFieldSettings(text, com.dukascopy.connect.sys.style.presets.Color.WHITE, FontSize.BODY, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, com.dukascopy.connect.sys.style.presets.Color.RED, 1, -1, NaN, getButtonWidth(), Style.size(Style.BUTTON_PADDING), Style.size(Style.SIZE_BUTTON_CORNER));
			acceptButton.setBitmapData(buttonBitmap, true);
		}
		
		private function drawBackButton():void
		{
			var textSettings:TextFieldSettings = new TextFieldSettings(Lang.textBack.toUpperCase(), Style.color(Style.COLOR_TEXT), FontSize.BODY, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, Style.color(Style.COLOR_BACKGROUND), 1, -1, Style.color(Style.COLOR_BUTTON_OUTLINE), getButtonWidth(), Style.size(Style.BUTTON_PADDING), Style.size(Style.SIZE_BUTTON_CORNER));
			backButton.setBitmapData(buttonBitmap, true);
		}
		
		private function getButtonWidth():int 
		{
			return (getWidth() - contentPadding * 3) * .5;
		}
		
		override protected function drawView():void
		{
			if (_isDisposed == true)
				return;
			
			scrollBottom.y = scrollPanel.itemsHeight + Config.APPLE_BOTTOM_OFFSET + Config.FINGER_SIZE * .3;
			super.drawView();
		}
		
		override public function activateScreen():void
		{
			if (_isDisposed == true)
				return;
			
			super.activateScreen();
			
			if (walletSelected == true)
			{
				if (iAmount != null && !isNaN(iAmount.value) && selectorCommodity != null && selectorCommodity.value != null)
				{
					acceptButton.activate();
					acceptButton.alpha = 1;
				}
			}
			
			if (backButton.visible)
			{
				backButton.activate();
			}
			
			if (iAmount != null && iAmount.visible)
			{
				iAmount.activate();
				iAmountCurrency.activate();
			}
			
			if (selectorCommodity != null && selectorCommodity.visible)
			{
			//	selectorCommodity.activate();
			}
			priceSelector.activate();
		}
		
		override public function deactivateScreen():void
		{
			if (_isDisposed == true)
				return;
			
			super.deactivateScreen();
			
			acceptButton.deactivate();
			backButton.deactivate();
			selectorDebitAccont.deactivate();
			
			if (iAmount != null)
			{
				iAmount.deactivate();
				iAmountCurrency.deactivate();
			}
			
			if (selectorCommodity != null)
			{
				selectorCommodity.deactivate();
				selectorCurrency.deactivate();
			}
			priceSelector.deactivate();
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
			
			if (PayManager.S_CANCEL_AUTH)
				PayManager.S_CANCEL_AUTH.remove(cancelAuth);
			PaymentsManager.deactivate();
			
			if (PayAPIManager.S_SWISS_API_CHECKED)
			{
				PayAPIManager.S_SWISS_API_CHECKED.remove(onSwissApiChecked);
			}
			if (PayManager.S_ACCOUNT)
			{
				PayManager.S_ACCOUNT.remove(onAccountInfo);
			}
			if (PayManager.S_INVESTMENTS_RATE_RESPOND)
			{
				PayManager.S_INVESTMENTS_RATE_RESPOND.remove(onRateRespond);
			}
			if (PayManager.S_SYSTEM_OPTIONS_READY)
			{
				PayManager.S_SYSTEM_OPTIONS_READY.remove(onSystemOptions);
			}
			if (PayManager.S_SYSTEM_OPTIONS_ERROR){
				PayManager.S_SYSTEM_OPTIONS_ERROR.remove(onSystemOptions);
			}
			if (workHoursText != null)
			{
				UI.destroy(workHoursText);
				workHoursText = null;
			}
			if (iconAttention2 != null)
			{
				UI.destroy(iconAttention2);
				iconAttention2 = null;
			}
			if (attentionText != null)
			{
				UI.destroy(attentionText);
				attentionText = null;
			}
			if (title != null)
			{
				UI.destroy(title);
				title = null;
			}
			if (payFrom != null)
			{
				UI.destroy(payFrom);
				payFrom = null;
			}
			if (accountTitle != null)
			{
				UI.destroy(accountTitle);
				accountTitle = null;
			}
			if (costValue != null)
			{
				UI.destroy(costValue);
				costValue = null;
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
			if (icon != null)
			{
				UI.destroy(icon);
				icon = null;
			}
			if (iAmount != null)
			{
				iAmount.dispose();
				iAmount = null;
			}
			if (selectorCommodity != null)
			{
				selectorCommodity.dispose();
				selectorCommodity = null;
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
			if (acceptButton != null)
			{
				acceptButton.dispose();
				acceptButton = null;
			}
			if (priceSelector != null)
			{
				priceSelector.dispose();
				priceSelector = null;
			}
			TweenMax.killDelayedCallsTo(startLoadRate);
			TweenMax.killDelayedCallsTo(loadRate);
			commodity = null;
			
			if (PayManager.S_ACCOUNT != null)
				PayManager.S_ACCOUNT.remove(onAccountInfo);
		}
	}
}