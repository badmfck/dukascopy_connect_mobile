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
	import com.dukascopy.langs.Lang;
	
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	
	public class PaidChannelStartServerTask extends BaseAction implements IServerTask {
		
		private var currentPayTask:PayTaskVO;
		private var payId:String;
		private var transactionId:String;
		private var state:String;
		private var product:ShopProduct;
		private var payWallet:String;
		
		private var channelUID:String;
		static private var channelData:Object;
		
		public function PaidChannelStartServerTask(product:ShopProduct, payWallet:String) {
			this.product = product;
			this.payWallet = payWallet;
			
			state = ShopServerTask.TASK_STATUS_NEW;
		}
		
		public function getStatus():String {
			return state;
		}
		
		public function execute():void {
			
			var request:PaidChannelRequestData = product.targetData as PaidChannelRequestData;
			
			PHP.channelStart(onChannelCreated, request.title, request.mode, request.settingsValues);
		}
		
		private function onChannelCreated(phpRespond:PHPRespond):void {
			if (phpRespond.error) {
			//	ToastMessage.display(ErrorLocalizer.getText(phpRespond.errorMsg));
				phpRespond.dispose();
				S_ACTION_FAIL.invoke(phpRespond.errorMsg);
				return;
			}
			
			channelData = phpRespond.data;
			if (channelData != null && "uid" in channelData && channelData.uid != null)
			{
				transferPay();
			}
			else
			{
				S_ACTION_FAIL.invoke();
			}
			
			/*channels ||= [emptyChannelVO];
			var channel:ChatVO = getChannel(phpRespond.data.uid);
			if (channel == null) {
				channel = new ChatVO(phpRespond.data);
				channels.splice(1, 0, channel);
			}
			var chatScreenData:ChatScreenData = new ChatScreenData();
			chatScreenData.chatVO = channel;
			chatScreenData.type = ChatInitType.CHAT;
			chatScreenData.backScreen = RootScreen;
			MobileGui.showChatScreen(chatScreenData);
			ChannelsManager.S_CHANNELS.invoke();
			
			WSClient.call_blackHoleToGroup("public", "send", "mobile", WSMethodType.CHANNEL_CREATED, { cuid:channel.uid, senderUID:Auth.uid } );*/
			
			phpRespond.dispose();
		}
		
		private function transferPay():void {
			currentPayTask = new PayTaskVO(PayTaskVO.TASK_TYPE_PAY_MERCH);
			currentPayTask.handleInCustomScreenName = "CreateGiftPopup";
			currentPayTask.amount = product.cost.value
			currentPayTask.currency = product.cost.currency;
			currentPayTask.from_wallet = payWallet;
			
			var requestPayData:Object = currentPayTask.generateRequestObject();
			requestPayData.message = Lang.paidChannel;
			requestPayData.description = "ircPayOn" + channelData.uid;
			
			PaymentsManager.activate();
			PaymentsManager.S_ERROR.add(onError);
			PaymentsManager.S_COMPLETE.add(onComplete);
			PaymentsManager.S_BACK.add(onError);
			payId = new Date().time + "_channel";
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
			requestFinish(transactionId);
		}
		
		private function requestFinish(transactionId:String):void {
			//!TODO:;
			PHP.enableChannel(onChannelEnableResponse, channelData.uid, 4*7, 1);
		}
		
		private function onChannelEnableResponse(respond:PHPRespond):void {
			if (respond.error == true) {
				var message:String = respond.errorMsg;
				S_ACTION_FAIL.invoke(message);
			} else if ("data" in respond) {
				if (respond.data == null)
					S_ACTION_FAIL.invoke(Lang.serverError + " " + Lang.emptyData);
				else if(respond.data == false)
					S_ACTION_FAIL.invoke(Lang.serverError + " " + Lang.emptyData);
				else
					S_ACTION_SUCCESS.invoke(channelData);
			} else { 
				S_ACTION_FAIL.invoke(Lang.serverError);
				ApplicationErrors.add("bad server data");
			}
			respond.dispose();
			dispose();
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