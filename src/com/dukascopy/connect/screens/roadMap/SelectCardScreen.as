package com.dukascopy.connect.screens.roadMap {
	
	import assets.MastercardClip;
	import assets.VisaClip;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.scrollPanel.ScrollPanel;
	import com.dukascopy.connect.gui.topBar.TopBarScreen;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.payments.card.TypeCurrency;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.errors.ErrorLocalizer;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	import white.Currency_CHF;
	import white.Currency_EUR;
	import white.Currency_GBP;
	import white.Currency_USD;
	import white.Flag_CHF;
	import white.Flag_EUR;
	import white.Flag_GBP;
	import white.Flag_USD;
	
	/**
	 * @author Sergey Dobarin
	 */
	
	public class SelectCardScreen extends BaseScreen {
		static public const STATE_SELECT_DELIVERY:String = "stateSelectDelivery";
		static public const STATE_SELECT_TYPE:String = "stateSelectType";
		static public const STATE_SELECT_CURRENCY:String = "stateSelectCurrency";
		static public const DELIVERY_TYPE_STANDARD:String = "standard";
		static public const DELIVERY_TYPE_EXPRESS:String = "expedited";
		
		private var topBar:TopBarScreen;
		private var topHeight:int;
		private var card:CardClip;
		private var scroll:ScrollPanel;
		private var description:Bitmap;
		private var subtitle:Bitmap;
		private var mastercardType:SelectorClip;
		private var visaType:SelectorClip;
		private var selectedCardType:String;
		private var nextButton:BitmapButton;
		private var topClip:Sprite;
		private var bottomClip:Sprite;
		private var state:String = STATE_SELECT_TYPE;
		private var locked:Boolean = false;
		private var currency_CHF:SelectorClip;
		private var currency_EUR:SelectorClip;
		private var currency_USD:SelectorClip;
		private var currency_GBP:SelectorClip;
		private var selectedCardCurrency:String;
		private var commissionReceived:Boolean;
		private var lastCommissionCallID:String;
		private var amountCurrency:Bitmap;
		private var amountTitle:Bitmap;
		private var amountValue:Bitmap;
		
		private var virtualType:SelectorClip;
		private var plasticType:SelectorClip;
		private var selectedCardVirtualType:String;
		private var selectedCardDelivery:String = DELIVERY_TYPE_EXPRESS;
		private var delivery_standard:SelectorClip;
		private var delivery_express:SelectorClip;
			
		public function SelectCardScreen() {}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			topBar.setData(Lang.selectCard, true);
			
			card = new CardClip(_width);
			scroll.addObject(card);
			
			drawDescription(Lang.selectCardDescription);
			drawCardTypeSelector();
			drawNextButton();
			
			scroll.view.y = topBar.y + topBar.trueHeight;
			scroll.setWidthAndHeight(_width, _height - topBar.trueHeight);
			
			var position:int = 0;
			position += card.height;
			position += Config.FINGER_SIZE * .4;
			description.y = position;
			position += description.height + Config.FINGER_SIZE * .4;
			mastercardType.y = visaType.y = position;
			position += mastercardType.height + Config.FINGER_SIZE * .4;
			virtualType.y = plasticType.y = position;
			position += virtualType.height + Config.FINGER_SIZE * .4;
			
			nextButton.y = position;
			position += nextButton.height + Config.DIALOG_MARGIN + Config.APPLE_BOTTOM_OFFSET;
			bottomClip.y = position;
		}
		
		override public function onBack(e:Event = null):void
		{
			if (state == STATE_SELECT_TYPE)
			{
				super.onBack();
			}
			else if (state == STATE_SELECT_CURRENCY)
			{
				showTypeState();
			}
			else if (state == STATE_SELECT_DELIVERY)
			{
				showStateCurrency();
			}
		}
		
		private function showTypeState():void 
		{
			locked = true;
			TweenMax.to(scroll.view, 0.3, {alpha:0, onComplete:constructStateType});
			
			state = STATE_SELECT_TYPE;
		}
		
		private function constructStateType():void 
		{
			if (isDisposed == true)
			{
				return;
			}
			
			TweenMax.killTweensOf(amountTitle);
			TweenMax.killTweensOf(amountCurrency);
			TweenMax.killTweensOf(amountValue);
			
			removeSubtitle();
			removeCommission();
			removeCurrencySelector();
			
			drawDescription(Lang.selectCardDescription);
			drawCardTypeSelector();
			drawNextButton();
			
			var position:int = 0;
			position += card.height;
			position += Config.FINGER_SIZE * .4;
			description.y = position;
			position += description.height + Config.FINGER_SIZE * .4;
			mastercardType.y = visaType.y = position;
			position += mastercardType.height + Config.FINGER_SIZE * .4;
			virtualType.y = plasticType.y = position;
			position += mastercardType.height + Config.FINGER_SIZE * .4;
			
			nextButton.y = position;
			position += nextButton.height + Config.DIALOG_MARGIN + Config.APPLE_BOTTOM_OFFSET;
			bottomClip.y = position;
			
			drawNextButton();
			
			if (selectedCardType == CardClip.TYPE_MASTERCARD)
			{
				selectMastercard(true);
			}
			else if(selectedCardType == CardClip.TYPE_VISA)
			{
				selectVisa(true);
			}
			
			if (selectedCardVirtualType == CardClip.TYPE_PLASTIC)
			{
				selectPlastic(true);
			}
			else if(selectedCardVirtualType == CardClip.TYPE_VIRTUAL)
			{
				selectVirtual(true);
			}
			
			scroll.update();
			scroll.scrollToPosition(0);
			
			TweenMax.to(scroll.view, 0.3, {alpha:1, onComplete:constructStateTypeComplete});
		}
		
		private function removeSubtitle():void 
		{
			if (subtitle != null)
			{
				scroll.removeObject(subtitle);
				if (subtitle.bitmapData != null)
				{
					subtitle.bitmapData.dispose();
					subtitle.bitmapData = null;
				}
			}
		}
		
		private function removeCommission():void 
		{
			scroll.removeObject(amountTitle);
			scroll.removeObject(amountValue);
			scroll.removeObject(amountCurrency);
		}
		
		private function removeCurrencySelector():void 
		{
			if (currency_CHF != null)
			{
				scroll.removeObject(currency_CHF);
				currency_CHF.dispose();
				currency_CHF = null;
			}
			if (currency_EUR != null)
			{
				scroll.removeObject(currency_EUR);
				currency_EUR.dispose();
				currency_EUR = null;
			}
			if (currency_GBP != null)
			{
				scroll.removeObject(currency_GBP);
				currency_GBP.dispose();
				currency_GBP = null;
			}
			if (currency_USD != null)
			{
				scroll.removeObject(currency_USD);
				currency_USD.dispose();
				currency_USD = null;
			}
		}
		
		private function constructStateTypeComplete():void 
		{
			if (isDisposed == true)
			{
				return;
			}
			
			locked = false;
		}
		
		private function drawNextButton(active:Boolean = false):void 
		{
			if (nextButton == null)
			{
				nextButton = new BitmapButton();
				scroll.addObject(nextButton);
				nextButton.setDownScale(1);
				nextButton.setOverlay(HitZoneType.BUTTON);
				nextButton.setDownColor(NaN);
				nextButton.show();
				nextButton.tapCallback = onNextClick;
				
				scroll.addObject(nextButton);
				if (isActivated)
				{
					nextButton.activate();
				}
				nextButton.x = Config.DIALOG_MARGIN;
			}
			
			var textSettings:TextFieldSettings;
			var buttonBitmap:ImageBitmapData;
			if (active)
			{
				textSettings = new TextFieldSettings(Lang.BTN_NEXT_STEP.toUpperCase(), Color.WHITE, FontSize.BODY, TextFormatAlign.CENTER);
				buttonBitmap = TextUtils.createbutton(textSettings, Color.GREEN, 1, -1, NaN, _width - Config.DIALOG_MARGIN * 2, Config.FINGER_SIZE * .3, Style.size(Style.SIZE_BUTTON_CORNER));
			}
			else
			{
				textSettings = new TextFieldSettings(Lang.BTN_NEXT_STEP.toUpperCase(), Style.color(Style.FILTER_TABS_COLOR_TAB_BG_BORDER), FontSize.BODY, TextFormatAlign.CENTER);
				buttonBitmap = TextUtils.createbutton(textSettings, Style.color(Style.COLOR_BACKGROUND), 1, -1, Style.color(Style.FILTER_TABS_COLOR_TAB_BG_BORDER), _width - Config.DIALOG_MARGIN * 2, Config.FINGER_SIZE * .3, Style.size(Style.SIZE_BUTTON_CORNER));
			}
			nextButton.setBitmapData(buttonBitmap, true);
		}
		
		private function onNextClick():void 
		{
			if (locked == true)
			{
				return;
			}
			if (state == STATE_SELECT_TYPE)
			{
				if (selectedCardType != null && selectedCardVirtualType != null)
				{
					showStateCurrency();
				}
			}
			else if (state == STATE_SELECT_CURRENCY)
			{
				if (selectedCardCurrency != null)
				{
					if (selectedCardVirtualType == CardClip.TYPE_VIRTUAL)
					{
						selectedCardDelivery = DELIVERY_TYPE_STANDARD;
						processCardOrder();
					}
					else
					{
						showStateDelivery();
					}
				}
			}
			else if (state == STATE_SELECT_DELIVERY)
			{
				if (selectedCardDelivery != null)
				{
					processCardOrder();
				//	PHP.pay_issueCardGet(onCardSelectedData);
				}
			}
		}
		
		private function processCardOrder():void 
		{
			lock();
			var system:String = "VISA";
			if (selectedCardType == CardClip.TYPE_MASTERCARD)
			{
				system = "MC";
			}
			else if (selectedCardType == CardClip.TYPE_VISA)
			{
				system = "VISA";
			}
			
			var type:String = "virtual";
			if (selectedCardVirtualType == CardClip.TYPE_VIRTUAL)
			{
				type = "virtual";
			}
			else if (selectedCardVirtualType == CardClip.TYPE_PLASTIC)
			{
				type = "plastic";
			}
			
			PHP.call_statVI("saveCard", selectedCardCurrency + ", " + system + ", " + type + ", " + selectedCardDelivery);
			PHP.pay_issueCardStore(onCardSelected, selectedCardCurrency, system, type, selectedCardDelivery);
		}
		
		private function onCardSelectedData(respond:PHPRespond):void 
		{
			respond.dispose();
		}
		
		private function lock():void 
		{
			//!TODO:;
		}
		
		private function unlock():void 
		{
			//!TODO:;
		}
		
		private function onCardSelected(respond:PHPRespond):void 
		{
			if (isDisposed == true)
			{
				return;
			}
			unlock();
			if (respond.error == true)
			{
				ToastMessage.display(ErrorLocalizer.getText(respond.errorMsg));
			}
			else
			{
				MobileGui.showRoadMap();
			}
			respond.dispose();
		}
		
		private function showStateAddress():void 
		{
			locked = true;
			TweenMax.to(scroll.view, 0.3, {alpha:0, onComplete:constructStateAddress});
		}
		
		private function constructStateAddress():void 
		{
			if (isDisposed == true)
			{
				return;
			}
			
			TweenMax.killTweensOf(amountTitle);
			TweenMax.killTweensOf(amountCurrency);
			TweenMax.killTweensOf(amountValue);
			
			removeCurrencySelector();
			
			drawDescription(Lang.selectCardCurrency);
			drawAddress();
			
			scroll.update();
			scroll.scrollToPosition(0);
			
			drawNextButton();
			
			TweenMax.to(scroll.view, 0.3, {alpha:1, onComplete:constructStateAddressComplete});
		}
		
		private function drawAddress():void 
		{
	//		var realAddress:String =  PayManager.accountInfo.address + ", \n" + PayManager.accountInfo.city + " , " + PayManager.accountInfo.zip + " \n" + PayManager.accountInfo.country;
	//		var contactText:String = Lang.TEXT_HISTORY_CONTACT + "<a href='mailto:"+Lang.TEXT_HISTORY_CONTACT_EMAIL+"'> <font color='#000000'><u>"+Lang.TEXT_HISTORY_CONTACT_EMAIL+"</u></font></a>"+Lang.TEXT_HISTORY_CONTACT_PART_TWO;
		}
		
		private function constructStateAddressComplete():void 
		{
			locked = true;
		}
		
		private function showStateCurrency():void 
		{
			locked = true;
			TweenMax.to(scroll.view, 0.3, {alpha:0, onComplete:constructStateCurrency});
		}
		
		private function showStateDelivery():void 
		{
			locked = true;
			TweenMax.to(scroll.view, 0.3, {alpha:0, onComplete:constructStateDelivery});
		}
		
		private function constructStateCurrency():void 
		{
			if (isDisposed == true)
			{
				return;
			}
			
			TweenMax.killTweensOf(amountTitle);
			TweenMax.killTweensOf(amountCurrency);
			TweenMax.killTweensOf(amountValue);
			
			removeSubtitle();
			removeCommission();
			removeDeliverySelector();
			removeTypeSelector();
			drawCurrencySelector();
			drawDescription(Lang.selectCardCurrency);
			
			if (selectedCardVirtualType == CardClip.TYPE_VIRTUAL)
			{
				addCommissionLoader();
				drawamountTitle(Lang.cardChargeAmount);
				drawAmountCurrency(TypeCurrency.EUR);
				drawAmount("0.00");
			}
			
			var position:int = 0;
			position += card.height;
			position += Config.FINGER_SIZE * .4;
			description.y = position;
			position += description.height + Config.FINGER_SIZE * .4;
			currency_CHF.y = currency_EUR.y = position;
			position += currency_CHF.height + Config.FINGER_SIZE * .3;
			currency_USD.y = currency_GBP.y = position;
			position += currency_USD.height + Config.FINGER_SIZE * .6;
			
			if (selectedCardVirtualType == CardClip.TYPE_VIRTUAL)
			{
				amountTitle.x = int(_width * .5 - amountTitle.width * .5);
				amountTitle.y = position;
				position += amountTitle.height + Config.FINGER_SIZE * .23;
				amountCurrency.x = int(_width * .5 - (amountCurrency.width + amountValue.width + Config.FINGER_SIZE * .15) * .5);
				amountValue.x = int(amountCurrency.x + amountCurrency.width + Config.FINGER_SIZE * .15);
				amountCurrency.y = amountValue.y = position;
				position += Math.max(amountCurrency.height, amountValue.height) + Config.FINGER_SIZE * .7;
			}
			
			nextButton.y = position;
			position += nextButton.height + Config.DIALOG_MARGIN + Config.APPLE_BOTTOM_OFFSET;
			bottomClip.y = position;
			
			scroll.update();
			scroll.scrollToPosition(0);
			
			drawNextButton();
			
			if (selectedCardCurrency == TypeCurrency.CHF)
			{
				selectCurrency_CHF(true);
			}
			else if (selectedCardCurrency == TypeCurrency.EUR)
			{
				selectCurrency_EUR(true);
			}
			else if (selectedCardCurrency == TypeCurrency.USD)
			{
				selectCurrency_USD(true);
			}
			else if (selectedCardCurrency == TypeCurrency.GBP)
			{
				selectCurrency_GBP(true);
			}
			
			TweenMax.to(scroll.view, 0.3, {alpha:1, onComplete:constructStateCurrencyComplete});
		}
		
		private function constructStateDelivery():void 
		{
			if (isDisposed == true)
			{
				return;
			}
			
			state = STATE_SELECT_DELIVERY;
			
			removeCurrencySelector();
			drawDeliverySelector();
			drawDescription(Lang.selectCardDelivery);
			drawSubtitle(Lang.upsCardDeliveryDescription);
			
			addCommissionLoader();
			drawamountTitle(Lang.cardChargeAmount);
			drawAmountCurrency(TypeCurrency.EUR);
			drawAmount("0.00");
			
			var position:int = 0;
			position += card.height;
			position += Config.FINGER_SIZE * .4;
			description.y = position;
			position += description.height + Config.FINGER_SIZE * .3;
			subtitle.y = position;
			position += subtitle.height + Config.FINGER_SIZE * .4;
			delivery_express.y = position;
			position += delivery_express.height + Config.FINGER_SIZE * .3;
			delivery_standard.y = position;
			position += delivery_standard.height + Config.FINGER_SIZE * .6;
			
			amountTitle.x = int(_width * .5 - amountTitle.width * .5);
			amountTitle.y = position;
			position += amountTitle.height + Config.FINGER_SIZE * .23;
			amountCurrency.x = int(_width * .5 - (amountCurrency.width + amountValue.width + Config.FINGER_SIZE * .15) * .5);
			amountValue.x = int(amountCurrency.x + amountCurrency.width + Config.FINGER_SIZE * .15);
			amountCurrency.y = amountValue.y = position;
			position += Math.max(amountCurrency.height, amountValue.height) + Config.FINGER_SIZE * .7;
			
			nextButton.y = position;
			position += nextButton.height + Config.DIALOG_MARGIN + Config.APPLE_BOTTOM_OFFSET;
			bottomClip.y = position;
			
			scroll.update();
			scroll.scrollToPosition(0);
			
			drawNextButton();
			
			if (selectedCardDelivery == DELIVERY_TYPE_EXPRESS)
			{
				selectDeliveryExpress(true);
			}
			else if (selectedCardDelivery == DELIVERY_TYPE_STANDARD)
			{
				selectDeliveryStandard(true);
			}
			
			TweenMax.to(scroll.view, 0.3, {alpha:1, onComplete:constructStateDeliveryComplete});
		}
		
		private function addCommissionLoader():void 
		{
			
		}
		
		private function drawamountTitle(value:String):void 
		{
			scroll.addObject(amountTitle);
			
			if (amountTitle.bitmapData != null)
			{
				amountTitle.bitmapData.dispose();
				amountTitle.bitmapData = null;
			}
			amountTitle.bitmapData = TextUtils.createTextFieldData(value, _width - Config.DIALOG_MARGIN * 2, 10, 
																	true, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
																	Config.FINGER_SIZE * .26, true, Style.color(Style.COLOR_SUBTITLE), 
																	Style.color(Style.COLOR_BACKGROUND), true);
		}
		
		private function getCommission():void
		{
			clearCommission();	
			commissionReceived = false;
			
			lastCommissionCallID = (new Date().getTime()).toString();
			var system:String = "MC";
			if (selectedCardType == CardClip.TYPE_MASTERCARD)
			{
				system = "MC";
			}
			else{
				system = "VISA";
			}
			
			var type:String = "virtual";
			if (selectedCardVirtualType == CardClip.TYPE_VIRTUAL)
			{
				type = "virtual";
			}
			else{
				type = "plastic";
			}
			PHP.getCardComission(onCardComission, system, selectedCardCurrency, type, selectedCardDelivery);
		//	PayManager.callGetCardCommissionOpen(currency, system, "virtual", lastCommissionCallID);
		}
		
		private function onCardComission(respond:PHPRespond):void{

			if (isDisposed == true){
				respond.dispose();
				return;
			}

			if (state == STATE_SELECT_DELIVERY || (state == STATE_SELECT_CURRENCY && selectedCardVirtualType == CardClip.TYPE_VIRTUAL)){
				if (respond.error == true)
				{
					ToastMessage.display(ErrorLocalizer.getText(respond.errorMsg));
				}
				else
				{
					if (respond.data != null && "commission_amount" in respond.data && "commission_currency" in respond.data){
						drawAmountCurrency(respond.data.commission_currency);
						drawAmount(respond.data.commission_amount);
					}
				}
			}
			
			respond.dispose();
		}
		
		private function clearCommission():void 
		{
			if (amountTitle != null)
			{
				TweenMax.killTweensOf(amountTitle);
				amountTitle.alpha = 0;
			}
			if (amountValue != null)
			{
				TweenMax.killTweensOf(amountValue);
				amountValue.alpha = 0;
			}
			if (amountCurrency != null)
			{
				TweenMax.killTweensOf(amountCurrency);
				amountCurrency.alpha = 0;
			}
		}
		
		private function drawAmountCurrency(value:String):void 
		{
			scroll.addObject(amountCurrency);
			var clip:Sprite;
			switch(value)
			{
				case TypeCurrency.EUR:
				{
					clip = new Currency_EUR();
					break;
				}
				case TypeCurrency.USD:
				{
					clip = new Currency_USD();
					break;
				}
				case TypeCurrency.GBP:
				{
					clip = new Currency_GBP();
					break;
				}
				case TypeCurrency.CHF:
				{
					clip = new Currency_CHF();
					break;
				}
			}
			if (clip != null)
			{
				UI.colorize(clip, Style.color(Style.COLOR_TEXT));
				UI.scaleToFit(clip, Config.FINGER_SIZE * 2, int(Config.FINGER_SIZE * .3));
				if (amountCurrency.bitmapData != null)
				{
					amountCurrency.bitmapData.dispose();
					amountCurrency.bitmapData = null;
				}
				amountCurrency.bitmapData = UI.getSnapshot(clip);
				
				UI.destroy(clip);
				clip = null;
			}
			else
			{
				ApplicationErrors.add();
			}
		}
		
		private function drawAmount(value:String):void 
		{
			if (state == STATE_SELECT_DELIVERY || (state == STATE_SELECT_CURRENCY && selectedCardVirtualType == CardClip.TYPE_VIRTUAL))
			{
				scroll.addObject(amountValue);
				if (amountValue.bitmapData != null)
				{
					amountValue.bitmapData.dispose();
					amountValue.bitmapData = null;
				}
				amountValue.bitmapData = TextUtils.createTextFieldData(value, _width - Config.DIALOG_MARGIN*2, 10, 
																		true, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
																		Config.FINGER_SIZE * .5, true, Style.color(Style.COLOR_TEXT), Style.color(Style.COLOR_BACKGROUND), true);
				amountCurrency.x = int(_width * .5 - (amountCurrency.width + amountValue.width + Config.FINGER_SIZE * .15) * .5);
				amountValue.x = int(amountCurrency.x + amountCurrency.width + Config.FINGER_SIZE * .15);
				
				if (amountCurrency != null)
				{
					TweenMax.to(amountCurrency, 0.2, {alpha:1});
				}
				if (amountTitle != null)
				{
					TweenMax.to(amountTitle, 0.2, {alpha:1});
				}
				if (amountValue != null)
				{
					TweenMax.to(amountValue, 0.2, {alpha:1});
				}
			}
		}
		
		private function removeDeliverySelector():void 
		{
			if (delivery_express != null)
			{
				scroll.removeObject(delivery_express);
				delivery_express.dispose();
				delivery_express = null;
			}
			if (delivery_standard != null)
			{
				scroll.removeObject(delivery_standard);
				delivery_standard.dispose();
				delivery_standard = null;
			}
			if (plasticType != null)
			{
				scroll.removeObject(plasticType);
				plasticType.dispose();
				plasticType = null;
			}
		}
		
		private function removeTypeSelector():void 
		{
			if (mastercardType != null)
			{
				scroll.removeObject(mastercardType);
				mastercardType.dispose();
				mastercardType = null;
			}
			if (visaType != null)
			{
				scroll.removeObject(visaType);
				visaType.dispose();
				visaType = null;
			}
			if (plasticType != null)
			{
				scroll.removeObject(plasticType);
				plasticType.dispose();
				plasticType = null;
			}
			if (virtualType != null)
			{
				scroll.removeObject(virtualType);
				virtualType.dispose();
				virtualType = null;
			}
		}
		
		private function drawCurrencySelector():void 
		{
			state = STATE_SELECT_CURRENCY;
			
			var iconHeight:int = Config.FINGER_SIZE * .45;
			var itemHeight:int = Config.FINGER_SIZE * 1.1;
			var itemWidth:int = (_width - Config.DIALOG_MARGIN * 2 - Config.FINGER_SIZE * .4) * .5;
			
			var chf_icon:Sprite = new Flag_CHF();
			UI.scaleToFit(chf_icon, itemWidth, iconHeight);
			currency_CHF = new SelectorClip(chf_icon, TypeCurrency.CHF, itemWidth, itemHeight, selectCurrency_CHF);
			
			var eur_icon:Sprite = new Flag_EUR();
			UI.scaleToFit(eur_icon, itemWidth, iconHeight);
			currency_EUR = new SelectorClip(eur_icon, TypeCurrency.EUR, itemWidth, itemHeight, selectCurrency_EUR);
			
			var usd_icon:Sprite = new Flag_USD();
			UI.scaleToFit(usd_icon, itemWidth, iconHeight);
			currency_USD = new SelectorClip(usd_icon, TypeCurrency.USD, itemWidth, itemHeight, selectCurrency_USD);
			
			var gbp_icon:Sprite = new Flag_GBP();
			UI.scaleToFit(gbp_icon, itemWidth, iconHeight);
			currency_GBP = new SelectorClip(gbp_icon, TypeCurrency.GBP, itemWidth, itemHeight, selectCurrency_GBP);
			
			currency_CHF.x = currency_USD.x = Config.DIALOG_MARGIN;
			currency_EUR.x = currency_GBP.x = int(currency_CHF.x + currency_CHF.width + Config.FINGER_SIZE * .4);
			
			scroll.addObject(currency_CHF);
			scroll.addObject(currency_EUR);
			scroll.addObject(currency_USD);
			scroll.addObject(currency_GBP);
			
			if (isActivated)
			{
				currency_CHF.activate();
				currency_EUR.activate();
				currency_USD.activate();
				currency_GBP.activate();
			}
		}
		
		private function drawDeliverySelector():void 
		{
			var itemHeight:int = Config.FINGER_SIZE * 1.1;
		//	var itemWidth:int = (_width - Config.DIALOG_MARGIN * 2 - Config.FINGER_SIZE * .4) * .5;
			var itemWidth:int = _width - Config.DIALOG_MARGIN * 2;
			
			delivery_standard = new SelectorClip(null, Lang.cardDeliveryStandard, itemWidth, itemHeight, selectDeliveryStandard);
			delivery_express = new SelectorClip(null, Lang.cardDeliveryExpress, itemWidth, itemHeight, selectDeliveryExpress);
			
			delivery_standard.x = Config.DIALOG_MARGIN;
			delivery_express.x = Config.DIALOG_MARGIN;
			
			scroll.addObject(delivery_standard);
			scroll.addObject(delivery_express);
			
			if (isActivated)
			{
				delivery_standard.activate();
				delivery_express.activate();
			}
		}
		
		private function selectDeliveryExpress(ignoreLocked:Boolean = false):void 
		{
			if (locked == true && ignoreLocked == false)
			{
				return;
			}
			
			selectedCardDelivery = DELIVERY_TYPE_EXPRESS;
			delivery_express.select();
			delivery_standard.unselect();
			drawNextButton(true);
			
			getCommission();
			
			scroll.scrollToBottom();
		}
		
		private function selectDeliveryStandard(ignoreLocked:Boolean = false):void 
		{
			if (locked == true && ignoreLocked == false)
			{
				return;
			}
			
			selectedCardDelivery = DELIVERY_TYPE_STANDARD;
			delivery_express.unselect();
			delivery_standard.select();
			drawNextButton(true);
			
			getCommission();
			
			scroll.scrollToBottom();
		}
		
		private function selectCurrency_GBP(ignoreLocked:Boolean = false):void 
		{
			if (locked == true && ignoreLocked == false)
			{
				return;
			}
			
			selectedCardCurrency = TypeCurrency.GBP;
			currency_CHF.unselect();
			currency_EUR.unselect();
			currency_USD.unselect();
			currency_GBP.select();
			card.setCurrency(selectedCardCurrency);
			drawNextButton(true);
			
			if (selectedCardVirtualType == CardClip.TYPE_VIRTUAL)
			{
				getCommission();
			}
			
			scroll.scrollToBottom();
		}
		
		private function selectCurrency_USD(ignoreLocked:Boolean = false):void 
		{
			if (locked == true && ignoreLocked == false)
			{
				return;
			}
			
			selectedCardCurrency = TypeCurrency.USD;
			currency_CHF.unselect();
			currency_EUR.unselect();
			currency_USD.select();
			currency_GBP.unselect();
			card.setCurrency(selectedCardCurrency);
			drawNextButton(true);
			
			if (selectedCardVirtualType == CardClip.TYPE_VIRTUAL)
			{
				getCommission();
			}
			
			scroll.scrollToBottom();
		}
		
		private function selectCurrency_EUR(ignoreLocked:Boolean = false):void 
		{
			if (locked == true && ignoreLocked == false)
			{
				return;
			}
			
			selectedCardCurrency = TypeCurrency.EUR;
			currency_CHF.unselect();
			currency_EUR.select();
			currency_USD.unselect();
			currency_GBP.unselect();
			card.setCurrency(selectedCardCurrency);
			drawNextButton(true);
			
			if (selectedCardVirtualType == CardClip.TYPE_VIRTUAL)
			{
				getCommission();
			}
			
			scroll.scrollToBottom();
		}
		
		private function selectCurrency_CHF(ignoreLocked:Boolean = false):void 
		{
			if (locked == true && ignoreLocked == false)
			{
				return;
			}
			
			selectedCardCurrency = TypeCurrency.CHF;
			currency_CHF.select();
			currency_EUR.unselect();
			currency_USD.unselect();
			currency_GBP.unselect();
			card.setCurrency(selectedCardCurrency);
			drawNextButton(true);
			
			if (selectedCardVirtualType == CardClip.TYPE_VIRTUAL)
			{
				getCommission();
			}
			
			scroll.scrollToBottom();
		}
		
		private function constructStateCurrencyComplete():void 
		{
			if (isDisposed == true)
			{
				return;
			}
			
			locked = false;
		}
		
		private function constructStateDeliveryComplete():void 
		{
			if (isDisposed == true)
			{
				return;
			}
			
			locked = false;
		}
		
		private function drawCardTypeSelector():void 
		{
			var iconHeight:int = Config.FINGER_SIZE * .38;
			var itemHeight:int = Config.FINGER_SIZE * 1.35;
			var itemWidth:int = (_width - Config.DIALOG_MARGIN * 2 - Config.FINGER_SIZE * .4) * .5;
			
			var masterCardIcon:Sprite = new MastercardClip();
			UI.scaleToFit(masterCardIcon, itemWidth, iconHeight * 1.8);
			mastercardType = new SelectorClip(masterCardIcon, null, itemWidth, itemHeight, selectMastercard);
			
			var visaIcon:Sprite = new (Style.icon(Style.PAYMENT_VISA))();
			UI.scaleToFit(visaIcon, itemWidth, iconHeight);
			visaType = new SelectorClip(visaIcon, null, itemWidth, itemHeight, selectVisa);
			
			mastercardType.x = Config.DIALOG_MARGIN;
			visaType.x = int(mastercardType.x + mastercardType.width + Config.FINGER_SIZE * .4);
			
			scroll.addObject(mastercardType);
			scroll.addObject(visaType);
			
			virtualType = new SelectorClip(null, Lang.virtual, itemWidth, itemHeight, selectVirtual);
			plasticType = new SelectorClip(null, Lang.plastic, itemWidth, itemHeight, selectPlastic);
			
			virtualType.x = Config.DIALOG_MARGIN;
			plasticType.x = int(mastercardType.x + mastercardType.width + Config.FINGER_SIZE * .4);
			
			scroll.addObject(virtualType);
			scroll.addObject(plasticType);
			
			if (isActivated)
			{
				mastercardType.activate();
				visaType.activate();
				virtualType.activate();
				plasticType.activate();
			}
		}
		
		private function selectMastercard(ignoreLocked:Boolean = false):void 
		{
			if (locked == true && ignoreLocked == false)
			{
				return;
			}
			selectedCardType = CardClip.TYPE_MASTERCARD;
			mastercardType.select();
			visaType.unselect();
			card.setType(selectedCardType);
			drawNextButton(selectedCardVirtualType != null);
			
			if (ignoreLocked == false)
			{
				if (selectedCardVirtualType != null)
				{
					scroll.scrollToPosition(bottomClip.y, true);
				}
				else if(virtualType != null)
				{
					scroll.scrollToPosition(virtualType.y + virtualType.height + Config.FINGER_SIZE*.3, true);
				}
			}
		}
		
		private function selectVirtual(ignoreLocked:Boolean = false):void 
		{
			if (locked == true && ignoreLocked == false)
			{
				return;
			}
			selectedCardVirtualType = CardClip.TYPE_VIRTUAL;
			virtualType.select();
			plasticType.unselect();
			card.setVirtualType(selectedCardVirtualType);
			drawNextButton(selectedCardType != null);
			
			if (ignoreLocked == false)
			{
				scroll.scrollToPosition(bottomClip.y, true);
			}
		}
		
		private function selectPlastic(ignoreLocked:Boolean = false):void 
		{
			if (locked == true && ignoreLocked == false)
			{
				return;
			}
			selectedCardVirtualType = CardClip.TYPE_PLASTIC;
			virtualType.unselect();
			plasticType.select();
			card.setVirtualType(selectedCardVirtualType);
			drawNextButton(selectedCardType != null);
			
			if (ignoreLocked == false)
			{
				scroll.scrollToPosition(bottomClip.y, true);
			}
		}
		
		private function selectVisa(ignoreLocked:Boolean = false):void 
		{
			if (locked == true && ignoreLocked == false)
			{
				return;
			}
			selectedCardType = CardClip.TYPE_VISA;
			mastercardType.unselect();
			visaType.select();
			card.setType(selectedCardType);
			drawNextButton(selectedCardVirtualType != null);
			
			if (selectedCardVirtualType != null)
			{
				scroll.scrollToPosition(bottomClip.y, true);
			}
			else if(virtualType != null)
			{
				scroll.scrollToPosition(virtualType.y + virtualType.height + Config.FINGER_SIZE*.3, true);
			}
		}
		
		private function drawDescription(text:String):void 
		{
			if (description.bitmapData != null)
			{
				description.bitmapData.dispose();
				description.bitmapData = null;
			}
			
			description.bitmapData = TextUtils.createTextFieldData(text, _width - Config.DIALOG_MARGIN*2, 10, 
																	true, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
																	Config.FINGER_SIZE * .29, true, Style.color(Style.COLOR_TEXT), Style.color(Style.COLOR_BACKGROUND), true, true);
			description.x = Config.DIALOG_MARGIN;
		}
		
		private function drawSubtitle(text:String):void 
		{
			if (subtitle.bitmapData != null)
			{
				subtitle.bitmapData.dispose();
				subtitle.bitmapData = null;
			}
			scroll.addObject(subtitle);
			
			subtitle.bitmapData = TextUtils.createTextFieldData(text, _width - Config.DIALOG_MARGIN*2, 10, 
																	true, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
																	Config.FINGER_SIZE * .26, true, Style.color(Style.COLOR_SUBTITLE), Style.color(Style.COLOR_BACKGROUND), true, true);
			subtitle.x = Config.DIALOG_MARGIN;
		}
		
		override protected function createView():void {
			super.createView();
			topBar = new TopBarScreen();
			topHeight = topBar.trueHeight;
			_view.addChild(topBar);
			
			scroll = new ScrollPanel();
			view.addChild(scroll.view);
			
			description = new Bitmap();
			scroll.addObject(description);
			
			subtitle = new Bitmap();
		//	scroll.addObject(subtitle);
			
			topClip = new Sprite();
			bottomClip = new Sprite();
			
			topClip.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			topClip.graphics.drawRect(0, 0, 1, 1);
			topClip.graphics.endFill();
			
			bottomClip.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			bottomClip.graphics.drawRect(0, 0, 1, 1);
			bottomClip.graphics.endFill();
			
			scroll.addObject(topClip);
			scroll.addObject(bottomClip);
			
			amountCurrency = new Bitmap();
			amountTitle = new Bitmap();
			amountValue = new Bitmap();
		}
		
		override public function activateScreen():void {
			if (_isDisposed) return;
			super.activateScreen();
			if (topBar != null)
				topBar.activate();
			if (mastercardType != null)
			{
				mastercardType.activate();
			}
			if (visaType != null)
			{
				visaType.activate();
			}
			if (nextButton != null)
			{
				nextButton.activate();
			}
			if (currency_CHF != null)
			{
				currency_CHF.activate();
			}
			if (currency_EUR != null)
			{
				currency_EUR.activate();
			}
			if (currency_USD != null)
			{
				currency_USD.activate();
			}
			if (currency_GBP != null)
			{
				currency_GBP.activate();
			}
			if (plasticType != null)
			{
				plasticType.activate();
			}
			if (virtualType != null)
			{
				virtualType.activate();
			}
			
			scroll.enable();
		}
		
		override public function deactivateScreen():void {
			if (_isDisposed) return;
			super.deactivateScreen();
			if (topBar != null)
				topBar.deactivate();
			if (mastercardType != null)
			{
				mastercardType.deactivate();
			}
			if (visaType != null)
			{
				visaType.deactivate();
			}
			if (nextButton != null)
			{
				nextButton.deactivate();
			}
			if (currency_CHF != null)
			{
				currency_CHF.deactivate();
			}
			if (currency_EUR != null)
			{
				currency_EUR.deactivate();
			}
			if (currency_USD != null)
			{
				currency_USD.deactivate();
			}
			if (currency_GBP != null)
			{
				currency_GBP.deactivate();
			}
			if (plasticType != null)
			{
				plasticType.deactivate();
			}
			if (virtualType != null)
			{
				virtualType.deactivate();
			}
			
			scroll.disable();
		}
		
		override protected function drawView():void {
			if (_isDisposed) return;
			topBar.drawView(_width);
		}
		
		override public function dispose():void {
			if (_isDisposed) return;
			if (topBar != null)
				topBar.dispose();
			topBar = null;
			
			TweenMax.killTweensOf(amountTitle);
			TweenMax.killTweensOf(amountCurrency);
			TweenMax.killTweensOf(amountValue);
			
			if (scroll != null)
			{
				TweenMax.killTweensOf(scroll.view);
				scroll.dispose();
				scroll = null;
			}
			if (mastercardType != null)
			{
				mastercardType.dispose();
				mastercardType = null;
			}
			if (delivery_express != null)
			{
				delivery_express.dispose();
				delivery_express = null;
			}
			if (delivery_standard != null)
			{
				delivery_standard.dispose();
				delivery_standard = null;
			}
			if (visaType != null)
			{
				visaType.dispose();
				visaType = null;
			}
			if (currency_CHF != null)
			{
				currency_CHF.dispose();
				currency_CHF = null;
			}
			if (currency_EUR != null)
			{
				currency_EUR.dispose();
				currency_EUR = null;
			}
			if (currency_USD != null)
			{
				currency_USD.dispose();
				currency_USD = null;
			}
			if (currency_GBP != null)
			{
				currency_GBP.dispose();
				currency_GBP = null;
			}
			if (nextButton != null)
			{
				nextButton.dispose();
				nextButton = null;
			}
			if (card != null)
			{
				card.dispose();
				card = null;
			}
			if (amountValue != null)
			{
				UI.destroy(amountValue);
				amountValue = null;
			}
			if (subtitle != null)
			{
				UI.destroy(subtitle);
				subtitle = null;
			}
			if (description != null)
			{
				UI.destroy(description);
				description = null;
			}
			if (topClip != null)
			{
				UI.destroy(topClip);
				topClip = null;
			}
			if (bottomClip != null)
			{
				UI.destroy(bottomClip);
				bottomClip = null;
			}
			if (amountCurrency != null)
			{
				UI.destroy(amountCurrency);
				amountCurrency = null;
			}
			if (amountTitle != null)
			{
				UI.destroy(amountTitle);
				amountTitle = null;
			}
			if (virtualType != null)
			{
				virtualType.dispose();
				virtualType = null;
			}
			if (plasticType != null)
			{
				plasticType.dispose();
				plasticType = null;
			}
			
			_isDisposed = true;
			super.dispose();
		}
	}
}