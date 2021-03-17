package com.dukascopy.connect.screens.marketplace 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.coinMarketplace.stat.MarketplaceStatistic;
	import com.dukascopy.connect.data.coinMarketplace.stat.StatPointData;
	import com.dukascopy.connect.data.coinMarketplace.stat.StatSlice;
	import com.dukascopy.connect.gui.graph.lineChart.LineChart;
	import com.dukascopy.connect.gui.tabs.FilterTabs;
	import com.dukascopy.connect.gui.tools.HorizontalPreloader;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import flash.events.Event;
	/**
	 * ...
	 * @author Igor Bloom
	 */
	public class ChartsBase extends Charts{
		static public const TAB_ASK:String = "BUY";
		static public const TAB_BID:String = "SELL";
		
		private var lineChart:LineChart;
		private var locked:Boolean;
		private var tabs:FilterTabs;
		private var selectedFilter:String;
		private var horizontalLoader:HorizontalPreloader;
		private var currentData:StatSlice;
		private var dataLoading:Boolean;
		
		public function ChartsBase() {
			
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			tabs = new FilterTabs();
			tabs.setBackgroundColor(0x0A1842);
			tabs.tabBackgroundBorderColor = 0xFFFFFF;
			tabs.tabBackgroundBorderSelectedColor = 0xFFFFFF;
			tabs.tabBackgroundColor = 0x0A1842;
			tabs.tabBackgroundSelectedColor = 0xFFFFFF;
			tabs.tabTextColor = 0xFFFFFF;
			tabs.tabTextSelectedColor = 0x0A1842;
			
			tabs.add(Lang.bidSide, TAB_BID, false, "l");
			tabs.add(Lang.askSide, TAB_ASK, true, "r");
			_view.addChild(tabs.view);
			
			tabs.setWidthAndHeight(_width, Config.FINGER_SIZE * 1.6);
			tabs.view.y = _height - tabs.height;
			
			lineChart.setSizes(_width, _height - topBar.trueHeight - tabs.height);
			lineChart.draw(null);
			lineChart.y = topBar.y + topBar.trueHeight;
			
			horizontalLoader.setSize(_width, int(Config.FINGER_SIZE * .07));
			horizontalLoader.y = topBar.y + topBar.trueHeight;
			
			tabs.setSelection(TAB_BID);
			selectedFilter = TAB_BID;
			dataLoading = true;
			MarketplaceStatistic.S_DATA_UPDATE.add(onDataUpdate);
			getData();
		}
		
		private function getData():void 
		{
			horizontalLoader.start();
			TweenMax.killDelayedCallsTo(getData);
			lock();
			MarketplaceStatistic.update(selectedFilter);
		}
		
		private function lock():void 
		{
			locked = true;
			deactivateScreen();
			if (topBar != null)
				topBar.activate();
		}
		
		private function unlock():void 
		{
			locked = false;
			activateScreen();
		}
		
		private function onDataUpdate(points:StatSlice, updated:Boolean):void 
		{
			dataLoading = false;
			if (isDisposed)
			{
				return;
			}
			
			horizontalLoader.stop();
			
			unlock();
			
			topBar.hideAnimation();
			
			if (updated == false)
			{
				if (currentData == null && points != null)
				{
					lineChart.draw(points.data);
				}
				else if (updated == false && ((currentData == null && points != null) || (currentData != null && points != null && currentData.type != points.type)))
				{
					lineChart.draw(points.data);
				}
				if (points != null)
				{
					currentData = points;
				}
			}
			else
			{
				lineChart.draw(points.data, points.getIndexesShift());
				if (points != null)
				{
					currentData = points;
				}
			}
		}
		
		/*override protected function onRefresh():void
		{
			topBar.showAnimationOverButton("refreshBtn", false);
			getData();
		}*/
		
		override protected function createView():void {
			super.createView();
			
			lineChart = new LineChart();
			lineChart.S_REQUEST_DATA.add(onUserRequest);
			view.addChild(lineChart);
			
			horizontalLoader = new HorizontalPreloader(0xF6951D);
			view.addChild(horizontalLoader);
		} 
		
		private function onUserRequest(left:Boolean, right:Boolean):void 
		{
			if (dataLoading == true)
			{
				return;
			}
			dataLoading = true;
			
			horizontalLoader.start();
			TweenMax.killDelayedCallsTo(getData);
			lock();
			MarketplaceStatistic.update(selectedFilter, true, false);
		}
		
		override public function activateScreen():void {
			if (_isDisposed == true)
				return;
			super.activateScreen();
			
			if (locked == true)
			{
				return;
			}
			
			if (tabs != null) {
				if (tabs.S_ITEM_SELECTED != null)
					tabs.S_ITEM_SELECTED.add(onTabItemSelected);
				tabs.activate();
			}
	//		PointerManager.addDown(lineChart, onChartTap);
	//		PointerManager.addUp(lineChart, onChartUp);
			
			lineChart.activate();
		}
		
		private function onChartUp(e:Event):void 
		{
			PointerManager.removeMove(lineChart, updateChartValue);
		}
		
		private function onChartTap(e:Event):void 
		{
			updateChartValue(e);
			PointerManager.addMove(lineChart, updateChartValue);
		}
		
		private function updateChartValue(e:Event):void 
		{
			lineChart.showValue(lineChart.mouseX);
		}
		
		private function onTabItemSelected(id:String):void {
			selectedFilter = id;
			TweenMax.delayedCall(1, getData, null, true);
		}
		
		override public function deactivateScreen():void {
			if (_isDisposed == true)
				return;
			super.deactivateScreen();
			
			if (tabs != null) {
				if (tabs.S_ITEM_SELECTED != null)
					tabs.S_ITEM_SELECTED.remove(onTabItemSelected);
				tabs.deactivate();
			}
			
			PointerManager.removeDown(lineChart, onChartTap);
			PointerManager.removeUp(lineChart, onChartUp);
			PointerManager.removeMove(lineChart, updateChartValue);
			
			lineChart.deactivate();
		}
		
		override protected function drawView():void {
			super.drawView();
		}
		
		override public function dispose():void {
			super.dispose();
			
			TweenMax.killDelayedCallsTo(getData);
			if (lineChart != null)
			{
				lineChart.dispose();
				lineChart = null;
			}
			
			if (tabs != null)
				tabs.dispose();
			tabs = null;
			
			MarketplaceStatistic.S_DATA_UPDATE.remove(onDataUpdate);
		}
		
		override public function onShowComplete():void {
			
		}
	}
}