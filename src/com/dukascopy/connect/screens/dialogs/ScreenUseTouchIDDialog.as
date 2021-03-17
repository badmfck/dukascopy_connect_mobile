package com.dukascopy.connect.screens.dialogs {

	import assets.FingerprintInfo;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.utils.TextUtils;
	import flash.display.Sprite;

	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.langs.Lang;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.StageQuality;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;

	/**
	 * ...
	 * @author Aleksei L
	 */

	public class ScreenUseTouchIDDialog extends ScreenAlertDialog {
	
		private var textBitmap:Bitmap;
		private var _iconBmd:Bitmap;
		
		public function ScreenUseTouchIDDialog() {
			super();
		}
		
		override protected function createView():void {
			super.createView();
			//var maxTextHeight:int = Math.min(1500, 16777000 / (_width - padding * 2));
			var icon:Sprite = new FingerprintInfo();
			if (Config.APPLE_BOTTOM_OFFSET > 0)
			{
				icon = new FaceIdIcon();
			}
			else
			{
				icon = new FingerprintInfo();
			}
			UI.colorize(icon, Style.color(Style.ICON_COLOR));
			UI.scaleToFit(icon, Config.FINGER_SIZE, Config.FINGER_SIZE);
			//Dukascopy
			textBitmap = new Bitmap();
			
			
			/*textBitmap.bitmapData = UI.renderTextShadowed(message, _width - padding * 2,
					Config.FINGER_SIZE, true, true, TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, FontSize.BODY, true, Style.color(Style.COLOR_BACKGROUND), 0x000000, Style.color(Style.COLOR_TEXT), true, 1, false);*/
			_iconBmd = new Bitmap(UI.getSnapshot(icon, StageQuality.HIGH, "ImageFrames.frame"));
			_iconBmd.smoothing = true;
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			var message:String;
			if (Config.APPLE_BOTTOM_OFFSET > 0)
			{
				message = Lang.useFaceId;
			}
			else
			{
				message = Lang.useTouchIDPayments;
			}
			
			textBitmap.bitmapData = TextUtils.createTextFieldData(message, _width - padding * 2, 10, true, TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, FontSize.BODY, true, Style.color(Style.COLOR_TEXT));
			
			//btnsCount = 1;
		}
		
		override protected function fireCallbackFunctionWithValue(value:int):void {
			var callBackFunction:Function = callback;
			callback = null;
			callBackFunction(value);
		}
		
		override protected function getMaxContentHeight():Number {
			return _height - padding * 2 - headerHeight - buttonsAreaHeight;
		}
		
		override protected function drawView():void {
			super.drawView();
			// todo add check for valid input
		}
		
		override protected function repositionButtons():void {
			contentBottomPadding = 0;
			super.repositionButtons();
		}
		
		override protected function updateScrollArea():void {
			if (!content.fitInScrollArea()) {
				content.enable();
			}
			else {
				content.disable();
			}
			content.update();
		}
		
		override protected function recreateContent(padding:Number):void {
			super.recreateContent(padding);
			
			textBitmap.y = padding + _iconBmd.y + _iconBmd.height;
			
			content.addObject(_iconBmd);
			content.addObject(textBitmap);
			_iconBmd.x = (_width - (padding * 2 + _iconBmd.width)) * .5;
			textBitmap.x = (_width - (padding * 2 + textBitmap.width)) * .5;
		}
		
		override protected function updateContentHeight():void {
			contentHeight = (vPadding * 4 + title.trueHeight + buttonsAreaHeight + content.itemsHeight);
		}
		
		override public function activateScreen():void {
			super.activateScreen();
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
		}
		
		override protected function btn0Clicked():void {
			if (callback != null) {
				fireCallbackFunctionWithValue(1);
			}
			DialogManager.closeDialog();
		}
		
		override protected function btn1Clicked():void {
			if (callback != null) {
				fireCallbackFunctionWithValue(2);
			}
			DialogManager.closeDialog();
		}
		
		override protected function btn2Clicked():void {
			if (callback != null) {
				fireCallbackFunctionWithValue(3);
			}
			DialogManager.closeDialog();
		}
		
		override protected function onCloseButtonClick():void {
			if (callback != null) {
				fireCallbackFunctionWithValue(0);
			}
			DialogManager.closeDialog();
		}
		
		override public function dispose():void {
			super.dispose();
			
			if (textBitmap) {
				UI.destroy(textBitmap);
				textBitmap = null;
			}
			if (_iconBmd) {
				UI.destroy(_iconBmd);
				_iconBmd = null;
			}
		}
	}
}