package com.dukascopy.connect.screens.promoEvent {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.promoEvent.PromoEvent;
	import com.dukascopy.connect.gui.list.List;
	import com.dukascopy.connect.gui.list.renderers.ListPromoEvent;
	import com.dukascopy.connect.gui.preloader.Preloader;
	import com.dukascopy.connect.gui.tools.HorizontalPreloader;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.sys.promoEvents.PromoEvents;
	
	/**
	 * @author Sergey Dobarin.
	 */
	
	public class PromoEventsScreen extends BaseScreen {
		
		private var list:List;
		private var preloader:HorizontalPreloader;
		private var loadHistoryOnMouseUp:Boolean;
		private var historyLoadingScroller:com.dukascopy.connect.gui.preloader.Preloader;
		private var historyLoadingState:Boolean;
		private var needUpdate:Boolean;
		
		public function PromoEventsScreen() { }
		
		override protected function createView():void {
			super.createView();
			
			list = new List("PromoEventsScreen.list");
		//	list.setContextAvaliable(true);
			list.allowSmallListMove(true);
			list.backgroundColor = Style.color(Style.COLOR_BACKGROUND);;
			list.background = true;
			list.view.y = 0;
			_view.addChild(list.view);
			
			preloader = new HorizontalPreloader(0x629DB7);
			view.addChild(preloader);
		}
		
		override protected function drawView():void {
			
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			_params.doDisposeAfterClose = true;
			list.setWidthAndHeight(_width, _height);
			
			view.graphics.beginFill(0xFFFFFF);
			view.graphics.drawRect(0, 0, _width, _height);
			view.graphics.endFill();
			
			PromoEvents.S_EVENTS.add(showContent);
			PromoEvents.S_LOAD_START.add(showLoader);
			PromoEvents.S_LOAD_END.add(hidePreloader);
			preloader.setSize(_width, int(Config.FINGER_SIZE * .07));
			preloader.y = 0;
			showContent(false);
		}
		
		private function updateList():void 
		{
			if (isDisposed)
			{
				return;
			}
			if (list != null)
			{
				list.refresh(true, true);
			}
		}
		
		private function showContent(shoNewEventsItem:Boolean = true):void 
		{
			if (isDisposed)
			{
				return;
			}
			
			if (list != null && list.getScrolling() == true)
			{
				needUpdate = true;
				return;
			}
			
			var items:Vector.<PromoEvent>;
			
			if (PromoEvents.getEvents() != null)
			{
				items = PromoEvents.getEvents().concat();
			}
			else{
				items = PromoEvents.getEvents();
			}
			
			if (PromoEvents.eventsResponded == true)
			{
				shoNewEventsItem = true;
			}
			
			var newEventSoon:PromoEvent;
			if (shoNewEventsItem && (items == null || items.length == 0))
			{
				items = new Vector.<PromoEvent>();
				newEventSoon = new PromoEvent(null);
				newEventSoon.type = PromoEvent.TYPE_NEW_EVENT_SOON;
				items.push(newEventSoon);
			}
			else{
				if (items == null)
				{
					items = new Vector.<PromoEvent>();
				}
				newEventSoon = new PromoEvent(null);
				newEventSoon.type = PromoEvent.TYPE_NEW_EVENT_SOON;
				items.push(newEventSoon);
			}
			
			if (items == null || items.length == 0)
			{
				list.view.visible = false;
			}
			else
			{
				list.activate();
				list.S_ITEM_TAP.add(onItemTap);
				list.view.visible = true;
				list.setData(items, ListPromoEvent);
			}
		}
		
		private function onListMove(position:Number):void {
			if (position > 0) {
				if (!historyLoadingState) {
					var positionScroller:int = Config.FINGER_SIZE*.35 + Config.APPLE_TOP_OFFSET + position - Config.FINGER_SIZE;
					
					if (positionScroller > Config.FINGER_SIZE * 1.0) {
						loadHistoryOnMouseUp = true;
						positionScroller = Config.FINGER_SIZE * 1.0;
					} else {
						loadHistoryOnMouseUp = false;
					}
					
					if (historyLoadingScroller == null) {
						var loaderSize:int = Config.FINGER_SIZE * 0.6;
						if (loaderSize%2 == 1)
							loaderSize ++;
						
						historyLoadingScroller = new Preloader(loaderSize, ListLoaderShapeRed);
						_view.addChild(historyLoadingScroller);
						/*if (chatTop != null && chatTop.view != null && _view.contains(chatTop.view))
						{
							_view.setChildIndex(chatTop.view, _view.numChildren - 1);
						}*/
					}
					
					historyLoadingScroller.y = Config.FINGER_SIZE * .35 + Config.APPLE_TOP_OFFSET - Config.FINGER_SIZE * .5;
					historyLoadingScroller.x = int(_width * .5);
						
					historyLoadingScroller.show(true, false);
					
					historyLoadingScroller.rotation = positionScroller * 100 / Config.FINGER_SIZE;
					historyLoadingScroller.y = positionScroller;
				}
			}
			else if (position == 0)
			{
				hideHistoryLoader();
			}
		}
		
		private function hidePreloader():void 
		{
			if (hideHistoryLoader != null)
			{
				hideHistoryLoader;
			}
			
			preloader.stop();
		}
		
		private function showLoader():void 
		{
			if (historyLoadingState == true)
			{
				
			}
			else{
				preloader.start();
			}
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			if (_isDisposed)
				return;
			
			if (list != null && list.view.visible == true) {
				list.activate();
				list.S_ITEM_TAP.add(onItemTap);
				list.S_MOVING.add(onListMove);
				list.S_UP.add(onListTouchUp);
				list.S_STOPED.add(onScrollStopped);
			}
			if (list.data == null)
			{
				PromoEvents.getEvents();
			}
		}
		
		private function onScrollStopped(val:Number):void {
			if (isActivated == false)
				return;
			if (historyLoadingState == false)
			{
				hideHistoryLoader();
			}
			
			if (needUpdate == false)
				return;
			needUpdate = false;
			showContent();
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed)
				return;
			if (list != null) {
				list.deactivate();
				list.S_ITEM_TAP.remove(onItemTap);
				list.S_MOVING.remove(onListMove);
				list.S_UP.remove(onListTouchUp);
				list.S_STOPED.remove(onScrollStopped);
			}
		}
		
		private function onListTouchUp():void {
			if (loadHistoryOnMouseUp) {
				loadHistoryOnMouseUp = false;
				
				PromoEvents.refreshImmediately();
			}
		}
		
		override public function dispose():void {
			super.dispose();
			
			if (list != null)
				list.dispose();
			list = null;
			if (preloader != null){
				preloader.dispose();
				preloader = null;
			}
			if (historyLoadingScroller) {
				historyLoadingScroller.dispose();
				historyLoadingScroller = null;
			}
			
			PromoEvents.S_EVENTS.remove(showContent);
			PromoEvents.S_LOAD_START.remove(showLoader);
			PromoEvents.S_LOAD_END.remove(hidePreloader);
		}
		
		private function hideHistoryLoader():void {
			if (historyLoadingState) {
				historyLoadingState = false;
				if (historyLoadingScroller != null) {
					historyLoadingScroller.hide();
				}
			}
			if (historyLoadingScroller != null) {
				historyLoadingScroller.hide();
			}
		}
		
		private function onItemTap(data:Object, n:int):void {
			if (data == null || (data is PromoEvent) == false)
				return;
			var event:PromoEvent = data as PromoEvent;
			if (event.type == PromoEvent.TYPE_NEW_EVENT_SOON) {
				return;
			}
			MobileGui.changeMainScreen(
				PromoEventScreen,
				{
					data:event,
					backScreen:MobileGui.centerScreen.currentScreenClass, 
					backScreenData:this.data
				}
			);
		}
	}
}