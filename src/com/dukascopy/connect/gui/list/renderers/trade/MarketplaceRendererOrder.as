package com.dukascopy.connect.gui.list.renderers.trade {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.HitZoneData;
	import com.dukascopy.connect.data.coinMarketplace.TradingOrder;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.gui.list.renderers.chatMessageElements.ChatMessageRendererBase;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.vo.AnimatedZoneVO;
	import com.dukascopy.langs.Lang;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	
	public class MarketplaceRendererOrder extends Sprite implements IMarketplaceRenderer {
		protected var standartHeight:int;
		
		protected var back:Shape;
		
		protected var amount:TextField;
		protected var coinsAmount:TextField;
		protected var date:TextField;
		protected var comment:TextField;
		protected var price:TextField;
		protected var my:TextField;
		
		protected var textFormatAmount:TextFormat = new TextFormat();
		protected var textFormatCoinsAmount:TextFormat = new TextFormat();
		protected var textFormatPrice:TextFormat = new TextFormat();
		protected var textFormatDate:TextFormat = new TextFormat();
		protected var textFormatComment:TextFormat = new TextFormat();
		protected var textFormatMy:TextFormat = new TextFormat();
		
		protected var radiusBack:Number;
		protected var currentBackColor:Number = 0x525F72;
		protected var padding:int;
		protected var vPadding:int;
		
		public function MarketplaceRendererOrder() {
			standartHeight = Config.FINGER_SIZE * .33 * 2.5;
			initTextFormats();
			create();
		}
		
		public function getContentHeight():Number {
			return back.height;
		}
		
		public function getSelectedHitzone(itemTouchPoint:Point, listItem:ListItem):HitZoneData
		{
			var result:HitZoneData = new HitZoneData();
			result.radius = radiusBack;
			result.type = HitZoneType.MENU_SIMPLE_ELEMENT;
			result.x = x;
			result.y = y;
			result.width = back.width;
			result.height = back.height;
			return result;
		}
		
		public function getWidth():uint {
			return back.width;
		}
		
		protected function initTextFormats():void {
			textFormatAmount.font = Config.defaultFontName;
			textFormatAmount.size = Config.FINGER_SIZE * .23;
			textFormatAmount.color = 0xFFFFFF;
			textFormatAmount.align = TextFormatAlign.LEFT;
			
			textFormatCoinsAmount.font = Config.defaultFontName;
			textFormatCoinsAmount.size = Config.FINGER_SIZE * .26;
			textFormatCoinsAmount.color = 0xFFFFFF;
			textFormatCoinsAmount.align = TextFormatAlign.LEFT;
			
			textFormatPrice.font = Config.defaultFontName;
			textFormatPrice.size = Config.FINGER_SIZE * .26;
			textFormatPrice.color = 0x000000;
			textFormatPrice.align = TextFormatAlign.LEFT;
			
			textFormatDate.font = Config.defaultFontName;
			textFormatDate.size = Config.FINGER_SIZE * .20;
			textFormatDate.color = 0x000000;
			textFormatDate.align = TextFormatAlign.LEFT;
			
			textFormatComment.font = Config.defaultFontName;
			textFormatComment.size = Config.FINGER_SIZE * .20;
			textFormatComment.color = 0xCE3F43;
			textFormatComment.align = TextFormatAlign.LEFT;
			
			textFormatMy.font = Config.defaultFontName;
			textFormatMy.size = Config.FINGER_SIZE * .26;
			textFormatMy.color = 0xFFFFFF;
			textFormatMy.align = TextFormatAlign.LEFT;
		}
		
		public function updateHitzones(itemHitzones:Array):void {
			
		}
		
		public function getBackColor():Number {
			return currentBackColor;
		}
		
		protected function create():void {
			back = new Shape();
			addChild(back);
			
			radiusBack = Math.ceil(Config.FINGER_SIZE * .1);
			
			padding = Config.MARGIN * 1;
			vPadding = Config.FINGER_SIZE * .08;
			
			coinsAmount = new TextField();
				coinsAmount.defaultTextFormat = textFormatCoinsAmount;
				coinsAmount.text = "1:00";
				coinsAmount.height = coinsAmount.textHeight + 4;
				coinsAmount.width = coinsAmount.textWidth + 4 + padding;
				coinsAmount.text = "";
				coinsAmount.wordWrap = false;
				coinsAmount.multiline = false;
			addChild(coinsAmount);
			
			amount = new TextField();
				amount.defaultTextFormat = textFormatAmount;
				amount.text = "1:00";
				amount.height = amount.textHeight + 4;
				amount.text = "";
				amount.wordWrap = false;
				amount.multiline = false;
			//addChild(amount);
			
			price = new TextField();
				price.defaultTextFormat = textFormatPrice;
				price.text = "1:00";
				price.height = price.textHeight + 4;
				price.text = "";
				price.wordWrap = false;
				price.multiline = false;
			addChild(price);
			
			date = new TextField();
				date.defaultTextFormat = textFormatDate;
				date.text = "1:00";
				date.height = date.textHeight + 4;
				date.text = "";
				date.wordWrap = true;
				date.multiline = true;
			addChild(date);
			
			comment = new TextField();
				comment.defaultTextFormat = textFormatComment;
				comment.width = Config.FINGER_SIZE * 5;
				comment.text = Lang.fillOrKill.toUpperCase();
				comment.height = comment.textHeight + 4;
				comment.wordWrap = true;
				comment.multiline = true;
			addChild(comment);
			
			my = new TextField();
				my.defaultTextFormat = textFormatMy;
				my.text = Lang.mine.toUpperCase();
				my.height = my.textHeight + 4;
				my.wordWrap = false;
				my.multiline = false;
				my.setTextFormat(textFormatMy);
				my.autoSize = TextFieldAutoSize.LEFT;
			addChild(my);
			my.alpha = 0.6;
			
			amount.x = padding;
			amount.y = vPadding;
		}
		
		public function getHeight(data:Object, maxWidth:int, listItem:ListItem):uint
		{
			return standartHeight;
			
			var originalWidth:int = maxWidth;
			maxWidth = getMaxWidth(maxWidth);
			
			if (data != null && data is TradingOrder)
			{
				setTexts(data as TradingOrder, maxWidth, originalWidth);
				return int(amount.y + amount.height + vPadding);
			}
			
			return Config.FINGER_SIZE * 1.2;
		}
		
		protected function getMaxWidth(value:int):int 
		{
			return value * 0.73;
		}
		
		protected function setTexts(data:TradingOrder, maxWidth:int, originalWidth:int):void 
		{
			var coinText:String = data.coin;
			if (Lang[coinText] != null)
			{
				coinText = Lang[coinText];
			}
			
			amount.text = parseFloat((data.quantity * data.price).toFixed(6)).toString() + " " + data.currency;
			price.text = "@" + parseFloat(data.priceString).toString() + " €";
			coinsAmount.text = parseFloat(data.quantityString).toString() + " " + coinText;
			
			if (data.side == TradingOrder.SELL)
			{
				setChildIndex(coinsAmount, numChildren - 1);
			}
			else
			{
				setChildIndex(price, numChildren - 1);
			}

			amount.width = amount.textWidth + 4;
			price.width = price.textWidth + 4;
			coinsAmount.width = coinsAmount.textWidth + 4;
			
			if (data.suboffers != null && data.suboffers.length > 0)
			{
				var mineExist:Boolean = false;
				
				var l:int = data.suboffers.length;
				for (var i:int = 0; i < l; i++) 
				{
					if (data.suboffers[i].own == true)
					{
						mineExist = true;
						break;
					}
				}
				
				if (mineExist == true)
				{
					my.visible = true;
					my.text = "+" + Lang.mine.toUpperCase();
				}
			}
			
			if (padding + amount.width + price.width + padding > maxWidth)
			{
				if (data.side == TradingOrder.SELL)
				{
					price.x = padding;
					price.y = vPadding;
					
					coinsAmount.x = int(maxWidth - coinsAmount.width - padding);
					
					amount.x = int(maxWidth - amount.width - padding);
					coinsAmount.y = vPadding;
					price.y = int(coinsAmount.y + coinsAmount.height + vPadding * .1);
					/*if (mineExist || data.own == true)
					{
						price.x = 	int(maxWidth - price.width - padding);
					}*/
				}
				else if (data.side == TradingOrder.BUY)
				{
					amount.x = padding;
					coinsAmount.y = vPadding;
					
					coinsAmount.x = padding;
					
					price.x = int(maxWidth - price.width - padding);
					price.y = int(coinsAmount.y + coinsAmount.height + vPadding * .1);
					/*if (mineExist || data.own == true)
					{
						price.x = padding;
					}*/
				}
			}
			else
			{
				if (data.side == TradingOrder.SELL)
				{
					price.x = padding;
					price.y = vPadding;
					
					coinsAmount.x = int(maxWidth - coinsAmount.width - padding);
					
					amount.x = int(maxWidth - amount.width - padding);
					coinsAmount.y = vPadding;
				}
				else if (data.side == TradingOrder.BUY)
				{
					amount.x = padding;
					coinsAmount.y = vPadding;
					
					coinsAmount.x = padding;
					
					price.x = int(maxWidth - price.width - padding);
					price.y = vPadding;
				}
				amount.y = int(price.y + price.height + vPadding);
			}
			
			if (data.deadline != null)
			{
				date.visible = true;
				var currentDate:Date = new Date();
				if (currentDate.getFullYear() == data.deadline.getFullYear() &&
					currentDate.getMonth() == data.deadline.getMonth() &&
					currentDate.getDate() == data.deadline.getDate())
				{
					var minutes:String = data.deadline.getMinutes().toString();
					if (minutes.length == 1)
					{
						minutes = "0" + minutes;
					}
					var hours:String = data.deadline.getHours().toString();
					if (hours.length == 1)
					{
						hours = "0" + hours;
					}
					date.text = Lang.goodTill.toUpperCase() + ": " + hours + ":" + minutes;
				}
				else
				{
					var month:String = (data.deadline.getMonth() + 1).toString();
					if (month.length == 1)
					{
						month = "0" + month;
					}
					var day:String = (data.deadline.getDate()/* + 1*/).toString();
					if (day.length == 1)
					{
						day = "0" + day;
					}
					date.text = Lang.goodTill.toUpperCase() + ": " + data.deadline.getFullYear().toString() + "." + month + "." + day;
				}
				date.width = originalWidth - maxWidth - padding;
				date.height = date.textHeight + 4;
			}
			else{
				date.visible = false;
			}
			
			if (data.fillOrKill == true || data.publicOrder == false)
			{
				if (data.fillOrKill)
				{
					comment.text = Lang.fillOrKill.toUpperCase();
				}
				else if (data.publicOrder == false)
				{
					comment.text = Lang.privateOrder.toUpperCase();
				}
				comment.width = originalWidth - maxWidth - padding;
				comment.height = comment.textHeight + 4;
				comment.visible = true;
			}
			else
			{
				comment.visible = false;
			}
			
			my.visible = false;
			if (data.own == true || mineExist == true)
			{
				my.visible = true;
				if (data.suboffers == null)
				{
					my.text = Lang.mine.toUpperCase();
				}
			}
			
			if (data.side == TradingOrder.SELL)
			{
				date.width = date.textWidth + 6;
				comment.width = comment.textWidth + 6;
				textFormatDate.align = TextFormatAlign.RIGHT;
				date.setTextFormat(textFormatDate);
				textFormatComment.align = TextFormatAlign.RIGHT;
				comment.setTextFormat(textFormatComment);
				date.x = int(- date.width - Config.FINGER_SIZE * .1);
				comment.x = int( - comment.width - Config.FINGER_SIZE * .1);
				
				if (my.visible)
				{
					my.x = int(padding);
					my.y = int(standartHeight - my.height - Config.FINGER_SIZE * .0);
				//	if (Math.abs(price.y - my.y) < Config.FINGER_SIZE*.2)
				//	{
						my.x = int(maxWidth - my.width - padding);
				//	}
				}
			}
			else if (data.side == TradingOrder.BUY)
			{
				
				textFormatDate.align = TextFormatAlign.LEFT;
				date.setTextFormat(textFormatDate);
				textFormatComment.align = TextFormatAlign.LEFT;
				comment.setTextFormat(textFormatComment);
				date.x = int(maxWidth + Config.FINGER_SIZE * .1);
				comment.x = int(maxWidth + Config.FINGER_SIZE * .1);
				
				if (my.visible)
				{
					my.x = int(maxWidth - my.width - padding);
					my.y = int(standartHeight - my.height - Config.FINGER_SIZE * .0);
				//	if (Math.abs(price.y - my.y) < Config.FINGER_SIZE*.2)
				//	{
						my.x = int(padding);
				//	}
				}
			}
			
			if (date.visible && comment.visible)
			{
				date.y = Math.max(0, int((amount.y + amount.height + vPadding) * .5 - date.height - Config.FINGER_SIZE * .01));
				comment.y = int(date.y + date.height + Config.FINGER_SIZE * .02);
			}
			else if (date.visible)
			{
				date.y = Math.max(0, int((amount.y + amount.height + vPadding) * .5 - date.height * .5));
			}
			else if (comment.visible)
			{
				comment.y = Math.max(0, int((amount.y + amount.height + vPadding) * .5 - comment.height * .5));
			}
		}
		
		public function draw(data:Object, maxWidth:int, listItem:ListItem = null):void
		{
			var originalWidth:int = maxWidth;
			maxWidth = getMaxWidth(maxWidth);
			
			var itemData:TradingOrder = data as TradingOrder;
			
			if (itemData != null)
			{
				setTexts(itemData, maxWidth, originalWidth);
				
				if (itemData.side == TradingOrder.BUY)
				{
					currentBackColor = 0x639DC5;
				}
				else if (itemData.side == TradingOrder.SELL)
				{
					currentBackColor = 0x71C65F;
				}
				
				back.graphics.clear();
				back.graphics.beginFill(currentBackColor);
				
				back.graphics.drawRoundRect(0, 0, maxWidth, standartHeight, radiusBack * 2, radiusBack * 2);
				back.graphics.endFill();
			}
		}
		
		public function dispose():void {		
			UI.destroy(back);
			back = null;
			
			UI.destroy(coinsAmount);
			coinsAmount = null;
			
			UI.destroy(amount);
			amount = null;
			
			UI.destroy(price);
			price = null;
			
			UI.destroy(date);
			date = null;
			
			UI.destroy(comment);
			comment = null;
			
			UI.destroy(my);
			my = null;
			
			textFormatAmount = null;
			textFormatCoinsAmount = null;
			textFormatPrice = null;
			textFormatDate = null;
			textFormatComment = null;
			textFormatMy = null;
		}
		
		public function get animatedZone():AnimatedZoneVO {
			return null;
		}
		
		public function get isReadyToDisplay():Boolean {
			return true;
		}
		
		public function getSmallGap(listItem:ListItem):int {
			return ChatMessageRendererBase.smallGap;
		}
	}
}