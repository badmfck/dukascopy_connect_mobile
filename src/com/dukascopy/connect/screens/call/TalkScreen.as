package com.dukascopy.connect.screens.call {
import com.adobe.utils.IntUtil;	
import com.dukascopy.connect.Config;
import com.dukascopy.connect.gui.lightbox.UI;
import com.dukascopy.connect.gui.menuVideo.BitmapButton;
import com.dukascopy.connect.gui.menuVideo.OnAirButton;
import com.dukascopy.connect.MobileGui;
import com.dukascopy.connect.screens.base.BaseScreen;
import com.dukascopy.connect.screens.base.ScreenParams;
import com.dukascopy.connect.sys.auth.Auth;
import com.dukascopy.connect.sys.callManager.CallManager;
import com.dukascopy.connect.sys.callManager.EchoSuspension;
import com.dukascopy.connect.sys.dialogManager.DialogManager;
import com.dukascopy.connect.sys.echo.echo;
import com.dukascopy.connect.sys.idleManager.IdleManager;
import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
import com.dukascopy.connect.sys.imageManager.ImageManager;
import com.dukascopy.connect.sys.pointerManager.PointerManager;
import com.dukascopy.connect.sys.proximity.ProximityController;
import com.dukascopy.connect.sys.usersManager.UsersManager;
import com.dukascopy.connect.vo.CallVO;
import com.greensock.easing.Back;
import com.greensock.TweenMax;
import com.telefision.utils.Loop;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.media.AudioPlaybackMode;
import flash.media.SoundMixer;
import flash.media.Video;
import flash.system.Capabilities;
import flash.system.System;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
	
	/**
	*	@author Igor Bloom
	*/
	public class TalkScreen extends BaseScreen {
		
		protected var SPEACH_BLUE_BMD:ImageBitmapData;
		protected var SPEACH_RED_BMD:ImageBitmapData;
		// GUI
		protected var btnSwitch:BitmapButton;
		protected var btnHangup:BitmapButton;
		protected var btnMute:BitmapButton;
		protected var btnLoudspeaker:BitmapButton;
		protected var btnOpenChat:BitmapButton;
		protected var btnSwitchCams:BitmapButton;
		protected var btnSettings:BitmapButton;
		
		// Cached buttons bitmapdatas 
		private static var SETTINGS_BMD:ImageBitmapData;
		protected static var LOUDSPEAKER_ON_BMD:ImageBitmapData;
		protected static var LOUDSPEAKER_OFF_BMD:ImageBitmapData;		
		protected static var MICROPHONE_ON_BMD:ImageBitmapData;
		protected static var MICROPHONE_OFF_BMD:ImageBitmapData;		
		protected static var SWITCH_CAMERA_BMD:ImageBitmapData;		
		protected static var MEDIA_SOURCE_VIDEO_BMD:ImageBitmapData;
		//private static var MEDIA_SOURCE_VIDEO_GREEN_BMD:ImageBitmapData;
		private static var MEDIA_SOURCE_AUDIO_BMD:ImageBitmapData;		
		protected static var DROP_CALL_BMD:ImageBitmapData;
		private static var CHAT_BMD:ImageBitmapData;
		
		protected var LOADED_AVATAR_BMD:BitmapData;
		protected var EMPTY_AVATAR_BMD:ImageBitmapData;
		
		protected var avatarSize:int;
		protected var myCamSize:int;
		
		protected var BUTTON_SIZE:int = Config.FINGER_SIZE;
		// DEBUG!
		protected var debug:TextField;
		
		protected var incomeVideoBox:Sprite;
			protected var incomeVideoSprite:Sprite;
				protected var incomeVideo:Video;
				
		protected var myCameraTop:Sprite;
			protected var myCameraBox:Sprite;
				protected var myCameraSprite:Sprite;
					protected var myCameraVideo:Video;
				
		protected var incomeAvatarBox:Sprite;
			protected var incomeAvatar:Bitmap;
				private var msk:Shape;
					protected var avatar:ImageBitmapData;
					
					
		private var dx:int = 0;
		private var dy:int = 0;
		private var startMX:int = 0;
		private var startMY:int = 0;
		private var camMsk:Shape;
		
		protected var showTimeOffset:Number = .1;
		protected var showTimeDelay:Number = 1.2;
		private var activityDetectionTime:Number = 7;
		private var isTrackingActivity:Boolean = false;
		protected var uiVisibleActive:Boolean = true;
		
		private var oldVideoWidth:int = 0;
		private var oldVideoHeight:int = 0;
		private var speachInicator:Bitmap;
		
	
		
		private var dvSpr:Sprite;
		private var dv1:DebugValuer;
		private var dv2:DebugValuer;
		private var dv3:DebugValuer;
		private var dv4:DebugValuer;
		private var dv5:DebugValuer;
		private var dv6:DebugValuer;
		
		
		//TEST
		public function TalkScreen(){
			
		}
		
		override public function onBack(e:Event = null):void 
		{
			
		}
		
		override public function initScreen(data:Object = null):void{
			super.initScreen(data);
			_params.title = "Talk screen";
			
			SPEACH_BLUE_BMD ||= UI.renderAsset(new SWFLoudButtonBlue(), int(Config.FINGER_SIZE * .75), int(Config.FINGER_SIZE * .75), true);
			SPEACH_RED_BMD ||= UI.renderAsset(new SWFLoudButtonRed(), int(Config.FINGER_SIZE * .75), int(Config.FINGER_SIZE * .75), true);
			
			var bitmapPlane2:BitmapData;
			var half:int = _width * .5;
			generateCacahedAssets();
			
			// videobox
			incomeVideoBox = new Sprite();
			_view.addChild(incomeVideoBox);
			
			// DROP CALL
			btnHangup = new BitmapButton();
			btnHangup.setStandartButtonParams();
			btnHangup.setBitmapData(DROP_CALL_BMD,true);
			btnHangup.setDownScale(1);
			btnHangup.tapCallback = onBtnHangup;
			btnHangup.hide();
			btnHangup.show(.3,showTimeDelay);
			_view.addChild(btnHangup);
			
			btnHangup.y = _height - btnHangup.height-Config.DOUBLE_MARGIN;
			btnHangup.x = (half- btnHangup.width)*.5;
			showTimeDelay += showTimeOffset;
			
			// SWITCH MEDIA 		
			btnSwitch = new BitmapButton();
			btnSwitch.setStandartButtonParams();
			btnSwitch.setBitmapData(MEDIA_SOURCE_VIDEO_BMD,true);
			btnSwitch.setDownScale(1);
			btnSwitch.tapCallback = onBtnSwitch;
			btnSwitch.hide();
			btnSwitch.show(.3,showTimeDelay);
			_view.addChild(btnSwitch);
			
			btnSwitch.y = _height - btnSwitch.height-Config.DOUBLE_MARGIN;
			//btnSwitch.x = _width * .5 + Config.MARGIN;
			btnSwitch.x = half+(half- btnSwitch.width)*.5
			showTimeDelay += showTimeOffset;
			
			
			// MUTE BUTTON
			btnMute = new BitmapButton();
			btnMute.setStandartButtonParams();
			btnMute.setBitmapData(MICROPHONE_OFF_BMD,true);
			btnMute.setDownScale(1);
			btnMute.tapCallback = onBtnMute;
			btnMute.hide();
			btnMute.show(.3,showTimeDelay);
			_view.addChild(btnMute);			
			btnMute.y = Config.DOUBLE_MARGIN+Config.APPLE_TOP_OFFSET; 
			btnMute.x = Config.DOUBLE_MARGIN*2 + BUTTON_SIZE;
			showTimeDelay += showTimeOffset;
			
			// LOUDSPEAKER 
			btnLoudspeaker = new BitmapButton();
			btnLoudspeaker.setStandartButtonParams();
			btnLoudspeaker.setBitmapData(LOUDSPEAKER_OFF_BMD,true);
			btnLoudspeaker.setDownScale(1);
			btnLoudspeaker.tapCallback = onBtnLoudspeaker;
			btnLoudspeaker.x = Config.DOUBLE_MARGIN; 
			btnLoudspeaker.y = Config.DOUBLE_MARGIN + Config.APPLE_TOP_OFFSET; 			
			btnLoudspeaker.hide();
			btnLoudspeaker.show(.3,showTimeDelay);
			_view.addChild(btnLoudspeaker);
			showTimeDelay += showTimeOffset;
			
			// CHAT 
			btnOpenChat = new BitmapButton();
			btnOpenChat.setStandartButtonParams();
			btnOpenChat.setDownScale(1);
			//btnOpenChat.setBitmapData(bitmapPlane2,true);
			btnOpenChat.setDownScale(1);
			btnOpenChat.tapCallback = onBtnOpenChat;
			btnOpenChat.y = _height - BUTTON_SIZE*3 -Config.DOUBLE_MARGIN;
			btnOpenChat.x = (_width - btnOpenChat.width)*.5;
			btnOpenChat.hide();
			btnOpenChat.show(.3,1);
			_view.addChild(btnOpenChat);
			
			// SWITCH CAMERA Front/Back
		   	btnSwitchCams = new BitmapButton();
			btnSwitchCams.setStandartButtonParams();
			btnSwitchCams.setDownScale(1);
			btnSwitchCams.setBitmapData(SWITCH_CAMERA_BMD,true);
			btnSwitchCams.setDownScale(1);
			btnSwitchCams.tapCallback = onBtnSwitchCams;
			btnSwitchCams.x = BUTTON_SIZE*2 + Config.DOUBLE_MARGIN*3;
			btnSwitchCams.y = Config.DOUBLE_MARGIN +Config.APPLE_TOP_OFFSET;
			btnSwitchCams.hide();
			_view.addChild(btnSwitchCams);
			
			// SETTINGS CAMERA 
		   	btnSettings = new BitmapButton();
			btnSettings.setStandartButtonParams();
			btnSettings.setDownScale(1);
			btnSettings.setBitmapData(SETTINGS_BMD,true);
			btnSettings.setDownScale(1);
			btnSettings.tapCallback = onBtnSettings;
			btnSettings.x = _width - BUTTON_SIZE- Config.DOUBLE_MARGIN;
			btnSettings.y = Config.DOUBLE_MARGIN +Config.APPLE_TOP_OFFSET;
			btnSettings.hide();
			_view.addChild(btnSettings);
			btnSettings.show(.3, showTimeDelay);
			
			myCamSize = Config.FINGER_SIZE*1.2;
			
			//avatarbox
			avatarSize = _width  * .25;
				incomeAvatarBox = new Sprite();
					incomeAvatar = new Bitmap();
				incomeAvatarBox.addChild(incomeAvatar);
			_view.addChild(incomeAvatarBox);
			
			incomeVideoSprite = new Sprite();
			incomeVideo = new Video(/*CallManager.cameraWidth,CallManager.cameraHeight*/);
			
			// camera box	
			myCameraTop = new Sprite();
				myCameraBox = new Sprite();
					myCameraSprite = new Sprite();
						myCameraVideo = new Video();
					myCameraSprite.addChild(myCameraVideo);
				myCameraTop.addChild(myCameraBox);
			_view.addChild(myCameraTop);
			
			myCameraTop.x  = (_width - myCamSize*2) * .5;
			myCameraTop.y = _height - BUTTON_SIZE * 2 - Config.DOUBLE_MARGIN - myCamSize*2;
			
			
			camMsk = new Shape();
			camMsk.graphics.beginFill(0xFF0000, .2);
			camMsk.graphics.drawRoundRect(0, -myCamSize*.2, myCamSize*2, myCamSize*2.4, Config.FINGER_SIZE, Config.FINGER_SIZE);
			myCameraBox.mask = camMsk;
			myCameraTop.addChild(camMsk);
			myCameraBox.graphics.beginFill(0);
			myCameraBox.graphics.drawRect(0, 0, myCamSize * 2, myCamSize * 2.4);
			
			
			
			speachInicator = new Bitmap();
			
			speachInicator.x = Config.DOUBLE_MARGIN;
			speachInicator.y = Config.DOUBLE_MARGIN;
			speachInicator.visible = false;
			_view.addChild(speachInicator);
			
			// DEBUG
			if(Capabilities.isDebugger)
				CallManager.S_DEBUG_MIC_VALUES.add(onDebugMicValues);
				
				
			/*debug = new TextField();
			debug.background = true;
			debug.border = true;
			debug.width = 300;
			debug.multiline = true;
			debug.wordWrap = true;
			debug.autoSize = TextFieldAutoSize.LEFT;
			debug.y = 100;
			debug.alpha = .8;
			_view.addChild(debug);*/
			
			//Loop.add(onLoop);
			// --
			
			// fill data
			onCallVOChanged();
			
			// check stream
			onStreamReady();
			
			setDefaultAvatarImage();
			
			loadAvatar();
			
			if (CallManager.getCallVO() != null && CallManager.getCallVO().supporter == true)
				setSupporterControls();
			
			
		}
		
	
		
		
		
		// DEBUG PANEL
		private var debugMicValuesTF:TextField = null;
		private var debugSprite:Sprite = null;
		private var tme:int = 0;
		private function onDebugMicValues(values:Array):void{
			if (debugSprite == null){
				debugSprite = new Sprite();
				view.addChild(debugSprite);
				debugSprite.addEventListener(MouseEvent.CLICK,function(e:MouseEvent):void{
					CallManager.overridePhase();
				});
			}
			
			
			debugSprite.graphics.clear();
			debugSprite.graphics.beginFill(CallManager.isMicrophoneMuted()?0xFF0000:0, .6);
			debugSprite.graphics.drawRect(0, 0, 100, 100);
			debugSprite.graphics.endFill();
			
			// mic level
			debugSprite.graphics.beginFill(0xCCFF00);
			debugSprite.graphics.drawRect(0,100-values[0],49,values[0]);
			debugSprite.graphics.endFill();
			
			// far mic level
			debugSprite.graphics.beginFill(0x00FFCC);
			debugSprite.graphics.drawRect(51,100-values[1],49,values[1]);
			debugSprite.graphics.endFill();
			
	
			// silence level
			debugSprite.graphics.beginFill(0xFFFFFF);
			debugSprite.graphics.drawRect(0,100-EchoSuspension.silenceLevel,49,2);
			debugSprite.graphics.endFill();
			
			// speech level
			debugSprite.graphics.beginFill(0xFFFFFF);
			debugSprite.graphics.drawRect(51,100-EchoSuspension.speechLevel,49,2);
			debugSprite.graphics.endFill();
			
			debugSprite.height = MobileGui.stage.stageWidth*.3;
			debugSprite.width = MobileGui.stage.stageHeight * .3;
			
			debugSprite.x = (MobileGui.stage.stageWidth - debugSprite.width) * .5;
			debugSprite.y = 150;// (MobileGui.stage.stageHeight - debugSprite.height) * .5;
			
			if(debugMicValuesTF==null){
				debugMicValuesTF = new TextField()
				debugMicValuesTF.defaultTextFormat = new TextFormat("Arial", Config.FINGER_SIZE*.28);
				debugMicValuesTF.y = debugSprite.y+debugSprite.height;
				debugMicValuesTF.x = debugSprite.x;
				debugMicValuesTF.height = 260;
				debugMicValuesTF.width = debugSprite.width;
				debugMicValuesTF.background = true;
				view.addChild(debugMicValuesTF);
			}
			
			debugMicValuesTF.text = ""
			+" mic attached: "+CallManager.isMicrophoneAttached()+"\n"
			+" mic: "+(!CallManager.isMicrophoneMuted())+"\n"
			+" loudspeaker: "+(SoundMixer.audioPlaybackMode==AudioPlaybackMode.MEDIA) +"\n"
			+" phase: "+((CallManager.getCallVO()!=null)?CallManager.getCallVO().phase:" no phase")+"\n"
			+" --: "+"\n"
			+" noise min: "+EchoSuspension.noiseMin+"\n"
			+" noise max: "+EchoSuspension.noiseMax+"\n"
			+" average: "+EchoSuspension.averageNoiseLevel+"\n"
			+'';
			
			
			
			if (dvSpr == null) {
				dvSpr = new Sprite();
				dv1 = new DebugValuer("Speech LVL", EchoSuspension.speechLevel, 1, 0, 300, onDVChange1);
				
				dv2 = new DebugValuer("Timer 1", EchoSuspension.silenceDelayMax, 1, 0, 300, onDVChange2);
				dv2.y = (dv1.height + 5);
				
				dv3 = new DebugValuer("Timer 2.", EchoSuspension.silenceLastTimer, 1, 0, 300, onDVChange3);
				dv3.y = (dv1.height + 5) * 2;
				
				dvSpr.addChild(dv1);
				dvSpr.addChild(dv2);
				dvSpr.addChild(dv3);
				
				view.addChild(dvSpr);
				dvSpr.width = MobileGui.stage.stageWidth - Config.FINGER_SIZE_DOUBLE;
				dvSpr.height = Config.FINGER_SIZE * 2.3
				dvSpr.y = debugMicValuesTF.y + debugMicValuesTF.height;
				dvSpr.x = debugMicValuesTF.x;
			}
			
			tme++;
		}
		
		private function onDVChange1(val:Number):void {
			EchoSuspension.speechLevel=val;
		}
		
		private function onDVChange2(val:Number):void {
			EchoSuspension.silenceDelayMax = val;
		}
		
		private function onDVChange3(val:Number):void {
			EchoSuspension.silenceLastTimer = val;
		}
		// -------------------------------------------------------
		//
		//private function onWokiTokiClick(a:int = -1):void {
			//CallManager.overridePhase();
		//}
		
		protected function loadAvatar():void 
		{
			//load avatar
			if (CallManager.getCallVO().avatar == null || CallManager.getCallVO().avatar == ""){
				CallManager.getCallVO().avatar = "";
				onAvatarLoaded("", UI.getEmptyAvatarBitmapData(avatarSize * 2, avatarSize * 2),true);
			}else{
				ImageManager.loadImage(UsersManager.getAvatarImage(CallManager.getCallVO(), CallManager.getCallVO().avatar, avatarSize*2), onAvatarLoaded);
			}
		}
		
		// TEST FUNCTIONALITY
		private function setSupporterControls():void{
			// TEST
			var btnState1:Sprite = new Sprite();
			var btnState2:Sprite = new Sprite();
			var btnState3:Sprite = new Sprite();
			var btnState4:Sprite = new Sprite();
			var btnState5:Sprite = new Sprite();
			var btnState6:Sprite = new Sprite();
			var btnState7:Sprite = new Sprite();
			var btnState8:Sprite = new Sprite();
		
			var __onTestBtnClick:Function = function(e:MouseEvent):void{
				if (e.target == btnState1)
					CallManager.sendRecognitionState(1);
					
				if (e.target == btnState2)
					CallManager.sendRecognitionState(2);
					
				if (e.target == btnState3)
					CallManager.sendRecognitionState(3);
					
				if (e.target == btnState4)
					CallManager.sendRecognitionState(4);
					
				if (e.target == btnState5)
					CallManager.sendChangeQuality(CallManager.QUALITY_LOW);
					
				if (e.target == btnState6)
					CallManager.sendChangeQuality(CallManager.QUALITY_MEDIUM);
					
				if (e.target == btnState7)
					CallManager.sendChangeQuality(CallManager.QUALITY_HIGH);
					
				if (e.target == btnState8)
					CallManager.sendChangeQuality(CallManager.QUALITY_FPS);
				
			};
			
			var sy:int = 50;
			
			btnState1.graphics.beginFill(0xFF0000, 1);
			btnState1.graphics.drawRect(0, 0, 20, 20);
			btnState1.addEventListener(MouseEvent.CLICK, __onTestBtnClick);
			btnState1.y = sy;
			view.addChild(btnState1);
			
			
			btnState2.graphics.beginFill(0xFF0000, 1);
			btnState2.graphics.drawRect(0, 0, 20, 20);
			btnState2.addEventListener(MouseEvent.CLICK, __onTestBtnClick);
			btnState2.y = sy;
			btnState2.x = 25;
			view.addChild(btnState2);
			
			btnState3.graphics.beginFill(0xFF0000, 1);
			btnState3.graphics.drawRect(0, 0, 20, 20);
			btnState3.addEventListener(MouseEvent.CLICK, __onTestBtnClick);
			btnState3.y = sy;
			btnState3.x = 50;
			view.addChild(btnState3);
			
			btnState4.graphics.beginFill(0xFF0000, 1);
			btnState4.graphics.drawRect(0, 0, 20, 20);
			btnState4.addEventListener(MouseEvent.CLICK, __onTestBtnClick);
			btnState4.x = 75;
			btnState4.y = sy;
			view.addChild(btnState4);
			
			
			btnState5.graphics.beginFill(0xFFCC00, 1);
			btnState5.graphics.drawRect(0, 0, 20, 20);
			btnState5.addEventListener(MouseEvent.CLICK, __onTestBtnClick);
			btnState5.y = 25+sy;
			view.addChild(btnState5);
			
			btnState6.graphics.beginFill(0xFFCC00, 1);
			btnState6.graphics.drawRect(0, 0, 20, 20);
			btnState6.addEventListener(MouseEvent.CLICK, __onTestBtnClick);
			btnState6.y = 25+sy;
			btnState6.x = 25;
			view.addChild(btnState6);
			
			btnState7.graphics.beginFill(0xFFCC00, 1);
			btnState7.graphics.drawRect(0, 0, 20, 20);
			btnState7.addEventListener(MouseEvent.CLICK, __onTestBtnClick);
			btnState7.y = 25+sy;
			btnState7.x = 50;
			view.addChild(btnState7);
			
			btnState8.graphics.beginFill(0xFFCC00, 1);
			btnState8.graphics.drawRect(0, 0, 20, 20);
			btnState8.addEventListener(MouseEvent.CLICK, __onTestBtnClick);
			btnState8.y = 25+sy;
			btnState8.x = 75;
			view.addChild(btnState8);
		}
		

		private function onLoop():void{
			if (CallManager.getCallVO() == null || CallManager.getIncomeStream() == null)
				return;
			debug.text = "Audio bytes per sec: " + CallManager.getIncomeStream().info.audioBytesPerSecond;
			debug.text += "Current bytes per sec: " + CallManager.getIncomeStream().info.currentBytesPerSecond;
		}
		

		protected function setDefaultAvatarImage():void{
			if (incomeAvatar.bitmapData){
				if (incomeAvatar.bitmapData != EMPTY_AVATAR_BMD){
					UI.disposeBMD(incomeAvatar.bitmapData);
				}
				
				incomeAvatar.bitmapData = null;
			}
			incomeAvatar.bitmapData = getEmptyAvatar();
		}
		
		protected function onAvatarLoaded(url:String, bmd:ImageBitmapData, loaded:Boolean):void{
			if (isDisposed || !loaded)
				return;
			
			if (bmd.isDisposed){
				bmd = null;
				loaded = false;
			}
			loaded = false;
			
			if (LOADED_AVATAR_BMD != null) {
				LOADED_AVATAR_BMD.dispose();
				LOADED_AVATAR_BMD = null;
			}
			
			if (bmd){
				LOADED_AVATAR_BMD ||= new ImageBitmapData("TalkScreen.avatar", avatarSize * 2, avatarSize * 2, true);
				ImageManager.drawCircleImageToBitmap(LOADED_AVATAR_BMD, bmd, 0, 0, int(avatarSize));
			}
			
			updateAvatarBMD();
			
			drawView();
		}
		
		private function updateAvatarBMD():void{
			if (incomeAvatar == null) return;				
			if (LOADED_AVATAR_BMD != null) {	
				UI.disposeBMD(EMPTY_AVATAR_BMD);
				EMPTY_AVATAR_BMD = null;
				incomeAvatar.bitmapData = LOADED_AVATAR_BMD;
			}else {				
				incomeAvatar.bitmapData = getEmptyAvatar();
			}
			incomeAvatar.smoothing = true;
		}
		
		private function getEmptyAvatar():BitmapData{
			//EMPTY_AVATAR_BMD ||= UI.getEmptyAvatarBitmapData(avatarSize * 2, avatarSize * 2);
			EMPTY_AVATAR_BMD ||= UI.drawAssetToRoundRect(new SWFEmptyAvatar(), avatarSize * 2);
			return EMPTY_AVATAR_BMD;
		}
		
		protected function generateCacahedAssets():void{		
			SETTINGS_BMD ||= UI.renderAsset(new SWFMediaSettings , BUTTON_SIZE, BUTTON_SIZE, true);
			LOUDSPEAKER_ON_BMD ||= UI.renderAsset(new SWFMediaLoudspeakerOnBlue , BUTTON_SIZE, BUTTON_SIZE, true);		
			LOUDSPEAKER_OFF_BMD ||= UI.renderAsset(new SWFMediaLoudspeakerOff , BUTTON_SIZE, BUTTON_SIZE, true);
			MICROPHONE_ON_BMD ||= UI.renderAsset(new SWFMediaMicOn , BUTTON_SIZE, BUTTON_SIZE, true);
			MICROPHONE_OFF_BMD ||= UI.renderAsset(new SWFMediaMicOff , BUTTON_SIZE, BUTTON_SIZE, true);
			SWITCH_CAMERA_BMD ||= UI.renderAsset(new SWFMediaSwitchCam , BUTTON_SIZE, BUTTON_SIZE, true);
			MEDIA_SOURCE_VIDEO_BMD ||= UI.renderAsset(new SWFCallGreyCamButton   , _width * .5 - Config.DOUBLE_MARGIN, BUTTON_SIZE*1.7, true);
			//MEDIA_SOURCE_VIDEO_GREEN_BMD ||= UI.renderAsset(new SWFCallGreenCamButton , _width * .5 - Config.DOUBLE_MARGIN, BUTTON_SIZE*1.7, true);
			MEDIA_SOURCE_AUDIO_BMD ||= UI.renderAsset(new SWFCallGreenCamButton,  _width * .5 - Config.DOUBLE_MARGIN, BUTTON_SIZE*1.7, true);
			DROP_CALL_BMD ||= UI.renderAsset(new SWFCallRedButton ,  _width * .5 - Config.DOUBLE_MARGIN, BUTTON_SIZE*1.7, true);
			CHAT_BMD ||= UI.renderAsset(new SWFMediaChatIcon ,  BUTTON_SIZE, BUTTON_SIZE, true);
		}	
		
		protected function disposeButtons():void {
			// cleanup all bitmap datas 
			UI.disposeBMD(SETTINGS_BMD);
			UI.disposeBMD(LOUDSPEAKER_ON_BMD);
			UI.disposeBMD(LOUDSPEAKER_OFF_BMD);				
			UI.disposeBMD(MICROPHONE_ON_BMD);
			UI.disposeBMD(MICROPHONE_OFF_BMD);			
			UI.disposeBMD(SWITCH_CAMERA_BMD);
			UI.disposeBMD(MEDIA_SOURCE_VIDEO_BMD);			
			//UI.disposeBMD(MEDIA_SOURCE_VIDEO_GREEN_BMD);			
			UI.disposeBMD(MEDIA_SOURCE_AUDIO_BMD);
			
			SETTINGS_BMD=null;
			LOUDSPEAKER_ON_BMD=null;
			LOUDSPEAKER_OFF_BMD=null;		
			MICROPHONE_ON_BMD=null;
			MICROPHONE_OFF_BMD =null;		
			SWITCH_CAMERA_BMD=null;		
			MEDIA_SOURCE_VIDEO_BMD=null;
			//MEDIA_SOURCE_VIDEO_GREEN_BMD=null;
			MEDIA_SOURCE_AUDIO_BMD=null;		
			DROP_CALL_BMD=null;
			CHAT_BMD=null;
		
			// dispose buttons insances
			if (btnHangup != null)
				btnHangup.dispose();
				btnHangup  = null;		
				
			if (btnLoudspeaker != null)
				btnLoudspeaker.dispose();
				btnLoudspeaker  = null;
				
			if (btnMute != null)
				btnMute.dispose();
				btnMute  = null;
				
			if (btnOpenChat != null)
				btnOpenChat.dispose();
				btnOpenChat  = null;
				
			if (btnSwitch != null)
				btnSwitch.dispose();
				btnSwitch  = null;
			if (btnSwitchCams != null)
				btnSwitchCams.dispose();
				btnSwitchCams  = null;	
			if (btnSettings != null)
				btnSettings.dispose();
				btnSettings  = null;				
		}
		
		protected function onCallVOChanged():void{
			if (CallManager.getCallVO().mode == CallManager.MODE_AUDIO){
				if (myCameraVideo != null) {
					myCameraVideo.attachCamera(null);
					ProximityController.start()
				}
			} else {	
				if (myCameraVideo != null){
					myCameraVideo.attachCamera(CallManager.camera);
					myCameraVideo.width = 362; // CallManager.getCameraSetting().cameraWidth;
					myCameraVideo.height = 204;// CallManager.getCameraSetting().cameraHeight;
					ProximityController.stop()
				}
			}
			drawView();
			
		}
		
		protected function onBtnSwitch():void{
			CallManager.changeLocalCallMode();
		}
		
		protected function onBtnMute():void{
			CallManager.muteMicrophone();
		}
		
		private function onBtnLoudspeaker():void{
			CallManager.changeLoudspeaker();
		}
		
		private function onBtnOpenChat():void{
			
		}
		
		private function onBtnSettings():void{
			// call dialog 
			//DialogManager.alert("Video Settings", "Settings here", null);
			DialogManager.showVideoSettings();
		}
		
		protected function onBtnSwitchCams():void{
			CallManager.changeCamera();
		}
		
		protected function onBtnHangup():void{
			CallManager.cancel();
		}
		
		override public function activateScreen():void{
			super.activateScreen();
			CallManager.S_STREAM_READY.add(onStreamReady);
			CallManager.S_VIDEO_SIZE_CHANGED.add(onVideoSizeChanged);
			CallManager.S_CALLVO_CHANGED.add(onCallVOChanged);
			
			//btnWokitoki.activate();
			btnHangup.activate();
			btnLoudspeaker.activate();
			btnMute.activate();
			btnSwitch.activate();
			
			//todo - if shown, then activate
			btnSwitchCams.activate();
			btnSettings.activate();
			
			onStreamReady();
			stopRenderingBitmap();
			onCallVOChanged();
			IdleManager.keepAwake(true);
			PointerManager.addDown(myCameraTop, onMyCamTap);
			
			Loop.add(videoSizeWatcher);
		}
		
		private var kostil:int = 0;
		
		private function videoSizeWatcher():void{
			if (_isDisposed)
				return;
				
			if (incomeVideo == null || incomeVideo.parent == null)
				return;
				
			if (oldVideoHeight == incomeVideo.videoHeight && oldVideoWidth == incomeVideo.videoWidth)
				return;
				
			oldVideoHeight = incomeVideo.videoHeight;
			oldVideoWidth = incomeVideo.videoWidth;
			onCallVOChanged();
		
		}
		
		private function onMyCamTap(...rest):void{
			dx = myCameraTop.x;
			dy = myCameraTop.y;
			startMX = MobileGui.stage.mouseX;
			startMY = MobileGui.stage.mouseY;
			
			MobileGui.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			MobileGui.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}
		
		private function onMouseMove(e:MouseEvent):void{
			var cd:Array=moveMyCam();
			TweenMax.to(myCameraTop, .3, {x:cd[0], y:cd[1]});
		}
		
		private function moveMyCam():Array{
			var tx:int = dx + (MobileGui.stage.mouseX - startMX);
			var ty:int = dy + (MobileGui.stage.mouseY - startMY);
			var cs:int = myCamSize * 2;
			if (tx < 0)
				tx = 0;
			if (ty < myCamSize * .2)
				ty = myCamSize * .2;
			
			if (tx + myCamSize * 2 > _width)
				tx = _width - myCamSize * 2;
			if (ty + myCamSize * 2 + myCamSize * .2 > _height)
				ty = (_height) - myCamSize * 2 - myCamSize * .2;
			return [tx, ty];
		}
		
		private function onMouseUp(e:MouseEvent):void{
			MobileGui.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			MobileGui.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			var cd:Array = moveMyCam();
			TweenMax.killTweensOf(myCameraTop);
			TweenMax.to(myCameraTop, .4, {x:cd[0], y:cd[1],ease:Back.easeOut});
		}
		
		override public function deactivateScreen():void{
			super.deactivateScreen();
			CallManager.S_STREAM_READY.remove(onStreamReady);
			CallManager.S_VIDEO_SIZE_CHANGED.remove(onVideoSizeChanged);
			CallManager.S_CALLVO_CHANGED.remove(onCallVOChanged);
			btnHangup.deactivate();
			btnSettings.deactivate();
			btnLoudspeaker.deactivate();
			btnMute.deactivate();
			btnOpenChat.deactivate();
			btnSwitch.deactivate();
			btnSwitchCams.deactivate();
			ProximityController.stop();
			Loop.remove(videoSizeWatcher);
			//btnWokitoki.deactivate();
			IdleManager.keepAwake(false);
		}
		
		/**
		 * Start Track Activity 
		 */
		protected function startTrackActivity():void {
			echo("TalkScreen", "startTrackActivity", "");
			isTrackingActivity  = true;
			TweenMax.killDelayedCallsTo(onNoActivityTimeout);
			TweenMax.delayedCall(activityDetectionTime, onNoActivityTimeout);
			PointerManager.addUp(MobileGui.stage, onActivityAction);
		}		
		
		/**
		 * Stop track Activity 
		 */
		protected function stopTrackActivity():void {
			isTrackingActivity = false;
			TweenMax.killDelayedCallsTo(onNoActivityTimeout);
			PointerManager.removeUp(MobileGui.stage, onActivityAction);
			showUI();
		}
		
		/**
		 * Some activity ocured show UI and reset timer if needed
		 * reset timer if activityTracking
		 */
		private function onActivityAction(e:Event=null):void {			
			if (isTrackingActivity) {
				TweenMax.killDelayedCallsTo(onNoActivityTimeout);
				TweenMax.delayedCall(activityDetectionTime, onNoActivityTimeout);
				showUI();
			}
		}
		
		/**
		 * No Activity for lomng time hideUI
		 */
		private function onNoActivityTimeout():void {
			echo("TalkScreen", "onNoActivityTimeout");
			hideUI();				
		}
		
		private function showUI():void {
			uiVisibleActive = true;
			updateButtonsVisibility();
			if (speachInicator)
			{
				speachInicator.visible = false;
			}
		}
		
		private function hideUI():void {
			uiVisibleActive = false;
			updateButtonsVisibility();
			if (speachInicator)
			{
				speachInicator.visible = ((CallManager.getCallVO() != null) && (CallManager.getCallVO().loudspeaker));
			}
		}
		
		private function updateButtonsVisibility():void	{
			if (_isDisposed) 
				return;
			if(btnSwitch!=null)
				btnSwitch.visible = uiVisibleActive;
			if(btnHangup!=null)
				btnHangup.visible = uiVisibleActive;
			if(btnMute!=null)
				btnMute.visible = uiVisibleActive;
			if(btnLoudspeaker!=null)
				btnLoudspeaker.visible = uiVisibleActive;
			if(btnOpenChat!=null)
				btnOpenChat.visible = uiVisibleActive;
			if(btnSwitchCams!=null)
				btnSwitchCams.visible = uiVisibleActive;
			if(btnSettings!=null)
				btnSettings.visible = uiVisibleActive;
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
		
		protected function onStreamReady():void {
			if (isDisposed)
				return;
			if (CallManager.getIncomeStream() != null)
				incomeVideo.attachNetStream(CallManager.getIncomeStream());
		}
		
		protected function onVideoSizeChanged():void{
			drawView();
		}
		
		override protected function drawView():void{
			if (isDisposed)
				return;
			_view.graphics.clear();
			_view.graphics.beginFill(0x222533);
			_view.graphics.drawRect(0, 0, _width, _height);
			
			// debug
			if(debug!=null && debug.parent!=null)
				debug.text = CallManager.getCallVO().toString();
			
			
			if (CallManager.getCallVO().loudspeaker == true) {
				// SPEAKER IS ON
				btnLoudspeaker.setBitmapData(LOUDSPEAKER_ON_BMD);				
			} else{
				// SPEAKER IS OFF
				btnLoudspeaker.setBitmapData(LOUDSPEAKER_OFF_BMD);			
			}
			
			if (CallManager.getCallVO().mute){
				// MUTED
				btnMute.setBitmapData(MICROPHONE_OFF_BMD);
			}else {				
				// UNMUTED
				btnMute.setBitmapData(MICROPHONE_ON_BMD);
			}			
			
			if (CallManager.getCallVO().mode == CallManager.MODE_VIDEO){
				// SET BUTTON (AUDIO)
				btnSwitch.setBitmapData(MEDIA_SOURCE_AUDIO_BMD);
			}else{
				// SET BUTTON (VIDEO)
				btnSwitch.setBitmapData(MEDIA_SOURCE_VIDEO_BMD);
			}
			
			// change between avatar & video
			if (CallManager.getCallVO().broadcastMode == CallManager.MODE_VIDEO){
				startTrackActivity();
				// ATTACH VIDEO OBJECT
				if (incomeVideoSprite != null && incomeVideoSprite.parent==null)
					incomeVideoBox.addChild(incomeVideoSprite);
				incomeAvatarBox.visible = false;
			}else {
				stopTrackActivity();
				// REMOVE VIDEO OBJECT
				if (incomeVideoSprite != null && incomeVideoSprite.parent)
					incomeVideoSprite.parent.removeChild(incomeVideoSprite);
				incomeAvatarBox.visible = true;
			}
			
			if (CallManager.getCallVO().mode == CallManager.MODE_VIDEO){
				myCameraTop.visible = true;
				if (myCameraSprite != null && myCameraSprite.parent == null)
					myCameraBox.addChild(myCameraSprite);
					
				if (myCameraVideo.parent == null)
					myCameraSprite.addChild(myCameraVideo);
				
				btnSwitchCams.activate(); 
				btnSwitchCams.show(.3); // show if is active 
				btnSettings.activate();
				btnSettings.show(.3);
					
			}else{
				myCameraTop.visible = false;
				if (myCameraSprite != null && myCameraSprite.parent)
					myCameraSprite.parent.removeChild(myCameraSprite);
				
				btnSwitchCams.deactivate();
				btnSwitchCams.hide(.3);
				btnSettings.deactivate();
				btnSettings.hide(.3);
			}
			
			// Setup video size
			if (incomeVideo != null){
				
				incomeVideoSprite.rotation = 0;
				incomeVideo.width = CallManager.getCallVO().broadcasterCameraW;
				incomeVideo.height = CallManager.getCallVO().broadcasterCameraH;
				incomeVideoSprite.x = 0;
				incomeVideoSprite.y = 0;
				
				if (CallManager.getCallVO().broadcasterCameraR ==-90){
					incomeVideoSprite.rotation = -90;
					incomeVideoSprite.width = _width;
					incomeVideoSprite.x = 0;
					incomeVideoSprite.y = incomeVideoSprite.height;
				}else{
					incomeVideoSprite.rotation = 90;
					incomeVideoSprite.width = _width;
					incomeVideoSprite.x = incomeVideoSprite.width;
					incomeVideoSprite.y = 0;
				}
			}
			
			if (myCameraVideo != null){
				//scale down cam
				myCameraVideo.width = 362;// CallManager.getCameraSetting().cameraWidth;
				myCameraVideo.height = 204;//  CallManager.getCameraSetting().cameraHeight;

				
				var vs:int = myCamSize * 2;
				
				
				if (Config.PLATFORM_ANDROID && CallManager.getCallVO().cameraIndex == 1){
					// rotate -90
					myCameraSprite.rotation = -90;
					myCameraSprite.x = 0;
					myCameraSprite.y = myCameraSprite.height;
					myCameraSprite.width = vs;
					
					myCameraBox.y = (vs - myCameraSprite.height) * .5;
					myCameraBox.x = 0;
				}else{
					//rotate if needed: 90
					myCameraSprite.rotation = 90;
					myCameraSprite.x = myCameraSprite.width;
					myCameraSprite.y = 0;
					myCameraSprite.width = vs;
					myCameraBox.y = (vs - myCameraSprite.height) * .5;
					myCameraBox.x = 0;
				}
			}
			//positionWokitokiButton();
			// Setup avatar
			incomeAvatarBox.x = (_width - incomeAvatarBox.width) * .5;
			incomeAvatarBox.y = Config.FINGER_SIZE+Config.DOUBLE_MARGIN*2+Config.APPLE_TOP_OFFSET;
		}
		
		override public function dispose():void{
			super.dispose();
			stopTrackActivity();
			oldVideoWidth = 0;
			oldVideoHeight = 0;

			if(myCameraVideo!=null)
				myCameraVideo.attachCamera(null);

			if (incomeVideo != null){
				incomeVideo.clear();
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
			disposeButtons();
			
			if (speachInicator)
			{
				UI.destroy(speachInicator);
				speachInicator = null;
			}
			
			if (SPEACH_BLUE_BMD)
			{
				UI.disposeBMD(SPEACH_BLUE_BMD);
				SPEACH_BLUE_BMD = null;
			}
			if (SPEACH_RED_BMD)
			{
				UI.disposeBMD(SPEACH_RED_BMD);
				SPEACH_RED_BMD = null;
			}
		}
	}
}