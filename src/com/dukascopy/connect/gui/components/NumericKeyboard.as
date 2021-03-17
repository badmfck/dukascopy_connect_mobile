package com.dukascopy.connect.gui.components 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.type.HitZoneType;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.net.getClassByAlias;
	import flash.utils.getDefinitionByName;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class NumericKeyboard extends Sprite
	{
		private var buttons:Vector.<BitmapButton>;
		private var maxWidth:int;
		private var maxHeigt:int;
		private var callback:Function;
		private var locked:Boolean;
		
		public function NumericKeyboard(callback:Function) 
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
			
			this.callback = callback;
			
			buttons = new Vector.<BitmapButton>();
			
			var button:BitmapButton;
			for (var i:int = 0; i < 10; i++) 
			{
				button = new BitmapButton();
				button.setStandartButtonParams();
				button.setDownScale(1);
				button.setDownColor(Style.color(Style.COLOR_BACKGROUND));
				button.callbackParam = i.toString();
				button.tapCallback = buttonClick;
				button.disposeBitmapOnDestroy = true;
				button.setOverlay(HitZoneType.CIRCLE);
				addChild(button);
				
				buttons.push(button);
			}
		}
		
		private function buttonClick(index:int):void 
		{
			if (callback != null && locked == false)
			{
				var value:int = index + 1;
				if (value == 10)
				{
					value = 0;
				}
				callback(value.toString());
			}
		}
		
		public function draw(maxWidth:int, maxHeigt:int, zoom:Number = 1):void
		{
			clear();
			this.maxWidth = maxWidth;
			this.maxHeigt = maxHeigt;
			
			var buttonBD:ImageBitmapData;
			var maxButtonWidth:int = Config.FINGER_SIZE * 2.5 * zoom;
			var maxButtonHeight:int = Config.FINGER_SIZE * 1 * zoom;
			
			var buttonWidth:int = Math.min(maxWidth / 3, maxButtonWidth);
			var buttonHeight:int = Math.min(maxHeigt / 4, maxButtonHeight);
			buttonHeight = Math.max(Config.FINGER_SIZE * zoom, buttonHeight);
			
			var icon:Sprite;
			var charBD:ImageBitmapData;
			
			for (var i:int = 0; i < buttons.length; i++) 
			{
				buttonBD = new ImageBitmapData("numericKeyboard", buttonWidth, buttonHeight, false, Style.color(Style.COLOR_BACKGROUND));
				var char:int = i + 1;
				if (char == 10)
				{
					char = 0;
				}
				
				var classIcon:Class = getDefinitionByName("char_" + char.toString()) as Class;
				icon = new classIcon();
				UI.colorize(icon, Style.color(Style.COLOR_KEYBOARD_TEXT));
				UI.scaleToFit(icon, Config.FINGER_SIZE * .4 * zoom, Config.FINGER_SIZE * .4 * zoom);
				charBD = UI.getSnapshot(icon);
				buttonBD.copyPixels(charBD, charBD.rect, new Point(int(buttonBD.width * .5 - charBD.width * .5), int(buttonBD.height * .5 - charBD.height * .5)));
				charBD.dispose();
				
				buttons[i].setBitmapData(buttonBD, true);
				buttons[i].x = int(maxWidth * .5 - buttonWidth * 3 * .5 + i % 3 * (buttonWidth));
				buttons[i].y = int(Math.floor(i / 3) * (buttonHeight));
				if (i == 9)
				{
					buttons[i].x = int(maxWidth * .5 - buttonWidth * .5 + i % 3 * (buttonWidth));
				}
			}
			charBD = null;
			
		//	button.set
		}
		
		private function clear():void 
		{
			
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
		
		public function dispose():void
		{
			if (buttons != null)
			{
				for (var i:int = 0; i < buttons.length; i++) 
				{
					buttons[i].dispose();
				}
			}
			buttons = null;
		}
		
		public function lock():void 
		{
			locked = true;
		}
		
		public function unlock():void 
		{
			locked = false;
		}
	}
}