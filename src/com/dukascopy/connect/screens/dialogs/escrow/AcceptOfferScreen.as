package com.dukascopy.connect.screens.dialogs.escrow {
	
	import assets.ListIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.GD;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.EscrowScreenData;
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
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.renderers.ListCryptoWallet;
	import com.dukascopy.connect.gui.list.renderers.ListPayWalletItem;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.managers.escrow.vo.CryptoWallet;
	import com.dukascopy.connect.managers.escrow.vo.EscrowInstrument;
	import com.dukascopy.connect.screens.dialogs.paymentDialogs.elements.InputField;
	import com.dukascopy.connect.screens.dialogs.x.base.bottom.ListSelectionPopup;
	import com.dukascopy.connect.screens.payments.card.TypeCurrency;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.paymentsManagerNew.PaymentsManagerNew;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.softKeyboard.SoftKeyboard;
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
		private var chat:ChatVO;
		private var cryptoWallets:Vector.<CryptoWallet>;
		private var cryptoWalletInput:InputField;
		private var blockchainTitle:Bitmap;
		private var blockchainAddress:Bitmap;
		private var blockchainBack:Sprite;
		private var currentCryptoWallet:String;
		private var instrument:EscrowInstrument;
		private var messageId:Number;
		private var openAccountTitle:Bitmap;
		private var openAccountButton:BitmapButton;
		private var selectCryptoButton:BitmapButton;
		private var instruments:Vector.<EscrowInstrument>;
		private var dataReady:Boolean;
		
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
				if (selectorAccont != null)
				{
					selectorAccont.setValue(account);
				}
				else
				{
					ApplicationErrors.add();
				}
			}
		}
		
		private function selectDefaultAccount():void 
		{
			var filteredAccounts:Array = getAccounts();
			
			var preselectedAccount:Object;
			if (filteredAccounts != null)
			{
				var preferredCurrency:String;
				if (instrument != null && instrument.price != null && instrument.price.length > 0)
				{
					preferredCurrency = instrument.price[0].name;
				}
				if (escrowOffer != null && escrowOffer.currency != null)
				{
					preferredCurrency = escrowOffer.currency;
				}
				
				if (preferredCurrency != null)
				{
					for (var i:int = 0; i < filteredAccounts.length; i++) 
					{
						if (filteredAccounts[i].CURRENCY == preferredCurrency)
						{
							preselectedAccount = filteredAccounts[i];
							break;
						}
					}
				}
			}
			
			if (preselectedAccount != null)
			{
				selectedFiatAccount = preselectedAccount;
				if (selectorAccont != null)
				{
					selectorAccont.setValue(selectedFiatAccount);
				}
				else
				{
					ApplicationErrors.add();
				}
			}
			else
			{
				if (escrowOffer != null && escrowOffer.direction == TradeDirection.sell)
				{
					
					if (selectorAccont != null)
					{
						removeItem(selectorAccont);
						selectorAccont.dispose();
						selectorAccont = null;
					}
					addOpenAccountItems(preferredCurrency);
				}
			}
		}
		
		private function addOpenAccountItems(preferredCurrency:String):void 
		{
			if (openAccountTitle == null)
			{
				openAccountTitle = new Bitmap();
				
				var text:String = Lang.need_account;
				if (preferredCurrency != null)
				{
					text = text.replace("%@", preferredCurrency);
				}
				else
				{
					ApplicationErrors.add();
				}
				
				openAccountTitle.bitmapData = TextUtils.createTextFieldData(text, getWidth() - contentPadding * 2, 10, true,
																		TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
																		FontSize.BODY, true, Style.color(Style.COLOR_TEXT),
																		Style.color(Style.COLOR_BACKGROUND));
			}
			
			addItem(openAccountTitle);
			
			if (openAccountButton == null)
			{
				openAccountButton = new BitmapButton();
				openAccountButton.setStandartButtonParams();
				openAccountButton.tapCallback = openAccountClick;
				openAccountButton.disposeBitmapOnDestroy = true;
				openAccountButton.setDownScale(1);
				openAccountButton.setOverlay(HitZoneType.BUTTON);
				addItem(openAccountButton);
				if (isActivated)
				{
					openAccountButton.activate();
				}
				
				var textSettings:TextFieldSettings = new TextFieldSettings(Lang.openAccount, Style.color(Style.COLOR_TEXT), FontSize.BODY, TextFormatAlign.CENTER);
				var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, Style.color(Style.COLOR_BACKGROUND), 1, -1, Style.color(Style.COLOR_BUTTON_OUTLINE), getButtonWidth(), Style.size(Style.BUTTON_PADDING), Style.size(Style.SIZE_BUTTON_CORNER));
				openAccountButton.setBitmapData(buttonBitmap, true);
			}
			
			addItem(openAccountButton);
			
			updateContentPositions();
		}
		
		private function openAccountClick():void 
		{
			MobileGui.openBankBot();
			close();
		}
		
		private function openWalletSelector():void 
		{
			if (selectorAccont != null)
			{
				selectorAccont.valid();
			}
			
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
			if (dataReady == false)
			{
				return;
			}
			if (escrowOffer.direction == TradeDirection.sell)
			{
				var selectedCryptoWallet:String;
				
				if (instrument.isLinked)
				{
					selectedCryptoWallet = instrument.wallet;
				}
				else
				{
					if (cryptoWalletInput.valueString != null && cryptoWalletInput.valueString != "")
					{
						selectedCryptoWallet = cryptoWalletInput.valueString;
						GD.S_CRYPTO_WALLET_ADD.invoke(instrument.code, selectedCryptoWallet);
					}
					else
					{
						cryptoWalletInput.invalid();
					}
				}
				
				if (selectedCryptoWallet != null)
				{
					escrowOffer.cryptoWallet = selectedCryptoWallet;
				}
				else
				{
					ToastMessage.display(Lang.escrow_provide_crypto_wallet);
					return;
				}
			}
			
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
			
			var screenData:EscrowScreenData = data as EscrowScreenData;
			offerCreatedTime = screenData.created;
			if (offerCreatedTime.toString().length > 11)
			{
				offerCreatedTime = offerCreatedTime / 1000;
			}
			escrowOffer = screenData.escrowOffer;
			chat = screenData.chat;
			messageId = screenData.messageId;
			instrument = screenData.instrument;
			instruments = screenData.instruments;
			
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
				
				selectorAccont = new DDAccountButton(openWalletSelector, Lang.TEXT_SELECT_ACCOUNT, false, -1, NaN, title);
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
			
		//	requestPrice();
		}
		
		private function getLocalCryptoWallet():String 
		{
			if (escrowOffer.instrument != null)
			{
				if (cryptoWallets != null)
				{
					for (var i:int = 0; i < cryptoWallets.length; i++) 
					{
						if (cryptoWallets[i].crypto == escrowOffer.instrument)
						{
							return cryptoWallets[i].wallet;
						}
					}
				}
			}
			else
			{
				ApplicationErrors.add();
			}
			
			return "";
		}
		
		private function localWalletExist():Boolean 
		{
			if (escrowOffer.instrument != null)
			{
				if (cryptoWallets != null)
				{
					for (var i:int = 0; i < cryptoWallets.length; i++) 
					{
						if (cryptoWallets[i].crypto == escrowOffer.instrument)
						{
							return true;
						}
					}
				}
			}
			else
			{
				ApplicationErrors.add();
			}
			
			return false;
		}
		
		private function createWalletInput():void 
		{
			if (escrowOffer != null && escrowOffer.direction == TradeDirection.sell)
			{
				if (blockchainTitle == null)
				{
					blockchainTitle = new Bitmap();
				}
				if (blockchainTitle.bitmapData != null)
				{
					blockchainTitle.bitmapData.dispose();
					blockchainTitle.bitmapData = null;
				}
				blockchainTitle.bitmapData = TextUtils.createTextFieldData(Lang.my_blockchain_address, getWidth() - contentPadding * 2, 10, true,
																		TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
																		FontSize.SUBHEAD, true, Style.color(Style.COLOR_SUBTITLE),
																		Style.color(Style.COLOR_SEPARATOR));
				addItem(blockchainTitle);
				
				var numWallets:int = 0;
				if (instrument.isLinked)
				{
					numWallets ++;
				}
				if (localWalletExist())
				{
					if (instrument != null)
					{
						if (cryptoWallets != null)
						{
							for (var i:int = 0; i < cryptoWallets.length; i++) 
							{
								if (cryptoWallets[i].crypto == instrument.code)
								{
									numWallets++;
								}
							}
						}
					}
					else
					{
						ApplicationErrors.add();
					}
				}
				
				if (numWallets > 1)
				{
					addSelectWalletButton();
				}
				
				if (cryptoWalletInput == null)
				{
					var tf:TextFormat = new TextFormat();
					tf.size = FontSize.BODY;
					tf.color = Style.color(Style.COLOR_TEXT);
					tf.font = Config.defaultFontName;
					
					cryptoWalletInput = new InputField( -1, Input.MODE_INPUT);
					cryptoWalletInput.onSelectedFunction = onInputSelected;
					cryptoWalletInput.onChangedFunction = onInputChange;
					cryptoWalletInput.setMaxChars(300);
					cryptoWalletInput.setPadding(0);
					cryptoWalletInput.updateTextFormat(tf);
				}
				
				var inputWidth:int = getWidth() - contentPadding * 2;
				if (numWallets > 1 && selectCryptoButton != null)
				{
					inputWidth -= int(selectCryptoButton.width + Config.FINGER_SIZE * .3);
				}
				
				cryptoWalletInput.drawString(inputWidth, null, "");
					
				if (instrument.isLinked || localWalletExist())
				{
					var cryptoWallet:String;
					if (instrument.isLinked)
					{
						cryptoWallet = instrument.wallet;
					}
					else
					{
						cryptoWallet = getLocalCryptoWallet();
						currentCryptoWallet = cryptoWallet;
					}
					
					cryptoWalletInput.valueString = cryptoWallet;
				}
				
				addItem(cryptoWalletInput);
				
				updateContentPositions();
				updateScroll();
			}
		}
		
		private function addSelectWalletButton():void 
		{
			if (selectCryptoButton == null)
			{
				selectCryptoButton = new BitmapButton();
				selectCryptoButton.setStandartButtonParams();
				selectCryptoButton.tapCallback = onSelectWalletClick;
				selectCryptoButton.disposeBitmapOnDestroy = true;
				selectCryptoButton.setDownScale(1);
				selectCryptoButton.setOverlay(HitZoneType.CIRCLE);
				selectCryptoButton.setOverlayPadding(int(Config.FINGER_SIZE * .2));
				selectCryptoButton.setOverflow(Config.FINGER_SIZE * .2, Config.FINGER_SIZE * .2, Config.FINGER_SIZE * .2, Config.FINGER_SIZE * .2);
				
				var icon:Sprite = new ListIcon();
				var iconSize:int = Config.FINGER_SIZE * .3;
				UI.scaleToFit(icon, iconSize, iconSize);
				UI.colorize(icon, Style.color(Style.ICON_COLOR));
				
				selectCryptoButton.setBitmapData(UI.getSnapshot(icon), true);
			}
			
			addItem(selectCryptoButton);
			
			if (isActivated)
			{
				selectCryptoButton.activate();
			}
		}
		
		private function onSelectWalletClick():void 
		{
			var items:Vector.<EscrowInstrument> = new Vector.<EscrowInstrument>();
			
			var instrument:EscrowInstrument;
			for (var i:int = 0; i < cryptoWallets.length; i++) 
			{
				instrument = getInstrumentByCode(cryptoWallets[i].crypto);
				items.push(new EscrowInstrument(instrument.name, cryptoWallets[i].wallet, 0, instrument.code, null));
			}
			DialogManager.showDialog(
						ListSelectionPopup,
						{
							items:items,
							title:Lang.select_crypto_wallet,
							renderer:ListCryptoWallet,
							callback:callBackSelectCryptoWallet
						}, ServiceScreenManager.TYPE_SCREEN
					);
		}
		
		private function callBackSelectCryptoWallet(instrument:EscrowInstrument):void
		{
			if (cryptoWalletInput != null)
			{
				cryptoWalletInput.valueString = instrument.wallet;
			}
		}
		
		private function getInstrumentByCode(crypto:String):EscrowInstrument 
		{
			if (instruments != null)
			{
				for (var i:int = 0; i < instruments.length; i++) 
				{
					if (instruments[i].code == crypto)
					{
						return instruments[i];
					}
				}
			}
			return null;
		}
		
		private function onInputSelected():void 
		{
			cryptoWalletInput.valid();
		}
		
		private function onInputChange(e:Event = null):void
		{
			if (cryptoWalletInput != null)
			{
				if (cryptoWalletInput.valueString == null || cryptoWalletInput.valueString == "")
				{
					cryptoWalletInput.invalid();
				}
				else
				{
					cryptoWalletInput.valid();
					cryptoWalletInput.updatePositions();
				}
			}
		}
		
		private function requestPrice():void 
		{
		//	percent_price
			PHP.escrow_requestPrice(onPriceReady, {ccy:TypeCurrency.EUR, crypto:TypeCurrency.DCO, price:1000, percent_price:5});
		}
		
		private function onPriceReady(respond:PHPRespond):void 
		{
			respond.dispose();
		}
		
		private function loadAccounts():void 
		{
			showPreloader();
			if (accounts == null)
			{
				accounts = new PaymentsAccountsProvider(onAccountsReady, true, onAccountsFail);
				if (accounts.ready)
				{
					onAccountsReady();
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
			
			GD.S_CRYPTO_WALLETS.add(onCryptoWallets);
			GD.S_CRYPTO_WALLET_REQUEST.invoke();
		}
		
		private function onCryptoWallets(cryptoWallets:Vector.<CryptoWallet>):void 
		{
			if (_isDisposed)
			{
				ApplicationErrors.add();
				return;
			}
			this.cryptoWallets = cryptoWallets;
			createWalletInput();
			updateContentPositions();
			onDataReady();
		}
		
		public function onDataReady():void
		{
			dataReady = true;
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
			if (selectorAccont != null)
			{
				selectorAccont.setSize(getWidth() - contentPadding * 2, Config.FINGER_SIZE * .8);
			}
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
					
					if (openAccountTitle != null)
					{
						openAccountTitle.x = contentPadding;
						openAccountTitle.y = position;
						position += openAccountTitle.height + contentPaddingV * 1;
					}
					
					if (openAccountButton != null)
					{
						openAccountButton.x = contentPadding;
						openAccountButton.y = position;
						position += openAccountButton.height + contentPaddingV * 1;
					}
					
					if (blockchainTitle != null)
					{
						blockchainTitle.x = contentPadding;
						blockchainTitle.y = position;
						position += blockchainTitle.height + contentPaddingV * .3;
					}
					
					if (blockchainBack != null)
					{
						blockchainBack.x = contentPadding;
						blockchainBack.y = position;
						blockchainAddress.x = contentPadding * 2;
						blockchainAddress.y = position + contentPadding;
						position += blockchainBack.height + contentPaddingV * 2;
					}
					if(cryptoWalletInput != null)
					{
						cryptoWalletInput.x = contentPadding;
						cryptoWalletInput.y = position;
						position += cryptoWalletInput.getFullHeight() + contentPaddingV * 2;
						
						if (selectCryptoButton != null)
						{
							selectCryptoButton.y = int(cryptoWalletInput.y + cryptoWalletInput.linePosition() - selectCryptoButton.height - Config.FINGER_SIZE * .1);
							selectCryptoButton.x = int(cryptoWalletInput.x + cryptoWalletInput.width + Config.FINGER_SIZE * .3);
						}
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
			
		//	selectorAccont.activate();
			acceptButton.activate();
			rejectButton.activate();
			terms.activate();
			alertText.activate();
			if (cryptoWalletInput != null)
			{
				cryptoWalletInput.activate();
			}
			if (openAccountButton != null)
			{
				openAccountButton.activate();
			}
			if (selectCryptoButton != null)
			{
				selectCryptoButton.activate();
			}
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed) {
				return;
			}
			
			if (selectorAccont != null)
			{
				selectorAccont.deactivate();
			}
			
			acceptButton.deactivate();
			rejectButton.deactivate();
			terms.deactivate();
			alertText.deactivate();
			if (cryptoWalletInput != null)
			{
				cryptoWalletInput.deactivate();
			}
			if (openAccountButton != null)
			{
				openAccountButton.deactivate();
			}
			if (selectCryptoButton != null)
			{
				selectCryptoButton.deactivate();
			}
		}
		
		override protected function onRemove():void 
		{
			if (command != null && "callback" in data && data.callback != null && data.callback is Function && (data.callback as Function).length == 4)
			{
				if (escrowOffer.direction == TradeDirection.sell)
				{
					escrowOffer.debit_account = selectedFiatAccount.ACCOUNT_NUMBER;
				}
				
				(data.callback as Function)(escrowOffer, messageId, chat, command);
				command = null;
				chat = null;
				escrowOffer = null;
			}
		}
		
		override public function dispose():void {
			super.dispose();
			
			GD.S_CRYPTO_WALLETS.remove(onCryptoWallets);
			
			instruments = null;
			
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
			if (openAccountTitle != null)
			{
				UI.destroy(openAccountTitle);
				openAccountTitle = null;
			}
			if (selectorAccont != null)
			{
				selectorAccont.dispose();
				selectorAccont = null;
			}
			if (blockchainTitle != null)
			{
				UI.destroy(blockchainTitle);
				blockchainTitle = null;
			}
			if (blockchainBack != null)
			{
				UI.destroy(blockchainBack);
				blockchainBack = null;
			}
			if (blockchainAddress != null)
			{
				UI.destroy(blockchainAddress);
				blockchainAddress = null;
			}
			if (cryptoWalletInput != null)
			{
				cryptoWalletInput.dispose();
				cryptoWalletInput = null;
			}
			if (openAccountButton != null)
			{
				openAccountButton.dispose();
				openAccountButton = null;
			}
			if (selectCryptoButton != null)
			{
				selectCryptoButton.dispose();
				selectCryptoButton = null;
			}
		}
	}
}