package com.dukascopy.connect.gui.list.renderers {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.CountriesData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.sys.assets.Assets;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.vo.EntryPointVO;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
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
	public class ListPayCurrency extends BaseRenderer implements IListRenderer {
		
		private var tfLabel:TextField;
		private var tfName:TextField;
		
		private var padding:int = Config.DOUBLE_MARGIN;
		
		private var itemHeight:int = Config.FINGER_SIZE;
		private var format:TextFormat = new TextFormat(Config.defaultFontName, FontSize.BODY, Style.color(Style.COLOR_TEXT));
		private var format2:TextFormat = new TextFormat(Config.defaultFontName, FontSize.SUBHEAD, Style.color(Style.COLOR_TEXT));
		private var flagIcon:Bitmap;
		
		private var ICON_SIZE:int = Config.FINGER_SIZE * .6;
		
		public function ListPayCurrency() {
			tfLabel = new TextField();
			tfLabel.autoSize = TextFieldAutoSize.LEFT;
			tfLabel.defaultTextFormat = format;
			tfLabel.text = "Pp";
			tfLabel.multiline = false;
			tfLabel.wordWrap = false;
			tfLabel.x = padding;
			tfLabel.y = Math.round((itemHeight - tfLabel.textHeight) * .5);
			addChild(tfLabel);
			
			tfName = new TextField();
			tfName.autoSize = TextFieldAutoSize.LEFT;
			tfName.defaultTextFormat = format2;
			tfName.text = "Pp";
			tfName.multiline = false;
			tfName.wordWrap = false;
			tfName.x = padding;
			tfName.y = Math.round((itemHeight - tfName.textHeight) * .5);
			addChild(tfName);
			
			flagIcon = new Bitmap();
			addChild(flagIcon);
		}
		
		/* INTERFACE com.dukascopy.connect.gui.list.renderers.IListRenderer */
		public function getHeight(data:ListItem, width:int):int {
			return itemHeight;
		}
		
		public function getView(li:ListItem, h:int, width:int, highlight:Boolean=false):IBitmapDrawable {
			var data:Object = li.data;
			
			graphics.clear();
			if (highlight) {
				graphics.beginFill(Style.color(Style.FILTER_TABS_COLOR_TAB_BG_SELECTED));
				graphics.drawRect(0, 0, width, h);
				graphics.endFill();
			}
			
			graphics.beginFill(Style.color(Style.COLOR_LINE_SSL));
			graphics.drawRect(0, itemHeight - 1, width, 1);
			var originalCurrency:String;
			if(li.data != null){
				if (li.data is String)
				{
					var currencyText:String = li.data as String;
					originalCurrency = currencyText;
					if (Lang[currencyText] != null)
					{
						currencyText = Lang[currencyText];
					}
					tfLabel.text = currencyText;
				}
				if ("label" in li.data == true)
				{
					originalCurrency = li.data.label as String;
					tfLabel.text = li.data.label as String;
				}
			}
			tfLabel.width = width - tfLabel.x - padding;
			tfLabel.x = int(width - padding - tfLabel.width);
			
			
			if (Lang["currency_" + originalCurrency] != null)
			{
				tfName.text = Lang["currency_" + originalCurrency];
			}
			else{
				tfName.text = "";
			}
			
			UI.disposeBMD(flagIcon.bitmapData);			
			
			if (data != ""){
				flagIcon.visible = true;
				var flagAsset:Sprite = UI.getFlagByCurrency(data as String);			
				flagIcon.bitmapData = UI.renderAsset(flagAsset, ICON_SIZE, ICON_SIZE, false, "ListPayCurrency.flagIcon");
				
				flagIcon.y = int(h * .5 - ICON_SIZE * .5); // beacause height is FINGER SIZE
				flagIcon.x = padding;
				
				tfName.x = flagIcon.x + flagIcon.width + padding;
			}else{
				tfName.x = padding;
			}
			
			return this;
		}
		
		public function dispose():void {
			graphics.clear();
			
			if (flagIcon != null){
				UI.destroy(flagIcon);
				flagIcon = null;
			}
			
			if (tfLabel != null)
				tfLabel.text = "";
			tfLabel = null;
			if (tfName != null)
				tfName.text = "";
			tfName = null;
			format = null;
			format2 = null;
		}
		
		/* INTERFACE com.dukascopy.connect.gui.list.renderers.IListRenderer */
		public function get isTransparent():Boolean {
			return true;
		}
	}
}