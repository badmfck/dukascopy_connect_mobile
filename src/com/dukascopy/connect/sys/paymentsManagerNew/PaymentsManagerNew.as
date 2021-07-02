package com.dukascopy.connect.sys.paymentsManagerNew {
	
	import com.adobe.crypto.MD5;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.connectionManager.NetworkManager;
	import com.dukascopy.connect.sys.crypter.Crypter;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.payments.PayAPIManager;
	import com.dukascopy.connect.sys.payments.PayConfig;
	import com.dukascopy.connect.sys.payments.PayRespond;
	import com.dukascopy.connect.sys.payments.PayServer;
	import com.dukascopy.langs.Lang;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class PaymentsManagerNew {
		
		static private var callbacksHistory:Object;
		static private var callbacksExchange:Object;
		static private var callbacksInernalTransfer:Object;
		static private var callbacksSendMoney:Object;
		static private var callbacksRDeposit:Object;
		static private var callbacksCardWithdrawal:Object;
		static private var callbacksCardUnload:Object;
		static private var callbacksInvest:Object;
		static private var callbacksPassForgot:Object;
		static private var callbacksPossibleRD:Object;
		static private var callbacksCancelRD:Object;
		static private var callbacksTransactionInfo:Object;
		static private var callbacksPasswordCheck:Object;
		static private var callbacksPasswordChange:Object;
		static private var callbacksTrCode:Object;
		static private var callbacksCardHistory:Object;
		static private var callbacksWalletCreation:Object;
		static private var callbacksWalletSavingCreation:Object;
		static private var callbacksTradingAccountOpening:Object;
		static private var callbacksCardVerified:Object;
		static private var callbacksInvestmentCurrency:Object;
		static private var callbacksWallet:Array;
		static private var callbacksChangeMainCurrency:Array;
		static private var callbacksCryptoDeals:Array;
		static private var callbacksCrypto:Array;
		static private var callbacksCryptoRDs:Array;
		static private var callbacksDeclareETHAddress:Array;
		static private var callbacksGetTPILink:Array;
		static private var callbacksTotal:Array;
		static private var callbacksHome:Array;
		static private var callbacksOtherWithdrawal:Object;
		static private var callbacksPaymentsDeposit:Object;
		static private var callbacksInvestments:Array;
		static private var callbacksInvestmentsH:Array;
		static private var callbacksInvestmentDetails:Array;
		static private var callbacksFatCatz:Array;
		static private var callbacksCards:Array;
		static private var callbacksLinkedCards:Array;
		static private var callbacksCardAction:Object;
		static private var callbacksCardRemove:Object;
		static private var callbacksCryptoOfferCreate:Object;
		static private var callbacksOfferActivate:Object;
		static private var callbacksCryptoWithdrawal:Object;
		static private var callbacksDeliveryInvestment:Object;
		static private var callbacksCryptoDepositeAddress:Object;
		static private var callbacksCryptoDeposite:Object;
		static private var callbacksOfferDeactivate:Object;
		static private var callbacksOfferDelete:Object;
		
		public function PaymentsManagerNew() { }
		
		static private function preCall():Boolean {
			if (NetworkManager.isConnected == false) {
				DialogManager.alert(Lang.textError, Lang.noInternetConnection);
				return false;
			}
			return true;
		}
		
		static private function checkForError(respond:PayRespond):Object {
			if (respond == null)
				return null;
			if (respond.error == false)
				return respond.data;
			if (respond.errorCode == PayRespond.ERROR_NOT_APPROVED_ACCOUNT ||
				respond.errorCode == PayRespond.ERROR_CODE_ACCOUNT_IS_BLOCKED ||
				respond.errorCode == PayRespond.ERROR_CODE_TOO_MANY_WRONG_PASSWORD_ENTERED) {
					return { errorType:"error", code:respond.errorCode, msg:respond.errorMsg };
			}
			if (respond.errorCode == PayRespond.ERROR_NEED_PASSWORD_CHANGE ||
				respond.errorCode == PayRespond.ERROR_NEED_PASSWORD ||
				respond.errorCode == PayRespond.ERROR_PASSWORD_INVALID ||
				respond.errorCode == PayRespond.ERROR_DAILY_LIMIT ||
				respond.errorCode == PayRespond.ERROR_TRANSACTION_LIMIT ||
				respond.errorCode == PayRespond.ERROR_PASS_CHANGE_INVALID) {
					return { errorType:"type", code:respond.errorCode, msg:respond.errorMsg };
			}
			if (respond.errorCode == PayRespond.ERROR_CODE_SESSION_INVALID) {
				return { errorType:"request", code:respond.errorCode, msg:respond.errorMsg };
			}
			return { errorType:"data", code:respond.errorCode, msg:respond.errorMsg };
		}
		
		/**
		 * This method request payments history from selected payments. If session is invalid (incorrect, need password etc.). Returns hash.
		 * @param	callback
		 * @param	page
		 * @param	itemsPerPage
		 * @param	status
		 * @param	type
		 * @param	dateFrom
		 * @param	dateTo
		 * @param	destination
		 */
		static public function callHistory(
			callback:Function,
			page:int,
			itemsPerPage:int = 10,
			status:String = "",
			type:String = "",
			dateFrom:String = "",
			dateTo:String = "",
			destination:String = "",
			wallet:String = "",
			userAcc:String = "",
			operationType:String = ""):String {
				if (preCall() == false)
					return null;
				var hash:String = MD5.hash(page + itemsPerPage + status + type + dateFrom + dateTo + destination + wallet);
				if (callbacksHistory == null || hash in callbacksHistory == false) {
					callbacksHistory ||= {};
					callbacksHistory[hash] = [callback];
				} else {
					if (callbacksHistory[hash].indexOf(callback) == -1)
						callbacksHistory[hash].push(callback);
					return hash;
				}
				PayServer.call_getMoneyHistory(onHistoryGetted, page, itemsPerPage, status, type, dateFrom, dateTo, destination, hash, callback, wallet, userAcc, operationType);
				return hash;
		}
		
		static private function onHistoryGetted(respond:PayRespond):void {
			if (callbacksHistory == null)
				return;
			var hashCallbacks:Array;
			if (respond.savedRequestData.callID in callbacksHistory == true)
				hashCallbacks = callbacksHistory[respond.savedRequestData.callID];
			if (hashCallbacks == null || hashCallbacks.length == 0) {
				delete callbacksHistory[respond.savedRequestData.callID];
				respond.dispose();
				return;
			}
			var res:Object = checkForError(respond);
			res.page = respond.savedRequestData.data.page;
			while (hashCallbacks.length != 0)
				hashCallbacks.shift()(res, respond.savedRequestData.callID, respond.savedRequestData.accountNumber);
			hashCallbacks = null;
			delete callbacksHistory[respond.savedRequestData.callID];
			respond.dispose();
		}
		
		static public function passForgot(callback:Function, email:String, phone:String, code:String = null, token:String = null):String {
			if (preCall() == false)
				return null;
			var hash:String = MD5.hash(email + phone + code + token);
			if (callbacksPassForgot == null || hash in callbacksPassForgot == false) {
				callbacksPassForgot ||= {};
				callbacksPassForgot[hash] = [callback];
			} else {
				if (callbacksPassForgot[hash].indexOf(callback) == -1)
					callbacksPassForgot[hash].push(callback);
				return hash;
			}
			var data:Object = {
				email: email,
				phone: phone
			}
			if (code != null) {
				data.code = code;
				data.token = token;
			}
			PayServer.call_postForgot(passForgotReminded, data, hash);
			return hash;
		}
		
		static private function passForgotReminded(respond:PayRespond):void {
			if (callbacksPassForgot == null)
				return;
			var hashCallbacks:Array;
			if (respond.savedRequestData.callID in callbacksPassForgot == true)
				hashCallbacks = callbacksPassForgot[respond.savedRequestData.callID];
			if (hashCallbacks == null || hashCallbacks.length == 0) {
				delete callbacksPassForgot[respond.savedRequestData.callID];
				respond.dispose();
				return;
			}
			var res:Object = checkForError(respond);
			while (hashCallbacks.length != 0)
				hashCallbacks.shift()(res, respond.savedRequestData.callID);
			hashCallbacks = null;
			delete callbacksPassForgot[respond.savedRequestData.callID];
			respond.dispose();
		}
		
		static public function getPossibleRDReceived(callback:Function, currency:String, amount:String):String {
			if (preCall() == false)
				return null;
			var hash:String = MD5.hash(amount + currency);
			if (callbacksPossibleRD == null || hash in callbacksPossibleRD == false) {
				callbacksPossibleRD ||= {};
				callbacksPossibleRD[hash] = [callback];
			} else {
				if (callbacksPossibleRD[hash].indexOf(callback) == -1)
					callbacksPossibleRD[hash].push(callback);
				return hash;
			}
			var data:Object = {
				currency: currency,
				amount: amount
			}
			PayServer.call_getPossibleRD(onPossibleRD, data, hash);
			return hash;
		}
		
		static private function onPossibleRD(respond:PayRespond):void {
			if (callbacksPossibleRD == null)
				return;
			var hashCallbacks:Array;
			if (respond.savedRequestData.callID in callbacksPossibleRD == true)
				hashCallbacks = callbacksPossibleRD[respond.savedRequestData.callID];
			if (hashCallbacks == null || hashCallbacks.length == 0) {
				delete callbacksPossibleRD[respond.savedRequestData.callID];
				respond.dispose();
				return;
			}
			var res:Object = checkForError(respond);
			while (hashCallbacks.length != 0)
				hashCallbacks.shift()(res, respond.savedRequestData.callID);
			hashCallbacks = null;
			delete callbacksPossibleRD[respond.savedRequestData.callID];
			respond.dispose();
		}
		
		static public function cancelRDDeposit(callback:Function, id:String):void {
			if (preCall() == false)
				return;
			if (callbacksCancelRD == null || id in callbacksCancelRD == false) {
				callbacksCancelRD ||= {};
				callbacksCancelRD[id] = [callback];
			} else {
				if (callbacksCancelRD[id].indexOf(callback) == -1)
					callbacksCancelRD[id].push(callback);
				return;
			}
			PayServer.call_postRDCancel(onRDCanceled, { code: id } );
			return;
		}
		
		static private function onRDCanceled(respond:PayRespond):void {
			if (callbacksCancelRD == null)
				return;
			var hashCallbacks:Array;
			if (respond.savedRequestData.callID in callbacksCancelRD == true)
				hashCallbacks = callbacksCancelRD[respond.savedRequestData.callID];
			if (hashCallbacks == null || hashCallbacks.length == 0) {
				delete callbacksCancelRD[respond.savedRequestData.callID];
				respond.dispose();
				return;
			}
			var res:Object = checkForError(respond);
			while (hashCallbacks.length != 0)
				hashCallbacks.shift()(res, respond.savedRequestData.callID);
			hashCallbacks = null;
			delete callbacksCancelRD[respond.savedRequestData.callID];
			respond.dispose();
		}
		
		static public function callInvest(callback:Function, currency:String, walletNumberFrom:String, quantity:Number, amount:Number, direction:String ="buy"):String {
			if (preCall() == false)
				return null;
			var hash:String = MD5.hash(currency + walletNumberFrom + quantity + amount);
			if (callbacksInvest == null || hash in callbacksInvest == false) {
				callbacksInvest ||= {};
				callbacksInvest[hash] = [callback];
			} else {
				if (callbacksInvest[hash].indexOf(callback) == -1)
					callbacksInvest[hash].push(callback);
				return hash;
			}
			var data:Object = {
				account: walletNumberFrom,
				instrument: currency,
				direction: direction
			}
			if (isNaN(quantity) == false)
				data.quantity = quantity;
			else
				data.amount = amount;
			PayServer.call_putInvestment(onInvested, data, hash);
			return hash;
		}
		
		static private function onInvested(respond:PayRespond):void {
			if (callbacksInvest == null)
				return;
			var hashCallbacks:Array;
			if (respond.savedRequestData.callID in callbacksInvest == true)
				hashCallbacks = callbacksInvest[respond.savedRequestData.callID];
			if (hashCallbacks == null || hashCallbacks.length == 0) {
				delete callbacksInvest[respond.savedRequestData.callID];
				respond.dispose();
				return;
			}
			var res:Object = checkForError(respond);
			while (hashCallbacks.length != 0)
				hashCallbacks.shift()(res, respond.savedRequestData.callID);
			hashCallbacks = null;
			delete callbacksInvest[respond.savedRequestData.callID];
			respond.dispose();
		}
		
		static public function callCardWithdrawal(callback:Function, amount:Number, currency:String, wallet:String, card:String, type:String = "PPCARD"):String {
			if (preCall() == false)
				return null;
			var hash:String = MD5.hash(amount + currency + wallet + card);
			if (callbacksCardWithdrawal == null || hash in callbacksCardWithdrawal == false) {
				callbacksCardWithdrawal ||= {};
				callbacksCardWithdrawal[hash] = [callback];
			} else {
				if (callbacksCardWithdrawal[hash].indexOf(callback) == -1)
					callbacksCardWithdrawal[hash].push(callback);
				return hash;
			}
			PayServer.call_putMoneyWithdrawal(onCardWithdrawed, Number(wallet), type, amount, currency, card, "", hash);
			return hash;
		}
		
		static private function onCardWithdrawed(respond:PayRespond):void {
			if (callbacksCardWithdrawal == null)
				return;
			var hashCallbacks:Array;
			if (respond.savedRequestData.callID in callbacksCardWithdrawal == true)
				hashCallbacks = callbacksCardWithdrawal[respond.savedRequestData.callID];
			if (hashCallbacks == null || hashCallbacks.length == 0) {
				delete callbacksCardWithdrawal[respond.savedRequestData.callID];
				respond.dispose();
				return;
			}
			var res:Object = checkForError(respond);
			while (hashCallbacks.length != 0)
				hashCallbacks.shift()(res, respond.savedRequestData.callID);
			hashCallbacks = null;
			delete callbacksCardWithdrawal[respond.savedRequestData.callID];
			respond.dispose();
		}
		
		static public function callOtherWithdrawal(callback:Function, from:String, currency:String, type:String):String {
			if (preCall() == false)
				return null;
			var hash:String = MD5.hash(from + currency + type);
			if (callbacksOtherWithdrawal == null || hash in callbacksOtherWithdrawal == false) {
				callbacksOtherWithdrawal ||= {};
				callbacksOtherWithdrawal[hash] = [callback];
			} else {
				if (callbacksOtherWithdrawal[hash].indexOf(callback) == -1)
					callbacksOtherWithdrawal[hash].push(callback);
				return hash;
			}
			PayServer.call_putMoneyWithdrawalOther(onOtherWithdrawed, from, currency, type, hash);
			return hash;
		}
		
		static private function onOtherWithdrawed(respond:PayRespond):void {
			if (callbacksOtherWithdrawal == null)
				return;
			var hashCallbacks:Array;
			if (respond.savedRequestData.callID in callbacksOtherWithdrawal == true)
				hashCallbacks = callbacksOtherWithdrawal[respond.savedRequestData.callID];
			if (hashCallbacks == null || hashCallbacks.length == 0) {
				delete callbacksOtherWithdrawal[respond.savedRequestData.callID];
				respond.dispose();
				return;
			}
			var res:Object = checkForError(respond);
			while (hashCallbacks.length != 0)
				hashCallbacks.shift()(res, respond.savedRequestData.callID);
			hashCallbacks = null;
			delete callbacksOtherWithdrawal[respond.savedRequestData.callID];
			respond.dispose();
		}
		
		static public function callPaymentsDeposit(callback:Function, type:String, currency:String = null):String {
			if (preCall() == false)
				return null;
			var hash:String = MD5.hash(currency + type);
			if (callbacksPaymentsDeposit == null || hash in callbacksPaymentsDeposit == false) {
				callbacksPaymentsDeposit ||= {};
				callbacksPaymentsDeposit[hash] = [callback];
			} else {
				if (callbacksPaymentsDeposit[hash].indexOf(callback) == -1)
					callbacksPaymentsDeposit[hash].push(callback);
				return hash;
			}
			if (type == "ApplePAY") {
				PayServer.call_putDepositApplePay(onPaymentsDeposited, hash);
				return hash;
			}
			var data:Object = { type:type };
			if (type == "PPCARD")
				data.async = true;
			if (currency != null)
				data.currency = currency;
			PayServer.call_putDeposit(onPaymentsDeposited, data, hash);
			return hash;
		}
		
		static private function onPaymentsDeposited(respond:PayRespond):void {
			if (callbacksPaymentsDeposit == null)
				return;
			var hashCallbacks:Array;
			if (respond.savedRequestData.callID in callbacksPaymentsDeposit == true)
				hashCallbacks = callbacksPaymentsDeposit[respond.savedRequestData.callID];
			if (hashCallbacks == null || hashCallbacks.length == 0) {
				delete callbacksPaymentsDeposit[respond.savedRequestData.callID];
				respond.dispose();
				return;
			}
			var res:Object = checkForError(respond);
			while (hashCallbacks.length != 0)
				hashCallbacks.shift()(res, respond.savedRequestData.callID);
			hashCallbacks = null;
			delete callbacksPaymentsDeposit[respond.savedRequestData.callID];
			respond.dispose();
		}
		
		static public function callUnloadCard(callback:Function, amount:Number, currency:String, card:String, cvv:String = null):String {
			if (preCall() == false)
				return null;
			var hash:String = MD5.hash(amount + currency + card + cvv);
			if (callbacksCardUnload == null || hash in callbacksCardUnload == false) {
				callbacksCardUnload ||= {};
				callbacksCardUnload[hash] = [callback];
			} else {
				if (callbacksCardUnload[hash].indexOf(callback) == -1)
					callbacksCardUnload[hash].push(callback);
				return hash;
			}
			var type:String = (isNaN(Number(card)) == true) ? "MCARD" : "PPCARD";
			PayServer.call_putMoneyMyCardDeposit(onCardUnloaded, amount, currency, type, card, false, hash, cvv);
			return hash;
		}
		
		static private function onCardUnloaded(respond:PayRespond):void {
			if (callbacksCardUnload == null)
				return;
			var hashCallbacks:Array;
			if (respond.savedRequestData.callID in callbacksCardUnload == true)
				hashCallbacks = callbacksCardUnload[respond.savedRequestData.callID];
			if (hashCallbacks == null || hashCallbacks.length == 0) {
				delete callbacksCardUnload[respond.savedRequestData.callID];
				respond.dispose();
				return;
			}
			var res:Object = checkForError(respond);
			while (hashCallbacks.length != 0)
				hashCallbacks.shift()(res, respond.savedRequestData.callID);
			hashCallbacks = null;
			delete callbacksCardUnload[respond.savedRequestData.callID];
			respond.dispose();
		}
		
		static public function callSendMoney(callback:Function, amount:Number, currency:String, userUID:String, walletNumberFrom:String, comment:String, pass:String, clarification:String,  toType:String = "tfuid"):String {
			if (preCall() == false)
				return null;
			var hash:String = MD5.hash(amount + currency + userUID + walletNumberFrom + comment);
			if (callbacksSendMoney == null || hash in callbacksSendMoney == false) {
				callbacksSendMoney ||= {};
				callbacksSendMoney[hash] = [callback];
			} else {
				if (callbacksSendMoney[hash].indexOf(callback) == -1)
					callbacksSendMoney[hash].push(callback);
				return hash;
			}
			var data:Object = {
				from: walletNumberFrom,
				to: userUID,
				amount: amount,
				currency: currency,
				from_uid: Auth.uid,
				to_type: toType
			}
			if (comment != "")
				data.message = comment;
			if (pass != "")
				data.code = pass;
			if (clarification != "")
				data.clarification = clarification;
			PayServer.call_putMoneySendAdvanced(onMoneySent, data, hash);
			return hash;
		}
		
		static private function onMoneySent(respond:PayRespond):void {
			if (callbacksSendMoney == null)
				return;
			var hashCallbacks:Array;
			if (respond.savedRequestData.callID in callbacksSendMoney == true)
				hashCallbacks = callbacksSendMoney[respond.savedRequestData.callID];
			if (hashCallbacks == null || hashCallbacks.length == 0) {
				delete callbacksSendMoney[respond.savedRequestData.callID];
				respond.dispose();
				return;
			}
			var res:Object = checkForError(respond);
			while (hashCallbacks.length != 0)
				hashCallbacks.shift()(res, respond.savedRequestData.callID);
			hashCallbacks = null;
			delete callbacksSendMoney[respond.savedRequestData.callID];
			respond.dispose();
		}
		
		static public function callMakeRDeposit(callback:Function, amount:Number, currency:String, type:String):String {
			if (preCall() == false)
				return null;
			var hash:String = MD5.hash(amount + currency + type);
			if (callbacksRDeposit == null || hash in callbacksRDeposit == false) {
				callbacksRDeposit ||= {};
				callbacksRDeposit[hash] = [callback];
			} else {
				if (callbacksRDeposit[hash].indexOf(callback) == -1)
					callbacksRDeposit[hash].push(callback);
				return hash;
			}
			var data:Object = {
				amount: amount,
				currency: currency,
				deposit_scheme: type
			}
			PayServer.call_putRDeposit(onRDepositCreated, data, hash);
			return hash;
		}
		
		static private function onRDepositCreated(respond:PayRespond):void {
			if (callbacksRDeposit == null)
				return;
			var hashCallbacks:Array;
			if (respond.savedRequestData.callID in callbacksRDeposit == true)
				hashCallbacks = callbacksRDeposit[respond.savedRequestData.callID];
			if (hashCallbacks == null || hashCallbacks.length == 0) {
				delete callbacksRDeposit[respond.savedRequestData.callID];
				respond.dispose();
				return;
			}
			var res:Object = checkForError(respond);
			while (hashCallbacks.length != 0)
				hashCallbacks.shift()(res, respond.savedRequestData.callID);
			hashCallbacks = null;
			delete callbacksRDeposit[respond.savedRequestData.callID];
			respond.dispose();
		}
		
		static public function callExchange(callback:Function, walletNumberFrom:String, walletNumberTo:String, amount:Number, currency:String):String {
			if (preCall() == false)
				return null;
			var hash:String = MD5.hash(walletNumberFrom + walletNumberTo + amount + currency);
			if (callbacksExchange == null || hash in callbacksExchange == false) {
				callbacksExchange ||= {};
				callbacksExchange[hash] = [callback];
			} else {
				if (callbacksExchange[hash].indexOf(callback) == -1)
					callbacksExchange[hash].push(callback);
				return hash;
			}
			var data:Object = {
				from: walletNumberFrom,
				to: walletNumberTo,
				amount: amount,
				currency: currency
			}
			PayServer.call_internalTransfer(onExchanged, data, hash);
			return hash;
		}
		
		static private function onExchanged(respond:PayRespond):void {
			if (callbacksExchange == null)
				return;
			var hashCallbacks:Array;
			if (respond.savedRequestData.callID in callbacksExchange == true)
				hashCallbacks = callbacksExchange[respond.savedRequestData.callID];
			if (hashCallbacks == null || hashCallbacks.length == 0) {
				delete callbacksExchange[respond.savedRequestData.callID];
				respond.dispose();
				return;
			}
			var res:Object = checkForError(respond);
			while (hashCallbacks.length != 0)
				hashCallbacks.shift()(res, respond.savedRequestData.callID);
			hashCallbacks = null;
			delete callbacksExchange[respond.savedRequestData.callID];
			respond.dispose();
		}
		
		static public function callInternalTransfer(callback:Function, walletNumberFrom:String, walletNumberTo:String, amount:Number, currency:String):String {
			if (preCall() == false)
				return null;
			var hash:String = MD5.hash(walletNumberFrom + walletNumberTo + amount + currency);
			if (callbacksInernalTransfer == null || hash in callbacksInernalTransfer == false) {
				callbacksInernalTransfer ||= {};
				callbacksInernalTransfer[hash] = [callback];
			} else {
				if (callbacksInernalTransfer[hash].indexOf(callback) == -1)
					callbacksInernalTransfer[hash].push(callback);
				return hash;
			}
			var data:Object = {
				from: walletNumberFrom,
				to: walletNumberTo,
				amount: amount,
				currency: currency
			}
			PayServer.call_putMoneyTransfer(onInternalTransfer, walletNumberFrom, walletNumberTo, amount, currency, hash);
			return hash;
		}
		
		static private function onInternalTransfer(respond:PayRespond):void {
			if (callbacksInernalTransfer == null)
				return;
			var hashCallbacks:Array;
			if (respond.savedRequestData.callID in callbacksInernalTransfer == true)
				hashCallbacks = callbacksInernalTransfer[respond.savedRequestData.callID];
			if (hashCallbacks == null || hashCallbacks.length == 0) {
				delete callbacksInernalTransfer[respond.savedRequestData.callID];
				respond.dispose();
				return;
			}
			var res:Object = checkForError(respond);
			while (hashCallbacks.length != 0)
				hashCallbacks.shift()(res, respond.savedRequestData.callID);
			hashCallbacks = null;
			delete callbacksInernalTransfer[respond.savedRequestData.callID];
			respond.dispose();
		}
		
		static public function callCreateWallet(callback:Function, currency:String):String {
			if (preCall() == false)
				return null;
			if (callbacksWalletCreation == null || currency in callbacksWalletCreation == false) {
				callbacksWalletCreation ||= {};
				callbacksWalletCreation[currency] = [callback];
			} else {
				if (callbacksWalletCreation[currency].indexOf(callback) == -1)
					callbacksWalletCreation[currency].push(callback);
				return currency;
			}
			PayServer.call_putAccountWallet(onWalletCreated, currency, "", currency)
			return currency;
		}
		
		static private function onWalletCreated(respond:PayRespond):void {
			if (callbacksWalletCreation == null)
				return;
			var hashCallbacks:Array;
			if (respond.savedRequestData.callID in callbacksWalletCreation == true)
				hashCallbacks = callbacksWalletCreation[respond.savedRequestData.callID];
			if (hashCallbacks == null || hashCallbacks.length == 0) {
				delete callbacksWalletCreation[respond.savedRequestData.callID];
				respond.dispose();
				return;
			}
			var res:Object = checkForError(respond);
			while (hashCallbacks.length != 0)
				hashCallbacks.shift()(res, respond.savedRequestData.callID);
			hashCallbacks = null;
			delete callbacksWalletCreation[respond.savedRequestData.callID];
			respond.dispose();
		}
		
		static public function callCreateWalletSaving(callback:Function, currency:String):String {
			if (preCall() == false)
				return null;
			if (callbacksWalletSavingCreation == null || currency in callbacksWalletSavingCreation == false) {
				callbacksWalletSavingCreation ||= {};
				callbacksWalletSavingCreation[currency] = [callback];
			} else {
				if (callbacksWalletSavingCreation[currency].indexOf(callback) == -1)
					callbacksWalletSavingCreation[currency].push(callback);
				return currency;
			}
			PayServer.call_putSavingWallet(onWalletSavingCreated, currency, currency)
			return currency;
		}
		
		static private function onWalletSavingCreated(respond:PayRespond):void {
			if (callbacksWalletSavingCreation == null)
				return;
			var hashCallbacks:Array;
			if (respond.savedRequestData.callID in callbacksWalletSavingCreation == true)
				hashCallbacks = callbacksWalletSavingCreation[respond.savedRequestData.callID];
			if (hashCallbacks == null || hashCallbacks.length == 0) {
				delete callbacksWalletSavingCreation[respond.savedRequestData.callID];
				respond.dispose();
				return;
			}
			var res:Object = checkForError(respond);
			while (hashCallbacks.length != 0)
				hashCallbacks.shift()(res, respond.savedRequestData.callID);
			hashCallbacks = null;
			delete callbacksWalletSavingCreation[respond.savedRequestData.callID];
			respond.dispose();
		}
		
		static public function callOpenTradingAccount(callback:Function, currency:String, account:String = "forex"):String {
			if (preCall() == false)
				return null;
			var hash:String = account + currency;
			if (callbacksTradingAccountOpening == null || hash in callbacksTradingAccountOpening == false) {
				callbacksTradingAccountOpening ||= {};
				callbacksTradingAccountOpening[hash] = [callback];
			} else {
				if (callbacksTradingAccountOpening[hash].indexOf(callback) == -1)
					callbacksTradingAccountOpening[hash].push(callback);
				return currency;
			}
			var data:Object = { };
			data[account] = currency;
			PayServer.call_postAccountTrading(callTradingAccountOpened, data, hash);
			return hash;
		}
		
		static private function callTradingAccountOpened(respond:PayRespond):void {
			if (callbacksTradingAccountOpening == null)
				return;
			var hashCallbacks:Array;
			if (respond.savedRequestData.callID in callbacksTradingAccountOpening == true)
				hashCallbacks = callbacksTradingAccountOpening[respond.savedRequestData.callID];
			if (hashCallbacks == null || hashCallbacks.length == 0) {
				delete callbacksTradingAccountOpening[respond.savedRequestData.callID];
				respond.dispose();
				return;
			}
			var res:Object = checkForError(respond);
			while (hashCallbacks.length != 0)
				hashCallbacks.shift()(res, respond.savedRequestData.callID);
			hashCallbacks = null;
			delete callbacksTradingAccountOpening[respond.savedRequestData.callID];
			respond.dispose();
		}
		
		static public function callCardVerify(callback:Function, cardID:String, amount:String = null, code:String = null):String {
			if (preCall() == false)
				return null;
			var hash:String = MD5.hash(cardID + amount + code);
			if (callbacksCardVerified == null || hash in callbacksCardVerified == false) {
				callbacksCardVerified ||= {};
				callbacksCardVerified[hash] = [callback];
			} else {
				if (callbacksCardVerified[hash].indexOf(callback) == -1)
					callbacksCardVerified[hash].push(callback);
				return hash;
			}
			var dta:Object = { card_uid:cardID };
			if (amount != null)
				dta.amount = amount;
			else if (code != null)
				dta.code = code;
			PayServer.call_postMoneyCards(onCardVerified, hash, dta);
			return hash;
		}
		
		static private function onCardVerified(respond:PayRespond):void {
			if (callbacksCardVerified == null)
				return;
			var hashCallbacks:Array;
			if (respond.savedRequestData.callID in callbacksCardVerified == true)
				hashCallbacks = callbacksCardVerified[respond.savedRequestData.callID];
			if (hashCallbacks == null || hashCallbacks.length == 0) {
				delete callbacksCardVerified[respond.savedRequestData.callID];
				respond.dispose();
				return;
			}
			var res:Object = checkForError(respond);
			while (hashCallbacks.length != 0)
				hashCallbacks.shift()(res, respond.savedRequestData.callID);
			hashCallbacks = null;
			delete callbacksCardVerified[respond.savedRequestData.callID];
			respond.dispose();
		}
		
		static public function callInvestmentCurrency(callback:Function, currency:String):String {
			if (preCall() == false)
				return null;
			if (callbacksInvestmentCurrency == null || currency in callbacksInvestmentCurrency == false) {
				callbacksInvestmentCurrency ||= {};
				callbacksInvestmentCurrency[currency] = [callback];
			} else {
				if (callbacksInvestmentCurrency[currency].indexOf(callback) == -1)
					callbacksInvestmentCurrency[currency].push(callback);
				return currency;
			}
			PayServer.call_postSettings(onInvestmentCurrencySetted, { INVESTMENT_REFERENCE_CURRENCY:currency }, currency);
			return currency;
		}
		
		static private function onInvestmentCurrencySetted(respond:PayRespond):void {
			if (callbacksInvestmentCurrency == null)
				return;
			var hashCallbacks:Array;
			if (respond.savedRequestData.callID in callbacksInvestmentCurrency == true)
				hashCallbacks = callbacksInvestmentCurrency[respond.savedRequestData.callID];
			if (hashCallbacks == null || hashCallbacks.length == 0) {
				delete callbacksInvestmentCurrency[respond.savedRequestData.callID];
				respond.dispose();
				return;
			}
			var res:Object = checkForError(respond);
			while (hashCallbacks.length != 0)
				hashCallbacks.shift()(res);
			hashCallbacks = null;
			delete callbacksInvestmentCurrency[respond.savedRequestData.callID];
			respond.dispose();
		}
		
		static public function callTransactionInfo(callback:Function, transactionID:String):String {
			if (preCall() == false)
				return null;
			if (callbacksTransactionInfo == null || transactionID in callbacksTransactionInfo == false) {
				callbacksTransactionInfo ||= {};
				callbacksTransactionInfo[transactionID] = [callback];
			} else {
				if (callbacksTransactionInfo[transactionID].indexOf(callback) == -1)
					callbacksTransactionInfo[transactionID].push(callback);
				return transactionID;
			}
			PayServer.call_getMoneySpecific(onTransactionInfoGetted, transactionID);
			return transactionID;
		}
		
		static private function onTransactionInfoGetted(respond:PayRespond):void {
			if (callbacksTransactionInfo == null)
				return;
			var hashCallbacks:Array;
			if (respond.savedRequestData.callID in callbacksTransactionInfo == true)
				hashCallbacks = callbacksTransactionInfo[respond.savedRequestData.callID];
			if (hashCallbacks == null || hashCallbacks.length == 0) {
				delete callbacksTransactionInfo[respond.savedRequestData.callID];
				respond.dispose();
				return;
			}
			var res:Object = checkForError(respond);
			while (hashCallbacks.length != 0)
				hashCallbacks.shift()(res, respond.savedRequestData.callID);
			hashCallbacks = null;
			delete callbacksTransactionInfo[respond.savedRequestData.callID];
		}
		
		static public function createCryptoOffer(
			callback:Function,
			coin:String,
			currency:String,
			side:String,
			price:Number,
			quantity:Number,
			for_account:String = "",
			good_till:Number = NaN,
			fullOrder:Boolean = false):String {
				if (preCall() == false)
					return null;
				var hash:String = MD5.hash(coin + currency + side + price + quantity + for_account + good_till);
				if (callbacksCryptoOfferCreate == null || hash in callbacksCryptoOfferCreate == false) {
					callbacksCryptoOfferCreate ||= {};
					callbacksCryptoOfferCreate[hash] = [callback];
				} else {
					if (callbacksCryptoOfferCreate[hash].indexOf(callback) == -1)
						callbacksCryptoOfferCreate[hash].push(callback);
					return hash;
				}
				var dta:Object = { coin:coin, currency:currency, side:side, price:price, quantity:quantity, activate:true };
				if (fullOrder == true)
					dta.fill_or_kill = true;
				if (for_account != "")
					dta.for_account = for_account;
				if (good_till != 0)
					dta.deadline = good_till;
				PayServer.call_cryptoOfferCreate(onCryptoOfferCreated, dta, hash);
				return hash;
		}
		
		static private function onCryptoOfferCreated(respond:PayRespond):void {
			if (callbacksCryptoOfferCreate == null)
				return;
			var hashCallbacks:Array;
			if (respond.savedRequestData.callID in callbacksCryptoOfferCreate == true)
				hashCallbacks = callbacksCryptoOfferCreate[respond.savedRequestData.callID];
			if (hashCallbacks == null || hashCallbacks.length == 0) {
				delete callbacksCryptoOfferCreate[respond.savedRequestData.callID];
				respond.dispose();
				return;
			}
			var res:Object = checkForError(respond);
			while (hashCallbacks.length != 0)
				hashCallbacks.shift()(res, respond.savedRequestData.callID);
			hashCallbacks = null;
			delete callbacksCryptoOfferCreate[respond.savedRequestData.callID];
		}
		
		static public function getCryptoDeals(callback:Function):void {
			if (preCall() == false)
				return;
			if (callbacksCryptoDeals == null || callbacksCryptoDeals.length == 0) {
				callbacksCryptoDeals = [callback];
			} else {
				if (callbacksCryptoDeals.indexOf(callback) == -1)
					callbacksCryptoDeals.push(callback);
				return;
			}
			PayServer.call_cryptoDeals(onCryptoDealsGetted);
		}
		
		static private function onCryptoDealsGetted(respond:PayRespond):void {
			if (callbacksCryptoDeals == null)
				return;
			var res:Object = checkForError(respond);
			while (callbacksCryptoDeals.length != 0)
				callbacksCryptoDeals.shift()(res);
			callbacksCryptoDeals = null;
		}
		
		static public function callCardAction(callback:Function, cardID:String, action:String, param:String = null):String {
			if (preCall() == false)
				return null;
			var hash:String = MD5.hash(cardID + action + param);
			if (callbacksCardAction == null || hash in callbacksCardAction == false) {
				callbacksCardAction ||= {};
				callbacksCardAction[hash] = [callback];
			} else {
				if (callbacksCardAction[hash].indexOf(callback) == -1)
					callbacksCardAction[hash].push(callback);
				return hash;
			}
			var dta:Object = { action:action };
			if (param != null)
				dta.verification_value = param;
			PayServer.call_actionCard(onCardActionRespond, cardID, dta, hash);
			return hash;
		}
		
		static private function onCardActionRespond(respond:PayRespond):void {
			if (callbacksCardAction == null)
				return;
			var hashCallbacks:Array;
			if (respond.savedRequestData.callID in callbacksCardAction == true)
				hashCallbacks = callbacksCardAction[respond.savedRequestData.callID];
			if (hashCallbacks == null || hashCallbacks.length == 0) {
				delete callbacksCardAction[respond.savedRequestData.callID];
				respond.dispose();
				return;
			}
			var res:Object = checkForError(respond);
			while (hashCallbacks.length != 0)
				hashCallbacks.shift()(res, respond.savedRequestData.callID);
			hashCallbacks = null;
			delete callbacksCardAction[respond.savedRequestData.callID];
		}
		
		static public function tradeCrypto(callback:Function, offerID:String, quantity:Number, price:Number, side:String):String {
			if (preCall() == false)
				return null;
			var hash:String = MD5.hash(offerID + side + quantity + price);
			if (callbacksOfferActivate == null || hash in callbacksOfferActivate == false) {
				callbacksOfferActivate ||= {};
				callbacksOfferActivate[hash] = [callback];
			} else {
				if (callbacksOfferActivate[hash].indexOf(callback) == -1)
					callbacksOfferActivate[hash].push(callback);
				return hash;
			}
			PayServer.call_cryptoTrade(onCryptoTraded, offerID, side, quantity, price, hash);
			return hash;
		}
		
		static private function onCryptoTraded(respond:PayRespond):void {
			if (callbacksOfferActivate == null)
				return;
			var hashCallbacks:Array;
			if (respond.savedRequestData.callID in callbacksOfferActivate == true)
				hashCallbacks = callbacksOfferActivate[respond.savedRequestData.callID];
			if (hashCallbacks == null || hashCallbacks.length == 0) {
				delete callbacksOfferActivate[respond.savedRequestData.callID];
				respond.dispose();
				return;
			}
			var res:Object = checkForError(respond);
			while (hashCallbacks.length != 0)
				hashCallbacks.shift()(res, respond.savedRequestData.callID);
			hashCallbacks = null;
			delete callbacksOfferActivate[respond.savedRequestData.callID];
		}
		
		static public function withdrawalCrypto(callback:Function, amount:Number, coin:String, address:String):String {
			if (preCall() == false)
				return null;
			var hash:String = MD5.hash(amount + coin + address);
			if (callbacksCryptoWithdrawal == null || hash in callbacksCryptoWithdrawal == false) {
				callbacksCryptoWithdrawal ||= {};
				callbacksCryptoWithdrawal[hash] = [callback];
			} else {
				if (callbacksCryptoWithdrawal[hash].indexOf(callback) == -1)
					callbacksCryptoWithdrawal[hash].push(callback);
				return hash;
			}
			PayServer.call_cryptoWithdrawal(onCryptoWithdrawal, address, amount, coin, hash);
			return hash;
		}
		
		static private function onCryptoWithdrawal(respond:PayRespond):void {
			if (callbacksCryptoWithdrawal == null)
				return;
			var hashCallbacks:Array;
			if (respond.savedRequestData.callID in callbacksCryptoWithdrawal == true)
				hashCallbacks = callbacksCryptoWithdrawal[respond.savedRequestData.callID];
			if (hashCallbacks == null || hashCallbacks.length == 0) {
				delete callbacksCryptoWithdrawal[respond.savedRequestData.callID];
				respond.dispose();
				return;
			}
			var res:Object = checkForError(respond);
			while (hashCallbacks.length != 0)
				hashCallbacks.shift()(res, respond.savedRequestData.callID);
			hashCallbacks = null;
			delete callbacksCryptoWithdrawal[respond.savedRequestData.callID];
		}
		
		static public function deliveryInvestments(callback:Function, amount:Number, coin:String, address:String, feeAcc:String):String {
			if (preCall() == false)
				return null;
			var hash:String = MD5.hash(amount + coin + address + feeAcc);
			if (callbacksDeliveryInvestment == null || hash in callbacksDeliveryInvestment == false) {
				callbacksDeliveryInvestment ||= {};
				callbacksDeliveryInvestment[hash] = [callback];
			} else {
				if (callbacksDeliveryInvestment[hash].indexOf(callback) == -1)
					callbacksDeliveryInvestment[hash].push(callback);
				return hash;
			}
			PayServer.call_investmentDelivery(onDeliveryInvestments, address, amount, coin, feeAcc, hash);
			return hash;
		}
		
		static private function onDeliveryInvestments(respond:PayRespond):void {
			if (callbacksDeliveryInvestment == null)
				return;
			var hashCallbacks:Array;
			if (respond.savedRequestData.callID in callbacksDeliveryInvestment == true)
				hashCallbacks = callbacksDeliveryInvestment[respond.savedRequestData.callID];
			if (hashCallbacks == null || hashCallbacks.length == 0) {
				delete callbacksDeliveryInvestment[respond.savedRequestData.callID];
				respond.dispose();
				return;
			}
			var res:Object = checkForError(respond);
			while (hashCallbacks.length != 0)
				hashCallbacks.shift()(res, respond.savedRequestData.callID);
			hashCallbacks = null;
			delete callbacksDeliveryInvestment[respond.savedRequestData.callID];
		}
		
		static public function depositeAddressCrypto(callback:Function, amount:Number, coin:String, address:String):String {
			if (preCall() == false)
				return null;
			var hash:String = MD5.hash(amount + coin + address);
			if (callbacksCryptoDepositeAddress == null || hash in callbacksCryptoDepositeAddress == false) {
				callbacksCryptoDepositeAddress ||= {};
				callbacksCryptoDepositeAddress[hash] = [callback];
			} else {
				if (callbacksCryptoDepositeAddress[hash].indexOf(callback) == -1)
					callbacksCryptoDepositeAddress[hash].push(callback);
				return hash;
			}
			PayServer.call_cryptoDepositAddress(onCryptoDepositeAddress, address, amount, coin, hash);
			return hash;
		}
		
		static private function onCryptoDepositeAddress(respond:PayRespond):void {
			if (callbacksCryptoDepositeAddress == null)
				return;
			var hashCallbacks:Array;
			if (respond.savedRequestData.callID in callbacksCryptoDepositeAddress == true)
				hashCallbacks = callbacksCryptoDepositeAddress[respond.savedRequestData.callID];
			if (hashCallbacks == null || hashCallbacks.length == 0) {
				delete callbacksCryptoDepositeAddress[respond.savedRequestData.callID];
				respond.dispose();
				return;
			}
			var res:Object = checkForError(respond);
			while (hashCallbacks.length != 0)
				hashCallbacks.shift()(res, respond.savedRequestData.callID);
			hashCallbacks = null;
			delete callbacksCryptoDepositeAddress[respond.savedRequestData.callID];
		}
		
		static public function activateCryptoOffer(callback:Function, offerID:String):void {
			if (preCall() == false)
				return;
			if (callbacksOfferActivate == null || offerID in callbacksOfferActivate == false) {
				callbacksOfferActivate ||= {};
				callbacksOfferActivate[offerID] = [callback];
			} else {
				if (callbacksOfferActivate[offerID].indexOf(callback) == -1)
					callbacksOfferActivate[offerID].push(callback);
				return;
			}
			PayServer.call_cryptoOfferActivate(onCryptoOfferActivated, offerID, offerID);
		}
		
		static private function onCryptoOfferActivated(respond:PayRespond):void {
			if (callbacksOfferActivate == null)
				return;
			var hashCallbacks:Array;
			if (respond.savedRequestData.callID in callbacksOfferActivate == true)
				hashCallbacks = callbacksOfferActivate[respond.savedRequestData.callID];
			if (hashCallbacks == null || hashCallbacks.length == 0) {
				delete callbacksOfferActivate[respond.savedRequestData.callID];
				respond.dispose();
				return;
			}
			var res:Object = checkForError(respond);
			while (hashCallbacks.length != 0)
				hashCallbacks.shift()(res, respond.savedRequestData.callID);
			hashCallbacks = null;
			delete callbacksOfferActivate[respond.savedRequestData.callID];
		}
		
		static public function deactivateCryptoOffer(callback:Function, offerID:String):void {
			if (preCall() == false)
				return;
			if (callbacksOfferDeactivate == null || offerID in callbacksOfferDeactivate == false) {
				callbacksOfferDeactivate ||= {};
				callbacksOfferDeactivate[offerID] = [callback];
			} else {
				if (callbacksOfferDeactivate[offerID].indexOf(callback) == -1)
					callbacksOfferDeactivate[offerID].push(callback);
				return;
			}
			PayServer.call_cryptoOfferDeactivate(onCryptoOfferDeactivated, offerID, offerID);
		}
		
		static private function onCryptoOfferDeactivated(respond:PayRespond):void {
			if (callbacksOfferDeactivate == null)
				return;
			var hashCallbacks:Array;
			if (respond.savedRequestData.callID in callbacksOfferDeactivate == true)
				hashCallbacks = callbacksOfferDeactivate[respond.savedRequestData.callID];
			if (hashCallbacks == null || hashCallbacks.length == 0) {
				delete callbacksOfferDeactivate[respond.savedRequestData.callID];
				respond.dispose();
				return;
			}
			var res:Object = checkForError(respond);
			while (hashCallbacks.length != 0)
				hashCallbacks.shift()(res, respond.savedRequestData.callID);
			hashCallbacks = null;
			delete callbacksOfferDeactivate[respond.savedRequestData.callID];
		}
		
		static public function deleteCryptoOffer(callback:Function, offerID:String):void {
			if (preCall() == false)
				return;
			if (callbacksOfferDelete == null || offerID in callbacksOfferDelete == false) {
				callbacksOfferDelete ||= {};
				callbacksOfferDelete[offerID] = [callback];
			} else {
				if (callbacksOfferDelete[offerID].indexOf(callback) == -1)
					callbacksOfferDelete[offerID].push(callback);
				return;
			}
			PayServer.call_cryptoOfferDelete(onCryptoOfferDeleted, offerID, offerID);
		}
		
		static private function onCryptoOfferDeleted(respond:PayRespond):void {
			if (callbacksOfferDelete == null)
				return;
			var hashCallbacks:Array;
			if (respond.savedRequestData.callID in callbacksOfferDelete == true)
				hashCallbacks = callbacksOfferDelete[respond.savedRequestData.callID];
			if (hashCallbacks == null || hashCallbacks.length == 0) {
				delete callbacksOfferDelete[respond.savedRequestData.callID];
				respond.dispose();
				return;
			}
			var res:Object = checkForError(respond);
			while (hashCallbacks.length != 0)
				hashCallbacks.shift()(res, respond.savedRequestData.callID);
			hashCallbacks = null;
			delete callbacksOfferDelete[respond.savedRequestData.callID];
		}
		
		static public function callCardRemove(callback:Function, cardID:String):void {
			if (preCall() == false)
				return;
			if (callbacksCardRemove == null || cardID in callbacksCardRemove == false) {
				callbacksCardRemove ||= {};
				callbacksCardRemove[cardID] = [callback];
			} else {
				if (callbacksCardRemove[cardID].indexOf(callback) == -1)
					callbacksCardRemove[cardID].push(callback);
				return;
			}
			PayServer.call_deleteMoneyCards(onCardRemoved, cardID, cardID);
		}
		
		static private function onCardRemoved(respond:PayRespond):void {
			if (callbacksCardRemove == null)
				return;
			var hashCallbacks:Array;
			if (respond.savedRequestData.callID in callbacksCardRemove == true)
				hashCallbacks = callbacksCardRemove[respond.savedRequestData.callID];
			if (hashCallbacks == null || hashCallbacks.length == 0) {
				delete callbacksCardRemove[respond.savedRequestData.callID];
				respond.dispose();
				return;
			}
			var res:Object = checkForError(respond);
			while (hashCallbacks.length != 0)
				hashCallbacks.shift()(res, respond.savedRequestData.callID);
			hashCallbacks = null;
			delete callbacksCardRemove[respond.savedRequestData.callID];
		}
		
		static public function callPasswordCheck(callback:Function, pwd:String):String {
			if (preCall() == false)
				return null;
			var hash:String = MD5.hash(pwd);
			if (callbacksPasswordCheck == null || hash in callbacksPasswordCheck == false) {
				callbacksPasswordCheck ||= {};
				callbacksPasswordCheck[hash] = [callback];
			} else {
				if (callbacksPasswordCheck[hash].indexOf(callback) == -1)
					callbacksPasswordCheck[hash].push(callback);
				return hash;
			}
			PayServer.call_passCheck(onPasswordChecked, pwd, hash);
			return hash;
		}
		
		static private function onPasswordChecked(respond:PayRespond):void {
			if (respond.error == false) {
				PayAPIManager.S_LOGIN_SUCCESS.invoke(respond.savedRequestData);
			}
			
			if (callbacksPasswordCheck == null)
				return;
			var hashCallbacks:Array;
			if (respond.savedRequestData.callID in callbacksPasswordCheck == true)
				hashCallbacks = callbacksPasswordCheck[respond.savedRequestData.callID];
			if (hashCallbacks == null || hashCallbacks.length == 0) {
				delete callbacksPasswordCheck[respond.savedRequestData.callID];
				respond.dispose();
				return;
			}
			var res:Object = checkForError(respond);
			while (hashCallbacks.length != 0)
				hashCallbacks.shift()(res);
			hashCallbacks = null;
			delete callbacksPasswordCheck[respond.savedRequestData.callID];
		}
		
		static public function callPasswordChange(callback:Function, pwd:String, pwdNew:String):String {
			if (preCall() == false)
				return null;
			var hash:String = MD5.hash(pwd);
			if (callbacksPasswordChange == null || hash in callbacksPasswordChange == false) {
				callbacksPasswordChange ||= {};
				callbacksPasswordChange[hash] = [callback];
			} else {
				if (callbacksPasswordChange[hash].indexOf(callback) == -1)
					callbacksPasswordChange[hash].push(callback);
				return hash;
			}
			PayServer.call_passChange(callPasswordChanged, pwd, pwdNew, hash);
			return hash;
		}
		
		static private function callPasswordChanged(respond:PayRespond):void {
			if (callbacksPasswordChange == null)
				return;
			var hashCallbacks:Array;
			if (respond.savedRequestData.callID in callbacksPasswordChange == true)
				hashCallbacks = callbacksPasswordChange[respond.savedRequestData.callID];
			if (hashCallbacks == null || hashCallbacks.length == 0) {
				delete callbacksPasswordChange[respond.savedRequestData.callID];
				respond.dispose();
				return;
			}
			var res:Object = checkForError(respond);
			var callback:Function;
			while (hashCallbacks.length != 0)
			{
				callback = hashCallbacks.shift();
				if (callback.length == 1)
				{
					callback(res);
				}
				else if(callback.length == 2)
				{
					callback(res, respond.savedRequestData);
				}
			}
			hashCallbacks = null;
			delete callbacksPasswordChange[respond.savedRequestData.callID];
		}
		
		static public function callWallets(callback:Function):void {
			if (preCall() == false)
				return;
			if (callbacksWallet == null || callbacksWallet.length == 0) {
				callbacksWallet = [callback];
			} else {
				if (callbacksWallet.indexOf(callback) == -1)
					callbacksWallet.push(callback);
				return;
			}
			PayServer.call_getAccount(onWalletsGetted);
		}
		
		static private function onWalletsGetted(respond:PayRespond):void {
			if (callbacksWallet == null)
				return;
			var res:Object = checkForError(respond);
			while (callbacksWallet.length != 0)
				callbacksWallet.shift()(res);
			callbacksWallet = null;
		}
		
		static public function changeMainCurrency(callback:Function, currency:String):void {
			if (preCall() == false)
				return;
			if (callbacksChangeMainCurrency == null || callbacksChangeMainCurrency.length == 0) {
				callbacksChangeMainCurrency = [callback];
			} else {
				if (callbacksChangeMainCurrency.indexOf(callback) == -1)
					callbacksChangeMainCurrency.push(callback);
				return;
			}
			PayServer.call_postSettings(onMainCurrencyChanged, { CONSOLIDATE_CURRENCY:currency }, "");
		}
		
		static private function onMainCurrencyChanged(respond:PayRespond):void {
			if (callbacksChangeMainCurrency == null)
				return;
			var res:Object = checkForError(respond);
			while (callbacksChangeMainCurrency.length != 0)
				callbacksChangeMainCurrency.shift()(res);
			callbacksChangeMainCurrency = null;
		}
		
		static public function callCrypto(callback:Function):void {
			if (preCall() == false)
				return;
			if (callbacksCrypto == null || callbacksCrypto.length == 0) {
				callbacksCrypto = [callback];
			} else {
				if (callbacksCrypto.indexOf(callback) == -1)
					callbacksCrypto.push(callback);
				return;
			}
			PayServer.call_getCrypto(onCryptoGetted);
		}
		
		static private function onCryptoGetted(respond:PayRespond):void {
			if (callbacksCrypto == null)
				return;
			var res:Object = checkForError(respond);
			while (callbacksCrypto.length != 0)
				callbacksCrypto.shift()(res);
			callbacksCrypto = null;
		}
		
		static public function callCryptoRDs(callback:Function):void {
			if (preCall() == false)
				return;
			if (callbacksCryptoRDs == null || callbacksCryptoRDs.length == 0) {
				callbacksCryptoRDs = [callback];
			} else {
				if (callbacksCryptoRDs.indexOf(callback) == -1)
					callbacksCryptoRDs.push(callback);
				return;
			}
			PayServer.call_getCryptoRDs(onCryptoRDsGetted);
		}
		
		static private function onCryptoRDsGetted(respond:PayRespond):void {
			if (callbacksCryptoRDs == null)
				return;
			var res:Object = checkForError(respond);
			while (callbacksCryptoRDs.length != 0)
				callbacksCryptoRDs.shift()(res);
			callbacksCryptoRDs = null;
		}
		
		static public function getDeclareETHAddressLink(callback:Function, currency:String):void {
			if (preCall() == false)
				return;
			if (callbacksDeclareETHAddress == null || callbacksDeclareETHAddress.length == 0) {
				callbacksDeclareETHAddress = [callback];
			} else {
				if (callbacksDeclareETHAddress.indexOf(callback) == -1)
					callbacksDeclareETHAddress.push(callback);
				return;
			}
			PayServer.call_getDeclareEthAddressLink(onDeclareETHAddressLinkGetted, currency);
		}
		
		static private function onDeclareETHAddressLinkGetted(respond:PayRespond):void {
			if (callbacksDeclareETHAddress == null)
				return;
			var res:Object = checkForError(respond);
			while (callbacksDeclareETHAddress.length != 0)
				callbacksDeclareETHAddress.shift()(res);
			callbacksDeclareETHAddress = null;
		}
		
		static public function getTPILink(callback:Function, amount:Number, currency:String, message:String):String {
			if (preCall() == false)
				return null;
			var hash:String = MD5.hash(amount + currency + message);
			if (callbacksGetTPILink == null || callbacksGetTPILink.length == 0) {
				callbacksGetTPILink = [callback];
			} else {
				if (callbacksGetTPILink.indexOf(callback) == -1)
					callbacksGetTPILink.push(callback);
				return hash;
			}
			var data:Object = {
				type: "CC",
				amount: amount,
				currency: currency,
				description: message,
				to: "+" + Auth.phone
			};
			PayServer.call_putDepositThirdParty(onTPILinkGetted, data, hash);
			return hash
		}
		
		static private function onTPILinkGetted(respond:PayRespond):void {
			if (callbacksGetTPILink == null)
				return;
			var res:Object = checkForError(respond);
			if (respond.savedRequestData != null && "data" in respond.savedRequestData && respond.savedRequestData.data != null)
			{
				var requestParams:Object = respond.savedRequestData.data;
				if ("amount" in requestParams)
				{
					res.amount = requestParams.amount;
				}
				if ("currency" in requestParams)
				{
					res.currency = requestParams.currency;
				}
			}
			while (callbacksGetTPILink.length != 0)
				callbacksGetTPILink.shift()(res, respond.savedRequestData.callID);
			callbacksGetTPILink = null;
		}
		
		static public function callTotal(callback:Function):void {
			if (preCall() == false)
				return;
			if (callbacksTotal == null || callbacksTotal.length == 0) {
				callbacksTotal = [callback];
			} else {
				if (callbacksTotal.indexOf(callback) == -1)
					callbacksTotal.push(callback);
				return;
			}
			PayServer.call_getAIC(onTotalGetted);
		}
		
		static private function onTotalGetted(respond:PayRespond):void {
			if (callbacksTotal == null)
				return;
			var res:Object = checkForError(respond);
			while (callbacksTotal.length != 0)
				callbacksTotal.shift()(res);
			callbacksTotal = null;
		}
		
		static public function callHome(callback:Function, withCards:Boolean = false):void {
			if (preCall() == false)
				return;
			if (callbacksHome == null || callbacksHome.length == 0) {
				callbacksHome = [callback];
			} else {
				if (callbacksHome.indexOf(callback) == -1)
					callbacksHome.push(callback);
				return;
			}
			PayServer.call_getHome(onHomeGetted, withCards);
		}
		
		static private function onHomeGetted(respond:PayRespond):void {
			if (callbacksHome == null)
				return;
			var res:Object = checkForError(respond);
			if (respond.savedRequestData.data.with_cards == true)
				res.fullRequest = true;
			while (callbacksHome.length != 0)
				callbacksHome.shift()(res);
			callbacksHome = null;
		}
		
		static public function callInvestments(callback:Function):void {
			if (preCall() == false)
				return;
			if (callbacksInvestments == null || callbacksInvestments.length == 0) {
				callbacksInvestments = [callback];
			} else {
				if (callbacksInvestments.indexOf(callback) == -1)
					callbacksInvestments.push(callback);
				return;
			}
			PayServer.call_getInvestment(onInvestmentsGetted);
		}
		
		static private function onInvestmentsGetted(respond:PayRespond):void {
			if (callbacksInvestments == null)
				return;
			var res:Object = checkForError(respond);
			while (callbacksInvestments.length != 0)
				callbacksInvestments.shift()(res);
			callbacksInvestments = null;
		}
		
		static public function callInvestmentDetails(callback:Function, instrument:String=""):void {
			if (preCall() == false)
				return;
			if (callbacksInvestmentDetails == null || callbacksInvestmentDetails.length == 0) {
				callbacksInvestmentDetails = [callback];
			} else {
				if (callbacksInvestmentDetails.indexOf(callback) == -1)
					callbacksInvestmentDetails.push(callback);
				return;
			}
			PayServer.call_getInvestmentDetails(onInvestmentsDetailsGetted,instrument);
		}
		
		static private function onInvestmentsDetailsGetted(respond:PayRespond):void {
			if (callbacksInvestmentDetails == null)
				return;
			var res:Object = checkForError(respond);
			while (callbacksInvestmentDetails.length != 0)
				callbacksInvestmentDetails.shift()(res);
			callbacksInvestmentDetails = null;
		}
		
		static public function callInvestmentHistory(callback:Function, number:String):void {
			if (preCall() == false)
				return;
			if (callbacksInvestmentsH == null || callbacksInvestmentsH.length == 0) {
				callbacksInvestmentsH = [callback];
			} else {
				if (callbacksInvestmentsH.indexOf(callback) == -1)
					callbacksInvestmentsH.push(callback);
				return;
			}
			PayServer.call_getInvestmentTrades(onInvestmentHistoryGetted, number, 1, number);
		}
		
		static private function onInvestmentHistoryGetted(respond:PayRespond):void {
			if (callbacksInvestmentsH == null)
				return;
			var res:Object = checkForError(respond);
			while (callbacksInvestmentsH.length != 0)
				callbacksInvestmentsH.shift()(res, respond.savedRequestData.callID);
			callbacksInvestmentsH = null;
		}
		
		static public function callCards(callback:Function):void {
			if (preCall() == false)
				return;
			if (callbacksCards == null || callbacksCards.length == 0) {
				callbacksCards = [callback];
			} else {
				if (callbacksCards.indexOf(callback) == -1)
					callbacksCards.push(callback);
				return;
			}
			PayServer.call_getCards(onCardsGetted);
		}
		
		static private function onCardsGetted(respond:PayRespond):void {
			if (callbacksCards == null)
				return;
			var res:Object = checkForError(respond);
			while (callbacksCards.length != 0)
				callbacksCards.shift()(res);
			callbacksCards = null;
		}
		
		static public function callLinkedCards(callback:Function):void {
			if (preCall() == false)
				return;
			if (callbacksLinkedCards == null || callbacksLinkedCards.length == 0) {
				callbacksLinkedCards = [callback];
			} else {
				if (callbacksLinkedCards.indexOf(callback) == -1)
					callbacksLinkedCards.push(callback);
				return;
			}
			PayServer.call_getMoneyCards(onLinkedCardsGetted);
		}
		
		static private function onLinkedCardsGetted(respond:PayRespond):void {
			if (callbacksLinkedCards == null)
				return;
			var res:Object = checkForError(respond);
			while (callbacksLinkedCards.length != 0)
				callbacksLinkedCards.shift()(res);
			callbacksLinkedCards = null;
		}
		
		static public function callCardHistory(callback:Function, number:String):void {
			if (preCall() == false)
				return;
			if (callbacksCardHistory == null || number in callbacksCardHistory == false) {
				callbacksCardHistory ||= {};
				callbacksCardHistory[number] = [callback];
			} else {
				if (callbacksCardHistory[number].indexOf(callback) == -1)
					callbacksCardHistory[number].push(callback);
				return;
			}
			var data:Object = {
				type:"All",
				load:"history"
			};
			PayServer.call_getCardInfo(onCardInfoGetted, number, data, number);
		}
		
		static private function onCardInfoGetted(respond:PayRespond):void {
			if (callbacksCardHistory == null)
				return;
			var hashCallbacks:Array;
			if (respond.savedRequestData.callID in callbacksCardHistory == true)
				hashCallbacks = callbacksCardHistory[respond.savedRequestData.callID];
			if (hashCallbacks == null || hashCallbacks.length == 0) {
				delete callbacksCardHistory[respond.savedRequestData.callID];
				respond.dispose();
				return;
			}
			var res:Object = checkForError(respond);
			while (hashCallbacks.length != 0)
				hashCallbacks.shift()(res, respond.savedRequestData.callID);
			hashCallbacks = null;
			delete callbacksCardHistory[respond.savedRequestData.callID];
			respond.dispose();
		}
		
		/*static public function callLogin(onLoggedIn:Function):void {
			PayServer.call_loginWithToken(onLoggedIn, Crypter.crypt(Auth.key, MD5.hash("someMd5key")), null);
		}*/
		
		static public function callLinkCardURL(callback:Function):void {
			PayServer.call_putMoneyCards(
				function(respond:PayRespond):void {
					var res:Object = checkForError(respond);
					if (callback != null)
						callback(res);
				}
			);
		}
		
		static public function requestCardPin(callback:Function, cardID:String):void {
			PayServer.call_sendPinForCard(
				function(respond:PayRespond):void {
					var res:Object = checkForError(respond);
					if (callback != null)
						callback(res);
				},
				cardID
			);
		}
		
		static private function onPinCodeRequested(respond:PayRespond):void {
			if (callbacksFatCatz == null)
				return;
			var res:Object = checkForError(respond);
			while (callbacksFatCatz.length != 0)
				callbacksFatCatz.shift()(res);
			respond.dispose();
		}
		
		static public function fatCatz(callback:Function):void {
			if (preCall() == false)
				return;
			if (callbacksFatCatz == null)
				callbacksFatCatz = [];
			if (callbacksFatCatz.indexOf(callback) != -1)
				return;
			callbacksFatCatz.push(callback);
			PayServer.call_getFatCatz(onFatCatz);
		}
		
		static private function onFatCatz(respond:PayRespond):void {
			if (callbacksFatCatz == null)
				return;
			var res:Object = checkForError(respond);
			while (callbacksFatCatz.length != 0)
				callbacksFatCatz.shift()(res);
			respond.dispose();
		}
		
		static public function transactionCode(callback:Function, trID:String, code:String):String {
			if (preCall() == false)
				return null;
			var hash:String = MD5.hash(trID + code);
			if (callbacksTrCode == null || hash in callbacksTrCode == false) {
				callbacksTrCode ||= {};
				callbacksTrCode[hash] = [callback];
			} else {
				if (callbacksTrCode[hash].indexOf(callback) == -1)
					callbacksTrCode[hash].push(callback);
				return hash;
			}
			PayServer.call_getMoneySpecific(onTransactionCode, trID, code, hash);
			return hash;
		}
		
		static public function callCardStatement(cardNumber:String, from:String, to:String, timezone:String = null):void {
			PayServer.cardStatement(cardNumber, from, to, timezone);
		}
		
		static public function callWalletStatement(accountNumber:String, from:String, to:String, timezone:String = null):void {
			PayServer.walletStatement(accountNumber, from, to, timezone);
		}
		
		static private function onTransactionCode(respond:PayRespond):void {
			if (callbacksTrCode == null)
				return;
			var hashCallbacks:Array;
			if (respond.savedRequestData.callID in callbacksTrCode == true)
				hashCallbacks = callbacksTrCode[respond.savedRequestData.callID];
			if (hashCallbacks == null || hashCallbacks.length == 0) {
				delete callbacksTrCode[respond.savedRequestData.callID];
				respond.dispose();
				return;
			}
			var res:Object = checkForError(respond);
			while (hashCallbacks.length != 0)
				hashCallbacks.shift()(res, respond.savedRequestData.callID);
			hashCallbacks = null;
			delete callbacksTrCode[respond.savedRequestData.callID];
		}
		
		static public function filterEmptyWallets(accounts:Array):Array 
		{
			var result:Array = new Array();
			
			if (accounts != null)
			{
				for (var i:int = 0; i < accounts.length; i++) 
				{
					if ("BALANCE" in accounts[i] && accounts[i].BALANCE > 0)
					{
						result.push(accounts[i]);
					}
				}
			}
			
			return result;
		}
	}
}