package com.dukascopy.connect.screens.dialogs {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.input.PassInput;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.scrollPanel.ScrollPanel;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.serviceScreen.Overlay;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.type.MainColors;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	import mx.utils.StringUtil;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class ScreenChangePayPassDialog extends BaseScreen {
		
		private var nextButton:BitmapButton;
		private var backButton:BitmapButton;
		private var container:Sprite;
		private var logo:Bitmap;
		private var title:Bitmap;
		private var description:Bitmap;
		private var scroll:ScrollPanel;
		private var componentsWidth:Number;
		private var state:String;
		private var callBack:Function;
		private var padding:Number;
		private var backDrawn:Boolean;
		private var inputOldPassword:PassInput;
		private var inputNewPassword:PassInput;
		private var inputNewPasswordRepeat:PassInput;
		private var legend:Bitmap;
		private var legendLine:Bitmap;
		private var scrollPoint:Sprite;
		
		public function ScreenChangePayPassDialog() {
			super();
		}
		
		override protected function createView():void {
			super.createView();
			
			container = new Sprite();
			view.addChild(container);
			
			scroll = new ScrollPanel();
			container.addChild(scroll.view);
			
			logo = new Bitmap();
			scroll.addObject(logo);
			
			title = new Bitmap();
			scroll.addObject(title);
			
			legend = new Bitmap();
			scroll.addObject(legend);
			
			description = new Bitmap();
			scroll.addObject(description);
			
			nextButton = new BitmapButton();
			nextButton.setStandartButtonParams();
			nextButton.setDownScale(1);
			nextButton.setDownColor(0);
			nextButton.tapCallback = nextClick;
			nextButton.disposeBitmapOnDestroy = true;
			nextButton.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
			container.addChild(nextButton);
			
			backButton = new BitmapButton();
			backButton.setStandartButtonParams();
			backButton.setDownScale(1);
			backButton.setDownColor(0);
			backButton.tapCallback = backClick;
			backButton.disposeBitmapOnDestroy = true;
			backButton.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
			container.addChild(backButton);
			
			inputOldPassword = new PassInput(Lang.TEXT_ENTER_CURR_PASS);
			scroll.addObject(inputOldPassword);
			
			inputNewPassword = new PassInput(Lang.TEXT_ENTER_NEW_PASS);
			scroll.addObject(inputNewPassword);
			
			inputNewPasswordRepeat = new PassInput(Lang.TEXT_REPEAT_NEW_PASS);
			scroll.addObject(inputNewPasswordRepeat);
			
			var lineBitmapData:ImageBitmapData = UI.getVerticalLine(Math.max(int(Config.FINGER_SIZE * 0.06), 2), 0xFF9A00);
			legendLine = new Bitmap(lineBitmapData);
			scroll.addObject(legendLine);
			
			scrollPoint = new Sprite();
			scrollPoint.graphics.beginFill(0xFFFFFF);
			scrollPoint.graphics.drawRect(0, 0, 1, 1);
			scrollPoint.graphics.endFill();
			scroll.addObject(scrollPoint);
		}
		
		private function fireCallbackFunctionWithValue(value:int):void {
			if (callBack != null) {
				var callBackFunction:Function = callBack;
				callBack = null;
				if (callBackFunction.length == 2) {
					callBackFunction(value, inputOldPassword.value);
				} else if (callBackFunction.length == 3) {
					if (data != null && "data" in data) {
						callBackFunction(value, inputOldPassword.value, data.data);
					} else {
						callBackFunction(value, inputOldPassword.value, null);
					}
				}
			}
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			inputOldPassword.activate();
			inputNewPassword.activate();
			inputNewPasswordRepeat.activate();
			nextButton.activate();
			backButton.activate();
			scroll.enable();
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			inputOldPassword.deactivate();
			inputNewPassword.deactivate();
			inputNewPasswordRepeat.deactivate();
			nextButton.deactivate();
			backButton.deactivate();
			scroll.disable();
		}
		
		private function backClick():void {
			if (callBack != null && callBack.length == 3)
			{
				callBack(0, null, null);
			}
			
			inputOldPassword.label = "";
			DialogManager.closeDialog();
		}
		
		private function nextClick():void {
			
			var currentPass:String = inputOldPassword.value;
			var newPass:String = inputNewPassword.value;
			var newPass2:String = inputNewPasswordRepeat.value;
			// VALIDATION 
			
			if (UI.isEmpty(currentPass) || UI.isEmpty(newPass) || UI.isEmpty(newPass2) ) {
				ToastMessage.display(Lang.emptyFields); 
				return;
			}			
			 
			if (currentPass == newPass && currentPass == newPass2) {
				ToastMessage.display(Lang.passDifferent);
				return;
			}
			 
			if (newPass != newPass2) {
				ToastMessage.display(Lang.passNotMatch);
				return; 
			}			
			 
			if (newPass.length < 6 || newPass2.length < 6) {
				ToastMessage.display(Lang.pass6chars);
				return;
			}
			
			if (data != null && data.callBack != null)
			{
				data.callBack(1, currentPass, newPass);
			}
			
			inputOldPassword.label = "";
			DialogManager.closeDialog();
		}
		
		private function focusOnInput():void {
			inputOldPassword.setFocus();
			inputOldPassword.requestSoftKeyboard();
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			if (data != null && "callBack" in data && data.callBack != null && data.callBack is Function) {
				callBack = data.callBack as Function;
			}
			
			padding = Config.FINGER_SIZE * .6;
			
			container.x = - Config.DOUBLE_MARGIN;
			container.y = - Config.DOUBLE_MARGIN;
			componentsWidth = getWidth() - padding * 2;
			
			redrawComponents();
			
			updatePositions();
		}
		
		private function redrawComponents():void {
			drawNextButton(Lang.CHANGE);
			drawBackButton(Lang.textBack);
			drawTitle();
			drawLegend();
			drawDescription();
			drawLogo();
		}
		
		private function drawLegend():void 
		{
			var text:String = Lang.TEXT_MARKER_1 + "\n" + Lang.TEXT_MARKER_2 + "\n" + Lang.TEXT_MARKER_3;
			
			legend.bitmapData = TextUtils.createTextFieldData(
				text,
				componentsWidth - Config.MARGIN,
				10,
				true,
				TextFormatAlign.LEFT,
				TextFieldAutoSize.LEFT,
				Config.FINGER_SIZE * .3,
				true,
				0x586270,
				MainColors.WHITE,
				true,
				false,
				false
			);
			legend.x = padding + Config.FINGER_SIZE * .36;
			legendLine.height = legend.height;
		}
		
		private function updatePositions():void {
			
			scroll.setWidthAndHeight(getWidth(), getHeight() - backButton.height - nextButton.height - Config.APPLE_BOTTOM_OFFSET - Config.MARGIN * 6);
			
			nextButton.x = int(getWidth() * .5 - nextButton.width * .5);
			nextButton.y = getHeight() - Config.APPLE_BOTTOM_OFFSET - Config.DIALOG_MARGIN - nextButton.height;
			
			backButton.x = int(getWidth() * .5 - backButton.width * .5);
			backButton.y = int(nextButton.y - backButton.height - Config.DOUBLE_MARGIN);
			
			var position:int = 0;
			position += Config.FINGER_SIZE;
			
			logo.y = position;
			logo.x = int(getWidth() * .5 - logo.width * .5);
			position += logo.height + Config.FINGER_SIZE * .4;
			
			title.y = position;
			title.x = int(getWidth() * .5 - title.width * .5);
			position += title.height + Config.FINGER_SIZE * .5;
			
			description.y = position;
			position += description.height + Config.FINGER_SIZE * .1;
			description.x = int(getWidth() * .5 - description.width * .5);
			
			if (inputOldPassword.parent != null) {
				inputOldPassword.width = componentsWidth;
				inputOldPassword.y = position;
				inputOldPassword.x = padding;
				position += inputOldPassword.height + Config.FINGER_SIZE * 0.65;
			}
			
			legend.y = position;
			legendLine.x = padding;
			legendLine.y = position;
			position += legend.height + Config.FINGER_SIZE * .15;
			
			if (inputNewPassword.parent != null) {
				inputNewPassword.width = componentsWidth;
				inputNewPassword.y = position;
				inputNewPassword.x = padding;
				position += inputNewPassword.height + Config.FINGER_SIZE * 0.3;
			}
			if (inputNewPasswordRepeat.parent != null) {
				inputNewPasswordRepeat.width = componentsWidth;
				inputNewPasswordRepeat.y = position;
				inputNewPasswordRepeat.x = padding;
				position += inputNewPasswordRepeat.height + Config.FINGER_SIZE * 0.3;
			}
		}
		
		private function drawLogo():void {
			var icon:IconLogo = new IconLogo();
			var size:int = Config.FINGER_SIZE;
			UI.scaleToFit(icon, size, size);
			logo.bitmapData = UI.getSnapshot(icon, StageQuality.HIGH, "ScreenPayPassDialogNew.iconLogo");
			UI.destroy(icon);
		}
		
		private function drawTitle():void {
			var text:String = Lang.paymentsEnterPassTitle;
			if (data != null && "title" in data && data.title != null) {
				text = data.title;
			}
			title.bitmapData = TextUtils.createTextFieldData(
				text,
				componentsWidth,
				10,
				true,
				TextFormatAlign.CENTER,
				TextFieldAutoSize.LEFT,
				Config.FINGER_SIZE * .4,
				true,
				0x586270,
				MainColors.WHITE,
				true,
				false,
				false
			);
		}
		
		private function drawDescription():void {
			description.bitmapData = TextUtils.createTextFieldData(
				Lang.passwordMustBeChanged,
				componentsWidth,
				10,
				true,
				TextFormatAlign.LEFT,
				TextFieldAutoSize.LEFT,
				Config.FINGER_SIZE * .3,
				true,
				0x586270,
				MainColors.WHITE,
				true,
				false,
				false
			);
		}
		
		private function drawNextButton(text:String):void {
			var textSettings:TextFieldSettings = new TextFieldSettings(text, 0xFFFFFF, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, 0x6FB53E, 1, Config.FINGER_SIZE * .8, NaN);
			nextButton.setBitmapData(buttonBitmap, true);
		}
		
		private function drawBackButton(text:String):void {
			var textSettings:TextFieldSettings = new TextFieldSettings(text, 0xFFFFFF, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, 0xBDC6D4, 1, Config.FINGER_SIZE * .8, NaN);
			backButton.setBitmapData(buttonBitmap, true);
		}

		override protected function drawView():void {
			if (backDrawn == false) {
				backDrawn = true;
				view.graphics.clear();
				view.graphics.beginFill(0xFFFFFF, 1);
				view.graphics.drawRect( -Config.DOUBLE_MARGIN, -Config.DOUBLE_MARGIN, getWidth(), getHeight());
				view.graphics.endFill();
			}
			updatePositions();
		}
		
		private function getHeight():Number {
			return _height + Config.DOUBLE_MARGIN * 2;
		}
		
		private function getWidth():Number {
			return _width + Config.DOUBLE_MARGIN * 2;
		}

		private function onChangeInputValue():void {
			if (inputOldPassword != null) {
				var currentValue:String = StringUtil.trim(inputOldPassword.value);
				if (currentValue != "") {
					nextButton.activate();
					nextButton.alpha = 1;
				} else {
					nextButton.alpha = .7;
					nextButton.deactivate();
				}
			}
		}
		
		protected function onCloseButtonClick():void {
			if (inputOldPassword != null)
				inputOldPassword.label = "";
			DialogManager.closeDialog();
		}

		override public function dispose():void {
			if (isDisposed == true) {
				return;
			}
			super.dispose();
			
			Overlay.removeCurrent();
			
			callBack = null;
			
			if (inputOldPassword != null)
				inputOldPassword.dispose();
			inputOldPassword = null;
			if (inputNewPassword != null)
				inputNewPassword.dispose();
			inputNewPassword = null;
			if (inputNewPasswordRepeat != null)
				inputNewPasswordRepeat.dispose();
			inputNewPasswordRepeat = null;
			if (container != null)
				UI.destroy(container);
			container = null;
			if (logo != null)
				UI.destroy(logo);
			logo = null;
			if (legend != null)
				UI.destroy(legend);
			legend = null;
			if (legendLine != null)
				UI.destroy(legendLine);
			legendLine = null;
			if (title != null)
				UI.destroy(title);
			title = null;
			if (scrollPoint != null)
				UI.destroy(scrollPoint);
			scrollPoint = null;
			if (description != null)
				UI.destroy(description);
			description = null;
			if (nextButton != null)
				nextButton.dispose();
			nextButton = null;
			if (backButton != null)
				backButton.dispose();
			backButton = null;
			if (scroll != null)
				scroll.dispose();
			scroll = null;
		}
	}
}