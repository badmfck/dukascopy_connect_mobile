package com.dukascopy.connect.screens.dialogs.paymentDialogs {

	import assets.FingerprintIcon;
	import assets.MountainAnimation;
	import assets.PaymentsLogo;
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
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;


	/**
	 * ...
	 * @author Sergey Dobarin
	 */

	public class PaymentsUnavaliableScreen extends BaseScreen {
		
		private var background:Sprite;
		private var illustration:MountainAnimation;
		private var description:Bitmap;
		private var title:Bitmap;
		private var okButton:BitmapButton;
		private var backButton:BitmapButton;
		private var closeButton:BitmapButton;
		
		private var container:Sprite;
		private var contentPadding:int;
		
		public function PaymentsUnavaliableScreen() {
			super();
		}
		
		override protected function createView():void {
			super.createView();
			
			container = new Sprite();
			view.addChild(container);
			
			background = new Sprite();
			container.addChild(background);
			
			illustration = new MountainAnimation();
			container.addChild(illustration);
			
			description = new Bitmap();
			container.addChild(description);
			
			title = new Bitmap();
			container.addChild(title);
			
			okButton = new BitmapButton();
			okButton.setStandartButtonParams();
			okButton.setDownScale(1);
			okButton.setDownColor(NaN);
			okButton.setOverlay(HitZoneType.BUTTON);
			okButton.cancelOnVerticalMovement = false;
			okButton.ignoreHittest = false;
			okButton.tapCallback = onButtonOkClick;
			
			container.addChild(okButton);
			
			backButton = new BitmapButton();
			backButton.setStandartButtonParams();
			backButton.setDownScale(1);
			backButton.setDownColor(NaN);
			backButton.setOverlay(HitZoneType.CIRCLE);
			backButton.setOverlayPadding(Config.FINGER_SIZE * .2);
			backButton.setOverflow(Config.FINGER_SIZE * .3, Config.FINGER_SIZE * .3, Config.FINGER_SIZE * .3, Config.FINGER_SIZE * .3);
			backButton.tapCallback = onButtonBackClick;
			container.addChild(backButton);
			
			var icon:Sprite = new (Style.icon(Style.ICON_BACK))();
			UI.colorize(icon, Style.color(Style.TOP_BAR_ICON_COLOR));
			icon.height = int(Config.FINGER_SIZE * .45);
			icon.scaleX = icon.scaleY;
			backButton.setBitmapData(UI.getSnapshot(icon, StageQuality.HIGH, "PaymentsLogin.back"), true);
			backButton.y = Config.APPLE_TOP_OFFSET + int(Config.TOP_BAR_HEIGHT * .5 - backButton.height * .5);
			backButton.x = Config.DOUBLE_MARGIN;
			
			
			closeButton = new BitmapButton();
			closeButton.setStandartButtonParams();
			closeButton.setDownScale(1);
			closeButton.setDownColor(NaN);
			closeButton.setOverlay(HitZoneType.BUTTON);
			closeButton.cancelOnVerticalMovement = true;
			closeButton.tapCallback = onButtonBackClick;
			container.addChild(closeButton);
		}
		
		private function onButtonRestoreClick():void 
		{
			
		}
		
		private function onButtonOkClick():void 
		{
			navigateToURL(new URLRequest(Config.PAYMENTS_WEB));
		}
		
		private function onForgotClick():void {
			
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
		
		private function drawButtonClose(text:String):void {
			var textSettings:TextFieldSettings = new TextFieldSettings(text, Style.color(Style.COLOR_SUBTITLE), FontSize.BODY, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, 0, 0, -1, Style.color(Style.COLOR_SUBTITLE), _width - contentPadding * 2, Config.FINGER_SIZE * .3, Style.size(Style.SIZE_BUTTON_CORNER));
			closeButton.setBitmapData(buttonBitmap, true);
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			contentPadding = Config.FINGER_SIZE * .7;
			
			redrawComponents();
			drawIllustration();
			
			background.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			background.graphics.drawRect(0, 0, _width, _height);
			background.graphics.endFill();
		}
		
		private function redrawComponents():void 
		{
			drawTitle(Lang.maintenanceWork);
			drawDescription(Lang.maintenanceWorkDescription);
			drawButtonOK(Lang.openWebApplication);
			drawButtonClose(Lang.textBack);
		}
		
		private function drawIllustration():void 
		{
			UI.scaleToFit(illustration, Config.FINGER_SIZE * 1.3, Config.FINGER_SIZE * 1.3);
		}
		
		private function drawTitle(text:String):void 
		{
			if (title.bitmapData != null)
			{
				title.bitmapData.dispose();
				title.bitmapData = null;
			}
			
			title.bitmapData = TextUtils.createTextFieldData(
				text,
				_width - contentPadding * 2,
				10,
				true,
				TextFormatAlign.CENTER,
				TextFieldAutoSize.CENTER,
				FontSize.TITLE_1,
				true,
				Style.color(Style.COLOR_TEXT)
			);
		}
		
		private function drawDescription(text:String):void 
		{
			if (description.bitmapData != null)
			{
				description.bitmapData.dispose();
				description.bitmapData = null;
			}
			
			if (data != null)
			{
				for each (var item:String in data.text) 
				{
					text += "\n" + item + ": " + data.text[item];
				}
				
			}
			
			description.bitmapData = TextUtils.createTextFieldData(
				text,
				_width - contentPadding * 2,
				10,
				true,
				TextFormatAlign.CENTER,
				TextFieldAutoSize.CENTER,
				FontSize.BODY,
				true,
				Style.color(Style.COLOR_TEXT)
			);
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			
			backButton.activate();
			okButton.activate();
			closeButton.activate();
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			
			backButton.deactivate();
			okButton.deactivate();
			closeButton.deactivate();
		}
		
		override protected function drawView():void {
			super.drawView();
			
			illustration.x = int(_width * .5 - illustration.width * .5);
			okButton.x = int(_width * .5 - okButton.width * .5);
			closeButton.x = int(_width * .5 - closeButton.width * .5);
			title.x = int(_width * .5 - title.width * .5);
			description.x = int(_width * .5 - description.width * .5);
			
			closeButton.y = int(_height - Config.APPLE_BOTTOM_OFFSET - Config.DIALOG_MARGIN - closeButton.height);
			okButton.y = int(closeButton.y - Config.FINGER_SIZE * .3 - okButton.height);
			
			illustration.y = (okButton.y - Config.FINGER_SIZE - illustration.height - title.height - description.height - Config.FINGER_SIZE * 1.2) * .5;
			title.y = int(illustration.y + illustration.height + Config.FINGER_SIZE * .7);
			description.y = int(title.y + title.height + Config.FINGER_SIZE * .4);
		}
		
		override public function dispose():void {
			if (isDisposed == true) {
				return;
			}
			super.dispose();
			
			if (container != null)
				UI.destroy(container);
			container = null;
			if (illustration != null)
				UI.destroy(illustration);
			illustration = null;
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