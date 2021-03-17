package com.dukascopy.connect.screens.dialogs.calendar
{
	import assets.PassportIllustration;
	import assets.PassportMrzZoneAnimation;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.scrollPanel.ScrollPanel;
	import com.dukascopy.connect.gui.tools.HorizontalPreloader;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.serviceScreen.Overlay;
	import com.dukascopy.connect.sys.calendar.Calendar;
	import com.dukascopy.connect.sys.calendar.DayBookData;
	import com.dukascopy.connect.sys.calendar.Month;
	import com.dukascopy.connect.sys.calendar.TimeRange;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.mrz.MrzBridge;
	import com.dukascopy.connect.sys.mrz.MrzResult;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	
	public class SelectDatePopup extends BaseScreen
	{
		protected var container:Sprite;
		private var bg:Shape;
		private var title:Bitmap;
		private var componentsWidth:Number;
		private var nextButton:BitmapButton;
		private var padding:int;
		private var calendarView:DatePicker;
		private var calendarMask:Sprite;
		private var firstTime:Boolean;
		private var content:Sprite;
		private var callback:Function;
		private var allowAllDates:Boolean;
		
		public function SelectDatePopup()
		{
			
		}
		
		override protected function createView():void
		{
			super.createView();
			
			if (data != null && "callback" in data && data.callback != null && data.callback is Function)
			{
				callback = data.callback as Function;
			}
			
			container = new Sprite();
			content = new Sprite();
			
			bg = new Shape();
			container.addChild(bg);
			
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
			
			calendarView.mask = calendarMask;
			
			_view.addChild(container);
			container.addChild(content);
		}
		
		private function nextClick():void
		{
			if (callback != null)
			{
				callback(calendarView.getSelectedDate());
			}
			DialogManager.closeDialog();
		}
		
		override public function clearView():void
		{
			super.clearView();
		}
		
		override public function initScreen(data:Object = null):void
		{
			super.initScreen(data);
			
			if (data != null && "callback" in data && data.callback != null && data.callback is Function)
			{
				callback = data.callback as Function;
			}
			
			if (data != null && "allowAllDates" in data && data.allowAllDates != null)
			{
				allowAllDates = data.allowAllDates;
			}
			
			padding = Config.DIALOG_MARGIN;
			
			componentsWidth = _width - padding * 2;
			
			calendarView.allowAllDates(allowAllDates);
			
			drawTitle(Lang.selectDate);
			drawCalendar();
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
			calendarMask.height = calendarView.height + Config.FINGER_SIZE * 1.5;
			
			position += calendarView.height;
			position += padding + Config.FINGER_SIZE * .6;
			
			nextButton.y = position;
			position += nextButton.height + Config.FINGER_SIZE * .3;
			
			nextButton.x = int(_width * .5 - nextButton.width * .5);
			
			var bdDrawPosition:int = title.y + title.height + Config.FINGER_SIZE * .3;
			
			bg.graphics.clear();
			bg.graphics.beginFill(0xD9E5F0);
			bg.graphics.drawRect(0, 0, _width, bdDrawPosition);
			bg.graphics.endFill();
			
			bg.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			bg.graphics.drawRect(0, bdDrawPosition, _width, position - bdDrawPosition);
			bg.graphics.endFill();
			
			container.y = int(_height - position);
			
			selectFirstAvaliable();
		}
		
		private function selectFirstAvaliable():void 
		{
			calendarView.selectFirstAvaliable();
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
			
			nextButton.activate();
			
			if (calendarView != null && calendarView.visible == true)
			{
				calendarView.activate();
			}
		}
		
		override public function deactivateScreen():void
		{
			if (_isDisposed == true)
				return;
			
			super.deactivateScreen();
			nextButton.deactivate();
			calendarView.deactivate();
			
			if (calendarView != null)
			{
				calendarView.deactivate();
			}
		}
		
		override public function dispose():void
		{
			Overlay.removeCurrent();
			
			callback = null;
			
			if (_isDisposed == true)
				return;
			super.dispose();
			
			if (nextButton != null)
			{
				nextButton.dispose();
				nextButton = null;
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
			if (calendarView != null)
			{
				calendarView.dispose();
				calendarView = null;
			}
		}
	}
}