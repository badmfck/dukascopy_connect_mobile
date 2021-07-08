package com.dukascopy.connect.sys.payments {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.CheckDuplicateTransfer;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.screens.ChatScreen;
	import com.dukascopy.connect.screens.base.ScreenManager;
	import com.dukascopy.connect.screens.payments.PaymentsRTOLimitsScreen;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.payments.advancedPayments.vo.PayTaskVO;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.sys.questionsManager.QuestionsManager;
	import com.dukascopy.connect.type.InvoiceStatus;
	import com.dukascopy.connect.vo.ChatMessageVO;
	import com.dukascopy.connect.vo.ChatVO;
	import com.dukascopy.langs.Lang;
	import com.telefision.sys.signals.Signal;
	import flash.text.TextFormatAlign;

	/**
	 * Manager Class that handles invoice payments operations similar to PayManager
	 * @author ...
	 */
	
	public class InvoiceManager {
		
		static public const DEPENDENCY_BALANCE_CHECK:String = "dependencyBalanceCheck";
		static public const DEPENDENCY_SENDING_INVOICE:String = "dependencyInvoice";
		
		public static var S_START_PROCESS_INVOICE:Signal = new Signal("InvoiceManager.S_START_PROCESS_INVOICE");
		public static var S_STOP_PROCESS_INVOICE:Signal = new Signal("InvoiceManager.S_STOP_PROCESS_INVOICE");
		
		public static var S_START_PREPROCESS_INVOICE:Signal = new Signal("InvoiceManager.S_START_PREPROCESS_INVOICE");
		public static var S_STOP_PREPROCESS_INVOICE:Signal = new Signal("InvoiceManager.S_STOP_PREPROCESS_INVOICE");
		
		public static var S_ERROR_PROCESS_INVOICE:Signal = new Signal("InvoiceManager.S_ERROR_PROCESS_INVOICE");
		public static var S_ACCOUNT_READY:Signal = new Signal("InvoiceManager.S_ACCOUNT_READY");
		public static var S_CALL_GET_COMMISSION:Signal = new Signal("InvoiceManager.S_CALL_GET_COMMISSION");
		public static var S_RECEIVED_COMMISSION:Signal = new Signal("InvoiceManager.S_RECEIVED_COMMISSION");
		public static var S_RECEIVE_COMMISSION_ERROR:Signal = new Signal("InvoiceManager.S_RECEIVE_COMMISSION_ERROR");
		public static var S_TRANSFER_RESPOND:Signal = new Signal("InvoiceManager.S_TRANSFER_RESPOND");
		public static var S_START_TRANSFER:Signal = new Signal("InvoiceManager.S_START_TRANSFER");
		public static var S_ERROR_MESSAGE:Signal = new Signal("InvoiceManager.S_ERROR_MESSAGE");
		
		public static var S_PAY_TASK_COMPLETED:Signal = new Signal("InvoiceManager.S_PAY_TASK_COMPLETED");		
		public static var S_TRANSACTION_STATE_CHANGED:Signal = new Signal("InvoiceManager.s_TRANSACTION_STATE_CHANGED");
		private static var _isAuthorized:Boolean= false;
		private static var _isProcessingInvoice:Boolean = false;
		private static var _isMakingTransaction:Boolean = false; // flag for showing preloader 
		
		private static var _lastTransactionCallID:String = "";
			
		private static var _currentInvoiceData:PayTaskVO;		
		private static var failedInvoiceData:Object = null; // save not completed invoice data on transaction error
		private static var failedComissionData:Object = null; // save not completed invoice data on transaction error
		public static var inTransactionTasks:Object = {}; 	// Store in transaction invoices data 
		private static var preProcesInvoiceData:PayTaskVO;
			
		private static var _isPreProcessing:Boolean = false;
		
		public function InvoiceManager() { }
		
		
		
		//===========================================================================================================
		// STORED INVOICES DATA THAT ARE IN TRANSACTION 
		//===========================================================================================================	
		public static function getCurrentInvoiceData():PayTaskVO { return _currentInvoiceData; }
		
		public static function addTaskToActiveTransactions(key:String, invoiceData:PayTaskVO):void {
			inTransactionTasks[key] = invoiceData;
		}
		public static function removeTaskFromTransactions(key:String):void {
			inTransactionTasks[key] = null;
		}		
		
		
		//===========================================================================================================
		// PRE PROCESS INVOICE 
		//===========================================================================================================	
		
		public static function preProcessInvoce(dta:PayTaskVO):void {
			_isPreProcessing = true;
			S_START_PREPROCESS_INVOICE.invoke();
			preProcesInvoiceData = dta;
				onAPICheckComplete();
		}
		
		private static function onAPICheckComplete():void{
			if (PayAPIManager.hasSwissAccount == true){		
				onAccountExist(); // has account		
			}else{
				onAccountNotExists();// no account
			}
		}
		
		private static function onAccountExist():void{
			_isPreProcessing = false;
			// # INVOICE OPERATION 
			if(preProcesInvoiceData != null){
				processInvoice(preProcesInvoiceData);
				preProcesInvoiceData = null;
			}				
		}
		
		private static function onAccountNotExists():void {		
			// # INVOICE OPERATION
			if (preProcesInvoiceData != null){
				if (preProcesInvoiceData.showNoAccountAlert == true)
				{
					DialogManager.alert(Lang.information, Lang.featureNoPaments, createPaymentsAccount, Lang.registrate, Lang.textCancel);
				}
				else if (preProcesInvoiceData.allowCardPayment)
				{
					processInvoice(preProcesInvoiceData);
					return;
				}
				
				preProcesInvoiceData = null;	
			}
			S_ERROR_PROCESS_INVOICE.invoke();
		}
		
		static private function createPaymentsAccount(val:int):void {
			S_ERROR_PROCESS_INVOICE.invoke();
			stopProcessInvoice();
			if (val != 1) {
				return;
			}
			MobileGui.showRoadMap();
		}
		
		//===========================================================================================================
		// AUTH MANAGER 
		//===========================================================================================================	
		private static function initPayAuthManagerEvents():void {
			PayAuthManager.init();
			PayAuthManager.S_ON_BACK.add(onAuthBack);
			
			if (PayManager.S_CANCEL_AUTH != null)
			{
				PayManager.S_CANCEL_AUTH.add(onAuthBack);
			}
			
		//	PayAuthManager.S_ON_AUTH_SUCCESS.add(onAuthPassSuccess);
			PayAuthManager.S_ON_PASS_CHANGE_SUCCESS.add(onAuthPassChangeSuccess);
			PayAuthManager.S_ON_DISMISS_PASS.add(onPassDismiss);
			
			PayAPIManager.S_LOGIN_SUCCESS.add(onLoginSuccess);
		}
		
		static private function onLoginSuccess(someData:Object = null):void 
		{
			//someData ?
			
			onAuthPassSuccess();
		}
		
		private static function removePayAuthManagerEvents():void {
			// Don't stop to listen signal if we have some task in queue
			// for example invoice money sended, but check balance operation is not completed 
			
			if (PayManager.S_CANCEL_AUTH != null)
			{
				PayManager.S_CANCEL_AUTH.remove(onAuthBack);
			}
			
			if (! PayAuthManager.hasDependencies()){ 
				PayAuthManager.S_ON_BACK.remove(onAuthBack);
			//	PayAuthManager.S_ON_AUTH_SUCCESS.remove(onAuthPassSuccess);
				PayAuthManager.S_ON_PASS_CHANGE_SUCCESS.remove(onAuthPassChangeSuccess);
				PayAuthManager.S_ON_DISMISS_PASS.remove(onPassDismiss);
			}
			
			PayAPIManager.S_LOGIN_SUCCESS.remove(onLoginSuccess);
		}
	

		
		
		
		//===========================================================================================================
		// START PROCESSING INVOICE 
		//===========================================================================================================	
		public static function processInvoice(invoiceData:PayTaskVO):void {			
			_isProcessingInvoice = true;
			PayAuthManager.activate(DEPENDENCY_SENDING_INVOICE);
			echo("IncoiceManager", "processInvoice");
			_currentInvoiceData = invoiceData;			
			S_START_PROCESS_INVOICE.invoke();			
			initPayManager();	
		}
		
		//===========================================================================================================
		// STOP PROCESSING INVOICE 
		//===========================================================================================================
		public static function stopProcessInvoice():void{
			_isProcessingInvoice = false;		
			PayAuthManager.deactivate(DEPENDENCY_SENDING_INVOICE);
			removePayAuthManagerEvents();
			echo("IncoiceManager", "stopProcessInvoice");
			S_STOP_PROCESS_INVOICE.invoke();
			_lastTransactionCallID = ""; // just mark 
			_isMakingTransaction = false; // clear flag 	
			PayAPIManager.S_SWISS_API_CHECKED.remove(onAPICheckComplete);
		}
		
		//===========================================================================================================
		// INIT PAY MANAGER  
		//===========================================================================================================
		public static function initPayManager():void {
			// Init PayManager 
			if (PayManager.isInitialized == false) {
				PayManager.init();
			}
			
			// Authorization Screens managment 
			initPayAuthManagerEvents();
				
			// Sys Options
			PayManager.S_SYSTEM_OPTIONS_READY.add(onSystemOptions);
			
			// Acount Info 
			PayManager.S_ACCOUNT_RESPOND.add(onAccountInfoRespond);
			PayManager.S_ACCOUNT.add(onAccountGetted);
			
			// Invoked on call Login and login Respond 
			
			// First of all get server delta time
			
			var paymentsReady:Boolean = PayManager.systemOptions != null && "currencyList" in PayManager.systemOptions == true;
			if (paymentsReady == false) {
				onPaymentsConfig();	// get the config 
				PayManager.callGetSystemOptions(); // currency list , ppcards currency
				PayManager.callGetAccountInfo(); // wallets list phone num
			} else {
				trace("Payments config ready input interface");
				trace("Pay Acount info Data > " + UI.tracedObj(PayManager.accountInfo));
				//if no account info 
				if (PayManager.accountInfo == null){
					PayManager.callGetSystemOptions(); // currency list , ppcards currency
					PayManager.callGetAccountInfo();
				}else{
					trace("Acount info exists call send money ");
					S_ACCOUNT_READY.invoke(); // acount info exists, show select pointers/wallet interface
				}
			}
		}
		
	

		
	
		
		/** Reset Manager */
		public static function reset():void	{
			// Clean up 
		}
		
		//===========================================================================================================
		// 1  SERVER DELTA AND CONFIG LOADED
		//===========================================================================================================
		
		private static function onPaymentsConfig():void {
			if (PayManager.S_SYSTEM_OPTIONS_READY == null)
				PayManager.S_SYSTEM_OPTIONS_READY = new Signal("PayManager.S_SYSTEM_OPTIONS_READY");
			PayManager.S_SYSTEM_OPTIONS_READY.add(onSystemOptions);
		}
		
		//===========================================================================================================
		// 2  OPTIONS LOADED AND CAN GET ACCOUNT INFO 
		//==============================================================================================
		private static function onSystemOptions():void {
			echo("IncoiceManager", "onSystemOptions");
		}
		
		
		//===========================================================================================================
		// 3  ACCOUNT INFO RECEIVED
		//===========================================================================================================
		
		/**
		 * Called on account info respond, no matter error or not 
		*/
		private static function onAccountInfoRespond():void {
			echo("IncoiceManager", "onAccountInfoRespond", PayManager.accountInfo);
		}
		
		/**
		 * Called when we get account info data seted sucessfully 
		*/
		private static function onAccountGetted():void {
			echo("IncoiceManager", "onAccountGetted", PayManager.accountInfo);
			S_ACCOUNT_READY.invoke();
		}
		
		// ENABLE PWP DIALOG CALLBACK 
		public static function onPWPDialog(value:int):void {
			echo("IncoiceManager", "onPWPDialog", value);
			if (value == 1) {
				var callID:String = new Date().time + "_setting";
				PayManager.callPostAccountSettings(callID, 1);
				// A esli etot zapros vozvrawaet SESSION LOCKED WITH PASSWORD??? 
			}
			
			// # IVOICE - check for comission
			 if (_isProcessingInvoice && failedComissionData != null){
				getCommission();
				failedComissionData  = null;
			 }
		}
		
		//===========================================================================================================
		// 4 LOAD COMMISSION
		//===========================================================================================================
		
		// Pass Auth Sucess 
		static private function onAuthPassSuccess():void {
			_isAuthorized = true;
			echo("mpney.IncoiceManager", "onAuthPassSuccess !!!");
			
			// if is pendng transaction > sendInvoice
			if (failedInvoiceData != null && failedInvoiceData.data != null) {
				var callID:String = failedInvoiceData.callID;				
				var failedTask:PayTaskVO =  inTransactionTasks[callID];
				if (failedTask != null){
					// show preloader 
					sendPaymentToPayServer(failedTask, callID);
				}else{
					echo("IncoiceManager", "onAuthPassSuccess", "failedInvoice is null");
				}
			}				
			// if comisiion was failed get it again
			if (failedComissionData != null) {
				failedComissionData = null;
				if (_currentInvoiceData.taskType != PayTaskVO.TASK_TYPE_PAY_GIFT_BY_UID)
				{
					getCommission();
				}
			}
		}
		
		// DISMISS PASS
		static private function onPassDismiss():void {
			if (_currentInvoiceData != null && ( _currentInvoiceData.taskType == PayTaskVO.TASK_TYPE_PAY_GIFT_BY_UID 
													||_currentInvoiceData.taskType == PayTaskVO.TASK_TYPE_PAY_MERCH) )	{
				S_ERROR_PROCESS_INVOICE.invoke();
				return;
			}
			InvoiceManager.stopProcessInvoice();
		}		
		
		// Pass Auth Change Sucess 
		static private function onAuthPassChangeSuccess(...rest):void 	{
			echo("IncoiceManager", "onAuthPassChangeSuccess");			
		}
		
		// Auth Back 
		static private function onAuthBack():void {
			onBack();
		}
		
		
		//===========================================================================================================
		// 4 LOAD COMMISSION
		//===========================================================================================================
		
		private static var _lastCommissionCallID:String = "";
		private static var _lastCommissionObj:Object;
		public static function getCommisiionObject():Object	{	return _lastCommissionObj;	}
		
		private static var _commissionLoaded:Boolean = false;
		static public function get commissionLoaded():Boolean {	return _commissionLoaded; }
		
		static public function get isProcessingInvoice():Boolean 	{return _isProcessingInvoice; }
		static public function set isProcessingInvoice(value:Boolean):void 	{_isProcessingInvoice = value; }
		
		static public function get isMakingTransaction():Boolean {return _isMakingTransaction;}		
		static public function set isMakingTransaction(value:Boolean):void {
			if (_isMakingTransaction == value) return; 
			_isMakingTransaction = value;
			S_TRANSACTION_STATE_CHANGED.invoke();
		}
		
		static public function get isPreProcessing():Boolean {	return _isPreProcessing;	}
		
		private static var _fromAccount:String = "";
		static public function setFromAccount(value:String):void {
			_fromAccount = value;
		}
		
		private static var isWaitingCommission:Boolean = false;
		
		/** 
		 * GET Comission for current invoice 
		 ***/
		public static function getCommission():void {
			// TODO check for interenet connecton  	
			_commissionLoaded = false;
			isWaitingCommission = true;
			_lastCommissionObj = null;
			_lastCommissionCallID = new Date().getTime().toString() + "_comm";
			if(_currentInvoiceData!=null){
				PayManager.S_SEND_MONEY_COMMISSION_RESPOND.add(onSendMoneyCommissionRespond);
				PayManager.callGetSendMoneyCommission(_currentInvoiceData.amount , _currentInvoiceData.currency, _lastCommissionCallID);
			}
			S_CALL_GET_COMMISSION.invoke();
		}
		
		/**
		 * Comission Respondded
		 * @param	respond
		 */
		static private function onSendMoneyCommissionRespond(respond:PayRespond):void {
			if (!respond.error) {// show commisiion data 				
				handleCommissionRespond(respond.savedRequestData.callID, respond.data);
			} else if (respond.hasAuthorizationError) {
					failedComissionData = respond.savedRequestData;
					PayManager.validateAuthorization(respond);
					
			} 
			else if (respond.hasTrialVersionError) {//is trial reached
				
				if(respond.savedRequestData.callID ==_lastCommissionCallID){ // handle most actual call 
					var unfinishedTask:PayTaskVO =  _currentInvoiceData;
					var screenData:Object = {};
					screenData.unfinishedTask = unfinishedTask;
					screenData.backScreen  = MobileGui.centerScreen.currentScreenClass;
					screenData.backScreenData  = MobileGui.centerScreen.currentScreen.data;
					MobileGui.changeMainScreen(PaymentsRTOLimitsScreen, screenData, ScreenManager.DIRECTION_RIGHT_LEFT);
					stopProcessInvoice();
				}
					
			}
			else{
				
				if (respond.errorCode == 3002){ // wrong amount
						if (_lastCommissionCallID == respond.savedRequestData.callID) {
							isWaitingCommission = false;
							_commissionLoaded = false;
							showAlert(Lang.textError, respond.errorMsg, onWrongAmountCloseCallback );
							failedComissionData = null;
							S_RECEIVE_COMMISSION_ERROR.invoke();
						}
					
				}else{
					
					showAlert(Lang.textError, respond.errorMsg, null);
					failedComissionData = null;
					// hide preloader 
				}
			}
		}
		
		private static function onWrongAmountCloseCallback(val:int):void
		{
			stopProcessInvoice();
		}
		
		private static function handleCommissionRespond(callID:String, data:Object):void {
			if (_lastCommissionCallID == callID) {
				isWaitingCommission = false;
				_commissionLoaded = true;
				_lastCommissionObj = {};
				if (data != null) {					
					// poluchili kommisiiju -> rasparsili dannie
					var commissionObj:Array = data[0];
					var commissionAmount:String = (commissionObj != null && commissionObj[0] != null) ? commissionObj[0] : "";
					var commissionCurrency:String = (commissionObj != null && commissionObj[1] != null) ? commissionObj[1] : "";
					var commissionText:String = commissionAmount + " " + commissionCurrency;	
					// setim text komissiji v TaskVO
					_currentInvoiceData.commissionText = commissionText;					
					
					if (data.length > 2 && data[2] != null && "request_clarification" in data[2] && data[2].request_clarification == true)
					{
						_currentInvoiceData.requestClarification = true;
					}
					
					var messageText:String = UI.isEmpty( _currentInvoiceData.messageText) ? "" : renderBlock(Lang.textMessage + ":",  _currentInvoiceData.messageText);
					var phoneInfo:String = _currentInvoiceData.taskType == PayTaskVO.TASK_TYPE_PAY_INVOICE_BY_PHONE? renderBlock(Lang.enterDestinationPhone + ":", _currentInvoiceData.to_phone):"";
					var destinationUser:String = UI.isEmpty(_currentInvoiceData.destinationUserName)?"":renderBlock(Lang.enterDestinationUser + ":" , _currentInvoiceData.destinationUserName);
					var confirmBody:String = renderBlock(Lang.TEXT_DEBIT_WALLET + ":", _fromAccount) +
							phoneInfo +
							destinationUser +
							renderBlock(Lang.textAmount + ":", _currentInvoiceData.amount+"") +
							renderBlock(Lang.textCurrency + ":", _currentInvoiceData.currency) +
							renderBlock(Lang.textCommission + ":", _currentInvoiceData.commissionText) +
							messageText;
					_lastCommissionObj.text = confirmBody; 
					S_RECEIVED_COMMISSION.invoke();
				}
			}
		}
		
		
		private static function renderBlock(param:String, value:String):String {
			var result:String = "";	
			var baseSize:Number = Config.FINGER_SIZE * 0.32;
			var captionSize:Number = Config.FINGER_SIZE * 0.23;
			result = "<font color='#999999' size='" + captionSize + "'><i>" + param + "</i></font><br>" +
					"<b>" + value + "</b><br>" + "<font size='10'></font>";
			return result;
		}
				
		
		
		//===========================================================================================================
		// 4 SEND INVOICE PROCESS
		//===========================================================================================================
	
		
		// SEND ---> $$$ advanced mathod is used now 
		public static function sendPaymentToPayServer(invoiceVO:PayTaskVO, callID:String):void { 			
			if (invoiceVO != null) {	
				S_START_TRANSFER.invoke();
				_lastTransactionCallID = callID;
				isMakingTransaction = true;
				addTaskToActiveTransactions(callID, invoiceVO);
				
				// make merch transaction
				if (invoiceVO.taskType == PayTaskVO.TASK_TYPE_PAY_MERCH){
					PayManager.S_MERCH_TRANSFER_RESPOND.add(onMerchTransferRespond);
					PayManager.callMerchTransfer(invoiceVO.generateRequestObject(), callID);
				}
				else if (invoiceVO.taskType == PayTaskVO.TASK_TYPE_SELF_TRANSFER){
					PayManager.S_SELF_TRANSFER_RESPOND.add(onSelfTransferRespond);
					PayManager.callInternalTransferFromGiftScreen(invoiceVO.generateRequestObject(), callID); 
				}else{
					PayManager.S_INVOICE_TRANSFER_RESPOND.add(onInvoiceTransferRespond);
					PayManager.callInvoiceTransfer(invoiceVO.generateRequestObject(), callID);	
				}
			
			}			
		}
		
		public static function onSelfTransferRespond(respond:PayRespond):void {
			if (respond.savedRequestData.callID == _lastTransactionCallID){
				isMakingTransaction = false;
			}
			echo("money", "onSelfTransferRespond", "1");
			S_TRANSFER_RESPOND.invoke(respond);
			if (!respond.error){
				echo("money", "onSelfTransferRespond", "2");
				markAsAcepted( respond.savedRequestData.callID);				
				failedInvoiceData = null;
			}else{			
				echo("money", "onSelfTransferRespond", "3");
				if (respond.hasAuthorizationError){					
					failedInvoiceData = respond.savedRequestData;
					PayManager.validateAuthorization(respond);
					PayManager.clearSavedData()
				}else if (respond.errorCode == 3408){//3408	PWP operation amount limit reached	see PWP mode
					echo("onSelfTransferRespond", "HANLE PWP ERROR 3408");
					failedInvoiceData = respond.savedRequestData;
					PayManager.needAuthorizationInvoke();
					PayManager.clearSavedData()
				}else if (respond.errorCode == 3409){//3409	PWP daily limit reached
					failedInvoiceData = respond.savedRequestData;
					echo("onSelfTransferRespond", "HANLE PWP ERROR 3409");
					PayManager.needAuthorizationInvoke();
					PayManager.clearSavedData()
				} 
				else if (respond.hasTrialVersionError) {//is trial reached
				
					if(respond.savedRequestData.callID ==_lastTransactionCallID){ // handle most actual call 
						var unfinishedTask:PayTaskVO =  _currentInvoiceData;
						var screenData:Object = {};
						screenData.unfinishedTask = unfinishedTask;
						screenData.backScreen  = ChatScreen;
						screenData.backScreenData  = MobileGui.centerScreen.currentScreen.data;
						MobileGui.changeMainScreen(PaymentsRTOLimitsScreen, screenData, ScreenManager.DIRECTION_RIGHT_LEFT);
						stopProcessInvoice();
					}
				}
				
				else{				
					showAlert(Lang.textError, respond.errorMsg, null);
					failedInvoiceData = respond.savedRequestData;
					if(failedInvoiceData!=null && failedInvoiceData.callID!=null){
						removeTaskFromTransactions(failedInvoiceData.callID); // gift invoice data 
					}
					failedInvoiceData = null;
					// hide preloader 	
				}
			}	
		}
		
		/**
		 * Merch Responded
		 * @param	respond
		 */
		public static function onMerchTransferRespond(respond:PayRespond):void {
			echo("onMerchTransferRespond", "Respond Invoice Merch call id = " + respond.savedRequestData.callID );			
			if (respond.savedRequestData.callID == _lastTransactionCallID){
				isMakingTransaction = false;
			}
			
			S_TRANSFER_RESPOND.invoke(respond);
			if (!respond.error){					
				markAsAcepted( respond.savedRequestData.callID);
				failedInvoiceData = null;
			}else{			
				
				if (respond.hasAuthorizationError){					
					failedInvoiceData = respond.savedRequestData;
					
					PayManager.validateAuthorization(respond);					
					PayManager.clearSavedData()
				}else if (respond.errorCode == 3408){//3408	PWP operation amount limit reached	see PWP mode
					echo("onMerchTransferRespond", "HANLE PWP ERROR 3408");
					failedInvoiceData = respond.savedRequestData;
					
					PayManager.needAuthorizationInvoke();
					PayManager.clearSavedData()
				}else if (respond.errorCode == 3409){//3409	PWP daily limit reached
					failedInvoiceData = respond.savedRequestData;
					
					echo("onMerchTransferRespond", "HANLE PWP ERROR 3409");
					PayManager.needAuthorizationInvoke();
					PayManager.clearSavedData()
				} 
				else if (respond.hasTrialVersionError) {//is trial reached
				
					if(respond.savedRequestData.callID ==_lastTransactionCallID){ // handle most actual call 
						var unfinishedTask:PayTaskVO =  _currentInvoiceData;
						var screenData:Object = {};
						screenData.unfinishedTask = unfinishedTask;
						screenData.backScreen  = ChatScreen;
						screenData.backScreenData  = MobileGui.centerScreen.currentScreen.data;
						MobileGui.changeMainScreen(PaymentsRTOLimitsScreen, screenData, ScreenManager.DIRECTION_RIGHT_LEFT);
						stopProcessInvoice();
					}
			
				}
				
				else{				
					showAlert(Lang.textError, respond.errorMsg, null);
					failedInvoiceData = respond.savedRequestData;
					if(failedInvoiceData!=null && failedInvoiceData.callID!=null){
						removeTaskFromTransactions(failedInvoiceData.callID); // gift invoice data 
					}
					failedInvoiceData = null;
					// hide preloader 	
					
				}
			}	
		}
		
		
		/**
		 * Invoice Responded
		 * @param	respond
		 */
		public static function onInvoiceTransferRespond(respond:PayRespond):void {
			echo("onInvoiceTransferRespond", "Respond Invoice call id = " + respond.savedRequestData.callID );			
			if (respond.savedRequestData.callID == _lastTransactionCallID){
				isMakingTransaction = false;
			}
			
			S_TRANSFER_RESPOND.invoke(respond);	
			if (!respond.error){					
				markAsAcepted( respond.savedRequestData.callID);			
				failedInvoiceData = null;
			}else{			
				 
				if (respond.hasAuthorizationError){					
					failedInvoiceData = respond.savedRequestData;
					PayManager.validateAuthorization(respond);	
					PayManager.clearSavedData();// for not to call again from PyaManager but call here
					if (respond.savedRequestData != null && "data" in respond.savedRequestData && respond.savedRequestData.data != null)
					{
						if ("to" in respond.savedRequestData.data && respond.savedRequestData.data.to != null)
						{
							echo("onInvoiceTransferRespond", "try clear");
							CheckDuplicateTransfer.clear(respond.savedRequestData.data.to);
						}
					}
				}else if (respond.errorCode == 3408){//3408	PWP operation amount limit reached	see PWP mode
					echo("onInvoiceTransferRespond", "HANLE PWP ERROR 3408");
					failedInvoiceData = respond.savedRequestData;
					PayManager.needAuthorizationInvoke();
					PayManager.clearSavedData();// for not to call again from PyaManager but call here
					if (respond.savedRequestData != null && "data" in respond.savedRequestData && respond.savedRequestData.data != null)
					{
						if ("to" in respond.savedRequestData.data && respond.savedRequestData.data.to != null)
						{
							echo("onInvoiceTransferRespond", "try clear");
							CheckDuplicateTransfer.clear(respond.savedRequestData.data.to);
						}
					}
				}else if (respond.errorCode == 3409){//3409	PWP daily limit reached
					failedInvoiceData = respond.savedRequestData;
					echo("onInvoiceTransferRespond", "HANLE PWP ERROR 3409");
					PayManager.needAuthorizationInvoke();
					PayManager.clearSavedData();// for not to call again from PyaManager but call here
					if (respond.savedRequestData != null && "data" in respond.savedRequestData && respond.savedRequestData.data != null)
					{
						if ("to" in respond.savedRequestData.data && respond.savedRequestData.data.to != null)
						{
							echo("onInvoiceTransferRespond", "try clear");
							CheckDuplicateTransfer.clear(respond.savedRequestData.data.to);
						}
					}
				} 
				else if (respond.hasTrialVersionError) {//is trial reached
				
					if(respond.savedRequestData.callID ==_lastTransactionCallID){ // handle most actual call 
						var unfinishedTask:PayTaskVO =  _currentInvoiceData;
						var screenData:Object = {};
						screenData.unfinishedTask = unfinishedTask;
						screenData.backScreen  = ChatScreen;
						screenData.backScreenData  = MobileGui.centerScreen.currentScreen.data;
						MobileGui.changeMainScreen(PaymentsRTOLimitsScreen, screenData, ScreenManager.DIRECTION_RIGHT_LEFT);
						stopProcessInvoice();
					}
			
				}
				
				else{
					S_ERROR_MESSAGE.invoke(respond.errorMsg);
				//	showAlert(Lang.textError, respond.errorMsg, null, Lang.textOk);
					failedInvoiceData = respond.savedRequestData;
					if(failedInvoiceData!=null && failedInvoiceData.callID!=null){
						removeTaskFromTransactions(failedInvoiceData.callID); // gift invoice data 
					}
					failedInvoiceData = null;
					// hide preloader 	
					
				}
			}	
		}
		
		public static function onInvoiceTransactionCompleteDialogClose(val:int):void {
			onBack();
		}
		
		
		
		//===========================================================================================================
		// 5 MARK INVOICE AS COMPLETED 
		//===========================================================================================================
		public static function markAsAcepted(callID:String):void {	
			
			// Pay Task COMPLETED 
			var completedTask:PayTaskVO =  inTransactionTasks[callID];
			echo("money", "markAsAcepted", completedTask);
			if (completedTask != null){	
				echo("markAsAcepted", "Payment Task Is completed:" +callID +" >"+ completedTask.amount + completedTask.currency );
				
				
				// This is how to handle on complete 	
				if (completedTask.taskType == PayTaskVO.TASK_TYPE_PAY_INVOICE_BY_PHONE){
					// Mark InvoiceMessage as paid					
					showAlert(Lang.moneyTransferedTitle, Lang.invoicePaidText, onInvoiceTransactionCompleteDialogClose);
					
				}else if (completedTask.taskType == PayTaskVO.TASK_TYPE_PAY_INVOICE_BY_UID){
					// Mark taskType as paid
					showAlert(Lang.moneyTransferedTitle, Lang.invoicePaidText, onInvoiceTransactionCompleteDialogClose);
					
				}else if (completedTask.taskType == PayTaskVO.TASK_TYPE_PAY_GIFT_BY_UID){
					// Send gift message or notify that gift has been send
					
				}else if (completedTask.taskType == PayTaskVO.TASK_TYPE_PAY_PUZZLE_BY_UID){
					// Send puzzle message or notify that puzzle money has been send
					
				} // end puzzle task
				
				
				
				// Now maybe lets make it inside type check 
				
				// Send message to chat as you se
				var msgVO:ChatMessageVO = completedTask.messageVO;
				if (msgVO != null && msgVO.systemMessageVO != null && msgVO.systemMessageVO.invoiceVO != null) {
					
					msgVO.systemMessageVO.invoiceVO.status = InvoiceStatus.ACCEPTED;
					if (msgVO.systemMessageVO.invoiceVO.showCancel == false) {
						var cVO:ChatVO = ChatManager.getChatByUID(msgVO.chatUID);
						if (cVO != null && cVO.questionID != null && cVO.questionID != "") {
							QuestionsManager.getQuestionByUID(cVO.questionID, false).setIsPaid();
							PHP.question_isPaid(onIsPaidResponse, cVO.questionID);
						}
					}
					ChatManager.updateInvoce(Config.BOUNDS + JSON.stringify(msgVO.systemMessageVO.invoiceVO.getData()), msgVO.id);
					
				} else {
					echo("markAsAcepted", "Cannot mark Invoice as complete because messageVO is null or messageVO.invoiceData is null");
				}
				echo("money", "S_PAY_TASK_COMPLETED", completedTask);
				S_PAY_TASK_COMPLETED.invoke(completedTask);
				if (completedTask.updateAccount == true)
				{
					PayManager.callGetAccountInfo();
				}
			}else{
				echo("markAsAcepted", "Cannot mark InvoiceData as complete because inTransactionTasks[callID] is null");
			}
			
			// TODO maybe keep completed PayTaskVO's in stock ?
			removeTaskFromTransactions(callID);
		}
		
		public static function onIsPaidResponse(phpRespond:PHPRespond):void {
			echo("onIsPaidResponse", "onIsPaidResponse");
		}
		
		//===========================================================================================================
		// 6  HELPERS
		//===========================================================================================================

		
		private static function onBack():void {
			InvoiceManager.stopProcessInvoice();
		}
		
		private static function showAlert(title:String, message:String, callback:Function = null, btn1:String = 'ok', btn2:String = null, btn3:String = null, textAlign:String = TextFormatAlign.CENTER,htmlText:Boolean = false):void {
			if (_isProcessingInvoice)
				DialogManager.alert(title, message, callback, btn1, btn2, btn3, textAlign,htmlText);
		}
		
		static public function hasTransactionWithChatMessageID(msgID:Number):Boolean
		{
			if (isNaN(msgID))
				return false;					
			for (var id:String in inTransactionTasks) {
				var taskVO:PayTaskVO = inTransactionTasks[id]
				if (taskVO != null && taskVO.messageVO != null && taskVO.messageVO.id == msgID){
					return true;
					break;
				}		
			}		
			
			// also check if this item is preprocerssing and in account checking phase??
			if (preProcesInvoiceData != null && preProcesInvoiceData.messageVO!=null && preProcesInvoiceData.messageVO.id == msgID){
				return true;
			}
			return false;
		}
	}
}