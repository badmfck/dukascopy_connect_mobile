package com.dukascopy.connect.gui.list.renderers.trade {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.HitZoneData;
	import com.dukascopy.connect.data.coinMarketplace.TradingOrder;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.gui.list.renderers.BaseRenderer;
	import com.dukascopy.connect.gui.list.renderers.IListRenderer;
	import com.dukascopy.connect.sys.applicationShop.product.SubscriptionDuration;
	import com.dukascopy.connect.sys.applicationShop.product.SubscriptionDurationCollection;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.langs.Lang;
	import fl.motion.Color;
	import flash.display.IBitmapDrawable;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class OrderListItem extends BaseRenderer implements IListRenderer{
		
		private var price:TextField;
		private var start:TextField;
		private var current:TextField;
		private var sum:TextField;
		
		private var format:TextFormat = new TextFormat(Config.defaultFontName, Config.FINGER_SIZE*.24, 0x00477E);
		private var formatStart:TextFormat = new TextFormat(Config.defaultFontName, Config.FINGER_SIZE*.24, 0x587D9A);
		private var formatInactive:TextFormat = new TextFormat(Config.defaultFontName, Config.FINGER_SIZE*.24, 0xCACACA);
		
		private var padding:int = Config.FINGER_SIZE * .5;
		private var itemHeight:int = Config.FINGER_SIZE * 1.5;
		
		private var progress:Sprite;
		
		public function OrderListItem() {
			
			price = new TextField();
			price.autoSize = TextFieldAutoSize.LEFT;
			price.defaultTextFormat = format;
			price.text = "Pp";
			price.multiline = false;
			price.wordWrap = false;
			price.x = padding;
			price.y = Math.round(Config.FINGER_SIZE * .2);
			addChild(price);
			
			start = new TextField();
			start.autoSize = TextFieldAutoSize.LEFT;
			start.defaultTextFormat = formatStart;
			start.text = "Pp";
			start.multiline = false;
			start.wordWrap = false;
			start.x = padding;
			start.y = Math.round(Config.FINGER_SIZE * .75);
			addChild(start);
			
			current = new TextField();
			current.autoSize = TextFieldAutoSize.LEFT;
			current.defaultTextFormat = formatStart;
			current.text = "Pp";
			current.multiline = false;
			current.wordWrap = false;
			current.x = padding;
			current.y = Math.round(Config.FINGER_SIZE * .75);
			addChild(current);
			
			sum = new TextField();
			sum.autoSize = TextFieldAutoSize.LEFT;
			sum.defaultTextFormat = format;
			sum.text = "Pp";
			sum.multiline = false;
			sum.wordWrap = false;
			sum.x = padding;
			sum.y = Math.round(Config.FINGER_SIZE * .2);
			addChild(sum);
			
			progress = new Sprite()
			addChild(progress);
			progress.x = padding;
			progress.y = int(Config.FINGER_SIZE * .65);
		}
		
		public function getMessageHitzone(listItem:ListItem):HitZoneData {
			var hitZoneType:String;
				hitZoneType = HitZoneType.MESSAGE_TEXT;
			
			if (hitZoneType != null) {
				var height:int = getHeight(listItem, listItem.width);
				getView(listItem, height, listItem.width);
				
				var hitzone:HitZoneData = new HitZoneData();
				hitzone.x = Config.MARGIN;
				hitzone.y = 0;
				hitzone.width = listItem.width - Config.MARGIN * 2;
				hitzone.height = height;
				hitzone.type = hitZoneType;
				
				return hitzone;
			}
			return null;
		}
		
		/* INTERFACE com.dukascopy.connect.gui.list.renderers.IListRenderer */
		public function getHeight(data:ListItem, width:int):int {
			return itemHeight;
		}
		
		public function getView(li:ListItem, h:int, w:int, highlight:Boolean=false):IBitmapDrawable {
			var data:TradingOrder = li.data as TradingOrder;
			
			/*graphics.clear();
			
			graphics.beginFill(0, .2);
			graphics.drawRect(0, h - 1, width, 1);
			graphics.endFill();*/
			
			var text:String;
			var sideColor:Number;
			
			if (data.active == true)
			{
				start.setTextFormat(formatStart);
				sum.setTextFormat(format);
				current.setTextFormat(formatStart);
				price.setTextFormat(format);
			}
			else
			{
				start.setTextFormat(formatInactive);
				sum.setTextFormat(formatInactive);
				start.setTextFormat(formatInactive);
				current.setTextFormat(formatInactive);
				price.setTextFormat(formatInactive);
			}
			
			if (data.startValue == 0)
			{
				data.startValue = data.quantity;
			}
			
			var sumText:String = "+";
			
			if (data.side == TradingOrder.BUY)
			{
				text = Lang.BUY.toUpperCase() + ": ";
				sideColor = 0x349FD3;
				sumText = "-" + (data.quantity * data.price).toFixed(2) + " <font size='" + Config.FINGER_SIZE * .2 + "'>" + "EUR" +  "</font>";
			}
			else
			{
				text = Lang.sell.toUpperCase() + ": ";
				sideColor = 0x34D374;
				sumText = "+" + (data.quantity * data.price).toFixed(2) + " <font size='" + Config.FINGER_SIZE * .2 + "'>" + "EUR" +  "</font>";
			}
			
			if (data.active == false)
			{
				sideColor = 0xCACACA;
			}
			
			text = text + "@" + data.priceString + " <font size='" + Config.FINGER_SIZE * .2 + "'>" + "EUR" +  "</font>";
			price.htmlText = text;
			price.width = w - price.x - padding;
			
			
			start.htmlText = data.startValue.toString() +  " <font size='" + Config.FINGER_SIZE*.2 + "'>" + "DUK+" +  "</font>";
			current.htmlText = data.quantity +  " <font size='" + Config.FINGER_SIZE * .2 + "'>" + "DUK+" +  "</font>";
			
			sum.htmlText = sumText;
			sum.x = int(w - padding - sum.width);
			
		//	sum.border = true;
		//	current.border = true;
			
			progress.graphics.clear();
			progress.graphics.lineStyle(1, 0xE3E3E4, 1);
			
			var progressHeight:int = Config.FINGER_SIZE * .15;
			var corner:int = Config.FINGER_SIZE * .15;
			
			var pos:int;
			
			if (data.startValue != data.quantity)
			{
				pos = (data.startValue - data.quantity) * (w - padding * 2) / data.startValue;
				
				progress.graphics.beginFill(sideColor);
				progress.graphics.drawRoundRectComplex(0, 0, pos, progressHeight, corner, 0, corner, 0);
				progress.graphics.endFill();
				
				progress.graphics.beginFill(0xF1F1F2);
				progress.graphics.drawRoundRectComplex(pos, 0, w - padding*2 - pos, progressHeight, 0, corner, 0,corner);
				progress.graphics.endFill();
			}
			else if(data.startValue == data.quantity)
			{
				pos = w - padding * 2;
				
				progress.graphics.beginFill(sideColor);
				progress.graphics.drawRoundRect(0, 0, w - padding * 2, progressHeight, corner, corner);
				progress.graphics.endFill();
			}
			else
			{
				pos = 0;
				
				progress.graphics.beginFill(0xF1F1F2);
				progress.graphics.drawRoundRect(0, 0, w - padding * 2, progressHeight, corner, corner);
				progress.graphics.endFill();
			}
			
			pos += padding;
			current.x = int(Math.max(start.x + start.width + Config.FINGER_SIZE*.25, Math.min(pos, w - padding - current.width)));
			
			current.y = start.y = int(progress.y + progress.height + Config.FINGER_SIZE * .03);
			
			return this;
		}
			
		public function dispose():void {
			graphics.clear();
			
			format = null
			formatStart = null
			
			if (price != null)
			{
				UI.destroy(price);
				price = null;
			}
			if (start != null)
			{
				UI.destroy(start);
				start = null;
			}
			if (current != null)
			{
				UI.destroy(current);
				current = null;
			}
			if (sum != null)
			{
				UI.destroy(sum);
				sum = null;
			}
			if (progress != null)
			{
				UI.destroy(progress);
				progress = null;
			}
		}
		
		/* INTERFACE com.dukascopy.connect.gui.list.renderers.IListRenderer */
		public function get isTransparent():Boolean {
			return true;
		}
	}
}