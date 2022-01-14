package com.dukascopy.connect.gui.list.renderers {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.managers.escrow.vo.EscrowAdsCryptoVO;
	import com.dukascopy.connect.managers.escrow.vo.EscrowPrice;
	import com.dukascopy.connect.screens.payments.card.TypeCurrency;
	import com.dukascopy.connect.sys.questionsManager.QuestionsManager;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.type.MainColors;
	import com.dukascopy.connect.utils.BaseGraphicsUtils;
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
	 * @author Sergey Dobarin
	 */
	
	public class ListEscrowInstrumentRendererBig extends BaseRenderer implements IListRenderer{
		
		private var title:TextField;
		private var subtitle_1:TextField;
		private var price:TextField;
		private var percent:TextField;
		
		private var subtitle_2:TextField;
		private var description:TextField;
		private var icon:Bitmap;
		private var newMessages:Sprite;
		private var tfNewMessagesCnt:TextField;
		private var itemHeight:int;
		private var graph:Sprite;
		private var iconSize:int;
		private var formatPercentGreen:TextFormat;
		private var formatPercentRed:TextFormat;
		
		public function ListEscrowInstrumentRendererBig() {
			
			iconSize = Config.FINGER_SIZE * .35;
			
			itemHeight = Config.FINGER_SIZE * 3;
			
			var formatTitle:TextFormat = new TextFormat();
			formatTitle.font = Config.defaultFontName;
			formatTitle.size = FontSize.AMOUNT;
			formatTitle.align = TextFormatAlign.LEFT;
			formatTitle.color = Style.color(Style.COLOR_TEXT);
			
			var formatSubtitle:TextFormat = new TextFormat();
			formatSubtitle.font = Config.defaultFontName;
			formatSubtitle.size = FontSize.SUBHEAD;
			formatSubtitle.align = TextFormatAlign.LEFT;
			formatSubtitle.color = Style.color(Style.COLOR_SUBTITLE);
			
			formatPercentGreen = new TextFormat();
			formatPercentGreen.font = Config.defaultFontName;
			formatPercentGreen.size = FontSize.SUBHEAD;
			formatPercentGreen.align = TextFormatAlign.LEFT;
			formatPercentGreen.color = Color.GREEN;
			
			formatPercentRed = new TextFormat();
			formatPercentRed.font = Config.defaultFontName;
			formatPercentRed.size = FontSize.SUBHEAD;
			formatPercentRed.align = TextFormatAlign.LEFT;
			formatPercentRed.color = Color.RED;
			
			title = new TextField();
			title.defaultTextFormat = formatTitle;
			title.text = "Pp";
			title.height = title.textHeight + 4;
			title.text = "";
			title.multiline = false;
			title.wordWrap = false;
			
			subtitle_1 = new TextField();
			subtitle_1.defaultTextFormat = formatSubtitle;
			subtitle_1.text = "Pp";
			subtitle_1.height = subtitle_1.textHeight + 4;
			subtitle_1.text = "";
			subtitle_1.multiline = false;
			subtitle_1.wordWrap = false;
			
			subtitle_2 = new TextField();
			subtitle_2.defaultTextFormat = formatSubtitle;
			subtitle_2.text = "Pp";
			subtitle_2.height = subtitle_2.textHeight + 4;
			subtitle_2.text = "";
			subtitle_2.multiline = false;
			subtitle_2.wordWrap = false;
			
			price = new TextField();
			price.defaultTextFormat = formatTitle;
			price.text = "Pp";
			price.height = price.textHeight + 4;
			price.text = "";
			price.multiline = false;
			price.wordWrap = false;
			
			percent = new TextField();
			percent.defaultTextFormat = formatSubtitle;
			percent.text = "Pp";
			percent.height = percent.textHeight + 4;
			percent.text = "";
			percent.multiline = false;
			percent.wordWrap = false;
			
			var tfDescription:TextFormat = new TextFormat();
			tfDescription.font = Config.defaultFontName;
			tfDescription.size = FontSize.SUBHEAD;
			tfDescription.align = TextFormatAlign.CENTER;
			tfDescription.color = Style.color(Style.COLOR_SUBTITLE);
			
			description = new TextField();
			description.defaultTextFormat = tfDescription;
			description.text = "Pp";
			description.height = subtitle_2.textHeight + 4;
			description.text = "";
			description.multiline = false;
			description.wordWrap = false;
			description.textColor = Style.color(Style.COLOR_TEXT);
			
			icon = new Bitmap();
			icon.x = Style.size(Style.SCREEN_PADDING_LEFT);
			icon.y = Style.size(Style.SCREEN_PADDING_LEFT);
			
			/*newMessages = new Sprite();
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
			newMessages.addChild(tfNewMessagesCnt);*/
			
			addChild(icon);
			addChild(description);
			addChild(title);
			addChild(subtitle_1);
			addChild(subtitle_2);
			addChild(price);
			addChild(percent);
		//	addChild(newMessages);
			
			graph = new Sprite();
			addChild(graph);
		}
		
		public function getView(li:ListItem, h:int, w:int, highlight:Boolean = false):IBitmapDrawable {
			
			var itemData:EscrowAdsCryptoVO = li.data as EscrowAdsCryptoVO;
			
			drawIcon(itemData);
			drawTitle(itemData);
			drawSubtitle(itemData);
			drawPrice(itemData);
			drawPercent(itemData);
			
			drawAmount(itemData);
			
			var textPosition:int = iconSize + Style.size(Style.SCREEN_PADDING_LEFT) + Style.size(Style.SCREEN_PADDING_LEFT);
			
			title.x = textPosition;
			title.y = int(Style.size(Style.SCREEN_PADDING_LEFT) - 2 - Config.FINGER_SIZE * .05);
			title.width = Math.max(w - Config.FINGER_SIZE * .5, Config.FINGER_SIZE * 3);
			
			subtitle_1.x = textPosition;
			subtitle_1.width = Math.max(w - Config.FINGER_SIZE * .5, Config.FINGER_SIZE * 3);
			subtitle_1.y = int(Config.FINGER_SIZE * .6);
			
			price.width = price.textWidth + 4;
			price.x = w - price.width - Style.size(Style.SCREEN_PADDING_LEFT); 
			price.y = int(Style.size(Style.SCREEN_PADDING_LEFT) - 2 - Config.FINGER_SIZE * .05);
			
			percent.width = percent.textWidth + 4;
			percent.x = w - percent.width - Style.size(Style.SCREEN_PADDING_LEFT); 
			percent.y = int(Config.FINGER_SIZE * .6);
			
			
			
			
			/*newMessages.visible = false;
			if (data.newExists == true) {
				newMessages.x = w - NEW_COUNT_SIZE - Config.DOUBLE_MARGIN;
				newMessages.visible = true;
				tfNewMessagesCnt.text = "!";
			}*/
			
			drawGraph(itemData);
			
			graphics.clear();
			graphics.beginFill(Style.color(Style.COLOR_SEPARATOR));
			var line:int = 2;
			graphics.drawRect(0, h - line, w, line);
			return this;
		}
		
		private function drawPrice(itemData:EscrowAdsCryptoVO):void {
			var value:String;
			
			if (itemData.instrument.price != null && itemData.instrument.price.length > 0)
			{
				var priceData:EscrowPrice = itemData.instrument.price[0];
				var priceValue:Number = priceData.value;
				
				var decimals:int = 2;
				if (priceValue > 100)
				{
					value = int(priceValue).toString();
				}
				else
				{
					value = priceValue.toPrecision(2);
				}
				
				if (priceData.name != null && priceData.name.toUpperCase() == TypeCurrency.USD)
				{
					value = "$" + value;
				}
				else if (priceData.name != null && priceData.name.toUpperCase() == TypeCurrency.EUR)
				{
					value = "€" + value;
				}
			}
			
			if (value != null) {
				price.text = value;
			} else {
				price.text = "";
			}
		}
		
		private function drawPercent(itemData:EscrowAdsCryptoVO):void {
			var value:String;
			
			if (itemData.instrument.rates != null && itemData.instrument.rates.lastChange != 0)
			{
				var percentValue:Number = itemData.instrument.rates.lastChange;
				if (percentValue > 0)
				{
					percent.defaultTextFormat = formatPercentGreen;
				}
				else
				{
					percent.defaultTextFormat = formatPercentRed;
				}
				value = percentValue + "%";
			}
			
			if (value != null) {
				percent.text = value;
			} else {
				percent.text = "";
			}
		}
		
		private function drawSubtitle(itemData:EscrowAdsCryptoVO):void {
			var name:String = itemData.instrument.name;
			
			if (name != null) {
				subtitle_1.text = name;
			} else {
				subtitle_1.text = "";
			}
		}
		
		private function drawGraph(itemData:EscrowAdsCryptoVO):void 
		{
			var graphWidth:int = Config.FINGER_SIZE * 5;
			var graphHeight:int = Config.FINGER_SIZE * 2;
			
			if (itemData.instrument.rates != null)
			{
				BaseGraphicsUtils.drawGraph(graph, graphWidth, graphHeight, itemData.instrument.rates);
			}
		}
		
		private function drawTitle(data:Object):void {
			var code:String = data.instrument.code;
			
			if (Lang[code] != null)
			{
				code = Lang[code];
			}
			if (code != null) {
				title.text = code.toUpperCase();
			} else {
				title.text = "";
			}
		}
		
		private function drawAmount(itemData:EscrowAdsCryptoVO):void {
			var textAmount:String = getAmountText(itemData);
		//	subtitle_1.htmlText = textAmount;
		}
		
		protected function getAmountText(itemData:EscrowAdsCryptoVO):String {
			var result:String;
			
			var captionSize:Number = FontSize.SUBHEAD;
			var color:String = "#" + Style.color(Style.COLOR_SUBTITLE).toString(16);
			
			result = "<font color='" + color + "'>" + Lang.escrow_ads + ": </font><font color='" + Color.RED + "'>" + itemData.count + "</font>";
			result += "<font color='" + color + "'>  ·  " + Lang.escrow_coins + ": </font><font color='" + Color.RED + "'>" + itemData.volume + "</font>";
			return result;
		}
		
		private function drawIcon(itemData:EscrowAdsCryptoVO):void {
			var iconClass:Class = UI.getCryptoIconClass(itemData.instrument.code);
			if (iconClass != null) {
				if (icon.bitmapData != null) {
					icon.bitmapData.dispose();
					icon.bitmapData = null;
				}
				
				var iconSource:Sprite = (new iconClass)();
				
				UI.scaleToFit(iconSource, iconSize, iconSize);
				icon.bitmapData = UI.getSnapshot(iconSource);
				iconSource = null;
			}
		}
		
		public function dispose():void {
			graphics.clear();
			
			UI.destroy(icon);
			icon = null;
			
			if (description != null)
				UI.destroy(description);
			description = null;
			
			if (title != null)
				UI.destroy(title);
			title = null;
			
			if (subtitle_1 != null)
				UI.destroy(subtitle_1);
			subtitle_1 = null;
			
			if (subtitle_2 != null)
				UI.destroy(subtitle_2);
			subtitle_2 = null;
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