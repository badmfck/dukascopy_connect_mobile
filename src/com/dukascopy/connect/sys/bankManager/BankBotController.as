package com.dukascopy.connect.sys.bankManager {
	
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.screens.dialogs.paymentDialogs.PaymentsUnavaliableScreen;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.payments.CurrencyHelpers;
	import com.dukascopy.connect.sys.payments.PayAPIManager;
	import com.dukascopy.connect.sys.payments.PayAuthManager;
	import com.dukascopy.connect.sys.payments.PayConfig;
	import com.dukascopy.connect.sys.payments.PayManager;
	import com.dukascopy.connect.sys.payments.PayRespond;
	import com.dukascopy.connect.sys.paymentsManagerNew.PaymentsManagerNew;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.utils.DateUtils;
	import com.dukascopy.langs.Lang;
	import com.dukascopy.langs.LangManager;
	import com.telefision.sys.signals.Signal;
	import flash.utils.ByteArray;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class BankBotController {
		
		static public var rewards:Array = [
			{ amount: 100, reward: 5 },
			{ amount: 250, reward: 10 },
			{ amount: 500, reward: 20 },
			{ amount: 750, reward: 30 },
			{ amount: 1000, reward: 40 },
			{ amount: 2000, reward: 50 },
			{ amount: 3000, reward: 60 },
			{ amount: 4000, reward: 70 },
			{ amount: 5000, reward: 80 },
			{ amount: 7500, reward: 90 },
			{ amount: 10000, reward: 100 }
		];
		static public var cashContracts:Array = [
			{ title: "EUR", address: "0x57dae83653dd99e876ff1f11b970c686b90a9a2e" },
			{ title: "USD", address: "0x3ecf807b8a10e053d5273312f2384e5d59f81057" },
			{ title: "CHF", address: "0x18aa37548adc1826411b5da2aa026e7e7af9ca4f" }
		];
		static public var rewardFiat:Number = .5;
		
		static public var S_ANSWER:Signal = new Signal('BankBotController.S_ANSWER');
		
		static private var scenario:BankBotScenario = new BankBotScenario();
		
		static private var steps:Array;
		static private var stepsOld:Array;
		
		static private var lastPaymentsRequests:Object;
		static private var lastPaymentsRequestsID:Object;
		
		static private var myAccountNumber:int = -1;
		static private var isLoggining:Boolean = false;
		static private var waitForPass:Boolean = false;
		
		static private var langClass:Class;
		
		static private var nonSessionCounter:int;
		static private var save:Boolean = true;
		
		static public var accountInfo:Object;
		static public var cryptoAccounts:Object;
		static public var investmentsData:Object;
		static public var investmentDetailsData:Object = {};
		
		static public var lastWaitingWalletsAction:String;
		static public var lastWaitingCryptoAction:String;
		static public var lastWaitingInvestmentsAction:String;
		static public var lastWaitingInvestmentDetailsAction:String;
		static public var rewardIBAN:String = "CH9508843102600931010";
		static public var fatCatzURL:String = "https://www.dukascoin.com/?cat=wp&page=18";
		
		public function BankBotController() { }
		
		static public function getAnswer(msg:String):void {
			var block:Object;
			var tempAction:String = msg;
			if (msg.indexOf("bot:") != 0)
				return;
			msg = msg.substr(4);
			if (msg.indexOf("bankbot ") != 0)
				return;
			msg = msg.substr(8);
			var command:String = msg.substring(0, msg.indexOf(":"));
			if (command == "payments") {
				callPaymentsMethod(msg.substr(command.length + 1));
				return;
			}
			if (command == "val") {
				if (steps != null && steps.length != 0) {
					steps[steps.length - 1].val = msg.substr(command.length + 1);
				} else {
					steps ||= [];
					steps.push( { val: msg.substr(command.length + 1) } );
				}
				return;
			}
			msg = msg.replace(/[^\w\:\,\|\!\.\s\+\-]/g, "");
			var tmp:Array = msg.split(":");
			var vals:Array;
			if (command == "system") {
				if (tmp[1] == "toLast") {
					if (stepsOld != null) {
						steps = stepsOld;
						stepsOld = null;
						S_ANSWER.invoke("app:toLast");
					}
					return;
				}
				if (tmp[1] == "cancel") {
					if (waitForPass == true)
						lastPaymentsRequests = null;
					waitForPass = false;
					steps = null;
					stepsOld = null;
					S_ANSWER.invoke("app:actionCompleted");
					sendBlock("main");
					return;
				}
				if (tmp[1] == "lang") {
					if (tmp[2] == "ru")
						langClass = BankBotScenarioLangRU;
					else if (tmp[2] == "fr")
						langClass = BankBotScenarioLangFR;
					else
						langClass = BankBotScenarioLangEN;
				}
			}
			if (command == "nav") {
				if (tmp[1] == "cryptoSwapSecondConfirm") {
					onRewardDepositeSwapStep1();
					return;
				}
				if (tmp[1] == "cryptoSwapThirdConfirm") {
					onRewardDepositeSwapStep2();
					return;
				}
				if (tmp[1] == "cryptoSwapConfirmed") {
					onRewardDepositeSwapConfirm();
					return;
				}
				if (tmp[1] == "cryptoSwapList") {
					onCryptoSwapList();
					return;
				}
				if (tmp[1] == "cryptoDeposites") {
					delete scenario.scenario.cryptoDeposites.menu[2].disabled;
					delete scenario.scenario.cryptoDeposites.menu[3].disabled;
					delete scenario.scenario.cryptoDeposites.menu[4].disabled;
					if (steps[steps.length - 1].val == "ACTIVE")
						scenario.scenario.cryptoDeposites.menu[2].disabled = true;
					else if (steps[steps.length - 1].val == "CANCELLED")
						scenario.scenario.cryptoDeposites.menu[3].disabled = true;
					else if (steps[steps.length - 1].val == "CLOSED")
						scenario.scenario.cryptoDeposites.menu[4].disabled = true;
					sendBlock(tmp[1], [steps[steps.length - 1].val]);
					return;
				}
				if (tmp[1] == "otherWithdrawalAcc") {
					sendBlock(tmp[1], [fatCatzURL]);
					return;
				}
				if (tmp[1] == "cryptoFatCatz") {
					sendBlock(tmp[1], [fatCatzURL]);
					return;
				}
				if (tmp[1] == "cryptoTradeStat") {
					sendBlock(tmp[1], [steps[steps.length - 1].val]);
					return;
				}
				if (tmp[1] == "transactionCodeConfirm") {
					onTransactionCodeConfirm();
					return;
				}
				if (tmp[1] == "otherWithdrawalConfirm") {
					onOtherWithdrawalConfirm();
					return;
				}
				if (tmp[1] == "otherWithdrawalWallets") {
					vals = steps[steps.length - 1].val.split("|!|");
					sendBlock(tmp[1], [vals[1]]);
					return;
				}
				if (tmp[1] == "paymentsWallets") {
					sendBlock(tmp[1], [steps[steps.length - 1].val]);
					return;
				}
				if (tmp[1] == "paymentsWalletsAll") {
					sendBlock(tmp[1], [steps[steps.length - 2].val]);
					return;
				}
				if (tmp[1] == "paymentsDepositConfirm") {
					onPaymentsDepositConfirm();
					return;
				}
				if (tmp[1] == "cryptoRewardsDepositeConfirm") {
					vals = steps[steps.length - 1].val.split("|!|");
					var rdCurrency:String = vals[7];
					if (rdCurrency == "DCO")
						rdCurrency = "DUK+";
					if (Number(vals[4]) == 0)
						tmp[1] = "cryptoRewardsDepositeConfirmNonPen"
					// setup Termination date
					var expires:String = "----.--.--";
					if (vals.length == 9 && vals[8] != null) {
						try {
							var dt:Date = new Date(parseInt(vals[8]) * 1000);
							var m:int = (dt.getMonth() + 1);
							var d:int = dt.getDate();
							expires = dt.getFullYear() + "." + ((m < 10) ? "0" + m : m) + "." + ((d < 10) ? "0" + d : d);
						} catch (e) {
							echo("BankBotController", "cryptoRewardsDepositeConfirm", "Can't parse termination date", true);
							expires = "???";
						}
					}
					sendBlock(tmp[1], [vals[0], expires, vals[6] + " " + rdCurrency, vals[4] + " DUK+"]);
					return;
				}
				if (tmp[1] == "createOfferConfirm") {
					vals = steps[steps.length - 1].val.split("|!|");
					sendBlock(tmp[1], [getLangValue(vals[2].toLowerCase()), vals[4], vals[3]]);
					return;
				}
				if (tmp[1] == "cryptoRDCancelConfirm") {
					vals = steps[steps.length - 2].val.split("|!|");
					if (Number(vals[2]) == 0)
						tmp[1] = "cryptoRDCancelConfirmNonPen";
					sendBlock(tmp[1], [vals[2], Number(Number(vals[1]) - Number(vals[2])).toFixed(4)]);
					return;
				}
				if (tmp[1] == "crypto") {
					if (accountInfo == null) {
						lastWaitingWalletsAction = tempAction;
						callPaymentsMethod("wallets");
						return;
					}
					if (cryptoAccounts == null) {
						lastWaitingCryptoAction = tempAction;
						callPaymentsMethod("crypto");
						return;
					}
					var l:int;
					var i:int;
					if ("coin" in cryptoAccounts == true) {
						l = cryptoAccounts.coin.length;
						for (i = 0; i < l; i++) {
							if ("COIN" in cryptoAccounts.coin[i] && cryptoAccounts.coin[i].COIN == "DCO") {
								break;
							}
						}
					}
					if (i == l)
						tmp[1] = "cryptoOpen";
				}
				if (tmp[1] == "myCryptoOffers") {
					if (steps != null && steps[steps.length - 1].nav == "cryptoOperations") {
						if (steps[steps.length - 2].val == "0")
							sendBlock(tmp[1], [getLangValue("buy1"), 0]);
						else
							sendBlock(tmp[1], [getLangValue("sell1"), 1]);
					} else
						sendBlock(tmp[1], ["", "", 2]);
					return;
				}
				if (tmp[1] == "cryptoOperations") {
					if (steps != null) {
						if (steps[steps.length - 1].val == "0")
							sendBlock(tmp[1], [getLangValue("buy"), getLangValue("buy1"), 1]);
						else
							sendBlock(tmp[1], [getLangValue("sell"), getLangValue("sell1"), 0]);
					}
					return;
				}
				if (tmp[1] == "cryptoDeals") {
					if (steps != null) {
						if (steps.length > 1) {
							if (steps[steps.length - 1].nav == "cryptoOperations" && steps[steps.length - 2].nav == "crypto") {
								if ("val" in steps[steps.length - 2] == true) {
									if (steps[steps.length - 2].val == 0) {
										sendBlock(tmp[1], [1]);
										return;
									} else if (steps[steps.length - 2].val == 1) {
										sendBlock(tmp[1], [2]);
										return;
									}
								}
							}
						}
					}
					sendBlock(tmp[1], [0]);
					return;
				}
				if (tmp[1] == "main") {
					var currentSteps:Array = steps;
					reset();
					stepsOld = currentSteps;
					currentSteps = null;
					waitForPass = false;
					sendBlock(tmp[1]);
					return;
				}
				if (tmp[1] == "needPwdCheck") {
					sendBlock("passwordEnter");
					return;
				}
				if (tmp[1] == "linkCard") {
					getLinkCardLink();
					return;
				}
				if (tmp[1] == "cardPin") {
					vals = steps[steps.length - 2].val.split("|!|");
					sendBlock(tmp[1], [vals[0]]);
					return;
				}
				if (tmp[1] == "cardVOperationsActive" ||
					tmp[1] == "cardOperationsActive" ||
					tmp[1] == "cardLinkedOperationsActive" ||
					tmp[1] == "cardOperationsSBlocked" ||
					tmp[1] == "cardOperationsHBlocked" ||
					tmp[1] == "cardOperationsNew" ||
					tmp[1] == "cardOperationsNewTracking" ||
					tmp[1] == "cardOperationsLNew" ||
					tmp[1] == "cardOperationsLExp" ||
					tmp[1] == "cardOperationsExp" ||
					tmp[1] == "cardOperationsSRBlocked")
						tmp[1] = "cardOperations";
				if (tmp[1] == "cardOperations") {
					if (steps == null)
						return;
					vals = steps[steps.length - 1].val.split("|!|");
					if (vals.length != 3)
						return;
					if (vals[1] == "A" || vals[1] == "AR") {
						if (vals[2] == "V")
							tmp[1] = "cardVOperationsActive";
						else
							tmp[1] = "cardOperationsActive";
					}
					else if (vals[1] == "AL")
						tmp[1] = "cardLinkedOperationsActive";
					else if (vals[1] == "S")
						tmp[1] = "cardOperationsSBlocked";
					else if (vals[1] == "H")
						tmp[1] = "cardOperationsHBlocked";
					else if (vals[1] == "N")
						tmp[1] = "cardOperationsNew";
					else if (vals[1] == "NT")
						tmp[1] = "cardOperationsNewTracking";
					else if (vals[1] == "NL")
						tmp[1] = "cardOperationsLNew";
					else if (vals[1] == "EL")
						tmp[1] = "cardOperationsLExp";
					else if (vals[1] == "E")
						tmp[1] = "cardOperationsExp";
					else if (vals[1] == "SR")
						tmp[1] = "cardOperationsSRBlocked";
					sendBlock(tmp[1], [vals[0]]);
					return;
				}
				if (tmp[1] == "walletOperations") {
					if (steps == null)
						return;
					vals = steps[steps.length - 1].val.split("|!|");
					if (vals.length != 1)
						return;
					sendBlock(tmp[1], [vals[0]]);
					return;
				}
				if (tmp[1] == "walletOperationsOnly") {
					sendBlock(tmp[1], [tmp[2]]);
					return;
				}
				if (tmp[1] == "cryptoRDActions") {
					if (steps == null)
						return;
					vals = steps[steps.length - 1].val.split("|!|");
					if (vals.length != 4)
						return;
					if (vals[3] == "E")
						sendBlock("cryptoRDActionsNothing", [vals[0]]);
					else if (vals[3] == "B")
						sendBlock("cryptoRDActionsB", [vals[0]]);
					else if (vals[3] == "BC")
						sendBlock("cryptoRDActionsBC", [vals[0]]);
					else
						sendBlock(tmp[1], [vals[0]]);
					return;
				}
				if (tmp[1] == "cryptoRDActionsB") {
					if (steps == null)
						return;
					vals = steps[steps.length - 1].val.split("|!|");
					sendBlock(tmp[1], [vals[0]]);
					return;
				}
				if (tmp[1] == "offerOperations") {
					if (steps == null)
						return;
					vals = steps[steps.length - 1].val.split("|!|");
					if (vals.length != 2)
						return;
					if (vals[1] == "1")
						tmp[1] = "offerOperationsActive";
					else if (vals[1] == "0")
						tmp[1] = "offerOperationsInactive";
					sendBlock(tmp[1], [vals[0]]);
					return;
				}
				if (tmp[1] == "offerOperationsActive") {
					if (steps == null)
						return;
					vals = steps[steps.length - 1].val.split("|!|");
					sendBlock(tmp[1], [vals[0]]);
					return;
				}
				if (tmp[1] == "cardDetails") {
					if (steps == null)
						return;
					vals = steps[steps.length - 2].val.split("|!|");
					if (vals.length != 3)
						return;
					sendBlock(tmp[1], [vals[0]]);
					return;
				}
				if (tmp[1] == "cardDetailsWebView") {
					onCardDetailsSensitiveConfirm();
					return;
				}
				if (tmp[1] == "investmentTransactionConfirmed") {
					onInvestmentTransactionConfirm();
					return;
				}
				if (tmp[1] == "cardStatementAsFileConfirmed") {
					onCardStatementAsFileConfirmed();
					return;
				}
				if (tmp[1] == "operationAsFileConfirmed") {
					onOperationAsFileConfirmed();
					return;
				}
				if (tmp[1] == "walletStatementAsFileConfirmed") {
					onWalletStatementAsFileConfirmed();
					return;
				}
				if (tmp[1] == "cryptoAccountCreateConfirmed") {
					oncryptoAccountCreateConfirm();
					return;
				}
				if (tmp[1] == "cryptoRewardDepositeConfirmed") {
					onCryptoRDConfirm();
					return;
				}
				if (tmp[1] == "activateOfferConfirmed") {
					onСryptoOfferActivateConfirm();
					return;
				}
				if (tmp[1] == "deactivateOfferConfirmed") {
					onСryptoOfferDeactivateConfirm();
					return;
				}
				if (tmp[1] == "deleteOfferConfirmed") {
					onСryptoOfferDeactivateConfirm();
					return;
				}
				if (tmp[1] == "bcWithdrawalConfirmed") {
					onCryptoWithdrawalConfirm();
					return;
				}
				if (tmp[1] == "bcDepositeConfirmed") {
					onCryptoDepositeConfirm();
					return;
				}
				if (tmp[1] == "bcDepositeAddressConfirmed") {
					onCryptoDepositeAddressConfirm();
					return;
				}
				if (tmp[1] == "bcDepositeAddressInvestmentConfirmed") {
					onCryptoDepositeAddressInvestmentConfirm();
					return;
				}
				if (tmp[1] == "investments") {
					if (accountInfo == null) {
						lastWaitingWalletsAction = tempAction;
						callPaymentsMethod("wallets");
						return;
					}
					if ("settings" in accountInfo == true &&
						accountInfo.settings != null &&
						"INVESTMENT_REFERENCE_CURRENCY" in accountInfo.settings == true &&
						accountInfo.settings.INVESTMENT_REFERENCE_CURRENCY != null &&
						accountInfo.settings.INVESTMENT_REFERENCE_CURRENCY != "") {
					} else {
						tmp[1] = "investmentDisclaimer";
					}
				}
				if (tmp[1] == "investmentOperations") {
					if (steps == null)
						return;
					vals = steps[steps.length - 1].val.split("|!|");
					sendBlock(tmp[1], [vals[0], vals[1], ((vals.length == 3) ? !vals[2] : true)]);
					return;
				}
				if (tmp[1] == "investmentsList" || tmp[1] == "investmentsListAll" || tmp[1] == "investmentsListSell") {
					if (investmentsData == null) {
						lastWaitingInvestmentsAction = tempAction;
						callPaymentsMethod("investments");
						return;
					}
				}
				if (tmp[1] == "investMoneyAfterReferalCurrency") {
					onConfirmInvestmentCurrency();
					return;
				}
				if (tmp[1] == "investmentConfirmed") {
					onInvestmentConfirm();
					return;
				}
				if (tmp[1] == "createOfferConfirmed") {
					onCreateOfferConfirm();
					return;
				}
				if (tmp[1] == "investmentDetails") {
					vals = steps[steps.length - 1].val.split("|!|");
					var instrument:String = vals[0];
					if (instrument == null)
						return;
					callPaymentsMethod("investmentDetails:" + instrument);
					return;
				}
				if (tmp[1] == "investmentSellConfirmed") {
					onInvestmentSellConfirm();
					return;
				}
				if (tmp[1] == "openTradingAccountConfirmed") {
					onOpenTradingAccountConfirm();
					return;
				}
				if (tmp[1] == "investmentSellAllConfirmed") {
					onInvestmentSellAllConfirm();
					return;
				}
				if (tmp[1] == "bcDeliveryConfirmed") {
					onInvestmentDeliveryConfirm();
					return;
				}
				if (tmp[1] == "cardWithdrawalConfirmed") {
					onCardWithdrawalConfirm();
					return;
				}
				if (tmp[1] == "transactionConfirmed") {
					onConfirm();
					return;
				}
				if (tmp[1] == "dukaCardDepositeTransactionConfirmed") {
					onDukaCardDepositeConfirm();
					return;
				}
				if (tmp[1] == "linkedCardDepositeTransactionConfirmed") {
					onLinkedCardDepositeConfirm();
					return;
				}
				if (tmp[1] == "cardVerificationConfirmed") {
					onCardVerificationConfirm();
					return;
				}
				if (tmp[1] == "cardActivationConfirmed") {
					onCardActivationConfirm();
					return;
				}
				if (tmp[1] == "invoiceConfirmed") {
					onInvoiceConfirm();
					return;
				}
				if (tmp[1] == "changeCurrencyConfirmed") {
					onChangeCurrencyConfirm();
					return;
				}
				if (tmp[1] == "transferConfirm") {
					var temp:Array = steps[steps.length - 1].val.split("|!|");
					if (temp[1].length == 3) {
						sendBlock("notExistWalletConfirm", [temp[1]]);
						return;
					}
				}
				if (tmp[1] == "transferInternalConfirm") {
					var temp1:Array = steps[steps.length - 1].val.split("|!|");
					if (temp1[1].length == 3) {
						sendBlock("notExistWalletConfirm", [temp1[1]]);
						return;
					}
				}
				if (tmp[1] == "transferToNotExistWalletConfirmed") {
					onNotExistWalletConfirm();
					return;
				}
				if (tmp[1] == "transferConfirmed") {
					onTransferConfirm();
					return;
				}
				
				if (tmp[1] == "transferInternalConfirmed") {
					onTransferInternalConfirm();
					return;
				}
				if (tmp[1] == "walletConfirmed") {
					onWalletConfirm();
					return;
				}
				if (tmp[1] == "walletSavingsConfirmed") {
					onWalletSavingsConfirm();
					return;
				}
				if (tmp[1] == "blockCardConfirmed") {
					onBlockCardConfirm();
					return;
				}
				if (tmp[1] == "unblockCardConfirmed") {
					onUnblockCardConfirm();
					return;
				}
				if (tmp[1] == "removeCardConfirmed") {
					onRemoveCardConfirm();
					return;
				}
				if (tmp[1] == "cancelRDConfirmed") {
					onCancelRDConfirm();
					return;
				}
				if (tmp[1] == "investmentCurrencyConfirm") {
					sendBlock(tmp[1], [steps[steps.length - 1].val]);
					return;
				}
				sendBlock(tmp[1]);
			} else if (command == "cmd") {
				if (tmp[1] == "pwdIgnore") {
					lastPaymentsRequests = null;
					getAnswer("bot:bankbot cmd:back");
					return;
				}
				if (tmp[1] == "pwdForgot") {
					lastPaymentsRequests = null;
					sendBlock("passwordForgot");
					return;
				}
				if (tmp[1] == "back") {
					if (waitForPass == true)
						lastPaymentsRequests = null;
					waitForPass = false;
					if (steps == null || steps.length == 0 || (steps.length == 1 && "nav" in steps[0] == false)) {
						echo("BankBotController", "getAnswer", "BACK ERROR (NO STEPS)");
						getAnswer("bot:bankbot nav:main");
						return;
					}
					if (tmp.length == 3) {
						for (var j:int = steps.length; j > 0; j--) {
							if (steps[j - 1].nav == tmp[2])
								break;
							if (j == 2 && ("nav" in steps[0] == false))
								break;
							steps.pop();
						}
					} else {
						steps.pop();
					}
					if (steps.length == 0) {
						getAnswer("bot:bankbot nav:main");
						return;
					}
					var obj:Object = steps.pop();
					var commandString:String = "bot:bankbot ";
					if ("nav" in obj == true)
						commandString += "nav:" + obj.nav;
					else if ("cmd" in obj)
						commandString += "cmd:" + obj.cmd + ":" + obj.value;
					getAnswer(commandString);
					if ("val" in obj == true)
						getAnswer("bot:bankbot val:" + obj.val);
					return;
				} else if (tmp[1] == "last") {
					if (waitForPass == true)
						lastPaymentsRequests = null;
					waitForPass = false;
					if (steps == null || steps.length < 2) {
						echo("BankBotController", "getAnswer", "LAST ERROR (NO STEPS)");
						return;
					}
					save = false;
					getAnswer("bot:bankbot nav:" + steps[steps.length - 1].nav);
					save = true;
					return;
				} else if (tmp[1] == "keyword") {
					var res:Array = getMenuItemsByKeywords(tmp[2]);
					if (res == null)
						return;
					else if (res.length == 1 && "action" in res[0])
						sendBlock("action", [res[0]]);
					else {
						steps.push( { cmd:"keyword", value:tmp[2] } );
						sendBlock("search", [res]);
					}
				}
			}
		}
		
		static public function getReward(amount:Number):int {
			var res:int;
			for (var i:int = 0; i < rewards.length; i++) {
				if (rewards[i].amount > amount)
					break;
				res = rewards[i].reward;
			}
			return res;
		}
		
		static private function getMenuItemsByKeywords(val:String):Array {
			if (val == null || val == "")
				return null;
			var l:int;
			var i:int;
			val = val.replace(/\W/gis, " ");
			val = val.replace(/\d/gis, " ");
			val = val.toLowerCase();
			var keywords:Array = val.split(" ");
			l = keywords.length - 1
			for (i = l; i >= 0; i--) {
				if (keywords[i] == "")
					keywords.splice(i, 1);
			}
			if (keywords.length == 0)
				return null;
			return continueSearchByKeywords(keywords);
		}
		
		static private function continueSearchByKeywords(keywords:Array, items:Array = null):Array {
			var res:Array;
			var l:int;
			var i:int;
			if (items == null) {
				for (var n:String in scenario.scenario) {
					if ("menu" in scenario.scenario[n] == false)
						continue;
					if (scenario.scenario[n].menu == null)
						continue;
					if (scenario.scenario[n].menu is Array == false)
						continue;
					l = scenario.scenario[n].menu.length;
					if (l == 0)
						continue;
					for (i = 0; i < l; i++) {
						if ("keywords" in scenario.scenario[n].menu[i] == false)
							continue;
						if (scenario.scenario[n].menu[i].keywords == null ||
							scenario.scenario[n].menu[i].keywords == "")
								continue;
						if (scenario.scenario[n].menu[i].keywords.indexOf(keywords[0]) != -1) {
							res ||= [];
							res.push(scenario.scenario[n].menu[i]);
						}
					}
				}
			} else {
				l = items.length;
				for (i = 0; i < l; i++) {
					if (items[i].keywords.indexOf(keywords[0]) != -1) {
						res ||= [];
						res.push(items[i]);
					}
				}
			}
			if (keywords.length == 1)
				return res;
			keywords.shift();
			if (res == null)
				res = continueSearchByKeywords(keywords);
			else if (res.length != 1)
				res = continueSearchByKeywords(keywords, res);
			return res;
		}
		
		static private function onInvoiceConfirm():void {
			if (steps == null)
				return;
			S_ANSWER.invoke("requestRespond:invoice:" + steps[steps.length - 2].val);
		}
		
		static private function onChangeCurrencyConfirm():void {
			if (steps == null)
				return;
			sendBlock("actionProgress");
			callPaymentsMethod("changeMainCurrency:" + steps[steps.length - 2].val);
		}
		
		static private function checkForPaymentsRequestExist(msg:String):Boolean {
			lastPaymentsRequests ||= {};
			lastPaymentsRequestsID ||= {};
			for (var n:String in lastPaymentsRequests)
				if (lastPaymentsRequests[n] == msg)
					return true;
			return false;
		}
		
		static public function getLinkCardLink():void {
			sendBlock("actionProgress");
			callPaymentsMethod("linkCard");
		}
		
		static private function onConfirmInvestmentCurrency():void {
			sendBlock("actionProgress");
			callPaymentsMethod("investmentCurrency:" + steps[steps.length - 2].val);
		}
		
		static private function onInvestmentConfirm():void {
			sendBlock("actionProgress");
			callPaymentsMethod("investment:" + steps[steps.length - 2].val.substr(0, steps[steps.length - 2].val.length - 4));
		}
		
		static private function onTransactionCodeConfirm():void {
			sendBlock("actionProgress");
			callPaymentsMethod("transactionCode:" + steps[steps.length - 1].val);
		}
		
		static private function onRewardDepositeSwapStep1():void {
			sendBlock("actionProgress");
			callPaymentsMethod("rdSwapStep1:" + steps[steps.length - 1].val);
		}
		
		static private function onRewardDepositeSwapStep2():void {
			sendBlock("actionProgress");
			if (steps.length > 1)
				callPaymentsMethod("rdSwapStep2:" + steps[steps.length - 2].val + "|!|" + steps[steps.length - 1].val);
		}
		
		static private function onRewardDepositeSwapConfirm():void {
			sendBlock("actionProgress");
			if (steps.length > 2)
				callPaymentsMethod("rdSwapConfirm:" + steps[steps.length - 3].val + "|!|" + steps[steps.length - 2].val);
		}
		
		static private function onCryptoSwapList():void {
			sendBlock("actionProgress");
			callPaymentsMethod("cryptoSwapList");
		}
		
		static private function onOtherWithdrawalConfirm():void {
			sendBlock("actionProgress");
			callPaymentsMethod("otherWithdrawal:" + steps[steps.length - 1].val + "|!|" + steps[steps.length - 2].val);
		}
		
		static private function onCardDetailsSensitiveConfirm():void {
			sendBlock("actionProgress");
			if (steps == null)
				return;
			var vals:Array = steps[steps.length - 2].val.split("|!|");
			if (vals.length != 3)
				return;
			callPaymentsMethod("cardDepositeSensitive:" + vals[0]);
		}
		
		static private function onPaymentsDepositConfirm():void {
			sendBlock("actionProgress");
			callPaymentsMethod("paymentsDeposit:" + steps[steps.length - 1].val);
		}
		
		static private function onCreateOfferConfirm():void {
			sendBlock("actionProgress");
			callPaymentsMethod("cryptoOffer:" + steps[steps.length - 2].val);
		}
		
		static private function oncryptoAccountCreateConfirm():void {
			sendBlock("actionProgress");
			callPaymentsMethod("cryptoAccount");
		}
		
		static private function onCryptoRDConfirm():void {
			sendBlock("actionProgress");
			callPaymentsMethod("cryptoRDs:" + steps[steps.length - 2].val);
		}
		
		static private function onСryptoOfferActivateConfirm():void {
			sendBlock("actionProgress");
			if (steps != null && steps[steps.length - 1].nav == "activateOfferConfirm")
				callPaymentsMethod("cryptoOfferActivate:" + steps[steps.length - 3].val.substring(0, steps[steps.length - 3].val.indexOf("|")));
			else
				callPaymentsMethod("cryptoOfferActivate:" + steps[steps.length - 2].val);
		}
		
		static private function onСryptoOfferDeactivateConfirm():void {
			sendBlock("actionProgress");
			if (steps != null && steps[steps.length - 1].nav == "deleteOfferConfirm")
				callPaymentsMethod("cryptoOfferDeactivate:" + steps[steps.length - 3].val.substring(0, steps[steps.length - 3].val.indexOf("|")));
		}
		
		static private function onCryptoWithdrawalConfirm():void {
			sendBlock("actionProgress");
			callPaymentsMethod("cryptoWithdrawal:" + steps[steps.length - 2].val);
		}
		
		static private function onCryptoDepositeConfirm():void {
			sendBlock("actionProgress");
			callPaymentsMethod("cryptoDeposite:" + steps[steps.length - 2].val);
		}
		
		static private function onCryptoDepositeAddressConfirm():void {
			sendBlock("actionProgress");
			callPaymentsMethod("cryptoDepositeAddress:" + steps[steps.length - 2].val);
		}
		
		static private function onCryptoDepositeAddressInvestmentConfirm():void {
			sendBlock("actionProgress");
			callPaymentsMethod("cryptoDepositeAddressInvestment:" + steps[steps.length - 2].val);
		}
		
		static private function onCardStatementAsFileConfirmed():void {
			callPaymentsMethod("cardStatementAsFile:" + steps[steps.length - 1].val);
		}
		
		static private function onOperationAsFileConfirmed():void {
			callPaymentsMethod("operationAsFile:" + steps[steps.length - 1].val);
		}
		
		static private function onWalletStatementAsFileConfirmed():void {
			callPaymentsMethod("walletStatementAsFile:" + steps[steps.length - 1].val);
		}
		
		static private function onInvestmentTransactionConfirm():void {
			sendBlock("actionProgress");
			var temp:Array = steps[steps.length - 2].val.split("|!|");
			if (temp.length != 5)
				return;
			if (temp[4].toLowerCase() == "b")
				callPaymentsMethod("investment:" + steps[steps.length - 2].val.substr(0, steps[steps.length - 2].val.length - 4));
			else if (temp[4].toLowerCase() == "s")
				callPaymentsMethod("investmentSell:" + steps[steps.length - 2].val.substr(0, steps[steps.length - 2].val.length - 4));
		}
		
		static private function onInvestmentSellConfirm():void {
			sendBlock("actionProgress");
			callPaymentsMethod("investmentSell:" + steps[steps.length - 2].val.substr(0, steps[steps.length - 2].val.length - 4));
		}
		
		static private function onOpenTradingAccountConfirm():void {
			sendBlock("actionProgress");
			callPaymentsMethod("openTradingAccount:" + steps[steps.length - 2].val);
		}
		
		static private function onInvestmentDetailsConfirm():void {
			
		}
		
		static private function onInvestmentSellAllConfirm():void {
			sendBlock("actionProgress");
			callPaymentsMethod("investmentSell:" + steps[steps.length - 2].val.substr(0, steps[steps.length - 2].val.length - 4));
		}
		
		static private function onInvestmentDeliveryConfirm():void {
			sendBlock("actionProgress");
			callPaymentsMethod("investmentDelivery:" + steps[steps.length - 2].val);
		}
		
		static private function onCardWithdrawalConfirm():void {
			sendBlock("actionProgress");
			callPaymentsMethod("cardWithdrawal:" + steps[steps.length - 2].val);
		}
		
		static private function onDukaCardDepositeConfirm():void {
			sendBlock("actionProgress");
			callPaymentsMethod("dukaCardDeposite:" + steps[steps.length - 2].val);
		}
		static private function onLinkedCardDepositeConfirm():void {
			sendBlock("actionProgress");
			callPaymentsMethod("linkedCardDeposite:" + steps[steps.length - 1].val);
		}
		
		static private function onConfirm():void {
			sendBlock("actionProgress");
			callPaymentsMethod("sendmoney:" + steps[steps.length - 2].val);
		}
		
		static private function onCardVerificationConfirm():void {
			sendBlock("actionProgress");
			callPaymentsMethod("cardVerify:" + steps[steps.length - 1].val);
		}
		
		static private function onCardActivationConfirm():void {
			sendBlock("actionProgress");
			callPaymentsMethod("cardActivate:" + steps[steps.length - 1].val);
		}
		
		static private function onTransferConfirm():void {
			sendBlock("actionProgress");
			callPaymentsMethod("exchange:" + steps[steps.length - 2].val);
		}
		
		static private function onTransferInternalConfirm():void {
			sendBlock("actionProgress");
			callPaymentsMethod("internalTransfer:" + steps[steps.length - 2].val);
		}
		
		static private function onWalletConfirm():void {
			sendBlock("actionProgress");
			callPaymentsMethod("walletCreation:" + steps[steps.length - 2].val);
		}
		
		static private function onWalletSavingsConfirm():void {
			sendBlock("actionProgress");
			callPaymentsMethod("walletSavingsCreation:" + steps[steps.length - 2].val);
		}
		
		static private function onNotExistWalletConfirm():void {
			sendBlock("actionProgress");
			callPaymentsMethod("notExistWalletCreation:" + steps[steps.length - 2].val);
		}
		
		static private function onBlockCardConfirm():void {
			sendBlock("actionProgress");
			callPaymentsMethod("cardAction:" + steps[steps.length - 3].val);
		}
		
		static private function onUnblockCardConfirm():void {
			sendBlock("actionProgress");
			callPaymentsMethod("cardAction:" + steps[steps.length - 3].val);
		}
		
		static private function onRemoveCardConfirm():void {
			sendBlock("actionProgress");
			callPaymentsMethod("cardAction:" + steps[steps.length - 3].val);
		}
		
		static private function onCancelRDConfirm():void {
			sendBlock("actionProgress");
			callPaymentsMethod("cancelRD:" + steps[steps.length - 3].val);
		}
		
		static private function callPaymentsMethod(msg:String):void {
			var index:int = msg.indexOf(":");
			var command:String;
			var hash:String;
			if (PayConfig.PAY_SESSION_ID == "") {
				if (isLoggining == true)
					return;
				if (checkForPaymentsRequestExist(msg) == false) {
					lastPaymentsRequests["nonSession" + nonSessionCounter] = msg;
					nonSessionCounter++;
				}
				isLoggining = true;
				PayAPIManager.login(onLoggedIn);
				return;
			}
			if (index == -1)
				command = msg;
			else
				command = msg.substring(0, index);
			var temp:Array;
			if (command == "cardPinRequest") {
				sendBlock("actionProgress");
				temp = msg.substr(command.length + 1).split("|!|");
				PaymentsManagerNew.requestCardPin(onPinRequested, temp[1], temp[0]);
				return;
			}
			if (command == "transactionCode") {
				if (checkForPaymentsRequestExist(msg) == true)
					return;
				temp = msg.substr(command.length + 1).split("|!|");
				lastPaymentsRequests["transactionCode" + PaymentsManagerNew.transactionCode(onTransactionCodeResponse, temp[0], temp[1])] = msg;
			}
			if (command == "rdSwapStep1") {
				if (checkForPaymentsRequestExist(msg) == true)
					return;
				lastPaymentsRequests["rdSwapStep1"] = msg;
				PaymentsManagerNew.rdSwapStep1(onRDSwapStep1, msg.substr(command.length + 1));
			}
			if (command == "rdSwapStep2") {
				if (checkForPaymentsRequestExist(msg) == true)
					return;
				temp = msg.substr(command.length + 1).split("|!|");
				if (temp.length != 4)
					return;
				lastPaymentsRequests[PaymentsManagerNew.rdSwapStep2(onRDSwapStep2, temp[0], temp[1], temp[2], temp[3])] = msg;
			}
			if (command == "rdSwapConfirm") {
				if (checkForPaymentsRequestExist(msg) == true)
					return;
				temp = msg.substr(command.length + 1).split("|!|");
				if (temp.length != 4)
					return;
				lastPaymentsRequests[PaymentsManagerNew.rdSwap(onRDSwap, temp[0], temp[1], temp[2], temp[3])] = msg;
			}
			if (command == "cryptoSwapList") {
				if (checkForPaymentsRequestExist(msg) == true)
					return;
				lastPaymentsRequests["cryptoSwapList"] = msg;
				lastPaymentsRequests[PaymentsManagerNew.cryptoSwapList(onCryptoSwapListResponse)] = msg;
			}
			if (command == "fatCatz") {
				if (checkForPaymentsRequestExist(msg) == true)
					return;
				lastPaymentsRequests["fatCatz"] = msg;
				PaymentsManagerNew.fatCatz(onFatCatz);
			}
			if (command == "cardStatementAsFile") {
				temp = msg.substr(command.length + 1).split("|!|");
				if (temp.length != 4)
					return;
				PaymentsManagerNew.callCardStatement(temp[2], temp[0], temp[1], temp[3]);
			}
			if (command == "operationAsFile") {
				PaymentsManagerNew.callOperationStatement(msg.substr(command.length + 1));
			}
			if (command == "changeMainCurrency") {
				if (checkForPaymentsRequestExist(msg) == true)
					return;
				lastPaymentsRequests["changeMainCurrency"] = msg;
				PaymentsManagerNew.changeMainCurrency(onMainCurrencyChanged, msg.substr(command.length + 1));
			}
			if (command == "walletStatementAsFile") {
				temp = msg.substr(command.length + 1).split("|!|");
				if (temp.length != 4)
					return;
				PaymentsManagerNew.callWalletStatement(temp[2], temp[0], temp[1], temp[3]);
			}
			if (command == "possibleRewardDeposites") {
				if (checkForPaymentsRequestExist(msg) == true)
					return;
				temp = msg.substr(command.length + 1).split("|!|");
				lastPaymentsRequests["possibleRD" + PaymentsManagerNew.getPossibleRDReceived(onPossibleRD, temp[0], temp[1])] = msg;
			}
			if (command == "getDeclareETHAddressLink") {
				if (checkForPaymentsRequestExist(msg) == true)
					return;
				lastPaymentsRequests["declareETHAddressLink"] = msg;
				PaymentsManagerNew.getDeclareETHAddressLink(onETHLinkReceived, msg.substr(command.length + 1));
			}
			if (command == "getThirdpartyInvoiceLink") {
				if (checkForPaymentsRequestExist(msg) == true)
					return;
				temp = msg.substr(command.length + 1).split("|!|");
				lastPaymentsRequests["tpiLink" + PaymentsManagerNew.getTPILink(onThirdpartyInvoiceLinkReceived, temp[0], temp[1], temp[2])] = msg;
			}
			if (command == "cancelRD") {
				if (checkForPaymentsRequestExist(msg) == true)
					return;
				temp = msg.substr(command.length + 1).split("|!|");
				lastPaymentsRequests["cancelRD" + temp[0]] = msg;
				PaymentsManagerNew.cancelRDDeposit(onCancelRD, temp[0]);
			}
			if (command == "passForgot") {
				if (checkForPaymentsRequestExist(msg) == true)
					return;
				temp = msg.substr(command.length + 1).split("|!|");
				if (temp.length == 2)
					lastPaymentsRequests[PaymentsManagerNew.passForgot(onPassForgot, temp[0], temp[1])] = msg;
				else
					lastPaymentsRequests[PaymentsManagerNew.passForgot(onPassForgot, temp[0], temp[1], temp[2], temp[3])] = msg;
			}
			if (command == "crypto") {
				if (checkForPaymentsRequestExist(msg) == true)
					return;
				lastPaymentsRequests["crypto"] = msg;
				PaymentsManagerNew.callCrypto(onCryptoLoaded);
				return;
			}
			if (command == "cryptoRD") {
				if (checkForPaymentsRequestExist(msg) == true)
					return;
				lastPaymentsRequests["cryptoRDs"] = msg;
				PaymentsManagerNew.callCryptoRDs(onRDLoaded);
				return;
			}
			if (command == "cryptoAccount") {
				if (checkForPaymentsRequestExist(msg) == true)
					return;
				lastPaymentsRequests["cryptoAccount"] = msg;
				PaymentsManagerNew.callCreateWallet(onCryptoCreated, "DCO");
				return;
			}
			if (command == "cryptoOffer") {
				if (checkForPaymentsRequestExist(msg) == true)
					return;
				temp = msg.substr(command.length + 1).split("|!|");
				lastPaymentsRequests[PaymentsManagerNew.createCryptoOffer(onCryptoOfferCreated, temp[0], temp[1], temp[2], temp[3], temp[4], temp[5], Number(temp[6]), temp[7] == "true")] = msg;
				return;
			}
			if (command == "cryptoOfferCreate") {
				if (checkForPaymentsRequestExist(msg) == true)
					return;
				temp = msg.substr(command.length + 1).split("|!|");
				lastPaymentsRequests[PaymentsManagerNew.createCryptoOffer(onCryptoOfferCreated1, temp[0], temp[1], temp[2], temp[3], temp[4], temp[5], Number(temp[6]), temp[7] == "true")] = msg;
				return;
			}
			if (command == "cryptoWithdrawal") {
				if (checkForPaymentsRequestExist(msg) == true)
					return;
				temp = msg.substr(command.length + 1).split("|!|");
				lastPaymentsRequests[PaymentsManagerNew.withdrawalCrypto(onCryptoWithdrawed, temp[0], temp[1], temp[2])] = msg;
				return;
			}
			if (command == "investmentDelivery") {
				if (checkForPaymentsRequestExist(msg) == true)
					return;
				temp = msg.substr(command.length + 1).split("|!|");
				lastPaymentsRequests[PaymentsManagerNew.deliveryInvestments(onInvestmentDelivered, temp[0], temp[1], temp[2], temp[3])] = msg;
				return;
			}
			if (command == "cryptoDepositeAddress") {
				if (checkForPaymentsRequestExist(msg) == true)
					return;
				temp = msg.substr(command.length + 1).split("|!|");
				lastPaymentsRequests[PaymentsManagerNew.depositeAddressCrypto(onCryptoDepositeAddress, temp[0], temp[1], temp[2])] = msg;
				return;
			}
			if (command == "cryptoDepositeAddressInvestment") {
				if (checkForPaymentsRequestExist(msg) == true)
					return;
				temp = msg.substr(command.length + 1).split("|!|");
				lastPaymentsRequests[PaymentsManagerNew.depositeAddressInvestmentCrypto(onCryptoDepositeAddressInvestment, temp[0], temp[1], temp[2])] = msg;
				return;
			}
			if (command == "tradeCoins") {
				if (checkForPaymentsRequestExist(msg) == true)
					return;
				temp = msg.substr(command.length + 1).split("|!|");
				hash = PaymentsManagerNew.tradeCrypto(onCryptoTraded, temp[0], temp[1], temp[2], temp[3]);
				lastPaymentsRequestsID[hash] = temp[4];
				lastPaymentsRequests[hash] = msg;
				return;
			}
			if (command == "cryptoOffers") {
				if (checkForPaymentsRequestExist(msg) == true)
					return;
				lastPaymentsRequests["cryptoDeals"] = msg;
				PaymentsManagerNew.getCryptoDeals(onCryptoDeals);
				return;
			}
			if (command == "cryptoOffersActive") {
				if (checkForPaymentsRequestExist(msg) == true)
					return;
				lastPaymentsRequests["cryptoDealsActive"] = msg;
				PaymentsManagerNew.getCryptoDeals(onCryptoDeals);
				return;
			}
			if (command == "cryptoOfferActivate") {
				if (checkForPaymentsRequestExist(msg) == true)
					return;
				lastPaymentsRequests["cryptoOfferActivate" + msg.substr(command.length + 1)] = msg;
				PaymentsManagerNew.activateCryptoOffer(onCryptoOfferActivated, msg.substr(command.length + 1));
				return;
			}
			if (command == "cryptoOfferDeactivate") {
				if (checkForPaymentsRequestExist(msg) == true)
					return;
				lastPaymentsRequests["cryptoOfferDectivate" + msg.substr(command.length + 1)] = msg;
				PaymentsManagerNew.deactivateCryptoOffer(onCryptoOfferDeactivated, msg.substr(command.length + 1));
				return;
			}
			if (command == "cardVerify") {
				if (checkForPaymentsRequestExist(msg) == true)
					return;
				temp = msg.substr(command.length + 1).split("|!|");
				if (temp.length == 3) {
					if (temp[0].toLowerCase() == "code")
						lastPaymentsRequests[PaymentsManagerNew.callCardVerify(onCardVerified, temp[2], null, temp[1])] = msg;
					else if (temp[0].toLowerCase() == "amount")
						lastPaymentsRequests[PaymentsManagerNew.callCardVerify(onCardVerified, temp[2], temp[1])] = msg;
				}
				return;
			}
			if (command == "cardActivate") {
				if (checkForPaymentsRequestExist(msg) == true)
					return;
				temp = msg.substr(command.length + 1).split("|!|");
				if (temp.length == 2)
					lastPaymentsRequests["activateCard" + PaymentsManagerNew.callCardAction(onCardActivated, temp[1], "activate", temp[0])] = msg;
				return;
			}
			if (command == "home") {
				if (checkForPaymentsRequestExist(msg) == true)
					return;
				lastPaymentsRequests["home"] = msg;
				PaymentsManagerNew.callHome(onHomeLoaded, true);
				return;
			}
			if (command == "homeS") {
				if (checkForPaymentsRequestExist(msg) == true)
					return;
				lastPaymentsRequests["home"] = msg;
				PaymentsManagerNew.callHome(onHomeLoaded);
				return;
			}
			if (command == "total") {
				if (checkForPaymentsRequestExist(msg) == true)
					return;
				lastPaymentsRequests["total"] = msg;
				PaymentsManagerNew.callTotal(onTotalLoaded);
				return;
			}
			if (command == "linkCard") {
				if (checkForPaymentsRequestExist(msg) == true)
					return;
				lastPaymentsRequests["linkCard"] = msg;
				PaymentsManagerNew.callLinkCardURL(onLinkCardURL);
				return;
			}
			if (command == "history") {
				if (checkForPaymentsRequestExist(msg) == true)
					return;
				temp = msg.substr(command.length + 1).split("|!|");
				var clb:Function = onHistoryLoaded;
				if (temp.length > 2) {
					if (temp[2].indexOf("USER") == 0)
						lastPaymentsRequests[PaymentsManagerNew.callHistory(onHistoryLoaded, temp[0], temp[1], "", "", "", "", "", "", temp[2].substr(4))] = msg;
					else
						lastPaymentsRequests[PaymentsManagerNew.callHistory(onHistoryLoaded, temp[0], temp[1], temp[4], temp[3], temp[5], temp[6], "", temp[2])] = msg;
				} else {
					lastPaymentsRequests[PaymentsManagerNew.callHistory(onHistoryLoaded, temp[0], temp[1])] = msg;
				}
				return;
			}
			if (command == "historyTrades") {
				if (checkForPaymentsRequestExist(msg) == true)
					return;
				temp = msg.substr(command.length + 1).split("|!|");
				lastPaymentsRequests[PaymentsManagerNew.callHistory(onHistoryTradesLoaded, 1, 100, "", "", temp[1], temp[1], "", "", "", temp[0])] = msg;
				return;
			}
			if (command == "walletCreation") {
				if (checkForPaymentsRequestExist(msg) == true)
					return;
				lastPaymentsRequests["walletCreation" + PaymentsManagerNew.callCreateWallet(onWalletCreated, msg.substr(command.length + 1))] = msg;
				return;
			}
			if (command == "walletSavingsCreation") {
				if (checkForPaymentsRequestExist(msg) == true)
					return;
				lastPaymentsRequests["walletCreation" + PaymentsManagerNew.callCreateWalletSaving(onWalletCreated, msg.substr(command.length + 1))] = msg;
				return;
			}
			if (command == "investmentCurrency") {
				if (checkForPaymentsRequestExist(msg) == true)
					return;
				PaymentsManagerNew.callInvestmentCurrency(onInvestmentCurrencySetted, msg.substr(command.length + 1));
				lastPaymentsRequests["investmentCurrency"] = msg;
				return;
			}
			if (command == "openTradingAccount") {
				if (checkForPaymentsRequestExist(msg) == true)
					return;
				temp = msg.substr(command.length + 1).split("|!|");
				if (temp.length != 2)
					return;
				lastPaymentsRequests["tradingAccount" + PaymentsManagerNew.callOpenTradingAccount(onTradingAccountOpened, temp[0], (temp[1] == 0) ? "forex" : "binary")] = msg;
				return;
			}
			if (command == "notExistWalletCreation") {
				if (checkForPaymentsRequestExist(msg) == true)
					return;
				temp = msg.substr(command.length + 1).split("|!|");
				if (temp[4] == "MCA")
					lastPaymentsRequests["walletCreation" + PaymentsManagerNew.callCreateWallet(onNotExistWalletCreated, temp[1])] = msg;
				else if (temp[4] == "SAVING")
					lastPaymentsRequests["walletCreationSaving" + PaymentsManagerNew.callCreateWalletSaving(onNotExistWalletSavingCreated, temp[1])] = msg;
				return;
			}
			if (command == "exchange") {
				if (checkForPaymentsRequestExist(msg) == true)
					return;
				temp = msg.substr(command.length + 1).split("|!|");
				if (temp.length == 5)
					lastPaymentsRequests[PaymentsManagerNew.callExchange(onMoneyExchanged, temp[0], temp[1], temp[2], temp[3])] = msg;
				return;
			}
			if (command == "internalTransfer") {
				if (checkForPaymentsRequestExist(msg) == true)
					return;
				temp = msg.substr(command.length + 1).split("|!|");
				if (temp.length == 5)
					lastPaymentsRequests[PaymentsManagerNew.callInternalTransfer(onInternalTrasfer, temp[0], temp[1], temp[2], temp[3])] = msg;
				return;
			}
			if (command == "cardWithdrawal") {
				if (checkForPaymentsRequestExist(msg) == true)
					return;
				temp = msg.substr(command.length + 1).split("|!|");
				if (temp.length == 5)
					lastPaymentsRequests[PaymentsManagerNew.callCardWithdrawal(onCardWithdrawalCompleted, temp[0], temp[1], temp[2], temp[3], (temp[4] == "linked") ? "CARD" : "PPCARD")] = msg;
				return;
			}
			if (command == "otherWithdrawal") {
				if (checkForPaymentsRequestExist(msg) == true)
					return;
				temp = msg.substr(command.length + 1).split("|!|"); 
				if (temp.length == 3 || temp.length == 4)
					lastPaymentsRequests[PaymentsManagerNew.callOtherWithdrawal(onOtherWithdrawalCompleted, temp[0], temp[1], temp[2])] = msg;
				return;
			}
			if (command == "paymentsDeposit") {
				if (checkForPaymentsRequestExist(msg) == true)
					return;
				temp = msg.substr(command.length + 1).split("|!|");
				if (temp.length == 1)
					lastPaymentsRequests[PaymentsManagerNew.callPaymentsDeposit(onPaymentsDepositCompleted, temp[0])] = msg;
				else if (temp.length == 2)
					lastPaymentsRequests[PaymentsManagerNew.callPaymentsDeposit(onPaymentsDepositCompleted, temp[0], temp[1])] = msg;
				return;
			}
			if (command == "cardDepositeSensitive") {
				if (checkForPaymentsRequestExist(msg) == true)
					return;
				lastPaymentsRequests[PaymentsManagerNew.callCardDetailsSensitive(onCardDetailsSensitive, msg.substr(command.length + 1))] = msg;
				return;
			}
			if (command == "sendmoney") {
				if (checkForPaymentsRequestExist(msg) == true)
					return;
				temp = msg.substr(command.length + 1).split("|!|");
				if (temp.length == 7) {
					if (temp[2].indexOf("+") == 0)
						lastPaymentsRequests[PaymentsManagerNew.callSendMoney(onTransactionCompleted, temp[0], temp[1], temp[2], temp[3], temp[4], temp[5], temp[6], "phone")] = msg;
					else
						lastPaymentsRequests[PaymentsManagerNew.callSendMoney(onTransactionCompleted, temp[0], temp[1], temp[2], temp[3], temp[4], temp[5], temp[6])] = msg;
				}
				return;
			}
			if (command == "cryptoRDs") {
				if (checkForPaymentsRequestExist(msg) == true)
					return;
				temp = msg.substr(command.length + 1).split("|!|");
				if (temp.length == 9)
					lastPaymentsRequests[PaymentsManagerNew.callMakeRDeposit(onRDCompleted, temp[0], temp[1], temp[3])] = msg;
				else{
					// Ну и че делать если массив другой длины? как обновить чат с ботом?
				}

				return;
			}
			if (command == "dukaCardDeposite") {
				if (checkForPaymentsRequestExist(msg) == true)
					return;
				temp = msg.substr(command.length + 1).split("|!|");
				if (temp.length == 4)
					lastPaymentsRequests[PaymentsManagerNew.callUnloadCard(onCardUnloadCompleted, temp[2], temp[3], temp[0])] = msg;
				else if (temp.length == 5)
					lastPaymentsRequests[PaymentsManagerNew.callUnloadCard(onCardUnloadCompleted, temp[2], temp[3], temp[0], temp[4])] = msg;
				return;
			}
			if (command == "investment") {
				if (checkForPaymentsRequestExist(msg) == true)
					return;
				temp = msg.substr(command.length + 1).split("|!|");
				if (temp.length == 4)
					lastPaymentsRequests[PaymentsManagerNew.callInvest(onInvestmentCompleted, temp[1], temp[2], (temp[3] == "0") ? Number(temp[0]) : NaN, (temp[3] != "0") ? Number(temp[0]) : NaN)] = msg;
				return;
			}	
			 
			if (command == "investmentSell") {
				if (checkForPaymentsRequestExist(msg) == true)
					return;
				temp = msg.substr(command.length + 1).split("|!|");
				if (temp.length == 4)
					lastPaymentsRequests[PaymentsManagerNew.callInvest(onInvestmentSellCompleted, temp[1], temp[2], (temp[3] == "0") ? Number(temp[0]) : NaN, (temp[3] != "0") ? Number(temp[0]) : NaN, "sell") ] = msg;
				return;
			}
			if (command == "cardHistory") {
				if (checkForPaymentsRequestExist(msg) == true)
					return;
				PaymentsManagerNew.callCardHistory(onCardHistoryLoaded, msg.substr(command.length + 1));
				lastPaymentsRequests[msg.substr(command.length + 1)] = msg;
				return;
			}
			if (command == "wallets") {
				if (checkForPaymentsRequestExist(msg) == true)
					return;
				lastPaymentsRequests["wallet"] = msg;
				PaymentsManagerNew.callWallets(onWalletsLoaded);
				return;
			}
			if (command == "investments") {
				if (checkForPaymentsRequestExist(msg) == true)
					return;
				lastPaymentsRequests["investments"] = msg;
				PaymentsManagerNew.callInvestments(onInvestmentsLoaded);
				return;
			}
			if (command == "investmentDetails") {
				if (checkForPaymentsRequestExist(msg) == true)
					return;	
				var parts:Array = msg.substr(command.length + 1).split("|!|");
				PaymentsManagerNew.callInvestmentDetails(onInvestmentDetailsLoaded, parts[0]);
				return;
			}
			if (command == "investmentHistory") {
				if (checkForPaymentsRequestExist(msg) == true)
					return;
				lastPaymentsRequests["investmentsHistory" + msg.substr(command.length + 1)] = msg;
				PaymentsManagerNew.callInvestmentHistory(onInvestmentHistoryLoaded, msg.substr(command.length + 1));
				return;
			}
			if (command == "cards") {
				if (checkForPaymentsRequestExist(msg) == true)
					return;
				lastPaymentsRequests["cards"] = msg;
				PaymentsManagerNew.callCards(onCardsLoaded);
				return;
			}
			if (command == "linkedCards") {
				if (checkForPaymentsRequestExist(msg) == true)
					return;
				lastPaymentsRequests["linkedCards"] = msg;
				PaymentsManagerNew.callLinkedCards(onLinkedCardsLoaded);
				return;
			}
			if (command == "transaction") {
				if (checkForPaymentsRequestExist(msg) == true)
					return;
				lastPaymentsRequests[PaymentsManagerNew.callTransactionInfo(onTransactionLoaded, msg.substr(command.length + 1))] = msg;
				return;
			}
			if (command == "pwdCheck") {
				var val:String = msg.substr(command.length + 1);
				if (val.length == 0) {
					sendBlock("obligatoryPass");
					return;
				}
				PaymentsManagerNew.callPasswordCheck(onPasswordChecked, msg.substr(command.length + 1));
			}
			if (command == "pwdChange") {
				var val1:String = msg.substr(command.length + 1);
				if (val1.length == 0) {
					sendBlock("obligatoryPass");
					return;
				}
				sendBlock("actionProgress");
				var pwds:Array = val1.split("|!|");
				PaymentsManagerNew.callPasswordChange(onPasswordChanged, pwds[0], pwds[1]);
			}
			if (command == "cardAction") {
				if (checkForPaymentsRequestExist(msg) == true)
					return;
				temp = msg.substr(command.length + 1).split("|!|");
				if (temp.length == 3) {
					if (temp[1] == "S" || temp[1] == "SR") {
						lastPaymentsRequests["unblockCard" + PaymentsManagerNew.callCardAction(onCardUnblocked, temp[0], "unblock")] = msg;
					} else if (temp[1] == "A" || temp[1] == "AR") {
						lastPaymentsRequests["blockCard" + PaymentsManagerNew.callCardAction(onCardBlocked, temp[0], "block")] = msg;
					} else if (temp[1] == "AL" || temp[1] == "NL" || temp[1] == "EL") {
						lastPaymentsRequests["removeCard" + temp[0]] = msg;
						PaymentsManagerNew.callCardRemove(onCardRemoved, temp[0]);
					}
				}
			}
		}
		
		static private function sendBlock(val:String, params:Array = null):void {
			if (val in scenario.scenario == false)
				return;
			if (val == "passwordEnter")
				waitForPass = true;
			var data:Object = scenario.scenario[val];
			// Duplicate object --> //
			var stringObject:String = JSON.stringify(data);
			data = JSON.parse(stringObject);
			data.isFirst = (steps == null || steps.length == 0 || (steps.length == 1 && "nav" in steps[0] == false));
			stringObject = null;
			// <-- //
			addButtons(data);
			steps ||= [];
			if ("back" in data == false || data.back != false) {
				if ("isLast" in data == true || data.isLast == true) {
					steps = null;
					S_ANSWER.invoke("app:actionCompleted");
				} else if ("isError" in data == true) {
					
				} else if (save == true) {
					steps.push( { nav:val } );
				}
			}
			var json:String = setLang(JSON.stringify(data));
			var tmp:String;
			var re:RegExp;
			if (params != null && params.length != 0) {
				for (var i:int = 0; i < params.length; i++) {
					tmp = JSON.stringify(params[i]);
					if (params[i] is String == true) {
						tmp = tmp.substr(1, tmp.length - 2);
						re = new RegExp("@@" + (i + 1), "gi");
						json = json.replace(re, tmp);
					} else {
						re = new RegExp("\"@@" + (i + 1) + "\"", "gi");
						json = json.replace(re, setLang(tmp));
					}
				}
			}
			S_ANSWER.invoke(json);
		}
		
		static private function addButtons(data:Object):void {
			if ("isMain" in data == true && data.isMain == true)
				return;
			if ("isLast" in data == true && data.isLast == true)
				return;
			if (steps == null || steps.length == 0 || (steps.length == 1 && "nav" in steps[0] == false)) {
				data.buttons ||= [];
				data.buttons.push( { text:"lang.buttonCancel", action:"system:cancel" } );
				return;
			}
			if ("isBack" in data == false) {
				data.buttons ||= [];
				data.buttons.push( { text:"lang.buttonBack", action:"cmd:back" } );
			}
			if ("isCancel" in data == false) {
				data.buttons ||= [];
				data.buttons.push( { text:"lang.buttonCancel", action:"system:cancel" } );
			}
			return;
		}
		
		static private function setLang(val:String):String {
			var indexStart:int = val.indexOf("lang.");
			var indexEnd:int;
			var indexEnd1:int;
			var indexEnd2:int;
			var temp:String;
			var langKey:String;
			var dotsIndex:int;
			if (indexStart != -1) {
				langClass = BankBotScenarioLang;
				while (indexStart != -1) {
					indexEnd1 = val.indexOf('"', indexStart);
					indexEnd2 = val.indexOf(' ', indexStart);
					if (indexEnd2 == -1)
						indexEnd = indexEnd1;
					else
						indexEnd = Math.min(indexEnd1, indexEnd2);
					temp = val.substring(0, indexStart);
					langKey = val.substring(indexStart + 5, indexEnd);
					dotsIndex = langKey.indexOf(".");
					if (dotsIndex != -1) {
						if (langKey.substr(0, dotsIndex) in langClass == true) {
							if (langKey.substr(dotsIndex + 1) in langClass[langKey.substr(0, dotsIndex)] == true) {
								temp += langClass[langKey.substr(0, dotsIndex)][langKey.substr(dotsIndex + 1)];
							} else {
								temp += "Undefined";
							}
						} else {
							temp += "Undefined";
						}
					} else if (langKey in langClass == true && langClass[langKey] != "") {
						temp += langClass[langKey];
					} else {
						temp += "Undefined";
					}
					temp += val.substring(indexEnd);
					val = temp;
					indexStart = val.indexOf("lang.");
				}
			}
			indexStart = val.indexOf("locatool.");
			if (indexStart != -1) {
				while (indexStart != -1) {
					indexEnd1 = val.indexOf('"', indexStart);
					indexEnd2 = val.indexOf(' ', indexStart);
					if (indexEnd2 == -1)
						indexEnd = indexEnd1;
					else
						indexEnd = Math.min(indexEnd1, indexEnd2);
					temp = val.substring(0, indexStart);
					langKey = val.substring(indexStart + 9, indexEnd);
					if (langKey in Lang == true && Lang[langKey] != "")
						temp += Lang[langKey];
					temp += val.substring(indexEnd);
					val = temp;
					indexStart = val.indexOf("locatool.");
				}
			}
			return val;
		}
		
		static private function getLangValue(val:String):String {
			if (langClass == null)
				langClass = BankBotScenarioLangEN;
			return langClass[val];
		}
		
		static public function reset():void {
			steps = null;
			stepsOld = null;
			lastPaymentsRequests = null;
		}
		
		static public function addPassSignal():void {
			if (PayManager.S_PASS_AUTHORIZE_SUCESS != null)
				PayManager.S_PASS_AUTHORIZE_SUCESS.add(onPayManagerPassSuccess);
		}
		
		static public function setMyAccountNumber(customerNumber:int):void {
			myAccountNumber = customerNumber;
		}
		
		static private function onPayManagerPassSuccess():void {
			PayManager.S_PASS_AUTHORIZE_SUCESS.remove(onPayManagerPassSuccess);
			PayAuthManager.isLockedByPass = false;
			recall();
		}
		
		static private function recall():void {
			var request:String;
			for (var n:String in lastPaymentsRequests) {
				request = lastPaymentsRequests[n];
				delete lastPaymentsRequests[n];
				callPaymentsMethod(request);
			}
		}
		
		static private function onPassForgot(respondData:Object, hash:String):void {
			if (preCheckForErrors(respondData, hash, null, "paymentsErrorDataNull") == true)
				return;
			if (steps != null && steps.length != 0 && "val" in steps[steps.length - 1] == false)
				steps[steps.length - 1].val = respondData.uid;
			sendBlock("onPassReminded");
		}
		
		static private function onCryptoOfferCreated(respondData:Object, hash:String):void {
			if (preCheckForErrors(respondData, hash, null, "paymentsErrorDataNull") == true)
				return;
			if (steps != null && steps.length != 0 && "val" in steps[steps.length - 1] == false)
				steps[steps.length - 1].val = respondData.uid;
			sendBlock("clearCrypto");
			sendBlock("createOfferConfirmed");
		}
		
		static private function onCryptoOfferCreated1(respondData:Object, hash:String):void {
			if (preCheckForErrors(respondData, hash, null, "paymentsErrorDataNull") == true)
				return;
			sendBlock("clearCrypto");
			S_ANSWER.invoke("requestRespond:cryptoOfferCreated:" + JSON.stringify(respondData));
		}
		
		static private function onCryptoWithdrawed(respondData:Object, hash:String):void {
			if (preCheckForErrors(respondData, hash, null, "paymentsErrorDataNull") == true)
				return;
			sendBlock("clearCryptoAccount");
			var wpID:String = respondData.message;
			sendBlock("bcWithdrawalConfirmed", [wpID]);
		}
		
		static private function onInvestmentDelivered(respondData:Object, hash:String):void {
			if (preCheckForErrors(respondData, hash, null, "paymentsErrorDataNull") == true)
				return;
			sendBlock("clearInvestments");
			sendBlock("bcDeliveryConfirmed");
		}
		
		static private function onCryptoDeposite(respondData:Object, hash:String):void {
			if (preCheckForErrors(respondData, hash, null, "paymentsErrorDataNull") == true)
				return;
			sendBlock("clearCryptoAccount");
			sendBlock("bcDepositeConfirmed");
		}
		
		static private function onCryptoDepositeAddress(respondData:Object, hash:String):void {
			if (preCheckForErrors(respondData, hash, null, "paymentsErrorDataNull") == true)
				return;
			sendBlock("bcDepositeAddressConfirmed", [respondData.address, steps[steps.length - 2].val.split("|!|")[0]]);
		}
		
		static private function onCryptoDepositeAddressInvestment(respondData:Object, hash:String):void {
			if (preCheckForErrors(respondData, hash, null, "paymentsErrorDataNull") == true)
				return;
			var temp:Array = steps[steps.length - 2].val.split("|!|");
			sendBlock("bcDepositeAddressInvestmentConfirmed", [respondData.address, temp[0], temp[1]]);
		}
		
		static private function onCryptoTraded(respondData:Object, hash:String):void {
			if (preCheckForErrors(respondData, hash, null, "paymentsErrorDataNull") == true)
				return;
			if (steps != null && steps.length != 0 && "val" in steps[steps.length - 1] == false)
				steps[steps.length - 1].val = respondData.uid;
			sendBlock("clearCryptoAccount");
			S_ANSWER.invoke("requestRespond:cryptoTrading:" + JSON.stringify(respondData));
		}
		
		static private function onCryptoOfferActivated(respondData:Object, hash:String):void {
			if (preCheckForErrors(respondData, hash, null, "paymentsErrorDataNull") == true)
				return;
			sendBlock("clearCrypto");
			sendBlock("activateOfferConfirmed");
		}
		
		static private function onCryptoOfferDeactivated(respondData:Object, hash:String):void {
			if (preCheckForErrors(respondData, "cryptoOfferDectivate" + hash, null, "paymentsErrorDataNull") == true)
				return;
			sendBlock("clearCrypto");
			sendBlock("deleteOfferConfirmed");
			S_ANSWER.invoke("requestRespond:cryptoLotDeleted:" + hash);
		}
		
		static private function onCancelRD(respondData:Object, hash:String):void {
			if (preCheckForErrors(respondData, "cancelRD" + hash, null, "paymentsErrorDataNull") == true)
				return;
			sendBlock("clearCrypto");
			sendBlock("clearCryptoRD");
			sendBlock("cancelRDConfirmed");
		}
		
		static private function onCardVerified(respondData:Object, hash:String):void {
			if (preCheckForErrors(respondData, hash, null, "paymentsErrorDataNull") == true)
				return;
			sendBlock("clearCards");
			sendBlock("cardVerificationConfirmed");
		}
		
		static private function onLinkCardURL(respondData:Object):void {
			if (preCheckForErrors(respondData, "linkCard", null, "paymentsErrorDataNull") == true)
				return;
			sendBlock("clearCards");
			sendBlock("linkCard", [respondData.url + "&sid=" + PayConfig.PAY_SESSION_ID + "&lang=" + LangManager.model.getCurrentLanguageID()]);
		}
		
		static private function onCardBlocked(respondData:Object, hash:String):void {
			if (preCheckForErrors(respondData, "blockCard" + hash, null, "paymentsErrorDataNull") == true)
				return;
			sendBlock("clearCards");
			sendBlock("blockCardConfirmed");
		}
		
		static private function onCardRemoved(respondData:Object, hash:String):void {
			if (preCheckForErrors(respondData, "removeCard" + hash, null, "paymentsErrorDataNull") == true)
				return;
			sendBlock("clearCards");
			sendBlock("removeCardConfirmed");
		}
		
		static private function onCardUnblocked(respondData:Object, hash:String):void {
			if (preCheckForErrors(respondData, "unblockCard" + hash, null, "paymentsErrorDataNull") == true)
				return;
			sendBlock("clearCards");
			sendBlock("unblockCardConfirmed");
		}
		
		static private function onCardActivated(respondData:Object, hash:String):void {
			if (preCheckForErrors(respondData, "activateCard" + hash, null, "paymentsErrorDataNull") == true)
				return;
			sendBlock("clearCards");
			sendBlock("cardActivationConfirmed");
		}
		
		static private function onInvestmentsLoaded(respondData:Object):void {
			if (preCheckForErrors(respondData, "investments", "requestRespond:investments:") == true)
				return;
			investmentsData = respondData;
			S_ANSWER.invoke("requestRespond:investments:" + JSON.stringify(respondData));
			if (lastWaitingInvestmentsAction != null) {
				getAnswer(lastWaitingInvestmentsAction);
				lastWaitingInvestmentsAction = null;
			}
		}
		
		static private function onInvestmentDetailsLoaded(respondData:Object):void {
			if (preCheckForErrors(respondData, "investmentDetails", "requestRespond:investmentDetails:") == true)
				return;
			if (respondData != null) {
				investmentDetailsData[respondData.INSTRUMENT] = respondData;
			}
			S_ANSWER.invoke("requestRespond:investmentDetailsCompleted:" + JSON.stringify(respondData));
			sendBlock("investmentDetails", [Lang.investmentsTitles[respondData.INSTRUMENT], respondData.INSTRUMENT]);
		}
		
		static private function onInvestmentHistoryLoaded(respondData:Object, hash:String):void {
			if (preCheckForErrors(respondData, "investmentsHistory" + hash, "requestRespond:investmentHistory:") == true)
				return;
			if (respondData == null ||
				"data" in respondData == false ||
				respondData.data is Array == false ||
				respondData.data.length == 0) {
					S_ANSWER.invoke("requestRespond:investmentHistory:");
					return;
			}
			var history:Array = respondData.data as Array;
			var l:int = history.length;
			var objectForScreen:Array = [];
			var tempObject:Object;
			var tmp:String;
			for (var i:int = 0; i < l; i++) {
				tempObject = {};
				if (history[i].type.toLowerCase() == "sell") {
					tempObject.action = "repeatInvestmentSale";
					tempObject.mine = true;
				} else {
					tempObject.action = "repeatInvestmentPurchase";
					tempObject.mine = false;
				}
				tempObject.transactionID = history[i].id;
				tempObject.bankBot = true;
				tempObject.acc = history[i].instrument;
				tempObject.amount = Number(history[i].quantity);
				if (history[i].type.toLowerCase() == "sell")
					tempObject.desc = Lang.fundsReceived + " " + Math.abs((Number(history[i].price) * Number(history[i].quantity))).toFixed(2) + " " + history[i].currency + "\n" + Lang.fundsPL + " " + ((Number(history[i].pl) > 0) ? "+" : "") + Number(history[i].pl).toFixed(2) + " " + history[i].currency;
				else
					tempObject.desc = Lang.fundsInvested + " " + (Number(history[i].price) * Number(history[i].quantity)).toFixed(2) + " " + history[i].currency;
				tempObject.amountEnd = history[i].price;
				tempObject.amountEndCurrency = history[i].currency;
				tempObject.amountEndPreText = "Rate: ";
				tempObject.time = Number(history[i].ts) * 1000;
				tempObject.transaction = history[i];
				tempObject.uid = history[i].uid;
				tempObject.title = Lang.TEXT_INVESTMENT.substr(0, 1).toUpperCase() + Lang.TEXT_INVESTMENT.substr(1).toLowerCase();
				objectForScreen.push(tempObject);
			}
			objectForScreen.reverse();
			S_ANSWER.invoke("requestRespond:investmentHistory:" + JSON.stringify(objectForScreen));
		}
		
		static private function onTotalLoaded(respondData:Object):void {
			if (preCheckForErrors(respondData, "total", null, "requestRespond:total:") == true)
				return;
			S_ANSWER.invoke("requestRespond:total:" + JSON.stringify(respondData));
		}
		
		static private function onHomeLoaded(respondData:Object):void {
			if (preCheckForErrors(respondData, "home", null, "requestRespond:home:") == true)
				return;
			S_ANSWER.invoke("requestRespond:home:" + JSON.stringify(respondData));
		}
		
		static private function onInvestmentCompleted(respondData:Object, hash:String):void {
			if (preCheckForErrors(respondData, hash, null, "paymentsErrorDataNull") == true)
				return;
			sendBlock("clearInvestments");
			sendBlock("clearWallets");
			sendBlock("investmentConfirmed");
		}
		
		static private function onPinRequested(respondData:Object):void {
			if (preCheckForErrors(respondData, null, null, "paymentsErrorDataNull"))
				return; 
			if (respondData.channel == "ivr")
				sendBlock("pinCodeCallbackCompleted");
			else
				sendBlock("pinCodeCompleted");
		}
		
		static private function onTransactionCodeResponse(respondData:Object, hash:String):void {
			if (preCheckForErrors(respondData, "transactionCode" + hash, null, "paymentsErrorDataNull", [3503]) == true) {
				if (respondData.code == 3503)
					sendBlock("transactionCodeFailed");
				return;
			}
			sendBlock("transactionCodeCompleted");
		}
		
		static private function onCryptoSwapListResponse(respondData:Object):void {
			if (preCheckForErrors(respondData, "rdSwapStep1", null, "paymentsErrorDataNull") == true)
				return;
			respondData.step = 1;
			S_ANSWER.invoke("requestRespond:cryptoSwapList:" + JSON.stringify(respondData));
			sendBlock("cryptoSwapList");
		}
		
		static private function onRDSwapStep1(respondData:Object):void {
			if (preCheckForErrors(respondData, "rdSwapStep1", null, "paymentsErrorDataNull") == true)
				return;
			respondData.step = 1;
			S_ANSWER.invoke("requestRespond:rdSwap:" + JSON.stringify(respondData));
			sendBlock("cryptoSwapSecondConfirm", [respondData.min_amount.readable, respondData.max_amount.readable]);
		}
		
		static private function onRDSwapStep2(respondData:Object, hash:String):void {
			if (preCheckForErrors(respondData, hash, null, "paymentsErrorDataNull") == true)
				return;
			respondData.step = 2;
			S_ANSWER.invoke("requestRespond:rdSwap:" + JSON.stringify(respondData));
			sendBlock("cryptoSwapThirdConfirm", [steps[steps.length - 2].val]);
		}
		
		static private function onRDSwap(respondData:Object, hash:String):void {
			if (preCheckForErrors(respondData, hash, null, "paymentsErrorDataNull") == true)
				return;
			sendBlock("cryptoSwapConfirmed");
		}
		
		static private function onPossibleRD(respondData:Object, hash:String):void {
			if (preCheckForErrors(respondData, "possibleRD" + hash, null, "paymentsErrorDataNull") == true)
				return;
			S_ANSWER.invoke("requestRespond:possibleRD:" + JSON.stringify(respondData));
		}
		
		static private function onETHLinkReceived(respondData:Object):void {
			if (preCheckForErrors(respondData, "declareETHAddressLink", null, "paymentsErrorDataNull") == true)
				return;
			S_ANSWER.invoke("requestRespond:declareETHAddressLink:" + JSON.stringify(respondData));
		}
		
		static private function onThirdpartyInvoiceLinkReceived(respondData:Object, hash:String):void {
			if (preCheckForErrors(respondData, "tpiLink" + hash, null, "paymentsErrorDataNull") == true)
				return;
			S_ANSWER.invoke("requestRespond:thirdpartyInvoiceLink:" + JSON.stringify(respondData));
		}
		
		static private function onMainCurrencyChanged(respondData:Object):void {
			if (preCheckForErrors(respondData, "changeMainCurrency", null, "paymentsErrorDataNull") == true)
				return;
			sendBlock("changeCurrencyConfirmed");
		}
		
		static private function onInvestmentSellCompleted(respondData:Object, hash:String):void {
			if (preCheckForErrors(respondData, hash, null, "paymentsErrorDataNull") == true)
				return;
			sendBlock("clearInvestments");
			sendBlock("clearWallets");
			sendBlock("investmentSellConfirmed");
		}
		
		static private function onWalletCreated(respondData:Object, hash:String):void {
			if (preCheckForErrors(respondData, hash, null, "paymentsErrorDataNull") == true)
				return;
			sendBlock("clearWallets");
			sendBlock("walletConfirmed");
		}
		
		static private function onTradingAccountOpened(respondData:Object, hash:String):void {
			if (preCheckForErrors(respondData, hash, null, "paymentsErrorDataNull") == true)
				return;
			if (respondData.success == true)
				sendBlock("openTradingAccountConfirmed");
			else
				sendBlock("payError", [Lang.tradingAccOpeningWait]);
		}
		
		static private function onInvestmentCurrencySetted(respondData:Object):void {
			if (preCheckForErrors(respondData, "investmentCurrency", null, "paymentsErrorDataNull") == true)
				return;
			accountInfo.settings = respondData;
			sendBlock("clearWallets");
			sendBlock("investMoney");
		}
		
		static private function onNotExistWalletCreated(respondData:Object, hash:String):void {
			if (preCheckForErrors(respondData, "walletCreation" + hash, null, "paymentsErrorDataNull") == true)
				return;
			var temp:Array = steps[steps.length - 2].val.split("|!|");
			temp[1] = respondData as String;
			steps[steps.length - 1].val = "";
			for (var i:int = 0; i < temp.length; i++) {
				if (i != 0)
					steps[steps.length - 1].val += "|!|";
				steps[steps.length - 1].val += temp[i];
			}
			callPaymentsMethod("exchange:" + steps[steps.length - 1].val);
		}
		
		static private function onNotExistWalletSavingCreated(respondData:Object, hash:String):void {
			if (preCheckForErrors(respondData, "walletCreationSaving" + hash, null, "paymentsErrorDataNull") == true)
				return;
			var temp:Array = steps[steps.length - 2].val.split("|!|");
			temp[1] = respondData as String;
			steps[steps.length - 1].val = "";
			for (var i:int = 0; i < temp.length; i++) {
				if (i != 0)
					steps[steps.length - 1].val += "|!|";
				steps[steps.length - 1].val += temp[i];
			}
			callPaymentsMethod("exchange:" + steps[steps.length - 1].val);
		}
		
		static private function onTransactionLoaded(respondData:Object, hash:String):void {
			if (preCheckForErrors(respondData, hash) == true)
				return;
			S_ANSWER.invoke("requestRespond:transaction:" + JSON.stringify(respondData));
		}
		
		static private function onCardHistoryLoaded(respondData:Object, hash:String):void {
			if (preCheckForErrors(respondData, hash, "requestRespond:history:") == true)
				return;
			if (respondData == null ||
				respondData is Array == false ||
				respondData.length == 0) {
					S_ANSWER.invoke("requestRespond:history:");
					return;
			}
			var history:Array = respondData as Array;
			var l:int = history.length;
			var objectForScreen:Array = [];
			var tempObject:Object;
			var tmp:String;
			for (var i:int = 0; i < l; i++) {
				tempObject = {};
				if (history[i].type.toLowerCase() == "credit")
					tempObject.mine = false;
				else
					tempObject.mine = true;
				tempObject.acc = history[i].currency;
				tempObject.amount = Number(history[i].amount);
				tempObject.desc = history[i].comment;
				tempObject.status = history[i].status;
				tempObject.time = Number(history[i].timestamp) * 1000;
				tempObject.title = Lang.cardOperation.substr(0, 1).toUpperCase() + Lang.cardOperation.substr(1).toLowerCase();
				objectForScreen.push(tempObject);
			}
			objectForScreen.reverse();
			S_ANSWER.invoke("requestRespond:history:" + JSON.stringify(objectForScreen));
		}
		
		static private function onCardsLoaded(respondData:Object):void {
			if (preCheckForErrors(respondData, "cards", "requestRespond:cards:") == true)
				return;
			S_ANSWER.invoke("requestRespond:cards:" + JSON.stringify(respondData));
		}
		
		static private function onLinkedCardsLoaded(respondData:Object):void {
			if (preCheckForErrors(respondData, "linkedCards", "requestRespond:linkedCards:") == true)
				return;
			S_ANSWER.invoke("requestRespond:linkedCards:" + JSON.stringify(respondData));
		}
		
		static private function onWalletsLoaded(respondData:Object):void {
			if (preCheckForErrors(respondData, "wallet", "requestRespond:wallets:") == true)
				return;
			accountInfo = respondData;
			S_ANSWER.invoke("requestRespond:wallets:" + JSON.stringify(respondData));
			if (lastWaitingWalletsAction != null) {
				getAnswer(lastWaitingWalletsAction);
				lastWaitingWalletsAction = null;
			}
		}
		
		static private function onCryptoLoaded(respondData:Object):void {
			if (preCheckForErrors(respondData, "crypto", "requestRespond:crypto:") == true)
				return;
			cryptoAccounts = respondData;
			S_ANSWER.invoke("requestRespond:crypto:" + JSON.stringify(cryptoAccounts));
			if (lastWaitingCryptoAction != null) {
				getAnswer(lastWaitingCryptoAction);
				lastWaitingCryptoAction = null;
			}
		}
		
		static private function onFatCatz(respondData:Object):void {
			if (preCheckForErrors(respondData, "fatCatz", "requestRespond:fatCatz:") == true)
				return;
			S_ANSWER.invoke("requestRespond:fatCatz:" + JSON.stringify(respondData));
		}
		
		static private function onCryptoCreated(respondData:Object, hash:String):void {
			if (preCheckForErrors(respondData, hash, null, "paymentsErrorDataNull") == true)
				return;
			cryptoAccounts = null;
			getAnswer("bot:bankbot " + "nav:crypto");
		}
		
		static private function onCryptoDeals(respondData:Object):void {
			if (preCheckForErrors(respondData, "cryptoDeals", null, "paymentsErrorDataNull") == true)
				return;
			S_ANSWER.invoke("requestRespond:cryptoDeals:" + JSON.stringify(respondData));
		}
		
		static private function onLoggedIn(errorCode:Number = NaN):void {
			isLoggining = false;
			if (!isNaN(errorCode) && errorCode == PayRespond.ERROR_NOT_APPROVED_ACCOUNT)
			{
				sendBlock("payError", [BankManager.ACCOUNT_NOT_APPROVED]);
				return;
			}
			if (!isNaN(errorCode) && errorCode == -1)
			{
				reset();
				MobileGui.changeMainScreen(PaymentsUnavaliableScreen);
				
				return;
			}
			if (!isNaN(errorCode) && errorCode == 1)
			{
				sendBlock("payError", [BankManager.PWP_NOT_ENTERED]);
				return;
			}
			if (PayConfig.PAY_SESSION_ID == "") {
				if (errorCode == 1999)
				{
					//server error;
					MobileGui.changeMainScreen(PaymentsUnavaliableScreen);
				}
				else
				{
					sendBlock("payError", [BankManager.PWP_NOT_ENTERED]);
				}
				
				return;
			}
			recall();
		}
		
		static private function onPasswordChecked(respondData:Object):void {
			if (preCheckForErrors(respondData) == true)
				return;
			PayAuthManager.isLockedByPass = false;
			waitForPass = false;
			if (lastPaymentsRequests == null)
				return;
			var request:String;
			for (var n:String in lastPaymentsRequests) {
				request = lastPaymentsRequests[n];
				delete lastPaymentsRequests[n];
				callPaymentsMethod(request);
			}
		}
		
		static private function onPasswordChanged(respondData:Object, savedRequestData:Object = null):void {
			if (preCheckForErrors(respondData) == true) {
				if ("code" in respondData )	{
					if (respondData.code == 4101) {
						ToastMessage.display(Lang.currentPasswordWrong);
					} else if (respondData.code == 4102) {
						ToastMessage.display(Lang.passwordNotMeetComplexity);
					} else if ("msg" in respondData && respondData.msg != null) {
						ApplicationErrors.add("payment error not localized: " + respondData.msg);
						ToastMessage.display(respondData.msg);
					}
				}
				sendBlock("passwordChange");
				
				return;
			}
			
			onPasswordChangeSuccess(savedRequestData);
			
			waitForPass = false;
			if (lastPaymentsRequests == null)
				return;
			var request:String;
			for (var n:String in lastPaymentsRequests) {
				request = lastPaymentsRequests[n];
				delete lastPaymentsRequests[n];
				callPaymentsMethod(request);
			}
		}
		
		static private function onPasswordChangeSuccess(requestData:Object):void {
			var responseData:Object = new Object();
			responseData.data = new Object();
			responseData.data.password = requestData.pass;
			
			PayAPIManager.S_LOGIN_SUCCESS.invoke(responseData);
			
			if (MobileGui.touchIDManager != null) {
				MobileGui.touchIDManager.changePassTouchID(requestData.pass);
				MobileGui.touchIDManager.saveTouchID(requestData.pass);
			}
		}
		
		static private function onHistoryTradesLoaded(respondData:Object, hash:String, accountNumber:String = null):void {
			if (preCheckForErrors(respondData, hash, "requestRespond:historyTrades:") == true)
				return;
			if ("data" in respondData == false ||
				respondData.data == null ||
				respondData.data is Array == false ||
				respondData.data.length == 0) {
					S_ANSWER.invoke("requestRespond:historyTrades:");
					return;
			}
			var history:Array = respondData.data;
			var l:int = history.length;
			var objectForScreen:Array = [];
			var tempObject:Object;
			var tmp:String;
			for (var i:int = 0; i < l; i++) {
				tempObject = { };
				tempObject.mine = true;
				tempObject.type = "coinTrade";
				tempObject.bankBot = true;
				tempObject.acc = history[i].CURRENCY;
				tempObject.amount = Number(history[i].AMOUNT);
				tempObject.transaction = history[i];
				tempObject.action = "repeatCrypto";
				if ("STATUS" in history[i] == true)
					tempObject.status = history[i].STATUS;
				if ("DESCRIPTION" in history[i] == true)
					tempObject.desc = history[i].DESCRIPTION;
				if ("UID" in history[i] == true)
					tempObject.desc += "\nReference: " + history[i].UID;
				else if ("TRANSACTION_ID" in history[i] == true)
					tempObject.desc = "ID " + history[i].TRANSACTION_ID;
				tempObject.time = Number(history[i].CREATED_TS) * 1000;
				tempObject.timeEnd = Number(history[i].UPDATED_TS) * 1000;
				tempObject.amountEnd = Math.abs(tempObject.amount);
				tempObject.amountEndCurrency = tempObject.acc;
				tempObject.commentsCount = 0;
				tempObject.title = history[i].TITLE;
				tempObject.transactionID = history[i].TRANSACTION_ID;
				tempObject.raw = history[i];
				objectForScreen.push(tempObject);
			}
			objectForScreen.reverse();
			S_ANSWER.invoke("requestRespond:historyTrades:" + JSON.stringify(objectForScreen));
		}
		
		static private function onHistoryLoaded(respondData:Object, hash:String, accountNumber:String = null):void {
			var requestAction:String = "history";
			if (respondData.page != 1)
				requestAction += "More";
			if (preCheckForErrors(respondData, hash, "requestRespond:" + requestAction + ":") == true)
				return;
			if ("data" in respondData == false ||
				respondData.data == null ||
				respondData.data is Array == false ||
				respondData.data.length == 0) {
					S_ANSWER.invoke("requestRespond:" + requestAction + ":");
					return;
			}
			var history:Array = respondData.data;
			var l:int = history.length;
			var objectForScreen:Array = [];
			var tempObject:Object;
			var tmp:String;
			for (var i:int = 0; i < l; i++) {
				tempObject = { };
				if (history[i].TYPE == "COMMISSION CHARGE") {
					tempObject.mine = true;
					tempObject.acc = history[i].CURRENCY;
					tempObject.bankBot = true;
					tempObject.amount = Number(history[i].AMOUNT) + Number(history[i].FEE_AMOUNT);
				} else if (history[i].TYPE == "SAVINGS TRANSFER") {
					tempObject.mine = true;
					tempObject.type = "savingsTransfer";
					tempObject.bankBot = true;
					tempObject.acc = history[i].CURRENCY;
					tempObject.amount = Number(history[i].AMOUNT);
				} else if (history[i].TYPE == "SAVINGS") {
					tempObject.mine = false;
					tempObject.acc = history[i].CURRENCY;
					tempObject.type = "saving";
					tempObject.bankBot = true;
					tempObject.amount = Number(history[i].AMOUNT) + Number(history[i].FEE_AMOUNT);
				} else if (history[i].TYPE == "COIN TRADE"  || history[i].TYPE == "COIN_STAT_BUY" || history[i].TYPE == "COIN_STAT_SELL") {
					tempObject.mine = true;
					tempObject.type = "coinTrade";
					tempObject.bankBot = true;
					tempObject.acc = history[i].CURRENCY;
					tempObject.amount = Number(history[i].AMOUNT);
					tempObject.transaction = history[i];
					tempObject.action = "repeatCrypto";
				} else if (history[i].TYPE == "TERM DEPOSIT") {
					tempObject.mine = true;
					tempObject.type = "RD";
					tempObject.bankBot = true;
					tempObject.acc = history[i].CURRENCY;
					tempObject.amount = Number(history[i].AMOUNT);
					tempObject.transaction = history[i];
				} else if (history[i].TYPE == "OUTGOING TRANSFER") {
					tempObject.mine = true;
					tempObject.userAccNumber = history[i].RECEIVER_CUSTOMER_NUMBER;
					tempObject.user = UsersManager.getUserBy(history[i].TO);
					if (tempObject.user == null) {
						if (history[i].TO != null) {
							if (history[i].TO.indexOf("+") == 0) {
								tempObject.phone = history[i].TO;
								tempObject.action = "repeatSendMoneyPhone";
							} else {
								tempObject.login = history[i].TO;
							}
						} else {
							echo("BankBotController", "onHistoryLoaded", "FROM filed is null", true);
							tempObject.bankBot = true;
						}
					}
					tempObject.acc = history[i].CURRENCY;
					tempObject.amount = Number(history[i].AMOUNT) + Number(history[i].FEE_AMOUNT);
				} else if (history[i].TYPE == "INCOMING TRANSFER") {
					if (history[i].FROM == "dukascopy") {
						tempObject.bankBot = true;
					} else {
						tempObject.mine = false;
						tempObject.userAccNumber = history[i].SENDER_CUSTOMER_NUMBER;
						tempObject.user = UsersManager.getUserBy(history[i].FROM); // from can be null
						if (tempObject.user == null) {
							if (history[i].FROM != null) {
								if (history[i].FROM.indexOf("+") == 0) {
									tempObject.phone = history[i].FROM;
									tempObject.action = "repeatSendMoneyPhone";
								} else {
									tempObject.login = history[i].FROM;
								}
							} else {
								echo("BankBotController", "onHistoryLoaded", "FROM filed is null", true);
								tempObject.bankBot = true;
							}
						}
						if (history[i].CODE_SECURED == true && history[i].STATUS != "COMPLETED") {
							tempObject.withCode = true;
							tempObject.uid = history[i].UID;
							tempObject.action = "repeatSendMoneyPhoneCode";
						}
					}
					tempObject.acc = history[i].CURRENCY;
					tempObject.amount = Number(history[i].AMOUNT);
				} else if (history[i].TYPE == "WITHDRAWAL") {
					tempObject.bankBot = true;
					tempObject.mine = true;
					tempObject.acc = history[i].CURRENCY;
					tempObject.amount = Number(history[i].AMOUNT) + Number(history[i].FEE_AMOUNT);
					if ("DESCRIPTION" in history[i] &&
						history[i].DESCRIPTION != null &&
						history[i].DESCRIPTION != "") {
							if (history[i].DESCRIPTION.toLowerCase().indexOf("withdrawal") != -1 &&
								history[i].DESCRIPTION.toLowerCase().indexOf("card") != -1) {
									tempObject.action = "repeatCardWithdrawal";
							}
					}
				} else if (history[i].TYPE == "ORDER OF PREPAID CARD") {
					tempObject.bankBot = true;
					tempObject.mine = true;
					tempObject.acc = history[i].FEE_CURRENCY;
					tempObject.amount = Number(history[i].AMOUNT) + Number(history[i].FEE_AMOUNT);
				} else if (history[i].TYPE == "DEPOSIT") {
					tempObject.bankBot = true;
					tempObject.mine = false;
					tempObject.acc = history[i].CURRENCY;
					tempObject.amount = Number(history[i].AMOUNT) + Number(history[i].FEE_AMOUNT);
					if ("DESCRIPTION" in history[i] &&
						history[i].DESCRIPTION != null &&
						history[i].DESCRIPTION != "") {
							if (history[i].DESCRIPTION.toLowerCase().indexOf("deposit") != -1 &&
								history[i].DESCRIPTION.toLowerCase().indexOf("card") != -1) {
									tempObject.action = "repeatCardDeposit";
							}
					}
				} else if (history[i].TYPE == "MERCHANT TRANSFER" && myAccountNumber != -1) {
					if (int(history[i].SENDER_CUSTOMER_NUMBER) == myAccountNumber) {
						tempObject.bankBot = true;
						tempObject.mine = true;
						tempObject.acc = history[i].CURRENCY;
						tempObject.amount = Number(history[i].AMOUNT) + Number(history[i].FEE_AMOUNT);
					} else {
						tempObject.bankBot = true;
						tempObject.mine = false;
						tempObject.acc = history[i].CURRENCY;
						tempObject.amount = Number(history[i].AMOUNT) + Number(history[i].FEE_AMOUNT);
					}
				} else if (history[i].TYPE == "INTERNAL TRANSFER") {
					tempObject.bankBot = true;
					if (accountNumber != null && accountNumber != "") {
						var IBAN:String = getIBANByWalletNumber(accountNumber);
						if (history[i].FROM != IBAN)
							tempObject.mine = false;
						else
							tempObject.mine = true;
						tempObject.type = ")!2exchange";
					} else {
						tempObject.mine = true;
						tempObject.type = "exchange";
					}
					tempObject.action = "repeatExchange";
					tempObject.acc = history[i].CURRENCY;
					tempObject.amount = Number(history[i].AMOUNT) + Number(history[i].FEE_AMOUNT);
					tempObject.transaction = history[i];
				} else if (history[i].TYPE == "INVESTMENT") {
					if (accountNumber != null && accountNumber != "") {
						if (history[i].FROM != null && history[i].FROM != "" && history[i].FROM.charAt(0).toLowerCase() == "c")
							tempObject.mine = true;
						else
							tempObject.mine = false;
						tempObject.type = ")!2investment";
					} else {
						tempObject.mine = true;
						tempObject.type = "investment";
					}
					tempObject.bankBot = true;
					if ("DESCRIPTION" in history[i] == true && history[i].DESCRIPTION != null && history[i].DESCRIPTION.toLowerCase().indexOf("Sale") == 0)
						tempObject.action = "repeatInvestmentSale";
					else
						tempObject.action = "repeatInvestmentPurchase";
					tempObject.acc = history[i].CURRENCY;
					tempObject.amount = Number(history[i].AMOUNT);
					tempObject.transaction = history[i];
				} else {
					continue;
				}
				if ("STATUS" in history[i] == true)
					tempObject.status = history[i].STATUS;
				if (tempObject.user != null) {
					tempObject.fromTo = true;
					tempObject.userAvatar = tempObject.user.getAvatarURL();
				} else if ("bankBot" in tempObject == false || tempObject.bankBot == false) {
					tempObject.fromTo = true;
				}
				if (tempObject.bankBot == true) {
					if ("DESCRIPTION" in history[i] == true && history[i].DESCRIPTION != null)
						tempObject.desc = history[i].DESCRIPTION;
				} else if ("MESSAGE" in history[i] == true && history[i].MESSAGE != null)
					tempObject.desc = history[i].MESSAGE;
				
				if ("UID" in history[i] == true) {
					if ("desc" in tempObject == false) {
						if (history[i].UID != null)
						{
							tempObject.desc = Lang.textReference + " " + history[i].UID;
						}
					} else {
						if ((history[i].TYPE == "INVESTMENT" || history[i].TYPE == "COIN TRADE") && history[i].FEE_CURRENCY != null)
							tempObject.desc += "\nCommission: " + Math.abs(Number(history[i].FEE_AMOUNT)).toFixed(CurrencyHelpers.getMaxDecimalCount(history[i].FEE_CURRENCY)) + " " + history[i].FEE_CURRENCY;
						if (history[i].UID != null)
						{
							tempObject.desc += "\n" + Lang.textReference + ": " + history[i].UID;
						}
					}
				} else if ("TRANSACTION_ID" in history[i] == true) {
					if ("desc" in tempObject == false)
						tempObject.desc = "ID " + history[i].UID;
					else
						tempObject.desc += "\nID " + history[i].UID;
				}
				tempObject.time = Number(history[i].CREATED_TS) * 1000;
				tempObject.timeEnd = Number(history[i].UPDATED_TS) * 1000;
				tempObject.transactionID = history[i].TRANSACTION_ID;
				if ("CONSOLIDATE_AMOUNT" in history[i] == true) {
					tempObject.amountEnd = Number(history[i].CONSOLIDATE_AMOUNT);
					tempObject.amountEndCurrency = history[i].CONSOLIDATE_CURRENCY;
				} else {
					tempObject.amountEnd = Math.abs(tempObject.amount);
					tempObject.amountEndCurrency = tempObject.acc;
				}
				tempObject.commentsCount = 0;
				tempObject.title = history[i].TITLE;
				tempObject.raw = history[i];
				objectForScreen.push(tempObject);
			}
			
			objectForScreen.reverse();
			S_ANSWER.invoke("requestRespond:" + requestAction + ":" + JSON.stringify(objectForScreen));
		}
		
		static private function getIBANByWalletNumber(accountNumber:String):String {
			if (accountInfo == null)
				return null;
			var l:int = accountInfo.accounts.length;
			for (var i:int = 0; i < l; i++) {
				if (accountInfo.accounts[i].ACCOUNT_NUMBER == accountNumber)
					return accountInfo.accounts[i].IBAN;
			}
			return null;
		}
		
		static private function onCardWithdrawalCompleted(respondData:Object, hash:String):void {
			if (preCheckForErrors(respondData, hash, null, "paymentsErrorDataNull") == true)
				return;
			sendBlock("clearCards");
			sendBlock("clearWallets");
			sendBlock("cardWithdrawalConfirmed");
		}
		
		static private function onOtherWithdrawalCompleted(respondData:Object, hash:String):void {
			if (preCheckForErrors(respondData, hash, null, "paymentsErrorDataNull") == true)
				return;
			sendBlock("clearWallets");
			sendBlock("otherWithdrawalConfirm", [respondData.url]);
		}
		
		static private function onPaymentsDepositCompleted(respondData:Object, hash:String):void {
			if (preCheckForErrors(respondData, hash, null, "paymentsErrorDataNull") == true)
				return;
			sendBlock("clearWallets");
			sendBlock("paymentsDepositConfirm", [respondData.url]);
		}
		
		static private function onCardDetailsSensitive(respondData:Object, hash:String):void {
			if (preCheckForErrors(respondData, hash, null, "paymentsErrorDataNull") == true)
				return;
			sendBlock("cardDetailsWebView", [respondData.url]);
		}
		
		static private function onCardUnloadCompleted(respondData:Object, hash:String):void {
			var params:String;
			if (lastPaymentsRequests != null && hash in lastPaymentsRequests)
				params = lastPaymentsRequests[hash];
			if (preCheckForErrors(respondData, hash, null, "paymentsErrorDataNull") == true)
				return;
			var vals:Array = params.split("|!|");
			if (vals != null && vals.length > 2)
				PHP.call_statVI("min_" + vals[3], (Number(vals[2]) * 0.314) + "");
			sendBlock("clearCards");
			sendBlock("clearWallets");
			if ("url" in respondData == true) {
				sendBlock("dukaCardDepositeTransactionConfirmedURL", [respondData.url]);
			} else {
				sendBlock("dukaCardDepositeTransactionConfirmed");
			}
		}
		
		static private function onTransactionCompleted(respondData:Object, hash:String):void {
			if (preCheckForErrors(respondData, hash, null, "paymentsErrorDataNull") == true)
				return;
			sendBlock("clearWallets");
			sendBlock("clearCryptoAccount");
			fireTransactionComplete();
		}
		
		static private function fireTransactionComplete():void {
			if (steps == null || steps.length == 0)
				return;
			var temp:Array = steps[steps.length - 2].val.split("|!|");
			if (temp.length != 7)
				return;
			var res:Object = {
				userUid: temp[2],
				comment: temp[4],
				currency: temp[1],
				amount: temp[0],
				acc: temp[3]
			}
			temp = null;
			S_ANSWER.invoke("requestRespond:transactionCompeleted:" + JSON.stringify(res));
			sendBlock("transactionConfirmed");
		}
		
		static private function onRDCompleted(respondData:Object, hash:String):void {
			if (preCheckForErrors(respondData, hash, null, "paymentsErrorDataNull", [5408]) == true) {
				if (respondData.code == 5408)
					sendBlock("rdErrorNotEnoughMoney", [respondData.msg])
				return;
			}
			sendBlock("clearCryptoAccount");
			sendBlock("clearCryptoRD");
			sendBlock("cryptoRewardDepositeConfirmed");
		}
		
		static private function onRDLoaded(respondData:Object):void {
			if (preCheckForErrors(respondData, "cryptoRDs", null, "paymentsErrorDataNull") == true)
				return;
			S_ANSWER.invoke("requestRespond:cryptoRD:" + JSON.stringify(respondData));
		}
		
		static private function onMoneyExchanged(respondData:Object, hash:String):void {
			if (preCheckForErrors(respondData, hash, null, "paymentsErrorDataNull") == true)
				return;
			sendBlock("clearWallets");
			sendBlock("transferConfirmed");
		}
		
		static private function onInternalTrasfer(respondData:Object, hash:String):void {
			if (preCheckForErrors(respondData, hash, null, "paymentsErrorDataNull") == true)
				return;
			sendBlock("clearWallets");
			sendBlock("transferInternalConfirmed");
		}
		
		/**
		 * Precheck for errors.
		 * @param	respondData - PayManagerNew respond, hash - key in lastPaymentsRequests, answer - string for BankManager
		 * @return	true - error, false - all is ok;
		 */
		static private function preCheckForErrors(respondData:Object, hash:String = null, answer:String = null, block:String = null, codePass:Array = null):Boolean {
			var errorRespond:int = checkForErrors(respondData);
			if (errorRespond == 2) {
				removeByHash(hash);
				if (answer != null)
					S_ANSWER.invoke(answer);
				if (block != null)
					sendBlock(block);
				if (respondData.code == -2)
					MobileGui.changeMainScreen(PaymentsUnavaliableScreen);
				return true;
			}
			if (errorRespond == 1)
				return true;
			if (errorRespond == 3) {
				if (codePass == null || codePass.indexOf(respondData.code) == -1)
					sendBlock("payError", [respondData.msg, (hash != null && lastPaymentsRequestsID != null && "hash" in lastPaymentsRequestsID == true) ? lastPaymentsRequestsID[hash] : ""]);
				removeByHash(hash);
				return true;
			}
			removeByHash(hash);
			return false;
		}
		
		static private function removeByHash(hash):void {
			if (hash == null)
				return;
			if (lastPaymentsRequests != null)
				delete lastPaymentsRequests[hash];
			if (lastPaymentsRequestsID != null)
				delete lastPaymentsRequestsID[hash];
		}
		
		/**
		 * Check for errors.
		 * @param	respondData
		 * @return	0 - without error; 1 - error with request; 2 - fatal error; 3 - data error;
		 */
		static private function checkForErrors(respondData:Object):int {
			if (respondData == null) {
				sendBlock("paymentsErrorDataNull");
				return 2;
			}
			if (respondData == -2 || respondData == 1999 || respondData == 3014) {
				S_ANSWER.invoke("requestRespond:error:" + respondData);
				return 2;
			}
			if ("errorType" in respondData) {
				if (respondData.code == -2) {
					
					var errorText:String;
					if (respondData is String)
					{
						errorText = respondData as String;
					}
					else if (respondData is Object)
					{
						if ("msg" in respondData && respondData.msg != null)
						{
							errorText = respondData.msg;
						}
						else
						{
							errorText = respondData as String;
						}
					}
					
					S_ANSWER.invoke("requestRespond:error:" + errorText);
					return 2;
				}
				if (respondData.errorType == "type") {
					if (respondData.code == 2010 || respondData.code == 3202 || respondData.code == 3409 || respondData.code == 3408) {
						PayAuthManager.isLockedByPass = true;
						sendBlock("passwordEnter");
					} else if (respondData.code == 2011 || respondData.code == 4101) {
						sendBlock("passwordChange");
					}
					return 1;
				} else if (respondData.errorType == "error") {
					if (respondData.code == 2020)
						sendBlock("paymentsErrorNotApproved");
					else if (respondData.code == 2015)
						sendBlock("paymentsErrorBlocked");
					else if (respondData.code == 2012)
						sendBlock("paymentsErrorPwdManyTimes");
					return 2;
				} else if (respondData.errorType == "request") {
					if (respondData.code == 2000) {
						if (isLoggining == true)
							return 1;
						isLoggining = true;
						PayAPIManager.login(onLoggedIn, true);
					}
					return 1;
				} else if (respondData.errorType == "data") {
					return 3;
				}
				return 2;
			}
			return 0;
		}
		
		static public function getScenario():BankBotScenario {
			return scenario;
		}
	}
}