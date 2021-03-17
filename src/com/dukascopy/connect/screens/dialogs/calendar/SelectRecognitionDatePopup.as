package com.dukascopy.connect.screens.dialogs.calendar
{
	import assets.RunIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.scrollPanel.ScrollPanel;
	import com.dukascopy.connect.gui.tools.HorizontalPreloader;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.dialogs.QueuePopup;
	import com.dukascopy.connect.screens.serviceScreen.Overlay;
	import com.dukascopy.connect.sys.calendar.Calendar;
	import com.dukascopy.connect.sys.calendar.DayBookData;
	import com.dukascopy.connect.sys.calendar.TimeRange;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	
	public class SelectRecognitionDatePopup extends BaseScreen
	{
		static public const STATE_CALENDAR:String = "stateCalendar";
		static public const STATE_TIME:String = "stateTime";
		static public const STATE_FINAL:String = "stateFinal";
		
		protected var container:Sprite;
		private var bg:Shape;
		private var title:Bitmap;
		private var componentsWidth:Number;
		private var nextButton:BitmapButton;
		private var padding:int;
		private var calendarView:DatePicker;
		private var calendarMask:Sprite;
		private var state:String;
		private var timeSelector:TimeSelector;
		private var datePanel:DateTimePanel;
		private var resultDescription:Bitmap;
		private var horizontalLoader:HorizontalPreloader;
		private var firstTime:Boolean;
		private var content:Sprite;
		private var locked:Boolean;
		private var resultScroll:ScrollPanel;
		private var backButton:BitmapButton;
		private var noSlots:Bitmap;
		
		public function SelectRecognitionDatePopup()
		{
			
		}
		
		override protected function createView():void
		{
			super.createView();
			
			container = new Sprite();
			content = new Sprite();
			
			bg = new Shape();
			container.addChild(bg);
			
			backButton = new BitmapButton();
			backButton.setStandartButtonParams();
			backButton.setDownScale(1);
			backButton.setDownColor(0);
			backButton.tapCallback = backClick;
			backButton.disposeBitmapOnDestroy = true;
			backButton.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
			container.addChild(backButton);
			
			nextButton = new BitmapButton();
			nextButton.setStandartButtonParams();
			nextButton.setDownScale(1);
			nextButton.setDownColor(0);
			nextButton.tapCallback = nextClick;
			nextButton.disposeBitmapOnDestroy = true;
			nextButton.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
			container.addChild(nextButton);
			
			title = new Bitmap();
			content.addChild(title);
			
			calendarView = new DatePicker();
			content.addChild(calendarView);
			
			calendarMask = new Sprite();
			calendarMask.graphics.beginFill(0);
			calendarMask.graphics.drawRect(0, 0, 10, 10);
			calendarMask.graphics.endFill();
			content.addChild(calendarMask);
			
			resultDescription = new Bitmap();
			
			calendarView.mask = calendarMask;
			
			horizontalLoader = new HorizontalPreloader(0xB3BDC6);
			content.addChild(horizontalLoader);
			
			_view.addChild(container);
			container.addChild(content);
			
			resultScroll = new ScrollPanel();
			container.addChild(resultScroll.view);
			resultScroll.addObject(resultDescription);
			resultScroll.view.visible = false;
			
			noSlots = new Bitmap();
			content.addChild(noSlots);
		}
		
		private function backClick():void {
			DialogManager.closeDialog();
			if (Config.FAST_TRACK == true)
			{
				ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_DIALOG, QueuePopup);
			}
		}
		
		private function drawBackButton():void
		{
			var textSettings:TextFieldSettings;
			var buttonBitmap:ImageBitmapData
			
			if (Config.FAST_TRACK == true)
			{
				textSettings = new TextFieldSettings("    " + Lang.fastTrack, 0x657280, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
				
				var icon:RunIcon = new RunIcon();
				UI.scaleToFit(icon, Config.FINGER_SIZE * .6, Config.FINGER_SIZE * .6);
				var iconBD:ImageBitmapData = UI.getSnapshot(icon);
				
				buttonBitmap = TextUtils.createbutton(textSettings, 0xFCFCFC, 1, Config.FINGER_SIZE * .8, 0xEDEDED, (componentsWidth - Config.MARGIN) * .5);
				
				buttonBitmap.copyPixels(iconBD, iconBD.rect, new Point(Config.FINGER_SIZE * .2, buttonBitmap.height * .5 - iconBD.height * .5), null, null, true);
				iconBD.dispose();
				backButton.setBitmapData(buttonBitmap, true);
			}
			else
			{
				textSettings = new TextFieldSettings(Lang.textBack, 0x657280, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
				buttonBitmap = TextUtils.createbutton(textSettings, 0xFCFCFC, 1, Config.FINGER_SIZE * .8, 0xEDEDED, (componentsWidth - Config.MARGIN) * .5);
				backButton.setBitmapData(buttonBitmap, true);
			}
		}
		
		private function nextClick():void
		{
			if (state == STATE_CALENDAR)
			{
				if (calendarView.getSelectedDate() != null)
				{
					showTimeState();
				}
			}
			else if (state == STATE_TIME)
			{
				if (timeSelector != null && timeSelector.hasData())
				{
					bookSelectedData();
				}
			}
			else
			{
				DialogManager.closeDialog();
			}
		}
		
		private function bookSelectedData():void 
		{
			nextButton.deactivate();
			locked = true;
			
			horizontalLoader.start();
			Calendar.S_APPOINTMENT_BOOK.add(onBookResponse);
			Calendar.S_APPOINTMENT_BOOK_FAIL.add(onBookResponseFail);
			Calendar.bookVIAppointment(datePanel.getDate(), timeSelector.getHours(), timeSelector.getMinutes());
		}
		
		private function onBookResponseFail():void 
		{
			Calendar.S_APPOINTMENT_BOOK_FAIL.remove(onBookResponseFail);
			Calendar.S_APPOINTMENT_BOOK.remove(onBookResponse);
			
			DialogManager.closeDialog();
		}
		
		private function onBookResponse(success:Boolean, errorString:String = null):void 
		{
			Calendar.S_APPOINTMENT_BOOK_FAIL.remove(onBookResponseFail);
			Calendar.S_APPOINTMENT_BOOK.remove(onBookResponse);
			horizontalLoader.stop();
			locked = false;
			if (isActivated)
			{
				nextButton.activate();
			}
			
			if (success == true)
			{
				showFinalState();
			}
			else
			{
				//!TODO:;
				ToastMessage.display(Lang.textError);
			}
		}
		
		private function showFinalState():void 
		{
			Overlay.removeCurrent();
			
			drawTitle(Lang.verificationTime);
			
			datePanel.y = title.y + title.height + Config.FINGER_SIZE * .4;
			
			drawNextButton(Lang.textOk);
			
			if (state == STATE_TIME)
			{
				hideTimeSelector();
			}
			
			var hours:TimeRange = timeSelector.getHours();
			var minutes:TimeRange = timeSelector.getMinutes();
			
			datePanel.draw(Calendar.viAppointmentData.date, componentsWidth, Calendar.viAppointmentData.hours, Calendar.viAppointmentData.minutes, true);
			
			drawResultDescription();
			
			
			resultDescription.x = padding;
			resultScroll.view.y = int(datePanel.y + datePanel.getHeight() + Config.FINGER_SIZE * .35);
			
			resultScroll.setWidthAndHeight(_width, nextButton.y - resultScroll.view.y - Config.FINGER_SIZE * .3);
			resultScroll.enable();
			resultScroll.view.visible = true;
			noSlots.visible = false;
			
			state = STATE_FINAL;
		}
		
		private function drawResultDescription():void 
		{
			if (resultDescription.bitmapData != null)
			{
				resultDescription.bitmapData.dispose();
				resultDescription.bitmapData = null;
			}
			
			resultDescription.bitmapData = TextUtils.createTextFieldData(
															Lang.VIScheduleDescription, componentsWidth, 10, true, 
															TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
															Config.FINGER_SIZE * .30, true, 0x8092A6, 0xFFFFFF, true, true);
		}
		
		private function hideTimeSelector():void 
		{
			if (timeSelector != null)
			{
				timeSelector.visible = false;
				timeSelector.deactivate();
			}
		}
		
		private function showTimeState():void 
		{
			noSlots.visible = false;
			Overlay.removeCurrent();
			
			if (state == STATE_CALENDAR)
			{
				calendarView.visible = false;
				calendarMask.visible = false;
				calendarView.deactivate();
			}
			
			resultScroll.view.visible = false;
			
			state = STATE_TIME;
			
			if (datePanel == null)
			{
				datePanel = new DateTimePanel(openCalendar);
				container.addChild(datePanel);
				
				datePanel.x = padding;
				datePanel.y = title.y + title.height + Config.FINGER_SIZE * .4;
			}
			datePanel.draw(calendarView.getSelectedDate(), componentsWidth);
			
			if (timeSelector == null)
			{
				timeSelector = new TimeSelector();
				
				timeSelector.x = padding;
				
				container.addChild(timeSelector);
			}
			
			if (isActivated)
			{
				timeSelector.activate();
				datePanel.activate();
			}
			
			drawTimeRanges();
			
			datePanel.visible = true;
			
			container.setChildIndex(datePanel, container.numChildren - 1);
			container.setChildIndex(nextButton, container.numChildren - 1);
			container.setChildIndex(backButton, container.numChildren - 1);
		}
		
		private function drawTimeRanges():void 
		{
			if (Calendar.viCalendar != null && Calendar.viCalendar.success == true)
			{
				var ranges:DayBookData = Calendar.viCalendar.getFreeTimeRanges(calendarView.getSelectedDate());
				
				if (ranges != null)
				{
					setRanges(ranges.ranges);
				}
				else
				{
					timeSelector.visible = false;
					timeSelector.deactivate();
					
					Calendar.viCalendar.loadRanges(calendarView.getSelectedDate());
					Calendar.S_DAY_RANGES.add(onDayRangesLoaded);
					horizontalLoader.start();
				}
			}
		}
		
		private function setRanges(ranges:Vector.<TimeRange>):void 
		{
			timeSelector.draw(ranges, componentsWidth);
			
			timeSelector.y = int(Math.min(
											datePanel.y + datePanel.getHeight() + (nextButton.y - datePanel.y - datePanel.getHeight()) * .5 - timeSelector.getHeight() * .5, 
											nextButton.y - Config.MARGIN - timeSelector.getHeight()));
			timeSelector.visible = true;
			
			if (isActivated == true && timeSelector != null)
			{
				timeSelector.activate();
			}
			
			if (ranges == null || ranges.length == 0)
			{
				timeSelector.visible = false;
				timeSelector.deactivate();
				
				showNoSlotsText();
			}
		}
		
		private function showNoSlotsText():void 
		{
			if (noSlots.bitmapData == null)
			{
				noSlots.bitmapData = TextUtils.createTextFieldData(
															Lang.noFreeSlots, _width - Config.FINGER_SIZE * 2, 10, true, 
															TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
															Config.FINGER_SIZE * .34, true, 0x47515B, 0xFFFFFF, true);
			}
			noSlots.visible = true;
			noSlots.x = int(_width * .5 - noSlots.width * .5);
			noSlots.y = int(datePanel.y + Config.FINGER_SIZE * 2);
		}
		
		private function onDayRangesLoaded(date:Date):void 
		{
			Calendar.S_DAY_RANGES.remove(onDayRangesLoaded);
			if (_isDisposed == true)
			{
				return;
			}
			horizontalLoader.stop();
			
			var ranges:DayBookData = Calendar.viCalendar.getFreeTimeRanges(calendarView.getSelectedDate());
			
			if (ranges != null)
			{
				setRanges(ranges.ranges);
			}
			else
			{
				var currentSelected:Date = calendarView.getSelectedDate();
				if (calendarView.getSelectedDate().getFullYear() == date.getFullYear() && calendarView.getSelectedDate().getMonth() == date.getMonth() && calendarView.getSelectedDate().getDate() == date.getDate())
				{
					showCalendarState();
				}
			}
		}
		
		private function openCalendar():void 
		{
			showCalendarState();
		}
		
		private function showCalendarState():void 
		{
			drawTitle(Lang.chooseVerificationDay);
			
			Overlay.removeCurrent();
			
			resultScroll.view.visible = false;
			noSlots.visible = false;
			
			if (state == STATE_TIME)
			{
				datePanel.visible = false;
				timeSelector.clear();
				timeSelector.visible = false;
				timeSelector.deactivate();
				datePanel.deactivate();
			}
			
			if (isActivated)
			{
				calendarView.activate();
			}
			
			state = STATE_CALENDAR;
			
			calendarView.visible = true;
			calendarMask.visible = true;
			
			calendarView.alpha = 0;
			TweenMax.to(calendarView, 0.3, {alpha:1});
		}
		
		override public function clearView():void
		{
			super.clearView();
		}
		
		override public function initScreen(data:Object = null):void
		{
			super.initScreen(data);
			
			padding = Config.DIALOG_MARGIN;
			
			componentsWidth = _width - padding * 2;
			
			drawTitle(Lang.chooseVerificationDay);
			drawCalendar();
			animateCalendar();
			drawBackButton();
			drawNextButton(Lang.textNext);
			
			var position:int = Config.FINGER_SIZE * .35;
			
			title.x = padding;
			title.y = position;
			position += title.height + Config.FINGER_SIZE * .75;
			
			calendarView.x = int(_width * .5 - calendarView.getWidth() * .5);
			calendarView.y = position;
			
			calendarMask.x = 0;
			calendarMask.y = calendarView.y - Config.FINGER_SIZE * .5;
			calendarMask.width = _width;
			calendarMask.height = calendarView.height + Config.FINGER_SIZE;
			
			position += calendarView.height;
			position += padding;
			
			nextButton.y = position;
			backButton.y = position;
			position += nextButton.height + Config.FINGER_SIZE * .3;
			
			backButton.x = padding;
			nextButton.x = int(backButton.x + backButton.width + Config.MARGIN);
			
			var bdDrawPosition:int = title.y + title.height + Config.FINGER_SIZE * .3;
			
			bg.graphics.clear();
			bg.graphics.beginFill(0xD9E5F0);
			bg.graphics.drawRect(0, 0, _width, bdDrawPosition);
			bg.graphics.endFill();
			
			bg.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			bg.graphics.drawRect(0, bdDrawPosition, _width, position - bdDrawPosition);
			bg.graphics.endFill();
			
			container.y = int(_height - position);
			
			state = STATE_CALENDAR;
			
			horizontalLoader.setSize(_width, int(Config.FINGER_SIZE * .06));
			horizontalLoader.y = bdDrawPosition;
			
			if (Calendar.viCalendar == null || Calendar.viCalendar.ready == false)
			{
				listenMainData();
			}
			else
			{
				onCalendarDataReady();
			}
		}
		
		private function listenMainData():void 
		{
			Calendar.S_CALENDAR_VI_READY.add(onCalendarDataReady);
			Calendar.loadClosedRecognitionCalendar();
			horizontalLoader.start();
		}
		
		private function onCalendarDataReady():void 
		{
			horizontalLoader.stop();
			Calendar.S_CALENDAR_VI_READY.remove(onCalendarDataReady);
			if (Calendar.viCalendar != null && Calendar.viCalendar.success == true)
			{
				if (_isActivated == true)
				{
					nextButton.activate();
					calendarView.activate();
				}
				markUnavaliableDays();
				selectFirstAvaliable();
			}
		}
		
		private function markUnavaliableDays():void 
		{
			if (calendarView != null)
			{
				calendarView.markAnavaliableDays();
			}
		}
		
		private function selectFirstAvaliable():void 
		{
			calendarView.selectFirstAvaliable();
		}
		
		private function animateCalendar():void 
		{
			if (calendarView != null)
			{
				calendarView.animateShow();
			}
		}
		
		private function drawCalendar():void 
		{
			calendarView.draw(Math.min(componentsWidth, Config.FINGER_SIZE * 5.3));
		}
		
		private function drawNextButton(text:String):void
		{
			var textSettings:TextFieldSettings = new TextFieldSettings(text, 0xFFFFFF, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, Color.GREEN, 1, Config.FINGER_SIZE * .8, NaN, (componentsWidth - Config.MARGIN) * .5);
			nextButton.setBitmapData(buttonBitmap, true);
		}
		
		private function drawTitle(text:String, maxWidth:Number = NaN):void
		{
			var maxTextWidth:Number = maxWidth;
			if (isNaN(maxTextWidth))
			{
				maxTextWidth = componentsWidth;
			}
			
			if (title.bitmapData != null)
			{
				title.bitmapData.dispose();
				title.bitmapData = null;
			}
			
			title.bitmapData = TextUtils.createTextFieldData(
															text, maxTextWidth, 10, true, 
															TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
															Config.FINGER_SIZE * .34, true, 0x47515B, 0xFFFFFF, true);
			
			var bdDrawPosition:int = title.y + title.height + Config.FINGER_SIZE * .3;
			
			var h:int = bg.height;
			
			bg.graphics.clear();
			bg.graphics.beginFill(0xD9E5F0);
			bg.graphics.drawRect(0, 0, _width, bdDrawPosition);
			bg.graphics.endFill();
			
			bg.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			bg.graphics.drawRect(0, bdDrawPosition, _width, h - bdDrawPosition);
			bg.graphics.endFill();
		}
		
		override protected function drawView():void
		{
			if (_isDisposed == true)
				return;
		}
		
		override public function activateScreen():void
		{
			if (_isDisposed == true)
				return;
			
			super.activateScreen();
			
			if (state != STATE_CALENDAR || (Calendar.viCalendar != null && Calendar.viCalendar.ready == true && Calendar.viCalendar.success == true))
			{
				nextButton.activate();
			}
			
			backButton.activate();
			
			if (calendarView != null && calendarView.visible == true)
			{
				calendarView.activate();
			}
			
			if (timeSelector != null && timeSelector.visible == true)
			{
				timeSelector.activate();
			}
			
			if (datePanel != null)
			{
				datePanel.activate();
			}
			
			if (firstTime == false)
			{
				firstTime = true;
				
				bg.alpha = 0;
				TweenMax.to(bg, 0.3, {alpha:1});
				
				content.alpha = 0;
				TweenMax.to(content, 0.3, {alpha:1, delay:0.15});
			}
			
			if (state == STATE_FINAL && resultScroll != null)
			{
				resultScroll.enable();
			}
		}
		
		override public function deactivateScreen():void
		{
			if (_isDisposed == true)
				return;
			
			super.deactivateScreen();
			nextButton.deactivate();
			calendarView.deactivate();
			
			backButton.deactivate();
			
			if (calendarView != null)
			{
				calendarView.deactivate();
			}
			
			if (timeSelector != null)
			{
				timeSelector.deactivate();
			}
			
			if (datePanel != null)
			{
				datePanel.deactivate();
			}
			if (resultScroll != null)
			{
				resultScroll.disable();
			}
		}
		
		override public function dispose():void
		{
			Calendar.S_DAY_RANGES.remove(onDayRangesLoaded);
			Calendar.S_CALENDAR_VI_READY.remove(onCalendarDataReady);
			Calendar.S_APPOINTMENT_BOOK.remove(onBookResponse);
			Overlay.removeCurrent();
			
			Calendar.S_APPOINTMENT_BOOK_FAIL.remove(onBookResponseFail);
			
			if (_isDisposed == true)
				return;
			super.dispose();
			
			if (nextButton != null)
			{
				nextButton.dispose();
				nextButton = null;
			}
			if (backButton != null)
			{
				backButton.dispose();
				backButton = null;
			}
			if (container != null)
			{
				UI.destroy(container);
				container = null;
			}
			if (bg != null)
			{
				UI.destroy(bg);
				bg = null;
			}
			if (noSlots != null)
			{
				UI.destroy(noSlots);
				noSlots = null;
			}
			if (title != null)
			{
				UI.destroy(title);
				title = null;
			}
			if (calendarMask != null)
			{
				UI.destroy(calendarMask);
				calendarMask = null;
			}
			if (resultDescription != null)
			{
				UI.destroy(resultDescription);
				resultDescription = null;
			}
			if (resultScroll != null)
			{
				resultScroll.dispose()
				resultScroll = null;
			}
			if (calendarView != null)
			{
				calendarView.dispose();
				calendarView = null;
			}
			if (timeSelector != null)
			{
				timeSelector.dispose();
				timeSelector = null;
			}
			if (datePanel != null)
			{
				datePanel.dispose();
				datePanel = null;
			}
		}
	}
}