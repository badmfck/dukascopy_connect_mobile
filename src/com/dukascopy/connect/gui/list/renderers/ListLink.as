package com.dukascopy.connect.gui.list.renderers {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.CountriesData;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.sys.assets.Assets;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.vo.EntryPointVO;
	import flash.display.IBitmapDrawable;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author IgorBloom
	 */
	
	public class ListLink extends BaseRenderer implements IListRenderer{
		
		protected var tfLabel:TextField;
		protected var tfInteger:TextField;
		protected var tfFraction:TextField;
		protected var tfCurrency:TextField;
		
		protected var padding:int = Config.FINGER_SIZE * .3;
		
		protected var itemHeight:int = Config.FINGER_SIZE;
		protected var format:TextFormat=new TextFormat(Config.defaultFontName, FontSize.BODY, Style.color(Style.COLOR_TEXT));
		
		public function ListLink() {
			tfLabel = new TextField();
			tfLabel.autoSize = TextFieldAutoSize.NONE;
			tfLabel.defaultTextFormat = format;
			tfLabel.text = "Pp";
			tfLabel.height = tfLabel.textHeight + 4;
			tfLabel.text = "";
			tfLabel.multiline = false;
			tfLabel.wordWrap = false;
			tfLabel.x = padding;
			tfLabel.y = Math.round((itemHeight - tfLabel.height) * .5);
			
			addChild(tfLabel);
		}
		
		/* INTERFACE com.dukascopy.connect.gui.list.renderers.IListRenderer */
		public function getHeight(data:ListItem, width:int):int {
			return itemHeight;
		}
		
		public function getView(li:ListItem, h:int, width:int, highlight:Boolean=false):IBitmapDrawable {
			var data:Object = getData(li);			
			graphics.clear();
			if (highlight) {
				graphics.beginFill(Style.color(Style.FILTER_TABS_COLOR_TAB_BG_SELECTED));
				graphics.drawRect(0, 0, width, h);
				graphics.endFill();
			}
			graphics.beginFill(Style.color(Style.COLOR_LINE_SSL));
			graphics.drawRect(0, h - 1, width, 1);
			if ("disabled" in li.data && li.data.disabled){
				tfLabel.textColor = Style.color(Style.COLOR_TEXT_DISABLE);
			}
			if (!("fullLink" in data) || data.fullLink == undefined)
			{
				if ("id" in data)
				{
					tfLabel.htmlText = data.id as String;
				}
				else if("label" in data)
				{
					tfLabel.text = data.label;
				}
			}
			else
				tfLabel.htmlText = data.fullLink as String;
			tfLabel.width = width - tfLabel.x - padding;			
			return this;
		}
		
		protected function getData(li:ListItem):Object 
		{
			return li.data;
		}
		
		public function dispose():void {
			graphics.clear();
			if (tfLabel != null)
				tfLabel.text = "";
			tfLabel = null;		
			format = null
		}
		
		/* INTERFACE com.dukascopy.connect.gui.list.renderers.IListRenderer */
		public function get isTransparent():Boolean {
			return true;
		}
	}
}