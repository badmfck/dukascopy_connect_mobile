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
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	
	public class SelectTimePopup extends BaseScreen
	{
		protected var container:Sprite;
		private var bg:Shape;
		private var title:Bitmap;
		private var componentsWidth:Number;
		private var nextButton:BitmapButton;
		private var padding:int;
		private var content:Sprite;
		private var callback:Function;
		private var timeSelector:TimeSelector;
		private var currentExpirationDate:Date;
		private var backButton:BitmapButton;
		
		public function SelectTimePopup()
		{
			
		}
		
		override protected function createView():void
		{
			super.createView();
			
			container = new Sprite();
			content = new Sprite();
			
			bg = new Shape();
			container.addChild(bg);
			
			title = new Bitmap();
			content.addChild(title);
			
			timeSelector = new TimeSelector();
		//	timeSelector.unlinkSelectors();
			container.addChild(timeSelector);
			
			nextButton = new BitmapButton();
			nextButton.setStandartButtonParams();
			nextButton.setDownScale(1);
			nextButton.setDownColor(0);
			nextButton.tapCallback = nextClick;
			nextButton.disposeBitmapOnDestroy = true;
			nextButton.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
			container.addChild(nextButton);
			
			backButton = new BitmapButton();
			backButton.setStandartButtonParams();
			backButton.setDownScale(1);
			backButton.setDownColor(0);
			backButton.tapCallback = backClick;
			backButton.disposeBitmapOnDestroy = true;
			container.addChild(backButton);
			
			_view.addChild(container);
			container.addChild(content);
		}
		
		private function backClick():void
		{
			rejectPopup();
		}
		
		private function rejectPopup():void 
		{
			DialogManager.closeDialog();
		}
		
		private function nextClick():void
		{
			if (callback != null)
			{
				if (currentExpirationDate != null)
				{
					currentExpirationDate.setHours(timeSelector.getHours().value);
					currentExpirationDate.setMinutes(timeSelector.getMinutes().value);
				}
				callback(currentExpirationDate);
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
			
			if (data != null && "currentExpirationDate" in data && data.currentExpirationDate != null && data.currentExpirationDate is Date)
			{
				currentExpirationDate = data.currentExpirationDate as Date;
			}
			
			padding = Config.DIALOG_MARGIN;
			
			componentsWidth = _width - padding * 2;
			
			drawTitle(Lang.selectTime);
			drawTime();
			drawNextButton(Lang.textNext);
			drawBackButton();
			
			var position:int = Config.FINGER_SIZE * .35;
			
			title.x = padding;
			title.y = position;
			position += title.height + Config.FINGER_SIZE * .75 + Config.FINGER_SIZE * .4;
			
			timeSelector.x = padding;
			timeSelector.y = position;
			
			position += timeSelector.height;
			position += padding;
			
			nextButton.y = position;
			backButton.y = position;
			position += nextButton.height + Config.FINGER_SIZE * .3;
			
			backButton.x = Config.DIALOG_MARGIN;
			nextButton.x = backButton.x + backButton.width + Config.MARGIN;
			
			var bdDrawPosition:int = title.y + title.height + Config.FINGER_SIZE * .3;
			
			bg.graphics.clear();
			bg.graphics.beginFill(0xD9E5F0);
			bg.graphics.drawRect(0, 0, _width, bdDrawPosition);
			bg.graphics.endFill();
			
			bg.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			bg.graphics.drawRect(0, bdDrawPosition, _width, position - bdDrawPosition);
			bg.graphics.endFill();
			
			container.y = int(_height - position);
		}
		
		private function drawBackButton():void
		{
			var textSettings:TextFieldSettings = new TextFieldSettings(Lang.textBack, 0x657280, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, 0xFFFFFF, 1, Config.FINGER_SIZE * .8, NaN, (componentsWidth - Config.MARGIN) * .5);
			backButton.setBitmapData(buttonBitmap, true);
		}
		
		private function drawTime():void 
		{
			var date:Date = new Date();
			var ranges:Vector.<TimeRange> = new Vector.<com.dukascopy.connect.sys.calendar.TimeRange>();
			var rangeHour:TimeRange;
			var rangeMinute:TimeRange;
			
			var startHour:int = 0;
			var startMinute:int = 0;
			
			if (date.getFullYear() == currentExpirationDate.getFullYear() && 
				date.getMonth() == currentExpirationDate.getMonth() &&
				date.getDate() == currentExpirationDate.getDate())
			{
				startHour = currentExpirationDate.getHours();
				startMinute = currentExpirationDate.getMinutes();
			}
			
			var startMinutesValue:int;
			
			for (var i:int = startHour; i < 24; i++) 
			{
				rangeHour = new TimeRange(i, 1);
				
				if (i == startHour)
				{
					startMinutesValue = startMinute;
				}
				else
				{
					startMinutesValue = 0;
				}
				
				for (var j:int = startMinutesValue; j < 60; j++) 
				{
					rangeMinute = new TimeRange(j, 1);
					rangeHour.addSubrange(rangeMinute);
				}
				ranges.push(rangeHour);
			}
			
			timeSelector.draw(ranges, componentsWidth);
			timeSelector.select(currentExpirationDate.getHours(), currentExpirationDate.getMinutes());
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
			backButton.activate();
			
			timeSelector.activate();
		}
		
		override public function deactivateScreen():void
		{
			if (_isDisposed == true)
				return;
			
			super.deactivateScreen();
			
			nextButton.deactivate();
			backButton.deactivate();
			
			timeSelector.deactivate();
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
			if (title != null)
			{
				UI.destroy(title);
				title = null;
			}
			if (timeSelector != null)
			{
				timeSelector.dispose();
				timeSelector = null;
			}
		}
	}
}