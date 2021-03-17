package com.dukascopy.connect.screens {
	
	import assets.IntroBackImage;
	import assets.IntroDogImage;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.CountriesData;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.preloader.Preloader;
	import com.dukascopy.connect.gui.scrollPanel.ScrollPanel;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.dialogs.ScreenCountryPicker;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.pool.Pool;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.StatusEvent;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Timer;
	
	/**
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class AuthScreen extends BaseScreen {
		
		private static const BUTTON_REQUEST_CALL_SHOW_DELAY:int = 60;
		
		private var bg:BitmapData;
		private var scrollPanel:ScrollPanel;
			private var dog:Bitmap;
			private var inptCodeAndPhone:Input;
			private var requestBtn:BitmapButton;
			private var cancelBtn:BitmapButton;
			private var resendBtn:BitmapButton;
			private var requestCallBtn:BitmapButton;
			private var verifyIndicator:Preloader;
			private var privacyTF:TextField;
		
		private var resendDelayTimer:Timer = new Timer(1000);
		private var requestCallDelayTimer:Timer = new Timer(1000);
		
		private var currentPhone:String;
		private var currentCountry:Array;
		
		private var countryPicked:Boolean = false;
		
		private var state:int;
		private var oldWidth:int;
		private var oldHeight:int;
		
		private var firstTime:Boolean = true;
		
		public function AuthScreen() {
			super();
		}
		
		override protected function createView():void {
			super.createView();
			
			scrollPanel = new ScrollPanel();
			scrollPanel.background = false;
					dog = new Bitmap();
						var dogMC:Sprite = new IntroDogImage() as Sprite;
						UI.scaleToFit(dogMC, Config.FINGER_SIZE * 4.5, Config.FINGER_SIZE * 7);
					dog.bitmapData = UI.getSnapshot(dogMC, StageQuality.HIGH, "AuthScreen.dog");
				scrollPanel.addObject(dog);
					inptCodeAndPhone = Pool.getItem(Input) as Input;
					inptCodeAndPhone.setParams(Lang.selectYourCountryCode + "...", Input.MODE_BUTTON);
					inptCodeAndPhone.S_CHANGED.add(onChanged);
					inptCodeAndPhone.S_TAPPED.add(onInputCodeAndPhoneTap);
					inptCodeAndPhone.S_INFOBOX_TAPPED.add(onInputCodeAndPhoneTap);
				scrollPanel.addObject(inptCodeAndPhone.view);
					privacyTF = new TextField();
						var format1:TextFormat = new TextFormat("Tahoma", Config.FINGER_SIZE * .23);
						format1.align = TextFormatAlign.CENTER;
					privacyTF.defaultTextFormat = format1;
					setPrivacyText();
					privacyTF.multiline = true;
					privacyTF.wordWrap = true;
					privacyTF.selectable = false;
				scrollPanel.addObject(privacyTF);
			_view.addChild(scrollPanel.view);
		}
		
		private function setPrivacyText():void {
			var splittingText:Array = Lang.txtPrivacyDC.split("[U]");
			var resultString:String = "";
			var changeFormat:Boolean = false;
			for (var i:int = 0; i < splittingText.length; i++) {
				if (changeFormat == true)
					resultString += "<u><font color='#cd3f43'>" + splittingText[i] + "</font></u>";
				else
					resultString += "<font>" + splittingText[i] + "</font>";
				changeFormat = !changeFormat;
			}
			privacyTF.htmlText = resultString;
		}
		
		override public function onBack(e:Event = null):void {
			DialogManager.alert(Lang.textWarning, Lang.areYouSureQuitApplication, MobileGui.onQuitDialogCallback, Lang.textQuit, Lang.textCancel);
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			_params.title = 'Authorization';
			
			var vectorBack:IntroBackImage = new IntroBackImage();
			var maxH:int = _height;
			var maxW:int = _width;
			vectorBack.width = maxW;
			vectorBack.height = maxH;
			vectorBack.scaleX > vectorBack.scaleY ? vectorBack.scaleY = vectorBack.scaleX : vectorBack.scaleX = vectorBack.scaleY;
			bg = new ImageBitmapData("IntroBack", _width, _height, false);
			bg.drawWithQuality(vectorBack, vectorBack.transform.matrix, vectorBack.transform.colorTransform, null, null, true, StageQuality.HIGH);
			ImageManager.drawGraphicImage(view.graphics, 0, 0, _width, _height, bg);
		}
		
		override protected function drawView():void {
			if (_isDisposed == true)
				return;
			if (_width == oldWidth && _height == oldHeight)
				return;
			oldWidth = _width;
			oldHeight = _height;
			
			setComponentSizes();
			setComponentPositions();
			scrollPanel.setWidthAndHeight(_width, _height, true);
		}
		
		public function setComponentSizes():void {
			if (_isDisposed == true)
				return;
			if (inptCodeAndPhone != null)
				inptCodeAndPhone.width = getButtonWidth();
			if (privacyTF != null) {
				privacyTF.width = _width - Config.DOUBLE_MARGIN * 2;
				privacyTF.width = privacyTF.textWidth + 4;
				privacyTF.height = privacyTF.textHeight + 4;
			}
		}
		
		private function setComponentPositions():void {
			if (_isDisposed == true)
				return;
			var componentsHeight:int = getComponentsHeight();
			var componentsY:int;
			if (state == 0 || state == 1) {
				if (privacyTF != null && privacyTF.parent != null)
					componentsY = (_height - privacyTF.height - Config.MARGIN - componentsHeight) * .5;
				else
					componentsY = (_height - componentsHeight) * .5;
			} else {
				componentsY = (_height - componentsHeight) * .5;
			}
			if (componentsY < Config.APPLE_TOP_OFFSET)
				componentsY = Config.APPLE_TOP_OFFSET;
			if (dog != null) {
				dog.x = int((_width - dog.width) * .5);
				dog.y = componentsY;
				componentsY += dog.height;
			}
			if (inptCodeAndPhone != null) {
				inptCodeAndPhone.view.x = int((_width - inptCodeAndPhone.width) * .5);
				inptCodeAndPhone.view.y = componentsY;
				componentsY += inptCodeAndPhone.height + Config.MARGIN;
			}
			if (requestBtn != null) {
				requestBtn.x = int((_width - requestBtn.width) * .5);
				requestBtn.y = componentsY;
				componentsY += requestBtn.height + Config.MARGIN;
			}
			if (cancelBtn != null && cancelBtn.parent != null && cancelBtn.visible == true) {
				cancelBtn.x = requestBtn.x;
				cancelBtn.y = componentsY;
			}
			if (resendBtn != null && resendBtn.parent != null && resendBtn.visible == true) {
				if (state == 2 && cancelBtn != null && cancelBtn.parent != null)
					resendBtn.x = cancelBtn.x + cancelBtn.width + Config.MARGIN;
				else
					resendBtn.x = int((_width - resendBtn.width) * .5);
				resendBtn.y = componentsY;
				componentsY += resendBtn.height + Config.MARGIN;
			}
			if (requestCallBtn != null && requestCallBtn.parent != null && requestCallBtn.visible == true) {
				requestCallBtn.x = requestBtn.x;
				requestCallBtn.y = componentsY;
			}
			if (privacyTF != null && privacyTF.parent != null) {
				privacyTF.x = int((_width - privacyTF.width) * .5);
				privacyTF.y = _height - privacyTF.height - Config.MARGIN - Config.APPLE_BOTTOM_OFFSET;
				var minY:int = componentsY;
				if (privacyTF.y < minY)
					privacyTF.y = minY;
			}
			scrollPanel.update();
		}
		
		private function getComponentsHeight():int {
			if (_isDisposed == true)
				return 0;
			var res:int;
			if (state == 0) {
				if (dog != null)
					res += dog.height;
				if (inptCodeAndPhone != null)
					res += inptCodeAndPhone.height;
				return res;
			}
			if (state == 1) {
				if (dog != null)
					res += dog.height;
				if (inptCodeAndPhone != null)
					res += inptCodeAndPhone.height;
				if (requestBtn != null)
					res += requestBtn.height + Config.MARGIN;
				if (resendBtn != null)
					res += resendBtn.height + Config.MARGIN;
				return res;
			}
			if (state == 2) {
				if (dog != null)
					res += dog.height;
				if (inptCodeAndPhone != null)
					res += inptCodeAndPhone.height;
				if (requestBtn != null)
					res += requestBtn.height + Config.MARGIN;
				if (resendBtn != null && resendBtn.visible == true && resendBtn.parent != null)
					res += resendBtn.height + Config.MARGIN;
				if (requestCallBtn != null && requestCallBtn.visible == true && requestCallBtn.parent != null)
					res += requestCallBtn.height + Config.MARGIN;
				return res;
			}
			return 0;
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			if (_isDisposed == true)
				return;
			if (firstTime == true) {
				firstTime = false;
				PHP.call_gelLocation(onLocationGetted);
			}
			if (scrollPanel != null)
				scrollPanel.enable();
			if (inptCodeAndPhone != null)
				inptCodeAndPhone.activate();
			if (cancelBtn != null)
				cancelBtn.activate();
			onChanged();
			if (resendBtn != null)
				resendBtn.activate();
			if (privacyTF != null && privacyTF.parent != null)
				PointerManager.addTap(privacyTF, showPrivacy);
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed == true)
				return;
			if (scrollPanel != null)
				scrollPanel.disable();
			if (inptCodeAndPhone != null)
				inptCodeAndPhone.deactivate();
			if (cancelBtn != null)
				cancelBtn.deactivate();
			if (requestBtn != null)
				requestBtn.deactivate();
			if (resendBtn != null)
				resendBtn.deactivate();
			if (privacyTF != null && privacyTF.parent != null)
				PointerManager.removeTap(privacyTF, showPrivacy);
		}
		
		override public function drawViewLang():void {
			var bitmapPlane:ImageBitmapData;
			if (requestBtn != null && requestBtn.tapCallback == onBtnVerifyCodeClick) {
				inptCodeAndPhone.setLabelText(Lang.enterVerifyCode);
				renderBtn(requestBtn, Lang.verifyCode, getButtonWidth());
			} else {
				if (inptCodeAndPhone.getMode() == Input.MODE_BUTTON)
					inptCodeAndPhone.setLabelText(Lang.selectYourCountryCode + '...');
				else
					inptCodeAndPhone.setLabelText(Lang.enterYourPhone + '...');
				renderBtn(requestBtn, Lang.BTN_REQUEST_CODE, getButtonWidth());
			}
			if (cancelBtn != null)
				renderBtn(cancelBtn, Lang.textCancel, getButtonWidth(2));
			onTimerContinue(requestCallDelayTimer);
			onTimerContinue(resendDelayTimer);
			
			if (privacyTF != null)
				setPrivacyText();
			
			super.drawViewLang();
			
			setComponentSizes();
			setComponentPositions();
		}
		
		override public function dispose():void {
			super.dispose();
			Auth.S_GET_SMS_CODE_RESPOND.remove(onPhoneNumberRespond);
			Auth.S_SMS_CODE_VERIFICATION_RESPOND.remove(onSMSCodeRespondReceive);
			
			if (bg != null)
				bg.dispose();
			bg = null;
			if (dog != null && dog.bitmapData != null) {
				dog.bitmapData.dispose();
				dog.bitmapData = null;
			}
			dog = null
			if (inptCodeAndPhone != null)
				inptCodeAndPhone.dispose();
			inptCodeAndPhone = null;
			if (requestBtn != null)
				requestBtn.dispose();
			requestBtn = null;
			if (cancelBtn != null)
				cancelBtn.dispose();
			cancelBtn = null;
			if (resendBtn != null)
				resendBtn.dispose();
			resendBtn = null;
			if (requestCallBtn != null)
				requestCallBtn.dispose();
			requestCallBtn = null;
			if (verifyIndicator != null)
				verifyIndicator.dispose();
			verifyIndicator = null;
			if (privacyTF != null)
				privacyTF.text = "";
			privacyTF = null;
			if (scrollPanel != null)
				scrollPanel.dispose();
			scrollPanel = null;
			killTimer(resendDelayTimer);
			resendDelayTimer = null;
			killTimer(requestCallDelayTimer);
			requestCallDelayTimer = null;
			
			currentPhone = null;
			currentCountry = null;
			
			countryPicked = false;
			
			state = 0;
			oldWidth = 0;
			oldHeight = 0;
			
			firstTime = false;
		}
		
		private function onLocationGetted(phpRespond:PHPRespond):void {
			if (countryPicked == true) {
				phpRespond.dispose();
				return;
			}
			if (phpRespond.error == true) {
				phpRespond.dispose();
				return;
			}
			var d:Array = CountriesData.getCurrentCountry();
			if (d == null)
				d = phpRespond.data as Array;
			onCountrySelected(d);
			phpRespond.dispose();
		}
		
		private function onInputCodeAndPhoneTap():void {
			countryPicked = true;
			DialogManager.showDialog(ScreenCountryPicker, { onCountrySelected:onCountrySelected } );
		}
		
		private function onCountrySelected(country:Array, getStoredPhone:Boolean = false):void {
			if (country == null)
				return;
			
			currentCountry = country;
			
			CountriesData.setCurrentCountry(country);
			inptCodeAndPhone.setInfoBox('+' + country[3],AppTheme.RED_MEDIUM);
			inptCodeAndPhone.setLabelText(Lang.enterYourPhone + "...");
			inptCodeAndPhone.setMode(Input.MODE_DIGIT);
			
			if (getStoredPhone == true) {
				var myPhone:String = Auth.getMyPhone();
				if (myPhone != "" && !isNaN(Number(myPhone)))
					inptCodeAndPhone.value = myPhone;
			}
			
			if (requestBtn == null) {
				requestBtn = new BitmapButton();
				requestBtn.setStandartButtonParams();
				requestBtn.setOverflow(Config.MARGIN * .5, Config.MARGIN, Config.MARGIN, Config.MARGIN * .5);
				requestBtn.usePreventOnDown = false;
				requestBtn.cancelOnVerticalMovement = true;
				requestBtn.hide();
				scrollPanel.addObject(requestBtn);
			}
			renderBtn(requestBtn, Lang.BTN_REQUEST_CODE, getButtonWidth());
			requestBtn.tapCallback = onBtnRequestCodeClick;
			requestBtn.show(.3, .1);
			
			if (currentPhone != null && currentPhone != "") {
				if (resendBtn == null) {
					resendBtn = new BitmapButton();
					resendBtn.setStandartButtonParams();
					resendBtn.setOverflow(Config.MARGIN * .5, Config.MARGIN, Config.MARGIN, Config.MARGIN * .5);
					resendBtn.usePreventOnDown = false;
					resendBtn.cancelOnVerticalMovement = true;
					resendBtn.hide();
					scrollPanel.addObject(resendBtn);
				}
				renderBtn(resendBtn, Lang.BTN_ENTER_CODE, getButtonWidth());
				resendBtn.tapCallback = onEnterCodeClick;
				resendBtn.show(.3, .2);
			}
			
			state = 1;
			
			onChanged();
			
			scrollPanel.addObject(privacyTF);
			setComponentPositions();
		}
		
		private function onEnterCodeClick():void {
			onBtnRequestCodeClick(false);
		}
		
		private function onChanged():void {
			if (state == 1) {
				if (inptCodeAndPhone.value != Lang.enterYourPhone && inptCodeAndPhone.value.length > 5) {
					requestBtn.alpha = 1;
					if (resendBtn != null)
						resendBtn.alpha = 1;
					if (_isActivated == true) {
						requestBtn.activate();
						if (resendBtn != null)
							resendBtn.activate();
					}
					return;
				}
				requestBtn.alpha = .7;
				requestBtn.deactivate();
				if (resendBtn != null) {
					resendBtn.alpha = .7;
					resendBtn.deactivate();
				}
				return;
			}
			if (state == 2) {
				if (inptCodeAndPhone.value != Lang.enterVerifyCode && inptCodeAndPhone.value.length == 6) {
					requestBtn.alpha = 1;
					if (_isActivated == true)
						requestBtn.activate();
				} else {
					requestBtn.alpha = .7;
					requestBtn.deactivate();
				}
			}
		}
		
		private function showPrivacy(e:Event = null):void {
			navigateToURL(new URLRequest("https://www.dukascopy.com/media/pdf/911/terms_and_conditions.pdf"));
		}
		
		private function onBtnRequestCodeClick(needToSendCode:Boolean = true):void {
			if (inptCodeAndPhone.value == Lang.enterYourPhone || inptCodeAndPhone.value.length < 6)
				return;
			var countryCode:String = inptCodeAndPhone.getInfoBoxValue().substr(1);
			var phoneString:String = inptCodeAndPhone.value;
			if (phoneString.substr(0, 2) == "00") {
				var country:Array = CountriesData.getCountryByPhoneNumber(phoneString);
				if (country != null)
					phoneString = phoneString.substr(CountriesData.getCountryByPhoneNumber(phoneString)[3].length + 2);
				inptCodeAndPhone.value = phoneString;
			} else if (countryCode.length > 2 && phoneString.indexOf(countryCode) == 0) { // 03.04.2018 - Тупые хохлы вводят телефон с кодом
				phoneString = phoneString.substr(countryCode.length);
			}
			if (countryCode != "33" /*France*/)
				phoneString = UI.trimFront(phoneString, "0");
			if (phoneString.length < 6)
				return;
			/*phoneString = "0000000000";
			countryCode = "80";*/
			Auth.setMyPhone(phoneString);
			currentPhone = countryCode + phoneString;
			requestBtn.deactivate();
			requestBtn.alpha = .7;
			if (needToSendCode == true) {
				showIndicatorOnRequest();
				Auth.S_GET_SMS_CODE_RESPOND.add(onPhoneNumberRespond);
				TweenMax.killDelayedCallsTo(dellayedSendSMSCode);
				TweenMax.delayedCall(0, dellayedSendSMSCode);
			} else {
				onPhoneNumberRespond();
			}
		}
		
		private function onPhoneNumberRespond(error:Boolean = false, errorCode:String = null):void {
			listenSMS();
			if (state == 2)
				return;
			hideIndicatorOnRequest();
			if (error == true) {
				if (_isActivated == true)
					onChanged();
				if (errorCode == "sms..04") {
					if (resendBtn == null) {
						resendBtn = new BitmapButton();
						resendBtn.setStandartButtonParams();
						resendBtn.setOverflow(Config.MARGIN * .5, Config.MARGIN, Config.MARGIN, Config.MARGIN * .5);
						resendBtn.usePreventOnDown = false;
						resendBtn.cancelOnVerticalMovement = true;
						resendBtn.hide();
						scrollPanel.addObject(resendBtn);
					}
					renderBtn(resendBtn, Lang.BTN_ENTER_CODE, getButtonWidth());
					resendBtn.tapCallback = onEnterCodeClick;
					resendBtn.show(.3, .2);
					
					setComponentPositions();
				}
				return;
			}
			state = 2;
			if (inptCodeAndPhone != null) {
				inptCodeAndPhone.removeInfoBox();
				inptCodeAndPhone.value = null;
				inptCodeAndPhone.setLabelText(Lang.enterVerifyCode);
				if (Config.isTest() == true)
					inptCodeAndPhone.value = Auth.getMyPhone().substr(Auth.getMyPhone().length - 6);
			}
			var bitmapPlane:BitmapData;
			if (requestBtn != null) {
				renderBtn(requestBtn, Lang.verifyCode, getButtonWidth());
				requestBtn.tapCallback = onBtnVerifyCodeClick;
				requestBtn.deactivate();
				requestBtn.alpha = .7;
				requestBtn.hide();
			}
			if (resendBtn == null) {
				resendBtn = new BitmapButton();
				resendBtn.setStandartButtonParams();
				resendBtn.setOverflow(Config.MARGIN * .5, Config.MARGIN, Config.MARGIN, Config.MARGIN * .5);
				resendBtn.usePreventOnDown = false;
				resendBtn.cancelOnVerticalMovement = true;
				resendBtn.hide();
				scrollPanel.addObject(resendBtn);
			}
			renderBtn(resendBtn, Lang.resendCode, getButtonWidth(2));
			resendBtn.tapCallback = onBtnResendClick;
			resendBtn.hide();
			if (privacyTF != null && privacyTF.parent != null) {
				PointerManager.removeTap(privacyTF, showPrivacy);
				scrollPanel.removeObject(privacyTF);
			}
			if (cancelBtn == null) {
				cancelBtn  = new BitmapButton();
				cancelBtn.setStandartButtonParams();
				cancelBtn.usePreventOnDown = false;
				cancelBtn.tapCallback = onBtnCancelClick;
				cancelBtn.setOverflow(Config.MARGIN * .5, Config.MARGIN * .5, Config.MARGIN * .5, Config.MARGIN * .5);
				renderBtn(cancelBtn, Lang.textCancel, getButtonWidth(2));
			}
			cancelBtn.hide();
			scrollPanel.addObject(cancelBtn);
			if (requestCallBtn == null) {
				requestCallBtn = new BitmapButton();
				requestCallBtn.setStandartButtonParams();
				requestCallBtn.usePreventOnDown = false;
				requestCallBtn.tapCallback = onBtnRequestCallClick;
				requestCallBtn.setOverflow(Config.MARGIN * .5, Config.MARGIN * .5, Config.MARGIN * .5, Config.MARGIN * .5);
			}
			requestCallBtn.alpha = .7;
			requestCallBtn.hide();
			initTimer(requestCallDelayTimer);
			scrollPanel.addObject(requestCallBtn);
			
			setComponentPositions();
			
			requestBtn.show(.3, .1);
			cancelBtn.show(.3, .2);
			resendBtn.show(.3, .3);
			requestCallBtn.show(.3, .4);
			
			if (_isActivated == true) {
				resendBtn.activate();
				cancelBtn.activate();
			}
		}
		
		private function listenSMS():void {
			stopListenSMS();
			if (Config.PLATFORM_ANDROID == true)
				if (MobileGui.androidExtension != null)
					MobileGui.androidExtension.addEventListener(StatusEvent.STATUS, nativeExtensionEvent);
		}
		
		private function stopListenSMS():void {
			if (Config.PLATFORM_ANDROID == true)
				if (MobileGui.androidExtension != null)
					MobileGui.androidExtension.removeEventListener(StatusEvent.STATUS, nativeExtensionEvent);
		}
		
		private function nativeExtensionEvent(e:StatusEvent):void{
			if (e.code == "sms_recieved") {
				if (e.level && e.level.length > 5) {
					var regExp:RegExp = /^[0-9]{6}[\s][\s\S]+?[dD]ukascopy/;
					if (regExp.test(e.level))
						insertCodeFromSMS(e.level.substr(0, 6));
				}
			}
		}
		
		private function insertCodeFromSMS(code:String):void {
			inptCodeAndPhone.value = code;
			DialogManager.closeDialog();
			onBtnVerifyCodeClick();
		}
		
		private function onBtnCancelClick():void {
			state = 1;
			
			cancelBtn.deactivate();
			scrollPanel.removeObject(cancelBtn);
			
			requestCallBtn.deactivate();
			scrollPanel.removeObject(requestCallBtn);
			if (requestCallDelayTimer != null) {
				requestCallDelayTimer.removeEventListener(TimerEvent.TIMER, onTimer);
				requestCallDelayTimer.reset();
			}
			if (resendDelayTimer != null) {
				resendDelayTimer.removeEventListener(TimerEvent.TIMER, onTimer);
				resendDelayTimer.reset();
			}
			
			requestBtn.hide();
			resendBtn.hide();
			onCountrySelected(currentCountry, true);
		}

		private function onBtnResendClick():void {
			resendBtn.deactivate();
			resendBtn.alpha = .7;
			initTimer(resendDelayTimer);
			
			TweenMax.killDelayedCallsTo(dellayedSendSMSCode);
			TweenMax.delayedCall(0, dellayedSendSMSCode);
		}
		
		private function onBtnRequestCallClick():void {
			requestCallBtn.deactivate();
			requestCallBtn.alpha = .7;
			initTimer(requestCallDelayTimer);
		}
		
		private function onBtnVerifyCodeClick():void {
			if (inptCodeAndPhone.value == Lang.enterVerifyCode || inptCodeAndPhone.value.length != 6) {
				DialogManager.alert(Lang.alertWrongCode, Lang.textWrongCode );
				return;
			}
			
			cancelBtn.hide(.3);
			resendBtn.hide(.3, .1);
			requestCallBtn.hide(.3, .2);
			
			showIndicatorOnRequest();
			
			Auth.S_SMS_CODE_VERIFICATION_RESPOND.add(onSMSCodeRespondReceive);
			TweenMax.killDelayedCallsTo(delayedAuthorizeSendCode);
			TweenMax.delayedCall(0, delayedAuthorizeSendCode);
		}
		
		private function onSMSCodeRespondReceive(error:Boolean):void {
			hideIndicatorOnRequest();
			if (error == true) {
				cancelBtn.show(.3);
				resendBtn.show(.3, .1);
				requestCallBtn.show(.3, .2)
			}
		}
		
		private function showIndicatorOnRequest():void {
			if (verifyIndicator == null)
				verifyIndicator = new Preloader(Config.FINGER_SIZE * .4);
			if (requestBtn != null) {
				verifyIndicator.y = requestBtn.height * .5;
				verifyIndicator.x = requestBtn.width-Config.FINGER_SIZE * .4 - 10;
				requestBtn.addChild(verifyIndicator);
				verifyIndicator.show();
			}
		}
		
		private function hideIndicatorOnRequest():void {
			if (verifyIndicator != null) {
				verifyIndicator.hide(true);
				verifyIndicator = null;
			}
		}
		
		private function delayedAuthorizeSendCode():void {
			Auth.authorize_sendCode(currentPhone, inptCodeAndPhone.value);
		}
		
		private function dellayedSendSMSCode():void {
			Auth.authorize_requestCode(currentPhone);
		}
		
		private function delayedSendPhoneRequest():void {
			Auth.authorize_requestCall(currentPhone);
		}
		
		private function initTimer(timer:Timer):void {
			killTimer(timer);
			if (timer == null)
				return;
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			timer.start();
			onTimerContinue(timer);
		}
		
		private function killTimer(timer:Timer):void {
			if (timer == null)
				return;
			timer.removeEventListener(TimerEvent.TIMER, onTimer);
			timer.reset();
		}
		
		private function onTimer(e:TimerEvent):void {
			onTimerContinue(e.currentTarget as Timer);
		}
		
		private function onTimerContinue(timer:Timer):void {
			if (timer == null)
				return;
			var currentCount:int = BUTTON_REQUEST_CALL_SHOW_DELAY - timer.currentCount;
			var btnCount:int = 1;
			var btn:BitmapButton;
			var btnTitle:String;
			if (timer == requestCallDelayTimer) {
				btn = requestCallBtn;
				btnTitle = Lang.requestCall;
			} else if (timer == resendDelayTimer) {
				btn = resendBtn;
				btnTitle = Lang.resendCode;
				btnCount = 2;
			} else
				return;
			if (currentCount > 0) {
				renderBtn(btn, btnTitle + " (" + currentCount + ")", getButtonWidth(btnCount));
				return;
			}
			killTimer(timer);
			if (Auth.isCallableToObtainLoginCode == true) {
				if (_isActivated == true)
					btn.activate();
				btn.alpha = 1;
			}
			renderBtn(btn, btnTitle, getButtonWidth(btnCount));
		}
		
		private function renderBtn(btn:BitmapButton, val:String, btnWidth:int):void {
			if (btn == null)
				return;
			if (val == null)
				return;
			if (btnWidth == 0)
				return;
			var bmd:ImageBitmapData = UI.renderButton(
				val,
				btnWidth,
				Config.FINGER_SIZE,
				0xFFFFFF,
				AppTheme.RED_MEDIUM,
				AppTheme.RED_DARK,
				Config.FINGER_SIZE * .3
			);
			btn.setBitmapData(bmd, true);
		}
		
		private function getButtonWidth(count:int = 1):int {
			var side:int = (_width < _height) ? _width : _height;
			var w:int = side * .6;
			if (w < 250)
				w = 250;
			if (count < 2)
				return w;
			else
				return int((w - Config.MARGIN * (count - 1)) / count);
		}
	}
}