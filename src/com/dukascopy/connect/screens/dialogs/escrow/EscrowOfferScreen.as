package com.dukascopy.connect.screens.dialogs.escrow {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
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
	import com.dukascopy.connect.vo.ChatMessageVO;
	import com.dukascopy.connect.vo.ChatVO;
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

	public class EscrowOfferScreen extends EscrowDealScreen {
		
		private var button:BitmapButton;
		private var amount:Bitmap;
		private var price:Bitmap;
		private var balance:BalanceCalculation;
		private var status:OfferStatusClip;
		private var description:Bitmap;
		private var time:TimeClip;
		private var illustration:Bitmap;
		
		private var escrowOffer:EscrowMessageData;
		private var alertText:AlertTextArea;
		private var offerCreatedTime:Number;
		private var chatmate:String;
		private var command:OfferCommand;
		private var chat:ChatVO;
		private var message:ChatMessageVO;
		
		public function EscrowOfferScreen() { }
		
		override protected function createView():void {
			super.createView();
			
			illustrationSize = Config.FINGER_SIZE * 1.4;
			
			topColor = Color.BLACK;
			bottomColor = Style.color(Style.COLOR_BACKGROUND);
			
			createBuyButton();
			
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
		
		private function onButtonClick():void 
		{
			if (!EscrowScreenNavigation.isExpired(escrowOffer, offerCreatedTime))
			{
				command = OfferCommand.cancel;
			}
			
			close();
		}
		
		override public function onBack(e:Event = null):void {
			close();
		}
		
		private function createBuyButton():void 
		{
			button = new BitmapButton();
			button.setStandartButtonParams();
			button.tapCallback = onButtonClick;
			button.disposeBitmapOnDestroy = true;
			button.setDownScale(1);
			button.setOverlay(HitZoneType.BUTTON);
			addItem(button);
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
			if ("userName" in data && data.userName != null)
			{
				chatmate = data.userName;
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
			drawAlertBlock();
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
				if (escrowOffer.status == EscrowStatus.offer_created)
				{
					if (EscrowScreenNavigation.isExpired(escrowOffer, offerCreatedTime))
					{
						if (escrowOffer.direction == TradeDirection.buy)
						{
							texts.push(Lang.amount_unblocked);
							colors.push(Style.color(Style.COLOR_SUBTITLE));
							values.push(NumberFormat.formatAmount(escrowOffer.amount * escrowOffer.price * EscrowSettings.refundableFee + escrowOffer.amount * escrowOffer.price, escrowOffer.currency));
						}
					}
					else if (escrowOffer.direction == TradeDirection.buy)
					{
						texts.push(Lang.to_pay_for_crypto);
						texts.push(Lang.refundable_fee.replace("%@", (EscrowSettings.refundableFee*100)));
						texts.push(Lang.amount_blocked);
						
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
						texts.push(Lang.commission_crypto.replace("%@", (EscrowSettings.commission*100)));
						texts.push(Lang.amount_to_be_credited);
						
						colors.push(Style.color(Style.COLOR_SUBTITLE));
						colors.push(Style.color(Style.COLOR_SUBTITLE));
						colors.push(Color.WHITE);
						
						values.push(NumberFormat.formatAmount(escrowOffer.amount * escrowOffer.price, escrowOffer.currency));
						values.push(NumberFormat.formatAmount(escrowOffer.amount * escrowOffer.price * EscrowSettings.commission, escrowOffer.currency));
						values.push(NumberFormat.formatAmount(escrowOffer.amount * escrowOffer.price * EscrowSettings.refundableFee + escrowOffer.amount * escrowOffer.price, escrowOffer.currency));
					
					}
				}
				else if (escrowOffer.status == EscrowStatus.offer_cancelled)
				{
					if (escrowOffer.direction == TradeDirection.buy)
					{
						texts.push(Lang.amount_unblocked);
						colors.push(Style.color(Style.COLOR_SUBTITLE));
						values.push(NumberFormat.formatAmount(escrowOffer.amount * escrowOffer.price * EscrowSettings.refundableFee + escrowOffer.amount * escrowOffer.price, escrowOffer.currency));
					}
				}
				else if (escrowOffer.status == EscrowStatus.offer_rejected)
				{
					if (escrowOffer.direction == TradeDirection.buy)
					{
						texts.push(Lang.amount_unblocked);
						colors.push(Style.color(Style.COLOR_SUBTITLE));
						values.push(NumberFormat.formatAmount(escrowOffer.amount * escrowOffer.price * EscrowSettings.refundableFee + escrowOffer.amount * escrowOffer.price, escrowOffer.currency));
					}
				}
			}
			
			if (balance == null)
			{
				balance = new BalanceCalculation(texts, colors);
				addItem(balance);
			}
			
			balance.draw(getWidth() - contentPadding * 2, values);
		}
		
		private function drawTime():void 
		{
			if (escrowOffer != null && !EscrowScreenNavigation.isExpired(escrowOffer, offerCreatedTime))
			{
				time.draw(getWidth() - contentPadding * 2, EscrowSettings.offerMaxTime * 60 - ((new Date()).time / 1000 - offerCreatedTime));
			}
			else
			{
				removeItem(time);
			}
		}
		
		private function drawAlertBlock():void 
		{
			if (escrowOffer != null && !EscrowScreenNavigation.isExpired(escrowOffer, offerCreatedTime))
			{
				if (escrowOffer.direction == TradeDirection.sell)
				{
					if (alertText == null)
					{
						alertText = new AlertTextArea();
						addItem(alertText);
						alertText.draw(getWidth() - contentPadding * 2, Lang.escrow_send_obligation_penalty, Lang.escrow_send_obligation_penalty_url);
					}
					
				}
			}
			else
			{
				removeItem(alertText);
			}
		}
		
		private function drawStatus():void 
		{
			if (escrowOffer != null)
			{
				var text:String = "";
				var color:Number = Color.GREEN;
				if (escrowOffer.status == EscrowStatus.offer_created)
				{
					if (EscrowScreenNavigation.isExpired(escrowOffer, offerCreatedTime))
					{
						text = Lang.offer_expired;
						color = Color.GREY;
					}
					else if (escrowOffer.direction == TradeDirection.buy)
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
			var text:String = "";
			if (escrowOffer != null)
			{
				if (escrowOffer.status == EscrowStatus.offer_created)
				{
					if (EscrowScreenNavigation.isExpired(escrowOffer, offerCreatedTime))
					{
						if (escrowOffer.direction == TradeDirection.buy)
						{
							text = Lang.offer_buy_expired_details;
						}
						else if (escrowOffer.direction == TradeDirection.sell)
						{
							text = Lang.offer_sell_expired_details;
						}
					}
					else if (escrowOffer.direction == TradeDirection.buy)
					{
						text = Lang.buy_offer_description;
						text = text.replace("%@1", EscrowSettings.offerMaxTime);
						text = text.replace("%@2", chatmate);
					}
					else if (escrowOffer.direction == TradeDirection.sell)
					{
						text = Lang.sell_offer_description;
						text = text.replace("%@", EscrowSettings.dealMaxTime);
					}
				}
			}
			
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
			
			if (alertText != null)
			{
				alertText.x = contentPadding;
				alertText.y = position;
				position += alertText.height + contentPaddingV;
			}
			
			if (escrowOffer != null && !EscrowScreenNavigation.isExpired(escrowOffer, offerCreatedTime))
			{
				time.x = int(getWidth() * .5 - time.width * .5);
				time.y = position;
				position += time.height + contentPaddingV;
			}
			else
			{
				removeItem(time);
			}
			
			button.x = contentPadding;
			button.y = position;
			position += button.height + contentPaddingV;
		}
		
		private function drawControls():void
		{
			var text:String = "";
			if (escrowOffer != null)
			{
				if (EscrowScreenNavigation.isExpired(escrowOffer, offerCreatedTime))
				{
					text = Lang.textOk;
				}
				else
				{
					text = Lang.cancel_offer;
				}
			}
			
			var textSettings:TextFieldSettings = new TextFieldSettings(text, Style.color(Style.COLOR_TEXT), FontSize.BODY, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, Style.color(Style.COLOR_BACKGROUND), 1, -1, Style.color(Style.COLOR_BUTTON_OUTLINE), getButtonWidth(), Style.size(Style.BUTTON_PADDING), Style.size(Style.SIZE_BUTTON_CORNER));
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
			if (alertText != null)
			{
				alertText.activate();
			}
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed) {
				return;
			}
			
			button.deactivate();
			if (alertText != null)
			{
				alertText.deactivate();
			}
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
			if (alertText != null)
			{
				alertText.dispose();
				alertText = null;
			}
			if (alertText != null)
			{
				UI.destroy(alertText);
				alertText = null;
			}
			if (amount != null)
			{
				UI.destroy(amount);
				amount = null;
			}
		}
	}
}