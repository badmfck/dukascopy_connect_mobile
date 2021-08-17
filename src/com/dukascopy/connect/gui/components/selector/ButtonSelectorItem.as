package com.dukascopy.connect.gui.components.selector 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.SelectorItemData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.text.TextField;
	import flash.text.TextFormat;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class ButtonSelectorItem extends Sprite implements ISelectorItem
	{
		private var textFormat:TextFormat;
		private  var labelField:TextField;
		private var back:Sprite;
		
		private var verticalPadding:int;
		private var horizontalPadding:int;
		private var radius:int = Config.FINGER_SIZE * .2;
		
		
		public function ButtonSelectorItem() {
			textFormat = new TextFormat();
			textFormat.size = FontSize.SUBHEAD;
			textFormat.font = Config.defaultFontName;
			textFormat.color = Style.color(Style.COLOR_TEXT);
			
			back = new Sprite();
			addChild(back);
			labelField = new TextField();		
			
			verticalPadding = Config.FINGER_SIZE * .18;
			horizontalPadding = Config.FINGER_SIZE * .36;
		}
		
		public function dispose():void {
			if (labelField != null){
				UI.destroy(labelField);
				labelField = null;
			}					
			if (textFormat != null){
				textFormat = null;
			}
			UI.destroy(back);
		}
		
		public function render(data:SelectorItemData, select:Boolean = false):ImageBitmapData {
			if (!data)
				return null;
			
			back.graphics.clear();	
			
			var labelText:String = "";
			if (data.label != null)
			{
				labelText = data.label;
			}
			else if(data.data != null && "name" in data.data)
			{
				labelText = data.data.name;
			}
			labelField.text = labelText;
			labelField.setTextFormat(textFormat);
			labelField.width = labelField.textWidth + 4;
			labelField.height = labelField.textHeight + 4;
			labelField.x = horizontalPadding;
			labelField.y = verticalPadding;
			
			var countText:String = "";
			back.addChild(labelField);		
			
			back.graphics.lineStyle(Math.max(2, int(Config.FINGER_SIZE * .03)), Style.color(Style.FILTER_TABS_COLOR_TAB_BG_BORDER));
			if (select) {
				back.graphics.beginFill(Style.color(Style.COLOR_SEPARATOR));
				back.graphics.drawRoundRect(0, 0, labelField.width + horizontalPadding * 2, labelField.height + verticalPadding * 2, radius, radius);
				back.graphics.endFill();
			} else {
				back.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
				back.graphics.drawRoundRect(0, 0, labelField.width + horizontalPadding * 2, labelField.height + verticalPadding * 2, radius, radius);
				back.graphics.endFill();
			}			
			var bitmapData:ImageBitmapData = new ImageBitmapData("TextSelectorItem", labelField.width + horizontalPadding * 2, labelField.height + verticalPadding * 2);
			bitmapData.drawWithQuality(back, null,null,null,null,false,StageQuality.HIGH);			
			return bitmapData;
		}
	}
}