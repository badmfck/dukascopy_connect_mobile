package com.dukascopy.connect.screens.dialogs.paymentDialogs 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.tools.HorizontalPreloader;
	import com.dukascopy.connect.screens.dialogs.newDialogs.DialogBaseScreen;
	import com.dukascopy.connect.screens.dialogs.paymentDialogs.elements.InputField;
	import com.dukascopy.connect.screens.serviceScreen.Overlay;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	public class RestorePasswordPopup extends DialogBaseScreen
	{
		static public const STATE_START:String = "stateStart";
		static public const STATE_CODE:String = "stateCode";
		
		private var backButton:BitmapButton;
		private var nextButton:BitmapButton;
		
		private var padding:int;
		
		private var titleBitmap:Bitmap;
		private var horizontalLoader:HorizontalPreloader;
		private var state:String = STATE_START;
		private var inputEmail:InputField;
		private var inputCode:InputField;
		
		public function RestorePasswordPopup()
		{
			
		}
		
		override protected function createView():void
		{
			super.createView();
			
			backButton = new BitmapButton();
			backButton.setStandartButtonParams();
			backButton.setDownScale(1);
			backButton.setDownColor(0);
			backButton.tapCallback = backClick;
			backButton.disposeBitmapOnDestroy = true;
			backButton.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
			container.addChild(backButton);
			
			nextButton = new BitmapButton();
			nextButton.setStandartButtonParams();
			nextButton.setDownScale(1);
			nextButton.setDownColor(0);
			nextButton.tapCallback = nextClick;
			nextButton.disposeBitmapOnDestroy = true;
			nextButton.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
			container.addChild(nextButton);
			
			inputEmail = new InputField(-1, Input.MODE_INPUT);
			inputEmail.onSelectedFunction = onInputSelected;
			inputEmail.onChangedFunction = onChangeInputEmail;
			scrollPanel.addObject(inputEmail);
			
			inputCode = new InputField(-1, Input.MODE_INPUT);
			inputCode.onSelectedFunction = onInputCodeSelected;
			inputCode.onChangedFunction = onChangeCodePrice;
		//	scrollPanel.addObject(inputCode);
			
			titleBitmap = new Bitmap();
			scrollPanel.addObject(titleBitmap);
			
			horizontalLoader = new HorizontalPreloader(0xF6951D);
			container.addChild(horizontalLoader);
		}
		
		private function onChangeCodePrice():void 
		{
			
		}
		
		private function onInputCodeSelected():void 
		{
			
		}
		
		private function onChangeInputEmail():void 
		{
			
		}
		
		private function onInputSelected():void 
		{
			
		}
		
		private function checkDataValid():void 
		{
			var invalid:Boolean = false;
			
			if (invalid)
			{
				nextButton.deactivate();
				nextButton.alpha = 0.5;
			}
			else
			{
				nextButton.activate();
				nextButton.alpha = 1;
			}
		}
		
		private function nextClick():void
		{
			if (state == STATE_START)
			{
				horizontalLoader.start();
				
				if (data != null && "callback" in data && data.callback != null && (data.callback is Function) == true && (data.callback as Function).length == 1)
				{
					(data.callback as Function)(inputEmail.valueString);
				}
				TweenMax.delayedCall(2, onEmailSent);
			}
			else if (state == STATE_CODE)
			{
				horizontalLoader.start();
				TweenMax.delayedCall(2, onCodeSent);
			}
		}
		
		private function onCodeSent():void 
		{
			horizontalLoader.stop();
		}
		
		private function onEmailSent():void 
		{
			state = STATE_CODE;
			horizontalLoader.stop();
			scrollPanel.addObject(inputCode);
			
			inputEmail.deactivate();
			inputEmail.alpha = 0.4;
			
			drawView();
		}
		
		private function backClick():void {
			if (state == STATE_CODE)
			{
				scrollPanel.removeObject(inputCode);
				inputCode.valueString = "";
				state = STATE_START;
				
				if (isActivated)
				{
					inputEmail.activate();
				}
				inputEmail.alpha = 1;
				drawView();
			}
			else
			{
				onBack();
			}
		}
		
		private function rejectPopup():void 
		{
			ServiceScreenManager.closeView();
		}
		
		override public function onBack(e:Event = null):void
		{
			rejectPopup();
		}
		
		override public function clearView():void
		{
			super.clearView();
		}
		
		override public function initScreen(data:Object = null):void
		{
			if (data != null)
			{
				data.title = null;
			}
			
			topBar.init(Lang.forgotPassword, onCloseTap);
			
			super.initScreen(data);
			
			horizontalLoader.setSize(_width, int(Config.FINGER_SIZE * .07));
			
			padding = Config.DIALOG_MARGIN;			
			
			drawTitle();
			
			inputEmail.x = hPadding;
			inputEmail.drawString(componentsWidth, Lang.enterEmail, null, null, null);
			
			inputCode.x = hPadding;
			inputCode.drawString(componentsWidth, Lang.enterCode, null, null, null);
			
			drawNextButton(Lang.textSend);
			drawBackButton();
			
			updatePositions();
		}
		
		private function drawTitle():void 
		{
			titleBitmap.bitmapData = TextUtils.createTextFieldData(
																	Lang.restorePasswordDescription, 
																	componentsWidth, 
																	10, 
																	true, 
																	TextFormatAlign.LEFT, 
																	TextFieldAutoSize.LEFT, 
																	Config.FINGER_SIZE * .28, 
																	true, 
																	0x47515B, 
																	topBar.getColor(), false, false, true);
			titleBitmap.x = hPadding;
		}
		
		override protected function onCloseTap():void {
			if (_isDisposed == true)
				return;
			onBack();
		}
		
		private function updatePositions():void 
		{
			var position:int = 0;
			
			titleBitmap.y = position;
			
			position += titleBitmap.height + Config.FINGER_SIZE * .5;
			
			inputEmail.y = position;
			position += inputEmail.height + Config.FINGER_SIZE * .4;
			
			inputCode.y = position;
			position += inputCode.height + Config.FINGER_SIZE * .4;
			
			backButton.x = Config.DIALOG_MARGIN;
			
			nextButton.x = backButton.x + backButton.width + Config.MARGIN;
		}
		
		override protected function getMaxContentHeight():int {
			return _height - scrollPanel.view.y - vPadding * 2 - nextButton.height;
		}
		
		override protected function calculateBGHeight():int {
			var value:int = scrollPanel.view.y + scrollPanel.height + vPadding * 2 + nextButton.height;
			return value;
		}
		
		private function drawNextButton(text:String):void
		{
			var textSettings:TextFieldSettings = new TextFieldSettings(text, 0xFFFFFF, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, Color.GREEN, 1, Config.FINGER_SIZE * .8, NaN, (componentsWidth - Config.MARGIN) * .5);
			nextButton.setBitmapData(buttonBitmap, true);
		}
		
		private function drawBackButton():void
		{
			var textSettings:TextFieldSettings = new TextFieldSettings(Lang.textBack, 0x657280, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, 0xFFFFFF, 1, Config.FINGER_SIZE * .8, NaN, (componentsWidth - Config.MARGIN) * .5);
			backButton.setBitmapData(buttonBitmap, true);
		}
		
		override protected function drawView():void
		{
			if (_isDisposed == true)
				return;
			
			super.drawView();
			
			horizontalLoader.y = topBar.y + topBar.trueHeight;
			
			backButton.y = scrollPanel.view.y + scrollPanel.height + vPadding;
			nextButton.y = scrollPanel.view.y + scrollPanel.height + vPadding;
		}
		
		override public function activateScreen():void
		{
			if (_isDisposed == true)
				return;
			
			super.activateScreen();
			
			backButton.activate();
			nextButton.activate();
			
			if (state != STATE_CODE)
			{
				inputEmail.activate();
			}
			
			inputCode.activate();
		}
		
		override public function deactivateScreen():void
		{
			if (_isDisposed == true)
				return;
			
			super.deactivateScreen();
			
			backButton.deactivate();
			nextButton.deactivate();
			
			inputEmail.deactivate();
			inputCode.deactivate();
		}
		
		override public function dispose():void
		{
			if (_isDisposed == true)
				return;
			super.dispose();
			
			Overlay.removeCurrent();
			
			if (backButton != null)
			{
				backButton.dispose();
				backButton = null;
			}
			if (nextButton != null)
			{
				nextButton.dispose();
				nextButton = null;
			}
			if (inputEmail != null)
			{
				inputEmail.dispose();
				inputEmail = null;
			}
			if (inputCode != null)
			{
				inputCode.dispose();
				inputCode = null;
			}
			if (titleBitmap != null)
			{
				UI.destroy(titleBitmap);
				titleBitmap = null;
			}
		}
	}
}