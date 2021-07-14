package com.dukascopy.connect.gui.button {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.uiFactory.UIFactory;
	import com.dukascopy.langs.Lang;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.text.TextField;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class RoundedButton extends BitmapButton {
		
		private var generatedBitmap:BitmapData;
		private var value:String = Lang.textInvite + "!";
		
		private var box:Sprite;
		private var tf:TextField;
		
		private var w:int = 0;
		private var h:int = 0;
		private var icon:Sprite;
		private var mainHeight:int;
		private var mainWidth:int;
		private var colorTop:Number;
		private var colorBottom:Number;
		private var iconXPosition:Number = 0;
		private var iconWidth:Number = 0;
		private var iconPadding:Number = 0;
		private var minWidth:int;
		private var maxWidth:int;
		
		private var lastValue:String;
		private var changed:Boolean;
		private var lastColorTop:Number;
		private var lastColorBottom:Number;
		private var lastIconClass:Class;
		private var lastMinWidth:int = -1;
		private var lastMaxWidth:int = -1;
		private var cornerRadius:Number;
		private var shadowHeight:Number;
		
		public function RoundedButton(	value:String, 
										colorTop:Number, 
										colorBottom:Number,
										iconClass:Class = null,
										cornerRadius:Number = NaN,
										shadowHeight:Number = NaN,
										buttonHeight:int = -1,
										fontSize:Number = NaN)
		{
			super();
			this.colorTop = colorTop;
			this.colorBottom = colorBottom;
			this.value = value;
			this.shadowHeight = shadowHeight;
			this.cornerRadius = cornerRadius;
			setStandartButtonParams();	
			usePreventOnDown = true;
			cancelOnVerticalMovement = true;
			
			if (isNaN(fontSize))
			{
				fontSize = Config.FINGER_SIZE * 0.3;
			}
			
			if (isNaN(cornerRadius))
			{
				cornerRadius = Config.MARGIN * 1.2;
			}
			if (isNaN(shadowHeight))
			{
				shadowHeight = Config.FINGER_SIZE * 0.12;
			}
			
			if (lastColorTop != colorTop)
			{
				changed = true;
			}
			if (lastColorBottom != colorBottom)
			{
				changed = true;
			}
			if (lastValue != value)
			{
				changed = true;
			}
			if (lastIconClass != iconClass)
			{
				changed = true;
			}
			
			lastColorTop = colorTop;
			lastColorBottom = colorBottom;
			lastValue = value;
			lastIconClass = iconClass;
			
			box = new Sprite();
				tf = UIFactory.createTextField(fontSize);
				tf.textColor = Color.WHITE;
			box.addChild(tf);
			
			if (iconClass)
			{
				icon = new iconClass();
			}
			else {
				icon = null;
			}
			
			if (buttonHeight == -1)
			{
				mainHeight = Config.MARGIN * 5;
			}
			else
			{
				mainHeight = buttonHeight;
			}
			
			
			if (icon)
			{
				box.addChild(icon);
				icon.height = int(Config.FINGER_SIZE * .3);
				icon.width = icon.width * icon.scaleY;
				icon.y = int((mainHeight - icon.height) * .5);
				
				iconXPosition = icon.x;
				iconWidth = icon.width;
				iconPadding = Config.MARGIN * 1.2;
			}
		}
		
		public function draw():void
		{
			if (!changed)
			{
				return;
			}
			changed = false;
			
			calculateTextWidth();
			
			if (icon)
			{
				icon.x = int((mainWidth - tf.width - icon.width - Config.MARGIN * 1.2)*.5);
			}
			tf.x = int(icon?(icon.x + icon.width + Config.MARGIN * 1.2):(mainWidth*.5 - tf.width*.5));
			
			
			box.graphics.clear();
			
			if (isNaN(cornerRadius))
			{
				cornerRadius = Config.MARGIN * 1.2;
			}
			if (isNaN(shadowHeight))
			{
				shadowHeight = Config.FINGER_SIZE * 0.12;
			}
			
			box.graphics.beginFill(colorBottom, 1);
			box.graphics.drawRoundRect(0, int(shadowHeight), mainWidth, mainHeight, cornerRadius, cornerRadius);
			box.graphics.endFill();
			
			box.graphics.beginFill(colorTop, 1);
			box.graphics.drawRoundRect(0, 0, mainWidth, mainHeight, cornerRadius, cornerRadius);
			box.graphics.endFill();
			
			if (generatedBitmap == null || generatedBitmap.width != mainHeight || generatedBitmap.height != int(mainHeight + Config.FINGER_SIZE * 0.12)) {
				
				UI.disposeBMD(generatedBitmap);
				
				generatedBitmap = new ImageBitmapData("RoundedButton.draw", mainWidth, int(mainHeight + Config.FINGER_SIZE*0.12), true, 0);
			}else {
				generatedBitmap.fillRect(generatedBitmap.rect, 0);	
			}
			
			generatedBitmap.drawWithQuality(box, null, null, null, null, true, StageQuality.BEST);
			
			setBitmapData(generatedBitmap);
		}
		
		private function calculateTextWidth():Boolean 
		{
			tf.text = value;
			
			var padding:int = Config.MARGIN * 1.8;
			
			var contentWidth:int = iconWidth + (tf.textWidth + 4) + Config.MARGIN * 7 + iconPadding;
			
			mainWidth = (minWidth < 1)?contentWidth:Math.max(minWidth, contentWidth);
			mainWidth = (maxWidth < 1)?mainWidth:Math.min(maxWidth, mainWidth);
			
			tf.y = int((mainHeight - tf.height) * .5);
			
			var textFieldWidth:int = icon?(mainWidth - Config.MARGIN * 1.6 - icon.width - padding * 2):(mainWidth - padding * 2);
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
			if (icon)
			{
				UI.destroy(icon);
			}
			icon = null;
			
			super.dispose();
		}
		
		public function getWidth():int
		{
			return mainWidth;
		}
		
		public function getHeight():int
		{
			return mainHeight + Config.FINGER_SIZE*0.12;
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