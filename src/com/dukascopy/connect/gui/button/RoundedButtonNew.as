package com.dukascopy.connect.gui.button {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.uiFactory.UIFactory;
	import com.dukascopy.langs.Lang;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class RoundedButtonNew extends BitmapButton {
		
		private var generatedBitmap:BitmapData;
		private var value:String = Lang.textInvite + "!";
		
		private var box:Sprite;
		private var tf:TextField;
		
		private var w:int = 0;
		private var h:int = 0;
		private var mainHeight:int;
		private var mainWidth:int;
		private var color:Number;
		private var minWidth:int;
		private var maxWidth:int;
		
		private var lastValue:String;
		private var changed:Boolean;
		private var lastColor:Number;
		private var lastMinWidth:int = -1;
		private var lastMaxWidth:int = -1;
		private var textColor:uint;
		
		public function RoundedButtonNew(value:String, 
										color:Number, 
										textColor:uint,
										fontSize:Number = NaN)
		{
			super();
			this.color = color;
			this.value = value;
			this.textColor = textColor;
			setStandartButtonParams();	
			usePreventOnDown = true;
			cancelOnVerticalMovement = true;
			
			if (isNaN(fontSize))
			{
				fontSize = Config.FINGER_SIZE * 0.3;
			}
			
			if (color != color)
			{
				changed = true;
			}
			if (lastValue != value)
			{
				changed = true;
			}
			
			lastColor = color;
			lastValue = value;
			
			box = new Sprite();
				tf = UIFactory.createTextField(fontSize);
				tf.textColor = textColor;
			box.addChild(tf);
		}
		
		public function draw():void
		{
			if (!changed)
			{
				return;
			}
			changed = false;
			
			mainHeight = Config.FINGER_SIZE*.8;
			
			calculateTextWidth();
			
			tf.x = int(mainWidth * .5 - tf.width * .5);
			
			box.graphics.clear();
			
			
			
			box.graphics.beginFill(color);
			box.graphics.drawRoundRect(0, 0, mainWidth, mainHeight, mainHeight, mainHeight);
			box.graphics.endFill();
		//	addChild(box);
			UI.disposeBMD(generatedBitmap);
			generatedBitmap = new ImageBitmapData("RoundedButton.draw", mainWidth, int(mainHeight), true, 0);
			generatedBitmap.drawWithQuality(box, null, null, null, null, true, StageQuality.HIGH);
			setBitmapData(generatedBitmap);
		}
		
		private function calculateTextWidth():Boolean 
		{
			tf.text = value;
			
			var padding:int = Config.MARGIN * 1.8;
			
			var contentWidth:int = (tf.textWidth + 4) + Config.MARGIN * 2;
			
			mainWidth = (minWidth < 1)?contentWidth:Math.max(minWidth, contentWidth);
			mainWidth = (maxWidth < 1)?mainWidth:Math.min(maxWidth, mainWidth);
			
			tf.y = int((mainHeight - tf.height) * .5);
			
			var textFieldWidth:int = mainWidth - padding * 2;
			tf.width = Math.min(tf.textWidth + 4, textFieldWidth);
			
			return tf.width < tf.textWidth + 4;
		}
		
		public function setValue(value:String = null):void
		{
			if (value == null)
				value = Lang.textInvite;
			this.value = value;
			if (lastValue != value)
			{
				lastValue = value;
				changed = true;
			}
			draw();
		}
		
		override public function dispose():void
		{
			UI.safeRemoveChild(tf);			
			tf = null;				
			if (box != null)
				box.graphics.clear();			
			box = null;
			if (generatedBitmap != null)
				generatedBitmap.dispose();
			generatedBitmap = null;
			
			super.dispose();
		}
		
		public function getWidth():int
		{
			return mainWidth;
		}
		
		public function getHeight():int
		{
			return height;
		}
		
		public function setSizeLimits(minWidth:int, maxWidth:int):void 
		{
			if (minWidth > maxWidth)
			{
				minWidth = maxWidth;
			}
			
			this.minWidth = minWidth;
			this.maxWidth = maxWidth;
			
			if (lastMinWidth != minWidth)
			{
				changed = true;
			}
			if (lastMaxWidth != maxWidth)
			{
				changed = true;
			}
			lastMinWidth = minWidth;
			lastMaxWidth = maxWidth;
		}
		
		public function isTextCropped():Boolean 
		{
			return calculateTextWidth();
		}
	}
}