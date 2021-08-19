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
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.renderers.ListPayWalletItem;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.screens.dialogs.x.base.bottom.ListSelectionPopup;
	import com.dukascopy.connect.screens.payments.card.TypeCurrency;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.paymentsManagerNew.PaymentsManagerNew;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.softKeyboard.SoftKeyboard;
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
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin.
	 */

	public class AcceptOfferScreen extends EscrowDealScreen {
		
		private var acceptButton:BitmapButton;
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
		private var terms:TermsChecker;
		private var rejectButton:BitmapButton;
		private var selectorAccont:DDAccountButton;
		private var accounts:PaymentsAccountsProvider;
		private var selectedFiatAccount:Object;
		private var command:OfferCommand;
		private var message:ChatMessageVO;
		private var chat:ChatVO;
		
		public function AcceptOfferScreen() { }
		
		override protected function createView():void {
			super.createView();
			
			illustrationSize = Config.FINGER_SIZE * 1.4;
			
			topColor = Color.BLACK;
			bottomColor = Style.color(Style.COLOR_BACKGROUND);
			
			createAcceptButton();
			createRejectButton();
			
			illustration = new Bitmap();
			container.addChild(illustration);
			
			description = new Bitmap();
			addItem(description);
			
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
			
			terms = new TermsChecker(onTermsChecker);
			addItem(terms);
		}
		
		private function onTermsChecker():void 
		{
			
		}
		
		private function onTimeFinish():void 
		{
			if (isDisposed)
			{
				return;
			}
			
			recreateLayout();
		}
		
		private function getAccounts():Array 
		{
			//!TODO: any account or only prices?;
			if (accounts != null)
			{
				var accountsArray:Array = accounts.moneyAccounts;
				accountsArray = PaymentsManagerNew.filterEmptyWallets(accountsArray);
				return accountsArray;
			}
			else
			{
				ApplicationErrors.add();
			}
			return null;
		}
		
		private function onWalletFiatSelect(account:Object, cleanCurrent:Boolean = false):void
		{
			if (account != null)
			{
				selectedFiatAccount = account;
				selectorAccont.setValue(account);
			}
		}
		
		private function selectDefaultAccount():void 
		{
			var filteredAccounts:Array = getAccounts();
			
			var preselectedAccount:Object;
			if (filteredAccounts != null)
			{
				var preferredCurrency:String = TypeCurrency.USD;
				if (escrowOffer != null && escrowOffer.currency != null)
				{
					preferredCurrency = escrowOffer.currency;
				}
				for (var i:int = 0; i < filteredAccounts.length; i++) 
				{
					if (filteredAccounts.CURRENCY == preferredCurrency)
					{
						preselectedAccount = filteredAccounts[i];
						break;
					}
				}
				if (preselectedAccount == null && filteredAccounts.length > 0)
				{
					preselectedAccount = filteredAccounts[0];
				}
			}
			
			//!TODO:;
			
			if (preselectedAccount != null)
			{
				selectedFiatAccount = preselectedAccount;
				
				selectorAccont.setValue(selectedFiatAccount);
			}
		}
		
		private function openWalletSelector():void 
		{
			selectorAccont.valid();
			
			//!TODO: need?
			SoftKeyboard.closeKeyboard();
			
			if (accounts.ready)
			{
				var wallets:Array = accounts.moneyAccounts;
				wallets = PaymentsManagerNew.filterEmptyWallets(wallets);
				if (wallets != null && wallets.length > 0)
				{
					DialogManager.showDialog(
						ListSelectionPopup,
						{
							items:wallets,
							title:Lang.TEXT_SELECT_ACCOUNT,
							renderer:ListPayWalletItem,
							callback:onWalletFiatSelect
						}, ServiceScreenManager.TYPE_SCREEN
					);
					
				//	DialogManager.showDialog(ScreenPayDialog, {callback: onWalletFiatSelect, data: wallets, itemClass: ListPayWalletItem, label: Lang.TEXT_SELECT_ACCOUNT});
				}
			}
			else
			{
				accounts.getData();
			}
		}
		
		private function onAcceptClick():void 
		{
			if (terms != null)
			{
				if (terms.isSelected())
				{
					if (escrowOffer != null && escrowOffer.direction == TradeDirection.sell && selectedFiatAccount == null)
					{
						ToastMessage.display(Lang.please_select_debit_account);
					}
					else
					{
						if (!EscrowScreenNavigation.isExpired(escrowOffer, offerCreatedTime))
						{
							command = OfferCommand.accept;
						}
						close();
					}
				}
				else
				{
					ToastMessage.display(Lang.need_accept_terms);
				}
			}
			else
			{
				ApplicationErrors.add();
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
		
		private function createRejectButton():void 
		{
			rejectButton = new BitmapButton();
			rejectButton.setStandartButtonParams();
			rejectButton.tapCallback = onRejectClick;
			rejectButton.disposeBitmapOnDestroy = true;
			rejectButton.setDownScale(1);
			rejectButton.setOverlay(HitZoneType.BUTTON);
			addItem(rejectButton);
		}
		
		private function onRejectClick():void 
		{
			if (!EscrowScreenNavigation.isExpired(escrowOffer, offerCreatedTime))
			{
				command = OfferCommand.reject;
			}
			close();
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
			
			if (escrowOffer != null)
			{
				var title:String;
				if (escrowOffer.direction == TradeDirection.buy)
				{
					title = Lang.credit_to;
				}
				else if (escrowOffer.direction == TradeDirection.sell)
				{
					title = Lang.pay_from_account;
				}
				selectorAccont = new DDAccountButton(openWalletSelector, Lang.TEXT_SELECT_ACCOUNT, true, -1, NaN, title);
				addItem(selectorAccont);
			}
			
			super.initScreen(data);
			
			if (escrowOffer != null && escrowOffer.direction == TradeDirection.sell)
			{
				loadAccounts();
			}
			else
			{
				removeItem(selectorAccont);
				onDataReady();
				recreateLayout();
			}
		}
		
		private function loadAccounts():void 
		{
			showPreloader();
			if (accounts == null)
			{
				accounts = new PaymentsAccountsProvider(onAccountsReady, true, onAccountsFail);
				if (accounts.ready)
				{
					onDataReady();
				}
				else
				{
					accounts.getData();
				}
			}
		}
		
		private function onAccountsFail():void 
		{
			if (_isDisposed)
			{
				return;
			}
			hidePreloader();
			ToastMessage.display(Lang.needToByAuthorized);
		}
		
		private function onAccountsReady():void 
		{
			if (_isDisposed)
			{
				return;
			}
			hidePreloader();
			onDataReady();
		}
		
		public function onDataReady():void
		{
			if (isDisposed)
			{
				return;
			}
			hidePreloader();
			
			if (escrowOffer != null && !EscrowScreenNavigation.isExpired(escrowOffer, offerCreatedTime))
			{
				if (escrowOffer.direction == TradeDirection.sell)
				{
					selectDefaultAccount();
				}
			}
			else
			{
				removeItem(selectorAccont);
				recreateLayout();
			}
		}
		
		override protected function drawContent():void 
		{
			drawTerms();
			drawAlert();
			drawAmount();
			drawPrice();
			drawIllustration();
			drawStatus();
			drawText();
			drawTime();
			drawControls();
			createBalance();
			drawAccount();
		}
		
		private function drawAccount():void 
		{
			selectorAccont.setSize(getWidth() - contentPadding * 2, Config.FINGER_SIZE * .8);
		}
		
		private function drawAlert():void 
		{
			if (isAvaliable(escrowOffer))
			{
				if (escrowOffer.direction == TradeDirection.buy)
				{
					alertText.draw(getWidth() - contentPadding * 2, Lang.escrow_send_obligation_penalty, Lang.escrow_send_obligation_penalty_url);
				}
				else
				{
					removeItem(alertText);
				}
			}
			else
			{
				removeItem(alertText);
			}
		}
		
		private function drawTerms():void 
		{
			if (isAvaliable(escrowOffer))
			{
				terms.draw(getWidth() - contentPadding * 2, Lang.escrow_terms_accept, Lang.escrow_terms_link);
			}
			else
			{
				removeItem(terms);
			}
		}
		
		private function isAvaliable(offer:EscrowMessageData):Boolean 
		{
			return offer != null && !EscrowScreenNavigation.isExpired(offer, offerCreatedTime) && offer.status == EscrowStatus.offer_created;
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
						texts.push(Lang.amount_of_transaction);
						texts.push(Lang.commission_crypto.replace("%@", (EscrowSettings.getCommission(escrowOffer.instrument) * 100)));
						texts.push(Lang.amount_to_be_credited);
						
						colors.push(Style.color(Style.COLOR_SUBTITLE));
						colors.push(Style.color(Style.COLOR_SUBTITLE));
						colors.push(Color.WHITE);
						
						values.push(NumberFormat.formatAmount(escrowOffer.amount * escrowOffer.price, escrowOffer.currency));
						values.push(NumberFormat.formatAmount(escrowOffer.amount * escrowOffer.price * EscrowSettings.getCommission(escrowOffer.instrument), escrowOffer.currency));
						values.push(NumberFormat.formatAmount(-escrowOffer.amount * escrowOffer.price * EscrowSettings.getCommission(escrowOffer.instrument) + escrowOffer.amount * escrowOffer.price, escrowOffer.currency));
					}
					else if (escrowOffer.direction == TradeDirection.sell)
					{
						texts.push(Lang.to_pay_for_crypto);
						texts.push(Lang.refundable_fee.replace("%@", (EscrowSettings.refundableFee * 100)));
						texts.push(Lang.amount_to_be_debited);
						
						colors.push(Style.color(Style.COLOR_SUBTITLE));
						colors.push(Style.color(Style.COLOR_SUBTITLE));
						colors.push(Color.WHITE);
						
						values.push(NumberFormat.formatAmount(escrowOffer.amount * escrowOffer.price, escrowOffer.currency));
						values.push(NumberFormat.formatAmount(escrowOffer.amount * escrowOffer.price * EscrowSettings.refundableFee, escrowOffer.currency));
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
				balance = new BalanceCalculation();
				addItem(balance);
			}
			balance.drawTexts(texts, colors);
			balance.draw(getWidth() - contentPadding * 2, values);
		}
		
		private function drawTime():void 
		{
			if (isAvaliable(escrowOffer))
			{
				time.draw(getWidth() - contentPadding * 2, EscrowSettings.offerMaxTime * 60 - ((new Date()).time / 1000 - offerCreatedTime));
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
						text = Lang.escrow_sell_offer;
						color = Color.RED;
					}
					else if (escrowOffer.direction == TradeDirection.sell)
					{
						text = Lang.escrow_buy_offer;
						color = Color.GREEN;
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
						text = Lang.sell_offer_accept_description;
						text = text.replace("%@", EscrowSettings.dealMaxTime);
					}
					else if (escrowOffer.direction == TradeDirection.sell)
					{
						text = Lang.buy_offer_accept_description;
						text = text.replace("%@", EscrowSettings.offerMaxTime);	
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
			
			if (escrowOffer != null)
			{
				if (escrowOffer.direction == TradeDirection.sell)
				{
					description.x = contentPadding;
					description.y = position;
					position += description.height + contentPaddingV * 1.5;
					
					if (selectorAccont != null && selectorAccont.parent != null)
					{
						selectorAccont.x = contentPadding;
						selectorAccont.y = position;
						position += selectorAccont.height + contentPaddingV * 1;
					}
					
					if (terms != null && terms.parent != null)
					{
						terms.x = contentPadding;
						terms.y = position;
						position += terms.height + contentPaddingV * 1.5;
					}
				}
				else if (escrowOffer.direction == TradeDirection.buy)
				{
					/*selectorAccont.x = contentPadding;
					selectorAccont.y = position;
					position += selectorAccont.height + contentPaddingV * 1.5;*/
					
					description.x = contentPadding;
					description.y = position;
					position += description.height + contentPaddingV * 1.5;
					
					if (alertText != null && alertText.parent != null)
					{
						alertText.x = contentPadding;
						alertText.y = position;
						position += alertText.height + contentPaddingV * 1.5;
					}
					
					if (terms != null && terms.parent != null)
					{
						terms.x = contentPadding;
						terms.y = position;
						position += terms.height + contentPaddingV * 1.5;
					}
				}
			}
			else
			{
				ApplicationErrors.add();
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
			
			if (acceptButton != null && acceptButton.parent != null)
			{
				acceptButton.x = contentPadding;
				acceptButton.y = position;
				position += acceptButton.height + contentPaddingV;
			}
			
			rejectButton.x = contentPadding;
			rejectButton.y = position;
			position += rejectButton.height + contentPaddingV;
		}
		
		private function drawControls():void
		{
			var textSettings:TextFieldSettings;
			var buttonBitmap:ImageBitmapData;
			
			if (EscrowScreenNavigation.isExpired(escrowOffer, offerCreatedTime))
			{
				textSettings = new TextFieldSettings(Lang.textOk, Style.color(Style.COLOR_TEXT), FontSize.BODY, TextFormatAlign.CENTER);
				buttonBitmap = TextUtils.createbutton(textSettings, Style.color(Style.COLOR_BACKGROUND), 1, -1, Style.color(Style.COLOR_BUTTON_OUTLINE), getButtonWidth(), Style.size(Style.BUTTON_PADDING), Style.size(Style.SIZE_BUTTON_CORNER));
				rejectButton.setBitmapData(buttonBitmap, true);
				
				removeItem(acceptButton);
			}
			else
			{
				textSettings = new TextFieldSettings(Lang.accept_offer, Style.color(Style.COLOR_BACKGROUND), FontSize.BODY, TextFormatAlign.CENTER);
				buttonBitmap = TextUtils.createbutton(textSettings, Style.color(Style.COLOR_BUTTON_ACCENT), 1, -1, NaN, getButtonWidth(), Style.size(Style.BUTTON_PADDING), Style.size(Style.SIZE_BUTTON_CORNER));
				acceptButton.setBitmapData(buttonBitmap, true);
				
				textSettings = new TextFieldSettings(Lang.reject_offer, Style.color(Style.COLOR_TEXT), FontSize.BODY, TextFormatAlign.CENTER);
				buttonBitmap = TextUtils.createbutton(textSettings, Style.color(Style.COLOR_BACKGROUND), 1, -1, Style.color(Style.COLOR_BUTTON_OUTLINE), getButtonWidth(), Style.size(Style.BUTTON_PADDING), Style.size(Style.SIZE_BUTTON_CORNER));
				rejectButton.setBitmapData(buttonBitmap, true);
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
			
			selectorAccont.activate();
			acceptButton.activate();
			rejectButton.activate();
			terms.activate();
			alertText.activate();
			
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed) {
				return;
			}
			
			selectorAccont.deactivate();
			acceptButton.deactivate();
			rejectButton.deactivate();
			terms.deactivate();
			alertText.deactivate();
		}
		
		override protected function onRemove():void 
		{
			if (command != null && "callback" in data && data.callback != null && data.callback is Function && (data.callback as Function).length == 4)
			{
				if (escrowOffer.direction == TradeDirection.sell)
				{
					escrowOffer.debit_account = selectedFiatAccount.ACCOUNT_NUMBER;
				}
				
				(data.callback as Function)(escrowOffer, message, chat, command);
				command = null;
				chat = null;
				message = null;
				escrowOffer = null;
			}
		}
		
		override public function dispose():void {
			super.dispose();
			
			if (accounts != null)
			{
				accounts.dispose();
				accounts = null;
			}
			if (terms != null)
			{
				terms.dispose();
				terms = null;
			}
			if (acceptButton != null)
			{
				acceptButton.dispose();
				acceptButton = null;
			}
			if (rejectButton != null)
			{
				rejectButton.dispose();
				rejectButton = null;
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
			if (amount != null)
			{
				UI.destroy(amount);
				amount = null;
			}
			if (selectorAccont != null)
			{
				selectorAccont.dispose();
				selectorAccont = null;
			}
		}
	}
}