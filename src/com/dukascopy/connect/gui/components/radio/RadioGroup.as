package com.dukascopy.connect.gui.components.radio 
{
	import assets.RadioIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.SelectorItemData;
	import com.dukascopy.connect.data.layout.LayoutExecutor;
	import com.dukascopy.connect.data.layout.LayoutType;
	import com.dukascopy.connect.gui.layout.Layout;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class RadioGroup extends Sprite
	{
		private var items:Vector.<IRadioItem>;
		private var onSelect:Function;
		private var layout:LayoutType;
		private var lastSelectedValue:SelectorItemData;
		public var gap:int;
		
		public function RadioGroup(onSelect:Function, layout:LayoutType = null) 
		{
			if (layout == null)
			{
				layout = LayoutType.vertical;
			}
			
			this.layout = layout;
			this.onSelect = onSelect;
			
			gap = Config.FINGER_SIZE * .13;
		}
		
		public function draw(selectors:Vector.<SelectorItemData>, itemWidth:int, Renderer:Class):void 
		{
			items = new Vector.<IRadioItem>();
			var item:IRadioItem;
			for (var i:int = 0; i < selectors.length; i++) 
			{
				item = new Renderer(onItemSelected);
				item.draw(selectors[i], itemWidth, layout == LayoutType.vertical);
				items.push(item);
				addChild(item as Sprite);
			}
			updatePositions(itemWidth);
		}
		
		private function onItemSelected(value:SelectorItemData):void 
		{
			lastSelectedValue = value;
			updateSelection(value);
			
			if (onSelect != null)
			{
				onSelect(value);
			}
			else
			{
				ApplicationErrors.add();
			}
		}
		
		private function updateSelection(value:SelectorItemData):void 
		{
			if (items != null)
			{
				for (var i:int = 0; i < items.length; i++) 
				{
					if (items[i].getData() == value)
					{
						items[i].select();
					}
					else
					{
						items[i].unselect();
					}
				}
			}
			else
			{
				ApplicationErrors.add();
			}
		}
		
		private function updatePositions(componentWidth:int):void 
		{
			var clips:Vector.<Sprite> = new Vector.<Sprite>();
			for (var n:int = 0; n < items.length; n++) 
			{
				clips.push(items[n]);
			}
			LayoutExecutor.execute(clips, layout, componentWidth);
		}
		
		public function activate():void
		{
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
			if (items != null)
			{
				for (var i:int = 0; i < items.length; i++) 
				{
					items[i].activate();
				}
			}
		}
		
		public function dispose():void
		{
			lastSelectedValue = null;
			layout = null;
			onSelect = null;
			
			if (items != null)
			{
				for (var i:int = 0; i < items.length; i++) 
				{
					items[i].dispose();
				}
				items = null;
			}
		}
		
		public function select(selectorItemData:SelectorItemData):void 
		{
			updateSelection(selectorItemData);
		}
		
		public function getSelection():SelectorItemData 
		{
			return lastSelectedValue;
		}
	}
}