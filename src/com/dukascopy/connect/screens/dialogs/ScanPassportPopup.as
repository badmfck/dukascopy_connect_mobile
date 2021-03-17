package com.dukascopy.connect.screens.dialogs
{
	import assets.IconOk2;
	import assets.PassportIllustration;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.ScanPassportResult;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.nativeExtensionController.NativeExtensionController;
	import com.dukascopy.connect.sys.photoGaleryManager.PhotoGaleryManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	
	public class ScanPassportPopup extends BaseScreen
	{
		static public const STATE_PHOTO:String = "statePhoto";
		static public const STATE_INIT:String = "stateInit";
		
		protected var container:Sprite;
		private var bg:Shape;
		private var backButton:BitmapButton;
		private var description:flash.display.Bitmap;
		private var componentsWidth:Number;
		private var nextButton:BitmapButton;
		private var callbackFunction:Function;
		private var exampleText:flash.display.Bitmap;
		private var illustration:flash.display.Bitmap;
		private var padding:int;
		private var state:String;
		private var resultBitmap:ImageBitmapData;
		private var successClip:Bitmap;
		private var makePhotoButton:com.dukascopy.connect.gui.menuVideo.BitmapButton;
		private var wasCallback:Boolean;
		
		public function ScanPassportPopup()
		{
			
		}
		
		override protected function createView():void
		{
			super.createView();
			
			container = new Sprite();
			
			bg = new Shape();
			container.addChild(bg);
			
			backButton = new BitmapButton();
			backButton.setStandartButtonParams();
			backButton.setDownScale(1);
			backButton.setDownColor(0);
			backButton.tapCallback = backClick;
			backButton.disposeBitmapOnDestroy = true;
			container.addChild(backButton);
			
			nextButton = new BitmapButton();
			nextButton.setStandartButtonParams();
			nextButton.setDownScale(1);
			nextButton.setDownColor(0);
			nextButton.tapCallback = nextClick;
			nextButton.disposeBitmapOnDestroy = true;
			container.addChild(nextButton);
			
			makePhotoButton = new BitmapButton();
			makePhotoButton.setStandartButtonParams();
			makePhotoButton.setDownScale(1);
			makePhotoButton.setDownColor(0);
			makePhotoButton.tapCallback = photoClick;
			makePhotoButton.disposeBitmapOnDestroy = true;
			container.addChild(makePhotoButton);
			
			description = new Bitmap();
			container.addChild(description);
			
			exampleText = new Bitmap();
			container.addChild(exampleText);
			
			illustration = new Bitmap();
			container.addChild(illustration);
			
			_view.addChild(container);
		}
		
		private function photoClick():void 
		{
			makePhoto();
		}
		
		private function nextClick():void
		{
			if (state == STATE_PHOTO)
			{
				if (callbackFunction != null)
				{
					wasCallback = true;
					callbackFunction(new ScanPassportResult(true, resultBitmap));
				}
				DialogManager.closeDialog();
			}
			else if (state == STATE_INIT)
			{
				makePhoto();
			}
		}
		
		private function makePhoto():void 
		{
			PhotoGaleryManager.S_GALLERY_IMAGE_LOADED_PASSPORT.add(onAvatarSelected);
			lockScreen();
			
			if (Config.PLATFORM_WINDOWS)
			{
				PhotoGaleryManager.takeImage(false, false, PhotoGaleryManager.PASSPORT);
			}
			else
			{
				if (Config.PLATFORM_ANDROID)
				{
					NativeExtensionController.S_PERMISSION.add(onPermissionsResult);
					NativeExtensionController.getCameraPermissions();
					
				}
				else
				{
					PhotoGaleryManager.takeCamera(false, false, PhotoGaleryManager.PASSPORT);
				}
			}
		}
		
		private function onPermissionsResult(type:String, success:Boolean):void 
		{
			if (type == NativeExtensionController.CAMERA_PERMISSIONS)
			{
				NativeExtensionController.S_PERMISSION.remove(onPermissionsResult);
				if (success == true)
				{
					PhotoGaleryManager.takeCamera(false, false, PhotoGaleryManager.PASSPORT);
				}
				else
				{
					ToastMessage.display(Lang.photoPermission);
				}
			}
		}
		
		private function lockScreen():void 
		{
			
		}
		
		private function onAvatarSelected(success:Boolean, image:ImageBitmapData, message:String):void {
			PhotoGaleryManager.S_GALLERY_IMAGE_LOADED.remove(onAvatarSelected);
			if (success && image && !isNaN(image.width)) {
				showImagePreview(image);
			} else {
				unlockScreen();
				if (message != null)
					DialogManager.alert(Lang.textWarning, message);
			}
		}
		
		private function unlockScreen():void 
		{
			
		}
		
		private function showImagePreview(image:ImageBitmapData):void 
		{
			if (state != STATE_PHOTO)
			{
				drawSuccessClip();
				drawDescription(Lang.photoUploadSuccess, componentsWidth - successClip.width - Config.FINGER_SIZE);
				drawNextButton(Lang.readyToCall);
				drawPhotoButton();
			}
			
			state = STATE_PHOTO;
			
			if (resultBitmap != null)
			{
				resultBitmap.dispose();
			}
			
			resultBitmap = new ImageBitmapData("ScanPassport", image.width, image.height);
			resultBitmap.copyPixels(image, image.rect, new Point());
			
			drawPhoto();
			
			var position:int = Config.FINGER_SIZE * .3;
			
			successClip.x = int(Config.FINGER_SIZE * .5);
			
			description.x = int(successClip.x + successClip.width + Config.FINGER_SIZE * .5);
			description.y = position;
			position += description.height + Config.FINGER_SIZE * .6;
			
			successClip.y = int(description.y + description.height * .5 - successClip.height * .5);
			
			illustration.x = int(componentsWidth * .5 - illustration.width * .5 + padding);
			exampleText.visible = false;
			
			illustration.y = position;
			position += illustration.height + Config.FINGER_SIZE * .25;
			
			makePhotoButton.x = int(padding + componentsWidth * .5 - makePhotoButton.width * .5);
			makePhotoButton.y = position;
			position += makePhotoButton.height + Config.FINGER_SIZE * .65;
			
			backButton.y = nextButton.y = position;
			position += nextButton.height + Config.FINGER_SIZE * .4;
			
			backButton.x = Config.DIALOG_MARGIN;
			nextButton.x = backButton.x + backButton.width + Config.MARGIN;
			
			var bdDrawPosition:int = description.y + description.height + Config.FINGER_SIZE * .3;
			
			bg.graphics.clear();
			
			bg.graphics.beginFill(0xD9E5F0);
			bg.graphics.drawRect(0, 0, _width, bdDrawPosition);
			bg.graphics.endFill();
			
			var darkHeight:int = illustration.height + Config.FINGER_SIZE * .6 + makePhotoButton.height + Config.FINGER_SIZE * .2;
			
			bg.graphics.beginFill(0x414141);
			bg.graphics.drawRect(0, bdDrawPosition, _width, darkHeight);
			bg.graphics.endFill();
			
			bdDrawPosition += darkHeight;
			
			bg.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			bg.graphics.drawRect(0, bdDrawPosition, _width, position - bdDrawPosition);
			bg.graphics.endFill();
			
			container.y = int(_height - position - Config.DIALOG_MARGIN);
		}
		
		private function drawPhotoButton():void 
		{
			var textSettings:TextFieldSettings = new TextFieldSettings(Lang.reshootPhoto, 0x343434, Config.FINGER_SIZE * .26, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, 0x8D8D8D, 1, Config.FINGER_SIZE * .8, NaN);
			makePhotoButton.setBitmapData(buttonBitmap, true);
		}
		
		private function drawSuccessClip():void 
		{
			successClip = new Bitmap();
			container.addChild(successClip);
			
			var icon:Sprite = new IconOk2();
			UI.scaleToFit(icon, Config.FINGER_SIZE * .5, Config.FINGER_SIZE * .5);
			
			successClip.bitmapData = UI.getSnapshot(icon, StageQuality.HIGH, "ScanPassportPopup.successClip");
			
			UI.destroy(icon);
		}
		
		private function drawPhoto():void 
		{
			if (illustration.bitmapData != null)
			{
				illustration.bitmapData.dispose();
				illustration.bitmapData = null;
			}
			
			var scaleFactor:Number = Math.min(
											(componentsWidth - Config.DIALOG_MARGIN * 2) / resultBitmap.width,
											Config.FINGER_SIZE * 3.5 / resultBitmap.height);
			
			var preview:ImageBitmapData = TextUtils.scaleBitmapData(resultBitmap, scaleFactor);
			
			if (preview != null)
			{
				illustration.bitmapData = preview;
			}
		}
		
		private function backClick():void
		{
			rejectPopup();
		}
		
		private function rejectPopup():void 
		{
			if (resultBitmap != null)
			{
				UI.disposeBMD(resultBitmap);
				resultBitmap = null;
			}
			
			if (callbackFunction != null)
			{
				wasCallback = true;
				callbackFunction(new ScanPassportResult(false));
			}
			DialogManager.closeDialog();
		}
		
		override public function onBack(e:Event = null):void
		{
			rejectPopup();
		}
		
		override public function clearView():void
		{
			super.clearView();
		}
		
		override public function initScreen(data:Object = null):void
		{
			super.initScreen(data);
			
			state = STATE_INIT;
			
			if (data != null && "callback" in data && data.callback != null && data.callback is Function)
			{
				callbackFunction = data.callback as Function;
			}
			
			padding = Config.DIALOG_MARGIN;
			
			componentsWidth = _width - padding * 2;
			
			drawDescription(Lang.scanDocumentDescription);
			drawExampletext();
			drawNextButton(Lang.makePhoto);
			drawBackButton();
			drawIllustration();
			
			var position:int = Config.FINGER_SIZE * .3;
			
			description.x = padding;
			description.y = position;
			position += description.height + Config.FINGER_SIZE * .6;
			
			illustration.x = int(componentsWidth * .5 - illustration.width * .5 + padding);
			exampleText.y = position;
			exampleText.x = illustration.x;
			position += exampleText.height + Config.FINGER_SIZE * .1;
			
			illustration.y = position;
			position += illustration.height + Config.FINGER_SIZE * .5;
			
			backButton.y = nextButton.y = position;
			position += nextButton.height + Config.FINGER_SIZE * .4;
			
			backButton.x = Config.DIALOG_MARGIN;
			nextButton.x = backButton.x + backButton.width + Config.MARGIN;
			
			var bdDrawPosition:int = description.y + description.height + Config.FINGER_SIZE * .3;
			
			bg.graphics.beginFill(0xD9E5F0);
			bg.graphics.drawRect(0, 0, _width, bdDrawPosition);
			bg.graphics.endFill();
			
			bg.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			bg.graphics.drawRect(0, bdDrawPosition, _width, position - bdDrawPosition);
			bg.graphics.endFill();
			
			container.y = int(_height - position - Config.DIALOG_MARGIN);
		}
		
		private function drawIllustration():void 
		{
			if (illustration.bitmapData != null)
			{
				illustration.bitmapData.dispose();
				illustration.bitmapData = null;
			}
			
			var source:Sprite = new PassportIllustration();
			UI.scaleToFit(source, componentsWidth - Config.DIALOG_MARGIN * 2, Config.FINGER_SIZE * 5);
			illustration.bitmapData = UI.getSnapshot(source, StageQuality.HIGH, "ScanPassportPopup.illustration");
			UI.destroy(source);
		}
		
		private function drawNextButton(text:String):void
		{
			var textSettings:TextFieldSettings = new TextFieldSettings(text, 0xFFFFFF, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, Color.GREEN, 1, Config.FINGER_SIZE * .8, NaN, (componentsWidth - Config.MARGIN) * .5);
			nextButton.setBitmapData(buttonBitmap, true);
		}
		
		private function drawExampletext():void
		{
			if (exampleText.bitmapData != null)
			{
				exampleText.bitmapData.dispose();
				exampleText.bitmapData = null;
			}
			
			exampleText.bitmapData = TextUtils.createTextFieldData(
															Lang.example, componentsWidth, 10, false, 
															TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, 
															Config.FINGER_SIZE * .26, false, 
															0x657280, 0xFFFFFFF, true);
		}
		
		private function drawDescription(text:String, maxWidth:Number = NaN):void
		{
			var maxTextWidth:Number = maxWidth;
			if (isNaN(maxTextWidth))
			{
				maxTextWidth = componentsWidth;
			}
			
			if (description.bitmapData != null)
			{
				description.bitmapData.dispose();
				description.bitmapData = null;
			}
			
			description.bitmapData = TextUtils.createTextFieldData(
															text, maxTextWidth, 10, true, 
															TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
															Config.FINGER_SIZE * .32, true, 0x47515B, 0xFFFFFF, true);
		}
		
		private function drawBackButton():void
		{
			var textSettings:TextFieldSettings = new TextFieldSettings(Lang.textBack, 0x657280, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, 0xFFFFFF, 1, Config.FINGER_SIZE * .8, NaN, (componentsWidth - Config.MARGIN) * .5);
			backButton.setBitmapData(buttonBitmap, true);
		}
		
		override protected function drawView():void
		{
			if (_isDisposed == true)
				return;
		}
		
		override public function activateScreen():void
		{
			if (_isDisposed == true)
				return;
			
			super.activateScreen();
			
			backButton.activate();
			nextButton.activate();
			makePhotoButton.activate();
		}
		
		override public function deactivateScreen():void
		{
			if (_isDisposed == true)
				return;
			
			super.deactivateScreen();
			
			backButton.deactivate();
			nextButton.deactivate();
			makePhotoButton.deactivate();
		}
		
		override public function dispose():void
		{
			if (_isDisposed == true)
				return;
			super.dispose();
			
			if (wasCallback == false)
			{
				callbackFunction(new ScanPassportResult(false));
			}
			
			if (backButton != null)
			{
				backButton.dispose();
				backButton = null;
			}
			if (nextButton != null)
			{
				nextButton.dispose();
				nextButton = null;
			}
			if (makePhotoButton != null)
			{
				makePhotoButton.dispose();
				makePhotoButton = null;
			}
			if (container != null)
			{
				UI.destroy(container);
				container = null;
			}
			if (bg != null)
			{
				UI.destroy(bg);
				bg = null;
			}
			if (description != null)
			{
				UI.destroy(description);
				description = null;
			}
			if (exampleText != null)
			{
				UI.destroy(exampleText);
				exampleText = null;
			}
			if (illustration != null)
			{
				UI.destroy(illustration);
				illustration = null;
			}
			if (successClip != null)
			{
				UI.destroy(successClip);
				successClip = null;
			}
			
			callbackFunction = null;
			
			PhotoGaleryManager.S_GALLERY_IMAGE_LOADED_PASSPORT.remove(onAvatarSelected);
			NativeExtensionController.S_PERMISSION.remove(onPermissionsResult);
		}
	}
}