package com.dukascopy.connect.sys.applicationShop.serverTask {
	
	import com.dukascopy.connect.data.screenAction.BaseAction;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.applicationShop.product.ShopProduct;
	import com.dukascopy.connect.sys.applicationShop.serverTask.ShopServerTask;
	import com.dukascopy.connect.sys.errors.ErrorLocalizer;
	import com.dukascopy.connect.sys.payments.PaymentsManager;
	import com.dukascopy.connect.sys.payments.advancedPayments.vo.PayTaskVO;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.sys.usersManager.extensions.Extension;
	import com.dukascopy.langs.Lang;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class BuyFlowerServerTask extends BaseAction implements IServerTask {
		
		private var state:String;
		private var product:ShopProduct;
		private var payWallet:String;
		private var payId:String;
		private var currentPayTask:PayTaskVO;
		private var transactionId:String;
		private var extension:Extension;
		private var requestCode:String;
		
		public function BuyFlowerServerTask(product:ShopProduct, payWallet:String) {
			this.product = product;
			this.payWallet = payWallet;
			
			state = ShopServerTask.TASK_STATUS_NEW;
		}
		
		public function getStatus():String {
			return state;
		}
		
		public function execute():void {
			
			extension = product.targetData as Extension;
			PHP.gift_setItem(onRequestResponse, product.userUID, extension.getProductId(), product.duration.getDays(), extension.reason, extension.incognito, extension.info);
		}
		
		private function onRequestResponse(respond:PHPRespond):void {
			if (respond.error == true) {
				var message:String = ErrorLocalizer.getText(respond.errorMsg);
				S_ACTION_FAIL.invoke(message);
			}
			else if ("data" in respond && respond.data != null) {
				requestCode = respond.data.payHash as String;
				pay();
			}
			else {
				S_ACTION_FAIL.invoke(Lang.serverError);
				ApplicationErrors.add("bad server data");
			}
			
			respond.dispose();
		}
		
		private function pay():void 
		{
			currentPayTask = new PayTaskVO(PayTaskVO.TASK_TYPE_PAY_MERCH);
			currentPayTask.handleInCustomScreenName = "PutUserExtension";
			currentPayTask.amount = product.cost.value;
			currentPayTask.currency = product.cost.currency;
			currentPayTask.messageText = "Flower gift";
			currentPayTask.from_wallet = payWallet;
			
			var requestPayData:Object = currentPayTask.generateRequestObject();
			requestPayData.code = "gift";
			requestPayData.order_details = "giftSet." + extension.getProductId() + "." + requestCode;
			requestPayData.description = "Flower gift";
			
			PaymentsManager.S_ERROR.add(onError);
			PaymentsManager.S_COMPLETE.add(onComplete);
			PaymentsManager.S_BACK.add(onError);
			payId = "gift_" + requestCode;
			PaymentsManager.startTask(currentPayTask, payId);
		}
		
		private function onError(errorCode:String = null, errorMessage:String = null):void {
			S_ACTION_FAIL.invoke(ErrorLocalizer.getPaymentsError(errorCode, errorMessage));
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
			if (transactionId == null)
			{
				S_ACTION_FAIL.invoke(Lang.serverError);
			}
			else
			{
				S_ACTION_SUCCESS.invoke();
			}
		}
		
		override public function dispose():void {
			super.dispose();
			
			extension = null;
			payId = null;
			currentPayTask = null;
			
			PaymentsManager.S_ERROR.remove(onError);
			PaymentsManager.S_COMPLETE.remove(onComplete);
			PaymentsManager.S_BACK.remove(onError);
		}
	}
}