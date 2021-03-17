package com.dukascopy.connect.screens.dialogs {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	
	/**
	 * ...
	 * @author ...
	 */
	
	public class EditUserNameDialog extends ScreenAlertDialog
	{
		private var inputBottom:Bitmap;
		private var input:Input;
		
		public function EditUserNameDialog()
		{
			super();
		}
		
		override protected function createView():void
		{
			super.createView();
			
			input = new Input();
			input.setMode(Input.MODE_INPUT);
			input.setLabelText(Lang.enterName);
			input.setBorderVisibility(false);
			input.setRoundBG(false);
		//	input.getTextField().textColor = AppTheme.GREY_DARK;
			input.setRoundRectangleRadius(0);
			input.inUse = true;
			
			var hLineBitmapData:ImageBitmapData = UI.getHorizontalLine(2);
			inputBottom = new Bitmap(hLineBitmapData);
		}
		
		override public function initScreen(data:Object = null):void
		{
			super.initScreen(data);
		}
		
		override protected function fireCallbackFunctionWithValue(value:int):void 
		{
			callback(value, input.value);
		}
		
		override protected function updateScrollArea():void 
		{
			if (!content.fitInScrollArea())
			{
				content.scrollToPosition(input.view.y - Config.MARGIN);
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
			
			input.width = _width - padding * 2;
			
			var emailPosition:int = 0;
			if (content.itemsHeight > 0)
			{
				emailPosition = content.itemsHeight + padding;
			}
			
			input.view.y = emailPosition;
			content.addObject(input.view);
			
			inputBottom.width = _width - padding * 2;
			content.addObject(inputBottom);
			inputBottom.y = input.view.y + input.view.height;
		}
		
		override protected function updateContentHeight():void 
		{
			contentHeight = (vPadding * 3 + title.trueHeight + buttonsAreaHeight + content.itemsHeight);
		}
		
		override public function activateScreen():void {
			input.activate();
			super.activateScreen();			
		}
		
		override public function deactivateScreen():void {
			input.activate();
			super.deactivateScreen();
		}
		
		override public function dispose():void {
			super.dispose();
			
			if (input)
			{
				input.dispose();
				input = null;
			}
			
			if (inputBottom)
			{
				UI.destroy(inputBottom);
				inputBottom = null;
			}
		}
	}
}