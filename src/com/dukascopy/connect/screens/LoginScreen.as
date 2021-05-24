package com.dukascopy.connect.screens {
	
	import assets.CallIcon;
	import assets.ClearPhoneIcon;
	import assets.LoginLogo;
	import assets.RefreshIcon2;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.CountriesData;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.IUpdatableAction;
	import com.dukascopy.connect.data.screenAction.customActions.ExecuteAction;
	import com.dukascopy.connect.data.screenAction.customActions.TimerAction;
	import com.dukascopy.connect.gui.components.CirclePreloader;
	import com.dukascopy.connect.gui.components.CountryButton;
	import com.dukascopy.connect.gui.components.NumericKeyboard;
	import com.dukascopy.connect.gui.components.PhoneField;
	import com.dukascopy.connect.gui.components.WhiteToast;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.renderers.ListCountry;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.dialogs.ScreenCountryPicker;
	import com.dukascopy.connect.screens.dialogs.bottom.base.ListSelectionPopup;
	import com.dukascopy.connect.screens.dialogs.bottom.base.SearchListSelectionPopup;
	import com.dukascopy.connect.screens.serviceScreen.BottomContextMenuScreen;
	import com.dukascopy.connect.screens.serviceScreen.Overlay;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import com.greensock.easing.Power2;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	import flash.utils.Timer;
	import white.Back;
	import white.ChatIcon;
	import white.MenuChat;
	import white.Phone;
	import white.Refresh;
	
	/**
	 * @author Sergey Dobarin
	 */
	
	public class LoginScreen extends BaseScreen {
		
		static public const STATE_CODE:String = "stateCode";
		static public const STATE_PHONE:String = "statePhone";
		static public const SCREEN_SIZE_SMALL:String = "screenSizeSmall";
		static public const SCREEN_SIZE_NORMAL:String = "screenSizeNormal";
		
		private static const BUTTON_REQUEST_CALL_SHOW_DELAY:int = 60;
		
		private var keyboard:NumericKeyboard;
		private var logo:Sprite;
		private var nextButton:BitmapButton;
		private var clearPhoneButton:BitmapButton;
		private var selectCountryButton:CountryButton;
		private var termsText:Bitmap;
		private var title:Bitmap;
		private var phone:PhoneField;
		private var countryPicked:Boolean;
		private var currentCountry:Array;
		private var currentPhone:String;
		private var maxPhoneLength:int = 14;
		private var locked:Boolean;
		private var loader:CirclePreloader;
		private var toast:WhiteToast;
		private var firstTime:Boolean = true;
		private var bg:Shape;
		private var terms:Sprite;
		private var hideTime:Number = 0.3;
		private var state:String;
		private var retryCodeButton:BitmapButton;
		private var backAction:ExecuteAction;
		private var requestCallAction:TimerAction;
		private var resendCodeAction:TimerAction;
		private var currentCode:String;
		private var updateAfterShow:Boolean;
		private var inAnimation:Boolean;
		private var codeSentTimer:Timer;
		private var resendTimeout:int = 60;
		private var finalPhone:String;
		private var screenSize:String;
		private var fingerSize:int;
		private var keyboardZoom:Number = 1;
		private var sizeSetted:Boolean;
		private var startSupportAction:ExecuteAction;
		private var textCode:String;

		public function LoginScreen()
		{
			super();
		}
		
		override protected function createView():void
		{
			super.createView();
			
			bg = new Shape();
			bg.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			bg.graphics.drawRect(0, 0, 50, 50);
			bg.graphics.endFill();
			view.addChild(bg);
			
			keyboard = new NumericKeyboard(onKeyboard);
			view.addChild(keyboard);
			
			logo = new (Style.icon(Style.ICON_LOGIN_LOGO))();
			UI.scaleToFit(logo, Config.FINGER_SIZE * 10, Config.FINGER_SIZE * 1.7);
			view.addChild(logo);
			
			nextButton = new BitmapButton();
			nextButton.setStandartButtonParams();
			nextButton.setDownScale(1);
			nextButton.setDownColor(0);
			nextButton.tapCallback = nextClick;
			nextButton.disposeBitmapOnDestroy = true;
			nextButton.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
			view.addChild(nextButton);
			
			retryCodeButton = new BitmapButton();
			retryCodeButton.setStandartButtonParams();
			retryCodeButton.setDownScale(1);
			retryCodeButton.setDownColor(0);
			retryCodeButton.tapCallback = noCodeClick;
			retryCodeButton.disposeBitmapOnDestroy = true;
			retryCodeButton.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
			view.addChild(retryCodeButton);
			
			retryCodeButton.visible = false;
			
			clearPhoneButton = new BitmapButton();
			clearPhoneButton.setStandartButtonParams();
			clearPhoneButton.setDownScale(1);
			clearPhoneButton.setDownColor(0);
			clearPhoneButton.tapCallback = clearPhone;
			clearPhoneButton.disposeBitmapOnDestroy = true;
			clearPhoneButton.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
			view.addChild(clearPhoneButton);
			
			var icon:Sprite = new ClearPhoneIcon();
			UI.scaleToFit(icon, Config.FINGER_SIZE * .4, Config.FINGER_SIZE * .4);
			clearPhoneButton.setBitmapData(UI.getSnapshot(icon), true);
			var overflow:int = Math.max((Config.FINGER_SIZE * .8 - clearPhoneButton.width) * .5, 0);
			clearPhoneButton.setOverflow(overflow, overflow, overflow, overflow);
			
			selectCountryButton = new CountryButton();
			selectCountryButton.tapCallback = selectCountryClick;
			view.addChild(selectCountryButton);
			
			terms = new Sprite();
			view.addChild(terms);
			
			termsText = new Bitmap();
			terms.addChild(termsText);
			
			title = new Bitmap();
			view.addChild(title);
			
			phone = new PhoneField();
			view.addChild(phone);
		}
		
		private function noCodeClick():void 
		{
			if (locked == true)
			{
				return;
			}
			
			var actions:Vector.<IScreenAction> = new Vector.<IScreenAction>();
			
			var timeout:int = 0;
			if (codeSentTimer != null)
			{
				timeout = resendTimeout - codeSentTimer.currentCount;
			}
			
			resendCodeAction = new TimerAction();
			resendCodeAction.getSuccessSignal().add(resendCode);
			resendCodeAction.setData(Lang.resendCode);
			resendCodeAction.setTime(timeout);
			resendCodeAction.setIconClass(Refresh);
			
			requestCallAction = new TimerAction();
			requestCallAction.getSuccessSignal().add(requestCall);
			requestCallAction.setData(Lang.requestCall);
			requestCallAction.setTime(timeout);
			requestCallAction.setIconClass(Phone);
			
			backAction = new ExecuteAction();
			backAction.getSuccessSignal().add(onBack);
			backAction.setData(Lang.changePhoneNumber);
			backAction.setIconClass(Back);
			
			startSupportAction = new ExecuteAction();
			startSupportAction.getSuccessSignal().add(startSupportChat);
			startSupportAction.setData(Lang.startSupportChat);
			startSupportAction.setIconClass(ChatIcon);
			
			actions.push(resendCodeAction);
			actions.push(requestCallAction);
			actions.push(startSupportAction);
			actions.push(backAction);
			
			Overlay.removeCurrent();
			
			DialogManager.showDialog(BottomContextMenuScreen, actions);
		}
		
		private function startSupportChat():void 
		{
			MobileGui.changeMainScreen(GuestChatScreen, {phone:finalPhone, currentPhone:currentPhone, country:currentCountry});
		}
		
		private function clearPhone():void 
		{
			if (locked == false)
			{
				if (state == STATE_PHONE)
				{
					if (currentPhone!= null && currentPhone.length > 0)
					{
						currentPhone = currentPhone.slice(0, currentPhone.length - 1);
						phone.removeLast();
					}
				//	currentPhone = "";
				}
				else if (state == STATE_CODE)
				{
					if (currentCode!= null && currentCode.length > 0)
					{
						currentCode = currentCode.slice(0, currentCode.length - 1);
						phone.removeLast();
					}
					
				//	currentCode = "";
				//	phone.clear();
				}
				
				
				updatePositionPhone(true);
			}
		}
		
		private function onKeyboard(value:String):void 
		{
			if (state == STATE_PHONE)
			{
				if (currentPhone.length < maxPhoneLength)
				{
					currentPhone += value;
					phone.add(value);
					updatePositionPhone(true);
				}
			}
			else if (state == STATE_CODE)
			{
				if (currentCode.length < 6)
				{
					currentCode += value;
					phone.add(value);
					updatePositionPhone(true);
					
					if (currentCode.length == 6)
					{
						TweenMax.killDelayedCallsTo(trySendCode);
						TweenMax.delayedCall(1, trySendCode);
					}
				}
			}
		}
		
		private function trySendCode():void 
		{
			TweenMax.killDelayedCallsTo(trySendCode);
			if (isDisposed == true || locked == true || currentCode == null || currentCode.length < 6)
			{
				return;
			}
			nextClick();
		}
		
		override public function setWidthAndHeight(width:int, height:int):void {
			if (sizeSetted == false)
			{
				sizeSetted = true;
				super.setWidthAndHeight(width, height);
			}
		}
		
		private function selectCountryClick():void
		{
		//	DialogManager.showDialog(ScreenCountryPicker, { onCountrySelected:onCountrySelected } );
			
			var oldDelimiter:String = "";
			var newDelimiter:String = "";
			var cData:Array = CountriesData.COUNTRIES;
			var cDataNew:Array = [];
			for (var i:int = 0; i < cData.length; i++) {
				newDelimiter = String(cData[i][0]).substr(0, 1).toUpperCase();
				if (newDelimiter != oldDelimiter) {
					oldDelimiter = newDelimiter;
					cDataNew.push([oldDelimiter.toLowerCase(), oldDelimiter]);
				}
				cDataNew.push(cData[i]);
			}
			
			DialogManager.showDialog(
				SearchListSelectionPopup,
				{
					items:cDataNew,
					title:Lang.selectCountry,
					renderer:ListCountry,
					callback:onCountryListSelected
				}, ServiceScreenManager.TYPE_SCREEN
			);
		}
		
		private function onCountryListSelected(country:Array):void
		{
			if (country.length == 2)
				return;
			onCountrySelected(country);
		}
		
		private function showPrivacy(e:Event = null):void
		{
			navigateToURL(new URLRequest("https://www.dukascopy.com/media/pdf/911/terms_and_conditions.pdf"));
		}
		
		private function nextClick():void {
			if (locked == false) {
				if (state == STATE_PHONE) {
					if (currentPhone != null && currentPhone.length > 5) {
						requestCode();
					}
				} else if (state == STATE_CODE) {
					if (currentCode == null || currentCode.length != 6) {
						displayMessage();
						return;
					}
					locked = true;
					keyboard.lock();
					
					loader = new CirclePreloader();
					view.addChild(loader);
					loader.x = int(_width * .5);
					loader.y = int(title.y + (phone.height + (phone.y - title.y)) * .5);
					TweenMax.to(phone, 0.2, {alpha:0.2} );
					TweenMax.to(title, 0.2, {alpha:0.2} );
					TweenMax.to(clearPhoneButton, 0.2, {alpha:0.2});
					Auth.S_SMS_CODE_VERIFICATION_RESPOND.add(onSMSCodeRespondReceive);
					TweenMax.killDelayedCallsTo(trySendCode);
					TweenMax.killDelayedCallsTo(delayedAuthorizeSendCode);
					TweenMax.delayedCall(0, delayedAuthorizeSendCode);
				}
			}
		}
		
		private function displayMessage():void 
		{
			var toastTime:Number = 2.5;
			toast = new WhiteToast(Lang.textWrongCode, _width, _height, null, toastTime);
			view.addChild(toast);
			TweenMax.delayedCall(toastTime + 0.5, onTostMessageHided);
		}
		
		private function onTostMessageHided():void 
		{
			if (isDisposed == true)
			{
				return;
			}
			
			if (toast != null)
			{
				toast.dispose();
				if (view.contains(toast))
				{
					view.removeChild(toast);
				}
				toast = null;
			}
		}
		
		private function delayedAuthorizeSendCode():void {
			TweenMax.killDelayedCallsTo(trySendCode);
			var phoneString:String = finalPhone;
			if (phoneString != null && phoneString.length > 0 && phoneString.indexOf("p") == 0)
			{
				phoneString = phoneString.substring(1);
			}
			Auth.authorize_sendCode(phoneString, currentCode);
		}
		
		private function onSMSCodeRespondReceive(error:Boolean):void {
			if (loader != null && error == true)
			{
				view.removeChild(loader);
				loader = null;
			}
			
			if (error == true)
			{
				TweenMax.to(phone, 0.3, {alpha:1});
				TweenMax.to(title, 0.3, {alpha:1});
				TweenMax.to(clearPhoneButton, 0.3, {alpha:1});
				
				unlock();
			}
		}
		
		private function requestCode():void 
		{
			if (currentPhone.length < 6)
				return;
				
			var countryCode:String = selectCountryButton.getValue().substr(0);
			var phoneString:String = currentPhone;
			if (phoneString != null && phoneString.length > 0 && phoneString.indexOf("p") == 0)
			{
				phoneString = phoneString.substring(1);
			}
			if (phoneString.substr(0, 2) == "00") {
				var country:Array = CountriesData.getCountryByPhoneNumber(phoneString);
				if (country != null)
					phoneString = phoneString.substr(CountriesData.getCountryByPhoneNumber(phoneString)[3].length + 2);
				
				//!TODO:;
			//	inptCodeAndPhone.value = phoneString;
				
			} else if (countryCode.length > 2 && phoneString.indexOf(countryCode) == 0) {
				phoneString = phoneString.substr(countryCode.length);
			}
			if (countryCode != "33" /*France*/)
				phoneString = UI.trimFront(phoneString, "0");
			if (phoneString.length < 6)
				return;
			Auth.setMyPhone(phoneString);
			finalPhone = countryCode + phoneString;
			
			//!TODO:;
			var needToSendCode:Boolean = true;
			
			if (needToSendCode == true) {
				
				locked = true;
				keyboard.lock();
				selectCountryButton.lock();
				
				TweenMax.to(selectCountryButton, 0.2, {alpha:0.2});
				TweenMax.to(phone, 0.2, {alpha:0.2});
				TweenMax.to(title, 0.2, {alpha:0.2});
				TweenMax.to(clearPhoneButton, 0.2, {alpha:0.2});
				
				loader = new CirclePreloader();
				view.addChild(loader);
				loader.x = int(_width * .5);
				loader.y = int(title.y + (phone.height + (phone.y - title.y)) * .5);
				
				Auth.S_GET_SMS_CODE_RESPOND.add(onPhoneNumberRespond);
				TweenMax.killDelayedCallsTo(dellayedSendSMSCode);
				TweenMax.delayedCall(0, dellayedSendSMSCode);
			} else {
				onPhoneNumberRespond();
			}
		}
		
		private function dellayedSendSMSCode():void {
			var phoneString:String = finalPhone;
			if (phoneString != null && phoneString.length > 0 && phoneString.indexOf("p") == 0)
			{
				phoneString = phoneString.substring(1);
			}
			Auth.authorize_requestCode(phoneString);
		}
		
		private function onPhoneNumberRespond(error:Boolean = false, errorCode:String = null):void
		{
			if(loader != null)
			{
				view.removeChild(loader);
				loader = null;
			}
			
			if (error == true)
			{
				if (state == STATE_PHONE)
				{
					onErrorTostHided();
				}
			}
			else
			{
				var toastTime:Number = 3;
				toast = new WhiteToast(Lang.smsCodeSent, _width, _height, null, toastTime);
				view.addChild(toast);
				TweenMax.delayedCall(toastTime - 0.5, onTostHided);
				
				startTimerCodeSent();
			}
		}
		
		private function startTimerCodeSent():void 
		{
			clearTimer();
			codeSentTimer = new Timer(1000, resendTimeout);
			codeSentTimer.start();
		}
		
		private function clearTimer():void 
		{
			if (codeSentTimer != null)
			{
				codeSentTimer.stop();
				codeSentTimer = null;
			}
		}
		
		private function setCurrentCode(value:String = null):void
		{
			if (value != null && phone != null)
			{
				currentCode = value;

				for (var i:int = 0; i < currentCode.length; i++)
				{
					phone.add(currentCode.charAt(i));
				}
			}
		}
		
		private function requestCall():void 
		{
			clearActions();
			
			startTimerCodeSent();
			
			var phoneString:String = finalPhone;
			if (phoneString != null && phoneString.length > 0 && phoneString.indexOf("p") == 0)
			{
				phoneString = phoneString.substring(1);
			}
			Auth.authorize_requestCall(phoneString);
		}
		
		private function resendCode():void 
		{
			clearActions();
			
		//	initTimer(resendDelayTimer);
			
			TweenMax.killDelayedCallsTo(dellayedSendSMSCode);
			TweenMax.delayedCall(0, dellayedSendSMSCode);
		}
		
		private function onTimerContinue(timer:Timer):void {
			/*if (timer == null)
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
			renderBtn(btn, btnTitle, getButtonWidth(btnCount));*/
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
		
		private function onErrorTostHided():void 
		{
			unlock();
			
			TweenMax.to(selectCountryButton, 0.3, {alpha:1});
			TweenMax.to(phone, 0.3, {alpha:1});
			TweenMax.to(title, 0.3, {alpha:1});
			TweenMax.to(clearPhoneButton, 0.3, {alpha:1});
			
			if (toast != null && view.contains(toast))
			{
				view.removeChild(toast);
			}
		}
		
		private function onTostHided():void 
		{
			if (isDisposed == true)
			{
				return;
			}
			
			view.removeChild(toast);
			
			locked = false;
			
			if (state == STATE_PHONE)
			{
				locked = true;
				animateHide(logo);
				animateHide(title);
				animateHide(keyboard);
				animateHide(nextButton);
				animateHide(terms);
				animateHide(clearPhoneButton);
				animateHide(phone);
				animateHide(selectCountryButton);
				
				TweenMax.delayedCall(hideTime, drawStateCode);
			}
		}
		
		private function drawStateCode():void 
		{
			state = STATE_CODE;
			
			retryCodeButton.visible = true;
			retryCodeButton.alpha = 0;

			selectCountryButton.visible = false;
			clearPhoneButton.visible = false;
			phone.clear();
			
			drawTitle(Lang.enterVerifyCode, (screenSize == SCREEN_SIZE_SMALL)?Config.FINGER_SIZE * .25:NaN);
			drawNextButton(Lang.verifyCode);
			
			var maxKeyboardHeight:int = _height - Config.APPLE_BOTTOM_OFFSET;
			maxKeyboardHeight -= fingerSize * .3 + retryCodeButton.height;
			maxKeyboardHeight -= fingerSize * .25 + nextButton.height;
			maxKeyboardHeight -= fingerSize * .5 + title.height;
			maxKeyboardHeight -= fingerSize * .5 + phone.getHeight();
			maxKeyboardHeight -= fingerSize * .5 + fingerSize * .5;
			maxKeyboardHeight -= logo.height - fingerSize;
			
			keyboard.draw(_width - Config.FINGER_SIZE * 1.6, maxKeyboardHeight, keyboardZoom);
			
			var freeSpace:int = _height - Config.APPLE_BOTTOM_OFFSET;
			freeSpace -= fingerSize * .3 + retryCodeButton.height;
			freeSpace -= nextButton.height;
			freeSpace -= keyboard.height;
			freeSpace -= fingerSize * .25 + title.height;
			freeSpace -= fingerSize * .5 + phone.getHeight();
			freeSpace -= fingerSize * .5 + fingerSize * .5;
			freeSpace -= logo.height;
			
			
			freeSpace = Math.max(0, freeSpace);
			
			var position:int = freeSpace * 3 / 6;
			logo.y = position;
			position += logo.height + freeSpace * 2 / 6;
			title.y = position;
			position += title.height + fingerSize * .35;
			
			phone.x = int(_width * .5 - phone.getWidth() * .5);
			phone.y = position;
			position += phone.getHeight() + fingerSize * .5;
			
			keyboard.y = position;
			position += keyboard.height + fingerSize * .5;
			nextButton.y = position;
			position += nextButton.height + fingerSize * .3;
			retryCodeButton.x = int(_width * .5 - retryCodeButton.width * .5);
			retryCodeButton.y = position;
			
			keyboard.x = Config.FINGER_SIZE * 1.6 * .5;
			
			nextButton.x = int(_width * .5 - nextButton.width * .5);
			title.x = int(_width * .5 - title.width * .5);
			
			showStateCode();
			
			if (Config.isTest() == true && textCode != null)
			{
				setCurrentCode(textCode);
			}
		}
		
		private function showStateCode():void 
		{
			terms.visible = false;
			currentCode = "";
			var distance:int = Config.FINGER_SIZE;
			updatePositionPhone();
			
			animateShow(0, logo, distance, 0);
			animateShow(1, title, distance, 0);
			animateShow(2, phone, distance, 0);
			animateShow(2, clearPhoneButton, distance, 0);
			animateShow(3, keyboard, distance, 0);
			animateShow(4, nextButton, distance, 0);
			animateShow(5, retryCodeButton, distance, 0);
			
			TweenMax.delayedCall(1.5, unlock);
		}
		
		private function animateHide(item:DisplayObject):void 
		{
			TweenMax.to(item, hideTime, {alpha:0, y:item.y - Config.FINGER_SIZE});
		}
		
		override public function onBack(e:Event = null):void
		{
			if (state == STATE_PHONE)
			{
				DialogManager.alert(Lang.textWarning, Lang.areYouSureQuitApplication, MobileGui.onQuitDialogCallback, Lang.textQuit, Lang.textCancel);
			}
			else if(state == STATE_CODE)
			{
				clearActions();
				currentPhone = "";
				finalPhone = "";
				toPhoneState();
			}
		}
		
		private function toPhoneState():void 
		{
			if(loader != null)
			{
				view.removeChild(loader);
				loader = null;
			}
			
			locked = false;
			
			animateHide(logo);
			animateHide(title);
			animateHide(keyboard);
			animateHide(nextButton);
			animateHide(retryCodeButton);
			animateHide(clearPhoneButton);
			animateHide(phone);
			animateHide(selectCountryButton);
			
			TweenMax.delayedCall(hideTime, drawStateStart);
		}
		
		private function drawStateStart():void 
		{
			state = STATE_PHONE;
			
			phone.clear();
			terms.visible = true;
			terms.alpha = 0;
			
			retryCodeButton.visible = false;
			
			drawNextButton(Lang.BTN_REQUEST_CODE);
			drawTitle(Lang.enterYourPhone);
			
			drawView();
			
			showStateStart();
		}
		
		private function showStateStart():void 
		{
			TweenMax.killDelayedCallsTo(trySendCode);
			var distance:int = Config.FINGER_SIZE;
			
			updatePositionPhone();
			
			animateShow(0, logo, distance, 0);
			animateShow(1, title, distance, 0);
			animateShow(2, phone, distance, 0);
			animateShow(2, selectCountryButton, distance, 0);
			animateShow(2, clearPhoneButton, distance, 0);
			animateShow(3, keyboard, distance, 0);
			animateShow(4, nextButton, distance, 0);
			animateShow(5, terms, distance, 0);
			
			TweenMax.delayedCall(1.5, unlock);
		}
		
		private function clearActions():void 
		{
			if (resendCodeAction != null)
			{
				resendCodeAction.getSuccessSignal().remove(resendCode);
				resendCodeAction.dispose();
				resendCodeAction = null;
			}
			
			if (requestCallAction != null)
			{
				requestCallAction.getSuccessSignal().remove(requestCall);
				requestCallAction.dispose();
				requestCallAction = null;
			}
			
			if (backAction != null)
			{
				backAction.getSuccessSignal().remove(onBack);
				backAction.dispose();
				backAction = null;
			}
			
			if (startSupportAction != null)
			{
				startSupportAction.getSuccessSignal().remove(startSupportChat);
				startSupportAction.dispose();
				startSupportAction = null;
			}
		}
		
		override public function initScreen(data:Object = null):void
		{
			super.initScreen(data);
			
			fingerSize = Config.FINGER_SIZE;
			
			state = STATE_PHONE;
			
			if (data != null && "state" in data && data.state != null)
			{
				if (data.state == STATE_CODE || data.state == STATE_PHONE)
				{
					if (data.state == STATE_CODE)
					{
						if ("phone" in data && data.phone != null)
						{
							finalPhone = data.phone;
							state = data.state;
							if ("curentPhone" in data)
							{
								currentPhone = data.currentPhone;
							}
							if ("country" in data)
							{
								onCountrySelected(data.country);
							}
						}
					}
					else
					{
						state = data.state;
					}
				}
			}

			bg.width = _width;
			bg.height = _height;

			drawNoCodeButton(Lang.didntReceiveCode);
			drawNextButton(Lang.BTN_REQUEST_CODE);
			drawTerms();

			if (state == STATE_PHONE)
			{
				drawTitle(Lang.enterYourPhone);

				onCountrySelected(CountriesData.getCountryByPhoneNumber("+415555000123"), false, false);

				loadCountry();

				currentPhone = "";
				finalPhone = "";

				hide();

				if (Config.isTest())
				{
					Auth.S_AUTH_CODE.add(insertCode);
				}
			}
			else if (state == STATE_CODE)
			{
				firstTime = false;
				drawStateCode();
			}
		}

		private function insertCode(code:String):void
		{
			if (isDisposed)
			{
				return;
			}
			textCode = code;
			setCurrentCode(code);
		}
		
		private function hide():void 
		{
			terms.visible = false;
			keyboard.visible = false;
			logo.visible = false;
			nextButton.visible = false;
			phone.visible = false;
			title.visible = false;
			selectCountryButton.visible = false;
			clearPhoneButton.visible = false;
		}
		
		private function show():void 
		{
			inAnimation = true;
			
			updatePositionPhone();
			
			logo.alpha = 0;
			logo.visible = true;
			
			var logoPosition:int = logo.y;
			logo.y = int(_height * .5 - logo.height * .5);
			TweenMax.to(logo, 0.3, {alpha:1, delay:0.5});
			TweenMax.to(logo, 0.6, {y:logoPosition, delay:1.7, ease:Power2.easeOut});
			
			animateShow(1, title, logo.y - logoPosition);
			
			animateShow(2, selectCountryButton, logo.y - logoPosition);
			animateShow(2, phone, logo.y - logoPosition);
			animateShow(2, clearPhoneButton, logo.y - logoPosition);
			
			animateShow(3, keyboard, logo.y - logoPosition);
			
			animateShow(4, nextButton, logo.y - logoPosition);
			
			animateShow(5, terms, logo.y - logoPosition);
			
			TweenMax.delayedCall(2.5, unlock);
		}
		
		private function unlock():void 
		{
			inAnimation = false;
			if (updateAfterShow == true)
			{
				updateAfterShow = false;
				drawView();
			}
			
			selectCountryButton.unlock();
			keyboard.unlock();
			locked = false;
			
			if (isActivated)
			{
				if (state == STATE_PHONE)
				{
					activateStateStart();
				}
				else if (state == STATE_CODE)
				{
					activateStateCode();
				}
			}
		}
		
		private function animateShow(index:int, item:DisplayObject, difference:int, delay:Number = 1.7):void 
		{
			item.alpha = 0;
			item.visible = true;
			var positionCurrent:int = item.y;
			item.y += difference;
			
			TweenMax.to(item, 0.6, {alpha:1, y:positionCurrent, delay:delay + 0.05 * index, ease:Power2.easeOut});
		}
		
		private function loadCountry():void
		{
			PHP.call_gelLocation(onLocationGetted);
		}
		
		private function onLocationGetted(phpRespond:PHPRespond):void
		{
			if (countryPicked == true)
			{
				phpRespond.dispose();
				return;
			}
			if (phpRespond.error == true)
			{
				phpRespond.dispose();
				return;
			}
			var d:Array = CountriesData.getCurrentCountry();
			if (d == null)
				d = phpRespond.data as Array;
			onCountrySelected(d);
			phpRespond.dispose();
		}
		
		private function onCountrySelected(country:Array, getStoredPhone:Boolean = false, store:Boolean = true):void
		{
			if (country == null)
				return;
			
			currentCountry = country;
			
			if (store == true)
			{
				CountriesData.setCurrentCountry(country);
			}
			
			drawSelectCountryButton(country[3]);
			
			if (getStoredPhone == true)
			{
				var myPhone:String = Auth.getMyPhone();
				if (myPhone != "" && !isNaN(Number(myPhone)))
				{
					//!TODO:;
					//	inptCodeAndPhone.value = myPhone;
				}
			}
		}
		
		private function drawSelectCountryButton(countryCode:String):void
		{
			if (selectCountryButton != null)
			{
				selectCountryButton.draw("p" + countryCode);
				
				updatePositionPhone();
			}
		}
		
		private function updatePositionPhone(animate:Boolean = false):void 
		{
			var time:Number = 0.2;
			if (animate == false)
			{
				time = 0;
			}
			var buttonPos:int;
			if (state == STATE_PHONE)
			{
				var posSelector:int = (_width * .5 - (selectCountryButton.width + Config.MARGIN + phone.getWidth()) * .5);
				var posNumber:int = posSelector + selectCountryButton.width + Config.MARGIN;
				TweenMax.to(selectCountryButton, time, {x:posSelector}); 
				TweenMax.to(phone, time, {x:posNumber});
				buttonPos = posNumber + phone.getWidth() + Config.DOUBLE_MARGIN;
				clearPhoneButton.y = int(phone.y + phone.getHeight() * .5 - clearPhoneButton.height * .5);
			}
			else if (state == STATE_CODE)
			{
				buttonPos = phone.x + phone.getWidth() + Config.DOUBLE_MARGIN;
				clearPhoneButton.y = int(phone.y + phone.getHeight() * .5 - clearPhoneButton.height * .5);
			}
			if (phone.x + phone.getWidth() > _width - clearPhoneButton.width - Config.FINGER_SIZE * .4)
			{
				TweenMax.killTweensOf(clearPhoneButton);
				clearPhoneButton.x = int(_width * .5 - clearPhoneButton.width * .5);
				clearPhoneButton.y = int(phone.y + phone.getHeight() + Config.FINGER_SIZE * .16);
			}
			else
			{
				TweenMax.to(clearPhoneButton, time, {x:buttonPos});
			}
		}
		
		private function drawTerms(textWidth:Number = NaN, textSize:Number = NaN):void
		{
			if (isNaN(textWidth))
			{
				textWidth = Math.max(Math.min(Config.FINGER_SIZE * 4, _width - Config.MARGIN * 2), _width - Config.FINGER_SIZE * 2);
			}
			
			if (isNaN(textSize))
			{
				textSize = Config.FINGER_SIZE * .21;
			}
			
			var splittingText:Array = Lang.txtPrivacyDC.split("[U]");
			var resultString:String = "";
			var changeFormat:Boolean = false;
			for (var i:int = 0; i < splittingText.length; i++)
			{
				if (changeFormat == true)
					resultString += "<u><font color='#5F90D4'>" + splittingText[i] + "</font></u>";
				else
					resultString += "<font>" + splittingText[i] + "</font>";
				changeFormat = !changeFormat;
			}
			
			termsText.bitmapData = TextUtils.createTextFieldData(resultString, textWidth, 10, true, TextFormatAlign.CENTER, 
																	TextFieldAutoSize.LEFT, textSize, true, 0xB1B1B1, 0xFFFFFF, false, true);
		}
		
		private function drawTitle(text:String, textSize:Number = NaN):void
		{
			var size:Number = Config.FINGER_SIZE * .36;
			if (!isNaN(textSize))
			{
				size = textSize;
			}
			title.bitmapData = TextUtils.createTextFieldData(text, _width - Config.FINGER_SIZE * 2, 10, true, 
															TextFormatAlign.CENTER, TextFieldAutoSize.CENTER, size, true, 0x717880, 0xFFFFFF, false, true);
		}
		
		private function drawNextButton(text:String):void
		{
			var textSettings:TextFieldSettings = new TextFieldSettings(text, 0xFFFFFF, Config.FINGER_SIZE * .33, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, 0x3599CD, 1, Config.FINGER_SIZE * 1.0, NaN, -1, Config.FINGER_SIZE * .25);
			nextButton.setBitmapData(buttonBitmap, true);
		}
		
		private function drawNoCodeButton(text:String):void
		{
			var textSettings:TextFieldSettings = new TextFieldSettings(text, Style.color(Style.COLOR_TEXT), Config.FINGER_SIZE * .33, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, Style.color(Style.COLOR_BACKGROUND), 1, Config.FINGER_SIZE * 1.0, NaN, -1, Config.FINGER_SIZE * .25);
			retryCodeButton.setBitmapData(buttonBitmap, true);
		}
		
		override public function drawViewLang():void {
			if (inAnimation)
			{
				updateAfterShow = true;
				return;
			}
			drawView();
		}
		
		override protected function drawView():void
		{
			if (_isDisposed == true)
				return;
			
			logo.x = int(_width * .5 - logo.width * .5);
			if (state == STATE_PHONE)
			{
				var maxKeyboardHeight:int = _height - Config.APPLE_BOTTOM_OFFSET;
				maxKeyboardHeight -= fingerSize * .15 + terms.height;
				maxKeyboardHeight -= fingerSize * .25 + nextButton.height;
				maxKeyboardHeight -= fingerSize * .5 + title.height;
				maxKeyboardHeight -= fingerSize * .5 + phone.getHeight();
				maxKeyboardHeight -= fingerSize * .5 + fingerSize * .5;
				maxKeyboardHeight -= logo.height - fingerSize;
				
				keyboard.draw(_width - fingerSize * 1.6, maxKeyboardHeight, keyboardZoom);
				
				var freeSpace:int = _height - Config.APPLE_BOTTOM_OFFSET;
				freeSpace -= fingerSize * .15 + terms.height;
				freeSpace -= nextButton.height;
				freeSpace -= keyboard.height;
				freeSpace -= fingerSize * .25 + title.height;
				freeSpace -= fingerSize * .5 + phone.getHeight();
				freeSpace -= fingerSize * .5 + fingerSize * .5;
				freeSpace -= logo.height;
				
				if (freeSpace < 0 && screenSize != SCREEN_SIZE_SMALL && screenSize != SCREEN_SIZE_NORMAL)
				{
					fingerSize = Config.FINGER_SIZE * .6;
					UI.scaleToFit(logo, Config.FINGER_SIZE * 10, Config.FINGER_SIZE * .9);
					drawTitle(Lang.enterYourPhone, Config.FINGER_SIZE * .25);
					screenSize = SCREEN_SIZE_SMALL;
					keyboardZoom = 0.75;
					drawTerms(_width - Config.MARGIN * 2, Config.FINGER_SIZE * .18);
				//	selectCountryButton.redraw(0.7);
				//	phone.redraw(0.7);
					keyboard.draw(_width - fingerSize * 1.6, maxKeyboardHeight, keyboardZoom);
					drawView();
					
					return;
				}
				else
				{
					screenSize = SCREEN_SIZE_NORMAL;
				}
				
				freeSpace = Math.max(0, freeSpace);
				
				var position:int = freeSpace * 3 / 6;
				logo.y = position;
				position += logo.height + freeSpace * 2 / 6;
				title.y = position;
				position += title.height + fingerSize * .35;
				
				updatePositionPhone();
				phone.y = position;
				selectCountryButton.y = position;
				position += phone.getHeight() + fingerSize * .5;
				
				keyboard.y = position;
				position += keyboard.height + fingerSize * .5;
				nextButton.y = position;
				
				keyboard.x = fingerSize * 1.6 * .5;
				
				nextButton.x = int(_width * .5 - nextButton.width * .5);
				title.x = int(_width * .5 - title.width * .5);
				terms.x = int(_width * .5 - terms.width * .5);
				terms.y = int(_height - Config.APPLE_BOTTOM_OFFSET - fingerSize * .15 * 1.5 - terms.height);
			}
		}
		
		override public function activateScreen():void
		{
			super.activateScreen();
			if (_isDisposed == true)
				return
			
			if (firstTime)
			{
				firstTime = false;
				locked = true;
				show();
			}
			else
			{
				if (state == STATE_PHONE)
				{
					activateStateStart();
				}
				else if (state == STATE_CODE)
				{
					activateStateCode();
				}
			}
		}
		
		private function activateStateCode():void 
		{
			retryCodeButton.activate();
			keyboard.activate();
			nextButton.activate();
			clearPhoneButton.activate();
		}
		
		private function activateStateStart():void 
		{
			keyboard.activate();
			nextButton.activate();
			clearPhoneButton.activate();
			selectCountryButton.activate();
			PointerManager.addTap(terms, showPrivacy);
		}
		
		override public function deactivateScreen():void
		{
			super.deactivateScreen();
			if (_isDisposed == true)
				return;
			
			keyboard.deactivate();
			nextButton.deactivate();
			clearPhoneButton.deactivate();
			selectCountryButton.deactivate();
			retryCodeButton.activate();
			PointerManager.removeTap(terms, showPrivacy);
		}
		
		override public function dispose():void
		{
			super.dispose();
			
			TweenMax.killTweensOf(phone);
			TweenMax.killTweensOf(title);
			TweenMax.killTweensOf(clearPhoneButton);
			TweenMax.killTweensOf(selectCountryButton);
			TweenMax.killTweensOf(logo);
			
			TweenMax.killDelayedCallsTo(delayedAuthorizeSendCode);
			TweenMax.killDelayedCallsTo(dellayedSendSMSCode);
			
			TweenMax.killDelayedCallsTo(drawStateCode);
			TweenMax.killDelayedCallsTo(unlock);
			TweenMax.killDelayedCallsTo(drawStateStart);
			TweenMax.killDelayedCallsTo(onTostHided);
			TweenMax.killDelayedCallsTo(onTostMessageHided);
			TweenMax.killDelayedCallsTo(trySendCode);
			
			Auth.S_SMS_CODE_VERIFICATION_RESPOND.remove(onSMSCodeRespondReceive);
			Auth.S_GET_SMS_CODE_RESPOND.remove(onPhoneNumberRespond);
			
			clearTimer();
			
			if (toast != null)
			{
				toast.dispose();
				toast = null;
			}
			if (keyboard != null)
			{
				keyboard.dispose();
				keyboard = null;
			}
			if (nextButton != null)
			{
				nextButton.dispose();
				nextButton = null;
			}
			if (clearPhoneButton != null)
			{
				clearPhoneButton.dispose();
				clearPhoneButton = null;
			}
			if (toast != null)
			{
				UI.destroy(toast);
				toast = null;
			}
			if (selectCountryButton != null)
			{
				selectCountryButton.dispose();
				selectCountryButton = null;
			}
			if (phone != null)
			{
				phone.dispose();
				phone = null;
			}
			if (loader != null)
			{
				loader.dispose();
				loader = null;
			}
			if (logo != null)
			{
				UI.destroy(logo);
				logo = null;
			}
			if (termsText != null)
			{
				UI.destroy(termsText);
				termsText = null;
			}
			if (title != null)
			{
				UI.destroy(title);
				title = null;
			}
			if (bg != null)
			{
				UI.destroy(bg);
				bg = null;
			}
			if (terms != null)
			{
				UI.destroy(terms);
				terms = null;
			}
			
			clearActions();
		}
	}
}