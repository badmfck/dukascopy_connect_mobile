package com.dukascopy.connect.gui.tabs {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.tabs.TabsItemBottom;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.mobileClip.MobileClip;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;

	import com.greensock.TweenMax;
	import com.greensock.easing.Back;
	import com.greensock.easing.Expo;
	import com.telefision.sys.signals.Signal;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.system.Capabilities;
	
	/**
	 * @author Roman Kulyk
	 */
	
	public class TabBar extends MobileClip {
		
		public var S_ITEM_SELECTED:Signal = new Signal("Tabs.MobileClip");
		
		private var stock:Array/*TabsItemBottom*/;
		private var boxItems:Sprite;
		private var boxItemsCont:Sprite;
		private var _width:int=320;
		private var _height:int = Config.FINGER_SIZE_DOUBLE;
		
		public var busy:Boolean;
		
		private static var pt:Point;
		private var isActive:Boolean;
		// collapse - 
		private var _isCollapsed:Boolean = true;
		private var _allowItemTap:Boolean = false;
		private var _collapsable:Boolean = true;
		private var COLLAPSE_OFFSET:Number = Config.FINGER_SIZE_DOT_5;
		public var offsetChangeCallback:Function;
		public var hitZoneSprite:Sprite;
		
		private var boxBg:Shape;
		private var itemBgColor:uint;
		private var itemTextColor:uint;
		private var itemBgAlpha:Number;
		private var selectionBgColor:uint;
		private var selectedIndex:String;
		private var lineBitmap:Bitmap;
		private var bottomOffset:int = 0;
		private var selectedBackgroundColor:Number;
		
		public function TabBar(itemBgColor:uint = 0xFFFFFF, itemTextColor:uint = 0x0, itemBgAlpha:Number = 1, selectionBgColor:uint = 0xEA3311, collapsable:Boolean = false, drawLine:Boolean  = false, selectedBackgroundColor:Number = NaN){
			this.selectionBgColor = selectionBgColor;
			this.itemBgAlpha = itemBgAlpha;
			this.itemTextColor = itemTextColor;
			this.itemBgColor = itemBgColor;
			this.selectedBackgroundColor = selectedBackgroundColor;
			_view = new Sprite();
			
			boxBg = new Shape();
			_view.addChild(boxBg);
			
			boxItems = new Sprite();
			boxItemsCont = new Sprite();
			boxItems.addChild(boxItemsCont);
			_view.addChild(boxItems);			
			stock = [];
			busy = false;
						
			// Collapse functions
			_collapsable = collapsable;
			if (_collapsable){
				hitZoneSprite = new Sprite();
				_view.addChild(hitZoneSprite);
				hitZoneSprite.graphics.beginFill(0xff0000, 0);
				hitZoneSprite.graphics.drawRect(0, 0, 10, 10);
				hitZoneSprite.graphics.endFill();
				
				if (_isCollapsed){
					_allowItemTap = false;
					collapse(0);
				}else{
					_allowItemTap = true;
					expand(0);
				}
			}else{
				_allowItemTap = true;
			}
			
			if(drawLine == true){
				lineBitmap = new Bitmap();
				_view.addChild(lineBitmap);
				lineBitmap.bitmapData = new BitmapData(1, 1, false, 0xc5d1db);
			}
			// END collapse functions
		}		
			
		public function add(name:String, id:String,icon:/*MovieClip*/DisplayObject=null,iconDown:/*MovieClip*/DisplayObject=null,bg:ImageBitmapData=null,doSelection:Boolean=true,scale:Number=1, drawComponent:Boolean = true):void {
			if (stock == null)
				return;
			var i:TabsItemBottom = getItemById(id);
			if (i != null)
				return;				
			i = new TabsItemBottom(name, id, stock.length, icon, iconDown, bg, itemBgColor, itemBgAlpha, itemTextColor, doSelection, scale, selectionBgColor, selectedBackgroundColor);
			
			stock.push(i);
			i.tapCallback=function():void{callTap(id)};
			boxItemsCont.addChild(i.view);
			if (drawComponent == true)
			{
				updateView();
			}
		}			
		
		public function addToIndex(index:int, name:String, id:String,icon:/*MovieClip*/DisplayObject=null,iconDown:/*MovieClip*/DisplayObject=null,bg:ImageBitmapData=null,doSelection:Boolean=true,scale:Number=1):void {
			if (stock == null)
				return;
			var i:TabsItemBottom = getItemById(id);
			if (i != null)
				return;				
			i = new TabsItemBottom(name, id, stock.length, icon, iconDown, bg, itemBgColor, itemBgAlpha, itemTextColor, doSelection, scale, selectionBgColor, selectedBackgroundColor);
			
			stock.splice(index, 0, i);
			i.tapCallback = function():void{callTap(id)};
			boxItemsCont.addChild(i.view);
			updateView();
		}
		
		public function callTap(id:String):void {
			if (_allowItemTap ==  false) {
				return;
			}
			if (busy == true)
				return;
			var l:int = stock.length;
			for (var n:int = 0; n < l; n++) {
				stock[n].select();
			}
			var tab:TabsItemBottom = getItemById(id);
			if (tab == null)
				return;
			tab.select(true);
			S_ITEM_SELECTED.invoke(id);
		}
		
		public function selectTap(id:String):void {
			selectedIndex = id;
			var l:int = stock.length;
			for (var n:int = 0; n < l; n++) {
				stock[n].select();
			}
			if (id == null)
				return;
			var tab:TabsItemBottom = getItemById(id);
			if (tab == null)
				return;
			tab.select(true);
		}
		
		public function selectNotification(id:String, val:Boolean = true):void {
			if (id == null)
				return;
			var tab:TabsItemBottom = getItemById(id);
			if (tab == null)
				return;
			tab.notificate(val);
		}
		
		public function selectBlink(id:String, val:Boolean = true):void {
			if (id == null)
				return;
			var tab:TabsItemBottom = getItemById(id);
			if (tab == null)
				return;
			tab.blink(val);
		}
		
		public function activate():void {
			isActive = true;
			if (_collapsable && boxItems != null){					
				PointerManager.addDown(boxItems, onMouseDown);			
				PointerManager.addDown(hitZoneSprite, onMouseDown);			
			}
		}
		
		public function deactivate():void {
			isActive = false;
			if(boxItems != null){
				PointerManager.removeDown(hitZoneSprite, onMouseDown);
				PointerManager.removeDown(boxItems, onMouseDown);
			}
		}
		
		override public function dispose():void {			
			super.dispose();
			deactivate();
			stopCollapseTimer();
			UI.destroy(lineBitmap);
			lineBitmap = null;
			if (hitZoneSprite != null){
				UI.destroy(hitZoneSprite);
				hitZoneSprite = null;
			}
			if (stock != null) {
				var l:int = stock.length;
				for (var n:int = 0; n < l; n++){
					stock[n].dispose();
				}
			}
			stock = null;
			
			if (S_ITEM_SELECTED != null)
				S_ITEM_SELECTED.dispose();
			S_ITEM_SELECTED = null;			
				
			if (boxItems != null)
				boxItems.graphics.clear();
			boxItems = null;
			if (boxItemsCont != null)
				boxItemsCont.graphics.clear();
			boxItemsCont = null;
			
			pt = null;
		}
		
		public function setWidthAndHeight(w:int, h:int, bottomOffset:int = 0):void {
			_width = w;
			_height = h;
			this.bottomOffset = bottomOffset;
			updateView();
		}
		
		/*public function displayNewItemsInTab(tabId:String, missedNum:int):void 
		{
			var tab:TabsItemBottom = getItemById(tabId);
			if (tab)
			{
				tab.displayNewItemsNum(missedNum);
			}
		}*/
		
		private function onMouseDown(e:Event):void 	{			
			stopCollapseTimer();
			
			expand();
			PointerManager.addUp(MobileGui.stage, onStageUp);		
		}
		
		private function onStageUp(e:Event):void {
			_allowItemTap = true;
			startCollapseTimer();
			PointerManager.removeUp(MobileGui.stage, onStageUp);
		}
		
		public function setExpandedState(time:Number= 0):void {
			_allowItemTap = true;
			expand(time);
			startCollapseTimer();			
		}
		
		public function setCollapsedState(time:Number = 0):void {
			_allowItemTap = false;
			collapse(time);
			stopCollapseTimer();
		}
		
		private function collapse(time:Number = .3):void {
			_isCollapsed = true;
			_allowItemTap = false;
			if(hitZoneSprite!=null){
				hitZoneSprite.visible = true;
			}
			if (boxItems == null) return;
			TweenMax.killChildTweensOf(boxItems);
			TweenMax.to(boxItems, time, {y:COLLAPSE_OFFSET,ease:Back.easeOut, onUpdate:onTweenUpdate, onComplete:onTweenUpdate});
		}
			
		private function expand(time:Number = .3):void {
			_isCollapsed = false;
			if(hitZoneSprite!=null){
				hitZoneSprite.visible = false;
			}
			if (boxItems == null) return;
			TweenMax.killChildTweensOf(boxItems);
			TweenMax.to(boxItems, time, {y:0,ease:Expo.easeOut, onUpdate:onTweenUpdate, onComplete:onTweenUpdate});
		}
		
		private function onTweenUpdate():void {
			//trace(boxItems.y +" callback");
			if (offsetChangeCallback != null){
				offsetChangeCallback(boxItems.y);
			}
		}
		
		public function getCurrentOffset():Number {
			if (boxItems == null)
				return 0;			
			return boxItems.y;
		}
		
		private function startCollapseTimer():void {
			var hideTimeout:Number = 3;
			TweenMax.killDelayedCallsTo(onHideTimeoutComplete);
			TweenMax.delayedCall(hideTimeout, onHideTimeoutComplete);
		}
		
		private function stopCollapseTimer():void {
			TweenMax.killDelayedCallsTo(onHideTimeoutComplete);
		}
		
		private function onHideTimeoutComplete():void {
			//trace("HIDE PANEL ");
			collapse();
		}
		
		public function updateView():void {
			var l:int = stock.length;
			var x:int = 0;
			
			boxBg.graphics.clear();
			boxBg.graphics.beginFill(itemBgColor);
			boxBg.graphics.drawRect(0, 0, _width, _height + bottomOffset);
			
			var paddindSide:int = 0;
			//IPHONE X;
			if (Config.PLATFORM_APPLE && Config.isRetina()>0) {
				paddindSide = 10 * 3;
				x = paddindSide;
			}
			
			var itemWidth:int = (_width - paddindSide * 2) / l;
			
			for (var n:int = 0; n < l; n++) {
				if (stock[n].id==selectedIndex) {
					stock[n].rebuild(_height, itemWidth, true);
				}else{
					stock[n].rebuild(_height, itemWidth);
				}
				stock[n].view.x = x;
				stock[n].view.y = 0;
				x += stock[n].view.width;
			}	
			
			// Collapse functions
			if (_collapsable){
				if (_isCollapsed){
					boxItems.y  = COLLAPSE_OFFSET;
				}else{
					boxItems.y  = 0;
				}
			}
			if (hitZoneSprite != null) {
				hitZoneSprite.width = _width;
				hitZoneSprite.height = _height;
			}
			// end collapse functions
			
			if (lineBitmap != null){
				lineBitmap.width = _width;
			}
		}
		
		private function getItemById(id:String):TabsItemBottom {
			if (stock == null)
				return null;
			var m:int = stock.length;
			while (m--){
				if (stock[m].id == id)
					return stock[m];				
			}
			return null;
		}
		
		public function get height():int {
			return _height + bottomOffset;
		}		
	}
}