package com.dukascopy.connect.screens.dialogs.escrow {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.SelectorItemData;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.data.escrow.CryptoWalletData;
	import com.dukascopy.connect.data.escrow.CryptoWalletStatus;
	import com.dukascopy.connect.data.escrow.EscrowDealData;
	import com.dukascopy.connect.gui.button.DDFieldButton;
	import com.dukascopy.connect.gui.components.radio.RadioGroup;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.list.renderers.ListCryptoWallet;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.screens.dialogs.paymentDialogs.elements.InputField;
	import com.dukascopy.connect.screens.dialogs.x.base.bottom.ListSelectionPopup;
	import com.dukascopy.connect.screens.dialogs.x.base.bottom.ScrollAnimatedTitlePopup;
	import com.dukascopy.connect.screens.payments.card.TypeCurrency;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import flash.events.Event;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin.
	 */

	public class CreateEscrowScreen extends ScrollAnimatedTitlePopup {
		
		private var inputAmount:InputField;
		private var inputPrice:InputField;
		
		private var nextButton:BitmapButton;
		
		private var needCallback:Boolean;
		private var dealDetails:EscrowDealData;
		
		private var selectorCurrency:DDFieldButton;
		private var selectedCrypto:CryptoWalletData;
		private var radio:RadioGroup;
		private var radioSelection:Vector.<SelectorItemData>;
		
		public function CreateEscrowScreen() { }
		
		override protected function createView():void {
			super.createView();
			
			createNextButton();
			createInputAmount();
			createInputPrice();
			createCurrencySelector();
			createRadio();
		}
		
		private function createRadio():void 
		{
			radio = new RadioGroup();
			addItem(radio);
		}
		
		private function createCurrencySelector():void 
		{
			selectorCurrency = new DDFieldButton(selectCurrencyTap, "", true, NaN, Lang.crypto);
			addItem(selectorCurrency);
		}
		
		private function selectCurrencyTap():void 
		{
			var currencies:Vector.<CryptoWalletData> = getCurrencies();
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
		
		private function onCurrencySelected(value:CryptoWalletData):void
		{
			if (isDisposed)
			{
				return;
			}
			selectedCrypto = value;
			selectorCurrency.setValueExtend(selectedCrypto.title, selectedCrypto, selectedCrypto.getIcon());
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
			tf.size = FontSize.BODY;
			tf.color = Style.color(Style.COLOR_TEXT);
			tf.font = Config.defaultFontName;
			
			inputPrice = new InputField( -1, Input.MODE_DIGIT_DECIMAL);
			inputPrice.onChangedFunction = onAmountChange;
			inputPrice.setPadding(0);
			inputPrice.updateTextFormat(tf);
			addItem(inputPrice);
		}
		
		private function onAmountChange():void 
		{
			//TODO:;
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			drawControls();
			
			var currencies:Vector.<CryptoWalletData> = getCurrencies();
			if (currencies != null && currencies.length > 0)
			{
				selectedCrypto = currencies[0];
				selectorCurrency.setValueExtend(selectedCrypto.title, selectedCrypto, selectedCrypto.getIcon());
			}
			
			updatePositions();
			
			updateScroll();
		}
		
		private function getCurrencies():Vector.<CryptoWalletData> 
		{
			var result:Vector.<CryptoWalletData> = new Vector.<CryptoWalletData>();
			
			result.push(new CryptoWalletData(TypeCurrency.DCO, "fg545hfyfkjgf5675ghjgh65ар7nmqgh390gxf345d", CryptoWalletStatus.ready));
			result.push(new CryptoWalletData(TypeCurrency.ETH, null, CryptoWalletStatus.linkageRequired));
			
			return result;
		}
		
		override protected function getBottomPadding():int 
		{
			return nextButton.height + contentPadding * 2;
		}
		
		private function updatePositions():void 
		{
			inputAmount.x = contentPadding;
			inputPrice.x = contentPadding;
			selectorCurrency.x = contentPadding;
			
			var position:int = Config.FINGER_SIZE * .2;
			
			selectorCurrency.y = position;
			position += selectorCurrency.height + contentPaddingV;
			
			inputAmount.y = position;
			position += inputAmount.height + contentPaddingV;
			
			inputPrice.y = position;
			position += inputPrice.height + contentPaddingV;
			
			nextButton.x = contentPadding;
			nextButton.y = int(getHeight() - nextButton.height - contentPadding);
		}
		
		private function drawControls():void
		{
			radioSelection = new Vector.<SelectorItemData>();
			radioSelection.push(new SelectorItemData(Lang.deviation_from_market, showDeviationControl));
			radioSelection.push(new SelectorItemData(Lang.fixed_price, showFixedPriceControl));
			radio.draw(radioSelection, _width);
			
			selectorCurrency.setSize(_width - contentPadding * 2, Config.FINGER_SIZE * 1.0);
			
			var textSettings:TextFieldSettings = new TextFieldSettings(Lang.textNext.toUpperCase(), Style.color(Style.COLOR_TEXT), FontSize.BODY, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, Style.color(Style.COLOR_BACKGROUND), 1, -1, Style.color(Style.COLOR_BUTTON_OUTLINE), getButtonWidth(), Style.size(Style.BUTTON_PADDING), Style.size(Style.SIZE_BUTTON_CORNER));
			nextButton.setBitmapData(buttonBitmap, true);
			
			inputAmount.draw(_width - contentPadding * 2, Lang.textAmount, 0);
			inputPrice.draw(_width - contentPadding * 2, Lang.pricePerCoin, 0);
		}
		
		private function showFixedPriceControl():void 
		{
			
		}
		
		private function showDeviationControl():void 
		{
			
		}
		
		private function getButtonWidth():int 
		{
			return _width - contentPadding * 2;
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
			
			nextButton.activate();
			inputAmount.activate();
			inputPrice.activate();
			selectorCurrency.activate();
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed) {
				return;
			}
			
			nextButton.deactivate();
			inputAmount.deactivate();
			inputPrice.deactivate();
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
			dealDetails = null;
		}
	}
}