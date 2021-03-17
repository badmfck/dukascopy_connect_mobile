package com.dukascopy.connect.screens.serviceScreen
{
	
	import assets.AppIntroBack;
	import assets.AttachPhotoIcon;
	import assets.DogIntro;
	import assets.GalleryIcon;
	import assets.PhotoShotIcon;
	import com.adobe.crypto.MD5;
	import com.adobe.utils.StringUtil;
	import com.dukascopy.connect.*;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.gui.button.*;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.renderers.ListLinkWithIcon;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.preloader.Preloader;
	import com.dukascopy.connect.gui.tools.ImagePreviewCrop;
	import com.dukascopy.connect.screens.base.*;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.photoGaleryManager.PhotoGaleryManager;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.Back;
	import com.greensock.easing.Bounce;
	import com.greensock.easing.Power1;
	import com.hurlant.util.Base64;
	import flash.display.*;
	import flash.geom.Point;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	
	public class FillUserInfoScreen extends BaseScreen
	{
		private var AVATAR_SIZE:Number;
		private var LOADED_AVATAR_BMD:com.dukascopy.connect.sys.imageManager.ImageBitmapData;
		private var background:Sprite;
		private var skipButton:BitmapButton;
		private var nextButton:BitmapButton;
		private var sidePadding:Number;
		private var animatedBack:flash.display.Sprite;
		private var backAnimator:Object;
		private var attachPhotoButton:com.dukascopy.connect.gui.menuVideo.BitmapButton;
		private var attachPhotoButtonContainer:flash.display.Sprite;
		private var illustration:flash.display.Bitmap;
		private var nameInput:com.dukascopy.connect.gui.input.Input;
		private var animatedBackMask:flash.display.Sprite;
		private var nameLine:flash.display.Bitmap;
		private var description:flash.display.Bitmap;
		private var avatarUploading:Boolean;
		private var preloaderAvatar:com.dukascopy.connect.gui.preloader.Preloader;
		private var imageCropper:com.dukascopy.connect.gui.tools.ImagePreviewCrop;
		private var changeAvatarRequest:String;
		private var lastLoadedImageName:String;
		private var firstTime:Boolean = true;
		
		public function FillUserInfoScreen() { }
		
		override public function initScreen(data:Object = null):void {
			if (MobileGui.stage != null){
				MobileGui.stage.quality = StageQuality.HIGH;
			}
			super.initScreen(data);
			
			AVATAR_SIZE = Config.FINGER_SIZE * 1.7;
			_params.doDisposeAfterClose = true;
			
			background.graphics.beginFill(0xFFFFFF);
			background.graphics.drawRect(0, 0, _width, _height);
			background.visible = false;
			
			sidePadding = Config.FINGER_SIZE;
			var buttonWidth:int = (_width - Config.FINGER_SIZE * 1.5) / 2;
			
			var textSettings:TextFieldSettings = new TextFieldSettings(Lang.later, 0x7A9AAD, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, 0x81CA2E, 0, Config.FINGER_SIZE * .8, NaN, buttonWidth);
			skipButton.setBitmapData(buttonBitmap);
			
			textSettings = new TextFieldSettings(Lang.textContinue, 0xFFFFFF, Config.FINGER_SIZE * .36, TextFormatAlign.CENTER);
			buttonBitmap = TextUtils.createbutton(textSettings, 0x81CA2E, 1, Config.FINGER_SIZE * .8, NaN, buttonWidth);
			nextButton.setBitmapData(buttonBitmap);
			
			skipButton.x = int(_width * .5 - skipButton.width * .5);
			nextButton.x = int(_width * .5 - nextButton.width * .5);
			
			skipButton.y = int(_height - Config.FINGER_SIZE * .4 - skipButton.height - Config.APPLE_BOTTOM_OFFSET);
			nextButton.y = int(skipButton.y - skipButton.height - Config.FINGER_SIZE * .3);
			
			var illustrationSource:DogIntro = new DogIntro();
			UI.scaleToFit(illustrationSource, _width - Config.FINGER_SIZE * 2, (_height - Config.APPLE_TOP_OFFSET) * .3 - Config.FINGER_SIZE*.5);
			illustration.bitmapData = UI.getSnapshot(illustrationSource);
			
			illustration.x = int(_width * .5 - illustration.width * .5);
			illustration.y = Config.APPLE_TOP_OFFSET + (_height - Config.APPLE_TOP_OFFSET) * .3 - illustration.height - Config.FINGER_SIZE * .3;
			
			illustration.mask = animatedBackMask;
			
			skipButton.hide();
			nextButton.hide();
			
			description.bitmapData = TextUtils.createTextFieldData(
																	Lang.enterYourNameToCreateAccount, _width - Config.DIALOG_MARGIN * 4, 10, 
																	true, TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, 
																	Config.FINGER_SIZE * .28, true, 0x7DA0BB, 0xFFFFFF); 
			
			description.alpha = 0;
			description.x = int(_width * .5 - description.width * .5);
			
			if (Auth.avatar != null && Auth.avatar != "")
			{
				var path:String = Auth.getLargeAvatar(Config.FINGER_SIZE * 0.85);
				var imageCache:ImageBitmapData = ImageManager.getImageFromCache(path);
				if (imageCache)
					onAvatarLoaded(path, imageCache);
				else
					ImageManager.loadImage(Auth.getLargeAvatar(Config.FINGER_SIZE * 0.85), onAvatarLoaded);
			}
			
			if (data != null && "defaultName" in data && data.defaultName != null && data.defaultName != "")
			{
				nameInput.value = data.defaultName;
			}
		}
		
		private function animateBack():void 
		{
			background.visible = true;
			background.height = 1;
			background.y = _height - background.height;
			TweenMax.to(background, 0.4, {height:_height, onUpdate:resizeBack, ease:Power1.easeInOut});
			
			backAnimator = new Object();
			backAnimator.currentDrawPosition = 0;
			backAnimator.endPosition = int(_height * .3 + Config.FINGER_SIZE * 2);
			TweenMax.to(backAnimator, 0.8, { delay:0.4, currentDrawPosition:backAnimator.endPosition, ease:Back.easeInOut, onUpdate:drawBack, onComplete:headerDrawn});
			TweenMax.delayedCall(0.7, showPhotoButton);
		}
		
		private function animateElements():void 
		{
			
		}
		
		private function resizeBack():void 
		{
			background.y = _height - background.height;
		}
		
		private function showPhotoButton():void 
		{
			attachPhotoButtonContainer.x = int(_width * .5);
			var newY:int = int(_height * .3 + Config.FINGER_SIZE * .47);
			
			attachPhotoButton.x = int(-attachPhotoButton.width * .5);
			attachPhotoButton.y = int(-attachPhotoButton.height * .5);
			
			attachPhotoButton.show();
			
			attachPhotoButtonContainer.alpha = 0;
			attachPhotoButtonContainer.scaleX = 1;
			attachPhotoButtonContainer.scaleY = 1;
			attachPhotoButtonContainer.y = _height*.3;
			
			TweenMax.to(attachPhotoButtonContainer, 0.5, {y:newY, scaleX:1, scaleY:1, ease:Back.easeOut.config(1), alpha:1});
		}
		
		private function drawBack():void 
		{
			var drawPosition:int = backAnimator.currentDrawPosition;
			var overhead:int = 0;
			if (drawPosition > _height * .3)
			{
				drawPosition = _height * .3;
				overhead = backAnimator.currentDrawPosition - drawPosition;
			}
			
			animatedBack.graphics.clear();
			animatedBack.graphics.beginFill(0xCD3F43);
			animatedBack.graphics.drawRect(0, 0, _width, drawPosition);
			animatedBack.graphics.endFill();
			
			animatedBackMask.graphics.clear();
			animatedBackMask.graphics.beginFill(0xCD3F43);
			animatedBackMask.graphics.drawRect(0, 0, _width, drawPosition);
			animatedBackMask.graphics.endFill();
			
			if (overhead > 0)
			{
				animatedBack.graphics.moveTo(0, drawPosition);
				animatedBack.graphics.beginFill(0xCD3F43);
				animatedBack.graphics.cubicCurveTo(
													_width * .33, drawPosition + overhead*.3, 
													_width * .66, drawPosition + overhead*.3,
													_width, drawPosition);
				animatedBack.graphics.endFill();
			}
		}
		
		private function headerDrawn():void 
		{
			nameInput.width = _width - Config.DIALOG_MARGIN * 4;
			nameInput.view.x = Config.DIALOG_MARGIN * 2;
			nameInput.view.y = attachPhotoButtonContainer.y + Config.FINGER_SIZE * 1;
			
			nameLine.width = _width - Config.DIALOG_MARGIN * 4;
			nameLine.x = Config.DIALOG_MARGIN * 2;
			nameLine.y = int(nameInput.view.y + nameInput.height);
			
			nameInput.view.alpha = 0;
			nameInput.view.visible = true;
			TweenMax.to(nameInput.view, 0.6, {alpha:1});
			TweenMax.to(nameLine, 0.6, {alpha:1});
			TweenMax.to(description, 0.6, {alpha:1});
			
			skipButton.show(0.4);
			nextButton.show(0.4);
			
			description.y = int(nameLine.y + Config.FINGER_SIZE * .4);
		}
		
		override protected function createView():void {
			super.createView();
			
			background = new Sprite();
			view.addChild(background);
			
			animatedBack = new Sprite();
			view.addChild(animatedBack);
			
			animatedBackMask = new Sprite();
			view.addChild(animatedBackMask);
			
			skipButton = new BitmapButton();
			skipButton.setStandartButtonParams();
			skipButton.setDownScale(1);
			skipButton.setDownColor(0);
			skipButton.tapCallback = skipClick;
			skipButton.disposeBitmapOnDestroy = true;
			view.addChild(skipButton);
			
			nextButton = new BitmapButton();
			nextButton.setStandartButtonParams();
			nextButton.setDownScale(1);
			nextButton.setDownColor(0);
			nextButton.tapCallback = nextClick;
			nextButton.disposeBitmapOnDestroy = true;
			view.addChild(nextButton);
			
			attachPhotoButton = new BitmapButton();
			attachPhotoButton.setStandartButtonParams();
			attachPhotoButton.setOverflow(Config.MARGIN, Config.MARGIN, Config.MARGIN, Config.MARGIN);
			attachPhotoButton.setDownScale(1.1);
			attachPhotoButton.setDownColor(0);
			attachPhotoButton.tapCallback = attachPhoto;
			attachPhotoButton.hide();
			
			attachPhotoButtonContainer = new Sprite();
			view.addChild(attachPhotoButtonContainer);
			attachPhotoButtonContainer.addChild(attachPhotoButton);
			
			var icon:AttachPhotoIcon = new AttachPhotoIcon();
			UI.scaleToFit(icon, Config.FINGER_SIZE * 1.7, Config.FINGER_SIZE * 1.7);
			attachPhotoButton.setBitmapData(UI.getSnapshot(icon), true);
			UI.destroy(icon);
			
			illustration = new Bitmap();
			view.addChild(illustration);
			
			
			nameInput = new Input();
			nameInput.backgroundColor = 0xFFFFFF;
			nameInput.setMode(Input.MODE_INPUT);
			
			var textFormat:TextFormat = new TextFormat();
			textFormat.size = Config.FINGER_SIZE * .4;
			textFormat.color = 0x8595A7;
			
			nameInput.updateTextFormat(textFormat);
			nameInput.setLabelText(Lang.yourName);
			nameInput.S_FOCUS_OUT.add(onPoneInputFocusOut);
			nameInput.setBorderVisibility(false);
			nameInput.setRoundBG(false);
			nameInput.S_CHANGED.add(onPhoneChange);
		//	phoneField.getTextField().textColor = AppTheme.GREY_DARK;
			nameInput.setRoundRectangleRadius(0);
			nameInput.inUse = true;
			view.addChild(nameInput.view);
			
			nameInput.view.visible = false;
			
			var hLineBitmapData:ImageBitmapData = UI.getHorizontalLine(3, 0x8195B8);
			nameLine = new Bitmap(hLineBitmapData);
			view.addChild(nameLine);
			nameLine.alpha = 0;
			
			description = new Bitmap();
			view.addChild(description);
		}
		
		private function onPhoneChange():void 
		{
			
		}
		
		private function attachPhoto():void 
		{
			if (avatarUploading)
				return;
			var menuItems:Array = [];
			menuItems.push( { fullLink:Lang.selectFromGallery, id:0, icon:GalleryIcon } );
			menuItems.push( { fullLink:Lang.makePhoto, id:1, icon:PhotoShotIcon } );
			DialogManager.showSelectItemDialog( { callBack:onAvatarChangeMethod, itemClass:ListLinkWithIcon, listData:menuItems, title:Lang.changeAvatar } );
		}
		
		private function onAvatarChangeMethod(val:int):void {
			if (val == -1)
				return;
			if (val == 0) {
				PhotoGaleryManager.S_GALLERY_IMAGE_LOADED.add(onAvatarSelected);
				lockScreen();
				PhotoGaleryManager.takeImage(false);
				return;
			}
			if (val == 1) {
				PhotoGaleryManager.S_GALLERY_IMAGE_LOADED.add(onAvatarSelected);
				lockScreen();
				PhotoGaleryManager.takeCamera(false);
				return;
			}
		}
		
		private function onAvatarSelected(success:Boolean, image:ImageBitmapData, message:String):void {
			PhotoGaleryManager.S_GALLERY_IMAGE_LOADED.remove(onAvatarSelected);
			if (success && image && !isNaN(image.width)) {
				showImagePreview(image);
			} else { //!TODO: добавить отправку сообщения об ошибке?;
				unlockScreen();
				avatarUploading = false;
				if (message)
					DialogManager.alert(Lang.textWarning, message);
			}
		}
		
		private function lockScreen():void {
			displayPreloader();
			deactivateScreen();
		}
		
		private function unlockScreen():void {
			hidePreloader();
			activateScreen();
		}
		
		private function displayPreloader():void {
			if (preloaderAvatar == null) {
				preloaderAvatar = new Preloader();
				preloaderAvatar.x = _width * .5;
				preloaderAvatar.y = attachPhotoButtonContainer.y + Config.FINGER_SIZE * 1.7;
				view.addChild(preloaderAvatar);
			}
			preloaderAvatar.y = attachPhotoButtonContainer.y + Config.FINGER_SIZE * 1.7;
			preloaderAvatar.show();
		}
		
		private function hidePreloader():void {
			if (preloaderAvatar != null)
			{
				preloaderAvatar.hide();
			}
		}
		
		private function showImagePreview(image:ImageBitmapData):void {
			var currentImage:ImageBitmapData = new ImageBitmapData("SettingsScreen.previewImg", image.width, image.height);
			currentImage.copyPixels(image, image.rect, new Point(0, 0));
			image.dispose();
			image = null;
			if (currentImage.width > Config.BITMAP_SIZE_MAX || currentImage.height > Config.BITMAP_SIZE_MAX)
				currentImage = ImageManager.resize(currentImage, Config.BITMAP_SIZE_MAX, Config.BITMAP_SIZE_MAX, ImageManager.SCALE_INNER_PROP);
			deactivateScreen();
			if (imageCropper == null)
				imageCropper = new ImagePreviewCrop();
			imageCropper.display(currentImage, onCropDone, onCropCancel);
		}
		
		private function onCropDone(imageData:ImageBitmapData):void {
			activateScreen();
			imageCropper.clearCurrent();
			updateAvatarWithBitmapData(imageData);
		}
		
		private function onCropCancel():void {
			imageCropper.clearCurrent();
			unlockScreen();
		}
		
		private function updateAvatarWithBitmapData(image:ImageBitmapData):void {
			if (image.isDisposed)
				return;
			
			avatarUploading = true;
			
			if (image.width > Config.USER_AVATAR_SIZE_MAX || image.height > Config.USER_AVATAR_SIZE_MAX) {
				image = ImageManager.resize(image, Config.USER_AVATAR_SIZE_MAX, Config.USER_AVATAR_SIZE_MAX, ImageManager.SCALE_INNER_PROP, false, false);
			}
			
			var imageToSave:ImageBitmapData = new ImageBitmapData("SettingsScreen.avatarSaveServerImageData", image.width, image.height);
			imageToSave.copyPixels(image, image.rect, new Point(0, 0));
			
			uploadAvatarImage(imageToSave);
			imageToSave = null;
			onAvatarLoaded("custom", ImageManager.resize(image, AVATAR_SIZE, AVATAR_SIZE, ImageManager.SCALE_NONE, false, false));
			image.dispose();
			image = null;
		}
		
		private function uploadAvatarImage(image:ImageBitmapData):void {
			changeAvatarRequest = createRequestId();
			encodeAvatar(image);
		}
		
		private function createRequestId():String {
			return MD5.hash(getTimer().toString());
		}
		
		private function encodeAvatar(image:ImageBitmapData):void {
			var pngImage:ByteArray = image.encode(image.rect, new JPEGEncoderOptions(87));
			image.dispose();
			image = null;
			var imageString:String = "data:image/jpeg;base64," + Base64.encodeByteArray(pngImage);
			avatarUploading = true;
			Auth.S_PROFILE_CHANGE.add(onAvatarImageChanged);
			Auth.changeAvatar(imageString, changeAvatarRequest);
			imageString = null;
			pngImage = null;
		}
		
		private function onAvatarImageChanged(result:Object):void {
			if (result.requestId != changeAvatarRequest)
				return;
			unlockScreen();
			changeAvatarRequest = null;
			Auth.S_PROFILE_CHANGE.remove(onAvatarImageChanged);
		//	ChatManager.S_LATEST.invoke();
			avatarUploading = false;
		}
		
		private function onAvatarLoaded(url:String, bmd:ImageBitmapData):void {
			if (isDisposed)
				return;
			if (!bmd)
				return;
			if (LOADED_AVATAR_BMD != null)
			{
				LOADED_AVATAR_BMD.dispose();
				LOADED_AVATAR_BMD = null;
			}
			LOADED_AVATAR_BMD ||= new ImageBitmapData("SettingsScreen.LOADED_AVATAR_BMD", AVATAR_SIZE, AVATAR_SIZE);
			lastLoadedImageName = url;
			ImageManager.drawCircleImageToBitmap(LOADED_AVATAR_BMD, bmd, 0, 0, AVATAR_SIZE * .5);
			
			bmd = null;
			updateAvatarBMD();
		}

		
		private function updateAvatarBMD():void {
			if (LOADED_AVATAR_BMD != null) {
				attachPhotoButton.setBitmapData(LOADED_AVATAR_BMD, true);
			}
		}
		
		private function nextClick():void 
		{
			if (nameInput.value != null && nameInput.value != "" && nameInput.value != Lang.yourName)
			{
				var currentName:String = "";
				var currentSurname:String = "";
				
				var res:String = StringUtil.trim(nameInput.value);
				var elements:Array = res.split(" ");
				if (elements.length > 1)
				{
					currentSurname = elements[elements.length - 1];
					elements.pop();
					currentName = elements.join(" ");
				}
				else{
					currentName = elements[0];
				}
				
				var valid:Boolean = true;
				
				var badPatterns:Array = [
											"duka",
											"dukа",
											"duкa",
											"duка",
											"dиka",
											"dиkа",
											"dикa",
											"dика",
											"bank",
											"bаnk",
											"banк",
											"bаnк",
											"support",
											"sapport",
											"suppоrt",
											"sappоrt",
											"supрort",
											"sapрort",
											"supроrt",
											"sapроrt",
											"suрport",
											"saрport",
											"suрpоrt",
											"saрpоrt",
											"suррort",
											"saррort",
											"suрроrt",
											"saрроrt",
											"банк",
											"бaнк",
											"банк",
											"бaнk",
											"чат",
											"чaт",
											"поддержка",
											"пoддержка",
											"поддержkа",
											"пoддержkа",
											"поддержкa",
											"пoддержкa",
											"поддержka",
											"пoддержka",
											"поддeржка",
											"пoддeржка",
											"поддeржkа",
											"пoддeржkа",
											"поддeржкa",
											"пoддeржкa",
											"поддeржka",
											"пoддeржka"
										];
				var i:int;
				if (currentName != null)
				{
					for (i = 0; i < badPatterns.length; i++) 
					{
						if (currentName.indexOf(badPatterns[i]) != -1)
						{
							valid = false;
							break;
						}
					}
				}
				if (currentSurname != null)
				{
					for (i = 0; i < badPatterns.length; i++) 
					{
						if (currentSurname.indexOf(badPatterns[i]) != -1)
						{
							valid = false;
							break;
						}
					}
				}
				
				if (valid == true)
				{
					Auth.changeUsername(currentName, currentSurname, "1");
				}
			}
			
			ServiceScreenManager.closeView();
		}
		
		private function skipClick():void 
		{
			ServiceScreenManager.closeView();
		}
		
		override protected function drawView():void {
			super.drawView();
			
			nameInput.width = _width - Config.DIALOG_MARGIN * 4;
			nameInput.view.x = Config.DIALOG_MARGIN * 2;
			nameInput.view.y = attachPhotoButtonContainer.y + Config.FINGER_SIZE * 1;
			
			nameLine.width = _width - Config.DIALOG_MARGIN * 4;
			nameLine.x = Config.DIALOG_MARGIN * 2;
			nameLine.y = int(nameInput.view.y + nameInput.height);
			
			description.y = int(nameLine.y + Config.FINGER_SIZE * .4);
			
			view.graphics.clear();
		}
		
		override public function clearView():void {
			super.clearView();
		}
		
		override public function dispose():void {
			TweenMax.killTweensOf(background);
			TweenMax.killTweensOf(attachPhotoButtonContainer);
			TweenMax.killTweensOf(backAnimator);
			TweenMax.killTweensOf(nameInput);
			TweenMax.killTweensOf(nameLine);
			TweenMax.killTweensOf(description);
			TweenMax.killDelayedCallsTo(showPhotoButton);
			
			if (MobileGui.stage != null){
				MobileGui.stage.quality = StageQuality.LOW;
			}
			super.dispose();
			
			if (skipButton != null)
			{
				skipButton.dispose();
				skipButton = null;
			}
			if (nextButton != null)
			{
				nextButton.dispose();
				nextButton = null;
			}
		}
		
		override public function activateScreen():void
		{
			super.activateScreen();
			
			if (_isDisposed)
			{
				return;
			}
			
			skipButton.activate();
			nextButton.activate();
			attachPhotoButton.activate();
			
			nameInput.S_CHANGED.add(onPhoneChange);
			nameInput.S_FOCUS_OUT.add(onPoneInputFocusOut);
			nameInput.activate();
			
			if (firstTime)
			{
				firstTime = false;
				animateBack();
			}
		}
		
		override public function deactivateScreen():void
		{
			super.deactivateScreen();
			
			if (_isDisposed)
			{
				return;
			}
			
			nameInput.S_CHANGED.remove(onPhoneChange);
			nameInput.S_FOCUS_OUT.remove(onPoneInputFocusOut);
			nameInput.deactivate();
			
			skipButton.deactivate();
			nextButton.deactivate();
			attachPhotoButton.deactivate();
		}
		
		private function onPoneInputFocusOut():void {
			
			//!TODO;
			
			/*var currentValue:String = StringUtil.trim(phoneField.value);
			if (currentValue != "" && currentValue != phoneField.getDefValue()) {
				currentPhone = currentValue;
			} else {
				phoneField.value = currentPhone;
			}*/
		}
	}
}