package com.dukascopy.connect.screens.dialogs.paymentDialogs {

	import assest.LockIconGrey2;
	import assets.EditIcon;
	import assets.EyeIcon;
	import assets.FingerprintIcon;
	import assets.LoginLogo;
	import assets.NextButton4;
	import assets.PaymentsLogo;
	import assets.SendToMailIcon2;
	import com.adobe.utils.StringUtil;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.GD;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.gui.components.CirclePreloader;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.scrollPanel.ScrollPanel;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.serviceScreen.FingerprintScreen;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.nativeExtensionController.NativeExtensionController;
	import com.dukascopy.connect.sys.payments.PayAPIManager;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.softKeyboard.SoftKeyboard;
	import com.dukascopy.connect.sys.store.Store;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.sys.touchID.TouchIDManager;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import com.dukascopy.langs.LangManager;
	import com.greensock.TweenMax;
	import com.greensock.easing.Power2;
	import com.greensock.easing.Power3;
	import com.greensock.easing.Power4;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.SoftKeyboardEvent;
	import flash.events.StatusEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.SoftKeyboardType;
	import flash.text.StageText;
	import flash.text.StageTextInitOptions;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;


	/**
	 * ...
	 * @author Sergey Dobarin
	 */

	public class PaymentsLoginScreen extends BaseScreen {
		
		static public const STATE_PASSWORD:String = "statePassword";
		static public const STATE_ENTER_EMAIL:String = "stateEnterEmail";
		static public const STATE_ENTER_CODE:String = "stateEnterCode";
		static public const STATE_RESTORE_SUCCESS:String = "stateRestoreSuccess";
		
		private var state:String;
		
		private var background:Sprite;
		private var backImage:Bitmap;
		private var logo:Bitmap;
		private var description:Bitmap;
		private var inputBottom:Bitmap;
		private var okButton:BitmapButton;
		private var backButton:BitmapButton;
		private var restoreButton:BitmapButton;
	//	private var showPassButton:BitmapButton;
		private var fingerprintButton:BitmapButton;
		private var contentPadding:Number;
		private var initialHeight:int;
		private var startDescriptinPosition:Number;
		private var inputHeight:Number;
		private var lastHeight:int;
		private var input:StageText;
		private var preloader:CirclePreloader;
		private var fingerprint:FingerprintScreen;
		private var inAnimation:Boolean;
		private var locked:Boolean;
		private var currentEmail:String;
		private var nextState:String;
		private var currentTocken:String;
		private var callBack:Function;
		private var savedPinExist:Boolean;
		private var fingerprintShown:Boolean;
		private var firstTime:Boolean = true;
		private var container:Sprite;
		private var callbackValue:int;
		private var dialogClosed:Boolean;
		private var inHideAnimation:Boolean;
		private var keyboardHeight:int = 0;
	//	private var needModePass:Boolean;
		
		public function PaymentsLoginScreen() {
			super();
		}
		
		override protected function createView():void {
			super.createView();
			
			container = new Sprite();
			view.addChild(container);
			
			background = new Sprite();
			container.addChild(background);
			
			backImage = new Bitmap();
			background.addChild(backImage);
			
			logo = new Bitmap();
			container.addChild(logo);
			
			var options:StageTextInitOptions = new StageTextInitOptions(false);
			
			var textFormat:TextFormat = new TextFormat();
			textFormat.size = Config.FINGER_SIZE * .4;
			textFormat.color = Style.color(Style.COLOR_TEXT);
			textFormat.font = Config.defaultFontName;
			
			/*input = new Input();
			input.S_CHANGED.add(onInputChanged);
			input.allowDropFocus = false;
			input.updateTextFormat(textFormat);
			input.setMode(Input.MODE_INPUT);
			needModePass = true;
			input.text = "";
			input.backgroundAlpha = 0;
			input.setRoundBG(false);
			input.getTextField().textColor = Style.color(Style.COLOR_TEXT);
			input.setRoundRectangleRadius(0);
			input.setBorderVisibility(false);
			input.inUse = true;
			container.addChild(input.view);*/
			
			input = new StageText(options);
			input.softKeyboardType = SoftKeyboardType.DEFAULT;
			input.color = Style.color(Style.COLOR_TEXT);
			input.fontSize = Config.FINGER_SIZE * .4;
			input.fontFamily = Config.defaultFontName;
			input.stage = MobileGui.stage;
			input.displayAsPassword = true;
		//	input.text = "123456a";
			
			var hLineBitmapData:ImageBitmapData = UI.getHorizontalLine(3, Style.color(Style.COLOR_TEXT));
			inputBottom = new Bitmap(hLineBitmapData);
			container.addChild(inputBottom);
			
			description = new Bitmap();
			container.addChild(description);
			
			okButton = new BitmapButton();
			okButton.setStandartButtonParams();
			okButton.setDownScale(1);
			okButton.setDownColor(NaN);
			okButton.setOverlay(HitZoneType.BUTTON);
			okButton.cancelOnVerticalMovement = false;
			okButton.ignoreHittest = true;
			okButton.tapCallback = onButtonOkClick;
			
			container.addChild(okButton);
			
			backButton = new BitmapButton();
			backButton.setStandartButtonParams();
			backButton.setDownScale(1);
			backButton.setDownColor(NaN);
			backButton.setOverlay(HitZoneType.CIRCLE);
			backButton.setOverlayPadding(Config.FINGER_SIZE * .2);
			backButton.cancelOnVerticalMovement = true;
			backButton.setOverflow(Config.FINGER_SIZE * .3, Config.FINGER_SIZE * .3, Config.FINGER_SIZE * .3, Config.FINGER_SIZE * .3);
			backButton.tapCallback = onButtonBackClick;
			backButton.ignoreHittest = true;
			container.addChild(backButton);
			
			var icon:Sprite = new (Style.icon(Style.ICON_BACK))();
			UI.colorize(icon, Color.RED);
			icon.height = int(Config.FINGER_SIZE * .45);
			icon.scaleX = icon.scaleY;
			backButton.setBitmapData(UI.getSnapshot(icon, StageQuality.HIGH, "PaymentsLogin.back"), true);
			backButton.y = Config.APPLE_TOP_OFFSET + int(Config.TOP_BAR_HEIGHT * .5 - backButton.height * .5);
			backButton.x = Config.DOUBLE_MARGIN;
			
			
			restoreButton = new BitmapButton();
			restoreButton.setStandartButtonParams();
			restoreButton.setDownScale(1);
			restoreButton.setDownColor(NaN);
			restoreButton.setOverlay(HitZoneType.BUTTON);
			restoreButton.cancelOnVerticalMovement = true;
			restoreButton.tapCallback = onButtonRestoreClick;
			container.addChild(restoreButton);
			
			/*showPassButton = new BitmapButton();
			showPassButton.setStandartButtonParams();
			showPassButton.setDownScale(1);
			showPassButton.setDownColor(NaN);
			showPassButton.setOverlay(HitZoneType.CIRCLE);
			showPassButton.cancelOnVerticalMovement = true;
			showPassButton.tapCallback = null;
			showPassButton.upCallback = hidePass;
			showPassButton.downCallback = showPass;
			showPassButton.setOverflow(Config.FINGER_SIZE * .2, Config.FINGER_SIZE * .2, Config.FINGER_SIZE * .2, Config.FINGER_SIZE * .2);
			showPassButton.setOverlayPadding(Config.FINGER_SIZE * .2);
			container.addChild(showPassButton);
			
			var icon:Sprite = new EyeIcon();
			UI.colorize(icon, Style.color(Style.COLOR_ICON_SETTINGS));
			UI.scaleToFit(icon, Config.FINGER_SIZE * .45, Config.FINGER_SIZE * .45);
			showPassButton.setBitmapData(UI.getSnapshot(icon, StageQuality.HIGH, "PaymentsLoginScreen.icon"));*/
		}
		
		private function onInputChanged():void 
		{
			
		}
		
		private function listenKeyboard():void 
		{
			if (Config.PLATFORM_ANDROID == true)
			{
			//	MobileGui.androidExtension.addEventListener(StatusEvent.STATUS, extensionAndroidStatusHandler);
			}
			else if (Config.PLATFORM_APPLE == true)
			{
				MobileGui.dce.addEventListener(StatusEvent.STATUS, statusHandlerApple);
			}
		}
		
		private function statusHandlerApple(e:StatusEvent):void {
			var data:Object;
			switch (e.code) {
				
				case "inputViewHeightChangeStart":
				case "inputViewKeyboardShowStart":
				case "inputViewKeyboardHideStart":
				case "inputViewHeightChangeEnd":
				case "inputViewKeyboardShowEnd":
				case "inputViewKeyboardHideEnd": {
					data = JSON.parse(e.level);
					
					if ("inputViewHeight" in data)
					{
						if (keyboardHeight != data.inputViewHeight)
						{
							keyboardHeight = data.inputViewHeight;
							drawView();
						}
					}
					break;
				}
			}
		}
		
		private function extensionAndroidStatusHandler(e:StatusEvent):void
		{
			if (e.code == "keyboardHeight")
			{
				keyboardHeight = parseInt(e.level);
				updateOnNative();
			}
		}
		
		private function updateOnNative():void 
		{
		//	TweenMax.killDelayedCallsTo(drawView);
		//	TweenMax.delayedCall(0.5, drawView);
			
			drawView();
		}
		
		private function onButtonRestoreClick():void 
		{
			if (restoreButton != null && restoreButton.alpha < 1)
			{
				return;
			}
			
			if (locked == true) {
				return;
			}
			if (inAnimation == true) {
				return;
			}
			if (state == STATE_PASSWORD) {
				toState(STATE_ENTER_EMAIL);
			}
		}
		
		private function onButtonOkClick():void 
		{
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
				//	input.text = "";
				}
			} else if (state == STATE_ENTER_EMAIL) {
				
				if (input.text != getDefValue())
				{
					locked = true;
					showPreloader();
					
					currentEmail = input.text;
					PayAPIManager.S_PASS_REMIND_ERROR.add(onEmailError);
					PayAPIManager.S_PASS_REMIND.add(onEmailRespond);
					
					PayAPIManager.remindPassword(currentEmail);
				}
				
			} else if (state == STATE_ENTER_CODE) {
				locked = true;
				showPreloader();
				
				PayAPIManager.S_PASS_REMIND_ERROR.add(onCodeError);
				PayAPIManager.S_PASS_REMIND.add(onCodeRespond);
				
				PayAPIManager.remindPassword(currentEmail, input.text, currentTocken);
			} else if (state == STATE_RESTORE_SUCCESS) {
				fireCallbackFunctionWithValue(0);
				input.text = "";
			}
		}
		
		private function showPreloader():void 
		{
			if (preloader == null)
			{
				preloader = new CirclePreloader(NaN, NaN, Color.WHITE);
				preloader.x = int(_width * .5);
				preloader.y = int(_height * .5);
				view.addChild(preloader);
			}
			if (inHideAnimation == false)
			{
				TweenMax.killTweensOf(container);
				TweenMax.to(container, 0.3, {colorTransform:{brightness: 0.5}, delay:0.3});
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
			hidePreloader();
			
			if (success == true) {
				NativeExtensionController.clearFingerprint();
				toState(STATE_RESTORE_SUCCESS);
			}
		}
		
		private function hidePreloader():void 
		{
			if (preloader != null)
			{
				if (view.contains(preloader))
				{
					view.removeChild(preloader);
				}
				preloader.dispose();
				preloader = null;
			}
			if (inHideAnimation == false)
			{
				TweenMax.killTweensOf(container);
				TweenMax.to(container, 0.3, {colorTransform:{brightness: 1}});
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
			hidePreloader();
			
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
			hidePreloader();
			
			nextState = newState;
			inAnimation = true;
			
			hideCurrentState();
		}
		
		private function updateInputViewport(inputAnimation:Object):void
		{
			if (isDisposed)
			{
				return;
			}
			if (input != null)
			{
				input.viewPort = new Rectangle(inputAnimation.x, 
											   input.viewPort.y, 
											   input.viewPort.width, 
											   input.viewPort.height);
			}
			if (fingerprintButton != null)
			{
				fingerprintButton.x = int(input.viewPort.x + _width - contentPadding * 2 - fingerprintButton.width);
			}
		}
		
		private function hideCurrentState():void 
		{
			var inputAnimation:Object = new Object();
			inputAnimation.startX = input.viewPort.x;
			inputAnimation.endX = input.viewPort.x - _width;
			inputAnimation.x = input.viewPort.x;
			var hideTime:Number = 0.6;
			var delay:Number = 0.3;
			var delayDiff:Number = 0.007;
			if (state == STATE_PASSWORD)
			{
				TweenMax.to(logo,           hideTime, {x:okButton.x - _width, ease:Power3.easeIn, delay:delay});
				delay += delayDiff;
				TweenMax.to(description,    hideTime, {x:description.x - _width, ease:Power3.easeIn, delay:delay});
				delay += delayDiff;
				TweenMax.to(inputAnimation, hideTime, {x:inputAnimation.endX, ease:Power3.easeIn, onUpdate:updateInputViewport, onUpdateParams:[inputAnimation], delay:delay});
				delay += delayDiff;
				TweenMax.to(inputBottom,    hideTime, {x:inputBottom.x - _width, ease:Power3.easeIn, delay:delay});
				delay += delayDiff;
				TweenMax.to(restoreButton,  hideTime, {x:restoreButton.x - _width, ease:Power3.easeIn, delay:delay});
				delay += delayDiff;
				TweenMax.to(okButton,  hideTime, {x:okButton.x - _width, ease:Power3.easeIn, delay:delay, onComplete:onStateHide});
				delay += delayDiff;
			//	TweenMax.to(backButton,  hideTime, {x:backButton.x - _width, ease:Power3.easeIn, delay:delay});
			}
			else if (state == STATE_ENTER_EMAIL)
			{
				TweenMax.to(logo,           hideTime, {x:okButton.x - _width, ease:Power3.easeIn, delay:delay});
				delay += delayDiff;
				TweenMax.to(description,    hideTime, {x:description.x - _width, ease:Power3.easeIn, delay:delay});
				delay += delayDiff;
				TweenMax.to(inputAnimation, hideTime, {x:inputAnimation.endX, ease:Power3.easeIn, onUpdate:updateInputViewport, onUpdateParams:[inputAnimation], delay:delay});
				delay += delayDiff;
				TweenMax.to(inputBottom,    hideTime, {x:inputBottom.x - _width, ease:Power3.easeIn, delay:delay});
				delay += delayDiff;
				TweenMax.to(okButton,  hideTime, {x:okButton.x - _width, ease:Power3.easeIn, delay:delay, onComplete:onStateHide});
				delay += delayDiff;
			//	TweenMax.to(backButton,  hideTime, {x:backButton.x - _width, ease:Power3.easeIn, delay:delay});
			}
			else if (state == STATE_ENTER_CODE)
			{
				TweenMax.to(logo,           hideTime, {x:okButton.x - _width, ease:Power3.easeIn, delay:delay});
				delay += delayDiff;
				TweenMax.to(description,    hideTime, {x:description.x - _width, ease:Power3.easeIn, delay:delay});
				delay += delayDiff;
				TweenMax.to(inputAnimation, hideTime, {x:inputAnimation.endX, ease:Power3.easeIn, onUpdate:updateInputViewport, onUpdateParams:[inputAnimation], delay:delay});
				delay += delayDiff;
				TweenMax.to(inputBottom,    hideTime, {x:inputBottom.x - _width, ease:Power3.easeIn, delay:delay});
				delay += delayDiff;
				TweenMax.to(okButton,  hideTime, {x:okButton.x - _width, ease:Power3.easeIn, delay:delay, onComplete:onStateHide});
				delay += delayDiff;
			//	TweenMax.to(backButton,  hideTime, {x:backButton.x - _width, ease:Power3.easeIn, delay:delay});
			}
		}
		
		private function onStateHide():void 
		{
			changeState();
		}
		
		private function changeState():void {
			state = nextState;
			if (state == STATE_ENTER_EMAIL) {
				removeRestoreButton();
				removeShowPassButton();
				removeFingerprintButton();
				input.displayAsPassword = false
				input.text = Lang.enterEmail;
			} else if (state == STATE_ENTER_CODE) {
				removeRestoreButton();
				removeShowPassButton();
				removeFingerprintButton();
				input.displayAsPassword = false;
				input.text = Lang.enterCode;
			} else if (state == STATE_PASSWORD) {
				addRestoreButton();
				addShowPassButton();
				addFingerprintButton();
				input.displayAsPassword = true;
				input.text = "";
			} else if (state == STATE_RESTORE_SUCCESS) {
				removeRestoreButton();
				removeFingerprintButton();
				input.visible = false;
				removeShowPassButton();
			}
			
			redrawComponents();
			
			startDescriptinPosition = NaN;
			setInitialYPositions();
			updateInputOnScreenResize();
			showNextState();
		}
		
		private function addFingerprintButton():void 
		{
			trace("finger addFingerprintButton");
			if (fingerprintButton != null)
			{
				container.addChild(fingerprintButton);
			}
		}
		
		private function removeFingerprintButton():void 
		{
			if (fingerprintButton != null && container.contains(fingerprintButton))
			{
				container.removeChild(fingerprintButton);
			}
		}
		
		private function showNextState():void 
		{
			var inputAnimation:Object = new Object();
			inputAnimation.startX = contentPadding + _width;
			inputAnimation.endX = contentPadding;
			inputAnimation.x = contentPadding + _width;
			var showTime:Number = 0.5;
			var delay:Number = 0.2;
			var delayDiff:Number = 0.01;
			
			if (state == STATE_PASSWORD)
			{
				logo.x = _width * .5 - logo.width*.5 + _width;
				description.x = contentPadding + _width;
				inputBottom.x = _width * .5 - inputBottom.width*.5 + _width;
				restoreButton.x = _width * .5 - restoreButton.width*.5 + _width;
				okButton.x = _width * .5 - okButton.width*.5 + _width;
			//	backButton.x = _width * .5 - backButton.width * .5 + _width;
				if (fingerprintButton != null)
				{
					fingerprintButton.x = int(input.viewPort.x + _width - contentPadding * 2 - fingerprintButton.width);
				}
				
				TweenMax.to(logo,           showTime, {x:int(_width * .5 - logo.width*.5), ease:Power3.easeOut, delay:delay});
				delay += delayDiff;
				TweenMax.to(description,    showTime, {x:contentPadding, ease:Power3.easeOut, delay:delay});
				delay += delayDiff;
				TweenMax.to(inputAnimation, showTime, {x:inputAnimation.endX, ease:Power3.easeOut, onUpdate:updateInputViewport, onUpdateParams:[inputAnimation], delay:delay});
				delay += delayDiff;
				TweenMax.to(inputBottom,    showTime, {x:contentPadding, ease:Power3.easeOut, delay:delay});
				delay += delayDiff;
				TweenMax.to(restoreButton,  showTime, {x:int(_width * .5 - restoreButton.width * .5), ease:Power3.easeOut, delay:delay});
				delay += delayDiff;
				TweenMax.to(okButton,  showTime, {x:int(_width * .5 - okButton.width * .5), ease:Power3.easeOut, delay:delay, onComplete:onStateShow});
				delay += delayDiff;
			//	TweenMax.to(backButton,  showTime, {x:int(_width * .5 - backButton.width * .5), ease:Power3.easeOut, delay:delay});
			}
			else if (state == STATE_ENTER_EMAIL)
			{
				logo.x = _width * .5 - logo.width*.5 + _width;
				description.x = contentPadding + _width;
				inputBottom.x = _width * .5 - inputBottom.width*.5 + _width;
				restoreButton.x = _width * .5 - restoreButton.width*.5 + _width;
				okButton.x = _width * .5 - okButton.width*.5 + _width;
			//	backButton.x = _width * .5 - backButton.width*.5 + _width;
				
				TweenMax.to(logo,           showTime, {x:int(_width * .5 - logo.width*.5), ease:Power3.easeOut, delay:delay});
				delay += delayDiff;
				TweenMax.to(description,    showTime, {x:contentPadding, ease:Power3.easeOut, delay:delay});
				delay += delayDiff;
				TweenMax.to(inputAnimation, showTime, {x:inputAnimation.endX, ease:Power3.easeOut, onUpdate:updateInputViewport, onUpdateParams:[inputAnimation], delay:delay});
				delay += delayDiff;
				TweenMax.to(inputBottom,    showTime, {x:contentPadding, ease:Power3.easeOut, delay:delay});
				delay += delayDiff;
				TweenMax.to(okButton,  showTime, {x:int(_width * .5 - okButton.width * .5), ease:Power3.easeOut, delay:delay, onComplete:onStateShow});
				delay += delayDiff;
			//	TweenMax.to(backButton,  showTime, {x:int(_width * .5 - backButton.width * .5), ease:Power3.easeOut, delay:delay});
			}
			else if (state == STATE_ENTER_CODE)
			{
				logo.x = _width * .5 - logo.width*.5 + _width;
				description.x = contentPadding + _width;
				inputBottom.x = _width * .5 - inputBottom.width*.5 + _width;
				restoreButton.x = _width * .5 - restoreButton.width*.5 + _width;
				okButton.x = _width * .5 - okButton.width*.5 + _width;
			//	backButton.x = _width * .5 - backButton.width*.5 + _width;
				
				TweenMax.to(logo,           showTime, {x:int(_width * .5 - logo.width*.5), ease:Power3.easeOut, delay:delay});
				delay += delayDiff;
				TweenMax.to(description,    showTime, {x:contentPadding, ease:Power3.easeOut, delay:delay});
				delay += delayDiff;
				TweenMax.to(inputAnimation, showTime, {x:inputAnimation.endX, ease:Power3.easeOut, onUpdate:updateInputViewport, onUpdateParams:[inputAnimation], delay:delay});
				delay += delayDiff;
				TweenMax.to(inputBottom,    showTime, {x:contentPadding, ease:Power3.easeOut, delay:delay});
				delay += delayDiff;
				TweenMax.to(okButton,  showTime, {x:int(_width * .5 - okButton.width * .5), ease:Power3.easeOut, delay:delay, onComplete:onStateShow});
				delay += delayDiff;
			//	TweenMax.to(backButton,  showTime, {x:int(_width * .5 - backButton.width * .5), ease:Power3.easeOut, delay:delay});
			}
			else if (state == STATE_RESTORE_SUCCESS)
			{
				logo.x = _width * .5 - logo.width*.5 + _width;
				description.x = contentPadding + _width;
				inputBottom.x = _width * .5 - inputBottom.width*.5 + _width;
				restoreButton.x = _width * .5 - restoreButton.width*.5 + _width;
				okButton.x = _width * .5 - okButton.width*.5 + _width;
			//	backButton.x = _width * .5 - backButton.width*.5 + _width;
				
				TweenMax.to(logo,           showTime, {x:int(_width * .5 - logo.width*.5), ease:Power3.easeOut, delay:delay});
				delay += delayDiff;
				TweenMax.to(description,    showTime, {x:contentPadding, ease:Power3.easeOut, delay:delay});
				delay += delayDiff;
				TweenMax.to(okButton,  showTime, {x:int(_width * .5 - okButton.width * .5), ease:Power3.easeOut, delay:delay, onComplete:onStateShow});
			}
		}
		
		private function onStateShow():void 
		{
			inAnimation = false;
		}
		
		private function removeOkButton():void 
		{
			if (okButton != null && container.contains(okButton))
			{
				container.removeChild(okButton);
			}
		}
		
		private function removeShowPassButton():void 
		{
			/*if (showPassButton != null && container.contains(showPassButton))
			{
				container.removeChild(showPassButton);
			}*/
		}
		
		private function removeRestoreButton():void 
		{
			if (restoreButton != null && container.contains(restoreButton))
			{
				container.removeChild(restoreButton);
			}
		}
		
		private function addShowPassButton():void 
		{
			/*if (showPassButton != null)
			{
				container.addChild(showPassButton);
			}*/
		}
		
		private function addRestoreButton():void 
		{
			if (restoreButton != null)
			{
				container.addChild(restoreButton);
			}
		}
		
		private function changeStateComplete():void {
			inAnimation = false;
		}
		
		private function onButtonBackClick():void 
		{
			if (locked == true) {
				return;
			}
			if (inAnimation == true) {
				return;
			}
			if (state == STATE_ENTER_EMAIL) {
				toState(STATE_PASSWORD);
			} else if (state == STATE_PASSWORD) {
				fireCallbackFunctionWithValue(0);
				input.text = "";
			} else if (state == STATE_ENTER_CODE) {
				toState(STATE_ENTER_EMAIL);
			}

			GD.S_PAYPASS_BACK_CLICK.invoke();
		}
		
		private function fingerprintClick():void 
		{
			if (Config.PLATFORM_APPLE)
			{
				if (MobileGui.touchIDManager != null) {
					MobileGui.touchIDManager.callbackFunction = function(val:int, secret:String = ""):void {
						if (val == 0) {
							return;
						}
						TweenMax.delayedCall(0.5, fillPass, [secret]);
					};
					if (MobileGui.touchIDManager.getSecretFrom() == false) {
						MobileGui.touchIDManager.callbackFunction = null;
					}
					return;
				}
			}
			else if (Config.PLATFORM_ANDROID)
			{
				if (fingerprint != null)
				{
					return;
				}
				fingerprint = new FingerprintScreen();
				
				container.addChild(fingerprint.view);
				fingerprint.setInitialSize(_width, _height);
				fingerprint.setWidthAndHeight(_width, _height);
				fingerprint.initScreen({onClosed:onFingerprintClosed, callback:onFingerprintSuccess});
				fingerprint.activateScreen();
				deactivateScreen();
			}
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
				onButtonOkClick();
			}
		}
		
		private function onFingerprintClosed():void 
		{
			activateScreen();
			if (fingerprint != null)
			{
				container.removeChild(fingerprint.view);
				fingerprint.dispose();
				fingerprint = null;
			}
		}
		
		override public function onBack(e:Event = null):void
		{
			if (fingerprint != null)
			{
				fingerprint.close();
			}
			else
			{
				fireCallbackFunctionWithValue(0);
			}
		}
		
		private function drawButtonOK(text:String):void {
			var textSettings:TextFieldSettings = new TextFieldSettings(text, Color.WHITE, FontSize.BODY, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, Color.GREEN, 1, -1, NaN, _width - contentPadding * 2, Config.FINGER_SIZE * .3, Style.size(Style.SIZE_BUTTON_CORNER));
			okButton.setBitmapData(buttonBitmap, true);
		}
		
		private function drawButtonRestore(text:String):void {
			var textSettings:TextFieldSettings = new TextFieldSettings(text, Color.WHITE, FontSize.BODY, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, 0, 0, -1, NaN, _width - contentPadding * 2, Config.FINGER_SIZE * .3, Style.size(Style.SIZE_BUTTON_CORNER));
			restoreButton.setBitmapData(buttonBitmap, true);
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			state = STATE_PASSWORD;
			
			contentPadding = Config.FINGER_SIZE * .7;
			
			NativeExtensionController.payPassByFingerprint = false;
			if (data != null && "callBack" in data && data.callBack != null && data.callBack is Function) {
				callBack = data.callBack as Function;
			}
		//	NativeExtensionController.setStatusBarColor(getBackColor());
			redrawComponents();
			
			drawLogo();
			
			var illustration:BitmapData = new (Style.icon(Style.PAYMENTS_LOGIN_IMAGE))();
			backImage.bitmapData = TextUtils.scaleBitmapData(illustration, _width / illustration.width);
			if (backImage.bitmapData.height > _height)
			{
				backImage.y = 0;
				var newBackBitmap:ImageBitmapData = new ImageBitmapData("paymentsBitmap", _width, _height);
				newBackBitmap.copyPixels(backImage.bitmapData, new Rectangle(0, 0, _width, backImage.bitmapData.height), new Point(0, _height - backImage.bitmapData.height));
				backImage.bitmapData.dispose();
				backImage.bitmapData = null;
				backImage.bitmapData = newBackBitmap;
			}
			else
			{
				backImage.y = int(_height - backImage.height);
			}
			if (illustration != null)
			{
				illustration.dispose();
				illustration = null;
			}
			background.graphics.beginFill(Style.color(Style.PAYMENTS_LOGIN_BACK_COLOR));
			background.graphics.drawRect(0, 0, _width, _height);
			background.graphics.endFill();
			
			inputBottom.width = _width - contentPadding * 2;
			inputBottom.x = contentPadding;
			
			setInitialXPositions();
			
			setInitialYPositions(true);
			
			container.y = _height;
			container.alpha = 0.5;
			
			listenKeyboard();
		}
		
		private function getBackColor():Number 
		{
			return 0;
		}
		
		private function redrawComponents():void 
		{
			drawTitle(getDescription());
			drawButtonOK(getNextButtonText());
		//	drawButtonBack(Lang.textBack);
			drawButtonRestore(Lang.restorePassword);
			if (fingerprintButton != null)
			{
				drawFingerprintButton();
			}
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
				text = Lang.textOk;
			}
			return text;
		}
		
		private function drawFingerprintButton():void 
		{
			var IconClass:Class;
			if (Config.APPLE_BOTTOM_OFFSET > 0 && Config.PLATFORM_APPLE)
			{
				IconClass = Style.icon(Style.ICON_FACE_ID);
			}
			else
			{
				IconClass = FingerprintIcon;
			}
			
			var icon:Sprite = new IconClass();
			UI.colorize(icon, Style.color(Style.COLOR_ICON_SETTINGS));
			UI.scaleToFit(icon, Config.FINGER_SIZE * .6, Config.FINGER_SIZE * .6);
			fingerprintButton.setBitmapData(UI.getSnapshot(icon), true);
		}
		
		private function drawLogo():void 
		{
			var logoImage:Sprite = new (Style.icon(Style.ICON_PAYMENTS_LOGO))();
			UI.scaleToFit(logoImage, _width - contentPadding * 2 - Config.FINGER_SIZE, Config.FINGER_SIZE * 0.9);
			logo.bitmapData = UI.getSnapshot(logoImage);
			UI.destroy(logoImage);
		}
		
		private function drawTitle(text:String):void 
		{
			if (description.bitmapData != null)
			{
				description.bitmapData.dispose();
				description.bitmapData = null;
			}
			
			description.bitmapData = TextUtils.createTextFieldData(
				text,
				_width - contentPadding * 2,
				10,
				true,
				TextFormatAlign.LEFT,
				TextFieldAutoSize.LEFT,
				FontSize.BODY,
				true,
				Style.color(Style.COLOR_TEXT)
			);
		}
		
		private function setInitialXPositions():void 
		{
			description.x = contentPadding;
			
		//	backButton.x = int(_width * .5 - backButton.width * .5);
			
			okButton.x = int(_width * .5 - okButton.width * .5);
			
			restoreButton.x = int(_width * .5 - restoreButton.width * .5);
			
			logo.x = int(_width * .5 - logo.width * .5);
			
			input.viewPort.x = contentPadding;
			
			if (fingerprintButton != null)
			{
				fingerprintButton.x = int(_width - contentPadding - fingerprintButton.width);
			}
		}
		
		private function setInitialYPositions(firstTime:Boolean = false):void 
		{
			initialHeight = _height;
			
			description.y = int(_height * .5 - description.height - Config.FINGER_SIZE * .6);
			
			okButton.y = int(_height - Config.APPLE_BOTTOM_OFFSET - contentPadding - Config.FINGER_SIZE * .7 - okButton.height - Config.FINGER_SIZE * .3);
			
			restoreButton.y = int(okButton.y - restoreButton.fullHeight - Config.FINGER_SIZE * .3);
			
			inputHeight = Config.FINGER_SIZE * .85;
			
			if (state == STATE_PASSWORD)
			{
				if(restoreButton != null && restoreButton.y - Config.FINGER_SIZE * 0.8 - inputHeight < description.y + description.height)
				{
					description.y = restoreButton.y - Config.FINGER_SIZE * 0.8 - inputHeight - description.height;
				}
			}
			else
			{
				if(okButton != null && okButton.y - Config.FINGER_SIZE * 0.8 - inputHeight < description.y + description.height)
				{
					description.y = okButton.y - Config.FINGER_SIZE * 0.8 - inputHeight - description.height;
				}
			}
			
			logo.y = int(description.y * .5 - logo.height * .5);
			
			
			var positionInput:int = description.y + description.height;
			var positionText:int = positionInput + inputHeight * .5 - Config.FINGER_SIZE * .6 * .5;
			var buttonWidth:int = 0;
			if (fingerprintButton != null)
			{
				buttonWidth = fingerprintButton.width;
			}
			buttonWidth = Config.FINGER_SIZE;
			
			var inputX:int;
			if (firstTime == true)
			{
				inputX = contentPadding;
			}
			else
			{
				inputX = input.viewPort.x;
			}
			input.viewPort = new Rectangle(inputX, 
											positionText, 
											_width - contentPadding*2 - Config.FINGER_SIZE*.2 - buttonWidth, 
											inputHeight);
			inputBottom.y = int(positionInput + inputHeight);
			
			if (fingerprintButton != null)
			{
				fingerprintButton.y = int(positionInput + inputHeight * .5 - fingerprintButton.height * .5);
			}
			
			updateFingerprintButtonPosition();
		}
		
		private function updateFingerprintButtonPosition(loadFingerprintStatus:Boolean = true):void 
		{
			if (input.visible == true)
			{
				var fingerprintWidth:int = 0;
				
				if (loadFingerprintStatus && fingerprintButton == null && Config.PLATFORM_ANDROID && MobileGui.androidExtension.fingerprint_pinExist() == true && MobileGui.androidExtension.fingerprint_avaliable() == true)
				{
					Store.load(Store.USE_FINGERPRINT, onFingerprintStatusLoaded);
				}
				else if (loadFingerprintStatus && fingerprintButton == null && Config.PLATFORM_APPLE && 
						NativeExtensionController.touchIDManager != null && NativeExtensionController.touchIDManager.useTouchID)
				{
				//	ToastMessage.display("123");
					
					Store.load(Store.USE_FINGERPRINT, onFingerprintStatusLoaded);
				}
				else if(fingerprintButton != null)
				{
					if (fingerprintButtonAvaliable() == true)
					{
						savedPinExist = NativeExtensionController.bankPinExist();
						if (savedPinExist == true)
						{
							fingerprintWidth = fingerprintButton.width + Config.MARGIN * 3.7;
						}
					}
				}
			}
		}
		
		private function onFingerprintStatusLoaded(data:Boolean, error:Boolean):void 
		{
			if (isDisposed == true)
			{
				return;
			}
			if (error == true || data == true)
			{
				if (fingerprintButton == null)
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
					
					if (state == STATE_PASSWORD)
					{
						container.addChild(fingerprintButton);
					}
					
					fingerprintButton.x = int(_width - contentPadding - fingerprintButton.width);
					fingerprintButton.y = int(description.y + description.height + inputHeight * .5 - fingerprintButton.height * .5);
					
					updateFingerprintButtonPosition(false);
					
					
					
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
		
		private function callbackTouchID(secret:String = ""):void {
			input.text = secret;
			input.displayAsPassword = true;
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
		
		override public function activateScreen():void {
			super.activateScreen();
			
			if (firstTime) {
				firstTime = false;
				
				var showTime:Number = 0.5;
				TweenMax.to(container, showTime, { y:0, ease:Power4.easeOut, onComplete:animationFinished, delay:0.5 } );
				TweenMax.to(container, showTime, { alpha:1, delay:0.5 } );
				
				return;
			}
			input.addEventListener(FocusEvent.FOCUS_IN, onTextFocusIn);
			input.addEventListener(FocusEvent.FOCUS_OUT, onTextFocusOut);
			input.addEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_ACTIVATE, onSKActivate);
			input.addEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_ACTIVATING, onSKActivating);
			input.addEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_DEACTIVATE, onSKDeactivating);
			
			if (state == STATE_PASSWORD) {
				//!TODO:;
				okButton.activate();
				backButton.activate();
				restoreButton.activate();
				if (fingerprintButton != null)
				{
					fingerprintButton.activate();
				}
			}
			
			input.visible = true;
			
		//	onButtonOkClick();
		}
		
		private function onSKActivate(e:SoftKeyboardEvent):void {
			invokeSoftkeyboard(true);
		}
		
		private function invokeSoftkeyboard(val:Boolean):void 
		{
			TweenMax.delayedCall(10, function():void {
				Input.S_SOFTKEYBOARD.invoke(val);
			}, null, true);
		}
		
		private function onSKActivating(e:SoftKeyboardEvent):void {
			invokeSoftkeyboard(true);
		}
		
		private function onSKDeactivating(e:SoftKeyboardEvent):void {
			invokeSoftkeyboard(false);
		}
		
		private function hidePass(e:Event = null):void 
		{
			if (input != null && input.text != getDefValue())
			{
				input.displayAsPassword = true;
			}
		}
		
		private function showPass(e:Event = null):void 
		{
			if (input != null)
			{
				input.displayAsPassword = false;
			}
		}
		
		protected function close(e:Event = null):void {
			if (isDisposed == true)
			{
				return;
			}
			
			TweenMax.killDelayedCallsTo(close);
			
			deactivateScreen();
			inHideAnimation = true;
			TweenMax.to(container, 0.3, { y:initialHeight, onComplete:remove, ease:Power2.easeIn } );
		}
		
		private function remove():void {
			dialogClosed = true;
			if (callBack != null) {
				fireCallbackFunctionWithValue(callbackValue);
			}
			DialogManager.closeDialog();
		}
		
		protected function animationFinished():void 
		{
			activateScreen();
		}
		
		private function onTextFocusIn(e:FocusEvent = null):void 
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
		
		private function updateCarret():void 
		{
			
		}
		
		private function onTextFocusOut(e:FocusEvent = null):void 
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
		
		private function fingerprintButtonAvaliable():Boolean 
		{
			if (Config.PLATFORM_ANDROID == true && state == STATE_PASSWORD)
			{
				return true;
			}
			return false;
		}
		
		private function fireCallbackFunctionWithValue(value:int):void {
			if (callBack != null) {
				if (dialogClosed == true)
				{
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
				else
				{
					callbackValue = value;
					close();
				}
			}
			else
			{
				close();
			}
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
		//	input.deactivate();
		//	input.S_FOCUS_IN.remove(onTextFocusIn);
		//	input.S_FOCUS_OUT.remove(onTextFocusOut);
			
			input.removeEventListener(FocusEvent.FOCUS_IN, onTextFocusIn);
			input.removeEventListener(FocusEvent.FOCUS_OUT, onTextFocusOut);
			input.removeEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_ACTIVATE, onSKActivate);
			input.removeEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_ACTIVATING, onSKActivating);
			input.removeEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_DEACTIVATE, onSKDeactivating);
			
			if (state == STATE_PASSWORD) {
				//!TODO:;
				okButton.deactivate();
				backButton.deactivate();
				restoreButton.deactivate();
			//	showPassButton.deactivate();
				if (fingerprintButton != null)
				{
					fingerprintButton.deactivate();
				}
			}
			
			input.visible = false;
		}
		
		override protected function drawView():void {
			var maxHeight:int = initialHeight - keyboardHeight;
			
			if (keyboardHeight == 0)
			{
				maxHeight = _height;
			}
			
			if (fingerprint != null)
			{
				fingerprint.setWidthAndHeight(_width, maxHeight);
				fingerprint.updatePositions();
			}
			
			trace("UPDATEP", maxHeight, keyboardHeight, lastHeight);
			
			if (initialHeight != maxHeight)
			{
				if (lastHeight > maxHeight)
				{
					if (state == STATE_PASSWORD && input.displayAsPassword == false)
					{
						input.displayAsPassword = true;
					}
					
					animateMinimize(maxHeight);
				}
				else
				{
					animateMaximize(maxHeight);
				}
			}
			else
			{
				animateMaximize(maxHeight);
				drawFullscreen();
			}
			
			lastHeight = maxHeight;
		}
		
		private function animateMaximize(localHeight:int):void 
		{
			trace("animateMaximize", localHeight);
			
			var animationTime:Number = 0.2;
			
			if (inHideAnimation == false) {
				TweenMax.to(logo, 0.2, {alpha:(Math.min(Math.max(1 - (initialHeight - localHeight) / (Config.FINGER_SIZE * 3), 0), 1))});
				TweenMax.to(restoreButton, 0.2, {alpha:(Math.min(Math.max(1 - (initialHeight - localHeight) / (Config.FINGER_SIZE * 3), 0), 1))});
			}
			
			var okButtonPosition:int;
			var restoreButtonPosition:int;
			var descriptionPosition:int;
			var logoPosition:int;
			
			
			descriptionPosition = int(_height * .5 - description.height - Config.FINGER_SIZE * .6);
			
			okButtonPosition = int(_height - Config.APPLE_BOTTOM_OFFSET - contentPadding - Config.FINGER_SIZE * .7 - okButton.height - Config.FINGER_SIZE * .3);
			
			restoreButtonPosition = int(okButtonPosition - restoreButton.fullHeight - Config.FINGER_SIZE * .3);
			
			inputHeight = Config.FINGER_SIZE * .85;
			
			if (state == STATE_PASSWORD)
			{
				if(restoreButton != null && restoreButtonPosition - Config.FINGER_SIZE * 0.8 - inputHeight < descriptionPosition + description.height)
				{
					descriptionPosition = restoreButtonPosition - Config.FINGER_SIZE * 0.8 - inputHeight - description.height;
				}
			}
			else
			{
				if(okButton != null && okButtonPosition - Config.FINGER_SIZE * 0.8 - inputHeight < descriptionPosition + description.height)
				{
					descriptionPosition =okButtonPosition - Config.FINGER_SIZE * 0.8 - inputHeight - description.height;
				}
			}
			
			logoPosition = int(descriptionPosition * .5 - logo.height * .5);
			
			
			TweenMax.to(description,   animationTime, {y:descriptionPosition, onUpdate:updateInputOnScreenResize});
			TweenMax.to(okButton,      animationTime, {y:okButtonPosition});
			TweenMax.to(restoreButton, animationTime, {y:restoreButtonPosition});
			TweenMax.to(logo,          animationTime, {y:logoPosition});
		}
		
		private function drawFullscreen():void 
		{
			if (state == STATE_PASSWORD)
			{
				restoreButton.activate();
			}
		}
		
		private function animateMinimize(localHeight:Number):void 
		{
			trace("animateMinimize", localHeight);
			
			var animationTime:Number = 0.2;
			
			if (inHideAnimation == false) {
				TweenMax.to(logo, 0.2, {alpha:(Math.min(Math.max(1 - (initialHeight - localHeight) / (Config.FINGER_SIZE * 3), 0), 1))});
				TweenMax.to(restoreButton, 0.2, {alpha:(Math.min(Math.max(1 - (initialHeight - localHeight) / (Config.FINGER_SIZE * 3), 0), 1))});
			}
			
			var additionalBottom:int;
			if (initialHeight - localHeight > Config.APPLE_BOTTOM_OFFSET) {
				additionalBottom = 0;
			} else {
				additionalBottom = Config.APPLE_BOTTOM_OFFSET;
			}
			
			var distance:int = (localHeight - description.height - okButton.height - inputHeight) / 3;
			if (distance < 0)
			{
				distance = 0;
			}
			
			var okButtonPosition:int = int(localHeight - okButton.height - distance);
			var restoreButtonPosition:int = int(okButtonPosition - restoreButton.fullHeight - Config.FINGER_SIZE * .3);
			
			var descriptionPosition:int = distance;
			var logoPosition:int = descriptionPosition - int(description.y - logo.y);
			
			TweenMax.to(description,   animationTime, {y:descriptionPosition, onUpdate:updateInputOnScreenResize});
			TweenMax.to(okButton,      animationTime, {y:okButtonPosition});
			TweenMax.to(restoreButton, animationTime, {y:restoreButtonPosition});
			TweenMax.to(logo,          animationTime, {y:logoPosition});
		}
		
		private function updateInputOnScreenResize():void 
		{
			if (isDisposed == true)
			{
				return;
			}
			
			if (restoreButton.alpha < 1) {
				restoreButton.deactivate();
			} else {
				restoreButton.activate();
			}
			
			if (input != null && input.visible)
			{
				var positionInput:int = description.y + description.height;
				var positionText:int = positionInput + inputHeight * .5 - Config.FINGER_SIZE * .6 * .5;
				var buttonWidth:int = 0;
				if (fingerprintButton != null)
				{
					buttonWidth = fingerprintButton.width;
				}
				input.viewPort = new Rectangle(input.viewPort.x, 
												positionText, 
												_width - contentPadding*2 - Config.FINGER_SIZE*.2 - buttonWidth, 
												inputHeight);
											
				
				inputBottom.y = int(positionInput + inputHeight);
				
				if (fingerprintButton != null)
				{
					fingerprintButton.x = int(_width - contentPadding - fingerprintButton.width);
					fingerprintButton.y = int(positionInput + inputHeight * .5 - fingerprintButton.height * .5);
				}
			}
		}
		
		override public function dispose():void {
			if (isDisposed == true) {
				return;
			}
			super.dispose();
			
			Input.S_SOFTKEYBOARD.invoke(false);
			
			TweenMax.killDelayedCallsTo(drawView);
			TweenMax.killDelayedCallsTo(close);
			TweenMax.killDelayedCallsTo(fillPass);
			TweenMax.killTweensOf(container);
			TweenMax.killTweensOf(logo);
			TweenMax.killTweensOf(description);
			TweenMax.killTweensOf(inputBottom);
			TweenMax.killTweensOf(restoreButton);
			TweenMax.killTweensOf(okButton);
			TweenMax.killTweensOf(backButton);
			
			if (MobileGui.androidExtension != null)
			{
				MobileGui.androidExtension.removeEventListener(StatusEvent.STATUS, extensionAndroidStatusHandler);
			}
			if (MobileGui.dce != null)
			{
				MobileGui.dce.removeEventListener(StatusEvent.STATUS, statusHandlerApple);
			}
			
			PayAPIManager.S_PASS_REMIND_ERROR.remove(onEmailError);
			PayAPIManager.S_PASS_REMIND.remove(onEmailRespond);
			
			PayAPIManager.S_PASS_REMIND_ERROR.remove(onCodeError);
			PayAPIManager.S_PASS_REMIND.remove(onCodeRespond);
			
			callBack = null;
			if (preloader != null)
				preloader.dispose();
			preloader = null;
			if (input != null)
			{
				/*input.S_CHANGED.remove(onInputChanged);
				input.S_FOCUS_IN.remove(onTextFocusIn);
				input.S_FOCUS_OUT.remove(onTextFocusOut);*/
				input.removeEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_ACTIVATE, onSKActivate);
				input.removeEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_ACTIVATING, onSKActivating);
				input.removeEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_DEACTIVATE, onSKDeactivating);
				input.stage = null;
				input.dispose();
			}
			input = null;
			if (restoreButton != null)
				restoreButton.dispose();
			restoreButton = null;
			/*if (showPassButton != null)
				showPassButton.dispose();
			showPassButton = null;*/
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
			if (okButton != null)
				okButton.dispose();
			okButton = null;
			if (backButton != null)
				backButton.dispose();
			backButton = null;
			if (fingerprintButton != null)
				fingerprintButton.dispose();
			fingerprintButton = null;
			if (fingerprint != null)
			{
				view.removeChild(fingerprint.view);
				fingerprint.dispose();
				fingerprint = null;
			}
		}
	}
}