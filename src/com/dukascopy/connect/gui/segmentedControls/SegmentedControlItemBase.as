package com.dukascopy.connect.gui.segmentedControls 
{
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Alexey
	 */
	public class SegmentedControlItemBase extends Sprite
	{
		protected var _data:Object;
		protected var _autosized:Boolean = true;
		protected var _viewWidth:int = 10;
		protected var _viewHeight:int = 40;
		
		public var isFirst:Boolean = false;
		public var isLast:Boolean = false;
		public var index:int = -1;
		protected var _selected:Boolean = false;
		
	
		public function SegmentedControlItemBase() {
			
		}
		
		// Override 
		public function setData(data:Object):void	{	_data = data;		}		
		public function setWidth(w:int):void{
			_viewWidth = w;
			updateViewPort();
		}	
		
		
		protected function updateViewPort():void 
		{
			if (_autosized) {
				//rerender to auto sized width 
			}else {
				// render to fit _viewWidth
			}
		}
		
		protected function onSelectionChange():void 
		{
			
		}
		
		protected function onAutoSizeChange():void 
		{
			
		}
		
		public function dispose():void	{	}		
		public function get autosized():Boolean 	{		return _autosized;	}		
		public function set autosized(value:Boolean):void 
		{
			_autosized = value;
			onAutoSizeChange();
		}
		

		
		public function get selected():Boolean 	{		return _selected;	}		
		public function set selected(value:Boolean):void 	{
			_selected = value;
			onSelectionChange();
			
		}
		
		public function get viewWidth():int 	{		return _viewWidth;	}		
		public function set viewWidth(value:int):void 	{	
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
		
	
		
		

		
		
		
		
	}

}