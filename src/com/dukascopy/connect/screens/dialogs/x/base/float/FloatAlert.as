package com.dukascopy.connect.screens.dialogs.x.base.float {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.AlertScreenData;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.screens.dialogs.x.base.float.FloatPopup;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin.
	 */

	public class FloatAlert extends FloatPopup {
		
		private var nextButton:BitmapButton;
		
		private var title:Bitmap;
		private var description:Bitmap;
		private var illustration:Bitmap;
		protected var screenData:AlertScreenData;
		
		public function FloatAlert() { }
		
		override protected function createView():void {
			super.createView();
			
			createNextButton();
			
			illustration = new Bitmap();
			addItem(illustration);
			
			description = new Bitmap();
			addItem(description);
			
			title = new Bitmap();
			addItem(title);
		}
		
		override public function onBack(e:Event = null):void {
			needCallback = false;
			
			close();
		}
		
		private function createNextButton():void 
		{
			nextButton = new BitmapButton();
			nextButton.setStandartButtonParams();
			nextButton.tapCallback = onNextClick;
			nextButton.disposeBitmapOnDestroy = true;
			nextButton.setDownScale(1);
			nextButton.setOverlay(HitZoneType.BUTTON);
			addItem(nextButton);
		}
		
		protected function onNextClick():void 
		{
			needCallback = true;
			
			close();
		}
		
		override public function initScreen(data:Object = null):void {
			screenData = data as AlertScreenData;
			super.initScreen(data);
		}
		
		override protected function drawContent():void 
		{
			drawIllustration();
			drawText();
			drawControls();
		}
		
		private function drawIllustration():void 
		{
			if (screenData != null && screenData.icon != null)
			{
				var icon:Sprite = new screenData.icon();
				if (icon != null)
				{
					var iconSize:int = Config.FINGER_SIZE * 1;
					UI.scaleToFit(icon, iconSize, iconSize);
					UI.colorize(icon, screenData.iconColor);
					illustration.bitmapData = UI.getSnapshot(icon);
					icon = null;
				}
			}
		}
		
		private function drawText():void 
		{
			if (screenData != null && screenData.text != null)
			{
				description.bitmapData = TextUtils.createTextFieldData(screenData.text, getWidth() - contentPadding * 2, 10, true,
																	TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
																	FontSize.BODY, true, getTextColor(),
																	Style.color(Style.COLOR_BACKGROUND), false, true);
			}
			if (screenData != null && screenData.title != null)
			{
				title.bitmapData = TextUtils.createTextFieldData(screenData.title, getWidth() - contentPadding * 4, 10, true,
																	TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
																	FontSize.TITLE_3, true, Style.color(Style.COLOR_TEXT),
																	Style.color(Style.COLOR_BACKGROUND), false);
			}
		}
		
		private function getTextColor():uint 
		{
			if (!isNaN(screenData.textColor))
			{
				return screenData.textColor;
			}
			return Style.color(Style.COLOR_TEXT);
		}
		
		override protected function updateContentPositions():void 
		{
			var position:int = 0;
			
			if (screenData.icon != null)
			{
				illustration.x = int(getWidth() * .5 - illustration.width * .5);
				illustration.y = position;
				position += illustration.height + contentPaddingV * 2.5;
			}
			if (screenData.title != null)
			{
				title.x = int(getWidth() * .5 - title.width * .5);
				title.y = position;
				position += title.height + contentPaddingV * 2.5;
			}
			
			if (position == 0)
			{
				position += contentPaddingV;
			}
			
			description.x = contentPadding;
			description.y = position;
			position += description.height + contentPaddingV * 2.5;
			
			nextButton.x = contentPadding;
			nextButton.y = position;
			position += nextButton.height + contentPaddingV;
		}
		
		private function drawControls():void
		{
			var buttonText:String = Lang.textOk;
			if (screenData != null && screenData.button != null)
			{
				buttonText = screenData.button;
			}
			var textSettings:TextFieldSettings = new TextFieldSettings(buttonText, Style.color(Style.COLOR_TEXT), FontSize.BODY, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, Style.color(Style.COLOR_BACKGROUND), 1, -1, Style.color(Style.COLOR_BUTTON_OUTLINE), getButtonWidth(), Style.size(Style.BUTTON_PADDING), Style.size(Style.SIZE_BUTTON_CORNER));
			nextButton.setBitmapData(buttonBitmap, true);
		}
		
		private function getButtonWidth():int 
		{
			return (getWidth() - contentPadding * 2);
		}
		
		override protected function drawView():void {
			if (_isDisposed == true)
				return;
			
			super.drawView();
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			if (_isDisposed) {
				return;
			}
			
			nextButton.activate();
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed) {
				return;
			}
			
			nextButton.deactivate();
		}
		
		override protected function onRemove():void 
		{
			if (needCallback)
			{
				if (screenData.callback != null)
				{
					if (screenData.callback.length == 0)
					{
						screenData.callback();
					}
					else if (screenData.callback.length == 1)
					{
						screenData.callback(screenData.callbackData);
					}
				}
			}
		}
		
		override public function dispose():void {
			super.dispose();
			
			if (nextButton != null)
			{
				nextButton.dispose();
				nextButton = null;
			}
			if (illustration != null)
			{
				UI.destroy(illustration);
				illustration = null;
			}
			if (description != null)
			{
				UI.destroy(description);
				description = null;
			}
			if (title != null)
			{
				UI.destroy(title);
				title = null;
			}
		}
	}
}