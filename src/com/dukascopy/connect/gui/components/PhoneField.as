package com.dukascopy.connect.gui.components 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.style.Style;
	import com.greensock.TweenMax;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.utils.getDefinitionByName;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class PhoneField extends Sprite
	{
		private var maxEmptyClips:int = 6;
		private var itemHeight:int;
		private var itemWidth:int;
		private var emptyClips:Vector.<Bitmap>;
		private var symbols:Vector.<Bitmap>;
		private var gap:int;
		
		public function PhoneField() 
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
			
			itemHeight = int(Config.FINGER_SIZE * .42);
			itemWidth = int(itemHeight * 0.63);
			gap = Config.FINGER_SIZE * .08;
			
			create();
		}
		
		private function create():void 
		{
			emptyClips = new Vector.<Bitmap>();
			symbols = new Vector.<Bitmap>();
			
			var emptyClip:Bitmap;
			var target:Sprite = new Sprite;
			
			var thickness:int = Math.max(2, Config.FINGER_SIZE * .02);
			target.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			target.graphics.drawRect(0, 0, itemWidth, itemHeight);
			target.graphics.endFill();
			target.graphics.beginFill(Style.color(Style.COLOR_KEYBOARD_TEXT));
			target.graphics.drawRect(0, itemHeight-thickness, itemWidth, thickness);
			target.graphics.endFill();
			
			var targetBD:ImageBitmapData = UI.getSnapshot(target);
			
			for (var i:int = 0; i < maxEmptyClips; i++) 
			{
				emptyClip = new Bitmap();
				emptyClip.bitmapData = targetBD.clone();
				addChild(emptyClip);
				emptyClips.push(emptyClip);
			}
			targetBD.dispose();
			targetBD = null;
			
			reposition();
		}
		
		private function reposition():void 
		{
			var position:int;
			if (symbols != null)
			{
				position = symbols.length * (itemWidth + gap);
			}
			else
			{
				position = 0;
			}
			
			for (var i:int = 0; i < emptyClips.length; i++) 
			{
				emptyClips[i].x = position;
				position += (itemWidth + gap);
			}
		}
		
		private function createSymbol(value:String):Bitmap 
		{
			var classIcon:Class = getDefinitionByName("char_" + value.toString()) as Class;
			var icon:Sprite = new classIcon();
			UI.colorize(icon, Style.color(Style.COLOR_PHONE));
			UI.scaleToFit(icon, Config.FINGER_SIZE, itemHeight);
			var clip:Bitmap = new Bitmap();
			clip.bitmapData = UI.getSnapshot(icon);
			return clip;
		}
		
		public function add(value:String):void
		{
			var symbol:Bitmap = createSymbol(value);
			if (symbol != null)
			{
				addChild(symbol);
				if (emptyClips.length > 0)
				{
					var clip:Bitmap = emptyClips.shift();
					symbol.x = int((itemWidth + gap) * (maxEmptyClips - emptyClips.length - 1) + itemWidth * .5 - symbol.width * .5);
					UI.destroy(clip);
					if (contains(clip))
					{
						removeChild(clip);
					}
				}
				else
				{
					if (symbols.length > 0)
					{
						symbol.x = int((itemWidth + gap) * (symbols.length) + itemWidth * .5 - symbol.width * .5);
					}
					else
					{
						symbol.x = itemWidth * .5 - symbol.width * .5;
					}
					
				}
				symbol.y = -Config.FINGER_SIZE * .2;
				TweenMax.to(symbol, 0.2, {y:0});
				
				symbols.push(symbol);
			}
			else
			{
				ApplicationErrors.add();
			}
		}
		
		public function getHeight():int 
		{
			return itemHeight;
		}
		
		public function getWidth():int 
		{
			return (emptyClips.length + symbols.length) * (itemWidth + gap);
		}
		
		public function clear():void 
		{
			for (var i:int = 0; i < symbols.length; i++) 
			{
				UI.destroy(symbols[i]);
				if (contains(symbols[i]))
				{
					removeChild(symbols[i]);
				}
			}
			symbols.length = 0;
			
			if (emptyClips.length < maxEmptyClips)
			{
				var emptyClip:Bitmap;
				var target:Sprite = new Sprite;
				
				var thickness:int = Math.max(2, Config.FINGER_SIZE * .02);
				target.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
				target.graphics.drawRect(0, 0, itemWidth, itemHeight);
				target.graphics.endFill();
				target.graphics.beginFill(Style.color(Style.COLOR_KEYBOARD_TEXT));
				target.graphics.drawRect(0, itemHeight-thickness, itemWidth, thickness);
				target.graphics.endFill();
				
				var targetBD:ImageBitmapData = UI.getSnapshot(target);
				
				var currentLength:int = emptyClips.length;
				for (i = 0; i < maxEmptyClips - currentLength; i++) 
				{
					emptyClip = new Bitmap();
					emptyClip.bitmapData = targetBD.clone();
					addChild(emptyClip);
					emptyClips.insertAt(i, emptyClip);
				}
				targetBD.dispose();
				targetBD = null;
				
				reposition();
			}
		}
		
		public function dispose():void 
		{
			if (symbols != null)
			{
				for (var i:int = 0; i < symbols.length; i++) 
				{
					UI.destroy(symbols[i]);
					if (contains(symbols[i]))
					{
						removeChild(symbols[i]);
					}
				}
			}
			symbols = null;
			
			if (emptyClips != null)
			{
				for (var i2:int = 0; i2 < emptyClips.length; i2++) 
				{
					UI.destroy(emptyClips[i2]);
					if (contains(emptyClips[i2]))
					{
						removeChild(emptyClips[i2]);
					}
				}
			}
			emptyClips = null;
		}
		
		public function removeLast():void 
		{
			if (symbols != null && symbols.length > 0)
			{
				UI.destroy(symbols[symbols.length - 1]);
				if (contains(symbols[symbols.length - 1]))
				{
					removeChild(symbols[symbols.length - 1]);
				}
				symbols.length = symbols.length - 1;
			}
			
			if (emptyClips.length + symbols.length < maxEmptyClips)
			{
				var emptyClip:Bitmap;
				var target:Sprite = new Sprite;
				
				var thickness:int = Math.max(2, Config.FINGER_SIZE * .02);
				target.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
				target.graphics.drawRect(0, 0, itemWidth, itemHeight);
				target.graphics.endFill();
				target.graphics.beginFill(Style.color(Style.COLOR_KEYBOARD_TEXT));
				target.graphics.drawRect(0, itemHeight-thickness, itemWidth, thickness);
				target.graphics.endFill();
				
				var targetBD:ImageBitmapData = UI.getSnapshot(target);
				
				var currentLength:int = emptyClips.length + symbols.length;
				for (var i:int = 0; i < maxEmptyClips - currentLength; i++) 
				{
					emptyClip = new Bitmap();
					emptyClip.bitmapData = targetBD.clone();
					addChild(emptyClip);
					emptyClips.insertAt(maxEmptyClips - i + 1, emptyClip);
				}
				targetBD.dispose();
				targetBD = null;
				
				reposition();
			}
		}
		
		public function redraw(size:Number):void 
		{
			
		}
	}
}