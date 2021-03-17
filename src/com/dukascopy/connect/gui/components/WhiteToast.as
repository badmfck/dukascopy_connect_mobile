package com.dukascopy.connect.gui.components 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.utils.TextUtils;
	import com.greensock.TweenMax;
	import com.greensock.easing.Back;
	import com.greensock.easing.Bounce;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class WhiteToast extends Sprite
	{
		private var text:String;
		private var back:Sprite;
		private var white:Sprite;
		private var maskClip:Sprite;
		private var itemWidth:int;
		private var itemHeight:int;
		private var textImage:Bitmap;
		private var completeHandler:Function;
		private var time:Number;
		
		public function WhiteToast(text:String, itemWidth:int, itemHeight:int, completeHandler:Function, time:Number) 
		{
			this.time = time;
			this.completeHandler = completeHandler;
			this.text = text;
			this.itemWidth = itemWidth;
			this.itemHeight = itemHeight;
			
			back = new Sprite();
			addChild(back);
			back.graphics.beginFill(Color.BLACK_TRUE);
			back.graphics.drawRect(0, 0, itemWidth, itemHeight);
			back.graphics.endFill();
			back.alpha = 0;
			
			white = new Sprite();
			addChild(white);
			
			textImage = new Bitmap();
			addChild(textImage);
			
			maskClip = new Sprite();
			addChild(maskClip);
			
			textImage.bitmapData = TextUtils.createTextFieldData(text, itemWidth - Config.DIALOG_MARGIN * 2 - Config.FINGER_SIZE * 2, 10, 
																	true, TextFormatAlign.CENTER, TextFieldAutoSize.CENTER, 
																	Config.FINGER_SIZE * .34, true, Style.color(Style.COLOR_TEXT), Style.color(Style.COLOR_BACKGROUND));
			
			white.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			white.graphics.drawRect(0, 0, itemWidth - Config.DIALOG_MARGIN * 2, textImage.height + Config.FINGER_SIZE * 1.5);
			white.graphics.endFill();
			
			maskClip.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			maskClip.graphics.drawRect(0, 0, itemWidth - Config.DIALOG_MARGIN * 2, textImage.height + Config.FINGER_SIZE * 1.5);
			maskClip.graphics.endFill();
			
			white.x = int(itemWidth * .5 - white.width * .5);
			maskClip.x = int(itemWidth * .5 - white.width * .5);
			var whiteY:int = int((itemHeight - white.height) * .37);
			white.visible = false;
			
			textImage.x = int(itemWidth * .5 - textImage.width * .5);
			var textImageY:int = int(whiteY + white.height * .5 - textImage.height * .5);
			textImage.visible = false;
			
			white.y = whiteY + Config.FINGER_SIZE * .7;
			maskClip.y = whiteY + Config.FINGER_SIZE * .7;
			textImage.y = textImageY + Config.FINGER_SIZE;
		//	maskClip.visible = false;
			textImage.mask = maskClip;
			
			var targetHeight:int = white.height;
			white.height = Math.max(1, white.height - Config.FINGER_SIZE * 1.7);
			maskClip.height = Math.max(1, white.height - Config.FINGER_SIZE * 1.7);
			
			TweenMax.to(back, 0.2, {alpha:0.3});
			
			TweenMax.to(white, 0.5, {delay:0.0, y:whiteY, height:targetHeight, onStart:showWhite, ease:Back.easeOut});
			TweenMax.to(maskClip, 0.5, {delay:0.0, y:whiteY, height:targetHeight, ease:Back.easeOut});
			TweenMax.to(textImage, 0.5, {delay:0.0, y:textImageY, onStart:showText, ease:Back.easeOut});
			
			TweenMax.delayedCall(time, hide);
		}
		
		private function hide():void 
		{
			if (white != null)
			{
				TweenMax.to(white, 0.3, {y:white.y - Config.FINGER_SIZE, height:0, onComplete:onHided});
				TweenMax.to(textImage, 0.3, {y:textImage.y - Config.FINGER_SIZE});
				TweenMax.to(back, 0.3, {alpha:0});
				TweenMax.to(maskClip, 0.3, {y:maskClip.y - Config.FINGER_SIZE, height:0});
			}
		}
		
		private function onHided():void 
		{
			if (completeHandler != null)
			{
				completeHandler();
			}
		}
		
		private function showText():void 
		{
			textImage.visible = true;
		}
		
		private function showWhite():void 
		{
			white.visible = true;
		}
		
		public function dispose():void
		{
			completeHandler = null;
			
			if (back != null)
			{
				UI.destroy(back);
				back = null;
			}
			
			if (white != null)
			{
				UI.destroy(white);
				white = null;
			}
			if (maskClip != null)
			{
				UI.destroy(maskClip);
				maskClip = null;
			}
			if (textImage != null)
			{
				UI.destroy(textImage);
				textImage = null;
			}
		}
	}
}