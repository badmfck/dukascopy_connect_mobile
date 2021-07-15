package com.dukascopy.connect.sys.bankManager {
	
	import assets.ExchangeIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.GD;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.CoinTradeOrder;
	import com.dukascopy.connect.data.GiftData;
	import com.dukascopy.connect.data.OrderScreenData;
	import com.dukascopy.connect.data.PopupData;
	import com.dukascopy.connect.data.TradeNotesRequest;
	import com.dukascopy.connect.data.coinMarketplace.MarketplaceScreenData;
	import com.dukascopy.connect.data.coinMarketplace.TradingOrder;
	import com.dukascopy.connect.data.coinMarketplace.TradingOrderRequest;
	import com.dukascopy.connect.data.screenAction.customActions.SendTradeNotesRequestAction;
	import com.dukascopy.connect.data.voiceCommand.VoiceCommand;
	import com.dukascopy.connect.data.voiceCommand.VoiceCommandType;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.components.textEditors.FullscreenTextEditor;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.renderers.ListPayCurrency;
	import com.dukascopy.connect.screens.BankBotChatScreen;
	import com.dukascopy.connect.screens.MyAccountScreen;
	import com.dukascopy.connect.screens.UserProfileScreen;
	import com.dukascopy.connect.screens.dialogs.CreateTemplateDialog;
	import com.dukascopy.connect.screens.dialogs.CreateTemplateDialog;
	import com.dukascopy.connect.screens.dialogs.ScreenAddInvoiceDialog;
	import com.dukascopy.connect.screens.dialogs.ScreenPayDialog;
	import com.dukascopy.connect.screens.dialogs.x.base.bottom.ListSelectionPopup;
	import com.dukascopy.connect.screens.dialogs.x.base.content.ShareLinkPopup;
	import com.dukascopy.connect.screens.dialogs.gifts.CreateGiftPopup;
	import com.dukascopy.connect.screens.dialogs.paymentDialogs.BuyCommodityPopup;
	import com.dukascopy.connect.screens.dialogs.paymentDialogs.CoinsDepositPopup;
	import com.dukascopy.connect.screens.dialogs.paymentDialogs.DepositFromCardPopup;
	import com.dukascopy.connect.screens.dialogs.paymentDialogs.MoneyExchangePopup;
	import com.dukascopy.connect.screens.dialogs.paymentDialogs.PaymentsLoginScreen;
	import com.dukascopy.connect.screens.dialogs.paymentDialogs.RewardsDepositPopupNew;
	import com.dukascopy.connect.screens.dialogs.paymentDialogs.ScreenPayPassDialogNew;
	import com.dukascopy.connect.screens.dialogs.paymentDialogs.SellCommodityPopup;
	import com.dukascopy.connect.screens.dialogs.paymentDialogs.SendCoinsByPhonePopup;
	import com.dukascopy.connect.screens.dialogs.paymentDialogs.SendCoinsPopup;
	import com.dukascopy.connect.screens.dialogs.paymentDialogs.SendMoneyByPhonePopup;
	import com.dukascopy.connect.screens.dialogs.paymentDialogs.TradeCoinPopup;
	import com.dukascopy.connect.screens.dialogs.paymentDialogs.TradeCoinsExtendedPopup;
	import com.dukascopy.connect.screens.dialogs.paymentDialogs.TradeNotesPopup;
	import com.dukascopy.connect.screens.dialogs.paymentDialogs.TransactionPresetsPopup;
	import com.dukascopy.connect.screens.dialogs.paymentDialogs.WithdrawalPopup;
	import com.dukascopy.connect.screens.marketplace.CoinMarketplace;
	import com.dukascopy.connect.screens.marketplace.MyOrdersScreen;
	import com.dukascopy.connect.screens.payments.OrderCardScreen;
	import com.dukascopy.connect.screens.WebViewScreen;
	import com.dukascopy.connect.screens.payments.settings.PaymentsSettingsVerificationLimitsScreen;
	import com.dukascopy.connect.screens.serviceScreen.BottomTimeSelectionScreen;
	import com.dukascopy.connect.screens.serviceScreen.SelectContactExtendedScreen;
	import com.dukascopy.connect.screens.serviceScreen.SelectContactScreen;
	import com.dukascopy.connect.sys.Gifts;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.configManager.ConfigManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.nativeExtensionController.NativeExtensionController;
	import com.dukascopy.connect.sys.payments.InvoiceManager;
	import com.dukascopy.connect.sys.payments.PayAPIManager;
	import com.dukascopy.connect.sys.payments.PayInvestmentsManager;
	import com.dukascopy.connect.sys.payments.PayManager;
	import com.dukascopy.connect.sys.payments.PayRespond;
	import com.dukascopy.connect.sys.payments.PaymentsManager;
	import com.dukascopy.connect.sys.payments.vo.AccountInfoVO;
	import com.dukascopy.connect.sys.payments.vo.AccountLimit;
	import com.dukascopy.connect.sys.payments.vo.AccountLimitVO;
	import com.dukascopy.connect.sys.payments.vo.SystemOptionsVO;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.store.Store;
	import com.dukascopy.connect.type.ChatInitType;
	import com.dukascopy.connect.type.GiftType;
	import com.dukascopy.connect.type.InvoiceStatus;
	import com.dukascopy.connect.type.OperationType;
	import com.dukascopy.connect.utils.DateUtils;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.connect.vo.BankMessageVO;
	import com.dukascopy.connect.vo.chat.ChatMessageInvoiceData;
	import com.dukascopy.connect.vo.screen.ChatScreenData;
	import com.dukascopy.connect.vo.users.UserVO;
	import com.dukascopy.langs.Lang;
	import com.dukascopy.langs.LangManager;
	import com.greensock.TweenMax;
	import com.telefision.sys.signals.Signal;
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.globalization.StringTools;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class BankManager {
		
		static public var S_ANSWER:Signal = new Signal('BankManager.S_ANSWER');
		static public var S_HISTORY:Signal = new Signal('BankManager.S_HISTORY');
		static public var S_HISTORY_MORE:Signal = new Signal('BankManager.S_HISTORY_MORE');
		static public var S_HISTORY_TRADES:Signal = new Signal('BankManager.S_HISTORY_TRADES');
		static public var S_HISTORY_TS_ERROR:Signal = new Signal('BankManager.S_HISTORY_TS_ERROR');
		static public var S_INVESTMENT_HISTORY:Signal = new Signal('BankManager.S_INVESTMENT_HISTORY');
		static public var S_INVESTMENT_DETAIL:Signal = new Signal('BankManager.S_INVESTMENT_DETAIL');
		static public var S_WALLETS:Signal = new Signal('BankManager.S_WALLETS');
		static public var S_INVESTMENTS:Signal = new Signal('BankManager.S_INVESTMENTS');
		static public var S_CRYPTO:Signal = new Signal('BankManager.S_CRYPTO');
		static public var S_CRYPTO_RD:Signal = new Signal('BankManager.S_CRYPTO_RD');
		static public var S_CRYPTO_DEALS:Signal = new Signal('BankManager.S_CRYPTO');
		static public var S_TRADE_COMPLETE:Signal = new Signal('BankManager.S_TRADE_COMPLETE');
		static public var S_CARDS:Signal = new Signal('BankManager.S_CARDS');
		static public var S_ALL_DATA:Signal = new Signal('BankManager.S_ALL_DATA');
		static public var S_ERROR:Signal = new Signal('BankManager.S_ERROR');
		static public var S_PAYMENT_ERROR:Signal = new Signal('BankManager.S_PAYMENT_ERROR');
		static public var S_ADDITIONAL_DATA_ENTERED:Signal = new Signal('BankManager.S_ADDITIONAL_DATA_ENTERED');
		static public var S_REMOVE_MAIN_MENU:Signal = new Signal('BankManager.S_REMOVE_MAIN_MENU');
		static public var S_LAST_ACTIVATE:Signal = new Signal('BankManager.S_LAST_ACTIVATE');
		static public var S_MENU_HIDE:Signal = new Signal('BankManager.S_MENU_HIDE');
		static public var S_TOTAL:Signal = new Signal('BankManager.S_TOTAL');
		static public var S_OFFER_CREATED:Signal = new Signal('BankManager.S_OFFER_CREATED');
		static public var S_CRYPTO_EXISTS:Signal = new Signal('BankManager.S_CRYPTO_EXISTS');
		static public var S_ORDER_REMOVED:Signal = new Signal('BankManager.S_ORDER_REMOVED');
		static public var S_POSSIBLE_RD:Signal = new Signal('BankManager.S_POSSIBLE_RD');
		static public var S_DECLARE_ETH_LINK:Signal = new Signal('BankManager.S_DECLARE_ETH_LINK');
		
		static public const PWP_NOT_ENTERED:String = "pwpNotEntered";
		static public const ACCOUNT_NOT_APPROVED:String = "accountNotApproved";
		
		static public var balanceOpened:Boolean;
		
		static public var rewardAccount:String = "1026009";
		static public var blockchainConditionsURL:String = "https://www.dukascoin.com";
		
		static public var fiatMin:Number = 1000;
		static public var fiatMax:Number = 100000;
		static public var coinMax:Number = 25000;
		
		static private var _initData:Object;
		
		static private var historyAcc:String;
		static private var historyAccIBAN:String;
		static private var historyAccCurrency:String;
		static private var isCardHistory:Boolean;
		static private var isInvestmentHistory:Boolean;
		static private var history:Object;
		static private var tsHistory:Object;
		static private var investmentDetails:Object;
		static private var wallets:Array;
		static private var cryptoAccounts:Array;
		static private var cryptoBCAccounts:Array;
		static private var cryptoRDs:Array;
		static private var cryptoDeals:Object;
		
		static private var bankMessages:Array/*BankMessageVO*/;
		static private var cacheBankMessages:Array;
		static private var lastBankMessageVO:BankMessageVO;
		
		static private var currentTransaction:Object;
		
		static private var initialized:Boolean;
		static private var total:Object;
		static private var totalAll:Array;
		
		static private var needToGetHistoryUser:String;
		static private var needToShowHistoryWallet:String;
		
		static private var accountInfo:AccountInfoVO;
		static private var cards:Array;
		static private var fatCatz:Object;
		static private var otherAccounts:Array;
		static private var savingsAccounts:Array;
		static private var investments:Array;
		static private var cardMasked:String;
		static private var waitingBMVO:BankMessageVO;
		static private var cardsLoaded:Boolean;
		static private var fatCatzLoaded:Boolean;
		static private var otherAccountLoaded:Boolean;
		static private var savingsAccountLoaded:Boolean;
		static private var cryptoOffersLoaded:Boolean;
		static private var cryptoAccountsLoaded:Boolean;
		static private var cryptoRDLoaded:Boolean;
		
		static private var inProgress:Boolean;
		static private var _lastMainIndex:int;
		static private var _cryptoExists:Boolean;
		
		static private var selectedData:Object;
		static private var lastTransactionData:Object;
		
		static private var transactionTemplates:Array;
		
		static private var cardIssueAvailable:Boolean;
		
		static private var needToCash:Boolean;
		static private var investmentExist:Boolean = false;
		
		public function BankManager() { }
		
		static public function init():void {
			if (initialized == true)
				return;
			
			Store.load("transactionTemplates", onTemplatesLoaded);
			
			initialized = true;
			BankBotController.S_ANSWER.add(onAnswerReceived);
			Auth.S_NEED_AUTHORIZATION.add(clear);
			PayAPIManager.S_SESSION_LOCKED.add(onSessionLocked);
			PayManager.S_SYSTEM_OPTIONS_READY.add(onSystemOptionsReady);
			
			sendMessage("system:lang:" + LangManager.model.getCurrentLanguageID());
			S_OFFER_CREATED.add(updateMarketplace);
			
			Store.load(Store.CRYPTO_EXISTS, onCryptoExistLoaded);
		}
		
		static private function onSystemOptionsReady():void {
			var so:SystemOptionsVO = PayManager.systemOptions;
			if (so.investmentsByGroups == null)
				return;
			var scenario:BankBotScenario = BankBotController.getScenario();
			var menuItemsGroups:Array;
			var menuItemsInner:Array;
			var label:String;
			var selectInvestments:Object;
			for (var n:String in so.investmentsByGroups) {
				label = n.substr(0, 1).toUpperCase() + n.substr(1).toLowerCase();
				menuItemsGroups ||= [];
				menuItemsGroups.push( {
					text:"lang.investmentsGroups." + n.toLowerCase(),
					action:"nav:select" + label
				} );
				if ("select" + label in scenario.scenario == false) {
					scenario.scenario["select" + label] = {
						desc:"lang.investmentBuySelectDesc." + n.toLowerCase(),
						menuLayout:"vertical",
						menu:[],
						buttons: [
							{
								text:"lang.buttonBack",
								action:"cmd:back"
							}, {
								text:"lang.buttonCancel",
								action:"system:cancel"
							}
						]
					};
				} else {
					scenario.scenario["select" + label].desc = "lang.investmentBuySelectDesc." + n.toLowerCase();
				}
				menuItemsInner = [];
				for (var i:int = 0; i < so.investmentsByGroups[n].length; i++) {
					menuItemsInner.push( {
						text:"lang.investmentLabel." + so.investmentsByGroups[n][i].toUpperCase(),
						value:so.investmentsByGroups[n][i].toUpperCase(),
						type:"paymentsInvestments",
						textForUser1:"lang.itemInvestmentBuy1",
						textForUser2:"lang.itemInvestmentBuy2",
						action:"nav:investmentConfirm"
					} );
				}
				scenario.scenario["select" + label].menu = menuItemsInner;
			}
			scenario.scenario.investMoney.menu = menuItemsGroups;
		}
		
		static private function onTemplatesLoaded(data:Object, err:Boolean):void {
			if (err == true || data == null) {
				transactionTemplates = [];
				return;
			}
			if (data.length != 0)
				delete BankBotController.getScenario().scenario.sendMoney.menu[1].disabled;
			transactionTemplates = data as Array;
		}
		
		static private function onSessionLocked():void {
			clear();
		}
		
		static private function onCryptoExistLoaded(data:Object, err:Boolean):void {
			if (data == true)
				_cryptoExists = true;
			S_CRYPTO_EXISTS.invoke();
		}
		
		static private function updateMarketplace(data:Object = null):void {
			refreshCryptoBoard();
		}
		
		static private function clear():void {
			initialized = false;
			BankBotController.S_ANSWER.remove(onAnswerReceived);
			Auth.S_NEED_AUTHORIZATION.remove(clear);
			PayAPIManager.S_SESSION_LOCKED.remove(onSessionLocked);
			S_OFFER_CREATED.remove(updateMarketplace);
			_initData = null;
			
			needToCash = false;
			historyAcc = null;
			historyAccIBAN = null;
			historyAccCurrency = null;
			isCardHistory = false;
			isInvestmentHistory = false;
			history = null;
			tsHistory = null;
			investmentDetails = null;
			wallets = null;
			savingsAccounts = null;
			otherAccounts = null;
			
			bankMessages = null;
			cacheBankMessages = null;
			lastBankMessageVO = null;
			
			currentTransaction = null;
			
			initialized = false;
			total = null;
			totalAll = null;
			
			needToGetHistoryUser = null;
			needToShowHistoryWallet = null;
			
			accountInfo = null;
			
			PayManager.accountInfo = null;
			
			cards = null;
			investments = null;
			cardMasked = null;
			waitingBMVO = null;
			cardsLoaded = false;
			cryptoOffersLoaded = false;
			cryptoAccountsLoaded = false;
			cryptoRDLoaded = false;
			savingsAccountLoaded = false;
			otherAccountLoaded = false;
			
			inProgress = false;
			_lastMainIndex = 0;
			
			BankBotController.reset();
		}
		
		static public function openChatBotScreen(data:Object, newSession:Boolean = false):void {
			if (newSession == true) {
				_lastMainIndex = 0;
				closeBankChatBotSession();
				_initData = data;
			}
			var backScreen:Class = MobileGui.centerScreen.currentScreenClass;
			var backScreenData:Object = MobileGui.centerScreen.currentScreen.data;
			if (data != null && "backScreen" in data && data.backScreen != null) {
				backScreen = data.backScreen as Class;
				backScreenData = null;
			}
			MobileGui.changeMainScreen(
				BankBotChatScreen,
				{
					backScreen:backScreen,
					backScreenData:backScreenData
				}
			);
		}
		
		static public function startBankChat(command:String = null):void {
			init();
			sendInitialDataMessage();
			if (inProgress == true) {
				for (var i:int = 0; i < bankMessages.length; i++)
					invokeAnswerSignal(bankMessages[i], false);
				if (command != null) {
					sendMessage(command);
				} else if (bankMessages[bankMessages.length - 1].disabled == true)
					bankMessages[bankMessages.length - 1].enable();
				return;
			}
			var msgDisplay:String;
			var msg:String;
			if (_initData == null) {
				msgDisplay = Lang.showMeMainMenu;
				msg = "nav:main";
			} else if ("transactionID" in _initData == true && _initData.transactionID != null) {
				msgDisplay = Lang.showMeCurrentTransactionMenu;
				if ("action" in _initData == true && _initData.action != null && _initData.action != "") {
					msg = "nav:" + _initData.action;
				} else {
					if (_initData.mine == true) {
						if (_initData.user != null)
							msg = "nav:transactionOut";
						else
							msg = "nav:transactionOutNoUser";
					} else {
						if (_initData.user != null)
							msg = "nav:transactionIn";
						else
							msg = "nav:transactionInNoUser";
					}
				}
			} else if ("bankBot" in _initData == true && _initData.bankBot == true) {
				msgDisplay = Lang.showMeMainMenu;
				msg = "nav:main";
			} else if ("investmentDisclaimer" in _initData == true && _initData.investmentDisclaimer == true) {
				msgDisplay = Lang.showMeInvestmentMenu;
				msg = "nav:investments";
			} else if ("investmentOps" in _initData == true && _initData.investmentOps == true) {
				sendMessage("nav:investmentOperationsAdd:" + _initData.investmentAcc.ACCOUNT_NUMBER + "|!|" + _initData.investmentAcc.INSTRUMENT);
			}
			if (msgDisplay != null) {
				var baVO:BankMessageVO = new BankMessageVO(msgDisplay);
				baVO.setMine();
				invokeAnswerSignal(baVO);
			}
			PayManager.callGetSystemOptions(function():void {
				sendMessage(msg);
			} );
		}
		
		static private function sendInitialDataMessage():void {
			if (_initData == null)
				return;
			if ("transactionID" in _initData == true && _initData.transactionID != null)
				S_ANSWER.invoke(_initData);
		}
		
		static public function preSendMessage(data:Object, needToSendMessage:Boolean = true):void {
			var msg:String = data.action;
			var baVO:BankMessageVO;
			if ("type" in data && data.type != null && data.type != "") {
				var giftData:GiftData;
				if (data.type == "orderCards") {
					if (cardIssueAvailable == false) {
						DialogManager.alert(Lang.information, Lang.cardIssueNotAvailable);
						return;
					}
					data["tapped"] = true;
					baVO = new BankMessageVO(data.text);
					baVO.setMine();
					invokeAnswerSignal(baVO);
					sendMessage(msg);
					return;
				}
				if (data.type == "BCCheckETH") {
					if (lastBankMessageVO == null || lastBankMessageVO.additionalData == null)
						return;
					navigateToURL(new URLRequest(Lang.textBlockchainInfoURL + lastBankMessageVO.additionalData.storage_address));
					return;
				}
				if (data.type == "saveTemplate") {
					DialogManager.showDialog(CreateTemplateDialog, { title:Lang.enterTemplateName, data:lastTransactionData, callBack:onSaveTemplate } );
					return;
				}
				if (data.type == "enterTransactionCode") {
					DialogManager.showSecureCode(callbackEnderCode, true, true, "", data);
					return;
				}
				if (data.type == "coinTradeStat") {
					data["tapped"] = true;
					baVO = new BankMessageVO(data.text);
					baVO.setMine();
					invokeAnswerSignal(baVO);
					sendMessage("val:" + data.value);
					sendMessage(msg);
					return;
				}
				if (data.type == "cardPin") {
					data["tapped"] = true;
					S_ADDITIONAL_DATA_ENTERED.invoke();
					sendMessage(msg + ":" + data.value);
					return;
				}
				if (data.type == "cryptoSB") {
					data["tapped"] = true;
					baVO = new BankMessageVO(data.text);
					baVO.setMine();
					invokeAnswerSignal(baVO);
					sendMessage("val:" + data.value);
					sendMessage(msg);
					return;
				}
				if (data.type == "showCryptoRDs") {
					data["tapped"] = true;
					S_ADDITIONAL_DATA_ENTERED.invoke();
					sendMessage("val:" + data.value);
					sendMessage(msg);
					return;
				}
				if (data.type == "showAcc") {
					data["tapped"] = true;
					S_ADDITIONAL_DATA_ENTERED.invoke();
					sendMessage("val:" + data.value);
					sendMessage(msg);
					return;
				}
				if (data.type == "otherWithdrawal") {
					data["tapped"] = true;
					S_ADDITIONAL_DATA_ENTERED.invoke();
					sendMessage("val:" + data.value);
					sendMessage(msg);
					return;
				}
				if (data.type == "otherWithdrawalWire") {
					data["tapped"] = true;
					S_ADDITIONAL_DATA_ENTERED.invoke();
					sendMessage("val:WIRE|!|" + data.value);
					sendMessage(msg);
					return;
				}
				if (data.type == "paymentsDeposit") {
					data["tapped"] = true;
					S_ADDITIONAL_DATA_ENTERED.invoke();
					sendMessage("val:" + data.value);
					sendMessage(msg);
					return;
				}
				if (data.type == "walletSelectWithoutTotal") {
					data["tapped"] = true;
					S_ADDITIONAL_DATA_ENTERED.invoke();
					sendMessage("val:" + data.param.ACCOUNT_NUMBER + "|!|" + data.param.CURRENCY);
					sendMessage(msg);
					return;
				}
				if (data.type == "marketPrice") {
					if ("value" in data == true) {
						if (data.value == "1") {
							showCryptoSellBuyPopup(1);
							return;
						} else if (data.value == "0") {
							showCryptoSellBuyPopup(2);
							return;
						}
					}
					return;
				}
				if (data.type == "BCDeposite" || data.type == "BCWithdrawal" || data.type == "BCDepositeAddress" || data.type == "BCWithdrawalInvestment") {
					giftData = new GiftData();
					giftData.additionalData = data;
					if (_initData != null) {
						if ("acc" in _initData == true)
							giftData.currency = _initData.acc;
						if ("amount" in _initData == true)
							giftData.customValue = Math.abs(_initData.amount);
					}
					var title:String = "";
					var desc:String = "";
					var bcAddressReq:String = "";
					if (data.type == "BCDepositeAddress") {
						giftData.type = 0;
						title = "coinsDeposit";
						desc = "myBlockcheinAddress";
						bcAddressReq = "blockchainAddressNeeded";
					} else if (data.type == "BCDeposite") {
						giftData.txTransaction = data.value.split("|!|");
						giftData.type = 2;
						title = "coinsDeposit";
						desc = "myBlockcheinAddress";
						bcAddressReq = "blockchainAddressNeeded";
					} else if (data.type == "BCWithdrawalInvestment") {
						giftData.type = 3;
						title = "deliveryToBC";
						desc = "deliveryToBCAddress";
						bcAddressReq = "deliveryToBCAddressNeeded";
					} else {
						giftData.type = 1;
						title = "coinsWithdrawal";
						desc = "selectedBlockchainAddress";
						bcAddressReq = "blockchainAddressNeeded";
					}
					if (giftData.type == 3) {
						if (accountInfo == null) {
							getWallets(false);
							loading = true;
							return;
						}
						giftData.wallets = [getInvestmentByAccount(data.selectionAcc)];
						giftData.cards = accountInfo.accounts;
						giftData.callback = onInvestmentsBCWCallback;
					} else {
						giftData.wallets = cryptoAccounts;
						giftData.callback = onCryptoBCDWCallback;
					}
					ServiceScreenManager.showScreen(
						ServiceScreenManager.TYPE_DIALOG,
						CoinsDepositPopup,
						{
							giftData: giftData,
							title:title,
							description:desc,
							addrNeed:bcAddressReq
						}
					);
					return;
				}
				if (data.type == "cryptoMyDeals") {
					var mpsd:MarketplaceScreenData = new MarketplaceScreenData();
					mpsd.dataProvider = getCryptoBoard;
					mpsd.myOrders = getCryptoDealAccounts;
					mpsd.resreshFunction = refreshCryptoBoard;
					mpsd.updateSignal = S_CRYPTO_DEALS;
					MobileGui.changeMainScreen(
						MyOrdersScreen,
						{
							backScreen:MobileGui.centerScreen.currentScreenClass,
							backScreenData:MobileGui.centerScreen.currentScreen.data,
							screeenData:mpsd
						}
					);
					return;
				}
				if (data.type == "cryptoHistory") {
					if (cryptoAccounts == null || cryptoAccounts.length == 0)
						return;
					showHistoryByCoinAccountNumber(cryptoAccounts[0]);
					if (MobileGui.centerScreen.currentScreen.data.backScreen != MyAccountScreen) {
						MobileGui.changeMainScreen(MyAccountScreen);
						return;
					}
					MobileGui.S_BACK_PRESSED.invoke();
					return;
				}
				if (data.type == "moneySendPhone") {
					giftData = new GiftData();
					giftData.additionalData = data;
					if (_initData != null) {
						if ("phone" in _initData == true)
							giftData.credit_account_number = _initData.phone;
						if ("acc" in _initData == true)
							giftData.currency = _initData.acc;
						if ("amount" in _initData == true)
							giftData.customValue = Math.abs(_initData.amount);
					}
					giftData.callback = onMoneySendPhoneCallback;
					ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_DIALOG, SendMoneyByPhonePopup, { giftData: giftData } );
				} else if (data.type == "cryptoSendPhone") {
					giftData = new GiftData();
					giftData.additionalData = data;
					if (_initData != null) {
						if ("phone" in _initData == true)
							giftData.credit_account_number = _initData.phone;
						if ("acc" in _initData == true)
							giftData.currency = _initData.acc;
						if ("amount" in _initData == true)
							giftData.customValue = Math.abs(_initData.amount);
					}
					giftData.wallets = cryptoAccounts;
					giftData.callback = onMoneySendPhoneCallback;
					ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_DIALOG, SendCoinsByPhonePopup, { giftData: giftData } );
				} else if (data.type == "cryptoRewardDeposite") {
					giftData = new GiftData();
					giftData.additionalData = data;
					if (_initData != null) {
						if ("acc" in _initData == true)
							giftData.currency = _initData.acc;
						if ("amount" in _initData == true)
							giftData.customValue = Math.abs(_initData.amount);
					}
					giftData.type = int(data.value);
					if (giftData.type == 0) {
						giftData.minAmount = BankBotController.rewards[0].amount;
						giftData.maxAmount = checkForMaxDepositeLimit();
						giftData.fiatReward = false;
					} else {
						giftData.minAmount = fiatMin;
						giftData.maxAmount = checkForMaxDepositeLimit(true);
						giftData.fiatReward = true;
					}
					if (cryptoBCAccounts != null)
						giftData.wallets = cryptoAccounts.concat(cryptoBCAccounts);
					else
						giftData.wallets = cryptoAccounts;
					giftData.callback = onCryptoDepositeCallback;
					ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_DIALOG, RewardsDepositPopupNew, { giftData: giftData } );
				} else if (data.type == "createCryptoOffer") {
					var screenData:OrderScreenData = new OrderScreenData();
					screenData.additionalData = data;
					screenData.title = Lang.newSellCoinLot;
					if (data.value == 0) {
						screenData.type = TradingOrder.SELL;
					} else {
						screenData.type = TradingOrder.BUY;
					}
					screenData.orders = null;
					screenData.callback = onCryptoOfferCallback;
					ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_DIALOG, TradeCoinPopup, screenData);
				} else if (data.type == "editCryptoOffer") {
					var screenData1:OrderScreenData = new OrderScreenData();
					screenData1.additionalData = data;
					screenData1.title = Lang.newSellCoinLot;
					if (data.value == 0) {
						screenData1.type = TradingOrder.SELL;
					} else {
						screenData1.type = TradingOrder.BUY;
					}
					screenData1.orders = [getCryptoDealByUID(data.value)];
					screenData1.callback = onCryptoOfferEditCallback;
					ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_DIALOG, TradeCoinPopup, screenData1);
				} else if (data.type == "paymentsSend") {
					giftData = new GiftData();
					giftData.additionalData = data;
					giftData.type = GiftType.MONEY_TRANSFER_CALLBACK;
					if ("user" in _initData == true && _initData.user != null)
						giftData.user = _initData.user;
					if ("acc" in _initData == true && _initData.acc != null && _initData.acc != "")
						giftData.currency = _initData.acc;
					if ("amount" in _initData == true && isNaN(_initData.amount) == false)
						giftData.customValue = Math.abs(_initData.amount);
					if ("desc" in _initData == true && _initData.desc != null && _initData.desc != "")
						giftData.comment = _initData.desc;
					giftData.callback = onMoneySendCallback;
					Gifts.startSendMoney(giftData);
				} else if (data.type == "invoiceSend") {
					if (_initData == null)
						ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, ScreenAddInvoiceDialog, {callback:callBackAddInvoice, additionalData:data}, 0.5, 0.5, 3);
					else
						ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, ScreenAddInvoiceDialog, {amount:_initData.amount, currency:_initData.acc, message:_initData.desc, callback:callBackAddInvoice, additionalData:data}, 0.5, 0.5, 3);
				} else if (data.type == "paymentsSendMy") {
					PayManager.callGetSystemOptions(function():void {
						giftData = new GiftData();
						giftData.additionalData = data;
						giftData.callback = onMoneyTransferCallback;
						if (_initData != null && "transaction" in _initData && _initData.transaction != null) {
							if ("AMOUNT" in _initData.transaction)
								giftData.customValue = Number(_initData.transaction.AMOUNT);
							if ("CURRENCY" in _initData.transaction)
								giftData.currency = _initData.transaction.CURRENCY;
							if ("FROM" in _initData.transaction)
								giftData.accountNumber = _initData.transaction.FROM;
							if ("TO" in _initData.transaction)
								giftData.credit_account_number = _initData.transaction.TO;
						}
						// REGULAR EXCHANGE;
						if (data.value == "MCA") {
							giftData.fromAccounts = PayManager.accountInfo.accounts;
							giftData.toAccounts = PayManager.accountInfo.accounts;
							giftData.transferType = OperationType.MCA_MONEY_EXCHANGE;
						} else if (data.value == "SAVINGS") {
							giftData.fromAccounts = savingsAccounts;
							giftData.toAccounts = savingsAccounts;
							giftData.transferType = OperationType.SAVING_MONEY_EXCHANGE;
						}
						giftData.currencies = PayManager.systemOptions.currencyList;
						ServiceScreenManager.showScreen(
							ServiceScreenManager.TYPE_DIALOG,
							MoneyExchangePopup, {
								icon:ExchangeIcon,
								titleText:Lang.TEXT_EXCHANGE,
								fromText:Lang.exchangeDebit,
								toText:Lang.exchangeCredit,
								giftData:giftData
							}
						);
					} );
				} else if (data.type == "sendMoneyOtherAcc") {
					// FROM MCA TO SAVING ACCOUNT;
					PayManager.callGetSystemOptions(function():void {
						giftData = new GiftData();
						giftData.additionalData = data;
						giftData.callback = onMoneyTransferCallback;
						var textFrom:String = Lang.fromSavingAccount;
						var textTo:String = Lang.toMultiAccount;
						var title:String = Lang.TEXT_DEPOSIT;
						if (data.value == "SAVINGS") {
							textFrom = Lang.fromMultiAccount;
							textTo = Lang.toSavingAccount;
							title = Lang.TEXT_WITHDRAWAL
							giftData.fromAccounts = PayManager.accountInfo.accounts;
							giftData.toAccounts = savingsAccounts;
							giftData.transferType = OperationType.SAVING_MONEY_TRANSFER;
						} else if (data.value == "TRADING") {
							textFrom = Lang.fromMultiAccount;
							textTo = Lang.toTradingAccount;
							title = Lang.TEXT_WITHDRAWAL;
							giftData.currencyAvaliable = false;
							giftData.fromAccounts = PayManager.accountInfo.accounts;
							giftData.toAccounts = removeCryptoAccounts(otherAccounts);
							giftData.transferType = OperationType.SAVING_MONEY_TRANSFER;
						} else if (data.value == "SMCA") {
							giftData.fromAccounts = savingsAccounts;
							giftData.toAccounts = PayManager.accountInfo.accounts;
							giftData.transferType = OperationType.MCA_MONEY_TRANSFER;
						} else if (data.value == "TMCA") {
							textFrom = Lang.fromTradingAccount;
							giftData.currencyAvaliable = false;
							giftData.fromAccounts = removeCryptoAccounts(otherAccounts);
							giftData.toAccounts = PayManager.accountInfo.accounts;
							giftData.transferType = OperationType.MCA_MONEY_TRANSFER;
						}
						ServiceScreenManager.showScreen(
							ServiceScreenManager.TYPE_DIALOG,
							MoneyExchangePopup, {
								titleText:title,
								fromText:textFrom,
								toText:textTo,
								giftData:giftData
							}
						);
					} );
				} else if (data.type == "depositesCard") {
					PayManager.callGetSystemOptions(function():void {
						giftData = new GiftData();
						if ("value" in data == true && data.value != null && data.value != "" && data.value != "@@1")
							giftData.currency = data.value;
						giftData.additionalData = data;
						giftData.callback = onCardDepositCallback;
						giftData.cards = getAllCards();
						
						giftData.currencies = PayManager.systemOptions.cardDepositCurrencies;
						ServiceScreenManager.showScreen(
							ServiceScreenManager.TYPE_DIALOG,
							DepositFromCardPopup,
							{ 
								giftData:giftData
							}
						);
					} );
				} else if (data.type == "paymentsInvestments") {
					giftData = new GiftData();
					giftData.additionalData = data;
					if ("value" in data == true && data.value != null && data.value != "")
						giftData.currency = data.value;
					giftData.callback = onInvestmentCallback;
					ServiceScreenManager.showScreen(
						ServiceScreenManager.TYPE_DIALOG,
						BuyCommodityPopup,
						{ 
							giftData:giftData
						}
					);
				} else if (data.type == "paymentsInvestmentsTransaction") {
					if (_initData == null || "transaction" in _initData == false || _initData.transaction == null)
						return;
					giftData = new GiftData();
					giftData.additionalData = data;
					giftData.callback = onInvestmentCallback;
					if ("AMOUNT" in _initData.transaction) {
						giftData.customValue = Number(_initData.transaction.AMOUNT);
					} else if ("quantity" in _initData.transaction) {
						giftData.fixedCommodityValue = true;
						giftData.customValue = Math.abs(Number(_initData.transaction.quantity));
					}
					var cls:Class;
					var loading:Boolean = false;
					if (accountInfo == null) {
						getWallets(false);
						loading = true;
					}
					if (investments == null) {
						getInvestments(false);
						loading = true;
					}
					if (loading == true)
						return;
					var investmentObj:Object;
					var accObj:Object;
					if ("FROM" in _initData.transaction) {
						if (_initData.transaction.FROM.indexOf("CH") == 0) {
							investmentObj = getInvestmentByAccount(_initData.transaction.TO);
							if (investmentObj == null)
								return;
							accObj = getWalletByIBAN(_initData.transaction.FROM);
							if (accObj == null)
								return;
							giftData.currency = investmentObj.INSTRUMENT;
							giftData.accountNumber = accObj.ACCOUNT_NUMBER;
							giftData.callback = onInvestmentCallback;
							cls = BuyCommodityPopup;
						} else {
							investmentObj = getInvestmentByAccount(_initData.transaction.FROM);
							if (investmentObj == null)
								return;
							accObj = getWalletByIBAN(_initData.transaction.TO);
							if (accObj == null)
								return;
							giftData.currency = investmentObj.INSTRUMENT;
							giftData.accountNumber = accObj.ACCOUNT_NUMBER;
							giftData.callback = onInvestmentSellCallback;
							cls = SellCommodityPopup;
						}
					} else {
						accObj = getWalletByCurrency(_initData.transaction.currency);
						if (accObj == null)
							return;
						giftData.currency = _initData.transaction.instrument;
						giftData.accountNumber = accObj.ACCOUNT_NUMBER;
						if ("type" in _initData.transaction == false)
							return;
						if (_initData.transaction.type.toLowerCase() == "sell") {
							cls = SellCommodityPopup;
							giftData.callback = onInvestmentSellCallback;
						} else {
							cls = BuyCommodityPopup;
							giftData.callback = onInvestmentCallback;
						}
					}
					ServiceScreenManager.showScreen(
						ServiceScreenManager.TYPE_DIALOG,
						cls, { 
							giftData:giftData
						}
					);
				} else if (data.type == "cryptoNotesBS") {
					screenData = new OrderScreenData();
					if (data.val == "b")
						screenData.type = TradingOrder.BUY;
					else
						screenData.type = TradingOrder.SELL;
					ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_DIALOG, TradeNotesPopup, { callback:sendNotesRequest, data:screenData } );
				} else if (data.type == "paymentsInvestmentsSell" ||data.type == "paymentsInvestmentsSellPart") {
					giftData = new GiftData();
					giftData.additionalData = data;
					if (_initData != null && "transaction" in _initData == true && _initData.transaction != null)
						giftData.currency = _initData.transaction.instrument;
					else if ("param" in data == true &&
						data.param != null &&
						"INSTRUMENT" in data.param == true &&
						data.param.INSTRUMENT != null &&
						data.param.INSTRUMENT != "")
							giftData.currency = data.param.INSTRUMENT;
					else if ("selection" in data == true &&
						data.selection != null &&
						data.selection != "")
							giftData.currency = data.selection;
					giftData.callback = onInvestmentSellCallback;
					ServiceScreenManager.showScreen(
						ServiceScreenManager.TYPE_DIALOG,
						SellCommodityPopup, {
							giftData:giftData
						}
					);
				} else if (data.type == "paymentsInvestmentsSellAll") {
					if ("selection" in data == false || data.selection == null || data.selection == "")
						return;
					var investmentObj1:Object = getInvestmentByAccount(data.selection);
					if (accountInfo == null) {
						getWallets(false);
						return;
					}
					var accObj1:Object = getWalletByCurrency(accountInfo.investmentReferenceCurrency);
					if (accObj1 == null)
						return;
					var requestObj:Object = {};
					requestObj.currency = accountInfo.investmentReferenceCurrency;
					requestObj.instrument = investmentObj1.INSTRUMENT;
					requestObj.direction  = "sell";
					requestObj.quantity = Number(investmentObj1.BALANCE);
					PayManager.callGetInvestmentRate(
						requestObj,
						"BMInvestmentRate" + new Date().getTime(),
						function(respond:PayRespond):void {
							if (!respond.error && respond.data) {
								if ("offmarket_warning" in respond.data)
									DialogManager.alert(Lang.information, respond.data.offmarket_warning);
							}
							giftData = new GiftData();
							giftData.additionalData = data;
							giftData.customValue = Number(investmentObj1.BALANCE);
							giftData.credit_account_currency = investmentObj1.INSTRUMENT;
							giftData.accountNumber = accObj1.ACCOUNT_NUMBER;
							giftData.fixedCommodityValue = true;
							onInvestmentSellCallback(giftData);
						}
					);
				} else if (data.type == "cardMoneySend") {
					PayManager.callGetSystemOptions(function():void {
						giftData = new GiftData();
						if ("value" in data == true && data.value != null && data.value != "" && data.value != "@@1")
							giftData.currency = data.value;
						giftData.callback = onCardMoneySend;
						giftData.additionalData = data;
						giftData.currencies = PayManager.systemOptions.cardWithdrawalCurrencies;
						giftData.cards = getAllCards();
						ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_DIALOG, WithdrawalPopup, { giftData:giftData } );
					} );
				} else if (data.type == "paymentsSelectChatmate") {
					DialogManager.showDialog(SelectContactExtendedScreen, { title:Lang.selectChatmate, callback:onSelectChatmate, items:data, searchText:Lang.TEXT_SEARCH_CONTACT, data:data }, ServiceScreenManager.TYPE_SCREEN );
				} else if (data.type == "paymentsSelectChatmate1") {
					DialogManager.showDialog(SelectContactExtendedScreen, { title:Lang.selectChatmate, callback:onSelectChatmate1, items:data, searchText:Lang.TEXT_SEARCH_CONTACT, data:data }, ServiceScreenManager.TYPE_SCREEN );
				} else if (data.type == "paymentsInvoiceThirdparty") {
					ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, ScreenAddInvoiceDialog, {callback:callBackAddInvoiceThirdparty, thirdparty:true}, 0.5, 0.5, 3);
				} else if (data.type == "paymentsSelectContact") {
					DialogManager.showDialog(SelectContactScreen, { title:Lang.selectContacts, callback:onSelectContact, searchText:Lang.TEXT_SEARCH_CONTACT, data:data, dialog:true }, ServiceScreenManager.TYPE_SCREEN );
				} else if (data.type == "paymentsSelectTemplate") {
					DialogManager.showDialog(TransactionPresetsPopup, { transactionTemplates:transactionTemplates, data:data, deleteTemplate:deleteTemplate, callback:onSelectTemplate } );
				} else if (data.type == "cryptoSelectContact") {
					DialogManager.showDialog(SelectContactScreen, { title:Lang.selectContacts, callback:onSelectContactForCrypto, searchText:Lang.TEXT_SEARCH_CONTACT, data:data, dialog:true  }, ServiceScreenManager.TYPE_SCREEN );
				} else if (data.type == "walletSelectCurrency") {
					PayManager.callGetSystemOptions(
						function ():void {
							openCurrencySelector(data);
						}
					);
				} else if (data.type == "selectCurrency") {
					PayManager.callGetSystemOptions(
						function ():void {
							openCurrencySelectorAll(data);
						}
					);
				} else if (data.type == "selectedAccCurrency") {
					var acc:Object = getAccountByNumber(data.val);
					if (acc == null)
						acc = getSavingAccountByNumber(data.val);
					if (acc == null)
						return;
					sendMessage("val:" + data.value + "|!|" + acc.CURRENCY);
					sendMessage(data.action);
				} else if (data.type == "cardActivate") {
					DialogManager.showVerify(onCardActivationDialogClose, { account:data.value, additional:data } );
				} else if (data.type == "cardNewActivate") {
					DialogManager.showActivateCard(onCardNewActivationDialogClose, getCardByNumber(data.value), data);
				} else if (data.type == "cardStatement") {
					var popupData:PopupData = new PopupData();
					popupData.title = Lang.cardStatement;
					popupData.data = data;
					popupData.callback = onPeriodSetted;
					ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, BottomTimeSelectionScreen, popupData);
				} else if (data.type == "walletStatement") {
					var popupData1:PopupData = new PopupData();
					popupData1.title = Lang.accountStatement;
					popupData1.data = data;
					popupData1.callback = onPeriodSetted;
					ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, BottomTimeSelectionScreen, popupData1);
				} else if (data.type == "cardSelect") {
					if ("status" in data.param == false ||
						data.param.status == null ||
						data.param.status == "")
							return;
					if (data.param.status == "P") {
						DialogManager.alert(Lang.information, Lang.provisionallyBlockedDesc);
						return;
					}
					if ("typeNext" in data == true) {
						if (data.param.status == "NL") {
							ToastMessage.display(Lang.cardNotVerified);
							return;
						}
						data.tapped = false;
						var str:String = data.typeNext;
						data.typeNext = data.type;
						data.type = str;
						data.value = data.param.number;
						preSendMessage(data);
						str = data.typeNext;
						data.typeNext = data.type;
						data.type = str;
						return;
					} else {
						data.tapped = true;
						baVO = new BankMessageVO(data.text);
						baVO.setMine();
						invokeAnswerSignal(baVO);
						sendMessage(
							"val:" + 
								data.param.number + "|!|" + 
								data.param.status + 
								(("trackingNumber" in data.param == true && data.param.trackingNumber != null && data.param.trackingNumber != "") ? "T" : "" ) + 
								(("reloaded" in data.param == true) ? "R" : "" ) + "|!|" +
								((data.param.programme == "virtual") ? "V" : "P"));
						sendMessage(msg);
					}
				} else if (data.type == "walletSelect" || data.type == "walletSelectAll") {
					data.tapped = true;
					baVO = new BankMessageVO(data.text);
					baVO.setMine();
					invokeAnswerSignal(baVO);
					sendMessage("val:" + data.param.ACCOUNT_NUMBER);
					sendMessage(msg);
				} else if (data.type == "cryptoRewardsDeposites") {
					if ("param" in data == false)
						return;
					var answerType:String = "";
					if (data.param.storage_type == "DUKASCOPY") {
						if (data.value == "CANCELLED" || data.value == "CLOSED")
							return;
						if (data.param.used_for_trading || data.param.restrict_cancel)
							answerType = "E";
					}
					if (data.param.storage_type == "BLOCKCHAIN") {
						if (data.value == "CANCELLED" || data.value == "CLOSED")
							answerType = "BC";
						else if (data.param.used_for_trading || data.param.restrict_cancel)
							answerType = "BC";
						else
							answerType = "B";
					}
					data.tapped = true;
					baVO = new BankMessageVO(data.text);
					baVO.setMine();
					invokeAnswerSignal(baVO);
					sendMessage("val:" + data.param.code + "|!|" + data.param.deposit + "|!|" + data.param.deposit_penalty + "|!|" + answerType)
					sendMessage(msg);
				} else if (data.type == "cryptoOfferSelect") {
					data.tapped = true;
					baVO = new BankMessageVO(data.text);
					baVO.setMine();
					invokeAnswerSignal(baVO);
					sendMessage("val:" + data.param.uid + "|!|" + ((data.param.active == true) ? 1 : 0));
					sendMessage(msg);
					return;
				} else if (data.type == "cryptoSelect") {
					return;
				} else if (data.type == "investmentSelect" || data.type == "investmentSelectAll") {
					data.tapped = true;
					baVO = new BankMessageVO(PayInvestmentsManager.getInvestmentNameByInstrument(data.param.INSTRUMENT));
					baVO.setMine();
					baVO.additionalData = data.param;
					invokeAnswerSignal(baVO);
					sendMessage("val:" + data.param.ACCOUNT_NUMBER + "|!|" + data.param.INSTRUMENT);
					sendMessage(msg);
				} else if (data.type == "investmentDetails") {
					data.tapped = true;
					baVO = new BankMessageVO(data.text);
					baVO.setMine();
					invokeAnswerSignal(baVO);
					sendMessage("val:" + data.selection1);
					sendMessage(msg);
				} else if (data.type == "paymentsInvestmentHistory") {
					
				} else if (data.type == "demoOpen") {
					openLink(data);
				} else if (data.type == "openTracking") {
					data.value = lastBankMessageVO.additionalData.trackingNumber;
					openLink(data);
				} else if (data.type == "fatCatzConditions") {
					data.value += "&lang=" + LangManager.model.getCurrentLanguageID();
					openLink(data);
				} else if (data.type == "liveOpen") {
					openLink(data);
				} else if (data.type == "demoLogin") {
					openLink(data);
				} else if (data.type == "liveLogin") {
					openLink(data);
				} else if (data.type == "BCDepositeCopyAddress") {
					ToastMessage.display(Lang.copied);
					Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, data.value);
				} else if (data.type == "cryptoRDCoinTerms" || data.type == "cryptoRDFiatTerms") {
					openLink(data);
				} else if (data.type == "cryptoWebsite") {
					data.value = data.value + "/?from=connect&lang=" + LangManager.model.getCurrentLanguageID();
					openLink(data);
				} else if (data.type == "cryptoBCTerms") {
					data.value = blockchainConditionsURL + "&lang=" + LangManager.model.getCurrentLanguageID();
					openLink(data);
				} else if (data.type == 'selectCurrency') {
					var ddd:Object = data;
					PayManager.callGetSystemOptions(function():void {
						DialogManager.showDialog(ScreenPayDialog, { callback: function(currency:String):void {
							if (currency == null)
								return;
							var baVO:BankMessageVO = new BankMessageVO("Referral currency " + currency);
							baVO.setMine();
							invokeAnswerSignal(baVO);
							sendMessage("val:" + currency);
							sendMessage(ddd.action);
							ddd.tapped = true;
							S_ADDITIONAL_DATA_ENTERED.invoke();
						}, data: PayManager.systemOptions.currencyList, itemClass: ListPayCurrency, label: Lang.selectCurrency } );	
					} );
				} else if (data.type == 'selectCurrencyAccount') {
					var ddd1:Object = data;
					PayManager.callGetSystemOptions(function():void {
						DialogManager.showDialog(ScreenPayDialog, { callback: function(currency:String):void {
							if (currency == null)
								return;
							var baVO:BankMessageVO = new BankMessageVO(Lang.selectedCurrencyIs + " " + currency);
							baVO.setMine();
							invokeAnswerSignal(baVO);
							sendMessage("val:" + currency + "|!|" + ddd1.value);
							sendMessage(ddd1.action);
							ddd1.tapped = true;
							S_ADDITIONAL_DATA_ENTERED.invoke();
						}, data: PayManager.systemOptions.currencyList, itemClass: ListPayCurrency, label: Lang.selectCurrency } );
					} );
				}
				return;
			}
			if (msg == null)
				return;
			if (msg.indexOf("app:") == 0) {
				data["tapped"] = true;
				msg = msg.substr(4);
				if (msg == "copyValue") {
					data["tapped"] = false;
					Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, lastBankMessageVO.additionalData.numberCard);
					ToastMessage.display(Lang.numberCopied);
					return;
				}
				if (msg == "copyIBAN") {
					data["tapped"] = false;
					Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, lastBankMessageVO.additionalData.IBAN);
					ToastMessage.display(Lang.IBANCopied);
					return;
				}
				if (msg == "payments") {
					data["tapped"] = false;
					navigateToURL(new URLRequest(Config.PAYMENTS_WEB));
				} else if (msg == "showKeyword") {
					data["tapped"] = false;
					showTextComposer(data);
				} else if (msg == "historyUser") {
					needToGetHistoryUser = _initData.userAccNumber;
					if (MobileGui.centerScreen.currentScreen.data.backScreen != MyAccountScreen) {
						MobileGui.changeMainScreen(MyAccountScreen);
						return;
					}
					MobileGui.S_BACK_PRESSED.invoke();
				} else if (msg == "historyWallet") {
					isCardHistory = false;
					isInvestmentHistory = false;
					data["tapped"] = false;
					showHistoryByAccountNumber(getWalletByNumber(data.selection));
					if (MobileGui.centerScreen.currentScreen.data.backScreen != MyAccountScreen) {
						MobileGui.changeMainScreen(MyAccountScreen);
						return;
					}
					MobileGui.S_BACK_PRESSED.invoke();
				} else if (msg == "historyInvestment") {
					data["tapped"] = false;
					historyAcc = data.selection;
					isCardHistory = false;
					isInvestmentHistory = true;
					if (MobileGui.centerScreen.currentScreen.data.backScreen != MyAccountScreen) {
						MobileGui.changeMainScreen(MyAccountScreen);
						return;
					}
					MobileGui.S_BACK_PRESSED.invoke();
				} else if (msg == "historyCard") {
					data["tapped"] = false;
					var card:Object = getCardByNumber(data.selection);
					if (card != null) {
						historyAcc = card.number;
						cardMasked = getCardByNumber(historyAcc).masked.replace("********", "…");
						isCardHistory = true;
						isInvestmentHistory = false;
					}
					if (MobileGui.centerScreen.currentScreen.data.backScreen != MyAccountScreen) {
						MobileGui.changeMainScreen(MyAccountScreen);
						return;
					}
					MobileGui.S_BACK_PRESSED.invoke();
				} else if (msg == "limits") {
					data["tapped"] = false;
					MobileGui.changeMainScreen(PaymentsSettingsVerificationLimitsScreen, {
						backScreen: MobileGui.centerScreen.currentScreenClass,
						backScreenData: MobileGui.centerScreen.currentScreen.data
					} );
				} else if (msg == "support") {
					data["tapped"] = false;
					var chatScreenData:ChatScreenData = new ChatScreenData();
					chatScreenData.pid = Config.EP_VI_DEF;
					chatScreenData.type = ChatInitType.SUPPORT;
					chatScreenData.backScreen = MobileGui.centerScreen.currentScreenClass;
					chatScreenData.backScreenData = MobileGui.centerScreen.currentScreen.data;
					MobileGui.showChatScreen(chatScreenData);
				} else if (msg == "profile") {
					data["tapped"] = false;
					if (_initData != null && _initData.user != null)
						MobileGui.changeMainScreen(UserProfileScreen, {
							backScreen: MobileGui.centerScreen.currentScreenClass,
							backScreenData: MobileGui.centerScreen.currentScreen.data,//data,
							data: _initData.user
						} );
				} else if (msg == "back") {
					closeBankChatBotSession();
					MobileGui.S_BACK_PRESSED.invoke();
				} else if (msg == "transaction") {
					data["tapped"] = false;
					var msg1:String;
					if ("textForUser" in data == true && data.textForUser != null)
						msg1 = data.textForUser;
					else
						msg1 = "Click on transaction from list and proceed with payments";
					DialogManager.alert(Lang.information, msg1, function(val:int):void {
						if (val != 1)
							return;
						historyAcc = null;
						historyAccCurrency = null;
						isInvestmentHistory = false;
						isCardHistory = false;
						TweenMax.delayedCall(.5,
							function():void {
								if (MobileGui.centerScreen.currentScreen.data.backScreen != MyAccountScreen) {
									MobileGui.changeMainScreen(MyAccountScreen);
									return;
								}
								MobileGui.S_BACK_PRESSED.invoke();
							}
						);
					} );
				} else if (msg == "transactionsList") {
					MobileGui.changeMainScreen(MyAccountScreen);
				}
				return;
			} else {
				data["tapped"] = true;
			}
			
			if (needToSendMessage == true) {
				baVO = new BankMessageVO(data.text);
				baVO.setMine();
				invokeAnswerSignal(baVO);
			}
			sendMessage(msg);
		}
		
		static private function removeCryptoAccounts(accounts:Array):Array 
		{
			var result:Array = new Array();
			if (accounts != null)
			{
				for (var i:int = 0; i < accounts.length; i++) 
				{
					if (!isCryptoFoundAccount(accounts[i]))
					{
						result.push(accounts[i]);
					}
				}
			}
			return result;
		}
		
		static private function isCryptoFoundAccount(account:Object):Boolean 
		{
			var result:Boolean = false;
			if (account != null)
			{
				if ("IS_BITCOIN_FUNDING" in account && account.IS_BITCOIN_FUNDING == "1")
				{
					return true;
				}
				if ("IS_DUKASCOINS_FUNDING" in account && account.IS_DUKASCOINS_FUNDING == "1")
				{
					return true;
				}
				if ("IS_ETHEREUM_FUNDING" in account && account.IS_ETHEREUM_FUNDING == "1")
				{
					return true;
				}
				if ("IS_TETHER_FUNDING" in account && account.IS_TETHER_FUNDING == "1")
				{
					return true;
				}
			}
			return result;
		}
		
		static private function onSaveTemplate(val:int, transactionData:Object):void {
			if (val != 1)
				return;
			if (transactionTemplates == null)
				return;
			delete BankBotController.getScenario().scenario.sendMoney.menu[1].disabled;
			transactionTemplates.push(transactionData);
			Store.save("transactionTemplates", transactionTemplates);
		}
		
		static private function sendNotesRequest(request:TradeNotesRequest = null):void {
			if (request != null) {
				var action:SendTradeNotesRequestAction = new SendTradeNotesRequestAction(request, accountInfo);
				action.execute();
			}
		}
		
		static private function getWalletByCurrency(val:String):Object {
			if (accountInfo == null)
				return null;
			var l:int = accountInfo.accounts.length;
			for (var i:int = 0; i < l; i++) {
				if (accountInfo.accounts[i].CURRENCY == val)
					return accountInfo.accounts[i];
			}
			return null;
		}
		
		static private function getWalletByIBAN(val:String):Object {
			if (accountInfo == null)
				return null;
			var l:int = accountInfo.accounts.length;
			for (var i:int = 0; i < l; i++) {
				if (accountInfo.accounts[i].IBAN == val)
					return accountInfo.accounts[i];
			}
			return null;
		}
		
		static private function getWalletByNumber(val:String):Object {
			if (accountInfo == null)
				return null;
			if (accountInfo.accounts == null)
				return null;
			var i:int;
			var l:int = accountInfo.accounts.length;
			for (i = 0; i < l; i++) {
				if (accountInfo.accounts[i].ACCOUNT_NUMBER == val)
					return accountInfo.accounts[i];
			}
			if (savingsAccounts == null)
				return null;
			l = savingsAccounts.length;
			for (i = 0; i < l; i++) {
				if (savingsAccounts[i].ACCOUNT_NUMBER == val)
					return savingsAccounts[i];
			}
			return null;
		}
		
		static private function onCardActivationDialogClose(i:int, value:String = "", title:String = "code", data:Object = null):void {
			if (i != 1)
				return;
			if (data != null)
				data["tapped"] = true;
			S_ADDITIONAL_DATA_ENTERED.invoke();
			var baVO:BankMessageVO = new BankMessageVO("Activate card");
			baVO.setMine();
			invokeAnswerSignal(baVO);
			sendMessage("val:" +
				title + "|!|" +
				value + "|!|" +
				data.value
			);
			sendMessage(data.action);
		}
		
		static private function onCardNewActivationDialogClose(i:int, value:String = "", data:Object = null):void {
			if (i != 1)
				return;
			if (data != null)
				data["tapped"] = true;
			S_ADDITIONAL_DATA_ENTERED.invoke();
			var baVO:BankMessageVO = new BankMessageVO("Activate card");
			baVO.setMine();
			invokeAnswerSignal(baVO);
			sendMessage("val:" +
				value + "|!|" +
				data.value
			);
			sendMessage(data.action);
		}
		
		static private function onPeriodSetted(i:int, data:Object = null, value:Object = null):void {
			if (i != 1)
				return;
			if (value == null)
				return;
			var temp:int;
            var from:String = value.dateFrom.getFullYear();
            temp = value.dateFrom.getMonth() + 1;
            from += "-";
            from += (temp < 10) ? "0" + temp : temp;
            temp = value.dateFrom.getDate();
            from += "-";
            from += (temp < 10) ? "0" + temp : temp;
            var to:String = value.dateTo.getFullYear();
            temp = value.dateTo.getMonth() + 1;
            to += "-";
            to += (temp < 10) ? "0" + temp : temp;
            temp = value.dateTo.getDate();
            to += "-";
            to += (temp < 10) ? "0" + temp : temp;
            sendMessage("val:" +
                from + "|!|" +
                to + "|!|" +
                data.value, true
            );
            sendMessage(data.action, true);
			return;
			/*var from:String = Number(value.dateFrom.getTime() * .001).toFixed(0);
			var to:String = Number(value.dateTo.getTime() * .001).toFixed(0);
			GD.S_TIMEZONE_REQUEST.invoke(function(val:String):void {
				sendMessage("val:" +
					from + "|!|" +
					to + "|!|" +
					data.value + "|!|" + 
					val, true
				);
				sendMessage(data.action, true);
			} );*/
		}
		
		static private function openLink(data:Object):void {
			if ("value" in data == true && data.value != null && data.value != "")
				navigateToURL(new URLRequest(data.value));
			if ("action" in data == true) {
				data["tapped"] = true;
				S_ADDITIONAL_DATA_ENTERED.invoke();
				sendMessage(data.action);
			}
		}
		
		static private function onCardMoneySend(giftData:GiftData):void {
			giftData.additionalData["tapped"] = true;
			S_ADDITIONAL_DATA_ENTERED.invoke();
			var msg:String = "";
			if ("textForUser" in giftData.additionalData == true) {
				msg = giftData.additionalData.textForUser.replace("@1", giftData.customValue).replace("@2", giftData.currency).replace("@3", giftData.masked).replace("@4", giftData.credit_account_currency);
			} else if ("text" in giftData.additionalData == true) {
				msg = giftData.additionalData.text.replace("@1", giftData.customValue).replace("@2", giftData.currency).replace("@3", giftData.masked).replace("@4", giftData.currency);
			} else {
				msg = "Withdrawal " + giftData.customValue + " " + giftData.currency;
			}
			var baVO:BankMessageVO = new BankMessageVO(msg);
			baVO.setMine();
			invokeAnswerSignal(baVO);
			sendMessage("val:" +
				giftData.customValue + "|!|" +
				giftData.currency + "|!|" +
				giftData.accountNumber + "|!|" +
				giftData.credit_account_number
			);
			sendMessage(giftData.additionalData.action);
			giftData.dispose();
		}
		
		static private function onInvestmentCallback(giftData:GiftData, needDirection:Boolean = false):void {
			giftData.additionalData["tapped"] = true;
			S_ADDITIONAL_DATA_ENTERED.invoke();
			var msg:String = "";
			if (giftData.fixedCommodityValue == true) {
				if ("textForUser1" in giftData.additionalData)
					msg = giftData.additionalData.textForUser1.replace("@1", giftData.customValue + " " + giftData.credit_account_currency);
				else
					msg = "Purchase " + giftData.customValue + " " + giftData.credit_account_currency;
			} else {
				if ("textForUser2" in giftData.additionalData)
					msg = giftData.additionalData.textForUser2.replace("@1", giftData.customValue + " " + giftData.currency).replace("@2", giftData.credit_account_currency);
				else
					msg = "Purchase " + giftData.customValue + " " + giftData.currency + " worth of " + giftData.credit_account_currency;
			}
			var baVO:BankMessageVO = new BankMessageVO(msg);
			baVO.setMine();
			invokeAnswerSignal(baVO);
			sendMessage("val:" +
				giftData.customValue + "|!|" +
				giftData.credit_account_currency + "|!|" +
				giftData.accountNumber + "|!|" +
				((giftData.fixedCommodityValue == true) ? "0" : "1") +
				"|!|B"
			);
			sendMessage(giftData.additionalData.action);
			giftData.dispose();
		}
		
		static private function onInvestmentSellCallback(giftData:GiftData, needDirection:Boolean = false):void {
			giftData.additionalData["tapped"] = true;
			S_ADDITIONAL_DATA_ENTERED.invoke();
			var msg:String = "";
			if (giftData.fixedCommodityValue == true) {
				if ("textForUser1" in giftData.additionalData)
					msg = giftData.additionalData.textForUser1.replace("@1", giftData.customValue + " " + giftData.credit_account_currency);
				else
					msg = "Sell " + giftData.customValue + " " + giftData.credit_account_currency;
			} else {
				if ("textForUser2" in giftData.additionalData)
					msg = giftData.additionalData.textForUser2.replace("@1", giftData.customValue + " " + giftData.currency).replace("@2", giftData.credit_account_currency);
				else
					msg = "Sell " + giftData.customValue + " " + giftData.currency + " worth of " + giftData.credit_account_currency;
			}
			var baVO:BankMessageVO = new BankMessageVO(msg);
			baVO.setMine();
			invokeAnswerSignal(baVO);
			
			sendMessage("val:" +
				giftData.customValue + "|!|" +
				giftData.credit_account_currency + "|!|" +
				giftData.accountNumber + "|!|" +
				((giftData.fixedCommodityValue == true) ? "0" : "1") +
				"|!|S"
			);
			sendMessage(giftData.additionalData.action);
			giftData.dispose();
		}
		
		static private function getCardByNumber(val:String):Object {
			if (cards == null)
				return null;
			for (var i:int = 0; i < cards.length; i++) {
				if (cards[i].number == val)
					return cards[i];
			}
			return null;
		}
		
		static private function getCryptoRDByID(val:String):Object {
			if (cryptoRDs == null)
				return null;
			for (var i:int = 0; i < cryptoRDs.length; i++) {
				if (cryptoRDs[i].code == val)
					return cryptoRDs[i];
			}
			return null;
		}
		
		static public function getAccountByCurrency(val:String):Object {
			if (accountInfo == null || accountInfo.accounts == null)
				return null;
			for (var i:int = 0; i < accountInfo.accounts.length; i++) {
				if (accountInfo.accounts[i].CURRENCY == val)
					return accountInfo.accounts[i];
			}
			return null;
		}
		
		static public function getAccountByNumberAll(val:String):Object {
			var acc:Object = getAccountByNumber(val);
			if (acc != null)
				return acc;
			acc = getSavingAccountByNumber(val);
			if (acc != null)
				return acc;
			acc = getCryptoAccountByNumber(val);
			if (acc != null)
				return acc;
			return null;
		}
		
		static public function getAccountByNumber(val:String):Object {
			if (accountInfo == null || accountInfo.accounts == null)
				return null;
			for (var i:int = 0; i < accountInfo.accounts.length; i++) {
				if (accountInfo.accounts[i].ACCOUNT_NUMBER == val)
					return accountInfo.accounts[i];
			}
			return null;
		}
		
		static public function getCryptoAccountByNumber(val:String):Object {
			if (cryptoAccounts == null)
				return null;
			for (var i:int = 0; i < cryptoAccounts.length; i++) {
				if (cryptoAccounts[i].ACCOUNT_NUMBER == val)
					return cryptoAccounts[i];
			}
			return null;
		}
		
		static public function getSavingAccountByNumber(val:String):Object {
			if (savingsAccounts == null)
				return null;
			for (var i:int = 0; i < savingsAccounts.length; i++) {
				if (savingsAccounts[i].ACCOUNT_NUMBER == val)
					return savingsAccounts[i];
			}
			return null;
		}
		
		static private function openCurrencySelector(data:Object):void {
			if (accountInfo == null) {
				PayManager.callGetAccountInfo(function():void{
					accountInfo = PayManager.accountInfo;
					if (accountInfo != null)
						openCurrencySelector(data);
				});
				return;
			}
			if (PayManager.systemOptions == null)
				return;
			var accounts:Array = (data.value == "SAVINGS") ? savingsAccounts : accountInfo.accounts;
			var currencies:Array = PayManager.systemOptions.currencyList;
			var result:Array = currencies.slice();
			for (var i:int = 0; i < accounts.length; i++) {
				var currency:String = accounts[i].CURRENCY;
				if (result.indexOf(currency) !=-1)
					result.splice(result.indexOf(currency), 1);
			}
			DialogManager.showDialog(ScreenPayDialog, {
				callback: callBackSelectCurrency,
				data: result,
				itemClass: ListPayCurrency,
				label: Lang.selectCurrency,
				additionalData: data
			} );
		}
		
		static private function openCurrencySelectorAll(data:Object):void {
			if (PayManager.systemOptions == null)
				return;
			
			DialogManager.showDialog(ScreenPayDialog, {
				callback: callBackSelectCurrencyWithValue,
				data: PayManager.systemOptions.currencyList,
				itemClass: ListPayCurrency,
				label: Lang.selectCurrency,
				additionalData: data
			} );
		}
		
		static private function callBackSelectCurrencyWithValue(currency:String, data:Object):void {
			if (currency == null)
				return;
			data["tapped"] = true;
			S_ADDITIONAL_DATA_ENTERED.invoke();
			if ("textForUser" in data) {
				var baVO:BankMessageVO = new BankMessageVO(data.textForUser.replace("@1", currency));
				baVO.setMine();
				invokeAnswerSignal(baVO);
			}
			if (data.value)
				sendMessage("val:" + data.value + "|!|" + currency);
			else
				sendMessage("val:" + currency);
			sendMessage(data.action);
		}
		
		static private function callBackSelectCurrency(currency:String, data:Object):void {
			if (currency == null)
				return;
			data["tapped"] = true;
			S_ADDITIONAL_DATA_ENTERED.invoke();
			var baVO:BankMessageVO = new BankMessageVO(("textForUser" in data == true) ? data.textForUser.replace("@1", currency) : "Open new " + currency + " account");
			baVO.setMine();
			invokeAnswerSignal(baVO);
			sendMessage("val:" + currency);
			sendMessage(data.action);
		}
		
		static private function onSelectChatmate(user:UserVO, data:Object):void {
			var chatScreenData:ChatScreenData = new ChatScreenData();
			chatScreenData.usersUIDs = [user.uid];
			chatScreenData.type = ChatInitType.USERS_IDS;
			chatScreenData.backScreen = MobileGui.centerScreen.currentScreenClass;
			chatScreenData.backScreenData = data;
			chatScreenData.additionalData = {
				openSendMoney: true
			};
			MobileGui.showChatScreen(chatScreenData);
		}
		
		static private function onSelectChatmate1(user:UserVO, data:Object):void {
			var chatScreenData:ChatScreenData = new ChatScreenData();
			chatScreenData.usersUIDs = [user.uid];
			chatScreenData.type = ChatInitType.USERS_IDS;
			chatScreenData.backScreen = MobileGui.centerScreen.currentScreenClass;
			chatScreenData.backScreenData = data;
			chatScreenData.additionalData = {
				openSendInvoice: true
			};
			MobileGui.showChatScreen(chatScreenData);
		}
		
		static private function onSelectContact(user:UserVO, data:Object):void {
			TweenMax.delayedCall(.3, function():void {
				var giftData:GiftData = new GiftData();
				giftData.additionalData = data;
				if (user.uid == null || user.uid == "") {
					giftData.userName = user.getDisplayName();
					giftData.credit_account_number = user.phone;
					giftData.callback = onMoneySendPhoneCallback;
					ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_DIALOG, SendMoneyByPhonePopup, { giftData: giftData } );
				} else {
					giftData.callback = onMoneySendCallback;
					ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_DIALOG, CreateGiftPopup, 
																	{
																		user:user, 
																		giftType:GiftType.MONEY_TRANSFER_CALLBACK, 
																		receiverSecret:false, 
																		giftData:giftData
																	} );
				}
			} );
		}
		
		static private function onSelectTemplate(template:Object, data:Object):void {
			var giftData:GiftData = new GiftData();
			giftData.additionalData = data;
			giftData.accountNumber = template.acc;
			giftData.currency = template.currency;
			giftData.minAmount = template.amount;
			giftData.comment = template.comment;
			if (String(template.userUid).charAt(0) == "+") {
				giftData.credit_account_number = template.userUid;
				giftData.callback = onMoneySendPhoneCallback;
				ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_DIALOG, SendMoneyByPhonePopup, { giftData: giftData } );
			} else {
				giftData.callback = onMoneySendCallback;
				ServiceScreenManager.showScreen(
					ServiceScreenManager.TYPE_DIALOG, CreateGiftPopup, 
					{
						user:template.userUid,
						giftType:GiftType.MONEY_TRANSFER_CALLBACK,
						receiverSecret:false,
						giftData:giftData
					}
				);
			}
		}
		
		static private function deleteTemplate(index:int):void {
			transactionTemplates.splice(index, 1);
			Store.save("transactionTemplates", transactionTemplates);
			if (transactionTemplates.length == 0)
				BankBotController.getScenario().scenario.sendMoney.menu[1].disabled = true;
		}
		
		static private function onSelectContactForCrypto(user:UserVO, data:Object):void {
			TweenMax.delayedCall(.3, function():void {
				var giftData:GiftData = new GiftData();
				giftData.additionalData = data;
				if (user.uid == null || user.uid == "") {
					giftData.userName = user.getDisplayName();
					giftData.credit_account_number = user.phone;
					giftData.callback = onMoneySendPhoneCallback;
					giftData.wallets = cryptoAccounts;
					ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_DIALOG, SendCoinsByPhonePopup, { giftData: giftData } );
				} else {
					giftData.user = user;
					giftData.callback = onMoneySendCallback;
					giftData.wallets = cryptoAccounts;
					ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_DIALOG, SendCoinsPopup, { giftData: giftData } );
				}
			} );
		}
		
		static private function callBackAddInvoice(i:int, paramsObj:Object):void {
			if (i != 1)
				return;
			paramsObj.additionalData["tapped"] = true;
			S_ADDITIONAL_DATA_ENTERED.invoke();
			var msg:String = "";
			if ("textForUser" in paramsObj.additionalData == true && paramsObj.additionalData.textForUser != null)
				msg = paramsObj.additionalData.textForUser.replace("@1", paramsObj.amount + " " + paramsObj.currency).replace("@2", ((_initData.user != null) ? _initData.user.getDisplayName() : "N/A"));
			else
				msg = "Send invoice for " + paramsObj.amount + " " + paramsObj.currency + " to " + ((_initData.user != null) ? _initData.user.getDisplayName() : "N/A");
			var baVO:BankMessageVO = new BankMessageVO(msg);
			baVO.setMine();
			invokeAnswerSignal(baVO);
			sendMessage("val:" + 
				paramsObj.amount + "|!|" + 
				paramsObj.currency + "|!|" + 
				((_initData.user != null) ? _initData.user.uid : "") + "|!|" + 
				paramsObj.message
			);
			sendMessage(paramsObj.additionalData.action);
		}
		
		static private function callBackAddInvoiceThirdparty(i:int, paramsObj:Object):void {
			if (i != 1)
				return;
			BankBotController.getAnswer(
				"bot:bankbot payments:getThirdpartyInvoiceLink:" + 
				paramsObj.amount + "|!|" + 
				paramsObj.currency + "|!|" + 
				paramsObj.message
			);
		}
		
		static private function onMoneySendCallback(giftData:GiftData):void {
			giftData.additionalData["tapped"] = true;
			S_ADDITIONAL_DATA_ENTERED.invoke();
			if (giftData.currency == "DUK+")
				giftData.currency = "DCO";
			var currency:String = giftData.currency;
			if (currency == "DCO")
				currency = "DUK+";
			var msg:String = "";
			if ("textForUser" in giftData.additionalData == true && giftData.additionalData.textForUser != null)
				msg = giftData.additionalData.textForUser.replace("@1", giftData.customValue  + " " + currency).replace("@2", ((giftData.user != null) ? giftData.user.getDisplayName() : "N/A"));
			else
				msg = Lang.sendMoneyTo.replace("@1", giftData.customValue + " " + currency).replace("@2", ((giftData.user != null) ? giftData.user.getDisplayName() : "N/A"));
			var baVO:BankMessageVO = new BankMessageVO(msg);
			baVO.setMine();
			invokeAnswerSignal(baVO); 
			var vals:String = giftData.customValue + "|!|" + 
				giftData.currency + "|!|" + 
				((giftData.user != null) ? giftData.user.uid : "") + "|!|" + 
				giftData.accountNumber + "|!|" +
				giftData.comment + "|!|" +
				((giftData.pass == null) ? "" : giftData.pass) + "|!|" +
				((giftData.purpose == null) ? "" : giftData.purpose);
			sendMessage("val:" + vals);
			sendMessage(giftData.additionalData.action);
			giftData.dispose();
		}
		
		static private function onMoneySendPhoneCallback(giftData:GiftData):void {
			giftData.additionalData["tapped"] = true;
			S_ADDITIONAL_DATA_ENTERED.invoke();
			if (giftData.currency == "DUK+")
				giftData.currency = "DCO";
			var currency:String = giftData.currency;
			if (currency == "DCO")
				currency = "DUK+";
			var msg:String = "";
			if ("textForUser1" in giftData.additionalData == true && giftData.additionalData.textForUser != null)
				msg = giftData.additionalData.textForUser.replace("@1", giftData.customValue  + " " + currency).replace("@2", giftData.credit_account_number);
			else
				msg = Lang.sendMoneyTo.replace("@1", giftData.customValue + " " + currency).replace("@2", giftData.credit_account_number);
			var baVO:BankMessageVO = new BankMessageVO(msg);
			baVO.setMine();
			invokeAnswerSignal(baVO);
			var vals:String = giftData.customValue + "|!|" + 
				giftData.currency + "|!|" + 
				giftData.credit_account_number + "|!|" + 
				giftData.accountNumber + "|!|" +
				giftData.comment + "|!|" +
				((giftData.pass == null) ? "" : giftData.pass) + "|!|" +
				((giftData.purpose == null) ? "" : giftData.purpose);
			sendMessage("val:" + vals);
			sendMessage(giftData.additionalData.action);
			giftData.dispose();
		}
		
		static private function onCryptoOfferCallback(val:int, data:CoinTradeOrder = null):void {
			if (val != 1)
				return;
			if (isNaN(data.quantity) == true || data.quantity == 0)
				return;
			if (isNaN(data.price) == true || data.price == 0)
				return;
			data.additionalData["tapped"] = true;
			S_ADDITIONAL_DATA_ENTERED.invoke();
			var msg:String = "";
			if (data.action == TradingOrder.BUY) {
				msg = "Buy " + data.quantity + " DUK+ at " + data.price + " EUR";
			} else if (data.action == TradingOrder.SELL) {
				msg = "Sell " + data.quantity + " DUK+ at " + data.price + " EUR";
			}
			var baVO:BankMessageVO = new BankMessageVO(msg);
			baVO.setMine();
			invokeAnswerSignal(baVO);
			sendMessage("val:DCO|!|EUR|!|" +
				((data.action == TradingOrder.BUY) ? "BUY" : "SELL") + "|!|" +
				data.price + "|!|" +
				data.quantity + "|!|" +
				((data.privateOrderReciever != null) ? data.privateOrderReciever : "") + "|!|" +
				((data.expirationTime != null) ? int(data.expirationTime.getTime() / 1000) : "") + "|!|" +
				data.fullOrder
			);
			sendMessage(data.additionalData.action);
		}
		
		static private function onCryptoOfferEditCallback(val:int, data:CoinTradeOrder = null):void {
			if (val != 1)
				return;
			if (isNaN(data.quantity) == true || data.quantity == 0)
				return;
			if (isNaN(data.price) == true || data.price == 0)
				return;
			data.additionalData["tapped"] = true;
			S_ADDITIONAL_DATA_ENTERED.invoke();
			var msg:String = "Edit order";
			var baVO:BankMessageVO = new BankMessageVO(msg);
			baVO.setMine();
			invokeAnswerSignal(baVO);
			sendMessage("val:DCO|!|EUR|!|" +
				((data.action == TradingOrder.BUY) ? "BUY" : "SELL") + "|!|" +
				data.price + "|!|" +
				data.quantity + "|!|" +
				((data.privateOrderReciever != null) ? data.privateOrderReciever : "") + "|!|" +
				((data.expirationTime != null) ? int(data.expirationTime.getTime() / 1000) : "")
			);
			sendMessage(data.additionalData.action);
		}
		
		static private function onCryptoDepositeCallback(giftData:GiftData):void {
			giftData.additionalData["tapped"] = true;
			S_ADDITIONAL_DATA_ENTERED.invoke();
			var msg:String = "I want to deposit " + giftData.customValue + " DUK+";
			var baVO:BankMessageVO = new BankMessageVO(msg);
			baVO.setMine();
			invokeAnswerSignal(baVO);
			sendMessage("val:" + 
				giftData.customValue + "|!|" + 
				giftData.currency + "|!|" + 
				giftData.accountNumber + "|!|" +
				giftData.rewardDeposit.code + "|!|" +
				giftData.rewardDeposit.penalty_deposit + "|!|" +
				giftData.rewardDeposit.penalty_reward + "|!|" +
				giftData.rewardDeposit.reward + "|!|" +
				giftData.rewardDeposit.reward_currency+ "|!|" +
				giftData.rewardDeposit.termination

			);
			sendMessage(giftData.additionalData.action);
			giftData.dispose();
		}
		
		static private function callbackEnderCode(val:int, code:String, data:Object):void {
			if (val != 1)
				return;
			data["tapped"] = true;
			S_ADDITIONAL_DATA_ENTERED.invoke();
			sendMessage("val:" + _initData.uid + "|!|" + code);
			sendMessage(data.action);
		}
		
		static private function onCryptoBCDWCallback(giftData:GiftData):void {
			giftData.additionalData["tapped"] = true;
			S_ADDITIONAL_DATA_ENTERED.invoke();
			var msg:String = "";
			if (giftData.type == 1) {
				if ("textForUser" in giftData.additionalData == true && giftData.additionalData.textForUser != null)
					msg = giftData.additionalData.textForUser.replace("@1", giftData.customValue).replace("@2", getDCOWallet());
				else
					msg = "I want to withdrawal " + giftData.customValue + " DUK+ to " + getDCOWallet();
			} else if (giftData.type == 0) {
				if ("textForUser" in giftData.additionalData == true && giftData.additionalData.textForUser != null)
					msg = giftData.additionalData.textForUser.replace("@1", giftData.customValue);
				else
					msg = "I want to deposit " + giftData.customValue + " DUK+";
			}
			var baVO:BankMessageVO = new BankMessageVO(msg);
			baVO.setMine();
			invokeAnswerSignal(baVO);
			var val:String = "val:" + 
				giftData.customValue + "|!|" + 
				giftData.currency + "|!|" + 
				getDCOWallet();
			if (giftData.type == 2)
				val += "|!|" + giftData.txHash;
			sendMessage(val);
			sendMessage(giftData.additionalData.action);
			giftData.dispose();
		}
		
		static private function onInvestmentsBCWCallback(giftData:GiftData):void {
			giftData.additionalData["tapped"] = true;
			S_ADDITIONAL_DATA_ENTERED.invoke();
			var msg:String = "";
			if ("textForUser" in giftData.additionalData == true && giftData.additionalData.textForUser != null)
				msg = giftData.additionalData.textForUser.replace("@1", giftData.customValue + " " + giftData.currency).replace("@2", getDCOWallet(giftData.currency));
			else
				msg = "I want to deliver " + giftData.customValue + " " + giftData.currency.toUpperCase() + " of my investment to " + getDCOWallet(giftData.currency);
			var baVO:BankMessageVO = new BankMessageVO(msg);
			baVO.setMine();
			invokeAnswerSignal(baVO);
			var val:String = "val:" + 
				giftData.customValue + "|!|" + 
				giftData.currency + "|!|" + 
				getDCOWallet(giftData.currency) + "|!|" +
				giftData.credit_account_number;
			sendMessage(val);
			sendMessage(giftData.additionalData.action);
			giftData.dispose();
		}
		
		static private function onCardDepositCallback(giftData:GiftData):void {
			giftData.additionalData["tapped"] = true;
			S_ADDITIONAL_DATA_ENTERED.invoke();
			var baVO:BankMessageVO;
			if ("textForUser" in giftData.additionalData == true) {
				baVO = new BankMessageVO(
					giftData.additionalData.textForUser.replace("@1", giftData.customValue).replace("@2", giftData.currency).replace("@3", giftData.masked).replace("@4", giftData.currency)
				);
			} else {
				baVO = new BankMessageVO(
					"Transfer " + giftData.customValue + " " + giftData.currency + " from " + giftData.masked + " account to " + giftData.currency + " account"
				);
			}
			baVO.setMine();
			invokeAnswerSignal(baVO);
			sendMessage("val:" + 
				giftData.accountNumber + "|!|" + 
				giftData.credit_account_number + "|!|" + 
				giftData.customValue + "|!|" +
				giftData.currency + 
				((giftData.cvv == null) ? "" : "|!|" + giftData.cvv)
			);
			sendMessage(giftData.additionalData.action);
			giftData.dispose();
		}
		
		static public function processCommand(command:VoiceCommand):void {
			switch(command.type.type) {
				case VoiceCommandType.TYPE_EXCHANGE: {
					var giftData:GiftData = new GiftData();
					giftData.customValue = command.debitValue;
					giftData.currency = command.debitCurrency;
					giftData.debit_account_currency = command.debitCurrency;
					giftData.credit_account_currency = command.creditCurrency;
					giftData.additionalData = new Object();
					giftData.additionalData.action = "nav:transferConfirm";
					giftData.additionalData.text = "Exchange money";
					giftData.additionalData.type = "paymentsSendMy";
					if (accountInfo != null && accountInfo.accounts != null) {
						var l:int = accountInfo.accounts.length;
						for (var i:int = 0; i < l; i++) {
							if (accountInfo.accounts.CURRENCY == giftData.debit_account_currency) {
								giftData.accountNumber = accountInfo.accounts.NUMBER;
							}
							if (accountInfo.accounts.CURRENCY == giftData.credit_account_currency) {
								giftData.credit_account_number = accountInfo.accounts.NUMBER;
							}
						}
					}
					onMoneyTransferCallback(giftData);
					break;
				}
			}
		}
		
		static private function onMoneyTransferCallback(giftData:GiftData):void {
			giftData.additionalData["tapped"] = true;
			S_ADDITIONAL_DATA_ENTERED.invoke();
			var msg:String;
			if ("textForUser" in giftData.additionalData == true)
				msg = giftData.additionalData.textForUser.replace("@1", giftData.customValue).replace("@2", giftData.currency).replace("@3", giftData.debit_account_currency).replace("@4", giftData.credit_account_currency);
			else
				msg = "Transfer " + giftData.customValue + " " + giftData.currency + " from " + giftData.debit_account_currency + " account to " + giftData.credit_account_currency + " account";
			var baVO:BankMessageVO = new BankMessageVO(msg);
			baVO.setMine();
			invokeAnswerSignal(baVO);
			var transferType:String = "MCA";
			if (giftData.transferType == OperationType.SAVING_MONEY_EXCHANGE ||
				giftData.transferType == OperationType.SAVING_MONEY_TRANSFER)
				transferType = "SAVING";
			var accNumberIban1:String = giftData.accountNumber;
			var accNumberIban2:String = giftData.credit_account_number;
			if (giftData.transferType == OperationType.SAVING_MONEY_TRANSFER ||
				giftData.transferType == OperationType.MCA_MONEY_TRANSFER) {
					accNumberIban1 = giftData.accountNumberIBAN;
					accNumberIban2 = giftData.credit_account_numberIBAN;
			}
			/*if (accNumberIban2 == null)
				accNumberIban2 = giftData.credit_account_currency;*/
			sendMessage("val:" +
				accNumberIban1 + "|!|" +
				accNumberIban2 + "|!|" +
				giftData.customValue + "|!|" +
				giftData.currency + "|!|" +
				transferType
			);
			sendMessage(giftData.additionalData.action);
			giftData.dispose();
		}
		
		static private function sendMessage(val:String, doNotDisable:Boolean = false):void {
			if (lastBankMessageVO != null) {
				if (doNotDisable == false)
					lastBankMessageVO.disable();
			}
			TweenMax.delayedCall(.5, function():void {
				BankBotController.getAnswer("bot:bankbot " + val);
			} );
		}
		
		static private function onAnswerReceived(val:String):void {
			if (checkForRequestRespond(val) == true)
				return;
			if (checkForAppComand(val) == true)
				return;
			lastBankMessageVO = new BankMessageVO(val);
			if (lastBankMessageVO.isMain == true) {
				if (bankMessages == null || bankMessages.length == 0)
					return;
				_lastMainIndex = bankMessages.length - 1;
				if (lastBankMessageVO.saveItem == false)
					_initData = null;
				if (inProgress == true)
					S_LAST_ACTIVATE.invoke(true);
				else
					S_MENU_HIDE.invoke();
			} else {
				if (_lastMainIndex != 0)
					removeLastTree();
				S_LAST_ACTIVATE.invoke(false);
			}
			if (lastBankMessageVO.isItem == true) {
				if (lastBankMessageVO.item == null)
					return;
				var backScreenData:Object;
				if (lastBankMessageVO.item.type == "error") {
					if (MobileGui.serviceScreen.currentScreen == null)
						invokeAnswerSignal(lastBankMessageVO);
					S_PAYMENT_ERROR.invoke(lastBankMessageVO);
				}
				if (lastBankMessageVO.item.type == "action") {
					preSendMessage(lastBankMessageVO.item.action, false);
					return;
				}
				if (lastBankMessageVO.item.type == "otherWithdrawal") {
					backScreenData = MobileGui.centerScreen.currentScreen.data;
					if (backScreenData == null)
						backScreenData = {};
					if ("command" in lastBankMessageVO.item == true) {
						backScreenData["command"] = lastBankMessageVO.item.command;
					}
					NativeExtensionController.showWebView(lastBankMessageVO.item.value, Lang.TEXT_WITHDRAWAL, MobileGui.centerScreen.currentScreenClass, backScreenData);
					startBankChat();
					return;
				}
				if (lastBankMessageVO.item.type == "paymentsDeposit") {
					backScreenData = MobileGui.centerScreen.currentScreen.data;
					if (backScreenData == null)
						backScreenData = {};
					if ("command" in lastBankMessageVO.item == true) {
						backScreenData["command"] = lastBankMessageVO.item.command;
					}
					
					
					var nativeWindow:Boolean = NativeExtensionController.showWebView(
																					lastBankMessageVO.item.value, 
																					Lang.TEXT_DEPOSIT, 
																					MobileGui.centerScreen.currentScreenClass, 
																					backScreenData);
					if (nativeWindow && "command" in lastBankMessageVO.item == true)
					{
					//	echo("!!!!!!!!", lastBankMessageVO.item.command);
						sendMessage(lastBankMessageVO.item.command);
					}
					/*MobileGui.changeMainScreen( 
						WebViewScreen,
						{
							title:Lang.TEXT_DEPOSIT,
							backScreen:MobileGui.centerScreen.currentScreenClass,
							link:lastBankMessageVO.item.value,
							backScreenData:backScreenData
						}
					);*/
					return;
				}
				if (lastBankMessageVO.item.type == "passwordEnter")
					onNeedPassword();
				if (lastBankMessageVO.item.type == "passwordForgot")
					onPasswordForgot();
				if (lastBankMessageVO.item.type == "passwordChange")
					onNeedPasswordChange();
				if (lastBankMessageVO.item.type == "dialogShow")
					DialogManager.alert(Lang.information, lastBankMessageVO.text);
				if (lastBankMessageVO.item.type == "linkCard") {
					cardsLoaded = false;
					cards = null;
					backScreenData = MobileGui.centerScreen.currentScreen.data;
					if (backScreenData == null)
						backScreenData = {};
					if ("command" in lastBankMessageVO.item == true) {
						backScreenData["command"] = lastBankMessageVO.item.command;
					}
					MobileGui.changeMainScreen(
						WebViewScreen,
						{
							title:Lang.linkCard,
							backScreen:MobileGui.centerScreen.currentScreenClass,
							link:lastBankMessageVO.item.value,
							backScreenData:backScreenData
						}
					);
				}
				if (lastBankMessageVO.item.type == "card3ds") {
					backScreenData = MobileGui.centerScreen.currentScreen.data;
					if (backScreenData == null)
						backScreenData = {};
					if ("command" in lastBankMessageVO.item == true) {
						backScreenData["command"] = lastBankMessageVO.item.command;
					}
					MobileGui.changeMainScreen(
						WebViewScreen,
						{
							title:Lang.TEXT_3D_SECURE,
							backScreen:MobileGui.centerScreen.currentScreenClass,
							link:lastBankMessageVO.item.value,
							backScreenData:backScreenData
						}
					);
				}
				if (lastBankMessageVO.item.type == "cryptoDeals") {
					backScreenData = MobileGui.centerScreen.currentScreen.data;
					if (backScreenData == null)
						backScreenData = {};
					if ("command" in lastBankMessageVO.item == true) {
						backScreenData["command"] = lastBankMessageVO.item.command;
					}
					openMarketPlace((lastBankMessageVO.item.value == "MINE") ? 1 : -1);
				}
				if (lastBankMessageVO.item.type == "orderCard") {
					cardsLoaded = false;
					cards = null;
					backScreenData = MobileGui.centerScreen.currentScreen.data;
					if (backScreenData == null)
						backScreenData = {};
					if ("command" in lastBankMessageVO.item == true) {
						backScreenData["command"] = lastBankMessageVO.item.command;
					}
					var autofill:Object = {};
					if (lastBankMessageVO.item.value == "v") {
						autofill.tabID = OrderCardScreen.CARD_TYPE_VIRTUAL;
					} else if (lastBankMessageVO.item.value == "p") {
						autofill.tabID = OrderCardScreen.CARD_TYPE_PLASTIC;
					}
					MobileGui.changeMainScreen(OrderCardScreen, { autofillData:autofill, backScreenData:backScreenData, backScreen:BankBotChatScreen } );
				}
				if (lastBankMessageVO.item.type == "clearCards") {
					cardsLoaded = false;
					cards = null;
				}
				if (lastBankMessageVO.item.type == "clearCrypto") {
					cryptoOffersLoaded = false;
					cryptoDeals = null;
				}
				if (lastBankMessageVO.item.type == "clearCryptoAccount") {
					cryptoAccountsLoaded = false;
					cryptoAccounts = null;
				}
				if (lastBankMessageVO.item.type == "clearCryptoRD") {
					cryptoRDLoaded = false;
					cryptoRDs = null;
				}
				if (lastBankMessageVO.item.type == "clearWallets") {
					PayManager.accountInfo = null;
					otherAccounts = null;
					savingsAccounts = null;
					otherAccountLoaded = false;
					savingsAccountLoaded = false;
					accountInfo = null;
					BankBotController.getAnswer("bot:bankbot payments:homeS");
				}
				if (lastBankMessageVO.item.type == "clearInvestments") {
					investments = null;
				}
				return;
			}
			if (lastBankMessageVO.item != null) {
				var needReturn:Boolean = false;
				if (lastBankMessageVO.item.type == "showLimits" && accountInfo == null) {
					lastBankMessageVO.waitingType = "limits";
					BankBotController.getAnswer("bot:bankbot payments:wallets");
					needReturn = true;
				}
				if (lastBankMessageVO.item.type == "investments") {
					if (investmentExist == false) {
						lastBankMessageVO.menu[1].disabled = true;
					} else {
						lastBankMessageVO.menu[3].disabled = true;
					}
				}
				if (lastBankMessageVO.item.type == "walletSelect" || lastBankMessageVO.item.type == "walletSelectAll" || lastBankMessageVO.item.type == "walletSelectWithoutTotal") {
					if (accountInfo == null) {
						lastBankMessageVO.waitingType = (lastBankMessageVO.item.value == "SAVINGS") ? "walletsSav" : "wallets";
						BankBotController.getAnswer("bot:bankbot payments:homeS");
						needReturn = true;
					} else if (lastBankMessageVO.item.value == "SAVINGS") {
						lastBankMessageVO.additionalData = savingsAccounts;
					} else {
						lastBankMessageVO.additionalData = accountInfo.accounts;
					}
				}
				if (lastBankMessageVO.item.type == "showWallet") {
					lastBankMessageVO.additionalData = getWalletByNumber(lastBankMessageVO.item.selection);
				}
				if (lastBankMessageVO.item.type == "cardSelect") {
					if (cardsLoaded == false) {
						lastBankMessageVO.waitingType = "cards";
						BankBotController.getAnswer("bot:bankbot payments:cards");
						needReturn = true;
					} else
						lastBankMessageVO.additionalData = cards;
				}
				if (lastBankMessageVO.item.type == "fatCatz") {
					if (fatCatzLoaded == false) {
						lastBankMessageVO.waitingType = "fatCatz";
						BankBotController.getAnswer("bot:bankbot payments:fatCatz");
						needReturn = true;
					} else {
						var dt:Date = new Date();
						if (lastBankMessageVO.additionalData.is_fc == true)
							lastBankMessageVO.text = lastBankMessageVO.addDesc[1];
						else
							lastBankMessageVO.text = lastBankMessageVO.addDesc[0];
						waitingBMVO.text = lastBankMessageVO.text.replace(/%@/g, Lang["month_" + dt.getMonth()]);
						lastBankMessageVO.additionalData = fatCatz;
					}
				}
				if (lastBankMessageVO.item.type == "operationDetails") {
					if (_initData != null && "transactionID" in _initData == true && _initData.transactionID != null) {
						if ("raw" in _initData == false) {
							lastBankMessageVO.waitingType = "operationDetails" + _initData.uid;
							getOperationTransactions(_initData.uid);
							needReturn = true;
						} else
							lastBankMessageVO.additionalData = _initData.raw;
					}
				}
				if (lastBankMessageVO.item.type == "otherAccSelect") {
					if (otherAccountLoaded == false) {
						lastBankMessageVO.waitingType = "homeS";
						BankBotController.getAnswer("bot:bankbot payments:homeS");
						needReturn = true;
					} else
						lastBankMessageVO.additionalData = otherAccounts;
				}
				if (lastBankMessageVO.item.type == "showTradeStat") {
					lastBankMessageVO.waitingType = "cryptoTradeStat";
					BankBotController.getAnswer("bot:bankbot payments:cryptoOffers");
					needReturn = true;
				}
				if (lastBankMessageVO.item.type == "cryptoBestPrice" ||
					lastBankMessageVO.item.type == "cryptoOfferSelect") {
						lastBankMessageVO.waitingType = "cryptoOffers";
						BankBotController.getAnswer("bot:bankbot payments:cryptoOffers");
						needReturn = true;
				}
				if (lastBankMessageVO.item.type == "cryptoSelect") {
					if (cryptoAccountsLoaded == false) {
						lastBankMessageVO.waitingType = "crypto";
						getCrypto(false);
						needReturn = true;
					}
				}
				if (lastBankMessageVO.item.type == "investmentSelect") {
					if (investments == null) {
						lastBankMessageVO.waitingType = "investments";
						getInvestments(false);
						needReturn = true;
					}
				}
				if (lastBankMessageVO.item.type == "showInvestment") {
					PayManager.callGetSystemOptions(function():void {
						if (PayManager.systemOptions != null &&
							PayManager.systemOptions.investmentDeliveryCurrencies != null &&
							PayManager.systemOptions.investmentDeliveryCurrencies.length != 0) {
								if (lastBankMessageVO.menu != null) {
									for (var i:int = 0; i < lastBankMessageVO.menu.length; i++) {
										if ("type" in lastBankMessageVO.menu[i] &&
											lastBankMessageVO.menu[i].type == "BCWithdrawalInvestment") {
												if (PayManager.systemOptions.investmentDeliveryCurrencies.indexOf(lastBankMessageVO.menu[i].selection) != -1 &&
													Number(getInvestmentByAccount(lastBankMessageVO.menu[i].selectionAcc).BALANCE) != 0) {
														delete lastBankMessageVO.menu[i].disabled;
												}
										}
										if ("type" in lastBankMessageVO.menu[i] &&
											lastBankMessageVO.menu[i].type == "paymentsInvestmentsSellAll" &&
											Number(getInvestmentByAccount(lastBankMessageVO.item.selection).BALANCE) == 0) {
												lastBankMessageVO.menu[i].disabled = true;
										}
										
										if ("type" in lastBankMessageVO.menu[i] &&
											lastBankMessageVO.menu[i].type == "paymentsInvestmentsSellPart" &&
											Number(getInvestmentByAccount(lastBankMessageVO.item.selection).BALANCE) == 0) {
												lastBankMessageVO.menu[i].disabled = true;
										}
									}
								}
						}
						invokeAnswerSignal(lastBankMessageVO);
					} );
					return;
				}
				if (lastBankMessageVO.item.type == "cryptoRewardsDeposites") {
					if (cryptoRDLoaded == false) {
						lastBankMessageVO.waitingType = "cryptoRD";
						getCryptoRD(false);
						needReturn = true;
					}
				}
				if (lastBankMessageVO.item.type == "operationTransactions") {
					if (_initData != null) {
						var uid:String;
						if ("raw" in _initData == true) {
							uid = _initData.raw.UID;
						} else if ("uid" in _initData == true) {
							uid = _initData.uid;
						}
						lastBankMessageVO.waitingType = "operationTransactions" + uid;
						getOperationTransactions(uid);
					}
					needReturn = true;
				}
				if (lastBankMessageVO.item.type == "showCard" || lastBankMessageVO.item.type == "showCardDetails") {
					lastBankMessageVO.additionalData = getCardByNumber(lastBankMessageVO.item.selection);
				}
				if (lastBankMessageVO.item.type == "showRD") {
					lastBankMessageVO.additionalData = getCryptoRDByID(lastBankMessageVO.item.selection);
				}
				if (lastBankMessageVO.item.type == "cardsRemove") {
					cardsLoaded = false;
					cards = null;
				}
				if (needReturn == true) {
					waitingBMVO = lastBankMessageVO;
					return;
				}
			}
			invokeAnswerSignal(lastBankMessageVO);
		}
		
		static private function showCryptoSellBuyPopup(side:int):void {
			var screenDataNew:Object = new Object();
			screenDataNew.dataProvider = getCryptoBoard;
			screenDataNew.refreshDataFunction = refreshCryptoBoard;
			screenDataNew.updateDataSignal = S_CRYPTO_DEALS;
			screenDataNew.callback = tradeCoins;
			screenDataNew.resultSignal = S_TRADE_COMPLETE;
			if (side == 2)
				screenDataNew.type = TradingOrder.SELL;
			else if (side == 1)
				screenDataNew.type = TradingOrder.BUY;
			ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_DIALOG, TradeCoinsExtendedPopup, screenDataNew);
		}
		
		static private function createNewLot(val:int, order:CoinTradeOrder = null):void {
			if (val != 1)
				return;
			if (isNaN(order.quantity) == true || order.quantity == 0)
				return;
			if (isNaN(order.price) == true || order.price == 0)
				return;
			BankBotController.getAnswer("bot:bankbot payments:cryptoOfferCreate:" +
				"DCO|!|EUR|!|" +
				((order.action == TradingOrder.BUY) ? "BUY" : "SELL") + "|!|" +
				order.price + "|!|" +
				order.quantity + "|!|" +
				((order.privateOrderReciever != null) ? order.privateOrderReciever : "") + "|!|" +
				((order.expirationTime != null) ? int(order.expirationTime.getTime() / 1000) : "") + "|!|" +
				order.fullOrder
			);
		}
		
		static private function tradeCoins(tor:TradingOrderRequest):Boolean {
			if (tor == null || tor.orders == null || tor.orders.length == 0)
				return false;
			var order:TradingOrder = tor.orders[0];
			if (order.fillOrKill && tor.quantity < order.quantity)
				return false;
			BankBotController.getAnswer(
				"bot:bankbot payments:tradeCoins:" + 
				order.uid + "|!|" + 
				tor.quantity + "|!|" + 
				order.price + "|!|" + 
				((order.side == "BUY") ? "SELL" : "BUY") + "|!|" +
				tor.requestID);
			return true;
		}
		
		static public function deleteCryptoLot(lotID:String):void {
			BankBotController.getAnswer("bot:bankbot payments:cryptoOfferDeactivate:" + lotID);
		}
		
		static private function checkForAppComand(val:String):Boolean {
			if (val.indexOf("app") != 0)
				return false;
			var command:String = val.substr(4);
			if (command == "toLast") {
				if (bankMessages == null || bankMessages.length < 3)
					return true;
				bankMessages.pop();
				bankMessages.pop();
				lastBankMessageVO = bankMessages[bankMessages.length - 1];
				lastBankMessageVO.enable();
				S_REMOVE_MAIN_MENU.invoke();
			} else if (command == "actionCompleted") {
				inProgress = false;
			}
			return true;
		}
		
		static private function checkForRequestRespond(val:String):Boolean {
			if (val.indexOf("requestRespond") != 0)
				return false;
			var startObjectIndex:int = val.indexOf(":", 15);
			var command:String = val.substring(15, startObjectIndex);
			if (command == "error") {
				var message:String = "";
				if (val != null && val.length > startObjectIndex)
				{
					message = val.substr(startObjectIndex + 1)
				}
				DialogManager.alert(Lang.information, "Payments Error: " + message);
				S_ERROR.invoke();
				return true;
			}
			var func:Function;
			if (command == "cryptoTrading")
				func = onCryptoTradeCompleted;
			if (command == "history")
				func = onHistoryLoaded;
			if (command == "historyMore")
				func = onHistoryMoreLoaded;
			if (command == "historyTrades")
				func = onHistoryTradesLoaded;
			else if (command == "wallets")
				func = onWalletsLoaded;
			else if (command == "investments")
				func = onInvestmentsLoaded;
			else if (command == "cards")
				func = onCardsLoaded;
			else if (command == "linkedCards")
				func = onLinkedCardsLoaded;
			else if (command == "invoice")
				func = onInvoiceAccepted;
			else if (command == "transaction")
				func = onTransactionInfoLoaded;
			else if (command == "transactionCompeleted")
				func = onTransactionCompeleted;
			else if (command == "investmentHistory")
				func = onInvestmentHistoryLoaded;
			else if (command == "investmentDetailsCompleted")
				func = onInvestmentDetailsLoaded;
			else if (command == "total")
				func = onTotalLoaded;
			else if (command == "crypto")
				func = onCryptoAccounts;
			else if (command == "cryptoDeals")
				func = onCryptoDealsAccounts;
			else if (command == "cryptoRD")
				func = onCryptoRDs;
			else if (command == "cryptoOfferCreated")
				func = onCryptoOfferCreated;
			else if (command == "cryptoLotDeleted")
				func = onCryptoLotDeleted;
			else if (command == "home")
				func = onHomeLoaded;
			else if (command == "fatCatz")
				func = onFatCatzLoaded;
			else if (command == "possibleRD")
				func = onPossibleRDsReceived;
			else if (command == "declareETHAddressLink")
				func = onETHLinkReceived;
			else if (command == "thirdpartyInvoiceLink")
				func = onTPILinkReceived;
			if (func == null)
				return true;
			func(val.substr(startObjectIndex + 1));
			return true;
		}
		
		static private var currentTextEditor:FullscreenTextEditor;
		static private var currentItem:Object;
		
		static private function showTextComposer(item:Object):void {
			currentItem = item;
			currentTextEditor = new FullscreenTextEditor();
			currentTextEditor.editText(null, onInfoEditResult);
		}
		
		static private function onInfoEditResult(isAccepted:Boolean, result:String = null):void {
			if (result == null)
				return;
			currentTextEditor.dispose();
			currentTextEditor = null;
			MobileGui.centerScreen.currentScreen.activateScreen();
			currentItem.tapped = true;
			sendMessage(currentItem.command + ":" + result);
			currentItem = null;
		}
		
		static private function removeLastTree():void {
			if (bankMessages == null || bankMessages.length == 0)
				return;
			for (var i:int = 0; i < _lastMainIndex; i++) {
				if (bankMessages.length == 0)
					break;
				bankMessages.shift();
			}
			_lastMainIndex = 0;
		}
		
		static private function onTransactionCompeleted(detailsJSON:String):void {
			var data:Object = null;
			try {
				data = JSON.parse(detailsJSON);
			} catch (e:Error) {
				return;
			}
			lastTransactionData = data;
			Gifts.preSendMessage(data);
		}
		
		static private function onCryptoTradeCompleted(detailsJSON:String):void {
			var data:Object = null;
			try {
				data = JSON.parse(detailsJSON);
			} catch (e:Error) {
				return;
			}
			getWallets(false);
			PayManager.updateaccountInfo(null);
			S_TRADE_COMPLETE.invoke(data);
		}
		
		static private function onCryptoOfferCreated(detailsJSON:String):void {
			var data:Object = null;
			try {
				data = JSON.parse(detailsJSON);
			} catch (e:Error) {
				return;
			}
			S_OFFER_CREATED.invoke(data);
		}
		
		static private function onCryptoLotDeleted(lotID:String):void {
			S_ORDER_REMOVED.invoke(lotID);
		}
		
		static private function onInvoiceAccepted(val:String):void {
			var temp:Array = val.split("|!|");
			if (temp.length != 4)
				return;
			var data:ChatMessageInvoiceData = ChatMessageInvoiceData.create(
				temp[0],
				temp[1],
				temp[3],
				TextUtils.checkForNumber(Auth.username),
				Auth.uid,
				_initData.user.login,
				temp[2],
				"+" + Auth.countryCode + Auth.getMyPhone(),
				InvoiceStatus.NEW
			);
			closeBankChatBotSession();
			var chatScreenData:ChatScreenData = new ChatScreenData();
			chatScreenData.usersUIDs = [temp[2]];
			chatScreenData.type = ChatInitType.USERS_IDS;
			chatScreenData.backScreen = MyAccountScreen;
			chatScreenData.backScreenData = null;
			chatScreenData.pendingInvoice = data;
			MobileGui.showChatScreen(chatScreenData);
		}
		
		static private function onPasswordForgot():void {
			var bodyText:String = Lang.ALERT_FORGOT_PASSWORD_SWISS;
			DialogManager.alert(
				Lang.forgotPassword,
				bodyText,
				callToBank,
				Lang.textCall,
				Lang.textClose.toUpperCase(),
				null,
				TextFormatAlign.CENTER,
				true
			);
		}
		
		private static function callToBank(val:int):void {
			if (val == 1)
				navigateToURL(new URLRequest("tel:" + Lang.BANK_PHONE_SWISS));
		}
		
		static private function onNeedPassword():void {
			if (DialogManager.hasOpenedDialog == true) {
				if (MobileGui.dialogScreen.currentScreenClass == PaymentsLoginScreen) {
					BankBotController.addPassSignal();
					return;
				}
				MobileGui.S_DIALOG_CLOSED.add(onNeedPassword);
				return;
			}
			if (MobileGui.touchIDManager != null) {
				MobileGui.touchIDManager.callbackFunction = callbackTouchID;
				if (MobileGui.touchIDManager.getSecretFrom() == false) {
					showPasswordDialog();
					MobileGui.touchIDManager.callbackFunction = null;
				}
				return;
			}
			showPasswordDialog();
		}
		
		private  static function callbackTouchID(val:int, secret:String = ""):void {
			if (val == 0) {
				showPasswordDialog();
				return;
			}
			callBackShowPayPass(val, secret);
		}
		
		static private function showPasswordDialog():void {
			MobileGui.S_DIALOG_CLOSED.remove(onNeedPassword);
			DialogManager.showPayPass(callBackShowPayPass);
		}
		
		static private function callBackShowPayPass(val:int, pass:String):void {
			if (lastBankMessageVO == null || lastBankMessageVO.item == null)
				return;
			if (val == 1) {
				sendMessage(lastBankMessageVO.item.action + ":" + pass);
				return;
			}
			S_ERROR.invoke(PWP_NOT_ENTERED);
			if (val == 0) {
				if (MobileGui.serviceScreen.currentScreen != null || MobileGui.centerScreen.currentScreenClass == MyAccountScreen) {
					sendMessage(lastBankMessageVO.item.action4);
					return;
				}
				sendMessage(lastBankMessageVO.item.action2);
				return;
			} else if (val == 3) {
				sendMessage(lastBankMessageVO.item.action1);
				return;
			}
			sendMessage(lastBankMessageVO.item.action2);
		}
		
		static private function onNeedPasswordChange():void {
			if (MobileGui.centerScreen.currentScreenClass != BankBotChatScreen &&
				MobileGui.centerScreen.currentScreenClass != MyAccountScreen)
					return;
			if (DialogManager.hasOpenedDialog == true) {
				MobileGui.S_DIALOG_CLOSED.add(onNeedPasswordChange);
				return;
			}
			MobileGui.S_DIALOG_CLOSED.remove(onNeedPasswordChange);
			DialogManager.showChangePayPass(callBackShowPayPassChange);
		}
		
		static private function callBackShowPayPassChange(val:int, pass:String, newPass:String):void {
			if (val != 1) {
				if (MobileGui.centerScreen.currentScreenClass != BankBotChatScreen &&
					MobileGui.centerScreen.currentScreenClass != MyAccountScreen)
					return;
				closeBankChatBotSession();
				//!TODO!!!!!!!;
				MobileGui.S_BACK_PRESSED.invoke();
				return;
			}
			
			sendMessage(lastBankMessageVO.item.action + ":" + pass + "|!|" + newPass);
		}
		
		static private function invokeAnswerSignal(bmVO:BankMessageVO, needToAdd:Boolean = true):void {
			if (needToAdd == true) {
				bankMessages ||= [];
				bankMessages.push(bmVO);
			}
			S_ANSWER.invoke(bmVO);
		}
		
		static public function closeBankChatBotSession():void {
			initialized = false;
			if (bankMessages != null) {
				_initData = null;
				while (bankMessages.length != 0)
					bankMessages.shift().dispose();
				bankMessages = null;
			}
			_lastMainIndex = 0;
			inProgress = false;
			BankBotController.reset();
			BankBotController.S_ANSWER.remove(onAnswerReceived);
		}
		
		static private function getTransactionInfo(transactionID:String):void {
			BankBotController.getAnswer("bot:bankbot payments:transaction:" + transactionID);
		}
		
		static private function onTransactionInfoLoaded(transactionJSON:String):void {
			var data:Object = null;
			try {
				data = JSON.parse(transactionJSON);
			} catch (e:Error) {
				return;
			}
			currentTransaction = data;
			if (waitingBMVO != null) {
				if (waitingBMVO.waitingType == "operationTransactions" + currentTransaction.data.UID) {
					waitingBMVO.additionalData = currentTransaction.transactions;
				} else if (waitingBMVO.waitingType == "operationDetails" + currentTransaction.data.UID) {
					waitingBMVO.additionalData = currentTransaction.data;
				} else
					return;
				invokeAnswerSignal(waitingBMVO);
				waitingBMVO = null;
			}
		}
		
		static public function getPaymentHistory(
			page:int = 1,
			count:int = 50,
			historyAccount:String = "all",
			local:Boolean = true,
			flag:Boolean = false,
			currency:String = null,
			type:String = null,
			status:String = null,
			tsFrom:int = 0,
			tsTo:int = 0,
			obligatory:Boolean = false):void {
				init();
				needToCash = true
				if (needToGetHistoryUser != null) {
					needToCash = false;
					BankBotController.getAnswer("bot:bankbot payments:history:" + page + "|!|" + count + "|!|USER" + needToGetHistoryUser);
					needToGetHistoryUser = null;
					return;
				}
				if (flag == true)
					historyAccount = historyAcc;
				if (flag == false && historyAcc == historyAccount) {
					S_HISTORY_TS_ERROR.invoke();
					needToCash = false;
					return;
				}
				if (historyAccount == null || historyAccount == "") {
					historyAccCurrency = null;
					historyAccount = "all";
				}
				isCardHistory = false;
				isInvestmentHistory = false;
				if (historyAccount != "all") {
					var account:Object = getAccountByNumberAll(historyAccount);
					if (account != null) {
						if ("CURRENCY" in account == true)
							historyAccCurrency = account.CURRENCY;
						else if ("COIN" in account == true)
							historyAccCurrency = account.COIN;
					}
				}
				var notNull:Boolean = false;
				if (history != null &&
					historyAccount in history == true &&
					history[historyAccount] != null &&
					obligatory == false) {
						notNull = true;
						if (flag == true || historyAcc != historyAccount)
							S_HISTORY.invoke(history[historyAccount], true);
				}
				historyAcc = historyAccount;
				var request:String = "bot:bankbot payments:history:" + page + "|!|" + count + "|!|";
				if (historyAcc != "all")
					request += historyAcc;
				request += "|!|";
				if (type != null) {
					request += type;
					needToCash = false;
				}
				request += "|!|";
				if (status != null) {
					request += status;
					needToCash = false;
				}
				request += "|!|";
				if (tsFrom != 0) {
					request += tsFrom;
					needToCash = false;
				}
				request += "|!|";
				if (tsTo != 0) {
					request += tsTo;
					needToCash = false;
				}
				var tsCurrent:Number = new Date().getTime();
				if (obligatory == false &&
					notNull == true &&
					tsHistory != null &&
					historyAcc in tsHistory == true &&
					tsHistory[historyAcc] != null &&
					tsHistory[historyAcc] > tsCurrent - 60000) {
						S_HISTORY_TS_ERROR.invoke();
						needToCash = false;
						return;
				}
				tsHistory ||= {};
				tsHistory[historyAcc] = tsCurrent;
				BankBotController.getAnswer(request);
		}
		
		static public function getWallets(local:Boolean = true):void {
			init();
			if (local == true) {
				if (accountInfo != null) {
					accountInfo.accounts.sort(sortWallets);
					S_WALLETS.invoke(accountInfo.accounts, true);
				}
			} else
				BankBotController.getAnswer("bot:bankbot payments:wallets");
		}
		
		static public function getInvestments(local:Boolean = true):void {
			init();

			if (local == true) {

				if (investments != null) {

					investments.sort(sortInvestments);

					S_INVESTMENTS.invoke(investments, true);

				} else {
					S_INVESTMENTS.invoke(null, true);
				}
			} else
				BankBotController.getAnswer("bot:bankbot payments:investments");
		}
		
		static public function getCrypto(local:Boolean = true):void {
			init();
			if (local == true) {
				if (cryptoAccounts != null && cryptoAccounts.length > 0) {
					_cryptoExists = true;
					Store.save(Store.CRYPTO_EXISTS, true);
					S_CRYPTO.invoke(cryptoAccounts, true);
				} else
					S_CRYPTO.invoke(null, true);
			} else
				BankBotController.getAnswer("bot:bankbot payments:crypto");
		}
		
		static public function getCryptoRD(local:Boolean = true):void {
			init();
			if (local == true) {
				if (cryptoRDs != null) {
					S_CRYPTO_RD.invoke(cryptoRDs, true);
				}
			} else
				BankBotController.getAnswer("bot:bankbot payments:cryptoRD");
		}
		
		static public function getOperationTransactions(uid:String):void {
			init();
			BankBotController.getAnswer("bot:bankbot payments:transaction:" + uid);
		}
		
		static public function get cryptoExists():Boolean {
			return _cryptoExists;
		}
		
		static public function getCryptoRDs():Array {
			return cryptoRDs;
		}
		
		static public function getTotalServer(local:Boolean = true):void {
			init();
			if (local == true) {
				if (total != null) {
					S_TOTAL.invoke(total, local);
				} else {
					S_TOTAL.invoke(totalAccounts, local);
				}
			} else
				BankBotController.getAnswer("bot:bankbot payments:total");
		}
		
		static public function getInvestmentsArray():Array {
			return investments;
		}
		
		static public function getInvestmentByAccount(accNum:String = ""):Object {
			if (investments == null)
				return null;
			if (investments.length > 0) {
				for (var i:int = 0; i < investments.length; i++) {
					if (investments[i].ACCOUNT_NUMBER == accNum) {
						return investments[i];
					}
				}
			}
			return null;
		}
		
		static public function get allCards():Array {
			return cards;
		}
		
		static public function getAllData(local:Boolean = true, needToLoad:Boolean = false):void {
			init();
			if (local == true) {
				if (accountInfo != null)
					S_ALL_DATA.invoke(false, true);
				if (needToLoad == true)
					BankBotController.getAnswer("bot:bankbot payments:home");
			} else {
				GD.S_BANK_CACHE_ACCOUNT_INFO_REQUEST.invoke(onHomeLoaded);
				BankBotController.getAnswer("bot:bankbot payments:home");
			}
		}
		
		static public function getCards(local:Boolean = true, needToLoad:Boolean = false):void {
			init();
			if (local == true) {
				if (cards != null) {
					cards = cards.sort(sortCardsByType);
					S_CARDS.invoke(cards, true);
				}
				if (needToLoad == true)
					BankBotController.getAnswer("bot:bankbot payments:cards");
				else
					S_CARDS.invoke(null, true);
			} else
				BankBotController.getAnswer("bot:bankbot payments:cards");
		}
		
		static public function getLinkedCards():void {
			init();
			BankBotController.getAnswer("bot:bankbot payments:linkedCards");
		}
		
		static public function stopPayments():void {
			initialized = false;
			needToGetHistoryUser = null;
			needToCash = false;
			BankBotController.S_ANSWER.remove(onAnswerReceived);
			BankBotController.reset();
		}
		
		static public function getTotal():Object {
			return total;
		}
		
		static public function getTotalAll():Array {
			return totalAll;
		}
		
		static public function backToLastStep():void {
			checkForProgress();
			if (inProgress == true) {
				reset();
				return;
			}
			if (lastBankMessageVO.isMain == false) {
				reset();
				return;
			}
			sendMessage("system:toLast");
		}
		
		static public function reset():void {
			if (bankMessages != null && bankMessages.length != 0 && bankMessages[bankMessages.length - 1].isMain == true)
				return;
			if (lastBankMessageVO != null)
				lastBankMessageVO.disable();
			var msgDisplay:String = Lang.showMeMainMenu;
			var msg:String = "nav:main";
			
			var baVO:BankMessageVO = new BankMessageVO(msgDisplay);
			baVO.setMine();
			invokeAnswerSignal(baVO);
			
			sendMessage(msg);
		}
		
		static public function showLoadMyAccount():void {
			var msgDisplay:String = "Show all my accounts.";
			var baVO:BankMessageVO = new BankMessageVO(msgDisplay);
			baVO.setMine();
			invokeAnswerSignal(baVO);
		}
		
		static public function showInvestmentItemHistory(instrument:String):void {
			init();
			historyAcc = instrument;
			isInvestmentHistory = true;
			isCardHistory = false;
			var request:String = "bot:bankbot payments:investmentHistory:" + instrument;
			BankBotController.getAnswer(request);
		}
		
		static public function showAllAcounts():void {
			reset();
		}
		
		static public function getInvestmentsDetails():Object {
			return investmentDetails;
		}
		
		static public function getAccountInfo():AccountInfoVO {
			return accountInfo;
		}
		
		static public function getCryptoAccounts():Array {
			return cryptoAccounts;
		}
		
		static public function getCryptoBCAccounts():Array {
			return cryptoBCAccounts;
		}
		
		static public function getCryptoDealAccounts(type:int = 0, active:Boolean = false):Array {
			if (cryptoDeals == null)
				return null;
			if ("my" in cryptoDeals == false ||
				cryptoDeals.my == null ||
				cryptoDeals.my is Array == false ||
				cryptoDeals.my.length == 0)
					return null;
			var res:Array;
			var l:int = cryptoDeals.my.length;
			var deal:Object;
			for (var i:int = 0; i < l; i++) {
				deal = cryptoDeals.my[i];
				if (active == false && deal.active == false)
					continue;
				if (type == 1 && deal.side != "BUY")
					continue;
				if (type == 2 && deal.side != "SELL")
					continue;
				res ||= [];
				res.push(deal);
			}
			return res;
		}
		
		static public function getCryptoDealByUID(uid:String):Object {
			if (cryptoDeals == null)
				return null;
			if ("my" in cryptoDeals == false ||
				cryptoDeals.my == null ||
				cryptoDeals.my is Array == false ||
				cryptoDeals.my.length == 0)
					return null;
			var l:int = cryptoDeals.my.length;
			var deal:Object;
			for (var i:int = 0; i < l; i++) {
				deal = cryptoDeals.my[i];
				if (deal.uid == uid)
					return deal;
			}
			return null;
		}
		
		static public function getCryptoBoard():Object {
			if (cryptoDeals == null)
				return null;
			if ("board" in cryptoDeals == false ||
				cryptoDeals.board == null)
					return null;
			return cryptoDeals.board;
		}
		
		static public function openMarketPlace(type:int = -1):void {
			var mpsd:MarketplaceScreenData = new MarketplaceScreenData();
			mpsd.dataProvider = getCryptoBoard;
			mpsd.myOrders = getCryptoDealAccounts;
			mpsd.resreshFunction = refreshCryptoBoard;
			mpsd.updateSignal = S_CRYPTO_DEALS;
			mpsd.tradeFunction = tradeCoins;
			mpsd.tradeSignal = S_TRADE_COMPLETE;
			mpsd.createLotFunction = createNewLot;
			if (type != -1)
				mpsd.type = type;
			MobileGui.changeMainScreen(
				CoinMarketplace,
				{
					backScreen:MobileGui.centerScreen.currentScreenClass,
					backScreenData:MobileGui.centerScreen.currentScreen.data,
					screeenData:mpsd
				}
			);
		}
		
		static public function getPossibleRewardDeposites(giftData:GiftData):void {
			var curency:String = giftData.currency;
			var amount:Number = giftData.customValue;
			BankBotController.getAnswer("bot:bankbot payments:possibleRewardDeposites:" + curency + "|!|" + amount);
		}
		
		static public function refreshCryptoBoard():void {
			BankBotController.getAnswer("bot:bankbot payments:cryptoOffers");
		}
		
		static public function getDeclareETHAddressLink(currency:String = "DCO"):void {
			if (currency == null)
				currency = "DCO";
			BankBotController.getAnswer("bot:bankbot payments:getDeclareETHAddressLink:" + currency);
		}
		
		static public function getHistoryAccount():String {
			return historyAcc;
		}
		
		static public function getHistoryAccountIBAN():String {
			return historyAccIBAN;
		}
		
		static public function getAccountCurrency():String {
			if (historyAccCurrency == "DCO")
				return "DUK+";
			return historyAccCurrency;
		}
		
		static public function getCardHistory(cardNumber:String, masked:String):void {
			init();
			historyAcc = cardNumber;
			tsHistory ||= {};
			tsHistory[historyAcc] = new Date().getTime();
			isCardHistory = true;
			isInvestmentHistory = false;
			cardMasked = masked.replace("********", "…");
			var request:String = "bot:bankbot payments:cardHistory:" + cardNumber;
			BankBotController.getAnswer(request);
		}
		
		static public function getIsCardHistory():Boolean {
			return isCardHistory;
		}
		
		static public function getIsInvestmentHistory():Boolean {
			return isInvestmentHistory;
		}
		
		static private function onHistoryLoaded(historyJSON:String):void {
			var data:Object = null;
			try {
				data = JSON.parse(historyJSON);
			} catch (e:Error) {
				S_HISTORY.invoke(null, false);
				return;
			}
			history ||= { };
			if (needToCash == true)
				history[historyAcc] = data as Array;
			S_HISTORY.invoke(data, false);
		}
		
		static private function onHistoryMoreLoaded(historyJSON:String):void {
			var data:Object = null;
			try {
				data = JSON.parse(historyJSON);
			} catch (e:Error) {
				S_HISTORY_MORE.invoke(null, false);
				return;
			}
			S_HISTORY_MORE.invoke(data, false);
		}
		
		static private function onHistoryTradesLoaded(historyTradesJSON:String):void {
			var data:Object = null;
			try {
				data = JSON.parse(historyTradesJSON);
			} catch (e:Error) {
				S_HISTORY_TRADES.invoke(null);
				return;
			}
			S_HISTORY_TRADES.invoke(data);
		}
		
		static private function onInvestmentHistoryLoaded(historyJSON:String):void {
			var data:Object = null;
			try {
				data = JSON.parse(historyJSON);
			} catch (e:Error) {
				S_HISTORY.invoke(null, false);
				return;
			}
			S_HISTORY.invoke(data, false);
		}
		
		static private function onInvestmentDetailsLoaded(historyJSON:String):void {
			var data:Object = null;
			try {
				data = JSON.parse(historyJSON);
			} catch (e:Error) {
				S_INVESTMENT_DETAIL.invoke(null, false);
				return;
			}
			if (data != null){
				investmentDetails ||= {};
				investmentDetails[data.INSTRUMENT] = data;
			}
			S_INVESTMENT_DETAIL.invoke(data.data, false);
		}
		
		static private function onWalletsLoaded(walletsJSON:String):void {
			var data:Object = null;
			try {
				data = JSON.parse(walletsJSON);
			} catch (e:Error) {
				S_WALLETS.invoke(null, false);
				return;
			}
			processAccount( { account:data } );
			S_WALLETS.invoke(accountInfo.accounts, false);
		}
		
		static private function processAccount(data:Object):void {
			if ("account" in data == false || data.account == null)
				return;
			accountInfo ||= new AccountInfoVO();
			PayManager.accountInfo = accountInfo;
			accountInfo.update(data.account);
			PayManager.updateaccountInfo(data);
			BankBotController.setMyAccountNumber(accountInfo.customerNumber);
			accountInfo.accounts.sort(sortWallets);
			if (accountInfo.enableInvestments == true) {
				delete BankBotController.getScenario().scenario.main.menu[6].disabled;
			} else {
				BankBotController.getScenario().scenario.main.menu[6].disabled = true;
			}
			if (accountInfo.enableTrading == true) {
				delete BankBotController.getScenario().scenario.main.menu[8].disabled;
			} else {
				BankBotController.getScenario().scenario.main.menu[8].disabled = true;
			}
			if (accountInfo.enableSaving == true) {
				delete BankBotController.getScenario().scenario.otherWithdrawalAcc.menu[1].disabled;
				delete BankBotController.getScenario().scenario.accountOperations.menu[1].disabled;
				delete BankBotController.getScenario().scenario.otherExchangeAcc.menu[1].disabled;
				delete BankBotController.getScenario().scenario.deposites.menu[5].disabled;
				delete BankBotController.getScenario().scenario.sendMoney.menu[6].disabled;
				delete BankBotController.getScenario().scenario.withdrawals.menu[4].disabled;
				delete BankBotController.getScenario().scenario.selectNewWalletCurrency.menu[1].disabled;
			} else {
				BankBotController.getScenario().scenario.otherWithdrawalAcc.menu[1].disabled = true;
				BankBotController.getScenario().scenario.accountOperations.menu[1].disabled = true;
				BankBotController.getScenario().scenario.otherExchangeAcc.menu[1].disabled = true;
				BankBotController.getScenario().scenario.deposites.menu[5].disabled = true;
				BankBotController.getScenario().scenario.sendMoney.menu[6].disabled = true;
				BankBotController.getScenario().scenario.withdrawals.menu[4].disabled = true;
				BankBotController.getScenario().scenario.selectNewWalletCurrency.menu[1].disabled = true;
			}
			if (accountInfo.enableApplePay == true && Config.PLATFORM_APPLE == true) {
				delete BankBotController.getScenario().scenario.deposites.menu[7].disabled;
			} else {
				BankBotController.getScenario().scenario.deposites.menu[7].disabled = true;
			}
			if (waitingBMVO != null) {
				if (waitingBMVO.waitingType != "wallets" && waitingBMVO.waitingType != "limits")
					return;
				if (waitingBMVO.waitingType == "wallets")
					waitingBMVO.additionalData = accountInfo.accounts;
				invokeAnswerSignal(waitingBMVO);
				waitingBMVO = null;
			}
		}
		
		static private function onTotalLoaded(totalJSON:String):void {
			var data:Object = null;
			try {
				data = JSON.parse(totalJSON);
			} catch (e:Error) {
				S_TOTAL.invoke(null, false);
				return;
			}
			checkTotal(data);
			S_TOTAL.invoke(total, false);
		}
		
		static public function get allInvestments():Array {
			return investments;
		}
		
		static private function onInvestmentsLoaded(investmentsJSON:String):void {
			var data:Object = null;
			try {
				data = JSON.parse(investmentsJSON);
			} catch (e:Error) {
				S_INVESTMENTS.invoke(null, false);
				return;
			}
			processInvestments(data);
			S_INVESTMENTS.invoke(investments, false);
			if (waitingBMVO != null) {
				if (waitingBMVO.waitingType != "investments")
					return;
				invokeAnswerSignal(waitingBMVO);
				waitingBMVO = null;
			}
		}
		
		static private function processInvestments(data:Object):void {
			if (data == null || data.length == 0) {
				investments = null;
				return;
			}
			investments = data as Array;
			investments.sort(sortInvestments);
			var l:int = investments.length;
			investmentExist = false;
			for (var i:int = 0; i < l; i++) {
				if (Number(investments[i].BALANCE) > 0) {
					investmentExist = true;
					break;
				}
			}
		}
		
		static private function onCryptoDealsAccounts(cryptoJSON:String):void {
			cryptoOffersLoaded = true;
			var data:Object = null;
			try {
				data = JSON.parse(cryptoJSON);
			} catch (e:Error) {
				S_CRYPTO_DEALS.invoke(null);
				return;
			}
			cryptoDeals = data;
			S_CRYPTO_DEALS.invoke(cryptoDeals);
			if (waitingBMVO != null) {
				if (waitingBMVO.waitingType != "cryptoOffers" &&
					waitingBMVO.waitingType != "cryptoTradeStat")
						return;
				if (waitingBMVO.waitingType != "cryptoOffers") {
					waitingBMVO.additionalData = cryptoDeals.stat;
					waitingBMVO.additionalData ||= [];
					if (cryptoDeals.coins != null) {
						for (var i:int = 0; i < cryptoDeals.coins.length; i++) {
							if (cryptoDeals.coins[i].COIN == "DCO") {
								waitingBMVO.additionalData.unshift(cryptoDeals.coins[0]);
								break;
							}
						}
					}
				}
				invokeAnswerSignal(waitingBMVO);
				waitingBMVO = null;
			}
		}
		
		static public function getBestPrice(side:int):AccountLimitVO {
			if (cryptoDeals == null)
				return null;
			var price:Number = 0;
			if ("board" in cryptoDeals == false || cryptoDeals.board == null)
				return null;
			var i:int;
			if (side == 0) {
				if ("BUY" in cryptoDeals.board == false || cryptoDeals.board.BUY == null || cryptoDeals.board.BUY.length == 0)
					return null;
				for (i = 0; i < cryptoDeals.board.BUY.length; i++) {
					if (cryptoDeals.board.BUY[i].own == false) {
						price = Number(cryptoDeals.board.BUY[i].price);
						break;
					}
				}
				price = Number(cryptoDeals.board.BUY[0].price);
			} else if (side == 1) {
				if ("SELL" in cryptoDeals.board == false || cryptoDeals.board.SELL == null || cryptoDeals.board.SELL.length == 0)
					return null;
				for (i = 0; i < cryptoDeals.board.SELL.length; i++) {
					if (cryptoDeals.board.SELL[i].own == false) {
						price = Number(cryptoDeals.board.SELL[i].price);
						break;
					}
				}
			}
			var alVO:AccountLimitVO = new AccountLimitVO( [ AccountLimit.TYPE_BEST_MARKET_PRICE, NaN, price, "EUR" ] );
			return alVO;
		}
		
		static private function onCryptoAccounts(cryptoJSON:String):void {
			cryptoAccountsLoaded = true;
			var data:Object = null;
			try {
				data = JSON.parse(cryptoJSON);
			} catch (e:Error) {
				S_CRYPTO.invoke(null, false);
				return;
			}
			processCrypto(data);
			S_CRYPTO.invoke(cryptoAccounts, false);
		}
		
		static private function processCrypto(data:Object):void {
			if (data is Array) {
				cryptoAccounts = data as Array;
			} else {
				if ("coin" in data == true)
					cryptoAccounts = data.coin as Array;
				if ("blockchain" in data == true)
					cryptoBCAccounts = data.blockchain as Array;
			}
			if (cryptoAccounts != null && cryptoAccounts.length > 0) {
				Store.save(Store.CRYPTO_EXISTS, true);
				_cryptoExists = true;
			}
			if (waitingBMVO != null) {
				if (waitingBMVO.waitingType != "crypto")
					return;
				invokeAnswerSignal(waitingBMVO);
				waitingBMVO = null;
			}
		}
		
		static private function onCryptoRDs(cryptoJSON:String):void {
			cryptoRDLoaded = true;
			var data:Object = null;
			try {
				data = JSON.parse(cryptoJSON);
			} catch (e:Error) {
				cryptoRDLoaded = false;
			}
			cryptoRDs = data as Array;
			var i:int = cryptoRDs.length;
			S_CRYPTO_RD.invoke(cryptoRDs, false);
			if (waitingBMVO != null) {
				if (waitingBMVO.waitingType != "cryptoRD")
					return;
				invokeAnswerSignal(waitingBMVO);
				waitingBMVO = null;
			}
		}
		
		static public function checkForMaxDepositeLimit(fiat:Boolean = false):Number {
			if (cryptoRDs == null || cryptoRDs.length == 0) {
				if (fiat == true)
					return fiatMax;
				return coinMax;
			}
			var current:Number = 0;
			for (var i:int = 0; i < cryptoRDs.length; i++) {
				if (cryptoRDs[i].type == "coin" && fiat == false) {
					current += Number(cryptoRDs[i].amount);
					continue;
				}
				if (cryptoRDs[i].type == "fiat" && fiat == true) {
					current += Number(cryptoRDs[i].amount);
					continue;
				}
			}
			if (fiat == true)
				return fiatMax - current;
			else
				return coinMax - current;
		}
		
		static private function checkTotal(data:Object):void {
			if (data == null)
				return;
			var lastOpened:Boolean = (total != null) ? total.opened : false;
			totalAll = [];
			total ||= {
				"type": "total",
				"IBAN": Lang.textTotalCash.toUpperCase(),
				"opened": lastOpened
			};
			total["BALANCE"] = 0;
			total["CURRENCY"] = accountInfo.consolidateCurrency
			var balance:Number;
			var index:int;
			for (var n:String in data) {
				index = data[n].indexOf(" ");
				balance = Number(data[n].substr(0, index));
				if (isNaN(balance) == false)
					total["BALANCE"] += balance;
				totalAll.push( {
					"type": "total",
					"IBAN": Lang["textTotal" + n.charAt(0).toUpperCase() + n.substr(1).toLowerCase()].toUpperCase(),
					"BALANCE": balance,
					"CURRENCY": accountInfo.consolidateCurrency
				} );
			}
		}
		
		static public function get totalAccounts():Object {
			if (totalAll == null || totalAll.length == 0) {
				if (accountInfo != null && accountInfo.accounts != null && accountInfo.accounts.length > 0) {
					var totalAcc:Object = {
						"type": "total",
						"IBAN": Lang.textTotalAccounts.toUpperCase(),
						"BALANCE": 0,
						"CURRENCY": accountInfo.consolidateCurrency
					}
					for (var j:int = 0; j < accountInfo.accounts.length; j++) {
						totalAcc.BALANCE += Number(accountInfo.accounts[j].CONSOLIDATE_BALANCE);
					}
				}
				return totalAcc;
			}
			var l:int = totalAll.length;
			for (var i:int = 0; i < l; i++) {
				if (totalAll[i].IBAN.toLowerCase().indexOf("accounts") != -1)
					return totalAll[i];
			}
			return null;
		}
		
		static public function get totalSavingAccounts():Object {
			if (savingsAccounts == null || savingsAccounts.length == 0)
				return null;
			var res:Object = {
				CURRENCY: savingsAccounts[0].CONSOLIDATE_CURRENCY,
				IBAN: Lang.textTotalCash.toUpperCase(),
				type: "total",
				opened: false,
				moreFnc: getTotalSavingsAll
			}
			var balance:Number = 0;
			var l:int = savingsAccounts.length;
			for (var i:int = 0; i < l; i++) {
				balance += Number(savingsAccounts[i].CONSOLIDATE_BALANCE);
			}
			res.BALANCE = balance;
			return res;
		}
		
		static public function getTotalSavingsAll():Array {
			return null;
		}
		
		static private function onFatCatzLoaded(fatCatzJSON:String):void {
			var data:Object = null;
			try {
				data = JSON.parse(fatCatzJSON);
			} catch (e:Error) {
				return;
			}
			fatCatz = data;
			if (waitingBMVO != null) {
				if (waitingBMVO.waitingType != "fatCatz")
					return;
				waitingBMVO.additionalData = fatCatz;
				var dt:Date = new Date();
				if (waitingBMVO.additionalData.is_fc == true)
					waitingBMVO.text = waitingBMVO.addDesc[1];
				else
					waitingBMVO.text = waitingBMVO.addDesc[0];
				if ("avg_balance_required" in fatCatz == true)
					waitingBMVO.text = waitingBMVO.text.replace(/%@1/g, fatCatz.avg_balance_required.substr(0, fatCatz.avg_balance_required.indexOf(" ")));
				waitingBMVO.text = waitingBMVO.text.replace(/%@/g, Lang["month_" + dt.getMonth()]);
				invokeAnswerSignal(waitingBMVO);
				waitingBMVO = null;
			}
		}
		
		static private function onPossibleRDsReceived(fatCatzJSON:String):void {
			var data:Object = null;
			try {
				data = JSON.parse(fatCatzJSON);
			} catch (e:Error) {
				return;
			}
			S_POSSIBLE_RD.invoke(data);
		}
		
		static private function onETHLinkReceived(link:String):void {
			var data:Object = null;
			try {
				data = JSON.parse(link);
			} catch (e:Error) {
				return;
			}
			S_DECLARE_ETH_LINK.invoke(data);
		}
		
		static private function onTPILinkReceived(link:String):void {
			var data:Object = null;
			try {
				data = JSON.parse(link);
			} catch (e:Error) {
				return;
			}
			var description:String = "";
			var filename:String = "";
			if (data != null && "amount" in data && "currency" in data)
			{
				var date:Date = new Date();
				date.setTime(date.getTime() + 7 * 24 * 60 * 60 * 1000);
				description = data.amount + " " + data.currency + " invoice, valid till " + DateUtils.getComfortDateRepresentationOnlyDate(date, true);
				filename = data.amount + " " + data.currency + " " + DateUtils.getComfortDateRepresentationOnlyDate(date, true)
				filename = filename.replace(/\./g, "-");
			}
			ServiceScreenManager.showScreen(
				ServiceScreenManager.TYPE_SCREEN,
				ShareLinkPopup,
				{
					url:data.url,
					filename:filename,
					title:Lang.requestMoney,
					description:description,
					subtitle:Lang.requestMoneyDesc,
					sharetitle:data.message
				}
			);
			
			/*ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, 
											ShareLinkPopup, 
												{url:"http://google.com", 
												title:Lang.requestMoney, 
												description:"20 EUR invoice, valid till 12 Jan 2020",
												subtitle:"Send the link to the contact to request money", 
												callback:function(result:String):void{}})*/
		}
		
		static private function onHomeLoaded(homeJSON:String, fromELS:Boolean = false):void {
			var data:Object = null;
			try {
				data = JSON.parse(homeJSON);
			} catch (e:Error) {
				S_ALL_DATA.invoke(true, fromELS);
				return;
			}
			if (fromELS == false && data.fullRequest == true) {
				GD.S_BANK_CACHE_ACCOUNT_INFO_SAVE.invoke(homeJSON);
			} else if (homeJSON == null) {
				return;
			}
			processAccount(data);
			if ("prepaid-cards" in data == true &&
				data["prepaid-cards"] != null &&
				"card_orders" in data["prepaid-cards"] == true &&
				"cards" in data["prepaid-cards"] == true)
					processCards(data["prepaid-cards"]);
			if ("linked-cards" in data == true &&
				data["linked-cards"] != null) {
					cardsLoaded = true;
					processLinkedCards(data["linked-cards"]);
			}
			if ("investments" in data == true &&
				data["investments"] != null)
					processInvestments(data["investments"]);
			if ("coins" in data == true &&
				data["coins"] != null)
					processCrypto(data["coins"]);
			if ("aic" in data == true &&
				data["aic"] != null)
					checkTotal(data["aic"]);
			if ("other-accounts" in data == true &&
				data["other-accounts"] != null) {
					otherAccountLoaded = true;
					processOtherAccounts(data["other-accounts"]);
			}
			if (accountInfo.enableSaving == true &&
				"savings" in data == true &&
				data["savings"] != null) {
					savingsAccountLoaded = true;
					processSavingsAccounts(data["savings"]);
			}
			S_ALL_DATA.invoke(false, fromELS);
		}
		
		static private function processOtherAccounts(data:Array):void {
			otherAccounts = data;
			if (otherAccounts == null || otherAccounts.length == 0) {
				BankBotController.getScenario().scenario.withdrawals.menu[5].disabled = true;
				BankBotController.getScenario().scenario.sendMoney.menu[7].disabled = true;
				BankBotController.getScenario().scenario.deposites.menu[6].disabled = true;
			} else {
				delete BankBotController.getScenario().scenario.withdrawals.menu[5].disabled;
				delete BankBotController.getScenario().scenario.sendMoney.menu[7].disabled;
				delete BankBotController.getScenario().scenario.deposites.menu[6].disabled;
			}
			otherAccounts.sort(otherAccountSort);
			if (waitingBMVO != null) {
				if (waitingBMVO.waitingType != "homeS")
					return;
				waitingBMVO.additionalData = otherAccounts.slice();
				invokeAnswerSignal(waitingBMVO);
				waitingBMVO = null;
			}
		}
		
		static private function processSavingsAccounts(data:Array):void {
			savingsAccounts = data;
			savingsAccounts.sort(sortWallets);
			if (waitingBMVO != null) {
				if (waitingBMVO.waitingType != "walletsSav")
					return;
				waitingBMVO.additionalData = savingsAccounts.slice();
				invokeAnswerSignal(waitingBMVO);
				waitingBMVO = null;
			}
		}
		
		static private function otherAccountSort(a:Object, b:Object):int {
			if (a.TYPE == "02" || b.TYPE == "02") {
				if (a.TYPE == b.TYPE) {
					if (a.IBAN < b.IBAN)
						return -1;
					return 1;
				} else if (b.TYPE == "02")
					return 1;
				return -1;
			}
			if (a.TYPE == "22" || b.TYPE == "22") {
				if (a.TYPE == b.TYPE) {
					if (a.IBAN < b.IBAN)
						return -1;
					return 1;
				} else if (b.TYPE == "22")
					return 1;
				return -1;
			}
			if (a.TYPE == "41" || b.TYPE == "41") {
				if (a.TYPE == b.TYPE) {
					if (a.IBAN < b.IBAN)
						return -1;
					return 1;
				} else if (b.TYPE == "41")
					return 1;
				return -1;
			}
			if (a.TYPE == "04" || b.TYPE == "04") {
				if (a.TYPE == b.TYPE) {
					if (a.IBAN < b.IBAN)
						return -1;
					return 1;
				} else if (b.TYPE == "04")
					return 1;
				return -1;
			}
			if (a.TYPE == "05" || b.TYPE == "05") {
				if (a.TYPE == b.TYPE) {
					if (a.IBAN < b.IBAN)
						return -1;
					return 1;
				} else if (b.TYPE == "05")
					return 1;
				return -1;
			}
			if (a.IBAN < b.IBAN)
				return -1;
			return 1;
		}
		
		static private function onCardsLoaded(cardsJSON:String):void {
			var data:Object = null;
			try {
				data = JSON.parse(cardsJSON);
			} catch (e:Error) {
				S_CARDS.invoke(null, false);
				return;
			}
			processCards(data);
			getLinkedCards();
		}
		
		static private function processCards(data:Object):void {
			if (data.card_issue_available == true) {
				cardIssueAvailable = true;
				//delete BankBotController.getScenario().scenario.cards.menu[0].disabled;
			} else {
				cardIssueAvailable = false;
				//BankBotController.getScenario().scenario.cards.menu[0].disabled = true;
			}
			cards ||= [];
			cards.length = 0;
			var temp:Array = data.card_orders;
			var i:int;
			var l:int;
			if (temp != null && temp.length != 0) {
				l = temp.length;
				for (i = 0; i < l; i++)
					cards.push(
						{
							valid:"",
							holder:"",
							cvv:"",
							status:"",
							masked:"****************",
							numberCard:"",
							available:"0.00",
							currency:temp[i].currency,
							ordered:true,
							programme:temp[i].programme
						} 
					);
			}
			temp = data.cards;
			if (temp != null && temp.length != 0) {
				l = temp.length;
				var cardObject:Object;
				for (i = 0; i < l; i++) {
						cardObject = {
						valid: temp[i].valid,
						holder: temp[i].name_on_card,
						cvv: temp[i].code,
						status: temp[i].status,
						number: temp[i].id,
						masked: temp[i].masked,
						numberCard: temp[i].number,
						available: temp[i].available,
						currency: temp[i].currency,
						programme: temp[i].programme
					};
					if (cardObject.numberCard == null)
						cardObject.numberCard = cardObject.masked;
					if (cardObject.cvv == null)
						cardObject.cvv = "";
					if (cardObject.holder == null)
						cardObject.holder = "";
					if ("tracking_number" in temp[i] && temp[i].tracking_number != null && temp[i].tracking_number.length != 0)
						cardObject.trackingNumber = temp[i].tracking_number;
					if ("can_be_reloaded" in temp[i] && temp[i].can_be_reloaded == 1)
						cardObject.reloaded = true;
					if (isCardHistory == true && historyAcc == temp[i].id) {
						cards.unshift(cardObject);
						continue;
					}
					cards.push(cardObject);
				}
			}
		}
		
		static private function sortCardsByType(a:Object, b:Object):int {
			if (isCardHistory == true) {
				if (a.number == historyAcc)
					return -1;
				if (b.number == historyAcc)
					return 1;
			}
			if ("ordered" in a == true && a.ordered == true && "ordered" in b == true && b.ordered == true) {
				if (a.programme == b.programme)
					return 0;
				else if (a.programme < b.programme)
					return -1;
				return 1;
			}
			if ("ordered" in a == true && a.ordered == true)
				return 1;
			if ("ordered" in b == true && b.ordered == true)
				return -1;
			if (a.status == "H" && a.status == b.status) {
				if (a.programme == b.programme) {
					if (a.number < b.number)
						return -1;
					return 1;
				}
				else if (a.programme < b.programme)
					return -1;
				return 1;
			}
			if (a.status == "H")
				return 1;
			if (b.status == "H")
				return -1;
			if (a.programme == "linked" && a.programme == b.programme) {
				if (a.number < b.number)
					return -1;
				return 1;
			}
			if (a.programme == "linked")
				return 1;
			if (b.programme == "linked")
				return -1;
			if (a.programme < b.programme)
				return -1;
			if (a.programme > b.programme)
				return 1;
			if (a.number < b.number)
				return -1;
			if (a.number > b.number)
				return 1;
			return 0;
		}
		
		static private function onLinkedCardsLoaded(linkedCardsJSON:String):void {
			cardsLoaded = true;
			var data:Array = null;
			try {
				data = JSON.parse(linkedCardsJSON) as Array;
			} catch (e:Error) {
				if (cards != null)
					cards = cards.sort(sortCardsByType);
				S_CARDS.invoke(cards, false);
				return;
			}
			processLinkedCards(data);
			S_CARDS.invoke(cards, false);
		}
		
		static private function processLinkedCards(data:Array):void {
			cards ||= [];
			var i:int;
			var l:int;
			if (data != null && data.length != 0) {
				l = data.length;
				var status:String;
				var cardData:Object;
				for (i = 0; i < l; i++) {
					if (data[i].status == "NOT VERIFIED")
						status = "NL";
					else if (data[i].status == "EXPIRED")
						status = "EL";
					else
						status = "AL";
					if (getCardByNumber(data[i].uid) != null)
						continue;
					cardData = { status:status, number:data[i].uid, masked:data[i].number, available:0, programme:"linked" };
					if ("bank_name" in data[i] == true)
						cardData.bankName = data[i].bank_name;
					if ("ccy" in data[i] && data[i].ccy != null)
						cardData.ccy = data[i].ccy;
					if (cardData.bankName == null)
						delete cardData.bankName;
					//cards.push( { status:status, number:data[i].uid, masked:data[i].number, available:0, currency:data[i].ccy, programme:"linked" } );
					cards.push(cardData);
				}
			}
			cards = cards.sort(sortCardsByType);
			if (waitingBMVO != null) {
				if (waitingBMVO.waitingType != "cards")
					return;
				waitingBMVO.additionalData = cards;
				invokeAnswerSignal(waitingBMVO);
				waitingBMVO = null;
			}
		}
		
		static public function getCardMasked():String {
			return cardMasked;
		}
		
		static public function showHistoryByCoinAccountNumber(account:Object):void {
			historyAcc = account.ACCOUNT_NUMBER;
			historyAccCurrency = (account.COIN == "DCO") ? "DUK+" : account.COIN;
		}
		
		static public function showHistoryByAccountNumber(account:Object):void {
			if (account == null)
				return;
			historyAcc = account.ACCOUNT_NUMBER;
			historyAccCurrency = account.CURRENCY;
		}
		
		static public function getAllCards():Array {
			return cards;
		}
		
		static public function getInvestmentsTotal():Object {
			if (investments == null || investments.length == 0) {
				return {
					BALANCE: 0,
					CURRENCY: "EUR",
					IBAN: "TOTAL INVESTMENTS",
					type: "total"
				};
			}
			var total:Number = 0;
			var l:int = investments.length;
			for (var i:int = 0; i < l; i++)
				total += Number(investments[i].CONSOLIDATE_BALANCE);
			return {
				BALANCE: total,
				CURRENCY: ("CONSOLIDATE_CURRENCY" in investments[0] == false) ? "EUR" : investments[0].CONSOLIDATE_CURRENCY,
				IBAN: "TOTAL INVESTMENTS",
				type: "total"
			};
		}
		
		static private function sortWallets(a:Object, b:Object):int {
			if (String(a.ACCOUNT_NUMBER) == historyAcc)
				return -1;
			if (String(b.ACCOUNT_NUMBER) == historyAcc)
				return 1;
			if (Number(a.BALANCE) < Number(b.BALANCE))
				return 1;
			if (Number(a.BALANCE) > Number(b.BALANCE))
				return -1;
			if (a.IBAN < b.IBAN)
				return -1;
			if (a.IBAN > b.IBAN)
				return 1;
			return 0;
		}
		
		static private function sortInvestments(a:Object, b:Object):int {
			if (String(a.INSTRUMENT) == historyAcc)
				return -1;
			if (String(b.INSTRUMENT) == historyAcc)
				return 1;
			if (Number(a.CONSOLIDATE_BALANCE) < Number(b.CONSOLIDATE_BALANCE))
				return 1;
			if (Number(a.CONSOLIDATE_BALANCE) > Number(b.CONSOLIDATE_BALANCE))
				return -1;
			if (a.ACCOUNT_NUMBER < b.ACCOUNT_NUMBER)
				return -1;
			if (a.ACCOUNT_NUMBER > b.ACCOUNT_NUMBER)
				return 1;
			return 0;
		}
		
		static public function get needToShowMenu():Boolean {
			return inProgress;
		}
		
		static public function checkForProgress(needToCloseSession:Boolean = false):void {
			if (bankMessages == null ||
				bankMessages.length == 0 ||
				bankMessages[bankMessages.length - 1].isMain == true ||
				bankMessages[bankMessages.length - 1].isLast == true) {
					if (needToCloseSession == true)
						closeBankChatBotSession();
					else
						inProgress = false;
					return;
			}
			inProgress = true;
		}
		
		static public function setSelectedData(data:Object):void {
			selectedData = data;
		}
		
		static public function getOtherAccounts():Array {
			return otherAccounts;
		}
		
		static public function getSavingsAccounts():Array {
			return savingsAccounts;
		}
		
		static public function getTimeForHistory():Number {
			if (tsHistory == null || historyAcc in tsHistory == false)
				return NaN;
			return tsHistory[historyAcc];
		}
		
		static public function getDCOWallet(currency:String = "DCO"):String {
			if (accountInfo != null) {
				if (currency == null || currency.toLowerCase() == "dco" || currency.toLowerCase() == "eth")
					return accountInfo.ethAddress;
				if (currency.toLowerCase() == "btc")
					return accountInfo.btcAddress;
			}
			return null;
		}
		
		static public function loadCoinTrades(data:Object, n:int):Boolean {
			if ("raw" in data == false || data.raw == null)
				return false;
			if ("TYPE" in data.raw == false)
				return false;
			if (data.raw.TYPE != "COIN_STAT_BUY" && data.raw.TYPE != "COIN_STAT_SELL")
				return false;
			var request:String = "bot:bankbot payments:historyTrades:";
			if (data.raw.TYPE == "COIN_STAT_BUY")
				request += "COIN_BUY";
			else
				request += "COIN_SELL";
			var dt:Date = new Date();
			dt.setTime(data.time);
			request += "|!|" + DateUtils.getDateStringByFormat(dt, "YYYY-MM-DD", true);
			BankBotController.getAnswer(request);
			return true;
		}
	}
}