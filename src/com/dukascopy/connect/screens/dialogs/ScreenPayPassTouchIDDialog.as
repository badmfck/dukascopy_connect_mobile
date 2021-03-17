package com.dukascopy.connect.screens.dialogs {

	import com.adobe.utils.StringUtil;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;


	/**
	 * ...
	 * @author Sergey Dobarin
	 */

	public class ScreenPayPassTouchIDDialog extends ScreenAlertDialog {

		protected var passInput:Input;
		private var inputBottom:Bitmap;
		private var forgotPassButton:BitmapButton;
//		protected var showForgotPass:Boolean = true;
		protected var showPass:Boolean = true;

		public function ScreenPayPassTouchIDDialog() {
			super();
		}

		override protected function createView():void {
			super.createView();
			showPass = false;
			passInput = new Input();
			passInput.setMode(Input.MODE_PASSWORD);
			passInput.setLabelText(Lang.enterPassword);
			passInput.setBorderVisibility(false);
			passInput.setRoundBG(false);
			passInput.getTextField().textColor = Style.color(Style.COLOR_TEXT);
			passInput.setRoundRectangleRadius(0);
			passInput.inUse = true;

			var hLineBitmapData:ImageBitmapData = UI.getHorizontalLine(2);
			inputBottom = new Bitmap(hLineBitmapData);
//			if (showForgotPass) {
				forgotPassButton = new BitmapButton();
				forgotPassButton.setStandartButtonParams();
				forgotPassButton.setDownScale(1);
				forgotPassButton.setDownColor(0xFFFFFF);
				forgotPassButton.tapCallback = btn2Clicked;
				forgotPassButton.disposeBitmapOnDestroy = true;
				forgotPassButton.usePreventOnDown = false;
				forgotPassButton.cancelOnVerticalMovement = true;
				forgotPassButton.setOverflow(Config.FINGER_SIZE * .33, Config.FINGER_SIZE * .33, Config.FINGER_SIZE * .33, Config.FINGER_SIZE * .33);
				forgotPassButton.hide();
//			}
		}

		override protected function btn2Clicked():void {
			/*showPass = !showPass;
			if (showPass) {
				passInput.setMode(Input.MODE_PASSWORD);
			} else {
				passInput.setMode(Input.MODE_INPUT);
			}
			passInput.value = passInput.value;*/
		}

		private function focusOnInput():void {
			passInput.setFocus();
			passInput.getTextField().requestSoftKeyboard();
		}

		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			if ("btnsCount" in data)
				btnsCount = data["btnsCount"];
		}

		private function callbackTouchID(secret:String = ""):void {
			passInput.value = secret;
			btn0Clicked();
		}

		override protected function fireCallbackFunctionWithValue(value:int):void {
			var callBackFunction:Function = callback;
			callback = null;
			callBackFunction(value, passInput.value);
		}

		override protected function getMaxContentHeight():Number {
			return _height - padding * 2 - headerHeight - buttonsAreaHeight;
		}

		override protected function drawView():void {
//			if (showForgotPass) {
				forgotPassButton.setBitmapData(TextUtils.createTextFieldData(
						Lang.showPassword,
						_width - padding * 2,
						Config.FINGER_SIZE,
						true,
						TextFormatAlign.LEFT,
						TextFieldAutoSize.LEFT,
						Config.FINGER_SIZE * .33,
						true,
						Style.color(Style.COLOR_TEXT),
						Style.color(Style.COLOR_BACKGROUND),
						true,
						false,
						false), true);
//			}
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

			passInput.width = _width - padding * 2;
			passInput.view.y = int(content.itemsHeight + padding * .5);
			content.addObject(passInput.view);

			inputBottom.width = _width - padding * 2;
			content.addObject(inputBottom);
			inputBottom.y = passInput.view.y + passInput.view.height;
//			if (showForgotPass) {
				forgotPassButton.y = inputBottom.y + inputBottom.height -/*+*/ padding;
				forgotPassButton.x = int((_width - padding * 2) * .5 - forgotPassButton.width * .5);
				content.addObject(forgotPassButton);
//			}
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
			contentHeight = (padding * 4 + headerHeight + buttonsAreaHeight + content.itemsHeight);
		}

		override public function activateScreen():void {
			passInput.activate();
//			if (showForgotPass) {
				//forgotPassButton.activate();
//			}
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
//			if (showForgotPass) {
				//forgotPassButton.deactivate();
//			}
			super.deactivateScreen();

			passInput.S_CHANGED.add(onChangeInputValue);
		}

		override protected function btn0Clicked():void {
			if (callback != null) {
				fireCallbackFunctionWithValue(1);
			}
			if(passInput)passInput.setLabelText("");
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
//			if (showForgotPass) {}
			if (forgotPassButton) {
				forgotPassButton.dispose();
				forgotPassButton = null;
			}

			if (inputBottom) {
				UI.destroy(inputBottom);
				inputBottom = null;
			}
		}
	}
}