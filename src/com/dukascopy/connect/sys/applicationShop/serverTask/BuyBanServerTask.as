package com.dukascopy.connect.sys.applicationShop.serverTask
{
	import com.dukascopy.connect.data.paidBan.PaidBanReasons;
	import com.dukascopy.connect.data.paidBan.dataParser.PaidBanParser;
	import com.dukascopy.connect.sys.applicationShop.serverTask.ShopServerTask;
	import com.dukascopy.connect.data.screenAction.BaseAction;
	import com.dukascopy.connect.data.screenAction.IAction;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.errors.ErrorLocalizer;
	import com.dukascopy.connect.sys.payments.InvoiceManager;
	import com.dukascopy.connect.sys.payments.PayRespond;
	import com.dukascopy.connect.sys.payments.PayRespond;
	import com.dukascopy.connect.sys.payments.advancedPayments.vo.PayTaskVO;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.sys.usersManager.paidBan.PaidBan;
	import com.dukascopy.connect.vo.users.adds.UserBan911VO;
	import com.dukascopy.langs.Lang;
	
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	public class BuyBanServerTask extends BaseAction implements IServerTask
	{
		private var requestData:UserBan911VO;
		private var banData:UserBan911VO;
		private var currentPayTask:PayTaskVO;
		private var payId:String;
		private var payWallet:String;
		private var transactionId:String;
		private var state:String;
		
		public function BuyBanServerTask(requestData:UserBan911VO, payWallet:String) {
			this.requestData = requestData;
			this.payWallet = payWallet;
			state = ShopServerTask.TASK_STATUS_NEW;
		}
		
		public function getStatus():String {
			return state;
		}
		
		public function execute():void {
			if (requestData != null) {
				var reasonData:Object = new Object();
				reasonData.id = requestData.reason;
				reasonData.text = PaidBanReasons.getReason(requestData.reason);
				PHP.requestPaidUserBan(onRequestBanResponse, requestData.user_uid, requestData.days, JSON.stringify(reasonData), requestData.incognito);
			}
			else {
				S_ACTION_FAIL.invoke("error");
				ApplicationErrors.add("data not set");
			}
		}
		
		private function onRequestBanResponse(respond:PHPRespond):void {
			if (respond.error == true) {
				var message:String = ErrorLocalizer.getText(respond.errorMsg);
				S_ACTION_FAIL.invoke(message);
			}
			else if ("data" in respond && respond.data != null) {
				var paidBanParser:PaidBanParser = new PaidBanParser();
				banData = paidBanParser.parse(respond.data);
				paidBanParser = null;
				if(banData.payHash != null) {
					payForBan();
				}
				else {
					S_ACTION_FAIL.invoke(Lang.serverError);
					ApplicationErrors.add("bad server data, no hash");
				}
				
			}
			else {
				S_ACTION_FAIL.invoke(Lang.serverError);
				ApplicationErrors.add("bad server data");
			}
			
			respond.dispose();
		}
		
		private function payForBan():void {
			InvoiceManager.isProcessingInvoice = true;
			InvoiceManager.S_STOP_PROCESS_INVOICE.add(onStopProcess);
			InvoiceManager.S_ERROR_PROCESS_INVOICE.add(onStopProcess);
			
			currentPayTask = new PayTaskVO(PayTaskVO.TASK_TYPE_PAY_MERCH);
			currentPayTask.handleInCustomScreenName = "PaidBanUserPopup";
			currentPayTask.amount = PaidBan.getBanCost(banData, ShopServerTask.BUY_BAN);
			currentPayTask.currency = PaidBan.getCurrency(ShopServerTask.BUY_BAN);
			currentPayTask.from_wallet = payWallet;
			
			var requestPayData:Object = currentPayTask.generateRequestObject();
			
			requestPayData.description = "Purchase 911 Ban, " + banData.days.toString() + " ";
			if (banData.days == 1) {
				requestPayData.description += "day";
			} else {
				requestPayData.description += "days";
			}
			
			var details:Object = {payHash:banData.payHash, id:banData.id, type:"set_ban"};
			requestPayData.order_details = JSON.stringify(details);
			
			InvoiceManager.S_TRANSFER_RESPOND.add(onTransferRespond);
			InvoiceManager.S_PAY_TASK_COMPLETED.add(onRequestComplete);
			
			payId = new Date().time + "_gift";
			InvoiceManager.processInvoice(currentPayTask);
			InvoiceManager.sendPaymentToPayServer(currentPayTask, payId);
		}
		
		private function onStopProcess():void {
			clearInvoice();
			S_ACTION_FAIL.invoke();
		}
		
		public function onTransferRespond(respond:PayRespond):void {
			// Handle Only our callID/ payID
			if (respond.savedRequestData != null && respond.savedRequestData.callID == payId){
				
				if (respond.hasAuthorizationError) {
					//S_ACTION_FAIL.invoke(Lang.textError + " " + respond.errorMsg);
				}
				else if (respond.error) {
					S_ACTION_FAIL.invoke(Lang.textError + " " + respond.errorMsg);
				}
				else {
					if ("data" in respond && respond.data != null && respond.data is Array && (respond.data as Array).length > 1 &&
						(respond.data as Array)[1] != null && ((respond.data as Array)[1] == "COMPLETED" || (respond.data as Array)[1] == "PENDING")) {
						transactionId = (respond.data as Array)[0];
					}
					else {
						S_ACTION_FAIL.invoke(Lang.somethingWentWrong);
						ApplicationErrors.add("bad server data");
					}
				}
			
			}
		}
		
		private function onRequestComplete(task:PayTaskVO):void {
			if (task == currentPayTask)	{
				if (transactionId != null) {
					onBanPaidSuccess(transactionId);
				}
				else {
					//!TODO:
				}
			}
		}
		
		private function onBanPaidSuccess(transactionId:String):void {
			state = ShopServerTask.TASK_STATUS_PAID;
			requestFinishBan(transactionId);
		}
		
		private function requestFinishBan(transactionId:String):void {	
			PHP.requestFinishUserBan(onRequestFinishBanResponse, banData.id, transactionId);
		}
		
		private function onRequestFinishBanResponse(respond:PHPRespond):void {
			if (respond.error == true) {
				var message:String = ErrorLocalizer.getText(respond.errorMsg);
				S_ACTION_FAIL.invoke(message);
			}
			else if ("data" in respond && respond.data != null && "status" in respond.data && respond.data.status != null) {
				if (respond.data.status == PaidBan.SERVER_STATUS_PAID) {
					var paidBanParser:PaidBanParser = new PaidBanParser();
					var banData:UserBan911VO = paidBanParser.parse(respond.data.info);
					paidBanParser = null;
					S_ACTION_SUCCESS.invoke(banData);
				} else {
					S_ACTION_FAIL.invoke(Lang.somethingWentWrong);
				}
			}
			else { 
				S_ACTION_FAIL.invoke(Lang.serverError);
				ApplicationErrors.add("bad server data");
			}
			
			respond.dispose();
		}
		
		/*
		 * &k=referral&s=1
		 * */
		
		override public function dispose():void {
			super.dispose();
			requestData = null;
			banData = null;
			currentPayTask = null;
			clearInvoice();
		}
		
		private function clearInvoice():void {
			InvoiceManager.isProcessingInvoice = false;
			InvoiceManager.S_STOP_PROCESS_INVOICE.remove(onStopProcess);
			InvoiceManager.S_ERROR_PROCESS_INVOICE.remove(onStopProcess);
			InvoiceManager.S_TRANSFER_RESPOND.remove(onTransferRespond);
			InvoiceManager.S_PAY_TASK_COMPLETED.remove(onRequestComplete);
			
			InvoiceManager.stopProcessInvoice();
		}
	}
}