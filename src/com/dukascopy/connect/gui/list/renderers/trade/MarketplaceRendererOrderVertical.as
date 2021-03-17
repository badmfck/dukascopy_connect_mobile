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
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	
	public class MarketplaceRendererOrderVertical extends MarketplaceRendererOrder {
		
		public function MarketplaceRendererOrderVertical() {
			super()
			vPadding = Config.FINGER_SIZE * .08;
		}
		
		override protected function getMaxWidth(value:int):int 
		{
			return value * 1;
		}
		
		override public function getHeight(data:Object, maxWidth:int, listItem:ListItem):uint
		{
			var originalWidth:int = maxWidth;
			maxWidth = getMaxWidth(maxWidth);
			
			if (data != null && data is TradingOrder)
			{
				setTexts(data as TradingOrder, maxWidth, originalWidth);
				return int(coinsAmount.y + coinsAmount.height + vPadding);
			}
			
			return Config.FINGER_SIZE * 1.2;
		}
		
		override public function draw(data:Object, maxWidth:int, listItem:ListItem = null):void
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
				
				back.graphics.drawRoundRect(0, 0, maxWidth, coinsAmount.y + coinsAmount.height + vPadding, radiusBack * 2, radiusBack * 2);
				back.graphics.endFill();
				
				if (itemData.fillOrKill == true)
				{
					back.graphics.beginFill(0xCC0000);
					back.graphics.drawCircle(Config.FINGER_SIZE * .1, Config.FINGER_SIZE * .1, Config.FINGER_SIZE * .05);
					back.graphics.endFill();
				}
			}
		}
		
		override protected function initTextFormats():void {
			textFormatAmount.font = Config.defaultFontName;
			textFormatAmount.size = Config.FINGER_SIZE * .20;
			textFormatAmount.color = 0xFFFFFF;
			textFormatAmount.align = TextFormatAlign.LEFT;
			
			textFormatCoinsAmount.font = Config.defaultFontName;
			textFormatCoinsAmount.size = Config.FINGER_SIZE * .28;
			textFormatCoinsAmount.color = 0xFFFFFF;
			textFormatCoinsAmount.align = TextFormatAlign.LEFT;
			
			textFormatPrice.font = Config.defaultFontName;
			textFormatPrice.size = Config.FINGER_SIZE * .28;
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
		
		override protected function create():void 
		{
			super.create();
			
			comment.defaultTextFormat = textFormatComment;
			comment.width = Config.FINGER_SIZE * 5;
			comment.text = Lang.FOK;
			comment.textColor = 0xFFFFFF;
			comment.width = comment.textWidth + 4;
			comment.height = comment.textHeight + 4;
			comment.wordWrap = false;
			comment.multiline = false;
		}
		
		override protected function setTexts(data:TradingOrder, maxWidth:int, originalWidth:int):void 
		{
			var coinText:String = data.coin;
			if (Lang[coinText] != null)
			{
				coinText = Lang[coinText];
			}
			
			amount.width = maxWidth;
			price.width = maxWidth;
			coinsAmount.width = maxWidth;
			
			amount.text = (data.quantity * data.price).toFixed(2) + " " + data.currency;
			price.text = "@" + data.priceString + " €";
			coinsAmount.text = data.quantityString + " " + coinText;
			
			amount.width = amount.textWidth + 4;
			price.width = price.textWidth + 4;
			coinsAmount.width = coinsAmount.textWidth + 4;
			
			price.y = vPadding;
		//	amount.y = int(coinsAmount.y + coinsAmount.height + vPadding * .1);
			coinsAmount.y = int(price.y + price.height + vPadding * .1);
			amount.visible = false;
			
			if (data.side == TradingOrder.BUY)
			{
				price.x = maxWidth - padding - price.width;
				amount.x = padding;
				
				if (my.visible)
				{
					my.x = int(padding);
					my.y = amount.y;
				}
			}
			else
			{
				amount.x = maxWidth - padding - amount.width;
				price.x = padding;
				
				if (my.visible)
				{
					my.x = int(maxWidth - my.width - padding);
					my.y = amount.y;
				}
			}
			
			if (data.side == TradingOrder.BUY)
			{
				coinsAmount.x = padding;
			}
			else
			{
				coinsAmount.x = maxWidth - padding - coinsAmount.width;
			}
			
			my.visible = false;
			if (data.own == true)
			{
				my.visible = true;
			}
			
			
			if (data.deadline != null)
			{
				/*date.visible = true;
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
					var day:String = (data.deadline.getDate() + 1).toString();
					if (day.length == 1)
					{
						day = "0" + day;
					}
					date.text = Lang.goodTill.toUpperCase() + ": " + data.deadline.getFullYear().toString() + "." + month + "." + day;
				}
				date.width = originalWidth - maxWidth - padding;
				date.height = date.textHeight + 4;*/
			}
			else
			{
				date.visible = false;
			}
			
			if (data.min_trade == data.quantity)
			{
				comment.visible = true;
				if (data.side == TradingOrder.BUY)
				{
					comment.x = int(maxWidth - comment.width - Config.FINGER_SIZE * .1);
				}
				else
				{
					comment.x = int(Config.FINGER_SIZE * .1);
				}
				comment.y = int(coinsAmount.y + coinsAmount.height - comment.height);
			}
			else
			{
				comment.visible = false;
			}
			
		//	comment.visible = false;
			date.visible = false;
			
			
			
			
			
			/*if (data.side == TradingOrder.SELL)
			{
				date.width = date.textWidth + 6;
				comment.width = comment.textWidth + 6;
				textFormatDate.align = TextFormatAlign.RIGHT;
				date.setTextFormat(textFormatDate);
				textFormatComment.align = TextFormatAlign.RIGHT;
				comment.setTextFormat(textFormatComment);
				date.x = int(- date.width - Config.FINGER_SIZE * .1);
				comment.x = int(- comment.width - Config.FINGER_SIZE * .1);
			}
			else if (data.side == TradingOrder.BUY)
			{
				textFormatDate.align = TextFormatAlign.LEFT;
				date.setTextFormat(textFormatDate);
				textFormatComment.align = TextFormatAlign.LEFT;
				comment.setTextFormat(textFormatComment);
				date.x = int(maxWidth + Config.FINGER_SIZE * .1);
				comment.x = int(maxWidth + Config.FINGER_SIZE * .1);
			}*/
			
			/*if (date.visible && comment.visible)
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
			}*/
		}
	}
}