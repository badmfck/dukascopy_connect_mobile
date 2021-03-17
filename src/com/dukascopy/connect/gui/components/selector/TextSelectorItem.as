package com.dukascopy.connect.gui.components.selector 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.SelectorItemData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.type.MainColors;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFormat;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class TextSelectorItem extends Sprite implements ISelectorItem
	{
		private var back:Sprite;
		private var textFormat:TextFormat;
		private var verticalPadding:int;
		private var horizontalPadding:int;
		 
		public function TextSelectorItem() 
		{
			textFormat = new TextFormat();
			textFormat.size = Config.FINGER_SIZE * .3;
			
			back = new Sprite();
			addChild(back);
			
			verticalPadding = Config.FINGER_SIZE * .1;
			horizontalPadding = Config.FINGER_SIZE * .25;
		}
		
		public function render(data:SelectorItemData, select:Boolean = false):ImageBitmapData
		{
			if (!data)
			{
				return null;
			}
			
			back.graphics.clear();
			var textField:TextField = UI.getTextField();
			
			textFormat.color = (select == true)?MainColors.WHITE:AppTheme.GREY_MEDIUM;
			
			textField.text = data.label;
			textField.setTextFormat(textFormat);
			textField.width = textField.textWidth + 4;
			textField.height = textField.textHeight + 4;
			
			if (select)
			{
				textFormat.color = MainColors.WHITE;
				back.graphics.beginFill(0xFFC600);
				back.graphics.drawRoundRect(0, 0, textField.width + horizontalPadding * 2, textField.height + verticalPadding * 2, Config.FINGER_SIZE * .6, Config.FINGER_SIZE * .6);
				back.graphics.endFill();
			}
			else
			{
				textFormat.color = AppTheme.GREY_MEDIUM;
			}
			
			var bitmapData:ImageBitmapData = new ImageBitmapData("TextSelectorItem", textField.width + horizontalPadding * 2, textField.height + verticalPadding * 2);
			bitmapData.draw(back);
			var matrix:Matrix = new Matrix();
			matrix.translate(horizontalPadding, verticalPadding);
			bitmapData.draw(textField, matrix);
			
			return bitmapData;
		}
	}
}