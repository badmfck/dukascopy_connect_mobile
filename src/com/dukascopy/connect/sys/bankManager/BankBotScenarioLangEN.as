package com.dukascopy.connect.sys.bankManager {
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class BankBotScenarioLangEN {
		
		// OTHER
		static public const otherOperation:String = "Do you want to continue with other operations?";
		static public const actionInProgress:String = "Your action is in progress…";
		static public const notReadyYet:String = "This functionality is currently in development.";
		static public const obligatoryPass:String = "Please confirm operation with your password.";
		static public const whatWant:String = "What would you like to do?";
		static public const pleaseChoose:String = "Please choose.";
		
		static public const buy:String = "Buy";
		static public const sell:String = "Sell";
		static public const buy1:String = "Buy";
		static public const sell1:String = "Sell";
		static public const bid:String = "Bid";
		static public const ask:String = "Ask";
		
		// BUTTONS
		static public const buttonCancel:String = "Cancel";
		static public const buttonBack:String = "Back";
		static public const buttonConfirm:String = "Confirm";
		static public const buttonYes:String = "Yes";
		static public const buttonNo:String = "No";
		static public const buttonOk:String = "Ok";
		static public const buttonCopyAddress:String = "Copy address";
		
		// MENU DESCRIPTIONS
		static public const mainDesc:String = "What would you like to do?";
		static public const cardsDesc:String = "Please select card or other operation.";
		static public const cardOpsDesc:String = "Please select card operation.";
		static public const accountsDesc:String = "Please select account operation.";
		static public const accountsSelectDesc:String = "Please select account.";
		static public const withdrawalsDesc:String = "Withdrawals";
		static public const depositsDesc:String = "Deposits";
		static public const sendMoneyDesc:String = "Select recipient.";
		static public const investmentsDesc:String = "Please choose.";
		static public const investmentsListDesc:String = "Please select investment instrument.";
		static public const investmentsSellDesc:String = "Please select investment to sell.";
		static public const investmentDesc:String = "Please select investment operation.";
		static public const investmentBuyDesc:String = "Select investments to buy.";
		static public const investmentBuySelectIndexDesc:String = "Select index.";
		static public const investmentBuySelectCommoditiesDesc:String = "Select commodities.";
		static public const investmentBuySelectCryptoDesc:String = "Select crypto currency.";
		static public const accountOpening:String = "Choose account type to open.";
		static public const accountLimits:String = "All limits.";
		static public const cardOrder:String = "Please select card type.";
		static public const cryptoDesc:String = "Please select operation with Dukascoins.";
		static public const cryptoOpenDesc:String = "You do not have Dukascoins account yet. You want to create it now?";
		static public const cryptoOffersDesc:String = "Please choose.";
		static public const cryptoBuySellDesc:String = "@@1 Dukascoins";
		static public const rewardsDepositesDesc:String = "Reward deposits";
		static public const blockchainOperationsDesc:String = "Blockchain operations";
		static public const myCryptoOffersDesc:String = "My conditional “@@1” lots"; // @@2 (@@1)
		static public const myAllCryptoOffersDesc:String = "My conditional lots"; // @@2 (@@1)
		static public const cryptoOfferOperationsDesc:String = "Order operations";
		static public const selectRewardDesc:String = "Select reward type";
		static public const rewardsDepositesConditionsDesc:String = "Reward deposits conditions";
		static public const cyptoNotAvailableDesc:String = "Dukascoins not available for your account.";
		static public const otherDepositesDesc:String = "Please select other Dukascopy account to deposit money from it.";
		static public const otherWithdrawalDesc:String = "Please select other Dukascopy account to withdrawal money on it.";
		
		static public const bcDepositeDesc:String = "Use this form to deposit DUK+ coins from your external blockchain wallet.\\n\\n"
			+ "Be ready to provide the sender wallet address before making the deposit and report the transaction ID after sending the DUK+ coins.\\n\\n"
			+ "By using this function you confirm that your are the sole beneficial owner of the external crypto wallet used for DUK+ deposit in this operation.";
		
		static public const bcWithdrawalDesc:String = "Please fill out the form to withdraw DUK+ to your registered external blockchain wallet.\\n\\n"
			+ "Please note: During the start-up stage of the new service all withdrawal requests are processed manually during standard business hours.";
		
		// CONFIRM DESCRIPTIONS
		static public const confirmCardDeposite:String = "Please confirm unload from card.";
		static public const confirmCardWithdrawal:String = "Please confirm withdrawal to card.";
		static public const confirmCardEnable:String = "Press confirm to enable card.";
		static public const confirmCardDisable:String = "Press confirm to disable card.";
		static public const confirmCardRemove:String = "Please confirm card removing.";
		static public const confirmAccountOpen:String = "Please confirm account opening.";
		static public const confirmTransaction:String = "Please confirm your transaction.";
		static public const confirmExchange:String = "Please confirm your transfer.";
		static public const confirmInvestment:String = "Please confirm investment.";
		static public const confirmInvestmentSell:String = "Please confirm investment sell.";
		static public const confirmInvestmentSellAll:String = "Please confirm all investment sell.";
		static public const confirmInvoice:String = "Please confirm your invoice.";
		static public const confirmInvestmentCurrency:String = "Do you want, that @@1 be your investment referral currency?";
		static public const confirmAccountOpening:String = "Please confirm trading account opening.";
		static public const confirmCreateOffer:String = "Please confirm the following order: @@1 @@2 DUK+ at @@3 EUR";
		static public const confirmBCDeposite:String = "Please confirm this operation";
		static public const confirmBCWithdrawal:String = "Please confirm this operation";
		static public const confirmCryptoTrade:String = "Please confirm this operation";
		static public const confirmBCRewardDeposite:String = "Amount: @@1 DUK+\\nExpiration date:\\n@@2\\nReward:\\n@@3\\n\\nImportant:\\nIf you cancel deposit before the Expiration date, the reward will be revoked and you will pay a @@4 penalty.\\n\\nPlease confirm.";
		static public const confirmOfferActivate:String = "Do you want to activate it?";
		static public const confirmOfferDeactivate:String = "Do you want to deactivate it?";
		static public const confirmOfferDelete:String = "Do you want to delete it?";
		
		// CONFIRMED DESCRIPTIONS
		static public const confirmedCardDeposite:String = "Your deposit has been completed.";
		static public const confirmedCardEnable:String = "Now your card is enabled.";
		static public const confirmedCardDisable:String = "Your card was disabled.";
		static public const confirmedCardRemove:String = "Your card removed.";
		static public const confirmedCardWithdrawal:String = "Your withdrawal has been completed.";
		static public const confirmedCardActivate:String = "Your card has been activated.";
		static public const confirmedCardVerify:String = "Your card has been verified.";
		static public const confirmedAccountOpening:String = "Your account has been opened.";
		static public const confirmedTransaction:String = "Your transaction has been completed.";
		static public const confirmedExchange:String = "Your transfer has been completed.";
		static public const confirmedInvestmentSell:String = "Your investment sell has been completed.";
		static public const confirmedInvestmentSellAll:String = "Your investments sell has been completed.";
		static public const confirmedInvestmentBuy:String = "Your investment has been completed.";
		static public const confirmedInvestmentCurrency:String = "Your investment referral currency is selected.";
		static public const confirmedInvoice:String = "Your invoice has been completed.";
		static public const confirmedTradingAccountOpen:String = "Request has been successfully submitted. Your Account manager will contact you.";
		static public const confirmedCreateOffer:String = "Order was created and published in Marketplace.";
		static public const confirmedActivateOffer:String = "Order was activated.";
		static public const confirmedDeactivateOffer:String = "Order was deactivated.";
		static public const confirmedDeleteOffer:String = "Order was deleted.";
		static public const confirmedBCWithdrawal:String = "Your withdrawal request is accepted.";
		static public const confirmedBCDeposite:String = "Your deposit request is accepted.";
		static public const confirmedCryptoTrade:String = "Your trade was completed.";
		static public const confirmedRewardDeposite:String = "Reward deposit created.";
		static public const confirmedBCAddressDeposite:String = "Now please send the previously declared amount of DUK+ coins to this deposit address:\\n@@1\\n\\nPlease be informed that unvalidated transfers (where the amount or sender wallet address mismatch the announced ones) cannot be returned.\\n\\nAfter the sending has been made, press “Ok” and provide the blockchain transaction ID of your transfer.";
		
		// MENU ITEMS
		static public const menuCardsOps:String = "Cards operations";
		static public const menuAccOps:String = "Account operations";
		static public const menuSendMoney:String = "Send money";
		static public const menuLoadMoney:String = "Load money (Deposit)";
		static public const menuSendInvoice:String = "Send Invoice";
		static public const menuExchangeMoney:String = "Exchange money";
		static public const menuInvestments:String = "Investments";
		static public const menuOpenTradingAccount:String = "Open trading account";
		static public const menuOpenP2P:String = "911 Crypto P2P";
		static public const menuCheckAccLimits:String = "Check account limits";
		static public const menuOpenEBank:String = "Open e-bank";
		static public const menuOrderCard:String = "Order card";
		static public const menuLinkCard:String = "Link card";
		static public const menuCardDetails:String = "Card details";
		static public const menuCardTopUp:String = "Top up card";
		static public const menuCardUnload:String = "Unload card";
		static public const menuCardDisable:String = "Disable card";
		static public const menuCardEnable:String = "Enable card";
		static public const menuCardRemove:String = "Remove card";
		static public const menuCardActivate:String = "Activate card";
		static public const menuCardVerify:String = "Verify card";
		static public const menuShowAccounts:String = "Show all accounts";
		static public const menuOpenAccount:String = "Open new account";
		static public const menuDepositeAccount:String = "Deposits";
		static public const menuWithdrawalAccount:String = "Withdrawals";
		static public const menuToCard:String = "To card";
		static public const menuFromCard:String = "From card";
		static public const menuBankTransfer:String = "Bank transfer";
		static public const menuCardTransfer:String = "Card top up";
		static public const menuHistory:String = "History";
		static public const menuAccountHistory:String = "Account history";
		static public const menuFromTransaction:String = "From transactions list";
		static public const menuToPhone:String = "To phone number";
		static public const menuToContact:String = "From my contact list";
		static public const menuToChatmate:String = "To chatmate";
		static public const menuExternalRecipient:String = "External recipient";
		static public const menuRepeatTransaction:String = "Repeat transaction";
		static public const menuRepeatExchange:String = "Repeat exchange";
		static public const menuRepeatDeposit:String = "Repeat deposit";
		static public const menuRepeatWithdrawal:String = "Repeat withdrawal";
		static public const menuInviteConsultant:String = "Invite Consultant";
		static public const menuInvestmentBuy:String = "Invest money";
		static public const menuInvestmentSell:String = "Sell investments";
		static public const menuInvestmentPortfolio:String = "My portfolio";
		static public const menuInvestmentDetails:String = "Details";
		static public const menuInvestmentSellAll:String = "Sell all";
		static public const menuInvestmentIndexes:String = "Indexes";
		static public const menuInvestmentCommodities:String = "Commodities";
		static public const menuInvestmentCrypto:String = "Crypto";
		static public const menuForexCFD:String = "Forex/CFD";
		static public const menuBinaryOptions:String = "Binary Options";
		static public const menuIncreaseLimits:String = "Increase limits";
		static public const menuAcceptAndProceed:String = "Accept and proceed";
		static public const menuCardVirtual:String = "Virtual card";
		static public const menuCardPlastic:String = "Plastic card";
		static public const menuUserTransactions:String = "Transactions with User";
		static public const menuEnterPwd:String = "Enter Password";
		static public const menuRecipientProfile:String = "Recipient profile";
		static public const menuSenderProfile:String = "Sender profile";
		static public const menuCryptoMarket:String = "Dukascoins";
		static public const menuDukasnotes:String="Dukasnotes";
		static public const menuCryptoBuy:String = "Buy";
		static public const menuCryptoSell:String = "Sell";
		static public const menuCryptoOrders:String = "My orders";
		static public const menuCryptoWithdrawal:String = "Withdrawal to my blockchain wallet";
		static public const menuCryptoDeposit:String = "Deposit from my blockchain wallet";
		static public const menuCryptoTransfer:String = "Send Dukascoins";
		static public const menuShowOffers:String = "Marketplace";
		static public const createOffer:String = 'Add “@@1” Lot';//"Place @@2 (@@1) order";
		static public const menuMyShowOffers:String = 'My “@@2” Lots';// "My @@2 (@@1) orders";
		static public const menuByBestPrice:String = "Best price";
		static public const menuByVolume:String = "Biggest size";
		static public const menuByFilter:String = "Advanced filter";
		static public const menuBlockchainOperations:String = "Blockchain operations";
		static public const menuRewardsDeposite:String = "Reward deposits";
		static public const menuRDReadConditions:String = "Read conditions";
		static public const menuRDCreateNew:String = "New deposit";
		static public const menuRDCoin:String = "Coin reward (DUK+)";
		static public const menuRDFiat:String = "Fiat reward (EUR)";
		static public const cryptoSellBuyMarket:String = "@@1 at market price";
		static public const menuCryptoOfferDeactivate:String = "Deactivate";
		static public const menuCryptoOfferActivate:String = "Activate";
		static public const menuCryptoOfferRemove:String = "Remove";
		static public const menuRDCoinConditions:String = "Coin reward conditions";
		static public const menuRDFiatConditions:String = "Fiat reward conditions";
		static public const menuShowMyOffers:String = "Show my lots";
		static public const menuRequestChatmate:String = "Ask a friend";
		static public const menuVisitDukascoin:String = "Visit dukascoin.com";
		
		static public const investmentIndex:String = "Index";
		static public const investmentSilver:String = "Silver";
		static public const investmentGold:String = "Gold";
		static public const investmentNaturalGas:String = "Natural gas";
		static public const investmentBrentOil:String = "Brent oil";
		static public const investmentBitcoin:String = "Bitcoin";
		static public const investmentEthereum:String = "Ethereum";
		
		static public const itemShowCardOps:String = "Show card operations.";
		static public const itemUnloadCard:String = "Transfer @1 @2 from @3 card to @4 account.";
		static public const itemSendToCard:String = "Top up card @3 from @4 account by @1 @2.";
		static public const itemOpenAccount:String = "Open new @1 account.";
		static public const itemExchange:String = "Transfer @1 @2 from @3 account to @4 account.";
		static public const itemOpenAccountAuto:String = "@@1 account will be opened automatically.";
		static public const itemInvestmentSell1:String = "Sell @1.";
		static public const itemInvestmentSell2:String = "Sell @1 worth of @2.";
		static public const itemInvestmentBuy1:String = "Purchase @1.";
		static public const itemInvestmentBuy2:String = "Purchase @1 worth of @2.";
		static public const itemInvestmentDetails:String = "@@1 detail.";
		static public const itemInvestmentCurrency:String = "Set @1 for my investment currency";
		static public const itemClickOnTransaction:String = "Click on transaction from list and proceed with payments";
		static public const itemInvoice:String = "Send invoice for @1 to @2";
		static public const itemSendMoney:String = "Send @1 to @2";
		static public const itemSendMoneyPhone:String = "Send @1 to @2";
		static public const itemShowCryptoOfferOperations:String = "Show order operations";
		
		static public const errorPwdManyTimes:String = "Password verification is blocked. Too many failed attempts during short period of time. Try again later.";
		static public const errorAccountBlocked:String = "Account is blocked";
		static public const errorAccountNotApproved:String = "Account not approved";
		static public const errorWrongData:String = "Something went wrong";
		
		static public const investmentDisclaimer:String = "All operations with investments have to be conducted in one reference currency. All further operations related to investments (purchase, sale, dividends and custody charge) will be made only in that currency. Reference currency may be changed only when all active assets are sold.";
		
		public function BankBotScenarioLangEN() {
			
		}
	}
}