package com.dukascopy.connect.gui.segmentedControls 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.signals.Signal;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author Alexey
	 */
	public class SegmentedControls extends Sprite 
	{
		
		private var _rendererClass:Class;
		private var _dataArray:Array = [];
		private var _addedButtons:Array = [];
		
		private var _viewWidth:int = 0;
		private var _viewHeight:int = 0;
		private var _fitToView:Boolean = true;
			
		public var S_ITEM_CLICKED:Signal = new Signal("SegmentedControls.S_ITEM_CLICKED");
		
		private var _selectedIndex:int = -1;		

		
		public function SegmentedControls() 
		{
			super();			
		}
			
		
		public function activate():void	{
			PointerManager.addTap(this,onTap);
		}
		
		public function deactivate():void	{
			PointerManager.removeTap(this,onTap);
		}
		
		
		private static var tempPoint:Point = new Point();
		private function onTap(e:Event = null):void {
		
			var index:int = getIndexByX(MobileGui.stage.mouseX);
			//trace("Tap", index);
			S_ITEM_CLICKED.invoke(index);			
		}			
		
		private function getIndexByX(_x:int):int		{
			var result:int = -1;
				if(totalCount>0){ // redraw all buttons to fit width
					var l:int = _addedButtons.length;
					var rendererItem:SegmentedControlItemBase;
					for (var i:int = 0; i < l; i++) {
						rendererItem = _addedButtons[i];
						tempPoint.x = 0;
						tempPoint.y = 0;
						var coord:Point =  rendererItem.localToGlobal(tempPoint);
						if (coord.x <= _x && coord.x + rendererItem.width >= _x) {
							result = i;
						}
					}					
				}	
			return result;			
		}
		
		
		
		
		public function setData(d:Array):void	{
			_dataArray = d;
			createButtons();
			updateViewPort();
		}
		
		
		private function createButtons():void 
		{
			_addedButtons.length = 0;
			const l:int = _dataArray.length;
			var rendererItem:SegmentedControlItemBase;
			for (var i:int = 0; i < l; i++)  {
				rendererItem  = getRenderer();				
				rendererItem.index = i;
				rendererItem.isFirst = i == 0;
				rendererItem.isLast = i == l;
				rendererItem.selected = i == _selectedIndex;
				rendererItem.viewHeight = Config.FINGER_SIZE*.8;
				rendererItem.setData(_dataArray[i]);
				addChild(rendererItem);
				_addedButtons[_addedButtons.length] = rendererItem;			
			}
		}
		
		
				
		
		
		private function getRenderer():SegmentedControlItemBase	{
			return new _rendererClass; // must extend SegmentedControlItemBase.as
		}
		
		
		public function setRendererClass(cls:Class):void	{
			_rendererClass = cls;
			//renderButtons();
		}
		
		
		
		public  function setSize(w:int, h:int):void
		{
			_viewWidth  = w;
			_viewHeight = h;
			updateViewPort();
		}
		
		private function updateViewPort():void 	{
			rerenderButtons();			
		}
		
		
		
		private function rerenderButtons():void 
		{
			var itemWidth:int = _viewWidth / totalCount;
			var buttonItem:SegmentedControlItemBase;
			
			if (_fitToView) {
				if(totalCount>0){ // redraw all buttons to fit width
					var l:int = _addedButtons.length;
					for (var i:int = 0; i < l; i++) {
						buttonItem = _addedButtons[i];
						buttonItem.autosized = false;
						buttonItem.setWidth(itemWidth);
						buttonItem.x = itemWidth * i;
					}
				}
			}else {
				// do nothing buttons automaticly 
					if (totalCount > 0) { // redraw all buttons to fit width
						var g:int = _addedButtons.length;
						for (var j:int = 0; j< g; j++) {
							buttonItem = _addedButtons[j];
							buttonItem.autosized = true;
							
						}
				}
			}
		}
		
		
		
		public function removeAllButtons():void
		{
			var buttonItem:SegmentedControlItemBase;
			var l:int = _addedButtons.length;
			for (var i:int = 0; i < l; i++) {
				buttonItem = _addedButtons[i];
				buttonItem.dispose();
			}
			_addedButtons.length = 0;	
		}
		
		
		
		
		private function onSelectedIndexChange():void 
		{
			// select item by _selectedIndex
			var buttonItem:SegmentedControlItemBase;
			var l:int = _addedButtons.length;
			for (var i:int = 0; i < l; i++) {
				buttonItem = _addedButtons[i];
				buttonItem.selected = _selectedIndex == i;
			}
		}
		
		
		
		
		
		private function get totalCount():int	{	return _dataArray.length;	}		
		public function get selectedIndex():int 	{	return _selectedIndex	;	}		
		public function set selectedIndex(value:int):void 
		{
			_selectedIndex = value;
			onSelectedIndexChange();
		}
		
		
		
		public function get viewWidth():int 	{		return _viewWidth;	}		
		public function set viewWidth(value:int):void 
		{
			if (_viewWidth == value) return;
			_viewWidth = value;
			updateViewPort();
		}
		
		public function get viewHeight():int 	{		return _viewHeight;	}		
		public function set viewHeight(value:int):void 
		{
			if (_viewHeight == value) return;
			_viewHeight = value;
			updateViewPort(); 
		}
		
	
		
		
		public function dispose():void
		{
			deactivate();
			removeAllButtons();
			_dataArray.length = 0;
			_selectedIndex = -1;
			// dispose all buttons 
			// dispose signals 
			
			
		}
		
		
		
		
		
		
	
		
		
		
		
	}

}