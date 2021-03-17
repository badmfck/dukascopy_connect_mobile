package com.dukascopy.connect.screens.serviceScreen {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.RtoAgreementData;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.lightbox.ZoomPanContainer;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	
	public class RtoAgreementScreen extends BaseScreen {
	
		private var background:Sprite;
		private var skipButton:BitmapButton;
		private var locked:Boolean = false;
		private var nextButton:BitmapButton;
		private var zoomPanCont:ZoomPanContainer;
		private var sidePadding:int;
		private var bd:ImageBitmapData;
		private var agreementData:RtoAgreementData;
		private var callback:Function;
		
		public function RtoAgreementScreen() { }
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			if (data == null || data.data == null || !(data.data is RtoAgreementData)) {
				ServiceScreenManager.closeView();
				return;
			}
			
			agreementData = data.data as RtoAgreementData;
			
			if (data.callback != null) {
				callback = data.callback;
			}
			
			_params.doDisposeAfterClose = true;
			
			background.graphics.beginFill(0xFFFFFF);
			background.graphics.drawRect(0, 0, _width, _height);
			
			sidePadding = Config.FINGER_SIZE * 0.6;
			var buttonWidth:int = (_width - sidePadding * 3)/2;
			
			var textSettings:TextFieldSettings = new TextFieldSettings(Lang.decline.toUpperCase(), 0x9A2600, Config.FINGER_SIZE * .30, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, 0xFFFFFF, 1, Config.FINGER_SIZE * .8, NaN, buttonWidth);
			skipButton.setBitmapData(buttonBitmap);
			
			textSettings = new TextFieldSettings(Lang.agree.toUpperCase(), 0xFFFFFF, Config.FINGER_SIZE * .30, TextFormatAlign.CENTER);
			buttonBitmap = TextUtils.createbutton(textSettings, 0x81CA2E, 1, Config.FINGER_SIZE * .8, NaN, buttonWidth);
			nextButton.setBitmapData(buttonBitmap);
			
			skipButton.x = sidePadding;
			nextButton.x = sidePadding * 2 + buttonWidth;
			
			skipButton.y = int(_height - sidePadding - skipButton.height);
			nextButton.y = int(_height - sidePadding - skipButton.height);
			
			zoomPanCont.setViewportSize(_width, _height - Config.FINGER_SIZE * 2);
			zoomPanCont.show();
			
			drawAgreement();
		}
		
		private function drawAgreement():void {
			var image:RtoAgreement = new RtoAgreement();
			bd = new ImageBitmapData("imageRTO", image.width, image.height);
			bd.copyBitmapData(image);
			
			image.dispose();
			image = null;
			
			var paddingLeft:int = 165;
			
			var fontSize:int = 36;
			
			var nameField:ImageBitmapData = TextUtils.createTextFieldData(agreementData.clientName, 1278, 10, false, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, fontSize, false, 0, 0xFFFFFF);
			bd.copyPixels(nameField, nameField.rect, new Point(paddingLeft, 710 - 45));
			
			var birthDate:ImageBitmapData = TextUtils.createTextFieldData(agreementData.birthDate, 1278, 10, false, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, fontSize, false, 0, 0xFFFFFF);
			bd.copyPixels(birthDate, birthDate.rect, new Point(paddingLeft, 868 - 45));
			
			var citizenship:ImageBitmapData = TextUtils.createTextFieldData(agreementData.citizenship, 1278, 10, false, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, fontSize, false, 0, 0xFFFFFF);
			bd.copyPixels(citizenship, citizenship.rect, new Point(paddingLeft, 1024 - 45));
			
			var address:ImageBitmapData = TextUtils.createTextFieldData(agreementData.homeAddress, 1278, 10, false, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, fontSize, false, 0, 0xFFFFFF);
			bd.copyPixels(address, address.rect, new Point(paddingLeft, 1182 - 45));
			
			var date:ImageBitmapData = TextUtils.createTextFieldData(agreementData.date, 1278, 10, false, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, fontSize, false, 0, 0xFFFFFF);
			bd.copyPixels(date, date.rect, new Point(paddingLeft, 2032 - 45));
			
			zoomPanCont.setBitmapData(bd as ImageBitmapData);
			
			nameField.dispose();
			birthDate.dispose();
			citizenship.dispose();
			address.dispose();
			date.dispose();
			
			nameField = null;
			birthDate = null;
			citizenship = null;
			address = null;
			date = null;
		}
		
		override protected function createView():void {
			super.createView();
			
			background = new Sprite();
			view.addChild(background);
			
			zoomPanCont = new ZoomPanContainer(MobileGui.stage, 0, 0);
			zoomPanCont.touchStartCallback = hideButtons;
			zoomPanCont.touchEndCallback = showButtons;
			zoomPanCont.allowHideOnSwipe = false;
			view.addChild(zoomPanCont);
			
			skipButton = new BitmapButton();
			skipButton.setStandartButtonParams();
			skipButton.setDownScale(1);
			skipButton.setDownColor(0);
			skipButton.tapCallback = skipClick;
			skipButton.disposeBitmapOnDestroy = true;
			view.addChild(skipButton);
			
			nextButton = new BitmapButton();
			nextButton.setStandartButtonParams();
			nextButton.setDownScale(1);
			nextButton.setDownColor(0);
			nextButton.tapCallback = nextClick;
			nextButton.disposeBitmapOnDestroy = true;
			view.addChild(nextButton);
		}
		
		private function hideButtons():void {
			if (nextButton != null)	{
				nextButton.deactivate();
				nextButton.alpha = 0.3;
			}
			
			if (skipButton != null)	{
				skipButton.deactivate();
				skipButton.alpha = 0.3;
			}
		}
		
		private function showButtons():void {
			if (nextButton != null)	{
				nextButton.activate();
				nextButton.alpha = 1;
			}
			
			if (skipButton != null)	{
				skipButton.activate();
				skipButton.alpha = 1;
			}
		}
		
		private function nextClick():void {
			if (callback != null) {
				callback(true);
			}
			ServiceScreenManager.closeView();
		}
		
		private function skipClick():void {
			if (callback != null) {
				callback(false);
			}
			ServiceScreenManager.closeView();
		}
		
		override protected function drawView():void {
			super.drawView();
		}
		
		override public function clearView():void {
			super.clearView();
		}
		
		override public function dispose():void {
			super.dispose();
			
			if (background != null)	{
				UI.destroy(background);
				background = null;
			}
			if (skipButton != null)	{
				skipButton.dispose();
				skipButton = null;
			}
			if (nextButton != null)	{
				nextButton.dispose();
				nextButton = null;
			}
			
			callback = null;
			agreementData = null;
			
			if (zoomPanCont != null) {
				zoomPanCont.destroy();
				zoomPanCont = null;
			}
			
			if (bd != null)	{
				bd.dispose();
				bd = null;
			}
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			
			if (_isDisposed) {
				return;
			}
			
			if (locked)	{
				return;
			}
			
			zoomPanCont.activate();
			skipButton.activate();
			nextButton.activate();
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed) {
				return;
			}
			
			zoomPanCont.deactivate();
			skipButton.deactivate();
			nextButton.deactivate();
		}
	}
}