package com.dukascopy.connect.gui.button {
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.type.MainColors;
	import com.dukascopy.connect.uiFactory.UIFactory;
	import com.dukascopy.langs.Lang;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class RectangleButton extends BitmapButton
	{
		protected var generatedBitmap:ImageBitmapData;
		private var value:String = Lang.textInvite + "!";
		
		protected var box:Sprite;
		protected var tf:TextField;
		
		protected var w:int = 0;
		protected var color:Number;
		
		private var lastValue:String;
		private var changed:Boolean;
		private var lastColor:Number;
		private var lastButtonWidth:int;
		
		public function RectangleButton(value:String, 
										color:Number)
		{
			super();
			this.color = color;
			this.value = value;
			setStandartButtonParams();	
			usePreventOnDown = true;
			cancelOnVerticalMovement = true;
			
			if (lastColor != color)
			{
				lastColor = color;
				changed = true;
			}
			if (lastValue != value)
			{
				lastValue = value;
				changed = true;
			}
			
			box = new Sprite();
				tf = UIFactory.createTextField(Config.FINGER_SIZE * .37, true);
				tf.textColor = MainColors.WHITE;
				
			box.addChild(tf);
		}
		
		public function draw():void
		{
			if (!changed)
			{
				return;
			}
			changed = false;
			
			tf.text = value;
			var textFormat:TextFormat = new TextFormat();
				textFormat.align = TextFormatAlign.CENTER;
				tf.setTextFormat(textFormat);
			
			tf.width = w - Config.MARGIN * 2;
			tf.height = tf.textHeight + 4;
			tf.y = int(Config.MARGIN * 1.3);
			tf.x = int(w * .5 - tf.width * .5);
			
			var itemHeight:int = int(Config.MARGIN * 2.6 + tf.height);
			
			box.graphics.clear();
			box.graphics.beginFill(color, 1);
			box.graphics.drawRect(0, 0, w, itemHeight);
			box.graphics.endFill();
			
			if (generatedBitmap == null || generatedBitmap.isDisposed == true || generatedBitmap.width != w || generatedBitmap.height != itemHeight) {
				
				UI.disposeBMD(generatedBitmap);
				
				generatedBitmap = new ImageBitmapData("RectangleButton.generatedBitmap", w, itemHeight, true, 0);
			}else {
				generatedBitmap.fillRect(generatedBitmap.rect, 0);	
			}
			
			generatedBitmap.drawWithQuality(box, null, null, null, null, true, StageQuality.BEST);
			
			setBitmapData(generatedBitmap);
		}
		
		public function setValue(value:String = null):void
		{
			if (value == null)
				value = Lang.textOk.toUpperCase();
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
			return w;
		}
		
		public function getHeight():int
		{
			return height;
		}
		
		public function setWidth(value:int):void
		{
			if (lastButtonWidth != value)
			{
				changed = true;
				lastButtonWidth = value;
			}
			w = value;
			draw();
		}
	}
}