package com.dukascopy.connect.gui.components.radio 
{
	import assets.RadioIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.SelectorItemData;
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
		public var gap:int;
		
		public function RadioGroup(onSelect:Function) 
		{
			gap = Config.FINGER_SIZE * .13;
			this.onSelect = onSelect;
		}
		
		public function draw(selectors:Vector.<SelectorItemData>, itemWidth:int, Renderer:Class):void 
		{
			items = new Vector.<IRadioItem>();
			var item:IRadioItem;
			for (var i:int = 0; i < selectors.length; i++) 
			{
				item = new Renderer(onItemSelected);
				item.draw(selectors[i], itemWidth);
				items.push(item);
				addChild(item as Sprite);
			}
			updatePositions();
		}
		
		private function onItemSelected(value:SelectorItemData):void 
		{
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
		
		private function updatePositions():void 
		{
			var position:int = 0;
			for (var i:int = 0; i < items.length; i++) 
			{
				items[i].y = position;
				position += items[i].height + gap;
			}
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
	}
}