package com.dukascopy.connect.screens.dialogs.escrow 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.utils.TextUtils;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class OfferStatusClip extends Sprite
	{
		private var field:Bitmap;
		private var contentPadding:int;
		private var contentPaddingV:int;
		
		public function OfferStatusClip() 
		{
			contentPadding = Config.FINGER_SIZE * .35;
			contentPaddingV = Config.FINGER_SIZE * .16;
			
			field = new Bitmap();
			addChild(field);
		}
		
		public function dispose():void 
		{
			graphics.clear();
			if (field != null)
			{
				UI.destroy(field);
				field = null;
			}
		}
		
		public function draw(itemWidth:Number, text:String, color:Number):void 
		{
			if (field != null)
			{
				if (field.bitmapData != null)
				{
					field.bitmapData.dispose();
					field.bitmapData = null;
				}
				
				field.bitmapData = TextUtils.createTextFieldData(text, itemWidth - contentPadding * 2, 10, true,
																	TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
																	FontSize.SUBHEAD, true, Color.WHITE,
																	color, false);
				graphics.clear();
				var itemHeight:int = field.height + contentPaddingV * 2;
				graphics.beginFill(color);
				graphics.drawRoundRect(0, 0, field.width + contentPadding * 2, itemHeight, itemHeight, itemHeight);
				graphics.endFill();
				field.x = contentPadding;
				field.y = contentPaddingV;
			}
		}
	}
}