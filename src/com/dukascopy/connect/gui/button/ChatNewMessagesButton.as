package com.dukascopy.connect.gui.button 
{
	import assets.ScrollBottomIcon;
	import assets.ScrollBottomIconWhite;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.utils.TextUtils;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class ChatNewMessagesButton extends BitmapButton
	{
		private var unreadedMessagesNum:int = 0;
		private var baseStatus:ImageBitmapData;
		private var baseStatusWhite:ImageBitmapData;
		
		public function ChatNewMessagesButton() 
		{
			setStandartButtonParams();
			setDownScale(1.1);
			
			var target:Sprite = new ScrollBottomIcon();
			UI.scaleToFit(target, Config.FINGER_SIZE, Config.FINGER_SIZE);
			baseStatus = UI.getSnapshot(target);
			setBitmapData(baseStatus);
			
			target = new ScrollBottomIconWhite();
			UI.scaleToFit(target, Config.FINGER_SIZE, Config.FINGER_SIZE);
			baseStatusWhite = UI.getSnapshot(target);
		}
		
		public function setUnreded(value:int):void 
		{
			unreadedMessagesNum = value;
			update();
		}
		
		private function update():void 
		{
			if (unreadedMessagesNum == 0)
			{
				setBitmapData(baseStatus, baseStatus != iconBitmap.bitmapData);
			}
			else
			{
				setBitmapData(createUnrededBitmap(), baseStatus != iconBitmap.bitmapData);
			}
		}
		
		private function createUnrededBitmap():BitmapData 
		{
			var text:ImageBitmapData = TextUtils.createTextFieldData(Math.min(99, unreadedMessagesNum).toString(), 
																	Config.FINGER_SIZE, 10, false, TextFormatAlign.CENTER, 
																	TextFieldAutoSize.LEFT, FontSize.CAPTION_1, false, Color.WHITE, Color.GREEN);
			var textHeight:int = Config.FINGER_SIZE * .4;
			var padding:int = Config.FINGER_SIZE * .08;
			var textWidth:int = Math.max(textHeight, text.width + padding * 2);
			
			var resultText:ImageBitmapData = new ImageBitmapData("ChatNewMessageButton.text", textWidth, textHeight);
			var clip:Sprite = new Sprite();
			clip.graphics.beginFill(Color.GREEN);
			clip.graphics.lineStyle(1, Color.WHITE);
			clip.graphics.drawRoundRect(0, 0, textWidth, textHeight, textHeight, textHeight);
			clip.graphics.endFill();
			resultText.draw(clip);
			resultText.copyPixels(text, text.rect, new Point(int(resultText.width * .5 - text.width * .5), int(resultText.height * .5 - text.height * .5)), null, null, true);
			
			var result:ImageBitmapData = new ImageBitmapData("ChatNewMessageButton.result", baseStatusWhite.width, baseStatusWhite.height);
			result.copyBitmapData(baseStatusWhite, false);
			result.copyPixels(resultText, resultText.rect, new Point(int(result.width - resultText.width), 0), null, null, true);
			
			resultText.dispose();
			text.dispose();
			
			resultText = null;
			text = null;
			return result;
		}
		
		public function isVisible():Boolean 
		{
			return alpha == 1;
		}
		
		public function add():void 
		{
			alpha = 1;
		}
		
		public function remove():void 
		{
			alpha = 0;
			unreadedMessagesNum = 0;
		}
		
		override public function dispose():void
		{
			
			super.dispose();
			baseStatus.dispose();
			baseStatus = null;
		}
	}
}