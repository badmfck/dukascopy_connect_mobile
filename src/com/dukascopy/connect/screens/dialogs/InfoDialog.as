package com.dukascopy.connect.screens.dialogs {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.type.MainColors;
	import com.dukascopy.langs.Lang;
	import flash.display.BitmapData;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;


	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.menuVideo.OptionSwitcher;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.base.ScreenParams;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author IgorBloom
	 */
	
	public class InfoDialog extends PopupDialogBase{
			
		private var buttonOne:BitmapButton;
		private var buttonTwo:BitmapButton;
		private var optionSwitcher:OptionSwitcher;
		private var lineOne:Bitmap;
		private var lineTwo:Bitmap;
		private var _doNotShowSelected:Boolean = false;
		
		private var FIT_WIDTH:Number = 0;
		private const OPTION_LINE_HEIGHT:int = Config.FINGER_SIZE *.8;
		private const BTN_ICON_LEFT_SIZE:int = Config.FINGER_SIZE * 0.36;
		private const AVATAR_SIZE:int = Config.FINGER_SIZE * 3;
		private const BTN_ICON_RIGHT_SIZE:int = Config.FINGER_SIZE * 0.36;
	
		
		public function InfoDialog() { }
		
		// TODO refactor a bit this class
		override public function initScreen(data:Object = null):void{
			super.initScreen(data);
			if (data.title) 	{
				data.title = data.title.toLocaleUpperCase();
			}
			
			FIT_WIDTH = _width - Config.DOUBLE_MARGIN * 2;
			
			
			// btn 1
			var iconChat:SWFChatIconRed = new SWFChatIconRed();
			UI.scaleToFit(iconChat, BTN_ICON_LEFT_SIZE*2, BTN_ICON_LEFT_SIZE*2);			
			var bitmapPlane:BitmapData =  UI.renderTextPlane(getHTMLString(Lang.openMessenger, Lang.freeMessenger), 
																FIT_WIDTH,
																OPTION_LINE_HEIGHT*2,
																true,
																TextFormatAlign.LEFT,
																TextFieldAutoSize.LEFT,
																Config.FINGER_SIZE * 0.34,
																true,
																AppTheme.GREY_DARK,
																0xffffff,
																0,
																0,
																0,
																Config.MARGIN,
																0,
																iconChat,
																true,
																true,
																0);
			UI.destroy(iconChat);					
			buttonOne.setBitmapData(bitmapPlane);
			buttonOne.x = Config.DOUBLE_MARGIN;
			container.addChild(buttonOne);
			buttonOne.show(0);
			
			// btn 2
			var iconPay:SWFPayIconRed = new SWFPayIconRed();
			UI.scaleToFit(iconPay, BTN_ICON_LEFT_SIZE*2, BTN_ICON_LEFT_SIZE*2);			
			var bitmapPlane2:BitmapData =  UI.renderTextPlane(getHTMLString(Lang.openPayments, Lang.instantPayments), 
																FIT_WIDTH,
																OPTION_LINE_HEIGHT*2,
																true,
																TextFormatAlign.LEFT,
																TextFieldAutoSize.LEFT,
																Config.FINGER_SIZE * 0.34,
																true,
																AppTheme.GREY_DARK,
																0xffffff,
																0,
																0,
																0,
																Config.MARGIN,
																0,
																iconPay,
																true,
																true,
																0);
			UI.destroy(iconPay);		
			buttonTwo.setBitmapData(bitmapPlane2);
			buttonTwo.x = Config.DOUBLE_MARGIN;
			container.addChild(buttonTwo);
			buttonTwo.show(0);
			
			// Lines
			container.addChild(lineOne);
			container.addChild(lineTwo);
			lineOne.x = lineTwo.x = Config.DOUBLE_MARGIN;
			lineOne.width = lineTwo.width = FIT_WIDTH;
			
			// Do not show again
			optionSwitcher.create(FIT_WIDTH, OPTION_LINE_HEIGHT, null, Lang.doNotShowAgain);
			optionSwitcher.onSwitchCallback = onOptionCallback
			optionSwitcher.x = Config.DOUBLE_MARGIN;
			container.addChild(optionSwitcher);
			
		}
		
		private function getHTMLString(partMain:String, partSecond:String):String{
			var resultText:String = "<font color='#3e4756' size='" + int(Config.FINGER_SIZE*.34)+ "'>"   + partMain   + "</font><br>" 
									+"<font color='#93a2ae' size='" + int(Config.FINGER_SIZE*.22) + "'>" + partSecond +  "</font>";
			return resultText;			
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
			
			// btn 2			
			buttonTwo = new BitmapButton();
			buttonTwo.setStandartButtonParams();
			buttonTwo.setDownScale(1);
			buttonTwo.setDownColor(0xffffff);
			buttonTwo.disposeBitmapOnDestroy = true;
			buttonTwo.tapCallback = onButtonTwoClick;
			
			// switcher
			optionSwitcher = new OptionSwitcher();
			
			// lines
			lineOne  = new Bitmap(new BitmapData(1, 1, false, MainColors.GREY));
			lineTwo  = new Bitmap(new BitmapData(1, 1, false, MainColors.GREY));
			
		}
		
		// Open Messanger Clicked		
		private function onButtonOneClick():void {
			//trace("Open Messanger Clicked");
			if (_data && _data.callBack != null) {
				_data.callBack({ doNotShowAgain:_doNotShowSelected, id:0});
			}			
			super.onCloseButtonClick();
		}
		
		// Open Payments Clicked
		private function onButtonTwoClick():void {
			//trace("Open Payments Clicked");		
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
		override protected function onCloseButtonClick():void		{
			if (_data && _data.callBack != null) {
				_data.callBack({ doNotShowAgain:_doNotShowSelected, id:-1});
			}			
			super.onCloseButtonClick();
		}
		
		
		override public function activateScreen():void{
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
			buttonOne.y = positionDrawing + Config.DOUBLE_MARGIN;
			lineOne.y = int(buttonOne.y + buttonOne.height + Config.DOUBLE_MARGIN);
			
			buttonTwo.y = lineOne.y + Config.DOUBLE_MARGIN;	
			lineTwo.y = int(buttonTwo.y + buttonTwo.height + Config.DOUBLE_MARGIN);
			
			
			contentHeight = positionDrawing + buttonOne.height + buttonTwo.height + OPTION_LINE_HEIGHT + Config.DOUBLE_MARGIN * 6;
			
			optionSwitcher.y = contentHeight - OPTION_LINE_HEIGHT - Config.DOUBLE_MARGIN;
			updateBack();
			updateBack();
		}
		
		
		
		
		override public function dispose():void{
			super.dispose();
			if (optionSwitcher != null){
				optionSwitcher.dispose();
				optionSwitcher = null;
			}
			
			
			UI.destroy(lineOne);
			lineOne = null;
			
			UI.destroy(lineTwo);
			lineTwo = null;
			
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