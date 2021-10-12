package com.dukascopy.connect.gui.tabs {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.TabsColorSettings;
	import com.dukascopy.connect.sys.mobileClip.MobileClip;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.telefision.sys.signals.Signal;
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * @author Ilya Shcherbakov
	 */
	
	public class FilterTabs extends MobileClip {
		
		public static var LEFT:String = "l";
		public static var RIGHT:String = "r";
		
		public static const COLOR_TAB_TEXT:uint = 0x6e92af;// 0x788B9A;
		public static const COLOR_TAB_BG:uint = 0xFFFFFF;
		public static const COLOR_TAB_BG_BORDER:uint = 0x6e92af;// 0xADB8C1;
		public static const COLOR_TAB_TEXT_SELECTED:uint = 0xFFFFFF;
		public static const COLOR_TAB_BG_SELECTED:uint = 0x6e92af;// 0x3E4755;
		public static const COLOR_TAB_BG_BORDER_SELECTED:uint = 0x6e92af;// 0x222D3D;
		public static const CORNER_RADIUS:uint = Config.FINGER_SIZE * .1;
		public var backgroundColor:uint = Style.color(Style.COLOR_BACKGROUND);
		public var tabTextColor:uint = COLOR_TAB_TEXT;
		public var tabBackgroundColor:uint = COLOR_TAB_BG;
		public var tabBackgroundBorderColor:uint = COLOR_TAB_BG_BORDER;
		public var tabTextSelectedColor:uint = COLOR_TAB_TEXT_SELECTED;
		public var tabBackgroundSelectedColor:uint = COLOR_TAB_BG_SELECTED;
		public var tabBackgroundBorderSelectedColor:uint = COLOR_TAB_BG_BORDER_SELECTED;
		
		public var S_ITEM_SELECTED:Signal = new Signal('FilterTabs.S_ITEM_SELECTED');
		
		private var stock:Array/*TabsItemRounded*/;
		
		private var _width:int;
		private var _height:int;
		
		private var tabW:int;
		private var tabH:int;
		
		private var _indexSelected:int = -1;
		private var bgVisible:Boolean = true;
		
		private var tabsWidthByText:Boolean;
		private var trueWidth:int;
		private var noticication:Array;
		
		public function FilterTabs() {
			tabBackgroundSelectedColor = Style.color(Style.FILTER_TABS_COLOR_TAB_BG_SELECTED);
			tabTextSelectedColor = Style.color(Style.FILTER_TABS_COLOR_TAB_TEXT_SELECTED);
		//	tabBackgroundBorderSelectedColor = Style.color(Style.FILTER_TABS_COLOR_TAB_BG_BORDER_SELECTED);
			tabBackgroundBorderSelectedColor = Style.color(Style.FILTER_TABS_COLOR_TAB_BG_BORDER);
			tabTextColor = Style.color(Style.FILTER_TABS_COLOR_TAB_TEXT);
			tabBackgroundBorderColor = Style.color(Style.FILTER_TABS_COLOR_TAB_BG_BORDER);
			tabBackgroundColor = Style.color(Style.FILTER_TABS_COLOR_BACKGROUND);
			
			FilterTabs.LEFT = TabsItemRounded.LEFT;
			FilterTabs.RIGHT = TabsItemRounded.RIGHT;
			createView();
			stock = [];
		}
		
		private function createView():void {
			_view = new Sprite();
		}
		
		public function add(name:String, id:String, doSelection:Boolean = false, end:String = ""):void {
			if (stock == null)
				return;
			var i:TabsItemRounded = getItemById(id);
			if (i != null)
				return;
			if (doSelection == true) {
				if (_indexSelected != -1)
					stock[_indexSelected].selection = false;
				_indexSelected = stock.length;
			}
			_view.addChild(stock[stock.push(new TabsItemRounded(name, id, doSelection, end)) - 1].getView());
		}
		
		public function callTap(e:Event):void {
			if (stock == null || stock.length == 0)
				return;
			var l:int = stock.length;
			for (var i:int = 0; i < l; i++) {
				if (_view.mouseX < stock[i].getView().x + stock[i].getView().width)
					break;
			}
			var index:int = i;
			if (index >= stock.length)
				index = stock.length - 1;
			if (_indexSelected == index)
				return;
			if (_indexSelected != -1) {
				stock[_indexSelected].selection = false;
				stock[_indexSelected].rebuild(getColors(), tabW, tabH, tabsWidthByText);
			}
			_indexSelected = index;
			stock[index].selection = true;
			stock[index].rebuild(getColors(), tabW, tabH, tabsWidthByText);
			S_ITEM_SELECTED.invoke(stock[index].id);
		}
		
		private function getColors():TabsColorSettings
		{
			var settings:TabsColorSettings = new TabsColorSettings();
			settings.tabTextColor = tabTextColor;
			settings.tabBackgroundColor = tabBackgroundColor;
			settings.tabBackgroundBorderColor = tabBackgroundBorderColor;
			settings.tabTextSelectedColor = tabTextSelectedColor;
			settings.tabBackgroundSelectedColor = tabBackgroundSelectedColor;
			settings.tabBackgroundBorderSelectedColor = tabBackgroundBorderSelectedColor;
			return settings;
		}
		
		public function setSelection(id:String, invokeSignal:Boolean = false):void
		{
			if (stock == null || stock.length == 0)
				return;
			var item:TabsItemRounded = getItemById(id);
			var index:int = stock.indexOf(item);
			if (index >= stock.length)
				index = stock.length - 1;
			if (_indexSelected == index){
				if (invokeSignal)
					S_ITEM_SELECTED.invoke(stock[index].id);
				return;
			}
			if (_indexSelected != -1) {
				stock[_indexSelected].selection = false;
				stock[_indexSelected].rebuild(getColors(), tabW, tabH, tabsWidthByText);
			}
			if(index==-1){
				return;
			}			
			_indexSelected = index;
			stock[index].selection = true;
			stock[index].rebuild(getColors(), tabW, tabH, tabsWidthByText);
			if(invokeSignal)
				S_ITEM_SELECTED.invoke(stock[index].id);
		}
		
		public function activate():void {
			PointerManager.addDown(_view, callTap);
		}
		
		public function deactivate():void {
			PointerManager.removeDown(_view, callTap);
		}
		
		public function selectNotification(id:String, val:Boolean = true):void {
			if (id == null)
				return;
			var tab:TabsItemRounded = getItemById(id);
			if (tab == null)
				return;
			if (noticication == null)
			{
				noticication = new Array();
			}
			if (noticication[id] == null)
			{
				var notifyIcon:SWFAttentionIcon2 = new SWFAttentionIcon2();
				notifyIcon.width = Config.FINGER_SIZE * .16;
				notifyIcon.height = Config.FINGER_SIZE * .16;
				notifyIcon.visible = false;
				_view.addChild(notifyIcon);
				
				noticication[id] = notifyIcon;
			}
			if (val == true)
			{
				noticication[id].visible = true;
				noticication[id].x = int(tab.getView().x + tab.getView().width - noticication[id].width - Config.FINGER_SIZE * .1);
				noticication[id].y = int(tab.getView().y - noticication[id].height * .3);
			}
			else
			{
				noticication[id].visible = false;
			}
		}
		
		public function setWidthAndHeight(w:int, h:int):void {
			if (_width == w && _height == h)
				return;
			
			_width = w;
			_height = h;
			
			_view.graphics.clear();
			_view.graphics.beginFill(backgroundColor, (bgVisible == true) ? 1 : 0);
			_view.graphics.drawRect(0, 0, _width, _height);
			_view.graphics.endFill();
			
			updateView();
		}
		
		public function removeAll():void {
			var l:int = stock.length;
			var item:TabsItemRounded ;
			while (stock.length>0){
				item = stock.pop();/*.getView();*/
				_view.removeChild(item.getView());
				item.dispose();
			}

			stock = [];
			//_view.removeChildren();
			_indexSelected = -1;
		}

		private function updateView():void {
			var l:int = stock.length;
			tabW = (_width - Config.FINGER_SIZE_DOT_25 * 2) / l;
			tabH = _height * .66;
			var tabY:int = (_height - tabH) * .5;
			var x:int = Config.FINGER_SIZE_DOT_25;
			for (var i:int = 0; i < l; i++) {
				stock[i].rebuild(getColors(), tabW, tabH, tabsWidthByText);
				stock[i].getView().x = x;
				stock[i].getView().y = tabY;
				x += stock[i].getView().width;
			}
			trueWidth = x + Config.FINGER_SIZE_DOT_25;
		}
		
		public function getCurrentItem():TabsItemRounded {
			if (stock == null)
				return null;
			var m:int = stock.length;
			if (_indexSelected != -1)
				return	stock[_indexSelected];
			return null;
		}

		private function getItemById(id:String):TabsItemRounded {
			if (stock == null)
				return null;
			var m:int = stock.length;
			while (m--) {
				if (stock[m].id == id)
					return stock[m];
			}
			return null;
		}
		
		public function get height():int {
			return _height;
		}
		
		public function get width():int {
			return (tabsWidthByText == true) ? trueWidth : _width;
		}
		
		public function setBackgroundColor(value:uint):void {
			if (value == backgroundColor) return;		
			backgroundColor = value;
			_view.graphics.clear();
			_view.graphics.beginFill(backgroundColor, (bgVisible == true) ? 1 : 0);
			_view.graphics.drawRect(0, 0, _width, _height);
			_view.graphics.endFill();
		}
		
		override public function dispose():void {
			deactivate();
			S_ITEM_SELECTED.dispose();
			
			if (noticication != null)
			{
				for each (var item:Sprite in noticication) 
				{
					if (_view.contains(item))
					{
						try
						{
							_view.removeChild(item);
						}
						catch (e:Error)
						{
							
						}
					}
				}
				noticication = null;
			}
			
			super.dispose();
			if (stock != null) {
				while (stock.length != 0) {
					stock[0].dispose();
					stock.splice(0, 1);
				}
			}
			stock = null;
		}
		
		public function updateLabels(names:Array):void {
			for (var i:int = 0; i < stock.length; i++)
				stock[i].name = names[i];
			updateView();
		}
		
		public function setBackgroundVisible(val:Boolean):void {
			bgVisible = val;
		}
		
		public function setTabsWidthByText(val:Boolean):void {
			tabsWidthByText = val;
		}

		public function get indexSelected():int {
			return _indexSelected;
		}
	}
}