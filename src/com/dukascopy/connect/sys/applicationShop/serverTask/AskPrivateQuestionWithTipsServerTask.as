package com.dukascopy.connect.sys.applicationShop.serverTask {
	
	import com.dukascopy.connect.data.location.Location;
	import com.dukascopy.connect.data.screenAction.BaseAction;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.applicationShop.serverTask.ShopServerTask;
	import com.dukascopy.connect.sys.crypter.Crypter;
	import com.dukascopy.connect.sys.errors.ErrorLocalizer;
	import com.dukascopy.connect.sys.payments.PaymentsManager;
	import com.dukascopy.connect.sys.payments.advancedPayments.vo.PayTaskVO;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.sys.questionsManager.QuestionsManager;
	import com.dukascopy.langs.Lang;
	
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	
	public class AskPrivateQuestionWithTipsServerTask extends BaseAction implements IServerTask {
		
		private var currentPayTask:PayTaskVO;
		private var payId:String;
		private var transactionId:String;
		private var state:String;
		
		private var tipsAmount:Number;
		private var tipsCurrency:String;
		private var text:String;
		private var questionReserveId:String;
		private var payWallet:String;
		private var incognito:Boolean;
		private var type:String;
		private var geo:Location;
		
		public function AskPrivateQuestionWithTipsServerTask(tipsAmount:Number, tipsCurrency:String, text:String, payWallet:String, incognito:Boolean, type:String, geo:Location) {
			this.geo = geo;
			this.tipsAmount = tipsAmount;
			this.type = type;
			this.incognito = incognito;
			this.tipsCurrency = tipsCurrency;
			this.text = text;
			this.payWallet = payWallet;
			
			state = ShopServerTask.TASK_STATUS_NEW;
		}
		
		public function getStatus():String {
			return state;
		}
		
		public function execute():void {
			if (!isNaN(tipsAmount) && text != null && text.length > 0 && tipsCurrency != null) {
				PHP.question_reserve_tips(onTipsReserveResult, tipsAmount, tipsCurrency, type);
			}
			else {
				S_ACTION_FAIL.invoke("error");
				ApplicationErrors.add("data not set");
				dispose();
			}
		}
		
		private function onTipsReserveResult(phpRespond:PHPRespond):void {
			if (phpRespond.error == true) {
				S_ACTION_FAIL.invoke(phpRespond.errorMsg);
				dispose();
				return;
			} else if("data" in phpRespond && phpRespond.data != null) {
				questionReserveId = phpRespond.data as String;
				transferTips();
				phpRespond.dispose();
			} else {
				S_ACTION_FAIL.invoke(Lang.serverError);
				ApplicationErrors.add("bad server data");
				dispose();
			}
			phpRespond.dispose();
		}
		
		private function transferTips():void {
			currentPayTask = new PayTaskVO(PayTaskVO.TASK_TYPE_RESERVE_TIPS);
			currentPayTask.handleInCustomScreenName = "CreateQuestion";
			currentPayTask.amount = tipsAmount;
			currentPayTask.currency = tipsCurrency;
			currentPayTask.to_uid = questionReserveId.toString();
			currentPayTask.from_wallet = payWallet;
			
			var requestPayData:Object = currentPayTask.generateRequestObject();
			requestPayData.message = Lang.paidQuestionAward;
			requestPayData.description = "Reserve tips, q=" + questionReserveId.toString();
			
			PaymentsManager.S_ERROR.add(onError);
			PaymentsManager.S_COMPLETE.add(onComplete);
			PaymentsManager.S_BACK.add(onError);
			payId = new Date().time + "_tips";
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
			if (geo != null) {
				PHP.question_create(
					onQuestionCreated,
					Crypter.crypt(text, QuestionsManager.MESSAGE_KEY),
					tipsAmount,
					tipsCurrency,
					QuestionsManager.createCategoriesString(),
					incognito,
					type,
					geo.latitude,
					geo.longitude,
					questionReserveId
				);
				return;
			}
			PHP.question_create(
				onQuestionCreated,
				Crypter.crypt(text, QuestionsManager.MESSAGE_KEY),
				tipsAmount,
				tipsCurrency,
				QuestionsManager.createCategoriesString(),
				incognito,
				type,
				NaN,
				NaN,
				questionReserveId
			);
		}
		
		private function onQuestionCreated(respond:PHPRespond):void {
			if (respond.error == true) {
				var message:String = respond.errorMsg;
				S_ACTION_FAIL.invoke(message);
			} else if ("data" in respond) {
				if (respond.data == null)
					S_ACTION_FAIL.invoke(Lang.serverError + " " + Lang.emptyData);
				else if(respond.data == false)
					S_ACTION_FAIL.invoke(Lang.serverError + " " + Lang.emptyData);
				else
					S_ACTION_SUCCESS.invoke(respond.data);
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
		}
	}
}