package com.dukascopy.connect.screens.promocodes
{
	
	import assets.ReferralDoneIcon;
	import assets.ReferralDukIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.gui.button.RoundedButton;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.preloader.Preloader;
	import com.dukascopy.connect.gui.scrollPanel.ScrollPanel;
	import com.dukascopy.connect.gui.topBar.TopBarScreen;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.payments.PayAPIManager;
	import com.dukascopy.connect.sys.promocodes.ReferralProgram;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.softKeyboard.SoftKeyboard;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.type.MainColors;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import flash.display.Bitmap;
	import flash.display.CapsStyle;
	import flash.display.LineScaleMode;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.StatusEvent;
	import flash.events.TextEvent;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Dobarin Sergey
	 */
	
	public class EnterPromocodeScreen extends BaseScreen
	{
		private var topBar:TopBarScreen;
		private var scrollPanel:ScrollPanel;
		private var preloader:Preloader;
		private var locked:Boolean;
		private var okButton:BitmapButton;
		private var background:Sprite;
		private var cancelButton:BitmapButton;
		private var codeInput1:Input;
		private var codeInput2:Input;
		private var inputContainer:Sprite;
		private var title:Bitmap;
		private var subtitle:Bitmap;
		private var codeSuccess:Boolean;
		private var doneClip:doneRoundIcon3;
		private var iconDuk:Bitmap;
		private var iconSuccess:Bitmap;
		private var bottomClip:Sprite;
		private var buttonPadding:Number;
		private var topClip:Sprite;
		private var keyboardHeight:int = 0;
		private var codeAccepted:Boolean;
		
		public function EnterPromocodeScreen() { }
		
		override public function onBack(e:Event = null):void {
			ServiceScreenManager.closeView();
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			buttonPadding = Config.DOUBLE_MARGIN;
			
			_params.title = 'Enter promocode screen';
			_params.doDisposeAfterClose = true;
			
			//drawHeader();
			topBar.setData(Lang.referralProgram, true);
			topBar.drawView(_width);
			
			background.graphics.beginFill(0xFFFFFF);
			background.graphics.drawRect(0, 0, _width, _height - topBar.trueHeight);
			background.y = topBar.trueHeight;
			
			drawButtonCancel(Lang.textBack);
			drawButtonOK(Lang.textSend);
			
			codeInput1.width = Config.FINGER_SIZE * 1.6;
			codeInput2.width = Config.FINGER_SIZE * 1.6;
			codeInput1.view.x = int((_width - Config.FINGER_SIZE * 3.2 - Config.FINGER_SIZE * .3) * .5);
			codeInput2.view.x = int(codeInput1.view.x + codeInput1.width + Config.FINGER_SIZE * .3);
			
			title.bitmapData = TextUtils.createTextFieldData(Lang.referralCode, _width - Config.DIALOG_MARGIN * 2, 10, true, TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, FontSize.TITLE_1, true, Style.color(Style.COLOR_TEXT), Style.color(Style.COLOR_BACKGROUND));
			subtitle.bitmapData = TextUtils.createTextFieldData(Lang.enterInviteCode, _width - Config.DIALOG_MARGIN * 2, 10, true, TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, FontSize.BODY * 1.17, true, Style.color(Style.COLOR_SUBTITLE), Style.color(Style.COLOR_BACKGROUND));
			
			drawInputUnderline(Style.color(Style.COLOR_LINE_LIGHT));
			SoftKeyboard.S_REAL_HEIGHT_DETECTED.add(updateViewPort);
			ReferralProgram.S_CODE_SEND_RESULT.add(sendCodeResult);
			
			updatePositions();
			
			listenKeyboard();
		}
		
		private function updateViewPort():void 
		{
			updatePositions();
		}
		
		private function listenKeyboard():void 
		{
			if (Config.PLATFORM_ANDROID == true)
			{
			//	MobileGui.androidExtension.addEventListener(StatusEvent.STATUS, extensionAndroidStatusHandler);
			}
			else if (Config.PLATFORM_APPLE == true)
			{
				MobileGui.dce.addEventListener(StatusEvent.STATUS, statusHandlerApple);
			}
		}
		
		private function statusHandlerApple(e:StatusEvent):void {
			var data:Object;
			switch (e.code) {
				case "inputViewHeightChangeStart":
				case "inputViewKeyboardShowStart":
				case "inputViewKeyboardHideStart":
				case "inputViewHeightChangeEnd":
				case "inputViewKeyboardShowEnd":
				case "inputViewKeyboardHideEnd": {
					data = JSON.parse(e.level);
					
					if ("inputViewHeight" in data)
						keyboardHeight = data.inputViewHeight;
					break;
				}
			}
		}
		
		private function extensionAndroidStatusHandler(e:StatusEvent):void
		{
			if (e.code == "keyboardHeight")
			{
				keyboardHeight = parseInt(e.level);
				updateOnNative();
			}
		}
		
		private function updateOnNative():void 
		{
			TweenMax.killDelayedCallsTo(updatePositions);
			TweenMax.delayedCall(0.5, updatePositions);
		}
		
		private function drawInputUnderline(color:Number):void 
		{
			inputContainer.graphics.lineStyle(Math.max(2, Config.FINGER_SIZE * .02), color, 1, false, LineScaleMode.NORMAL, CapsStyle.NONE);
			
			inputContainer.graphics.moveTo(int(codeInput1.view.x), int(codeInput1.height));
			inputContainer.graphics.lineTo(int(codeInput1.view.x + codeInput1.view.width + codeInput2.view.width) + Config.FINGER_SIZE * .3, int(codeInput1.height));
			
			inputContainer.graphics.lineStyle(Math.max(2, Config.FINGER_SIZE * .02), Style.color(Style.COLOR_SUBTITLE), 1, false, LineScaleMode.NORMAL, CapsStyle.NONE);
			
			inputContainer.graphics.moveTo(int(_width * .5 - Config.FINGER_SIZE * .1), int(codeInput1.view.y + codeInput1.getTextField().y + codeInput1.getTextField().height * .5));
			inputContainer.graphics.lineTo(int(_width * .5 + Config.FINGER_SIZE * .1), int(codeInput1.view.y + codeInput1.getTextField().y + codeInput1.getTextField().height * .5));
		}
		
		private function updatePositions():void 
		{
			var maxHeight:int = _height;
			if (keyboardHeight > 100)
			{
				maxHeight = _height - keyboardHeight;
			}
			
			var buttonsPosition:int = maxHeight - buttonPadding - okButton.height - Config.APPLE_BOTTOM_OFFSET;
			
			cancelButton.x = buttonPadding;
			okButton.x = cancelButton.x + cancelButton.width + buttonPadding;
			
			cancelButton.y = buttonsPosition;
			okButton.y = buttonsPosition;
			
			scrollPanel.view.y = topBar.trueHeight;
			scrollPanel.setWidthAndHeight(_width, buttonsPosition - topBar.trueHeight - buttonPadding, false);
			
			iconDuk.x = int(scrollPanel.getWidth() * .5 - iconDuk.width * .5);
			iconSuccess.x = int(scrollPanel.getWidth() * .5 - iconSuccess.width * .5);
			
			title.x = int(scrollPanel.getWidth() * .5 - title.width * .5);
			subtitle.x = int(scrollPanel.getWidth() * .5 - subtitle.width * .5);
			
			var minimumPadding:int = Config.FINGER_SIZE * .5;
			var padding:int = (scrollPanel.height - iconDuk.height - title.height - subtitle.height - Config.FINGER_SIZE * .16 - inputContainer.height) / 5;
			padding = Math.max(padding, minimumPadding);
			
			var position:int = padding;
			
			iconDuk.y = position;
			position += iconDuk.height + padding;
			
			title.y = position;
			position += title.height + Config.FINGER_SIZE * .16;
			
			subtitle.y = position;
			position += subtitle.height + padding * 1;
			
			inputContainer.y = position;
			position += inputContainer.height + padding * 1.5;
			
			bottomClip.y = position;
			
			scrollPanel.update();
		}
		
		private function drawButtonCancel(text:String):void {
			var textSettings:TextFieldSettings = new TextFieldSettings(text, Style.color(Style.COLOR_TEXT), FontSize.BODY, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, Style.color(Style.COLOR_BACKGROUND), 1, -1, Style.color(Style.COLOR_LINE_SSL), (_width - buttonPadding * 3) * .5, -1, Style.size(Style.SIZE_BUTTON_CORNER));
			cancelButton.setBitmapData(buttonBitmap, true);
		}
		
		private function drawButtonOK(text:String):void {
			var textSettings:TextFieldSettings = new TextFieldSettings(text, Style.color(Style.COLOR_BACKGROUND), FontSize.BODY, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, Color.GREEN, 1, -1, NaN, (_width - buttonPadding * 3) * .5, -1, Style.size(Style.SIZE_BUTTON_CORNER));
			okButton.setBitmapData(buttonBitmap, true);
		}
		
		override protected function createView():void {
			super.createView();
			
			background = new Sprite();
			view.addChild(background);
			
			scrollPanel = new ScrollPanel();
			scrollPanel.background = true;
			scrollPanel.backgroundColor = Style.color(Style.COLOR_BACKGROUND);
			_view.addChild(scrollPanel.view);
			
			topBar = new TopBarScreen();
			_view.addChild(topBar);
			
			preloader = new Preloader();
			_view.addChild(preloader);
			preloader.hide();
			preloader.visible = false;
			
			okButton = new BitmapButton();
			okButton.setStandartButtonParams();
			okButton.setDownScale(1);
			okButton.setDownColor(NaN);
			okButton.setOverlay(HitZoneType.BUTTON);
			okButton.cancelOnVerticalMovement = true;
			okButton.tapCallback = onButtonOkClick;
			_view.addChild(okButton);
			
			cancelButton = new BitmapButton();
			cancelButton.setStandartButtonParams();
			cancelButton.setDownColor(NaN);
			cancelButton.setDownScale(1);
			cancelButton.setOverlay(HitZoneType.BUTTON);
			cancelButton.cancelOnVerticalMovement = true;
			cancelButton.tapCallback = onButtonCancelClick;
			_view.addChild(cancelButton);
			
			iconDuk = new Bitmap();
			scrollPanel.addObject(iconDuk);
			iconSuccess = new Bitmap();
		//	scrollPanel.addObject(iconSuccess);
			var icon:Sprite = new ReferralDukIcon();
			UI.scaleToFit(icon, Config.FINGER_SIZE * 1.8, Config.FINGER_SIZE * 1.8);
			iconDuk.bitmapData = UI.getSnapshot(icon);
			icon = new ReferralDoneIcon();
			UI.scaleToFit(icon, Config.FINGER_SIZE * 1.8, Config.FINGER_SIZE * 1.8);
			iconSuccess.bitmapData = UI.getSnapshot(icon);
			
			title = new Bitmap();
			scrollPanel.addObject(title);
			
			subtitle = new Bitmap();
			scrollPanel.addObject(subtitle);
			
			var textFormatCode:TextFormat = new TextFormat();
			textFormatCode.size = Config.FINGER_SIZE * .45;
			textFormatCode.align = TextFormatAlign.CENTER;
			
			codeInput1 = new Input();
			codeInput1.backgroundColor = Style.color(Style.COLOR_BACKGROUND);
			codeInput1.backgroundAlpha = 0;
			codeInput1.setMode(Input.MODE_INPUT);
			codeInput1.updateTextFormat(textFormatCode);
			codeInput1.setBorderVisibility(false);
			codeInput1.setLabelText("XXX", Style.color(Style.COLOR_SUBTITLE));
			codeInput1.getTextField().maxChars = 3;
			codeInput1.getTextField().restrict = "A-Z0-9^OI0";
			codeInput1.setMinValue(3);
			codeInput1.setDownBorder(true);
			codeInput1.setRoundBG(false);
			codeInput1.setRoundRectangleRadius(Config.FINGER_SIZE * .2);
			codeInput1.inUse = true;
			codeInput1.S_CHANGED.add(onFirstCodeChange);
			inputContainer = new Sprite();
			inputContainer.addChild(codeInput1.view);
			scrollPanel.addObject(inputContainer);
			codeInput1.getTextField().addEventListener(TextEvent.TEXT_INPUT, onCodePaste);
			
			codeInput2 = new Input();
			codeInput2.backgroundColor = Style.color(Style.COLOR_BACKGROUND);
			codeInput2.backgroundAlpha = 0;
			codeInput2.setMode(Input.MODE_INPUT);
			codeInput2.updateTextFormat(textFormatCode);
			codeInput2.setBorderVisibility(false);
			codeInput2.setLabelText("XXX", Style.color(Style.COLOR_SUBTITLE));
			codeInput2.getTextField().maxChars = 3;
			codeInput2.getTextField().restrict = "A-Z0-9^OI0";
			codeInput2.setMinValue(3);
			codeInput2.setDownBorder(true);
			codeInput2.setRoundBG(false);
			codeInput2.setRoundRectangleRadius(Config.FINGER_SIZE * .2);
			codeInput2.inUse = true;
			inputContainer.addChild(codeInput2.view);
			codeInput2.getTextField().addEventListener(TextEvent.TEXT_INPUT, onCodePaste);
			
			inputContainer.y = Config.FINGER_SIZE;
			
			topClip = new Sprite();
			topClip.graphics.beginFill(0, 0);
			topClip.graphics.drawRect(0, 0, 1, 1);
			topClip.graphics.endFill();
			scrollPanel.addObject(topClip);
			
			bottomClip = new Sprite();
			bottomClip.graphics.beginFill(0, 0);
			bottomClip.graphics.drawRect(0, 0, 1, 1);
			bottomClip.graphics.endFill();
			scrollPanel.addObject(bottomClip);
		}
		
		private function onCodePaste(e:TextEvent):void 
		{
			if (e.text != null)
			{
				if (e.text.length == 7 && e.text.indexOf("-") == 3)
				{
					e.stopPropagation();
					e.stopImmediatePropagation();
					e.preventDefault();
					var values:Array = e.text.split("-");
					codeInput1.value = values[0];
					codeInput2.value = values[1];
					codeInput2.getTextField().setSelection(3, 3);
				}
				else if (e.text.length == 6)
				{
					e.stopPropagation();
					e.stopImmediatePropagation();
					e.preventDefault();
					codeInput1.value = e.text.substr(0, 3);
					codeInput2.value = e.text.substr(3, 3);
					codeInput2.getTextField().setSelection(3, 3);
				}
			}
		}
		
		private function onFirstCodeChange():void 
		{
			if (codeInput1 != null && codeInput1.value != null && codeInput1.value.length == 3)
			{
				MobileGui.stage.focus = null;
				codeInput2.setFocus();
			}
		}
		
		private function onButtonCancelClick():void {
			ServiceScreenManager.closeView();
		}
		
		private function onButtonOkClick():void {
			if (codeSuccess == true) {
				onBack();
			}
			else {
				if (codeInput1.value != "" && codeInput2.value != "") {
					lockScreen();
					ReferralProgram.sendCode(codeInput1.value + codeInput2.value);
				}
			}
		}
		
		private function sendCodeResult(success:Boolean, errorMessage:String = null):void {
			if (success == true)
				onCodeSendSuccess();
			else
				displayError(errorMessage);
			
			unlockScreen();
		}
		
		private function onCodeSendSuccess():void {
			codeAccepted = true;
			codeSuccess = true;
			
			cancelButton.hide();
			okButton.hide();
			
			TweenMax.to(subtitle, 0.3, {alpha:0, onComplete:showSuccessClips});
			TweenMax.to(title, 0.3, {alpha:0});
			TweenMax.to(inputContainer, 0.3, {alpha:0});
			cancelButton.deactivate();
			scrollPanel.removeObject(cancelButton);
		}
		
		private function showSuccessClips():void {
			if (isDisposed == true)
			{
				return;
			}
			if (title.bitmapData != null){
				title.bitmapData.dispose();
				title.bitmapData = null;
			}
			title.bitmapData = TextUtils.createTextFieldData(Lang.referralCodeAccepted, _width - Config.MARGIN * 4, 10, true, TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .35, true, 0x000000, 0xFFFFFF);
			title.x = int((_width - Config.MARGIN * 2) * .5 - title.width * .5);
			
			scrollPanel.addObject(iconSuccess);
			iconSuccess.alpha = 0;
			
			iconSuccess.x = int(_width * .5 - iconSuccess.width * .5);
			iconSuccess.alpha = 0;
			scrollPanel.removeObject(subtitle);
			scrollPanel.removeObject(iconDuk);
			scrollPanel.removeObject(inputContainer);
			
			TweenMax.to(title, 0.3, {alpha:1});
			TweenMax.to(iconSuccess, 0.3, {alpha:1});
			drawButtonOK(Lang.textOk);
			okButton.x = _width * .5 - okButton.width * .5;
			okButton.show(0.3);
			
			var buttonsPosition:int = _height - buttonPadding - okButton.height - Config.APPLE_BOTTOM_OFFSET;
			
			scrollPanel.view.y = topBar.trueHeight;
			scrollPanel.setWidthAndHeight(_width, buttonsPosition - topBar.trueHeight - buttonPadding, false);
			
			iconSuccess.x = int(scrollPanel.getWidth() * .5 - iconSuccess.width * .5);
			
			title.x = int(scrollPanel.getWidth() * .5 - title.width * .5);
			
			var minimumPadding:int = Config.FINGER_SIZE * .5;
			var padding:int = (scrollPanel.height - iconSuccess.height - title.height) / 5;
			padding = Math.max(padding, minimumPadding);
			
			var position:int = padding * 2;
			
			iconSuccess.y = position;
			position += iconSuccess.height + padding;
			
			title.y = position;
			position += title.height + padding * 2;			
			bottomClip.y = position;
			
			scrollPanel.update();
		}
		
		private function displayError(value:String):void {
			if (value == null)
				return;
			
			ToastMessage.display(value);
		}
		
		private function lockScreen():void {
			locked = true;
			displayPreloader();
			deactivateScreen();
		}
		
		private function unlockScreen():void {
			locked = false;
			hidePreloader();
			activateScreen();
		}
		
		private function displayPreloader():void {
			preloader.x = _width * .5;
			preloader.y = _height * .5;
			preloader.visible = true;
			preloader.show();
		}
		
		private function hidePreloader():void {
			preloader.hide();
		}
		
		override protected function drawView():void {
			scrollPanel.update();
			updateViewPort();
		}
		
		override public function clearView():void {
			super.clearView();
		}
		
		private function stopListenKeyboard():void 
		{
			if (Config.PLATFORM_ANDROID == true)
			{
				MobileGui.androidExtension.removeEventListener(StatusEvent.STATUS, extensionAndroidStatusHandler);
			}
			else if (Config.PLATFORM_APPLE == true)
			{
				MobileGui.dce.removeEventListener(StatusEvent.STATUS, statusHandlerApple);
			}
		}
		
		override public function dispose():void {
			super.dispose();
			stopListenKeyboard();
			TweenMax.killDelayedCallsTo(updatePositions);
			TweenMax.killChildTweensOf(view);
			TweenMax.killDelayedCallsTo(updateViewPort);
			SoftKeyboard.S_REAL_HEIGHT_DETECTED.remove(updateViewPort);
			
			TweenMax.killTweensOf(subtitle);
			TweenMax.killTweensOf(iconSuccess);
			TweenMax.killTweensOf(title);
			TweenMax.killTweensOf(inputContainer);
			
			if (topBar != null)
				topBar.dispose();
			topBar = null;
			
			if (scrollPanel != null) {
				scrollPanel.dispose();
				scrollPanel = null;
			}
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
				if (codeInput1.getTextField() != null)
				{
					codeInput1.getTextField().removeEventListener(TextEvent.TEXT_INPUT, onCodePaste);
				}
				codeInput1.dispose();
				codeInput1 = null;
			}
			if (codeInput2 != null) {
				if (codeInput2.getTextField() != null)
				{
					codeInput2.getTextField().removeEventListener(TextEvent.TEXT_INPUT, onCodePaste);
				}
				codeInput2.dispose();
				codeInput2 = null;
			}
			if (inputContainer != null) {
				UI.destroy(inputContainer);
				inputContainer = null;
			}
			if (background != null) {
				UI.destroy(background);
				background = null;
			}
			if (subtitle != null) {
				UI.destroy(subtitle);
				subtitle = null;
			}
			if (title != null) {
				UI.destroy(title);
				title = null;
			}
			if (subtitle != null) {
				UI.destroy(subtitle);
				subtitle = null;
			}
			if (doneClip != null) {
				UI.destroy(doneClip);
				doneClip = null;
			}
			if (iconDuk != null) {
				UI.destroy(iconDuk);
				iconDuk = null;
			}
			if (iconSuccess != null) {
				UI.destroy(iconSuccess);
				iconSuccess = null;
			}
			
			if (topClip != null) {
				UI.destroy(topClip);
				topClip = null;
			}
			if (bottomClip != null) {
				UI.destroy(bottomClip);
				bottomClip = null;
			}
			
			ReferralProgram.S_CODE_SEND_RESULT.remove(sendCodeResult);
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			if (_isDisposed)
				return;
			if (locked)
				return;
			if (topBar != null)
				topBar.activate();
			scrollPanel.enable();
			
			codeInput1.activate();
			codeInput2.activate();
			
			okButton.activate();
			cancelButton.activate();
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed)
				return;
			if (topBar != null)
				topBar.deactivate();		
			okButton.deactivate();
			cancelButton.deactivate();
			
			codeInput1.deactivate();
			codeInput2.deactivate();
			
			scrollPanel.disable();
		}
	}
}