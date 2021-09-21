package com.dukascopy.connect.gui.list.renderers {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.type.MainColors;
	import flash.display.Bitmap;
	import flash.display.IBitmapDrawable;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Alexey
	 */
	
	public class ListEscrowInstrumentRenderer extends BaseRenderer implements IListRenderer{
		
		private static const TEXT_SIZE_LABEL:int = Config.FINGER_SIZE * .3;
		private static const TEXT_SIZE_DESC:int = Config.FINGER_SIZE * .2;
		private static const TEXT_SIZE_DESC_VALS:int = Config.FINGER_SIZE * .17;
		private static const ICON_SIZE:int = Config.FINGER_SIZE * .7;
		private static const NEW_COUNT_SIZE:int = Config.FINGER_SIZE * .42;
		private static const PADDING:int = Config.FINGER_SIZE * .2;
		
		private var itemHeight:int;
		
		private var tfLabel:TextField;
		private var tfDescription:TextField;
		private var icon:Bitmap;
		private var newMessages:Sprite;
		private var tfNewMessagesCnt:TextField;
		
		protected var format:TextFormat = new TextFormat(Config.defaultFontName, FontSize.BODY, Style.color(Style.COLOR_TEXT));
		
		public function ListEscrowInstrumentRenderer() {
			
			format.size = TEXT_SIZE_LABEL;
			tfLabel = new TextField();
			tfLabel.autoSize = TextFieldAutoSize.LEFT;
			tfLabel.defaultTextFormat = format;
			tfLabel.text = "Pp";
			tfLabel.multiline = false;
			tfLabel.wordWrap = false;
			tfLabel.x = ICON_SIZE + PADDING * 2;
			tfLabel.textColor = Style.color(Style.COLOR_TEXT);
			tfLabel.y = Config.DOUBLE_MARGIN;
			
			format.size = TEXT_SIZE_DESC;
			format.bold = false;
			tfDescription = new TextField();
			tfDescription.autoSize = TextFieldAutoSize.LEFT;
			tfDescription.defaultTextFormat = format;
			tfDescription.text = "Pp";
			tfDescription.multiline = false;
			tfDescription.wordWrap = false;
			tfDescription.x = tfLabel.x;
			tfDescription.y = tfLabel.y + tfLabel.height;
			tfDescription.textColor = Style.color(Style.COLOR_TEXT);
			
			itemHeight = tfDescription.y + tfDescription.height + Config.DOUBLE_MARGIN;
			
			icon = new Bitmap();
			icon.x = Config.DOUBLE_MARGIN;
			icon.y = int((itemHeight - ICON_SIZE) * .5);
			
			newMessages = new Sprite();
			newMessages.graphics.beginFill(MainColors.GREEN);
			newMessages.graphics.drawRoundRect(0, 0, NEW_COUNT_SIZE, NEW_COUNT_SIZE, NEW_COUNT_SIZE, NEW_COUNT_SIZE);
			newMessages.graphics.endFill();
				tfNewMessagesCnt = new TextField();
				tfNewMessagesCnt.width = newMessages.width;
				format.align = TextFormatAlign.CENTER;
				format.bold = false;
				format.color = MainColors.WHITE;
				format.size = NEW_COUNT_SIZE * .45;
				tfNewMessagesCnt.defaultTextFormat = format;
				tfNewMessagesCnt.text = 'Pp';
				tfNewMessagesCnt.height = tfNewMessagesCnt.textHeight + 5;
				tfNewMessagesCnt.y = int((newMessages.height - tfNewMessagesCnt.height) * .5);
			newMessages.y = int((itemHeight - NEW_COUNT_SIZE) * .5);
			newMessages.addChild(tfNewMessagesCnt);
			
			addChild(icon);
			addChild(tfDescription);
			addChild(tfLabel);
			addChild(newMessages);
		}
		
		public function getView(li:ListItem, h:int, w:int, highlight:Boolean = false):IBitmapDrawable {
			var data:Object = li.data;
			
			drawBack(highlight, h, w);
			drawIcon(li.data);
			drawName(li.data);
			drawAmount(li.data);
			
			newMessages.visible = false;
			var newCount:int = int(Math.random() * 100);
			if (newCount != 0) {
				newMessages.x = w - NEW_COUNT_SIZE - Config.DOUBLE_MARGIN;
				newMessages.visible = true;
				if (newCount > 100)
					tfNewMessagesCnt.text = "+99";
				else
					tfNewMessagesCnt.text = "+" + newCount + "";
			}
			
			return this;
		}
		
		private function drawName(data:Object):void {
			var code:String = data.code;
			if (code == "DCO")
				code = "DUK+";
			var text:String = String(data.name + " (" + code + ")").toUpperCase();
			if (text != null) {
				tfLabel.text = text;
			} else {
				tfLabel.text = "";
			}
		}
		
		private function drawAmount(data:Object):void {
			var textAmount:String = getAmountText(data);
			tfDescription.htmlText = textAmount;
		}
		
		protected function getAmountText(data:Object):String {
			var result:String;
			
			var baseSize:Number = FontSize.TITLE_2;
			var captionSize:Number = FontSize.SUBHEAD;
			var color:String = "#" + Style.color(Style.COLOR_TEXT).toString(16);
			
			result = "<font color='" + color + "' size='" + TEXT_SIZE_DESC + "'>ADS: </font><font color='#CD3F43' size='" + TEXT_SIZE_DESC_VALS + "'>751</font>";
			result += "<font color='" + color + "' size='" + TEXT_SIZE_DESC + "'>, COINS: </font><font color='#CD3F43' size='" + TEXT_SIZE_DESC_VALS + "'>124 123</font>";
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
			if (tfDescription != null)
				tfDescription.text = "";
			tfDescription = null;
			if (tfLabel != null)
				tfLabel.text = "";
			tfLabel = null;
			format = null;
		}
		
		/* INTERFACE com.dukascopy.connect.gui.list.renderers.IListRenderer */
		public function get isTransparent():Boolean {
			return true;
		}
		
		/* INTERFACE com.dukascopy.connect.gui.list.renderers.IListRenderer */
		public function getHeight(data:ListItem, w:int):int {
			return itemHeight;
		}
	}
}