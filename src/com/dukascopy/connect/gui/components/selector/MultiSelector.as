package com.dukascopy.connect.gui.components.selector {
	
	import com.dukascopy.connect.data.HitZoneData;
	import com.dukascopy.connect.data.SelectorItemData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.errors.ApplicationError;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.telefision.sys.signals.Signal;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author Sergey Dobarin recreated by Alexey
	 */
	
	public class MultiSelector extends Sprite {
		
		public var S_ON_SELECT:Signal = new Signal("MultiSelector.S_ON_SELECT");
		
		private var _dataProvider:Vector.<SelectorItemData>;
		private var _itemRenderer:Class = CategorySelectorItem;
		private var _maxWidth:Number;
		private var _layout:String;
		private var _selectedItemIndex:int;
		private var items:Array;
		private var container:Sprite;
		private var hitzones:Array;
		private var _gap:int;
		
		private var _selectedIndexes:Vector.<int> = new Vector.<int>; // array stores indexes of selected elements/data
		
		static public const LAYOUT_HORIZONTAL:String = "layoutHorizontal";
		static public const LAYOUT_VERTICAL:String = "layoutVertical";
		public var multiselection:Boolean;
		
		public function MultiSelector(layout:String = LAYOUT_HORIZONTAL, selectedItemIndex:int = -1) {
			_gap = 0;
			_layout = layout;
			_selectedItemIndex = selectedItemIndex;
			container = new Sprite();
			addChild(container);
			hitzones = new Array();
		}
		
		public function set itemRenderer(value:Class):void	{
			_itemRenderer = value;
			/*if (value is ISelectorItem)	{
				_itemRenderer = value;
				callRender();
			}else{
				throw new ApplicationError(ApplicationError.SELECTOR_COMPONENT_WRONG_RENDERER);
			}*/
		}
		
		public function set maxWidth(value:Number):void{
			_maxWidth = value;
			callRender();
		}
		
		public function selectItemIndex(value:int, needSignal:Boolean = true):void {
			var indexInSelected:int = _selectedIndexes.indexOf(value);
			if (indexInSelected != -1) {
				_selectedIndexes.removeAt(indexInSelected);
				deselect(value);
			} else {
				if (!multiselection)
				{
					for (var i:int = 0; i < _selectedIndexes.length; i++) 
					{
						deselect(_selectedIndexes[i]);
					}
					_selectedIndexes = new Vector.<int>();
				}
				_selectedIndexes.push(value);
				select(value);
			}
			if (dataProvider != null)
			{
				if (needSignal == true)
					S_ON_SELECT.invoke((indexInSelected == -1) ? dataProvider[value] : null);
			}
		}
		
		public function isIndexSelected(ind:int):Boolean { return _selectedIndexes.indexOf(ind) !=-1; }
		
		
		private function select(value:int):void {
			if (!itemRenderer || !dataProvider || isNaN(_maxWidth) || value >= dataProvider.length)	{ return; } // validation
			if (items.length > value) {
				var renderer:ISelectorItem = new _itemRenderer();
				var item:DisplayObject = items[value];
				if (item && (item is Bitmap)) {
					UI.disposeBMD((item as Bitmap).bitmapData);
					(item as Bitmap).bitmapData = renderer.render(dataProvider[value], true);
				}
			}
		}
		
		private function deselect(value:int):void {
			if (!itemRenderer || !dataProvider || isNaN(_maxWidth) || value >= dataProvider.length)	{ return; } // validation
			if (items.length > value) {
				var renderer:ISelectorItem = new _itemRenderer();
				var item:DisplayObject = items[value];
				if (item && (item is Bitmap)) {
					UI.disposeBMD((item as Bitmap).bitmapData);
					(item as Bitmap).bitmapData = renderer.render(dataProvider[value], false);
				}
			}
		}
		
		public function deselectAll():void {
			_selectedIndexes.length = 0;
			callRender();
		}
		
		public function selectAll():void {
			for (var i:int = 0; i < _dataProvider.length; i++)
				_selectedIndexes.push(i);
			callRender();
		}
		
		public function get gap():int { return _gap; }
		public function set gap(value:int):void	{
			_gap = value;
			invalidatePositions();
		}
		
		private function invalidatePositions():void { }
		
		public function get selectedItemIndex():int	{	return _selectedItemIndex;	} 
		public function get dataProvider():Vector.<SelectorItemData> { return _dataProvider; }
		public function set dataProvider(value:Vector.<SelectorItemData>):void {
			_dataProvider = value;
			callRender();
		}
		
		private function callRender():void {
			if (itemRenderer && dataProvider && !isNaN(_maxWidth))
				render();
		}
		
		private function render():void {
			clear();
			
			items = new Array();
			hitzones = new Array();
			
			var renderer:ISelectorItem = new _itemRenderer(); // reusable renderer 
			var itemsNum:int = dataProvider.length;
			var item:Bitmap;
			var itemX:int = 0;
			var itemY:int = 0;
			
			var hitzone:HitZoneData;
			
			for (var i:int = 0; i < itemsNum; i++) {
				item = new Bitmap(renderer.render(dataProvider[i], _selectedIndexes.indexOf(i) !=-1));
				items.push(item);
				
				if (_layout == LAYOUT_HORIZONTAL) {
					
					itemX += (i == 0)?0:_gap;
					
					if (itemX + item.width > _maxWidth) {
						itemX = 0;
						itemY += item.height + _gap;
					}
					
					item.x = itemX;
					item.y = itemY;
					
					itemX += item.width;
				} else if (_layout == LAYOUT_VERTICAL) {
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
		
		private function onTap(e:Event):void {
			if (hitzones != null) {
				var touchPoint:Point = new Point(e["localX"], e["localY"]);
				for (var j:int = 0; j < hitzones.length; j++) {
					if (touchPoint.x >= hitzones[j].x && touchPoint.x <= hitzones[j].x + hitzones[j].width && 
						touchPoint.y >= hitzones[j].y && touchPoint.y <= hitzones[j].y + hitzones[j].height) {
							selectItemIndex(j);
							break;
					}
				}
			}
		}
		
		private function clear():void {
			if (items){
				var itemsNum:int = items.length;
				for (var i:int = 0; i < itemsNum; i++){
					UI.destroy(items[i]);
				}
			}
			container.removeChildren();
			hitzones = null;
			items = null;
		}
		
		public function get itemRenderer():Class{	return _itemRenderer;	}
		
		public function get selectedIndexes():Vector.<int> { return _selectedIndexes; }
		public function set selectedIndexes(value:Vector.<int>):void {
			_selectedIndexes = value;
			callRender();
		}
		
		public function dispose():void {
			_dataProvider = null;
			_itemRenderer = null;
			// todo dispose renderer
			clear();			
			if (container)	{
				UI.destroy(container);
				container = null;
			}
		}
		
		public function deactivate():void 	{
			PointerManager.removeTap(this, onTap);
		}
		
		public function activate():void {
			PointerManager.addTap(this, onTap);
		}
		
		public function getSelectedDataVector():Vector.<SelectorItemData> {
			var result:Vector.<SelectorItemData> = new Vector.<SelectorItemData>;
			for (var i:int = 0; i < dataProvider.length; i++)
				if (isIndexSelected(i))
					result.push(dataProvider[i]);	
			return result;
		}
		
		public function deselectLast():void {
			if (_selectedIndexes == null || _selectedIndexes.length == 0)
				return;
			selectItemIndex(_selectedIndexes[_selectedIndexes.length - 1], false);;
		}
		
		public function selectLastOnly():void {
			if (_selectedIndexes == null || _selectedIndexes.length == 0)
				return;
			var selectedIndex:int = _selectedIndexes[_selectedIndexes.length - 1];
			deselectAll();
			selectItemIndex(selectedIndex, false);
		}
	}
}