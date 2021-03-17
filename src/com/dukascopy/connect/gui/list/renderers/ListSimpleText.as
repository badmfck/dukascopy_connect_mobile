package com.dukascopy.connect.gui.list.renderers {
	
	import assets.New_selected;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.SelectorItemData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import fl.motion.Color;
	import flash.display.IBitmapDrawable;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class ListSimpleText extends BaseRenderer implements IListRenderer {
		
		private var icon:New_selected;
		
		protected var textFormat:TextFormat = new TextFormat();
		protected var text:TextField;
		protected var bg:Shape;
		
		public function ListSimpleText(){
			bg = new Shape();
				bg.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
				bg.graphics.drawRect(0, 0, 10, 10);
				bg.graphics.endFill();
				bg.graphics.beginFill(0, .10);
				bg.graphics.drawRect(0, 9, 10, 1);
				bg.scale9Grid = new Rectangle(1, 1, 8, 5);
			addChild(bg);
				
				text = new TextField();
				textFormat.font = Config.defaultFontName;
				textFormat.color = Style.color(Style.COLOR_TEXT);
				textFormat.align = TextFormatAlign.LEFT;
				textFormat.size = FontSize.BODY;
				text.defaultTextFormat = textFormat;
			//	text.text = "Pp";
			//	text.height = text.textHeight + 4;
			//	text.text = "";
				text.x = Config.DOUBLE_MARGIN;
				text.wordWrap = true;
				text.y = int(Config.MARGIN * 1.7);
				text.multiline = true;
			addChild(text);
			
			icon = new New_selected();
			var color:Color = new Color();
			color.color = Style.color(Style.ICON_RIGHT_COLOR);
			icon.transform.colorTransform = color;
			UI.scaleToFit(icon, Config.FINGER_SIZE * .3, Config.FINGER_SIZE * .3);
			icon.y = int(Config.FINGER_SIZE * .2);
			addChild(icon);
		}
		
		/* INTERFACE com.dukascopy.connect.gui.list.renderers.IListRenderer */
		public function getHeight(data:ListItem, w:int):int {
			var h:int = setText(data, w);
			return h;
		}
		
		private function setText(data:ListItem, w:int):int 
		{
			var value:String;
			if (data.data is SelectorItemData && (data.data as SelectorItemData).label != null){
				value = (data.data as SelectorItemData).label;
			}
			else if ("label" in data.data && data.data.label != null && data.data.label is String)
			{
				value = data.data.label as String;
			}
			
			if (value != null)
			{
				text.width = w - text.x - Config.DOUBLE_MARGIN * 2 - icon.width;
				text.text = value;
			//	text.width = text.textWidth + 4;
				text.height = text.textHeight + 4;
				return text.y + text.height + int(Config.MARGIN * 2.0);
			}
			return 0;
		}
		
		public function getView(data:ListItem, h:int, w:int, highlight:Boolean = false):IBitmapDrawable {
			setText(data, w);
			if (data.data is SelectorItemData){
				icon.visible = (data.data as SelectorItemData).selected;
			}
			else
			{
				icon.visible = false;
			}
			
			bg.width = w;
			bg.height = h;
			
			icon.x = int(width - Config.DOUBLE_MARGIN - icon.width);
			icon.y = int(h * .5 - icon.height * .5);
			
			return this;
		}
		
		public function dispose():void {
			graphics.clear();
			textFormat = null;
			if (text != null)
				text.text = "";
			text = null;
			if (bg != null)
				bg.graphics.clear();
			bg = null;
			if (icon != null){
				UI.destroy(icon);
				icon = null;
			}
		}
		
		/* INTERFACE com.dukascopy.connect.gui.list.renderers.IListRenderer */
		public function get isTransparent():Boolean {
			return true;
		}
	}
}