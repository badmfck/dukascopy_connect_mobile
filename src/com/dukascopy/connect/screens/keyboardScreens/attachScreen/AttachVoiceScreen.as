package com.dukascopy.connect.screens.keyboardScreens.attachScreen
{
	
	import assets.MicDown;
	import assets.MicUp;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.LocalSoundFileData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.base.ScreenParams;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.connectionManager.NetworkManager;
	import com.dukascopy.connect.sys.nativeExtensionController.NativeExtensionController;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.ws.WS;
	import com.dukascopy.connect.utils.GeometryUtils;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import com.greensock.easing.Power1;
	import com.greensock.easing.Power2;
	import com.greensock.TweenMax;
	import com.telefision.sys.signals.Signal;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.events.TouchEvent;
	import flash.filesystem.File;
	import flash.geom.Point;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class AttachVoiceScreen extends BaseScreen
	{
		private var bg:Shape;
		
		private var timer:Timer;
		private var maxTime:int = 60;
		
		private var buttonRecord:Sprite;
		private var radius:int;
		private var micUp:MicUp;
		private var micDown:MicDown;
		private var recordAnimation:Sprite;
		private var currentState:String;
		private var startPoint:Point;
		private var currentPoint:Point;
		private var circleWhite:Sprite;
		private var animationMask:Sprite;
		private var hintLabel:Bitmap;
		private var timeLabel:Bitmap;
		private var discardLabel:Bitmap;
		private var sendLabel:Bitmap;
		private var startRecordTime:int;
		private var permissionsGranted:Boolean = false;
		
		public static var S_SEND_VOICE_MESSAGE:Signal = new Signal("AttachVoiceScreen.S_SEND_VOICE_MESSAGE");
		
		static public const RECORD_DISCARD:String = "recordDiscard";
		static public const RECORD:String = "record";
		static public const IDLE:String = "idle";
		
		public function AttachVoiceScreen()
		{
			super();
		}
		
		override protected function createView():void
		{
			super.createView();
			
			bg = new Shape();
			bg.graphics.beginFill(0xF9F9F9);
			bg.graphics.drawRect(0, 0, 10, 10);
			bg.graphics.endFill();
			
			_view.addChild(bg);
			
			buttonRecord = new Sprite();
			_view.addChild(buttonRecord);
			
			recordAnimation = new Sprite();
			recordAnimation.mouseEnabled = false;
			recordAnimation.mouseChildren = false;
			_view.addChild(recordAnimation);
			
			micUp = new MicUp();
			micUp.mouseEnabled = false;
			micUp.mouseChildren = false;
			_view.addChild(micUp);
			
			micDown = new MicDown();
			micDown.mouseEnabled = false;
			micDown.mouseChildren = false;
			_view.addChild(micDown);
			
			micUp.visible = false;
			micDown.visible = false;
			
			startPoint = new Point(0, 0);
			currentPoint = new Point();
			
			circleWhite = new Sprite();
			circleWhite.mouseEnabled = false;
			circleWhite.mouseChildren = false;
			_view.addChild(circleWhite);
			circleWhite.alpha = 0;
			
			animationMask = new Sprite();
			animationMask.graphics.beginFill(0);
			animationMask.graphics.drawRect(0, 0, 10, 10);
			animationMask.graphics.endFill();
			_view.addChild(animationMask);
			animationMask.mouseEnabled = false;
			animationMask.mouseChildren = false;
			recordAnimation.mask = animationMask;
			
			hintLabel = new Bitmap();
			_view.addChild(hintLabel);
			
			discardLabel = new Bitmap();
			_view.addChild(discardLabel);
			
			sendLabel = new Bitmap();
		//	_view.addChild(sendLabel);
			
			timeLabel = new Bitmap();
			_view.addChild(timeLabel);
			
			timeLabel.visible = false;
			discardLabel.visible = false;
			sendLabel.visible = false;
		}
		
		public function showRecent():void
		{
			
		}
		
		override public function initScreen(data:Object = null):void
		{
			super.initScreen(data);
			
			radius = int(_height * .25);
			
			drawCircles();
			
			UI.scaleToFit(micUp, radius, radius);
			UI.scaleToFit(micDown, radius, radius);
			
			micUp.visible = true;
			micDown.visible = false;
			
			micUp.x = micDown.x = int(buttonRecord.x - micUp.width*.5);
			micUp.y = micDown.y = int(buttonRecord.y - micUp.height * .5);
			
			animationMask.width = _width;
			animationMask.height = _height;
			
			timeLabel.visible = false;
			
			if (hintLabel.bitmapData)
			{
				hintLabel.bitmapData.dispose();
				hintLabel.bitmapData = null;
			}
			
			if (sendLabel.bitmapData)
			{
				sendLabel.bitmapData.dispose();
				sendLabel.bitmapData = null;
			}
			
			if (discardLabel.bitmapData)
			{
				discardLabel.bitmapData.dispose();
				discardLabel.bitmapData = null;
			}
			
			hintLabel.bitmapData = TextUtils.createTextFieldData(
																Lang.holdToRecord, 
																_width, 
																10, 
																false, 
																TextFormatAlign.LEFT, 
																TextFieldAutoSize.LEFT, 
																Config.FINGER_SIZE * .3, 
																false, 
																0xA2A2A5, 
																0xF9F9F9, 
																true);
			
			sendLabel.bitmapData = TextUtils.createTextFieldData(
																Lang.releaseToSend, 
																_width, 
																10, 
																false, 
																TextFormatAlign.LEFT, 
																TextFieldAutoSize.LEFT, 
																Config.FINGER_SIZE * .3, 
																false, 
																0xDA3A39, 
																0xF9F9F9, 
																true);
			
			discardLabel.bitmapData = TextUtils.createTextFieldData(
																Lang.releaseToCancel, 
																_width, 
																10, 
																false, 
																TextFormatAlign.LEFT, 
																TextFieldAutoSize.LEFT, 
																Config.FINGER_SIZE * .3, 
																false, 
																0xFFFFFF, 
																0xDA3A39, 
																true);
			
			
			discardLabel.x = int(recordAnimation.x - discardLabel.width * .5 );
			discardLabel.y = int((recordAnimation.y - radius) * .5 - discardLabel.height * .5);
			
			sendLabel.x = int(recordAnimation.x - sendLabel.width * .5 );
			sendLabel.y = int((recordAnimation.y - radius) * .5 - sendLabel.height * .5);
			
			hintLabel.x = int(recordAnimation.x - hintLabel.width * .5 );
			hintLabel.y = int((recordAnimation.y - radius) * .5 - hintLabel.height * .5);
			
			hintLabel.visible = true;
			sendLabel.visible = false;
			discardLabel.visible = false;
			
			requestPermissions();
		}
		
		private function requestPermissions():void 
		{
			if (Config.PLATFORM_ANDROID == true)
			{
				NativeExtensionController.S_PERMISSION.add(onPermissionsResult);
				NativeExtensionController.requestSoundPermission();
				micUp.alpha = 0.3;
			}
		}
		
		private function onPermissionsResult(permission:String, success:Boolean):void 
		{
			if (permission == NativeExtensionController.RECORD_SOUND_PERMISSIONS) {
				NativeExtensionController.S_PERMISSION.remove(onPermissionsResult);
				permissionsGranted = success;
				
				if (isDisposed == false) {
					if (permissionsGranted == true) {
						micUp.alpha = 1;
						PointerManager.addDown(buttonRecord, startRecord);
					}
				}
			}
		}
		
		private function drawCircles():void 
		{
			buttonRecord.graphics.clear();
			buttonRecord.graphics.beginFill(0xE4E4E8);
			buttonRecord.graphics.drawCircle(0, 0, radius);
			buttonRecord.graphics.endFill();
			
			buttonRecord.x = int(_width*.5);
			buttonRecord.y = int(_height * .5);
			
			recordAnimation.graphics.clear();
			recordAnimation.graphics.beginFill(0xDA3A39);
			recordAnimation.graphics.drawCircle(0, 0, radius);
			recordAnimation.graphics.endFill();
			
			recordAnimation.x = int(_width*.5);
			recordAnimation.y = int(_height * .5);
			
			recordAnimation.visible = false;
			
			circleWhite.graphics.clear();
			circleWhite.graphics.beginFill(0xFFFFFF);
			circleWhite.graphics.drawCircle(0, 0, radius);
			circleWhite.graphics.endFill();
			
			circleWhite.x = int(_width*.5);
			circleWhite.y = int(_height * .5);
			circleWhite.alpha = 0;
		}
		
		override protected function drawView():void
		{
			if (_isDisposed)
				return;
			
			bg.width = _width;
			bg.height = _height;	
		}
		
		override public function activateScreen():void
		{
			if (_isDisposed) return;
			
			if (isAvaliable())
			{
				PointerManager.addDown(buttonRecord, startRecord);
			}
		}
		
		private function isAvaliable():Boolean 
		{
			if (Config.PLATFORM_ANDROID == true)
				return permissionsGranted;
			return true;
		}
		
		private function startRecord(e:Event = null):void
		{
			circleWhite.alpha = 0;
			currentState = RECORD;
			
			micUp.visible = false;
			micDown.visible = true;
			recordAnimation.visible = true;
			
			PointerManager.addUp(this.view, stopRecord);
			PointerManager.addMove(this.view, onMove);
			
			animatePress();
			
			timeLabel.visible = true;
			drawTimeLabel("0:00");
			updateTimeLabelPosition();
			
			sendStartRecordToNativeSide();
			
			hintLabel.visible = false;
			sendLabel.visible = false;
			discardLabel.visible = false;
			
			startRecordTime = getTimer();
			
			startTimer();
		}
		
		private function animatePress():void 
		{
			var k:Number = 0.3;
			
			TweenMax.to(recordAnimation, 0.5*k, { scaleX:1.4, scaleY:1.4, ease:Power2.easeIn } );
			TweenMax.to(recordAnimation, 0.4*k, { scaleX:0.9, scaleY:0.9, delay:0.5*k, ease:Power2.easeInOut } );
			TweenMax.to(recordAnimation, 0.1*k, { scaleX:1, scaleY:1, delay:0.9*k, ease:Power2.easeInOut } );
		}
		
		private function sendStartRecordToNativeSide():void 
		{
			if (Config.PLATFORM_ANDROID)
			{
				if (MobileGui.androidExtension)
				{
					MobileGui.androidExtension.startRecord(File.cacheDirectory.url.slice(6));
				}
			}
		}
		
		private function sendStopRecordToNativeSide():void 
		{
			if (Config.PLATFORM_ANDROID)
			{
				if (MobileGui.androidExtension)
				{
					MobileGui.androidExtension.stopRecord();
				}
			}
		}
		
		private function startTimer():void
		{
			timer = new Timer(1000, maxTime);
			timer.addEventListener(TimerEvent.TIMER, update);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, onMaxTimeProgressBar);
			timer.start();
		}
		
		private function update(e:TimerEvent):void 
		{
			if (isDisposed)
			{
				if (timer)
				{
					timer.stop();
					timer = null;
				}
				return;
			}
			
			drawTimeLabel(getCurrentTime());
			
			if (timer != null && timer.currentCount == maxTime && (currentState == RECORD || currentState == RECORD_DISCARD)) {
				sendStopRecordToNativeSide();
			}
			
			updateTimeLabelPosition();
		}
		
		private function drawTimeLabel(currentTime:String):void 
		{
			if (timeLabel.bitmapData)
			{
				timeLabel.bitmapData.dispose();
				timeLabel.bitmapData = null;
			}
			
			timeLabel.bitmapData = TextUtils.createTextFieldData(currentTime, _width, 10, false, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .3, false, 0xDA3A39, 0xF9F9F9, true);
		}
		
		private function getCurrentTime():String 
		{
			if (!timer)
			{
				return "0:00";
			}
			
			if (timer.currentCount == maxTime)
			{
				if (currentState == RECORD)
				{
					return Lang.releaseToSend;
				}
				else if (currentState == RECORD_DISCARD)
				{
					return "1:00";
				}
			}
			
			var result:String = (timer.currentCount % maxTime).toString();
			if (result.length == 1)
			{
				result = "0" + result;
			}
			result = ":" + result;
			result = Math.floor(timer.currentCount / maxTime) + result;
			
			return result;
		}
		
		private function updateTimeLabelPosition():void 
		{
			if (currentState == RECORD)
			{
				timeLabel.x = int(recordAnimation.x - timeLabel.width * .5 );
				timeLabel.y = int((recordAnimation.y - radius) * .5 - timeLabel.height * .5);
			}
			else if(currentState == RECORD_DISCARD)
			{
				timeLabel.x = int(recordAnimation.x - timeLabel.width * .5 );
				timeLabel.y = int(recordAnimation.y - timeLabel.height * .5);
			}
		}
		
		private function onMaxTimeProgressBar(e:TimerEvent):void
		{
			
		}
		
		private function stopRecord(e:Event = null):void
		{
			var lastState:String = currentState;
			currentState = IDLE;
			micUp.visible = true;
			micDown.visible = false;
			recordAnimation.visible = false;
			circleWhite.alpha = 0;
			PointerManager.removeUp(this.view, stopRecord);
			PointerManager.removeMove(this.view, onMove);
			
			timeLabel.visible = false;
			
			if (isActivated)
			{
				send();
			}
			
			TweenMax.killTweensOf(recordAnimation);
			TweenMax.killTweensOf(circleWhite);
			recordAnimation.scaleX = recordAnimation.scaleY = 1;
			
			hintLabel.visible = true;
			sendLabel.visible = false;
			discardLabel.visible = false;
			
			sendStopRecordToNativeSide();
			
			if (lastState == RECORD)
			{
				TweenMax.delayedCall(1, sendVoice);
			}
		}
		
		private function sendVoice():void 
		{
			if (ChatManager.getCurrentChat())
			{
				var time:int = (getTimer() - startRecordTime)/1000;
				ChatManager.sendVoice(new LocalSoundFileData(File.cacheDirectory.url + "/recorded.mp4", time));
			}
		}
		
		private function send():void 
		{
			if (WS.connected == false || NetworkManager.isConnected == false)
			{
				return;
			}
			
			S_SEND_VOICE_MESSAGE.invoke();
		}
		
		override public function deactivateScreen():void
		{
			super.deactivateScreen();
			if (_isDisposed) return;
			
			PointerManager.removeDown(buttonRecord, startRecord);
			PointerManager.removeUp(this.view, stopRecord);
			PointerManager.removeMove(this.view, onMove);
		}
		
		private function onMove(e:Event = null):void 
		{
			if (e is MouseEvent)
			{
				currentPoint.x = (e as MouseEvent).stageX - _width*.5;
				currentPoint.y = (e as MouseEvent).stageY - _height * .5;
			}
			else if (e is TouchEvent)
			{
				currentPoint.x = (e as TouchEvent).stageX - _width*.5;
				currentPoint.y = (e as TouchEvent).stageY - _height * .5;
			}
			
			currentPoint = _view.globalToLocal(currentPoint);
			
			var isFingerOnButton:Boolean = GeometryUtils.distance(startPoint, currentPoint) < radius;
			
			var lastState:String = currentState;
			
			if (isFingerOnButton && currentState != IDLE)
			{
				currentState = RECORD;
			}
			else
			{
				currentState = RECORD_DISCARD;
			}	
			
			if (currentState == RECORD && lastState != currentState)
			{
				micDown.visible = true;
				
				TweenMax.killTweensOf(circleWhite);
				TweenMax.killTweensOf(recordAnimation);
				TweenMax.to(circleWhite, 0.5, { alpha:0 } );
				TweenMax.to(recordAnimation, 0.5, { scaleX:1, scaleY:1 } );
				
				drawTimeLabel(getCurrentTime());
				updateTimeLabelPosition();
				
				hintLabel.visible = false;
				sendLabel.visible = true;
				discardLabel.visible = false;
			}
			else if (currentState == RECORD_DISCARD && lastState != currentState)
			{
				micDown.visible = false;
				
				TweenMax.killTweensOf(circleWhite);
				TweenMax.killTweensOf(recordAnimation);
				TweenMax.to(circleWhite, 0.5, { alpha:1 } );
				TweenMax.to(recordAnimation, 0.5, { scaleX:4, scaleY:4 } );
				
				drawTimeLabel(getCurrentTime());
				updateTimeLabelPosition();
				
				hintLabel.visible = false;
				sendLabel.visible = false;
				discardLabel.visible = true;
			}
		}
		
		override public function dispose():void {
			if (_isDisposed == true) {
				return;
			}
			
			TweenMax.killTweensOf(circleWhite);
			TweenMax.killTweensOf(recordAnimation);
			TweenMax.killDelayedCallsTo(sendVoice);
			
			if (bg != null) {
				UI.destroy(bg);
				bg = null;
			}
			if (timer != null) {
				timer.stop();
				timer = null;
			}
			if (buttonRecord != null) {
				UI.destroy(buttonRecord);
				buttonRecord = null;
			}
			if (micUp != null) {
				UI.destroy(micUp);
				micUp = null;
			}
			if (micDown != null) {
				UI.destroy(micDown);
				micDown = null;
			}
			if (recordAnimation != null) {
				UI.destroy(recordAnimation);
				recordAnimation = null;
			}
			if (circleWhite != null) {
				UI.destroy(circleWhite);
				circleWhite = null;
			}
			if (animationMask != null) {
				UI.destroy(animationMask);
				animationMask = null;
			}
			if (hintLabel != null) {
				UI.destroy(hintLabel);
				hintLabel = null;
			}
			if (timeLabel != null) {
				UI.destroy(timeLabel);
				timeLabel = null;
			}
			if (discardLabel != null) {
				UI.destroy(discardLabel);
				discardLabel = null;
			}
			if (sendLabel != null) {
				UI.destroy(sendLabel);
				sendLabel = null;
			}
			
			startPoint = null;
			currentPoint = null;
			NativeExtensionController.S_PERMISSION.remove(onPermissionsResult);
			
			super.dispose();
		}
	}
}