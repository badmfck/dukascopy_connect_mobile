package com.dukascopy.connect.screens.dialogs.paymentDialogs 
{
	import assets.IconAttention2;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.GiftData;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.gui.button.DDAccountButton;
	import com.dukascopy.connect.gui.button.DDFieldButton;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.renderers.ListLinkWithIcon;
	import com.dukascopy.connect.gui.list.renderers.ListPayCurrency;
	import com.dukascopy.connect.gui.list.renderers.ListPayWalletItem;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.preloader.Preloader;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.dialogs.ScreenLinksDialog;
	import com.dukascopy.connect.screens.dialogs.ScreenPayDialog;
	import com.dukascopy.connect.screens.dialogs.bottom.base.ListSelectionPopup;
	import com.dukascopy.connect.screens.payments.card.TypeCurrency;
	import com.dukascopy.connect.sys.applicationShop.commodity.Commodity;
	import com.dukascopy.connect.sys.applicationShop.commodity.CommodityType;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.bankManager.BankManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
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
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import com.telefision.sys.signals.Signal;
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
	
	public class SellCommodityPopup extends BaseScreen {
		
		protected var container:Sprite;
		private var bg:Shape;
		private var text:Bitmap;
		private var acceptButton:BitmapButton;
		private var accountText:Bitmap;
		private var backButton:BitmapButton;
		private var selectorDebitAccont:DDAccountButton;
		private var preloader:Preloader;
		private var _lastCommissionCallID:String;
		private var screenLocked:Boolean;
		private var finishImage:Bitmap;
		private var finishImageMask:Sprite;
		private var verticalMargin:Number;
		private var walletSelected:Boolean;
		private var iAmount:Input;
		private var selectorCommodity:DDFieldButton;
		private var selectedAccount:Object;
		private var currentPayTask:PayTaskVO;
		private var payId:String;
		private var resultAccount:String;
		private var newAmount:Number;
		private var currentCommision:Number = 0;
		private var preloaderShown:Boolean = false;
		private var commodity:Commodity;
		private var icon:Bitmap;
		private var avatarSize:int;
		private var neeedShowCommodityList:Boolean;
		private var iAmountCurrency:com.dukascopy.connect.gui.input.Input;
		private var selectorCurrency:com.dukascopy.connect.gui.button.DDFieldButton;
		private var needShowCurrencies:Boolean;
		private var title:flash.display.Bitmap;
		private var payFrom:flash.display.Bitmap;
		private var commodities:Vector.<Commodity>;
		protected var componentsWidth:int;
		private var maxInvestments:Bitmap;
		
		private var rateCallID:String;
		private var latestCommissionData:Object;
		private var _hasLoadedCommission:Boolean;
		private var targetInvestment:Boolean;
		static private var c:int = 0;
		private var _isLoadingCommission:Boolean = false; // in process 
		private var giftData:GiftData;
		private var accountTitle:flash.display.Bitmap;
		private var timeout:Number = 30;
		private var amountBack:Sprite;
		private var useAllButton:BitmapButton;
		private var currentBalance:Number;
		private var costValue:Bitmap;
		private var iconAttention:IconAttention2;
		private var iconAttention2:IconAttention2;
		private var attentionText:Bitmap;
		private var workHoursText:Bitmap;
		
		public function SellCommodityPopup() {
			
		}
		
		override protected function createView():void {
			super.createView();
			container = new Sprite();
			
			avatarSize = Config.FINGER_SIZE * 2;
			
			bg = new Shape();
			bg.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			var round:int = Config.FINGER_SIZE * .3;
			var round3:int = round * 3;
			bg.graphics.drawRect(0, 0, round3, round3);
			bg.scale9Grid = new Rectangle(round, round, round, round);
			container.addChild(bg);
			
			accountText = new Bitmap();
			container.addChild(accountText);
			
			amountBack = new Sprite();
			container.addChild(amountBack);
			
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
			
			useAllButton = new BitmapButton();
			useAllButton.setStandartButtonParams();
			useAllButton.setDownScale(1);
			useAllButton.setDownColor(0);
			useAllButton.tapCallback = useAll;
			useAllButton.disposeBitmapOnDestroy = true;
			container.addChild(useAllButton);
			
			icon = new Bitmap();
			container.addChild(icon);
			
			selectorDebitAccont = new DDAccountButton(openWalletSelector, null, false);
			container.addChild(selectorDebitAccont);
		//	selectorDebitAccont.ena
			
			_view.addChild(container);
			
			iAmount = new Input(Input.MODE_DIGIT_DECIMAL);
			iAmount.setParams(Lang.textAmount, Input.MODE_DIGIT_DECIMAL);
			iAmount.S_CHANGED.add(onChangeInputValue);
			iAmount.setRoundBG(false);
			iAmount.getTextField().textColor = com.dukascopy.connect.sys.style.presets.Color.RED;
			iAmount.setRoundRectangleRadius(0);
			iAmount.inUse = true;
			container.addChild(iAmount.view);
			
			selectorCommodity = new DDFieldButton(selectCommodityTap);
			container.addChild(selectorCommodity);
			
			iAmountCurrency = new Input(Input.MODE_DIGIT_DECIMAL);
			iAmountCurrency.setParams(Lang.textAmount, Input.MODE_DIGIT_DECIMAL);
			iAmountCurrency.S_CHANGED.add(onChangeInputValueCurrency);
			iAmountCurrency.setRoundBG(false);
			iAmountCurrency.getTextField().textColor = com.dukascopy.connect.sys.style.presets.Color.GREEN;
			iAmountCurrency.setRoundRectangleRadius(0);
			iAmountCurrency.inUse = true;
			container.addChild(iAmountCurrency.view);
			
			selectorCurrency = new DDFieldButton(selectCurrencyTap, "", false);
			container.addChild(selectorCurrency);
			
			title = new Bitmap();
			container.addChild(title);
			
			maxInvestments = new Bitmap();
			container.addChild(maxInvestments);
			
			payFrom = new Bitmap();
			container.addChild(payFrom);
			
			accountTitle = new Bitmap();
			container.addChild(accountTitle);
			
			costValue = new Bitmap();
			container.addChild(costValue);
			
			iconAttention = new IconAttention2();
			container.addChild(iconAttention);
			
			iconAttention2 = new IconAttention2();
			container.addChild(iconAttention2);
			
			var iconSize:int = Config.FINGER_SIZE * .25;
			UI.scaleToFit(iconAttention, iconSize, iconSize);
			UI.scaleToFit(iconAttention2, iconSize, iconSize);
			
			iconAttention2.visible = false;
			
			attentionText = new Bitmap();
			container.addChild(attentionText);
		}
		
		private function useAll():void 
		{
			if (!isNaN(currentBalance))
			{
				iAmount.value = currentBalance.toString();
				loadRate();
			}
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
			
		//	DialogManager.showDialog(ScreenPayDialog, {callback: onWalletSelect, data: PayManager.accountInfo.accounts, itemClass: ListPayWalletItem/*ListPayAccount*/, label: Lang.TEXT_SELECT_ACCOUNT});
		}
		
		private function showPreloader():void
		{
			preloaderShown = true;
			
			var color:fl.motion.Color = new fl.motion.Color();
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
		
		private function onWalletSelect(account:Object):void
		{
			if (account == null) return;
			walletSelected = true;
			
			selectedAccount = account;
			selectorDebitAccont.setValue(account);
			
			if (iAmount != null)
			{
				if (iAmount.value != null && iAmount.value != "" && !isNaN(Number(iAmount.value)) && selectorCommodity != null && selectorCommodity.value != null)
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
				iAmountCurrency.value = "";
			}
			else{
				iAmount.value = "";
			}
			
			startLoadRate();
			
			loadCommision();
		}
		
		private function loadCommision():void
		{
			drawAccountText(Lang.commisionWillBe + "...");
			
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
			if (giftData.callback != null)
			{
				giftData.callback(giftData);
			}
			
			ServiceScreenManager.closeView();
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
			icon.x = int(_width * .5 - icon.width * .5);
		}
		
		override public function initScreen(data:Object = null):void
		{
			super.initScreen(data);
			
			if (data != null && "giftData" in data && data.giftData is GiftData) {
				giftData = data.giftData as GiftData;
				if (giftData.currency != null)
				{
					commodity = new Commodity(new CommodityType(giftData.currency));
				}
			}
			
			componentsWidth = _width - Config.DIALOG_MARGIN * 2;
			
			drawUseAllButton();
			drawTitle();
			drawTitle2();
			drawTitle3();
			drawAtentionText();
			
			drawCommodityIcon();
			drawMaxInvestments();
			drawAccountSelector();
		//	drawAccountText(Lang.chooseAccount);
			drawAcceptButton(Lang.sell);
			acceptButton.deactivate();
			acceptButton.alpha = 0.5;
			drawCostValue();
			
			drawBackButton();
			
			var itemWidth:int = (componentsWidth - Config.MARGIN) / 2;
			
			iAmount.width = itemWidth;
			iAmount.view.x = Config.DIALOG_MARGIN;
			
			iAmount.value = "1";
			if (!isNaN(currentBalance) && currentBalance < 1)
			{
				iAmount.value = currentBalance.toString();
			}
			
			selectorCommodity.x = iAmount.view.x + itemWidth + Config.MARGIN;
			selectorCommodity.setSize(itemWidth, Config.FINGER_SIZE * .8);
			
			iAmountCurrency.width = itemWidth;
			iAmountCurrency.view.x = Config.DIALOG_MARGIN;
			
			selectorCurrency.x = iAmountCurrency.view.x + itemWidth + Config.MARGIN;
			selectorCurrency.setSize(itemWidth, Config.FINGER_SIZE * .8);
			
			if (commodity)
			{
				selectorCommodity.setValue(commodity.getName());
			}
			
			PaymentsManager.activate();
			PayManager.S_CANCEL_AUTH.add(cancelAuth);
			
			checkData();
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
			attentionText.bitmapData = TextUtils.createTextFieldData(Lang.indicativeRates, componentsWidth - iconAttention.width - Config.MARGIN, 10, true, TextFormatAlign.LEFT, 
																	TextFieldAutoSize.LEFT, FontSize.CAPTION_1, true, Style.color(Style.COLOR_SUBTITLE), Style.color(Style.COLOR_BACKGROUND), false, true);
			
			iconAttention.x = Config.DOUBLE_MARGIN;
			attentionText.x = int(iconAttention.x + iconAttention.width + Config.MARGIN);
		}
		
		private function drawCostValue(value:String = " "):void 
		{
			if (costValue.bitmapData)
			{
				costValue.bitmapData.dispose();
				costValue.bitmapData = null;
			}
			costValue.bitmapData = TextUtils.createTextFieldData(value, componentsWidth, 10, true, TextFormatAlign.CENTER, 
																	TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .24, true, Style.color(Style.COLOR_SUBTITLE), Style.color(Style.COLOR_BACKGROUND), false, true);
			costValue.x = int(_width * .5 - costValue.width * .5);
		}
		
		private function drawTitle3():void 
		{
			if (accountTitle.bitmapData)
			{
				accountTitle.bitmapData.dispose();
				accountTitle.bitmapData = null;
			}
			accountTitle.bitmapData = TextUtils.createTextFieldData("<b>" + Lang.toAccount + "</b>", componentsWidth, 10, false, TextFormatAlign.LEFT, 
																	TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .3, false, 0x777E8A, 0xFFFFFF, false, true);
		}
		
		private function drawMaxInvestments():void 
		{
			if (maxInvestments.bitmapData)
			{
				maxInvestments.bitmapData.dispose();
				maxInvestments.bitmapData = null;
			}
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
			
			var value:String = "<font color='#2D4819' size='" + Config.FINGER_SIZE * .24 + "'>" + Lang.youHave + ": </font>" + 
							   "<font color='#2D4819' size='" + Config.FINGER_SIZE * .32 + "'>" + investmentNum + "</font>";
			
			maxInvestments.bitmapData = TextUtils.createTextFieldData(value, componentsWidth - useAllButton.width - Config.MARGIN, 10, false, TextFormatAlign.LEFT, 
																	TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .3, false, 0x777E8A, 0xD7ECC8, false, true);
			
			amountBack.x = iAmount.view.x;
			
			amountBack.graphics.clear();
			amountBack.graphics.beginFill(0xD7ECC8);
			amountBack.graphics.drawRoundRect(0, 0, componentsWidth - Config.FINGER_SIZE * .5, useAllButton.height, useAllButton.height, useAllButton.height);
			amountBack.graphics.endFill();
			
			amountBack.graphics.lineStyle(Config.FINGER_SIZE * .15, 0xFFFFFF);
			amountBack.graphics.drawRoundRect(componentsWidth - useAllButton.width, 0, useAllButton.width, useAllButton.height, useAllButton.height, useAllButton.height);
			amountBack.visible = false;
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
						drawMaxInvestments();
						drawCommodityIcon();
					}
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
					iAmountCurrency.value = giftData.customValue.toString();
				}
				else{
					targetInvestment = true;
					if (giftData.customValue != 0)
					{
						iAmount.value = giftData.customValue.toString();
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
				iAmount.selectBorder();
				iAmountCurrency.unselectBorder();
			}
			else{
				iAmountCurrency.selectBorder();
				iAmount.unselectBorder();
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
				
			//	addCommissionMeta(Lang.loadingCommission);
			//	addAssetMeta(Lang.loading);
			//	addAccountMeta(Lang.loading);
			}else{		
				
				if (latestCommissionData != null){
					
					var additionalWarning:String = "";
					if ("offmarket_warning" in latestCommissionData && latestCommissionData.offmarket_warning != null)
					{
					//	additionalWarning = "<br/><br/><font color='#FF0000'>" + latestCommissionData.offmarket_warning + "</font>";
						drawWarning(latestCommissionData.offmarket_warning);
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
					
					
					//var commissionText:String = Lang.spotRate+ latestCommissionData.rate_spot +", markup "+ latestCommissionData.rate_markup +"\n\nShown rates are indicative only\n"
					//var commissionText:String = Lang.commissionText;
					/*var str:String = "";
						str = LangManager.replace(Lang.regExtValue,Lang.commissionText, String(latestCommissionData.rate_spot));
						str = LangManager.replace(Lang.regExtValue, str, String(latestCommissionData.rate_markup));					
					addCommissionMeta(str);
					
					if (CURRENT_TAB_ID == TAB_ID_BUY){
						addAccountMeta("-" + latestCommissionData.debit +" " + PayManager.accountInfo.investmentReferenceCurrency ); //!!!!
						addAssetMeta("+"+latestCommissionData.credit + " "+CurrencyHelpers.getCurrencyByKey(fieldsData.instrument));
					}else{
						addAssetMeta("-"+latestCommissionData.debit+ " " + CurrencyHelpers.getCurrencyByKey(fieldsData.instrument));
						addAccountMeta("+"+latestCommissionData.credit+" " + PayManager.accountInfo.investmentReferenceCurrency);
					}*/
					
				}
			
			}
			
		//	updateComponentsActivity();
			
		}
		
		private function drawWarning(text:String):void 
		{
			if (workHoursText == null)
			{
				workHoursText = new Bitmap()
				container.addChild(workHoursText);
				
				workHoursText.bitmapData = TextUtils.createTextFieldData(text, componentsWidth, 10, true, TextFormatAlign.LEFT, 
																	TextFieldAutoSize.LEFT, FontSize.CAPTION_1, true, Style.color(Style.COLOR_SUBTITLE), Style.color(Style.COLOR_BACKGROUND), false, true);
				
				iconAttention2.x = Config.DOUBLE_MARGIN;
				iconAttention2.visible = true;
				workHoursText.x = int(iconAttention2.x + iconAttention2.width + Config.MARGIN);
			}
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
			title.bitmapData = TextUtils.createTextFieldData("<b>" + Lang.sell + " " + commodity.getName() + "</b>", componentsWidth, 10, false, 
															TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .3, false, 0x777E8A, 0xFFFFFF, false, true);
			title.x = int(_width * .5 - title.width * .5);
			
			drawView();
		}
		
		private function drawTitle2():void 
		{
			if (payFrom.bitmapData)
			{
				payFrom.bitmapData.dispose();
				payFrom.bitmapData = null;
			}
			payFrom.bitmapData = TextUtils.createTextFieldData("<b>" + Lang.textGet + "</b>", componentsWidth, 10, false, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
																Config.FINGER_SIZE * .3, false, 0x777E8A, 0xFFFFFF, false, true);
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
		//	selectorCurrency.activate();
		}
		
		private function callBackSelectCurrency(currency:String):void {
			if (selectorCurrency != null && currency != null) {
				selectorCurrency.setValue(currency);
				
			//	selectAccount(currency);
			//	checkCommision();
			}
			
			selectAccount(currency);
			
			iAmountCurrency.value = "";
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
				
			//	DialogManager.showDialog(ScreenLinksDialog, { callback:callBackSelectCommodity, data:commodities, itemClass:ListLinkWithIcon, title:Lang.selectCommodity, multilineTitle:false } );
			//	onChangeInputValue();
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
				//	checkCommision();
				}
			}
			drawMaxInvestments();
			drawCommodityIcon();
			drawTitle();
			
			iAmountCurrency.value = "";
			targetInvestment = true;
			startLoadRate();
		}
		
		private function showToastMessage():void {
			ToastMessage.display(Lang.connectionError);
		}
		
		private function onChangeInputValue():void {
			
		//	checkCommision();
			
			if (iAmount != null && selectorCommodity != null && selectorCommodity.value != null && iAmount.value != null && iAmount.value != "" && !isNaN(Number(iAmount.value)) && Number(iAmount.value) > 0)
			{
				if (acceptButton != null && walletSelected == true)	{
					acceptButton.activate();
					acceptButton.alpha = 1;
				}
			}
			else {
				if (acceptButton != null) {
				//	acceptButton.deactivate();
				}
			}
			iAmountCurrency.value = "";
			targetInvestment = true;
			startLoadRate();
		}
		
		private function onChangeInputValueCurrency():void {
			
		//	checkCommision();
			
			if (iAmount != null && selectorCommodity != null && selectorCommodity.value != null && iAmount.value != null && iAmount.value != "" && !isNaN(Number(iAmount.value)) && Number(iAmount.value) > 0)
			{
				if (acceptButton != null && walletSelected == true)	{
					acceptButton.activate();
					acceptButton.alpha = 1;
				}
			}
			else {
				if (acceptButton != null) {
				//	acceptButton.deactivate();
				}
			}
			iAmount.value = "";
			targetInvestment = false;
			startLoadRate();
		}
		
		private function checkCommision(immidiate:Boolean = false):void {
			currentCommision = 0;
			TweenMax.killDelayedCallsTo(checkCommision);
			
			var needUpdate:Boolean = true;
			
			if (iAmount != null && selectorCommodity != null && selectorCommodity.value != null && iAmount.value != null && iAmount.value != "" && !isNaN(Number(iAmount.value)) && Number(iAmount.value) > 0)
			{
				needUpdate = true;
			}
			
			if (walletSelected == false)
			{
				needUpdate = false;
			}
			
			if (needUpdate)
			{
				drawAccountText(Lang.commisionWillBe + "...");
				
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
			selectorDebitAccont.setValue(Lang.loading);
			
			selectorDebitAccont.x = Config.DIALOG_MARGIN;
		}
		
		private function drawUseAllButton():void
		{
			var textSettings:TextFieldSettings = new TextFieldSettings(Lang.useAll, 0xFFFFFF, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, 0x78C043, 1, Config.FINGER_SIZE * .6, NaN, -1, Config.FINGER_SIZE*.09);
			useAllButton.setBitmapData(buttonBitmap, true);
			useAllButton.x = int(_width - useAllButton.width - Config.DIALOG_MARGIN);
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
			
			position = verticalMargin + avatarSize;
			
			position += verticalMargin * 0.5;
			
			title.y = position;
			position += title.height + verticalMargin * .6;
			
			costValue.y = position;
			position += costValue.height + verticalMargin * 1.5;
			
			attentionText.y = position;
			iconAttention.y = int(attentionText.y);
			position += attentionText.height + verticalMargin;
			
			if (workHoursText != null)
			{
				workHoursText.y = position;
				iconAttention2.y = int(workHoursText.y);
				position += workHoursText.height + verticalMargin;
				
				iconAttention.x = Config.DOUBLE_MARGIN;
				attentionText.x = int(iconAttention.x + iconAttention.width + Config.MARGIN);
			}
			else
			{
				iconAttention.x = int(_width * .5 - (iconAttention.width + attentionText.width + Config.MARGIN) * .5);
				attentionText.x = int(iconAttention.x + iconAttention.width + Config.MARGIN);
			}
			
			title.x = int(_width * .5 - title.width * .5);
			
			iAmount.view.y = position;
			selectorCommodity.y = position;
			position += iAmount.height + verticalMargin;
			
			
			amountBack.y = position;
			useAllButton.y = position;
			maxInvestments.y = int(useAllButton.y + useAllButton.height * .5 - maxInvestments.height * .5);
			
			maxInvestments.x = Config.DIALOG_MARGIN;
			
			position += amountBack.height + verticalMargin * 2;
			
			payFrom.y = position;
			payFrom.x = int(_width * .5 - payFrom.width * .5);
			position += payFrom.height + verticalMargin * 1;
			
			iAmountCurrency.view.y = position;
			selectorCurrency.y = position;
			position += iAmountCurrency.height + verticalMargin * 2;
			
			accountTitle.y = position;
			accountTitle.x = int(_width * .5 - accountTitle.width * .5);
			position += accountTitle.height + verticalMargin * .6;
			
			selectorDebitAccont.y = position;
			position += selectorDebitAccont.height + verticalMargin * 2;
			
			//	accountText.y = position;
			//	position += accountText.height + verticalMargin * 1.8;
			accountText.visible = false;
			
			acceptButton.y = position;
			backButton.y = position;
			position += acceptButton.height + verticalMargin * 1.8;
			
			bg.height = position - avatarSize/2;
			
			bg.y = avatarSize / 2;
			
			container.y = _height - position;
		}
		
		override public function activateScreen():void
		{
			if (_isDisposed == true)
				return;
			
			super.activateScreen();
			
			if (walletSelected == true)
			{
				if (iAmount != null && iAmount.value != null && iAmount.value != "" && !isNaN(Number(iAmount.value)) && selectorCommodity != null && selectorCommodity.value != null)
				{
					acceptButton.activate();
					acceptButton.alpha = 1;
				}
			}
			
			if (backButton.visible)
			{
				backButton.activate();
			}
			
			if (selectorDebitAccont.visible)
			{
			//	selectorDebitAccont.activate();
			}
			
			useAllButton.activate();
			
			if (iAmount != null && iAmount.view.visible)
			{
				iAmount.activate();
				iAmountCurrency.activate();
			}
			
			if (selectorCommodity != null && selectorCommodity.visible)
			{
				selectorCommodity.activate();
			//	selectorCurrency.activate();
			}
		}
		
		override public function deactivateScreen():void
		{
			if (_isDisposed == true)
				return;
			
			super.deactivateScreen();
			
			acceptButton.deactivate();
			backButton.deactivate();
			useAllButton.deactivate();
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
			
			if (iconAttention != null)
			{
				UI.destroy(iconAttention);
				iconAttention = null;
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
			if (maxInvestments != null)
			{
				UI.destroy(maxInvestments);
				maxInvestments = null;
			}
			if (amountBack != null)
			{
				UI.destroy(amountBack);
				amountBack = null;
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
			if (useAllButton != null)
			{
				useAllButton.dispose();
				useAllButton = null;
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
			TweenMax.killDelayedCallsTo(startLoadRate);
			TweenMax.killDelayedCallsTo(loadRate);
			commodity = null;
			
			if (PayManager.S_ACCOUNT != null)
				PayManager.S_ACCOUNT.remove(onAccountInfo);
		}
	}
}