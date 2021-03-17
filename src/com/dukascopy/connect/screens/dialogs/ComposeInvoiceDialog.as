package com.dukascopy.connect.screens.dialogs {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.langs.Lang;

	import flash.display.Bitmap;


	/**
	 * ...
	 * @author ...
	 */
	
	public class ComposeInvoiceDialog extends ScreenAlertDialog {
		
		private var inputBottom:Bitmap;
		private var emailInput:Input;
		
		public function ComposeInvoiceDialog() {
			super();
		}
		
		override protected function createView():void {
			super.createView();
			
			emailInput = new Input();
			emailInput.setMode(Input.MODE_INPUT);
			emailInput.setLabelText(Lang.enterEmail);
			emailInput.setBorderVisibility(false);
			emailInput.setRoundBG(false);
			emailInput.getTextField().textColor = Style.color(Style.COLOR_TEXT);
			emailInput.setRoundRectangleRadius(0);
			emailInput.inUse = true;
			
			var hLineBitmapData:ImageBitmapData = UI.getHorizontalLine(2);
			inputBottom = new Bitmap(hLineBitmapData);
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
		}
		
		override protected function fireCallbackFunctionWithValue(value:int):void
		{
			callback(value, emailInput.value);
		}
		
		override protected function updateScrollArea():void 
		{
			if (!content.fitInScrollArea())
			{
				content.scrollToPosition(emailInput.view.y - Config.MARGIN);
				content.enable();
			}
			else {
				content.disable();
			}
			
			content.update();
		}
		
		override protected function recreateContent(padding:Number):void 
		{
			super.recreateContent(padding);
			
			emailInput.width = _width - padding * 2;
			
			var emailPosition:int = 0;
			if (content.itemsHeight > 0)
			{
				emailPosition = content.itemsHeight + padding;
			}
			
			emailInput.view.y = emailPosition;
			content.addObject(emailInput.view);
			
			inputBottom.width = _width - padding * 2;
			content.addObject(inputBottom);
			inputBottom.y = emailInput.view.y + emailInput.view.height;
		}
		
		override protected function updateContentHeight():void 
		{
			contentHeight = (padding * 3 + headerHeight + buttonsAreaHeight + content.itemsHeight);
		}
		
		override public function activateScreen():void {
			emailInput.activate();
			super.activateScreen();			
		}
		
		override public function deactivateScreen():void {
			emailInput.activate();
			super.deactivateScreen();
		}
		
		override public function dispose():void {
			super.dispose();
			
			if (emailInput)
			{
				emailInput.dispose();
				emailInput = null;
			}
			
			if (inputBottom)
			{
				UI.destroy(inputBottom);
				inputBottom = null;
			}
		}
	}
}