package com.dukascopy.connect.screens.dialogs.escrow {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.data.escrow.EscrowMessageData;
	import com.dukascopy.connect.data.escrow.EscrowScreenNavigation;
	import com.dukascopy.connect.data.escrow.EscrowSettings;
	import com.dukascopy.connect.data.escrow.EscrowStatus;
	import com.dukascopy.connect.data.escrow.OfferCommand;
	import com.dukascopy.connect.data.escrow.TradeDirection;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
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
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin.
	 */

	public class RegisterBlockchainScreen extends EscrowDealScreen {
		
		private var registerButton:BitmapButton;
		private var amount:Bitmap;
		private var price:Bitmap;
		private var balance:BalanceCalculation;
		private var status:OfferStatusClip;
		private var description:Bitmap;
		private var illustration:Bitmap;
		private var escrowOffer:EscrowMessageData;
		private var command:OfferCommand;
		private var descriptionSprite:Sprite;
		
		public function RegisterBlockchainScreen() { }
		
		override protected function createView():void {
			super.createView();
			
			illustrationSize = Config.FINGER_SIZE * 1.4;
			
			topColor = Color.BLACK;
			bottomColor = Style.color(Style.COLOR_BACKGROUND);
			
			createRegisterButton();
			
			illustration = new Bitmap();
			container.addChild(illustration);
			
			descriptionSprite = new Sprite();
			addItem(descriptionSprite);
			
			description = new Bitmap();
			descriptionSprite.addChild(description);
			
			amount = new Bitmap();
			addItem(amount);
			
			price = new Bitmap();
			addItem(price);
			
			status = new OfferStatusClip();
			addItem(status);
		}
		
		private function onRegisterClick():void 
		{
			command = OfferCommand.register_blockchain;
			close();
		}
		
		override public function onBack(e:Event = null):void {
			close();
		}
		
		private function createRegisterButton():void 
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
			
			if ("escrowOffer" in data && data.escrowOffer != null)
			{
				escrowOffer = data.escrowOffer as EscrowMessageData;
			}
			
			super.initScreen(data);
		}
		
		override protected function drawContent():void 
		{
			drawAmount();
			drawPrice();
			drawIllustration();
			drawStatus();
			drawText();
			drawControls();
			createBalance();
		}
		
		private function createBalance():void 
		{
			var texts:Vector.<String> = new Vector.<String>();
			var values:Vector.<String> = new Vector.<String>();
			var colors:Vector.<Number> = new Vector.<Number>();
			
			if (escrowOffer != null)
			{
				if (escrowOffer.status == EscrowStatus.offer_created)
				{
					if (escrowOffer.direction == TradeDirection.buy)
					{
						texts.push(Lang.to_pay_for_crypto);
						texts.push(Lang.refundable_fee.replace("%@", (EscrowSettings.refundableFee*100)));
						texts.push(Lang.amount_to_be_debited);
						
						colors.push(Style.color(Style.COLOR_SUBTITLE));
						colors.push(Style.color(Style.COLOR_SUBTITLE));
						colors.push(Color.WHITE);
						
						values.push(NumberFormat.formatAmount(escrowOffer.amount * escrowOffer.price, escrowOffer.currency));
						values.push(NumberFormat.formatAmount(escrowOffer.amount * escrowOffer.price * EscrowSettings.refundableFee, escrowOffer.currency));
						values.push(NumberFormat.formatAmount(escrowOffer.amount * escrowOffer.price * EscrowSettings.refundableFee + escrowOffer.amount * escrowOffer.price, escrowOffer.currency));
					}
					else if (escrowOffer.direction == TradeDirection.sell)
					{
						texts.push(Lang.amount_of_transaction);
						texts.push(Lang.commission_crypto.replace("%@", (EscrowSettings.getCommission(escrowOffer.instrument) * 100)));
						texts.push(Lang.amount_to_be_credited);
						
						colors.push(Style.color(Style.COLOR_SUBTITLE));
						colors.push(Style.color(Style.COLOR_SUBTITLE));
						colors.push(Color.WHITE);
						
						values.push(NumberFormat.formatAmount(escrowOffer.amount * escrowOffer.price, escrowOffer.currency));
						values.push(NumberFormat.formatAmount(escrowOffer.amount * escrowOffer.price * EscrowSettings.getCommission(escrowOffer.instrument), escrowOffer.currency));
						values.push(NumberFormat.formatAmount(escrowOffer.amount * escrowOffer.price * EscrowSettings.refundableFee + escrowOffer.amount * escrowOffer.price, escrowOffer.currency));
					}
				}
			}
			
			if (balance == null)
			{
				balance = new BalanceCalculation();
				addItem(balance);
			}
			balance.drawTexts(texts, colors);
			balance.draw(getWidth() - contentPadding * 2, values);
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
				if (amount.bitmapData != null)
				{
					amount.bitmapData.dispose();
					amount.bitmapData = null;
				}
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
				
				if (price.bitmapData != null)
				{
					price.bitmapData.dispose();
					price.bitmapData = null;
				}
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
					if (illustration.bitmapData != null)
					{
						illustration.bitmapData.dispose();
						illustration.bitmapData = null;
					}
					
					var icon:Sprite = (new iconClass)();
					UI.scaleToFit(icon, illustrationSize, illustrationSize);
					illustration.bitmapData = UI.getSnapshot(icon);
					icon = null;
				}
			}
		}
		
		private function drawText():void 
		{
			if (description.bitmapData != null)
			{
				description.bitmapData.dispose();
				description.bitmapData = null;
			}
			description.bitmapData = TextUtils.createTextFieldData(Lang.declare_blockchain, getWidth() - contentPadding * 2, 10, true,
																	TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
																	FontSize.SUBHEAD, true, Style.color(Style.COLOR_SUBTITLE),
																	Style.color(Style.COLOR_BACKGROUND), false, true);
		}
		
		override protected function updateContentPositions():void 
		{
			illustration.x = int(getWidth() * .5 - illustration.width * .5);
			illustration.y = int( - illustration.height * .5);
			
			var position:int = Config.FINGER_SIZE * .4;
			
			amount.x = int(getWidth() * .5 - amount.width * .5);
			amount.y = position;
			position += amount.height + contentPaddingV;
			
			price.x = int(getWidth() * .5 - price.width * .5);
			price.y = position;
			position += price.height + contentPaddingV;
			
			balance.x = int(getWidth() * .5 - balance.width * .5);
			balance.y = position;
			position += balance.height + contentPaddingV * 1.5;
			
			status.y = position;
			status.x = int(getWidth() * .5 - status.width * .5);
			position += status.height * .5;
			
			colorDelimiterPosition = position;
			position += status.height * .5;
			
			position += contentPaddingV * 1.7;
			
			
			descriptionSprite.x = contentPadding;
			descriptionSprite.y = position;
			position += descriptionSprite.height + contentPaddingV * 1.5;
			
			registerButton.x = contentPadding;
			registerButton.y = position;
			position += registerButton.height + contentPaddingV;
		}
		
		private function drawControls():void
		{
			var textSettings:TextFieldSettings;
			var buttonBitmap:ImageBitmapData;
				
			textSettings = new TextFieldSettings(Lang.textRegister.toUpperCase(), Style.color(Style.COLOR_BACKGROUND), FontSize.BODY, TextFormatAlign.CENTER);
			buttonBitmap = TextUtils.createbutton(textSettings, Style.color(Style.COLOR_BUTTON_ACCENT), 1, -1, NaN, getButtonWidth(), Style.size(Style.BUTTON_PADDING), Style.size(Style.SIZE_BUTTON_CORNER));
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
			
			registerButton.activate();
			PointerManager.addTap(descriptionSprite, openInfoLink);
		}
		
		private function openInfoLink(e:Event):void 
		{
			navigateToURL(new URLRequest(Lang.declare_blockchain_description_url));
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed) {
				return;
			}
			
			registerButton.deactivate();
			PointerManager.removeTap(descriptionSprite, openInfoLink);
		}
		
		override protected function onRemove():void 
		{
			if (command != null && "callback" in data && data.callback != null && data.callback is Function && (data.callback as Function).length == 4)
			{
				(data.callback as Function)(escrowOffer, null, null, command);
				command = null;
				escrowOffer = null;
			}
		}
		
		override public function dispose():void {
			super.dispose();
			
			if (registerButton != null)
			{
				registerButton.dispose();
				registerButton = null;
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
			if (descriptionSprite != null)
			{
				UI.destroy(descriptionSprite);
				descriptionSprite = null;
			}
			if (description != null)
			{
				UI.destroy(description);
				description = null;
			}
			if (amount != null)
			{
				UI.destroy(amount);
				amount = null;
			}
		}
	}
}