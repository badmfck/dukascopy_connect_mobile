package com.dukascopy.connect.screens.dialogs {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.menuVideo.OptionSwitcher;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.display.StageQuality;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class QuestionRulesDialog extends PopupDialogBase {
		
		private var buttonOpenRules:BitmapButton;
		private var optionSwitcher:OptionSwitcher;
		private var _doNotShowSelected:Boolean = false;
		
		private var FIT_WIDTH:Number = 0;
		private const OPTION_LINE_HEIGHT:int = Config.FINGER_SIZE *.8;
		private const BTN_ICON_LEFT_SIZE:int = Config.FINGER_SIZE * 0.36;
		private const AVATAR_SIZE:int = Config.FINGER_SIZE * 3;
		private const BTN_ICON_RIGHT_SIZE:int = Config.FINGER_SIZE * 0.36;
		private var dogImage:Bitmap;
		private var description:Bitmap;
		private var maxDialogWidth:int;
		private var originalWidth:int;
		
		public function QuestionRulesDialog() {
			maxDialogWidth = Config.FINGER_SIZE * 5;
		}
		
		override public function setWidthAndHeight(width:int, height:int):void {
			originalWidth = width;
			_width = Math.min(width, maxDialogWidth);
			_height = height;
			
			screenWidth = _width;
			screenHeight = _height;
			
			contentWidth = screenWidth;
			
			drawView();
		}
		
		override public function initScreen(data:Object = null):void {
			_width = Math.min(maxDialogWidth, _width);
			super.initScreen(data);
			
			FIT_WIDTH = _width - Config.DOUBLE_MARGIN * 4;
			
			var buttonText:TextFieldSettings = new TextFieldSettings(Lang.readRules, 0x00000A, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			var buttonBD:ImageBitmapData = TextUtils.createbutton(buttonText, 0xF7F8F9, 1, int(Config.FINGER_SIZE * 0.3), NaN, -1, int(Config.FINGER_SIZE * .1));
			
			buttonOpenRules.setBitmapData(buttonBD);
			buttonOpenRules.x = Config.DOUBLE_MARGIN;
			buttonOpenRules.show(0);
			
			// Do not show again
			optionSwitcher.create(_width - Config.DOUBLE_MARGIN * 2, OPTION_LINE_HEIGHT, null, Lang.doNotShowAgain, false, true, -1, NaN, 0);
			optionSwitcher.onSwitchCallback = onOptionCallback
			optionSwitcher.x = Config.DOUBLE_MARGIN;
			
			var text:String;
			if (data != null && "text" in data && data.text != null) {
				text = data.text;
			}
			else {
				text = Lang.questionInfoShortText;
			}
			
			description.bitmapData = TextUtils.createTextFieldData(text, 
																FIT_WIDTH, 
																10, 
																true, 
																TextFormatAlign.CENTER, 
																TextFieldAutoSize.LEFT, 
																Config.FINGER_SIZE * .26, 
																true, 
																0x758898, 0xFFFFFF, true);
		}
		
		override protected function createView():void {
			super.createView();				
			// btn 1			
			buttonOpenRules = new BitmapButton();
			buttonOpenRules.setStandartButtonParams();
			buttonOpenRules.setDownScale(1);
			buttonOpenRules.setDownColor(0xffffff);
			buttonOpenRules.disposeBitmapOnDestroy = true;
			buttonOpenRules.tapCallback = onButtonOneClick;
			container.addChild(buttonOpenRules);
			
			// switcher
			optionSwitcher = new OptionSwitcher();
			container.addChild(optionSwitcher);
			
			var dog:assets_stiker_Stiker_phone = new assets_stiker_Stiker_phone();
			UI.scaleToFit(dog, Config.FINGER_SIZE * 2.5, Config.FINGER_SIZE * 2.5);
			dogImage = new Bitmap();
			container.addChild(dogImage);
			dogImage.bitmapData = UI.getSnapshot(dog, StageQuality.HIGH, "QuestionRulesDialog.dogImage");
			UI.destroy(dog);
			dog = null;
			
			description = new Bitmap();
			container.addChild(description);
		}
		
		private function onButtonOneClick():void {
			if (_data && _data.callBack != null) {
				_data.callBack({ doNotShowAgain:_doNotShowSelected, id:0});
			}			
			super.onCloseButtonClick();
		}
		
		// Do not show selector changed
		private function onOptionCallback(selected:Boolean):void {
			_doNotShowSelected = selected;
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
			if(buttonOpenRules!=null)
				buttonOpenRules.activate();
			if(optionSwitcher!=null)
				optionSwitcher.activate();
		}	
		
		override public function deactivateScreen():void {
			super.deactivateScreen();	
			if(buttonOpenRules!=null)
				buttonOpenRules.deactivate();	
			if(optionSwitcher!=null)
				optionSwitcher.deactivate();		
		}
		
		override protected function drawView():void {
			super.drawView();
			
			dogImage.y = positionDrawing;
			dogImage.x = int(_width * .5 - dogImage.width * .5);
			
			positionDrawing += dogImage.height + Config.DOUBLE_MARGIN;
			
			description.y = positionDrawing;
			description.x = int(_width * .5 - description.width * .5);
			
			positionDrawing += description.height + Config.DOUBLE_MARGIN;
			
			buttonOpenRules.y = positionDrawing;
			buttonOpenRules.x = int(_width * .5 - buttonOpenRules.width * .5);
			
			positionDrawing += buttonOpenRules.height + Config.DOUBLE_MARGIN;
			
			optionSwitcher.y = positionDrawing;
			
			positionDrawing += optionSwitcher.height + Config.DOUBLE_MARGIN;
			
			contentHeight = positionDrawing;
			
			updateBack();
			
			view.x = int(originalWidth * .5 - _width * .5);
		}
		
		override public function dispose():void {
			super.dispose();
			if (optionSwitcher != null){
				optionSwitcher.dispose();
				optionSwitcher = null;
			}
			
			if (buttonOpenRules != null){
				buttonOpenRules.dispose();
				buttonOpenRules = null;
			}
			
			if (dogImage != null) {
				UI.destroy(dogImage);
				dogImage = null;
			}
			
			if (description != null) {
				UI.destroy(description);
				description = null;
			}
		}
	}
}