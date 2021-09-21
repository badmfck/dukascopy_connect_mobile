package com.dukascopy.connect.screens.dialogs.escrow {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.data.coinMarketplace.PaymentsAccountsProvider;
	import com.dukascopy.connect.data.escrow.EscrowMessageData;
	import com.dukascopy.connect.data.escrow.EscrowScreenNavigation;
	import com.dukascopy.connect.data.escrow.EscrowSettings;
	import com.dukascopy.connect.data.escrow.EscrowStatus;
	import com.dukascopy.connect.data.escrow.OfferCommand;
	import com.dukascopy.connect.data.escrow.TradeDirection;
	import com.dukascopy.connect.gui.button.DDAccountButton;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.screens.dialogs.paymentDialogs.elements.InputField;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.NumberFormat;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.connect.vo.ChatMessageVO;
	import com.dukascopy.connect.vo.ChatVO;
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

	public class WaitCryptoScreen extends EscrowDealScreen {
		
		private var acceptButton:BitmapButton;
		private var amount:Bitmap;
		private var price:Bitmap;
		private var balance:BalanceCalculation;
		private var status:OfferStatusClip;
		private var description:Bitmap;
		private var time:TimeClip;
		private var illustration:Bitmap;
		
		private var escrowOffer:EscrowMessageData;
		private var offerCreatedTime:Number;
		private var message:ChatMessageVO;
		private var chat:ChatVO;
		private var command:OfferCommand;
		
		public function WaitCryptoScreen() { }
		
		override protected function createView():void {
			super.createView();
			
			illustrationSize = Config.FINGER_SIZE * 1.4;
			
			topColor = Color.BLACK;
			bottomColor = Style.color(Style.COLOR_BACKGROUND);
			
			createAcceptButton();
			
			illustration = new Bitmap();
			container.addChild(illustration);
			
			description = new Bitmap();
			addItem(description);
			
			amount = new Bitmap();
			addItem(amount);
			
			price = new Bitmap();
			addItem(price);
			
			status = new OfferStatusClip();
			addItem(status);
			
			time = new TimeClip(onTimeFinish);
			addItem(time);
		}
		
		private function onTimeFinish():void 
		{
			if (isDisposed)
			{
				return;
			}
			
			recreateLayout();
		}
		
		private function onAcceptClick():void 
		{
			close();
		}
		
		override public function onBack(e:Event = null):void {
			close();
		}
		
		private function createAcceptButton():void 
		{
			acceptButton = new BitmapButton();
			acceptButton.setStandartButtonParams();
			acceptButton.tapCallback = onAcceptClick;
			acceptButton.disposeBitmapOnDestroy = true;
			acceptButton.setDownScale(1);
			acceptButton.setOverlay(HitZoneType.BUTTON);
			addItem(acceptButton);
		}
		
		override public function initScreen(data:Object = null):void {
			
			if ("created" in data)
			{
				offerCreatedTime = data.created as Number;
			}
			if ("escrowOffer" in data && data.escrowOffer != null)
			{
				escrowOffer = data.escrowOffer as EscrowMessageData;
			}
			if ("chat" in data && data.chat != null)
			{
				chat = data.chat as ChatVO;
			}
			if ("message" in data && data.message != null)
			{
				message = data.message as ChatMessageVO;
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
			drawTime();
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
				texts.push(Lang.to_pay_for_crypto);
				texts.push(Lang.refundable_fee.replace("%@", (EscrowSettings.refundableFee * 100)));
				texts.push(Lang.amount_blocked);
				
				colors.push(Style.color(Style.COLOR_SUBTITLE));
				colors.push(Style.color(Style.COLOR_SUBTITLE));
				colors.push(Color.WHITE);
				
				values.push(NumberFormat.formatAmount(escrowOffer.amount * escrowOffer.price, escrowOffer.currency));
				values.push(NumberFormat.formatAmount(escrowOffer.amount * escrowOffer.price * EscrowSettings.refundableFee, escrowOffer.currency));
				values.push(NumberFormat.formatAmount(escrowOffer.amount * escrowOffer.price * EscrowSettings.refundableFee + escrowOffer.amount * escrowOffer.price, escrowOffer.currency));
			}
			
			if (balance == null)
			{
				balance = new BalanceCalculation();
				addItem(balance);
			}
			balance.drawTexts(texts, colors);
			balance.draw(getWidth() - contentPadding * 2, values);
		}
		
		private function drawTime():void 
		{
			if (escrowOffer != null && !EscrowScreenNavigation.isExpired(escrowOffer, offerCreatedTime))
			{
				//!TODO: check start time;
				time.draw(getWidth() - contentPadding * 2, EscrowSettings.dealMaxTime * 60 - ((new Date()).time / 1000 - offerCreatedTime));
			}
			else
			{
				removeItem(time);
			}
		}
		
		private function drawStatus():void 
		{
			var text:String = Lang.waiting_for_crypto;
			var color:Number = Color.GREEN;
			
			status.draw(getWidth() - contentPadding * 2, text, color);
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
			var text:String = Lang.waiting_for_crypto_description;
			text = text.replace("%@", EscrowSettings.dealMaxTime);
			
			if (description.bitmapData != null)
			{
				description.bitmapData.dispose();
				description.bitmapData = null;
			}
			description.bitmapData = TextUtils.createTextFieldData(text, getWidth() - contentPadding * 2, 10, true,
																	TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
																	FontSize.BODY, true, Style.color(Style.COLOR_TEXT),
																	Style.color(Style.COLOR_BACKGROUND), false);
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
			
			description.x = contentPadding;
			description.y = position;
			position += description.height + contentPaddingV * 1.5;
			
			time.x = int(getWidth() * .5 - time.width * .5);
			time.y = position;
			position += time.height + contentPaddingV;
			
			acceptButton.x = contentPadding;
			acceptButton.y = position;
			position += acceptButton.height + contentPaddingV;
		}
		
		private function drawControls():void
		{
			var textSettings:TextFieldSettings;
			var buttonBitmap:ImageBitmapData;
			
			textSettings = new TextFieldSettings(Lang.textOk, Style.color(Style.COLOR_TEXT), FontSize.BODY, TextFormatAlign.CENTER);
			buttonBitmap = TextUtils.createbutton(textSettings, Style.color(Style.COLOR_BACKGROUND), 1, -1, Style.color(Style.COLOR_BUTTON_OUTLINE), getButtonWidth(), Style.size(Style.BUTTON_PADDING), Style.size(Style.SIZE_BUTTON_CORNER));
			acceptButton.setBitmapData(buttonBitmap, true);
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
			
			acceptButton.activate();
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed) {
				return;
			}
			
			acceptButton.deactivate();
		}
		
		override protected function onRemove():void 
		{
			if (command != null && "callback" in data && data.callback != null && data.callback is Function && (data.callback as Function).length == 4)
			{
				(data.callback as Function)(escrowOffer, message, chat, command);
				command = null;
				chat = null;
				message = null;
				escrowOffer = null;
			}
		}
		
		override public function dispose():void {
			super.dispose();
			
			if (acceptButton != null)
			{
				acceptButton.dispose();
				acceptButton = null;
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
			if (amount != null)
			{
				UI.destroy(amount);
				amount = null;
			}
		}
	}
}