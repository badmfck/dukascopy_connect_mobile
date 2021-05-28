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
		
		protected var tfLabel:TextField;
		protected var tfName:TextField;
		
		protected var padding:int = Config.FINGER_SIZE * .2;
		
		protected var itemHeight:int = Config.FINGER_SIZE;
		protected var format:TextFormat = new TextFormat(Config.defaultFontName, FontSize.BODY, Style.color(Style.COLOR_TEXT));
		protected var format2:TextFormat = new TextFormat(Config.defaultFontName, FontSize.SUBHEAD, Style.color(Style.COLOR_TEXT));
		protected var flagIcon:Sprite;
		
		protected var ICON_SIZE:int = Config.FINGER_SIZE * .6;
		
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
			
			flagIcon = new Sprite();
			addChild(flagIcon);
		}
		
		/* INTERFACE com.dukascopy.connect.gui.list.renderers.IListRenderer */
		public function getHeight(data:ListItem, width:int):int {
			return itemHeight;
		}
		
		public function getView(li:ListItem, h:int, w:int, highlight:Boolean=false):IBitmapDrawable {
			var data:Object = getItemData(li.data);
			
			redrawBack(highlight, h, w);
			
			var originalCurrency:String;
			if(data != null){
				if (data is String)
				{
					var currencyText:String = data as String;
					originalCurrency = currencyText;
					if (Lang[currencyText] != null)
					{
						currencyText = Lang[currencyText];
					}
					tfLabel.text = currencyText;
				}
				if ("label" in data == true)
				{
					originalCurrency = data.label as String;
					tfLabel.text = data.label as String;
				}
			}
			if (Lang["currency_" + originalCurrency] != null)
			{
				tfName.text = Lang["currency_" + originalCurrency];
			}
			else{
				tfName.text = "";
			}
			
			updatePositions(h, w);
			
			drawIcon(li, h);
			
			return this;
		}
		
		protected function updatePositions(h:int, w:int):void 
		{
			tfLabel.y = int(h * .5 - tfLabel.height - Config.FINGER_SIZE * .1);
			tfLabel.width = w - tfLabel.x - padding;
			tfLabel.x = int(w - padding - tfLabel.width);
		}
		
		protected function drawIcon(li:ListItem, h:int):void 
		{
			flagIcon.removeChildren();
			var data:Object = getItemData(li.data);
			if (data != ""){
				flagIcon.visible = true;
				var flagAsset:Sprite = UI.getFlagByCurrency(data as String);
				UI.scaleToFit(flagAsset, ICON_SIZE, ICON_SIZE);
				flagIcon.addChild(flagAsset);
				
				flagIcon.y = int(h * .5 - ICON_SIZE * .5);
				flagIcon.x = padding;
				
				tfName.x = flagIcon.x + flagIcon.width + padding;
			}else{
				tfName.x = padding;
			}
		}
		
		private function redrawBack(highlight:Boolean, h:int, w:int):void 
		{
			graphics.clear();
			if (highlight) {
				graphics.beginFill(Style.color(Style.FILTER_TABS_COLOR_TAB_BG_SELECTED));
				graphics.drawRect(0, 0, w, h);
				graphics.endFill();
			}
			graphics.beginFill(Style.color(Style.COLOR_LINE_SSL));
			graphics.drawRect(0, h - 1, w, 1);
		}
		
		protected function getItemData(data:Object):Object 
		{
			return data;
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