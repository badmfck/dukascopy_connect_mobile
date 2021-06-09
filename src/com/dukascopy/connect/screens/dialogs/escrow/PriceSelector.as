package com.dukascopy.connect.screens.dialogs.escrow 
{
	import assets.TooltipBottom;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.escrow.TradeDirection;
	import com.dukascopy.connect.gui.components.seekbar.Seekbar;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.screens.payments.card.TypeCurrency;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class PriceSelector extends Sprite
	{
		private var _direction:TradeDirection;
		private var title:Bitmap;
		private var left:Bitmap;
		private var right:Bitmap;
		private var center:Bitmap;
		private var price:Bitmap;
		private var currency:Bitmap;
		private var percent:Bitmap;
		private var percentBack:Sprite;
		private var percentBackArrow:Sprite;
		private var priceBack:Sprite;
		private var seekBar:Seekbar;
		private var minValue:Number;
		private var maxValue:Number;
		private var currentValue:Number;
		private var itemWidth:int;
		private var priceValue:Number;
		private var currencySign:String;
		private var priceCurrent:Bitmap;
		private var onChange:Function;
		private var selectedValue:Number;
		
		public function PriceSelector(onChange:Function) 
		{
			this.onChange = onChange;
			
			createClips();
		}
		
		private function createClips():void 
		{
			title = new Bitmap();
			addChild(title);
			
			left = new Bitmap();
			addChild(left);
			
			right = new Bitmap();
			addChild(right);
			
			center = new Bitmap();
			addChild(center);
			
			price = new Bitmap();
			addChild(price);
			
			priceBack = new Sprite();
			priceBack.alpha = 0.2;
			addChild(priceBack);
			
			priceCurrent = new Bitmap();
			addChild(priceCurrent);
			
			currency = new Bitmap();
			addChild(currency);
			
			percentBack = new Sprite();
			addChild(percentBack);
			
			percent = new Bitmap();
			percentBack.addChild(percent);
			
			percentBackArrow = new TooltipBottom();
			percentBack.addChild(percentBackArrow);
			UI.scaleToFit(percentBackArrow, Config.FINGER_SIZE*.23, Config.FINGER_SIZE*.23);
			
			seekBar = new Seekbar(onValueChange);
			if (direction == TradeDirection.sell)
			{
				seekBar.flipColors = true;
			}
			else
			{
				seekBar.flipColors = false;
			}
			addChild(seekBar);
		}
		
		public function getPrice():Number
		{
			var priceResult:Number = parseFloat((priceValue + priceValue * selectedValue/100).toFixed(2));
			return priceResult;
		}
		
		private function onValueChange(value:Number):void 
		{
			selectedValue = value;
			drawPrice(value);
			drawPercent(value);
			
			var color:Number;
			if (value > currentValue)
			{
				color = (direction == TradeDirection.sell)?Color.GREEN:Color.RED;
			}
			else if (value < currentValue)
			{
				color = (direction == TradeDirection.sell)?Color.RED:Color.GREEN;
			}
			else
			{
				color = Style.color(Style.COLOR_SUBTITLE);
			}
			var radius:int = Config.FINGER_SIZE * .12;
			priceBack.graphics.clear();
			if (priceCurrent.width > 0)
			{
				priceBack.graphics.beginFill(color);
				priceBack.graphics.drawRoundRect(0, 0, int(priceCurrent.width + Config.FINGER_SIZE * .1), int(priceCurrent.height + Config.FINGER_SIZE * .16), radius, radius);
				priceBack.graphics.endFill();
				priceBack.x = int(priceCurrent.x - Config.FINGER_SIZE*.05);
				priceBack.y = int(priceCurrent.y - Config.FINGER_SIZE * .08);
			}
			
			dispatchValue(value);
		}
		
		private function dispatchValue(value:Number):void 
		{
			var priceResult:Number = parseFloat((priceValue + priceValue * value/100).toFixed(2));
			if (onChange != null && onChange.length == 1)
			{
				onChange(priceResult);
			}
		}
		
		private function drawTexts():void 
		{
			if (center.bitmapData != null)
			{
				center.bitmapData.dispose();
				center.bitmapData = null;
			}
			if (left.bitmapData != null)
			{
				left.bitmapData.dispose();
				left.bitmapData = null;
			}
			if (right.bitmapData != null)
			{
				right.bitmapData.dispose();
				right.bitmapData = null;
			}
			
			center.bitmapData = TextUtils.createTextFieldData(Lang.current_price, itemWidth * .28, 10, true,
																	TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
																	FontSize.CAPTION_1, true, Style.color(Style.COLOR_SUBTITLE),
																	Style.color(Style.COLOR_BACKGROUND), false, true);
			left.bitmapData = TextUtils.createTextFieldData(Lang.below, itemWidth * .28, 10, true,
																	TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
																	FontSize.CAPTION_1, true, Style.color(Style.COLOR_SUBTITLE),
																	Style.color(Style.COLOR_BACKGROUND), false, true);
			right.bitmapData = TextUtils.createTextFieldData(Lang.above, itemWidth * .28, 10, true,
																	TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
																	FontSize.CAPTION_1, true, Style.color(Style.COLOR_SUBTITLE),
																	Style.color(Style.COLOR_BACKGROUND), false, true);
		}
		
		public function draw(itemWidth:Number, minValue:Number, maxValue:Number, currentValue:Number, priceValue:Number, currencySign:String):void
		{
			this.itemWidth = itemWidth;
			this.minValue = minValue;
			this.maxValue = maxValue;
			this.currentValue = currentValue;
			this.priceValue = priceValue;
			this.currencySign = currencySign;
			
			selectedValue = currentValue;
			
			drawTexts();
			seekBar.draw(itemWidth, minValue, maxValue, currentValue);
			drawPrice(currentValue);
			drawPercent(currentValue);
			drawCurrentPrice();
			
			var position:int = 0;
			
			price.y = position;
			position += Config.FINGER_SIZE * .3 + Config.FINGER_SIZE * .1;
			
			percentBack.y = position;
			position += Config.FINGER_SIZE * .4 + Config.FINGER_SIZE * .3;
			
			seekBar.y = position;
			position += seekBar.height + Config.FINGER_SIZE * .0;
			
			left.x = 0;
			center.x = int(itemWidth * .5 - center.width * .5);
			right.x = int(itemWidth - right.width);
			
			left.y = center.y = right.y = position;
			position += left.height + Config.FINGER_SIZE * .2;
			
			priceCurrent.y = position;
			currency.y = int(priceCurrent.y + priceCurrent.height - currency.height);
			priceCurrent.x = int(itemWidth * .5 - (priceCurrent.width + currency.width + Config.FINGER_SIZE * .15) * .5);
			currency.x = int(priceCurrent.x + priceCurrent.width + Config.FINGER_SIZE * .15);
		}
		
		private function drawCurrentPrice():void 
		{
			if (!isNaN(priceValue))
			{
				if (priceCurrent.bitmapData != null)
				{
					priceCurrent.bitmapData.dispose();
					priceCurrent.bitmapData = null;
				}
				priceCurrent.bitmapData = TextUtils.createTextFieldData(priceValue.toFixed(2), itemWidth, 10, true,
																		TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
																		FontSize.BODY, true, Style.color(Style.COLOR_TEXT),
																		Style.color(Style.COLOR_BACKGROUND));
				currency.bitmapData = TextUtils.createTextFieldData(getCurrency() , itemWidth, 10, true,
																		TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
																		FontSize.BODY, true, Style.color(Style.COLOR_TEXT),
																		Style.color(Style.COLOR_BACKGROUND));
			}
		}
		
		private function drawPercent(value:Number):void 
		{
			if (percent.bitmapData != null)
			{
				percent.bitmapData.dispose();
				percent.bitmapData = null;
			}
			percent.bitmapData = TextUtils.createTextFieldData(value.toFixed(1) + "%", itemWidth, 10, true,
																	TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
																	FontSize.AMOUNT, true, Color.WHITE,
																	Style.color(Style.COLOR_BACKGROUND));
			percentBack.graphics.clear();
			var color:Number;
			if (value > currentValue)
			{
				color = (direction == TradeDirection.sell)?Color.GREEN:Color.RED;
			}
			else if (value < currentValue)
			{
				color = (direction == TradeDirection.sell)?Color.RED:Color.GREEN;
			}
			else
			{
				color = Style.color(Style.COLOR_SUBTITLE);
			}
			percentBack.graphics.beginFill(color);
			var widthClip:int = int(percent.width + Config.FINGER_SIZE * .15 * 2);
			var heightClip:int = int(percent.height + Config.FINGER_SIZE * .15 * 2);
			var radius:int = Config.FINGER_SIZE * .15;
			percentBack.graphics.drawRoundRect(0, 0, widthClip, heightClip, radius, radius);
			percentBack.graphics.endFill();
			percentBackArrow.x = int(widthClip * .5 - percentBackArrow.width * .5);
			percentBackArrow.y = heightClip;
			UI.colorize(percentBackArrow, color)
			percent.x = int(widthClip * .5 - percent.width * .5);
			percent.y = int(heightClip * .5 - percent.height * .5);
			
			percentBack.x = int(seekBar.getPosition() - percentBack.width * .5);
			if (percentBack.x < 0)
			{
				percentBack.x = 0;
				percentBackArrow.x = int(Math.max(Config.FINGER_SIZE * .1, seekBar.getPosition() - percentBackArrow.width * .5));
			}
			if (percentBack.x + widthClip > itemWidth)
			{
				percentBack.x = int(itemWidth - widthClip);
				percentBackArrow.x = int(Math.min(itemWidth - Config.FINGER_SIZE * .1 - percentBackArrow.width * .5, seekBar.getPosition() - percentBackArrow.width * .5) - percentBack.x);
			}
		}
		
		private function drawPrice(value:Number):void 
		{
			if (!isNaN(value) && !isNaN(priceValue))
			{
				var color:Number;
				if (value > currentValue)
				{
					color = (direction == TradeDirection.sell)?Color.GREEN:Color.RED;
				}
				else if (value < currentValue)
				{
					color = (direction == TradeDirection.sell)?Color.RED:Color.GREEN;
				}
				else
				{
					color = Style.color(Style.COLOR_SUBTITLE);
				}
				var calculatedPrice:String = (priceValue + priceValue * value/100).toFixed(2);
				
				if (price.bitmapData != null)
				{
					price.bitmapData.dispose();
					price.bitmapData = null;
				}
				price.bitmapData = TextUtils.createTextFieldData(Lang.indicative_price + " " + calculatedPrice + " " + getCurrency(), itemWidth, 10, true,
																		TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
																		FontSize.SUBHEAD, true, color,
																		Style.color(Style.COLOR_BACKGROUND));
				price.x = int(itemWidth * .5 - price.width * .5);
			}
		}
		
		private function getCurrency():String 
		{
			var result:String = "";
			if (currencySign != null)
			{
				if (currencySign == TypeCurrency.EUR)
				{
					result = "€";
				}
				else if (Lang[currencySign] != null)
				{
					result = Lang[currencySign];
				}
				else
				{
					result = currencySign;
				}
			}
			return result;
		}
		
		public function activate():void 
		{
			seekBar.activate();
		}
		
		public function deactivate():void 
		{
			seekBar.deactivate();
		}
		
		public function dispose():void 
		{
			direction = null;
			onChange = null;
			
			if (title != null)
			{
				UI.destroy(title);
				title = null;
			}
			if (left != null)
			{
				UI.destroy(left);
				left = null;
			}
			if (right != null)
			{
				UI.destroy(right);
				right = null;
			}
			if (center != null)
			{
				UI.destroy(center);
				center = null;
			}
			if (price != null)
			{
				UI.destroy(price);
				price = null;
			}
			if (currency != null)
			{
				UI.destroy(currency);
				currency = null;
			}
			if (percent != null)
			{
				UI.destroy(percent);
				percent = null;
			}
			if (percentBack != null)
			{
				UI.destroy(percentBack);
				percentBack = null;
			}
			if (percentBackArrow != null)
			{
				UI.destroy(percentBackArrow);
				percentBackArrow = null;
			}
			if (priceBack != null)
			{
				UI.destroy(priceBack);
				priceBack = null;
			}
			if (priceCurrent != null)
			{
				UI.destroy(priceCurrent);
				priceCurrent = null;
			}
			if (seekBar != null)
			{
				seekBar.dispose();
				seekBar = null;
			}
		}
		
		public function get direction():TradeDirection 
		{
			return _direction;
		}
		
		public function set direction(value:TradeDirection):void 
		{
			_direction = value;
			if (seekBar != null)
			{
				if (value == TradeDirection.sell)
				{
					seekBar.flipColors = true;
				}
				else
				{
					seekBar.flipColors = false;
				}
			}
		}
	}
}