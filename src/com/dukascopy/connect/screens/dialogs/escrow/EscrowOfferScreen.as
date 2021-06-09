package com.dukascopy.connect.screens.dialogs.escrow {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.data.escrow.EscrowMessageData;
	import com.dukascopy.connect.data.escrow.EscrowStatus;
	import com.dukascopy.connect.data.escrow.TradeDirection;
	import com.dukascopy.connect.gui.components.LinkClip;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.NumberFormat;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin.
	 */

	public class EscrowOfferScreen extends EscrowDealScreen {
		
		private var button:BitmapButton;
		private var amount:Bitmap;
		private var price:Bitmap;
		private var balance:BalanceCalculation;
		private var status:OfferStatusClip;
		private var description:Bitmap;
		private var time:TimeClip;
		private var illustration:Bitmap;
		
		private var needOpenAccount:Boolean;
		private var escrowOffer:EscrowMessageData;
		
		public function EscrowOfferScreen() { }
		
		override protected function createView():void {
			super.createView();
			
			createBuyButton();
			
			illustration = new Bitmap();
			addItem(illustration);
			
			description = new Bitmap();
			addItem(description);
			
			amount = new Bitmap();
			addItem(amount);
			
			price = new Bitmap();
			addItem(price);
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
			button = new BitmapButton();
			button.setStandartButtonParams();
			button.tapCallback = onRegisterClick;
			button.disposeBitmapOnDestroy = true;
			button.setDownScale(1);
			button.setOverlay(HitZoneType.BUTTON);
			addItem(button);
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			if ("escrowOffer" in data && data.escrowOffer != null)
			{
				escrowOffer = data.escrowOffer as EscrowMessageData;
			}
			
		}
		
		override protected function drawContent():void 
		{
			drawAmount();
			drawPrice();
			drawIllustration();
			drawStatus();
			drawText();
			drawControls();
		}
		
		private function drawStatus():void 
		{
			if (escrowOffer != null)
			{
				var text:String = "";
				var color:Number = Color.GREEN;
				if (escrowOffer.status == EscrowStatus.offer_created)
				{
					if (escrowOffer.direction == TradeDirection.buy)
					{
						text = Lang.buy_offer_awaiting_acceptance;
						color = Color.GREEN;
					}
					else if (escrowOffer.direction == TradeDirection.sell)
					{
						text = Lang.sell_offer_awaiting_acceptance;
						color = Color.RED;
					}
				}
				
				status.draw(getWidth() - contentPadding * 2, text, color);
			}
		}
		
		private function drawAmount():void 
		{
			//!TODO: colors for theme;
			if (escrowOffer != null)
			{
				var text:String = NumberFormat.formatAmount(escrowOffer.amount, escrowOffer.instrument);
				amount.bitmapData = TextUtils.createTextFieldData(text, getWidth() - contentPadding * 2, 10, true,
																	TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
																	FontSize.TITLE_28, true, Color.WHITE,
																	Color.BLACK, false);
			}
			
		}
		
		private function drawPrice():void 
		{
			//!TODO: colors for theme;
			if (escrowOffer != null)
			{
				var text:String = Lang.price_per_coin;
				text = text.replace(Lang.regExtValue, NumberFormat.formatAmount(escrowOffer.price, escrowOffer.currency));
				
				price.bitmapData = TextUtils.createTextFieldData(text, getWidth() - contentPadding * 2, 10, true,
																	TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
																	FontSize.SUBHEAD, true, Color.WHITE,
																	Color.BLACK, false);
			}
			
		}
		
		private function drawIllustration():void 
		{
			if (escrowOffer != null)
			{
				var iconClass:Class = UI.getCryptoIconClass(escrowOffer.instrument);
				if (iconClass != null)
				{
					var icon:Sprite = (new iconClass)();
					var iconSize:int = Config.FINGER_SIZE * 1.2;
					UI.scaleToFit(icon, iconSize, iconSize);
					illustration.bitmapData = UI.getSnapshot(icon);
					icon = null;
				}
			}
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
			
			colorDelimiterPosition = position;
			position += contentPaddingV * 1.5;
			
			amount.x = contentPadding;
			amount.y = position;
			position += amount.height + contentPaddingV * 1.5;
			
			button.x = contentPadding;
			button.y = position;
			position += button.height + contentPaddingV;
		}
		
		private function drawControls():void
		{
			var textSettings:TextFieldSettings = new TextFieldSettings(Lang.openMcaAccount, Color.WHITE, FontSize.BODY, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, Color.GREEN, 1, -1, NaN, getButtonWidth(), Style.size(Style.BUTTON_PADDING), Style.size(Style.SIZE_BUTTON_CORNER));
			button.setBitmapData(buttonBitmap, true);
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
			
			button.activate();
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed) {
				return;
			}
			
			button.deactivate();
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
			
			if (button != null)
			{
				button.dispose();
				button = null;
			}
			if (balance != null)
			{
				balance.dispose();
				balance = null;
			}
			if (status != null)
			{
				status.dispose();
				status = null;
			}
			if (time != null)
			{
				time.dispose();
				time = null;
			}
			if (illustration != null)
			{
				UI.destroy(illustration);
				illustration = null;
			}
			if (price != null)
			{
				UI.destroy(price);
				price = null;
			}
			if (description != null)
			{
				UI.destroy(description);
				description = null;
			}
		}
	}
}