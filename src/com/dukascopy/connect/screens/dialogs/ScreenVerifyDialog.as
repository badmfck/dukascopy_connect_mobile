package com.dukascopy.connect.screens.dialogs {
	import com.adobe.utils.StringUtil;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.tabs.FilterTabs;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;


	/**
	 * ...
	 * @author Aleksei L
	 */

	public class ScreenVerifyDialog extends ScreenAlertDialog {
		private var passInput:Input;
		private var inputBottom:Bitmap;

		private var currencyBitmap:Bitmap;
		private var account:Object;
		private var tabs:FilterTabs;
		private var arrTab:Array = [Lang.textAmount,Lang.textCode];
		private var arrValues:Array = ["amount","code"];

		public function ScreenVerifyDialog() {
			super();
		}


		override protected function createView():void {
			super.createView();

			tabs = new FilterTabs();
			tabs.activate();
			if (tabs != null) {
				if (tabs.S_ITEM_SELECTED != null)
					tabs.S_ITEM_SELECTED.add(onTabItemSelected);
			}
			currencyBitmap = new Bitmap();
			passInput = new Input(Input.MODE_DIGIT_DECIMAL);
			passInput.setMode(Input.MODE_DIGIT_DECIMAL);
			passInput.setBorderVisibility(false);
			passInput.setRoundBG(false);
			passInput.getTextField().textColor = Style.color(Style.COLOR_TEXT);
			passInput.setRoundRectangleRadius(0);
			passInput.setLabelText(Lang.textAmount);//default state
			passInput.inUse = true;

			var hLineBitmapData:ImageBitmapData = UI.getHorizontalLine(2);
			inputBottom = new Bitmap(hLineBitmapData);
		}

		private function onTabItemSelected(id:String):void {
			//var index:int = id == "card"?1:0;
			if(tabs.indexSelected == 0){
				content.addObject(currencyBitmap)
			} else{
				content.removeObject(currencyBitmap);
			}
			passInput.value = "";
			passInput.setLabelText(id);
//			focusOnInput();
		}

		private function focusOnInput():void {
			passInput.setFocus();
			passInput.getTextField().requestSoftKeyboard();
		}

		override public function initScreen(data:Object = null):void {

			super.initScreen(data);
			if ("account" in data) {
				account = data.account;
			}
			if ("btnsCount" in data) {
				btnsCount = data["btnsCount"];
			}
		}

		private function callbackTouchID(secret:String = ""):void {
			passInput.value = secret;
			btn0Clicked();
		}

		override protected function fireCallbackFunctionWithValue(value:int):void {
			var callBackFunction:Function = callback;
			callback = null;
			if ("additional" in data.account)
				callBackFunction(value, passInput.value,arrValues[tabs.indexSelected], data.account.additional);
			else
				callBackFunction(value, passInput.value, arrValues[tabs.indexSelected]);
		}

		override protected function getMaxContentHeight():Number {
			return _height - padding * 2 - headerHeight - buttonsAreaHeight;
		}

		override protected function drawView():void {
			super.drawView();
			// todo add check for valid input
			onChangeInputValue();
			//button0.alpha = 0.7;
			//button0.deactivate();
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
			//
			posY = 0;// int(/*content.itemsHeight*/ + padding * .5);

			tabs.add(arrTab[0], arrTab[0], true, FilterTabs.LEFT);
			tabs.add(arrTab[1], arrTab[1], false, FilterTabs.RIGHT);
			//tabs.setBackgroundColor(PaymentsScreen.bgColor);
			tabs.setWidthAndHeight(_width - padding * 2, Config.FINGER_SIZE * .85);
			tabs.view.y = posY;
			tabs.view.x = Config.MARGIN * .25;
			content.addObject(tabs.view);
			//
			currencyBitmap.bitmapData = UI.renderTextShadowed((account != null && "ccy" in account)? account.ccy:" ", 1, Config.FINGER_SIZE, false, false, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .30, false, 0xffffff, 0x000000, AppTheme.GREY_MEDIUM, true, 1, false);

			posY = tabs.view.y + tabs.view.height + padding * .5;
			passInput.width = _width - (padding * 2 + currencyBitmap.width);
			passInput.view.y = posY;
			currencyBitmap.y = posY + (passInput.view.height - currencyBitmap.height)*.5;
			currencyBitmap.x = passInput.view.x + passInput.width;
			content.addObject(passInput.view);
			if(tabs.indexSelected == 0){
				content.addObject(currencyBitmap);
			}else{
				content.removeObject(currencyBitmap);
			}

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
			contentHeight = (padding * 3 * 1.3 + headerHeight + buttonsAreaHeight + content.itemsHeight);
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
				passInput.dispose();
				passInput = null;
			}
			if (inputBottom) {
				UI.destroy(inputBottom);
				inputBottom = null;
			}
			if (tabs != null) {
				tabs.dispose();
				tabs = null;
			}
			UI.destroy(currencyBitmap);
			currencyBitmap = null;
		}
	}
}