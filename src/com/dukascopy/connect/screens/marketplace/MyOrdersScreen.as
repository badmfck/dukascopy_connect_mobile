package com.dukascopy.connect.screens.marketplace 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.HitZoneData;
	import com.dukascopy.connect.data.coinMarketplace.MarketplaceScreenData;
	import com.dukascopy.connect.data.coinMarketplace.TradingOrder;
	import com.dukascopy.connect.data.coinMarketplace.TradingOrderParser;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.customActions.RemoveOrderAction;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.List;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.gui.list.renderers.trade.OrderListItem;
	import com.dukascopy.connect.gui.tabs.FilterTabs;
	import com.dukascopy.connect.gui.tools.HorizontalPreloader;
	import com.dukascopy.connect.gui.topBar.TopBarScreen;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.context.ContextMenuScreen;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.bankManager.BankManager;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.type.MainColors;
	import com.dukascopy.langs.Lang;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class MyOrdersScreen extends BaseScreen 
	{
		private const DEFAULT_BACKGROUND_COLOR:uint = 0xffffff;
		static public const TAB_SELL:String = "tabSell";
		static public const TAB_ALL:String = "tabAll";
		static public const TAB_BUY:String = "tabBuy";
		
		private var topBar:TopBarScreen;
		private var list:List;
		
		private var horizontalLoader:HorizontalPreloader;
		private var backClip:Sprite;
		private var screenData:MarketplaceScreenData;
		private var tabs:FilterTabs;
		private var selectedFilter:String;
		
		public function MyOrdersScreen() { }
		
		override protected function createView():void {
			super.createView();
			backClip = new Sprite();
			_view.addChild(backClip);
			
			list = new List("Chat");
			list.setMask(true);
			list.setAdditionalBottomHeight(Config.FINGER_SIZE * .5);
			list.backgroundColor = MainColors.WHITE;
			list.background = true;
			_view.addChild(list.view);
			
			topBar = new TopBarScreen();
			_view.addChild(topBar);
			
			horizontalLoader = new HorizontalPreloader(0xF6951D);
			view.addChild(horizontalLoader);
			
			tabs = new FilterTabs();
			tabs.add(Lang.all.toUpperCase(), TAB_ALL, true, "l");
			tabs.add(Lang.sell.toUpperCase(), TAB_SELL);
			tabs.add(Lang.BUY.toUpperCase(), TAB_BUY, false, "r");
			_view.addChild(tabs.view);
		}
		
		/**
		 * @param	data - Object with initialized params (for exaple - list of searched conversations or etc..)
		 */
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			
			if (data != null && "screeenData" in data && data.screeenData != null && data.screeenData is MarketplaceScreenData)
			{
				screenData = data.screeenData as MarketplaceScreenData;
			}
			
			topBar.setData(Lang.myOrders, true, null);
			
			backClip.graphics.clear();
			backClip.graphics.beginFill(DEFAULT_BACKGROUND_COLOR);
			backClip.graphics.drawRect(0, 0, _width, _height - topBar.trueHeight);
			backClip.graphics.endFill();
			backClip.y = topBar.trueHeight;
			
			horizontalLoader.setSize(_width, int(Config.FINGER_SIZE * .07));
			
			tabs.view.y = topBar.y + topBar.trueHeight;
			tabs.setWidthAndHeight(_width, Config.FINGER_SIZE);
			
			startListenData();
			
			BankManager.S_ORDER_REMOVED.add(onOrderRemoved);
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
		
		private function onDataUpdate(newData:Object = null):void 
		{
			horizontalLoader.stop(false);
			if (screenData != null && screenData.myOrders != null)
			{
				var dataProvider:Array = screenData.myOrders();
				
				if (dataProvider != null)
				{
					var newListData:Array;
					newListData = getModels(dataProvider as Array);
					if (selectedFilter == TAB_BUY)
					{
						newListData = getBuy(newListData);
					}
					else if (selectedFilter == TAB_SELL)
					{
						newListData = getSell(newListData);
					}
					list.setData(newListData, OrderListItem);
				}
				else
				{
					list.setData(null, OrderListItem);
				}
			}
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
			
			backClip.width = _width;
			backClip.height = _height;
			
			horizontalLoader.y = topBar.y + topBar.trueHeight;
			
			list.view.y = tabs.view.y + tabs.height;
			list.setWidthAndHeight(_width, _height - list.view.y);
		}
		
		override public function activateScreen():void {
			
			if (_isActivated)
				return;
			
			if (isDisposed)
				return;
			
			super.activateScreen();
			
			if (topBar != null)
				topBar.activate();
			
			list.activate();
			list.S_ITEM_TAP.add(onItemTap);
			
			if (tabs != null) {
				if (tabs.S_ITEM_SELECTED != null)
					tabs.S_ITEM_SELECTED.add(onTabItemSelected);
				tabs.activate();
			}
		}
		
		private function onTabItemSelected(id:String):void {			
			selectedFilter = id;
			onDataUpdate();
		}
		
		private function onItemTap(data:Object, n:int):void {
			
			var selectedItem:ListItem;
			var lastHitzoneObject:Object;
			var lhz:String;
			
			selectedItem = list.getItemByNum(n);
			lastHitzoneObject =  selectedItem.getLastHitZoneObject();
			
			var actionsTap:Vector.<IScreenAction> = new Vector.<IScreenAction>();
		//	actionsTap.push(new EditOrderAction(data as TradingOrder));
			actionsTap.push(new RemoveOrderAction(data as TradingOrder));
			
			var messageContentHitzone:HitZoneData = (selectedItem.renderer as OrderListItem).getMessageHitzone(selectedItem);
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
		}
		
		override public function deactivateScreen():void {
			if (!_isActivated)
				return;
			
			super.deactivateScreen();
			
			if (topBar != null)
				topBar.deactivate();
			list.deactivate();
			
			if (tabs != null) {
				if (tabs.S_ITEM_SELECTED != null)
					tabs.S_ITEM_SELECTED.remove(onTabItemSelected);
				tabs.deactivate();
			}
		}
		
		override public function clearView():void {
			if (list != null)
				list.dispose();
			list = null;
			
			if (backClip != null)
				UI.destroy(backClip);
			backClip = null;
			
			if (topBar != null)
				topBar.dispose();
			topBar = null;
			
			if (tabs != null)
				tabs.dispose();
			tabs = null;
			
			if (horizontalLoader != null)
			{
				horizontalLoader.dispose();
				horizontalLoader = null;
			}
			
			if (screenData != null && screenData.updateSignal != null)
			{
				screenData.updateSignal.remove(onDataUpdate);
			}
			
			BankManager.S_ORDER_REMOVED.remove(onOrderRemoved);
			
			super.clearView();
		}
		
		override public function dispose():void {
			super.dispose();
		}
	}
}