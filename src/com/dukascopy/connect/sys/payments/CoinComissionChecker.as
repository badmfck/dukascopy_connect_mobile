package com.dukascopy.connect.sys.payments 
{
	import com.dukascopy.connect.data.coinMarketplace.TradingOrder;
	import com.dukascopy.langs.Lang;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class CoinComissionChecker 
	{
		private var _lastCommissionCallID:String;
		private var callback:Function;
		private var orders:Array;
		private var currentIndex:int;
		private var commission:Number;
		private var commissionCurrency:String;
		private var isDisposed:Boolean;
		private var total:Number;
		private var lastCommissionData:Object;
		
		public function CoinComissionChecker(callback:Function) 
		{
			this.callback = callback;
		}
		
		public function execute(currentProposal:Array, total:Number):void 
		{
			if (currentProposal == null)
			{
				return;
			}
			this.total = total;
			
			stopCurrent();
			
			_lastCommissionCallID = new Date().getTime().toString() + "coinComission";
			
			/*if (PayManager.S_SELL_COINS_COMMISSION_RESPOND != null)
			{
				PayManager.S_SELL_COINS_COMMISSION_RESPOND.add(onCommissionRespond);
			}*/
			
			if (PayManager.S_SELL_COINS_BULK_COMMISSION_RESPOND != null)
			{
				PayManager.S_SELL_COINS_BULK_COMMISSION_RESPOND.add(onCommissionBulkRespond);
			}
			
			orders = new Array();
			var order:TradingOrder;
			for (var i:int = 0; i < currentProposal.length; i++) 
			{
				order = new TradingOrder();
				if (total > 0)
				{
					var newQuantity:Number = Math.min((currentProposal[i] as TradingOrder).quantity, total);
					order.quantity = newQuantity;
					total -= newQuantity;
					total = Number.round(total*10000)/10000;
				}
				
				order.coin = (currentProposal[i] as TradingOrder).coin;
				order.currency = (currentProposal[i] as TradingOrder).currency;
				order.fillOrKill = (currentProposal[i] as TradingOrder).fillOrKill;
				order.max_trade = (currentProposal[i] as TradingOrder).max_trade;
				order.min_trade = (currentProposal[i] as TradingOrder).min_trade;
				order.own = (currentProposal[i] as TradingOrder).own;
				order.price = (currentProposal[i] as TradingOrder).price;
				
				order.side = (currentProposal[i] as TradingOrder).side;
				order.startValue = (currentProposal[i] as TradingOrder).startValue;
				order.suboffers = (currentProposal[i] as TradingOrder).suboffers;
				order.trades_count = (currentProposal[i] as TradingOrder).trades_count;
				
				
				orders.push(order);
			}
			
			commission = NaN;
			commissionCurrency = "";
			
			if (orders != null && orders.length > 0)
			{
			//	currentIndex = 0;
			//	processNext();
				loadComission();
			}
		}
		
		private function loadComission():void 
		{
			var request:Object = new Object();
			request.coin = "DCO";
			request.side = "SELL";
			var prices:Object = new Object();
			
			for (var i:int = 0; i < orders.length; i++) 
			{
				if (prices[((orders[i] as TradingOrder).price).toString()] == null)
				{
					prices[((orders[i] as TradingOrder).price).toString()] = (orders[i] as TradingOrder).quantity;
				}
				else
				{
					prices[((orders[i] as TradingOrder).price).toString()] += (orders[i] as TradingOrder).quantity;
				}
			}
			
			var index:int = 1;
			for (var price:String in prices) 
			{
				request["amount" + index.toString()] = Number((prices[price] as Number).toFixed(4));
				request["price" + index.toString()] = Number(price);
				index++;
			}
			
			/*for (var i:int = 0; i < orders.length; i++) 
			{
				request["amount" + (i + 1).toString()] = (orders[i] as TradingOrder).quantity;
				request["price" + (i + 1).toString()] = (orders[i] as TradingOrder).price;
			}*/
			PayManager.callGetSellCoinsBulkCommission(request, _lastCommissionCallID);
		}
		
		private function stopCurrent():void 
		{
			
		}
		
		private function processNext():void 
		{
			if (currentIndex < orders.length)
			{
				PayManager.callGetSellCoinsCommission((orders[currentIndex] as TradingOrder).quantity, (orders[currentIndex] as TradingOrder).price, _lastCommissionCallID);
			}
			else
			{
				var commissionText:String = Math.round(commission * 1000) / 1000 + " " + commissionCurrency;
				invokeCallback(commissionText);
			}
		}
		
		private function onCommissionBulkRespond(respond:PayRespond):void {
			if (isDisposed == true) {
				return;
			}
			if (!respond.error) {
				handleCommissionBulkRespond(respond.savedRequestData.callID, respond.data);
				
			} else if (respond.hasAuthorizationError == false) {
				invokeCallback(Lang.textError + " " + respond.errorMsg);
			}
		}
		
		private function handleCommissionBulkRespond(callID:String, data:Object):void {
			if (isDisposed == true)
			{
				return;
			}
			if (_lastCommissionCallID == callID) {
				if (data != null) {
					lastCommissionData = data;
					invokeCallback(data);
				} else {
					invokeCallback(Lang.textError);
				}
			}
		}
		
		private function onCommissionRespond(respond:PayRespond):void {
			if (isDisposed == true) {
				return;
			}
			if (!respond.error) {
				handleCommissionRespond(respond.savedRequestData.callID, respond.data);
				
			} else if (respond.hasAuthorizationError == false) {
				invokeCallback(Lang.textError + " " + respond.errorMsg);
			}
		}
		
		private function handleCommissionRespond(callID:String, data:Object):void {
			if (isDisposed == true)
			{
				return;
			}
			if (_lastCommissionCallID == callID) {
				if (data != null) {
					if (isNaN(commission))
					{
						commission = 0;
					}
					commission += parseFloat(data.amount);
					commissionCurrency = data.currency;
				}
				currentIndex ++;
				processNext();
			}
		}
		
		private function invokeCallback(response:Object):void 
		{
			if (callback != null && callback.length == 1)
			{
				callback(response);
			}
		}
		
		public function dispose():void
		{
			if (PayManager.S_SELL_COINS_BULK_COMMISSION_RESPOND != null)
			{
				PayManager.S_SELL_COINS_BULK_COMMISSION_RESPOND.remove(onCommissionBulkRespond);
			}
			
			isDisposed = true;
			callback = null;
		}
		
		public function getValue():Number 
		{
			if (lastCommissionData != null && "total" in lastCommissionData && lastCommissionData.total != null && "amount" in lastCommissionData.total && !isNaN(Number(lastCommissionData.total.amount)))
			{
				return Number(lastCommissionData.total.amount);
			}
			return commission;
		}
		
		public function get firstTransactionComission():String 
		{
			if (lastCommissionData != null && "first_transaction" in lastCommissionData && lastCommissionData.first_transaction != null && "readable" in lastCommissionData.first_transaction)
			{
				return lastCommissionData.first_transaction.readable;
			}
			return null;
		}
		
		public function get lowLoquidityComission():String 
		{
			if (lastCommissionData != null && "low_liquidity" in lastCommissionData && lastCommissionData.low_liquidity != null && "readable" in lastCommissionData.low_liquidity)
			{
				return lastCommissionData.low_liquidity.readable;
			}
			return null;
		}
		
		public function get low_liquidity_eur_per_coin():String 
		{
			if (lastCommissionData != null && "low_liquidity_eur_per_coin")
			{
				return lastCommissionData.low_liquidity_eur_per_coin;
			}
			return "0";
		}
		
		public function get low_liquidity_price_limit():String 
		{
			if (lastCommissionData != null && "low_liquidity_price_limit" in lastCommissionData)
			{
				return lastCommissionData.low_liquidity_price_limit;
			}
			return "0";
		}
	}
}