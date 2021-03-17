package com.dukascopy.connect.gui.components.selector 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.HitZoneData;
	import com.dukascopy.connect.data.SelectorItemData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.errors.ApplicationError;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class Selector extends Sprite
	{
		private var _dataProvider:Vector.<SelectorItemData>;
		private var _itemRenderer:Class = TextSelectorItem;
		private var _maxWidth:Number;
		private var _layout:String;
		private var _selectedItemIndex:int;
		private var items:Array;
		private var container:Sprite;
		private var hitzones:Array;
		private var _gap:int;
		
		static public const LAYOUT_HORIZONTAL:String = "layoutHorizontal";
		static public const LAYOUT_VERTICAL:String = "layoutVertical";
		
		public function Selector(layout:String = LAYOUT_HORIZONTAL, selectedItemIndex:int = 0) 
		{
			_gap = 0;
			_layout = layout;
			_selectedItemIndex = selectedItemIndex;
			container = new Sprite();
			addChild(container);
			hitzones = new Array();
		}
		
		public function set itemRenderer(value:Class):void
		{
			_itemRenderer = value;
			/*if (value is ISelectorItem)
			{
				_itemRenderer = value;
				callRender();
			}
			else
			{
				throw new ApplicationError(ApplicationError.SELECTOR_COMPONENT_WRONG_RENDERER);
			}*/
		}
		
		public function set maxWidth(value:Number):void
		{
			_maxWidth = value;
			callRender();
		}
		
		public function set selectedItemIndex(value:int):void
		{
			if (_selectedItemIndex != value)
			{
				select(value);
				_selectedItemIndex = value;
			}
		}
		
		private function select(value:int):void 
		{
			if (!itemRenderer || !dataProvider || isNaN(_maxWidth) || value >= dataProvider.length)
			{
				return;
			}
			if (items.length > value)
			{
				var renderer:ISelectorItem = new _itemRenderer();
				
				if (items[_selectedItemIndex] && (items[_selectedItemIndex] is Bitmap))
				{
					if ((items[_selectedItemIndex] as Bitmap).bitmapData)
					{
						(items[_selectedItemIndex] as Bitmap).bitmapData.dispose();
						(items[_selectedItemIndex] as Bitmap).bitmapData = null;
					}
					
					(items[_selectedItemIndex] as Bitmap).bitmapData = renderer.render(dataProvider[_selectedItemIndex], false);
				}
				
				if (items[value] && (items[value] is Bitmap))
				{
					if ((items[value] as Bitmap).bitmapData)
					{
						(items[value] as Bitmap).bitmapData.dispose();
						(items[value] as Bitmap).bitmapData = null;
					}
					
					(items[value] as Bitmap).bitmapData = renderer.render(dataProvider[value], true);
				}
			}
		}
		
		public function get gap():int
		{
			return _gap;
		}
		
		public function set gap(value:int):void
		{
			_gap = value;
			invalidatePositions();
		}
		
		private function invalidatePositions():void 
		{
			
		}
		
		public function get selectedItemIndex():int
		{
			return _selectedItemIndex;
		}
		
		public function set dataProvider(value:Vector.<SelectorItemData>):void
		{
			_dataProvider = value;
			callRender();
		}
		
		public function get dataProvider():Vector.<SelectorItemData>
		{
			return _dataProvider;
		}
		
		private function callRender():void 
		{
			if (itemRenderer && dataProvider && !isNaN(_maxWidth))
			{
				render();
			}
		}
		
		private function render():void 
		{
			clear();
			
			items = new Array();
			hitzones = new Array();
			
			var renderer:ISelectorItem = new _itemRenderer();
			var itemsNum:int = dataProvider.length;
			var item:Bitmap;
			var itemX:int = 0;
			var itemY:int = 0;
			
			var hitzone:HitZoneData;
			
			for (var i:int = 0; i < itemsNum; i++) 
			{
				item = new Bitmap(renderer.render(dataProvider[i], i == _selectedItemIndex));
				items.push(item);
				
				if (_layout == LAYOUT_HORIZONTAL)
				{
					
					itemX += (i == 0)?0:_gap;
					
					if (itemX + item.width > _maxWidth)
					{
						itemX = 0;
						itemY += item.height + _gap;
					}
					
					item.x = itemX;
					item.y = itemY;
					
					itemX += item.width;
				}
				else if (_layout == LAYOUT_VERTICAL)
				{
					item.x = 0;
					item.y = container.height + _gap;
				}
				
				hitzone = new HitZoneData();
				hitzone.x = item.x;
				hitzone.y = item.y;
				hitzone.width = item.width;
				hitzone.height = item.height;
				hitzones.push(hitzone);
				
				container.addChild(item);
			}
		}
		
		private function onTap(e:Event):void
		{
			if (hitzones != null)
			{
				var touchPoint:Point = new Point(e["localX"], e["localY"]);
				
				for (var j:int = 0; j < hitzones.length; j++)
				{
					if (touchPoint.x >= hitzones[j].x && touchPoint.x <= hitzones[j].x + hitzones[j].width && 
						touchPoint.y >= hitzones[j].y && touchPoint.y <= hitzones[j].y + hitzones[j].height)
					{
						selectedItemIndex = j;
						break;
					}
				}
			}
		}
		
		private function clear():void 
		{
			if (items)
			{
				var itemsNum:int = items.length;
				for (var i:int = 0; i < itemsNum; i++) 
				{
					UI.destroy(items[i]);
				}
			}
			container.removeChildren();
			
			hitzones = null;
			items = null;
		}
		
		public function get itemRenderer():Class
		{
			return _itemRenderer;
		}
		
		public function dispose():void 
		{
			_dataProvider = null;
			_itemRenderer = null;
			
			clear();
			
			if (container)
			{
				UI.destroy(container);
				container = null;
			}
		}
		
		public function deactivate():void 
		{
			PointerManager.removeTap(this, onTap);
		}
		
		public function activate():void 
		{
			PointerManager.addTap(this, onTap);
		}
		
		public function getSelectedData():Object 
		{
			return dataProvider[selectedItemIndex].data;
		}
	}
}