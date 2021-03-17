package com.dukascopy.connect.screens.dialogs {
	import assets.CloseButtonIconWhite;
	import assets.SecureIcon;
	import assets.SecureImage;
	import com.adobe.utils.StringUtil;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.gui.button.RoundedButton;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.scrollPanel.ScrollPanel;
	import com.dukascopy.connect.gui.tools.StrenghtIndicator;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.base.ScreenParams;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.type.MainColors;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import com.greensock.easing.Quint;
	import com.greensock.TweenMax;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.StatusEvent;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class ScreenSetPinDialog extends BaseScreen {
		
		private var buttonClose:BitmapButton;
		private var message:Bitmap;
		private var serviceTextField:TextField;
		private var content:ScrollPanel;
		private var topImageBitmap:Bitmap;
		private var title:Bitmap;
		private var pinInput:Input;
		private var callback:Function;
		private var okButton:RoundedButton;
		private var inputOutline:Shape;
		private var passStrenghtIndicator:StrenghtIndicator;
		private var inputOutlineBitmap:Bitmap;
		private var pointerEnd:Shape;
		private var lastTopImageWidth:int = 0;
		private var background:Sprite;
		private var keyboardHeight:int = 0;
		
		public function ScreenSetPinDialog() {
			super();
		}
		
		override protected function createView():void
		{
			super.createView();
			
			var btnSize:int = Config.FINGER_SIZE*.4;
			var btnOffset:int = (Config.FINGER_SIZE - btnSize) * .5;
			
			background = new Sprite();
			view.addChild(background);
			
			content = new ScrollPanel();
			content.background = false;
			content.backgroundColor = MainColors.PINK_DARK;
			
			view.addChild(content.view);
			
			message = new Bitmap();
			content.addObject(message);
			
			title = new Bitmap();
			content.addObject(title);
			
			// INput field
			
			inputOutline = new Shape();
			content.addObject(inputOutline);
			
			inputOutlineBitmap = new Bitmap();
			content.addObject(inputOutlineBitmap);
			
			pinInput = new Input();
			pinInput.setRoundBG(true);
			pinInput.setRoundRectangleRadius(Config.MARGIN*.5);
			pinInput.setMode(Input.MODE_INPUT);
			pinInput.setLabelText(Lang.enterPIN);
			pinInput.inUse = true;
			content.addObject(pinInput.view);
			
			//close button;
			buttonClose = new BitmapButton();
			buttonClose.setStandartButtonParams();
			buttonClose.setDownScale(1.3);
			buttonClose.setDownColor(0xFFFFFF);
			buttonClose.tapCallback = onCloseTap;
			buttonClose.disposeBitmapOnDestroy = true;
			buttonClose.show();
			view.addChild(buttonClose);
			var iconClose:CloseButtonIconWhite = new CloseButtonIconWhite();
			iconClose.width = iconClose.height = btnSize;
			buttonClose.setBitmapData(UI.getSnapshot(iconClose, StageQuality.HIGH, "ScreenSetPinDialog.buttonClose"), true);
			buttonClose.setOverflow(btnOffset, int(btnOffset * .6), Config.FINGER_SIZE, btnOffset);
			UI.destroy(iconClose);
			iconClose = null;
			
			// OK Button
			okButton  = new RoundedButton(Lang.textOk, MainColors.RED, MainColors.RED_DARK, SecureIcon);
			okButton.setStandartButtonParams();
			okButton.setDownScale(1);
			okButton.cancelOnVerticalMovement = true;
			okButton.tapCallback = onOKClick;
			content.addObject(okButton);
			
			passStrenghtIndicator = new StrenghtIndicator();
			content.addObject(passStrenghtIndicator);
			
			pointerEnd = new Shape();
			pointerEnd.graphics.beginFill(0, 0);
			pointerEnd.graphics.drawRect(0, 0, 1, 1);
			pointerEnd.graphics.endFill();
			content.addObject(pointerEnd);
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
			TweenMax.killDelayedCallsTo(drawView);
			TweenMax.delayedCall(0.5, drawView);
		}
		
		private function onCloseTap():void {
			callback(0, null);
			callBack();
		}
		
		override public function onBack(e:Event = null):void
		{
			callback(0, null);
		}
		
		private function callBack(e:Event=null):void {
			DialogManager.closeDialog();
		}
		
		private function onOKClick(e:Event = null):void {
			var currentValue:String =  StringUtil.trim(pinInput.value);
			var defValue:String =  pinInput.getDefValue();			
			if (currentValue != "" && currentValue != defValue && currentValue.length>5) {
				
				callback(1, currentValue);
				callBack(e);
			} else {
				wiggle();
				return;	
			}
		}
		
		private function wiggle():void {
			TweenMax.killTweensOf(this._view);
			TweenMax.to(this._view, .1, { x: -10, ease:Quint.easeInOut } );
			TweenMax.to(this._view, .1, { x:10, ease:Quint.easeInOut, delay:.1 } );
			TweenMax.to(this._view, .1, { x: -10, ease:Quint.easeInOut, delay:.2 } );
			TweenMax.to(this._view, .1, { x:10, ease:Quint.easeInOut, delay:.3 } );
			TweenMax.to(this._view, .1, { x:0, ease:Quint.easeInOut, delay:.4 } );
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			callback = data.callBack;
		}
		
		override protected function drawView():void {
			
			onChangeInputValue();
			
			checkTopImage();
			
			var padding:int = Config.MARGIN * 2.9;
			
			var titleText:BitmapData = TextUtils.createTextFieldData(Lang.setPin,
																	_width - Config.MARGIN*4, 
																	1,
																	false,
																	TextFormatAlign.CENTER,
																	TextFieldAutoSize.LEFT,
																	Config.FINGER_SIZE * 0.65,
																	false,
																	MainColors.WHITE,
																	MainColors.PINK_DARK,
																	true);
			if (title.bitmapData) {				
				title.bitmapData.dispose();
				title.bitmapData = null;
			}
			title.bitmapData = titleText;
			title.x = int((_width - title.width)*.5);
			title.y = int(Config.FINGER_SIZE);
			
			pinInput.width = int(Math.min(Config.FINGER_SIZE * 4, _width - Config.FINGER_SIZE * 2));
			
			passStrenghtIndicator.setWidth(Math.min(Config.FINGER_SIZE * 3, _width - Config.FINGER_SIZE * 2));
			
			pinInput.view.y = int(title.y + title.height + Config.FINGER_SIZE * .3 + padding);
			pinInput.view.x = int(_width*.5 - pinInput.view.width*.5);
			
			passStrenghtIndicator.x = int(_width * .5 - passStrenghtIndicator.width * .5);
			passStrenghtIndicator.y = int(pinInput.view.y + pinInput.view.height + Config.FINGER_SIZE * .3 + padding);
			
			var inputOutline:Shape = new Shape();
			inputOutline.graphics.clear();
			inputOutline.graphics.lineStyle(Config.FINGER_SIZE * .6, 0x34222C, 0.3);
			inputOutline.graphics.drawRoundRect(0, 0, pinInput.view.width, pinInput.view.height, Config.MARGIN * 2, Config.MARGIN * 2);
			
			if (inputOutlineBitmap.bitmapData)
			{
				UI.disposeBMD(inputOutlineBitmap.bitmapData);
				inputOutlineBitmap.bitmapData = null;
			}
			
			var bmd:ImageBitmapData = new ImageBitmapData("ScreenSetPin.textOutline", 
															pinInput.view.width + Config.FINGER_SIZE * .6, 
															pinInput.view.height + Config.FINGER_SIZE * .6, 
															true, 0x000000);
			var matrix:Matrix = new Matrix();
			matrix.translate(Config.FINGER_SIZE * .3, Config.FINGER_SIZE * .3);
			bmd.drawWithQuality(inputOutline, matrix, null, null, null, false, StageQuality.HIGH);
			matrix = null;
			inputOutlineBitmap.bitmapData = bmd;
			inputOutlineBitmap.x = int(pinInput.view.x - Config.FINGER_SIZE * .3);
			inputOutlineBitmap.y = int(pinInput.view.y - Config.FINGER_SIZE * .3);
			bmd = null;
			
			var messageText:BitmapData = TextUtils.createTextFieldData(Lang.enterPinText,
																	pinInput.width, 
																	1,
																	true,
																	TextFormatAlign.CENTER,
																	TextFieldAutoSize.LEFT,
																	Config.FINGER_SIZE * 0.25,
																	true,
																	MainColors.WHITE,
																	MainColors.PINK_DARK,
																	true);
			if (message.bitmapData) {				
				message.bitmapData.dispose();
				message.bitmapData = null;
			}
			message.bitmapData = messageText;
			message.x = int((_width - message.width)*.5);
			message.y = int(passStrenghtIndicator.y + passStrenghtIndicator.height + padding*.75);
			
			okButton.setSizeLimits(Config.FINGER_SIZE*3.5, _width - padding*2);
			okButton.draw();
			
			okButton.x = int(_width * .5 - okButton.width * .5);
			okButton.y = int(message.y + message.height + padding);
			
			pointerEnd.y = okButton.y + okButton.height + padding - pointerEnd.height + Config.FINGER_SIZE;
			
			var contentHeight:int = Math.min(_height, content.itemsHeight);
			var popupHeight:int = Math.min(contentHeight + _width * .57, _height);
			
			popupHeight = Math.max(popupHeight, _width * .87);
			
			content.view.y = int(popupHeight - contentHeight);
			
			content.setWidthAndHeight(_width, contentHeight, false);
			if (!content.fitInScrollArea())
			{
				content.scrollToPosition(pinInput.view.y - padding);
				content.enable();
			}
			else {
				content.disable();
			}
			content.update();
			
			background.graphics.clear();
			background.graphics.beginFill(MainColors.PINK_DARK);
			background.graphics.drawRect(0, 0, _width, popupHeight);
			background.graphics.endFill();
			
			buttonClose.x = int(_width - buttonClose.width - Config.MARGIN*2.4);
			buttonClose.y = int(Config.MARGIN * 2.4);
			
			var maxHeight:int = _height;
			if (keyboardHeight > 100)
			{
				maxHeight = _height - keyboardHeight;
			}
			
			view.y = int(maxHeight - popupHeight);
			
			listenKeyboard();
		}
		
		private function checkTopImage():void 
		{
			// To draw this top image onece;
			if (!topImageBitmap || lastTopImageWidth != _width)
			{
				if (topImageBitmap)
				{
					UI.disposeBMD(topImageBitmap.bitmapData);
					topImageBitmap.bitmapData = null;
				}
				else
				{
					topImageBitmap = new Bitmap();
					view.addChild(topImageBitmap);
					view.setChildIndex(content.view, view.numChildren - 1);
					view.setChildIndex(buttonClose, view.numChildren - 1);
				}
				var image:SecureImage = new SecureImage();
				image.scaleX = _width/386;
				image.scaleY = image.scaleX;
				
				lastTopImageWidth = _width;
				
				var bmd:ImageBitmapData = new ImageBitmapData("ScreenSetPinDialog.topImage", 386*image.scaleX, 330*image.scaleY, true, 0x000000);
				bmd.drawWithQuality(image, image.transform.matrix, null, null, null, false, StageQuality.HIGH);
				topImageBitmap.bitmapData = bmd;
				bmd = null;
				UI.destroy(image);
				image = null;
			}
		}
		
		private function onChangeInputValue():void 
		{
			if(pinInput!=null){
				var currentValue:String =  StringUtil.trim(pinInput.value);
				var defValue:String =  pinInput.getDefValue();
				if (currentValue != "" && currentValue != defValue && currentValue.length>5) {					
					// activate button
					//btn0TF.alpha = 1;
					okButton.activate();
					okButton.alpha = 1;
					
				}else {
					// deactivate button 
					okButton.alpha = .5;
					okButton.deactivate();
					//btn0TF.alpha = .5;
				}
				passStrenghtIndicator.setStrenghtLevel(TextUtils.getPassStrenghtLevel((currentValue == defValue)?"":currentValue));
			}
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			okButton.activate();
			buttonClose.activate();
			
			if (!content.fitInScrollArea())
			{
				content.enable();
			}
			else {
				content.disable();
			}
			
			pinInput.activate();
			pinInput.S_CHANGED.add(onChangeInputValue);
		}
		
		override public function deactivateScreen():void {
			if (isDisposed) return;
			super.deactivateScreen();
			okButton.deactivate();
			buttonClose.deactivate();
			content.disable();
			
			pinInput.deactivate();
			pinInput.S_CHANGED.remove(onChangeInputValue);
		}
		
		private function close():void 
		{
			if (isDisposed) return;
			DialogManager.closeDialog();
		}		
		
		override public function dispose():void {
			if (isDisposed) return;
			super.dispose();
			
			TweenMax.killDelayedCallsTo(drawView);
			
			if (MobileGui.androidExtension != null)
			{
				MobileGui.androidExtension.removeEventListener(StatusEvent.STATUS, extensionAndroidStatusHandler);
			}
			if (MobileGui.dce != null)
			{
				MobileGui.dce.removeEventListener(StatusEvent.STATUS, statusHandlerApple);
			}
			
			if (buttonClose)
				buttonClose.dispose();
			buttonClose = null;
			
			if (okButton)
				okButton.dispose();
			okButton = null;
			
			if (message)
				UI.destroy(message);
			message = null;
			
			if (message)
				UI.destroy(message);
			message = null;
			
			if (background)
				UI.destroy(background);
			background = null;
			
			if (serviceTextField)
				serviceTextField.text = "";
			serviceTextField = null;
			
			callback = null;
			
			if (pinInput != null)
				pinInput.dispose();
			pinInput = null;
			
			if (content)
				content.dispose();
			content = null;
			
			if (topImageBitmap)
				UI.destroy(topImageBitmap);
			topImageBitmap = null;
			
			if (inputOutlineBitmap)
				UI.destroy(inputOutlineBitmap);
			inputOutlineBitmap = null;
			
			if (title)
				UI.destroy(title);
			title = null;
			
			if (title)
				UI.destroy(title);
			title = null;
			
			if (pointerEnd)
				UI.destroy(pointerEnd);
			pointerEnd = null;
			
			if (passStrenghtIndicator)
				passStrenghtIndicator.dispose();
			passStrenghtIndicator = null;
			
			lastTopImageWidth = 0;
		}
	}
}