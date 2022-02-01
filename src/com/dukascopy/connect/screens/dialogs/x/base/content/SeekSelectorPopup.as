package com.dukascopy.connect.screens.dialogs.x.base.content {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.gui.components.seekbar.Seekbar;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.screens.dialogs.paymentDialogs.elements.InputField;
	import com.dukascopy.connect.screens.dialogs.x.base.float.FloatPopup;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin.
	 */

	public class SeekSelectorPopup extends FloatPopup {
		
		private var inputField:InputField;
		private var nextButton:BitmapButton;
		private var titleText:Bitmap;
		private var headerHeight:Number;
		private var seekBar:Seekbar;
		private var decimal:int = 0;
		private var minText:Bitmap;
		private var maxText:Bitmap;
		
		private var needCallback:Boolean;
		private var currentValue:Number = 0;
		private var minValue:Number = 0;
		private var maxValue:Number = 1;
		private var selectedValue:Number;
		private var currency:String;
		private var currencyText:Bitmap;
		
		public function SeekSelectorPopup() { }
		
		override protected function createView():void {
			super.createView();
			
			createNextButton();
			
			currencyText = new Bitmap();
			addItem(currencyText);
			
			createInputPrice();
			
			titleText = new Bitmap();
			container.addChild(titleText);
			
			seekBar = new Seekbar(onValueChange);
			seekBar.hideColors = true;
			addItem(seekBar);
			
			minText = new Bitmap();
			addItem(minText);
			
			maxText = new Bitmap();
			addItem(maxText);
		}
		
		private function onValueChange(value:Number):void 
		{
			inputField.value = Number(value.toFixed(decimal));
			updateCurrencyTextPosition();
		}
		
		private function onPriceChange(value:Number):void 
		{
			if (isValid())
			{
				inputField.valid();
			}
			else
			{
				inputField.invalid();
			}
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
			if (isValid())
			{
				needCallback = true;
				selectedValue = inputField.value;
				close();
			}
		}
		
		private function isValid():Boolean 
		{
			if (inputField != null)
			{
				var value:Number = inputField.value;
				if (value >= minValue && value <= maxValue)
				{
					return true;
				}
			}
			return false;
		}
		
		private function createInputPrice():void 
		{
			var tf:TextFormat = new TextFormat();
			tf.size = FontSize.TITLE_1;
			tf.align = TextFormatAlign.CENTER;
			tf.color = Style.color(Style.COLOR_KEYBOARD_TEXT);
			tf.font = Config.defaultFontName;
			
			inputField = new InputField( -1, Input.MODE_DIGIT_DECIMAL);
			inputField.backgroundAlpha = 0;
			inputField.onChangedFunction = onPriceInputChange;
			inputField.setPadding(0);
			inputField.underlineColor = Style.color(Style.COLOR_BACKGROUND);
			inputField.updateTextFormat(tf);
			addItem(inputField);
		}
		
		private function onPriceInputChange():void{
			onPriceChange(inputField.value);
			updateCurrencyTextPosition();
			
			seekBar.setValue(inputField.value);
		}
		
		private function updateCurrencyTextPosition():void 
		{
			currencyText.y = int(inputField.y + inputField.textY + inputField.textAscent - currencyText.height);
			currencyText.x = int(inputField.x + inputField.width * .5 + inputField.getTextWidth() * 0.5 + Config.FINGER_SIZE * .2);
		}
		
		private function drawMinText():void
		{
			var value:String;
			if (data != null)
			{
				if ("minText" in data && data.minText != null)
				{
					value = data.minText;
				}
				else if (!isNaN(minValue))
				{
					value = minValue.toString();
				}
			}
			if (value != null)
			{
				minText.bitmapData = TextUtils.createTextFieldData(value, getWidth() - contentPadding * 2, 10, true,
																		TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
																		FontSize.SUBHEAD, true, Style.color(Style.COLOR_SUBTITLE),
																		Style.color(Style.COLOR_BACKGROUND));
			}
		}
		
		private function drawCurrencyText():void
		{
			if (currency != null)
			{
				currencyText.bitmapData = TextUtils.createTextFieldData(currency, getWidth() - contentPadding * 2, 10, true,
																		TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
																		FontSize.TITLE_1, true, Style.color(Style.COLOR_TEXT_DISABLE),
																		Style.color(Style.COLOR_BACKGROUND));
			}
		}
		
		private function drawMaxText():void
		{
			var value:String;
			if (data != null)
			{
				if ("maxText" in data && data.maxText != null)
				{
					value = data.maxText;
				}
				else if (!isNaN(minValue))
				{
					value = maxValue.toString();
				}
			}
			if (value != null)
			{
				maxText.bitmapData = TextUtils.createTextFieldData(value, getWidth() - contentPadding * 2, 10, true,
																		TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
																		FontSize.SUBHEAD, true, Style.color(Style.COLOR_SUBTITLE),
																		Style.color(Style.COLOR_BACKGROUND));
			}
		}
		
		override public function initScreen(data:Object = null):void {
			
			if (data != null)
			{
				if ("minValue" in data && !isNaN(Number(data.minValue)))
				{
					minValue = Number(data.minValue);
					currentValue = minValue;
				}
				
				if ("maxValue" in data && !isNaN(Number(data.maxValue)))
				{
					maxValue = Number(data.maxValue);
				}
				
				if ("decimal" in data && !isNaN(parseInt(data.decimal)))
				{
					decimal = Math.max(parseInt(data.decimal), 0);
					inputField.decimals = decimal;
				}
				
				if ("currency" in data && data.currency != null)
				{
					currency = data.currency;
				}
				
				if ("title" in data && data.title != null)
				{
					
					var titleWidth:int = (_width - contentPadding * 3 - mainPadding * 2 - closeButton.width);
					titleText.bitmapData = TextUtils.createTextFieldData(data.title, titleWidth, 10, true, 
																	TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, 
																	FontSize.BODY, true, Style.color(Style.COLOR_TEXT),
																	Style.color(Style.COLOR_BACKGROUND), false);
				}
			}
			
			if (!isNaN(currentValue))
			{
				inputField.value = currentValue;
			}
			
			super.initScreen(data);
		}
		
		override protected function drawContent():void 
		{
			drawControls();
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
			
			inputField.x = contentPadding;
			inputField.y = position;
			
			var inputWidth:int = getWidth() - contentPadding * 2;
			
			inputField.draw(inputWidth, null, inputField.value, null);
			position += inputField.getHeight() + contentPaddingV;
			
			seekBar.x = contentPadding;
			seekBar.y = position;
			position += seekBar.getHeight() + Config.FINGER_SIZE * .1;
			
			minText.x = contentPadding;
			minText.y = position;
			maxText.x = int(getWidth() - contentPadding - maxText.width);
			maxText.y = position;
			
			position += Math.max(minText.height, maxText.height) + contentPaddingV * 3.5;
			
			nextButton.x = contentPadding;
			nextButton.y = position;
			
			if (nextButton.y + nextButton.height + contentPadding + scrollPanel.view.y < backgroundContent.height && backgroundContent.height > 0)
			{
				nextButton.y = backgroundContent.height - nextButton.height - contentPadding - scrollPanel.view.y;
			}
			
			updateCurrencyTextPosition();
		}
		
		private function drawControls():void
		{
			drawMinText();
			drawMaxText();
			drawCurrencyText();
			drawNextButton();
			
			seekBar.draw(getWidth() - contentPadding * 2, minValue, maxValue, currentValue);
		}
		
		private function drawNextButton():void 
		{
			var textSettings:TextFieldSettings;
			var buttonBitmap:ImageBitmapData;
			if (nextButton != null)
			{
				var buttonText:String;
				if ("buttonText" in data && data.buttonText != null)
				{
					buttonText = data.buttonText;
				}
				else
				{
					buttonText = Lang.textNext.toUpperCase();
				}
				
				textSettings = new TextFieldSettings(buttonText, Style.color(Style.COLOR_TEXT), FontSize.BODY, TextFormatAlign.CENTER);
				buttonBitmap = TextUtils.createbutton(textSettings, Style.color(Style.COLOR_BACKGROUND), 1, -1, Style.color(Style.COLOR_BUTTON_OUTLINE), getButtonWidth(), Style.size(Style.BUTTON_PADDING), Style.size(Style.SIZE_BUTTON_CORNER));
				nextButton.setBitmapData(buttonBitmap, true);
			}
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
			nextButton.activate();
			seekBar.activate();
			inputField.activate();
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed) {
				return;
			}
			nextButton.deactivate();
			seekBar.deactivate();
			inputField.deactivate();
		}
		
		override protected function onRemove():void 
		{
			if (needCallback == true)
			{
				needCallback = false;
				if (data != null && "callback" in data && data.callback != null && data.callback is Function)
				{
					if ((data.callback as Function).length == 1)
					{
						(data.callback as Function)(selectedValue);
					}
					else if ((data.callback as Function).length == 2)
					{
						var callbackCustomData:Object;
						if ("data" in data)
						{
							callbackCustomData = data.data;
						}
						(data.callback as Function)(selectedValue, callbackCustomData);
					}
				}
			}
		}
		
		override public function dispose():void {
			super.dispose();
			
			if (inputField != null)
			{
				inputField.dispose();
				inputField = null;
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
			if (seekBar != null)
			{
				seekBar.dispose();
				seekBar = null;
			}
			if (minText != null)
			{
				UI.destroy(minText);
				minText = null;
			}
			if (maxText != null)
			{
				UI.destroy(maxText);
				maxText = null;
			}
			if (currencyText != null)
			{
				UI.destroy(currencyText);
				currencyText = null;
			}
		}
	}
}