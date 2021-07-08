package com.dukascopy.connect.screens.serviceScreen {
	
	import assets.CalendarIcon2;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.PopupData;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.dialogs.calendar.SelectDatePopup;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.DateUtils;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import com.greensock.easing.Power2;
	import flash.display.Bitmap;
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
	
	public class BottomTimeSelectionScreen extends BaseScreen {
		
		private var background:Sprite;
		private var nextButton:BitmapButton;
		private var screenData:PopupData;
		private var title:Bitmap;
		private var titleTo:Bitmap;
		private var titleFrom:Bitmap;
		private var container:Sprite;
		private var firstTime:Boolean = true;
		private var needExecute:Boolean;
		private var fromButton:BitmapButton;
		private var toButton:BitmapButton;
		private var currentToTime:Number;
		private var currentFromTime:Number;
		
		public function BottomTimeSelectionScreen() { }
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			if (data != null && data is PopupData) {
				screenData = data as PopupData;
			} else {
				ServiceScreenManager.closeView();
				return;
			}
			_params.doDisposeAfterClose = true;
			background.graphics.beginFill(0x000000, 0.35);
			background.graphics.drawRect(0, 0, _width, _height);
			createButton();
			createTitle();
			createFromTitle();
			createToTitle();
			createFromButton();
			createToButton();
			setTo((new Date()).getTime());
			var startDate:Date = new Date();
			startDate.setHours(0);
			startDate.setMinutes(0);
			startDate.setSeconds(0);
			startDate.setMilliseconds(0);
			startDate.setMonth(startDate.getMonth() - 1);
			setFrom(startDate.getTime());
			var position:int = Config.FINGER_SIZE * .4;
			if (title.height > 0) {
				title.y = position;
				position += title.height + Config.FINGER_SIZE * .5;
			}
			title.x = int(Config.FINGER_SIZE * .4);
			
			titleTo.x = title.x;
			titleFrom.x = title.x;
			
			updateSelectorPositions();
			
			fromButton.y = position;
			position += fromButton.height + Config.FINGER_SIZE * .3;
			
			toButton.y = position;
			position += toButton.height + Config.FINGER_SIZE * .5;
			
			titleFrom.y = int(fromButton.y  + fromButton.height * .5 - titleFrom.height * .5);
			titleTo.y = int(toButton.y  + toButton.height * .5 - titleTo.height * .5);
			
			nextButton.y = position;
			nextButton.x = int(_width * .5 - nextButton.width * .5);
			position += nextButton.height + Config.FINGER_SIZE * .6;
			position += Config.APPLE_BOTTOM_OFFSET;
			container.graphics.beginFill(0xFFFFFF);
			var startPosition:int = 0;
			
			container.graphics.drawRect(0, startPosition, _width, position);
			container.graphics.endFill();
			container.y = _height;
			background.alpha = 0;
		}
		
		private function updateSelectorPositions():void 
		{
			var itemsWidth:int = Math.max(fromButton.width, toButton.width);
			var position:int = int(_width * .5 - itemsWidth * .5);
			position = Math.max(position, Math.max(titleFrom.x + titleFrom.width  + Config.FINGER_SIZE * .2, titleTo.x + titleTo.width  + Config.FINGER_SIZE * .2));
			fromButton.x = position;
			toButton.x = position;
		}
		
		private function setFrom(time:Number):void 
		{
			currentFromTime = time;
			drawTime(currentFromTime, fromButton);
		}
		
		private function setTo(time:Number):void 
		{
			currentToTime = time;
			drawTime(currentToTime, toButton);
		}
		
		private function drawTime(time:Number, button:BitmapButton):void 
		{
			if (isDisposed)
			{
				return;
			}
			var date:Date = new Date(time);
			var text:String = DateUtils.getComfortDateRepresentationOnlyDate(date, true);
			var icon:CalendarIcon2 = new CalendarIcon2();
			UI.scaleToFit(icon, int(Config.FINGER_SIZE * .4), int(Config.FINGER_SIZE * .4));
			var textBitmapData:ImageBitmapData = TextUtils.createTextFieldData(text, _width - icon.width - Config.FINGER_SIZE * 2, 
																				10, true, TextFormatAlign.CENTER, 
																				TextFieldAutoSize.LEFT, Config.FINGER_SIZE*.35, true, Color.GREY_DARK);
			
			var buttonBD:ImageBitmapData = new ImageBitmapData("date", int(textBitmapData.width + icon.width + Config.FINGER_SIZE * .3), Math.max(icon.height, textBitmapData.height + Config.FINGER_SIZE * .2));
			var iconBD:ImageBitmapData = UI.getSnapshot(icon);
			buttonBD.copyPixels(iconBD, iconBD.rect, new Point(int(0), int(buttonBD.height * .5 - iconBD.height * .5)), null, null, true);
			buttonBD.copyPixels(textBitmapData, textBitmapData.rect, new Point(int(iconBD.width + Config.FINGER_SIZE*.25), int(buttonBD.height * .5 - textBitmapData.height * .5)), null, null, true);
			
			textBitmapData.dispose();
			iconBD.dispose();
			
			textBitmapData = null;
			iconBD = null;
			
			UI.destroy(icon);
			
			button.setBitmapData(buttonBD, true);
			
			var itemsWidth:int = Math.max(fromButton.width, toButton.width);
			
			updateSelectorPositions();
		}
		
		private function createToButton():void 
		{
			toButton = new BitmapButton();
			toButton.setStandartButtonParams();
			toButton.setDownScale(1);
			toButton.setDownColor(0);
			toButton.tapCallback = toClick;
			toButton.disposeBitmapOnDestroy = true;
			toButton.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
			container.addChild(toButton);
		}
		
		private function toClick():void 
		{
			DialogManager.showDialog(SelectDatePopup, {callback:onToSelected, allowAllDates:true});
		}
		
		private function onToSelected(date:Date):void 
		{
			if (date != null)
			{
				setTo(date.getTime());
			}
		}
		
		private function createFromButton():void 
		{
			fromButton = new BitmapButton();
			fromButton.setStandartButtonParams();
			fromButton.setDownScale(1);
			fromButton.setDownColor(0);
			fromButton.tapCallback = fromClick;
			fromButton.disposeBitmapOnDestroy = true;
			fromButton.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
			container.addChild(fromButton);
		}
		
		private function fromClick():void 
		{
			DialogManager.showDialog(SelectDatePopup, {callback:onFromSelected, allowAllDates:true});
		}
		
		private function onFromSelected(date:Date):void 
		{
			if (date != null)
			{
				setFrom(date.getTime());
			}
		}
		
		private function createTitle():void {
			if (screenData.title != null) {
				title.bitmapData = TextUtils.createTextFieldData(
					screenData.title,
					_width - Config.DIALOG_MARGIN * 4,
					10,
					true,
					TextFormatAlign.CENTER,
					TextFieldAutoSize.LEFT,
					int(Config.FINGER_SIZE * .35),
					true,
					Style.color(Style.COLOR_TITLE),
					Style.color(Style.COLOR_BACKGROUND)
				);
			}
		}
		
		private function createFromTitle():void {
			titleFrom.bitmapData = TextUtils.createTextFieldData(
				Lang.textFrom + ":",
				_width - Config.DIALOG_MARGIN * 4,
				10,
				true,
				TextFormatAlign.CENTER,
				TextFieldAutoSize.LEFT,
				int(Config.FINGER_SIZE * .35),
				true,
				Color.RED,
				Style.color(Style.COLOR_BACKGROUND)
			);
		}
		
		private function createToTitle():void {
			titleTo.bitmapData = TextUtils.createTextFieldData(
				Lang.textTo + ":",
				_width - Config.DIALOG_MARGIN * 4,
				10,
				true,
				TextFormatAlign.CENTER,
				TextFieldAutoSize.LEFT,
				int(Config.FINGER_SIZE * .35),
				true,
				Color.RED,
				Style.color(Style.COLOR_BACKGROUND)
			);
		}
		
		private function createButton():void {
			var text:String;
			if (screenData.action != null && screenData.action.getData() != null && screenData.action.getData() is String) {
				text = screenData.action.getData() as String;
			} else {
				text = Lang.select;
			}
			var textSettings:TextFieldSettings = new TextFieldSettings(text, Color.WHITE, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, Color.GREEN, 1, Config.FINGER_SIZE * .8, NaN);
			nextButton.setBitmapData(buttonBitmap);
		}
		
		override protected function createView():void {
			super.createView();
			
			background = new Sprite();
			view.addChild(background);
			
			container = new Sprite();
			view.addChild(container);
			
			nextButton = new BitmapButton();
			nextButton.setStandartButtonParams();
			nextButton.setDownScale(1);
			nextButton.setDownColor(0);
			nextButton.tapCallback = nextClick;
			nextButton.disposeBitmapOnDestroy = true;
			container.addChild(nextButton);
			
			title = new Bitmap();
			container.addChild(title);
			
			titleFrom = new Bitmap();
			container.addChild(titleFrom);
			
			titleTo = new Bitmap();
			container.addChild(titleTo);
		}
		
		private function nextClick():void {
			if (screenData != null && screenData.callback != null)
			{
				var time:Object = new Object();
				var currentDate:Date = new Date(currentFromTime);
				currentDate.setHours(0);
				currentDate.setMinutes(0);
				currentDate.setSeconds(0);
				currentDate.setMilliseconds(0);
				time.dateFrom = currentDate;
				
				var timeTo:Date = new Date(currentToTime);
				if (timeTo.getHours() == 0 && timeTo.getMinutes() == 0 && timeTo.getSeconds() == 0)
				{
					timeTo.setSeconds(timeTo.getSeconds() - 1);
					timeTo.setDate(timeTo.getDate() + 1);
				}
				
				time.dateTo = timeTo;
				
				if (screenData.callback.length == 3)
				{
					screenData.callback(1, screenData.data, time);
				}
				
				screenData.callback = null;
			}
			else{
				needExecute = true;
			}
			
			close();
		}
		
		override protected function drawView():void {
			super.drawView();
			view.graphics.clear();
		}
		
		override public function clearView():void {
			super.clearView();
		}
		
		override public function dispose():void {
			super.dispose();
			TweenMax.killTweensOf(container);
			TweenMax.killTweensOf(background);
			if (background != null)
				UI.destroy(background);
			background = null;
			if (nextButton != null)
				nextButton.dispose();
			nextButton = null;
			if (fromButton != null)
				fromButton.dispose();
			fromButton = null;
			if (toButton != null)
				toButton.dispose();
			toButton = null;
			if (title != null)
				UI.destroy(title);
			title = null;
			if (titleFrom != null)
				UI.destroy(titleFrom);
			titleFrom = null;
			if (titleTo != null)
				UI.destroy(titleTo);
			titleTo = null;
			if (container != null)
				UI.destroy(container);
			container = null;
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			if (_isDisposed) {
				return;
			}
			if (firstTime) {
				firstTime = false;
				TweenMax.to(container, 0.3, { y:int(_height - container.height), ease:Power2.easeOut } );
				TweenMax.to(background, 0.3, { alpha:1 } );
			}
			fromButton.activate();
			toButton.activate();
			PointerManager.addTap(background, callClose);
			nextButton.activate();
		}
		
		private function callClose(e:Event = null):void 
		{
			if (screenData != null && screenData.callback != null)
			{
				if (screenData.callback.length == 3)
				{
					screenData.callback(0, screenData.data, null);
				}
				
				screenData.callback = null;
			}
			close();
		}
		
		private function close(e:Event = null):void {
			deactivateScreen();
			TweenMax.to(container, 0.3, { y:_height, onComplete:remove, ease:Power2.easeIn } );
			TweenMax.to(background, 0.3, { alpha:0 } );
		}
		
		private function remove():void {
			ServiceScreenManager.closeView();
			if (needExecute == true && screenData.action != null) {
				needExecute = false;
				screenData.action.execute();
			}
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed) {
				return;
			}
			fromButton.deactivate();
			toButton.deactivate();
			PointerManager.removeTap(background, callClose);
			nextButton.deactivate();
		}
	}
}