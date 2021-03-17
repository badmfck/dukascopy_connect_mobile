package com.dukascopy.connect.screens.call {
	
	import assets.IconCamera;
	import assets.IconEndCall;
	import assets.IconHelp;
	import assets.IconHelp2;
	import assets.IconMicOff;
	import assets.IconMicOn;
	import assets.IconPhoto;
	import assets.Shadow;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.RtoAgreementData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.progress.ProgressNavigator;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.screens.base.ScreenParams;
	import com.dukascopy.connect.screens.serviceScreen.RtoAgreementScreen;
	import com.dukascopy.connect.sys.callManager.CallManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.idleManager.IdleManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.nativeExtensionController.NativeExtensionController;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.proximity.ProximityController;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.vo.CallVO;
	import com.greensock.TweenMax;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.media.Camera;
	import flash.media.CameraPosition;
	import flash.media.Video;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	/**
	*	@author Ilya Shcherbakov, Telefision A.G. Team - RIGA
	*/
	
	public class VideoRecognitionScreenSmall extends TalkScreen {
		
		private static var INFO_BMD:ImageBitmapData;
		private static var SPEACH_BLUE_BMD:ImageBitmapData;
		private static var SPEACH_RED_BMD:ImageBitmapData;
		
		private var btnInfo:BitmapButton;
		
		protected var stateProgress:IProgressIndicator;
		
		private var stateContainer:Sprite;
		private var stateMask:Shape;
		private var stateBMP:Bitmap;
		private var stateIBMD:ImageBitmapData;
		private var lastRecognitionState:int = -1;

		
		private var indicator:Sprite;
		private var buttonsContainer:Sprite;
		private var showUITime:Number = 4;
		private var animationUITime:Number = 0.3;
		
		private var speachInicator:Bitmap;
		private var codePopup:VideoRecognitionCodePopupSmall;
		private var shadowTop:Bitmap;
		private var shadowBottom:Bitmap;
		private var videoMask:Shape;
		
		public function VideoRecognitionScreenSmall() {
			
		}
		
		override public function onBack(e:Event = null):void {
			
		}
		
		override public function initScreen(data:Object = null):void{
			_params = new ScreenParams("Video recognition screen");
			
			buttonsContainer = new Sprite();
			
			BUTTON_SIZE = Config.FINGER_SIZE * .8;
			
			var bitmapPlane2:BitmapData;
			var half:int = _width * .5;
			generateCacahedAssets();
			
			myCameraSprite = new Sprite();
				myCameraVideo = new Video();
			myCameraSprite.addChild(myCameraVideo);
			_view.addChild(myCameraSprite);
			
			stateContainer = new Sprite();
			stateContainer.x = stateContainer.y = 0;
			stateMask = new Shape();
			stateMask.graphics.beginFill(0);
			stateMask.graphics.drawRect(0, 0, _width, _height);
			stateMask.graphics.endFill();
			stateContainer.addChild(stateMask);
			
			
			
			
			// videobox
			incomeVideoBox = new Sprite();
			//_view.addChild(incomeVideoBox);
			
			speachInicator = new Bitmap();
			
			speachInicator.x = _width - Config.FINGER_SIZE * .5 + Config.FINGER_SIZE * .75 * .5;
			speachInicator.y = Config.APPLE_TOP_OFFSET + Config.FINGER_SIZE * .5 - Config.FINGER_SIZE * .75 * .5;
			speachInicator.alpha = 0;
			// DROP CALL
			btnInfo = new BitmapButton();
			btnInfo.setStandartButtonParams();
			btnInfo.setBitmapData(INFO_BMD, true);
			btnInfo.setDownScale(1);
			btnInfo.tapCallback = onBtnInfo;
			
			btnInfo.show();
			buttonsContainer.addChild(btnInfo);
			
		   	btnSwitchCams = new BitmapButton();
			btnSwitchCams.setStandartButtonParams();
			btnSwitchCams.setDownScale(1);
			btnSwitchCams.setBitmapData(SWITCH_CAMERA_BMD,true);
			btnSwitchCams.setDownScale(1);
			btnSwitchCams.tapCallback = onBtnSwitchCams;
			btnSwitchCams.show();
			buttonsContainer.addChild(btnSwitchCams);
			
			if (!Camera.names || Camera.names.length == 1 || Camera.names.length == 0)
			{
				btnSwitchCams.visible = false;
			}
			
			myCamSize = Config.FINGER_SIZE * 1.2;
			
			//avatarbox
			avatarSize = _width  * .25;
				incomeAvatarBox = new Sprite();
					incomeAvatar = new Bitmap();
				incomeAvatarBox.addChild(incomeAvatar);
			_view.addChild(incomeAvatarBox);
			
			incomeVideoSprite = new Sprite();
			incomeVideo = new Video();
			
			/*debug = new TextField();
			debug.background = true;
			debug.border = true;
			debug.width = 300;
			debug.multiline = true;
			debug.wordWrap = true;
			debug.autoSize = TextFieldAutoSize.LEFT;
			debug.y = 240;
			debug.alpha = .8;
			_view.addChild(debug);*/
			
			indicator = new Sprite();
		//	_view.addChild(indicator);		
			
			buttonsContainer.x = 0;
			
			_view.addChild(buttonsContainer);
			
			_view.addChild(speachInicator);
			
			/*shadowTop = new Bitmap();
			_view.addChild(shadowTop);
			
			shadowBottom = new Bitmap();
			_view.addChild(shadowBottom);
			
			var shadowClip:Shadow = new Shadow();
			shadowClip.height = Config.FINGER_SIZE * .1;
			shadowClip.width = _width;
			shadowClip.alpha = 0.3;
			
			shadowTop.bitmapData = UI.getSnapshot(shadowClip, StageQuality.HIGH, "VideoRecognitionScreenSmall.topShadow");
			
			shadowClip.height = Config.FINGER_SIZE * .14;
			shadowClip.width = _width;
			shadowClip.alpha = 0.33;
			
			shadowBottom.bitmapData = UI.getSnapshot(shadowClip, StageQuality.HIGH, "VideoRecognitionScreenSmall.topShadow");
			shadowBottom.y = _height;*/
			
			videoMask = new Shape();
			videoMask.graphics.beginFill(0);
			videoMask.graphics.drawRect(0, 0, _width, _height);
			videoMask.graphics.endFill();
			view.addChild(videoMask);
			
			myCameraSprite.mask = videoMask;
			
			showState();
			
			// fill data
			onCallVOChanged();
			
			// check stream
			onStreamReady();
			
			updateStateIndicator();
		}
		
		override protected function onBtnSwitchCams():void {
			onScreenTap();
			CallManager.changeCamera();
			drawView();
		}
		
		private function onBtnInfo():void {
			if (_isDisposed)
				return;
			if (stateContainer == null)
				return;
			if (stateContainer.parent != null)
				return;
			TweenMax.killTweensOf(stateContainer);
			TweenMax.killDelayedCallsTo(removeState);
			_view.addChildAt(stateContainer, 1);
			stateContainer.alpha = 0;
			TweenMax.to(stateContainer, 1, { alpha:1, onComplete:onStateShowed } );
		}
		
		override protected function generateCacahedAssets():void {
			INFO_BMD ||= UI.renderAsset(new IconHelpBlack(), BUTTON_SIZE, BUTTON_SIZE, true);
			SPEACH_BLUE_BMD ||= UI.renderAsset(new SWFLoudButtonBlue(), int(Config.FINGER_SIZE * .75), int(Config.FINGER_SIZE * .75), true);
			SPEACH_RED_BMD ||= UI.renderAsset(new SWFLoudButtonRed(), int(Config.FINGER_SIZE * .75), int(Config.FINGER_SIZE * .75), true);
			
			MICROPHONE_ON_BMD ||= UI.renderAsset(new IconMicOn(), BUTTON_SIZE, BUTTON_SIZE, true);
			MICROPHONE_OFF_BMD ||= UI.renderAsset(new IconMicOff(), BUTTON_SIZE, BUTTON_SIZE, true);
			SWITCH_CAMERA_BMD ||= UI.renderAsset(new IconPhotoBlack(), BUTTON_SIZE, BUTTON_SIZE, true);
			MEDIA_SOURCE_VIDEO_BMD ||= UI.renderAsset(new IconCamera(), BUTTON_SIZE, BUTTON_SIZE, true);
		}
		
		override protected function onCallVOChanged():void {
			
			if (CallManager.getCallVO().showAgreement == true && CallManager.getCallVO().rto != null) {
				CallManager.getCallVO().showAgreement = false;
				ServiceScreenManager.closeView();
				ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, RtoAgreementScreen, {data:CallManager.getCallVO().rto, callback:rtoAgreementCallback});
				return;
			}
			
			if (CallManager.getCallVO().mode == CallManager.MODE_AUDIO) {
				if (myCameraVideo != null) {
					myCameraVideo.attachCamera(null);
					echo("VideoRecognitionScreen", "onCallVOChanged", "Removing camera:" + CallManager.camera);
				}
				ProximityController.start();
			} else {
				if (myCameraVideo != null) {
					echo("VideoRecognitionScreen", "onCallVOChanged", "Attaching camera:" + CallManager.camera);
					myCameraVideo.attachCamera(CallManager.camera);
					ProximityController.stop()
				}
			} 
			
			if (indicator != null && indicator.parent != null){
				indicator.graphics.clear();
				indicator.graphics.beginFill((CallManager.isMicrophoneMuted()==false)?0x00FF00:0xFF0000);
				indicator.graphics.drawRect(0, 0, 100, 100);
			}
			
			drawView();
			showState();
			
			updateStateIndicator();
		}
		
		private function rtoAgreementCallback(agree:Boolean):void {
			CallManager.sendRtoResponse(agree, CallManager.getCallVO().rto);
		}
		
		private function updateStateIndicator():void 
		{			
			var cvo:CallVO =  CallManager.getCallVO();
			if (cvo != null){				
				if (cvo.farEncMic && cvo.nearEncMic){				
										
				}else{								
					
				}
			}
		}
		
		public function showState(forceShow:Boolean=false):void {			
			if (_isDisposed)
				return;
			if (CallManager.getCallVO() == null)
				return;
			if (CallManager.getCallVO().recognitionState == -1)
				return;
				
			if (forceShow==false){
				if (CallManager.getCallVO().recognitionState == lastRecognitionState)
					return;
			}
				
			if (stateBMP == null) {
				stateBMP ||= new Bitmap();
				stateBMP.mask = stateMask;
				stateContainer.addChild(stateBMP);
			}
			TweenMax.killTweensOf(stateContainer);
			TweenMax.killDelayedCallsTo(removeState);
			if (stateContainer.parent == null)
				_view.addChildAt(stateContainer, 1);
			stateContainer.alpha = 0;
			if (stateIBMD != null)
				stateIBMD.dispose();
			lastRecognitionState = CallManager.getCallVO().recognitionState;
			if (stateProgress != null)
			{
				stateProgress.selectStep(lastRecognitionState, true);
			}
			
		//	stateIBMD = Assets.getAsset(Assets["VIDEO_RECOGNITION_STATE_" + CallManager.getCallVO().recognitionState]);
		//	stateIBMD = ImageManager.resize(stateIBMD, stateMask.width, stateMask.height, ImageManager.SCALE_PORPORTIONAL);
			
			stateIBMD = getStateHelpImageBitmapData(CallManager.getCallVO().recognitionState, stateMask.width, stateMask.height);
			
			if (stateBMP.bitmapData)
			{
				stateBMP.bitmapData.dispose();
				stateBMP.bitmapData = null;
			}
			
			stateBMP.bitmapData = stateIBMD;
			if (stateBMP.width > stateMask.width) {
				stateBMP.y = 0;
				stateBMP.x = -int((stateBMP.width - stateMask.width) * .5);
			} else {
				stateBMP.y = -int((stateBMP.height - stateMask.height) * .5);
				stateBMP.x = 0;
			}
			TweenMax.to(stateContainer, 1, { alpha:1, onComplete:onStateShowed } );
			
			showUI();
		}
		
		private function getStateHelpImageBitmapData(stateIndex:int, imageWidth:int, imageHeight:int):ImageBitmapData 
		{
			var callModel:CallVO = CallManager.getCallVO();
			var source:Sprite;
			switch(stateIndex)
			{
				case -1:
					source = new assets.RecognitionStep1();
					break;
				case 1:
					if (CallManager.getCallVO().documentType == CallManager.DOCUMENT_TYPE_ID)
					{
						source = new assets.RecognitionStep2();
					}
					else if (CallManager.getCallVO().documentType == CallManager.DOCUMENT_TYPE_PASSPORT)
					{
						source = new assets.RecognitionPassState2();
					}
					
					break;
				case 2:
					
					if (CallManager.getCallVO().documentType == CallManager.DOCUMENT_TYPE_ID)
					{
						source = new assets.RecognitionStep3();
					}
					else if (CallManager.getCallVO().documentType == CallManager.DOCUMENT_TYPE_PASSPORT)
					{
						source = new assets.RecognitionPassState2();
					}
					
					break;
				case 3:
					source = new assets.RecognitionStep4();
					break;
			}
			if (source)
			{
				var result:ImageBitmapData = new ImageBitmapData("VideoRecognitionScreen.halpBackImage", imageWidth, imageHeight, false, 0x222533);
				var matrixMove:Matrix = new Matrix();
				
				var k:Number = Math.min((imageWidth - Config.FINGER_SIZE) / source.width, (imageHeight - Config.FINGER_SIZE) / source.height);
				
				matrixMove.scale(k, k);
			//	matrixMove.rotate(Math.PI / 2);
				/*if (stateIndex == -1)
				{
					matrixMove.translate(-imageWidth*.5 + source.width*k*.5 + imageWidth, imageHeight*.5 - source.height*k*.5);
				}
				else {
					matrixMove.translate(source.height * k, imageHeight * .5 - source.width * k * .5);
				}*/
				
				matrixMove.translate(imageWidth * .5 - source.width * k * .5, imageHeight - source.height * k);
				
				result.drawWithQuality(source, matrixMove, null, null, null, false, StageQuality.HIGH);
				return result;
			}
			return null;
		}
		
		private function onStateShowed():void {
			if (_isDisposed)
				return;
			echo("VideoRecognitionScreen", "onStateShowed");
			TweenMax.delayedCall(5, removeState);
		}
		
		private function removeState():void {
			if (_isDisposed)
				return;
			echo("VideoRecognitionScreen", "removeState");
			if (stateContainer == null)
				return;
			if (stateContainer.parent == null)
				return;
			stateContainer.parent.removeChild(stateContainer);
		}
		
		override public function activateScreen():void{
			if (_isDisposed) {
				_isActivated = false;
				return;
			}
			_isActivated = true;
			CallManager.S_STREAM_READY.add(onStreamReady);
			CallManager.S_VIDEO_SIZE_CHANGED.add(onVideoSizeChanged);
			CallManager.S_CALLVO_CHANGED.add(onCallVOChanged);
			CallManager.S_SECURITY_CODE.add(showCodeNumber);
			PointerManager.addDown(MobileGui.stage, onScreenTap);
			
			btnInfo.activate();
		//	btnMute.activate();
		//	btnSwitch.activate();
			btnSwitchCams.activate();
			
			onStreamReady();
			stopRenderingBitmap();
			//btnWokitoki.activate();
			onCallVOChanged();
			
			showUI();
			IdleManager.keepAwake(true);
			
			if (codePopup) {
				codePopup.activate();
			}
		}
		
		private function showUI():void {
			if (!btnHangup)
				return;
			
			//TweenMax.killTweensOf(btnWokitoki);
			//TweenMax.killTweensOf(btnInfo);

			TweenMax.killTweensOf(speachInicator);
			
			TweenMax.killDelayedCallsTo(hideUI);
			TweenMax.killDelayedCallsTo(showUI);
			
			TweenMax.delayedCall(animationUITime, onUIShown);
			TweenMax.delayedCall(showUITime, hideUI);
			
			TweenMax.to(speachInicator, animationUITime, { alpha:0 } );
		}
		
		private function onUIShown():void {
			btnHangup.activate();
			//btnWokitoki.activate();
			//btnInfo.activate();
		}
		
		private function onScreenTap(e:Event = null):void {
			TweenMax.killDelayedCallsTo(hideUI);
			showUI();
		}
		
		private function hideUI():void {
			btnHangup.deactivate();
			
			TweenMax.killTweensOf(speachInicator);
			
			TweenMax.to(speachInicator, animationUITime, { alpha:1 } );
		}
		
		override public function deactivateScreen():void {
			_isActivated = false;
			CallManager.S_STREAM_READY.remove(onStreamReady);
			CallManager.S_VIDEO_SIZE_CHANGED.remove(onVideoSizeChanged);
		//	CallManager.S_CALLVO_CHANGED.remove(onCallVOChanged);
			CallManager.S_SECURITY_CODE.remove(showCodeNumber);
			btnSwitchCams.deactivate();
			ProximityController.stop();
			btnInfo.deactivate();
			PointerManager.removeDown(MobileGui.stage, onScreenTap);
			IdleManager.keepAwake(false);
			
			if (codePopup) {
				codePopup.deactivate();
			}
		}
		
		private function showCodeNumber(code:String):void {
			if (codePopup == null) {
				codePopup = new VideoRecognitionCodePopupSmall();
				codePopup.setSizes(_width - Config.DOUBLE_MARGIN, _height - Config.DOUBLE_MARGIN);
				codePopup.x = Config.MARGIN;
				codePopup.y = Config.MARGIN;
				codePopup.POPUP_CLOSE.add(closeCodePopup);
				if (_isActivated) {
					codePopup.activate();
				}
			}
			if (codePopup.parent == null)
				_view.addChild(codePopup);
			codePopup.display(code);
		}
		
		private function closeCodePopup():void {
			if (codePopup) {
				codePopup.POPUP_CLOSE.remove(closeCodePopup);
				codePopup.destroy();
				if (codePopup.parent != null)
					codePopup.parent.removeChild(codePopup);
				codePopup = null;
			}
		}
		
		override public function stopRenderingBitmap():void{
			if (incomeVideo != null){
				if (incomeVideo.parent == null)
					incomeVideoSprite.addChild(incomeVideo);
			}
		}
		
		override public function startRenderingBitmap():void{
			if (incomeVideo != null){
				if (incomeVideo.parent != null)
					incomeVideo.parent.removeChild(incomeVideo);
			}
		}
		
		override protected function drawView():void{
			if (isDisposed)
				return;
			
			_view.graphics.clear();
			_view.graphics.beginFill(0x212433);
			_view.graphics.drawRect(0, 0, _width, _height);
			
			videoMask.width = _width;
			videoMask.height = _height;
			
			// Setup avatar
			incomeAvatarBox.x = (_width - incomeAvatarBox.width) * .5;
			incomeAvatarBox.y = Config.FINGER_SIZE + Config.DOUBLE_MARGIN * 2 + Config.APPLE_TOP_OFFSET;
			
			// debug
			if (debug != null && debug.parent != null)
				debug.text = CallManager.getCallVO().toString();
			
			if (btnMute)
			{
				if (CallManager.getCallVO().mute)
					btnMute.setBitmapData(MICROPHONE_OFF_BMD);
				else
					btnMute.setBitmapData(MICROPHONE_ON_BMD);
			}
			
			
			/*if (CallManager.getCallVO().recognitionState != -1 && lastRecognitionState == -1) {
				btnInfo.activate();
				btnInfo.show(.3);
			}*/
			
			if (CallManager.getCallVO().mode == CallManager.MODE_VIDEO){
				// SET BUTTON (AUDIO)
			//	if (btnSwitch.parent)
			//		btnSwitch.parent.removeChild(btnSwitch);
			} else {
			//	if (btnSwitch.parent != null)
			//		return;
				// SET BUTTON (VIDEO)
			//	btnSwitch.setBitmapData(MEDIA_SOURCE_VIDEO_BMD);
			}
			
			// change between avatar & video
			if (CallManager.getCallVO().broadcastMode == CallManager.MODE_VIDEO){
				startTrackActivity();
				// ATTACH VIDEO OBJECT
				if (incomeVideoSprite != null && incomeVideoSprite.parent==null)
					incomeVideoBox.addChild(incomeVideoSprite);
				incomeAvatarBox.visible = false;
			} else {
				stopTrackActivity();
				// REMOVE VIDEO OBJECT
				if (incomeVideoSprite != null && incomeVideoSprite.parent)
					incomeVideoSprite.parent.removeChild(incomeVideoSprite);
				incomeAvatarBox.visible = true;
			}
			
			if (CallManager.getCallVO().mode == CallManager.MODE_VIDEO) {
				if (myCameraVideo.parent == null)
					myCameraSprite.addChildAt(myCameraVideo, 0);
				
				btnSwitchCams.activate();
				btnSwitchCams.show(.3);
			} else {
				btnSwitchCams.deactivate();
				btnSwitchCams.hide(.3);
			}
			
			// Setup video size
			if (incomeVideo != null) {
				incomeVideoSprite.rotation = 0;
				incomeVideo.width = CallManager.getCallVO().broadcasterCameraW;
				incomeVideo.height = CallManager.getCallVO().broadcasterCameraH;
				incomeVideoSprite.x = 0;
				incomeVideoSprite.y = 0;
				
				if (CallManager.getCallVO().broadcasterCameraR == -90) {
					incomeVideoSprite.rotation = -90;
					incomeVideoSprite.width = _width;
					incomeVideoSprite.x = 0;
					incomeVideoSprite.y = incomeVideoSprite.height;
				} else {
					incomeVideoSprite.rotation = 90;
					incomeVideoSprite.width = _width;
					incomeVideoSprite.x = incomeVideoSprite.width;
					incomeVideoSprite.y = 0;
				}
			}
			
			if (myCameraVideo != null && CallManager.camera != null) {
				var scale:Number;
				if (Config.PLATFORM_WINDOWS) {
					/*scale = UI.getMinScale(CallManager.camera.width, CallManager.camera.height, _width, _height);
					myCameraVideo.width = CallManager.camera.width * scale;
					myCameraVideo.height = CallManager.camera.height * scale;*/
					scale = UI.getMaxScale(CallManager.camera.width, CallManager.camera.height, _width, _height);
					myCameraVideo.width = CallManager.camera.width * scale;
					myCameraVideo.height = CallManager.camera.height * scale;
					
					if (myCameraVideo.height == _height) {
						myCameraSprite.x = int((_width - myCameraVideo.width) * .5) + ((myCameraSprite.rotation == 90) ? myCameraVideo.width : (myCameraSprite.rotation == -90) ? -myCameraVideo.width : 0);
						myCameraSprite.y = 0 + ((myCameraSprite.rotation == 90) ? -myCameraVideo.height : (myCameraSprite.rotation == -90) ? myCameraVideo.height : 0);
					} else {
						myCameraSprite.x = 0 + ((myCameraSprite.rotation == 90) ? myCameraVideo.height : 0);
						myCameraSprite.y = ((myCameraSprite.rotation == -90) ? myCameraVideo.width : 0) + int((_height - ((myCameraSprite.rotation == 90 || myCameraSprite.rotation == -90) ? myCameraVideo.width : myCameraVideo.height)) * .5);
					}
				} else if (Config.PLATFORM_APPLE) {
					
					scale = UI.getMaxScale(CallManager.camera.height, CallManager.camera.width, _width, _height);
					myCameraVideo.width = CallManager.camera.width * scale;
					myCameraVideo.height = CallManager.camera.height * scale;
					myCameraSprite.rotation = 90;
					
					myCameraSprite.x = int(_width * .5 + myCameraVideo.height * .5);
					myCameraSprite.y = int(_height * .5 - myCameraVideo.width * .5);
				} else if (Config.PLATFORM_ANDROID) {
					
					var rotation:Number = NativeExtensionController.getCameraOrientation(CallManager.camera.position == CameraPosition.FRONT);
					
					if (rotation == 90)
					{
						scale = UI.getMaxScale(CallManager.camera.height, CallManager.camera.width, _width, _height);
						myCameraVideo.width = CallManager.camera.width * scale;
						myCameraVideo.height = CallManager.camera.height * scale;
						
						myCameraSprite.rotation = 90;
						
						myCameraSprite.x = int(_width * .5 + myCameraVideo.height * .5);
						myCameraSprite.y = int(_height * .5 - myCameraVideo.width * .5);
					}
					else if (rotation == 270)
					{
						scale = UI.getMaxScale(CallManager.camera.height, CallManager.camera.width, _width, _height);
						myCameraVideo.width = CallManager.camera.width * scale;
						myCameraVideo.height = CallManager.camera.height * scale;
						
						myCameraSprite.rotation = -90;
						
						myCameraSprite.x = int(_width * .5 - myCameraVideo.height * .5);
						myCameraSprite.y = int(_height * .5 + myCameraVideo.width * .5);
					}
				}
			}
			
			btnInfo.y = _height - btnInfo.height - Config.MARGIN;
			btnInfo.x = _width - btnInfo.width - Config.MARGIN;
			
			btnSwitchCams.y = btnInfo.y;
			btnSwitchCams.x = btnInfo.x - btnSwitchCams.width - Config.MARGIN;
			
			buttonsContainer.graphics.clear();
			
			buttonsContainer.graphics.lineStyle(1, 0x8294A1);
			buttonsContainer.graphics.moveTo(0, _height);
			buttonsContainer.graphics.lineTo(_width, _height);
		}
		
		override public function dispose():void {
			super.dispose();
			stopTrackActivity();
			
			stateProgress = null;
			
			ServiceScreenManager.closeView();
			
			CallManager.S_CALLVO_CHANGED.remove(onCallVOChanged);
			
			TweenMax.killTweensOf(speachInicator);
			
			TweenMax.killDelayedCallsTo(hideUI);
			TweenMax.killDelayedCallsTo(showUI);
			TweenMax.killDelayedCallsTo(onUIShown);
			
			TweenMax.killTweensOf(stateContainer);
			
			if (incomeVideo != null) {
				incomeVideo.attachNetStream(null);
				incomeVideo = null;
			}
			if (myCameraVideo != null) {
				myCameraVideo.attachCamera(null);
				myCameraVideo = null;
			}
			
			if (LOADED_AVATAR_BMD != null) {
				LOADED_AVATAR_BMD.dispose();
				LOADED_AVATAR_BMD = null;
			}
			if (EMPTY_AVATAR_BMD != null) {
				EMPTY_AVATAR_BMD.dispose();
				EMPTY_AVATAR_BMD = null;
			}
			if(avatar!=null)
				avatar.dispose();
			avatar = null;
			if (stateBMP != null) {
				TweenMax.killTweensOf(stateBMP);
				stateBMP.bitmapData = null;
			}
			stateBMP = null
			TweenMax.killDelayedCallsTo(removeState);
			if (stateIBMD != null)
				stateIBMD.dispose();
			disposeButtons();
			
			if (btnSwitchCams)
			{
				btnSwitchCams.dispose();
				btnSwitchCams = null;
			}
			
			if (speachInicator)
			{
				UI.destroy(speachInicator);
				speachInicator = null;
			}
			
			if (stateMask != null)
				stateMask.graphics.clear();
			stateMask = null;
			
			stateContainer = null;
			
			lastRecognitionState = -1;
			
			if (buttonsContainer)
			{
				UI.destroy(buttonsContainer);
				buttonsContainer = null;
			}
			
			if (SPEACH_RED_BMD)
			{
				UI.disposeBMD(SPEACH_RED_BMD);
				SPEACH_RED_BMD = null;
			}
			if (SPEACH_BLUE_BMD)
			{
				UI.disposeBMD(SPEACH_BLUE_BMD);
				SPEACH_BLUE_BMD = null;
			}
			
			closeCodePopup();
		}
		
		override protected function disposeButtons():void {
			super.disposeButtons();
			
			UI.disposeBMD(INFO_BMD);
			INFO_BMD = null;
			
			if (btnInfo != null)
				btnInfo.dispose();
			btnInfo = null;
		}
	}
}