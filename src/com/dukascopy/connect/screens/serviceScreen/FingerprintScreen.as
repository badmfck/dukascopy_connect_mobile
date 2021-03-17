package com.dukascopy.connect.screens.serviceScreen
{
	
	import assets.FingerprintIcon;
	import assets.IconSuccess;
	import avmplus.finish;
	import com.dukascopy.connect.*;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.gui.button.*;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.screens.base.*;
	import com.dukascopy.connect.screens.keyboardScreens.attachScreen.attachButtons.HorizontalActionButton;
	import com.dukascopy.connect.screens.keyboardScreens.attachScreen.attachButtons.SimpleActionButton;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.nativeExtensionController.NativeExtensionController;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.langs.*;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.greensock.TweenMax;
	import com.greensock.easing.Back;
	import com.greensock.easing.Power2;
	import flash.display.*;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import flash.geom.Transform;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	
	public class FingerprintScreen extends BaseScreen
	{
		private var background:Sprite;
		private var backButton:BitmapButton;
		private var container:Sprite;
		private var firstTime:Boolean = true;
		private var needExecute:Boolean;
		private var description:Bitmap;
		private var icon:Sprite;
		private var iconSuccess:Sprite;
		private var locked:Boolean;
		private var paddingOverride:int;
		
		public function FingerprintScreen() { }
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			paddingOverride = Config.DIALOG_MARGIN;
			
			_params.doDisposeAfterClose = true;
			
			var position:int = 0;
			
			position += Config.FINGER_SIZE * .5;
			
			drawDescription(Lang.fingerprintTouch);
			drawBackButton(Lang.textBack);
			
			description.y = position;
			position += description.height + Config.FINGER_SIZE * .7;
			
			icon.y = int(position + icon.height * .5);
			position += icon.height + Config.FINGER_SIZE * .7;
			
			icon.x = int(_width * .5);
			
			backButton.y = position;
			position += backButton.height + Config.FINGER_SIZE * .6;
			
			background.graphics.beginFill(0x000000, 0.35);
			background.graphics.drawRect( -paddingOverride, -paddingOverride, _width + paddingOverride * 2, _height + paddingOverride * 2);
			background.graphics.endFill();
			
			container.graphics.beginFill(0xFFFFFF);
			container.graphics.drawRect(-paddingOverride, 0, _width + paddingOverride * 2, position + Config.APPLE_BOTTOM_OFFSET);
			container.graphics.endFill();
			container.y = _height + paddingOverride;
			background.alpha = 0;
			
			description.x = int(_width * .5 - description.width * .5);
			backButton.x = int(_width * .5 - backButton.width * .5);
		}
		
		private function onTouchAction(actionCode:String):void 
		{
			if (actionCode == "1002")
			{
				uncolorizeIcon();
				TweenMax.killTweensOf(icon);
				TweenMax.to(icon, 0.3, {scaleX:1.3, scaleY:1.3, rotation:0});
			}
			else if (actionCode == "1003")
			{
				uncolorizeIcon();
				TweenMax.killTweensOf(icon);
				TweenMax.to(icon, 0.3, {scaleX:1, scaleY:1, rotation:0});
			}
		}
		
		override public function onBack(e:Event = null):void
		{
			close();
		}
		
		private function onNativePin(success:Boolean, pass:String, errorMessage:String = null):void 
		{
			if (success == true)
			{
				lock();
				
				animateSuccess(pass);
			}
			else
			{
				animateFail();
			//	TweenMax.delayedCall(1, close);
				TweenMax.killDelayedCallsTo(displayMessage);
				if (errorMessage != null)
				{
					TweenMax.delayedCall(0.5, displayMessage, [errorMessage]);
				}
			}
		}
		
		private function displayMessage(text:String):void 
		{
			if (isDisposed == false)
			{
				ToastMessage.display(text);
			}
		}
		
		private function onNativePinError(success:Boolean, pass:String, errorMessage:String = null):void 
		{
			if (success == true)
			{
				
			}
			else
			{
				animateFail();
				TweenMax.delayedCall(1, close);
				ToastMessage.display(errorMessage);
			}
		}
		
		private function animateFail():void 
		{
			UI.colorize(icon, 0xCD3F43);
			TweenMax.to(icon, 0.1, {rotation:10});		
			TweenMax.to(icon, 0.1, {rotation:-10, delay:0.1});
			TweenMax.to(icon, 0.1, {rotation:10, delay:0.2});
			TweenMax.to(icon, 0.1, {rotation:-10, delay:0.3});
			TweenMax.to(icon, 0.1, {rotation:0, delay:0.4});
			TweenMax.delayedCall(0.5, uncolorizeIcon);
		}
		
		private function uncolorizeIcon():void
		{
			if (_isDisposed == true)
			{
				return;
			}
			
			icon.transform.colorTransform = new ColorTransform();
		}
		
		private function lock():void 
		{
			locked = true;
		}
		
		private function animateSuccess(pass:String):void 
		{
			TweenMax.killTweensOf(icon);
			TweenMax.to(icon, 0.4, {scaleX:0.7, scaleY:0.7, rotation:90, alpha:0});
			
			if (iconSuccess == null)
			{
				iconSuccess = new Sprite();
				var clip:IconSuccess = new IconSuccess();
				UI.scaleToFit(clip, Config.FINGER_SIZE * .9, Config.FINGER_SIZE * .9);
				iconSuccess.addChild(clip);
				clip.x = -int(clip.width * .5);
				clip.y = -int(clip.height * .5);
				container.addChild(iconSuccess);
			}
			
			iconSuccess.x = icon.x;
			iconSuccess.y = icon.y;
			iconSuccess.alpha = 0;
			iconSuccess.rotation = -90;
			iconSuccess.scaleX = 0.7;
			iconSuccess.scaleY = 0.7;
			
			TweenMax.to(iconSuccess, 0.8, {scaleX:1, scaleY:1, alpha:1, rotation:0, delay:0.1, ease:Back.easeOut});
			TweenMax.delayedCall(1.5, fireSuccess, [pass]);
		}
		
		private function fireSuccess(pass:String):void 
		{
			if (_isDisposed == true)
			{
				return;
			}
			
			if (data != null && "callback" in data && data.callback != null)
			{
				data.callback(pass);
			}
			close();
		}
		
		private function drawBackButton(text:String):void {
			var textSettings:TextFieldSettings = new TextFieldSettings(text, 0xFFFFFF, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, 0x3599CD, 1, Config.FINGER_SIZE * .8, NaN, _width * .5 - Config.MARGIN - Config.DIALOG_MARGIN);
			backButton.setBitmapData(buttonBitmap, true);
		}
		
		private function drawDescription(text:String):void {
			if (description.bitmapData != null)
			{
				description.bitmapData.dispose();
				description.bitmapData = null;
			}
			
			description.bitmapData = TextUtils.createTextFieldData(
				text,
				_width - Config.DIALOG_MARGIN * 2,	
				10,
				true,
				TextFormatAlign.CENTER,
				TextFieldAutoSize.LEFT,
				Config.FINGER_SIZE * .35,
				true,
				0x586270
			);
		}
		
		override protected function createView():void {
			super.createView();
			
			background = new Sprite();
			view.addChild(background);
			
			container = new Sprite();
			view.addChild(container);
			
			backButton = new BitmapButton();
			backButton.setStandartButtonParams();
			backButton.setDownScale(1);
			backButton.setDownColor(0);
			backButton.tapCallback = backClick;
			backButton.disposeBitmapOnDestroy = true;
			backButton.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
			container.addChild(backButton);
			
			description = new Bitmap();
			container.addChild(description);
			
			icon = new Sprite();
			container.addChild(icon);
			var clip:FingerprintIcon = new FingerprintIcon();
			UI.scaleToFit(clip, Config.FINGER_SIZE, Config.FINGER_SIZE);
			icon.addChild(clip);
			clip.x = -int(clip.width * .5);
			clip.y = -int(clip.height * .5);
		}
		
		private function backClick():void 
		{
			if (locked == true)
			{
				return;
			}
			close();
		}
		
		override protected function drawView():void {
			super.drawView();
			view.graphics.clear();
		}
		
		override public function clearView():void {
			super.clearView();
		}
		
		override public function dispose():void {
			super.dispose();
			
			TweenMax.killDelayedCallsTo(uncolorizeIcon);
			TweenMax.killDelayedCallsTo(fireSuccess);
			TweenMax.killDelayedCallsTo(close);
			TweenMax.killDelayedCallsTo(displayMessage);
			
			TweenMax.killTweensOf(icon);
			TweenMax.killTweensOf(container);
			TweenMax.killTweensOf(background);
			
			NativeExtensionController.S_PIN.remove(onNativePin);
			NativeExtensionController.S_PIN_ACTION.remove(onTouchAction);
			NativeExtensionController.S_PIN_ERROR.remove(onNativePinError);
			NativeExtensionController.stopFingerprint();
			
			if (background != null)
			{
				UI.destroy(background);
				background = null;
			}
			if (container != null)
			{
				UI.destroy(container);
				container = null;
			}
			if (iconSuccess != null)
			{
				TweenMax.killTweensOf(iconSuccess);
				UI.destroy(iconSuccess);
				iconSuccess = null;
			}
			if (backButton != null)
			{
				backButton.dispose();
				backButton = null;
			}
			if (container != null)
			{
				UI.destroy(background);
				background = null;
			}
		}
		
		override public function activateScreen():void
		{
			super.activateScreen();
			
			if (_isDisposed)
			{
				return;
			}
			
			if (firstTime)
			{
				firstTime = false;
				TweenMax.to(container, 0.3, {y:int(_height - container.height + Config.APPLE_BOTTOM_OFFSET), ease:Power2.easeOut, onComplete:startListenFingerprint});
				TweenMax.to(background, 0.3, {alpha:1});
			}
			
			backButton.activate();
			
			PointerManager.addTap(background, close);
		}
		
		private function startListenFingerprint():void 
		{
			if (isDisposed == true)
			{
				return;
			}
			NativeExtensionController.S_PIN.add(onNativePin);
			NativeExtensionController.S_PIN_ERROR.add(onNativePinError);
			NativeExtensionController.S_PIN_ACTION.add(onTouchAction);
			NativeExtensionController.startListenFingerprint();
		}
		
		public function close(e:Event = null):void 
		{
			Overlay.removeCurrent();
			deactivateScreen();
			TweenMax.to(container, 0.3, {y:_height, onComplete:remove, ease:Power2.easeIn});
			TweenMax.to(background, 0.3, {alpha:0});
		}
		
		private function remove():void 
		{
			if (data != null && data.onClosed != null)
			{
				data.onClosed();
			}
		}
		
		override public function deactivateScreen():void
		{
			super.deactivateScreen();
			
			if (_isDisposed)
			{
				return;
			}
			
			backButton.deactivate();
			
			PointerManager.removeTap(background, close);
		}
		
		public function updatePositions():void 
		{
			background.graphics.clear();
			background.graphics.beginFill(0x000000, 0.35);
			background.graphics.drawRect( -paddingOverride, -paddingOverride, _width + paddingOverride * 2, _height + paddingOverride * 2);
			background.graphics.endFill();
			
			TweenMax.killTweensOf(container);
			TweenMax.killTweensOf(background);
			container.y = int(_height - container.height + Config.DIALOG_MARGIN + Config.APPLE_BOTTOM_OFFSET);
			startListenFingerprint();
			background.alpha = 1;
		}
	}
}