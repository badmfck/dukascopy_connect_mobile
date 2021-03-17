package com.dukascopy.connect.screens.dialogs.calendar
{
	import assets.CalendarIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.calendar.TimeRange;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class DateTimePanel extends Sprite
	{
		private var date:Date;
		private var hours:TimeRange;
		private var minutes:TimeRange;
		
		private var dateField:Bitmap;
		private var dayField:Bitmap;
		private var yearField:Bitmap;
		private var timeField:Bitmap;
		private var line:Bitmap;
		private var selectDateButton:BitmapButton;
		private var elementWidth:int;
		private var callCalendarCallback:Function;
		private var expanded:Boolean;
		
		public function DateTimePanel(callCalendarCallback:Function)
		{
			this.callCalendarCallback = callCalendarCallback;
			create();
		}
		
		private function create():void
		{
			dateField = new Bitmap();
			addChild(dateField);
			
			dayField = new Bitmap();
			addChild(dayField);
			
			yearField = new Bitmap();
			addChild(yearField);
			
			timeField = new Bitmap();
			addChild(timeField);
			
			line = new Bitmap();
			addChild(line);
			
			selectDateButton = new BitmapButton();
			selectDateButton.setStandartButtonParams();
			selectDateButton.setDownScale(1);
			selectDateButton.setDownColor(0);
			selectDateButton.tapCallback = selectDateClick;
			selectDateButton.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
			selectDateButton.setOverlayPadding(Config.FINGER_SIZE * .2);
			selectDateButton.disposeBitmapOnDestroy = true;
			addChild(selectDateButton);
		}
		
		private function selectDateClick():void
		{
			if (callCalendarCallback != null)
			{
				callCalendarCallback();
			}
		}
		
		public function activate():void
		{
			if (hours == null)
			{
				selectDateButton.activate();
			}
		}
		
		public function deactivate():void
		{
			if (hours != null)
			{
				selectDateButton.deactivate();
			}
		}
		
		public function draw(date:Date, elementWidth:int, hours:TimeRange = null, minutes:TimeRange = null, expanded:Boolean = false):void
		{
			this.expanded = expanded;
			this.date = date;
			this.hours = hours;
			this.minutes = minutes;
			this.elementWidth = elementWidth;
			
			drawElements();
		}
		
		public function getHeight():int 
		{
			return line.y + line.height;
		}
		
		public function dispose():void 
		{
			date = null;
			hours = null;
			minutes = null;
			callCalendarCallback = null;
			
			if (dateField != null)
			{
				UI.destroy(dateField);
				dateField = null;
			}
			if (dayField != null)
			{
				UI.destroy(dayField);
				dayField = null;
			}
			if (yearField != null)
			{
				UI.destroy(yearField);
				yearField = null;
			}
			if (timeField != null)
			{
				UI.destroy(timeField);
				timeField = null;
			}
			if (line != null)
			{
				UI.destroy(line);
				line = null;
			}
			if (selectDateButton != null)
			{
				selectDateButton.dispose();
				selectDateButton = null;
			}
		}
		
		public function getDate():Date 
		{
			var dateSelected:Date = new Date();
			dateSelected.setDate(1);
			dateSelected.setFullYear(date.getFullYear());
			dateSelected.setMonth(date.getMonth());
			dateSelected.setDate(date.getDate());
			return dateSelected;
		}
		
		private function drawElements():void
		{
			drawDay();
			drawDate();
			drawYear();
			if (hours != null)
			{
				drawTime();
			}
			else
			{
				drawCalenendarButton();
			}
			
			drawLine();
			
			dateField.x = int(Config.FINGER_SIZE * .2);
			dateField.y = int(Config.FINGER_SIZE * .3);
			
			if (expanded == true)
			{
				dateField.y += int(Config.FINGER_SIZE * .2);
			}
			
			yearField.y = int(dateField.y + dateField.height * .5 - Config.FINGER_SIZE * .15 - yearField.height * .5);
			dayField.y = int(dateField.y + dateField.height * .5 + Config.FINGER_SIZE * .15 - yearField.height * .5);
			yearField.x = dayField.x = int(dateField.x + dateField.width + Config.FINGER_SIZE * .3);
			
			if (hours == null)
			{
				selectDateButton.visible = true;
				timeField.visible = false;
				selectDateButton.x = int(elementWidth - selectDateButton.width - Config.FINGER_SIZE * .15);
				selectDateButton.y = int(dateField.y + dateField.height * .5 - selectDateButton.height * .5);
			}
			else
			{
				selectDateButton.visible = false;
				timeField.visible = true;
				timeField.x = int(elementWidth - timeField.width - Config.FINGER_SIZE * .15);
				timeField.y = int(dateField.y + dateField.height * .5 - timeField.height * .5);
			}
			
			line.y = int(dateField.y + dateField.height + Config.FINGER_SIZE * .35);
			
			if (expanded == true)
			{
				line.y += int(Config.FINGER_SIZE * .2);
			}
		}
		
		private function drawLine():void 
		{
			if (line.bitmapData != null)
			{
				line.bitmapData.dispose();
				line.bitmapData = null;
			}
			
			line.bitmapData = UI.getHorizontalLine(3, 0xDAE3EC);
			line.width = elementWidth;
		}
		
		private function drawCalenendarButton():void
		{
			var icon:CalendarIcon = new CalendarIcon();
			UI.scaleToFit(icon, Config.FINGER_SIZE * .5, Config.FINGER_SIZE * .5);
			selectDateButton.setBitmapData(UI.getSnapshot(icon, StageQuality.HIGH, "DateTimePanel.button"), true);
			UI.destroy(icon);
			icon = null;
		}
		
		private function drawTime():void
		{
			var timeValue:String = "";
			if (minutes != null)
			{
				timeValue += minutes.value.toString();
				if (timeValue.length == 1)
				{
					timeValue = "0" + timeValue;
				}
			}
			
			if (hours != null)
			{
				timeValue = hours.value.toString() + ":" + timeValue;
				if (timeValue.length == 4)
				{
					timeValue = "0" + timeValue;
				}
			}
			
			if (timeField.bitmapData != null)
			{
				timeField.bitmapData.dispose();
				timeField.bitmapData = null;
			}
			
			timeField.bitmapData = TextUtils.createTextFieldData(timeValue, Config.FINGER_SIZE * 3, 10, false, TextFormatAlign.LEFT, 
																	TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .50, false, 0xFF6600, 0xFFFFFF);
		}
		
		private function drawYear():void
		{
			if (yearField.bitmapData != null)
			{
				yearField.bitmapData.dispose();
				yearField.bitmapData = null;
			}
			
			yearField.bitmapData = TextUtils.createTextFieldData(Lang.getMonthTitleByIndex(date.getMonth())  + " " + date.getFullYear(), 
																	Config.FINGER_SIZE * 3, 10, false, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
																	Config.FINGER_SIZE * .26, false, 0x8FA3B8, 0xFFFFFF, true);
		}
		
		private function drawDate():void
		{
			if (dateField.bitmapData != null)
			{
				dateField.bitmapData.dispose();
				dateField.bitmapData = null;
			}
			
			dateField.bitmapData = TextUtils.createTextFieldData(date.getDate().toString(), Config.FINGER_SIZE * 3, 10, false, TextFormatAlign.LEFT, 
																	TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .70, false, 0x697787, 0xFFFFFF);
		}
		
		private function drawDay():void
		{
			if (dayField.bitmapData != null)
			{
				dayField.bitmapData.dispose();
				dayField.bitmapData = null;
			}
			
			dayField.bitmapData = TextUtils.createTextFieldData(getDayName(date.getDay()), Config.FINGER_SIZE * 3, 10, false, TextFormatAlign.LEFT, 
																	TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .26, false, 0x8FA3B8, 0xFFFFFF);
		}
		
		private function getDayName(index:int):String
		{
			var days:Vector.<String> = new <String>[Lang.monday, Lang.tuesday, Lang.wednesday, Lang.thursday, Lang.friday, Lang.saturday, Lang.sunday];
			if (index < 0 || index > days.length - 1)
			{
				ApplicationErrors.add();
				return "";
			}
			return days[index];
		}
	}
}