package com.dukascopy.connect.screens.call 
{
	import assets.StartRecognitionButton;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.AgreementBox;
	import com.dukascopy.connect.gui.components.CirclePreloader;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.sys.callManager.CallManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.langs.Lang;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class TalkScreenRecognition extends TalkScreen
	{
		private var startRecognitionButton:BitmapButton;
		private var START_BUTTON_BMD:ImageBitmapData;
		private var agreement:AgreementBox;
		private var btn:Sprite;
		private var loader:CirclePreloader;
		
		public function TalkScreenRecognition() 
		{
			startRecognitionButton = new BitmapButton();
			startRecognitionButton.setStandartButtonParams();
			startRecognitionButton.setBitmapData(START_BUTTON_BMD, true);
			startRecognitionButton.setDownScale(1);
			startRecognitionButton.tapCallback = onBtnStart;
			startRecognitionButton.hide();
		//	startRecognitionButton.show();
			_view.addChild(startRecognitionButton);
			
			loader = new CirclePreloader(NaN, NaN, Style.color(Style.COLOR_BACKGROUND));
			_view.addChild(loader);
			
			agreement = new AgreementBox();
			_view.addChild(agreement);
		}
		
		//!TODO!!!! копия из CallScreen!;
		private function drawButton(color:uint, colorSide:uint, icon:Sprite, iconSize:Number, width:int, height:int, name:String):ImageBitmapData {
			if (btn == null) {
				btn = new Sprite();
			} else {
				btn.graphics.clear();
				while (btn.numChildren)
					btn.removeChildAt(0);
			}
			var trueH:int = height * .93;
			btn.graphics.beginFill(colorSide);
			btn.graphics.drawRoundRect(0, 0, width, height, Config.FINGER_SIZE_DOT_75, Config.FINGER_SIZE_DOT_75);
			btn.graphics.beginFill(color);
			btn.graphics.drawRoundRect(0, 0, width, trueH, Config.FINGER_SIZE_DOT_75, Config.FINGER_SIZE_DOT_75);
			btn.graphics.endFill();
			
			var percentage:Number = icon.width / icon.height;
			if (icon.width > icon.height) {
				icon.width = int(trueH * iconSize);
				icon.height = int(icon.width / percentage);
			} else {
				icon.height = int(trueH * iconSize);
				icon.width = int(icon.height * percentage);
			}
			icon.x = int((width - icon.width) * .5);
			icon.y = int((trueH - icon.height) * .5);
			btn.addChild(icon);
			
			return UI.getSnapshot(btn, StageQuality.HIGH, "CallScreen::button" + name);
		}
		
		override public function initScreen(data:Object = null):void{
			super.initScreen(data);
			
			incomeVideoBox.visible = false;
			btnSwitch.visible = false;
			btnOpenChat.visible = false;
			btnSwitchCams.visible = false;
			btnSettings.visible = false;
			incomeAvatarBox.visible = false;
			incomeVideoSprite.visible = false;
			incomeVideo.visible = false;
			myCameraTop.visible = false;
			myCameraBox.visible = false;
			btnHangup.hide();
			btnHangup.setBitmapData(drawButton(0xD92626, 0xA51919, new SWFCallingIconDown(), .7, int((_width - Config.FINGER_SIZE * 1.5) * .5), Config.FINGER_SIZE, "Cancel"));
			
			btnHangup.show(.3, 0);
			var icon:StartRecognitionButton = new StartRecognitionButton();
			var startButtonSize:int = Math.min(Config.FINGER_SIZE * 6, _width/1.6);
			UI.scaleToFit(icon, startButtonSize, startButtonSize);
			
			startRecognitionButton.setBitmapData(UI.getSnapshot(icon, StageQuality.HIGH, "TalkScreenRecognition.icon"), true);
			UI.destroy(icon);
			icon = null;
			
			startRecognitionButton.x = _width * .5 - startRecognitionButton.width * .5;
			startRecognitionButton.y = _height / 2.5 - startRecognitionButton.height * .5;
			
			if (loader != null)
			{
				loader.x = startRecognitionButton.x + startRecognitionButton.width * .5;
				loader.y = startRecognitionButton.y + startRecognitionButton.height * .5;
			}
		}
		
		private function destroyAgreement():void {
			if (agreement != null) {
				agreement.dispose();
			}
			agreement = null;
		}
		
		private function activateAgreement():void {
			if (agreement != null)
				agreement.activate();
		}
		
		private function deactivateAgreement():void {
			if (agreement != null)
				agreement.deactivate();		
		}
		
		override protected function setDefaultAvatarImage():void{
			
		}
		
		override public function deactivateScreen():void{
			super.deactivateScreen();
			deactivateAgreement();
			startRecognitionButton.deactivate();
		}
		
		private function updateButtonsVisibility():void	{
			if (_isDisposed) 
				return;
			if(btnSwitch!=null)
				btnSwitch.visible = false;
			if(btnHangup!=null)
				btnHangup.visible = uiVisibleActive;
			if(btnMute!=null)
				btnMute.visible = uiVisibleActive;
			//if(btnLoudspeaker!=null)
				//btnLoudspeaker.visible = uiVisibleActive;
			if(btnOpenChat!=null)
				btnOpenChat.visible = false;
			if(btnSwitchCams!=null)
				btnSwitchCams.visible = false;
			if(btnSettings!=null)
				btnSettings.visible = uiVisibleActive;
			if(startRecognitionButton!=null)
				startRecognitionButton.visible = uiVisibleActive;
		}
		
		override protected function drawView():void{
			if (isDisposed)
				return;
			_view.graphics.clear();
			_view.graphics.beginFill(0x222533);
			_view.graphics.drawRect(0, 0, _width, _height);
			_view.graphics.endFill();
			
			// debug
			trace("CALLMANAGER", "drawView", CallManager.getCallVO());
			if (debug != null && debug.parent != null && CallManager.getCallVO() != null)
			{
				
				debug.text = CallManager.getCallVO().toString();
			}
			
			if (CallManager.getCallVO() != null)
			{
				if (CallManager.getCallVO().loudspeaker) {
					// SPEAKER IS ON
					btnLoudspeaker.setBitmapData(LOUDSPEAKER_OFF_BMD);
				} else {
					// SPEAKER IS OFF
					btnLoudspeaker.setBitmapData(LOUDSPEAKER_ON_BMD);
				}
				
				if (CallManager.getCallVO().mute) {
					// MUTED
					btnMute.setBitmapData(MICROPHONE_OFF_BMD);
				} else {				
					// UNMUTED
					btnMute.setBitmapData(MICROPHONE_ON_BMD);
				}
			}
			
			
			var margin:int = Config.FINGER_SIZE*.4;
			var maxTextSize:int = _height - btnMute.y - btnMute.height - margin * 6 - startRecognitionButton.height - btnHangup.height;
			
			agreement.setSize(_width - Config.MARGIN * 8, maxTextSize, true);
			if (CallManager.getCallVO().entryPointID == Config.EP_VI_EUR)
				agreement.setText(Lang.videoAgreementEuropa);
			else if (CallManager.getCallVO().entryPointID == Config.EP_VI_PAY)
				agreement.setText(Lang.videoAgreementPay);
			else
				agreement.setText(Lang.videoAgreementBank);
			
			var contentHeight:int = agreement.getHeight() + margin * 4 + btnHangup.height + startRecognitionButton.height;
			var startPosition:int = (_height - btnMute.y - btnMute.height) * .5 - contentHeight * .5 + btnMute.y + btnMute.height;
			
			_view.graphics.lineStyle(Math.max(2, int(Config.FINGER_SIZE * 0.02)), 0x0896EA);
			_view.graphics.drawRoundRect(Config.MARGIN*2, startPosition, _width - Config.MARGIN*4, contentHeight - btnHangup.height - margin, Config.FINGER_SIZE, Config.FINGER_SIZE);
			
			agreement.y = startPosition + margin;
			agreement.x = Config.MARGIN * 4;
			
			startRecognitionButton.y = agreement.y + agreement.getHeight() + margin;
			startRecognitionButton.x = int(_width * .5 - startRecognitionButton.width * .5);
			
			btnHangup.x = int(_width * .5 - btnHangup.width * .5);
			btnHangup.y = startRecognitionButton.y + startRecognitionButton.height + margin * 2;
			
			if (loader != null)
			{
				loader.x = startRecognitionButton.x + startRecognitionButton.width * .5;
				loader.y = startRecognitionButton.y + startRecognitionButton.height * .5;
			}
		}
		
		override protected function loadAvatar():void {
			
		}
		
		private function onBtnStart():void {
			CallManager.startRecognition();
		}
		
		override protected function onStreamReady():void {
			super.onStreamReady();
			hidePreloader();
			startRecognitionButton.show();
		}
		
		private function hidePreloader():void 
		{
			if (loader != null)
			{
				loader.dispose();
				loader = null;
			}
		}
		
		override public function activateScreen():void{
			super.activateScreen();
			CallManager.S_STREAM_READY.add(onStreamReady);
			CallManager.S_VIDEO_SIZE_CHANGED.add(onVideoSizeChanged);
			CallManager.S_CALLVO_CHANGED.add(onCallVOChanged);
			
			btnHangup.activate();
			//btnLoudspeaker.activate();
			btnMute.activate();
			
			//onStreamReady();
			stopRenderingBitmap();
			onCallVOChanged();
			activateAgreement();
			startRecognitionButton.activate();
		}
		
		override protected function generateCacahedAssets():void{				
			LOUDSPEAKER_ON_BMD ||= UI.renderAsset(new SWFMediaLoudspeakerOn , BUTTON_SIZE, BUTTON_SIZE, true);		
			LOUDSPEAKER_OFF_BMD ||= UI.renderAsset(new SWFMediaLoudspeakerOff , BUTTON_SIZE, BUTTON_SIZE, true);			
			MICROPHONE_ON_BMD ||= UI.renderAsset(new SWFMediaMicOnDark , BUTTON_SIZE, BUTTON_SIZE, true);
			MICROPHONE_OFF_BMD ||= UI.renderAsset(new SWFMediaMicOffDark , BUTTON_SIZE, BUTTON_SIZE, true);
			DROP_CALL_BMD ||= UI.renderAsset(new SWFCallRedButton ,  _width * .5 - Config.DOUBLE_MARGIN, BUTTON_SIZE*1.7, true);
			START_BUTTON_BMD ||= UI.renderAsset(new SWFMediaChatIcon ,  BUTTON_SIZE, BUTTON_SIZE, true);
		}	
		
		override public function dispose():void
		{
			super.dispose();
			destroyAgreement();
			hidePreloader();
		}
		
		override protected function disposeButtons():void {
			super.disposeButtons();
					
			UI.disposeBMD(START_BUTTON_BMD);
			START_BUTTON_BMD = null;
			
			if (btnHangup != null)
				btnHangup.dispose();
				btnHangup  = null;					
		}
	}
}