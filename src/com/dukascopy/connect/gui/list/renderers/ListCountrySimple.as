package com.dukascopy.connect.gui.list.renderers{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.CountriesData;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import flash.display.IBitmapDrawable;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author IgorBloom
	 */
	public class ListCountrySimple extends BaseRenderer implements IListRenderer{
		
		protected var tfCountry:TextField;
		
		protected var padding:int = Config.FINGER_SIZE * .3;
		
		protected var itemHeight:int = Config.FINGER_SIZE;
		protected var format:TextFormat = new TextFormat(Config.defaultFontName, FontSize.BODY, Style.color(Style.COLOR_TEXT));
		
		public function ListCountrySimple() {
			tfCountry = new TextField();
			tfCountry.defaultTextFormat = format;
			tfCountry.alpha = .5;
			tfCountry.x = padding;
			addChild(tfCountry);
		}
		
		/* INTERFACE com.dukascopy.connect.gui.list.renderers.IListRenderer */
		public function getHeight(data:ListItem, width:int):int {
			if (data.data.length == 2)
				return Config.FINGER_SIZE_DOT_75;
			return itemHeight;
		}
		
		public function getView(li:ListItem,h:int, width:int,highlight:Boolean=false):IBitmapDrawable {
			var data:Array = li.data as Array;
			
			var isSelected:Boolean = false;
			var currentCountry:Array = CountriesData.getCurrentCountry();
			//if (data != null && data.length > 2 && data[2] == CountriesData.getCurrentCountry()[2]) {
			if (data != null && data.length > 2 && currentCountry!=null &&  data[2] ==currentCountry[2]) {
				isSelected = true;
			}
			graphics.clear();
			
			if (highlight && data.length != 2) {
				graphics.beginFill(Style.color(Style.FILTER_TABS_COLOR_TAB_BG_SELECTED));
				graphics.drawRect(0, 0, width, h);
				graphics.endFill();
			} else if (isSelected == true) {
				graphics.beginFill(Style.color(Style.COLOR_TIP_BACKGROUND));
				graphics.drawRect(0, 0, width, h);
				graphics.endFill();
			}
			if (data.length == 2) {
				tfCountry.textColor = Color.RED_DARK;
				tfCountry.text = data[1];
				tfCountry.width = width - padding * 2;
				tfCountry.alpha = 1;
			} else {
				graphics.beginFill(Style.color(Style.COLOR_LINE_SSL));
				graphics.drawRect(0, h - 1, width, 1);
				graphics.endFill();
				tfCountry.textColor = Style.color(Style.COLOR_TEXT);
				tfCountry.text = data[4];
				tfCountry.width = width - tfCountry.x - padding;
			}
			
			tfCountry.y = Math.round((h - tfCountry.textHeight) * .5);
			
			return this;
		}
		
		public function dispose():void {
			graphics.clear();
			if (tfCountry != null)
				tfCountry.text = "";
			tfCountry = null;
			format = null;
		}
		
		/* INTERFACE com.dukascopy.connect.gui.list.renderers.IListRenderer */
		
		public function get isTransparent():Boolean {
			return true;
		}
	}
}