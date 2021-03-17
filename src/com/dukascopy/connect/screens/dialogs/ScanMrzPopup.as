package com.dukascopy.connect.screens.dialogs {
	import assets.PassportIllustration;
	import assets.PassportMrzZoneAnimation;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.mrz.MrzBridge;
	import com.dukascopy.connect.sys.mrz.MrzError;
	import com.dukascopy.connect.sys.mrz.MrzResult;
	import com.dukascopy.connect.sys.nativeExtensionController.NativeExtensionController;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	
	public class ScanMrzPopup extends BaseScreen {
		
		protected var container:Sprite;
		private var bg:Shape;
		private var backButton:BitmapButton;
		private var title:Bitmap;
		private var description:Bitmap;
		private var componentsWidth:Number;
		private var nextButton:BitmapButton;
		private var callbackFunction:Function;
		private var illustration:Bitmap;
		private var padding:int;
		private var animator:PassportMrzZoneAnimation;
		private var animatorStartScale:Number;
		
		public function ScanMrzPopup() {
			
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
			
			title = new Bitmap();
			container.addChild(title);
			
			description = new Bitmap();
			container.addChild(description);
			
			illustration = new Bitmap();
			container.addChild(illustration);
			
			animator = new PassportMrzZoneAnimation();
			container.addChild(animator);
			animator.alpha = 0;
			
			_view.addChild(container);
		}
		
		private function nextClick():void {
			var promoCode:String = (data != null && data.promoCode != null) ? data.promoCode : null;
			if (Config.PLATFORM_ANDROID == false || (Config.PLATFORM_ANDROID == true && NativeExtensionController.getVersion() <= 22)) {
				MrzBridge.startRecognition(callbackFunction, promoCode);
				DialogManager.closeDialog();
				return;
			}
			MrzBridge.startRecognition(onMrzResult, promoCode);
		}
		
		private function onMrzResult(result:MrzResult):void {
			if (result.error == true && result.errorText == MrzError.ENGINE_INIT_FAILED)
			{
				ToastMessage.display(result.getErrorLocalized());
				PHP.call_statVI("tryRTOErr", "mrz engine fail, " + ((result.errorText != null)?result.errorText:""));
				// fallback to server recognition;
				var promoCode:String = (data != null && data.promoCode != null) ? data.promoCode : null;
				MrzBridge.startRecognition(callbackFunction, promoCode, true);
				DialogManager.closeDialog();
				return;
			}
			else
			{
				if (callbackFunction != null)
					callbackFunction(result);
				DialogManager.closeDialog();
			}
		}
		
		private function makePhoto():void {
			
		}
		
		private function backClick():void
		{
			PHP.call_statVI("MRZ_CANCEL");
			rejectPopup();
		}
		
		private function rejectPopup():void 
		{
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
			
			if (data != null && "callback" in data && data.callback != null && data.callback is Function)
			{
				callbackFunction = data.callback as Function;
			}
			
			padding = Config.DIALOG_MARGIN;
			
			componentsWidth = _width - padding * 2;
			
			drawTitle(Lang.accountOpening);
			drawDescription(Lang.scanMrzDescription);
			drawNextButton(Lang.begin);
			drawBackButton();
			drawIllustration();
			
			var position:int = Config.FINGER_SIZE * .35;
			
			title.x = padding;
			title.y = position;
			position += title.height + Config.FINGER_SIZE * .2;
			
			description.x = padding;
			description.y = position;
			position += description.height + Config.FINGER_SIZE * .9;
			
			illustration.x = int(componentsWidth * .5 - illustration.width * .5 + padding);
			illustration.y = position;
			position += illustration.height + Config.FINGER_SIZE * .8;
			
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
			
			container.y = int(_height - position);
			
			startAnimation();
		}
		
		private function startAnimation():void
		{
			animator.width = illustration.width + Config.FINGER_SIZE * .4;
			animator.scaleY = animator.scaleX;
			
			animatorStartScale = animator.scaleX;
			
			animator.scaleY = animator.scaleY = animatorStartScale * 1.05;
			
			animator.x = int(illustration.x + illustration.width * .5);
			animator.y = int(illustration.y + illustration.height - animator.height * .3);
			
			showAnimator();
		}
		
		private function showAnimator():void
		{
			
			TweenMax.to(animator, 0.8, {alpha:1, onComplete:hideAnimator, delay:1, scaleX:animatorStartScale, scaleY:animatorStartScale});
		}
		
		private function hideAnimator():void
		{
			TweenMax.to(animator, 0.8, {alpha:0, onComplete:showAnimator, scaleX:animatorStartScale * 1.05, scaleY:animatorStartScale * 1.05});
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
		
		private function drawTitle(text:String, maxWidth:Number = NaN):void
		{
			var maxTextWidth:Number = maxWidth;
			if (isNaN(maxTextWidth))
			{
				maxTextWidth = componentsWidth;
			}
			
			if (title.bitmapData != null)
			{
				title.bitmapData.dispose();
				title.bitmapData = null;
			}
			
			title.bitmapData = TextUtils.createTextFieldData(
															text, maxTextWidth, 10, true, 
															TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
															Config.FINGER_SIZE * .4, true, 0x47515B, 0xFFFFFF, true);
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
															Config.FINGER_SIZE * .32, true, 0x6B7A8A, 0xFFFFFF, true);
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
		}
		
		override public function deactivateScreen():void
		{
			if (_isDisposed == true)
				return;
			
			super.deactivateScreen();
			
			backButton.deactivate();
			nextButton.deactivate();
		}
		
		override public function dispose():void
		{
			if (_isDisposed == true)
				return;
			super.dispose();
			
			TweenMax.killTweensOf(animator);
			
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
			if (container != null)
			{
				UI.destroy(container);
				container = null;
			}
			if (animator != null)
			{
				UI.destroy(animator);
				animator = null;
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
			if (title != null)
			{
				UI.destroy(title);
				title = null;
			}
			if (illustration != null)
			{
				UI.destroy(illustration);
				illustration = null;
			}
			
			callbackFunction = null;
		}
	}
}