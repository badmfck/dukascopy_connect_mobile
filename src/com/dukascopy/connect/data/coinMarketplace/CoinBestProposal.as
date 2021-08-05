package com.dukascopy.connect.data.coinMarketplace 
{
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.payments.PayManager;
	import com.dukascopy.langs.LangManager;
	import com.telefision.sys.signals.Signal;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class CoinBestProposal 
	{
		private var dataProvider:Function;
		private var updateSignal:Signal;
		private var callback:Function;
		private var refreshDataFunction:Function;
		private var sortSellFunction:Function;
		private var sortBuyFunction:Function;
		private var side:String;
		private var value:Number;
		private var priceLimit:Number;
		
		public function CoinBestProposal(callback:Function, dataProvider:Function, refreshDataFunction:Function, updateSignal:Signal) 
		{
			this.callback = callback;
			this.dataProvider = dataProvider;
			this.updateSignal = updateSignal;
			this.refreshDataFunction = refreshDataFunction;
			
			sortSellFunction = function (first:TradingOrder, second:TradingOrder):int {
				if (first.price > second.price)
					return -1;
				else if (first.price < second.price)
					return 1;
				else if (first.price == second.price)
				{
					/*if (first.publicOrder)
					{
						return -1;
					}
					if (second.publicOrder)
					{
						return 1;
					}*/
					
					if (first.created < second.created)
					{
						return -1;
					}
					else if (first.created > second.created)
					{
						return 1;
					}
				}
				return -1;
			}
			
			sortBuyFunction = function (first:TradingOrder, second:TradingOrder):int {
				if (first.price > second.price)
					return 1;
				else if (first.price < second.price)
					return -1;
				else if (first.price == second.price)
				{
					if (first.created < second.created)
					{
						return -1;
					}
					else if (first.created > second.created)
					{
						return 1;
					}
				}
				return -1;
			}
			
			if (updateSignal != null)
			{
				updateSignal.add(onUpdate);
			}
		}
		
		public function getProposal(side:String, value:Number, priceLimit:Number = NaN):void 
		{
			if (side == TradingOrder.SELL)
			{
				PayManager.callGetSystemOptions(function():void {
					processCalculation(side, value, priceLimit);
				} );
			}
			else
			{
				processCalculation(side, value, priceLimit);
			}
		}
		
		private function processCalculation(side:String, value:Number, priceLimit:Number):void 
		{
			this.side = side;
			this.value = value;
			this.priceLimit = priceLimit;
			
			if (value == 0)
			{
				sendResult(null);
			}
			
			if (dataProvider != null)
			{
				var rawData:Object = dataProvider();
				if (rawData != null)
				{
					var dataArray:Array;
					if (side == TradingOrder.BUY)
					{
						dataArray = getModels(rawData.SELL);
					}
					else
					{
						dataArray = getModels(rawData.BUY);
					}
					
					dataArray = dataArray.sort(getSortFunction(side));
					filter(dataArray, value, priceLimit, side);
				}
				else
				{
					if (refreshDataFunction != null)
					{
						refreshDataFunction();
					}
				}
			}
		}
		
		private function getSortFunction(side:String) :Function
		{
			if(side == TradingOrder.BUY)
			{
				return sortBuyFunction;
			}
			else
			{
				return sortSellFunction;
			}
		}
		
		private function filter(dataArray:Array, targetValue:Number, priceLimit:Number = NaN, side:String = null):void 
		{
			if (dataArray != null && dataArray.length > 0)
			{
				var currentQuantity:Number = 0;
				var l:int = dataArray.length;
				var resultArray:Array = new Array();
				
				if (currentQuantity >= targetValue)
				{
					sendResult(resultArray);
					return;
				}
				
				var order:TradingOrder;
				for (var i:int = 0; i < l; i++) 
				{
					order = dataArray[i] as TradingOrder;
					
					if (order.own == true)
					{
						continue;
					}
					
					if (!isNaN(priceLimit))
					{
						if (side == TradingOrder.BUY)
						{
							if (order.price > priceLimit)
							{
								continue;
							}
						}
						else
						{
							if (order.price < priceLimit)
							{
								continue;
							}
						}
					}
					
					if (order.fillOrKill)
					{
						if (targetValue - currentQuantity >= order.quantity)
						{
							resultArray.push(order);
							currentQuantity += order.quantity;
						}
					}
					else
					{
						currentQuantity += Math.min(order.quantity, targetValue - currentQuantity);
						resultArray.push(dataArray[i]);
					}
					
					if (currentQuantity >= targetValue)
					{
						sendResult(resultArray);
						return;
					}
				}
				
				sendResult(resultArray);
			}
		}
		
		private function sendResult(value:Array):void 
		{
			if (callback != null)
			{
				callback(value);
			}
		}
		
		private function getModels(source:Array):Array
		{
			var result:Array = new Array;
			
			if (source == null || source is Array == false)
			{
				return result;
			}
			
			var length:int = (source as Array).length;
			
			var parser:TradingOrderParser = new TradingOrderParser();
			var item:TradingOrder;
			for (var i:int = 0; i < length; i++) 
			{
				item = parser.parse(source[i]);
				if (item != null)
				{
					if (isDataValid(item))
					{
						result.push(item);
					}
				}
				else
				{
					ApplicationErrors.add();
				}
			}
			
			return result;
		}
		
		private function isDataValid(item:TradingOrder):Boolean 
		{
			var moneyValue:Number = item.price * item.quantity;
			if (PayManager.systemOptions != null && !isNaN(PayManager.systemOptions.coinMinFiatValue) && moneyValue < PayManager.systemOptions.coinMinFiatValue)
			{
				return false;
			}
			else
			{
				return true;
			}
		}
		
		public function dispose():void
		{
			if (updateSignal != null)
			{
				updateSignal.remove(onUpdate);
			}
			
			dataProvider = null;
			callback = null;
			refreshDataFunction = null;
			updateSignal = null;
			sortSellFunction = null;
			sortBuyFunction = null;
		}
		
		public function refresh():void 
		{
			if (refreshDataFunction != null)
			{
				refreshDataFunction();
			}
			else
			{
				ApplicationErrors.add();
			}
		}
		
		private function onUpdate(data:* = null):void 
		{
			if (side != null)
			{
				getProposal(side, value, priceLimit);
			}
		}
	}
}