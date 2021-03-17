package com.dukascopy.connect.screens.call {
	
	import assets.IconCamera;
	import assets.IconEndCall;
	import assets.IconHelp;
	import assets.IconMicOff;
	import assets.IconMicOn;
	import assets.IconPhoto;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.RtoAgreementData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.progress.ProgressNavigator;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.screens.base.ScreenParams;
	import com.dukascopy.connect.screens.serviceScreen.RtoAgreementScreen;
	import com.dukascopy.connect.sys.callManager.CallManager;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.idleManager.IdleManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
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
	import flash.media.Video;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	/**
	*	@author Ilya Shcherbakov, Telefision A.G. Team - RIGA
	*/
	
	public class VideoRecognitionScreen extends TalkScreen {
		
		private static var INFO_BMD:ImageBitmapData;
		private static var SPEACH_BLUE_BMD:ImageBitmapData;
		private static var SPEACH_RED_BMD:ImageBitmapData;
		
		private var topBar:Shape;
		
		private var btnInfo:BitmapButton;
		
		private var stateProgress:ProgressNavigator;
		
		private var stateSize:int;
		private var stateContainer:Sprite;
		private var stateMask:Shape;
		private var stateBMP:Bitmap;
		private var stateIBMD:ImageBitmapData;
		private var lastRecognitionState:int = -1;

		
		private var indicator:Sprite;
		private var buttonsContainer:Sprite;
		private var btnHangupPosition:Number;
		private var showUITime:Number = 4;
		private var animationUITime:Number = 0.3;
		private var btnInfoPosition:Number;
		
		private var speachInicator:Bitmap;
		private var btnSwitchCamsPosition:Number;
		private var codePopup:VideoRecognitionCodePopup;
		
		public function VideoRecognitionScreen() {
			
		}
		
		override public function onBack(e:Event = null):void {
			
		}
		
		override public function initScreen(data:Object = null):void{
			_params = new ScreenParams("Video recognition screen");
			
			buttonsContainer = new Sprite();
			
			buttonsContainer.y = Config.APPLE_TOP_OFFSET;
			
			var cellSize:int = _width * .333;
			BUTTON_SIZE = cellSize * .6;
			
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
			
			topBar = new Shape();
			topBar.graphics.beginFill(0x171A23, 1);
			topBar.graphics.drawRect(0, 0, 1, Config.FINGER_SIZE);
			topBar.graphics.endFill();
			
			topBar.x = _width;
			topBar.width = _height;
			topBar.rotation = 90;
			_view.addChild(topBar);
			
			
			// videobox
			incomeVideoBox = new Sprite();
			//_view.addChild(incomeVideoBox);
			
			speachInicator = new Bitmap();
			speachInicator.rotation = 90;
			
			speachInicator.x = _width - Config.FINGER_SIZE * .5 + Config.FINGER_SIZE * .75 * .5;
			speachInicator.y = Config.APPLE_TOP_OFFSET + Config.FINGER_SIZE * .5 - Config.FINGER_SIZE * .75 * .5;
			speachInicator.alpha = 0;
			// DROP CALL
			btnInfo = new BitmapButton();
			btnInfo.setStandartButtonParams();
			btnInfo.setBitmapData(INFO_BMD, true);
			btnInfo.setDownScale(1);
			btnInfo.tapCallback = onBtnInfo;
			btnInfo.y = Config.FINGER_SIZE * .5 - btnInfo.height*.5;
			btnInfo.x = _height - Config.APPLE_TOP_OFFSET - Config.FINGER_SIZE * .5 - btnInfo.width * .5;
			btnInfo.show();
			btnInfo.rotationAdded = 90;
			buttonsContainer.addChild(btnInfo);
			
			btnInfoPosition = btnInfo.y;
			
			stateProgress = new ProgressNavigator();
		//	stateProgress.x = Config.DOUBLE_MARGIN + stateProgress.selectedCircleRadius;
		//	stateProgress.y = Config.APPLE_TOP_OFFSET;
			
			stateProgress.y = 0;
			stateProgress.setSize(Math.min(btnInfo.x - Config.DOUBLE_MARGIN * 2 - stateProgress.selectedCircleRadius * 2, (_height - Config.APPLE_TOP_OFFSET) * .25), Config.FINGER_SIZE);
			stateProgress.x = int((_height - Config.APPLE_TOP_OFFSET)*.5 - stateProgress.width*.5);
			stateProgress.setStepsCount(CallManager.getTotalVideoRecognitionStates());
			stateProgress.selectStep(-1,false);
			buttonsContainer.addChild(stateProgress);
			
			// DROP CALL
			btnHangup = new BitmapButton();
			btnHangup.setStandartButtonParams();
			btnHangup.setBitmapData(DROP_CALL_BMD,true);
			btnHangup.setDownScale(1);
			btnHangup.tapCallback = onBtnHangup;
		//	btnHangup.y = int(_height - btnHangup.height - (cellSize - btnHangup.height) * .5) - Config.DOUBLE_MARGIN;
		//	btnHangup.x = int(cellSize + (cellSize - btnHangup.height) * .5);
			btnHangup.x = (_height - Config.APPLE_TOP_OFFSET) * .5 - btnHangup.width * .5;
			btnHangup.y = _width - Config.MARGIN*2 - btnHangup.height;
			btnHangup.rotationAdded = 90;
			buttonsContainer.addChild(btnHangup);
			btnHangup.hide();
			btnHangup.show(.3, showTimeDelay);
			
			
			showTimeDelay += showTimeOffset;
			
			// SWITCH MEDIA
			/*btnSwitch = new BitmapButton();
			btnSwitch.setStandartButtonParams();
			btnSwitch.setBitmapData(MEDIA_SOURCE_VIDEO_BMD,true);
			btnSwitch.setDownScale(1);
			btnSwitch.tapCallback = onBtnSwitch;
			btnSwitch.y = int(_height - btnSwitch.height - (cellSize - btnSwitch.height) * .5) - Config.DOUBLE_MARGIN;
			btnSwitch.x = int(cellSize * 2 + (cellSize - btnSwitch.height) * .5);
			_view.addChild(btnSwitch);
			btnSwitch.hide();
			btnSwitch.show(.3, showTimeDelay);
			
			showTimeDelay += showTimeOffset;*/
			
			
			
			
			// MUTE BUTTON
			/*btnMute = new BitmapButton();
			btnMute.setStandartButtonParams();
			btnMute.setBitmapData(MICROPHONE_OFF_BMD,true);
			btnMute.setDownScale(1);
			btnMute.tapCallback = onBtnMute;
			btnMute.y = int(_height - btnMute.height - (cellSize - btnMute.height) * .5) - Config.DOUBLE_MARGIN;
			btnMute.x = int((cellSize - btnMute.height) * .5);
			_view.addChild(btnMute);			
			btnMute.hide();
			btnMute.show(.3, showTimeDelay);
			
			showTimeDelay += showTimeOffset;*/
			
			// SWITCH CAMERA Front/Back
			
		   	btnSwitchCams = new BitmapButton();
			btnSwitchCams.setStandartButtonParams();
			btnSwitchCams.setDownScale(1);
			btnSwitchCams.setBitmapData(SWITCH_CAMERA_BMD,true);
			btnSwitchCams.setDownScale(1);
			btnSwitchCams.tapCallback = onBtnSwitchCams;
			btnSwitchCams.hide();
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
			
			stateSize = _height - cellSize - Config.DOUBLE_MARGIN * 2 - topBar.height;
			if (stateSize > _width - Config.DOUBLE_MARGIN)
				stateSize = _width - Config.DOUBLE_MARGIN;
			
			debug = new TextField();
			debug.background = true;
			debug.border = true;
			debug.width = 300;
			debug.multiline = true;
			debug.wordWrap = true;
			debug.autoSize = TextFieldAutoSize.LEFT;
			debug.y = 240;
			debug.alpha = .8;
		//	_view.addChild(debug);
			
			indicator = new Sprite();
		//	_view.addChild(indicator);		
			
			
			
			btnSwitchCams.x = (_height - Config.APPLE_TOP_OFFSET) * .5 + Config.FINGER_SIZE*.5 + btnHangup.width*.5;
			btnSwitchCams.y = btnHangup.y + btnHangup.height * .5 - btnSwitchCams.height * .5;
			
			buttonsContainer.rotation = 90;
			buttonsContainer.x = _width;
			
			_view.addChild(buttonsContainer);
			
			btnHangupPosition = btnHangup.y;
			btnSwitchCamsPosition = btnSwitchCams.y;
			
			_view.addChild(speachInicator);
			
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
		}
		
		/*private function showWellcomeMessage():void 
		{
			if (stateBMP == null) {
				stateBMP ||= new Bitmap();
				stateBMP.mask = stateMask;
				stateContainer.addChild(stateBMP);
			}
			
			wellcomeMessageOnScreen = true;
			stateIBMD = getStateHelpImageBitmapData(-1, stateMask.width, stateMask.height);
			
			if (stateBMP.bitmapData)
			{
				stateBMP.bitmapData.dispose();
				stateBMP.bitmapData = null;
			}
			
			if (stateContainer.parent == null)
				_view.addChildAt(stateContainer, 1);
			stateContainer.alpha = 0;
			
			stateBMP.bitmapData = stateIBMD;
			if (stateBMP.width > stateMask.width) {
				stateBMP.y = 0;
				stateBMP.x = -int((stateBMP.width - stateMask.width) * .5);
			} else {
				stateBMP.y = -int((stateBMP.height - stateMask.height) * .5);
				stateBMP.x = 0;
			}
			TweenMax.to(stateContainer, 1, { alpha:1, onComplete:onWellcomeShowed } );
		}
		
		private function onWellcomeShowed():void 
		{
			TweenMax.delayedCall(2, hideWellcomeMessage);
		}
		
		private function hideWellcomeMessage():void 
		{
			TweenMax.to(stateContainer, 0.5, { alpha:0, onComplete:onWellcomeHided } );
		}*/
		
		/*private function onWellcomeHided():void 
		{
			wellcomeMessageOnScreen = false;
			if (awaitingState)
			{
				awaitingState = false;
				showState();
			}
		}*/
		
		//private function onWokiTokiClick(a:int = -1):void {
			//
			//onScreenTap();
			//
			//var val:int;
			//if (a == -1)
				//val = btnWokitoki.state == 0 ? 1 : 0;
			//else if (btnWokitoki.state == a)
			//{
				//if (!speachInicator.bitmapData)
				//{
					//speachInicator.bitmapData = (val == 0) ? SPEACH_RED_BMD : SPEACH_BLUE_BMD;
				//}
				//return;
			//}	
			//else
				//val = a;
			//btnWokitoki.setState(val, 0.4);
			//speachInicator.bitmapData = (val == 0) ? SPEACH_RED_BMD : SPEACH_BLUE_BMD;
			//if (a == -1)
				//CallManager.overridePhase();
		//}
		
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
			INFO_BMD ||= UI.renderAsset(new IconHelp(), int(Config.FINGER_SIZE * .75), int(Config.FINGER_SIZE * .75), true);
			SPEACH_BLUE_BMD ||= UI.renderAsset(new SWFLoudButtonBlue(), int(Config.FINGER_SIZE * .75), int(Config.FINGER_SIZE * .75), true);
			SPEACH_RED_BMD ||= UI.renderAsset(new SWFLoudButtonRed(), int(Config.FINGER_SIZE * .75), int(Config.FINGER_SIZE * .75), true);
			
			MICROPHONE_ON_BMD ||= UI.renderAsset(new IconMicOn(), BUTTON_SIZE, BUTTON_SIZE, true);
			MICROPHONE_OFF_BMD ||= UI.renderAsset(new IconMicOff(), BUTTON_SIZE, BUTTON_SIZE, true);
			SWITCH_CAMERA_BMD ||= UI.renderAsset(new IconPhoto(), BUTTON_SIZE, BUTTON_SIZE, true);
			MEDIA_SOURCE_VIDEO_BMD ||= UI.renderAsset(new IconCamera(), BUTTON_SIZE, BUTTON_SIZE, true);
			DROP_CALL_BMD ||= UI.renderAsset(new IconEndCall(),  BUTTON_SIZE, BUTTON_SIZE, true);
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
					btnHangup.x = (_height - Config.APPLE_TOP_OFFSET) * .5 - btnHangup.width - Config.FINGER_SIZE_DOT_25;
					btnSwitchCams.x = (_height - Config.APPLE_TOP_OFFSET) * .5 + Config.FINGER_SIZE_DOT_25;					
				}else{								
					btnHangup.x = (_height - Config.APPLE_TOP_OFFSET) * .5 - btnHangup.width * .5;
					btnSwitchCams.x = (_height - Config.APPLE_TOP_OFFSET) * .5 + Config.FINGER_SIZE * .5 + btnHangup.width * .5;
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
			stateProgress.selectStep(lastRecognitionState - 1, true);
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
				/*case 4:
					if (CallManager.getCallVO().documentType == CallManager.DOCUMENT_TYPE_ID)
					{
						source = new assets.RecognitionStep5();
					}
					else if (CallManager.getCallVO().documentType == CallManager.DOCUMENT_TYPE_PASSPORT)
					{
						source = new assets.RecognitionPassStep5();
					}
					
					break;*/
			}
			if (source)
			{
			//	source.height = _width - Config.FINGER_SIZE * 2;
			//	source.scaleX = source.scaleY;
				
			//	source.rotation = 90;
				
				var result:ImageBitmapData = new ImageBitmapData("VideoRecognitionScreen.halpBackImage", imageWidth, imageHeight, false, 0x222533);
				var matrixMove:Matrix = new Matrix();
				
				var k:Number = Math.min((_width - Config.FINGER_SIZE * 2) / source.height, (imageHeight - Config.FINGER_SIZE*2)/source.width);
				
				matrixMove.scale(k, k);
				matrixMove.rotate(Math.PI / 2);
				if (stateIndex == -1)
				{
					matrixMove.translate(-imageWidth*.5 + source.height*k*.5 + imageWidth, imageHeight*.5 - source.width*k*.5);
				}
				else {
					matrixMove.translate(source.height*k, imageHeight*.5 - source.width*k*.5);
				}
				
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
			btnHangup.activate();
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
			if (!btnHangup || /*!btnWokitoki || !btnInfo ||*/ !topBar || !stateProgress)
				return;
			
			TweenMax.killTweensOf(btnHangup);
			//TweenMax.killTweensOf(btnWokitoki);
			//TweenMax.killTweensOf(btnInfo);
			TweenMax.killTweensOf(topBar);
			TweenMax.killTweensOf(stateProgress);
			TweenMax.killTweensOf(speachInicator);
			TweenMax.killTweensOf(btnSwitchCams);
			
			TweenMax.to(btnHangup, animationUITime, { y:btnHangupPosition, alpha:1 });
			//TweenMax.to(btnWokitoki, animationUITime, { y:btnWokitokiPoisition, alpha:1 } );
			TweenMax.to(btnSwitchCams, animationUITime, { y:btnSwitchCamsPosition, alpha:1 } );
			//TweenMax.to(btnInfo, animationUITime, { y:btnInfoPosition, alpha:1 });
			TweenMax.to(topBar, animationUITime, { x:_width, alpha:1 } );
			TweenMax.to(stateProgress, animationUITime, { y:0, alpha:1 });
			
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
			
			TweenMax.killTweensOf(btnHangup);
			TweenMax.killTweensOf(topBar);
			TweenMax.killTweensOf(stateProgress);
			TweenMax.killTweensOf(speachInicator);
			TweenMax.killTweensOf(btnSwitchCams);
			
			TweenMax.to(btnHangup, animationUITime, { y:(_height - btnHangupPosition), alpha:0 });
			TweenMax.to(btnSwitchCams, animationUITime, { y:(_height - btnSwitchCamsPosition), alpha:0 } );
			//TweenMax.to(btnInfo, animationUITime, { y:-Config.FINGER_SIZE, alpha:0 });
			TweenMax.to(topBar, animationUITime, { x:_width + Config.FINGER_SIZE, alpha:0 } );
			TweenMax.to(stateProgress, animationUITime, { y: -Config.FINGER_SIZE, alpha:0 } );
			
			TweenMax.to(speachInicator, animationUITime, { alpha:1 } );
		}
		
		override public function deactivateScreen():void {
			_isActivated = false;
			CallManager.S_STREAM_READY.remove(onStreamReady);
			CallManager.S_VIDEO_SIZE_CHANGED.remove(onVideoSizeChanged);
		//	CallManager.S_CALLVO_CHANGED.remove(onCallVOChanged);
			CallManager.S_SECURITY_CODE.remove(showCodeNumber);
			btnHangup.deactivate();
		//	btnMute.deactivate();
		//	btnSwitch.deactivate();
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
				codePopup = new VideoRecognitionCodePopup();
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
					myCameraSprite.rotation = 90;
					scale = UI.getMaxScale(CallManager.camera.height, CallManager.camera.width, _width, _height);
					myCameraVideo.width = CallManager.camera.width * scale;
					myCameraVideo.height = CallManager.camera.height * scale;
				} else if (Config.PLATFORM_APPLE) {
					myCameraSprite.rotation = 90;
					scale = UI.getMaxScale(CallManager.camera.height, CallManager.camera.width, _width, _height);
					myCameraVideo.width = CallManager.camera.width * scale;
					myCameraVideo.height = CallManager.camera.height * scale;
				} else if (Config.PLATFORM_ANDROID) {
					/*if (CallManager.camera.position == "front")
						myCameraSprite.rotation = 90;
					else*/
						myCameraSprite.rotation = 90;
					scale = UI.getMaxScale(CallManager.camera.height, CallManager.camera.width, _width, _height);
					myCameraVideo.width = CallManager.camera.width * scale;
					myCameraVideo.height = CallManager.camera.height * scale;
				}
				if (myCameraVideo.height == _height) {
					myCameraSprite.x = int((_width - myCameraVideo.width) * .5) + ((myCameraSprite.rotation == 90) ? myCameraVideo.width : (myCameraSprite.rotation == -90) ? -myCameraVideo.width : 0);
					myCameraSprite.y = 0 + ((myCameraSprite.rotation == 90) ? -myCameraVideo.height : (myCameraSprite.rotation == -90) ? myCameraVideo.height : 0);
				} else {
					myCameraSprite.x = 0 + ((myCameraSprite.rotation == 90) ? myCameraVideo.height : 0);
					myCameraSprite.y = ((myCameraSprite.rotation == -90) ? myCameraVideo.width : 0) + int((_height - ((myCameraSprite.rotation == 90 || myCameraSprite.rotation == -90) ? myCameraVideo.width : myCameraVideo.height)) * .5);
				}
			}
		}
		
		override public function dispose():void {
			super.dispose();
			stopTrackActivity();
			
			ServiceScreenManager.closeView();
			
			CallManager.S_CALLVO_CHANGED.remove(onCallVOChanged);
			
			TweenMax.killTweensOf(btnHangup);
			//TweenMax.killTweensOf(btnWokitoki);
			TweenMax.killTweensOf(btnInfo);
			TweenMax.killTweensOf(btnSwitchCams);
			TweenMax.killTweensOf(topBar);
			TweenMax.killTweensOf(stateProgress);
			TweenMax.killTweensOf(speachInicator);
			
			TweenMax.killDelayedCallsTo(hideUI);
			TweenMax.killDelayedCallsTo(showUI);
			TweenMax.killDelayedCallsTo(onUIShown);
			
			TweenMax.killTweensOf(stateContainer);
			
			if (incomeVideo != null) {
				incomeVideo.attachNetStream(null);
				incomeVideo = null;
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
			
			if (topBar != null)
				topBar.graphics.clear();
			topBar = null;
			
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
			
			if (stateProgress != null)
				stateProgress.dispose();
			stateProgress = null;
			
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