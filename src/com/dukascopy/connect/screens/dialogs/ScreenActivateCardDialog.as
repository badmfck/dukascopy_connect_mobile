package com.dukascopy.connect.screens.dialogs {
	import com.adobe.utils.StringUtil;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import flash.display.Bitmap;

	/**
	 * ...
	 * @author Aleksei L
	 */
	
	public class ScreenActivateCardDialog extends ScreenAlertDialog {
		private var passInput:Input;
		private var inputBottom:Bitmap;
		
		private var cardData:Object;
		
		public function ScreenActivateCardDialog() {
			super();
		}
		
		override protected function createView():void {
			super.createView();
			
			passInput = new Input(Input.MODE_DIGIT);
			passInput.setMode(Input.MODE_DIGIT);
			passInput.setBorderVisibility(false);
			passInput.setRoundBG(false);
			passInput.getTextField().textColor = Style.color(Style.COLOR_TEXT);
			passInput.setRoundRectangleRadius(0);
			passInput.setLabelText("XXXX"/*Lang.textAmount*/);
			passInput.inUse = true;
			
			var hLineBitmapData:ImageBitmapData = UI.getHorizontalLine(2);
			inputBottom = new Bitmap(hLineBitmapData);
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			if ("cardData" in data) {
				cardData = data["cardData"];
			}
			
			if ("btnsCount" in data) {
				btnsCount = data["btnsCount"];
			}
		}
		
		private function focusOnInput():void {
			passInput.setFocus();
			passInput.getTextField().requestSoftKeyboard();
		}
		
		override protected function fireCallbackFunctionWithValue(value:int):void {
			var callBackFunction:Function = callback;
			callback = null;
			if (data != null && "additional" in data){
				callBackFunction(value, passInput.value, data.additional );
			}else{
				callBackFunction(value, passInput.value);
			}
			
		}
		
		override protected function getMaxContentHeight():Number {
			return _height - vPadding * 2 - title.trueHeight - buttonsAreaHeight;
		}
		
		override protected function drawView():void {
			super.drawView();			
			onChangeInputValue();	
		}
		
		override protected function repositionButtons():void {
			contentBottomPadding = 0;
			super.repositionButtons();
		}
		
		override protected function updateScrollArea():void {
			if (!content.fitInScrollArea()) {
				content.scrollToPosition(passInput.view.y - Config.MARGIN);
				content.enable();
			}
			else {
				content.disable();
			}
			
			content.update();
		}
		
		override protected function recreateContent(padding:Number):void {
			super.recreateContent(padding);
			var posY:int;	
			posY =  int(content.itemsHeight + padding * .5);
			passInput.width = _width - (padding * 2 );
			passInput.view.y = posY;
			content.addObject(passInput.view);
			
			inputBottom.width = _width - padding * 2;
			content.addObject(inputBottom);
			//
			posY = passInput.view.y + passInput.view.height;
			inputBottom.y = posY;
			posY = inputBottom.y + inputBottom.height;
		}
		
		private function onChangeInputValue():void {
			if (passInput != null) {
				var currentValue:String = StringUtil.trim(passInput.value);
				var defValue:String = passInput.getDefValue();
				if (currentValue != "" && currentValue != passInput.getDefValue()) {
					// activate button
					//btn0TF.alpha = 1;
					button0.activate();
					button0.alpha = 1;
				} else {
					button0.alpha = .7;
					button0.deactivate();
				}
			}
		}
		
		override protected function updateContentHeight():void {
			contentHeight = (vPadding * 3 * 1.3 + title.trueHeight + buttonsAreaHeight + content.itemsHeight);
		}
		
		override public function activateScreen():void {
			passInput.activate();
			super.activateScreen();
			
			if (passInput.value && passInput.value != "" && passInput.value != passInput.getDefValue()) {
				button0.alpha = 1;
				button0.activate();
			}
			else {
				button0.alpha = 0.7;
				button0.deactivate();
			}
			
			passInput.S_CHANGED.add(onChangeInputValue);
			
			focusOnInput();
		}
		
		override public function deactivateScreen():void {
			passInput.deactivate();
			super.deactivateScreen();
			
			passInput.S_CHANGED.add(onChangeInputValue);
		}
		
		override protected function btn0Clicked():void {
			if (callback != null) {
				fireCallbackFunctionWithValue(1);
			}
			passInput.setLabelText("");
			DialogManager.closeDialog();
		}
		
		override protected function onCloseButtonClick():void {
			if (callback != null) {
				fireCallbackFunctionWithValue(0);
			}
			passInput.setLabelText("");
			DialogManager.closeDialog();
		}
		
		override public function dispose():void {
			super.dispose();	
			
			if (passInput) {
				passInput.S_CHANGED.remove(onChangeInputValue);
				passInput.dispose();
				passInput = null;
			}
			
			UI.destroy(inputBottom);
			inputBottom = null;
		}
	}
}