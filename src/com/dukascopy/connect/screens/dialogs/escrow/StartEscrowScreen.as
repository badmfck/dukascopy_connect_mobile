package com.dukascopy.connect.screens.dialogs.escrow {
	
	import assets.ExchangeIcon;
	import com.dukascopy.connect.Config;
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
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
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

	public class StartEscrowScreen extends FloatPopup {
		
		private var buyButton:BitmapButton;
		private var sellButton:BitmapButton;
		
		private var selectedDirection:TradeDirection;
		private var description:Bitmap;
		private var illustration:Bitmap;
		private var linkClip:LinkClip;
		
		public function StartEscrowScreen() { }
		
		override protected function createView():void {
			super.createView();
			
			createSellButton();
			createBuyButton();
			
			illustration = new Bitmap();
			addItem(illustration);
			
			description = new Bitmap();
			addItem(description);
		}
		
		private function createSellButton():void 
		{
			sellButton = new BitmapButton();
			sellButton.setStandartButtonParams();
			sellButton.tapCallback = onSellClick;
			sellButton.disposeBitmapOnDestroy = true;
			sellButton.setDownScale(1);
			sellButton.setOverlay(HitZoneType.BUTTON);
			addItem(sellButton);
		}
		
		private function onSellClick():void 
		{
			selectedDirection = TradeDirection.sell;
			close();
		}
		
		override public function onBack(e:Event = null):void {
			close();
		}
		
		private function createBuyButton():void 
		{
			buyButton = new BitmapButton();
			buyButton.setStandartButtonParams();
			buyButton.tapCallback = onBuyClick;
			buyButton.disposeBitmapOnDestroy = true;
			buyButton.setDownScale(1);
			buyButton.setOverlay(HitZoneType.BUTTON);
			addItem(buyButton);
		}
		
		private function onBuyClick():void 
		{
			selectedDirection = TradeDirection.buy;
			close();
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
		}
		
		override protected function drawContent():void 
		{
			drawIllustration();
			drawText();
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
			position += linkClip.height + contentPaddingV * 2;
			
			sellButton.x = contentPadding;
			buyButton.x = contentPadding;
			
			sellButton.y = position;
			position += sellButton.height + contentPaddingV;
			
			buyButton.y = position;
			position += buyButton.height + contentPaddingV;
		}
		
		private function drawControls():void
		{
			var textSettings:TextFieldSettings = new TextFieldSettings(Lang.wantBuyCrypto, Style.color(Style.COLOR_TEXT), FontSize.BODY, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, Style.color(Style.COLOR_BACKGROUND), 1, -1, Style.color(Style.COLOR_BUTTON_OUTLINE), getButtonWidth(), Style.size(Style.BUTTON_PADDING), Style.size(Style.SIZE_BUTTON_CORNER));
			buyButton.setBitmapData(buttonBitmap, true);
			
			textSettings = new TextFieldSettings(Lang.wantSellCrypto, Style.color(Style.COLOR_TEXT), FontSize.BODY, TextFormatAlign.CENTER);
			buttonBitmap = TextUtils.createbutton(textSettings, Style.color(Style.COLOR_BACKGROUND), 1, -1, Style.color(Style.COLOR_BUTTON_OUTLINE), getButtonWidth(), Style.size(Style.BUTTON_PADDING), Style.size(Style.SIZE_BUTTON_CORNER));
			sellButton.setBitmapData(buttonBitmap, true);
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
			buyButton.activate();
			sellButton.activate();
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed) {
				return;
			}
			
			linkClip.deactivate();
			buyButton.deactivate();
			sellButton.deactivate();
		}
		
		override protected function onRemove():void 
		{
			if (selectedDirection != null)
			{
				if (data != null && "callback" in data && data.callback != null && data.callback is Function && (data.callback as Function).length == 1)
				{
					(data.callback as Function)(selectedDirection);
				}
				selectedDirection = null;
			}
		}
		
		override public function dispose():void {
			super.dispose();
			
			if (buyButton != null)
			{
				buyButton.dispose();
				buyButton = null;
			}
			if (sellButton != null)
			{
				sellButton.dispose();
				sellButton = null;
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
			if (description != null)
			{
				UI.destroy(description);
				description = null;
			}
		}
	}
}