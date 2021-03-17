package com.dukascopy.connect.screens.dialogs.paymentDialogs {

	import assets.ClockAnimation;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import com.greensock.easing.Power3;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.StageTextInitOptions;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;


	/**
	 * ...
	 * @author Sergey Dobarin
	 */

	public class BlockedAccountScreen extends BaseScreen {
		
		private var background:Sprite;
		private var backImage:Bitmap;
		private var logo:Bitmap;
		private var description:Bitmap;
		private var okButton:BitmapButton;
		private var backButton:BitmapButton;
		private var contentPadding:Number;
		private var container:Sprite;
		private var animation:Sprite;
		
		public function BlockedAccountScreen() {
			super();
		}
		
		override protected function createView():void {
			super.createView();
			
			container = new Sprite();
			view.addChild(container);
			
			background = new Sprite();
			container.addChild(background);
			
			backImage = new Bitmap();
			background.addChild(backImage);
			
			logo = new Bitmap();
			container.addChild(logo);
			
			description = new Bitmap();
			container.addChild(description);
			
			okButton = new BitmapButton();
			okButton.setStandartButtonParams();
			okButton.setDownScale(1);
			okButton.setDownColor(NaN);
			okButton.setOverlay(HitZoneType.BUTTON);
			okButton.cancelOnVerticalMovement = false;
			okButton.ignoreHittest = true;
			okButton.tapCallback = onButtonOkClick;
			
			container.addChild(okButton);
			
			backButton = new BitmapButton();
			backButton.setStandartButtonParams();
			backButton.setDownScale(1);
			backButton.setDownColor(NaN);
			backButton.setOverlay(HitZoneType.CIRCLE);
			backButton.setOverlayPadding(Config.FINGER_SIZE * .2);
			backButton.cancelOnVerticalMovement = true;
			backButton.setOverflow(Config.FINGER_SIZE * .3, Config.FINGER_SIZE * .3, Config.FINGER_SIZE * .3, Config.FINGER_SIZE * .3);
			backButton.tapCallback = onButtonBackClick;
			backButton.ignoreHittest = true;
			container.addChild(backButton);
			
			var icon:Sprite = new (Style.icon(Style.ICON_BACK))();
			UI.colorize(icon, Color.RED);
			icon.height = int(Config.FINGER_SIZE * .45);
			icon.scaleX = icon.scaleY;
			backButton.setBitmapData(UI.getSnapshot(icon, StageQuality.HIGH, "PaymentsLogin.back"), true);
			backButton.y = Config.APPLE_TOP_OFFSET + int(Config.TOP_BAR_HEIGHT * .5 - backButton.height * .5);
			backButton.x = Config.DOUBLE_MARGIN;
			
			animation = new ClockAnimation();
			UI.scaleToFit(animation, Config.FINGER_SIZE * 1.5, Config.FINGER_SIZE * 1.5);
			container.addChild(animation);
		}
		
		private function onButtonOkClick():void 
		{
			onBack();
		}
		
		private function onButtonBackClick():void 
		{
			onBack();
		}
		
		private function drawButtonOK(text:String):void {
			var textSettings:TextFieldSettings = new TextFieldSettings(text, Color.WHITE, FontSize.BODY, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, Color.GREEN, 1, -1, NaN, _width - contentPadding * 2, Config.FINGER_SIZE * .3, Style.size(Style.SIZE_BUTTON_CORNER));
			okButton.setBitmapData(buttonBitmap, true);
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			contentPadding = Config.DIALOG_MARGIN;
			
			drawTitle(Lang.accountBeingApproved);
			drawButtonOK(Lang.textBack);
			drawLogo();
			drawIllustration();
			
			background.graphics.beginFill(Style.color(Style.PAYMENTS_LOGIN_BACK_COLOR));
			background.graphics.drawRect(0, 0, _width, _height);
			background.graphics.endFill();
			
			var gap:int = (_height - Config.APPLE_BOTTOM_OFFSET - logo.height - description.height - okButton.height)/6;
			
			okButton.x = int(_width * .5 - okButton.width * .5);
			okButton.y = int(_height - okButton.height - Config.DIALOG_MARGIN - Config.APPLE_BOTTOM_OFFSET);
			
			logo.x = int(_width * .5 - logo.width * .5);
			logo.y = gap;
			
			description.x = int(_width * .5 - description.width * .5);
			description.y = int(logo.y + logo.height + gap);
			
			animation.x = int(_width * .5 - animation.width * .5);
			animation.y = int(description.y + description.height + gap);
		}
		
		private function drawIllustration():void 
		{
			var illustration:BitmapData = new (Style.icon(Style.PAYMENTS_LOGIN_IMAGE))();
			backImage.bitmapData = TextUtils.scaleBitmapData(illustration, _width / illustration.width);
			if (backImage.bitmapData.height > _height)
			{
				backImage.y = 0;
				var newBackBitmap:ImageBitmapData = new ImageBitmapData("paymentsBitmap", _width, _height);
				newBackBitmap.copyPixels(backImage.bitmapData, new Rectangle(0, 0, _width, backImage.bitmapData.height), new Point(0, _height - backImage.bitmapData.height));
				backImage.bitmapData.dispose();
				backImage.bitmapData = null;
				backImage.bitmapData = newBackBitmap;
			}
			else
			{
				backImage.y = int(_height - backImage.height);
			}
			if (illustration != null)
			{
				illustration.dispose();
				illustration = null;
			}
		}
		
		private function drawLogo():void 
		{
			var logoImage:Sprite = new (Style.icon(Style.ICON_PAYMENTS_LOGO))();
			UI.scaleToFit(logoImage, _width - contentPadding * 2 - Config.FINGER_SIZE, Config.FINGER_SIZE * 0.9);
			logo.bitmapData = UI.getSnapshot(logoImage);
			UI.destroy(logoImage);
		}
		
		private function drawTitle(text:String):void 
		{
			if (description.bitmapData != null)
			{
				description.bitmapData.dispose();
				description.bitmapData = null;
			}
			
			description.bitmapData = TextUtils.createTextFieldData(
				text,
				_width - contentPadding * 2,
				10,
				true,
				TextFormatAlign.LEFT,
				TextFieldAutoSize.LEFT,
				FontSize.BODY,
				true,
				Style.color(Style.COLOR_TEXT)
			);
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			
			okButton.activate();
			backButton.activate();
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			
			okButton.deactivate();
			backButton.deactivate();
		}
		
		override protected function drawView():void {
			super.drawView();
		}
		
		override public function dispose():void {
			if (isDisposed == true) {
				return;
			}
			super.dispose();
			
			if (animation != null)
				UI.destroy(animation);
			animation = null;
			if (backImage != null)
				UI.destroy(backImage);
			backImage = null;
			if (background != null)
				UI.destroy(background);
			background = null;
			if (container != null)
				UI.destroy(container);
			container = null;
			if (logo != null)
				UI.destroy(logo);
			logo = null;
			if (description != null)
				UI.destroy(description);
			description = null;
			if (okButton != null)
				okButton.dispose();
			okButton = null;
			if (backButton != null)
				backButton.dispose();
			backButton = null;
		}
	}
}