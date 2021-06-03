package com.dukascopy.connect.data.screenAction.customActions {
	import com.dukascopy.connect.data.coinMarketplace.TradingOrder;
	import com.dukascopy.connect.data.coinMarketplace.TradingOrderRequest;
	import com.dukascopy.connect.data.coinMarketplace.TradingResponse;
	import com.dukascopy.connect.data.screenAction.BaseAction;
	import com.dukascopy.connect.data.screenAction.IAction;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.bankManager.BankManager;
	import com.dukascopy.langs.Lang;
	import com.telefision.sys.signals.Signal;
	import flash.utils.setTimeout;


	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class TradeCoinsAction extends BaseAction implements IAction
	{
		private var request:TradingOrderRequest;
		private var resultSignal:Signal;
		private var requestFunction:Function;
		private var currentOrderIndex:int;
		private var currentQuantity:Number;
		private var response:TradingResponse;
		private var wasSuccess:Boolean;
		private var lastError:String;
		private var orderResult:Function;
		
		public function TradeCoinsAction(request:TradingOrderRequest, resultSignal:Signal, requestFunction:Function, orderResult:Function = null) {
			this.request = request;
			this.orderResult = orderResult;
			this.resultSignal = resultSignal;
			this.requestFunction = requestFunction;
		}
		
		public function execute():void {
			response = new TradingResponse();
			
			BankManager.S_ERROR.add(onError);
			BankManager.S_PAYMENT_ERROR.add(onPaymentError);
			
			if (resultSignal != null) {
				resultSignal.add(onResult);
			} else {
				ApplicationErrors.add();
			}
			if (requestFunction != null) {
				currentOrderIndex = -1;
				currentQuantity = 0;
				
				processNext();
			} else {
				ApplicationErrors.add();
			}
		}
		
		private function processNext():void {
			currentOrderIndex ++;
			
			if (currentQuantity < request.quantity && currentOrderIndex < request.orders.length) {
				var currentRequest:TradingOrderRequest = new TradingOrderRequest();
				currentRequest.orders = [request.orders[currentOrderIndex]];
				
				var quantity:Number;
				if ((request.orders[currentOrderIndex] as TradingOrder).fillOrKill) {
					quantity = (request.orders[currentOrderIndex] as TradingOrder).quantity;
					if (quantity > request.quantity - currentQuantity) {
						processNext();
						return;
					}
				}
				else
				{
					quantity = Math.min(request.quantity - currentQuantity, (request.orders[currentOrderIndex] as TradingOrder).quantity);
				}
				
				currentRequest.quantity = parseFloat(quantity.toFixed(4));
				
				var res:Boolean = requestFunction(currentRequest);
				if (res == false)
				{
					onError();
				}
			}
			else
			{
				onFinish();
			}
		}
		
		private function test():void 
		{
			var d:Object = new Object();
			d.credit_amount = 0.1;
			d.debit_amount = 0.5;
			d.credit_currency = "EUR";
			d.debit_currency = "DUK+";
			d.text = "ошибка 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0";
		//	setTimeout(onResult, 5000, d);
			setTimeout(onPaymentError, 3000, d);
		}
		
		private function onFinish():void 
		{
			if (wasSuccess == false)
			{
				S_ACTION_FAIL.invoke(lastError);
			}
			else
			{
				response.complete = true;
				response.wasSuccess = wasSuccess;
				
				S_ACTION_SUCCESS.invoke(response);
			}
			dispose();
		}
		
		private function onError(type:Object = null):void 
		{
			if (type != null && type == BankManager.PWP_NOT_ENTERED)
			{
				onCancel();
			}
			else
			{
				if (orderResult != null)
				{
					orderResult(false, currentOrderIndex);
				}
				
				processNext();
			}
			
			/*S_ACTION_FAIL.invoke();
			dispose();*/
		}
		
		private function onResult(rawData:Object):void 
		{
			if (orderResult != null)
			{
				orderResult(true, currentOrderIndex, null, rawData);
			}
			
			if ((request.orders[0] as TradingOrder).side == TradingOrder.SELL)
			{
				currentQuantity += parseFloat(rawData.credit_amount);
			}
			else
			{
				currentQuantity += parseFloat(rawData.debit_amount);
			}
			
			wasSuccess = true;
			
			response.credit_amount += parseFloat(rawData.credit_amount);
			response.credit_currency = rawData.credit_currency;
			response.debit_currency = rawData.debit_currency;
			response.debit_amount += parseFloat(rawData.debit_amount);
			
			if ((request.orders[currentOrderIndex] as TradingOrder).side == TradingOrder.BUY)
			{
			//	response.price += ((request.orders[currentOrderIndex] as TradingOrder).price)*parseFloat(rawData.credit_amount);
				response.price += ((request.orders[currentOrderIndex] as TradingOrder).price)*parseFloat(rawData.credit_amount);
			}
			else
			{
			//	response.price += ((request.orders[currentOrderIndex] as TradingOrder).price)*parseFloat(rawData.debit_amount);
				response.price += ((request.orders[currentOrderIndex] as TradingOrder).price)*parseFloat(rawData.debit_amount);
			}
			
			processNext();
		}
		
		private function onPaymentError(data:Object):void 
		{
			var text:String = Lang.otherError;
			if (data != null && "text" in data && data.text != null)
			{
				text = data.text;
			}
			lastError = text;
			
			if (orderResult != null)
			{
				orderResult(false, currentOrderIndex, text);
			}
			
			processNext();
			
			/*S_ACTION_FAIL.invoke(text);
			
			dispose();*/
		}
		
		override public function dispose():void
		{
			super.dispose();
			
			BankManager.S_ERROR.remove(onError);
		//	BankManager.S_ERROR_PWD_NOT_ENTERED.remove(onCancel);
			BankManager.S_PAYMENT_ERROR.remove(onPaymentError);
			
			request = null;
			requestFunction = null;
			orderResult = null;
			
			if (resultSignal != null)
			{
				resultSignal.remove(onResult);
			}
		}
		
		private function onCancel():void 
		{
			onFinish();
		}
	}
}