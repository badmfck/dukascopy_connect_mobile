package com.dukascopy.connect.gui.input 
{
	import assest.LockIconGrey2;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.greensock.TweenMax;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class PassInput extends Sprite
	{
		private var widthValue:Number = 10;
		private var input:Input;
		private var prompt:String;
		private var bottomLine:Bitmap;
		private var bottomLineSelected:Bitmap;
		private var icon:Bitmap;
		private var background:Sprite;
		private var focusFunc:Function;
		
		public function PassInput(prompt:String = null) 
		{
			this.prompt = prompt;
			
			construct();
		}
		
		private function construct():void 
		{
			background = new Sprite();
			background.graphics.beginFill(0xE6F9FF);
			background.graphics.drawRect(0, 0, 10, 10);
			background.graphics.endFill();
			background.alpha = 0;
			addChild(background);
			
			input = new Input();
			input.setMode(Input.MODE_PASSWORD);
			if (prompt != null)
			{
				input.setLabelText(prompt);
			}
			
			input.setBorderVisibility(false);
			input.setRoundBG(false);
			input.backgroundAlpha = 0;
			input.getTextField().textColor = Style.color(Style.COLOR_TEXT);
			input.S_FOCUS_IN.add(onFocuseIn);
			input.S_FOCUS_LOST.add(onFocuseOut);
			input.setRoundRectangleRadius(0);
			input.inUse = true;
			addChild(input.view);
			
			var hLineBitmapData:ImageBitmapData = UI.getHorizontalLine(0x707D8E);
			bottomLine = new Bitmap(hLineBitmapData);
			addChild(bottomLine);
			
			var hLineSelectedBitmapData:ImageBitmapData = UI.getHorizontalLine(0x00BEFF);
			bottomLineSelected = new Bitmap(hLineSelectedBitmapData);
			addChild(bottomLineSelected);
			bottomLineSelected.alpha = 0;
			
			icon = new Bitmap();
			addChild(icon);
			icon.x = Config.MARGIN;
			
			var iconSource:Sprite = getIcon();
			if (iconSource != null) {
				var size:int = Config.FINGER_SIZE * .4;
				UI.scaleToFit(iconSource, size, size);
				var iconBD:ImageBitmapData = UI.getSnapshot(iconSource, StageQuality.HIGH, "PassInput.icon");
				icon.bitmapData = iconBD;
				UI.destroy(iconSource);
			}
			
			if (icon.width > 0)
			{
				input.view.x = int(icon.width + Config.MARGIN * 2);
			}
			
			icon.y = int(input.view.y + input.height * .5 - icon.height * .5);
			
			bottomLine.y = int(input.view.y + input.view.height);
			bottomLineSelected.y = int(input.view.y + input.view.height);
			
			background.height = height * .5;
			background.y = height - background.height;
		}
		
		private function onFocuseOut():void 
		{
			if (background != null)
			{
				TweenMax.to(background, 0.15, {alpha:0, height:height*.5, onUpdate:resizeBackground});
				
			}
			if (bottomLineSelected)
			{
				TweenMax.to(bottomLineSelected, 0.3, {alpha:0});
			}
			
			if (input != null)
			{
				if (input.value == "" && prompt != null)
				{
					input.updateLabelVisibility();
				}
			}
		}
		
		private function resizeBackground():void 
		{
			if (background != null)
			{
				background.y = height - background.height;
			}
		}
		
		private function onFocuseIn():void 
		{
			if (background != null)
			{
				TweenMax.to(background, 0.15, {alpha:1, height:height, onUpdate:resizeBackground});
			}
			if (bottomLineSelected != null)
			{
				TweenMax.to(bottomLineSelected, 0.3, {alpha:1});
			}
			if (focusFunc != null)
			{
				focusFunc();
			}
		}
		
		private function getIcon():Sprite 
		{
			return new LockIconGrey2();
		}
		
		override public function set width(value:Number):void
		{
			widthValue = value;
			resize();
		}
		
		private function resize():void 
		{
			var inputWidth:int;
			if (input != null)
			{
				if (icon != null && icon.width > 0)
				{
					inputWidth = widthValue - icon.width - Config.MARGIN * 2;
				}
				else
				{
					inputWidth = widthValue;
				}
				input.width = inputWidth;
			}
			if (bottomLine != null)
			{
				bottomLine.width = widthValue;
			}
			if (bottomLineSelected != null)
			{
				bottomLineSelected.width = widthValue;
			}
			if (background != null)
			{
				background.width = widthValue;
				background.height = height;
			}
		}
		
		public function dispose():void
		{
			focusFunc = null;
			
			if (input != null)
			{
				TweenMax.killTweensOf(background);
				
				input.S_FOCUS_IN.remove(onFocuseIn);
				input.S_FOCUS_OUT.remove(onFocuseOut);
				
				input.dispose();
				input = null;
			}
			if (bottomLine != null)
			{
				UI.destroy(bottomLine);
				bottomLine = null;
			}
			if (bottomLineSelected != null)
			{
				UI.destroy(bottomLineSelected);
				bottomLineSelected = null;
			}
			if (icon != null)
			{
				UI.destroy(icon);
				icon = null;
			}
			if (background != null)
			{
				UI.destroy(background);
				background = null;
			}
		}
		
		override public function get height():Number
		{
			if (bottomLine != null)
			{
				return bottomLine.y + bottomLine.height;
			}
			return 0;
		}
		
		public function activate():void
		{
			if (input != null)
			{
				input.activate();
			}
		}
		
		override public function requestSoftKeyboard():Boolean
		{
			if (input != null && input.getTextField() != null)
			{
				input.getTextField().requestSoftKeyboard();
				
				return true;
			}
			return false;
		}
		
		public function set label(value:String):void
		{
			prompt = value;
			if (input != null)
			{
				input.setLabelText(prompt);
			}
		}
		
		public function deactivate():void
		{
			if (input != null)
			{
				input.deactivate();
			}
		}
		
		public function setFocus():void 
		{
			if (input != null)
			{
				input.setFocus();
			}
		}
		
		public function onFocusIn(focusFunc:Function):void 
		{
			this.focusFunc = focusFunc;
		}
		
		public function get value():String
		{
			if (input != null)
			{
				if (input.getDefValue() == input.value)
				{
					return "";
				}
				
				return input.value;
			}
			return "";
		}
	}
}