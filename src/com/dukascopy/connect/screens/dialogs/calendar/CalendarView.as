package com.dukascopy.connect.screens.dialogs.calendar 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.HitZoneData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.calendar.BookedDays;
	import com.dukascopy.connect.sys.calendar.Calendar;
	import com.dukascopy.connect.sys.calendar.Month;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import com.greensock.easing.Back;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	public class CalendarView extends Sprite
	{
		public var rangeSelection:Boolean;
		private var month:Month;
		private var componentWidth:int;
		private var titles:Vector.<Bitmap>;
		private var fontSize:Number;
		private var activeFontColor:uint;
		private var disableFontColor:uint;
		private var titleFontColor:uint;
		private var prewMonth:Month;
		private var days:Vector.<Bitmap>;
		private var verticalGap:int;
		private var background:Sprite;
		private var selector:Sprite;
		private var horizontalGap:int;
		private var items:Sprite;
		private var lastSelectedIndex:int = -1;
		private var onDaySelectedCallback:Function;
		private var currentSelectedDate:Date;
		private var bookedDays:BookedDays;
		private var bookedColor:uint;
		private var allowAll:Boolean;
		private var rangeFirstDay:Date;
		private var rangeSecondDay:Date;
		private var selectorRangeFirst:Sprite;
		private var selectorRangeSecond:Sprite;
		private var lastSelectedFirstIndex:int;
		private var lastSelectedSecondIndex:int;
		private var selectionLayer:Sprite;
		
		public function CalendarView(month:Month, onDaySelectedCallback:Function, currentSelectedDate:Date, rangeFirstDay:Date, rangeSecondDay:Date) 
		{
			this.currentSelectedDate = currentSelectedDate;
			this.rangeFirstDay = rangeFirstDay;
			this.rangeSecondDay = rangeSecondDay;
			this.onDaySelectedCallback = onDaySelectedCallback;
			this.month = month;
			prewMonth = Calendar.getPrewMonth(month);
			create();
		}
		
		public function allowAllDates(value:Boolean):void 
		{
			this.allowAll = value;
		}
		
		private function create():void 
		{
			fontSize = Config.FINGER_SIZE * .27;
			activeFontColor = Style.color(Style.COLOR_TEXT);
			disableFontColor = Style.color(Style.COLOR_TEXT_DISABLE);
			titleFontColor = Style.color(Style.COLOR_TEXT);
			bookedColor = 0xF0ADAD;
			
			background = new Sprite();
			background.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			background.graphics.drawRect(0, 0, 10, 10);
			background.graphics.endFill();
			addChild(background);
			
			selectionLayer = new Sprite();
			selectionLayer.mouseChildren = false;
			selectionLayer.mouseEnabled = false;
			addChild(selectionLayer);
			
			drawSelector();
			
			items = new Sprite();
			addChild(items);
			items.mouseEnabled = false;
			items.mouseChildren = false;
			
			createDaysTitles();
		}
		
		private function createDaysTitles():void 
		{
			titles = new Vector.<Bitmap>();
			
			var title:Bitmap;
			
			var titlesNames:Vector.<String> = new <String>[
												Lang.monday_short, 
												Lang.tuesday_short, 
												Lang.wednesday_short,
												Lang.thursday_short,
												Lang.friday_short,
												Lang.saturday_short,
												Lang.sunday_short];
			for (var i:int = 0; i < titlesNames.length; i++) 
			{
				title = drawDayTitle(titlesNames[i]);
				items.addChild(title);
				titles.push(title);
			}
		}
		
		private function drawDayTitle(value:String):Bitmap 
		{
			var bitmap:Bitmap = new Bitmap();
			bitmap.bitmapData = createText(value, titleFontColor); 
			return bitmap;
		}
		
		private function createText(value:String, color:uint, backColor:uint = 0xFFFFFF):ImageBitmapData 
		{
			return TextUtils.createTextFieldData(
													value, 
													Config.FINGER_SIZE, 
													10, 
													false, 
													TextFormatAlign.LEFT,
													TextFieldAutoSize.LEFT, 
													fontSize, 
													false, 
													color, 
													backColor);
		}
		
		public function draw(componentWidth:int):void
		{
			this.componentWidth = componentWidth;
			
			verticalGap = Config.FINGER_SIZE * .64;
			
			if (bookedDays == null && allowAll == false)
			{
				getUnavaliableDays();
			}
			
			createDays();
			
			reposition();
			
			background.width = componentWidth;
			background.height = items.height;
			
			if (rangeSelection == true)
			{
				selectRange(rangeFirstDay, rangeSecondDay);
			}
			else
			{
				if (currentSelectedDate != null)
				{
					selectDate(currentSelectedDate);
				}
			}
		}
		
		public function setSelected(date:Date):void
		{
			currentSelectedDate = date;
			draw(componentWidth);
		}
		
		private function selectDate(date:Date):void 
		{
			if (month.monthIndex == date.getMonth() && month.year == date.getFullYear())
			{
				selectItem(date.getDate() + month.firstDay - 2);
			}
		}
		
		public function getWidth():int 
		{
			return componentWidth;
		}
		
		public function dispose():void 
		{
			month = null;
			prewMonth = null;
			onDaySelectedCallback = null;
			
			var i:int;
			var l:int = titles.length;
			if (titles != null)
			{
				for (i = 0; i < l; i++) 
				{
					UI.destroy(titles[i]);
				}
				titles = null;
			}
			l = days.length;
			if (days != null)
			{
				for (i = 0; i < l; i++) 
				{
					UI.destroy(days[i]);
				}
				days = null;
			}
			if (background != null)
			{
				UI.destroy(background);
				background = null;
			}
			if (selectionLayer != null)
			{
				UI.destroy(selectionLayer);
				selectionLayer = null;
			}
			if (selector != null)
			{
				UI.destroy(selector);
				selector = null;
			}
			if (items != null)
			{
				UI.destroy(items);
				items = null;
			}
		}
		
		private function onTap(e:MouseEvent):void 
		{
			var point:Point = new Point(e.localX, e.localY);
			point = e.target.localToGlobal(point);
			point = this.globalToLocal(point);
			
			point.y -= Config.FINGER_SIZE * .1;
			point.x -= Config.FINGER_SIZE * .15;
			
			var indexH:int = Math.round(point.x / horizontalGap);
			var indexV:int = Math.round(point.y / verticalGap);
			
			if (indexV > 0)
			{
				var firstActiveIndex:int = month.firstDay;
				
				var currentDate:Date = new Date();
				if (currentDate.getUTCFullYear() == month.year && currentDate.getMonth() == month.monthIndex && allowAll == false)
				{
					firstActiveIndex = month.firstDay + currentDate.getDate() - 1;
				}
				
				if (firstActiveIndex == 0)
				{
					firstActiveIndex = 7;
				}
				firstActiveIndex --;
				var lastActiveIndex:int;
				if (month.firstDay == 0)
				{
					lastActiveIndex = 5 + month.days;
				}
				else
				{
					lastActiveIndex = month.firstDay + month.days - 2;
				}
				
				var selectedIndex:int = (indexV - 1) * 7 + indexH;
				
				if (selectedIndex >= firstActiveIndex && selectedIndex <= lastActiveIndex && isDayBooked(selectedIndex - month.firstDay + 1) == false && isInAllowedRange(selectedIndex - month.firstDay + 1))
				{
					if (rangeSelection == false)
					{
						selectItem(selectedIndex);
					}
					else
					{
						lastSelectedIndex = selectedIndex;
					}
					
					var hitZone:HitZoneData = new HitZoneData();
					point = new Point(selector.x, selector.y);
					point = localToGlobal(point);
					hitZone.touchPoint = point;
					hitZone.type = HitZoneType.MENU_SIMPLE_ELEMENT;
					hitZone.x = point.x - Config.FINGER_SIZE * .5;
					hitZone.y = point.y - Config.FINGER_SIZE * .5;
					hitZone.width = Config.FINGER_SIZE;
					hitZone.height = Config.FINGER_SIZE;
					hitZone.radius = Config.FINGER_SIZE;
				//	Overlay.displayTouch(hitZone);
					
					if (onDaySelectedCallback != null)
					{
						onDaySelectedCallback();
					}
				}
			}
		}
		
		private function isInAllowedRange(index:Number):Boolean 
		{
			var avaliable:Boolean = true;
			if (Calendar.viCalendar != null && Calendar.viCalendar.lastDate != null && Calendar.viCalendar.lastDate.getFullYear() == month.year && Calendar.viCalendar.lastDate.getMonth() == month.monthIndex && (index + 1) > Calendar.viCalendar.lastDate.getDate())
			{
				avaliable = false;
			}
			else if (Calendar.viCalendar != null && Calendar.viCalendar.lastDate != null && 
						((Calendar.viCalendar.lastDate.getFullYear() == month.year && Calendar.viCalendar.lastDate.getMonth() < month.monthIndex) || Calendar.viCalendar.lastDate.getFullYear() < month.year))
			{
				avaliable = false;
			}
			return avaliable;
		}
		
		private function isDayBooked(index:Number):Boolean 
		{
			if (bookedDays != null && bookedDays.isBooked(index) == true)
			{
				return true;
			}
			return false;
		}
		
		private function selectItem(index:int):void 
		{
			selector.x = int(days[index].x + days[index].width * .5) - items.x;
			selector.y = int(days[index].y + days[index].height * .5) - items.y;
			
			selector.scaleX = selector.scaleY = 0.7;
			
			TweenMax.to(selector, 0.3, {scaleX:1, scaleY:1, ease:Back.easeOut });
			
			selector.visible = true;
			
			if (lastSelectedIndex != -1)
			{
				drawNormal(lastSelectedIndex);
			}
			drawSelected(index);
			
			lastSelectedIndex = index;
		}
		
		private function drawSelected(index:int):void 
		{
			var value:int = index;
			if (month.firstDay == 0)
			{
				value -= 5;
			}
			else
			{
				value -= month.firstDay - 2;
			}
			if (days != null && days[index] != null)
			{
				if (days[index].bitmapData != null)
				{
					days[index].bitmapData.dispose();
					days[index].bitmapData = null;
				}
				days[index].bitmapData = createText(value.toString(), 0xFFFFFF, 0x71C2E7);
			}
		}
		
		private function drawNormal(index:int):void 
		{
			var value:int = index;
			if (month.firstDay == 0)
			{
				value -= 5;
			}
			else
			{
				value -= month.firstDay - 2;
			}
			if (days != null && days[index] != null)
			{
				if (days[index].bitmapData != null)
				{
					days[index].bitmapData.dispose();
					days[index].bitmapData = null;
				}
				days[index].bitmapData = createText(value.toString(), activeFontColor);
			}
		}
		
		private function reposition():void 
		{
			var padding:int = Config.FINGER_SIZE * .2;
			var positions:Vector.<int> = new Vector.<int>();
			horizontalGap = (componentWidth - padding * 2) / 6;
			
			for (var i:int = 0; i < titles.length; i++) 
			{
				positions[i] = padding + horizontalGap * i;
			}
			
			for (var j:int = 0; j < titles.length; j++) 
			{
				titles[j].x = int(positions[j] - titles[j].width * .5);
			}
			
			var currentRow:int = 0;
			var currentDay:int = 0;
			for (var k:int = 0; k < days.length; k++) 
			{
				days[k].x = int(positions[currentDay] - days[k].width * .5);
				days[k].y = (currentRow * verticalGap + verticalGap);
				
				currentDay ++;
				if (currentDay > 6)
				{
					currentRow ++;
					currentDay = 0;
				}
			}
		}
		
		private function createDays():void 
		{
			var i:int;
			if (days != null)
			{
				var l:int = days.length;
				for (i = 0; i < l; i++) 
				{
					UI.destroy(days[i]);
				}
				days = null;
			}
			
			days = new Vector.<Bitmap>();
			
			var day:Bitmap;
			
			if (month.firstDay > 1 || month.firstDay == 0)
			{
				var firstPrewDay:int;
				if (month.firstDay == 0)
				{
					firstPrewDay = prewMonth.days - 6;
				}
				else
				{
					firstPrewDay = prewMonth.days - month.firstDay + 1;
				}
				
				for (var j:int = firstPrewDay; j < prewMonth.days; j++) 
				{
					day = drawDayInactive((j + 1).toString());
					day.visible = false;
					items.addChild(day);
					days.push(day);
				}
			}
			
			var currentDate:Date = new Date();
			
			var currentDay:int = 0;
			if (currentDate.getUTCFullYear() == month.year && currentDate.getMonth() == month.monthIndex)
			{
				currentDay = currentDate.getDate() - 1;
			}
			
			for (i = 0; i < month.days; i++) 
			{
				if (i >= currentDay)
				{
					if (bookedDays != null && bookedDays.isBooked(i) == true)
					{
						day = drawDayBooked((i + 1).toString());
					}
					else
					{
						var avaliable:Boolean = true;
						if (allowAll == false)
						{
							if (Calendar.viCalendar != null && Calendar.viCalendar.lastDate != null && Calendar.viCalendar.lastDate.getFullYear() == month.year && Calendar.viCalendar.lastDate.getMonth() == month.monthIndex && (i + 1) > Calendar.viCalendar.lastDate.getDate())
							{
								avaliable = false;
							}
							else if (Calendar.viCalendar != null && Calendar.viCalendar.lastDate != null &&
										((Calendar.viCalendar.lastDate.getFullYear() == month.year && Calendar.viCalendar.lastDate.getMonth() < month.monthIndex) || Calendar.viCalendar.lastDate.getFullYear() < month.year))
							{
								avaliable = false;
							}
						}
						
						if (avaliable)
						{
							day = drawDayActive((i + 1).toString());
						}
						else
						{
							day = drawDayInactive((i + 1).toString());
						}
					}
				}
				else
				{
					if (allowAll == true)
					{
						day = drawDayActive((i + 1).toString());
					}
					else
					{
						day = drawDayInactive((i + 1).toString());
					}
				}
				
				items.addChild(day);
				days.push(day);
			}
			
			if (month.lastDay < 7 && month.lastDay != 0)
			{
				for (var k:int = 0; k < 7 - month.lastDay; k++) 
				{
					day = drawDayInactive((k + 1).toString());
					day.visible = false;
					items.addChild(day);
					days.push(day);
				}
			}
		}
		
		private function drawSelector():void 
		{
			selector = new Sprite();
			var radius:int = Config.FINGER_SIZE * .38;
			selector.graphics.beginFill(0x71C2E7);
			selector.graphics.drawCircle(0, 0, radius);
			selector.graphics.endFill();
			selector.mouseChildren = false;
			selector.mouseEnabled = false;
			selector.visible = false;
			addChild(selector);
			
			selectorRangeFirst = new Sprite();
			radius = Config.FINGER_SIZE * .33;
			selectorRangeFirst.graphics.beginFill(Color.RED);
			selectorRangeFirst.graphics.drawCircle(0, 0, radius);
			selectorRangeFirst.graphics.endFill();
			selectorRangeFirst.mouseChildren = false;
			selectorRangeFirst.mouseEnabled = false;
			selectorRangeFirst.visible = false;
			addChild(selectorRangeFirst);
			
			selectorRangeSecond = new Sprite();
			radius = Config.FINGER_SIZE * .33;
			selectorRangeSecond.graphics.beginFill(Color.RED);
			selectorRangeSecond.graphics.drawCircle(0, 0, radius);
			selectorRangeSecond.graphics.endFill();
			selectorRangeSecond.mouseChildren = false;
			selectorRangeSecond.mouseEnabled = false;
			selectorRangeSecond.visible = false;
			addChild(selectorRangeSecond);
		}
		
		public function activate():void
		{
			PointerManager.addTap(background, onTap);
		}
		
		public function deactivate():void
		{
			PointerManager.removeTap(background, onTap);
		}
		
		public function getMonth():Month 
		{
			return month;
		}
		
		public function getSelectedDate():Date 
		{
			if (lastSelectedIndex == -1)
			{
				return null;
			}
			var date:Date = new Date();
			date.setDate(1);
			date.setFullYear(month.year);
			date.setMonth(month.monthIndex);
			date.setDate(lastSelectedIndex - month.firstDay + 2);
			
			var today:Date = new Date();
			
			if (date.getDate() == today.getDate() && date.getFullYear() == today.getFullYear() && date.getMonth() == today.getMonth())
			{
				
			}
			else
			{
				date.setHours(0);
				date.setMinutes(0);
				date.setSeconds(0);
				date.setMilliseconds(0);
			}
			
			return date;
		}
		
		public function animateShow(animationDistance:int, animationTime:Number):void 
		{
			var l:int = titles.length;
			for (var i:int = 0; i < l; i++) 
			{
				animate(titles[i], animationDistance, animationTime, 0);
			}
			l = days.length;
			for (var j:int = 0; j < l; j++) 
			{
				animate(days[j], animationDistance, animationTime, (Math.floor(j/7) + 1)*0.1);
			}
		}
		
		public function markAnavaliableDays():void 
		{
			getUnavaliableDays();
			if (bookedDays != null)
			{
				
			}
			else
			{
				//!TODO: загрузить закрыте дни на данный месяц и проверить не идёт ли уже загрузка?;
			}
			draw(componentWidth);
		}
		
		public function getSelectedFirstDate():Date 
		{
			if (lastSelectedFirstIndex == -1)
			{
				return null;
			}
			var date:Date = new Date();
			date.setDate(1);
			date.setFullYear(month.year);
			date.setMonth(month.monthIndex);
			date.setDate(lastSelectedFirstIndex - month.firstDay + 2);
			
			var today:Date = new Date();
			
			if (date.getDate() == today.getDate() && date.getFullYear() == today.getFullYear() && date.getMonth() == today.getMonth())
			{
				
			}
			else
			{
				date.setHours(0);
				date.setMinutes(0);
				date.setSeconds(0);
				date.setMilliseconds(0);
			}
			
			return date;
		}
		
		public function getSelectedSecondDate():Date 
		{
			if (lastSelectedSecondIndex == -1)
			{
				return null;
			}
			var date:Date = new Date();
			date.setDate(1);
			date.setFullYear(month.year);
			date.setMonth(month.monthIndex);
			date.setDate(lastSelectedSecondIndex - month.firstDay + 2);
			
			var today:Date = new Date();
			
			if (date.getDate() == today.getDate() && date.getFullYear() == today.getFullYear() && date.getMonth() == today.getMonth())
			{
				
			}
			else
			{
				date.setHours(0);
				date.setMinutes(0);
				date.setSeconds(0);
				date.setMilliseconds(0);
			}
			
			return date;
		}
		
		public function selectRange(rangeFirstDay:Date, rangeSecondDay:Date):void 
		{
			var firstIndex:int = -1;
			var secondIndex:int = -1;
			if (rangeFirstDay != null)
			{
				firstIndex = rangeFirstDay.getDate() + month.firstDay - 2;
				if (month.monthIndex == rangeFirstDay.getMonth() && month.year == rangeFirstDay.getFullYear())
				{
					selectorRangeFirst.visible = true;
					
					if (selectorRangeFirst.x != int(days[firstIndex].x + days[firstIndex].width * .5) - items.x ||
						selectorRangeFirst.y != int(days[firstIndex].y + days[firstIndex].height * .5) - items.y)
					{
						selectorRangeFirst.x = int(days[firstIndex].x + days[firstIndex].width * .5) - items.x;
						selectorRangeFirst.y = int(days[firstIndex].y + days[firstIndex].height * .5) - items.y;
						
						selectorRangeFirst.scaleX = selectorRangeFirst.scaleY = 0.7;
						
						TweenMax.to(selectorRangeFirst, 0.3, {scaleX:1, scaleY:1, ease:Back.easeOut });
					}
					
					if (lastSelectedFirstIndex != -1)
					{
						drawNormal(lastSelectedFirstIndex);
					}
					drawSelected(firstIndex);
					
					lastSelectedFirstIndex = firstIndex;
				}
				else
				{
					selectorRangeFirst.visible = false;
					if (lastSelectedFirstIndex != -1)
					{
						drawNormal(lastSelectedFirstIndex);
					}
					lastSelectedFirstIndex = -1;
					firstIndex = -1;
				}
			}
			else
			{
				selectorRangeFirst.visible = false;
				if (lastSelectedFirstIndex != -1)
				{
					drawNormal(lastSelectedFirstIndex);
				}
				lastSelectedFirstIndex = -1;
			}
			
			if (rangeSecondDay != null)
			{
				secondIndex = rangeSecondDay.getDate() + month.firstDay - 2;
				if (month.monthIndex == rangeSecondDay.getMonth() && month.year == rangeSecondDay.getFullYear())
				{
					selectorRangeSecond.visible = true;
					
					selectorRangeSecond.x = int(days[secondIndex].x + days[secondIndex].width * .5) - items.x;
					selectorRangeSecond.y = int(days[secondIndex].y + days[secondIndex].height * .5) - items.y;
					
					selectorRangeSecond.scaleX = selectorRangeSecond.scaleY = 0.7;
					
					TweenMax.to(selectorRangeSecond, 0.3, {scaleX:1, scaleY:1, ease:Back.easeOut });
					
					if (lastSelectedSecondIndex != -1)
					{
						drawNormal(lastSelectedSecondIndex);
					}
					drawSelected(secondIndex);
					
					lastSelectedSecondIndex = secondIndex;
				}
				else
				{
					selectorRangeSecond.visible = false;
					if (lastSelectedSecondIndex != -1)
					{
						drawNormal(lastSelectedSecondIndex);
					}
					lastSelectedSecondIndex = -1;
					secondIndex = -1;
				}
			}
			else
			{
				selectorRangeSecond.visible = false;
				if (lastSelectedSecondIndex != -1)
				{
					drawNormal(lastSelectedSecondIndex);
				}
				lastSelectedSecondIndex = -1;
			}
			
			selectionLayer.graphics.clear();
			
			if (firstIndex == -1 && secondIndex != -1)
			{
				firstIndex = month.firstDay - 1;
			}
			else if (firstIndex != -1 && secondIndex == -1 && rangeSecondDay != null)
			{
				secondIndex = month.days - 2 + month.firstDay;
			}
			else if (firstIndex == -1 && secondIndex == -1 && rangeFirstDay != null && rangeSecondDay != null &&
					((month.year > rangeFirstDay.getFullYear() && month.year < rangeSecondDay.getFullYear()) ||
					(month.year == rangeFirstDay.getFullYear() && month.year == rangeSecondDay.getFullYear() && month.monthIndex > rangeFirstDay.getMonth() && month.monthIndex < rangeSecondDay.getMonth()) ||
					(month.year > rangeFirstDay.getFullYear() && month.year == rangeSecondDay.getFullYear() && month.monthIndex < rangeSecondDay.getMonth()) ||
					(month.year == rangeFirstDay.getFullYear() && month.year < rangeSecondDay.getFullYear() && month.monthIndex > rangeFirstDay.getMonth())))
			{
				firstIndex = month.firstDay - 1;
				secondIndex = month.days - 2 + month.firstDay;
			}
			
			if (firstIndex != -1 && secondIndex != -1)
			{
				var startRow:int = Math.floor((firstIndex) / 7) + 1;
				var secondRow:int = Math.floor((secondIndex) / 7) + 1;
				/*if (!(month.monthIndex == rangeFirstDay.getMonth() && month.year == rangeFirstDay.getFullYear()))
				{
					firstIndex = 0;
					startRow = 0;
				}
				if (!(month.monthIndex == rangeSecondDay.getMonth() && month.year == rangeSecondDay.getFullYear()))
				{
					secondIndex = days.length - 1;
					secondRow = Math.round((month.firstDay + secondIndex + 1)/7);
				}*/
				
				var rows:int = secondRow - startRow + 1;
				
				var startX:int;
				var startY:int;
				var endX:int;
				var endY:int;
				
				var radius:int = Config.FINGER_SIZE * .2;
				var paddingV:int = Config.FINGER_SIZE * .29;
				var paddingH:int = Config.FINGER_SIZE * .29;
				if (rows == 1)
				{
					startX = int(days[firstIndex].x + days[firstIndex].width * .5 - paddingH) - items.x;
					startY = int(days[firstIndex].y + days[firstIndex].height * .5 - paddingV) - items.y;
					
					endX = int(days[secondIndex].x + days[secondIndex].width * .5 + paddingH) - items.x;
					endY = int(days[secondIndex].y + days[secondIndex].height * .5 + paddingV) - items.y;
					
					selectionLayer.graphics.beginFill(Style.color(Style.COLOR_TIP_BACKGROUND));
					selectionLayer.graphics.drawRoundRect(startX, startY, endX - startX, endY - startY, radius);
					selectionLayer.graphics.endFill();
				}
				else
				{
					var currentStartIndex:int = firstIndex;
					var currentEndIndex:int = Math.min(secondIndex, (startRow) * 7 - 1);
					for (var i:int = 0; i < rows; i++) 
					{
						
						startX = int(days[currentStartIndex].x + days[currentStartIndex].width * .5 - paddingH) - items.x;
						startY = int(days[currentStartIndex].y + days[currentStartIndex].height * .5 - paddingV) - items.y;
						
						endX = int(days[currentEndIndex].x + days[currentEndIndex].width * .5 + paddingH) - items.x;
						endY = int(days[currentEndIndex].y + days[currentEndIndex].height * .5 + paddingV) - items.y;
						
						selectionLayer.graphics.beginFill(Style.color(Style.COLOR_TIP_BACKGROUND));
						selectionLayer.graphics.drawRoundRect(startX, startY, endX - startX, endY - startY, radius);
						selectionLayer.graphics.endFill();
						
						currentStartIndex = (startRow + i) * 7;
						currentEndIndex = Math.min(secondIndex, (startRow + i + 1) * 7 - 1);
					}
				}
			}
		}
		
		private function getUnavaliableDays():void 
		{
			if (Calendar.viCalendar != null && Calendar.viCalendar.ready)
			{
				bookedDays = Calendar.viCalendar.getUnavaliableDays(month.year.toString() + "_" + month.monthIndex.toString());
			}
		}
		
		private function animate(target:DisplayObject, animationDistance:int, animationTime:Number, delay:Number):void 
		{
			return;
			
			var targetPosition:int = target.y;
			target.y += animationDistance;
			target.alpha = 0;
			TweenMax.to(target, animationTime, {y:targetPosition, alpha:1, delay:delay});
		}
		
		private function drawDayActive(value:String):Bitmap 
		{
			var bitmap:Bitmap = new Bitmap();
			bitmap.bitmapData = createText(value, activeFontColor);
			return bitmap;
		}
		
		private function drawDayBooked(value:String):Bitmap 
		{
			var bitmap:Bitmap = new Bitmap();
			bitmap.bitmapData = createText(value, bookedColor);
			return bitmap;
		}
		
		private function drawDayInactive(value:String):Bitmap 
		{
			var bitmap:Bitmap = new Bitmap();
			bitmap.bitmapData = createText(value, disableFontColor);
			return bitmap;
		}
	}
}