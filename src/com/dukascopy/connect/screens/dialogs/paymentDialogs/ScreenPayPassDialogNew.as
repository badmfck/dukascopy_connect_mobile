package com.dukascopy.connect.screens.dialogs.paymentDialogs {

	import assest.LockIconGrey2;
	import assets.EditIcon;
	import assets.FingerprintIcon;
	import assets.LoginLogo;
	import assets.NextButton4;
	import assets.SendToMailIcon2;
	import com.adobe.utils.StringUtil;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.GD;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.scrollPanel.ScrollPanel;
	import com.dukascopy.connect.gui.tools.HorizontalPreloader;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.serviceScreen.FingerprintScreen;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.nativeExtensionController.NativeExtensionController;
	import com.dukascopy.connect.sys.payments.PayAPIManager;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.store.Store;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.type.MainColors;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import com.dukascopy.langs.LangManager;
	import com.greensock.TweenMax;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.geom.Rectangle;
	import flash.text.StageText;
	import flash.text.StageTextInitOptions;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;


	/**
	 * ...
	 * @author Sergey Dobarin
	 */

	public class ScreenPayPassDialogNew extends BaseScreen {
		
		static public const STATE_PASSWORD:String = "statePassword";
		static public const STATE_ENTER_EMAIL:String = "stateEnterEmail";
		static public const STATE_ENTER_CODE:String = "stateEnterCode";
		static public const STATE_RESTORE_SUCCESS:String = "stateRestoreSuccess";
		
		protected var input:StageText;
		private var inputBottom:Bitmap;
		private var forgotPassButton:BitmapButton;
		
		private var nextButton:BitmapButton;
		private var backButton:BitmapButton;
		private var container:Sprite;
		private var logo:LoginLogo2;
		private var description:Bitmap;
		private var inputIcon:Bitmap;
		private var scroll:ScrollPanel;
		private var componentsWidth:Number;
		private var state:String;
		private var callBack:Function;
		private var padding:Number;
		private var nextState:String;
		private var inAnimation:Boolean;
		private var horizontalLoader:HorizontalPreloader;
		private var locked:Boolean;
		private var currentEmail:String;
		private var currentTocken:String;
		private var backDrawn:Boolean;
		private var fingerprintButton:BitmapButton;
		private var fingerprint:FingerprintScreen;
		private var savedPinExist:Boolean;
		private var fingerprintShown:Boolean;
		
		public function ScreenPayPassDialogNew() {
			super();
		}
		
		override protected function createView():void {
			super.createView();
			
			state = STATE_PASSWORD;
			
			container = new Sprite();
			view.addChild(container);
			
			scroll = new ScrollPanel();
			container.addChild(scroll.view);
			
			logo = new LoginLogo2();
			UI.scaleToFit(logo, Config.FINGER_SIZE * 10, Config.FINGER_SIZE * 1.7);
			scroll.addObject(logo);
			
			description = new Bitmap();
			scroll.addObject(description);
			
			inputIcon = new Bitmap();
			scroll.addObject(inputIcon);
			
			nextButton = new BitmapButton();
			nextButton.setStandartButtonParams();
			nextButton.setDownScale(1);
			nextButton.setDownColor(0);
			nextButton.tapCallback = nextClick;
			nextButton.disposeBitmapOnDestroy = true;
			nextButton.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
			scroll.addObject(nextButton);
			
			backButton = new BitmapButton();
			backButton.setStandartButtonParams();
			backButton.setDownScale(1);
			backButton.setDownColor(0);
			backButton.tapCallback = backClick;
			backButton.disposeBitmapOnDestroy = true;
			backButton.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
			container.addChild(backButton);
			
			var options:StageTextInitOptions = new StageTextInitOptions(false);
			
			input = new StageText(options);
			input.stage = MobileGui.stage;
			input.displayAsPassword = true;
			input.fontSize = Config.FINGER_SIZE * .43;
		//	input.text = Lang.enterPassword;
			input.color = AppTheme.GREY_MEDIUM;
		//	input.text = "123456a";
		//	input.text = "Dukascopy123";
			
			var hLineBitmapData:ImageBitmapData = UI.getHorizontalLine(3, 0x707D8E);
			inputBottom = new Bitmap(hLineBitmapData);
			scroll.addObject(inputBottom);
			
			forgotPassButton = new BitmapButton();
			forgotPassButton.setStandartButtonParams();
			forgotPassButton.setDownScale(1);
			forgotPassButton.setDownColor(0xFFFFFF);
			forgotPassButton.tapCallback = onForgotClick;
			forgotPassButton.disposeBitmapOnDestroy = true;
			forgotPassButton.usePreventOnDown = false;
			forgotPassButton.cancelOnVerticalMovement = true;
			forgotPassButton.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
			forgotPassButton.show();
			
			container.addChild(forgotPassButton);
			
			horizontalLoader = new HorizontalPreloader(0xF6951D);
			container.addChild(horizontalLoader);
		}
		
		private function fingerprintClick():void 
		{
			if (fingerprint != null)
			{
				return;
			}
			fingerprint = new FingerprintScreen();
			
			view.addChild(fingerprint.view);
			fingerprint.setInitialSize(_width, _height);
			fingerprint.setWidthAndHeight(_width, _height);
			fingerprint.initScreen({onClosed:onFingerprintClosed, callback:onFingerprintSuccess});
			fingerprint.activateScreen();
			deactivateScreen();
		}
		
		private function onFingerprintSuccess(pass:String):void 
		{
			NativeExtensionController.payPassByFingerprint = true;
			TweenMax.delayedCall(0.5, fillPass, [pass]);
		}
		
		private function fillPass(pass:String):void 
		{
			if (_isDisposed == true)
			{
				return;
			}
			if (state == STATE_PASSWORD)
			{
				input.text = pass;
				nextClick();
			}
		}
		
		private function onFingerprintClosed():void 
		{
			activateScreen();
			if (fingerprint != null)
			{
				view.removeChild(fingerprint.view);
				fingerprint.dispose();
				fingerprint = null;
			}
		}
		
		override public function onBack(e:Event = null):void
		{
			if (fingerprint != null)
			{
				view.removeChild(fingerprint.view);
				fingerprint.dispose();
				fingerprint = null;
			}
			else
			{
				super.onBack(e);
			}
		}
		
		private function onTextFocusIn(e:FocusEvent):void 
		{
			if (input.text == getDefValue())
			{
				input.text = "";
			}
			if (state == STATE_PASSWORD)
			{
				input.displayAsPassword = true;
			}
		}
		
		private function onTextFocusOut(e:FocusEvent):void 
		{
			if (input.text == "" && state != STATE_PASSWORD)
			{
				input.text = getDefValue();
			}
			if (state == STATE_PASSWORD)
			{
				if (input.text == getDefValue())
				{
				//	input.displayAsPassword = false;
				}
				else
				{
					input.displayAsPassword = true;
				}
			}
		}
		
		private function fireCallbackFunctionWithValue(value:int):void {
			if (callBack != null) {
				var callBackFunction:Function = callBack;
				callBack = null;
				if (callBackFunction.length == 2) {
					callBackFunction(value, input.text);
				} else if (callBackFunction.length == 3) {
					if (data != null && "data" in data) {
						callBackFunction(value, input.text, data.data);
					} else {
						callBackFunction(value, input.text, null);
					}
				}
			}
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			if (state == STATE_PASSWORD) {
			//	input.activate();
				nextButton.activate();
				backButton.activate();
				forgotPassButton.activate();
				if (fingerprintButton != null)
				{
					fingerprintButton.activate();
				}
			}
			scroll.enable();
			input.addEventListener(FocusEvent.FOCUS_IN, onTextFocusIn);
			input.addEventListener(FocusEvent.FOCUS_OUT, onTextFocusOut);
			input.visible = true;
		}
		
		private function fingerprintAvaliable():Boolean 
		{
			if (Config.PLATFORM_ANDROID == true && state == STATE_PASSWORD)
			{
				return true;
			}
			return false;
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (state == STATE_PASSWORD) {
				nextButton.deactivate();
				backButton.deactivate();
				forgotPassButton.deactivate();
				if (fingerprintButton != null)
				{
					fingerprintButton.deactivate();
				}
			}
			scroll.disable();
			input.addEventListener(FocusEvent.FOCUS_IN, onTextFocusIn);
			input.addEventListener(FocusEvent.FOCUS_OUT, onTextFocusOut);
			input.visible = false;
		}
		
		private function backClick():void {
			if (inAnimation == true) {
				return;
			}
			if (state == STATE_ENTER_EMAIL) {
				toState(STATE_PASSWORD);
			} else if (state == STATE_PASSWORD) {
				fireCallbackFunctionWithValue(0);
				input.text = "";
				DialogManager.closeDialog();
			} else if (state == STATE_ENTER_CODE) {
				toState(STATE_ENTER_EMAIL);
			} else if (state == STATE_RESTORE_SUCCESS) {
				fireCallbackFunctionWithValue(0);
				input.text = "";
				DialogManager.closeDialog();
			}

			GD.S_PAYPASS_BACK_CLICK.invoke();
		}
		
		private function nextClick():void {
			if (locked == true) {
				return;
			}
			if (inAnimation == true) {
				return;
			}
			if (state == STATE_PASSWORD) {
				if (input.text != null && input.text != "")
				{
					fireCallbackFunctionWithValue(1);
					input.text = "";
					DialogManager.closeDialog();
				}
			} else if (state == STATE_ENTER_EMAIL) {
				locked = true;
				horizontalLoader.start();
				currentEmail = input.text;
				
				PayAPIManager.S_PASS_REMIND_ERROR.add(onEmailError);
				PayAPIManager.S_PASS_REMIND.add(onEmailRespond);
				
				PayAPIManager.remindPassword(currentEmail);
			} else if (state == STATE_ENTER_CODE) {
				locked = true;
				horizontalLoader.start();
				
				PayAPIManager.S_PASS_REMIND_ERROR.add(onCodeError);
				PayAPIManager.S_PASS_REMIND.add(onCodeRespond);
				
				PayAPIManager.remindPassword(currentEmail, input.text, currentTocken);
			}
		}
		
		private function onCodeRespond(success:Boolean):void {
			if (success == false) {
				ToastMessage.display(Lang.serverError);
				onCodeSent(false);
			} else {
				onCodeSent(true);
			}
		}
		
		private function onCodeSent(success:Boolean):void {
			PayAPIManager.S_PASS_REMIND_ERROR.remove(onCodeError);
			PayAPIManager.S_PASS_REMIND.remove(onCodeRespond);
			
			locked = false;
			horizontalLoader.stop();
			
			if (success == true) {
				NativeExtensionController.clearFingerprint();
				toState(STATE_RESTORE_SUCCESS);
			}
		}
		
		private function onCodeError(errorCode:String = null):void {
			var errorText:String = Lang.notValidInputData;
			
			if (errorCode == "4002") {
				errorText = Lang.codeVerificationFailed;
			}
			
			ToastMessage.display(errorText);
			
			onCodeSent(false);
		}
		
		private function onEmailRespond(tocken:String = null):void {
			if (tocken == null) {
				ToastMessage.display(Lang.serverError);
				onEmailSent(false);
			} else {
				currentTocken = tocken;
				onEmailSent(true);
			}
		}
		
		private function onEmailError(errorCode:String = null):void {
			var errorText:String = Lang.notValidInputData;
			if (errorCode == "4001") {
				errorText = Lang.emailNotValid;
			}
			ToastMessage.display(errorText);
			onEmailSent(false);
		}
		
		private function onEmailSent(success:Boolean):void {
			PayAPIManager.S_PASS_REMIND_ERROR.remove(onEmailError);
			PayAPIManager.S_PASS_REMIND.remove(onEmailRespond);
			
			locked = false;
			horizontalLoader.stop();
			
			if (success == true) {
				toState(STATE_ENTER_CODE);
			}
		}
		
		private function onForgotClick():void {
			if (inAnimation == true) {
				return;
			}
			if (state == STATE_PASSWORD) {
				toState(STATE_ENTER_EMAIL);
			}
		}
		
		private function toState(newState:String):void {
			horizontalLoader.stop();
			
			nextState = newState;
			
			inAnimation = true;
			
			TweenMax.to(scroll.view, 0.3, {alpha:0, onComplete:changeState});
			
			redrawComponents();
			updatePositions();
			scroll.scrollToPosition(0);
		}
		
		private function changeState():void {
			state = nextState;
			if (state == STATE_ENTER_EMAIL) {
				forgotPassButton.visible = false;
				input.displayAsPassword = false;
				input.text = Lang.enterEmail;
			} else if (state == STATE_ENTER_CODE) {
				forgotPassButton.visible = false;
				input.displayAsPassword = false;
				input.text = Lang.enterCode;
			} else if (state == STATE_PASSWORD) {
				forgotPassButton.visible = true;
				input.displayAsPassword = true;
				input.text = "";
			//	input.text = Lang.enterPassword;
			} else if (state == STATE_RESTORE_SUCCESS) {
				forgotPassButton.visible = false;
				input.visible = false;
				scroll.removeObject(inputIcon);
				scroll.removeObject(inputBottom);
				scroll.removeObject(nextButton);
			}
			
			redrawComponents();
			updatePositions();
			scroll.scrollToPosition(0);
			TweenMax.to(scroll.view, 0.3, {alpha:1, onComplete:changeStateComplete});
		}
		
		private function changeStateComplete():void {
			inAnimation = false;
		}
		
		private function focusOnInput():void {
		//	input.setFocus();
		//	input.getTextField().requestSoftKeyboard();
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			NativeExtensionController.payPassByFingerprint = false;
			if (data != null && "callBack" in data && data.callBack != null && data.callBack is Function) {
				callBack = data.callBack as Function;
			}
			
			padding = Config.DIALOG_MARGIN;
			
			container.x = - Config.DOUBLE_MARGIN;
			container.y = - Config.DOUBLE_MARGIN;
			componentsWidth = getWidth() - padding * 2;
			
			redrawComponents();
			
			scroll.setWidthAndHeight(getWidth(), getHeight() - forgotPassButton.height - backButton.height - Config.APPLE_BOTTOM_OFFSET - Config.MARGIN * 5);
			
			backButton.x = int(getWidth() * .5 - backButton.width * .5);
			backButton.y = int(scroll.view.y + scroll.height + Config.MARGIN);
			
			forgotPassButton.x = int(getWidth() * .5 - forgotPassButton.width * .5);
			forgotPassButton.y = int(backButton.y + backButton.height + Config.MARGIN);
			
			horizontalLoader.setSize(getWidth(), int(Config.FINGER_SIZE * .07));
			
			updatePositions();
		}
		
		private function redrawComponents():void {
			drawNextButton(getNextButtonText());
			drawBackButton(Lang.textBack);
			drawRestoreButton(Lang.restorePassword);
			drawDescription();
		//	drawLogo();
			drawLockIcon();
			if (fingerprintButton != null)
			{
				drawFingerprintButton();
			}
		}
		
		private function drawFingerprintButton():void 
		{
			var icon:FingerprintIcon = new FingerprintIcon();
			UI.scaleToFit(icon, Config.FINGER_SIZE * .7, Config.FINGER_SIZE * .7);
			fingerprintButton.setBitmapData(UI.getSnapshot(icon), true);
		}
		
		private function getNextButtonText():String 
		{
			var text:String = "";
			if (state == STATE_PASSWORD) {
				text = Lang.login;
			} else if (state == STATE_ENTER_EMAIL) {
				text = Lang.textSend;
			} else if (state == STATE_ENTER_CODE) {
				text = Lang.textSend;
			} else if (state == STATE_RESTORE_SUCCESS) {
				text = Lang.textSend;
			}
			return text;
		}
		
		private function updatePositions(loadFingerprintStatus:Boolean = true):void {
			var position:int = 0;
			position += Config.FINGER_SIZE;
			
			logo.y = position;
			logo.x = int(getWidth() * .5 - logo.width * .5);
			position += logo.height + Config.FINGER_SIZE * .6;
			
			description.y = position;
			description.x = int(_width * .5 - description.width * .5 + Config.DIALOG_MARGIN * .5);
			position += description.height + Config.FINGER_SIZE * .4;
			
			if (input.visible == true)
			{
				var fingerprintWidth:int = 0;
				
				if (loadFingerprintStatus && fingerprintButton == null && Config.PLATFORM_ANDROID && MobileGui.androidExtension.fingerprint_pinExist() == true && MobileGui.androidExtension.fingerprint_avaliable() == true)
				{
					Store.load(Store.USE_FINGERPRINT, onFingerprintStatusLoaded);
				}
				else if(fingerprintButton != null)
				{
					if (fingerprintAvaliable() == true)
					{
						savedPinExist = NativeExtensionController.bankPinExist();
						if (savedPinExist == true)
						{
							fingerprintWidth = fingerprintButton.width + Config.MARGIN * 3.7;
							scroll.update();
						}
					}
				}
				
				var inputHeight:int = Config.FINGER_SIZE;
				input.viewPort = new Rectangle(padding + inputIcon.width + Config.MARGIN * 2, 
												position + Config.APPLE_TOP_OFFSET + Config.FINGER_SIZE*.2, 
												componentsWidth - fingerprintWidth - inputIcon.width, 
												inputHeight);
				inputBottom.y = int(position + Config.FINGER_SIZE * .85);
				
				if (savedPinExist == true && fingerprintButton != null)
				{
					fingerprintButton.x = int(input.viewPort.x + input.viewPort.width + Config.MARGIN);
					fingerprintButton.y = int(input.viewPort.y + input.viewPort.height * .5 - fingerprintButton.height * .5 - Config.FINGER_SIZE * .1);
				}
				
				inputIcon.y = int(position + inputHeight * .5 - inputIcon.height * .5 - Config.FINGER_SIZE * .05);
				
				position += inputHeight + Config.FINGER_SIZE * .5;
				inputBottom.x = padding;
				inputIcon.x = padding + Config.MARGIN;
				
				
			//	padding + componentsWidth - nextButton.width - Config.MARGIN;
				
				inputBottom.width = componentsWidth - fingerprintWidth;
			}
			
			backButton.y = position;
			backButton.x = int(getWidth()*.5 - backButton.width - Config.MARGIN);
			
			nextButton.y = position;
			nextButton.x = int(getWidth()*.5 + Config.MARGIN);
		}
		
		private function onFingerprintStatusLoaded(data:Boolean, error:Boolean):void 
		{
			if (isDisposed == true)
			{
				return;
			}
			if (error == true || data == true)
			{
				fingerprintButton = new BitmapButton();
				fingerprintButton.setStandartButtonParams();
				fingerprintButton.setDownScale(1);
				fingerprintButton.setDownColor(0);
				fingerprintButton.tapCallback = fingerprintClick;
				fingerprintButton.disposeBitmapOnDestroy = true;
				fingerprintButton.setOverlay(HitZoneType.CIRCLE);
				fingerprintButton.setOverlayPadding(Config.FINGER_SIZE * .2);
				drawFingerprintButton();
				scroll.addObject(fingerprintButton);
				
				updatePositions(false);
				if (_isActivated)
				{
					fingerprintButton.activate();
				}
				
				if (Config.PLATFORM_ANDROID == true && fingerprintShown == false)
				{
					fingerprintShown = true;
					fingerprintClick();
				}
			}
		}
		
		private function drawLockIcon():void {
			var icon:Sprite = getIcon();
			if (icon != null) {
				var size:int = Config.FINGER_SIZE * .4;
				UI.scaleToFit(icon, size, size);
				if (inputIcon.bitmapData != null) {
					inputIcon.bitmapData.dispose();
					inputIcon.bitmapData = null;
				}
				inputIcon.bitmapData = UI.getSnapshot(icon, StageQuality.HIGH, "ScreenPayPassDialogNew.lockIcon");
				UI.destroy(icon);
			}
		}
		
		private function getIcon():Sprite {
			var iconClip:Sprite
			if (state == STATE_PASSWORD) {
				iconClip = new LockIconGrey2();
			} else if (state == STATE_ENTER_EMAIL) {
				iconClip = new SendToMailIcon2();
				UI.colorize(iconClip, 0x9CA3AD);
			} else if (state == STATE_ENTER_CODE) {
				iconClip = new EditIcon();
				UI.colorize(iconClip, 0x9CA3AD);
			}
			return iconClip;
		}
		
		/*private function drawLogo():void {
			var icon:IconLogo = new IconLogo();
			var size:int = Config.FINGER_SIZE;
			UI.scaleToFit(icon, size, size);
			logo.bitmapData = UI.getSnapshot(icon, StageQuality.HIGH, "ScreenPayPassDialogNew.iconLogo");
			UI.destroy(icon);
		}*/
		
		private function drawRestoreButton(text:String):void {
			var textSettings:TextFieldSettings = new TextFieldSettings(text, 0xA0AAB6, Config.FINGER_SIZE * .33, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, 0xFFFFFF, 1, Config.FINGER_SIZE * .8, NaN);
			forgotPassButton.setBitmapData(buttonBitmap, true);
		}
		
		private function drawDescription():void {
			var text:String = getDescription();
			
			if (description.bitmapData != null)
			{
				description.bitmapData.dispose();
				description.bitmapData = null;
			}
			
			description.bitmapData = TextUtils.createTextFieldData(
				text,
				componentsWidth,
				10,
				true,
				TextFormatAlign.CENTER,
				TextFieldAutoSize.LEFT,
				Config.FINGER_SIZE * .35,
				true,
				0x586270
			);
		}
		
		private function getDescription():String {
			var text:String = Lang.paymentsEnterPassDescription;
			if (state == STATE_PASSWORD) {
				if (data != null && "text" in data && data.text != null) {
					text = data.text;
				}
			} else if (state == STATE_ENTER_EMAIL) {
				text = Lang.restorePasswordDescription;
			} else if (state == STATE_ENTER_CODE) {
				text = Lang.enterCodeFromEmail;
				text = LangManager.replace(Lang.regExtValue, text, currentEmail);	
			} else if (state == STATE_RESTORE_SUCCESS) {
				text = Lang.tempPassSentToEmail;
				text = LangManager.replace(Lang.regExtValue, text, currentEmail);	
			}
			return text;
		}
		
		private function drawNextButton(text:String):void {
			var textSettings:TextFieldSettings = new TextFieldSettings(text, 0xFFFFFF, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, 0x3599CD, 1, Config.FINGER_SIZE * .8, NaN, getWidth()*.5 - Config.MARGIN - Config.DIALOG_MARGIN);
			nextButton.setBitmapData(buttonBitmap, true);
		}
		
		private function drawBackButton(text:String):void {
			var textSettings:TextFieldSettings = new TextFieldSettings(text, 0xFFFFFF, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, 0xBDC6D4, 1, Config.FINGER_SIZE * .8, NaN, getWidth()*.5 - Config.MARGIN - Config.DIALOG_MARGIN);
			backButton.setBitmapData(buttonBitmap, true);
		}

		private function callbackTouchID(secret:String = ""):void {
			input.text = secret;
			input.displayAsPassword = true;
			//!TODO:;
		}

		override protected function drawView():void {
			if (backDrawn == false) {
				backDrawn = true;
				view.graphics.clear();
				view.graphics.beginFill(0xFFFFFF, 1);
				view.graphics.drawRect( -Config.DOUBLE_MARGIN, -Config.DOUBLE_MARGIN - Config.APPLE_TOP_OFFSET, getWidth(), getHeight() + Config.APPLE_TOP_OFFSET + Config.APPLE_BOTTOM_OFFSET);
				view.graphics.endFill();
			}
			if (input != null && scroll != null) {
			//	scroll.scrollToPosition(input.view.y + input.height + Config.MARGIN);
			}
		}
		
		private function getHeight():Number {
			return _height + Config.DOUBLE_MARGIN * 2;
		}
		
		private function getWidth():Number {
			return _width + Config.DOUBLE_MARGIN * 2;
		}

		private function onChangeInputValue():void {
			if (input != null) {
				var currentValue:String = StringUtil.trim(input.text);
				var defValue:String = getDefValue();
				if (currentValue != "" && currentValue != getDefValue()) {
					nextButton.activate();
					nextButton.alpha = 1;
				} else {
					nextButton.alpha = .7;
					nextButton.deactivate();
				}
			}
		}
		
		private function getDefValue():String
		{
			if (state == STATE_ENTER_CODE)
			{
				return Lang.enterCode;
			}
			else if (state == STATE_ENTER_EMAIL)
			{
				return Lang.enterEmail;
			}
			else if (state == STATE_PASSWORD)
			{
				return Lang.enterPassword;
			}
			return "";
		}
		
		protected function onCloseButtonClick():void {
			if (input != null &&  input.visible)
				input.text = "";
			DialogManager.closeDialog();
		}

		override public function dispose():void {
			if (isDisposed == true) {
				return;
			}
			super.dispose();
			
			PayAPIManager.S_PASS_REMIND_ERROR.remove(onEmailError);
			PayAPIManager.S_PASS_REMIND.remove(onEmailRespond);
			
			PayAPIManager.S_PASS_REMIND_ERROR.remove(onCodeError);
			PayAPIManager.S_PASS_REMIND.remove(onCodeRespond);
			
			TweenMax.killTweensOf(scroll.view);
			TweenMax.killDelayedCallsTo(fillPass);
			
			callBack = null;
			if (horizontalLoader != null)
				horizontalLoader.dispose();
			horizontalLoader = null;
			if (input != null)
			{
				input.removeEventListener(FocusEvent.FOCUS_IN, onTextFocusIn);
				input.removeEventListener(FocusEvent.FOCUS_OUT, onTextFocusOut);
				input.stage = null;
				input.dispose();
			}
			input = null;
			if (forgotPassButton != null)
				forgotPassButton.dispose();
			forgotPassButton = null;
			if (inputBottom != null)
				UI.destroy(inputBottom);
			inputBottom = null;
			if (container != null)
				UI.destroy(container);
			container = null;
			if (logo != null)
				UI.destroy(logo);
			logo = null;
			if (description != null)
				UI.destroy(description);
			description = null;
			if (inputIcon != null)
				UI.destroy(inputIcon);
			inputIcon = null;
			if (nextButton != null)
				nextButton.dispose();
			nextButton = null;
			if (backButton != null)
				backButton.dispose();
			backButton = null;
			if (fingerprintButton != null)
				fingerprintButton.dispose();
			fingerprintButton = null;
			if (scroll != null)
				scroll.dispose();
			scroll = null;
			if (fingerprint != null)
			{
				view.removeChild(fingerprint.view);
				fingerprint.dispose();
				fingerprint = null;
			}
		}
	}
}