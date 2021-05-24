package com.dukascopy.connect.screens.dialogs {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.data.escrow.EscrowDealData;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.screens.dialogs.bottom.ScrollAnimatedTitlePopup;
	import com.dukascopy.connect.screens.dialogs.paymentDialogs.elements.InputField;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
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
		private var cancelButton:BitmapButton;
		
		private var needCallback:Boolean;
		private var dealDetails:EscrowDealData;
		
		public function CreateEscrowScreen() { }
		
		override protected function createView():void {
			super.createView();
			
			createCancelButton();
			createNextButton();
			createInputAmount();
			createInputPrice();
		}
		
		private function createCancelButton():void 
		{
			cancelButton = new BitmapButton();
			cancelButton.setStandartButtonParams();
			cancelButton.tapCallback = onCancelClick;
			cancelButton.disposeBitmapOnDestroy = true;
			cancelButton.setDownScale(1);
			cancelButton.setOverlay(HitZoneType.BUTTON);
			container.addChild(cancelButton);
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
			tf.size = FontSize.BODY;
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
			updatePositions();
			
			updateScroll();
		}
		
		override protected function getBottomPadding():int 
		{
			return nextButton.height + Config.DIALOG_MARGIN * 2;
		}
		
		private function updatePositions():void 
		{
			inputAmount.x = contentPadding;
			inputPrice.x = contentPadding;
			
			var position:int = Config.FINGER_SIZE * .2;
			
			inputAmount.y = position;
			position += inputAmount.height + contentPaddingV;
			
			inputPrice.y = position;
			position += inputPrice.height + contentPaddingV;
			
			cancelButton.x = Config.DIALOG_MARGIN;
			nextButton.x = int(_width - Config.DIALOG_MARGIN - nextButton.width);
			
			cancelButton.y = int(getHeight() - cancelButton.height - Config.DIALOG_MARGIN);
			nextButton.y = int(getHeight() - cancelButton.height - Config.DIALOG_MARGIN);
		}
		
		private function drawControls():void
		{
			var textSettings:TextFieldSettings = new TextFieldSettings(Lang.create, Color.WHITE, FontSize.BODY, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, Color.GREEN, 1, -1, NaN, getButtonWidth(), -1, Style.size(Style.SIZE_BUTTON_CORNER));
			nextButton.setBitmapData(buttonBitmap, true);
			
			textSettings = new TextFieldSettings(Lang.textCancel, Style.color(Style.COLOR_TEXT), FontSize.BODY, TextFormatAlign.CENTER);
			buttonBitmap = TextUtils.createbutton(textSettings, Style.color(Style.COLOR_BACKGROUND), 1, -1, Style.color(Style.COLOR_LINE_SSL), getButtonWidth(), -1, Style.size(Style.SIZE_BUTTON_CORNER));
			cancelButton.setBitmapData(buttonBitmap, true);
			
			inputAmount.draw(_width - contentPadding * 2, Lang.textAmount, 0);
			inputPrice.draw(_width - contentPadding * 2, Lang.pricePerCoin, 0);
		}
		
		private function getButtonWidth():int 
		{
			return (_width - Config.DIALOG_MARGIN * 3) * .5;
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
			cancelButton.activate();
			inputAmount.activate();
			inputPrice.activate();
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed) {
				return;
			}
			
			nextButton.deactivate();
			cancelButton.deactivate();
			inputAmount.deactivate();
			inputPrice.deactivate();
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
			
			
		}
	}
}