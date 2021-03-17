package com.dukascopy.connect.gui.components.countdown 
{
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class CountdownDisplay extends Sprite
	{
		private var items:Vector.<CountdownItem>;
		private var itemWidth:Number;
		private var container:flash.display.Sprite;
		
		public function CountdownDisplay() 
		{
			
		}
		
		public function setHeight(value:int):void
		{
			itemWidth = value * .5 / .9;
		}
		
		public function setValue(value:int, animate:Boolean = false):void
		{
			clean();
			
			container = new Sprite();
			addChild(container);
			container.y = int(itemWidth * .9);
			
			var razryads:int = 0;
			if (value > 0)
			{
				razryads = increaseRazryad(razryads, value);
			}
			
			items = new Vector.<CountdownItem>();
			var item:CountdownItem;
			
			var targetString:String = value.toString();
			
			for (var i:int = 0; i < razryads; i++) 
			{
				item = new CountdownItem(itemWidth);
				item.setValue(int(targetString.charAt(i)), animate, i*0.1);
				items.push(item);
				container.addChild(item);
				item.x = int((itemWidth + itemWidth * .1) * i);
			}
		}
		
		public function dispose():void 
		{
			clean();
		}
		
		private function clean():void 
		{
			if (container != null)
			{
				UI.destroy(container);
				container = null;
			}
			
			if (items != null)
			{
				var l:int = items.length;
				for (var i:int = 0; i < l; i++)
				{
					items[i].dispose();
					try
					{
						container.removeChild(items[i]);
					}
					catch (e:Error)
					{
						ApplicationErrors.add();
					}
				}
				items = null;
			}
		}
		
		private function increaseRazryad(razryads:int, value:int):int 
		{
			razryads++;
			value = value / 10;
			if (value > 0)
			{
				return increaseRazryad(razryads, value);
			}
			return razryads;
		}
	}
}