package com.dukascopy.connect.gui.components.countdown 
{
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
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
	
	public class Countdown extends Sprite
	{
		private var firtHour:com.dukascopy.connect.gui.components.countdown.CountdownItem;
		private var secondHour:com.dukascopy.connect.gui.components.countdown.CountdownItem;
		private var firtMinute:com.dukascopy.connect.gui.components.countdown.CountdownItem;
		private var secondMinute:com.dukascopy.connect.gui.components.countdown.CountdownItem;
		private var firtSecond:com.dukascopy.connect.gui.components.countdown.CountdownItem;
		private var secondSecond:com.dukascopy.connect.gui.components.countdown.CountdownItem;
		
		private var itemWidth:int;
		private var smallPadding:int;
		private var bigPadding:int;
		private var hoursText:flash.display.Bitmap;
		private var minutesText:flash.display.Bitmap;
		private var secondsText:flash.display.Bitmap;
		private var drawnTexts:Boolean;
		private var modeDays:Boolean;
		private var container:flash.display.Sprite;
		
		public function Countdown() 
		{
			
		}
		
		public function setWidth(value:int):void
		{
			calcSizes(value);
			
			clear();
			
			container = new Sprite();
			addChild(container);
			container.y = int(itemWidth * .9);
			
			addHours();
			addMinutes();
			addSeconds();
			addDots();
			addTexts();
		}
		
		private function calcSizes(componentWidth:int):void 
		{
			itemWidth = componentWidth / (6 + .13 * 3 + .7 * 2);
			smallPadding = itemWidth * .13;
			bigPadding = itemWidth * .7;
		}
		
		private function addTexts():void 
		{
			hoursText = new Bitmap();
			minutesText = new Bitmap();
			secondsText = new Bitmap();
			
			container.addChild(hoursText);
			container.addChild(minutesText);
			container.addChild(secondsText);
		}
		
		public function setValue(value:Number):void
		{
			if (firtHour == null)
			{
				ApplicationErrors.add();
				return;
			}
			
			var seconds:Number = Math.floor((value / (1000)) % 60);
			var minutes:Number = Math.floor((value / (1000 * 60)) % 60);
			var hours:Number = Math.floor((value / (1000 * 60 * 60)) % 24);
			var days:Number = Math.floor((value / (1000 * 60 * 60)) / 24);
			
			if (days > 0)
			{
				modeDays = true;
				
				if (days >= 10)
				{
					firtHour.setValue(Math.floor(days / 10));
					secondHour.setValue(days % 10);
				}
				else{
					firtHour.setValue(0);
					secondHour.setValue(days);
				}
				
				if (hours >= 10)
				{
					firtMinute.setValue(Math.floor(hours / 10));
					secondMinute.setValue(hours % 10);
				}
				else{
					firtMinute.setValue(0);
					secondMinute.setValue(hours);
				}
				
				if (minutes >= 10)
				{
					firtSecond.setValue(Math.floor(minutes / 10));
					secondSecond.setValue(minutes % 10);
				}
				else{
					firtSecond.setValue(0);
					secondSecond.setValue(minutes);
				}
			}
			else
			{
				modeDays = false;
				
				if (hours >= 10)
				{
					firtHour.setValue(Math.floor(hours / 10));
					secondHour.setValue(hours % 10);
				}
				else{
					firtHour.setValue(0);
					secondHour.setValue(hours);
				}
				
				if (minutes >= 10)
				{
					firtMinute.setValue(Math.floor(minutes / 10));
					secondMinute.setValue(minutes % 10);
				}
				else{
					firtMinute.setValue(0);
					secondMinute.setValue(minutes);
				}
				
				if (seconds >= 10)
				{
					firtSecond.setValue(Math.floor(seconds / 10));
					secondSecond.setValue(seconds % 10);
				}
				else{
					firtSecond.setValue(0);
					secondSecond.setValue(seconds);
				}
			}
			
			if (drawnTexts == false)
			{
				drawnTexts = true;
				drawTexts();
			}
		}
		
		private function drawTexts():void 
		{
			var firstText:String;
			var secondText:String;
			var thirdText:String;
			
			if (modeDays == true)
			{
				firstText = Lang.days.toUpperCase();
				secondText = Lang.textHours.toUpperCase();
				thirdText = Lang.textMinutes.toUpperCase();
			}
			else
			{
				firstText = Lang.textHours.toUpperCase();
				secondText = Lang.textMinutes.toUpperCase();
				thirdText = Lang.textSeconds.toUpperCase();
			}
			
			hoursText.bitmapData = TextUtils.createTextFieldData(firstText, itemWidth * 2.5, 10, false, TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, int(itemWidth * .3), false, 0x596269, 0xFFFFFF);
			minutesText.bitmapData = TextUtils.createTextFieldData(secondText, itemWidth * 2.5, 10, false, TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, int(itemWidth * .3), false, 0x596269, 0xFFFFFF);
			secondsText.bitmapData = TextUtils.createTextFieldData(thirdText, itemWidth * 2.5, 10, false, TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, int(itemWidth * .3), false, 0x596269, 0xFFFFFF);
			
			hoursText.x = int(itemWidth + smallPadding * .5 - hoursText.width * .5);
			minutesText.x = int(itemWidth * 2 + smallPadding + bigPadding + itemWidth + smallPadding * .5 - minutesText.width * .5);
			secondsText.x = int(itemWidth * 4 + smallPadding * 2 + bigPadding * 2 + itemWidth + smallPadding * .5 - secondsText.width * .5);
			
			hoursText.y = minutesText.y = secondsText.y = int(itemWidth * 1 + itemWidth * .25);
		}
		
		private function addDots():void 
		{
			container.graphics.beginFill(0x444C51, 0.9);
			var radius:int = itemWidth * .06;
			var positionX:int = secondHour.x + itemWidth + bigPadding * .5;
			container.graphics.drawCircle(positionX, -itemWidth * .2, radius);
			container.graphics.drawCircle(positionX, itemWidth * .2, radius);
			
			positionX = secondMinute.x + itemWidth + bigPadding * .5;
			container.graphics.drawCircle(positionX, -itemWidth * .2, radius);
			container.graphics.drawCircle(positionX, itemWidth * .2, radius);
			container.graphics.endFill();
		}
		
		private function addSeconds():void 
		{
			firtSecond = new CountdownItem(itemWidth);
			secondSecond = new CountdownItem(itemWidth);
			
			container.addChild(firtSecond);
			container.addChild(secondSecond);
			
			firtSecond.x = itemWidth * 4 + smallPadding * 2 + bigPadding * 2;
			secondSecond.x = itemWidth * 5 + smallPadding * 3 + bigPadding * 2;
		}
		
		private function addMinutes():void 
		{
			firtMinute = new CountdownItem(itemWidth);
			secondMinute = new CountdownItem(itemWidth);
			
			container.addChild(firtMinute);
			container.addChild(secondMinute);
			
			firtMinute.x = itemWidth * 2 + smallPadding + bigPadding;
			secondMinute.x = itemWidth * 3 + smallPadding * 2 + bigPadding;
		}
		
		private function addHours():void 
		{
			firtHour = new CountdownItem(itemWidth);
			secondHour = new CountdownItem(itemWidth);
			
			container.addChild(firtHour);
			container.addChild(secondHour);
			
			firtHour.x = 0;
			secondHour.x = itemWidth + smallPadding;
		}
		
		private function clear():void 
		{
			graphics.clear();
			
			try
			{
				if (hoursText != null)
				{
					UI.destroy(hoursText);
					hoursText = null;
				}
				if (minutesText != null)
				{
					UI.destroy(minutesText);
					minutesText = null;
				}
				if (secondsText != null)
				{
					UI.destroy(secondsText);
					secondsText = null;
				}
				if (firtHour != null)
				{
					firtHour.dispose();
					container.removeChild(firtHour);
					firtHour = null;
				}
				if (secondHour != null)
				{
					secondHour.dispose();
					container.removeChild(secondHour);
					secondHour = null;
				}
				if (firtMinute != null)
				{
					firtMinute.dispose();
					container.removeChild(firtMinute);
					firtMinute = null;
				}
				if (secondMinute != null)
				{
					secondMinute.dispose();
					container.removeChild(secondMinute);
					secondMinute = null;
				}
				if (firtSecond != null)
				{
					firtSecond.dispose();
					container.removeChild(firtSecond);
					firtSecond = null;
				}
				if (secondSecond != null)
				{
					secondSecond.dispose();
					container.removeChild(secondSecond);
					secondSecond = null;
				}
				if (container != null)
				{
					UI.destroy(container);
					container = null;
				}
			}
			catch (e:Error)
			{
				ApplicationErrors.add();
			}
		}
		
		public function dispose():void 
		{
			clear();
		}
	}
}