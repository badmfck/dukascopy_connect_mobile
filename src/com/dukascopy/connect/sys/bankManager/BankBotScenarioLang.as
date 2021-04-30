package com.dukascopy.connect.sys.bankManager {
	import com.dukascopy.connect.Config;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class BankBotScenarioLang {
		
		// OTHER
		static public var otherOperation:String = "Do you want to continue with other operations?";
		static public var actionInProgress:String = "Your action is in progress…";
		static public var notReadyYet:String = "This functionality is currently in development.";
		static public var obligatoryPass:String = "Please confirm operation with your password.";
		static public var whatWant:String = "What would you like to do?";
		static public var pleaseChoose:String = "Please choose.";
		
		static public var buy:String = "Buy";
		static public var sell:String = "Sell";
		static public var buy1:String = "Buy";
		static public var sell1:String = "Sell";
		static public var bid:String = "Bid";
		static public var ask:String = "Ask";
		
		// BUTTONS
		static public var buttonCancel:String = "Cancel";
		static public var buttonBack:String = "Back";
		static public var buttonConfirm:String = "Confirm";
		static public var buttonYes:String = "Yes";
		static public var buttonNo:String = "No";
		static public var buttonOk:String = "Ok";
		static public var buttonCopyAddress:String = "Copy address";
		
		// MENU DESCRIPTIONS
		static public var mainDesc:String = "What would you like to do?";
		static public var cardsDesc:String = "Please select card or other operation.";
		static public var cardOpsDesc:String = "Please select card operation.";
		static public var walletOpsDesc:String = "Please select account operation.";
		static public var accountsDesc:String = "Please select account operation.";
		static public var accountsOtherTypesDesc:String = "Select accounts type.";
		static public var newWalletCurrencyDesc:String = "Select accounts type.";
		static public var accountsSelectDesc:String = "Please select account.";
		static public var withdrawalsDesc:String = "Withdrawals";
		static public var depositsDesc:String = "Deposits";
		static public var sendMoneyDesc:String = "Select recipient.";
		static public var investmentsDesc:String = "Please choose.";
		static public var investmentsListDesc:String = "Please select investment instrument.";
		static public var investmentsSellDesc:String = "Please select investment to sell.";
		static public var investmentDesc:String = "Please select investment operation.";
		static public var investmentBuyDesc:String = "Select investments to buy.";
		static public var investmentBuySelectIndexDesc:String = "Select index.";
		static public var investmentBuySelectSharesDesc:String = "Select share.";
		static public var investmentBuySelectCommoditiesDesc:String = "Select commodity.";
		static public var investmentBuySelectCryptoDesc:String = "Select crypto currency.";
		static public var accountOpening:String = "Choose account type to open.";
		static public var accountLimits:String = "All limits.";
		static public var cardOrder:String = "Please select card type.";
		static public var cryptoDesc:String = "Please select operation with Dukascoins.";
		static public var cryptoOpenDesc:String = "You do not have Dukascoins account yet. You want to create it now?";
		static public var cryptoOffersDesc:String = "Please choose.";
		static public var cryptoBuySellDesc:String = "@@1 Dukascoins";
		static public var rewardsDepositesDesc:String = "Reward deposits";
		static public var blockchainOperationsDesc:String = "Blockchain operations";
		static public var myCryptoOffersDesc:String = "My conditional “@@1” lots";
		static public var myAllCryptoOffersDesc:String = "My conditional lots";
		static public var cryptoOfferOperationsDesc:String = "Order operations";
		static public var selectRewardDesc:String = "Select reward type";
		static public var cryptoStatDesc:String = "DUK+ account statistics";
		static public var cryptoStatPeriodsDesc:String = "Statistics periods";
		static public var cryptoTradesStatDesc:String = "Traders statistics DUK+";
		static public var cryptoActiveOrdersDesc:String = "Active orders statistics DUK+";
		static public var rewardsDepositesConditionsDesc:String = "Reward deposits conditions";
		static public var cyptoNotAvailableDesc:String = "Dukascoins not available for your account.";
		static public var otherDepositesDesc:String = "Please select other Dukascopy account to deposit money from it.";
		static public var otherWithdrawalDesc:String = "Please select other Dukascopy account to withdrawal money on it.";
		static public var fatCatsDesc:String = "Dukascoin Fat Catz reward program.";
		static public var fatCatsDescNotFC:String = "You are not yet qualified for Fat Catz reward in %@. To be qualified for Fat Catz reward in %@ as of today your average monthly balance need to be %@1 DUK+ or more.";
		static public var fatCatsDescIsFC:String = "You are qualified for Fat Catz reward in %@ as of today:";
		static public var cryptoNotesDesc:String = "Minimal amount of deal is 1000 tokens. Please be sure that you have external ETH wallet.";
		static public var cryptoRDActionsDesc:String = "Please select reward deposite operation.";
		static public var operationDetails:String = "Operation details.";
		static public var operationTransactionsDesc:String = "Operation transactions.";
		static public var invoicesDesc:String = "Invoices";
		static public var confirmRDCancelWithPenaltyDesc:String = "You are about to cancel your reward deposit before its maturity date. This will lead to no reward being paid for the cancelled deposit and to a penalty charge  applied to the allocated Dukascoins in the amount of @@1 Dukascoins.\\n\\nTotal amount to be returned: @@2 Dukascoins";
		static public var confirmRDCancelWithoutPenaltyDesc:String = "You are about to cancel your reward deposit before its maturity date. This will lead to no reward being paid for the cancelled deposit.\\n\\nTotal amount to be returned: @@2 Dukascoins";
		
		static public var bcDepositeDesc:String = "You will be required to declare the DUK+ amount you intend to deposit during your top-up. Note that the entered DUK+ deposit amount has to match exactly the sum of Dukascoins that Dukascopy will receive, otherwise your deposit is likely not to be accepted.\\n\\n"
			+ "A unique deposit address will be generated for this deposit. It will be valid only for one deposit operation in the amount you declare in advance in the present form. Keep it strictly confidentially and do not disclose to third parties.";
		
		static public var bcWithdrawalDesc:String = "Please fill out the form to withdraw Dukascoins (DUK+) to your registered external blockchain wallet";// (ERC20 compatible).";
		
		// CONFIRM DESCRIPTIONS
		static public var confirmCardDeposite:String = "Please confirm unload from card.";
		static public var confirmCardWithdrawal:String = "Please confirm withdrawal to card.";
		static public var confirmCardEnable:String = "Press confirm to enable card.";
		static public var confirmCardDisable:String = "Press confirm to disable card.";
		static public var confirmCardRemove:String = "Please confirm card removing.";
		static public var confirmAccountOpen:String = "Please confirm account opening.";
		static public var confirmTransaction:String = "Please confirm your transaction.";
		static public var confirmExchange:String = "Please confirm your transfer.";
		static public var confirmInternalTransfer:String = "Confirm transfer.";
		static public var confirmInternalTransferT:String = "Transfers that require currency conversion are executed at Dukascopy Bank SA current spot rate adjusted by a Fee\\n\\nThe undersigned client(s) has/have taken due note of all activities carried out on the abovementioned account with Dukascopy Bank and hereby ratifies/ratify them in complete knowledge and understanding thereof, fully discharging Dukascopy Bank of all liabilities related thereto. If and to the extent needed to execute the transfer requested herein, the undersigned client(s) further authorise(s) Dukascopy Bank to close out any open positions relative to the aforesaid account with Dukascopy Bank. Finally please note that transaction may be executed instantly right after you click the 'I agree' button below.\\n\\nConfirm transfer.";
		static public var confirmInvestment:String = "Please confirm investment.";
		static public var confirmInvestmentSell:String = "Please confirm investment sell.";
		static public var confirmInvestmentSellAll:String = "Please confirm all investment sell.";
		static public var confirmInvoice:String = "Please confirm your invoice.";
		static public var confirmInvestmentCurrency:String = "Do you want, that @@1 be your investment referral currency?";
		static public var confirmAccountOpening:String = "Please confirm trading account opening.";
		static public var confirmCreateOffer:String = "Please confirm the following order: @@1 @@2 DUK+ at @@3 EUR";
		static public var confirmBCDeposite:String = "Please confirm this operation";
		static public var confirmBCWithdrawal:String = "Please confirm this operation";
		static public var confirmCryptoTrade:String = "Please confirm this operation";
		static public var confirmBCRewardDeposite:String = "Amount: @@1 DUK+\\nExpiration date:\\n@@2\\nReward:\\n@@3\\n\\nImportant:\\nIf you cancel this deposit before the Expiration date, the reward will be revoked and you will pay a @@4 penalty.\\n\\nPlease confirm.";
		static public var confirmBCRewardDepositeNonPen:String = "Amount: @@1 DUK+\\nExpiration date:\\n@@2\\nReward:\\n@@3\\n\\nImportant:\\nIf you cancel this deposit before the Expiration date, the reward will be revoked.\\n\\nPlease confirm.";
		static public var confirmOfferActivate:String = "Do you want to activate it?";
		static public var confirmOfferDeactivate:String = "Do you want to deactivate it?";
		static public var confirmOfferDelete:String = "Do you want to delete it?";
		static public var confirmChangeCurrency:String = "Do you want to change main currecy?";
		
		// CONFIRMED DESCRIPTIONS
		static public var confirmedCardDeposite:String = "Your deposit has been completed.";
		static public var confirmedCardEnable:String = "Now your card is enabled.";
		static public var confirmedCardDisable:String = "Your card was disabled.";
		static public var confirmedCardRemove:String = "Your card removed.";
		static public var confirmedCardWithdrawal:String = "Your withdrawal has been completed.";
		static public var confirmedCardActivate:String = "Your card has been activated.";
		static public var confirmedCardVerify:String = "Your card has been verified.";
		static public var confirmedAccountOpening:String = "Your account has been opened.";
		static public var confirmedTransaction:String = "Your transaction has been completed.";
		static public var confirmedExchange:String = "Your transfer has been completed.";
		static public var confirmedInvestmentSell:String = "Your investment sell has been completed.";
		static public var confirmedInvestmentSellAll:String = "Your investments sell has been completed.";
		static public var confirmedInvestmentBuy:String = "Your investment has been completed.";
		static public var confirmedInvestmentCurrency:String = "Your investment referral currency is selected.";
		static public var confirmedInvoice:String = "Your invoice has been completed.";
		static public var confirmedTradingAccountOpen:String = "Request has been successfully submitted. Your Account manager will contact you.";
		static public var confirmedCreateOffer:String = "Order was created and published in Marketplace.";
		static public var confirmedActivateOffer:String = "Order was activated.";
		static public var confirmedDeactivateOffer:String = "Order was deactivated.";
		static public var confirmedDeleteOffer:String = "Order was deleted.";
		static public var confirmedBCWithdrawal:String = "Your withdrawal request is accepted.";
		static public var confirmedBCDelivery:String = "Your delivery request is accepted.";
		static public var confirmedBCDeposite:String = "Your deposit request is accepted.";
		static public var confirmedCryptoTrade:String = "Your trade was completed.";
		static public var confirmedRewardDeposite:String = "Reward deposit created.";
		static public var confirmedCryptoRDCancel:String = "Reward deposit canceled.";
		static public var transactionCodeFailed:String = "Wrong code. Please try one more time.";
		static public var transactionCodeCompleted:String = "Code is correct. Transfer is finished.";
		static public var confirmedPinRequest:String = "Pin code was successfully sent to your phone via sms.";
		static public var confirmedChangeCurrency:String = "Main currency changed.";
		static public var confirmedBCAddressDeposite:String = "The address for this Dukascoin deposit operation is:\\n@@1\\n\\nPlease transfer the exact amount of @@2 Dukascoin\/s to this address.\\n\\nCAUTION! Any discrepancy between the amount declared and the actual deposit performed, mismatch in token address will potentially cause the total loss of the transferred crypto-assets. Dukascopy Bank SA is not obliged to return any crypto tokens received in case of the erroneous or unidentified transactions.";
		
		// MENU ITEMS
		static public var menuInvestmentDeliveryBC:String = "Delivery to blockchain";
		static public var menuCardsOps:String = "Cards operations";
		static public var menuAccOps:String = "Account operations";
		static public var menuSendMoney:String = "Send money";
		static public var menuLoadMoney:String = "Load money (Deposit)";
		static public var menuSendInvoice:String = "Send Invoice";
		static public var menuSendAnInvoice:String = "Send an invoice";
		static public var menuInvoiceToChatmate:String = "Invoice to a chatmate";
		static public var menuInvoiceToThirdParty:String = "Invoice to a third-party";
		static public var menuExchangeMoney:String = "Exchange money";
		static public var menuInvestments:String = "Investments";
		static public var menuOpenTradingAccount:String = "Open trading account";
		static public var menuCheckAccLimits:String = "Check account limits";
		static public var menuOpenEBank:String = "Open e-bank";
		static public var menuOrderCard:String = "Order card";
		static public var menuLinkCard:String = "Link card";
		static public var menuCardDetails:String = "Card details";
		static public var menuCardTopUp:String = "Top up card";
		static public var menuCardUnload:String = "Unload card";
		static public var menuCardDisable:String = "Disable card";
		static public var menuCardEnable:String = "Enable card";
		static public var menuCardRemove:String = "Remove card";
		static public var menuCancelRDWithPenalty:String = "Cancel with penalty";
		static public var menuCardActivate:String = "Activate card";
		static public var menuCardTracking:String = "Tracking card";
		static public var menuCardVerify:String = "Verify card";
		static public var menuShowAccounts:String = "Show MCA accounts";
		static public var menuShowAccountsSavings:String = "Show savings accounts";
		static public var menuOpenAccount:String = "Open new account";
		static public var menuDepositeAccount:String = "Deposits";
		static public var menuWithdrawalAccount:String = "Withdrawals";
		static public var menuToCard:String = "To card";
		static public var menuFromCard:String = "From card";
		static public var menuFromApplePay:String = "Apple Pay";
		static public var menuBankTransfer:String = "Bank transfer";
		static public var menuMainCurrency:String = "Select main currency";
		static public var menuCardTransfer:String = "Card top up";
		static public var menuHistory:String = "History";
		static public var menuMCA:String = "MCA";
		static public var menuSavings:String = "Savings";
		static public var menuFromMCA:String = "From MCA";
		static public var menuFromSaving:String = "From Savings";
		static public var menuNewAccSaving:String = "Saving account";
		static public var menuNewAccMCA:String = "Multi-currency account";
		static public var menuFromSavingAcc:String = "From Savings account";
		static public var menuFromTradingAcc:String = "From Trading account";
		static public var menuToSavingAcc:String = "To Saving account";
		static public var menuToTradingAcc:String = "To Trading account";
		static public var menuAccountHistory:String = "Last transactions log";
		static public var menuAccountStat:String = "Account statistics";
		static public var menuAccountsAll:String = "Show all accounts";
		static public var menuCoinTradesStat:String = "Trades statistics";
		static public var menuActiveOrdersStat:String = "Active orders statistics";
		static public var menuTradesStatTotal:String = "Total";
		static public var menuTradesStatCurrentMonth:String = "Current month";
		static public var menuTradesStatPreviousMonth:String = "Previous month";
		static public var menuTradesStatCurrentWeek:String = "Current week";
		static public var menuTradesStatPreviousWeek:String = "Previous week";
		static public var menuTradesStatCurrentDay:String = "Current day";
		static public var menuTradesStatPreviousDay:String = "Previous day";
		static public var menuFromTransaction:String = "From transactions list";
		static public var menuToPhone:String = "To phone number";
		static public var menuToContact:String = "From my contact list";
		static public var menuToChatmate:String = "To chatmate";
		static public var menuExternalRecipient:String = "External recipient";
		static public var menuRepeatTransaction:String = "Repeat transaction";
		static public var menuRepeatExchange:String = "Repeat exchange";
		static public var menuRepeatDeposit:String = "Repeat deposit";
		static public var menuRepeatWithdrawal:String = "Repeat withdrawal";
		static public var menuInviteConsultant:String = "Invite Consultant";
		static public var menuInvestmentBuy:String = "Invest money";
		static public var menuInvestmentSell:String = "Sell investments";
		static public var menuInvestmentPortfolio:String = "My portfolio";
		static public var menuInvestmentPortfolioAll:String = "Show all accounts";
		static public var menuInvestmentDetails:String = "Details";
		static public var menuInvestmentSellAll:String = "Sell all";
		static public var menuInvestmentIndexes:String = "Indexes";
		static public var menuInvestmentShares:String = "Shares";
		static public var menuInvestmentCommodities:String = "Commodities";
		static public var menuInvestmentCrypto:String = "Crypto";
		static public var menuForexCFD:String = "Forex/CFD";
		static public var menuBinaryOptions:String = "Binary Options";
		static public var menuIncreaseLimits:String = "Increase limits";
		static public var menuAcceptAndProceed:String = "Accept and proceed";
		static public var menuCardVirtual:String = "Virtual card";
		static public var menuCardPlastic:String = "Plastic card";
		static public var menuUserTransactions:String = "Transactions with User";
		static public var menuEnterPwd:String = "Enter Password";
		static public var menuRecipientProfile:String = "Recipient profile";
		static public var menuSenderProfile:String = "Sender profile";
		static public var menuCryptoMarket:String = "Dukascoins";
		static public var menuDukasnotes:String="Dukasnotes";
		static public var menuCryptoBuy:String = "Buy";
		static public var menuCryptoSell:String = "Sell";
		static public var menuCryptoOrders:String = "My orders";
		static public var menuCryptoWithdrawal:String = "Withdrawal to my blockchain wallet";
		static public var menuCryptoDeposit:String = "Deposit from my blockchain wallet";
		static public var menuCryptoTransfer:String = "Send Dukascoins";
		static public var menuShowOffers:String = "Marketplace";
		static public var createOffer:String = 'Add “@@1” Lot';//"Place @@2 (@@1) order";
		static public var menuMyShowOffers:String = 'My “@@2” Lots';// "My @@2 (@@1) orders";
		static public var menuByBestPrice:String = "Best price";
		static public var menuByVolume:String = "Biggest size";
		static public var menuByFilter:String = "Advanced filter";
		static public var menuBlockchainOperations:String = "Blockchain operations";
		static public var menuRewardsDeposite:String = "Reward deposits";
		static public var menuRDReadConditions:String = "Read conditions";
		static public var menuRDCreateNew:String = "New deposit";
		static public var menuRDCancelled:String = "Cancelled";
		static public var menuRDClosed:String = "Closed";
		static public var menuRDActive:String = "Active";
		static public var menuCheckAddressETH:String = "Check ETH address";
		static public var menuRDCoin:String = "Coin reward (DUK+)";
		static public var menuRDFiat:String = "Fiat reward (EUR)";
		static public var cryptoSellBuyMarket:String = "@@1 at market price";
		static public var menuCryptoOfferDeactivate:String = "Deactivate";
		static public var menuCryptoOfferActivate:String = "Activate";
		static public var menuCryptoOfferRemove:String = "Remove";
		static public var menuRDCoinConditions:String = "Coin reward conditions";
		static public var menuRDFiatConditions:String = "Fiat reward conditions";
		static public var menuShowMyOffers:String = "Show my lots";
		static public var menuRequestChatmate:String = "Ask a friend";
		static public var menuVisitDukascoin:String = "Visit dukascoin.com";
		static public var menuFatCatz:String = "Fat Catz";
		static public var menuEnterTransactionCode:String = "Enter code";
		static public var cryptoNotesBuy:String = "Buy Dukascash";
		static public var cryptoNotesSell:String = "Sell Dukascash";
		static public var cryptoNotes:String = "Dukascash";
		static public var menuFatCatzConditionsAndStatistic:String = "Fat Catz conditions and statistics";
		static public var menuCardPin:String = "Pin request";
		static public var menuSaveAsTemplate:String = "Save as template";
		static public var menuFromTemplate:String = "From template";
		static public var menuOperationDetails:String = "Operation details";
		static public var menuTransactions:String = "Transactions";
		static public var menuCardStatement:String = "Card statement";
		static public var menuAccountStatement:String = "Account statement";
		static public var menuCardNumberCopy:String = "Copy card number";
		static public var menuIBANCopy:String = "Copy IBAN";
		
		static public var investmentIndex:String = "Index";
		static public var investmentSilver:String = "Silver";
		static public var investmentGold:String = "Gold";
		static public var investmentNaturalGas:String = "Natural gas";
		static public var investmentBrentOil:String = "Brent oil";
		static public var investmentBitcoin:String = "Bitcoin";
		static public var investmentEthereum:String = "Ethereum";
		
		static public var itemShowCardOps:String = "Show card operations.";
		static public var itemShowAccountOps:String = "Show account operations.";
		static public var itemUnloadCard:String = "Transfer @1 @2 from @3 card to @4 account.";
		static public var itemSendToCard:String = "Top up card @3 from @4 account by @1 @2.";
		static public var itemOpenAccount:String = "Open new @1 account.";
		static public var itemExchange:String = "Transfer @1 @2 from @3 account to @4 account.";
		static public var itemOpenAccountAuto:String = "@@1 account will be opened automatically.";
		static public var itemInvestmentSell1:String = "Sell @1.";
		static public var itemInvestmentSell2:String = "Sell @1 worth of @2.";
		static public var itemInvestmentBuy1:String = "Purchase @1.";
		static public var itemInvestmentBuy2:String = "Purchase @1 worth of @2.";
		static public var itemInvestmentDetails:String = "@@1 detail.";
		static public var itemInvestmentCurrency:String = "Set @1 for my investment currency";
		static public var itemClickOnTransaction:String = "Click on transaction from list and proceed with payments";
		static public var itemInvoice:String = "Send invoice for @1 to @2";
		static public var itemSendMoney:String = "Send @1 to @2";
		static public var itemSendMoneyPhone:String = "Send @1 to @2";
		static public var itemBCWithdrawal:String = "I want to withdrawal @1 DUK+ to @2";
		static public var itemBCDeposite:String = "I want to deposit @1 DUK+";
		static public var itemShowCryptoOfferOperations:String = "Show order operations";
		static public var itemRewardDepositOperations:String = "Show reward deposit operations";
		static public var itemInvestmentDeliveryBC:String = "I want to deliver @1 of my investment to @2";
		static public var itemSelectMainCurrency:String = "Selected currency is @1";
		
		static public var errorPwdManyTimes:String = "Password verification is blocked. Too many failed attempts during short period of time. Try again later.";
		static public var errorAccountBlocked:String = "Account is blocked";
		static public var errorAccountNotApproved:String = "Account not approved";
		static public var errorWrongData:String = "Something went wrong";
		
		static public var investmentDisclaimer:String = "All operations with investments have to be conducted in one reference currency. All further operations related to investments (purchase, sale, dividends and custody charge) will be made only in that currency. Reference currency may be changed only when all active assets are sold.";
		static public var investmentDisclaimerNew:String = "All operations with investment instruments have to be conducted in one reference currency, which is chosen before making the first investment. All further operations related to investments (e.g. purchase, sale, dividends and custody charge) will be made only in that currency. Reference currency may be changed only when all active assets are sold or transferred.\n\nBy making an investment you are purchasing a CFD contract with maximum leverage 1 to 1. See contract specification here:\n\n<a href='https://www.dukascopy.bank/swiss/fees-limits/'>dukascopy.bank/swiss/fees-limits/</a>\n\nBy proceeding further, I confirm the above and that I have read and agreed with the brochure on\n\n<a href='https://www.dukascopy.com/swiss/docs/bankForms/Special-Risks-in-Securities-Trading.pdf'>Special Risks in Securities Trading</a>.";
		
		static public var investmentsGroups:Object = {
			commodities:"Commodities",
			indices:"Indices",
			crypto:"Crypto",
			stocks:"Stocks"
		}
		
		static public var investmentBuySelectDesc:Object = {
			commodities:"Select commodity.",
			indices:"Select index.",
			crypto:"Select crypto.",
			stocks:"Select stock."
		}
		
		static public var investmentLabel:Object = {
			XAU:"Golg",
			XAG:"Silver",
			OIL:"Brent oil",
			GAS:"Natural gas"
		}
		
		public function BankBotScenarioLang() {
			
		}
		
		static public function updateKeys(vals:Object):void {
			for (var n:String in vals) {
				if (n in BankBotScenarioLang == true && vals[n] != null && vals[n] != "")
					BankBotScenarioLang[n] = vals[n];
				else if (n.indexOf("investmentLabel") == 0)
					investmentLabel[n.substr(15).toUpperCase()] = vals[n];
				else if (n.indexOf("investmentBuySelectDesc") == 0)
					investmentBuySelectDesc[n.substr(23).toLowerCase()] = vals[n];
				else if (n.indexOf("investmentsGroups") == 0)
					investmentsGroups[n.substr(17).toLowerCase()] = vals[n];
			}
		}
	}
}