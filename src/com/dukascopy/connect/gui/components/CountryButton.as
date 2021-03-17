package com.dukascopy.connect.gui.components 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.style.Style;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.getDefinitionByName;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class CountryButton extends Sprite
	{
		private var _tapCallback:Function;
		private var symbols:Vector.<Bitmap>;
		private var itemHeight:int;
		private var gap:Number;
		private var itemWidth:int;
		private var back:Sprite;
		private var locked:Boolean;
		private var value:String;
		private var zoom:Number;
		
		public function CountryButton() 
		{
			char_1
			char_2
			char_3
			char_4
			char_5
			char_6
			char_7
			char_8
			char_9
			char_0
			char_p
			
			itemHeight = int(Config.FINGER_SIZE * .42);
			itemWidth = int(itemHeight * 0.63);
			gap = Config.FINGER_SIZE * .06;
			
			back = new Sprite();
			back.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			back.graphics.drawRect(0, 0, 10, 10);
			back.graphics.endFill();
			addChild(back);
		}
		
		public function set tapCallback(value:Function):void 
		{
			_tapCallback = value;
		}
		
		public function draw(value:String):void
		{
			this.value = value;
			clear();
			
			if (value != null && value.length > 0)
			{
				symbols = new Vector.<Bitmap>();
				
				var symbol:Bitmap;
				for (var i:int = 0; i < value.length; i++) 
				{
					symbol = createSymbol(value.charAt(i));
					addChild(symbol);
					if (symbols.length > 0)
					{
						symbol.x = int((itemWidth + gap) * (symbols.length) + itemWidth * .5 - symbol.width * .5);
					}
					else
					{
						symbol.x = itemWidth * .5 - symbol.width * .5;
					}
					
					symbols.push(symbol);
				}
				
				if (symbols.length > 0)
				{
					
				}
				back.width = symbols[symbols.length - 1].x + symbols[symbols.length - 1].width;
				back.height = symbols[symbols.length - 1].y + symbols[symbols.length - 1].height;
			}
		}
		
		public function dispose():void
		{
			removeSymbols();
			if (back != null)
			{
				UI.destroy(back);
				back = null;
			}
		}
		
		public function activate():void
		{
			PointerManager.addTap(this, onTapped);
		}
		
		private function onTapped(e:Event = null):void 
		{
			if (locked == false)
			{
				if (_tapCallback != null)
				{
					_tapCallback.call();
				}
			}
		}
		
		public function deactivate():void
		{
			PointerManager.removeTap(this, onTapped);
		}
		
		public function lock():void 
		{
			locked = true;
		}
		
		public function unlock():void 
		{
			locked = false;
		}
		
		public function getValue():String 
		{
			return value;
		}
		
		public function redraw(size:Number):void 
		{
			zoom = size;
			itemHeight = int(Config.FINGER_SIZE * .42) * zoom;
			gap = Config.FINGER_SIZE * .06 * zoom;
			draw(value);
		}
		
		private function clear():void 
		{
			removeSymbols();
		}
		
		private function removeSymbols():void 
		{
			if (symbols != null && symbols.length > 0)
			{
				var l:int = symbols.length;
				for (var i:int = 0; i < l; i++) 
				{
					UI.destroy(symbols[i]);
				}
			}
			symbols = null;
		}
		
		private function createSymbol(value:String):Bitmap 
		{
			var classIcon:Class = getDefinitionByName("char_" + value.toString()) as Class;
			var icon:Sprite = new classIcon();
			UI.colorize(icon, 0xD76F2F);
			UI.scaleToFit(icon, Config.FINGER_SIZE, itemHeight);
			var clip:Bitmap = new Bitmap();
			clip.bitmapData = UI.getSnapshot(icon);
			return clip;
		}
	}
}