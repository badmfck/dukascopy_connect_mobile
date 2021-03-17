package com.dukascopy.connect.gui.components 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.filter.FilterData;
	import com.dukascopy.connect.gui.scrollPanel.HorizontalScrollPanel;
	import com.dukascopy.connect.gui.scrollPanel.ScrollPanel;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class HorizontalSelector extends Sprite implements IFilterView
	{
		private var scroll:HorizontalScrollPanel;
		private var data:Vector.<FilterData>;
		private var items:Vector.<HSelectorItem>;
		private var contentWidth:int;
		private var onChangeFunction:Function;
		private var lastSelected:FilterData;
		
		public function HorizontalSelector(onChangeFunction:Function) 
		{
			this.onChangeFunction = onChangeFunction;
			scroll = new HorizontalScrollPanel();
			scroll.disableVisibilityChange();
			scroll.mask = false;
			addChild(scroll.view);
		}
		
		/* INTERFACE com.dukascopy.connect.gui.components.IFilterView */
		
		public function setData(value:Vector.<FilterData>):void 
		{
			this.data = value;
			construct();
		}
		
		private function construct():void 
		{
			if (data != null)
			{
				var maxHeight:int = 0;
				
				var position:int = 0;
				var padding:int = Config.FINGER_SIZE * 0.2;
				items = new Vector.<HSelectorItem>;
				var l:int = data.length;
				var item:HSelectorItem;
				for (var i:int = 0; i < l; i++) 
				{
					item = new HSelectorItem(data[i], onChange);
					items.push(item);
					scroll.addObject(item);
					item.x = position;
					position += item.getWidth() + padding;
					maxHeight = Math.max(maxHeight, item.getHeight());
					if (data[i].selected)
					{
						lastSelected = data[i];
					}
				}
			}
			scroll.setWidthAndHeight(contentWidth, maxHeight);
		}
		
		private function onChange(filter:FilterData):void 
		{
			if (lastSelected != null && lastSelected != filter)
			{
				lastSelected.selected = false;
				redraw();
			}
			lastSelected = filter;
			if (onChangeFunction != null)
			{
				onChangeFunction();
			}
		}
		
		public function dispose():void 
		{
			data = null;
			onChangeFunction = null;
			if (items != null)
			{
				for (var i:int = 0; i < items.length; i++) 
				{
					items[i].dispose();
				}
				items = null;
			}
			if (scroll != null)
			{
				scroll.dispose();
				scroll = null;
			}
		}
		
		/* INTERFACE com.dukascopy.connect.gui.components.IFilterView */
		
		public function setWidth(value:int):void 
		{
			contentWidth = value;
		}
		
		/* INTERFACE com.dukascopy.connect.gui.components.IFilterView */
		
		public function activate():void 
		{
			scroll.enable();
			if (items != null)
			{
				for (var i:int = 0; i < items.length; i++) 
				{
					items[i].activate();
				}
			}
		}
		
		public function deactivate():void 
		{
			scroll.disable();
			if (items != null)
			{
				for (var i:int = 0; i < items.length; i++) 
				{
					items[i].deactivate();
				}
			}
		}
		
		/* INTERFACE com.dukascopy.connect.gui.components.IFilterView */
		
		public function update():void 
		{
			if (scroll != null)
			{
				scroll.update();
			}
		}
		
		/* INTERFACE com.dukascopy.connect.gui.components.IFilterView */
		
		public function getHeight():int 
		{
			return height;
		}
		
		/* INTERFACE com.dukascopy.connect.gui.components.IFilterView */
		
		public function redraw():Boolean 
		{
			if (data != null && items != null && items.length == data.length)
			{
				for (var i:int = 0; i < items.length; i++) 
				{
					items[i].redraw();
				}
				return true;
			}
			else
			{
				return false;
			}
		}
	}
}