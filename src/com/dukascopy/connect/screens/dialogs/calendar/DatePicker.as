package com.dukascopy.connect.screens.dialogs.calendar 
{
	import assets.NextIcon2;
	import assets.PrewIcon2;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.calendar.BookedDays;
	import com.dukascopy.connect.sys.calendar.Calendar;
	import com.dukascopy.connect.sys.calendar.DayBookData;
	import com.dukascopy.connect.sys.calendar.Month;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.tapper.TapperInstance;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.type.MainColors;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	public class DatePicker extends Sprite
	{
		public var onSelect:Function;
		private var _rangeSelection:Boolean;
		private var calendar:Calendar;
		private var currentMonth:Month;
		private var componentWidth:int;
		private var view:CalendarView;
		
		private var title:Bitmap;
		private var prewButton:BitmapButton;
		private var buttonNext:BitmapButton;
		private var nextCalendar:Calendar;
		private var nextView:CalendarView;
		private var locked:Boolean;
		private var currentMonthIndex:int;
		private var currentYear:int;
		private var isActive:Boolean;
		private var tapper:TapperInstance;
		private var nextViewPending:CalendarView;
		private var prewViewPending:CalendarView;
		private var touchExistValue:Boolean;
		private var currentSelectedDate:Date;
		private var viDisabled:Boolean;
		private var allowAll:Boolean;
		private var rangeFirstDay:Date;
		private var rangeSecondDay:Date;
		
		public function DatePicker()
		{
			create();
			
			calendar = new Calendar();
			currentMonth = calendar.getCurrentMonth();
			currentMonthIndex = currentMonth.monthIndex;
			currentYear = currentMonth.year;
		}
		
		public function disableVI():void
		{
			viDisabled = true;
		}
		
		private function create():void
		{
			title = new Bitmap();
			addChild(title);
			
			drawNextButton();
			drawPrewButton();
		}
		
		private function drawPrewButton():void
		{
			var btnSize:int = Config.FINGER_SIZE * .5;
			var btnOffset:int = (Config.FINGER_SIZE - btnSize) * .5;
			prewButton = new BitmapButton();
			prewButton.setStandartButtonParams();
			prewButton.setDownScale(1.3);
			prewButton.setDownColor(0xFFFFFF);
			prewButton.tapCallback = onPrewButtonClick;
			prewButton.disposeBitmapOnDestroy = true;
			prewButton.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
			prewButton.show();
			addChild(prewButton);
			var iconClose:Sprite = new PrewIcon2();
			iconClose.width = iconClose.height = btnSize;
			
			prewButton.setBitmapData(UI.getSnapshot(iconClose, StageQuality.HIGH, "DatePicker.iconPrew"), true);
			prewButton.setOverflow(Config.MARGIN * .5, Config.MARGIN * .5, Config.MARGIN * .5, Config.MARGIN * .5);
			UI.destroy(iconClose);
			iconClose = null;
		}
		
		public function activate():void
		{
			isActive = true;
			
			buttonNext.activate();
			prewButton.activate();
			
			if (view != null && locked == false)
			{
				activateView();
			}
		}
		
		private function activateView():void 
		{
			if (locked == true)
			{
				return;
			}
			
			view.activate();
		//	PointerManager.addMove(view, onMove);
			if (tapper != null)
			{
				tapper.activate();
			}
		}
		
		private function onMove(e:MouseEvent):void 
		{
			
		}
		
		public function deactivate():void
		{
			isActive = false;
			
			buttonNext.deactivate();
			prewButton.deactivate();
			
			if (view != null)
			{
				deactivateView();
			}
		}
		
		private function deactivateView():void 
		{
			view.deactivate();
		//	PointerManager.removeMove(view, onMove);
			if (tapper != null)
			{
				tapper.deactivate();
			}
		}
		
		private function onPrewButtonClick():void
		{
			if (locked == true)
			{
				return;
			}
			
			if ((currentMonth.year > currentYear || currentMonth.monthIndex > currentMonthIndex) || allowAll == true)
			{
				lock();
				currentMonth = Calendar.getPrewMonth(currentMonth);
				nextView = new CalendarView(currentMonth, onDaySelected, currentSelectedDate, rangeFirstDay, rangeSecondDay);
				nextView.rangeSelection = rangeSelection;
				nextView.allowAllDates(allowAll);
				nextView.y = int(Config.FINGER_SIZE * .9);
				addChild(nextView);
				nextView.draw(componentWidth);
				nextView.x = - componentWidth - Config.FINGER_SIZE;
				
				TweenMax.killTweensOf(title);
				TweenMax.to(view, 0.5, {x:(componentWidth + Config.FINGER_SIZE)});
				TweenMax.to(title, 0.25, {alpha:0, onComplete:changeTitle, onCompleteParams:[getTitle(currentMonth)], y:(title.y + Config.FINGER_SIZE * .1)});
				TweenMax.to(nextView, 0.5, {x:0, onComplete:onNewCalenderShown});
			}
		}
		
		private function getTitle(month:Month):String 
		{
			return Lang.getMonthTitleByIndex(month.monthIndex) + " " + month.year.toString();
		}
		
		private function onNextButtonClick():void
		{
			if (locked == true)
			{
				return;
			}
			
			if (allowAll == false)
			{
				if (viDisabled == false && Calendar.viCalendar != null && Calendar.viCalendar.success && Calendar.viCalendar.lastDate != null)
				{
					var targetMonth:Month = Calendar.getNextMonth(currentMonth);
					if (Calendar.viCalendar.lastDate.getFullYear() < targetMonth.year)
					{
						return;
					}
					if (Calendar.viCalendar.lastDate.getFullYear() == targetMonth.year && Calendar.viCalendar.lastDate.getMonth() < targetMonth.monthIndex)
					{
						return;
					}
				}
			}
			
			lock();
			currentMonth = Calendar.getNextMonth(currentMonth);
			nextView = new CalendarView(currentMonth, onDaySelected, currentSelectedDate, rangeFirstDay, rangeSecondDay);
			nextView.rangeSelection = rangeSelection;
			nextView.allowAllDates(allowAll);
			nextView.y = int(Config.FINGER_SIZE * .9);
			addChild(nextView);
			nextView.draw(componentWidth);
			nextView.draw(componentWidth);
			nextView.x = componentWidth + Config.FINGER_SIZE;
			TweenMax.to(view, 0.5, {x:( - componentWidth - Config.FINGER_SIZE)});
			TweenMax.to(title, 0.25, {alpha:0, onComplete:changeTitle, onCompleteParams:[getTitle(currentMonth)]});
			TweenMax.to(nextView, 0.5, {x:0, onComplete:onNewCalenderShown});
		}
		
		private function changeTitle(value:String):void 
		{
			drawTitle(value);
			var endPosition:int = title.y;
			title.y = endPosition - Config.FINGER_SIZE * .1;
			TweenMax.to(title, 0.25, {alpha:1, y:endPosition});
		}
		
		private function onNewCalenderShown():void 
		{
			unlock();
			
			if (view != null)
			{
				view.dispose();
				removeChild(view);
			}
			view = nextView;
			nextView = null;
			
			addTapper();
			
			if (isActive)
			{
				activateView();
			}
		}
		
		private function onMoved(scrollStopped:Boolean = false):void {
			checkBoxBounds(scrollStopped);
		}
		
		private function checkBoxBounds(scrollStopped:Boolean = false):void {
			if (view.x < 0)
			{
				addNextMonth();
			}
			else if (view.x > 0)
			{
				if (currentMonth.year > currentYear || currentMonth.monthIndex > currentMonthIndex || allowAll == true)
				{
					addPrewMonth();
				}
				else
				{
					
				}
			}
			
			if (view.x < -componentWidth - Config.FINGER_SIZE)
			{
				if (touchExistValue)
				{
					view.x += (-componentWidth - Config.FINGER_SIZE) * .5 - view.x * .5;
				}
				else
				{
					
				}
			}
			else if (view.x > componentWidth + Config.FINGER_SIZE)
			{
				if (touchExistValue)
				{
					view.x -= view.x * .5 - (componentWidth + Config.FINGER_SIZE) * .5;
				}
				else
				{
					
				}
			}
			
			if (nextViewPending != null)
			{
				nextViewPending.x = int(view.x + componentWidth + Config.FINGER_SIZE);
			}
			
			if (prewViewPending != null)
			{
				prewViewPending.x = int(view.x - componentWidth - Config.FINGER_SIZE);
			}
			
			if (!touchExistValue)
			{
				if (view.x > componentWidth * .3)
				{
					if (currentMonth.year > currentYear || currentMonth.monthIndex > currentMonthIndex || allowAll == true)
					{
						toPrewMonth();
					}
					else
					{
						toCurrentMonth();
					}
				}
				else if (view.x < -componentWidth * .3)
				{
					var avaliable:Boolean = true;
					var targetMonth:Month = Calendar.getNextMonth(currentMonth);
					if (allowAll == false)
					{
						if (Calendar.viCalendar != null && viDisabled == false && Calendar.viCalendar.lastDate.getFullYear() < targetMonth.year)
						{
							avaliable = false;
						}
						if (Calendar.viCalendar != null && viDisabled == false && Calendar.viCalendar.lastDate.getFullYear() == targetMonth.year && Calendar.viCalendar.lastDate.getMonth() < targetMonth.monthIndex)
						{
							avaliable = false;
						}
					}
					
					if (avaliable)
					{
						toNextMonth();
					}
					else
					{
						toCurrentMonth();
					}
				}
				else
				{
					toCurrentMonth();
				}
			}
		}
		
		private function toCurrentMonth():void 
		{
			if (tapper != null)
			{
				tapper.deactivate();
			}
			
			lock();
			
			TweenMax.to(view, 0.5, {x:0, onUpdate:toCurrentwUpdate, onComplete:toCurrentComplete});
		}
		
		private function toCurrentwUpdate():void 
		{
			if (prewViewPending != null)
			{
				prewViewPending.x = int(view.x - componentWidth - Config.FINGER_SIZE);
			}
			
			if (nextViewPending != null)
			{
				nextViewPending.x = int(view.x + componentWidth + Config.FINGER_SIZE);
			}
		}
		
		private function toCurrentComplete():void 
		{
			unlock();
			
			removePrewPending();
			removeNextPending();
			
			if (isActive)
			{
				activateView();
			}
		}
		
		private function toPrewMonth():void 
		{
			lock();
			
			TweenMax.to(title, 0.25, {alpha:0, onComplete:changeTitle, onCompleteParams:[getTitle(prewViewPending.getMonth())]});
			TweenMax.to(prewViewPending, 0.5, {x:0, onUpdate:toPrewUpdate, onComplete:toPrewComplete});
		}
		
		private function toPrewUpdate():void 
		{
			view.x = int(prewViewPending.x + componentWidth + Config.FINGER_SIZE);
			if (nextViewPending != null)
			{
				nextViewPending.x = int(view.x + componentWidth + Config.FINGER_SIZE);
			}
		}
		
		private function toPrewComplete():void 
		{
			unlock();
			
			removeCurrent();
			removeNextPending();
			
			view = prewViewPending;
			prewViewPending = null;
			
			addTapper();
			
			if (isActive)
			{
				activateView();
			}
			
			currentMonth = view.getMonth();
		}
		
		private function toNextMonth():void 
		{
			lock();
			
			TweenMax.to(title, 0.25, {alpha:0, onComplete:changeTitle, onCompleteParams:[getTitle(nextViewPending.getMonth())]});
			TweenMax.to(nextViewPending, 0.5, {x:0, onUpdate:toNextUpdate, onComplete:toNextComplete});
		}
		
		private function lock():void 
		{
			locked = true;
			if (tapper != null)
			{
				tapper.deactivate();
			}
		}
		
		private function unlock():void 
		{
			locked = false;
			if (tapper != null && isActive)
			{
				tapper.activate();
			}
		}
		
		private function toNextUpdate():void 
		{
			view.x = int(nextViewPending.x - componentWidth - Config.FINGER_SIZE);
			if (prewViewPending != null)
			{
				prewViewPending.x = int(view.x - componentWidth - Config.FINGER_SIZE);
			}
		}
		
		private function toNextComplete():void 
		{
			unlock();
			
			removeCurrent();
			removePrewPending();
			
			view = nextViewPending;
			nextViewPending = null;
			
			addTapper();
			
			if (isActive)
			{
				activateView();
			}
			
			currentMonth = view.getMonth();
		}
		
		private function removePrewPending():void 
		{
			if (prewViewPending != null)
			{
				prewViewPending.dispose();
				removeChild(prewViewPending);
				prewViewPending = null;
			}
		}
		
		private function removeNextPending():void 
		{
			if (nextViewPending != null)
			{
				nextViewPending.dispose();
				removeChild(nextViewPending);
				nextViewPending = null;
			}
		}
		
		private function removeCurrent():void 
		{
			if (view != null)
			{
				view.dispose();
				removeChild(view);
				view = null;
			}
		}
		
		private function addPrewMonth():void 
		{
			if (prewViewPending != null)
			{
				return;
			}
			
			var prewMonth:Month = Calendar.getPrewMonth(currentMonth);
			prewViewPending = new CalendarView(prewMonth, onDaySelected, currentSelectedDate, rangeFirstDay, rangeSecondDay);
			prewViewPending.rangeSelection = rangeSelection;
			prewViewPending.allowAllDates(allowAll);
			prewViewPending.y = int(Config.FINGER_SIZE * .9);
			addChild(prewViewPending);
			prewViewPending.draw(componentWidth);
			prewViewPending.x = int(view.x - componentWidth - Config.FINGER_SIZE);
		}
		
		private function addNextMonth():void 
		{
			if (nextViewPending != null)
			{
				return;
			}
			
			var nextMonth:Month = Calendar.getNextMonth(currentMonth);
			nextViewPending = new CalendarView(nextMonth, onDaySelected, currentSelectedDate, rangeFirstDay, rangeSecondDay);
			nextViewPending.rangeSelection = rangeSelection;
			nextViewPending.allowAllDates(allowAll);
			nextViewPending.y = int(Config.FINGER_SIZE * .9);
			addChild(nextViewPending);
			nextViewPending.draw(componentWidth);
			nextViewPending.x = int(view.x + componentWidth + Config.FINGER_SIZE);
		}
		
		private function drawTitle(value:String):void
		{
			var maxWidth:int = componentWidth;
			if (prewButton != null)
			{
				maxWidth -= prewButton.width - Config.MARGIN;
			}
			if (buttonNext != null)
			{
				maxWidth -= buttonNext.width - Config.MARGIN;
			}
			
			if (title.bitmapData != null)
			{
				title.bitmapData.dispose();
				title.bitmapData = null;
			}
			
			title.bitmapData = TextUtils.createTextFieldData(
																value, 
																maxWidth, 
																10, 
																true, 
																TextFormatAlign.LEFT, 
																TextFieldAutoSize.LEFT, 
																Config.FINGER_SIZE * .28, 
																true, 
																Style.color(Style.COLOR_SUBTITLE), 
																Style.color(Style.COLOR_BACKGROUND));
			title.y = int(buttonNext.height * .5 - title.height * .5);
		}
		
		private function drawNextButton():void
		{
			var btnSize:int = Config.FINGER_SIZE * .5;
			var btnOffset:int = (Config.FINGER_SIZE - btnSize) * .5;
			buttonNext = new BitmapButton();
			buttonNext.setStandartButtonParams();
			buttonNext.setDownScale(1.3);
			buttonNext.setDownColor(0xFFFFFF);
			buttonNext.tapCallback = onNextButtonClick;
			buttonNext.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
			buttonNext.disposeBitmapOnDestroy = true;
			buttonNext.show();
			addChild(buttonNext);
			var iconClose:Sprite = new NextIcon2();
			iconClose.width = iconClose.height = btnSize;
			
			buttonNext.setBitmapData(UI.getSnapshot(iconClose, StageQuality.HIGH, "DatePicker.iconNext"), true);
			buttonNext.setOverflow(Config.MARGIN * .5, Config.MARGIN * .5, Config.MARGIN * .5, Config.MARGIN * .5);
			UI.destroy(iconClose);
			iconClose = null;
		}
		
		public function draw(componentWidth:int):void
		{
			this.componentWidth = componentWidth;
			drawCurrent();
			drawTitle(getTitle(currentMonth));
			
			buttonNext.x = int(componentWidth - buttonNext.width);
			prewButton.x = int(buttonNext.x - prewButton.width - Config.MARGIN * 2);
		}
		
		public function getWidth():int 
		{
			return view.getWidth();
		}
		
		public function dispose():void 
		{
			onSelect = null;
			calendar = null;
			nextCalendar = null;
			
			TweenMax.killTweensOf(view);
			TweenMax.killTweensOf(title);
			TweenMax.killTweensOf(nextView);
			TweenMax.killTweensOf(prewViewPending);
			TweenMax.killTweensOf(nextViewPending);
			
			if (view != null)
			{
				view.dispose();
				view = null;
			}
			if (prewButton != null)
			{
				prewButton.dispose();
				prewButton = null;
			}
			if (buttonNext != null)
			{
				buttonNext.dispose();
				buttonNext = null;
			}
			if (nextView != null)
			{
				nextView.dispose();
				nextView = null;
			}
			if (tapper != null)
			{
				tapper.dispose();
				tapper = null;
			}
			if (title != null)
			{
				UI.destroy(title);
				title = null;
			}
			if (nextViewPending != null)
			{
				nextViewPending.dispose();
				nextViewPending = null;
			}
			if (prewViewPending != null)
			{
				prewViewPending.dispose();
				prewViewPending = null;
			}
		}
		
		public function getSelectedFirstDate():Date 
		{
			if (view != null)
			{
				return view.getSelectedFirstDate();
			}
			ApplicationErrors.add();
			return null;
		}
		
		public function getSelectedSecondDate():Date 
		{
			if (view != null)
			{
				return view.getSelectedSecondDate();
			}
			ApplicationErrors.add();
			return null;
		}
		
		public function getSelectedDate():Date 
		{
			if (view != null)
			{
				return view.getSelectedDate();
			}
			ApplicationErrors.add();
			return null;
		}
		
		public function animateShow():void 
		{
			return;
			
			var animationDistance:int = Config.FINGER_SIZE * .1;
			var animationTime:Number = 0.3;
			
			animate(title, animationDistance, animationTime, 0);
			animate(buttonNext, animationDistance, animationTime, 0);
			animate(prewButton, animationDistance, animationTime, 0);
			view.animateShow(animationDistance, animationTime);
		}
		
		public function markAnavaliableDays():void 
		{
			if (view != null)
			{
				view.markAnavaliableDays();
			}
		}
		
		public function selectFirstAvaliable():void 
		{
			if (allowAll == false && Calendar.viCalendar != null)
			{
				var booked:BookedDays = Calendar.viCalendar.getUnavaliableDays(currentMonth.year.toString() + "_" + currentMonth.monthIndex);
				if (booked != null)
				{
					var today:Date = new Date();
					for (var i:int = today.getDate(); i <= currentMonth.days; i++) 
					{
						if (booked.isBooked(i - 1) == false)
						{
							var date:Date = new Date();
							date.setDate(i);
							var ranges:DayBookData = Calendar.viCalendar.getFreeTimeRanges(date);
							if (ranges == null || (ranges.ranges != null && ranges.ranges.length > 0))
							{
								selectDay(i);
								return;
							}
						}
					}
				}
			}
		}
		
		public function allowAllDates(value:Boolean):void 
		{
			this.allowAll = value;
		}
		
		public function updateBounds():void 
		{
			if (tapper != null)
			{
				var point:Point = new Point(view.x, view.y);
				point = localToGlobal(point);
				tapper.setBounds([componentWidth, view.height, point.x, point.y]);
			}
		}
		
		public function getDateFrom():Date 
		{
			return rangeFirstDay;
		}
		
		public function getDateUntil():Date 
		{
			return rangeSecondDay;
		}
		
		public function setRange(dateFrom:Date, dateUntil:Date):void 
		{
			rangeFirstDay = dateFrom;
			rangeSecondDay = dateUntil;
			if (view != null)
			{
				view.selectRange(rangeFirstDay, rangeSecondDay);
			}
		}
		
		private function selectDay(index:int):void 
		{
			currentSelectedDate = new Date();
			currentSelectedDate.setDate(1);
			currentSelectedDate.setFullYear(currentMonth.year);
			currentSelectedDate.setMonth(currentMonth.monthIndex);
			currentSelectedDate.setDate(index);
			view.setSelected(currentSelectedDate);
		}
		
		private function animate(target:DisplayObject, animationDistance:int, animationTime:Number, delay:Number):void 
		{
			var targetPosition:int = target.y;
			target.y += animationDistance;
			target.alpha = 0;
			TweenMax.to(target, animationTime, {y:targetPosition, alpha:1, delay:delay});
		}
		
		private function drawCurrent():void 
		{
			view = new CalendarView(currentMonth, onDaySelected, currentSelectedDate, rangeFirstDay, rangeSecondDay);
			view.rangeSelection = rangeSelection;
			view.allowAllDates(allowAll);
			view.y = int(Config.FINGER_SIZE * .9);
			view.addEventListener(Event.ADDED_TO_STAGE, updateTapper);
			addChild(view);
			view.draw(componentWidth);
			addTapper();
			
			if (isActive)
			{
				activateView();
			}
		}
		
		private function onDaySelected():void 
		{
			if (_rangeSelection == true)
			{
				if (rangeFirstDay == null)
				{
					rangeFirstDay = getSelectedDate();
				}
				else if (rangeSecondDay == null)
				{
					var second:Date = getSelectedDate();
					if (second != null && rangeFirstDay.time > second.time)
					{
						rangeFirstDay = second;
					}
					else
					{
						rangeSecondDay = second;
					}
				}
				else
				{
					rangeFirstDay = getSelectedDate();
					rangeSecondDay = null;
				}
				view.selectRange(rangeFirstDay, rangeSecondDay);
				if (onSelect != null)
				{
					onSelect();
				}
			}
			else
			{
				currentSelectedDate = getSelectedDate();
			}
		}
		
		private function updateTapper(e:Event):void 
		{
			var point:Point = new Point(view.x, view.y);
			point = localToGlobal(point);
			
			if (view != null)
			{
				view.removeEventListener(Event.ADDED_TO_STAGE, updateTapper);
				
				if (tapper != null)
				{
					tapper.setBounds([componentWidth, view.height, point.x, point.y]);
				}
			}
		}
		
		private function addTapper():void 
		{
			if (tapper != null)
			{
			//	tapper.setDownCallback(null);
			//	tapper.setUpCallback(null);
				tapper.dispose();
				tapper = null;
			}
			
			var point:Point = new Point(view.x, view.y);
			point = localToGlobal(point);
			tapper = new TapperInstance(MobileGui.stage, view, onMoved, [componentWidth, view.height, point.x, point.y], "x");
			tapper.setDownCallback(onDown);
			tapper.setUpCallback(onUp);
		}
		
		private function onUp(e:Event = null):void 
		{
			touchExistValue = false;
		}
		
		private function onDown():void 
		{
			touchExistValue = true;
		}
		
		public function get rangeSelection():Boolean 
		{
			return _rangeSelection;
		}
		
		public function set rangeSelection(value:Boolean):void 
		{
			_rangeSelection = value;
			if (view != null)
			{
				view.rangeSelection = _rangeSelection;
			}
		}
	}
}