package com.dukascopy.connect.screens.call {

	import assets.LogoRectangle;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.base.ScreenParams;
	import com.dukascopy.connect.sys.callManager.CallManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.sound.SoundController;
	import com.dukascopy.connect.vo.CallVO;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;

	/**
	 * Класс полностью завершен! Не трогать без спроса!!!
	 * @author Ilya Shcherbakov. Telefision AG.
	 */
	
	public class CallScreen extends BaseScreen {
		
		private var bg:Shape;
		private var avatar:Bitmap;
		private var lblUsername:Bitmap;
		private var lblType:Bitmap;
		private var btnAnswer:BitmapButton;
		private var btnVideo:BitmapButton;
		private var btnCancel:BitmapButton;
		private var btn:Sprite;
		
		private var callVO:CallVO;
		
		private var videoGreen:ImageBitmapData;
		private var videoGrey:ImageBitmapData;
		private var audioGreen:ImageBitmapData;
		private var audioGrey:ImageBitmapData;
		private var dcIcon:ImageBitmapData;
		private var eaIcon:ImageBitmapData;
		
		private var avatarSize:int;
		
		public function CallScreen() {
			super();
		}
		
		override protected function createView():void {
			super.createView();
			bg = new Shape();
				bg.graphics.beginFill(0);
				bg.graphics.drawRect(0, 0, 1, 1);
				bg.graphics.endFill();
			_view.addChild(bg);
			avatar = new Bitmap();
				avatar.y = Config.FINGER_SIZE;
				avatar.visible = false;
			_view.addChild(avatar);
			lblUsername = new Bitmap();
				lblUsername.x = Config.MARGIN;
			_view.addChild(lblUsername);
			lblType = new Bitmap();
				lblType.x = Config.MARGIN;
			_view.addChild(lblType);
			btnAnswer = new BitmapButton();
				btnAnswer.setStandartButtonParams();
				btnAnswer.setDownScale(.8);
				btnAnswer.setAlphaBlink(0);
				btnAnswer.setScaleBlink(1.1);
				btnAnswer.tapCallback = onAnswerTap;
				btnAnswer.hide();
			_view.addChild(btnAnswer);
			btnVideo = new BitmapButton();
				btnVideo.setStandartButtonParams();
				btnVideo.setDownScale(.8);
				btnVideo.setAlphaBlink(0);
				btnVideo.setScaleBlink(1.1);
				btnVideo.tapCallback = onVideoTap;
				btnVideo.hide();
			_view.addChild(btnVideo);
			btnCancel = new BitmapButton();
				btnCancel.setStandartButtonParams();
				btnCancel.setDownScale(.8);
				btnCancel.tapCallback = onCancelTap;
				btnCancel.hide();
			_view.addChild(btnCancel);
		}
		
		override public function onBack(e:Event = null):void { }
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			_params.title = "Call screen";
			
			callVO = data as CallVO;
			
			var trueWidth:int = int((_width - Config.FINGER_SIZE * 1.25) * .5);
			audioGreen ||= drawButton(0x87CA28, 0x61901E, new SWFCallingIconUp(), .5, trueWidth, Config.FINGER_SIZE, "Call");
			audioGrey ||= drawButton(0x5E6675, 0x3F4859, new SWFCallingIconUp(), .5, trueWidth, Config.FINGER_SIZE, "Call");
			videoGreen ||= drawButton(0x87CA28, 0x61901E, new SWFVideoCamIcon(), .5, trueWidth, Config.FINGER_SIZE, "Video");
			videoGrey ||= drawButton(0x5E6675, 0x3F4859, new SWFVideoCamIcon(), .5, trueWidth, Config.FINGER_SIZE, "Video");
			
			var bottomY:int = _height - Config.FINGER_SIZE_DOUBLE;
			var btnOffset:int = int((_width - trueWidth * 2) * .33);
			
			if (callVO.videoRecognition == true) {
				lblType.bitmapData = UI.renderText("Video Identification", _width - Config.DOUBLE_MARGIN, 10, true, TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .36, true, 0xF1F4f5, 0, true);
				// btn Answer setup
				btnAnswer.setBitmapData(audioGreen);
				btnAnswer.x = btnOffset;
				btnAnswer.y = bottomY;
				btnAnswer.show(.3, .4);
				// btn Cancel setup
				btnCancel.setBitmapData(drawButton(0xD92626, 0xA51919, new SWFCallingIconDown(), .7, trueWidth, Config.FINGER_SIZE, "Cancel"));
				btnCancel.x = btnOffset * 2 + trueWidth;
				btnCancel.y = bottomY;
				btnCancel.show(.3, .4);
			} else {
				lblType.bitmapData = UI.renderText(callVO.type.substr(4) + " Call...", _width - Config.DOUBLE_MARGIN, 10, true, TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .36, true, 0xF1F4f5, 0, true);
				// btn Cancel setup
				btnCancel.setBitmapData(drawButton(0xD92626, 0xA51919, new SWFCallingIconDown(), .7, _width - Config.FINGER_SIZE, Config.FINGER_SIZE, "Cancel"));
				btnCancel.x = btnOffset;
				btnCancel.y = bottomY;
				btnCancel.show(.3, .4);
				bottomY = btnCancel.y - Config.DOUBLE_MARGIN - Config.FINGER_SIZE;
				// btn Answer setup
				btnAnswer.setBitmapData(audioGreen);
				btnAnswer.x = btnOffset;
				btnAnswer.y = bottomY;
				btnAnswer.show(.3, .4);
				// btn Video setup
				btnVideo.setBitmapData(videoGrey);
				btnVideo.x = btnOffset * 2 + trueWidth;
				btnVideo.y = bottomY;
				btnVideo.show(.3, .4);
			}
			
			bottomY = bottomY - lblType.height - Config.MARGIN - Config.FINGER_SIZE;
			
			var minSizeAvatar:int = Config.FINGER_SIZE;
			var maxSizeAvatar:int = _width - Config.FINGER_SIZE_DOUBLE;
			var lblUsernameMaxHeight:int = bottomY - minSizeAvatar - Config.FINGER_SIZE - Config.DOUBLE_MARGIN;
			lblUsername.bitmapData = UI.renderTextByHeightWithMinMaxFontSize(callVO.name, _width - Config.DOUBLE_MARGIN, lblUsernameMaxHeight, true, TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .27, Config.FINGER_SIZE * .8, true, 0xFFFFFF, 0, true);
			
			bottomY = bottomY - lblUsername.height - Config.DOUBLE_MARGIN;
			
			if (bottomY - Config.FINGER_SIZE > maxSizeAvatar) {
				avatarSize = maxSizeAvatar;
				avatar.x = Config.FINGER_SIZE;
			} else {
				avatarSize = bottomY - Config.FINGER_SIZE;
				avatar.x = int((_width - avatarSize) * .5);
			}
			
			lblUsername.y = avatar.y + avatarSize + Config.DOUBLE_MARGIN;
			lblType.y = lblUsername.y + lblUsername.height + Config.MARGIN;
			
			if (callVO.videoRecognition == true) {
				var logo:MovieClip = new LogoRectangle();
				logo.width = logo.height = avatarSize;
				dcIcon = UI.getSnapshot(logo, StageQuality.HIGH, "CallScreen.avatar.logo");
				onAvatarLoaded("", dcIcon);
				logo = null;
			} else if (callVO.avatar == null || callVO.avatar == "") {
				eaIcon = UI.getEmptyAvatarBitmapData(avatarSize, avatarSize);
				onAvatarLoaded("", eaIcon);
			} else {
				ImageManager.loadImage(callVO.avatar, onAvatarLoaded);
			}
			
			onCallVOChanged();
		}
		
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
		
		private function onAvatarLoaded(url:String, bmd:ImageBitmapData):void {
			if (_isDisposed)
				return;
			if (bmd == null)
				return;
			if (bmd.isDisposed == true)
				return;
			avatar.visible = true;
			if (avatar.bitmapData == null)
				avatar.bitmapData = new BitmapData(avatarSize, avatarSize, true, 0);
			try {
				ImageManager.drawCircleImageToBitmap(avatar.bitmapData, bmd, 0, 0, avatarSize*.5);
			} catch (err:Error) {
				//trace(err.message);
			}
		}
		
		override protected function drawView():void {
			bg.width = _width;
			bg.height = _height;
		}
		
		override public function activateScreen():void {
			if (_isDisposed) return;
			if (btnAnswer != null)
				btnAnswer.activate();
			if (btnCancel != null)
				btnCancel.activate();
			if (btnVideo != null)
				btnVideo.activate();
			CallManager.S_CALLVO_CHANGED.add(onCallVOChanged);
			onCallVOChanged();
		}
		
		private function onCallVOChanged():void {
			if (callVO.videoRecognition == true) {
				btnAnswer.isBlinking = false;
				btnVideo.isBlinking = false;
			} else {
				if (callVO.mode == CallManager.MODE_AUDIO) {
					btnAnswer.setBitmapData(audioGreen);
					btnVideo.setBitmapData(videoGrey);
					btnAnswer.isBlinking = true;
					btnVideo.isBlinking = false;
				} else {
					btnAnswer.setBitmapData(audioGrey);
					btnVideo.setBitmapData(videoGreen);
					btnAnswer.isBlinking = false;
					btnVideo.isBlinking = true;
				}
			}
			drawView();
		}
		
		override public function deactivateScreen():void {
			if (_isDisposed) return;
			if (btnAnswer != null)
				btnAnswer.deactivate();
			if (btnCancel != null)
				btnCancel.deactivate();
			if (btnVideo != null)
				btnVideo.deactivate();
			CallManager.S_CALLVO_CHANGED.remove(onCallVOChanged);
		}		
		
		// Аудио Кнопка
		private function onAnswerTap(...rest):void {
			if (callVO.type == CallManager.TYPE_INCOMING) {
				if(btnAnswer)
					btnAnswer.deactivate();
				SoundController.stopAllSounds();
				CallManager.accept(CallManager.MODE_AUDIO);
				return;
			}
			if (callVO.mode != CallManager.MODE_AUDIO)
				CallManager.changeCallMode(CallManager.MODE_AUDIO);
			onCallVOChanged();
		}
		
		// Видева кнопка
		private function onVideoTap(e:Event = null):void {
			if (callVO.type == CallManager.TYPE_INCOMING){
				if(btnVideo)
					btnVideo.deactivate();
				SoundController.stopAllSounds();
				CallManager.accept(CallManager.MODE_VIDEO);
				return;
			}
			if (callVO.mode != CallManager.MODE_VIDEO)
				CallManager.changeCallMode(CallManager.MODE_VIDEO);
			onCallVOChanged();
		}
		
		private function onCancelTap(...rest):void {
			if (callVO.type == CallManager.TYPE_INCOMING)
				CallManager.reject();
					else
						CallManager.cancel();
			if (btnCancel)
				btnCancel.deactivate();
		}
		
		override public function dispose():void {
			if (_isDisposed)
				return;
			_view.graphics.clear();
			if (btnAnswer != null)
				btnAnswer.dispose();
			btnAnswer = null;
			if (btnCancel != null)
				btnCancel.dispose();
			btnCancel = null;
			if (btnVideo != null)
				btnVideo.dispose();
			btnVideo = null;
			if (btn != null) {
				while (btn.numChildren)
					btn.removeChildAt(0);
				UI.destroy(btn);
			}
			btn = null;
			UI.destroy(avatar);
			avatar = null;
			UI.destroy(lblUsername);
			lblUsername = null;
			UI.destroy(lblType);
			lblType = null;
			UI.destroy(bg);
			bg = null;
			UI.disposeBMD(audioGreen);
			audioGreen = null;
			UI.disposeBMD(audioGrey);
			audioGrey = null
			UI.disposeBMD(videoGreen);
			videoGreen = null;
			UI.disposeBMD(videoGrey);
			videoGrey = null;
			UI.disposeBMD(dcIcon);
			dcIcon = null;
			UI.disposeBMD(eaIcon);
			eaIcon = null;
			callVO = null;
			super.dispose();
		}
	}
}