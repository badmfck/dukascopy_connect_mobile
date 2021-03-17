package com.dukascopy.connect.sys.payments {
	
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.screens.base.ScreenManager;
	import com.dukascopy.connect.screens.payments.PaymentsRTOLimitsScreen;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.payments.advancedPayments.vo.PayTaskVO;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import com.telefision.sys.signals.Signal;
	
	/**
	 * Manager Class that handles invoice payments operations similar to PayManager
	 * @author Ilya Shcherbakov. Telefision AG.
	 */
	
	public class PaymentsManager {
		
		static public const NO_ACC:String = "Error_NoAccount";
		
		static public var S_COMPLETE:Signal = new Signal("InvoiceManagerNew.S_COMPLETE");
		static public var S_ERROR:Signal = new Signal("InvoiceManagerNew.S_ERROR");
		static public var S_READY:Signal = new Signal("InvoiceManagerNew.S_READY");
		static public var S_ACCOUNT:Signal = new Signal("InvoiceManagerNew.S_ACCOUNT");
		static public var S_BACK:Signal = new Signal("InvoiceManagerNew.S_BACK");
		
		static private var _isActive:Boolean;
		static private var _isAuthorized:Boolean;
		static private var _authorizing:Boolean;
		
		static private var _task:PayTaskVO;
		static private var _callID:String;
		static private var logging:Boolean;
		
		public function PaymentsManager() { }
		
		static public function activate():Boolean {
			if (_isActive == true)
				return false;
			_isActive = true;
			if (Auth.bank_phase == "ACC_APPROVED") {
				if (_authorizing == true)
					return true;
				_authorizing = true;
				initPayManagers();
				return true;
			}
			S_ERROR.invoke(NO_ACC);
			return true;
		}
		
		static public function deactivate():void {
			_isActive = false;
			_isAuthorized = false;
			_authorizing = false;
			_task = null;
			removePayAuthManagerEvents();
		}
		
		static private function onBack():void {
			_authorizing = false;
			_isActive = false;
			_isAuthorized = false;
			logging = false;
			S_BACK.invoke();
		}
		
		static private function initPayManagers():void {
			initPayManager();
			initPayAuthManager();
		}
		
		static private function initPayManager():void {
			PayManager.init();
			TweenMax.delayedCall(1, initPayManagerContinue, null, 1);
		}
		
		static private function initPayManagerContinue():void {
			if (PayConfig.PAY_SESSION_ID == "") {
				if (logging == true) {
					logging = false;
					onPassDismiss();
					return;
				}
				logging = true;
				PayAPIManager.login(initPayManagerContinue);
				return;
			}
			if (PayManager.systemOptions == null || "currencyList" in PayManager.systemOptions == false) {
				PayManager.S_SYSTEM_OPTIONS_READY.add(onSystemOptions);
				PayManager.callGetSystemOptions();
				return;
			}
			if (PayManager.accountInfo == null) {
				PayManager.S_ACCOUNT.add(onAccountGetted);
				PayManager.callGetAccountInfo();
				return;
			}
			S_ACCOUNT.invoke();
			onReady();
		}
		
		static private function onReady():void {
			if (_task != null)
				processTask();
			_isAuthorized = true;
			_authorizing = false;
			S_READY.invoke();
		}
		
		static private function initPayAuthManager():void {
			PayAuthManager.activate();
			PayAuthManager.init();
			PayAuthManager.S_ON_BACK.add(onBack);
			PayAuthManager.S_ON_AUTH_SUCCESS.add(onAuthPassSuccess);
			PayAuthManager.S_ON_DISMISS_PASS.add(onPassDismiss);
		}
		
		static private function removePayAuthManagerEvents():void {
			PayAuthManager.deactivate();
			PayAuthManager.S_ON_BACK.remove(onBack);
			PayAuthManager.S_ON_AUTH_SUCCESS.remove(onAuthPassSuccess);
			PayAuthManager.S_ON_DISMISS_PASS.remove(onPassDismiss);
		}
		
		static private function onConfig():void {
			initPayManager();
		}
		
		static private function onSystemOptions():void {
			PayManager.S_SYSTEM_OPTIONS_READY.remove(onSystemOptions);
			initPayManagerContinue();
		}
		
		static private function onAccountGetted():void {
			PayManager.S_ACCOUNT.remove(onAccountGetted);
			onAccountReceived();
			onReady();
		}
		
		static private function onAuthPassSuccess():void {
			if (_isAuthorized == false)
				return;
			if (_task != null)
				processTask();
		}
		
		static private function onPassDismiss():void {
			/*S_ERROR.invoke();*/
			S_BACK.invoke();
		}
		
		static public function startTask(task:PayTaskVO, callID:String):void {
			if (_task != null)
				return;
			if (task == null) {
				S_ERROR.invoke();
				return;
			}
			_task = task;
			_callID = callID;
			if (_isActive == false) {
				activate();
				return;
			}
			if (_isAuthorized == false)
				return;
			processTask();
		}
		
		static private function processTask():void {
			if (_task == null)
				return;
			var paymentsFunction:Function;
			if (_task.taskType == PayTaskVO.TASK_TYPE_PAY_MERCH)
				paymentsFunction = PayManager.callMerchTransfer;
			else if (_task.taskType == PayTaskVO.TASK_TYPE_SELF_TRANSFER)
				paymentsFunction = PayManager.callInternalTransferFromGiftScreen;
			else
				paymentsFunction = PayManager.callInvoiceTransfer;
			if (paymentsFunction != null)
				paymentsFunction(_task.generateRequestObject(), _callID, onTransferRespond);
		}
		
		public static function updateAccount():void {
			if (_isActive == false)
				return;
			if (isAuthorized == false) {
				initPayManagers();
				return;
			}
			PayManager.S_ACCOUNT.add(onAccountReceived);
			PayManager.callGetAccountInfo();
		}
		
		public static function onTransferRespond(respond:PayRespond):void {
			if (respond.savedRequestData.callID != _callID)
				return;
			if (checkForError(respond) == false) {
				S_COMPLETE.invoke(respond.data, _callID);
				PayManager.S_ACCOUNT.add(onAccountReceived);
				PayManager.callGetAccountInfo();
			}
			_task = null;
			_callID = null;
		}
		
		static private function onAccountReceived():void {
			PayManager.S_ACCOUNT.remove(onAccountReceived);
			S_ACCOUNT.invoke();
		}
		
		static private function checkForError(respond:PayRespond):Boolean {
			if (respond.error == false)
				return false;
			if (respond.hasAuthorizationError == true) {
				PayManager.validateAuthorization(respond);
				PayManager.clearSavedData();
				S_ERROR.invoke(null, Lang.somethingWentWrong);
			} else if (respond.errorCode == 3408) { // PWP operation amount limit reached	see PWP mode
				PayManager.needAuthorizationInvoke();
				PayManager.clearSavedData();
				S_ERROR.invoke(null, Lang.somethingWentWrong);
			} else if (respond.errorCode == 3409) { // PWP daily limit reached
				PayManager.needAuthorizationInvoke();
				PayManager.clearSavedData();
				S_ERROR.invoke(null, Lang.somethingWentWrong);
			} else if (respond.hasTrialVersionError == true) {
				S_ERROR.invoke(null, Lang.somethingWentWrong);
				var unfinishedTask:PayTaskVO = _task;
				var screenData:Object = {};
				screenData.unfinishedTask = unfinishedTask;
				screenData.backScreen = MobileGui.centerScreen.currentScreenClass;
				screenData.backScreenData  = MobileGui.centerScreen.currentScreen.data;
				MobileGui.changeMainScreen(PaymentsRTOLimitsScreen, screenData, ScreenManager.DIRECTION_RIGHT_LEFT);
			} else
				S_ERROR.invoke(respond.errorCode, respond.errorMsg);
			return true;
		}
		
		static public function get isAuthorized():Boolean {
			return _isAuthorized;
		}
	}
}