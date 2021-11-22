package com.dukascopy.connect.screens.dialogs.x.base.bottom 
{
	import assets.NewCloseIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.screens.dialogs.x.base.bottom.BottomPopup;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import flash.display.Bitmap;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class AnimatedTitlePopup extends BottomPopup
	{
		private var titleText:Bitmap;
		private var closeButton:BitmapButton;
		protected var contentPadding:int;
		protected var contentPaddingV:int;
		protected var headerHeight:int;
		
		public function AnimatedTitlePopup() 
		{
			
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			var titleWidth:int = (_width - contentPadding * 3 - closeButton.width);
			
			if (data != null && "title" in data && data.title != null)
			{
				titleText.bitmapData = TextUtils.createTextFieldData(data.title, titleWidth, 10, true, 
																	TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, 
																	FontSize.BODY, true, Style.color(Style.COLOR_TEXT),
																	Style.color(Style.COLOR_BACKGROUND), false);
			}
			
			headerHeight = Math.max(titleText.height, closeButton.height) + contentPaddingV * 2;
			
			titleText.x = int(_width * .5 - titleText.width * .5);
			titleText.y = int(Math.max(contentPaddingV, headerHeight * .5 - titleText.height * .5));
			
			closeButton.x = int(_width - contentPadding - closeButton.width);
			closeButton.y = contentPaddingV;
		}
		
		override protected function drawBack():void 
		{
			var radius:int = Config.FINGER_SIZE * .22;
			
			backgroundContent.graphics.beginFill(getHeaderColor());
			backgroundContent.graphics.drawRoundRectComplex(0, 0, _width, headerHeight, radius, radius, 0, 0);
			backgroundContent.graphics.endFill();
			
			backgroundContent.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			backgroundContent.graphics.drawRoundRectComplex(0, headerHeight, _width, getHeight() - headerHeight, 0, 0, 0, 0);
			backgroundContent.graphics.endFill();
		}
		
		private function getHeaderColor():uint 
		{
			if (data != null && "headerColor" in data && !isNaN(Number(data.headerColor)))
			{
				return Number(data.headerColor);
			}
			return Style.color(Style.COLOR_POPUP_HEADER);
		}
		
		override protected function createView():void {
			super.createView();
			
			contentPadding = Config.FINGER_SIZE * .3;
			contentPaddingV = Config.FINGER_SIZE * .3;
			
			titleText = new Bitmap();
			container.addChild(titleText);
			
			closeButton = new BitmapButton();
			closeButton.setStandartButtonParams();
			closeButton.setDownColor(NaN);
			closeButton.setDownScale(0.7);
			closeButton.setOverlay(HitZoneType.CIRCLE);
			closeButton.cancelOnVerticalMovement = true;
			closeButton.tapCallback = onButtonCloseClick;
			closeButton.setOverflow(Config.FINGER_SIZE * .3, Config.FINGER_SIZE * .3, Config.FINGER_SIZE * .3, Config.FINGER_SIZE * .3);
			closeButton.setOverlayPadding(Config.FINGER_SIZE * .2);
			container.addChild(closeButton);
			
			var icon:NewCloseIcon = new NewCloseIcon();
			UI.scaleToFit(icon, int(Config.FINGER_SIZE * .3), int(Config.FINGER_SIZE * .3));
			closeButton.setBitmapData(UI.getSnapshot(UI.colorize(icon, Style.color(Style.COLOR_ICON_SETTINGS))));
			UI.destroy(icon);
		}
		
		private function onButtonCloseClick():void 
		{
			close();
		}
		
		override protected function getHeight():int 
		{
			return _height - Config.FINGER_SIZE * .5 - Config.APPLE_TOP_OFFSET;
		}
		
		protected function getContentHeight():int 
		{
			return getHeight() - Config.APPLE_BOTTOM_OFFSET;
		}
		
		override protected function drawView():void {
			super.drawView();
		}
		
		override public function dispose():void {
			super.dispose();
			
			if (titleText != null)
			{
				UI.destroy(titleText);
				titleText = null;
			}
			
			if (closeButton != null)
			{
				closeButton.dispose();
				closeButton = null;
			}
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			
			if (_isDisposed) {
				return;
			}
			closeButton.activate();
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed) {
				return;
			}
			closeButton.deactivate();
		}
	}
}