package com.dukascopy.connect.sys.applicationShop.serverTask {
	
	import com.dukascopy.connect.data.paidChat.PaidChatData;
	import com.dukascopy.connect.data.screenAction.BaseAction;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.applicationShop.product.ShopProduct;
	import com.dukascopy.connect.sys.applicationShop.serverTask.ShopServerTask;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.errors.ErrorLocalizer;
	import com.dukascopy.connect.sys.payments.PaymentsManager;
	import com.dukascopy.connect.sys.payments.advancedPayments.vo.PayTaskVO;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.langs.Lang;
	
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	
	public class TransferMoneyServerTask extends BaseAction implements IServerTask {
		
		private var currentPayTask:PayTaskVO;
		private var payId:String;
		private var transactionId:String;
		private var state:String;
		private var paidChatData:PaidChatData;
		private var payWallet:String;
		
		private var channelUID:String;
		static private var channelData:Object;
		
		public function TransferMoneyServerTask(paidChatData:PaidChatData, payWallet:String) {
			this.paidChatData = paidChatData;
			this.payWallet = payWallet;
			
			state = ShopServerTask.TASK_STATUS_NEW;
		}
		
		public function getStatus():String {
			return state;
		}
		
		public function execute():void {
			transferPay();
		}
		
		private function transferPay():void {
			currentPayTask = new PayTaskVO(PayTaskVO.TASK_TYPE_PAY_GIFT_BY_UID);
			currentPayTask.handleInCustomScreenName = "CreateGiftPopup";
			currentPayTask.amount = paidChatData.cost;
			currentPayTask.currency = paidChatData.currency;
			currentPayTask.from_wallet = payWallet;
			currentPayTask.to_uid = paidChatData.userUid;
			currentPayTask.from_uid = Auth.uid;
			
			var requestPayData:Object = currentPayTask.generateRequestObject();
			requestPayData.message = Lang.paidChat;
			requestPayData.description = "chatPayOn";
			
			PaymentsManager.activate();
			PaymentsManager.S_ERROR.add(onError);
			PaymentsManager.S_COMPLETE.add(onComplete);
			PaymentsManager.S_BACK.add(onError);
			payId = new Date().time + "_chat";
			PaymentsManager.startTask(currentPayTask, payId);
		}
		
		private function onError(errorCode:String = null, errorMessage:String = null):void {
			S_ACTION_FAIL.invoke(ErrorLocalizer.getPaymentsError(errorCode, errorMessage));
			dispose();
		}
		
		private function onComplete(data:Object, callID:String):void {
			if (payId != callID)
				return;
			if (data != null &&
				data is Array && 
				data.length > 1 &&
				data[1] != null &&
				(data[1] == "COMPLETED" || data[1] == "PENDING"))
					transactionId = (data as Array)[0];
			onRequestComplete();
		}
		
		private function onRequestComplete():void {
			if (transactionId != null) {
				onPaidSuccess(transactionId);
			}
			else {
				S_ACTION_FAIL.invoke(Lang.serverError);
				dispose();
			}
		}
		
		private function onPaidSuccess(transactionId:String):void {
			state = ShopServerTask.TASK_STATUS_PAID;
			S_ACTION_SUCCESS.invoke(transactionId);
		}
		
		override public function dispose():void {
			super.dispose();
			currentPayTask = null;
			payId = null;
			
			PaymentsManager.S_ERROR.remove(onError);
			PaymentsManager.S_COMPLETE.remove(onComplete);
			PaymentsManager.S_BACK.remove(onError);
			PaymentsManager.deactivate();
		}
	}
}