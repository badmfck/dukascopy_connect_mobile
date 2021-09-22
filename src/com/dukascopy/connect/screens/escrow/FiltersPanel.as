package com.dukascopy.connect.screens.escrow 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.escrow.filter.EscrowFilter;
	import com.dukascopy.connect.gui.components.FilterPanelItem;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class FiltersPanel extends Sprite
	{
		private var filters:Vector.<EscrowFilter>;
		private var buttons:Vector.<FilterPanelItem>;
		
		private var hPadding:int;
		private var vPadding:int;
		private var maxWidth:int;
		private var buttonHeight:int;
		private var onRemove:Function;
		
		public function FiltersPanel(onRemove:Function) 
		{
			this.onRemove = onRemove;
			
			hPadding = Config.FINGER_SIZE * .1;
			vPadding = Config.FINGER_SIZE * .1;
		}
		
		public function draw(filters:Vector.<EscrowFilter>, maxWidth:int):void 
		{
			this.filters = filters;
			this.maxWidth = maxWidth;
			buttonHeight = Config.FINGER_SIZE * .45;
			
			clear();
			construct();
		}
		
		private function construct():void 
		{
			buttons = new Vector.<FilterPanelItem>();
			
			var button:FilterPanelItem;
			for (var i:int = 0; i < filters.length; i++) 
			{
				button = new FilterPanelItem(filters[i], onFilterRemove, maxWidth, buttonHeight, onFilterRemove);
				buttons.push(button);
				addChild(button);
			}
			activate();
			updatePositions();
		}
		
		private function updatePositions():void 
		{
			var lineWidth:int = 0;
			var linePosition:int = 0;
			var position:int = 0;
			if (buttons != null)
			{
				for (var i:int = 0; i < buttons.length; i++) 
				{
					if (lineWidth + buttons[i].width + hPadding > maxWidth)
					{
						lineWidth = 0;
						position += buttonHeight + vPadding;
					}
					buttons[i].x = linePosition;
					linePosition += buttons[i].width + hPadding;
					lineWidth += buttons[i].width + hPadding;
					buttons[i].y = position;
				}
			}
		}
		
		private function onFilterRemove(button:FilterPanelItem):void 
		{
			if (onRemove != null && onRemove.length == 1)
			{
				onRemove(button.getData());
			}
		}
		
		public function activate():void
		{
			if (buttons != null)
			{
				for (var i:int = 0; i < buttons.length; i++) 
				{
					buttons[i].activate();
				}
			}
		}
		
		public function deactivate():void
		{
			if (buttons != null)
			{
				for (var i:int = 0; i < buttons.length; i++) 
				{
					buttons[i].deactivate();
				}
			}
		}
		
		private function clear():void 
		{
			removeChildren();
			if (buttons != null)
			{
				for (var i:int = 0; i < buttons.length; i++) 
				{
					buttons[i].dispose();
				}
				buttons = null;
			}
		}
		
		public function getHeight():Number 
		{
			return height;
		}
		
		public function dispose():void
		{
			clear();
			onRemove = null;
		}
	}
}