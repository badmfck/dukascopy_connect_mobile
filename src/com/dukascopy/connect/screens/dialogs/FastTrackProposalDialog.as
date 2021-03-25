package com.dukascopy.connect.screens.dialogs {
	
	import assets.RunIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.OptionSwitcher;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.langs.Lang;
	import flash.display.BitmapData;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class FastTrackProposalDialog extends ScreenAlertDialog
	{
		private var optionSwitcher:OptionSwitcher;
		private var _doNotShowSelected:Boolean = false;
		private const OPTION_LINE_HEIGHT:int = Config.FINGER_SIZE *.8;
		private const BTN_ICON_LEFT_SIZE:int = Config.FINGER_SIZE * 0.36;
		private const AVATAR_SIZE:int = Config.FINGER_SIZE * 3;
		private const BTN_ICON_RIGHT_SIZE:int = Config.FINGER_SIZE * 0.36;
		
		public function FastTrackProposalDialog()
		{
			super();
		}
		
		override protected function createView():void
		{
			super.createView();
			
			
			
			// switcher
			optionSwitcher = new OptionSwitcher();
		}
		
		override public function initScreen(data:Object = null):void
		{
			data.buttonOk = "    " + Lang.getFastTrackButton;
			data.buttonSecond = Lang.willWait;
			super.initScreen(data);
			if (data.title) 	{
				data.title = data.title.toLocaleUpperCase();
			}
			
			// Do not show again
			optionSwitcher.create(_width - Config.DIALOG_MARGIN * 2, OPTION_LINE_HEIGHT, null, Lang.doNotShowAgain);
			optionSwitcher.onSwitchCallback = onOptionCallback;
		//	optionSwitcher.x = Config.DOUBLE_MARGIN;
			container.addChild(optionSwitcher);

			updateButton();
		}
		
		override protected function drawView():void
		{
			super.drawView();
			updateButton();
		}
		
		private function updateButton():void 
		{
			var icon:RunIcon = new RunIcon();
			UI.scaleToFit(icon, Config.FINGER_SIZE * .6, Config.FINGER_SIZE * .6);
			var iconBD:ImageBitmapData = UI.getSnapshot(icon);
			
			var buttonBitmap:BitmapData = button0.currentBitmapData;
			if (buttonBitmap != null)
			{
				buttonBitmap.copyPixels(iconBD, iconBD.rect, new Point(Config.FINGER_SIZE * .2, buttonBitmap.height * .5 - iconBD.height * .5), null, null, true);
			}
			
			iconBD.dispose();
		}
		
		private function onOptionCallback(selected:Boolean):void {
			_doNotShowSelected = selected;
		}
		
		override protected function fireCallbackFunctionWithValue(value:int):void 
		{
			callback(value, _doNotShowSelected);
		}
		
		override protected function recreateContent(padding:Number):void 
		{
			super.recreateContent(padding);
			
			var position:int = 0;
			if (content.itemsHeight > 0)
			{
				position = content.itemsHeight + padding;
			}
			optionSwitcher.x = 0;
			optionSwitcher.y = position;
			content.addObject(optionSwitcher);
		}
		
		override protected function updateContentHeight():void 
		{
			contentHeight = (vPadding * 3 + title.trueHeight + buttonsAreaHeight + content.itemsHeight + Config.FINGER_SIZE * .2);
		}
		
		override public function activateScreen():void {
			super.activateScreen();	
			if(optionSwitcher!=null)
				optionSwitcher.activate();
		}
		
		override public function deactivateScreen():void {
			if(optionSwitcher!=null)
				optionSwitcher.deactivate();		
			super.deactivateScreen();
		}
		
		override public function dispose():void {
			super.dispose();
			
			if (optionSwitcher != null){
				optionSwitcher.dispose();
				optionSwitcher = null;
			}
		}
	}
}