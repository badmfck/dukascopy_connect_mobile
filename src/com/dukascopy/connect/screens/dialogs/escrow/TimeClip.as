package com.dukascopy.connect.screens.dialogs.escrow
{
	import assets.EscrowClock;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.utils.DateUtils;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class TimeClip extends Sprite
	{
		private var finish:Function;
		private var timer:Timer;
		private var text:Bitmap;
		private var timeLeft:int;
		private var itemWidth:Number;
		private var iconTime:EscrowClock;
		
		public function TimeClip(finish:Function)
		{
			this.finish = finish;
			
			text = new Bitmap();
			addChild(text);
			
			var iconSize:int = Config.FINGER_SIZE * .46;
			iconTime = new EscrowClock();
			UI.colorize(iconTime, Style.color(Style.COLOR_SUBTITLE));
			addChild(iconTime);
			UI.scaleToFit(iconTime, iconSize, iconSize);
		}
		
		public function dispose():void
		{
			finish = null;
			clearTimer();
			if (text != null)
			{
				UI.destroy(text);
				text = null;
			}
			if (iconTime != null)
			{
				UI.destroy(iconTime);
				iconTime = null;
			}
		}
		
		public function draw(itemWidth:Number, time:int):void
		{
			timeLeft = time;
			this.itemWidth = itemWidth;
			clearTimer();
			timer = new Timer(1000, time);
			timer.addEventListener(TimerEvent.TIMER, onTick);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
			timer.start();
			drawCurrent();
		}
		
		private function onTimerComplete(e:TimerEvent):void 
		{
			if (finish != null)
			{
				finish();
			}
		}
		
		private function onTick(e:TimerEvent):void 
		{
			timeLeft -= 1;
			drawCurrent();
		}
		
		private function drawCurrent():void 
		{
			if (text != null)
			{
				if (text.bitmapData != null)
				{
					text.bitmapData.dispose();
					text.bitmapData = null;
				}
				var value:String = DateUtils.getTimeInNumbers2(timeLeft * 1000);
				value = Lang.time_left.replace(Lang.regExtValue, value);
				text.bitmapData = TextUtils.createTextFieldData(value, itemWidth, 10, true,
																	TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
																	FontSize.SUBHEAD, true, Style.color(Style.COLOR_SUBTITLE),
																	Style.color(Style.COLOR_BACKGROUND), false);
				text.x = int(iconTime.x + iconTime.width + Config.FINGER_SIZE * .15);
				text.y = int(iconTime.y + iconTime.height * .5 - text.height * .5);
			}
			else
			{
				ApplicationErrors.add();
			}
		}
		
		private function clearTimer():void
		{
			if (timer != null)
			{
				timer.removeEventListener(TimerEvent.TIMER, onTick);
				timer.removeEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
				timer.stop();
				timer = null;
			}
		}
	}
}