package com.dukascopy.connect.screens.dialogs.calendar
{
	import assets.CalendarIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.calendar.TimeRange;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
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
	public class DateTimePanelExtended extends Sprite
	{
		private var date:Date;
		private var hours:TimeRange;
		private var minutes:TimeRange;
		
		private var dateField:Bitmap;
		private var dayField:Bitmap;
		private var yearField:Bitmap;
		private var timeField:Bitmap;
		private var line:Bitmap;
		private var elementWidth:int;
		private var removeCallback:Function;
		private var subscribeCallback:Function;
		private var removeButton:BitmapButton;
		
		public function DateTimePanelExtended(removeCallback:Function, subscribeCallback:Function)
		{
			this.removeCallback = removeCallback;
			this.subscribeCallback = subscribeCallback;
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
			
			removeButton = new BitmapButton();
			removeButton.setStandartButtonParams();
			removeButton.setDownScale(1);
			removeButton.setDownColor(0);
			removeButton.tapCallback = removeClick;
			removeButton.disposeBitmapOnDestroy = true;
			removeButton.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
			addChild(removeButton);
		}
		
		private function selectClick():void 
		{
			if (subscribeCallback != null)
			{
				subscribeCallback();
			}
		}
		
		private function removeClick():void 
		{
			if (removeCallback != null)
			{
				removeCallback();
			}
		}
		
		public function activate():void
		{
			if (removeButton.visible == true)
			{
				removeButton.activate();
			}
		}
		
		public function deactivate():void
		{
			removeButton.deactivate();
		}
		
		public function draw(date:Date, elementWidth:int, hours:TimeRange = null, minutes:TimeRange = null):void
		{
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
			removeCallback = null;
			subscribeCallback = null;
			
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
			if (removeButton != null)
			{
				removeButton.dispose();
				removeButton = null;
			}
		}
		
		public function onCancelled():void 
		{
			timeField.visible = false;
			dateField.visible = false;
			dayField.visible = false;
			yearField.visible = false;
			
			drawRemoveButton(Lang.makeAppointment);
			removeButton.x = int(elementWidth * .5 - removeButton.width * .5);
			removeButton.tapCallback = selectClick;
		}
		
		private function drawElements():void
		{
			drawDay();
			drawDate();
			drawYear();
			drawTime();
			drawRemoveButton(Lang.cancelAppointment);
			
			drawLine();
			
			dateField.x = int(Config.FINGER_SIZE * .2);
			dateField.y = int(Config.FINGER_SIZE * .3);
			
			yearField.y = int(dateField.y + dateField.height * .5 - Config.FINGER_SIZE * .15 - yearField.height * .5);
			dayField.y = int(dateField.y + dateField.height * .5 + Config.FINGER_SIZE * .15 - yearField.height * .5);
			yearField.x = dayField.x = int(dateField.y + dateField.height + Config.FINGER_SIZE * .4);
			
			timeField.x = int(elementWidth - timeField.width - Config.FINGER_SIZE * .15);
			timeField.y = int(dateField.y + dateField.height * .5 - timeField.height * .5);
			
			removeButton.x = int(elementWidth * .5 - removeButton.width * .5);
			removeButton.y = int(dateField.y + dateField.height + Config.FINGER_SIZE * .35);
			
			line.y = int(removeButton.y + removeButton.height + Config.FINGER_SIZE * .3);
		}
		
		private function drawLine():void 
		{
			if (line.bitmapData != null)
			{
				line.bitmapData.dispose();
				line.bitmapData = null;
			}
			
			line.bitmapData = UI.getHorizontalLine(0xDAE3EC);
			line.width = elementWidth;
		}
		
		private function drawRemoveButton(value:String):void
		{
			var textSettings:TextFieldSettings = new TextFieldSettings(value, 0x6B7A8A, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, 0xFFFFFF, 0, Config.FINGER_SIZE * .8, 0xA0B8D0);
			removeButton.setBitmapData(buttonBitmap, true);
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