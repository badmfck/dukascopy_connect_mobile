package com.dukascopy.connect.screens.marketplace {
	
	import assets.SigmaIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.BackgroundModel;
	import com.dukascopy.connect.data.ChatBackgroundCollection;
	import com.dukascopy.connect.data.CoinTradeOrder;
	import com.dukascopy.connect.data.HitZoneData;
	import com.dukascopy.connect.data.OrderScreenData;
	import com.dukascopy.connect.data.PopupData;
	import com.dukascopy.connect.data.Separator;
	import com.dukascopy.connect.data.coinMarketplace.MarketplaceScreenData;
	import com.dukascopy.connect.data.coinMarketplace.TradingOrder;
	import com.dukascopy.connect.data.coinMarketplace.TradingOrderParser;
	import com.dukascopy.connect.data.coinMarketplace.TradingOrderRequest;
	import com.dukascopy.connect.data.escrow.TradeDirection;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.customActions.EmptyAction;
	import com.dukascopy.connect.data.screenAction.customActions.RemoveOrderAction;
	import com.dukascopy.connect.gui.components.VerticalDivider;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.List;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.gui.list.renderers.trade.ListMarketplaceItem;
	import com.dukascopy.connect.gui.list.renderers.trade.ListMarketplaceItemVertical;
	import com.dukascopy.connect.gui.tools.HorizontalPreloader;
	import com.dukascopy.connect.gui.topBar.TopBarScreen;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.context.ContextMenuScreen;
	import com.dukascopy.connect.screens.dialogs.paymentDialogs.BuySellCoinPopup;
	import com.dukascopy.connect.screens.dialogs.paymentDialogs.TradeCoinPopup;
	import com.dukascopy.connect.screens.dialogs.paymentDialogs.TradeCoinsExtendedPopup;
	import com.dukascopy.connect.screens.dialogs.x.base.content.CoinsBalancePopup;
	import com.dukascopy.connect.screens.payments.card.TypeCurrency;
	import com.dukascopy.connect.screens.serviceScreen.BottomPopupScreen;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.assets.Assets;
	import com.dukascopy.connect.sys.bankManager.BankManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.payments.PayManager;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.store.Store;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.type.MainColors;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class CoinMarketplace extends BaseScreen {
		
		private const DEFAULT_BACKGROUND_COLOR:uint = Style.color(Style.CHAT_BACKGROUND);
		static public const STATE_VERTICAL:String = "stateVertical";
		static public const STATE_HORIZONTAL:String = "stateHorizontal";
		
		private var topBar:TopBarScreen;
		private var list:List;
		
		private var horizontalLoader:HorizontalPreloader;
		private var backClip:Sprite;
		private var controlPanel:MarketplaceControlPanel;
		private var screenData:MarketplaceScreenData;
		private var sortSellFunction:Function;
		private var sortBuyFunction:Function;
		private var currentFilter:String;
		private var listRight:List;
		private var state:String;
		private var divider:VerticalDivider;
		private var needClose:Boolean;
		private var bestPriceText1:Bitmap;
		private var bestPriceText2:Bitmap;
		private var updateTimeout:Number = 5 * 60;
		private var backgroundImage:Bitmap;
		private var backgroundBitmapData:ImageBitmapData;
		
		private var actions:Array = [
			{ id:"balanceBtn", img:SigmaIcon, callback:showOrdersBalance }
		];
		
		public function CoinMarketplace() { }
		
		override protected function createView():void {
			super.createView();
			backClip = new Sprite();
			_view.addChild(backClip);
			
			backgroundImage = new Bitmap();
		//	_view.addChild(backgroundImage);
			
			list = new List("Chat");
			list.setMask(true);
			list.setAdditionalBottomHeight(Config.FINGER_SIZE * .5);
		//	list.backgroundColor = Style.color(Style.CHAT_BACKGROUND);
			list.background = false;
			_view.addChild(list.view);
			
			topBar = new TopBarScreen();
			_view.addChild(topBar);
			
			horizontalLoader = new HorizontalPreloader(0xF6951D);
			view.addChild(horizontalLoader);
			
			controlPanel = new MarketplaceControlPanel();
			controlPanel.clearFilter = clearFilter;
			controlPanel.refresh = callRefresh;
			controlPanel.buyClick = showBuyPopup;
			controlPanel.sellClick = showSellPopup;
			controlPanel.createBuy = createBuy;
			controlPanel.createSell = createSell;
			view.addChild(controlPanel);
			
			sortSellFunction = function (first:TradingOrder, second:TradingOrder):int {
				if (first.price > second.price)
					return -1;
				else if (first.price < second.price)
					return 1;
				else
				{
					if (first.quantity > second.quantity)
						return -1;
					else if (first.quantity < second.quantity)
						return 1;
				}
				return -1;
			}
			
			sortBuyFunction = function (first:TradingOrder, second:TradingOrder):int {
				if (first.price > second.price)
					return 1;
				else if (first.price < second.price)
					return -1;
				else
				{
					if (first.quantity > second.quantity)
						return -1;
					else if (first.quantity < second.quantity)
						return 1;
				}
				return -1;
			}
		}
		
		private function showOrdersBalance():void
		{
			if (screenData != null && screenData.myOrders != null && PayManager.getCoins() != null && PayManager.accountInfo != null && PayManager.accountInfo.accounts != null)
			{
				var dataProvider:Object = screenData.myOrders();
				var itemsSell:Array = getMy(getSell(getModels(dataProvider as Array)));
				var itemsBuy:Array = getMy(getBuy(getModels(dataProvider as Array)));
				
				var sellSum:Number = 0;
				var buySum:Number = 0;
				
				var coinBalance:Number = 0;
				var moneyBalance:Number = 0;
				
				var coinOrders:int = 0;
				var moneyOrders:Number = 0;
				
				var l:int = itemsSell.length;
				coinOrders = l;
				for (var i:int = 0; i < l; i++) 
				{
					sellSum += (itemsSell[i] as TradingOrder).quantity;
				}
				l = itemsBuy.length;
				moneyOrders = l;
				for (var j:int = 0; j < l; j++) 
				{
					buySum += (itemsBuy[j] as TradingOrder).quantity * (itemsBuy[j] as TradingOrder).price;
				}
				
				var coinAccounts:Array = PayManager.getCoins();
				l = coinAccounts.length;
				for (var i2:int = 0; i2 < l; i2++) {
					if (coinAccounts[i2].COIN == TypeCurrency.DCO) {
						coinBalance = coinAccounts[i2].BALANCE;
						break;
					}
				}
				
				l = PayManager.accountInfo.accounts.length;
				for (var i3:int = 0; i3 < l; i3++) {
					if (PayManager.accountInfo.accounts[i3].CURRENCY == TypeCurrency.EUR) {
						moneyBalance = PayManager.accountInfo.accounts[i3].BALANCE;
						break;
					}
				}
				
				ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, CoinsBalancePopup, {moneyOrders:moneyOrders, coinOrders:coinOrders, sellSum:sellSum, buySum:buySum, moneyBalance:moneyBalance, coinBalance:coinBalance});
			}
		}
		
		private function createSell():void 
		{
			var screenData:OrderScreenData = new OrderScreenData();
			screenData.additionalData = data;
			screenData.title = Lang.newSellCoinLot;
			screenData.type = TradingOrder.SELL;
			screenData.orders = null;
			screenData.localProcessing = true;
			screenData.callback = this.screenData.createLotFunction as Function;
			
			var l:int;
			var i:int;
			var bestPrice:Number;
			var dataProvider:Object;
			var currentData:Array;
			
			bestPrice = 0;
			dataProvider = this.screenData.dataProvider();
			var reservedCoin:Number = 0;
			var reservedFiat:Number = 0;
			var offer:TradingOrder;
			if (dataProvider != null)
			{
				currentData = getModels(dataProvider.BUY);
				if (currentData != null && currentData.length > 0)
				{
					l = currentData.length;
					for (i = 0; i < l; i++) 
					{
						offer = (currentData[i] as TradingOrder);
						if (offer.price > bestPrice)
						{
							bestPrice = offer.price;
						}
						if (offer.own == true && offer.side == TradingOrder.BUY)
						{
							reservedFiat += offer.quantity * offer.price;
						}
					}
				}
				currentData = getModels(dataProvider.SELL);
				if (currentData != null && currentData.length > 0)
				{
					l = currentData.length;
					for (i = 0; i < l; i++) 
					{
						offer = (currentData[i] as TradingOrder);
						if (offer.own == true && offer.side == TradingOrder.SELL)
						{
							reservedCoin += offer.quantity;
						}
					}
				}
			}
			screenData.bestPrice = bestPrice;
			screenData.reservedCoin = reservedCoin;
			screenData.reservedFiat = reservedFiat;
			ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_DIALOG, TradeCoinPopup, screenData);
		}
		
		private function onCryptoOfferCallback(val:int, data:CoinTradeOrder = null):void 
		{
			if (val != 1)
				return;
			
			if (screenData.createLotFunction != null)
			{
				screenData.createLotFunction(val, data);
			}
		}
		
		private function createBuy():void 
		{
			var screenData:OrderScreenData = new OrderScreenData();
			screenData.additionalData = data;
			screenData.title = Lang.newSellCoinLot;
			screenData.type = TradingOrder.BUY;
			screenData.orders = null;
			screenData.localProcessing = true;
			screenData.callback = this.screenData.createLotFunction as Function;
			
			var l:int;
			var i:int;
			var bestPrice:Number;
			var dataProvider:Object;
			var currentData:Array;
			
			bestPrice = Number.POSITIVE_INFINITY;
			dataProvider = this.screenData.dataProvider();
			if (dataProvider != null)
			{
				currentData = getModels(dataProvider.SELL);
				if (currentData != null && currentData.length > 0)
				{
					l = currentData.length;
					for (i = 0; i < l; i++) 
					{
						if ((currentData[i] as TradingOrder).price < bestPrice)
						{
							bestPrice = (currentData[i] as TradingOrder).price;
						}
					}
				}
			}
			screenData.bestPrice = bestPrice;
			
			ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_DIALOG, TradeCoinPopup, screenData);
		}
		
		private function showSellPopup():void 
		{
			var screenDataNew:Object = new Object();
			screenDataNew.dataProvider = this.screenData.dataProvider;
			screenDataNew.refreshDataFunction = this.screenData.resreshFunction;
			screenDataNew.updateDataSignal = this.screenData.updateSignal;
			screenDataNew.type = TradingOrder.SELL;
			
			screenDataNew.callback = this.screenData.tradeFunction;
			screenDataNew.resultSignal = this.screenData.tradeSignal;
			
			ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_DIALOG, TradeCoinsExtendedPopup, screenDataNew);
		}
		
		private function showBuyPopup():void 
		{
			var screenDataNew:Object = new Object();
			screenDataNew.dataProvider = this.screenData.dataProvider;
			screenDataNew.refreshDataFunction = this.screenData.resreshFunction;
			screenDataNew.updateDataSignal = this.screenData.updateSignal;
			screenDataNew.type = TradingOrder.BUY;
			
			screenDataNew.callback = this.screenData.tradeFunction;
			screenDataNew.resultSignal = this.screenData.tradeSignal;
			
			ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_DIALOG, TradeCoinsExtendedPopup, screenDataNew);
		}
		
		private function clearFilter():void 
		{
			if (currentFilter == "all")
			{
				currentFilter = "my";
			//	topBar.updateTitle(Lang.);
			}
			else
			{
				currentFilter = "all";
			}
			
			callRefresh();
			controlPanel.draw(_width, currentFilter);
		}
		
		private function callRefresh():void 
		{
			TweenMax.killDelayedCallsTo(callRefresh);
			horizontalLoader.start();
			if (screenData != null && screenData.resreshFunction != null)
			{
				screenData.resreshFunction();
			}
		}
		
		/**
		 * @param	data - Object with initialized params (for exaple - list of searched conversations or etc..)
		 */
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			BankManager.init();
			state = STATE_HORIZONTAL;
			
			if (data != null && "screeenData" in data && data.screeenData != null && data.screeenData is MarketplaceScreenData)
			{
				screenData = data.screeenData as MarketplaceScreenData;
			}
			
			if (data != null && "backScreenData" in data && data.backScreenData != null && "value" in data.backScreenData && data.backScreenData.value != null)
			{
			//	currentFilter = data.backScreenData.value as String;
			}
			
			currentFilter = "all"
			
			if (screenData.type == 1)
			{
				currentFilter = "my";
			}
			
			topBar.setData(Lang.dukascoinMarketplace, true, actions);
			
			backClip.graphics.clear();
			backClip.graphics.beginFill(DEFAULT_BACKGROUND_COLOR);
			backClip.graphics.drawRect(0, 0, _width, _height - topBar.trueHeight);
			backClip.graphics.endFill();
			backClip.y = topBar.trueHeight;
			
			controlPanel.draw(_width, currentFilter);
			controlPanel.y = _height - controlPanel.height;
			
			horizontalLoader.setSize(_width, int(Config.FINGER_SIZE * .07));
			
			startListenData();
			
			if (currentFilter == TradingOrder.BUY)
			{
				showSellPopup();
			}
			else if(currentFilter == TradingOrder.SELL)
			{
				showBuyPopup();
			}
			
			loadState();
			
			BankManager.S_ORDER_REMOVED.add(onOrderRemoved);
			
			addBackgroundImage();
		}
		
		private function startListenData():void 
		{
			if (screenData != null && screenData.updateSignal != null)
			{
				screenData.updateSignal.add(onDataUpdate);
			}
			
			if (screenData != null && screenData.resreshFunction != null)
			{
				screenData.resreshFunction();
			}
		}
		
		private function addBackgroundImage():void 
		{
			var backId:String = "7";
			var backgroundModel:BackgroundModel = ChatBackgroundCollection.getBackground(backId);
			if (backgroundModel == null)
				return;
			
			if (backgroundImage != null && backgroundImage.bitmapData) {
				backgroundImage.bitmapData.dispose();
				backgroundImage.bitmapData = null;
			}
			backgroundBitmapData = Assets.getBackground(backgroundModel.big);
			backgroundImage.bitmapData = UI.drawAreaCentered(backgroundBitmapData, _width, _height);
		}
		
		private function onDataUpdate(newData:Object = null):void 
		{
			horizontalLoader.stop(false);
			if (screenData != null && screenData.dataProvider != null && screenData.myOrders != null)
			{
				var temp:Array;
				var dataProvider:Object = screenData.dataProvider();
				
				if (currentFilter == "my")
				{
					dataProvider = screenData.myOrders();
				}
				else
				{
					dataProvider = screenData.dataProvider();
				}
				
				if (state == STATE_VERTICAL)
				{
					if (dataProvider != null)
					{
						var newListData:Array;
						if (currentFilter == "my")
						{
							newListData = getMy(getSell(getModels(dataProvider as Array)));
							newListData = newListData.sort(sortBuyFunction);
							listRight.setData(newListData, ListMarketplaceItemVertical);
							
							newListData = getMy(getBuy(getModels(dataProvider as Array)));
							newListData = newListData.sort(sortSellFunction);
							list.setData(newListData, ListMarketplaceItemVertical);
						}
						else
						{
							newListData = getModels(dataProvider.SELL);
							newListData = newListData.sort(sortBuyFunction);
							listRight.setData(newListData, ListMarketplaceItemVertical);
							
							newListData = getModels(dataProvider.BUY);
							newListData = newListData.sort(sortSellFunction);
							list.setData(newListData, ListMarketplaceItemVertical);
						}
					}
					else
					{
						list.setData(null, ListMarketplaceItem);
					}
				}
				else
				{
					if (dataProvider != null)
					{
						newListData = new Array()
						
						if (currentFilter == "my")
						{
							temp = getSell(getModels(dataProvider as Array));
							temp = temp.sort(sortSellFunction);
							newListData = newListData.concat(temp);
							
							newListData.push(new Separator(Separator.VERTICAL));
							
							temp = getBuy(getModels(dataProvider as Array));
							temp = temp.sort(sortSellFunction);
							
							newListData = newListData.concat(temp);
							if (newListData.length == 1)
							{
								newListData.length = 0;
							}
						}
						else
						{
							if (currentFilter != TradingOrder.BUY)
							{
								if (dataProvider.BUY != null)
								{
									temp = getModels(dataProvider.SELL);
									temp = temp.sort(sortSellFunction);
									newListData = newListData.concat(temp);
								}
							}
							
							newListData.push(new Separator(Separator.VERTICAL));
							
							if (currentFilter != TradingOrder.SELL)
							{
								if (dataProvider.SELL != null)
								{
									temp = getModels(dataProvider.BUY);
									temp = temp.sort(sortSellFunction);
									newListData = newListData.concat(temp);
								}
							}
						}
						
						if (currentFilter == "my")
						{
							newListData = getMy(newListData);
						}
						else
						{
							newListData = collapse(newListData);
						}
						
					//	newListData.sort(sortDataFunction);
						
						
						list.setData(newListData, ListMarketplaceItem);
						
						list.scrollToItem("side", TradingOrder.BUY, list.height * .5);
					}
					else
					{
						list.setData(null, ListMarketplaceItem);
						if (listRight != null)
						{
							listRight.setData(null, ListMarketplaceItem);
						}
					}
				}
			}
			
			TweenMax.delayedCall(updateTimeout, callRefresh);
		}
		
		private function getMy(models:Array):Array 
		{
			var result:Array = new Array();
			if (models != null)
			{
				var l:int = models.length;
				for (var i:int = 0; i < l; i++) 
				{
					if (models[i] is TradingOrder && (models[i] as TradingOrder).own == true && (models[i] as TradingOrder).active == true)
					{
						result.push(models[i]);
					}
					else if (models[i] is Separator)
					{
						result.push(models[i]);
					}
				}
			}
			return result;
		}
		
		private function getBuy(models:Array):Array 
		{
			var result:Array = new Array();
			if (models != null)
			{
				var l:int = models.length;
				for (var i:int = 0; i < l; i++) 
				{
					if (models[i] is TradingOrder && (models[i] as TradingOrder).side == TradingOrder.BUY)
					{
						result.push(models[i]);
					}
					else if (models[i] is Separator)
					{
						result.push(models[i]);
					}
				}
			}
			return result;
		}
		
		private function getSell(models:Array):Array 
		{
			var result:Array = new Array();
			if (models != null)
			{
				var l:int = models.length;
				for (var i:int = 0; i < l; i++) 
				{
					if (models[i] is TradingOrder && (models[i] as TradingOrder).side == TradingOrder.SELL)
					{
						result.push(models[i]);
					}
					else if (models[i] is Separator)
					{
						result.push(models[i]);
					}
				}
			}
			return result;
		}
		
		private function collapse(value:Array):Array
		{
			var result:Array = new Array();
			var length:int = value.length;
			var lastItem:TradingOrder;
			var stackItem:TradingOrder;
			for (var i:int = 0; i < length; i++) 
			{
				if (lastItem != null && lastItem is TradingOrder && value[i] is TradingOrder && value[i] != null && lastItem.side == value[i].side && lastItem.price == value[i].price)
				{
					if (lastItem.suboffers == null)
					{
						stackItem = new TradingOrder();
						stackItem.quantity = lastItem.quantity;
						stackItem.price = lastItem.price;
						stackItem.quantityString = lastItem.quantityString;
						stackItem.priceString = lastItem.priceString;
						stackItem.currency = lastItem.currency;
						stackItem.coin = lastItem.coin;
						stackItem.side = lastItem.side;
						
						stackItem.addSuboffer(lastItem);
						result.removeAt(result.length - 1);
						result.push(stackItem);
						lastItem = stackItem;
					}
					lastItem.quantity += value[i].quantity;
					lastItem.quantityString = lastItem.quantity.toFixed(4);
					lastItem.addSuboffer(value[i]);
				}
				else
				{
					if (value[i] is TradingOrder)
					{
						lastItem = value[i];
						result.push(lastItem);
					}
					else
					{
						result.push(value[i]);
					}
				}
			}
			return result;
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
					result.push(item);
				}
				else
				{
					ApplicationErrors.add();
				}
			}
			
			return result;
		}
		
		override public function onBack(e:Event = null):void {
			super.onBack(e);
		}
		
		private function refreshList(date:int):void {
			if (list != null)
				list.refresh();
		}
		
		override protected function drawView():void {
			if (_isDisposed)
				return;
			if (!list)
				return;
			
			topBar.drawView(_width);
			
			setListSize();
			backClip.width = _width;
			backClip.height = _height;
			
			horizontalLoader.y = topBar.y + topBar.trueHeight;
		}
		
		override public function activateScreen():void {
			
			if (_isActivated)
				return;
			
			if (isDisposed)
				return;
			
			super.activateScreen();
			
			controlPanel.activate();
			
			if (divider != null)
			{
				divider.activate();
			}
			
			if (topBar != null)
				topBar.activate();
			
			if (listRight != null)
			{
				listRight.activate();
				listRight.S_ITEM_TAP.add(onItemTap);
			}
			
			list.activate();
			list.S_ITEM_TAP.add(onItemTap);
			
			if (needClose == true)
			{
				needClose = false;
				onBack();
			}
		}
		
		private function onItemTap(data:Object, n:int):void {
			
			var selectedItem:ListItem;
			var lastHitzoneObject:Object;
			var lhz:String;
			
			if (data is Separator)
			{
				selectedItem = list.getItemByNum(n);
				lastHitzoneObject =  selectedItem.getLastHitZoneObject();
				lhz = lastHitzoneObject!=null?lastHitzoneObject.type:null;// selectedItem.getLastHitZone();
				
				if (lhz == HitZoneType.CHANGE_LAYOUT)
				{
					changeLayoutVertical();
				}
			}
			
			if (data == null)
				return;
			if (list.getItemByNum(n) == null)
				return;
			
			if (data is TradingOrder)
			{
				if (state == STATE_VERTICAL)
				{
					if ((data as TradingOrder).side == TradingOrder.SELL)
					{
						selectedItem = listRight.getItemByNum(n);
					}
					else
					{
						selectedItem = list.getItemByNum(n);
					}
				}
				else
				{
					selectedItem = list.getItemByNum(n);
				}
				
				lastHitzoneObject =  selectedItem.getLastHitZoneObject();
				lhz = lastHitzoneObject!=null?lastHitzoneObject.type:null;// selectedItem.getLastHitZone();
				
				var items:Vector.<TradingOrder>;
				if (lhz == HitZoneType.EXPAND) {
					items = (data as TradingOrder).suboffers;
					if (items != null) {
						list.deactivate();
						TweenMax.delayedCall(0.6, activateList), 
						
						list.removeItem(n, true, false);
						for (var i:int = 0; i < items.length; i++) {
							if (i == 0) {
								items[i].first = true;
							} else if (i == items.length - 1) {
								items[i].last = true;
							} else {
								items[i].middle = true;
							}
							list.appendItem(items[i], ListMarketplaceItem, null, true, true, n + i, (i) * .1 + 0.3, true);
						}
						list.refresh(true, true, false, true);
					}
					return;
				}
				
				if (lhz == HitZoneType.COLLAPSE) {
					items = new Vector.<TradingOrder>();
					var current:TradingOrder = data as TradingOrder;
				//	items.push(current);
					
					var stackItem:TradingOrder = new TradingOrder();
					stackItem.quantity = 0;
					stackItem.price = current.price;
					stackItem.quantityString = current.quantityString;
					stackItem.priceString = current.priceString;
					stackItem.currency = current.currency;
					stackItem.coin = current.coin;
					stackItem.side = current.side;
					
					for (var k:int = n; k >= 0; k--)
					{
						if (list.data[k] is TradingOrder && current.priceString == list.data[k].priceString)
						{
							stackItem.addSuboffer(list.data[k]);
							items.push(list.data[k]);
							list.data[k].first = false;
							list.data[k].middle = false;
							list.data[k].last = false;
							
							stackItem.quantity += list.data[k].quantity;
							stackItem.quantityString = stackItem.quantity.toFixed(4);
						}
						else
						{
							break;
						}
					}
					
					if (items != null)
					{
						list.deactivate();
						TweenMax.delayedCall(0.6, activateList); 
						
						for(var i2:int = 0; i2 < items.length; i2++) 
						{
							list.removeItem(n - i2, true, false);
						}
						list.appendItem(stackItem, ListMarketplaceItem, null, true, true, n - items.length + 1, 0.3, true);
						
						list.refresh(true, true, false, true);
					}
					return;
				}
				
				if ((data as TradingOrder).own == true)
				{
					var actionsTap:Vector.<IScreenAction> = new Vector.<IScreenAction>();
				//	actionsTap.push(new EditOrderAction(data as TradingOrder));
					actionsTap.push(new RemoveOrderAction(data as TradingOrder));
					
					
					var messageContentHitzone:HitZoneData = (selectedItem.renderer as ListMarketplaceItem).getMessageHitzone(selectedItem);
					if (messageContentHitzone != null) {
						var screenDataContext:Object = new Object();
						var globalPointTap:Point = selectedItem.liView.parent.localToGlobal(new Point(selectedItem.liView.x, selectedItem.liView.y));
						messageContentHitzone.x = globalPointTap.x + messageContentHitzone.x;
						messageContentHitzone.y = globalPointTap.y + messageContentHitzone.y;
						messageContentHitzone.visibilityRect = new Rectangle(0, list.view.y, _width, list.view.height);
						
						if (messageContentHitzone.y < list.view.y) {
							messageContentHitzone.height -= list.view.y - messageContentHitzone.y;
							messageContentHitzone.y = list.view.y;
						}
						if (messageContentHitzone.y + messageContentHitzone.height > list.view.y + list.height) {
							messageContentHitzone.height -= messageContentHitzone.y + messageContentHitzone.height - (list.view.y + list.height);
						}
						
						screenDataContext.hitzone = messageContentHitzone;
						
						screenDataContext.actions = actionsTap;
						ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, ContextMenuScreen, {
																												backScreen:MobileGui.centerScreen.currentScreen, 
																												backScreenData:MobileGui.centerScreen.currentScreen.data, 
																												data:screenDataContext}, 0, 0);
					}
					return;
				}
				
				if (lhz != HitZoneType.GET)
				{
					return;
				}
				
				var screenData:OrderScreenData = new OrderScreenData();
				if ((data as TradingOrder).suboffers != null)
				{
					var orders:Array = new Array();
					for (var j:int = 0; j < (data as TradingOrder).suboffers.length; j++) 
					{
						orders.push((data as TradingOrder).suboffers[j]);
					}
					screenData.orders = orders;
				}
				else
				{
					screenData.orders = [data as TradingOrder];
				}
				screenData.type = (data as TradingOrder).side;
				screenData.callback = this.screenData.tradeFunction;
				screenData.resultSignal = this.screenData.tradeSignal;
				screenData.refresh = this.screenData.resreshFunction;
				
				var onlyMyOrders:Boolean = true;
				if (screenData.orders != null)
				{
					for (var l:int = 0; l < screenData.orders.length; l++) 
					{
						if ((screenData.orders[l] as TradingOrder).own == false)
						{
							onlyMyOrders = false;
							break;
						}
					}
				}
				else
				{
					onlyMyOrders = false;
				}
				
				if (onlyMyOrders == false)
				{
					screenData.bestSellPrice = getBestSellPrice();
					screenData.bestBuyPrice = getBestBuyPrice();
					
					
					var orderInTop:Boolean = true;
					var counter:int = 1;
					var m:int;
					var lastPrice:Number = (data as TradingOrder).price;
					if (state == STATE_HORIZONTAL)
					{
						if ((data as TradingOrder).side == TradingOrder.BUY)
						{
							for (m = n-1; m >= 0; m--) 
							{
								if (list.data[m] is TradingOrder && (list.data[m] as TradingOrder).side == TradingOrder.BUY)
								{
									if ((list.data[m] as TradingOrder).price != lastPrice)
									{
										lastPrice = (list.data[m] as TradingOrder).price;
										counter ++;
									}
								}
								else
								{
									break;
								}
							}
						}
						else
						{
							if (n+1 < list.data.length)
							{
								for (m = n+1; m < list.data.length; m++) 
								{
									if (list.data[m] is TradingOrder && (list.data[m] as TradingOrder).side == TradingOrder.SELL)
									{
										if ((list.data[m] as TradingOrder).price != lastPrice)
										{
											lastPrice = (list.data[m] as TradingOrder).price;
											counter ++;
										}
									}
									else
									{
										break;
									}
								}
							}
						}
					}
					else if (state == STATE_VERTICAL)
					{
						if ((data as TradingOrder).side == TradingOrder.BUY)
						{
							if (n > 0)
							{
								for (m = n-1; m >= 0; m--) 
								{
									if (list.data[m] is TradingOrder && (list.data[m] as TradingOrder).side == TradingOrder.BUY)
									{
										if ((list.data[m] as TradingOrder).price != lastPrice)
										{
											lastPrice = (list.data[m] as TradingOrder).price;
											counter ++;
										}
									}
									else
									{
										break;
									}
								}
							}
						}
						else
						{
							if (n > 0)
							{
								for (m = n-1; m >= 0; m--) 
								{
									if (listRight.data[m] is TradingOrder && (listRight.data[m] as TradingOrder).side == TradingOrder.SELL)
									{
										if ((listRight.data[m] as TradingOrder).price != lastPrice)
										{
											lastPrice = (list.data[m] as TradingOrder).price;
											counter ++;
										}
									}
									else
									{
										break;
									}
								}
							}
						}
					}
					
					if (counter <= 10)
					{
						ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_DIALOG, BuySellCoinPopup, screenData);
					}
					else
					{
						var popupData:PopupData = new PopupData();
						var action:IScreenAction = new EmptyAction();
						action.setData(Lang.textOk);
						popupData.action = action;
						popupData.illustration = null;
						popupData.text = Lang.pleaseChooseBetterPrice;
						ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, BottomPopupScreen, popupData);
					}
				}
				
				return;
			}
		}
		
		private function getBestBuyPrice():Number 
		{
			var l:int;
			var i:int;
			var bestPrice:Number;
			var dataProvider:Object;
			var currentData:Array;
			
			bestPrice = Number.POSITIVE_INFINITY;
			dataProvider = this.screenData.dataProvider();
			if (dataProvider != null)
			{
				currentData = getModels(dataProvider.SELL);
				if (currentData != null && currentData.length > 0)
				{
					l = currentData.length;
					for (i = 0; i < l; i++) 
					{
						if ((currentData[i] as TradingOrder).price < bestPrice)
						{
							bestPrice = (currentData[i] as TradingOrder).price;
						}
					}
				}
			}
			return bestPrice;
		}
		
		private function getBestSellPrice():Number 
		{
			var l:int;
			var i:int;
			var bestPrice:Number;
			var dataProvider:Object;
			var currentData:Array;
			
			bestPrice = 0;
			dataProvider = this.screenData.dataProvider();
			if (dataProvider != null)
			{
				currentData = getModels(dataProvider.BUY);
				if (currentData != null && currentData.length > 0)
				{
					l = currentData.length;
					for (i = 0; i < l; i++) 
					{
						if ((currentData[i] as TradingOrder).price > bestPrice)
						{
							bestPrice = (currentData[i] as TradingOrder).price;
						}
					}
				}
			}
			return bestPrice;
		}
		
		private function changeLayoutVertical():void 
		{
			controlPanel.expandButtons(-(controlPanel.y - topBar.y - topBar.trueHeight - Config.MARGIN));
			state = STATE_VERTICAL;
			
			saveState();
			
			if (listRight == null)
			{
				listRight = new List("Marketplace.rightList");
				listRight.background = false;
				listRight.setMask(true);
				listRight.setAdditionalBottomHeight(Config.FINGER_SIZE * .5);
				listRight.backgroundColor = MainColors.WHITE;
				_view.addChild(listRight.view);
				
				listRight.view.y = topBar.y + topBar.trueHeight;
				listRight.view.x = int(_width * .5);
				view.setChildIndex(listRight.view, 1);
				
				setListSize();
			}
			
			onDataUpdate();
			
			divider = new VerticalDivider(changeLayoutHorizontal);
			divider.draw(_height - topBar.trueHeight - controlPanel.getHeight());
			divider.x = int(list.view.x + list.width - Config.FINGER_SIZE * .4);
			divider.y = topBar.y + topBar.trueHeight;
			view.addChild(divider);
			if (isActivated)
			{
				divider.activate();
				listRight.S_ITEM_TAP.add(onItemTap);
				listRight.activate();
			}
			
			if (bestPriceText1 == null)
			{
				bestPriceText1 = new Bitmap();
				view.addChild(bestPriceText1);
				bestPriceText1.bitmapData = TextUtils.createTextFieldData(Lang.bestPrice.toUpperCase(), _width*.5 - Config.FINGER_SIZE*1.5, 10, true, 
															TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .24, true, 0x999999, 0xFFFFFF, false, true);
			}
			if (bestPriceText2 == null)
			{
				bestPriceText2 = new Bitmap();
				view.addChild(bestPriceText2);
				bestPriceText2.bitmapData = TextUtils.createTextFieldData(Lang.bestPrice.toUpperCase(), _width*.5 - Config.FINGER_SIZE*1.5, 10, true, 
															TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .24, true, 0x999999, 0xFFFFFF, false, true);
			}
			bestPriceText1.visible = true;
			bestPriceText2.visible = true;
			
			bestPriceText1.x = int((_width * .5 - controlPanel.buttonLeftPadding() - Config.FINGER_SIZE * .25) * .5 + controlPanel.buttonLeftPadding() - bestPriceText1.width * .5);
			bestPriceText2.x = int(_width * .5 + (_width * .5 - controlPanel.buttonLeftPadding() - Config.FINGER_SIZE * .25) * .5 - bestPriceText2.width*.5 + Config.FINGER_SIZE * .25);
			
			bestPriceText1.y = bestPriceText2.y = topBar.y + topBar.trueHeight + Config.FINGER_SIZE * .5 - bestPriceText1.height * .5 + Config.FINGER_SIZE * .1;
		}
		
		private function saveState():void 
		{
			Store.save(Store.MARKETPLACE_LAYOUT, state);
		}
		
		private function loadState():void 
		{
			Store.load(Store.MARKETPLACE_LAYOUT, onLoadedLayout);
		}
		
		private function onLoadedLayout(data:Object = null, error:Boolean = false):void 
		{
			if (error == false && data != null)
			{
				if (data != state)
				{
					if (data == STATE_HORIZONTAL)
					{
						changeLayoutHorizontal();
					}
					else
					{
						changeLayoutVertical();
					}
				}
			}
		}
		
		private function changeLayoutHorizontal():void 
		{
			bestPriceText1.visible = false;
			bestPriceText2.visible = false;
			
			state = STATE_HORIZONTAL;
			
			saveState();
			
			if (listRight != null)
			{
				listRight.deactivate();
				listRight.S_ITEM_TAP.remove(onItemTap);
				view.removeChild(listRight.view);
				listRight.dispose();
				listRight = null;
				controlPanel.collapseButtons();
			}
			if (divider != null)
			{
				divider.deactivate();
				divider.dispose();
				view.removeChild(divider);
				divider = null;
			}
			list.setData(null, null);
			setListSize();
			onDataUpdate();
		}
		
		private function onBuySellCallback(orderRequest:TradingOrderRequest = null):void 
		{
			if (screenData != null && screenData.tradeFunction != null)
			{
				screenData.tradeFunction(orderRequest);
			}
			
			deactivateScreen();
			TweenMax.delayedCall(0.5, closeScreen, [orderRequest]);
		}
		
		private function closeScreen(orderRequest:TradingOrderRequest = null):void 
		{
			if(orderRequest != null)
			{
				if (this.data != null && this.data.backScreenData != null)
				{
					this.data.backScreenData.order = orderRequest.orders[0];
				}
				onBack();
			}
		}
		
		private function onOrderRemoved(orderID:String):void 
		{
			if (list != null && list.data != null && list.data is Array)
			{
				var l:int = (list.data as Array).length;
				for (var i:int = 0; i < l; i++) 
				{
					if (list.data[i] != null && list.data[i] is TradingOrder && (list.data[i] as TradingOrder).uid == orderID)
					{
						list.removeItem(i, false, true);
						list.refresh(true, true);
						break;
					}
				}
			}
			callRefresh();
		}
		
		private function activateList():void 
		{
			if (!isDisposed && list != null && isActivated)
			{
				list.activate();
			}
		}
		
		override public function deactivateScreen():void {
			if (!_isActivated)
				return;
			
			super.deactivateScreen();
			
			controlPanel.deactivate();
			
			if (topBar != null)
				topBar.deactivate();
			list.deactivate();
			
			if (divider != null)
			{
				divider.deactivate();
			}
			
			if (listRight != null)
			{
				listRight.deactivate();
				listRight.S_ITEM_TAP.remove(onItemTap);
			}
			
			if (listRight != null)
			{
				listRight.deactivate();
			}
		}
		
		private function setListSize(needScrollToBottom:Boolean = false):void {
			if (_isDisposed == true)
				return;
			if (list == null || list.view == null)
				return;
			var inBotomPosition:Boolean = true;
			if (list.innerHeight + list.getBoxY() > list.height)
				inBotomPosition = false;
			var lastY:Number = 0;
			var bottomY:int = controlPanel.y;
			
			if (state == STATE_VERTICAL)
			{
				list.view.y = topBar.y + topBar.trueHeight + Config.FINGER_SIZE * 1;
				if (listRight != null)
				{
					listRight.view.y = topBar.y + topBar.trueHeight + Config.FINGER_SIZE * 1;
				}
			}
			else
			{
				list.view.y = topBar.y + topBar.trueHeight;
			}
			
			var listHeightNew:int = bottomY - list.view.y;
			
			var listWidth:int = _width;
			if (state == STATE_VERTICAL)
			{
				listWidth = _width * .5;
			}
			
			if (state == STATE_VERTICAL)
			{
				list.setWidthAndHeight(listWidth, listHeightNew);
				if (listRight != null)
				{
					listRight.setWidthAndHeight(listWidth, listHeightNew);
				}
			}
			else
			{
				list.setWidthAndHeight(listWidth, listHeightNew);
			}
		}
		
		override public function clearView():void {
			if (list != null)
				list.dispose();
			list = null;
			
			if (listRight != null)
				listRight.dispose();
			listRight = null;
			
			if (backClip != null)
				UI.destroy(backClip);
			backClip = null;
			
			if (bestPriceText1 != null)
				UI.destroy(bestPriceText1);
			bestPriceText1 = null;
			
			if (bestPriceText2 != null)
				UI.destroy(bestPriceText2);
			bestPriceText2 = null;
			
			if (divider != null)
			{
				divider.dispose();
				divider = null;
			}
			
			if (topBar != null)
				topBar.dispose();
			topBar = null;
			
			if (controlPanel != null)
				controlPanel.dispose();
			controlPanel = null;
			
			if (horizontalLoader != null)
			{
				horizontalLoader.dispose();
				horizontalLoader = null;
			}
			
			stopListenData();
			
			screenData = null;
			_data = null;
			
			sortBuyFunction = null;
			sortSellFunction = null;
			
			BankManager.S_ORDER_REMOVED.remove(onOrderRemoved);
			
			super.clearView();
		}
		
		private function stopListenData():void 
		{
			if (screenData != null && screenData.updateSignal != null)
			{
				screenData.updateSignal.remove(onDataUpdate);
			}
		}
		
		override public function dispose():void {
			TweenMax.killDelayedCallsTo(callRefresh);
			super.dispose();
			
			Assets.removeBackground(backgroundBitmapData);
			UI.disposeBMD(backgroundBitmapData);
			backgroundBitmapData = null;
			
			if (backgroundImage) {
				UI.destroy(backgroundImage);
				backgroundImage = null;
			}
		}
	}
}