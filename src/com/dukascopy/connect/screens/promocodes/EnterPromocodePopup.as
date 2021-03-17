package com.dukascopy.connect.screens.promocodes {
	
	import assets.HelpIcon2;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.preloader.Preloader;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.notificationManager.InnerNotificationManager;
	import com.dukascopy.connect.sys.payments.PayAPIManager;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.promocodes.ReferralProgram;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import flash.display.Bitmap;
	import flash.display.CapsStyle;
	import flash.display.LineScaleMode;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Dobarin Sergey
	 */
	
	public class EnterPromocodePopup extends BaseScreen {
		
		private var preloader:Preloader;
		private var locked:Boolean;
		private var okButton:BitmapButton;
		private var cancelButton:BitmapButton;
		private var codeInput1:Input;
		private var inputContainer:Sprite;
		private var text:Bitmap;
	//	private var codeInput2:Input;
		private var errorText:Bitmap;
		private var container:Sprite;
		private var background:Sprite;
		private var shown:Boolean = false;
		private var helpButton:BitmapButton;
		private var codeSuccess:Boolean = false;
		private var doneClip:doneRoundIcon2;
		private var currentPromocodeText:String;
		private var containerBack:Sprite;
		private var codeAccepted:Boolean;
		
		public function EnterPromocodePopup() { }
		
		override public function initScreen(data:Object = null):void {
			InnerNotificationManager.pause();
			super.initScreen(data);
			
			_params.title = 'Enter promocode screen';
			_params.doDisposeAfterClose = true;
			
			var okText:TextFieldSettings = new TextFieldSettings(Lang.textSend, 0xFFFFFF, Config.FINGER_SIZE * .26, TextFormatAlign.CENTER);
			var cancelText:TextFieldSettings = new TextFieldSettings(Lang.textCancel, 0xFFFFFF, Config.FINGER_SIZE * .26, TextFormatAlign.CENTER);
			
			okButton.setBitmapData(TextUtils.createbutton(okText, 0x77BF43, 1, -1, NaN, (_width - Config.MARGIN * 6)*.5));
			cancelButton.setBitmapData(TextUtils.createbutton(cancelText, 0, 0, -1, 0xFFFFFF, (_width - Config.MARGIN * 6)*.5));
			
			cancelButton.x = Config.MARGIN * 2;
			okButton.x = cancelButton.x + cancelButton.width + Config.MARGIN * 2;
			
			codeInput1.width = Config.FINGER_SIZE * 1.5 * 2;
		//	codeInput2.width = Config.FINGER_SIZE * 1.5;
			codeInput1.view.x = int(Config.MARGIN * 2);
		//	codeInput2.view.x = int(codeInput1.view.x + codeInput1.width + Config.MARGIN * 3);
			
			currentPromocodeText = ReferralProgram.getPromocodeDescription(null);
			drawDescription();
			
			text.x = int(Config.DOUBLE_MARGIN);
			
			helpButton.x = int(_width - Config.MARGIN * 2 - helpButton.width);
			
			helpButton.y = Config.MARGIN * 3 + Config.APPLE_TOP_OFFSET;
			
			inputContainer.graphics.lineStyle(Math.max(2, Config.FINGER_SIZE * .02), 0xFFFFFF, 1, false, LineScaleMode.NORMAL, CapsStyle.NONE);
		//	inputContainer.graphics.moveTo(int(codeInput2.view.x), int(codeInput2.height));
		//	inputContainer.graphics.lineTo(int(codeInput2.view.x + codeInput2.width), int(codeInput2.height));
			
			inputContainer.graphics.moveTo(int(codeInput1.view.x), int(codeInput1.height));
			inputContainer.graphics.lineTo(int(codeInput1.view.x) + codeInput1.width, int(codeInput1.height));
			
		//	inputContainer.graphics.moveTo(int(codeInput1.view.x + codeInput1.width + Config.MARGIN*.7), int(codeInput1.height * .5));
		//	inputContainer.graphics.lineTo(int(codeInput2.view.x - Config.MARGIN * .7), int(codeInput1.height * .5));
			
			background.graphics.beginFill(0x000000, 0.2);
			background.graphics.drawRect(0, 0, _width, _height);
			
			containerBack.graphics.beginFill(0x2D384E);
			containerBack.graphics.drawRect(0, 0, _width, 10);
			
			repositionElements();
			container.y = -container.height;
			
			ReferralProgram.S_CODE_SEND_RESULT.add(sendCodeResult);
		}
		
		private function repositionElements(animationTime:Number = 0):void {
			
			TweenMax.killTweensOf(inputContainer);
			TweenMax.killTweensOf(cancelButton);
			TweenMax.killTweensOf(containerBack);
			TweenMax.killTweensOf(okButton);
			
			var position:int = text.y + text.height + Config.DOUBLE_MARGIN;
			TweenMax.to(inputContainer, animationTime, {y: position});
			TweenMax.to(cancelButton, animationTime, {y: position + inputContainer.height + Config.MARGIN * 3});
			TweenMax.to(okButton, animationTime, {y: position + inputContainer.height + Config.MARGIN * 3});
			
			var backHeight:int = position + inputContainer.height + Config.MARGIN * 3 + cancelButton.height + Config.DOUBLE_MARGIN
			TweenMax.to(containerBack, animationTime, {height: backHeight});
		}
		
		private function drawDescription():void {
			if (text.bitmapData != null) {
				text.bitmapData.dispose();
				text.bitmapData = null;
			}
			text.bitmapData = TextUtils.createTextFieldData(currentPromocodeText, 
															_width - Config.MARGIN * 5 - helpButton.width, 10, 
															true, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
															Config.FINGER_SIZE * .35, true, 0xFFFFFF, 0x2D384E);
		}
		
		override protected function createView():void {
			super.createView();
			
			background = new Sprite();
			view.addChild(background);
			
			container = new Sprite();
			view.addChild(container);
			
			containerBack = new Sprite();
			container.addChild(containerBack);
			
			okButton = new BitmapButton();
			okButton.setStandartButtonParams();
			okButton.setDownScale(1);
			okButton.cancelOnVerticalMovement = true;
			okButton.tapCallback = onButtonOkClick;
			container.addChild(okButton);
			
			cancelButton = new BitmapButton();
			cancelButton.setStandartButtonParams();
			cancelButton.setDownScale(1);
			cancelButton.cancelOnVerticalMovement = true;
			cancelButton.tapCallback = onButtonCancelClick;
			container.addChild(cancelButton);
			
			helpButton = new BitmapButton();
			helpButton.setStandartButtonParams();
			helpButton.setDownScale(1);
			helpButton.cancelOnVerticalMovement = true;
			helpButton.tapCallback = onHelpClick;
			container.addChild(helpButton);
			var helpIcon:HelpIcon2 = new HelpIcon2();
			UI.scaleToFit(helpIcon, Config.FINGER_SIZE*.5, Config.FINGER_SIZE*.5);
			helpButton.setBitmapData(UI.getSnapshot(helpIcon, StageQuality.HIGH, "EnterPromocodePopup.helpIcon"));
			helpButton.visible = false;
			text = new Bitmap();
			container.addChild(text);
			
			text.y = Config.DOUBLE_MARGIN + Config.APPLE_TOP_OFFSET;
			
			var textFormatCode:TextFormat = new TextFormat();
			textFormatCode.size = Config.FINGER_SIZE * .45;
			textFormatCode.align = TextFormatAlign.CENTER;
			textFormatCode.color = 0xFFFFFF;
			
			codeInput1 = new Input();
			codeInput1.backgroundColor = 0x2D384E;
			codeInput1.backgroundAlpha = 0;
			codeInput1.setMode(Input.MODE_INPUT);
			codeInput1.updateTextFormat(textFormatCode);
			codeInput1.setBorderVisibility(false);
			codeInput1.S_CHANGED.add(onInputChanged);
			codeInput1.setLabelText(Lang.enterCode, 0x4C5F85);
			codeInput1.getTextField().maxChars = 7;
			codeInput1.getTextField().restrict = "A-Z0-9\\-^OI0";
			codeInput1.setMinValue(3);
			codeInput1.setDownBorder(true);
			codeInput1.setRoundBG(false);
			codeInput1.setRoundRectangleRadius(Config.FINGER_SIZE * .2);
			codeInput1.inUse = true;
			inputContainer = new Sprite();
			inputContainer.addChild(codeInput1.view);
			container.addChild(inputContainer);
			
			/*codeInput2 = new Input();
			codeInput2.backgroundColor = 0x2D384E;
			codeInput2.backgroundAlpha = 0;
			codeInput2.setMode(Input.MODE_INPUT);
			codeInput2.S_CHANGED.add(onInputChanged);
			codeInput2.updateTextFormat(textFormatCode);
			codeInput2.setBorderVisibility(false);
			codeInput2.setLabelText("XXX", 0x4C5F85);
			codeInput2.getTextField().maxChars = 3;
			codeInput2.getTextField().restrict = "A-Z0-9^OI01";
			codeInput2.setMinValue(3);
			codeInput2.setDownBorder(true);
			codeInput2.setRoundBG(false);
			codeInput2.setRoundRectangleRadius(Config.FINGER_SIZE * .2);
			codeInput2.inUse = true;
			inputContainer.addChild(codeInput2.view);*/
			
			inputContainer.y = Config.FINGER_SIZE;
			
			preloader = new Preloader();
			container.addChild(preloader);
			preloader.hide();
			preloader.visible = false;
		}
		
		private function onHelpClick():void {
			navigateToURL(new URLRequest(Lang.referralProgramHelpURL));
		}
		
		private function onInputChanged():void {
			if (errorText != null && errorText.bitmapData != null) {
				errorText.bitmapData.dispose();
				errorText.bitmapData = null;
			}
			/*if (codeInput1.value != null && codeInput1.value.length > 2) {
				codeInput2.setFocus();
				codeInput2.getTextField().setSelection(0, codeInput2.value.length - 1);
			}*/
			
			var newText:String = ReferralProgram.getPromocodeDescription(getCode());
			if (newText != null && newText != currentPromocodeText) {
				currentPromocodeText = newText;
				
				TweenMax.killTweensOf(text);
				TweenMax.killDelayedCallsTo(drawDescription);
				TweenMax.killDelayedCallsTo(repositionElements);
				
				TweenMax.to(text, 0.2, {alpha:0});
				TweenMax.delayedCall(0.2, drawDescription);
				TweenMax.delayedCall(0.2, repositionElements, [0.2]);
				TweenMax.to(text, 0.2, {alpha:1, delay:0.4});
			}
		}
		
		private function onButtonCancelClick():void {
			if (codeAccepted == true)
			{
				PHP.call_statVI("rtoLater");
			}
			hidePanel();
		}
		
		private function hidePanel():void {
			TweenMax.killTweensOf(text);
			TweenMax.killDelayedCallsTo(drawDescription);
			TweenMax.killDelayedCallsTo(repositionElements);
			TweenMax.killTweensOf(inputContainer);
			TweenMax.killTweensOf(cancelButton);
			TweenMax.killTweensOf(containerBack);
			TweenMax.killTweensOf(okButton);
			
			lockScreen(false);
			TweenMax.to(container, 0.3, {y: -container.height, onComplete:removePanel});
			TweenMax.to(background, 0.3, {alpha:0});
		}
		
		private function removePanel():void {
			ServiceScreenManager.closeView();
		}
		
		private function onButtonOkClick():void {
			if (codeSuccess == true) {
				hidePanel();
				PayAPIManager.openSwissRTO(getCode());
			} else {
				if (codeInput1.value != "") {
					if (getCode() != null && getCode().length == 6)
					{
						lockScreen();
						ReferralProgram.sendCode(getCode());
					}
					else{
						ToastMessage.display(Lang.wrongPromoCode);
					}
				}
			}
		}
		
		private function getCode():String {
			var value:String = codeInput1.value;
			if (value != null)
				value = value.replace("-", "");
			return value;
		}
		
		private function sendCodeResult(success:Boolean, errorMessage:String = null):void {
			if (success == true)
				onCodeSendSuccess();
			else
				displayError(errorMessage);
			unlockScreen();
		}
		
		private function onCodeSendSuccess():void {
			Auth.needToAskFirstQuestion = false;
			codeSuccess = true;
			if (_isDisposed)
				return;
			cancelButton.hide();
			helpButton.hide();
			okButton.hide();
			TweenMax.to(inputContainer, 0.3, {alpha:0, onComplete:showSuccessClips});
			TweenMax.to(text, 0.3, {alpha:0});
		}
		
		private function showSuccessClips():void {
			codeAccepted = true;
			//var okText:TextFieldSettings = new TextFieldSettings(Lang.textClose, 0xFFFFFF, Config.FINGER_SIZE * .26, TextFormatAlign.CENTER);
			var okText:TextFieldSettings = new TextFieldSettings(Lang.openAccount, 0xFFFFFF, Config.FINGER_SIZE * .26, TextFormatAlign.CENTER);
			var cancelText:TextFieldSettings = new TextFieldSettings(Lang.later, 0xFFFFFF, Config.FINGER_SIZE * .26, TextFormatAlign.CENTER);
			
			okButton.setBitmapData(TextUtils.createbutton(okText, 0, 0, -1, 0xFFFFFF, (_width - Config.MARGIN * 6) * .5), true);
			cancelButton.setBitmapData(TextUtils.createbutton(cancelText, 0, 0, -1, 0xFFFFFF, (_width - Config.MARGIN * 6) * .5), true);
			
			cancelButton.x = Config.MARGIN * 2;
			okButton.x = cancelButton.x + cancelButton.width + Config.MARGIN * 2;
			
		//	okButton.x = _width*.5 - okButton.width*.5;
			
			if (text.bitmapData != null){
				text.bitmapData.dispose();
				text.bitmapData = null;
			}
			
			text.bitmapData = TextUtils.createTextFieldData(Lang.referralCodeAccepted, _width - Config.MARGIN * 4, 10, true, TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .35, true, 0xFFFFFF, 0x2D384E);
			text.x = int(_width * .5 - text.width * .5);
			
			doneClip = new doneRoundIcon2();
			container.addChild(doneClip);
			UI.scaleToFit(doneClip, Config.FINGER_SIZE, Config.FINGER_SIZE);
			
			doneClip.x = int(_width * .5 - doneClip.width * .5);
			doneClip.alpha = 0;
			doneClip.y = int(Config.DOUBLE_MARGIN + Config.APPLE_TOP_OFFSET);
			text.y = int(doneClip.y + doneClip.height + Config.DOUBLE_MARGIN);
			
			cancelButton.show(0.3);
			cancelButton.activate();;
			
			okButton.y = container.y + container.height - okButton.height - Config.MARGIN * 2;
			cancelButton.y = container.y + container.height - okButton.height - Config.MARGIN * 2;
			okButton.show(0.3);
			okButton.activate();
			
			TweenMax.to(text, 0.3, {alpha:1});
			TweenMax.to(doneClip, 0.3, {alpha:1});
		}
		
		private function displayError(value:String):void {
			if (value != null)
				ToastMessage.display(value);
		}
		
		private function lockScreen(showPreloader:Boolean = true):void {
			locked = true;
			if (showPreloader == true){
				displayPreloader();
			}
			deactivateScreen();
		}
		
		private function unlockScreen():void {
			locked = false;
			hidePreloader();
			activateScreen();
		}
		
		private function displayPreloader():void {
			preloader.x = int(container.width * .5);
			preloader.y = int(container.height * .5);
			preloader.visible = true;
			preloader.show();
		}
		
		private function hidePreloader():void {
			if (preloader != null){
				preloader.hide();
			}
		}
		
		override protected function drawView():void {
			
		}
		
		override public function clearView():void {
			super.clearView();
		}
		
		override public function dispose():void {
			super.dispose();
			TweenMax.killTweensOf(text);
			TweenMax.killDelayedCallsTo(drawDescription);
			TweenMax.killDelayedCallsTo(repositionElements);
			TweenMax.killTweensOf(inputContainer);
			TweenMax.killTweensOf(cancelButton);
			TweenMax.killTweensOf(containerBack);
			TweenMax.killTweensOf(okButton);
			TweenMax.killTweensOf(container);
			TweenMax.killTweensOf(background);
			InnerNotificationManager.unpause();
			TweenMax.killChildTweensOf(container);
			
			if (preloader != null) {
				preloader.dispose();
				preloader = null;
			}
			if (okButton != null) {
				okButton.dispose();
				okButton = null;
			}
			if (cancelButton != null) {
				cancelButton.dispose();
				cancelButton = null;
			}
			if (codeInput1 != null) {
				codeInput1.dispose();
				codeInput1 = null;
			}
			if (inputContainer != null) {
				UI.destroy(inputContainer);
				inputContainer = null;
			}
			if (background != null) {
				UI.destroy(background);
				background = null;
			}
			if (text != null) {
				UI.destroy(text);
				text = null;
			}
			if (errorText != null) {
				UI.destroy(errorText);
				errorText = null;
			}
			if (container != null) {
				UI.destroy(container);
				container = null;
			}
			if (helpButton) {
				helpButton.dispose();
				helpButton = null;
			}
			if (doneClip) {
				UI.destroy(doneClip);
				doneClip = null;
			}
			ReferralProgram.refDialogWasClosed();
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			
			if (_isDisposed)
				return;
			
			if (locked)
				return;
			
			codeInput1.activate();
			
			okButton.activate();
			cancelButton.activate();
			helpButton.activate();
			
			showPanel();
		}
		
		private function showPanel():void {
			if (shown)
				return;
			
			shown = true;
			TweenMax.to(container, 0.3, {y:0});
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed)
				return;		
			okButton.deactivate();
			cancelButton.deactivate();
			
			codeInput1.deactivate();
			helpButton.deactivate();
		}
	}
}