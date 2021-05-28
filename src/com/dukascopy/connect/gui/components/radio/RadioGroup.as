package com.dukascopy.connect.gui.components.radio 
{
	import assets.RadioIcon;
	import com.dukascopy.connect.data.SelectorItemData;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class RadioGroup extends Sprite
	{
		private var items:Vector.<RadioItem>;
		
		public function RadioGroup() 
		{
			
		}
		
		public function draw(selectors:Vector.<SelectorItemData>, itemWidth:int):void 
		{
			items = new Vector.<RadioItem>();
			var item:RadioItem;
			for (var i:int = 0; i < selectors.length; i++) 
			{
				item = new RadioItem();
				item.draw(selectors[i], width);
				items.push(item);
				addChild(item);
			}
			updatePositions();
		}
		
		private function updatePositions():void 
		{
			for (var i:int = 0; i < items.length; i++) 
			{
				
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
			if (items != null)
			{
				for (var i:int = 0; i < items.length; i++) 
				{
					items[i].dispose();
				}
				items = null;
			}
		}
	}
}