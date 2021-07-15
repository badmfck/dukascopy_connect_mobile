package com.dukascopy.connect.screens.dialogs.escrow {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.GD;
	import com.dukascopy.connect.data.SelectorItemData;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.data.coinMarketplace.PaymentsAccountsProvider;
	import com.dukascopy.connect.data.escrow.EscrowDealData;
	import com.dukascopy.connect.data.escrow.EscrowSettings;
	import com.dukascopy.connect.data.escrow.PriceVO;
	import com.dukascopy.connect.data.escrow.TradeDirection;
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
	import com.dukascopy.connect.managers.escrow.EscrowDealManager;
	import com.dukascopy.connect.managers.escrow.vo.EscrowInstrument;
	import com.dukascopy.connect.managers.escrow.vo.EscrowPrice;
	import com.dukascopy.connect.screens.dialogs.ScreenPayDialog;
	import com.dukascopy.connect.screens.dialogs.paymentDialogs.elements.InputField;
	import com.dukascopy.connect.screens.dialogs.x.base.bottom.ListSelectionPopup;
	import com.dukascopy.connect.screens.dialogs.x.base.bottom.ScrollAnimatedTitlePopup;
	import com.dukascopy.connect.screens.payments.card.TypeCurrency;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.payments.PayManager;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.softKeyboard.SoftKeyboard;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
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
			selectorAccont = new DDAccountButton(openWalletSelector, Lang.TEXT_SELECT_ACCOUNT, true, -1);
			addItem(selectorAccont);
		}
		
		private function createBalance():void 
		{
			var balanceTexts:Vector.<String> = new Vector.<String>();
			var colors:Vector.<Number> = new Vector.<Number>();
			if (selectedDirection == TradeDirection.buy)
			{
				balanceTexts.push(Lang.to_pay_for_crypto);
				balanceTexts.push(Lang.refundable_fee.replace("%@", (EscrowSettings.refundableFee*100)));
				balanceTexts.push(Lang.amount_to_be_debited);
				
				colors.push(Style.color(Style.COLOR_SUBTITLE));
				colors.push(Style.color(Style.COLOR_SUBTITLE));
				colors.push(Color.RED);
			}
			else
			{
				balanceTexts.push(Lang.to_get_for_crypto);
				balanceTexts.push(Lang.commission_crypto.replace("%@", (EscrowSettings.commission*100)));
				balanceTexts.push(Lang.amount_to_be_credited);
				
				colors.push(Style.color(Style.COLOR_SUBTITLE));
				colors.push(Style.color(Style.COLOR_SUBTITLE));
				colors.push(Color.GREEN);
			}
			
			balance = new BalanceCalculation(balanceTexts, colors);
			addItem(balance);
		}
		
		private function createPriceSelector():void 
		{
			priceSelector = new PriceSelector(onPriceChange);
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
			var values:Vector.<String> = new Vector.<String>();
			var currency:String = getCurrency();
			
			var decimals:int = 2;
			if (PayManager.systemOptions != null && PayManager.systemOptions.currencyDecimalRules != null && !isNaN(PayManager.systemOptions.currencyDecimalRules[currencySign]))
			{
				decimals = PayManager.systemOptions.currencyDecimalRules[currencySign];
			}
			
			var amount:Number = getAmount();
			if (selectedDirection == TradeDirection.buy)
			{
				values.push((amount * selectedPrice).toFixed(decimals) + " " + currency);
				values.push((amount * selectedPrice * EscrowSettings.refundableFee).toFixed(decimals) + " " + currency);
				values.push((amount * selectedPrice * EscrowSettings.refundableFee + amount * selectedPrice).toFixed(decimals) + " " + currency);
			}
			else
			{
				values.push((amount * selectedPrice).toFixed(decimals) + " " + currency);
				values.push((amount * selectedPrice * EscrowSettings.commission).toFixed(decimals) + " " + currency);
				values.push((amount * selectedPrice - amount * selectedPrice * EscrowSettings.commission).toFixed(decimals) + " " + currency);
			}
			
			balance.draw(_width, values);
			
			updatePositions();
			updateScroll();
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
			//!TODO:;
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
			selectorCurrency = new DDFieldButton(selectCurrencyTap, "", true, NaN, null, FontSize.AMOUNT);
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
		}
		
		private function onCurrencySelected(value:EscrowInstrument):void
		{
			if (isDisposed)
			{
				return;
			}
			selectInstrument(value);
			priceSelector.draw(_width - contentPadding * 2, -5, 5, 0, selectedPrice, getCurrency());
			if (!selectedCrypto.isLinked && state != STATE_REGISTER)
			{
				toState(STATE_REGISTER);
			}
			else if (selectedCrypto.isLinked && state != STATE_START)
			{
				toState(STATE_START);
			}
			updateBalance();
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
		}
		
		private function createFinishState():void 
		{
			createSendButton();
			createBackButton();
			
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
			
			if (blockchainBack == null)
			{
				blockchainBack = new Sprite();
			}
			addItem(blockchainBack);
			
			if (blockchainAddress == null)
			{
				blockchainAddress = new Bitmap();
			}
			if (blockchainAddress.bitmapData != null)
			{
				blockchainAddress.bitmapData.dispose();
				blockchainAddress.bitmapData = null;
			}
			blockchainAddress.bitmapData = TextUtils.createTextFieldData(selectedCrypto.wallet, _width - contentPadding * 4, 10, true,
																	TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
																	FontSize.TITLE_2, true, Style.color(Style.COLOR_SUBTITLE),
																	Style.color(Style.COLOR_SEPARATOR));
			addItem(blockchainAddress);
			
			blockchainBack.graphics.clear();
			blockchainBack.graphics.beginFill(Style.color(Style.COLOR_SEPARATOR));
			blockchainBack.graphics.drawRect(0, 0, _width - contentPadding * 2, blockchainAddress.height + contentPadding * 2);
			blockchainBack.graphics.endFill();
			
			creeateTerms();
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
			var filteredAccounts:Array = getAccounts();
			
			var preselectedAccount:Object;
			if (filteredAccounts.length > 0)
			{
				preselectedAccount = filteredAccounts[0];
			}
			var preferredCurrency:String = TypeCurrency.USD;
			for (var i:int = 0; i < filteredAccounts.length; i++) 
			{
				if (filteredAccounts.CURRENCY == preferredCurrency)
				{
					preselectedAccount = filteredAccounts[i];
					break;
				}
			}
			if (preselectedAccount != null)
			{
				selectedFiatAccount = preselectedAccount;
				
				selectorAccont.setValue(selectedFiatAccount);
			}
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
			if (state == STATE_START)
			{
				var dataValid:Boolean = true;
				
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
			
			if (terms != null)
			{
				if (terms.isSelected())
				{
					offerData = new EscrowDealData();
					offerData.price = selectedPrice;
					offerData.direction = selectedDirection;
					offerData.amount = inputAmount.value;
					offerData.instrument = selectedCrypto.code;
					offerData.currency = currencySign;
					if (selectedFiatAccount != null)
					{
						offerData.accountNumber = selectedFiatAccount.ACCOUNT_NUMBER;
					}
					needCallback = true;
					close();
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
		
		private function openWalletSelector():void 
		{
			selectorAccont.valid();
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
			if (account != null)
			{
				selectedFiatAccount = account;
				selectorAccont.setValue(account);
			}
		}
			
		private function activateStartState():void 
		{
			if (selectorAccont != null)
			{
				selectorAccont.activate();
			}
			if (selectorCurrency != null)
			{
				selectorCurrency.activate();
			}
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
			registerDescriprtion.bitmapData = TextUtils.createTextFieldData(Lang.declare_blockchain, _width - contentPadding * 2, 10, true,
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
				
				if (selectedDirection == TradeDirection.buy && selectedFiatAccount == null)
				{
					selectorAccont.invalid();
					dataValid = false;
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
				
				if (dataValid)
				{
					toState(STATE_FINISH);
				}
			}
			
			/*if (dataValid())
			{
				needCallback = true;
				
				dealDetails = new EscrowDealData();
				dealDetails.price = inputPrice.value;
				dealDetails.amount = inputAmount.value;
				
				close();
			}*/
		}
		
		private function dataValid():Boolean 
		{
			//!TODO:;
			
			// state?
			// prices?
			return true;
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
			inputAmount.valid();
			updateBalance();
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			currencySign = TypeCurrency.USD;
			
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
			showDeviationControl();
			updatePositions();
			updateScroll();
			
			loadInstruments();
		}
		
		private function creeateTerms():void 
		{
			if (terms == null)
			{
				terms = new TermsChecker(onTermsChecker);
				terms.draw(_width, Lang.escrow_terms_accept, Lang.escrow_terms_link);
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
			if (isDisposed)
			{
				return;
			}
			GD.S_ESCROW_INSTRUMENTS.remove(instrumentsLoaded);
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
					hidePreloader();
					onDataReady();
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
				
				if (selectorAccont != null)
				{
					selectorAccont.x = contentPadding;
					selectorAccont.y = position;
					position += selectorAccont.height + contentPaddingV;
				}
				
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
				
				if (terms != null)
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
				
				if (getHeight() - bottomButton.height - contentPadding - balance.height - scrollPanel.view.y - contentPaddingV > position)
				{
					balance.y = getHeight() - bottomButton.height - contentPadding - balance.height - scrollPanel.view.y - contentPaddingV;
				}
				
				bottomButton.x = contentPadding;
				bottomButton.y = int(getHeight() - bottomButton.height - contentPadding);
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
				position = Config.FINGER_SIZE * .3;
				
				blockchainTitle.x = contentPadding;
				blockchainTitle.y = position;
				position += blockchainTitle.height + contentPaddingV * .3;
				
				blockchainBack.x = contentPadding;
				blockchainBack.y = position;
				blockchainAddress.x = contentPadding * 2;
				blockchainAddress.y = position + contentPadding;
				position += blockchainBack.height + contentPaddingV * 2;
				
				terms.x = contentPadding;
				terms.y = position;
				position += terms.height + contentPaddingV * 2;
				
				balance.x = int(_width * .5 - balance.width * .5);
				balance.y = position;
				
				if (getHeight() - nextButton.height - contentPadding - balance.height - scrollPanel.view.y - contentPaddingV > position)
				{
					balance.y = getHeight() - nextButton.height - contentPadding - balance.height - scrollPanel.view.y - contentPaddingV;
				}
				
				backButton.x = contentPadding;
				backButton.y = int(getHeight() - nextButton.height - contentPadding);
				
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
			radio.select(radioSelection[0]);
			
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
				selectInstrument(instruments[0]);
			}
			else
			{
				ApplicationErrors.add();
			}
			if (selectedDirection == TradeDirection.buy)
			{
				selectDefaultAccount();
			}
			else
			{
				if (priceSelector != null)
				{
					if (selectedCrypto != null)
					{
						selectCurrencyFromPrices();
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
			
			refreshPrice();
		}
		
		private function refreshPrice():void 
		{
			updatePrice();
			if (state == STATE_START)
			{
				priceSelector.draw(_width - contentPadding * 2, -5, 5, 0, selectedPrice, getCurrency());
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
				accounts = new PaymentsAccountsProvider(onAccountsReady, false, onAccountsFail);
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
		
		private function updatePrice():void 
		{
			var price:Number = getPrice();
			if (!isNaN(price))
			{
				setPrice(price);
				inputPrice.value = selectedPrice;
				
				var underlineText:String = Lang.current_price_of_instrument.replace(Lang.regExtValue, getInstrument()) + " = " + price + " " + getCurrency();
				inputPrice.drawUnderlineValue(underlineText);
			}
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
								}
							}
							if (isNaN(price) && selectedCrypto.price.length > 0)
							{
								currencySign = selectedCrypto.price[0].name;
								price = selectedCrypto.price[0].value;
							}
						}
					}
				}
				else if (selectedDirection == TradeDirection.sell)
				{
					if (currencySign != null)
					{
						var selectedPrice:EscrowPrice;
						for (var k:int = 0; k < selectedCrypto.price.length; k++) 
						{
							if (selectedCrypto.price[k].name == currencySign)
							{
								selectedPrice = selectedCrypto.price[k];
								break;
							}
						}
						if (selectedPrice != null)
						{
							price = selectedPrice.value;
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
			terms.deactivate();
		}
		
		override protected function onRemove():void 
		{
			if (needCallback == true)
			{
				needCallback = false;
				if (data != null && "callback" in data && data.callback != null && data.callback is Function && (data.callback as Function).length == 1 && offerData != null)
				{
					(data.callback as Function)(offerData);
				}
				offerData = null;
			}
		}
		
		override public function dispose():void {
			super.dispose();
			
			GD.S_ESCROW_INSTRUMENTS.remove(instrumentsLoaded);
			
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
			
			selectedFiatAccount = null;
			selectedCrypto = null;
			radioSelection = null;
		}
	}
}