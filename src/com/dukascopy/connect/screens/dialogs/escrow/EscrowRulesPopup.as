package com.dukascopy.connect.screens.dialogs.escrow {
	
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.screens.dialogs.x.base.float.FloatAlert;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.utils.TextUtils;
	import flash.display.Bitmap;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin.
	 */

	public class EscrowRulesPopup extends FloatAlert {
		
		private var titleText:Bitmap;
		private var needCallback:Boolean;
		
		public function EscrowRulesPopup() { }
		
		override protected function createView():void {
			super.createView();
			
			titleText = new Bitmap();
			container.addChild(titleText);
		}
		
		override public function initScreen(data:Object = null):void {
			
			super.initScreen(data);
			
			var titleWidth:int = (_width - contentPadding * 3 - mainPadding * 2 - closeButton.width);
			
			if (screenData != null && screenData.mainTitle != null)
			{
				titleText.bitmapData = TextUtils.createTextFieldData(screenData.mainTitle, titleWidth, 10, true, 
																	TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, 
																	FontSize.BODY, true, Style.color(Style.COLOR_TEXT),
																	Style.color(Style.COLOR_BACKGROUND), false);
			}
		}
		
		override protected function onNextClick():void 
		{
			needCallback = true;
			close();
		}
		
		override protected function onRemove():void 
		{
			if (needCallback)
			{
				needCallback = false;
				if (screenData.callback != null && screenData.callback.length == 0)
				{
					screenData.callback();
				}
			}
		}
		
		override protected function updateContentPositions():void 
		{
			var headerHeight:int = Math.max(titleText.height, closeButton.height) + contentPaddingV * 2;
			
			titleText.x = int(getWidth() * .5 - titleText.width * .5);
			titleText.y = int(Math.max(contentPaddingV, headerHeight * .5 - titleText.height * .5));
			
			super.updateContentPositions();
		}
		
		override public function dispose():void {
			super.dispose();
			
			if (titleText != null)
			{
				UI.destroy(titleText);
				titleText = null;
			}
		}
	}
}