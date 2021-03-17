package com.dukascopy.connect.screens.call {
	
	import assets.MrzBack;
	import assets.MrzIllustration;
	import assets.MrzScan;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.preloader.Preloader;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.sys.configManager.ConfigManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.mrz.MrzError;
	import com.dukascopy.connect.sys.nativeExtensionController.NativeExtensionController;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.type.MainColors;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import com.hurlant.util.Base64;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.CapsStyle;
	import flash.display.JPEGEncoderOptions;
	import flash.display.JointStyle;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.PermissionEvent;
	import flash.geom.Point;
	import flash.media.Camera;
	import flash.media.Video;
	import flash.permissions.PermissionStatus;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	import flash.utils.ByteArray;
	
	/**
	*	@author Ilya Shcherbakov, Telefision A.G. Team - RIGA
	*/
	
	public class MRZScanScreen extends BaseScreen {
		
		private const CALL_COUNT:int = 4;
		
		private var btnCancel:BitmapButton;
		private var btnScan:BitmapButton;
		private var btnSkip:BitmapButton;
		private var label:Bitmap;
		private var myCameraTop:Sprite;
			private var myCameraBox:Sprite;
				private var myCameraSprite:Sprite;
					private var myCameraVideo:Video;
		private var camera:Camera;
		private var preloader:Preloader;
		private var pic:Bitmap;
		
		private var firstTime:Boolean = true;
		private var uploading:Boolean = false;
		private var trueWidth:int;
		private var trueHeight:int;
		
		private var callCount:int = 0;
		private var btnStart:BitmapButton;
		private var illustration:MrzIllustration;
		private var errorMessage:Sprite;
		private var errorMessageText:Bitmap;
		
		public function MRZScanScreen() {
			
		}
		
		override public function onBack(e:Event = null):void {
			super.onBack();
			NativeExtensionController.S_MRZ_STOPPED.invoke();
		}
		
		override public function initScreen(data:Object = null):void{
			super.initScreen(data);
			_params.title = "MRZ Scan Screen";
			
			myCameraTop = new Sprite();
				myCameraBox = new Sprite();
					myCameraSprite = new Sprite();
					myCameraSprite.graphics.drawRect(0, 0, 1, 1);
						myCameraVideo = new Video();
					myCameraSprite.addChild(myCameraVideo);
				myCameraBox.addChild(myCameraSprite);
			myCameraTop.addChild(myCameraBox);
		//	_view.addChild(myCameraTop);
			
			var textSettings:TextFieldSettings;
			var buttonBitmap:ImageBitmapData;
			var buttonSize:int = Config.FINGER_SIZE * 1.6;
			
			btnStart = new BitmapButton();
			btnStart.setStandartButtonParams();
			btnStart.setDownScale(1);
			btnStart.setDownColor(0);
			btnStart.tapCallback = startClick;
			btnStart.disposeBitmapOnDestroy = true;
			
			
			buttonBitmap = new ImageBitmapData("MRZ.buttonStart", buttonSize, buttonSize);
			var clip:Sprite = new Sprite();
			clip.graphics.beginFill(Color.GREEN);
			clip.graphics.drawCircle(buttonSize * .5, buttonSize * .5, buttonSize * .5);
			clip.graphics.endFill();
			buttonBitmap.draw(clip);
			UI.destroy(clip);
			clip = null;
			
			var text:ImageBitmapData = TextUtils.createTextFieldData(Lang.begin.toUpperCase(), Config.FINGER_SIZE * 4, 10, false, 
																	TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, 
																	Config.FINGER_SIZE * .6, false, Color.WHITE);
			var textResult:ImageBitmapData = TextUtils.scaleBitmapData(text, (buttonSize - Config.FINGER_SIZE * .6) / text.width);
			
			buttonBitmap.copyPixels(textResult, textResult.rect, new Point(int(buttonSize * .5 - textResult.width * .5), int(buttonSize * .5 - textResult.height * .5)), null, null, true);
			textResult.dispose();
			textResult = null;
			text.dispose();
			text = null;
			btnStart.setBitmapData(buttonBitmap, true);
			btnStart.show();
			_view.addChild(btnStart);
			
			btnCancel = new BitmapButton();
			btnCancel.setStandartButtonParams();
			btnCancel.setDownScale(1);
			btnCancel.setDownColor(0);
			btnCancel.tapCallback = cancelClick;
			btnCancel.disposeBitmapOnDestroy = true;
			
			var icon:Sprite = new MrzBack();
			UI.scaleToFit(icon, int(Config.FINGER_SIZE * .8), int(Config.FINGER_SIZE * .8));
			buttonBitmap = UI.getSnapshot(icon);
			btnCancel.setBitmapData(buttonBitmap, true);
			btnCancel.show();
			_view.addChild(btnCancel);
			UI.destroy(icon);
			icon = null;
			
			btnScan = new BitmapButton();
			btnScan.setStandartButtonParams();
			btnScan.setDownScale(1);
			btnScan.setDownColor(0);
			btnScan.tapCallback = nextClick;
			btnScan.disposeBitmapOnDestroy = true;
			icon = new MrzScan();
			UI.scaleToFit(icon, buttonSize, buttonSize);
			btnScan.setBitmapData(UI.getSnapshot(icon), true);
			UI.destroy(icon);
			icon = null;
			btnScan.hide();
			_view.addChild(btnScan);
			
			label = new Bitmap();
			label.bitmapData = TextUtils.createTextFieldData(
				Lang.positionDocumentInFrame, 
				_height - Config.FINGER_SIZE * 2, 
				10,
				true, 
				TextFormatAlign.CENTER, 
				TextFieldAutoSize.LEFT, 
				Config.FINGER_SIZE * .34, 
				true,
				Color.BLACK,
				0xFFFFFF,
				true
			);
			_view.addChild(label);
			
			illustration = new MrzIllustration();
			UI.scaleToFit(illustration, _height - Config.APPLE_TOP_OFFSET - Config.APPLE_BOTTOM_OFFSET - Config.FINGER_SIZE * 5, _width - Config.FINGER_SIZE * 2);
			illustration.rotation = 90;
			view.addChild(illustration);
		}
		
		private function startClick():void 
		{
			if (showCamera())
			{
				showCameraState();
			}
		}
		
		private function showCameraState():void 
		{
			btnStart.dispose();
			btnStart = null;
			UI.destroy(illustration);
			illustration = null;
			btnScan.show(0.3);
			_view.addChildAt(myCameraTop, 0);
			if (label.bitmapData != null)
			{
				label.bitmapData.dispose();
				label.bitmapData = null;
			}
			label.bitmapData = TextUtils.createTextFieldData(
				Lang.positionDocumentInFrame, 
				_height - Config.FINGER_SIZE * 2, 
				10,
				true, 
				TextFormatAlign.CENTER, 
				TextFieldAutoSize.LEFT, 
				Config.FINGER_SIZE * .34, 
				true,
				Color.WHITE,
				0xFFFFFF,
				true
			);
			var icon:Sprite = new MrzBack();
			UI.scaleToFit(icon, int(Config.FINGER_SIZE * .8), int(Config.FINGER_SIZE * .8));
			UI.colorize(icon, Color.WHITE);
			btnCancel.setBitmapData(UI.getSnapshot(icon), true);
			btnCancel.show();
			_view.addChild(btnCancel);
			UI.destroy(icon);
			icon = null;
		}
		
		private function addSkipButton():void {
		//	return;
			if (ConfigManager.config.mrzSkipEnabled == true)
				return;
			if (btnSkip != null)
				return;
			btnSkip = new BitmapButton();
			btnSkip.setStandartButtonParams();
			btnSkip.setDownScale(1);
			btnSkip.setDownColor(0);
			btnSkip.tapCallback = onSkip;
			btnSkip.disposeBitmapOnDestroy = true;
			var textSettings:TextFieldSettings = new TextFieldSettings(Lang.skip, 0xFFFFFF, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, 0x3F6DCD, 1, Config.FINGER_SIZE * .8);
			btnSkip.setBitmapData(buttonBitmap, true);
			btnSkip.rotation = 90;
			btnSkip.rotationAdded = 90;
			updateButtonsPosition();
			btnSkip.hide();
			_view.addChild(btnSkip);
			btnSkip.show(.3, .15, true, .8, 1.1);
			btnSkip.activate();
			btnSkip.x = int(btnSkip.height + Config.DIALOG_MARGIN);
			btnSkip.y = int(Config.APPLE_TOP_OFFSET + trueHeight * .5 - btnSkip.width * .5);
		}
		
		private function onSkip():void {
			NativeExtensionController.S_MRZ_RESULT.invoke(MrzError.ENGINE_INIT_FAILED);
			onBack();
		}
		
		private function cancelClick():void {
			onBack();
		}
		
		private function nextClick():void {
			if (_isDisposed == true)
				return;
			if (uploading == true)
				return;
			if (myCameraVideo != null && (myCameraVideo.videoWidth == 0 || myCameraVideo.videoHeight == 0))
				return;
			if (errorMessage != null)
			{
				TweenMax.killTweensOf(errorMessage);
				view.removeChild(errorMessage);
				UI.destroy(errorMessage);
				errorMessage = null;
			}
			if (errorMessageText != null)
			{
				UI.destroy(errorMessageText);
				errorMessageText = null;
			}
			callCount++;
			uploading = true;
			showPreloader();
			var bmd:BitmapData = new BitmapData(myCameraVideo.videoWidth, myCameraVideo.videoHeight);
			camera.drawToBitmapData(bmd);
			var mrzImage:ByteArray = bmd.encode(bmd.rect, new JPEGEncoderOptions(87));
			var mrzImageString:String = "data:image/jpeg;base64," + Base64.encodeByteArray(mrzImage);
			PHP.call_mrzUpload(onServerResponse, mrzImageString);
			pic ||= new Bitmap();//
			UI.disposeBMD(pic.bitmapData);//
			pic.bitmapData = bmd;//
			UI.scaleToFit(pic, trueHeight, trueWidth);//
		//	myCameraVideo.attachCamera(null);//
			myCameraSprite.addChild(pic);//
			ToastMessage.display(Lang.itMayTake, true);
			TweenMax.delayedCall(5, addSkipButton);
		}
		
		private function onServerResponse(phpRespond:PHPRespond):void {
			if (_isDisposed == true) {
				phpRespond.dispose();
				return;
			}
			hidePreloader();
			uploading = false;
			if (phpRespond.error == true) {
				echo("MRZScanScreen", "onServerResponse", "Error: " + phpRespond.errorMsg);
				if (phpRespond.errorMsg.indexOf("mrz..03") == 0 &&
					phpRespond.errorMsg.toLowerCase().indexOf("failed to recognize mrz") != -1) {
						if (callCount > CALL_COUNT)
							addSkipButton();
						showError(Lang.failedToRecognizeMRZ);
				} else {
					showError(Lang.somethingWentWrong);
					addSkipButton();
				}
				if (pic != null && pic.parent != null) {
					pic.parent.removeChild(pic);
					showCamera();
				}
				phpRespond.dispose();
				return;
			}
			NativeExtensionController.S_MRZ_RESULT.invoke(phpRespond.data.result);
			phpRespond.dispose();
			onBack();
		}
		
		private function showError(message:String):void 
		{
			ToastMessage.hide();
			if (errorMessage != null)
			{
				TweenMax.killTweensOf(errorMessage);
				view.removeChild(errorMessage);
				UI.destroy(errorMessage);
				errorMessage = null;
			}
			if (errorMessageText != null)
			{
				UI.destroy(errorMessageText);
				errorMessageText = null;
			}
			errorMessage = new Sprite();
			view.addChild(errorMessage);
			errorMessageText = new Bitmap();
			errorMessage.addChild(errorMessageText);
			errorMessageText.bitmapData = TextUtils.createTextFieldData(message, trueHeight - Config.FINGER_SIZE * 2, 10, true, 
																		TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, 
																		Config.FINGER_SIZE * .30, true, Color.WHITE);
			errorMessage.graphics.beginFill(Color.RED);
			errorMessage.graphics.drawRect(0, 0, errorMessageText.height + Config.FINGER_SIZE * .6, _height);
			errorMessage.graphics.endFill();
			errorMessageText.rotation = 90;
			errorMessageText.x = int(Config.FINGER_SIZE * .3 + errorMessageText.width);
			errorMessageText.y = int(_height * .5 - errorMessageText.height * .5);
			errorMessage.x = _width;
			
			TweenMax.to(errorMessage, 0.3, {x:_width - errorMessage.width, delay:0.4});
			TweenMax.to(errorMessage, 0.3, {x:_width, delay:3});
		}
		
		private function showPreloader():void {
			preloader ||= new Preloader();
			preloader.x = MobileGui.stage.stageWidth * .5;
			preloader.y = MobileGui.stage.stageHeight * .5;
			_view.addChild(preloader);
			preloader.show();
		}
		
		private function hidePreloader():void {
			if (preloader != null) {
				preloader.hide();
				if (preloader.parent) {
					preloader.parent.removeChild(preloader);
				}
			}
		}
		
		override protected function drawView():void {
			if (isDisposed == true)
				return;
			var heightWithoutOffset:int = MobileGui.stage.stageHeight - Config.APPLE_TOP_OFFSET - Config.APPLE_BOTTOM_OFFSET;
			if (trueWidth == MobileGui.stage.stageWidth && trueHeight == heightWithoutOffset)
				return;
			trueWidth = MobileGui.stage.stageWidth;
			trueHeight = heightWithoutOffset;
			_view.graphics.clear();
			_view.graphics.beginFill(Color.WHITE);
			_view.graphics.drawRect(0, 0, _width, _height);
			myCameraVideo.width = trueHeight;
			myCameraVideo.height = trueWidth;
			myCameraSprite.width = trueHeight;
			myCameraSprite.height = trueWidth;
			myCameraSprite.rotation = 90;
			myCameraSprite.x = trueWidth;
			myCameraSprite.y = Config.APPLE_TOP_OFFSET;
			btnCancel.rotation = 90;
			btnCancel.rotationAdded = 90;
			btnScan.rotation = 90;
			btnScan.rotationAdded = 90
			if (btnStart != null)
			{
				btnStart.rotation = 90;
				btnStart.rotationAdded = 90;
			}
			
			label.rotation = 90;
			label.x = _width - Config.DIALOG_MARGIN;
			label.y = int((trueHeight - label.height) * .5) + Config.APPLE_TOP_OFFSET;
			updateButtonsPosition();
			if (illustration != null)
			{
				illustration.x = int(_width * .5 + illustration.width * .5 - label.width);
				illustration.y = int((trueHeight - illustration.height) * .5 + Config.APPLE_TOP_OFFSET);
			}
		}
		
		private function updateButtonsPosition():void {
			if (btnStart != null)
			{
				btnStart.x = _width * .5 + btnStart.height * .5;
				btnStart.y = trueHeight - btnStart.width - Config.DIALOG_MARGIN;
			}
			if (btnScan != null)
			{
				btnScan.x = _width * .5 + btnScan.height * .5;
				btnScan.y = trueHeight - btnScan.width - Config.DIALOG_MARGIN;
			}
			if (btnCancel != null)
			{
				if (btnStart != null)
				{
					btnCancel.x = int(btnStart.x - Config.FINGER_SIZE * .6 - btnStart.width);
					btnCancel.y = int(btnStart.y + btnStart.height * .5 - btnCancel.height * .5);
				}
				else if (btnScan != null)
				{
					btnCancel.x = int(btnScan.x - Config.FINGER_SIZE * .6 - btnScan.width);
					btnCancel.y = int(btnScan.y + btnScan.height * .5 - btnCancel.height * .5);
				}
			}
			var totalBtnsWidth:int = btnCancel.width + btnScan.width + Config.MARGIN;
			if (btnSkip != null) {
				btnSkip.x = btnCancel.x;
				btnSkip.y = btnScan.y + btnScan.width + Config.MARGIN;
			}
		}
		
		override public function activateScreen():void {
			if (_isDisposed == true)
				return;
			super.activateScreen();
			btnCancel.activate();
			btnScan.activate();
			if (btnStart != null)
			{
				btnStart.activate();
			}
		}
		
		private function showCamera():Boolean {
			if (Camera.isSupported)
			{
				if (Camera.permissionStatus == PermissionStatus.GRANTED || Camera.permissionStatus == PermissionStatus.ONLY_WHEN_IN_USE)
				{
					addCamera();
					return true;
				}
				else if (Camera.permissionStatus == PermissionStatus.DENIED)
				{
					DialogManager.alert(Lang.textError, Lang.cameraPermission);
					return false;
				}
				else if (Camera.permissionStatus == PermissionStatus.UNKNOWN)
				{
					camera = Camera.getCamera();
					camera.addEventListener(PermissionEvent.PERMISSION_STATUS, function(e:PermissionEvent):void {
						if (isDisposed)
						{
							return;
						}
						if (e.status == PermissionStatus.GRANTED || e.status == PermissionStatus.ONLY_WHEN_IN_USE)
						{
							addCamera();
							showCameraState();
						}
						else if (Camera.permissionStatus == PermissionStatus.DENIED)
						{
							DialogManager.alert(Lang.textError, Lang.cameraPermission);
						}
					});
					try {
						camera.requestPermission();
					} catch(err:Error) {
						echo("CallManager", "getCameraPermission", err.message, true);
					}
				}
			}
			else
			{
				DialogManager.alert(Lang.textError, Lang.cameraNotSupported);
				return false;
			}
			return false;
		}
		
		public function addCamera():void {
			camera ||= Camera.getCamera();
			if (camera == null) {
				addSkipButton();
				return;
			}
			camera.setMode(trueHeight, trueWidth, 15);
			myCameraVideo.attachCamera(camera);
		}
		
		override public function deactivateScreen():void{
			if (_isDisposed == true)
				return;
			btnCancel.deactivate();
			btnScan.deactivate();
			closeVideo();
			if (btnStart != null)
			{
				btnStart.deactivate();
			}
		}
		
		override public function dispose():void {
			super.dispose();
			TweenMax.killDelayedCallsTo(addSkipButton);
			if (errorMessage != null)
			{
				TweenMax.killTweensOf(errorMessage);
				view.removeChild(errorMessage);
				UI.destroy(errorMessage);
				errorMessage = null;
			}
			if (errorMessageText != null)
			{
				UI.destroy(errorMessageText);
				errorMessageText = null;
			}
			disposeButtons();
			if (label != null)
				UI.destroy(label);
			label = null;
			if (preloader != null)
				preloader.dispose();
			preloader = null;
			camera = null;
			if (myCameraVideo != null)
			{
				closeVideo();
			}
			myCameraVideo = null;
			if (pic != null) {
				UI.disposeBMD(pic.bitmapData);
				pic.bitmapData = null;
			}
			pic = null;
		}
		
		private function closeVideo():void 
		{
			if (Camera.isSupported) {
				if (Camera.permissionStatus == PermissionStatus.GRANTED || Camera.permissionStatus == PermissionStatus.ONLY_WHEN_IN_USE) {
					myCameraVideo.attachCamera(null);
				}
			}
		}
		
		protected function disposeButtons():void {
			if (btnCancel != null)
				btnCancel.dispose();
			btnCancel = null;
			if (btnScan != null)
				btnScan.dispose();
			btnScan = null;
			if (btnStart != null)
				btnStart.dispose();
			btnStart = null;
			if (btnSkip != null)
				btnSkip.dispose();
			btnSkip = null;
			if (illustration != null)
			{
				UI.destroy(illustration);
				illustration = null;
			}
			if (errorMessage != null)
			{
				UI.destroy(errorMessage);
				errorMessage = null;
			}
			if (errorMessageText != null)
			{
				UI.destroy(errorMessageText);
				errorMessageText = null;
			}
		}
	}
}