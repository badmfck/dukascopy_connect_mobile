package com.dukascopy.connect.screens.call {
	
	import assets.ClosePopupButton;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.utils.TextUtils;
	import com.telefision.sys.signals.Signal;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class VideoRecognitionCodePopupSmall extends Sprite {
		
		private var back:Sprite;
		private var text:Bitmap;
		private var screenWidth:int;
		private var screenHeight:int;
		private var closeButton:BitmapButton;
		
		public const POPUP_CLOSE:Signal = new Signal("VideoRecognitionCodePopupSmall.POPUP_CLOSE");
		
		public function VideoRecognitionCodePopupSmall() {
			create();
		}
		
		private function create():void {
			back = new Sprite();
			addChild(back);
			back.graphics.beginFill(0x222533, 1);
			back.graphics.drawRect(0, 0, 10, 10);
			
			text = new Bitmap();
			addChild(text);
			
			closeButton = new BitmapButton();
			closeButton.setStandartButtonParams();
			closeButton.setDownScale(1.3);
			closeButton.setDownColor(0xFFFFFF);
			closeButton.setAlphaBlink(0);
			closeButton.tapCallback = closePopup;
			closeButton.disposeBitmapOnDestroy = true;
			closeButton.show();
			addChild(closeButton);
			
			var closeIcon:ClosePopupButton = new ClosePopupButton();
			UI.scaleToFit(closeIcon, Config.FINGER_SIZE, Config.FINGER_SIZE);
			
			closeButton.setBitmapData(UI.getSnapshot(closeIcon));
		}
		
		private function closePopup():void {
			POPUP_CLOSE.invoke();
		}
		
		public function activate():void {
			if (closeButton)
				closeButton.activate();
		}
		
		public function deactivate():void {
			if (closeButton)
				closeButton.deactivate();
		}
		
		public function setSizes(screenWidth:int, screenHeight:int):void {
			this.screenWidth = screenWidth;
			this.screenHeight = screenHeight;
			if (back) {
				back.width = screenWidth;
				back.height = screenHeight;
			}
			if (closeButton) {
				closeButton.x = int(screenWidth - Config.DOUBLE_MARGIN - closeButton.width);
				closeButton.y = int(Config.DOUBLE_MARGIN);
			}
		}
		
		public function display(value:String):void {
			if (text == null)
				return;
			if (text.bitmapData) {
				text.bitmapData.dispose();
				text.bitmapData = null;
			}
			text.bitmapData = TextUtils.createTextFieldData(value, screenWidth, 10, true, TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, Config.FINGER_SIZE, true, 0xC5C8D8, 0x222533);
			text.x = int(screenWidth * .5 - text.width * .5);
			text.y = int(screenHeight * .5 - text.height * .5);
		}
		
		public function destroy():void {
			if (back)
				UI.destroy(back);
			back = null;
			if (closeButton)
				closeButton.dispose();
			closeButton = null;
			if (text)
				UI.destroy(text);
			text = null;
			POPUP_CLOSE.dispose();
		}
	}
}