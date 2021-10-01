package com.dukascopy.connect.screens.dialogs.escrow {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.EscrowScreenData;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.data.escrow.EscrowMessageData;
	import com.dukascopy.connect.data.escrow.EscrowScreenNavigation;
	import com.dukascopy.connect.data.escrow.EscrowSettings;
	import com.dukascopy.connect.data.escrow.OfferCommand;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.screens.dialogs.paymentDialogs.elements.InputField;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.NumberFormat;
	import com.dukascopy.connect.utils.TextUtils;
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

	public class SendCryptoScreen extends EscrowDealScreen {
		
		private var acceptButton:BitmapButton;
		private var amount:Bitmap;
		private var price:Bitmap;
		private var balance:BalanceCalculation;
		private var status:OfferStatusClip;
		private var description:Bitmap;
		private var descriptionTransaction:Bitmap;
		private var time:TimeClip;
		private var illustration:Bitmap;
		
		private var escrowOffer:EscrowMessageData;
		private var alertText:AlertTextArea;
		private var offerCreatedTime:Number;
		private var command:OfferCommand;
		private var chat:ChatVO;
		private var transaction:InputField;
		private var transactionClip:TransactionClip;
		private var transactionId:String;
		private var messageId:Number;
		
		public function SendCryptoScreen() { }
		
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
			
			descriptionTransaction = new Bitmap();
			addItem(descriptionTransaction);
			
			alertText = new AlertTextArea();
			addItem(alertText);
			
			amount = new Bitmap();
			addItem(amount);
			
			price = new Bitmap();
			addItem(price);
			
			status = new OfferStatusClip();
			addItem(status);
			
			time = new TimeClip(onTimeFinish);
			addItem(time);
			
			var tf:TextFormat = new TextFormat();
			tf.size = FontSize.BODY;
			tf.color = Style.color(Style.COLOR_TEXT);
			tf.font = Config.defaultFontName;
			
			transaction = new InputField( -1, Input.MODE_INPUT);
			transaction.onSelectedFunction = onInputSelected;
			transaction.onChangedFunction = onInputChange;
			transaction.setMaxChars(100);
		//	transaction.restrict = "a-z A-z 0-9 ^[^] \\_,.";
			transaction.setPadding(0);
			transaction.updateTextFormat(tf);
			addItem(transaction);
			
			transactionClip = new TransactionClip();
			addItem(transactionClip);
		}
		
		private function onInputSelected():void 
		{
			transaction.valid();
		}
		
		private function onInputChange(e:Event = null):void
		{
			if (transaction != null)
			{
				if (transaction.valueString == null || transaction.valueString == "")
				{
					transaction.invalid();
				}
				else
				{
					transaction.valid();
					transaction.updatePositions();
				}
			}
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
			if (transaction.valueString == null || transaction.valueString == "")
			{
				transaction.invalid();
				ToastMessage.display(Lang.escrow_enter_transaction_id);
			}
			else
			{
				transactionId = transaction.valueString;
				command = OfferCommand.send_transaction_id;
				close();
			}
			
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
			
			var screenData:EscrowScreenData = data as EscrowScreenData;
			
			offerCreatedTime = screenData.created;
			escrowOffer = screenData.escrowOffer;
			chat = screenData.chat;
			messageId = screenData.messageId;
			
			super.initScreen(data);
		}
		
		override protected function drawContent():void 
		{
			drawAlert();
			drawAmount();
			drawPrice();
			drawIllustration();
			drawStatus();
			drawText();
			drawTextTransaction();
			drawTime();
			drawControls();
			createBalance();
			drawTransaction();
			drawTransactionClip();
		}
		
		private function drawTransactionClip():void 
		{
			transactionClip.draw(getWidth() - contentPadding * 2, Lang.buyers_wallet, escrowOffer.cryptoWallet);
		}
		
		private function drawTransaction():void 
		{
			transaction.drawString(getWidth() - contentPadding * 2, Lang.transaction_id, "");
		}
		
		private function drawAlert():void 
		{
			if (escrowOffer != null && !EscrowScreenNavigation.isExpired(escrowOffer, offerCreatedTime))
			{
				alertText.draw(getWidth() - contentPadding * 2, Lang.escrow_send_obligation_penalty, Lang.escrow_send_obligation_penalty_url);
			}
			else
			{
				//!TODO:;
				removeItem(alertText);
			}
		}
		
		private function createBalance():void 
		{
			var texts:Vector.<String> = new Vector.<String>();
			var values:Vector.<String> = new Vector.<String>();
			var colors:Vector.<Number> = new Vector.<Number>();
			
			if (escrowOffer != null)
			{
				if (EscrowScreenNavigation.isExpired(escrowOffer, offerCreatedTime))
				{
					//!TODO:;
				}
				else
				{
					//!TODO:;
					
					texts.push(Lang.amount_of_transaction);
					texts.push(Lang.commission_crypto.replace("%@", (EscrowSettings.getCommission(escrowOffer.instrument) * 100)));
					texts.push(Lang.amount_to_be_credited);
					
					colors.push(Style.color(Style.COLOR_SUBTITLE));
					colors.push(Style.color(Style.COLOR_SUBTITLE));
					colors.push(Color.WHITE);
					
					values.push(NumberFormat.formatAmount(escrowOffer.amount * escrowOffer.price, escrowOffer.currency));
					values.push(NumberFormat.formatAmount(escrowOffer.amount * escrowOffer.price * EscrowSettings.getCommission(escrowOffer.instrument), escrowOffer.currency));
					values.push(NumberFormat.formatAmount(- escrowOffer.amount * escrowOffer.price * EscrowSettings.getCommission(escrowOffer.instrument) + escrowOffer.amount * escrowOffer.price, escrowOffer.currency));
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
			if (escrowOffer != null)
			{
				var text:String = Lang.offer_accepted_by_buyer;
				var color:Number = Color.RED;
				
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
			var text:String = Lang.send_crypto;
			text = text.replace("%@1", EscrowSettings.dealMaxTime);
			if (escrowOffer != null)
			{
				text = text.replace("%@2", NumberFormat.formatAmount(escrowOffer.amount, escrowOffer.instrument));
			}
			else
			{
				ApplicationErrors.add();
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
		
		private function drawTextTransaction():void 
		{
			var text:String = Lang.type_transaction_id;
			
			if (descriptionTransaction.bitmapData != null)
			{
				descriptionTransaction.bitmapData.dispose();
				descriptionTransaction.bitmapData = null;
			}
			descriptionTransaction.bitmapData = TextUtils.createTextFieldData(text, getWidth() - contentPadding * 2, 10, true,
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
			
			transactionClip.x = contentPadding;
			transactionClip.y = position;
			position += transactionClip.height + contentPaddingV * 1.5;
			
			descriptionTransaction.x = contentPadding;
			descriptionTransaction.y = position;
			position += descriptionTransaction.height + contentPaddingV * 1.5;
			
			transaction.x = contentPadding;
			transaction.y = position;
			position += transaction.getFullHeight() + contentPaddingV * 1;
			
			alertText.x = contentPadding;
			alertText.y = position;
			position += alertText.height + contentPaddingV * 1.5;
			
			if (time != null && time.parent != null)
			{
				time.x = int(getWidth() * .5 - time.width * .5);
				time.y = position;
				position += time.height + contentPaddingV;
			}
			
			acceptButton.x = contentPadding;
			acceptButton.y = position;
			position += acceptButton.height + contentPaddingV;
		}
		
		private function drawControls():void
		{
			var textSettings:TextFieldSettings;
			var buttonBitmap:ImageBitmapData;
			
			if (EscrowScreenNavigation.isExpired(escrowOffer, offerCreatedTime))
			{
				textSettings = new TextFieldSettings(Lang.textOk, Style.color(Style.COLOR_TEXT), FontSize.BODY, TextFormatAlign.CENTER);
				buttonBitmap = TextUtils.createbutton(textSettings, Style.color(Style.COLOR_BACKGROUND), 1, -1, Style.color(Style.COLOR_BUTTON_OUTLINE), getButtonWidth(), Style.size(Style.BUTTON_PADDING), Style.size(Style.SIZE_BUTTON_CORNER));
				acceptButton.setBitmapData(buttonBitmap, true);
			}
			else
			{
				textSettings = new TextFieldSettings(Lang.i_have_sent_ctypto, Style.color(Style.COLOR_TEXT), FontSize.BODY, TextFormatAlign.CENTER);
				buttonBitmap = TextUtils.createbutton(textSettings, Style.color(Style.COLOR_BACKGROUND), 1, -1, Style.color(Style.COLOR_BUTTON_OUTLINE), getButtonWidth(), Style.size(Style.BUTTON_PADDING), Style.size(Style.SIZE_BUTTON_CORNER));
				acceptButton.setBitmapData(buttonBitmap, true);
			}
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
			
			transaction.activate();
			acceptButton.activate();
			alertText.activate();
			transactionClip.activate();
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed) {
				return;
			}
			
			transaction.deactivate();
			acceptButton.deactivate();
			alertText.deactivate();
			transactionClip.deactivate();
		}
		
		override protected function onRemove():void 
		{
			if (command != null && "callback" in data && data.callback != null && data.callback is Function && (data.callback as Function).length == 4)
			{
				escrowOffer.transactionId = transactionId;
				(data.callback as Function)(escrowOffer, messageId, chat, command);
				command = null;
				chat = null;
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
			if (descriptionTransaction != null)
			{
				UI.destroy(descriptionTransaction);
				descriptionTransaction = null;
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
			if (amount != null)
			{
				UI.destroy(amount);
				amount = null;
			}
			if (transactionClip != null)
			{
				transactionClip.dispose();
				transactionClip = null;
			}
		}
	}
}