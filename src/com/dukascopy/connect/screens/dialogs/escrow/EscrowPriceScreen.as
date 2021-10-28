package com.dukascopy.connect.screens.dialogs.escrow {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.SelectorItemData;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.data.escrow.EscrowSettings;
	import com.dukascopy.connect.data.escrow.TradeDirection;
	import com.dukascopy.connect.gui.button.DDFieldButton;
	import com.dukascopy.connect.gui.components.radio.RadioGroup;
	import com.dukascopy.connect.gui.components.radio.RadioItem;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.renderers.ListPayCurrency;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.managers.escrow.vo.EscrowInstrument;
	import com.dukascopy.connect.managers.escrow.vo.EscrowPrice;
	import com.dukascopy.connect.screens.dialogs.paymentDialogs.elements.InputField;
	import com.dukascopy.connect.screens.dialogs.x.base.bottom.ListSelectionPopup;
	import com.dukascopy.connect.screens.dialogs.x.base.float.FloatPopup;
	import com.dukascopy.connect.screens.payments.card.TypeCurrency;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.payments.PayManager;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import com.dukascopy.connect.GD;
	
	/**
	 * ...
	 * @author Sergey Dobarin.
	 */

	public class EscrowPriceScreen extends FloatPopup {
		
		private var inputPrice:InputField;
		
		private var nextButton:BitmapButton;
		
		private var needCallback:Boolean;
		
		private var radio:RadioGroup;
		private var radioSelection:Vector.<SelectorItemData>;
		
		private var priceSelector:PriceSelector;
		private var controlPriceSelected:Sprite;
		private var selectedPrice:Number;
		private var dataLoaded:Boolean;
		private var currencySign:String;
		private var selectorCurrency:DDFieldButton;
		private var selectedCrypto:EscrowInstrument;
		private var selectedDirection:TradeDirection;
		private var titleText:Bitmap;
		private var headerHeight:Number;
		private var isPercent:Boolean;
		private var selectedPriceValue:Number;
		
		public function EscrowPriceScreen() { }
		
		override protected function createView():void {
			super.createView();
			
			createNextButton();
			createInputPrice();
			createRadio();
			createPriceSelector();
			createCurrencySelector();
			
			titleText = new Bitmap();
			container.addChild(titleText);
		}
		
		private function createPriceSelector():void 
		{
			priceSelector = new PriceSelector(onPriceChange);
			priceSelector.disableCurrencyChange();
		}
		
		private function onPriceChange(value:Number):void 
		{
			setPrice(value);
		}
		
		private function setPrice(value:Number):void 
		{
			selectedPrice = value;
			if (isNaN(selectedPrice))
			{
				selectedPrice = 0;
			}
		}
		
		private function getCurrency():String 
		{
			var result:String = "";
			if (currencySign != null)
			{
				if (currencySign == TypeCurrency.EUR)
				{
					result = "€";
				}
				else if (Lang[currencySign] != null && Lang[currencySign] != "")
				{
					result = Lang[currencySign];
				}
				else
				{
					result = currencySign;
				}
			}
			return result;
		}
		
		private function createRadio():void 
		{
			radio = new RadioGroup(onRadioSelection);
			addItem(radio);
		}
		
		private function onRadioSelection(value:SelectorItemData):void 
		{
			if (value != null && value.data != null && value.data is Function)
			{
				(value.data as Function)();
			}
		}
		
		private function createCurrencySelector():void 
		{
			selectorCurrency = new DDFieldButton(selectCurrencyTap, "", false, NaN, null, FontSize.AMOUNT);
			addItem(selectorCurrency);
		}
		
		private function callBackSelectCurrency(currency:String):void
		{
			if (currency != null)
			{
				currencySign = currency;
				selectorCurrency.setValue(currencySign);
				updatePrice();
				
				priceSelector.draw(getWidth() - contentPadding * 2, -5, 5, 0, selectedPrice, getCurrency());
			}
		}
		
		private function selectCurrencyTap():void 
		{
			if (selectedCrypto != null && selectedCrypto.price != null && selectedCrypto.price.length > 0)
			{
				var currencies:Array = new Array();
				for (var i:int = 0; i < selectedCrypto.price.length; i++) 
				{
					currencies.push(selectedCrypto.price[i].name);
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
			else
			{
				ApplicationErrors.add();
			}
		}
		
		private function onCurrencySelected(value:EscrowInstrument):void
		{
			if (isDisposed)
			{
				return;
			}
			priceSelector.draw(getWidth() - contentPadding * 2, -5, 5, 0, selectedPrice, getCurrency());
			updatePrice();
		}
		
		private function getInstrument():String
		{
			var result:String = "";
			if (selectedCrypto != null)
			{
				if (Lang[selectedCrypto.code] != null)
				{
					result = Lang[selectedCrypto.code];
				}
				else
				{
					result = selectedCrypto.code;
				}
			}
			return result;
		}
		
		private function activateStartState():void 
		{
			/*if (selectorCurrency != null)
			{
				selectorCurrency.activate();
			}*/
			if (nextButton != null)
			{
				nextButton.activate();
			}
			
			radio.activate();
			inputPrice.activate();
			priceSelector.activate();
		}
		
		private function deactivateStartState():void 
		{
			if (selectorCurrency != null)
			{
				selectorCurrency.deactivate();
			}
			if (nextButton != null)
			{
				nextButton.deactivate();
			}
			
			radio.deactivate();
			inputPrice.deactivate();
			priceSelector.deactivate();
		}
		
		override public function onBack(e:Event = null):void {
			close();
		}
		
		private function createNextButton():void 
		{
			nextButton = new BitmapButton();
			nextButton.setStandartButtonParams();
			nextButton.tapCallback = onNextClick;
			nextButton.disposeBitmapOnDestroy = true;
			nextButton.setDownScale(1);
			nextButton.setOverlay(HitZoneType.BUTTON);
			addItem(nextButton);
		}
		
		private function onNextClick():void 
		{

			var isFixed:Boolean=controlPriceSelected == inputPrice;
			// check price
			if(isFixed && !checkPriceValue(inputPrice.value)){
				GD.S_TOAST.invoke(Lang.escrow_invalidFixedPrice);
				dataValid=false;
				return;
			}

			var dataValid:Boolean = true;
			
			if (isNaN(selectedPrice) || selectedPrice == 0)
			{
				if (controlPriceSelected == inputPrice)
				{
					inputPrice.invalid();
				}
				dataValid = false;
			}
			
			


			if (dataValid)
			{
				if (controlPriceSelected == inputPrice)
				{
					selectedPriceValue = inputPrice.value;
				}
				else
				{
					isPercent = true;
					selectedPriceValue = priceSelector.getValue();
				}
				
				needCallback = true;
				close();
			}
		}
		
		private function createInputPrice():void 
		{
			var tf:TextFormat = new TextFormat();
			tf.size = FontSize.TITLE_2;
			tf.color = Style.color(Style.COLOR_TEXT);
			tf.font = Config.defaultFontName;
			
			inputPrice = new InputField( -1, Input.MODE_DIGIT_DECIMAL);
			inputPrice.onChangedFunction = onPriceInputChange;
			inputPrice.setPadding(0);
			inputPrice.updateTextFormat(tf);
			addItem(inputPrice);
		}
		
		private function onPriceInputChange():void{
			
			if(checkPriceValue(inputPrice.value)){;
				inputPrice.valid();
				setPrice(inputPrice.value);
			}else{
				inputPrice.invalid();
			}
		}

		private function checkPriceValue(val:Number):Boolean{
			var price:Number=getPrice();
			var min:Number=price*.95;
			var max:Number=price*1.05;
			return val>=min && val<=max;
		}
		
		override public function initScreen(data:Object = null):void {
			
			
			var titleWidth:int = (_width - contentPadding * 3 - mainPadding * 2 - closeButton.width);
			if (data != null && "title" in data && data.title != null)
			{
				titleText.bitmapData = TextUtils.createTextFieldData(data.title, titleWidth, 10, true, 
																	TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, 
																	FontSize.BODY, true, Style.color(Style.COLOR_TEXT),
																	Style.color(Style.COLOR_BACKGROUND), false);
			}
			
			if (data != null && "instrument" in data && data.instrument != null)
			{
				selectedCrypto = data.instrument as EscrowInstrument;
			}
			if (data != null && "direction" in data && data.direction != null)
			{
				selectedDirection = data.direction as TradeDirection;
			}
			
			currencySign = TypeCurrency.USD;
			if (data != null && "currency" in data && data.currency != null)
			{
				currencySign = data.currency as String;
			}
			selectCurrencyFromPrices();
			
			super.initScreen(data);
			
		//	updateScroll();
		//	recreateLayout();
		}
		
		private function selectCurrencyFromPrices():void 
		{
			if (selectedCrypto != null && selectedCrypto.price != null)
			{
				var preferredCurrency:String = TypeCurrency.USD;
				var exist:Boolean;
				for (var i:int = 0; i < selectedCrypto.price.length; i++) 
				{
					if (selectedCrypto.price[i].name == preferredCurrency)
					{
						exist = true;
						break;
					}
				}
				if (exist)
				{
					currencySign = preferredCurrency;
				}
				else
				{
					if (selectedCrypto.price.length > 0)
					{
						currencySign = selectedCrypto.price[0].name;
					}
					else
					{
						ApplicationErrors.add();
					}
				}
			}
			else
			{
				ApplicationErrors.add("selectedCrypto null");
			}
		}
		
		override protected function drawContent():void 
		{
			priceSelector.direction = selectedDirection;
			priceSelector.draw(getWidth() - contentPadding * 2, -5, 5, 0, selectedPrice, getCurrency());
			
			drawControls();
			showFixedPriceControl();
			onDataReady();
			updatePositions();
		}
		
		override protected function getBottomPadding():int 
		{
			var result:int = 0;
			if (nextButton != null)
			{
				result = nextButton.height + contentPadding * 2;
			}
			return result;
		}
		
		private function updatePositions():void 
		{
			headerHeight = Math.max(titleText.height, closeButton.height) + contentPaddingV * 2;
			
			titleText.x = int(getWidth() * .5 - titleText.width * .5);
			titleText.y = int(Math.max(contentPaddingV, headerHeight * .5 - titleText.height * .5));
			
			var position:int;
			
			position = Config.FINGER_SIZE * .3;
			
			radio.x = contentPadding;
			radio.y = position;
			position += radio.height + contentPaddingV;
			
			priceSelector.x = contentPadding;
			priceSelector.y = position;
			
			inputPrice.x = contentPadding;
			inputPrice.y = position;
			
			var inputWidth:int = getWidth() - contentPadding * 2;
			if (selectorCurrency != null)
			{
				inputWidth -= int(selectorCurrency.fullWidth + Config.FINGER_SIZE * .15);
				selectorCurrency.x = int(getWidth() - contentPadding - selectorCurrency.width);
				selectorCurrency.y = int(inputPrice.y + inputPrice.linePosition() - selectorCurrency.linePosition());
			}
			inputPrice.draw(inputWidth, Lang.pricePerCoin, inputPrice.value, inputPrice.getUnderlineValue());
			
			if (controlPriceSelected == inputPrice)
			{
				position += inputPrice.height + contentPaddingV * 1.5;
			}
			else
			{
				position += priceSelector.height + contentPaddingV * 1.5;
			}
			
			nextButton.x = contentPadding;
			nextButton.y = position;
			
			if (nextButton.y + nextButton.height + contentPadding + scrollPanel.view.y < backgroundContent.height && backgroundContent.height > 0)
			{
				nextButton.y = backgroundContent.height - nextButton.height - contentPadding - scrollPanel.view.y;
			}
		}
		
		private function drawControls():void
		{
			radioSelection = new Vector.<SelectorItemData>();
			radioSelection.push(new SelectorItemData(Lang.deviation_from_market, showDeviationControl));
			radioSelection.push(new SelectorItemData(Lang.fixed_price, showFixedPriceControl));
			radio.draw(radioSelection, getWidth() - contentPadding * 2, RadioItem);
			radio.select(radioSelection[1]);
			
			var textSettings:TextFieldSettings;
			var buttonBitmap:ImageBitmapData;
			if (nextButton != null)
			{
				textSettings = new TextFieldSettings(Lang.textNext.toUpperCase(), Style.color(Style.COLOR_TEXT), FontSize.BODY, TextFormatAlign.CENTER);
				buttonBitmap = TextUtils.createbutton(textSettings, Style.color(Style.COLOR_BACKGROUND), 1, -1, Style.color(Style.COLOR_BUTTON_OUTLINE), getButtonWidth(), Style.size(Style.BUTTON_PADDING), Style.size(Style.SIZE_BUTTON_CORNER));
				nextButton.setBitmapData(buttonBitmap, true);
			}
			
			var inputWidth:int = getWidth() - contentPadding * 2;
			if (selectorCurrency != null)
			{
				selectorCurrency.setSize(int(Config.FINGER_SIZE * 1.2), Config.FINGER_SIZE * 0.6);
				inputWidth -= int(selectorCurrency.fullWidth + Config.FINGER_SIZE * .15);
			}
			
			inputPrice.draw(inputWidth, Lang.pricePerCoin, 0);
		}
		
		public function onDataReady():void
		{
			if (priceSelector != null)
			{
				if (selectedCrypto != null)
				{
					setCurrencyInControls();
				}
				else
				{
					ApplicationErrors.add("selectedCrypto null");
				}
			}
			
			refreshPrice();
		}
		
		private function refreshPrice():void 
		{
			updatePrice();
			
			priceSelector.draw(getWidth() - contentPadding * 2, -5, 5, 0, selectedPrice, getCurrency());
			
			updatePositions();
		}
		
		private function setCurrencyInControls():void 
		{
			if (currencySign != null && selectorCurrency != null)
			{
				selectorCurrency.setValue(currencySign);
			}
			priceSelector.setPrices(currencySign, selectCurrencyTap);
		}
		
		/*private function selectCurrencyFromPrices():void 
		{
			if (selectedCrypto != null && selectedCrypto.price != null)
			{
				var preferredCurrency:String = TypeCurrency.USD;
				var exist:Boolean;
				for (var i:int = 0; i < selectedCrypto.price.length; i++) 
				{
					if (selectedCrypto.price[i].name == preferredCurrency)
					{
						exist = true;
						break;
					}
				}
				if (exist)
				{
					currencySign = preferredCurrency;
				}
				else
				{
					if (selectedCrypto.price.length > 0)
					{
						currencySign = selectedCrypto.price[0].name;
					}
					else
					{
						ApplicationErrors.add();
					}
				}
			}
			else
			{
				ApplicationErrors.add("selectedCrypto null");
			}
		}*/
		
		private function updatePrice():void 
		{
			var price:Number = getPrice();
			if (!isNaN(price))
			{
				setPrice(price);
				inputPrice.value = selectedPrice;
				
				var underlineText:String = Lang.current_price_of_instrument.replace(Lang.regExtValue, getInstrument()) + " = " + price + " " + getCurrency();
				inputPrice.drawUnderlineValue(underlineText);
			}
		}
		
		private function getPrice():Number 
		{
			var price:Number;
			if (selectedCrypto != null && selectedCrypto.price != null)
			{
				if (selectedDirection == TradeDirection.buy)
				{
					for (var i:int = 0; i < selectedCrypto.price.length; i++) 
					{
						if (selectedCrypto.price[i].name == currencySign)
						{
							price = selectedCrypto.price[i].value;
							break;
						}
					}
					if (isNaN(price))
					{
						for (var j:int = 0; j < selectedCrypto.price.length; j++) 
						{
							if (currencySign == null && selectedCrypto.price[j].name == TypeCurrency.USD)
							{
								currencySign = TypeCurrency.USD;
								price = selectedCrypto.price[j].value;
							}
						}
						if (isNaN(price) && selectedCrypto.price.length > 0)
						{
							currencySign = selectedCrypto.price[0].name;
							price = selectedCrypto.price[0].value;
						}
					}
				}
				else if (selectedDirection == TradeDirection.sell)
				{
					if (currencySign != null)
					{
						var selectedPrice:EscrowPrice;
						for (var k:int = 0; k < selectedCrypto.price.length; k++) 
						{
							if (selectedCrypto.price[k].name == currencySign)
							{
								selectedPrice = selectedCrypto.price[k];
								break;
							}
						}
						if (selectedPrice != null)
						{
							price = selectedPrice.value;
						}
						else
						{
							ApplicationErrors.add();
						}
					}
				}
			}
			
			return price;
		}
		
		private function selectCrypto(escrowInstrument:EscrowInstrument):void 
		{
			//!TODO: подписаться на смену прайса?
			selectedCrypto = escrowInstrument;
		}
		
		private function showFixedPriceControl():void 
		{
			controlPriceSelected = inputPrice;
			setPrice(inputPrice.value);
			if (selectorCurrency != null)
			{
				addItem(selectorCurrency);
			}
			updatePositions();
			
			removeItem(priceSelector);
			addItem(inputPrice);
			makePositions();
		}
		
		private function showDeviationControl():void 
		{
			controlPriceSelected = priceSelector;
			if (!isNaN(priceSelector.getPrice()))
			{
				setPrice(priceSelector.getPrice());
			}
			if (selectorCurrency != null)
			{
				removeItem(selectorCurrency);
			}
			updatePositions();
			
			removeItem(inputPrice);
			addItem(priceSelector);
			makePositions();
		}
		
		private function getButtonWidth():int 
		{
			return getWidth() - contentPadding * 2;
		}
		
		override protected function updateContentPositions():void 
		{
			updatePositions();
		}
		
		override protected function drawView():void {
			if (_isDisposed == true)
				return;
			
			scrollBottom.y = scrollPanel.itemsHeight + Config.APPLE_BOTTOM_OFFSET + Config.FINGER_SIZE * .3;
			super.drawView();
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			if (_isDisposed) {
				return;
			}
			
			activateStartState();
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed) {
				return;
			}
			
			deactivateStartState();
		}
		
		override protected function onRemove():void 
		{
			if (needCallback == true)
			{
				needCallback = false;
				if (data != null && "callback" in data && data.callback != null && data.callback is Function && (data.callback as Function).length == 3)
				{
					(data.callback as Function)(selectedPriceValue, isPercent, currencySign);
				}
			}
		}
		
		override public function dispose():void {
			super.dispose();
			
			if (inputPrice != null)
			{
				inputPrice.dispose();
				inputPrice = null;
			}
			if (titleText != null)
			{
				UI.destroy(titleText);
				titleText = null;
			}
			if (nextButton != null)
			{
				nextButton.dispose();
				nextButton = null;
			}
			if (radio != null)
			{
				radio.dispose();
				radio = null;
			}
			if (inputPrice != null)
			{
				inputPrice.dispose();
				inputPrice = null;
			}
			if (priceSelector != null)
			{
				priceSelector.dispose();
				priceSelector = null;
			}
			if (selectorCurrency != null)
			{
				selectorCurrency.dispose();
				selectorCurrency = null;
			}
			
			selectedCrypto = null;
			radioSelection = null;
		}
	}
}