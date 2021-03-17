package com.dukascopy.connect.sys.payments {
	
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import com.telefision.sys.signals.Signal;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextFormatAlign;
	
	/**
	 * Class that handles:
	 * 
	 * 	-	Authorization process
	 * 	-	Password CHange Process
	 * 	-	Shows Password Asociated Dialogs if needed 
	 * 
	 * @author Alexey Skuryat
	 * 
	 */
	
	public class PayAuthManager {
		
		public static var S_ON_AUTH_SUCCESS:Signal = new Signal('PayAuthManager.S_ON_AUTH_SUCCESS');
		public static var S_ON_PASS_CHANGE_SUCCESS:Signal = new Signal('PayAuthManager.S_ON_PASS_CHANGE_SUCCESS');
		public static var S_ON_BACK:Signal = new Signal('PayAuthManager.S_ON_BACK');
		public static var S_ON_DISMISS_PASS:Signal = new Signal('PayAuthManager.S_ON_DISMISS_PASS');
		public static var S_ON_PASS_LOCK_CHANGE:Signal = new Signal('PayAuthManager.S_ON_PASS_LOCK_CHANGE');
		
		private static var _dependencies:Vector.<String> = new Vector.<String>;
		private static var _isManagerActivated:Boolean = true;
		private static var _isLockedByPass:Boolean = true;	
		
		public static function init():void {
			PayManager.S_NEED_AUTHORIZATION.add(onNeedPassword);
			PayManager.S_PASS_AUTHORIZE_SUCESS.add(onPasswordAuthorizeSucess);
			PayManager.S_PASS_RESPONDED.add(onPasswordAuthorizeRespond);
			PayManager.S_NEED_PASS_CHANGE.add(onNeedPasswordChange);
		}
		
		private static function onNeedPassword():void {
			isLockedByPass = true;
			if (_isManagerActivated == true) {
				if (DialogManager.hasOpenedDialog == false) {
					if (PayManager.isWaitingForPass == false) {
						if (MobileGui.touchIDManager != null) {
							MobileGui.touchIDManager.callbackFunction = callbackTouchID;
							if (MobileGui.touchIDManager.getSecretFrom() == false) {
								DialogManager.showPayPass(callBackShowPayPass);
								MobileGui.touchIDManager.callbackFunction = null;
							}
						} else {
							DialogManager.showPayPass(callBackShowPayPass);
						}
					}
				}
			}
		}
		
		private static function onPasswordAuthorizeRespond(respond:PayRespond):void {
			if (respond.errorCode == PayRespond.ERROR_NOT_APPROVED_ACCOUNT) {
				showAlert(Lang.textError, Lang.TEXT_ACCOUNT_NOT_APPROVED);
				return;
			}
			if (respond.errorCode == PayRespond.ERROR_CODE_TOO_MANY_WRONG_PASSWORD_ENTERED) {
				showAlert(Lang.alertAuthorisationError, Lang.PASS_VERIFICATION_BLOCKED, onManyWrongPassClosed);
				return;
			}
			if (respond.errorCode == PayRespond.ERROR_PASSWORD_INVALID)
				showAlert(Lang.alertAuthorisationError,Lang.TEXT_PASS_INVALID , onAuthWarningCallback, Lang.btnTryAgain);
		}
		
		private static function onPasswordAuthorizeSucess():void {
			isLockedByPass = false;
			S_ON_AUTH_SUCCESS.invoke();
		}
		
		private static function onManyWrongPassClosed(value:int):void {
			onBack();
		}
		
		private static function onAuthWarningCallback(value:int):void {
			if (value == 1)
				TweenMax.delayedCall(.1, onNeedPassword);
			else if (value == 0)
				onBack();
		}
		
		private  static function callbackTouchID(val:int, secret:String = ""):void {
			if (val == 0)
				DialogManager.showPayPass(callBackShowPayPass);
			else
				callBackShowPayPass(val, secret);
		}
		
		private static function callBackShowPayPass(val:int, pass:String):void {
			if (val == 1) {
				PayManager.callPass(pass);
				return;
			}
			if (val == 3) {
				TweenMax.delayedCall(1, forgotPassword, null, true);
				return;
			}
			if (val == 0 || val == 2)
				S_ON_DISMISS_PASS.invoke();
		}
		
		private static function forgotPassword():void {
			if (_isManagerActivated == false)
				return;
			var bodyText:String = Lang.ALERT_FORGOT_PASSWORD_SWISS;
			DialogManager.alert(
				Lang.forgotPassword,
				bodyText,
				callToBank,
				Lang.textCall,
				Lang.textClose.toUpperCase(),
				null,
				TextFormatAlign.CENTER,
				true
			);
		}
		
		private static function callToBank(val:int):void {
			if (val == 1)
				navigateToURL(new URLRequest("tel:" + Lang.BANK_PHONE_SWISS));
			TweenMax.delayedCall(1, onBack, null, true);
		}
		
		private static function onNeedPasswordChange():void {
			if (_isManagerActivated == true)
				DialogManager.showChangePayPass(onPassChangeComplete);
		}
		
		private static function onPassChangeComplete(value:int, currentPass:String = "", newPass:String = ""):void {
			if (value == 1) {
				PayManager.S_PASS_CHANGE_RESPOND.add(onPassChangeRespond);
				PayManager.callChangePassword(currentPass, newPass);
				return;
			}
			onBack();
		}
		
		private static function onPassChangeRespond(respond:PayRespond):void {
			if (respond.hasAuthorizationError == true) {
				PayManager.validateAuthorization(respond);
				return;
			}
			if (respond.error == true) {
				showAlert(Lang.textAlert, respond.errorMsg, onPassChangeErrorDialogCallback);
				return;
			}
			S_ON_PASS_CHANGE_SUCCESS.invoke(respond);
		}
		
		private static function onPassChangeErrorDialogCallback(val:int):void {
			TweenMax.delayedCall(.2, onNeedPasswordChange);
		}
		
		private static function onBack():void {
			S_ON_BACK.invoke();
		}
		
		private static function showAlert(
			title:String,
			message:String,
			callback:Function = null,
			btn1:String = 'ok',
			btn2:String = null,
			btn3:String = null,
			textAlign:String = TextFormatAlign.CENTER,
			htmlText:Boolean = false):void {
				if (_isManagerActivated == true)
					DialogManager.alert(title, message, callback, btn1, btn2, btn3, textAlign, htmlText);
		}
		
		public static function activate(instanceDependencyName:String = ""):void {
			_isManagerActivated = true;
			addDependency(instanceDependencyName);
		}
		
		/**
		 * We use dependency storage to know when we can disable showing 
		 * if no one other instances are using this class 
		 * @param	cls
		 */	
		public static function deactivate(instanceDependencyName:String = ""):void {
			_isManagerActivated = false;
			removeDependency(instanceDependencyName);
		}
		
		private static function addDependency(cls:String):void {
			if (cls == "")
				return;
			if (_dependencies.indexOf(cls) ==-1)
				_dependencies.push(cls);
		}
		
		private static function removeDependency(cls:String):void {
			if (cls == "")
				return;
			var ind:int = _dependencies.indexOf(cls);
			if (ind != -1)
				_dependencies.removeAt(ind);
		}
		
		public static function hasDependency(cls:String):Boolean {
			return _dependencies.indexOf(cls) != -1;
		}
		
		public static function hasDependencies():Boolean {
			return _dependencies.length > 0;
		}
		
		public static function set isLockedByPass(value:Boolean):void {
			if (value == _isLockedByPass)
				return;
			_isLockedByPass = value;
			S_ON_PASS_LOCK_CHANGE.invoke();
		}
		
		static public function get isLockedByPass():Boolean {
			return _isLockedByPass;
		}
	}
}