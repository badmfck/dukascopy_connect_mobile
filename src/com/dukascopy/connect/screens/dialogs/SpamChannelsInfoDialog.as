package com.dukascopy.connect.screens.dialogs {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.menuVideo.OptionSwitcher;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.type.MainColors;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;


	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class SpamChannelsInfoDialog extends PopupDialogBase{
			
		private var buttonOne:BitmapButton;
		private var buttonTwo:BitmapButton;
		private var optionSwitcher:OptionSwitcher;
		private var text:Bitmap;
		private var _doNotShowSelected:Boolean = false;
		
		private var FIT_WIDTH:Number = 0;
		private const OPTION_LINE_HEIGHT:int = Config.FINGER_SIZE *.8;
		private const BTN_ICON_LEFT_SIZE:int = Config.FINGER_SIZE * 0.36;
		private const AVATAR_SIZE:int = Config.FINGER_SIZE * 3;
		private const BTN_ICON_RIGHT_SIZE:int = Config.FINGER_SIZE * 0.36;
	
		
		public function SpamChannelsInfoDialog() { }
		
		// TODO refactor a bit this class
		override public function initScreen(data:Object = null):void{
			super.initScreen(data);
			if (data.title) 	{
				data.title = data.title.toLocaleUpperCase();
			}
			
			FIT_WIDTH = _width - Config.DOUBLE_MARGIN * 2;
			
			var textBack:TextFieldSettings = new TextFieldSettings(Lang.textBack, 0x666666, Config.FINGER_SIZE * .30, TextFormatAlign.CENTER);
			var buttonOneBitmap:ImageBitmapData = TextUtils.createbutton(textBack, 0x666666, 0, Config.FINGER_SIZE * .8, 0x666666, (FIT_WIDTH - Config.MARGIN) * .5);
			buttonOne.setBitmapData(buttonOneBitmap);
			buttonOne.show(0);
			
			var textProceed:TextFieldSettings = new TextFieldSettings(Lang.textProceed, 0x666666, Config.FINGER_SIZE * .30, TextFormatAlign.CENTER);
			var buttonTwoBitmap:ImageBitmapData = TextUtils.createbutton(textProceed, 0x666666, 0, Config.FINGER_SIZE * .8, 0x666666, (FIT_WIDTH - Config.MARGIN) * .5);
			buttonTwo.setBitmapData(buttonTwoBitmap);
			buttonTwo.show(0);
			
			container.addChild(text);
			
			text.bitmapData = TextUtils.createTextFieldData(
															Lang.spamChannelsNotification, 
															FIT_WIDTH, 
															10, 
															true, 
															TextFormatAlign.LEFT, 
															TextFieldAutoSize.LEFT, 
															Config.FINGER_SIZE * .26, 
															true, 0x666666, 0xFFFFFF);
			text.x = Config.DOUBLE_MARGIN;
			
			// Do not show again
			optionSwitcher.create(FIT_WIDTH, OPTION_LINE_HEIGHT, null, Lang.doNotShowAgain, false, true, -1, NaN, 0);
			optionSwitcher.onSwitchCallback = onOptionCallback
			optionSwitcher.x = Config.DOUBLE_MARGIN;
			container.addChild(optionSwitcher);
		}
		
		override protected function createView():void {
			super.createView();				
			// btn 1			
			buttonOne = new BitmapButton();
			buttonOne.setStandartButtonParams();
			buttonOne.setDownScale(1);
			buttonOne.setDownColor(0xffffff);
			buttonOne.disposeBitmapOnDestroy = true;
			buttonOne.tapCallback = onButtonOneClick;
			container.addChild(buttonOne);
			
			// btn 2			
			buttonTwo = new BitmapButton();
			buttonTwo.setStandartButtonParams();
			buttonTwo.setDownScale(1);
			buttonTwo.setDownColor(0xffffff);
			buttonTwo.disposeBitmapOnDestroy = true;
			buttonTwo.tapCallback = onButtonTwoClick;
			container.addChild(buttonTwo);
			
			// switcher
			optionSwitcher = new OptionSwitcher();
			
			// lines
			text  = new Bitmap();
		}
		
		private function onButtonOneClick():void {
			if (_data && _data.callBack != null) {
				_data.callBack({ doNotShowAgain:_doNotShowSelected, id:0});
			}			
			super.onCloseButtonClick();
		}
		
		private function onButtonTwoClick():void {
			if (_data && _data.callBack != null) {
				_data.callBack({ doNotShowAgain:_doNotShowSelected, id:1});
			}			
			super.onCloseButtonClick();
		}
		
		// Do not show selector changed
		private function onOptionCallback(selected:Boolean):void {
			_doNotShowSelected = selected;
			//trace("Do not show again:" + selected);
		}
		
		// Close Clicked
		override protected function onCloseButtonClick():void {
			if (_data && _data.callBack != null) {
				_data.callBack({ doNotShowAgain:_doNotShowSelected, id:-1});
			}			
			super.onCloseButtonClick();
		}
		
		override public function activateScreen():void {
			super.activateScreen();		
			if(buttonOne!=null)
				buttonOne.activate();
			if(buttonTwo!=null)
				buttonTwo.activate();
			if(optionSwitcher!=null)
				optionSwitcher.activate();
		}	
		
		override public function deactivateScreen():void{
			super.deactivateScreen();	
			if(buttonOne!=null)
				buttonOne.deactivate();	
			if(buttonTwo!=null)
				buttonTwo.deactivate();	
			if(optionSwitcher!=null)
				optionSwitcher.deactivate();		
		}
		
		override protected function drawView():void {
			super.drawView();
			
			positionDrawing +=  Config.MARGIN;
			
			text.y = positionDrawing;
			positionDrawing += text.height + Config.MARGIN;
			
			optionSwitcher.y = positionDrawing;
			positionDrawing += optionSwitcher.height + Config.MARGIN;
			
			buttonOne.y = buttonTwo.y = positionDrawing;
			
			buttonOne.x = Config.DOUBLE_MARGIN;
			buttonTwo.x = buttonOne.x + buttonOne.width + Config.MARGIN;
			
			contentHeight = buttonOne.y + buttonOne.height + Config.DOUBLE_MARGIN;
			updateBack();
		}
		
		override public function dispose():void{
			super.dispose();
			if (optionSwitcher != null){
				optionSwitcher.dispose();
				optionSwitcher = null;
			}
			
			UI.destroy(text);
			text = null;
			
			if (buttonOne != null){
				buttonOne.dispose();
				buttonOne = null;
			}		
			
			if (buttonTwo != null){
				buttonTwo.dispose();
				buttonTwo = null;
			}	
		}
	}
}