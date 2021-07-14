package com.dukascopy.connect.screens.dialogs.escrow {
	
	import assets.ExchangeIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.data.escrow.EscrowDealData;
	import com.dukascopy.connect.data.escrow.TradeDirection;
	import com.dukascopy.connect.gui.components.LinkClip;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.screens.dialogs.paymentDialogs.elements.InputField;
	import com.dukascopy.connect.screens.dialogs.x.base.bottom.ScrollAnimatedTitlePopup;
	import com.dukascopy.connect.screens.dialogs.x.base.float.FloatPopup;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin.
	 */

	public class RegisterEscrowScreen extends FloatPopup {
		
		private var registerButton:BitmapButton;
		
		private var description:Bitmap;
		private var registerText:Bitmap;
		private var illustration:Bitmap;
		private var linkClip:LinkClip;
		
		private var needOpenAccount:Boolean;
		
		public function RegisterEscrowScreen() { }
		
		override protected function createView():void {
			super.createView();
			
			createBuyButton();
			
			illustration = new Bitmap();
			addItem(illustration);
			
			description = new Bitmap();
			addItem(description);
			
			registerText = new Bitmap();
			addItem(registerText);
		}
		
		private function onRegisterClick():void 
		{
			needOpenAccount = true;
			close();
		}
		
		override public function onBack(e:Event = null):void {
			close();
		}
		
		private function createBuyButton():void 
		{
			registerButton = new BitmapButton();
			registerButton.setStandartButtonParams();
			registerButton.tapCallback = onRegisterClick;
			registerButton.disposeBitmapOnDestroy = true;
			registerButton.setDownScale(1);
			registerButton.setOverlay(HitZoneType.BUTTON);
			addItem(registerButton);
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
		}
		
		override protected function drawContent():void 
		{
			drawIllustration();
			drawText();
			drawRegisterText();
			drawLink();
			drawControls();
		}
		
		private function drawLink():void 
		{
			linkClip = new LinkClip(Lang.aboutService, Lang.escrow_about_service_url, getWidth());
			addItem(linkClip);
		}
		
		private function drawIllustration():void 
		{
			var icon:Sprite = new ExchangeIcon2();
			var iconSize:int = Config.FINGER_SIZE * 1.2;
			UI.scaleToFit(icon, iconSize, iconSize);
			UI.colorize(icon, Style.color(Style.COLOR_TEXT));
			illustration.bitmapData = UI.getSnapshot(icon);
			icon = null;
		}
		
		private function drawRegisterText():void 
		{
			var text:String = Lang.register_mca_description;
			registerText.bitmapData = TextUtils.createTextFieldData(text, getWidth() - contentPadding * 2, 10, true,
																	TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
																	FontSize.SUBHEAD, true, Style.color(Style.COLOR_SUBTITLE),
																	Style.color(Style.COLOR_LIST_SPECIAL), false);
		}
		
		private function drawText():void 
		{
			var text:String = Lang.escrow_description;
			description.bitmapData = TextUtils.createTextFieldData(text, getWidth() - contentPadding * 2, 10, true,
																	TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
																	FontSize.BODY, true, Style.color(Style.COLOR_TEXT),
																	Style.color(Style.COLOR_BACKGROUND), false);
		}
		
		override protected function updateContentPositions():void 
		{
			var position:int = 0;
			
			illustration.x = int(getWidth() * .5 - illustration.width * .5);
			illustration.y = position;
			position += illustration.height + contentPaddingV * 1.5;
			
			description.x = contentPadding;
			description.y = position;
			position += description.height + contentPaddingV * 1.5;
			
			linkClip.x = int(getWidth() * .5 - linkClip.width * .5);
			linkClip.y = position;
			position += linkClip.height + contentPaddingV * 1.5;
			
			colorDelimiterPosition = position;
			position += contentPaddingV * 1.5;
			
			registerText.x = contentPadding;
			registerText.y = position;
			position += registerText.height + contentPaddingV * 1.5;
			
			registerButton.x = contentPadding;
			registerButton.y = position;
			position += registerButton.height + contentPaddingV;
		}
		
		private function drawControls():void
		{
			var textSettings:TextFieldSettings = new TextFieldSettings(Lang.openMcaAccount, Color.WHITE, FontSize.BODY, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, Color.GREEN, 1, -1, NaN, getButtonWidth(), Style.size(Style.BUTTON_PADDING), Style.size(Style.SIZE_BUTTON_CORNER));
			registerButton.setBitmapData(buttonBitmap, true);
		}
		
		private function getButtonWidth():int 
		{
			return (getWidth() - contentPadding * 2);
		}
		
		override protected function drawView():void {
			if (_isDisposed == true)
				return;
			
			super.drawView();
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			if (_isDisposed) {
				return;
			}
			
			linkClip.activate();
			registerButton.activate();
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed) {
				return;
			}
			
			linkClip.deactivate();
			registerButton.deactivate();
		}
		
		override protected function onRemove():void 
		{
			if (needOpenAccount == true)
			{
				needOpenAccount = false;
				MobileGui.openMyAccountIfExist();
			}
		}
		
		override public function dispose():void {
			super.dispose();
			
			if (registerButton != null)
			{
				registerButton.dispose();
				registerButton = null;
			}
			if (linkClip != null)
			{
				linkClip.dispose();
				linkClip = null;
			}
			if (illustration != null)
			{
				UI.destroy(illustration);
				illustration = null;
			}
			if (registerText != null)
			{
				UI.destroy(registerText);
				registerText = null;
			}
			if (description != null)
			{
				UI.destroy(description);
				description = null;
			}
		}
	}
}