package com.dukascopy.connect.sys.payments {
	
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.CardDeliveryAddress;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.screens.RootScreen;
	import com.dukascopy.connect.screens.payments.OrderCardScreen;
	import com.dukascopy.connect.screens.payments.PayCardsManager;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.connectionManager.NetworkManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.payments.vo.AccountInfoVO;
	import com.dukascopy.connect.sys.payments.vo.SystemOptionsVO;
	import com.dukascopy.langs.Lang;
	import com.dukascopy.langs.LangManager;
	import com.greensock.TweenMax;
	import com.telefision.sys.signals.Signal;
	import flash.text.TextFormatAlign;
	
	/**
	 *  Manager Class that stores payment data
	 *  HTTPS Protocol - only https is supported
	 *  account information
	 *  session id
	 *  allowed currencies
	 *  user exists in payments
	 *  ...
	 *
	 * @author Alexey
	 */
	
	public class PayManager {
		
		static public var S_RESET:Signal = new Signal("PayManager.S_RESET");
		static public var S_CALL_AGAIN:Signal = new Signal("PayManager.S_CALL_AGAIN");
		static public var S_PENDING_CHANGED:Signal = new Signal("PayManager.S_PENDING_CHANGED");
		static public var S_PASS_CHANGE_RESPOND:Signal = new Signal("PayManager.S_PASS_CHANGE_RESPOND");
		static public var S_SYSTEM_OPTIONS_READY:Signal = new Signal("PayManager.S_SYSTEM_OPTIONS_READY");
		static public var S_SYSTEM_OPTIONS_ERROR:Signal = new Signal("PayManager.S_SYSTEM_OPTIONS_ERROR");
		static public var S_INVESTMENTS_RATE_RESPOND:Signal = new Signal("PayManager.S_INVESTMENTS_RATE_RESPOND");
		static public var S_SELL_COINS_BULK_COMMISSION_RESPOND:Signal = new Signal("PayManager.S_SELL_COINS_BULK_COMMISSION_RESPOND");
		static public var S_SELL_COINS_COMMISSION_BULK_RECEIVED:Signal = new Signal("PayManager.S_SELL_COINS_COMMISSION_BULK_RECEIVED");
		
		static public var S_NEED_AUTHORIZATION:Signal;
		static public var S_INVALID_PASS_DIALOG_CLOSED:Signal;
		static public var S_CANCEL_AUTH:Signal = new Signal("PayManager.S_CANCEL_AUTH");
		static public var S_ACCOUNT:Signal = new Signal("PayManager.S_ACCOUNT");
		static public var S_ACCOUNT_RESPOND:Signal = new Signal("PayManager.S_ACCOUNT_RESPOND");;
		static public var S_ENTER_PASSWORD_DISMISS:Signal;
		static public var S_MONEY_TRANSFERED:Signal;
		static public var S_MONEY_TRANSFERED_ERROR:Signal;
		static public var S_SEND_MONEY_COMMISSION_RECEIVED:Signal = new Signal("PayManager.S_SEND_MONEY_COMMISSION_RECEIVED");
		static public var S_SELL_COINS_COMMISSION_RECEIVED:Signal;
		static public var S_BCD_COINS_COMMISSION_RECEIVED:Signal = new Signal("PayManager.S_SELL_COINS_COMMISSION_RECEIVED");
		static public var S_INVESTMENT_COMMISSION_RECEIVED:Signal = new Signal("PayManager.S_INVESTMENT_COMMISSION_RECEIVED");
		static public var S_SEND_MONEY_COMMISSION_RESPOND:Signal = new Signal("PayManager.S_SEND_MONEY_COMMISSION_RESPOND");
		static public var S_SELL_COINS_COMMISSION_RESPOND:Signal;
		static public var S_BCD_COINS_COMMISSION_RESPOND:Signal;
		static public var S_INTERNAL_TRANSFER_CALL:Signal;
		static public var S_INVOICE_TRANSFER_RESPOND:Signal;
		static public var S_MERCH_TRANSFER_RESPOND:Signal;
		static public var S_SELF_TRANSFER_RESPOND:Signal;
		static public var S_WITHDRAWAL_COMMISSION_RECEIVED:Signal;
		static public var S_WITHDRAWAL_COMMISSION_RESPOND:Signal;
		static public var S_DEPOSITE_COMMISSION_RECEIVED:Signal;
		static public var S_CURRENCY_RATE_RECEIVE:Signal;
		static public var S_CURRENCY_RATE_ERROR:Signal;
		static public var S_PPCARDS_RECEIVE:Signal;
		static public var S_DUKASCOPY_CARDS_RESPOND:Signal;
		static public var S_DUKASCOPY_LINKED_CARDS_RESPOND:Signal;
		static public var S_MONEY_CARDS_RECEIVE:Signal;
		static public var S_ACCOUNT_SETTINGS_POST:Signal;
		static public var S_ACCOUNT_SETTINGS_CHANGE_RESPOND:Signal;
		static public var S_PPCARD_COMMISSION_RECEIVE:Signal;
		static public var S_PPCARD_ISSUE_RECEIVE:Signal;
		static public var S_ON_EXIT_PAYMENTS:Signal;
		static public var S_TRIAL_REACHED:Signal;
		static public var S_TRIAL_RESETED:Signal;
		static public var S_LOGOUT_CALL:Signal;
		static public var S_LOGOUT_RECEIVE:Signal;
		static public var S_PASS_CHANGED:Signal;
		static public var S_PASS_CHECKING_STATE_CHANGED:Signal;
		static public var S_PASS_RESPONDED:Signal;
		static public var S_PASS_AUTHORIZE_SUCESS:Signal;
		static public var S_NEED_PASS_CHANGE:Signal;
		static public var S_ACCOUNT_NOT_APPROVED:Signal;
		static public var S_WITHDRAWAL_COMMISSION_RECEIVED_ERROR:Signal;
		static public var S_DEPOSITE_COMMISSION_RECEIVED_ERROR:Signal;
		
		static public var S_ACCOUNT_UPDATE_RESPOND:Signal = new Signal("PayManager.S_ACCOUNT_UPDATE_RESPOND");
		static public var S_ACCOUNT_UPDATE_ERROR:Signal = new Signal("PayManager.S_ACCOUNT_UPDATE_ERROR");
		
		static public var S_LIMITS_INCREASE_RESPOND:Signal = new Signal("PayManager.S_LIMITS_INCREASE_RESPOND");
		static public var S_LIMITS_INCREASE_ERROR:Signal = new Signal("PayManager.S_LIMITS_INCREASE_ERROR");
		
		static public var S_DECLARE_BLOCKCHAIN_ADDRESS_ERROR:Signal = new Signal("PayManager.S_DECLARE_BLOCKCHAIN_ADDRESS_ERROR");
		static public var S_DECLARE_BLOCKCHAIN_ADDRESS_SUCCESS:Signal = new Signal("PayManager.S_DECLARE_BLOCKCHAIN_ADDRESS_SUCCESS");
		
		static private var savedData:Object;
		static public var respondThatTriggeredAuthorization:PayRespond;
		static private var _hasPendingTransfer:Boolean = false;
		
		static private var _isInitialized:Boolean = false;
		static private var _isAuthInitialized:Boolean = false;
		static private var _accountInfo:/*Object*/ AccountInfoVO;
		static private var _isAccountBlocked:Boolean = false;
		
		static private var _internalTransferBusy:Boolean = false;
		static private var _externalTransferBusy:Boolean = false;
		static private var _creatingWalletBussy:Boolean = false;
		static private var _isWaitingForPass:Boolean = false;
		
		static private var _isInsidePaymentsScreenNow:Boolean = false;
		static private var _wasFirstResponse:Boolean = false;
		
		// data that stored
		static public var systemOptions:SystemOptionsVO;
		
		static private var _trialReached:Boolean = false;
		
		static public var cachedCardsData:Object;
		static public var cachedCardsDataMyCard:Object;
		
		private static const key_session_id:String = "session_id";
		
		public function PayManager() { }
			
		static public function init():void {
			if (_isInitialized == true)
				return;
			_isInitialized = true;
			S_ON_EXIT_PAYMENTS = new Signal("PayManager.S_ON_EXIT_PAYMENTS");
			S_NEED_AUTHORIZATION = new Signal("PayManager.S_NEED_AUTHORIZATION");
		//	S_CANCEL_AUTH = new Signal("PayManager.S_CANCEL_AUTH");
			S_INVALID_PASS_DIALOG_CLOSED = new Signal("PayManager.S_INVALID_PASS_DIALOG_CLOSED");
		//	S_ACCOUNT = new Signal("PayManager.S_ACCOUNT");
		//	S_ACCOUNT_RESPOND = new Signal("PayManager.S_ACCOUNT_RESPOND");
			S_MONEY_TRANSFERED = new Signal("PayManager.S_MONEY_TRANSFERED");
			S_MONEY_TRANSFERED_ERROR = new Signal("PayManager.S_MONEY_TRANSFERED_ERROR");
			S_INTERNAL_TRANSFER_CALL = new Signal("PayManager.S_INTERNAL_TRANSFER_CALL");
			S_INVOICE_TRANSFER_RESPOND = new Signal("PayManager.S_INVOICE_TRANSFER_RESPOND");
			S_MERCH_TRANSFER_RESPOND = new Signal("PayManager.S_MERCH_TRANSFER_RESPOND");
			S_SELF_TRANSFER_RESPOND = new Signal("PayManager.S_SELF_TRANSFER_RESPOND");
		//	S_SEND_MONEY_COMMISSION_RECEIVED = new Signal("PayManager.S_SEND_MONEY_COMMISSION_RECEIVED");
			S_SELL_COINS_COMMISSION_RECEIVED = new Signal("PayManager.S_SELL_COINS_COMMISSION_RECEIVED");
		//	S_BCD_COINS_COMMISSION_RECEIVED = new Signal("PayManager.S_SELL_COINS_COMMISSION_RECEIVED");
		//	S_INVESTMENT_COMMISSION_RECEIVED = new Signal("PayManager.S_INVESTMENT_COMMISSION_RECEIVED");
		//	S_SEND_MONEY_COMMISSION_RESPOND = new Signal("PayManager.S_SEND_MONEY_COMMISSION_RESPOND");
			S_SELL_COINS_COMMISSION_RESPOND = new Signal("PayManager.S_SELL_COINS_COMMISSION_RESPOND");
			S_BCD_COINS_COMMISSION_RESPOND = new Signal("PayManager.S_BCD_COINS_COMMISSION_RESPOND");
			S_WITHDRAWAL_COMMISSION_RECEIVED = new Signal("PayManager.S_WITHDRAWAL_COMMISSION_RECEIVED");			 
			S_WITHDRAWAL_COMMISSION_RESPOND = new Signal("PayManager.S_WITHDRAWAL_COMMISSION_RESPOND");			 
			S_DEPOSITE_COMMISSION_RECEIVED = new Signal("PayManager.S_DEPOSITE_COMMISSION_RECEIVED");
			S_PPCARDS_RECEIVE = new Signal("PayManager.S_PPCARDS_RECEIVE");
			S_DUKASCOPY_CARDS_RESPOND = new Signal("PayManager.S_DUKASCOPY_CARDS_RESPOND");
			S_DUKASCOPY_LINKED_CARDS_RESPOND = new Signal("PayManager.S_DUKASCOPY_LINKED_CARDS_RESPOND");
			S_MONEY_CARDS_RECEIVE = new Signal("PayManager.S_MONEY_CARDS_RECEIVE");
			S_ACCOUNT_SETTINGS_POST = new Signal("PayManager.S_ACCOUNT_SETTINGS_POST");
			S_ACCOUNT_SETTINGS_CHANGE_RESPOND = new Signal("PayManager.S_ACCOUNT_SETTINGS_CHANGE_RESPOND");
			S_PPCARD_COMMISSION_RECEIVE = new Signal("PayManager.S_PPCARD_COMMISSION_RECEIVE");
			S_PPCARD_ISSUE_RECEIVE = new Signal("PayManager.S_PPCARD_ISSUE_RECEIVE");
			S_CURRENCY_RATE_RECEIVE = new Signal("PayManager.S_CURRENCY_RATE_RECEIVE");
			S_CURRENCY_RATE_ERROR = new Signal("PayManager.S_CURRENCY_RATE_ERROR");
			S_TRIAL_REACHED = new Signal("PayManager.S_TRIAL_REACHED");
			S_TRIAL_RESETED = new Signal("PayManager.S_TRIAL_RESET");
			S_LOGOUT_CALL = new Signal("PayManager.S_LOGOUT_CALL");
			S_LOGOUT_RECEIVE = new Signal("PayManager.S_LOGOUT_RECEIVE");
			S_PASS_CHANGED = new Signal("PayManager.S_PASS_CHANGED");
			S_PASS_CHECKING_STATE_CHANGED = new Signal("PayManager.S_PASS_CHECKING_STATE_CHANGED");
			S_PASS_RESPONDED = new Signal("PayManager.S_PASS_RESPONDED");
			S_PASS_AUTHORIZE_SUCESS = new Signal("PayManager.S_PASS_AUTHORIZE_SUCESS");
			S_NEED_PASS_CHANGE = new Signal("PayManager.S_NEED_PASS_CHANGE");
			S_ACCOUNT_NOT_APPROVED = new Signal("PayManager.S_ACCOUNT_NOT_APPROVED");
			S_WITHDRAWAL_COMMISSION_RECEIVED_ERROR = new Signal("PayManager.S_WITHDRAWAL_COMMISSION_RECEIVED_ERROR");
			S_DEPOSITE_COMMISSION_RECEIVED_ERROR = new Signal("PayManager.S_DEPOSITE_COMMISSION_RECEIVED_ERROR");
			S_ENTER_PASSWORD_DISMISS = new Signal("PayManager.S_ENTER_PASSWORD_DISMISS");
			authInit();
		}
		
		static private function authInit():void {
			if (_isAuthInitialized == true)
				_isAuthInitialized = true;
			Auth.S_NEED_AUTHORIZATION.add(reset);
		}
		
		/**
		 * GET System Options
		 */
		static public function callGetSystemOptions(callback:Function = null):void {
			if (systemOptionsReady == true) {
				TweenMax.delayedCall(1, function():void {
					S_SYSTEM_OPTIONS_READY.invoke();
					if (callback != null)
						callback();
				}, null, true);
				return;
			}
			if (callback != null) {
				PayServer.call_getSystemOptions(function(respond:PayRespond):void {
					onGetOptions(respond);
					callback();
				} );
				return;
			}
			PayServer.call_getSystemOptions(onGetOptions);
		}
		
		static private function onGetOptions(respond:PayRespond):void {
			if (respond.error) {
				echo("PayManager", "onGetOptions", respond.errorMsg);
				S_SYSTEM_OPTIONS_ERROR.invoke();
				return;
			}
			systemOptions ||= new SystemOptionsVO();
			systemOptions.update(respond.data);
			CurrencyHelpers.updateDecimalsRulesAndSymbols(systemOptions.currencyDecimalRules, systemOptions.currencySymbols);
			S_SYSTEM_OPTIONS_READY.invoke();
		}
		
		static public function callLogout():void {
			if (NetworkManager.isConnected == false) {
				showAlert(Lang.textError, Lang.noInternetConnection);
				return;
			}
			PayManager.accountInfo = null;
			if (S_LOGOUT_CALL != null)
				S_LOGOUT_CALL.invoke();
			PayAPIManager.lockSession();
		}
		
		static private function onLogoutRespond(respond:PayRespond):void {
			if (S_LOGOUT_RECEIVE != null)
				S_LOGOUT_RECEIVE.invoke();
		}
		
		/**
		 * Check what kind of authorization Errors occurs
		 * and invokes needed Signal
		 *
		 * @param    respond
		 * @return
		 */
		public static function validateAuthorization(respond:PayRespond):void {
			if (respond == null)
				return;
			if (respond.errorCode == PayRespond.ERROR_NOT_APPROVED_ACCOUNT) {
				showAlert(Lang.textError, Lang.TEXT_ACCOUNT_NOT_APPROVED);
				S_ACCOUNT_NOT_APPROVED.invoke();
				return;
			}
			if (respond.errorCode == PayRespond.ERROR_CODE_SESSION_INVALID) {
				PayConfig.PAY_SESSION_ID = "";
				PayAPIManager.login(onAuth);
				return;
			}
			if (respond.errorCode == PayRespond.ERROR_NEED_PASSWORD) {
				respondThatTriggeredAuthorization = respond;
				needAuthorizationInvoke();
				savedData = respond.savedRequestData;
				return;
			}
			if (respond.errorCode == PayRespond.ERROR_NEED_PASSWORD_CHANGE) {
				S_NEED_PASS_CHANGE.invoke();
				return;
			}
			if (respond.errorCode == PayRespond.ERROR_CODE_ACCOUNT_IS_BLOCKED) {
				_isAccountBlocked = true;
				showAlert(Lang.textError, Lang.TEXT_BLOCKED_ACCOUNT);
				S_ACCOUNT_NOT_APPROVED.invoke();
				return;
			}
		}
		
		static private function onAuth(cancelled:Boolean = false):void {
			if (cancelled)
			{
				invokeCancelAuthSignal();
				return;
			}
			
			callGetAccountInfo();
		}
		
		public static function needAuthorizationInvoke():void {
			cachedCardsData = null;
			cachedCardsDataMyCard = null;
			S_NEED_AUTHORIZATION.invoke();
		}
		
		/**
		 * GET Account Info
		 */
		static public function callGetAccountInfo(callback:Function = null):void {
			if (!NetworkManager.isConnected) {
				showAlert(Lang.textError, Lang.noInternetConnection);
				return;
			}
			if (callback != null) {
				PayServer.call_getHome(
					function(response:PayRespond):void {
						onAccountGetted(response);
						if (callback != null)
							callback();
					},
					false
				);
				return;
			}
			PayServer.call_getHome(onAccountGetted, false);
		}
		
		static private function onAccountGetted(respond:PayRespond):void {
			_wasFirstResponse = true;
			S_ACCOUNT_RESPOND.invoke();
			if (respond.savedRequestData != null && respond.savedRequestData.url != null) {
				var currentAPIURL:String = PayConfig.PAY_API_URL;
				var respondedAPIURL:String = respond.savedRequestData.url;
				if (respondedAPIURL.indexOf(currentAPIURL) != -1) {
					if (respond.hasAuthorizationError == true) {
						validateAuthorization(respond);
						return;
					}
					if (respond.error == true) {
						showAlert(Lang.textError, respond.errorMsg);
						return;
					}
					_accountInfo ||= new AccountInfoVO();
					_accountInfo.update(respond.data.account);
					if ("coins" in respond.data)
						_accountInfo.setCoins(respond.data.coins);
					S_ACCOUNT.invoke();
				}
			}
			if (savedData != null)
			{
				callAgain(savedData);
				savedData = null;
			}
		}
		
		private static var lastPassCallID:String = "";
		private static var passCounter:int = 1;
		
		/**
		 * Call Password Submit
		 * @param    pass
		 */
		static public function callPass(pass:String):void {
			isWaitingForPass = true;
			passCounter++;
			lastPassCallID = new Date().getTime().toString() + passCounter;
			PayServer.call_passCheck(onPassChecked, pass, lastPassCallID);
		}
		
		static private function onPassChecked(respond:PayRespond):void {
			// TODO esli imejutsa Authorization level errors - > isLoggedin = false;
			if (lastPassCallID != respond.savedRequestData.callID) {
				return;
			}
			S_PASS_RESPONDED.invoke(respond);
			isWaitingForPass = false;
			if (respond.errorCode == PayRespond.ERROR_PASSWORD_INVALID) {
				//show invalid error popup
				showAlert(Lang.alertAuthorisationError, Lang.TEXT_PASS_INVALID , onAuthWarningCallback, Lang.btnTryAgain);
				//InvoiceManager.S_ERROR_PROCESS_INVOICE.invoke();
				return;
			}
			if (respond.errorCode == PayRespond.ERROR_CODE_TOO_MANY_WRONG_PASSWORD_ENTERED) {
				showAlert(Lang.alertAuthorisationError, Lang.PASS_VERIFICATION_BLOCKED, onManyWrongPassClosed);
				//InvoiceManager.S_ERROR_PROCESS_INVOICE.invoke();
				return;
			}
			if (respond.hasAuthorizationError) {
				validateAuthorization(respond);
				return;
			}
			if (respond.error) {
				needAuthorizationInvoke();
				return;
			}
			if (respond.data == 0) {
				needAuthorizationInvoke();
				return;
			}
			//touchid
			S_PASS_AUTHORIZE_SUCESS.invoke();
			if (respond.savedRequestData.data != null && respond.savedRequestData.data.password != null) {
				if (MobileGui.touchIDManager != null) {
					MobileGui.touchIDManager.changePassTouchID(respond.savedRequestData.data.password);
					MobileGui.touchIDManager.saveTouchID(respond.savedRequestData.data.password);
				}
				if (respond.error == false) {
					PayAPIManager.S_LOGIN_SUCCESS.invoke(respond.savedRequestData);
				}
			}
			
			callAgain(savedData);
			savedData = null;
		}
		
		
		static private function onManyWrongPassClosed(value:int):void {
			MobileGui.changeMainScreen(RootScreen, null, 1);
		}
		
		static private function onAuthWarningCallback(value:int):void {
			if (value == 1) {
				needAuthorizationInvoke();
				TweenMax.delayedCall(.1, invokeNeedAuthSignal);
			} else if (value == 0) {
				savedData = null;
				TweenMax.delayedCall(.1, invokeCancelAuthSignal);				
				S_INVALID_PASS_DIALOG_CLOSED.invoke();
			}
		}
		
		static private function invokeNeedAuthSignal():void {
			echo("PayManager", "onAuthWarningCallback");
			needAuthorizationInvoke();
		}
		
		static private function invokeCancelAuthSignal():void {
			echo("PayManager", "invokeCancelAuthSignal");
			S_CANCEL_AUTH.invoke();
		}
		
		/**
		 * CALL Change Password
		 */
		static public function callChangePassword(currentPass:String, newPass:String):void {
			PayServer.call_passChange(onPassChangeRespond, currentPass, newPass);
		}
		
		static private function onPassChangeRespond(respond:PayRespond):void {
			S_PASS_CHANGE_RESPOND.invoke(respond);
			 
			if (respond.hasAuthorizationError) {
				validateAuthorization(respond);
				return;
			}
			if (respond.error) {
				showAlert(Lang.textAlert, respond.errorMsg);
				return;
			}
			else {
				if (respond.savedRequestData.data != null && "new" in respond.savedRequestData.data) {
					if (MobileGui.touchIDManager != null)
						MobileGui.touchIDManager.changePassTouchID(respond.savedRequestData.data["new"]);
				}
				if (S_PASS_CHANGED != null)
					S_PASS_CHANGED.invoke();
				ToastMessage.display(Lang.alertPasswordSuccessfully);
				return;
			}
		}
		
		static public function callMarketTradeEstimate(side:String, value:Number, priceLimit:Number, callback:Function):void {
			PayServer.callMarketTradeEstimate(callMarketTradeEstimateRespond, side, value, priceLimit, callback);
		}
		
		static private function callMarketTradeEstimateRespond(respond:PayRespond):void {
			
			if (respond.hasAuthorizationError) {
				validateAuthorization(respond);
				return;
			}
			// trial reached
			if (respond.hasTrialVersionError) {
				savedData = respond.savedRequestData;
				_trialReached = true;
				S_TRIAL_REACHED.invoke();
				return;
			}
			if (respond.savedRequestData != null && respond.savedRequestData.callback != null)
			{
				respond.savedRequestData.callback(respond);
			}
		}
		
		static public function callMarketTradeExecute(side:String, value:Number, fiatAmount:Number, callback:Function):void {
			PayServer.callMarketTradeExecute(callMarketTradeExecuteRespond, side, value, fiatAmount, callback);
		}
		
		static private function callMarketTradeExecuteRespond(respond:PayRespond):void {
			
			if (respond.hasAuthorizationError) {
				validateAuthorization(respond);
				return;
			}
			// trial reached
			if (respond.hasTrialVersionError) {
				savedData = respond.savedRequestData;
				_trialReached = true;
				S_TRIAL_REACHED.invoke();
				return;
			}
			if (respond.savedRequestData != null && respond.savedRequestData.callback != null)
			{
				respond.savedRequestData.callback(respond);
			}
		}
		
		static public function callGetInstrumentRatesHistory(instrumentCode:String, callback:Function):void {
			PayServer.callGetInstrumentRatesHistory(callGetInstrumentRatesHistoryRespond, instrumentCode, callback);
		}
		
		static private function callGetInstrumentRatesHistoryRespond(respond:PayRespond):void {
			
			if (respond.hasAuthorizationError) {
				validateAuthorization(respond);
				return;
			}
			// trial reached
			if (respond.hasTrialVersionError) {
				savedData = respond.savedRequestData;
				_trialReached = true;
				S_TRIAL_REACHED.invoke();
				return;
			}
			if (respond.savedRequestData != null && respond.savedRequestData.callback != null)
			{
				respond.savedRequestData.callback(respond);
			}
		}
		
		/**
		 * GET Currency Transfer Rate
		 * @param    fromCurrency
		 * @param    toCurrency
		 * @param    amount
		 * @param    currency
		 * @param    callID
		 */
		static public function callGetCurrencyTransferRate(fromCurrency:String, toCurrency:String, amount:Number, currency:String, callID:String = ""):void {
			if (!NetworkManager.isConnected) {
				S_CURRENCY_RATE_ERROR.invoke(Lang.checkNetworkStatus);
			//	showAlert(Lang.textError, Lang.noInternetConnection);
				return;
			}
			PayServer.call_getMoneyTransferRate(onTransferRateReceive, fromCurrency, toCurrency, amount, currency, callID);
		}
		
		static private function onTransferRateReceive(respond:PayRespond):void {
			if (respond.hasAuthorizationError) {
				S_CURRENCY_RATE_ERROR.invoke();
				validateAuthorization(respond);
				return;
			}
			// trial reached
			if (respond.hasTrialVersionError) {
				savedData = respond.savedRequestData;
				_trialReached = true;
				S_TRIAL_REACHED.invoke();
				return;
			}
			if (respond.error) {
				S_CURRENCY_RATE_ERROR.invoke();
				showAlert(Lang.textError, respond.errorMsg);
				return;
			}
			S_CURRENCY_RATE_RECEIVE.invoke(respond.savedRequestData.callID, respond.data);
		}
		
		static public function callGetSellCoinsCommission(amount:Number, price:Number, callID:String = ""):void {
			if (!NetworkManager.isConnected) {
				showAlert(Lang.textError, Lang.noInternetConnection);
				return;
			}
			PayServer.call_getCoinSellCommision(onSellCoinsCommissionRespond, amount, price, callID);
		}
		
		static public function callGetSellCoinsBulkCommission(request:Object, callID:String = ""):void {
			if (!NetworkManager.isConnected) {
				showAlert(Lang.textError, Lang.noInternetConnection);
				return;
			}
			PayServer.call_getCoinSellBulkCommision(onSellCoinsCommissionBulkRespond, request, callID);
		}
		
		static private function onSellCoinsCommissionBulkRespond(respond:PayRespond):void {
			//!TODO: can be null?
			if (S_SELL_COINS_BULK_COMMISSION_RESPOND == null) {
				init();
			}
			S_SELL_COINS_BULK_COMMISSION_RESPOND.invoke(respond);
			if (respond.hasAuthorizationError) {
				validateAuthorization(respond);
				return;
			}
			// trial reached
			if (respond.hasTrialVersionError) {
				savedData = respond.savedRequestData;
				_trialReached = true;
				S_TRIAL_REACHED.invoke();
				return;
			}
			if (respond.error) {
				S_SELL_COINS_COMMISSION_BULK_RECEIVED.invoke(respond.savedRequestData.callID, null);
				showAlert(Lang.textError, respond.errorMsg);
				return;
			}
			S_SELL_COINS_COMMISSION_BULK_RECEIVED.invoke(respond.savedRequestData.callID, respond.data);
		}
		
		static private function onSellCoinsCommissionRespond(respond:PayRespond):void {
			//!TODO: can be null?
			if (S_SELL_COINS_COMMISSION_RESPOND == null) {
				init();
			}
			S_SELL_COINS_COMMISSION_RESPOND.invoke(respond);
			if (respond.hasAuthorizationError) {
				validateAuthorization(respond);
				return;
			}
			// trial reached
			if (respond.hasTrialVersionError) {
				savedData = respond.savedRequestData;
				_trialReached = true;
				S_TRIAL_REACHED.invoke();
				return;
			}
			if (respond.error) {
				S_SELL_COINS_COMMISSION_RECEIVED.invoke(respond.savedRequestData.callID, null);
				showAlert(Lang.textError, respond.errorMsg);
				return;
			}
			S_SELL_COINS_COMMISSION_RECEIVED.invoke(respond.savedRequestData.callID, respond.data);
		}
		
		static public function callGetBCDCoinsCommission(amount:Number, callID:String = ""):void {
			if (!NetworkManager.isConnected) {
				showAlert(Lang.textError, Lang.noInternetConnection);
				return;
			}
			PayServer.call_getCoinBCDCommision(onBCDCoinsCommissionRespond, amount, callID);
		}
		
		static private function onBCDCoinsCommissionRespond(respond:PayRespond):void {
			if (S_BCD_COINS_COMMISSION_RESPOND == null) {
				init();
			}
			S_BCD_COINS_COMMISSION_RESPOND.invoke(respond);
			if (respond.hasAuthorizationError) {
				validateAuthorization(respond);
				return;
			}
			// trial reached
			if (respond.hasTrialVersionError) {
				savedData = respond.savedRequestData;
				_trialReached = true;
				S_TRIAL_REACHED.invoke();
				return;
			}
			if (respond.error) {
				S_BCD_COINS_COMMISSION_RECEIVED.invoke(respond.savedRequestData.callID, respond.errorCode);
				showAlert(Lang.textError, respond.errorMsg);
				return;
			}
			S_BCD_COINS_COMMISSION_RECEIVED.invoke(respond.savedRequestData.callID, respond.data);
		}
		
		static public function callGetInvestmentBlockchainCommission(amount:Number, instrument:String, callID:String = ""):void {
			if (!NetworkManager.isConnected) {
				showAlert(Lang.textError, Lang.noInternetConnection);
				return;
			}
			PayServer.call_getInvestmentBlockchainCommision(onInvestmentBlockchainCommissionRespond, amount, instrument, callID);
		}
		
		static private function onInvestmentBlockchainCommissionRespond(respond:PayRespond):void {
			if (S_INVESTMENT_COMMISSION_RECEIVED == null) {
				init();
			}
		//	S_INVESTMENT_COMMISSION_RECEIVED.invoke(respond);
			if (respond.hasAuthorizationError) {
				S_INVESTMENT_COMMISSION_RECEIVED.invoke(respond.savedRequestData.callID, respond.errorMsg);
				validateAuthorization(respond);
				return;
			}
			// trial reached
			if (respond.hasTrialVersionError) {
				savedData = respond.savedRequestData;
				_trialReached = true;
				S_TRIAL_REACHED.invoke();
				return;
			}
			if (respond.error) {
				S_INVESTMENT_COMMISSION_RECEIVED.invoke(respond.savedRequestData.callID, respond.errorMsg);
				showAlert(Lang.textError, respond.errorMsg);
				return;
			}
			S_INVESTMENT_COMMISSION_RECEIVED.invoke(respond.savedRequestData.callID, respond.data);
		}
		
		static public function callGetSendMoneyCommission(amount:Number, currency:String, callID:String = ""):void {
			if (!NetworkManager.isConnected) {
				showAlert(Lang.textError, Lang.noInternetConnection);
				return;
			}
			PayServer.call_getMoneySendCommision(onSendMoneyCommissionRespond, amount, currency, callID);
		}
		
		static private function onSendMoneyCommissionRespond(respond:PayRespond):void {
			//!TODO: can be null?
			if (S_SEND_MONEY_COMMISSION_RESPOND == null) {
				init();
			}
			S_SEND_MONEY_COMMISSION_RESPOND.invoke(respond);
			if (respond.hasAuthorizationError) {
				savedData = respond.savedRequestData;
				validateAuthorization(respond);
				return;
			}
			// trial reached
			if (respond.hasTrialVersionError) {
				savedData = respond.savedRequestData;
				_trialReached = true;
				S_TRIAL_REACHED.invoke();
				return;
			}
			if (respond.error) {
				S_SEND_MONEY_COMMISSION_RECEIVED.invoke(respond.savedRequestData.callID, null);
				showAlert(Lang.textError, respond.errorMsg);
				return;
			}
			S_SEND_MONEY_COMMISSION_RECEIVED.invoke(respond.savedRequestData.callID, respond.data);
		}
		
		/**
		 * GET Withdrawal Commission
		 * @param    amount
		 * @param    currency
		 * @param    type
		 * @param    callID
		 */
		static public function callGetDepositCommission(amount:Number, currency:String, type:String = "DINPAY" /* PPCARD*/, callID:String = "", id:String = null):void {
			if (!NetworkManager.isConnected) {
				showAlert(Lang.textError, Lang.noInternetConnection);
				return;
			}
			if (type == "CC")
				PayServer.call_getMoneyDepositCommissionLinked(onDepositCommissionRespond, amount, currency, id, callID);
			else
				PayServer.call_getMoneyDepositCommission(onDepositCommissionRespond, amount, currency, type, callID);
		}
		
		static private function onDepositCommissionRespond(respond:PayRespond):void {
			if (respond.hasAuthorizationError) {
				S_DEPOSITE_COMMISSION_RECEIVED_ERROR.invoke(respond.savedRequestData.callID);
				validateAuthorization(respond);
				return;
			}
			// trial reached
			if (respond.hasTrialVersionError) {
				S_DEPOSITE_COMMISSION_RECEIVED_ERROR.invoke(respond.savedRequestData.callID);
				savedData = respond.savedRequestData;
				_trialReached = true;
				S_TRIAL_REACHED.invoke();
				return;
			}
			if (respond.error) {
				S_DEPOSITE_COMMISSION_RECEIVED_ERROR.invoke(respond.savedRequestData.callID, respond.errorMsg);
				showAlert(Lang.textWarning, respond.errorMsg);
				return;
			}
			S_DEPOSITE_COMMISSION_RECEIVED.invoke(respond.savedRequestData.callID, respond.data);
		}
		
		/**
		 * GET Withdrawal Commission
		 * @param    amount
		 * @param    currency
		 * @param    type
		 * @param    callID
		 */
		static public function callGetWithdrawalCommission(amount:Number, currency:String, type:String = "WIRE" /* PPCARD*/, swift:String="", callID:String = "", debitCurrrency:String = null):void {
			if (!NetworkManager.isConnected) {
				showAlert(Lang.textError, Lang.noInternetConnection);
				return;
			}
			PayServer.call_getMoneyWithdrawalCommission(onWithdrawalCommissionRespond, amount, currency, type, swift, callID, debitCurrrency);
		}
		
		static private function onWithdrawalCommissionRespond(respond:PayRespond):void {
			
			S_WITHDRAWAL_COMMISSION_RESPOND.invoke(respond);
			
			if (respond.hasAuthorizationError) {
				S_WITHDRAWAL_COMMISSION_RECEIVED_ERROR.invoke(respond.savedRequestData.callID);
				validateAuthorization(respond);
				return;
			}
			// trial reached
			if (respond.hasTrialVersionError) {
				S_WITHDRAWAL_COMMISSION_RECEIVED_ERROR.invoke(respond.savedRequestData.callID);
				savedData = respond.savedRequestData;
				_trialReached = true;
				S_TRIAL_REACHED.invoke();
				return;
			}
			if (respond.error) {
				S_WITHDRAWAL_COMMISSION_RECEIVED_ERROR.invoke(respond.savedRequestData.callID);
				showAlert(Lang.textWarning, respond.errorMsg);
				return;
			}
			S_WITHDRAWAL_COMMISSION_RECEIVED.invoke(respond.savedRequestData.callID, respond.data);
		}
		
		/**
		 * CALL AGAIN method calls same method using saved respond
		 * @param    respondData
		 */
		static public function callAgain(respondData:Object):void {
			if (respondData == null)
				return;
			var apiMethod:String = (respondData.data != null && respondData.data.method != null) ? respondData.data.method : "";
			switch (apiMethod) {
				case "money/transfer":
					S_INTERNAL_TRANSFER_CALL.invoke();
					break;
				default:
					break;
			}
			S_CALL_AGAIN.invoke(respondData);
			PayCardsManager.onCallAgain(respondData);
			PayServer.callAgain(respondData);
		}
		
		/**
		 * CALL Internal Transfer
		 * @param    data
		 */
		static public function callInternalTransfer(data:Object,_callID:String = ""):void {
			if (!NetworkManager.isConnected) {
				showAlert(Lang.textError, Lang.noInternetConnection);
				return;
			}
			_internalTransferBusy = true;
			S_INTERNAL_TRANSFER_CALL.invoke();
			PayServer.call_internalTransfer(onMoneyTransfer, data, _callID);
		}
		
		static private function onMoneyTransfer(respond:PayRespond):void {
			_internalTransferBusy = false;			
			if (respond.hasAuthorizationError) {
				validateAuthorization(respond);
				return;
			}
			// trial reached
			if (respond.hasTrialVersionError) {
				savedData = respond.savedRequestData;
				_trialReached = true;
				S_TRIAL_REACHED.invoke();
				return;
			}
			if (respond.error) {
				// check for PWP
				if (respond.errorCode == 3408) { // 3408 PWP operation amount limit reached	see PWP mode
					savedData = respond.savedRequestData;
					//PayManager.needAuthorizationInvoke();
				} else if (respond.errorCode == 3409) { // 3409 PWP daily limit reached
					savedData = respond.savedRequestData;
				}
				S_MONEY_TRANSFERED_ERROR.invoke(respond); 
				return;
			} else {
				// Successfull exchange 
				var respondedData:Object = respond.data;
				var str:String = Lang.TEXT_MONEY_TRANSFERED;
				if (respondedData.status == "COMPLETED"){
					str = "";
					str = LangManager.replace(Lang.regExtValue, Lang.ALERT_EXCHANGE_SUCCESS, String(respondedData.debit_amount));
					str = LangManager.replace(Lang.regExtValue, str, String(respondedData.debit_currency));
					str = LangManager.replace(Lang.regExtValue, str, String(respondedData.credit_amount));
					str = LangManager.replace(Lang.regExtValue, str, String(respondedData.credit_currency));						
					showAlert(Lang.information, str);							
				}else if(respondedData.status == "PENDING"){
					str = "";
					str = LangManager.replace(Lang.regExtValue, Lang.ALERT_EXCHANGE_PENDING, String(respondedData.debit_amount));
					str = LangManager.replace(Lang.regExtValue, str, String(respondedData.debit_currency));
				}
				showAlert(Lang.information, str);
			}
			callGetAccountInfo();
			S_MONEY_TRANSFERED.invoke();
		}
		
		static private var configSetted:Boolean = false;
		
		private static var trialRespondCallback:Function;
		
		/**
		 * Call Remove TRIAL
		 * @param    filledData
		 */
		static public function submitTrialData(callback:Function, make_transfers_number:String = "", make_transfers_amount:String = "", make_payments_number:String = "", make_payments_amount:String = "", receive_payments_number:String = "", receive_payments_amount:String = "", form_html:String = ""):void {
			if (!NetworkManager.isConnected) {
				callback(null); // HZ mozet i ne tut
				showAlert(Lang.textError, Lang.noInternetConnection);
				return;
			}
			trialRespondCallback = callback;
			// todo check internet connection
			var answers:Object = {};
			if (!UI.isEmpty(make_transfers_number))
				answers['make_transfers_number'] = make_transfers_number;
			if (!UI.isEmpty(make_transfers_amount))
				answers['make_transfers_amount'] = make_transfers_amount;
			if (!UI.isEmpty(make_payments_number))
				answers['make_payments_number'] = make_payments_number;
			if (!UI.isEmpty(make_payments_amount))
				answers['make_payments_amount'] = make_payments_amount;
			if (!UI.isEmpty(receive_payments_number))
				answers['receive_payments_number'] = receive_payments_number;
			if (!UI.isEmpty(receive_payments_amount))
				answers['receive_payments_amount'] = receive_payments_amount;
			if (!UI.isEmpty(form_html))
				answers['form_html'] = replaceSymbols(form_html, "€", "EUR");
			PayServer.call_removeTrial(onTrialRemoveRespond, answers);
		}
		
		static private function replaceSymbols(src:String, from:String, to:String):String {
			if (src != null)
				src = src.split(from).join(to);
			return src;
		}
		
		static private function onTrialRemoveRespond(respond:PayRespond):void {
			if (trialRespondCallback != null) {
				trialRespondCallback(respond);
				trialRespondCallback = null;
			}
			if (respond.hasAuthorizationError) {
				validateAuthorization(respond);
				return;
			}
			if (respond.hasTrialVersionError) {
				savedData = respond.savedRequestData;
				_trialReached = true;
				S_TRIAL_REACHED.invoke();
				return;
			}
			if (respond.error) {
				showAlert(Lang.textError, respond.errorMsg);
				return;
			}
			if (respond.data == true) {
				_trialReached = false;
				S_TRIAL_RESETED.invoke();
				if (savedData != null) {
					callAgain(savedData);
					savedData = null;
				}
			}
		}
		
	    static public function callMerchTransfer(data:Object, callID:String = "", callback:Function = null):void {
			if (callback == null)
				callback = onMerchTransferRespond;
	        PayServer.call_putMoneyMerchant(callback, data, callID); 
		}
		
		static private function onMerchTransferRespond(respond:PayRespond):void {
			S_MERCH_TRANSFER_RESPOND.invoke(respond);
			if (respond.hasAuthorizationError) {
	            validateAuthorization(respond);
	            return;
	        }
	        if (respond.hasTrialVersionError) {
	            savedData = respond.savedRequestData;
	            _trialReached = true;
	            S_TRIAL_REACHED.invoke();
	            return;
	        }
	        if (respond.error) {
	            showAlert(Lang.textError, respond.errorMsg);
	            return;
	        }
		}
		
		static public function callInternalTransferFromGiftScreen(data:Object, callID:String = "", callback:Function = null):void {
			if (callback == null)
				callback = onInternalTransferRespond;
			PayServer.call_internalTransfer(callback, data, callID);
		}
		
		static private function onInternalTransferRespond(respond:PayRespond):void {
			_externalTransferBusy = false;
			S_SELF_TRANSFER_RESPOND.invoke(respond);
			if (!respond.error){
				callGetAccountInfo();
			}
		}
		
	    static public function callInvoiceTransfer(data:Object, callID:String = "", callback:Function = null):void {
			if (callback == null)
				callback = onInvoceTransferRespond;
	        PayServer.call_putMoneySendAdvanced(callback, data, callID);
	    }
		
		static private function onInvoceTransferRespond(respond:PayRespond):void {
	        _externalTransferBusy = false;
	        S_INVOICE_TRANSFER_RESPOND.invoke(respond);
			if (!respond.error){
				callGetAccountInfo();
			}
	    }
		
		/**
		 * GET Cards
		 * @param    _callID
		 */
		static public function callGetCards(_callID:String = "", _withExtra:Boolean = false):void {
			if (!NetworkManager.isConnected) {
				showAlert(Lang.textError, Lang.noInternetConnection);
				return;
			}
			PayServer.call_getCards(onCardsGetted, _withExtra, _callID);
		}
		
		
		static private function onCardsGetted(respond:PayRespond):void {
			S_DUKASCOPY_CARDS_RESPOND.invoke(respond);
			if (respond.hasAuthorizationError) {
				S_PPCARDS_RECEIVE.invoke(respond.savedRequestData.callID, null);
				validateAuthorization(respond);
				return;
			}
			if (respond.errorCode == 3801) {
				// you have 0 prepaid cards
				S_PPCARDS_RECEIVE.invoke(respond.savedRequestData.callID, null);
				return;
			}
			// trial reached
			if (respond.hasTrialVersionError) {
				savedData = respond.savedRequestData;
				_trialReached = true;
				S_TRIAL_REACHED.invoke();
				return;
			}
			if (respond.error) {
				PayManager.cachedCardsData = [];
				S_PPCARDS_RECEIVE.invoke(respond.savedRequestData.callID, null);
				return;
			}
			PayManager.cachedCardsData = respond.data;
			S_PPCARDS_RECEIVE.invoke(respond.savedRequestData.callID, respond.data);
		}
		
		/**
		 * GET Cards
		 * @param    _callID
		 */
		static public function callGetMoneyCards(_callID:String = ""):void {
			if (!NetworkManager.isConnected) {
				showAlert(Lang.textError, Lang.noInternetConnection);
				return;
			}
			PayServer.call_getMoneyCards(onMoneyCardsGetted, _callID);
		}
		
		static private function onMoneyCardsGetted(respond:PayRespond):void {
			S_DUKASCOPY_LINKED_CARDS_RESPOND.invoke(respond);
			if (respond.hasAuthorizationError) {
				S_MONEY_CARDS_RECEIVE.invoke(respond.savedRequestData.callID, null);
				validateAuthorization(respond);
				return;
			}
			if (respond.errorCode == 3801) {
				// you have 0 prepaid cards
				S_MONEY_CARDS_RECEIVE.invoke(respond.savedRequestData.callID, null);
				return;
			}
			// trial reached
			if (respond.hasTrialVersionError) {
				savedData = respond.savedRequestData;
				_trialReached = true;
				S_TRIAL_REACHED.invoke();
				return;
			}
			if (respond.error) {
				S_MONEY_CARDS_RECEIVE.invoke(respond.savedRequestData.callID, null);
				return;
			}
			cachedCardsDataMyCard = respond.data;
			S_MONEY_CARDS_RECEIVE.invoke(respond.savedRequestData.callID, respond.data);
		}
		
		/**
		 * POST Account Settings
		 * @param _callID
		 * @param pwp_enabled
		 * @param pwp_limit_amount
		 * @param pwp_limit_daily
		 */
		static public function callPostAccountSettings(_callID:String, pwp_enabled:int = -1 , pwp_limit_amount:int = -1,pwp_limit_daily:int = -1):void {
			if (!NetworkManager.isConnected) {
				showAlert(Lang.textError, Lang.noInternetConnection);
				return;
			}
			PayServer.call_postAccountSettings(onPostAccountSettings, pwp_enabled, pwp_limit_amount, pwp_limit_daily, _callID);
		}

			
		static private function onPostAccountSettings(respond:PayRespond):void {
			S_ACCOUNT_SETTINGS_CHANGE_RESPOND.invoke(respond);
			if (respond.hasAuthorizationError) {
				S_ACCOUNT_SETTINGS_POST.invoke(null);
				validateAuthorization(respond);
				return;
			}
			if (respond.error) {
				S_ACCOUNT_SETTINGS_POST.invoke(respond.error);
			}else{
				S_ACCOUNT_SETTINGS_POST.invoke(respond.data);
				//sohranjaem tut paralelno skrinu
				savePWPData(respond.data);
			}
		}
		
		// vibral u Leschenko iz skrina, inache setingi ne sohranjajutsa
		private static function savePWPData(data:*):void{
			if(data is Boolean){
			}else{
				if (data != null){
					if(PayManager.accountInfo!=null){
						PayManager.accountInfo.updateSettings(data);
					}					
				}
			}
		}
		
		/**
		 * CALL GET Card Commission
		 */
		static public function callGetCardCommission(type:String, currency:String, debitCurrency:String = null, cardType:String = null, delivery:String = null, callID:String = null):void {
			if (!NetworkManager.isConnected) {
				showAlert(Lang.textError, Lang.noInternetConnection);
				return;
			}
			if (currency == null || currency == "" || type == null || type == "") {
				return;
			}
			PayServer.call_getCardCommission(onCardCommissionGetted, type, currency, debitCurrency, cardType, delivery, callID);
		}
		
		static private function onCardCommissionGetted(respond:PayRespond):void {
			if (respond.hasAuthorizationError) {
				validateAuthorization(respond);
				return;
			}
			// trial reached
			if (respond.hasTrialVersionError) {
				savedData = respond.savedRequestData;
				_trialReached = true;
				S_TRIAL_REACHED.invoke();
				return;
			}
			if (respond.error) {
				showAlert(Lang.textError, respond.errorMsg);
				S_PPCARD_COMMISSION_RECEIVE.invoke(null, respond.savedRequestData.callID);
				return;
			}
			S_PPCARD_COMMISSION_RECEIVE.invoke(respond.data, respond.savedRequestData.callID);
		}
		
		/**
		 * CALL Issue New Card
		 */
		static public function callIssueNewCard(_from:Number, _type:String, _currency:String, _cardType:String, _delivery:String, _callID:String = "", deliveryAddress:CardDeliveryAddress = null):void {
			if (!NetworkManager.isConnected) {
				showAlert(Lang.textError, Lang.noInternetConnection);
				return;
			}
			
			if (deliveryAddress != null)
			{
				var currentName:String;
				if (PayManager.accountInfo != null)
				{
					if (accountInfo.fullname_card != null)
					{
						currentName = accountInfo.fullname_card;
					}
					else
					{
						currentName = accountInfo.firstName + " " + accountInfo.lastName;
					}
				}
				if (deliveryAddress.name != null && deliveryAddress.name != currentName)
				{
					deliveryAddress.nameChanged = true;
				}
			}
			
			PayServer.call_putAccountCards(onIssueNewCard, _from, _type, _currency, _cardType, _delivery, _callID, deliveryAddress);
		}
		
		static private function onIssueNewCard(respond:PayRespond):void {
			if (respond.hasAuthorizationError) {
				validateAuthorization(respond);
				return;
			}
			if (respond.hasTrialVersionError) {
				savedData = respond.savedRequestData;
				_trialReached = true;
				S_TRIAL_REACHED.invoke();
				return;
			}
			if (respond.error) {
				var errorText:String = respond.errorMsg;
				if (respond.errorCode == 4604)
				{
					errorText = Lang.cardAlreadyOrdered;
				}
				showAlert(Lang.textError, errorText);
				S_PPCARD_ISSUE_RECEIVE.invoke(respond.savedRequestData.callID, null);
				return;
			}
			S_PPCARD_ISSUE_RECEIVE.invoke(respond.savedRequestData.callID, respond.data);
		}
		
		/**
		 * CALL UPDATE PROFILE
		 */
		static public function callAccountUpdate(userData:Object, callID:String = ""):void {
			if (!NetworkManager.isConnected) {
				showAlert(Lang.textError, Lang.noInternetConnection);
				return;
			}
			
			PayServer.call_accountUpdate(onAccountUpdateResponse, userData, callID);
		}
		
		static private function onAccountUpdateResponse(respond:PayRespond):void {
			if (respond.hasAuthorizationError) {
				validateAuthorization(respond);
				return;
			}
			// trial reached
			if (respond.hasTrialVersionError) {
				savedData = respond.savedRequestData;
				_trialReached = true;
				S_TRIAL_REACHED.invoke();
				return;
			}
			if (respond.error) {
				S_ACCOUNT_UPDATE_ERROR.invoke(respond.errorMsg, respond.savedRequestData.callID);
				return;
			}
			S_ACCOUNT_UPDATE_RESPOND.invoke(respond, respond.savedRequestData.callID);
		}
		
		/**
		 * CALL LIMITS INCREASE
		 */
		static public function callLimitsIncrease(limitsRequest:Object, callID:String = ""):void {
			if (!NetworkManager.isConnected) {
				showAlert(Lang.textError, Lang.noInternetConnection);
				return;
			}
			
			PayServer.call_limitsIncrease(onLimitsIncreaseResponse, limitsRequest, callID);
		}
		
		static private function onLimitsIncreaseResponse(respond:PayRespond):void {
			if (respond.hasAuthorizationError) {
				validateAuthorization(respond);
				return;
			}
			// trial reached
			if (respond.hasTrialVersionError) {
				savedData = respond.savedRequestData;
				_trialReached = true;
				S_TRIAL_REACHED.invoke();
				return;
			}
			if (respond.error) {
				S_LIMITS_INCREASE_ERROR.invoke(respond.errorMsg, respond.savedRequestData.callID);
				return;
			}
			S_LIMITS_INCREASE_RESPOND.invoke(respond, respond.savedRequestData.callID);
		}
		
		// LOAD INVESTMENT COMMISSION 
		static public function callGetInvestmentRate(data:Object, _callID:String = "", callback:Function = null):void {
			if (callback != null) {
				PayServer.call_getInvestmentRate(function(respond:PayRespond):void {
					callback(respond);
				}, data, _callID);
				return;
			}
			PayServer.call_getInvestmentRate(onGetInvestmentRate, data, _callID);
		}
		
		static private function onGetInvestmentRate(respond:PayRespond):void {
			if (S_INVESTMENTS_RATE_RESPOND == null) {
				init();
			}
			
			if (respond.hasAuthorizationError) {
				savedData = respond.savedRequestData;
				validateAuthorization(respond);
				return;
			}
			
			// trial reached
			if (respond.hasTrialVersionError) {
				savedData = respond.savedRequestData;
				_trialReached = true;
				S_TRIAL_REACHED.invoke();
				return;
			}
			
			if (respond.error) {
				showAlert(Lang.textError, respond.errorMsg);
			//	return;
			}
			
			S_INVESTMENTS_RATE_RESPOND.invoke(respond);		
		}
		
		private static var timeKYCStatusWasAsked:Number = 0;
		
		static private function onPendingAlert(res:int):void { }
		
		static public function showAlert(title:String, message:String, callback:Function = null, btn1:String = null, btn2:String = null, btn3:String = null, textAlign:String = TextFormatAlign.CENTER,htmlText:Boolean = false):void {
			var buttonOkText:String = btn1;
			if (buttonOkText == null)
				buttonOkText = Lang.textOk;
			if (MobileGui.centerScreen.currentScreenClass == OrderCardScreen)
				DialogManager.alert(title, message, callback, buttonOkText, btn2, btn3, textAlign,htmlText);
		}
		
		
		// When switching between api 
		static public function resetAccountInfo():void {
			_accountInfo = null;
			systemOptions = null;
			PayManager.cachedCardsData = null;
			PayManager.cachedCardsDataMyCard = null;
			
			_isWaitingForPass = false;
			_isAccountBlocked = false;
			_isInitialized = false;
			_trialReached = false;
			timeKYCStatusWasAsked = 0;
			//accountExist = -1;
			cachedCardsData = null;
			cachedCardsDataMyCard = null;
			respondThatTriggeredAuthorization = null;
		}
		
		// When switching between api 
		static public function resetAccountInfoTEST():void {
			_accountInfo = null;
		}
		
		// TODO on logout call reset method to clean up all settings and unneceserry data
		static public function reset():void {
			Auth.setItem(key_session_id, "");
			PayConfig.PAY_SESSION_ID = "";
			
			_accountInfo = null;
			_isWaitingForPass = false;
			_isAccountBlocked = false;
			_isInitialized = false;
			_trialReached = false;
			timeKYCStatusWasAsked = 0;
			//accountExist = -1;
			cachedCardsData = null;
			cachedCardsDataMyCard = null;
			respondThatTriggeredAuthorization = null;
			S_RESET.invoke();
		}
		
		
		static public function get accountInfo():AccountInfoVO { return _accountInfo; }			
		static public function set accountInfo(value:AccountInfoVO):void {
			_accountInfo = value;
		}
		static public function get isInitialized():Boolean { return _isInitialized; }

		static public function get systemOptionsReady():Boolean { return systemOptions != null; }
		static public function get hasPendingTransfer():Boolean { return _hasPendingTransfer; }
		static public function get creatingWalletBussy():Boolean { return _creatingWalletBussy; }
		static public function get internalTransferBusy():Boolean { return _internalTransferBusy; }
		static public function get externalTransferBusy():Boolean { return _externalTransferBusy; }
		static public function set creatingWalletBussy(value:Boolean):void { _creatingWalletBussy = value; }
		static public function set externalTransferBusy(value:Boolean):void { _externalTransferBusy = value; }
		static public function get hasSession():Boolean {
			return PayConfig.PAY_SESSION_ID != null && PayConfig.PAY_SESSION_ID.length > 0;
		}
		
		static public function get walletsCurrencies():Array {
			var result:Array = [];
			if (_accountInfo != null && _accountInfo.accounts != null) {
				for (var i:int = 0; i < _accountInfo.accounts.length; i++) {
					result.push(_accountInfo.accounts[i].CURRENCY);
				}
			}
			return result;
		}
		
		static public function get isWaitingForPass():Boolean { return _isWaitingForPass; }
		static public function set isWaitingForPass(value:Boolean):void {
			if (value == _isWaitingForPass) return;
			_isWaitingForPass = value;
			S_PASS_CHECKING_STATE_CHANGED.invoke();
		}
	
		static public function set hasPendingTransfer(value:Boolean):void {
			if (value == _hasPendingTransfer)
				return;
			_hasPendingTransfer = value;
			S_PENDING_CHANGED.invoke();
		}		
		static public function get isInsidePaymentsScreenNow():Boolean {	return _isInsidePaymentsScreenNow; }	
		static public function set isInsidePaymentsScreenNow(value:Boolean):void {
			if (value == _isInsidePaymentsScreenNow)
				return;
			_isInsidePaymentsScreenNow = value;
			
			if (!_isInsidePaymentsScreenNow) {
				if (S_ON_EXIT_PAYMENTS != null) 
					S_ON_EXIT_PAYMENTS.invoke();
			}
			if (_isInsidePaymentsScreenNow == true)
				_wasFirstResponse = false;
		}
		static public function set trialReached(value:Boolean):void { _trialReached  = value; }
		static public function get trialReached():Boolean { return _trialReached; }
		
		
		public static function clearSavedData():void {
			savedData = null;
		}
		
		public static function onDismissPasswordEnter(respopnd:PayRespond):void {
			S_ENTER_PASSWORD_DISMISS.invoke(respopnd);
		}
		
		static public function getCoins():Array {
			if (accountInfo == null) {
				return null;
			}
			return accountInfo.coins;
		}
		
		static public function updateaccountInfo(data:Object):void {
			if (data == null || "account" in data == false || data.account == null) {
				accountInfo = null;
				return;
			}
			accountInfo ||= new AccountInfoVO();
			accountInfo.update(data.account);
			if ("coins" in data == true)
				_accountInfo.setCoins(data.coins);
		}
		
		static public function getDeclareBlockchainAddressLink(currency:String):void {
			if (!NetworkManager.isConnected) {
				showAlert(Lang.textError, Lang.noInternetConnection);
				return;
			}
			PayServer.call_getDeclareEthAddressLink(onDeclareBlockchainAddressLinkGetted, currency);
		}
		
		static public function getDCOWallet(currency:String = "DCO"):String {
			if (accountInfo != null) {
				if (currency == null || currency.toLowerCase() == "dco" || currency.toLowerCase() == "eth" || currency.toLowerCase() == "ust")
					return accountInfo.ethAddress;
				if (currency.toLowerCase() == "btc")
					return accountInfo.btcAddress;
			}
			return null;
		}
		
		static private function onDeclareBlockchainAddressLinkGetted(respond:PayRespond):void {
			if (respond.hasAuthorizationError) {
				savedData = respond.savedRequestData;
				validateAuthorization(respond);
				return;
			}
			if (respond.hasTrialVersionError) {
				savedData = respond.savedRequestData;
				_trialReached = true;
				S_TRIAL_REACHED.invoke();
				return;
			}
			if (respond.error) {
				
				S_DECLARE_BLOCKCHAIN_ADDRESS_ERROR.invoke(respond.savedRequestData.callID, respond.errorMsg);
				return;
			}
			S_DECLARE_BLOCKCHAIN_ADDRESS_SUCCESS.invoke(respond.savedRequestData.callID, respond.data);
		}
	}
}