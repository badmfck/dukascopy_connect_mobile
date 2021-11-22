package com.dukascopy.connect.screens.dialogs.escrow {
	
	import assets.ListIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.GD;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.SelectorItemData;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.data.coinMarketplace.PaymentsAccountsProvider;
	import com.dukascopy.connect.data.escrow.EscrowDealData;
	import com.dukascopy.connect.data.escrow.EscrowSettings;
	import com.dukascopy.connect.data.escrow.OfferCommand;
	import com.dukascopy.connect.data.escrow.TradeDirection;
	import com.dukascopy.connect.data.screenAction.customActions.TestCreateOfferAction;
	import com.dukascopy.connect.gui.button.DDAccountButton;
	import com.dukascopy.connect.gui.button.DDFieldButton;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.components.radio.RadioGroup;
	import com.dukascopy.connect.gui.components.radio.RadioItem;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.renderers.ListCryptoWallet;
	import com.dukascopy.connect.gui.list.renderers.ListPayCurrency;
	import com.dukascopy.connect.gui.list.renderers.ListPayWalletItem;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.managers.escrow.vo.CryptoWallet;
	import com.dukascopy.connect.managers.escrow.vo.EscrowInstrument;
	import com.dukascopy.connect.managers.escrow.vo.EscrowPrice;
	import com.dukascopy.connect.screens.dialogs.paymentDialogs.elements.InputField;
	import com.dukascopy.connect.screens.dialogs.x.base.bottom.ListSelectionPopup;
	import com.dukascopy.connect.screens.dialogs.x.base.bottom.ScrollAnimatedTitlePopup;
	import com.dukascopy.connect.screens.payments.card.TypeCurrency;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.paymentsManagerNew.PaymentsManagerNew;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.softKeyboard.SoftKeyboard;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.NumberFormat;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import com.dukascopy.langs.LangManager;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin.
	 */

	public class CreateEscrowScreen extends ScrollAnimatedTitlePopup {
		
		private const STATE_START:String = "STATE_START";
		private const STATE_REGISTER:String = "STATE_REGISTER";
		private const STATE_FINISH:String = "STATE_FINISH";
		
		private var inputAmount:InputField;
		private var inputPrice:InputField;
		
		private var nextButton:BitmapButton;
		
		private var needCallback:Boolean;
		
		private var selectorInstrument:DDFieldButton;
		private var selectedCrypto:EscrowInstrument;
		private var radio:RadioGroup;
		private var radioSelection:Vector.<SelectorItemData>;
		private var registerBlock:Sprite;
		private var registerDescriprtion:Bitmap;
		private var registerButton:BitmapButton;
		
		private var state:String = STATE_START;
		private var registerDescriptionClip:Sprite;
		private var priceSelector:PriceSelector;
		private var controlPriceSelected:Sprite;
		private var selectedDirection:TradeDirection;
		private var balance:BalanceCalculation;
		private var selectedPrice:Number;
		private var dataLoaded:Boolean;
		private var instruments:Vector.<EscrowInstrument>;
		private var currencySign:String;
		private var selectorAccont:DDAccountButton;
		private var selectedFiatAccount:Object;
		private var sendButton:BitmapButton;
		private var backButton:BitmapButton;
		private var accounts:PaymentsAccountsProvider;
		private var blockchainTitle:Bitmap;
		private var blockchainBack:Sprite;
		private var blockchainAddress:Bitmap;
		private var terms:TermsChecker;
		private var offerData:EscrowDealData;
		private var selectorCurrency:DDFieldButton;
		private var priceSummary:PriceClip;
		private var alert:AlertTextArea;
		private var lockInstrumentSelector:Boolean;
		private var checkPaymentsAction:TestCreateOfferAction;
		private var command:OfferCommand;
		private var selectorWallet:DDFieldButton;
		private var cryptoWallets:Vector.<CryptoWallet>;
		private var currentCryptoWallet:String;
		private var cryptoWalletInput:InputField;
		private var selectCryptoButton:BitmapButton;
		private var openAccountTitle:Bitmap;
		private var openAccountButton:BitmapButton;
		private var selectedPriceObject:EscrowPrice;
		
		public function CreateEscrowScreen() { }
		
		override protected function createView():void {
			super.createView();
			
			createInputAmount();
			createInputPrice();
			createInstrumentSelector();
			createRadio();
			createPriceSelector();
		}
		
		private function createAccountSelector():void 
		{
			selectorAccont = new DDAccountButton(openWalletSelector, Lang.TEXT_SELECT_ACCOUNT, false, -1, NaN, Lang.escrow_debit_from_account);
			addItem(selectorAccont);
		}
		
		private function createBalance():void 
		{
			balance = new BalanceCalculation();
			addItem(balance);
			updateBalanceTexts();
		}
		
		private function updateBalanceTexts():void 
		{
			if (selectedCrypto != null)
			{
				var balanceTexts:Vector.<String> = new Vector.<String>();
				var colors:Vector.<Number> = new Vector.<Number>();
				if (selectedDirection == TradeDirection.buy)
				{
					balanceTexts.push(Lang.to_pay_for_crypto);
					balanceTexts.push(Lang.refundable_fee.replace("%@", (EscrowSettings.refundableFee * 100)));
					balanceTexts.push(Lang.amount_to_be_debited);
					
					colors.push(Style.color(Style.COLOR_SUBTITLE));
					colors.push(Style.color(Style.COLOR_SUBTITLE));
					colors.push(Color.RED);
				}
				else
				{
					balanceTexts.push(Lang.to_get_for_crypto);
					balanceTexts.push(Lang.commission_crypto.replace("%@", (EscrowSettings.getCommission(selectedCrypto.code) * 100)));
					balanceTexts.push(Lang.amount_to_be_credited);
					
					colors.push(Style.color(Style.COLOR_SUBTITLE));
					colors.push(Style.color(Style.COLOR_SUBTITLE));
					colors.push(Color.GREEN);
				}
				balance.drawTexts(balanceTexts, colors);
			}
		}
		
		private function createPriceSelector():void 
		{
			priceSelector = new PriceSelector(onPriceChange);
			priceSelector.disableCurrencyChange();
		}
		
		private function onPriceChange(value:Number):void 
		{
			setPrice(value);
		}
		
		private function setPrice(value:Number):void 
		{
			selectedPrice = value;
			if (isNaN(selectedPrice))
			{
				selectedPrice = 0;
			}
			
			updateBalance();
		}
		
		private function updateBalance():void 
		{
			if (selectedCrypto != null)
			{
				updateBalanceTexts();
				
				var values:Vector.<String> = new Vector.<String>();
				var currency:String = getCurrency();
				
				
				var amount:Number = getAmount();
				var targetPrice:Number = 0;
				if (!isNaN(selectedPrice))
				{
					targetPrice = selectedPrice;
				}
				if (selectedDirection == TradeDirection.buy)
				{
					values.push(NumberFormat.formatAmount((amount * targetPrice), currency));
					values.push(NumberFormat.formatAmount((amount * targetPrice * EscrowSettings.refundableFee), currency));
					values.push(NumberFormat.formatAmount((amount * targetPrice * EscrowSettings.refundableFee + amount * targetPrice), currency));
				}
				else
				{
					values.push(NumberFormat.formatAmount((amount * targetPrice), currency));
					values.push(NumberFormat.formatAmount((amount * targetPrice * EscrowSettings.getCommission(selectedCrypto.code)), currency));
					values.push(NumberFormat.formatAmount((amount * targetPrice - amount * targetPrice * EscrowSettings.getCommission(selectedCrypto.code)), currency));
				}
				
				balance.draw(_width, values);
				
				updatePositions();
				updateScroll();
			}
		}
		
		private function getCurrency():String 
		{
			var result:String = "";
			if (currencySign != null)
			{
				if (currencySign == TypeCurrency.EUR)
				{
					result = "€";
				}
				else if (Lang[currencySign] != null && Lang[currencySign] != "")
				{
					result = Lang[currencySign];
				}
				else
				{
					result = currencySign;
				}
			}
			return result;
		}
		
		private function getAmount():Number
		{
			if (!isNaN(inputAmount.value))
			{
				return inputAmount.value;
			}
			return 0;
		}
		
		
		private function createRegisterBlockchainClips():void 
		{
			if (registerBlock == null)
			{
				registerBlock = new Sprite();
				
				registerDescriptionClip = new Sprite();
				registerBlock.addChild(registerDescriptionClip);
				
				registerDescriprtion = new Bitmap();
				registerDescriptionClip.addChild(registerDescriprtion);
				
				registerButton = new BitmapButton();
				registerButton.setStandartButtonParams();
				registerButton.tapCallback = onRegisterClick;
				registerButton.disposeBitmapOnDestroy = true;
				registerButton.setDownScale(1);
				registerButton.setOverlay(HitZoneType.BUTTON);
				registerBlock.addChild(registerButton);
			}
			container.addChild(registerBlock);
		}
		
		private function onRegisterClick():void 
		{
			offerData = new EscrowDealData();
			offerData.instrument = selectedCrypto.code;
			offerData.currency = currencySign;
			needCallback = true;
			command = OfferCommand.register_blockchain;
			close();
		}
		
		private function createRadio():void 
		{
			radio = new RadioGroup(onRadioSelection);
			addItem(radio);
		}
		
		private function onRadioSelection(value:SelectorItemData):void 
		{
			if (value != null && value.data != null && value.data is Function)
			{
				(value.data as Function)();
			}
		}
		
		private function createInstrumentSelector():void 
		{
			selectorInstrument = new DDFieldButton(selectInstrumentTap, "", true, NaN, Lang.crypto);
			addItem(selectorInstrument);
		}
		
		private function createCurrencySelector():void 
		{
			selectorCurrency = new DDFieldButton(selectCurrencyTap, "", false, NaN, null, FontSize.AMOUNT);
			addItem(selectorCurrency);
		}
		
		private function callBackSelectCurrency(currency:String):void
		{
			if (currency != null)
			{
				currencySign = currency;
				selectorCurrency.setValue(currencySign);
				updatePrice();
				
				priceSelector.draw(_width - contentPadding * 2, -5, 5, 0, selectedPrice, getCurrency());
			}
		}
		
		private function selectCurrencyTap():void 
		{
			if (selectedCrypto != null && selectedCrypto.price != null && selectedCrypto.price.length > 0)
			{
				var currencies:Array = new Array();
				for (var i:int = 0; i < selectedCrypto.price.length; i++) 
				{
					currencies.push(selectedCrypto.price[i].name);
				}
				DialogManager.showDialog(
						ListSelectionPopup,
						{
							items:currencies,
							title:Lang.selectCurrency,
							renderer:ListPayCurrency,
							callback:callBackSelectCurrency
						}, ServiceScreenManager.TYPE_SCREEN
					);
			}
			else
			{
				ApplicationErrors.add();
			}
		}
		
		private function selectInstrumentTap():void 
		{
			selectorInstrument.valid();
			if (!lockInstrumentSelector)
			{
				if (instruments != null && instruments.length > 0)
				{
					DialogManager.showDialog(
						ListSelectionPopup,
						{
							items:instruments,
							title:Lang.selectCurrency,
							renderer:ListCryptoWallet,
							callback:onCurrencySelected
						},
						DialogManager.TYPE_SCREEN
					);
				}
				else
				{
					loadInstruments();
				}
			}
		}
		
		private function onCurrencySelected(value:EscrowInstrument):void
		{
			if (isDisposed)
			{
				return;
			}
			
			currentCryptoWallet = null;
			selectInstrument(value);
			currencySign = null;
			selectCurrencyFromPrices();
			selectFiat(currencySign);
			setCurrencyInControls();
			
			checkFiatAccountExist();
			/*if (!selectedCrypto.isLinked && state != STATE_REGISTER)
			{
				toState(STATE_REGISTER);
			}
			else if (selectedCrypto.isLinked && state != STATE_START)
			{
				toState(STATE_START);
			}*/
			
			updatePrice();
			updateBalance();
			priceSelector.draw(_width - contentPadding * 2, -5, 5, 0, selectedPrice, getCurrency());
		}
		
		private function checkFiatAccountExist():void 
		{
			if (selectedCrypto != null && selectedFiatAccount == null && state != STATE_REGISTER && selectedDirection == TradeDirection.sell)
			{
				toState(STATE_REGISTER);
			}
			else if (state != STATE_START)
			{
				toState(STATE_START);
			}
		}
		
		private function selectFiat(currency:String):void 
		{
			var filteredAccounts:Array = getAccounts();
			if (filteredAccounts != null)
			{
				var preselectedAccount:Object;
				/*if (filteredAccounts.length > 0)
				{
					preselectedAccount = filteredAccounts[0];
				}*/
				var preferredCurrency:String = currency;
				for (var i:int = 0; i < filteredAccounts.length; i++) 
				{
					if (filteredAccounts[i].CURRENCY == preferredCurrency)
					{
						preselectedAccount = filteredAccounts[i];
						break;
					}
				}
				
				if (preselectedAccount != null)
				{
					selectedFiatAccount = preselectedAccount;
					
					if (selectorAccont == null)
					{
						createAccountSelector();
						selectorAccont.setSize(_width - contentPadding * 2, Config.FINGER_SIZE * .8);
					}
					if (openAccountTitle != null)
					{
						removeItem(openAccountTitle);
						UI.destroy(openAccountTitle);
						openAccountTitle = null;
					}
					if (openAccountButton != null)
					{
						removeItem(openAccountButton);
						openAccountButton = null;
						openAccountButton = null;
					}
					
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
					selectedFiatAccount = null;
					if (selectedDirection == TradeDirection.buy)
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
				
				openAccountTitle.bitmapData = TextUtils.createTextFieldData(text, _width - contentPadding * 2, 10, true,
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
		
		private function getInstrument():String
		{
			var result:String = "";
			if (selectedCrypto != null)
			{
				if (Lang[selectedCrypto.code] != null)
				{
					result = Lang[selectedCrypto.code];
				}
				else
				{
					result = selectedCrypto.code;
				}
			}
			return result;
		}
		
		private function getIcon(instrument:EscrowInstrument):Sprite 
		{
			return UI.getInvestIconByInstrument(instrument.code);
		}
		
		private function toState(newState:String):void 
		{
			if (state != newState)
			{
				hideCurrentState();
				state = newState;
				
				if (state == STATE_REGISTER)
				{
					addItem(selectorInstrument);
					createRegisterBlockchainClips();
					drawRegisterBlock();
					activateRegisterClips();
				}
				else if (state == STATE_START)
				{
					if (selectedDirection == TradeDirection.sell)
					{
						addItem(terms);
					}
					addItem(selectorInstrument);
					addItem(selectorAccont);
					addItem(radio);
					addItem(inputAmount);
					addItem(balance);
					if (controlPriceSelected == priceSelector)
					{
						addItem(priceSelector);
					}
					else
					{
						if (selectorCurrency != null)
						{
							addItem(selectorCurrency);
						}
						addItem(inputPrice);
					}
					if (nextButton != null)
					{
						container.addChild(nextButton);
					}
					else if (sendButton != null)
					{
						container.addChild(sendButton);
					}
					
					activateStartState();
				}
				else if (state == STATE_FINISH)
				{
					createFinishState();
					activateFinishState();
				}
				
				updateScrollSize();
				updatePositions();
			}
		}
		
		private function activateFinishState():void 
		{
			sendButton.activate();
			backButton.activate();
			terms.activate();
			if (cryptoWalletInput != null)
			{
				cryptoWalletInput.activate();
			}
			if (selectCryptoButton != null)
			{
				selectCryptoButton.activate();
			}
		}
		
		private function createFinishState():void 
		{
			createSendButton();
			createBackButton();
			
			if (priceSummary == null)
			{
				priceSummary = new PriceClip();
			}
			addItem(priceSummary);
			priceSummary.draw(Lang.escrow_you_buy, getAmount() + " " + selectedCrypto.name, Lang.escrow_price, NumberFormat.formatAmount(selectedPrice, getCurrency()), _width, contentPadding);
			
			if (alert == null)
			{
				alert = new AlertTextArea();
			}
			alert.draw(_width - contentPadding * 2, Lang.escrow_autocancel_description, null);
			addItem(alert);
			
			if (blockchainTitle == null)
			{
				blockchainTitle = new Bitmap();
			}
			if (blockchainTitle.bitmapData != null)
			{
				blockchainTitle.bitmapData.dispose();
				blockchainTitle.bitmapData = null;
			}
			blockchainTitle.bitmapData = TextUtils.createTextFieldData(Lang.my_blockchain_address, _width - contentPadding * 2, 10, true,
																	TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
																	FontSize.SUBHEAD, true, Style.color(Style.COLOR_SUBTITLE),
																	Style.color(Style.COLOR_SEPARATOR));
			addItem(blockchainTitle);
			
			var numWallets:int = 0;
			if (selectedCrypto.isLinked)
			{
				numWallets ++;
			}
			if (localWalletExist())
			{
				if (selectedCrypto != null)
				{
					if (cryptoWallets != null)
					{
						for (var i:int = 0; i < cryptoWallets.length; i++) 
						{
							if (cryptoWallets[i].crypto == selectedCrypto.code)
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
			addItem(cryptoWalletInput);
				
			var inputWidth:int = _width - contentPadding * 2;
			if (numWallets > 1 && selectCryptoButton != null)
			{
				inputWidth -= int(selectCryptoButton.width + Config.FINGER_SIZE * .3);
			}
			
			cryptoWalletInput.drawString(inputWidth, null, "");
				
			if (selectedCrypto.isLinked || localWalletExist())
			{
				var cryptoWallet:String;
				if (selectedCrypto.isLinked)
				{
					cryptoWallet = selectedCrypto.wallet;
				}
				else
				{
					cryptoWallet = getLocalCryptoWallet();
					currentCryptoWallet = cryptoWallet;
				}
				
				cryptoWalletInput.valueString = cryptoWallet;
			}
			
			creeateTerms();
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
		
		private function callBackSelectCryptoWallet(instrument:EscrowInstrument):void
		{
			if (cryptoWalletInput != null)
			{
				cryptoWalletInput.valueString = instrument.wallet;
			}
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
		
		private function getLocalCryptoWallet():String 
		{
			if (selectedCrypto != null)
			{
				if (cryptoWallets != null)
				{
					for (var i:int = 0; i < cryptoWallets.length; i++) 
					{
						if (cryptoWallets[i].crypto == selectedCrypto.code)
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
			if (selectedCrypto != null)
			{
				if (cryptoWallets != null)
				{
					for (var i:int = 0; i < cryptoWallets.length; i++) 
					{
						if (cryptoWallets[i].crypto == selectedCrypto.code)
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
		
		private function createBackButton():void 
		{
			var textSettings:TextFieldSettings;
			var buttonBitmap:ImageBitmapData;
			
			if (backButton == null)
			{
				backButton = new BitmapButton();
				backButton.setStandartButtonParams();
				backButton.tapCallback = onBackClick;
				backButton.disposeBitmapOnDestroy = true;
				backButton.setDownScale(1);
				backButton.setOverlay(HitZoneType.BUTTON);
				
				textSettings = new TextFieldSettings(Lang.textBack.toUpperCase(), Style.color(Style.COLOR_TEXT), FontSize.BODY, TextFormatAlign.CENTER);
				buttonBitmap = TextUtils.createbutton(textSettings, Style.color(Style.COLOR_BACKGROUND), 1, -1, Style.color(Style.COLOR_BUTTON_OUTLINE), getButtonWidth(), Style.size(Style.BUTTON_PADDING), Style.size(Style.SIZE_BUTTON_CORNER));
				backButton.setBitmapData(buttonBitmap, true);
			}
			container.addChild(backButton);
		}
		
		private function createSendButton():void 
		{
			var textSettings:TextFieldSettings;
			var buttonBitmap:ImageBitmapData;
			
			if (sendButton == null)
			{
				sendButton = new BitmapButton();
				sendButton.setStandartButtonParams();
				sendButton.tapCallback = onSendClick;
				sendButton.disposeBitmapOnDestroy = true;
				sendButton.setDownScale(1);
				sendButton.setOverlay(HitZoneType.BUTTON);
				
				textSettings = new TextFieldSettings(Lang.send_offer, Style.color(Style.COLOR_BACKGROUND), FontSize.BODY, TextFormatAlign.CENTER);
				buttonBitmap = TextUtils.createbutton(textSettings, Color.GREEN, 1, -1, NaN, getButtonWidth(), Style.size(Style.BUTTON_PADDING), Style.size(Style.SIZE_BUTTON_CORNER));
				sendButton.setBitmapData(buttonBitmap, true);
			}
			container.addChild(sendButton);
		}
		
		private function onTermsChecker():void 
		{
			
		}
		
		private function selectDefaultAccount():void 
		{
			selectFiat(TypeCurrency.USD);
		}
		
		private function getAccounts():Array 
		{
			if (accounts != null)
			{
				var accountsArray:Array = accounts.moneyAccounts;
				return filterAccountsByPrices(accountsArray);
			}
			else
			{
				ApplicationErrors.add();
			}
			return null;
		}
		
		private function filterAccountsByPrices(accountsArray:Array):Array 
		{
			return accountsArray;
			
			var result:Array = new Array();
			if (selectedCrypto != null && selectedCrypto.price != null)
			{
				var prices:Vector.<EscrowPrice> = selectedCrypto.price;
				for (var i:int = 0; i < accountsArray.length; i++) 
				{
					for (var j:int = 0; j < prices.length; j++) 
					{
						if (accountsArray[i].CURRENCY == prices[j].name)
						{
							result.push(accountsArray[i]);
						}
					}
				}
			}
			else
			{
				result = accountsArray;
			}
			return result;
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
		
		private function onAccountsFail():void 
		{
			if (_isDisposed)
			{
				return;
			}
			hidePreloader();
			ToastMessage.display(Lang.needToByAuthorized);
		}
		
		private function onBackClick():void 
		{
			if (state == STATE_FINISH)
			{
				toState(STATE_START);
			}
		}
		
		private function onSendClick():void 
		{
			var dataValid:Boolean = true;
			offerData = new EscrowDealData();
			
			if (state == STATE_START)
			{
				if (isNaN(selectedPrice) || selectedPrice == 0)
				{
					if (controlPriceSelected == inputPrice)
					{
						inputPrice.invalid();
					}
					dataValid = false;
				}
				if (isNaN(inputAmount.value) || inputAmount.value == 0)
				{
					inputAmount.invalid();
					dataValid = false;
				}
				
				if (!dataValid)
				{
					return;
				}
			}
			
			if (selectedDirection == TradeDirection.buy)
			{
				var selectedCryptoWallet:String;
				if (state == STATE_FINISH)
				{
					if (selectedCrypto.isLinked)
					{
						selectedCryptoWallet = selectedCrypto.wallet;
					}
					else
					{
						if (cryptoWalletInput != null)
						{
							if (cryptoWalletInput.valueString != null && cryptoWalletInput.valueString != "")
							{
								selectedCryptoWallet = cryptoWalletInput.valueString;
								GD.S_CRYPTO_WALLET_ADD.invoke(selectedCrypto.code, selectedCryptoWallet);
							}
							else
							{
								cryptoWalletInput.invalid();
							}
						}
						else
						{
							selectedCryptoWallet = currentCryptoWallet;
							GD.S_CRYPTO_WALLET_ADD.invoke(selectedCrypto.code, selectedCryptoWallet);
						}
						//!TODO:;
					}
				}
				if (selectedCryptoWallet != null)
				{
					offerData.cryptoWallet = selectedCryptoWallet;
				}
				else
				{
					ToastMessage.display(Lang.escrow_provide_crypto_wallet);
					return;
				}
			}
			
			if (selectedCrypto == null)
			{
				selectorInstrument.invalid();
				return;
			}
			
			if (terms != null)
			{
				if (initialAmountExist() && getInitialAmount() < inputAmount.value)
				{
					ToastMessage.display(Lang.escrow_amount_exceeds);
					return;
				}
				
				if (terms.isSelected())
				{
					if (controlPriceSelected == priceSelector)
					{
						offerData.price = priceSelector.getValue();
						offerData.isPercent = true;
					}
					else
					{
						offerData.price = parseFloat(NumberFormat.formatAmount(selectedPrice, currencySign, true));
					}
					
					offerData.direction = selectedDirection;
					offerData.amount = parseFloat(NumberFormat.formatAmount(inputAmount.value, selectedCrypto.code, true));
					offerData.instrument = selectedCrypto.code;
					offerData.currency = currencySign;
					if (selectedFiatAccount != null)
					{
						offerData.accountNumber = selectedFiatAccount.ACCOUNT_NUMBER;
					}
					/*if ()
					{
						
					}*/
					
					checkPaymentsSell();
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
		
		private function checkPaymentsSell():void 
		{
			//	values.push((amount * targetPrice * EscrowSettings.refundableFee + amount * targetPrice).toFixed(decimals) + " " + currency);
			
			//TODO: неверное значение при процентном прайсе;
			var resultAmount:Number = (offerData.amount * offerData.price - offerData.amount * offerData.price * EscrowSettings.getCommission(offerData.instrument));
			
			
			checkPaymentsAction = new TestCreateOfferAction(selectedDirection, resultAmount, offerData.currency, selectedCrypto);
			checkPaymentsAction.getFailSignal().add(onPaymentsSellCheckFail);
			checkPaymentsAction.getSuccessSignal().add(onPaymentsSellCheckSuccess);
			checkPaymentsAction.execute();
		}
		
		private function onPaymentsSellCheckSuccess():void 
		{
			needCallback = true;
			command = OfferCommand.create_offer;
			removeCheckPaymentsAction();
			close();
		}
		
		private function onPaymentsSellCheckFail(errorMessage:String):void 
		{
			removeCheckPaymentsAction();
			ToastMessage.display(errorMessage);
		}
		
		private function removeCheckPaymentsAction():void 
		{
			if (checkPaymentsAction != null)
			{
				if (checkPaymentsAction.getFailSignal() != null)
				{
					checkPaymentsAction.getFailSignal().remove(onPaymentsSellCheckFail);
					checkPaymentsAction.getSuccessSignal().remove(onPaymentsSellCheckSuccess);
					
					checkPaymentsAction.getFailSignal().remove(onPaymentsBuyCheckFail);
					checkPaymentsAction.getSuccessSignal().remove(onPaymentsBuyCheckSuccess);
				}
				
				checkPaymentsAction.dispose();
				checkPaymentsAction = null;
			}
		}
		
		private function openWalletSelector():void 
		{
			if (selectorAccont != null)
			{
				selectorAccont.valid();
			}
			
			if (dataLoaded)
			{
				SoftKeyboard.closeKeyboard();
				if (inputAmount != null)
				{
					inputAmount.forceFocusOut();
				}
				if (inputPrice != null)
				{
					inputPrice.forceFocusOut();
				}
				
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
		}
		
		private function onWalletFiatSelect(account:Object, cleanCurrent:Boolean = false):void
		{
			if (account != null && selectorAccont != null)
			{
				selectedFiatAccount = account;
				selectorAccont.setValue(account);
			}
		}
			
		private function activateStartState():void 
		{
			/*if (selectorAccont != null)
			{
				selectorAccont.activate();
			}*/
			/*if (selectorCurrency != null)
			{
				selectorCurrency.activate();
			}*/
			if (terms != null)
			{
				terms.activate();
			}
			if (nextButton != null)
			{
				nextButton.activate();
			}
			if (sendButton != null)
			{
				sendButton.activate();
			}
			if (openAccountButton != null)
			{
				openAccountButton.activate();
			}
			
			radio.activate();
			inputAmount.activate();
			inputPrice.activate();
			priceSelector.activate();
		}
		
		private function activateRegisterClips():void 
		{
			if (registerBlock != null)
			{
				if (registerDescriptionClip != null)
				{
					PointerManager.addTap(registerDescriptionClip, openRegisterLink);
				}
				if (registerButton != null)
				{
					registerButton.activate();
				}
			}
		}
		
		private function deactivateRegisterClips():void 
		{
			if (registerBlock != null)
			{
				if (registerDescriptionClip != null)
				{
					PointerManager.removeTap(registerDescriptionClip, openRegisterLink);
				}
				if (registerButton != null)
				{
					registerButton.deactivate();
				}
			}
		}
		
		private function openRegisterLink(e:Event):void 
		{
			navigateToURL(new URLRequest(Lang.declare_blockchain_description_url));
		}
		
		private function drawRegisterBlock():void 
		{
			if (registerDescriprtion.bitmapData != null)
			{
				registerDescriprtion.bitmapData.dispose();
				registerDescriprtion.bitmapData = null;
			}
			var text:String = Lang.register_fiat_account;
			text = LangManager.replace(Lang.regExtValue, text, currencySign);
			registerDescriprtion.bitmapData = TextUtils.createTextFieldData(text, _width - contentPadding * 2, 10, true,
																	TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
																	FontSize.SUBHEAD, true, Style.color(Style.COLOR_SUBTITLE),
																	Style.color(Style.COLOR_BACKGROUND), false, true);
			var textSettings:TextFieldSettings = new TextFieldSettings(Lang.textRegister.toUpperCase(), Style.color(Style.COLOR_BACKGROUND), FontSize.BODY, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, Style.color(Style.COLOR_BUTTON_ACCENT), 1, -1, NaN, getButtonWidth(), Style.size(Style.BUTTON_PADDING), Style.size(Style.SIZE_BUTTON_CORNER));
			registerButton.setBitmapData(buttonBitmap, true);
			
			var position:int = contentPaddingV;
			
			registerDescriptionClip.x = contentPadding;
			registerDescriptionClip.y = position;
			position += registerDescriptionClip.height + contentPaddingV * 2;
			
			registerButton.x = contentPadding;
			registerButton.y = position;
			position += registerButton.height + contentPaddingV + Config.APPLE_BOTTOM_OFFSET;
			
			registerBlock.graphics.clear();
			registerBlock.graphics.beginFill(Style.color(Style.BOTTOM_BAR_COLOR));
			registerBlock.graphics.drawRect(0, 0, _width, position);
			registerBlock.graphics.endFill();
			
			registerBlock.y = int(getHeight() - registerBlock.height);
		}
		
		private function hideCurrentState():void 
		{
			if (state == STATE_START)
			{
				if (nextButton != null && container.contains(nextButton))
				{
					container.removeChild(nextButton);
				}
				if (sendButton != null && container.contains(sendButton))
				{
					container.removeChild(sendButton);
				}
				
				removeItem(radio);
				removeItem(inputAmount);
				removeItem(inputPrice);
				removeItem(priceSelector);
				removeItem(balance);
				removeItem(selectorInstrument);
				removeItem(selectorAccont);
				removeItem(selectorCurrency);
				removeItem(terms);
				
				deactivateStartState();
			}
			else if (state == STATE_REGISTER)
			{
				if (container.contains(registerBlock))
				{
					container.removeChild(registerBlock);
				}
				else
				{
					ApplicationErrors.add();
				}
				
				deactivateRegisterClips();
			}
			else if (state == STATE_FINISH)
			{
				if (container.contains(backButton))
				{
					container.removeChild(backButton);
				}
				else
				{
					ApplicationErrors.add();
				}
				
				if (container.contains(sendButton))
				{
					container.removeChild(sendButton);
				}
				else
				{
					ApplicationErrors.add();
				}
				
				removeItem(blockchainAddress);
				removeItem(blockchainBack);
				removeItem(blockchainTitle);
				removeItem(terms);
				if (terms != null)
				{
					terms.unselect();
				}
				removeItem(cryptoWalletInput);
				removeItem(priceSummary);
				removeItem(alert);
				if (selectCryptoButton != null)
				{
					removeItem(selectCryptoButton);
				}
			}
		}
		
		private function deactivateStartState():void 
		{
			if (selectorAccont != null)
			{
				selectorAccont.deactivate();
			}
			if (selectorCurrency != null)
			{
				selectorCurrency.deactivate();
			}
			if (terms != null)
			{
				terms.deactivate();
			}
			if (nextButton != null)
			{
				nextButton.deactivate();
			}
			if (sendButton != null)
			{
				sendButton.deactivate();
			}
			if (openAccountButton != null)
			{
				openAccountButton.deactivate();
			}
			
			radio.deactivate();
			inputAmount.deactivate();
			inputPrice.deactivate();
			priceSelector.deactivate();
		}
		
		override public function onBack(e:Event = null):void {
			close();
		}
		
		private function createNextButton():void 
		{
			nextButton = new BitmapButton();
			nextButton.setStandartButtonParams();
			nextButton.tapCallback = onNextClick;
			nextButton.disposeBitmapOnDestroy = true;
			nextButton.setDownScale(1);
			nextButton.setOverlay(HitZoneType.BUTTON);
			container.addChild(nextButton);
		}
		
		private function onNextClick():void 
		{
			if (state == STATE_START)
			{
				var dataValid:Boolean = true;
				
				if (selectedDirection == TradeDirection.buy)
				{
					if (selectedFiatAccount == null)
					{
						if (selectorAccont != null)
						{
							selectorAccont.invalid();
						}
						dataValid = false;
					}
				}
				if (!dataLoaded)
				{
					dataValid = false;
				}
				if (isNaN(selectedPrice) || selectedPrice == 0)
				{
					if (controlPriceSelected == inputPrice)
					{
						inputPrice.invalid();
					}
					dataValid = false;
				}
				if (isNaN(inputAmount.value) || inputAmount.value == 0)
				{
					inputAmount.invalid();
					dataValid = false;
				}
				
				if (initialAmountExist())
				{
					if (getInitialAmount() < inputAmount.value)
					{
						dataValid = false;
						ToastMessage.display(Lang.escrow_amount_exceeds);
					}
				}
				
				if (dataValid)
				{
					checkPaymentsBuy();
				}
			}
		}
		
		private function checkPaymentsBuy():void 
		{
			//!TODO: lock;
			
			//TODO: неверное значение при процентном прайсе;
			var amount:Number = inputAmount.value;
			var fiatAmount:Number = amount * selectedPrice;
			var resultAmount:Number = (fiatAmount + fiatAmount * EscrowSettings.refundableFee);
			
			checkPaymentsAction = new TestCreateOfferAction(selectedDirection, resultAmount, currencySign, selectedCrypto);
			checkPaymentsAction.getFailSignal().add(onPaymentsBuyCheckFail);
			checkPaymentsAction.getSuccessSignal().add(onPaymentsBuyCheckSuccess);
			checkPaymentsAction.execute();
		}
		
		private function onPaymentsBuyCheckSuccess():void 
		{
			removeCheckPaymentsAction();
			toState(STATE_FINISH);
		}
		
		private function onPaymentsBuyCheckFail(errorMessage:String):void 
		{
			removeCheckPaymentsAction();
			ToastMessage.display(errorMessage);
		}
		
		private function createInputAmount():void 
		{
			var tf:TextFormat = new TextFormat();
			tf.size = FontSize.TITLE_2;
			tf.color = Style.color(Style.COLOR_TEXT);
			tf.font = Config.defaultFontName;
			
			inputAmount = new InputField( -1, Input.MODE_DIGIT_DECIMAL);
			inputAmount.onChangedFunction = onAmountChange;
			inputAmount.setPadding(0);
			inputAmount.updateTextFormat(tf);
			addItem(inputAmount);
		}
		
		private function createInputPrice():void 
		{
			var tf:TextFormat = new TextFormat();
			tf.size = FontSize.TITLE_2;
			tf.color = Style.color(Style.COLOR_TEXT);
			tf.font = Config.defaultFontName;
			
			inputPrice = new InputField( -1, Input.MODE_DIGIT_DECIMAL);
			inputPrice.onChangedFunction = onPriceInputChange;
			inputPrice.setPadding(0);
			inputPrice.updateTextFormat(tf);
			addItem(inputPrice);
		}
		
		private function onPriceInputChange():void 
		{
			inputPrice.valid();
			setPrice(inputPrice.value);
		}
		
		private function onAmountChange():void 
		{
			if (initialAmountExist())
			{
				if (getInitialAmount() < inputAmount.value)
				{
					inputAmount.invalid();
				}
				else
				{
					inputAmount.valid();
				}
			}
			else
			{
				inputAmount.valid();
			}
			
			updateBalance();
		}
		
		private function getInitialAmount():Number 
		{
			if (initialAmountExist())
			{
				return data.amount;
			}
			else
			{
				return 0;
			}
		}
		
		private function initialAmountExist():Boolean 
		{
			return (data != null && "amount" in data && !isNaN(data.amount));
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			if (data != null && "selectedDirection" in data && data.selectedDirection != null)
			{
				selectedDirection = data.selectedDirection as TradeDirection;
			}
			
			if (data != null)
			{
				if ("price" in data && "amount" in data)
				{
					lockInputs();
				}
			}
			
			if (selectedDirection == TradeDirection.buy)
			{
				createNextButton();
				createAccountSelector();
				loadWalletsData();
			}
			else if (selectedDirection == TradeDirection.sell)
			{
				createSendButton();
				createCurrencySelector();
				creeateTerms();
			}
			
			priceSelector.direction = selectedDirection;
			priceSelector.draw(_width - contentPadding * 2, -5, 5, 0, selectedPrice, getCurrency());
			
			drawControls();
			createBalance();
			showFixedPriceControl();
			updatePositions();
			updateScroll();
			
			loadInstruments();
		}
		
		private function loadWalletsData():void 
		{
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
		}
		
		private function creeateTerms():void 
		{
			if (terms == null)
			{
				terms = new TermsChecker(onTermsChecker);
				terms.draw(_width - contentPadding * 2, Lang.escrow_terms_accept, Lang.escrow_terms_link);
			}
			addItem(terms);
		}
		
		private function lockInputs():void 
		{
			
		}
		
		private function loadInstruments():void 
		{
			dataLoaded = false;
			showPreloader();
			GD.S_ESCROW_INSTRUMENTS.add(instrumentsLoaded);
			GD.S_ESCROW_INSTRUMENTS_REQUEST.invoke();
		}
		
		private function instrumentsLoaded(instruments:Vector.<EscrowInstrument>):void 
		{
			GD.S_ESCROW_INSTRUMENTS.remove(instrumentsLoaded);
			if (isDisposed)
			{
				return;
			}
			
			if (this.instruments == null)
			{
				this.instruments = instruments;
				dataLoaded = true;
				if (selectedDirection == TradeDirection.buy)
				{
					loadAccounts();
				}
				else
				{
					loadAccounts();
					
				//	hidePreloader();
				//	onDataReady();
				}
			}
		}
		
		/*private function loadPrices():void 
		{
			GD.S_ESCROW_PRICE.add(pricesLoaded);
			GD.S_ESCROW_PRICES_REQUEST.invoke();
		}
		
		private function pricesLoaded(ei:EscrowInstrument):void 
		{
			//!TODO: другой сигнал!, этот перенаправить
			if (isDisposed)
			{
				return;
			}
			GD.S_ESCROW_PRICE.remove(pricesLoaded);
			trace("123");
			dataLoaded = true;
			
			getAccounts();
		}*/
		
		override protected function getBottomPadding():int 
		{
			var result:int = 0;
			if (state == STATE_START)
			{
				if (nextButton != null)
				{
					result = nextButton.height + contentPadding * 2;
				}
				else if (sendButton != null)
				{
					result = sendButton.height + contentPadding * 2;
				}
			}
			else if (state == STATE_REGISTER)
			{
				if (registerBlock != null)
				{
					result = registerBlock.height;
				}
				else
				{
					ApplicationErrors.add();
				}
			}
			return result;
		}
		
		private function updatePositions():void 
		{
			var position:int;
			
			if (state == STATE_START)
			{
				position = Config.FINGER_SIZE * .2;
				
				selectorInstrument.x = contentPadding;
				selectorInstrument.y = position;
				position += selectorInstrument.height + contentPaddingV;
				
				inputAmount.x = contentPadding;
				inputAmount.y = position;
				position += inputAmount.height + contentPaddingV;
				
				radio.x = contentPadding;
				radio.y = position;
				position += radio.height + contentPaddingV;
				
				priceSelector.x = contentPadding;
				priceSelector.y = position;
				
				inputPrice.x = contentPadding;
				inputPrice.y = position;
				
				var inputWidth:int = _width - contentPadding * 2;
				if (selectorCurrency != null)
				{
					inputWidth -= int(selectorCurrency.fullWidth + Config.FINGER_SIZE * .15);
					selectorCurrency.x = int(_width - contentPadding - selectorCurrency.width);
					selectorCurrency.y = int(inputPrice.y + inputPrice.linePosition() - selectorCurrency.linePosition());
				}
				inputPrice.draw(inputWidth, Lang.pricePerCoin, inputPrice.value, inputPrice.getUnderlineValue());
				
				if (controlPriceSelected == inputPrice)
				{
					position += inputPrice.height + contentPaddingV * 1.5;
				}
				else
				{
					position += priceSelector.height + contentPaddingV * 1.5;
				}
				
				if (selectorAccont != null)
				{
					selectorAccont.x = contentPadding;
					selectorAccont.y = position;
					position += selectorAccont.height + contentPaddingV;
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
				
				if (terms != null && terms.parent != null)
				{
					terms.x = contentPadding;
					terms.y = position;
					position += terms.height + contentPaddingV * 1.5;
				}
				
				balance.x = int(_width * .5 - balance.width * .5);
				balance.y = position;
				
				var bottomButton:BitmapButton;
				if (nextButton != null)
				{
					bottomButton = nextButton;
				}
				else if (sendButton != null)
				{
					bottomButton = sendButton;
				}
				
				if (getContentHeight() - bottomButton.height - contentPadding - balance.height - scrollPanel.view.y - contentPaddingV > position)
				{
					balance.y = getContentHeight() - bottomButton.height - contentPadding - balance.height - scrollPanel.view.y - contentPaddingV;
				}
				
				bottomButton.x = contentPadding;
				bottomButton.y = int(getContentHeight() - bottomButton.height - contentPadding);
			}
			else if (state == STATE_REGISTER)
			{
				position = Config.FINGER_SIZE * .2;
				
				selectorInstrument.x = contentPadding;
				selectorInstrument.y = position;
				position += selectorInstrument.height + contentPaddingV;
			}
			else if (state == STATE_FINISH)
			{
				if (priceSummary != null)
				{
					position = 1;
					priceSummary.y = position;
					position += priceSummary.height + contentPaddingV * 2;
				}
				else
				{
					position = Config.FINGER_SIZE * .3;
				}
				
				blockchainTitle.x = contentPadding;
				blockchainTitle.y = position;
				position += blockchainTitle.height + contentPaddingV * .3;
				
				if (blockchainBack != null)
				{
					blockchainBack.x = contentPadding;
					blockchainBack.y = position;
					blockchainAddress.x = contentPadding * 2;
					blockchainAddress.y = position + contentPadding;
					position += blockchainBack.height + contentPaddingV * 2;
					if (selectCryptoButton != null)
					{
						selectCryptoButton.y = int(blockchainBack.y + Config.FINGER_SIZE * .3);
						selectCryptoButton.x = int(blockchainBack.x - Config.FINGER_SIZE * .3 - selectCryptoButton.width);
					}
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
				
				if (alert != null)
				{
					alert.x = contentPadding;
					alert.y = position;
					position += alert.height + contentPaddingV * 2;
				}
				
				terms.x = contentPadding;
				terms.y = position;
				position += terms.height + contentPaddingV * 2;
				
				balance.x = int(_width * .5 - balance.width * .5);
				balance.y = position;
				
				if (getContentHeight() - nextButton.height - contentPadding - balance.height - scrollPanel.view.y - contentPaddingV > position)
				{
					balance.y = getContentHeight() - nextButton.height - contentPadding - balance.height - scrollPanel.view.y - contentPaddingV;
				}
				
				backButton.x = contentPadding;
				backButton.y = int(getContentHeight() - nextButton.height - contentPadding);
				
				sendButton.x = contentPadding;
				sendButton.y = int(backButton.y - sendButton.height - contentPadding);
			}
		}
		
		private function drawControls():void
		{
			radioSelection = new Vector.<SelectorItemData>();
			radioSelection.push(new SelectorItemData(Lang.deviation_from_market, showDeviationControl));
			radioSelection.push(new SelectorItemData(Lang.fixed_price, showFixedPriceControl));
			radio.draw(radioSelection, _width - contentPadding * 2, RadioItem);
			radio.select(radioSelection[1]);
			
			if (selectorAccont != null)
			{
				selectorAccont.setSize(_width - contentPadding * 2, Config.FINGER_SIZE * .8);
			}
			
			selectorInstrument.setSize(_width - contentPadding * 2, Config.FINGER_SIZE * 1.0);
			
			var textSettings:TextFieldSettings;
			var buttonBitmap:ImageBitmapData;
			if (nextButton != null)
			{
				textSettings = new TextFieldSettings(Lang.textNext.toUpperCase(), Style.color(Style.COLOR_TEXT), FontSize.BODY, TextFormatAlign.CENTER);
				buttonBitmap = TextUtils.createbutton(textSettings, Style.color(Style.COLOR_BACKGROUND), 1, -1, Style.color(Style.COLOR_BUTTON_OUTLINE), getButtonWidth(), Style.size(Style.BUTTON_PADDING), Style.size(Style.SIZE_BUTTON_CORNER));
				nextButton.setBitmapData(buttonBitmap, true);
			}
			
			inputAmount.draw(_width - contentPadding * 2, Lang.textAmount, 0);
			
			var inputWidth:int = _width - contentPadding * 2;
			if (selectorCurrency != null)
			{
				selectorCurrency.setSize(int(Config.FINGER_SIZE * 1.2), Config.FINGER_SIZE * 0.6);
				inputWidth -= int(selectorCurrency.fullWidth + Config.FINGER_SIZE * .15);
			}
			
			inputPrice.draw(inputWidth, Lang.pricePerCoin, 0);
		}
		
		public function onDataReady():void
		{
			if (isDisposed)
			{
				return;
			}
			hidePreloader();
			dataLoaded = true;
			
			if (instruments != null && instruments.length > 0)
			{
				var targetInstrument:EscrowInstrument;
				if (data != null && "instrument" in data && data.instrument != null)
				{
					var requestedInstrument:String = data.instrument;
					for (var i:int = 0; i < instruments.length; i++) 
					{
						if (instruments[i].code == requestedInstrument)
						{
							lockInstrumentSelector = true;
							targetInstrument = instruments[i];
							break;
						}
					}
				}
				if (targetInstrument == null)
				{
					for (var j:int = 0; j < instruments.length; j++) 
					{
						if (instruments[j].isLinked)
						{
							targetInstrument = instruments[j];
							break;
						}
					}
					if (targetInstrument == null)
					{
						targetInstrument = instruments[0];
					}
				}
				selectInstrument(targetInstrument);
			}
			else
			{
				ApplicationErrors.add();
			}
			if (selectedDirection == TradeDirection.buy)
			{
				selectCurrencyFromPrices();
				selectFiat(currencySign);
			//	selectDefaultAccount();
			}
			else
			{
				if (priceSelector != null)
				{
					if (selectedCrypto != null)
					{
						selectCurrencyFromPrices();
						selectFiat(currencySign);
						setCurrencyInControls();
					}
					else
					{
						ApplicationErrors.add("selectedCrypto null");
					}
				}
				else
				{
					ApplicationErrors.add("priceSelector null");
				}
			}
			
			if (initialAmountExist())
			{
				inputAmount.value = data.amount;
			}
			if (data != null && "currency" in data && data.currency != null)
			{
				currencySign = data.currency;
			}
			if (data != null && "price" in data && data.price != null)
			{
				var requestedPrice:String = data.price;
				var pricePercentStartValue:Number = 0;
				if (requestedPrice.indexOf("%") != -1)
				{
					requestedPrice = requestedPrice.replace("%", "");
					if (!isNaN(Number(requestedPrice)))
					{
						selectedPrice = NaN;
						pricePercentStartValue = Number(requestedPrice);
						radio.select(radioSelection[0]);
						showDeviationControl();
						priceSelector.setValue(Number(requestedPrice));
					//	selectedPrice = priceSelector.getPrice();
					}
				}
				else if(!isNaN(Number(requestedPrice)))
				{
					radio.select(radioSelection[1]);
					showFixedPriceControl();
					selectedPrice = Number(requestedPrice);
					inputPrice.value = selectedPrice;
				}
				
				refreshPrice(selectedPrice, pricePercentStartValue);
			}
			else
			{
				refreshPrice();
			}
			
			if (selectedCrypto != null && selectedFiatAccount == null && state != STATE_REGISTER && selectedDirection == TradeDirection.sell)
			{
				toState(STATE_REGISTER);
			}
		}
		
		private function refreshPrice(overridePrice:Number = NaN, pricePercentStartValue:Number = 0):void 
		{
			var originalPrice:Number = updatePrice(overridePrice, pricePercentStartValue);
			if (state == STATE_START)
			{
				priceSelector.draw(_width - contentPadding * 2, -5, 5, pricePercentStartValue, originalPrice, getCurrency());
			}
			updateBalance();
			updatePositions();
		}
		
		private function setCurrencyInControls():void 
		{
			if (currencySign != null && selectorCurrency != null)
			{
				selectorCurrency.setValue(currencySign);
			}
			priceSelector.setPrices(currencySign, selectCurrencyTap);
		}
		
		private function selectCurrencyFromPrices():void 
		{
			if (selectedCrypto != null && selectedCrypto.price != null)
			{
				var preferredCurrency:String = TypeCurrency.USD;
				var exist:Boolean;
				for (var i:int = 0; i < selectedCrypto.price.length; i++) 
				{
					if (selectedCrypto.price[i].name == preferredCurrency)
					{
						exist = true;
						break;
					}
				}
				if (exist)
				{
					currencySign = preferredCurrency;
				}
				else
				{
					if (selectedCrypto.price.length > 0)
					{
						currencySign = selectedCrypto.price[0].name;
					}
					else
					{
						ApplicationErrors.add();
					}
				}
			}
			else
			{
				ApplicationErrors.add("selectedCrypto null");
			}
		}
		
		private function loadAccounts():void 
		{
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
		
		private function selectInstrument(escrowInstrument:EscrowInstrument):void 
		{
			selectCrypto(escrowInstrument);
			
			selectorInstrument.setValueExtend(selectedCrypto.name, selectedCrypto, getIcon(selectedCrypto));
			
			updatePrice();
		}
		
		private function updatePrice(overridePrice:Number = NaN, percentStartValue:Number = NaN):Number 
		{
			var price:Number = getPrice();
			var originalPrice:Number = price;
			if (!isNaN(percentStartValue) && !isNaN(price))
			{
				price = parseFloat((price + price * percentStartValue / 100).toFixed(2));
			}
			
			if (!isNaN(overridePrice))
			{
				price = overridePrice;
				originalPrice = price;
			}
			if (!isNaN(price))
			{
				setPrice(price);
				inputPrice.value = selectedPrice;
				
				var currentPriceValue:String = price + " " + getCurrency();
				if (selectedPriceObject != null)
				{
					currentPriceValue = NumberFormat.formatAmount(selectedPriceObject.value, currencySign, false);
				}
				
				var underlineText:String = Lang.current_price_of_instrument.replace(Lang.regExtValue, getInstrument()) + " = " + currentPriceValue;
				inputPrice.drawUnderlineValue(underlineText);
			}
			return originalPrice;
		}
		
		private function getPrice():Number 
		{
			var price:Number;
			if (selectedCrypto != null && selectedCrypto.price != null)
			{
				if (selectedDirection == TradeDirection.buy)
				{
					if (selectedFiatAccount != null)
					{
						for (var i:int = 0; i < selectedCrypto.price.length; i++) 
						{
							if (selectedCrypto.price[i].name == selectedFiatAccount.CURRENCY)
							{
								currencySign = selectedFiatAccount.CURRENCY;
								price = selectedCrypto.price[i].value;
								selectedPriceObject = selectedCrypto.price[i];
								break;
							}
						}
						if (isNaN(price))
						{
							for (var j:int = 0; j < selectedCrypto.price.length; j++) 
							{
								if (currencySign == null && selectedCrypto.price[j].name == TypeCurrency.USD)
								{
									currencySign = TypeCurrency.USD;
									price = selectedCrypto.price[j].value;
									selectedPriceObject = selectedCrypto.price[j];
								}
							}
							if (isNaN(price) && selectedCrypto.price.length > 0)
							{
								currencySign = selectedCrypto.price[0].name;
								price = selectedCrypto.price[0].value;
								selectedPriceObject = selectedCrypto.price[0];
							}
						}
					}
				}
				else if (selectedDirection == TradeDirection.sell)
				{
					if (currencySign != null)
					{
						
						for (var k:int = 0; k < selectedCrypto.price.length; k++) 
						{
							if (selectedCrypto.price[k].name == currencySign)
							{
								selectedPriceObject = selectedCrypto.price[k];
								break;
							}
						}
						if (selectedPriceObject != null)
						{
							price = selectedPriceObject.value;
							price = parseFloat(NumberFormat.formatAmount(price, currencySign, true));
						}
						else
						{
							ApplicationErrors.add();
						}
					}
				}
			}
			
			return price;
		}
		
		private function selectCrypto(escrowInstrument:EscrowInstrument):void 
		{
			//!TODO: подписаться на смену прайса?
			selectedCrypto = escrowInstrument;
		}
		
		private function showFixedPriceControl():void 
		{
			controlPriceSelected = inputPrice;
			setPrice(inputPrice.value);
			if (selectorCurrency != null)
			{
				addItem(selectorCurrency);
			}
			updatePositions();
			
			removeItem(priceSelector);
			addItem(inputPrice);
		}
		
		private function showDeviationControl():void 
		{
			controlPriceSelected = priceSelector;
			if (!isNaN(priceSelector.getPrice()))
			{
				setPrice(priceSelector.getPrice());
			}
			if (selectorCurrency != null)
			{
				removeItem(selectorCurrency);
			}
			updatePositions();
			
			removeItem(inputPrice);
			addItem(priceSelector);
		}
		
		private function getButtonWidth():int 
		{
			return _width - contentPadding * 2;
		}
		
		override protected function updateContentPositions():void 
		{
			updatePositions();
		}
		
		override protected function drawView():void {
			if (_isDisposed == true)
				return;
			
			scrollBottom.y = scrollPanel.itemsHeight + Config.APPLE_BOTTOM_OFFSET + Config.FINGER_SIZE * .3;
			super.drawView();
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			if (_isDisposed) {
				return;
			}
			
			if (state == STATE_START)
			{
				activateStartState();
			}
			else if (state == STATE_REGISTER)
			{
				activateRegisterClips();
			}
			else if (state == STATE_FINISH)
			{
				activateFinishState();
			}
			
			selectorInstrument.activate();
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed) {
				return;
			}
			
			if (state == STATE_START)
			{
				deactivateStartState();
			}
			else if (state == STATE_REGISTER)
			{
				deactivateRegisterClips();
			}
			else if (state == STATE_FINISH)
			{
				deactivateFinishState();
			}
			
			selectorInstrument.deactivate();
		}
		
		private function deactivateFinishState():void 
		{
			sendButton.deactivate();
			backButton.deactivate();
			if (terms != null)
			{
				terms.deactivate();
			}
			if (cryptoWalletInput != null)
			{
				cryptoWalletInput.deactivate();
			}
			if (selectCryptoButton != null)
			{
				selectCryptoButton.deactivate();
			}
		}
		
		override protected function onRemove():void 
		{
			if (needCallback == true)
			{
				needCallback = false;
				if (data != null && "callback" in data && data.callback != null && data.callback is Function && (data.callback as Function).length == 2 && offerData != null)
				{
					(data.callback as Function)(command, offerData);
				}
				command = null;
				offerData = null;
			}
		}
		
		override public function dispose():void {
			super.dispose();
			
			GD.S_CRYPTO_WALLETS.remove(onCryptoWallets);
			GD.S_ESCROW_INSTRUMENTS.remove(instrumentsLoaded);
			
			removeCheckPaymentsAction();
			
			if (selectorInstrument != null)
			{
				selectorInstrument.dispose();
				selectorInstrument = null;
			}
			if (inputAmount != null)
			{
				inputAmount.dispose();
				inputAmount = null;
			}
			if (inputPrice != null)
			{
				inputPrice.dispose();
				inputPrice = null;
			}
			if (nextButton != null)
			{
				nextButton.dispose();
				nextButton = null;
			}
			if (selectorInstrument != null)
			{
				selectorInstrument.dispose();
				selectorInstrument = null;
			}
			if (radio != null)
			{
				radio.dispose();
				radio = null;
			}
			if (inputPrice != null)
			{
				inputPrice.dispose();
				inputPrice = null;
			}
			if (registerButton != null)
			{
				registerButton.dispose();
				registerButton = null;
			}
			if (registerDescriprtion != null)
			{
				UI.destroy(registerDescriprtion);
				registerDescriprtion = null;
			}
			if (registerBlock != null)
			{
				UI.destroy(registerBlock);
				registerBlock = null;
			}
			if (priceSelector != null)
			{
				priceSelector.dispose();
				priceSelector = null;
			}
			if (registerDescriptionClip != null)
			{
				UI.destroy(registerDescriptionClip);
				registerDescriptionClip = null;
			}
			if (openAccountTitle != null)
			{
				UI.destroy(openAccountTitle);
				openAccountTitle = null;
			}
			if (balance != null)
			{
				balance.dispose();
				balance = null;
			}
			if (selectorAccont != null)
			{
				selectorAccont.dispose();
				selectorAccont = null;
			}
			if (sendButton != null)
			{
				sendButton.dispose();
				sendButton = null;
			}
			if (backButton != null)
			{
				backButton.dispose();
				backButton = null;
			}
			if (selectorCurrency != null)
			{
				selectorCurrency.dispose();
				selectorCurrency = null;
			}
			if (accounts != null)
			{
				accounts.dispose();
				accounts = null;
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
			if (terms != null)
			{
				terms.dispose();
				terms = null;
			}
			if (priceSummary != null)
			{
				priceSummary.dispose();
				priceSummary = null;
			}
			if (alert != null)
			{
				alert.dispose();
				alert = null;
			}
			if (cryptoWalletInput != null)
			{
				cryptoWalletInput.dispose();
				cryptoWalletInput = null;
			}
			if (selectCryptoButton != null)
			{
				selectCryptoButton.dispose();
				selectCryptoButton = null;
			}
			if (openAccountButton != null)
			{
				openAccountButton.dispose();
				openAccountButton = null;
			}
			
			selectedFiatAccount = null;
			selectedCrypto = null;
			radioSelection = null;
		}
	}
}