package com.dukascopy.connect.screens.dialogs.escrow 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.utils.TextUtils;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class PriceClip extends Sprite
	{
		private var titleClip1:Bitmap;
		private var titleClip2:Bitmap;
		private var valueClip1:Bitmap;
		private var valueClip2:Bitmap;
		
		public function PriceClip() 
		{
			titleClip1 = new Bitmap();
			addChild(titleClip1);
			
			titleClip2 = new Bitmap();
			addChild(titleClip2);
			
			valueClip1 = new Bitmap();
			addChild(valueClip1);
			
			valueClip2 = new Bitmap();
			addChild(valueClip2);
		}
		
		public function draw(title1:String, value1:String, title2:String, value2:String, clipWidth:int, sidePadding:int):void
		{
			var contentWidth:int = clipWidth - sidePadding * 2;
			
			if (titleClip1.bitmapData != null)
			{
				titleClip1.bitmapData.dispose();
				titleClip1.bitmapData = null;
			}
			titleClip1.bitmapData = TextUtils.createTextFieldData(title1, contentWidth, 10, true,
																	TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
																	FontSize.SUBHEAD, true, Style.color(Style.COLOR_SUBTITLE),
																	Style.color(Style.COLOR_BACKGROUND), false);
																	
			if (titleClip2.bitmapData != null)
			{
				titleClip2.bitmapData.dispose();
				titleClip2.bitmapData = null;
			}
			titleClip2.bitmapData = TextUtils.createTextFieldData(title2, contentWidth, 10, true,
																	TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
																	FontSize.SUBHEAD, true, Style.color(Style.COLOR_SUBTITLE),
																	Style.color(Style.COLOR_BACKGROUND), false);
			if (valueClip1.bitmapData != null)
			{
				valueClip1.bitmapData.dispose();
				valueClip1.bitmapData = null;
			}
			valueClip1.bitmapData = TextUtils.createTextFieldData(value1, contentWidth, 10, true,
																	TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
																	FontSize.BODY, true, Style.color(Style.COLOR_TEXT),
																	Style.color(Style.COLOR_BACKGROUND), false);
			if (valueClip2.bitmapData != null)
			{
				valueClip2.bitmapData.dispose();
				valueClip2.bitmapData = null;
			}
			valueClip2.bitmapData = TextUtils.createTextFieldData(value2, contentWidth, 10, true,
																	TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
																	FontSize.BODY, true, Style.color(Style.COLOR_TEXT),
																	Style.color(Style.COLOR_BACKGROUND), false);
			
			var paddingH:int = Config.FINGER_SIZE * .3;
			var paddingV:int = Config.FINGER_SIZE * .15;
			
			var sidePaddingVertical:int = Config.FINGER_SIZE * .5;
			titleClip1.y = sidePaddingVertical;
			valueClip1.y = int(titleClip1.y + Config.FINGER_SIZE * .3 + paddingV);
			
			titleClip1.x = sidePadding;
			valueClip1.x = sidePadding;
			
			if (Math.max(titleClip1.width, valueClip1.width) + Math.max(titleClip2.width, valueClip2.width) + paddingH > contentWidth)
			{
				titleClip2.x = sidePadding;
				valueClip2.x = sidePadding;
				
				titleClip2.y = int(valueClip2.y + valueClip2.height + paddingV * 2);
				valueClip2.y = int(titleClip2.y +  + Config.FINGER_SIZE * .3 + paddingV);
			}
			else
			{
				titleClip2.y = sidePaddingVertical;
				valueClip2.y = int(titleClip2.y +  + Config.FINGER_SIZE * .3 + paddingV);
				var position:int = int(sidePadding + Math.max(titleClip1.width, valueClip1.width) + paddingH);
				if (position < contentWidth * .5 + sidePadding)
				{
					position = contentWidth * .5 + sidePadding;
				}
				if (position + sidePadding + Math.max(titleClip2.width, valueClip2.width) > contentWidth)
				{
					position = sidePadding + contentWidth - Math.max(titleClip2.width, valueClip2.width);
				}
				titleClip2.x = position;
				valueClip2.x = position;
			}
			
			graphics.clear();
			graphics.beginFill(Style.color(Style.COLOR_SEPARATOR));
			graphics.drawRect(0, 0, clipWidth, int(Math.max(valueClip1.y + valueClip1.height, valueClip2.y + valueClip2.height) + sidePaddingVertical));
		}
		
		public function dispose():void
		{
			if (titleClip1 != null)
			{
				UI.destroy(titleClip1);
				titleClip1 = null;
			}
			if (titleClip2 != null)
			{
				UI.destroy(titleClip2);
				titleClip2 = null;
			}
			if (valueClip1 != null)
			{
				UI.destroy(valueClip1);
				valueClip1 = null;
			}
			if (valueClip2 != null)
			{
				UI.destroy(valueClip2);
				valueClip2 = null;
			}
		}
	}
}