package com.dukascopy.connect.screens.dialogs {
	
	import assets.LockClosedGrey;
	import com.adobe.utils.StringUtil;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.OptionSwitcher;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.StageQuality;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class UseFingerprintDialog extends ScreenAlertDialog {
		
		private var dontAskSwitch:OptionSwitcher;
		
		public function UseFingerprintDialog() {
			super();
		}
		
		/*override protected function createView():void {
			super.createView();
			
			dontAskSwitch = new OptionSwitcher();
			dontAskSwitch.onSwitchCallback = switchLimit;
		}*/
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
		}
		
		/*private function switchLimit(selected:Boolean):void 
		{
			dontAskSwitch.isSelected = selected;
		}*/
		
		override protected function fireCallbackFunctionWithValue(value:int):void 
		{
			var callBackFunction:Function = callback;
			callback = null;
			if (callBackFunction != null && callBackFunction.length == 2)
			{
			//	callBackFunction(value, dontAskSwitch.isSelected);
				callBackFunction(value, true);
			}
			else
			{
				callBackFunction(value);
			}
		}
		
		override protected function getMaxContentHeight():Number 
		{
			return _height - padding * 2 - headerHeight - buttonsAreaHeight;
		}
		
		override protected function drawView():void {
			super.drawView();
		}
		
		override protected function repositionButtons():void 
		{
			contentBottomPadding = 0;
			super.repositionButtons();
		}
		
		/*override protected function recreateContent(padding:Number):void 
		{
			super.recreateContent(padding);
			
			dontAskSwitch.y = (content.itemsHeight == 0 )? 0 :int(content.itemsHeight + padding);
			
			dontAskSwitch.create(_width - Config.DIALOG_MARGIN * 2, Config.FINGER_SIZE * .8, null, Lang.dontAskAgain, false, true, 0x47515B, Config.FINGER_SIZE * .3, 0);
			
			content.addObject(dontAskSwitch);
		}*/
		
		override protected function updateContentHeight():void 
		{
			contentHeight = (padding * 1.3 * 3 + headerHeight + buttonsAreaHeight + content.itemsHeight);
		}
		
		/*override public function activateScreen():void {
			super.activateScreen();
			
			dontAskSwitch.activate();
		}*/
		
		/*override public function deactivateScreen():void {
			super.deactivateScreen();
			
			dontAskSwitch.deactivate();
		}*/
		
		override protected function btn0Clicked():void {
			if (callback != null) {
				fireCallbackFunctionWithValue(1);
			}
			DialogManager.closeDialog();
		}
		
		override protected function onCloseButtonClick():void {
			if (callback != null) {
				fireCallbackFunctionWithValue(0);
			}
			DialogManager.closeDialog();
		}
		
		/*override public function dispose():void {
			super.dispose();
			
			if (dontAskSwitch != null)
			{
				dontAskSwitch.dispose();
				dontAskSwitch = null;
			}
		}*/
	}
}