package com.dukascopy.connect.sys.applicationShop.serverTask {
	
	import com.adobe.crypto.MD5;
	import com.dukascopy.connect.data.screenAction.BaseAction;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.applicationShop.serverTask.ShopServerTask;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.payments.PaymentsManager;
	import com.dukascopy.connect.sys.payments.advancedPayments.vo.PayTaskVO;
	import com.dukascopy.langs.Lang;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class BuyQuestionProductServerTask extends BaseAction implements IServerTask {
		
		private var state:String;
		private var qUID:String;
		private var payWallet:String;
		private var payId:String;
		private var currentPayTask:PayTaskVO;
		private var transactionId:String;
		
		public function BuyQuestionProductServerTask(qUID:String, payWallet:String) {
			this.qUID = qUID;
			this.payWallet = payWallet;
			
			state = ShopServerTask.TASK_STATUS_NEW;
		}
		
		public function getStatus():String {
			return state;
		}
		
		public function execute():void {
			if (qUID == null || qUID == "") {
				S_ACTION_FAIL.invoke("error");
				ApplicationErrors.add("qUID not set");
			}
			currentPayTask = new PayTaskVO(PayTaskVO.TASK_TYPE_PAY_MERCH);
			currentPayTask.handleInCustomScreenName = "PaidQuestionProlong";
			currentPayTask.amount = 1;
			currentPayTask.currency = "EUR";
			var temp:Object = currentPayTask.generateRequestObject();
			temp.description = "Prolong question: " + qUID;
			temp.order_details = "qProlong" + qUID;
			temp.code = MD5.hash(qUID + Auth.uid).substr(0, 8);
			currentPayTask.from_wallet = payWallet;
			
			payId = "qProlong_" + qUID;
			
			PaymentsManager.S_ERROR.add(onError);
			PaymentsManager.S_COMPLETE.add(onComplete);
			PaymentsManager.S_BACK.add(onError);
			PaymentsManager.startTask(currentPayTask, payId);
		}
		
		private function onError(code:int, msg:String):void {
			S_ACTION_FAIL.invoke(msg);
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
		
		private function onStopProcess():void {
			S_ACTION_FAIL.invoke();
		}
		
		private function onRequestComplete():void {
			if (transactionId == null) {
				S_ACTION_FAIL.invoke(Lang.serverError);
				return;
			}
			S_ACTION_SUCCESS.invoke(qUID);
		}
		
		override public function dispose():void {
			super.dispose();
			
			payId = null;
			currentPayTask = null;
			
			PaymentsManager.S_ERROR.remove(onError);
			PaymentsManager.S_COMPLETE.remove(onComplete);
			PaymentsManager.S_BACK.remove(onError);
		}
	}
}