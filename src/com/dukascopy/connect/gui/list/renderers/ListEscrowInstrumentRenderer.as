package com.dukascopy.connect.gui.list.renderers {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import flash.display.Bitmap;
	import flash.display.IBitmapDrawable;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author Alexey
	 */
	
	public class ListEscrowInstrumentRenderer extends BaseRenderer implements IListRenderer{
		
		protected var walletName:TextField;
		private var amount:TextField;
		protected var padding:int = Config.FINGER_SIZE * .2;
		protected var itemHeight:int = Config.FINGER_SIZE;
		protected var ICON_SIZE:int = Config.FINGER_SIZE * .5;
		protected var format:TextFormat=new TextFormat(Config.defaultFontName, FontSize.BODY, Style.color(Style.COLOR_TEXT));
		private var icon:Bitmap;
		
		public function ListEscrowInstrumentRenderer() {
			
			icon = new Bitmap();
			
			format.size = FontSize.SUBHEAD;
			walletName = new TextField();
			walletName.autoSize = TextFieldAutoSize.LEFT;
			walletName.defaultTextFormat = format;
			walletName.text = "Pp";
			walletName.multiline = false;
			walletName.wordWrap = false;
			walletName.x = ICON_SIZE + padding * 2;
			walletName.textColor = Style.color(Style.COLOR_TEXT);
			walletName.y = Math.round((itemHeight - walletName.textHeight) * .5);
			
			format.size = FontSize.TITLE_2;
			format.bold = false;
			amount = new TextField();
			amount.autoSize = TextFieldAutoSize.LEFT;
			amount.defaultTextFormat = format;
			amount.text = "Pp";
			amount.multiline = false;
			amount.wordWrap = false;
			amount.y = Math.round((itemHeight - amount.textHeight) * .5);
			amount.textColor = Style.color(Style.COLOR_TEXT)
			
			addChild(icon);
			addChild(amount);
			addChild(walletName);
		}
		
		/* INTERFACE com.dukascopy.connect.gui.list.renderers.IListRenderer */
		public function getHeight(data:ListItem, w:int):int {
			return itemHeight;
		}
		
		public function getView(li:ListItem, h:int, w:int, highlight:Boolean=false):IBitmapDrawable {
			var data:Object = li.data;
			
			drawBack(highlight, h, w);
			drawIcon(li.data);
			drawName(li.data);
			drawAmount(li.data);
			
			position(w);
			
			return this;
		}
		
		private function drawName(data:Object):void {
			var text:String = data.name;
			if (text != null) {
				walletName.text = text;
			} else {
				walletName.text = "";
			}
		}
		
		private function position(w:int):void {
			amount.x = int(amount.width - Config.FINGER_SIZE * .2);
			walletName.y = Math.round(itemHeight * .5 - walletName.height - Config.FINGER_SIZE * .02);
		}
		
		private function drawAmount(data:Object):void {
			var textAmount:String = getAmountText(data);
			amount.htmlText = textAmount;
		}
		
		protected function getAmountText(data:Object):String {
			var result:String;
			
			var baseSize:Number = FontSize.TITLE_2;
			var captionSize:Number = FontSize.SUBHEAD;
			var color:String = "#" + Style.color(Style.COLOR_TEXT).toString(16);
			
			result = "<font color='" + color + "' size='" + baseSize + "'>ADS:</font><font color='" + color + "' size='" + captionSize + "'>751</font>";
			result += "<font color='" + color + "' size='" + baseSize + "'>, COINS:</font><font color='" + color + "' size='" + captionSize + "'>124 123</font>";
			return result;
		}
		
		private function drawBack(highlight:Boolean, h:int, w:int):void {
			graphics.clear();
			if (highlight) {
				graphics.beginFill(Style.color(Style.FILTER_TABS_COLOR_TAB_BG_SELECTED));
				graphics.drawRect(0, 0, w, h);
				graphics.endFill();
			}
		}
		
		private function drawIcon(data:Object):void {
			var iconClass:Class = UI.getCryptoIconClass(data.code);
			if (iconClass != null) {
				if (icon.bitmapData != null) {
					icon.bitmapData.dispose();
					icon.bitmapData = null;
				}
				
				var iconSource:Sprite = (new iconClass)();
				UI.scaleToFit(iconSource, ICON_SIZE, ICON_SIZE);
				icon.bitmapData = UI.getSnapshot(iconSource);
				iconSource = null;
			}
		}
		
		public function dispose():void {
			graphics.clear();
			
			UI.destroy(icon);
			icon = null;
			if (amount != null)
				amount.text = "";
			amount = null;
			if (walletName != null)
				walletName.text = "";
			walletName = null;
			format = null;
		}
		
		/* INTERFACE com.dukascopy.connect.gui.list.renderers.IListRenderer */
		public function get isTransparent():Boolean {
			return true;
		}
	}
}