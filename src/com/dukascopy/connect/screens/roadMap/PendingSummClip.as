package com.dukascopy.connect.screens.roadMap 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.utils.TextUtils;
	import com.greensock.TweenMax;
	import com.greensock.easing.Linear;
	import flash.display.Bitmap;
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	import white.BalanceLoader;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class PendingSummClip extends Sprite
	{
		private var amount:Bitmap;
		private var currency:Bitmap;
		public static const size:int = Config.FINGER_SIZE * 2;
		private var background:Sprite;
		private var loader:BalanceLoader;
		
		public function PendingSummClip() 
		{
			background = new Sprite();
			addChild(background);
			
			background.x = int(size * .5);
			background.y = int(size * .5);
			
			amount = new Bitmap();
			addChild(amount);
			
			currency = new Bitmap();
			addChild(currency);
		}
		
		public function setValue(amountValue:Number, currencyValue:String):void
		{
			drawAmount(amountValue);
			drawCurrency(currencyValue);
			
			amount.x = size * .5 - amount.width * .5;
			currency.x = size * .5 - currency.width * .5;
			
			amount.y = int(size * .5 - (amount.height + currency.height + Config.FINGER_SIZE * .23) * .5);
			currency.y = int(amount.y + amount.height + Config.FINGER_SIZE * .23);
			
			background.graphics.clear();
			
			if (loader != null)
			{
				TweenMax.killTweensOf(loader);
				if (background != null && background.contains(loader))
				{
					background.removeChild(loader);
				}
				UI.destroy(loader);
				loader = null;
			}
			
			if (amountValue == 0)
			{
				amount.alpha = 0.5;
				currency.alpha = 0.7;
				
				background.graphics.lineStyle(UI.getLineThickness(), Color.WHITE, 0.3);
				background.graphics.drawCircle(0, 0, int(size * .5));
			}
			else
			{
				amount.alpha = 1;
				currency.alpha = 1;
				loader = new BalanceLoader();
				UI.scaleToFit(loader, Config.FINGER_SIZE * 3, size);
				background.addChild(loader);
				
				TweenMax.to(loader, 3, {rotation:360, onComplete:restartLoader, ease:Linear.easeNone});
			}
		}
		
		private function restartLoader():void 
		{
			if (loader != null)
			{
				loader.rotation = 0;
				TweenMax.to(loader, 3, {rotation:360, onComplete:restartLoader, ease:Linear.easeNone});
			}
		}
		
		private function drawCurrency(value:String):void 
		{
			if (currency.bitmapData != null)
			{
				currency.bitmapData.dispose();
				currency.bitmapData = null;
			}
			currency.bitmapData = TextUtils.createTextFieldData(value.toString(), size, 10, 
																	true, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
																	Config.FINGER_SIZE * .32, true, Color.WHITE, 0xFFFFFF, true);
		}
		
		private function drawAmount(value:Number):void 
		{
			if (amount.bitmapData != null)
			{
				amount.bitmapData.dispose();
				amount.bitmapData = null;
			}
			amount.bitmapData = TextUtils.createTextFieldData(value.toString(), size, 10, 
																	true, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
																	Config.FINGER_SIZE * .65, true, Color.WHITE, 0xFFFFFF, true);
		}
		
		public function dispose():void
		{
			if (amount != null)
			{
				UI.destroy(amount);
				amount = null;
			}
			
			if (currency != null)
			{
				UI.destroy(currency);
				currency = null;
			}
			
			if (loader != null)
			{
				TweenMax.killTweensOf(loader);
				if (background != null && background.contains(loader))
				{
					background.removeChild(loader);
				}
				UI.destroy(loader);
				loader = null;
			}
			
			if (background != null)
			{
				UI.destroy(background);
				background = null;
			}
		}
	}
}