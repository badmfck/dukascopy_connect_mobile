package com.dukascopy.connect.screens.dialogs.calendar
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.calendar.Calendar;
	import com.dukascopy.connect.sys.calendar.TimeRange;
	import com.dukascopy.connect.sys.calendar.TimeRanges;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class TimeSelector extends Sprite
	{
		private var closedTimeRanges:TimeRanges;
		private var freeRanges:Vector.<TimeRange>;
		private var componentWidth:int;
		private var hoursSelector:TimeScrollSelector;
		private var minutesSelector:TimeScrollSelector;
		private var hoursText:Bitmap;
		private var minutesText:Bitmap;
		private var selectorsLinked:Boolean = true;
		
		public function TimeSelector()
		{
			create();
		}
		
		private function create():void
		{
			hoursSelector = new TimeScrollSelector(onHoursChanged);
			addChild(hoursSelector);
			
			minutesSelector = new TimeScrollSelector();
			addChild(minutesSelector);
			
			hoursText = new Bitmap();
			addChild(hoursText);
			
			minutesText = new Bitmap();
			addChild(minutesText);
			
			drawTexts();
		}
		
		private function onHoursChanged():void 
		{
			if (hoursSelector != null && minutesSelector != null && selectorsLinked == true)
			{
				drawMinutes();
			}
		}
		
		private function drawTexts():void 
		{
			hoursText.bitmapData = TextUtils.createTextFieldData(
													Lang.hoursShort, 
													Config.FINGER_SIZE * 3, 
													10, 
													false, 
													TextFormatAlign.LEFT,
													TextFieldAutoSize.LEFT, 
													Config.FINGER_SIZE*.26, 
													false, 
													0xFF6600, 
													0xFFFFFF, true);
			
			minutesText.bitmapData = TextUtils.createTextFieldData(
													Lang.minutesShort, 
													Config.FINGER_SIZE * 3, 
													10, 
													false, 
													TextFormatAlign.LEFT,
													TextFieldAutoSize.LEFT, 
													Config.FINGER_SIZE*.26, 
													false, 
													0xFF6600, 
													0xFFFFFF, true);
		}
		
		public function draw(freeRanges:Vector.<TimeRange>, componentWidth:int):void
		{
			if (freeRanges == null || freeRanges.length == 0)
			{
				return;
			}
			
			this.componentWidth = componentWidth;
			this.freeRanges = freeRanges;
			
			hoursSelector.x = int(componentWidth * .5 - Config.FINGER_SIZE * .2 - hoursSelector.getItemWidth());
			minutesSelector.x = int(componentWidth * .5 + Config.FINGER_SIZE * .2);
			
			drawHours();
			drawMinutes();
			
			hoursText.x = int(hoursSelector.x + hoursSelector.getItemWidth() - Config.FINGER_SIZE * .15);
			hoursText.y = int(hoursSelector.y + hoursSelector.getHeight() * .5 + Config.FINGER_SIZE * .18 - hoursText.height * .5);
			
			minutesText.x = int(minutesSelector.x + minutesSelector.getItemWidth() - Config.FINGER_SIZE * .15);
			minutesText.y = int(minutesSelector.y + minutesSelector.getHeight() * .5 + Config.FINGER_SIZE * .18 - minutesText.height * .5);
		}
		
		public function activate():void
		{
			hoursSelector.activate();
			minutesSelector.activate();
		}
		
		public function deactivate():void
		{
			hoursSelector.deactivate();
			minutesSelector.deactivate();
		}
		
		public function getHeight():int 
		{
			return hoursSelector.getHeight();
		}
		
		public function getHours():TimeRange 
		{
			return hoursSelector.getSelected();
		}
		
		public function getMinutes():TimeRange 
		{
			return minutesSelector.getSelected();
		}
		
		public function dispose():void 
		{
			closedTimeRanges = null;
			freeRanges = null;
			
			if (hoursSelector != null)
			{
				hoursSelector.dispose();
				hoursSelector = null;
			}
			if (minutesSelector != null)
			{
				minutesSelector.dispose();
				minutesSelector = null;
			}
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
		}
		
		public function hasData():Boolean 
		{
			return freeRanges != null;
		}
		
		public function clear():void 
		{
			freeRanges = null;
		}
		
		public function unlinkSelectors():void 
		{
			selectorsLinked = false;
		}
		
		public function select(hours:Number, minutes:Number):void 
		{
			
		}
		
		private function drawHours():void
		{
			hoursSelector.draw(freeRanges);
			hoursSelector.alpha = 0;
			TweenMax.to(hoursSelector, 0.3, {alpha:1});
		}
		
		private function drawMinutes():void 
		{
			var selectedHour:TimeRange = hoursSelector.getSelected();
			if (selectedHour != null)
			{
				var minutes:Vector.<TimeRange> = selectedHour.ranges;
				
				if (!minutesSelector.equalData(minutes))
				{
					minutesSelector.draw(minutes);
					minutesSelector.alpha = 0;
					TweenMax.to(minutesSelector, 0.3, {alpha:1});
				}
				
				minutesSelector.activate();
			}
			else
			{
				clearMinutes();
			}
		}
		
		private function clearMinutes():void 
		{
			
		}
		
		private function calculateFreeTimeRanges():void
		{
			var hoursRanges:Vector.<TimeRange> = new Vector.<TimeRange>();
			var rangeHour:TimeRange;
			var rangeMinutes:TimeRange;
			var hourIntervals:int = Math.floor(60 / Calendar.viCalendar.defaultTimeInterval);
			var minutesRanges:Vector.<TimeRange>;
			
			for (var i:int = 0; i < 23; i++)
			{
				rangeHour = new TimeRange(i, Calendar.viCalendar.defaultTimeInterval);
				for (var j:int = 0; j < hourIntervals; j++)
				{
					rangeMinutes = new TimeRange(j * Calendar.viCalendar.defaultTimeInterval, Calendar.viCalendar.defaultTimeInterval);
					rangeHour.addSubrange(rangeMinutes);
				}
				hoursRanges.push(rangeHour);
			}
			
			freeRanges = hoursRanges;
		}
	}
}