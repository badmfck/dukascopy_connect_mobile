package com.dukascopy.connect.sys.applicationShop.serverTask {
	
	import com.dukascopy.connect.data.paidBan.dataParser.PaidBanParser;
	import com.dukascopy.connect.data.screenAction.BaseAction;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.applicationShop.serverTask.ShopServerTask;
	import com.dukascopy.connect.sys.errors.ErrorLocalizer;
	import com.dukascopy.connect.sys.payments.PaymentsManager;
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
	public class BuyBanProtectionServerTask extends BaseAction implements IServerTask {
		
		private var requestData:UserBan911VO;
		private var banData:UserBan911VO;
		private var payWallet:String;
		private var currentPayTask:PayTaskVO;
		private var payId:String;
		private var transactionId:String;
		private var state:String;
		private var completed:Boolean;
		private var waitingForAccountUpdate:Boolean;
		
		public function BuyBanProtectionServerTask(requestData:UserBan911VO, payWallet:String) {
			this.requestData = requestData;
			this.payWallet = payWallet;
			state = ShopServerTask.TASK_STATUS_NEW;
		}
		
		public function getStatus():String {
			return state;
		}
		
		public function execute():void {
			if (requestData != null) {
				PHP.requestBanProtection(onRequestSetProtectionResponse, requestData.user_uid, requestData.days);
			} else {
				S_ACTION_FAIL.invoke("error");
				ApplicationErrors.add("data not set");
			}
		}
		
		private function onRequestSetProtectionResponse(respond:PHPRespond):void {
			if (respond.error == true) {
				var message:String = ErrorLocalizer.getText(respond.errorMsg);
				S_ACTION_FAIL.invoke(message);
			}
			else if ("data" in respond && respond.data != null) {
				var parser:PaidBanParser = new PaidBanParser();
				banData = parser.parse(respond.data);
				payForProtection();
			}
			else {
				S_ACTION_FAIL.invoke(Lang.serverError);
				ApplicationErrors.add("bad server data");
			}
			
			respond.dispose();
		}
		
		private function payForProtection():void {
			currentPayTask = new PayTaskVO(PayTaskVO.TASK_TYPE_PAY_MERCH);
			currentPayTask.handleInCustomScreenName = "CreateGiftPopup";
			currentPayTask.amount = PaidBan.getBanCost(banData, ShopServerTask.BUY_PROTECTION);
			currentPayTask.currency = PaidBan.getCurrency(ShopServerTask.BUY_PROTECTION);
			currentPayTask.from_wallet = payWallet;
			var requestPayData:Object = currentPayTask.generateRequestObject();
			requestPayData.description = "Purchase 911 Protection, " + banData.days.toString() + " ";
			if (banData.days == 1) {
				requestPayData.description += "day";
			} else {
				requestPayData.description += "days";
			}
			var details:Object = {payHash:banData.payHash, id:banData.reqID, type:"bun_protection"};
			requestPayData.order_details = JSON.stringify(details);
			payId = new Date().time + "_gift";
			PaymentsManager.S_ERROR.add(onError);
			PaymentsManager.S_COMPLETE.add(onTransferRespond);
			PaymentsManager.startTask(currentPayTask, payId);
		}
		
		private function onError(val:String = ""):void {
			if (S_ACTION_FAIL == null || disposed == true)
			{
				PaymentsManager.S_ERROR.remove(onError);
				PaymentsManager.S_COMPLETE.remove(onTransferRespond);
				return;
			}
			S_ACTION_FAIL.invoke(Lang.textError + " " + val);
		}
		
		private function onStopProcess():void {
			clearInvoice();
			S_ACTION_FAIL.invoke();
		}
		
		public function onTransferRespond(respond:Object, callID:String):void {
			if (callID != payId)
				return;
			
			PaymentsManager.S_ERROR.remove(onError);
			PaymentsManager.S_COMPLETE.remove(onTransferRespond);
			
			if (respond != null && respond is Array && respond.length > 1) {
				if (respond[1] != null && (respond[1] == "COMPLETED" || respond[1] == "PENDING")) {
					transactionId = respond[0];
				}
			}
			onRequestComplete();
			waitingForAccountUpdate = true;
			PaymentsManager.S_ACCOUNT.add(onAccountUpdated);
		}
		
		private function onAccountUpdated():void {
			waitingForAccountUpdate = false;
			if (completed == true)
				S_ACTION_SUCCESS.invoke();
		}
		
		private function onRequestComplete():void {
			if (transactionId != null)
				onProtectionPaidSuccess(transactionId);
		}
		
		private function onProtectionPaidSuccess(transactionId:String):void {
			state = ShopServerTask.TASK_STATUS_PAID;
			requestFinishProtection(transactionId);
		}
		
		private function requestFinishProtection(transactionId:String):void {	
			PHP.requestFinishBanProtection(onRequestFinishProtectionResponse, banData.reqID, transactionId);
		}
		
		private function onRequestFinishProtectionResponse(respond:PHPRespond):void {
			if (respond.error == true) {
				var message:String = ErrorLocalizer.getText(respond.errorMsg);
				S_ACTION_FAIL.invoke(message);
			}
			else if ("data" in respond) {
				completed = true;
				if (waitingForAccountUpdate == false)
					S_ACTION_SUCCESS.invoke();
			}
			else { 
				S_ACTION_FAIL.invoke(Lang.serverError);
				ApplicationErrors.add("bad server data");
			}
			respond.dispose();
		}
		
		override public function dispose():void {
			super.dispose();
			
			PaymentsManager.S_ERROR.remove(onError);
			PaymentsManager.S_COMPLETE.remove(onTransferRespond);
			PaymentsManager.S_ACCOUNT.remove(onAccountUpdated);
			
			requestData = null;
			banData = null;
			currentPayTask = null;
			
			clearInvoice();
		}
		
		private function clearInvoice():void {
			PaymentsManager.S_COMPLETE.remove(onTransferRespond);
		}
	}
}