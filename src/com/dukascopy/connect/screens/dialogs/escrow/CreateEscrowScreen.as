package com.dukascopy.connect.screens.dialogs.escrow {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.GD;
	import com.dukascopy.connect.data.SelectorItemData;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.data.escrow.EscrowDealData;
	import com.dukascopy.connect.data.escrow.TradeDirection;
	import com.dukascopy.connect.gui.button.DDFieldButton;
	import com.dukascopy.connect.gui.components.radio.RadioGroup;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.renderers.ListCryptoWallet;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.managers.escrow.EscrowDealManager;
	import com.dukascopy.connect.managers.escrow.EscrowInstrument;
	import com.dukascopy.connect.screens.dialogs.paymentDialogs.elements.InputField;
	import com.dukascopy.connect.screens.dialogs.x.base.bottom.ListSelectionPopup;
	import com.dukascopy.connect.screens.dialogs.x.base.bottom.ScrollAnimatedTitlePopup;
	import com.dukascopy.connect.screens.payments.card.TypeCurrency;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin.
	 */

	public class CreateEscrowScreen extends ScrollAnimatedTitlePopup {
		
		private const STATE_START:String = "STATE_START";
		private const STATE_REGISTER:String = "STATE_REGISTER";
		
		private var inputAmount:InputField;
		private var inputPrice:InputField;
		
		private var nextButton:BitmapButton;
		
		private var needCallback:Boolean;
		private var dealDetails:EscrowDealData;
		
		private var selectorCurrency:DDFieldButton;
		private var selectedCrypto:EscrowInstrument;
		private var radio:RadioGroup;
		private var radioSelection:Vector.<SelectorItemData>;
		private var registerBlock:Sprite;
		private var registerDescriprtion:Bitmap;
		private var registerButton:BitmapButton;
		
		private var state:String = STATE_START;
		private var registerDescriptionClip:Sprite;
		private var priceSelector:PriceSelector;
		private var controlPriceSelected:Sprite;
		private var selectedDirection:TradeDirection;
		private var balance:BalanceCalculation;
		private var selectedPrice:Number;
		private var dataLoaded:Boolean;
		private var instruments:Vector.<EscrowInstrument>;
		private var currencySign:String;
		
		public function CreateEscrowScreen() { }
		
		override protected function createView():void {
			super.createView();
			
			createNextButton();
			createInputAmount();
			createInputPrice();
			createCurrencySelector();
			createRadio();
			createPriceSelector();
		}
		
		private function createBalance():void 
		{
			var balanceTexts:Vector.<String> = new Vector.<String>();
			var colors:Vector.<Number> = new Vector.<Number>();
			if (selectedDirection == TradeDirection.buy)
			{
				balanceTexts.push(Lang.to_pay_for_crypto);
				balanceTexts.push(Lang.refundable_fee);
				balanceTexts.push(Lang.amount_to_be_debited);
				
				colors.push(Style.color(Style.COLOR_SUBTITLE));
				colors.push(Style.color(Style.COLOR_SUBTITLE));
				colors.push(Color.RED);
			}
			else
			{
				balanceTexts.push(Lang.to_get_for_crypto);
				balanceTexts.push(Lang.commission_crypto);
				balanceTexts.push(Lang.amount_to_be_credited);
				
				colors.push(Style.color(Style.COLOR_SUBTITLE));
				colors.push(Style.color(Style.COLOR_SUBTITLE));
				colors.push(Color.GREEN);
			}
			
			balance = new BalanceCalculation(balanceTexts, colors);
			addItem(balance);
		}
		
		private function createPriceSelector():void 
		{
			priceSelector = new PriceSelector(onPriceChange);
		}
		
		private function onPriceChange(value:Number):void 
		{
			selectedPrice = value;
			updateBalance();
		}
		
		private function updateBalance():void 
		{
			//!TODO:fee;
			
			var values:Vector.<String> = new Vector.<String>();
			var currency:String = getCurrency();
			if (selectedDirection == TradeDirection.buy)
			{
				values.push((getAmount() * selectedPrice).toFixed(2) + " " + currency);
				values.push((getAmount() * selectedPrice * .3).toFixed(2) + " " + currency);
				values.push((getAmount() * selectedPrice * .3 + getAmount() * selectedPrice).toFixed(2) + " " + currency);
			}
			else
			{
				values.push((getAmount() * selectedPrice).toFixed(2) + " " + currency);
				values.push((getAmount() * selectedPrice * .3).toFixed(2) + " " + currency);
				values.push((getAmount() * selectedPrice - getAmount() * selectedPrice * .3).toFixed(2) + " " + currency);
			}
			
			balance.draw(_width, values);
			
			updatePositions();
			updateScroll();
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
				else if (Lang[currencySign] != null)
				{
					result = Lang[currencySign];
				}
			}
			return result;
		}
		
		private function getAmount():Number
		{
			if (!isNaN(inputAmount.value))
			{
				return inputAmount.value;
			}
			return 0;
		}
		
		
		private function createRegisterBlockchainClips():void 
		{
			if (registerBlock == null)
			{
				registerBlock = new Sprite();
				
				registerDescriptionClip = new Sprite();
				registerBlock.addChild(registerDescriptionClip);
				
				registerDescriprtion = new Bitmap();
				registerDescriptionClip.addChild(registerDescriprtion);
				
				registerButton = new BitmapButton();
				registerButton.setStandartButtonParams();
				registerButton.tapCallback = onRegisterClick;
				registerButton.disposeBitmapOnDestroy = true;
				registerButton.setDownScale(1);
				registerButton.setOverlay(HitZoneType.BUTTON);
				registerBlock.addChild(registerButton);
			}
			container.addChild(registerBlock);
		}
		
		private function onRegisterClick():void 
		{
			//!TODO:;
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
			selectorCurrency = new DDFieldButton(selectCurrencyTap, "", true, NaN, Lang.crypto);
			addItem(selectorCurrency);
		}
		
		private function selectCurrencyTap():void 
		{
			var currencies:Vector.<EscrowInstrument> = getCurrencies();
			if (currencies != null && currencies.length > 0)
			{
				DialogManager.showDialog(
					ListSelectionPopup,
					{
						items:currencies,
						title:Lang.selectCurrency,
						renderer:ListCryptoWallet,
						callback:onCurrencySelected
					},
					DialogManager.TYPE_SCREEN
				);
			}
		}
		
		private function onCurrencySelected(value:EscrowInstrument):void
		{
			if (isDisposed)
			{
				return;
			}
			selectedCrypto = value;
			selectedPrice = selectedCrypto.price;
			inputPrice.value = selectedPrice;
			selectorCurrency.setValueExtend(selectedCrypto.name, selectedCrypto, getIcon(selectedCrypto));
			
			if (!selectedCrypto.isLinked && state != STATE_REGISTER)
			{
				toState(STATE_REGISTER);
			}
			else if (selectedCrypto.isLinked && state != STATE_START)
			{
				toState(STATE_START);
			}
			updateBalance();
		}
		
		private function getIcon(instrument:EscrowInstrument):Sprite 
		{
			return UI.getInvestIconByInstrument(instrument.code);
		}
		
		private function toState(newState:String):void 
		{
			if (state != newState)
			{
				hideCurrentState();
				state = newState;
				
				if (state == STATE_REGISTER)
				{
					createRegisterBlockchainClips();
					drawRegisterBlock();
					activateRegisterClips();
				}
				else if (state == STATE_START)
				{
					addItem(radio);
					addItem(inputAmount);
					addItem(balance);
					if (controlPriceSelected == priceSelector)
					{
						addItem(priceSelector);
					}
					else
					{
						addItem(inputPrice);
					}
					
					container.addChild(nextButton);
					activateStartState();
				}
				
				updateScrollSize();
				updatePositions();
			}
		}
		
		private function activateStartState():void 
		{
			radio.activate();
			nextButton.activate();
			inputAmount.activate();
			inputPrice.activate();
			priceSelector.activate();
		}
		
		private function activateRegisterClips():void 
		{
			if (registerBlock != null)
			{
				if (registerDescriptionClip != null)
				{
					PointerManager.addTap(registerDescriptionClip, openRegisterLink);
				}
				if (registerButton != null)
				{
					registerButton.activate();
				}
			}
		}
		
		private function deactivateRegisterClips():void 
		{
			if (registerBlock != null)
			{
				if (registerDescriptionClip != null)
				{
					PointerManager.removeTap(registerDescriptionClip, openRegisterLink);
				}
				if (registerButton != null)
				{
					registerButton.deactivate();
				}
			}
		}
		
		private function openRegisterLink(e:Event):void 
		{
			navigateToURL(new URLRequest(Lang.declare_blockchain_description_url));
		}
		
		private function drawRegisterBlock():void 
		{
			if (registerDescriprtion.bitmapData != null)
			{
				registerDescriprtion.bitmapData.dispose();
				registerDescriprtion.bitmapData = null;
			}
			registerDescriprtion.bitmapData = TextUtils.createTextFieldData(Lang.declare_blockchain, _width - contentPadding * 2, 10, true,
																	TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
																	FontSize.SUBHEAD, true, Style.color(Style.COLOR_SUBTITLE),
																	Style.color(Style.COLOR_BACKGROUND), false, true);
			var textSettings:TextFieldSettings = new TextFieldSettings(Lang.textRegister.toUpperCase(), Style.color(Style.COLOR_BACKGROUND), FontSize.BODY, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, Style.color(Style.COLOR_BUTTON_ACCENT), 1, -1, NaN, getButtonWidth(), Style.size(Style.BUTTON_PADDING), Style.size(Style.SIZE_BUTTON_CORNER));
			registerButton.setBitmapData(buttonBitmap, true);
			
			var position:int = contentPaddingV;
			
			registerDescriptionClip.x = contentPadding;
			registerDescriptionClip.y = position;
			position += registerDescriptionClip.height + contentPaddingV * 2;
			
			registerButton.x = contentPadding;
			registerButton.y = position;
			position += registerButton.height + contentPaddingV + Config.APPLE_BOTTOM_OFFSET;
			
			registerBlock.graphics.clear();
			registerBlock.graphics.beginFill(Style.color(Style.BOTTOM_BAR_COLOR));
			registerBlock.graphics.drawRect(0, 0, _width, position);
			registerBlock.graphics.endFill();
			
			registerBlock.y = int(getHeight() - registerBlock.height);
		}
		
		private function hideCurrentState():void 
		{
			if (state == STATE_START)
			{
				if (container.contains(nextButton))
				{
					container.removeChild(nextButton);
				}
				else
				{
					ApplicationErrors.add();
				}
				
				removeItem(radio);
				removeItem(inputAmount);
				removeItem(inputPrice);
				removeItem(priceSelector);
				removeItem(balance);
				deactivateStartState();
			}
			else if (state == STATE_REGISTER)
			{
				if (container.contains(registerBlock))
				{
					container.removeChild(registerBlock);
				}
				else
				{
					ApplicationErrors.add();
				}
				
				deactivateRegisterClips();
			}
		}
		
		private function deactivateStartState():void 
		{
			radio.deactivate();
			nextButton.deactivate();
			inputAmount.deactivate();
			inputPrice.deactivate();
			priceSelector.deactivate();
		}
		
		private function onCancelClick():void 
		{
			onBack();
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
			container.addChild(nextButton);
		}
		
		private function onNextClick():void 
		{
			if (dataValid())
			{
				needCallback = true;
				
				dealDetails = new EscrowDealData();
				dealDetails.price = inputPrice.value;
				dealDetails.amount = inputAmount.value;
				
				close();
			}
		}
		
		private function dataValid():Boolean 
		{
			//!TODO:;
			
			// state?
			// prices?
			return true;
		}
		
		private function createInputAmount():void 
		{
			var tf:TextFormat = new TextFormat();
			tf.size = FontSize.TITLE_2;
			tf.color = Style.color(Style.COLOR_TEXT);
			tf.font = Config.defaultFontName;
			
			inputAmount = new InputField( -1, Input.MODE_DIGIT_DECIMAL);
			inputAmount.onChangedFunction = onAmountChange;
			inputAmount.setPadding(0);
			inputAmount.updateTextFormat(tf);
			addItem(inputAmount);
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
		
		private function onPriceInputChange():void 
		{
			selectedPrice = inputPrice.value;
			updateBalance();
		}
		
		private function onAmountChange():void 
		{
			updateBalance();
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			currencySign = TypeCurrency.EUR;
			
			if (data != null && "selectedDirection" in data && data.selectedDirection != null)
			{
				selectedDirection = data.selectedDirection as TradeDirection;
			}
			priceSelector.direction = selectedDirection;
			
			drawControls();
			createBalance();
			showDeviationControl();
			updatePositions();
			updateScroll();
			
			loadData();
		}
		
		private function loadData():void 
		{
			dataLoaded = false;
			showPreloader();
			GD.S_ESCROW_INSTRUMENTS.add(instrumentsLoaded);
			GD.S_ESCROW_INSTRUMENTS_REQUEST.invoke();
		}
		
		private function instrumentsLoaded(instruments:Vector.<EscrowInstrument>):void 
		{
			dataLoaded = true;
			hidePreloader();
			this.instruments = instruments;
			onDataReady();
		}
		
		private function getCurrencies():Vector.<EscrowInstrument> 
		{
			return instruments;
		}
		
		override protected function getBottomPadding():int 
		{
			var result:int = 0;
			if (state == STATE_START)
			{
				result = nextButton.height + contentPadding * 2;
			}
			else if (state == STATE_REGISTER)
			{
				if (registerBlock != null)
				{
					result = registerBlock.height;
				}
				else
				{
					ApplicationErrors.add();
				}
			}
			return result;
		}
		
		private function updatePositions():void 
		{
			var position:int;
			
			if (state == STATE_START)
			{
				position = Config.FINGER_SIZE * .2;
				
				selectorCurrency.x = contentPadding;
				selectorCurrency.y = position;
				position += selectorCurrency.height + contentPaddingV;
				
				inputAmount.x = contentPadding;
				inputAmount.y = position;
				position += inputAmount.height + contentPaddingV;
				
				radio.x = contentPadding;
				radio.y = position;
				position += radio.height + contentPaddingV;
				
				priceSelector.x = contentPadding;
				priceSelector.y = position;
				
				inputPrice.x = contentPadding;
				inputPrice.y = position;
				
				if (controlPriceSelected == inputPrice)
				{
					position += inputPrice.height + contentPaddingV;
				}
				else
				{
					position += priceSelector.height + contentPaddingV;
				}
				
				balance.x = int(_width * .5 - balance.width * .5);
				balance.y = position;
				
				if (getHeight() - nextButton.height - contentPadding - balance.height - scrollPanel.view.y - contentPaddingV > position)
				{
					balance.y = getHeight() - nextButton.height - contentPadding - balance.height - scrollPanel.view.y - contentPaddingV;
				}
				
				nextButton.x = contentPadding;
				nextButton.y = int(getHeight() - nextButton.height - contentPadding);
			}
			else if (state == STATE_REGISTER)
			{
				position = Config.FINGER_SIZE * .2;
				
				selectorCurrency.x = contentPadding;
				selectorCurrency.y = position;
				position += selectorCurrency.height + contentPaddingV;
			}
		}
		
		private function drawControls():void
		{
			radioSelection = new Vector.<SelectorItemData>();
			radioSelection.push(new SelectorItemData(Lang.deviation_from_market, showDeviationControl));
			radioSelection.push(new SelectorItemData(Lang.fixed_price, showFixedPriceControl));
			radio.draw(radioSelection, _width);
			radio.select(radioSelection[0]);
			
			selectorCurrency.setSize(_width - contentPadding * 2, Config.FINGER_SIZE * 1.0);
			
			var textSettings:TextFieldSettings = new TextFieldSettings(Lang.textNext.toUpperCase(), Style.color(Style.COLOR_TEXT), FontSize.BODY, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, Style.color(Style.COLOR_BACKGROUND), 1, -1, Style.color(Style.COLOR_BUTTON_OUTLINE), getButtonWidth(), Style.size(Style.BUTTON_PADDING), Style.size(Style.SIZE_BUTTON_CORNER));
			nextButton.setBitmapData(buttonBitmap, true);
			
			inputAmount.draw(_width - contentPadding * 2, Lang.textAmount, 0);
			inputPrice.draw(_width - contentPadding * 2, Lang.pricePerCoin, 0);
		}
		
		public function onDataReady():void
		{
			var currencies:Vector.<EscrowInstrument> = getCurrencies();
			if (currencies != null && currencies.length > 0)
			{
				selectedCrypto = currencies[0];
				selectorCurrency.setValueExtend(selectedCrypto.name, selectedCrypto, getIcon(selectedCrypto));
			}
			selectedPrice = selectedCrypto.price;
			inputPrice.value = selectedPrice;
			
			if (state == STATE_START)
			{
				priceSelector.draw(_width - contentPadding * 2, -5, 5, 0, selectedPrice, TypeCurrency.EUR);
			}
			updateBalance();
			updatePositions();
		}
		
		private function showFixedPriceControl():void 
		{
			controlPriceSelected = inputPrice;
			selectedPrice = inputPrice.value;
			updateBalance();
			removeItem(priceSelector);
			addItem(inputPrice);
		}
		
		private function showDeviationControl():void 
		{
			controlPriceSelected = priceSelector;
			if (!isNaN(priceSelector.getPrice()))
			{
				selectedPrice = priceSelector.getPrice();
				updateBalance();
			}
			
			removeItem(inputPrice);
			addItem(priceSelector);
		}
		
		private function getButtonWidth():int 
		{
			return _width - contentPadding * 2;
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
			
			if (state == STATE_START)
			{
				activateStartState();
			}
			else if (state == STATE_REGISTER)
			{
				activateRegisterClips();
			}
			
			selectorCurrency.activate();
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed) {
				return;
			}
			
			if (state == STATE_START)
			{
				deactivateStartState();
			}
			else if (state == STATE_REGISTER)
			{
				deactivateRegisterClips();
			}
			
			selectorCurrency.deactivate();
		}
		
		override protected function onRemove():void 
		{
			if (needCallback == true)
			{
				needCallback = false;
				if (data != null && "callback" in data && data.callback != null && data.callback is Function && (data.callback as Function).length == 1 && dealDetails != null)
				{
					(data.callback as Function)(dealDetails);
				}
			}
		}
		
		override public function dispose():void {
			super.dispose();
			
			GD.S_ESCROW_INSTRUMENTS.remove(instrumentsLoaded);
			
			if (selectorCurrency != null)
			{
				selectorCurrency.dispose();
				selectorCurrency = null;
			}
			if (inputAmount != null)
			{
				inputAmount.dispose();
				inputAmount = null;
			}
			if (inputPrice != null)
			{
				inputPrice.dispose();
				inputPrice = null;
			}
			if (nextButton != null)
			{
				nextButton.dispose();
				nextButton = null;
			}
			if (selectorCurrency != null)
			{
				selectorCurrency.dispose();
				selectorCurrency = null;
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
			if (registerButton != null)
			{
				registerButton.dispose();
				registerButton = null;
			}
			if (registerDescriprtion != null)
			{
				UI.destroy(registerDescriprtion);
				registerDescriprtion = null;
			}
			if (registerBlock != null)
			{
				UI.destroy(registerBlock);
				registerBlock = null;
			}
			if (priceSelector != null)
			{
				priceSelector.dispose();
				priceSelector = null;
			}
			if (registerDescriptionClip != null)
			{
				UI.destroy(registerDescriptionClip);
				registerDescriptionClip = null;
			}
			if (balance != null)
			{
				balance.dispose();
				balance = null;
			}
			
			dealDetails = null;
			selectedCrypto = null;
			radioSelection = null;
		}
	}
}