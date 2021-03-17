package com.dukascopy.connect.gui.list.renderers.chatMessageElements 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.ButtonActionData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author ...
	 */
	public class SystemMessageButton extends Sprite
	{
		private var message:TextField;
		private var verticalPadding:int;
		private var horizontalPadding:int;
		
		public function SystemMessageButton() 
		{
			var textFormat:TextFormat = new TextFormat();
			textFormat.font = Config.defaultFontName;
			textFormat.size = Config.FINGER_SIZE * .3;
			textFormat.color = 0x764242;
			textFormat.align = TextFormatAlign.CENTER;
			
			verticalPadding = Config.FINGER_SIZE * .1;
			horizontalPadding = Config.FINGER_SIZE * .4;
			
			message = new TextField();
				message.defaultTextFormat = textFormat;
				message.text = "";
				message.wordWrap = true;
				message.multiline = true;
				message.mouseEnabled = false;
			addChild(message);
			
			message.x = horizontalPadding;
			message.y = verticalPadding;
		}
		
		public function draw(data:ButtonActionData, maxWidth:int):void
		{
			message.width = 1000;
			
		//	message.width = maxWidth - horizontalPadding * 2;
			message.text = data.text;
			message.width = message.textWidth + 6;
			message.height = message.textHeight + 4;
			message.textColor = data.textColor;
			graphics.clear();
			graphics.lineStyle(1, data.outlineColor, 1, true);
			graphics.beginFill(data.backColor);
			graphics.drawRoundRect(0, 0, message.width + horizontalPadding * 2, message.y + message.height + verticalPadding, Config.FINGER_SIZE * .6, Config.FINGER_SIZE * .6);
			graphics.endFill();
		}
		
		public function destroy():void 
		{
			if (message)
			{
				UI.destroy(message);
				message = null;
			}
			graphics.clear();
		}
	}
}