package com.dukascopy.connect.sys.bankManager {
	
	/**
	 * ...
	 * @author Igor Bloom
	 */
	
	public class BankBotScenario extends Object {
		
		public var scenario:Object = {
			main: {
				desc:"lang.mainDesc",
				isMain:true,
				menu: [
					{
						text:"lang.menuCardsOps",
						keywords:"cards",
						action:"nav:cards"
					}, {
						text:"lang.menuAccOps",
						keywords:"accounts",
						action:"nav:accountOperations"
					}, {
						text:"lang.menuSendMoney",
						keywords:"send,money",
						action:"nav:sendMoney"
					}, {
						text:"lang.menuLoadMoney",
						keywords:"load,money",
						action:"nav:deposites"
					}, {
						text:"lang.menuSendAnInvoice",
						action:"nav:invoices"
					}, {
						text:"lang.menuExchangeMoney",
						keywords:"exchange,money",
						textForUser:"lang.itemExchange",
						/*type:"paymentsSendMy",
						action:"nav:transferConfirm"*/
						action:"nav:otherExchangeAcc"
					}, {
						text:"lang.menuInvestments",
						keywords:"investments",
						action:"nav:investments",
						disabled:true
					}, {
						text:"lang.menuCryptoMarket",
						keywords:"crypto",
						action:"nav:crypto",
						action1:"nav:cryptoOpen"
					}, 
					/*
						1. Нужен линкованный кошелёк.
						2. для покупки нужен счёт с фиатом не меншье 1000 (евро?) либо коинов по курсу
						Купить дукасноты
							: Проверить наличие линкованного кошелька
								: если нет, пиздуй открывать
							: какую из валют? EUR+ CHF+ USD+  Минимальное кол-во 1000. Убедись в наличии нужной суммы на своём MCA счету для покупки. 
								: Какое кол-во вы готовы приобрести? (сумму)
								: В какой валюты ты готов платить? (показываем счета с достаточными суммами)
								: отправляем всю собранную инфу в чат.
						Продать дукасноты
							: какую из валют? EUR+ CHF+ USD+
								: выбираем валюту и сумму. сумма на продажу больше 1000. Убедится что есть "прилинкованный кошелёк. Blockchain wallet"
									: если нет, пиздуй линковать.
									: введи адрес кошелька, узнать есть ли нужное кол-во нот, запросить процедуру чистоты (Витя знает)
								: отправляем всю собранную инфу в чат.
						Генерируем запрос в чат со всеми собранными данными
						API для проверки наличие бабла на кошельке
					*/
					/*{
						text:"lang.cryptoNotes",
						keywords:"notes,dukasnotes,dukascash",
						action:"nav:cryptoNotesOpen"
					},*/ {
						text:"lang.menuOpenTradingAccount",
						keywords:"open,account",
						action:"nav:chooseAccountToOpen"
					}, {
						text:"lang.menuCheckAccLimits",
						keywords:"limits",
						action:"nav:paymentsLimits"
					}, {
						text:"lang.menuOpenEBank",
						keywords:"payments,ebank",
						action:"app:payments",
						command:""
					}

				]
			},
			
/////////////////////////////////////////////////////////////////////////////////////////////////////////
/// CARDS -> ////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////
			
			cards: {
				desc:"lang.cardsDesc",
				menuLayout:"vertical",
				item: {
					text:"lang.itemShowCardOps",
					type:"cardSelect",
					action:"nav:cardOperations"
				},
				menu:[
					{
						text:"lang.menuOrderCard",
						keywords:"cards,order",
						type:"orderCards",
						action:"nav:orderCard"
					}, {
						text:"lang.menuLinkCard",
						keywords:"cards,link",
						action:"nav:linkCard"
					}
				],
				buttons: [
					{
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			cardUnload: {
				desc:"lang.cardsDesc",
				menuLayout:"vertical",
				item: {
					textForUser:"lang.itemUnloadCard",
					type:"cardSelect",
					typeNext:"depositesCard",
					action:"nav:transactionBankCardConfirm"
				},
				menu:[
					{
						text:"lang.menuCardTransfer",
						value:"CC",
						type:"paymentsDeposit",
						action:"nav:paymentsDepositConfirm"
					}
				],
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			depositesOther: {
				desc:"lang.otherDepositesDesc",
				menuLayout:"vertical",
				item: {
					textForUser:"lang.itemUnloadOther",
					type:"otherAccSelect",
					typeNext:"depositesOther",
					action:"nav:transactionOtherConfirm"
				},
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			withdrawalOther: {
				desc:"lang.otherWithdrawalDesc",
				menuLayout:"vertical",
				item: {
					textForUser:"lang.itemWithdrawalOther",
					type:"otherAccSelect",
					typeNext:"withdrawalOther",
					action:"nav:transactionOtherConfirm"
				},
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			bankWithdrawal: {
				item: {
					type:"cardSelect",
					action:"nav:cardWithdrawalConfirm"
				}
			},
			
			skrillWithdrawal: {
				item: {
					type:"cardSelect",
					action:"nav:cardWithdrawalConfirm"
				}
			},
			
			netellerWithdrawal: {
				item: {
					type:"cardSelect",
					action:"nav:cardWithdrawalConfirm"
				}
			},
			
			cardWithdrawal: {
				desc:"lang.cardsDesc",
				menuLayout:"vertical",
				item: {
					text:"lang.itemSendToCard",
					type:"cardSelect",
					typeNext:"cardMoneySend",
					action:"nav:cardWithdrawalConfirm"
				},
				menu:[
					{
						text:"lang.menuOrderCard",
						action:"nav:orderCard"
					}, {
						text:"lang.menuLinkCard",
						action:"nav:linkCard"
					}
				],
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			cardDetails: {
				desc:"lang.whatWant",
				item: {
					type:"showCardDetails",
					selection:"@@1"
				},
				menuLayout:"vertical",
				menu:[
					{
						text:"lang.menuCardNumberCopy",
						value:"@@1",
						action:"app:copyValue"
					}
				],
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			cardVOperationsActive: {
				desc:"lang.cardOpsDesc",
				item: {
					type:"showCard",
					selection:"@@1"
				},
				menuLayout:"vertical",
				menu:[
					{
						text:"lang.menuCardDetails",
						value:"@@1",
						action:"nav:cardDetails"
					}, {
						text:"lang.menuCardTopUp",
						keywords:"cards,top,up,money,send,withdrawal",
						textForUser:"lang.itemSendToCard",
						type:"cardMoneySend",
						value:"@@1",
						action:"nav:cardWithdrawalConfirm"
					}, {
						text:"lang.menuCardUnload",
						keywords:"cards,unload,deposit",
						textForUser:"lang.itemUnloadCard",
						type:"depositesCard",
						value:"@@1",
						action:"nav:transactionBankCardConfirm"
					}, {
						text:"lang.menuCardDisable",
						action:"nav:blockCardConfirm"
					}, {
						text:"lang.menuHistory",
						action:"app:historyCard",
						selection:"@@1"
					}, {
						text:"lang.menuCardStatement",
						type:"cardStatement",
						action:"nav:cardStatementAsFileConfirmed",
						value:"@@1"
					}
				],
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			cardOperationsActive: {
				desc:"lang.cardOpsDesc",
				item: {
					type:"showCard",
					selection:"@@1"
				},
				menuLayout:"vertical",
				menu:[
					{
						text:"lang.menuCardDetails",
						value:"@@1",
						action:"nav:cardDetails"
					}, {
						text:"lang.menuCardTopUp",
						keywords:"cards,top,up,money,send,withdrawal",
						textForUser:"lang.itemSendToCard",
						type:"cardMoneySend",
						value:"@@1",
						action:"nav:cardWithdrawalConfirm"
					}, {
						text:"lang.menuCardUnload",
						keywords:"cards,unload,deposit",
						textForUser:"lang.itemUnloadCard",
						type:"depositesCard",
						value:"@@1",
						action:"nav:transactionBankCardConfirm"
					}, {
						text:"lang.menuCardPin",
						type:"cardPin",
						value:"@@1",
						action:"payments:cardPinRequest"
					}, {
						text:"lang.menuCardDisable",
						action:"nav:blockCardConfirm"
					}, {
						text:"lang.menuHistory",
						action:"app:historyCard",
						selection:"@@1"
					}, {
						text:"lang.menuCardStatement",
						type:"cardStatement",
						action:"nav:cardStatementAsFileConfirmed",
						value:"@@1"
					}
				],
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			cardLinkedOperationsActive: {
				desc:"lang.cardOpsDesc",
				item: {
					type:"showCard",
					selection:"@@1"
				},
				menuLayout:"vertical",
				menu:[
					{
						text:"lang.menuCardTopUp",
						type:"cardMoneySend",
						value:"@@1",
						action:"nav:cardWithdrawalConfirm"
					}, {
						text:"lang.menuCardUnload",
						textForUser:"lang.itemUnloadCard",
						type:"depositesCard",
						value:"@@1",
						action:"nav:transactionBankCardConfirm"
					}, {
						text:"lang.menuCardRemove",
						action:"nav:removeCardConfirm"
					}
				],
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			cardOperationsSBlocked: {
				desc:"lang.cardOpsDesc",
				item: {
					type:"showCard",
					selection:"@@1"
				},
				menuLayout:"vertical",
				menu:[
					{
						text:"lang.menuCardEnable",
						action:"nav:unblockCardConfirm"
					}, {
						text:"lang.menuHistory",
						action:"app:historyCard",
						selection:"@@1"
					}, {
						text:"lang.menuCardStatement",
						type:"cardStatement",
						action:"nav:cardStatementAsFileConfirmed",
						value:"@@1"
					}
				],
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			cardOperationsSRBlocked: {
				desc:"lang.cardOpsDesc",
				item: {
					type:"showCard",
					selection:"@@1"
				},
				menuLayout:"vertical",
				menu:[
					{
						text:"lang.menuCardTopUp",
						type:"cardMoneySend",
						value:"@@1",
						action:"nav:cardWithdrawalConfirm"
					}, {
						text:"lang.menuCardEnable",
						action:"nav:unblockCardConfirm"
					}, {
						text:"lang.menuHistory",
						action:"app:historyCard",
						selection:"@@1"
					}, {
						text:"lang.menuCardStatement",
						type:"cardStatement",
						action:"nav:cardStatementAsFileConfirmed",
						value:"@@1"
					}
				],
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			cardOperationsExp: {
				desc:"lang.cardOpsDesc",
				item: {
					type:"showCard",
					selection:"@@1"
				},
				menuLayout:"vertical",
				menu:[
					{
						text:"lang.menuHistory",
						action:"app:historyCard",
						selection:"@@1"
					}, {
						text:"lang.menuCardStatement",
						type:"cardStatement",
						action:"nav:cardStatementAsFileConfirmed",
						value:"@@1"
					}
				],
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			cardOperationsHBlocked: {
				desc:"lang.cardOpsDesc",
				item: {
					type:"showCard",
					selection:"@@1"
				},
				menuLayout:"vertical",
				menu:[
					{
						text:"lang.menuHistory",
						action:"app:historyCard",
						selection:"@@1"
					}
				],
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			cardOperationsNew: {
				desc:"lang.cardOpsDesc",
				item: {
					type:"showCard",
					selection:"@@1"
				},
				menuLayout:"vertical",
				menu:[
					{
						text:"lang.menuCardActivate",
						value:"@@1",
						type:"cardNewActivate",
						action:"nav:cardActivationConfirmed"
					}, {
						text:"lang.menuCardDetails",
						value:"@@1",
						action:"nav:cardDetails"
					}
				],
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			cardOperationsNewTracking: {
				desc:"lang.cardOpsDesc",
				item: {
					type:"showCard",
					selection:"@@1"
				},
				menuLayout:"vertical",
				menu:[
					{
						text:"lang.menuCardActivate",
						value:"@@1",
						type:"cardNewActivate",
						action:"nav:cardActivationConfirmed"
					}, {
						text:"lang.menuCardTracking",
						type:"openTracking"
					}
				],
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			cardOperationsLNew: {
				desc:"lang.cardOpsDesc",
				item: {
					type:"showCard",
					selection:"@@1"
				},
				menuLayout:"vertical",
				menu:[
					{
						text:"lang.menuCardVerify",
						value:"@@1",
						type:"cardActivate",
						action:"nav:cardVerificationConfirmed"
					}, {
						text:"lang.menuCardRemove",
						action:"nav:removeCardConfirm"
					}
				],
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			cardOperationsLExp: {
				desc:"lang.cardOpsDesc",
				item: {
					type:"showCard",
					selection:"@@1"
				},
				menuLayout:"vertical",
				menu:[
					{
						text:"lang.menuCardRemove",
						action:"nav:removeCardConfirm"
					}
				],
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			cardWithdrawalConfirm: {
				desc:"lang.confirmCardWithdrawal",
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}, {
						text:"lang.buttonConfirm",
						action:"nav:cardWithdrawalConfirmed"
					}
				]
			},
			
			otherWithdrawalConfirm: {
				isItem: true,
				back:false,
				item: {
					value:"@@1",
					command:"cmd:back:withdrawals",
					type:"otherWithdrawal"
				}
			},
			
			paymentsDepositConfirm: {
				isItem: true,
				back:false,
				item: {
					value:"@@1",
					command:"cmd:back:deposites",
					type:"paymentsDeposit"
				}
			},
			
			transactionBankCardConfirm: {
				desc:"lang.confirmCardDeposite",
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}, {
						text:"lang.buttonConfirm",
						action:"nav:dukaCardDepositeTransactionConfirmed"
					}
				]
			},
			
			unblockCardConfirm: {
				desc:"lang.confirmCardEnable",
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}, {
						text:"lang.buttonConfirm",
						action:"nav:unblockCardConfirmed"
					}
				]
			},
			
			blockCardConfirm: {
				desc:"lang.confirmCardDisable",
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}, {
						text:"lang.buttonConfirm",
						action:"nav:blockCardConfirmed"
					}
				]
			},
			
			removeCardConfirm: {
				desc:"lang.confirmCardRemove",
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}, {
						text:"lang.buttonConfirm",
						action:"nav:removeCardConfirmed"
					}
				]
			},
			
			cardWithdrawalConfirmed: {
				desc:"lang.confirmedCardWithdrawal lang.otherOperation",
				isLast: true,
				buttons: [
					{
						text:"lang.buttonYes",
						action:"nav:main"
					}, {
						text:"lang.buttonNo",
						action:"app:back"
					}
				]
			},
			
			dukaCardDepositeTransactionConfirmed: {
				desc:"lang.confirmedCardDeposite lang.otherOperation",
				isLast: true,
				buttons: [
					{
						text:"lang.buttonYes",
						action:"nav:main"
					}, {
						text:"lang.buttonNo",
						action:"app:back"
					}
				]
			},
			
			dukaCardDepositeTransactionConfirmedURL: {
				isItem: true,
				item: {
					value:"@@1",
					command:"cmd:back:deposites",
					type:"card3ds"
				}
			},
			
			unblockCardConfirmed: {
				desc:"lang.confirmedCardEnable lang.otherOperation",
				isLast: true,
				item: {
					type:"cardsRemove"
				},
				buttons: [
					{
						text:"lang.buttonYes",
						action:"nav:main"
					}, {
						text:"lang.buttonNo",
						action:"app:back"
					}
				]
			},
			
			blockCardConfirmed: {
				desc:"lang.confirmedCardDisable lang.otherOperation",
				isLast: true,
				item: {
					type:"cardsRemove"
				},
				buttons: [
					{
						text:"lang.buttonYes",
						action:"nav:main"
					}, {
						text:"lang.buttonNo",
						action:"app:back"
					}
				]
			},
			
			removeCardConfirmed: {
				desc:"lang.confirmedCardRemove lang.otherOperation",
				isLast: true,
				item: {
					type:"cardsRemove"
				},
				buttons: [
					{
						text:"lang.buttonYes",
						action:"nav:main"
					}, {
						text:"lang.buttonNo",
						action:"app:back"
					}
				]
			},
			
			cardActivationConfirmed: {
				desc:"lang.confirmedCardActivate lang.otherOperation",
				isLast: true,
				item: {
					type:"cardsRemove"
				},
				buttons: [
					{
						text:"lang.buttonYes",
						action:"nav:main"
					}, {
						text:"lang.buttonNo",
						action:"app:back"
					}
				]
			},
			
			cardVerificationConfirmed: {
				desc:"lang.confirmedCardVerify lang.otherOperation",
				isLast: true,
				item: {
					type:"cardsRemove"
				},
				buttons: [
					{
						text:"lang.buttonYes",
						action:"nav:main"
					}, {
						text:"lang.buttonNo",
						action:"app:back"
					}
				]
			},
			
	/////////////////////////////////////////////////////////////////////////////////////////////////////////
	/// <- CARDS || ACCOUNT -> //////////////////////////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////////////////////////////////////////////////////
			
			accountOperations: {
				desc:"lang.accountsDesc",
				menuLayout:"vertical",
				menu:[
					{
						text:"lang.menuShowAccounts",
						type:"showAcc",
						keywords:"accounts,show",
						value:"MCA",
						action:"nav:paymentsWallets"
					}, {
						text:"lang.menuShowAccountsSavings",
						disabled:true,
						type:"showAcc",
						keywords:"accounts,show",
						value:"SAVINGS",
						action:"nav:paymentsWallets"
					}, {
						text:"lang.menuOpenAccount",
						keywords:"accounts,new,open",
						textForUser:"lang.itemOpenAccount",
						action:"nav:selectNewWalletCurrency"
					}, {
						text:"lang.menuLoadMoney",
						keywords:"accounts,deposit",
						action:"nav:deposites"
					}, {
						text:"lang.menuWithdrawalAccount",
						keywords:"accounts,withdrawal",
						action:"nav:withdrawals"
					}, {
						text:"lang.menuMainCurrency",
						textForUser:"lang.itemSelectMainCurrency",
						keywords:"change,currency",
						type:"selectCurrency",
						action:"nav:changeCurrencyConfirm"
					}, {
						text:"lang.menuOpenEBank",
						action:"app:payments"
					}
				],
				buttons: [
					{
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			otherWithdrawalAcc: {
				desc:"lang.accountsOtherTypesDesc",
				menu:[
					{
						text:"lang.menuFromMCA",
						value:"MCA",
						type:"otherWithdrawalWire",
						action:"nav:otherWithdrawalWallets"
					}, {
						disabled: true,
						text:"lang.menuFromSaving",
						value:"SAVINGS",
						type:"otherWithdrawalWire",
						action:"nav:otherWithdrawalWallets"
					}
				],
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			selectNewWalletCurrency: {
				desc:"lang.newWalletCurrencyDesc",
				menu:[
					{
						text:"lang.menuNewAccMCA",
						value:"MCA",
						type:"walletSelectCurrency",
						action:"nav:walletConfirm"
					}, {
						disabled: true,
						text:"lang.menuNewAccSaving",
						value:"SAVINGS",
						type:"walletSelectCurrency",
						action:"nav:walletSavingsConfirm"
					}
				],
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			otherExchangeAcc: {
				desc:"lang.accountsOtherTypesDesc",
				menu:[
					{
						text:"lang.menuMCA",
						value:"MCA",
						type:"paymentsSendMy",
						action:"nav:transferConfirm"
					}, {
						disabled: true,
						text:"lang.menuSavings",
						value:"SAVINGS",
						type:"paymentsSendMy",
						action:"nav:transferConfirm"
					}
				],
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			otherWithdrawalWallets: {
				desc:"lang.accountsSelectDesc",
				item: {
					type:"walletSelectWithoutTotal",
					value:"@@1",
					action:"nav:otherWithdrawalConfirm"
				},
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			paymentsWallets: {
				desc:"lang.accountsSelectDesc",
				item: {
					text:"lang.itemShowAccountOps",
					type:"walletSelect",
					value:"@@1",
					action:"nav:walletOperations"
				},
				menu:[
					{
						text:"lang.menuAccountsAll",
						action:"nav:paymentsWalletsAll"
					}
				],
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			paymentsWalletsAll: {
				desc:"lang.accountsSelectDesc",
				item: {
					text:"lang.itemShowAccountOps",
					type:"walletSelectAll",
					value:"@@1",
					action:"nav:walletOperations"
				},
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			walletOperations: {
				desc:"lang.walletOpsDesc",
				item: {
					type:"showWallet",
					selection:"@@1"
				},
				menuLayout:"vertical",
				menu:[
					{
						text:"lang.menuHistory",
						action:"app:historyWallet",
						selection:"@@1"
					}, {
						text:"lang.menuAccountStatement",
						type:"walletStatement",
						action:"nav:walletStatementAsFileConfirmed",
						value:"@@1"
					}, {
						text:"lang.menuIBANCopy",
						action:"app:copyIBAN"
					}
				],
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			walletConfirm: {
				desc:"lang.confirmAccountOpen",
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}, {
						text:"lang.buttonConfirm",
						action:"nav:walletConfirmed"
					}
				]
			},
			
			walletSavingsConfirm: {
				desc:"lang.confirmAccountOpen",
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}, {
						text:"lang.buttonConfirm",
						action:"nav:walletSavingsConfirmed"
					}
				]
			},
			
			changeCurrencyConfirm: {
				desc:"lang.confirmChangeCurrency",
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}, {
						text:"lang.buttonConfirm",
						action:"nav:changeCurrencyConfirmed"
					}
				]
			},
			
	/////////////////////////////////////////////////////////////////////////////////////////////////////////
	/// <- ACCOUNT || SEND MONEY -> /////////////////////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////////////////////////////////////////////////////
			
			withdrawals: {
				desc:"lang.withdrawalsDesc",
				menuLayout:"vertical",
				menu:[
					{
						text:"lang.menuToCard",
						action:"nav:cardWithdrawal"
					}, {
						text:"Skrill",
						value:"SKRILL",
						type:"otherWithdrawal",
						action:"nav:otherWithdrawalWallets"
					}, {
						text:"Neteller",
						value:"NETELLER",
						type:"otherWithdrawal",
						action:"nav:otherWithdrawalWallets"
					}, {
						text:"lang.menuBankTransfer",
						type:"otherWithdrawal",
						action:"nav:otherWithdrawalAcc"
					}, {
						disabled: true,
						text:"lang.menuToSavingAcc",
						type:"sendMoneyOtherAcc",
						value:"SAVINGS",
						action:"nav:transferInternalConfirm"
					}, {
						disabled: true,
						text:"lang.menuToTradingAcc",
						type:"sendMoneyOtherAcc",
						value:"TRADING",
						action:"nav:transferInternalConfirm"
					}
				],
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					},
					{
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			deposites: {
				desc:"lang.depositsDesc",
				menuLayout:"vertical",
				menu:[
					{
						text:"lang.menuFromCard",
						action:"nav:cardUnload"
					}, {
						text:"Skrill",
						value:"SKRILL",
						type:"paymentsDeposit",
						action:"nav:paymentsDepositConfirm"
					}, {
						text:"Neteller",
						value:"NETELLER",
						type:"paymentsDeposit",
						action:"nav:paymentsDepositConfirm"
					}, {
						text:"lang.menuBankTransfer",
						value:"WIRE",
						type:"selectCurrency",
						action:"nav:paymentsDepositConfirm"
					}, {
						text:"lang.menuSendAnInvoice",
						action:"nav:invoices"
					}, {
						disabled: true,
						text:"lang.menuFromSavingAcc",
						type:"sendMoneyOtherAcc",
						value:"SMCA",
						action:"nav:transferInternalConfirm"
					}, {
						disabled: true,
						text:"lang.menuFromTradingAcc",
						type:"sendMoneyOtherAcc",
						value:"TMCA",
						action:"nav:transferInternalConfirmT"
					}, {
						disabled: true,
						text:"lang.menuFromApplePay",
						type:"paymentsDeposit",
						value:"ApplePAY",
						action:"nav:paymentsDepositConfirm"
					}
				],
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					},
					{
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			invoices: {
				desc:"lang.invoicesDesc",
				menuLayout:"vertical",
				menu:[
					{
						text:"lang.menuInvoiceToChatmate",
						keywords:"money,receive,chat",
						type:"paymentsSelectChatmate1"
					}, {
						text:"lang.menuInvoiceToThirdParty",
						type:"paymentsInvoiceThirdparty"
					}
				],
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			sendMoney: {
				desc:"lang.sendMoneyDesc",
				menuLayout:"vertical",
				menu:[
					{
						text:"lang.menuFromTransaction",
						keywords:"money,send,transaction",
						textForUser:"lang.itemClickOnTransaction",
						action:"app:transaction"
					}, {
						text:"lang.menuFromTemplate",
						disabled:true,
						textForUser1:"lang.itemSendMoney",
						textForUser2:"lang.itemSendMoneyPhone",
						type:"paymentsSelectTemplate",
						action:"nav:transactionConfirm"
					}, {
						text:"lang.menuToPhone",
						keywords:"money,send,phones",
						textForUser:"lang.itemSendMoneyPhone",
						type:"moneySendPhone",
						action:"nav:transactionConfirm"
					}, {
						text:"lang.menuToContact",
						keywords:"money,send,contacts",
						textForUser:"lang.itemSendMoney",
						type:"paymentsSelectContact",
						action:"nav:transactionConfirm"
					}, {
						text:"lang.menuToChatmate",
						keywords:"money,send,chat",
						type:"paymentsSelectChatmate",
						action:"nav:transactionConfirm"
					}, {
						text:"lang.menuExternalRecipient",
						action:"nav:withdrawals"
					}, {
						disabled: true,
						text:"lang.menuToSavingAcc",
						type:"sendMoneyOtherAcc",
						value:"SAVINGS",
						action:"nav:transferInternalConfirm"
					}
				],
				buttons: [
					{
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			transactionConfirm: {
				desc:"lang.confirmTransaction",
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}, {
						text:"lang.buttonConfirm",
						action:"nav:transactionConfirmed"
					}
				]
			},
			
			transactionConfirmed: {
				desc:"lang.confirmedTransaction lang.otherOperation",
				isLast: true,
				menu:[
					{
						text:"lang.menuSaveAsTemplate",
						type:"saveTemplate"
					}
				],
				buttons: [
					{
						text:"lang.buttonYes",
						action:"nav:main"
					}, {
						text:"lang.buttonNo",
						action:"app:back"
					}
				]
			},
			
	/////////////////////////////////////////////////////////////////////////////////////////////////////////
	/// <- SEND || EXCHANGE -> //////////////////////////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////////////////////////////////////////////////////
			
			repeatInvestmentPurchase: {
				desc:"lang.whatWant",
				menuLayout:"vertical",
				menu: [
					{
						text:"lang.menuRepeatTransaction",
						type:"paymentsInvestmentsTransaction",
						textForUser1:"lang.itemInvestmentBuy1",
						textForUser2:"lang.itemInvestmentBuy2",
						action:"nav:investmentTransactionConfirm"
					}, {
						text:"lang.menuInvestments",
						action:"nav:investmentsBack"
					}, {
						text:"lang.menuOperationDetails",
						action:"nav:operationDetails"
					}, {
						text:"lang.menuTransactions",
						action:"nav:operationTransactions"
					}, {
						text:"lang.menuInviteConsultant",
						action:"app:support"
					}
				],
				buttons: [
					{
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			repeatInvestmentSale: {
				desc:"lang.whatWant",
				menuLayout:"vertical",
				menu: [
					{
						text:"lang.menuRepeatTransaction",
						type:"paymentsInvestmentsSell",
						textForUser1:"lang.itemInvestmentSell1",
						textForUser2:"lang.itemInvestmentSell2",
						action:"nav:investmentTransactionConfirm"
					}, {
						text:"lang.menuInvestments",
						action:"nav:investmentsBack"
					}, {
						text:"lang.menuOperationDetails",
						action:"nav:operationDetails"
					}, {
						text:"lang.menuTransactions",
						action:"nav:operationTransactions"
					}, {
						text:"lang.menuInviteConsultant",
						action:"app:support"
					}
				],
				buttons: [
					{
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			repeatExchange: {
				desc:"lang.whatWant",
				menuLayout:"vertical",
				menu: [
					{
						text:"lang.menuRepeatExchange",
						textForUser:"lang.itemExchange",
						type:"paymentsSendMy",
						action:"nav:transferConfirm"
					}, {
						text:"lang.menuOperationDetails",
						action:"nav:operationDetails"
					}, {
						text:"lang.menuTransactions",
						action:"nav:operationTransactions"
					}, {
						text:"lang.menuInviteConsultant",
						action:"app:support"
					}
				],
				buttons: [
					{
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			repeatCardDeposit: {
				desc:"lang.whatWant",
				menuLayout:"vertical",
				menu: [
					{
						text:"lang.menuRepeatDeposit",
						textForUser:"lang.itemUnloadCard",
						type:"depositesCard",
						action:"nav:transactionBankCardConfirm"
					}, {
						text:"lang.menuOperationDetails",
						action:"nav:operationDetails"
					}, {
						text:"lang.menuTransactions",
						action:"nav:operationTransactions"
					}, {
						text:"lang.menuInviteConsultant",
						action:"app:support"
					}
				],
				buttons: [
					{
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			repeatCardWithdrawal: {
				desc:"lang.whatWant",
				menuLayout:"vertical",
				menu: [
					{
						text:"lang.menuRepeatWithdrawal",
						type:"cardMoneySend",
						action:"nav:cardWithdrawalConfirm"
					}, {
						text:"lang.menuOperationDetails",
						action:"nav:operationDetails"
					}, {
						text:"lang.menuTransactions",
						action:"nav:operationTransactions"
					}, {
						text:"lang.menuInviteConsultant",
						action:"app:support"
					}
				],
				buttons: [
					{
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			repeatSendMoneyPhone: {
				desc:"lang.whatWant",
				menuLayout:"vertical",
				menu: [
					{
						text:"lang.menuRepeatTransaction",
						textForUser:"lang.itemSendMoneyPhone",
						type:"moneySendPhone",
						action:"nav:transactionConfirm"
					}, {
						text:"lang.menuOperationDetails",
						action:"nav:operationDetails"
					}, {
						text:"lang.menuTransactions",
						action:"nav:operationTransactions"
					}, {
						text:"lang.menuInviteConsultant",
						action:"app:support"
					}
				],
				buttons: [
					{
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			repeatSendMoneyPhoneCode: {
				desc:"lang.whatWant",
				menuLayout:"vertical",
				menu: [
					{
						text:"lang.menuRepeatTransaction",
						textForUser:"lang.itemSendMoneyPhone",
						type:"moneySendPhone",
						action:"nav:transactionConfirm"
					}, {
						text:"lang.menuEnterTransactionCode",
						type:"enterTransactionCode",
						action:"nav:transactionCodeConfirm"
					}, {
						text:"lang.menuOperationDetails",
						action:"nav:operationDetails"
					}, {
						text:"lang.menuTransactions",
						action:"nav:operationTransactions"
					}, {
						text:"lang.menuInviteConsultant",
						action:"app:support"
					}
				],
				buttons: [
					{
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			transactionCodeFailed: {
				desc:"lang.transactionCodeFailed",
				menuLayout:"vertical",
				menu: [
					{
						text:"lang.menuEnterTransactionCode",
						type:"enterTransactionCode",
						action:"nav:transactionCodeConfirm"
					}
				],
				buttons: [
					{
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			transactionCodeCompleted: {
				desc:"lang.transactionCodeCompleted lang.otherOperation",
				isLast: true,
				buttons: [
					{ 
						text:"lang.buttonYes",
						action:"nav:main"
					}, {
						text:"lang.buttonNo",
						action:"app:back"
					}
				]
			},
			
			transferConfirm: {
				desc:"lang.confirmExchange",
				buttons: [
					{
						text:"lang.buttonCancel",
						action:"system:cancel"
					}, {
						text:"lang.buttonConfirm",
						action:"nav:transferConfirmed"
					}
				]
			},
			
			transferInternalConfirm: {
				desc:"lang.confirmInternalTransfer",
				buttons: [
					{
						text:"lang.buttonCancel",
						action:"system:cancel"
					}, {
						text:"lang.buttonConfirm",
						action:"nav:transferInternalConfirmed"
					}
				]
			},
			
			transferInternalConfirmT: {
				desc:"lang.confirmInternalTransferT",
				buttons: [
					{
						text:"lang.buttonCancel",
						action:"system:cancel"
					}, {
						text:"lang.buttonConfirm",
						action:"nav:transferInternalConfirmed"
					}
				]
			},
			
			transferConfirmed: {
				desc:"lang.confirmedExchange lang.otherOperation",
				isLast: true,
				buttons: [
					{
						text:"lang.buttonYes",
						action:"nav:main"
					}, {
						text:"lang.buttonNo",
						action:"app:back"
					}
				]
			},
			
			transferInternalConfirmed: {
				desc:"lang.confirmedExchange lang.otherOperation",
				isLast: true,
				buttons: [
					{
						text:"lang.buttonYes",
						action:"nav:main"
					}, {
						text:"lang.buttonNo",
						action:"app:back"
					}
				]
			},
			
			notExistWalletConfirm: {
				desc:"lang.itemOpenAccountAuto lang.confirmExchange",
				buttons: [
					{
						text:"lang.buttonCancel",
						action:"system:cancel"
					}, {
						text:"lang.buttonConfirm",
						action:"nav:transferToNotExistWalletConfirmed"
					}
				]
			},
			
			transferToNotExistWalletConfirmed: {
				desc:"lang.confirmedExchange lang.otherOperation",
				isLast: true,
				buttons: [
					{
						text:"lang.buttonYes",
						action:"nav:main"
					}, {
						text:"lang.buttonNo",
						action:"app:back"
					}
				]
			},
			
	/////////////////////////////////////////////////////////////////////////////////////////////////////////
	/// <- EXCHANGE || INVEST -> ////////////////////////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////////////////////////////////////////////////////
			
			cryptoOpen: {
				desc:"lang.cryptoOpenDesc",
				menuLayout:"vertical",
				buttons: [
					{
						text:"lang.buttonYes",
						action:"nav:cryptoAccountCreateConfirmed"
					}, {
						text:"lang.buttonNo",
						action:"system:cancel"
					}
				]
			},
			
			crypto: {
				desc:"lang.cryptoDesc",
				menuLayout:"vertical",
				item: {
					type:"cryptoSelect"
				},
				menu:[
					{
						text:"lang.menuCryptoBuy",
						type:"cryptoSB",
						value:"0",
						action:"nav:cryptoOperations"
					}, {
						text:"lang.menuCryptoSell",
						type:"cryptoSB",
						value:"1",
						action:"nav:cryptoOperations"
					}, {
						text:"lang.menuShowMyOffers",
						action:"nav:cryptoDealsMy"
					}, {
						text:"lang.menuShowOffers",
						action:"nav:cryptoDeals"
					},{
						text:"lang.menuCryptoTransfer",
						action:"nav:cryptoTransfer"
					}, {
						text:"lang.menuBlockchainOperations",
						action:"nav:blockchainOps"
					}, {
						text:"lang.menuRewardsDeposite",
						type:"showCryptoRDs",
						value:"ACTIVE",
						action:"nav:cryptoDeposites"
					}, {
						text:"lang.menuAccountStat",
						action:"nav:cryptoStatistics"
					}, {
						text:"lang.menuFatCatz",
						action:"nav:cryptoFatCatz"
					}, {
						text:"lang.menuVisitDukascoin",
						type:"cryptoWebsite",
						textColor:0x0000FF,
						value:"https://dukascoin.com"
					}
				],
				buttons: [
					{
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			cryptoFatCatz: {
				desc:"lang.fatCatsDesc",
				addDesc: [
					"lang.fatCatsDescNotFC",
					"lang.fatCatsDescIsFC"
				],
				menuLayout:"vertical",
				item: {
					type:"fatCatz"
				},
				menu:[
					{
						text:"lang.menuFatCatzConditionsAndStatistic",
						type:"fatCatzConditions",
						value:"@@1"
					}
				],
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			repeatCrypto: {
				desc:"lang.cryptoDesc",
				isMain:true,
				saveItem:true,
				menuLayout:"vertical",
				menu:[
					{
						text:"lang.menuCryptoBuy",
						type:"cryptoSB",
						value:"0",
						action:"nav:cryptoOperations"
					}, {
						text:"lang.menuCryptoSell",
						type:"cryptoSB",
						value:"1",
						action:"nav:cryptoOperations"
					}, {
						text:"lang.menuShowOffers",
						action:"nav:cryptoDeals"
					}, {
						text:"lang.menuOperationDetails",
						action:"nav:operationDetails"
					}, {
						text:"lang.menuTransactions",
						action:"nav:operationTransactions"
					}, {
						text:"lang.menuInviteConsultant",
						action:"app:support"
					}
				],
				buttons: [
					{
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			operationTransactions: {
				desc:"lang.operationTransactionsDesc",
				menuLayout:"vertical",
				item: {
					type:"operationTransactions"
				},
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			cryptoDeposites: {
				desc:"lang.rewardsDepositesDesc",
				menuLayout:"vertical",
				item: {
					type:"cryptoRewardsDeposites",
					action:"nav:cryptoRDActions",
					value:"@@1",
					text:"lang.itemRewardDepositOperations"
				},
				menu:[
					{
						text:"lang.menuRDCreateNew",
						textForUser:"lang.itemBCDeposite",
						type:"cryptoRewardDeposite",
						action:"nav:cryptoRewardsDepositeConfirm"
					}, {
						text:"lang.menuRDReadConditions",
						action:"nav:cryptoRewardsTerms"
					}, {
						text:"lang.menuRDActive",
						type:"showCryptoRDs",
						value:"ACTIVE",
						action:"nav:cryptoDeposites"
					}, {
						text:"lang.menuRDCancelled",
						type:"showCryptoRDs",
						value:"CANCELLED",
						action:"nav:cryptoDeposites"
					}, {
						text:"lang.menuRDClosed",
						type:"showCryptoRDs",
						value:"CLOSED",
						action:"nav:cryptoDeposites"
					}
				],
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			cryptoRewardsTerms: {
				desc:"lang.rewardsDepositesConditionsDesc",
				menu:[
					{
						text:"lang.menuRDCoinConditions",
						value:"https://www.dukascoin.com/?cat=wp&page=06",
						type:"cryptoRDCoinTerms"
					}, {
						text:"lang.menuRDFiatConditions",
						value:"https://www.dukascoin.com/?cat=wp&page=16",
						type:"cryptoRDFiatTerms"
					}
				],
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			cryptoStatistics: {
				desc:"lang.cryptoStatDesc",
				menu:[
					{
						text:"lang.menuCoinTradesStat",
						action:"nav:cryptoStatisticsPeriods"
					}, {
						text:"lang.menuActiveOrdersStat",
						type:"coinTradeStat",
						value:"ACTIVE_ORDERS",
						action:"nav:cryptoTradeStat"
					}, {
						text:"lang.menuAccountHistory",
						type:"cryptoHistory"
					}
				],
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			cryptoStatisticsPeriods: {
				desc:"lang.cryptoStatPeriodsDesc",
				menu:[
					{
						text:"lang.menuTradesStatTotal",
						type:"coinTradeStat",
						value:"TOTAL",
						action:"nav:cryptoTradeStat"
					}, {
						text:"lang.menuTradesStatCurrentMonth",
						type:"coinTradeStat",
						value:"CURRENT_MONTH",
						action:"nav:cryptoTradeStat"
					}, {
						text:"lang.menuTradesStatPreviousMonth",
						type:"coinTradeStat",
						value:"PREVIOUS_MONTH",
						action:"nav:cryptoTradeStat"
					}, {
						text:"lang.menuTradesStatCurrentWeek",
						type:"coinTradeStat",
						value:"CURRENT_WEEK",
						action:"nav:cryptoTradeStat"
					}, {
						text:"lang.menuTradesStatPreviousWeek",
						type:"coinTradeStat",
						value:"PREVIOUS_WEEK",
						action:"nav:cryptoTradeStat"
					}, {
						text:"lang.menuTradesStatCurrentDay",
						type:"coinTradeStat",
						value:"CURRENT_DAY",
						action:"nav:cryptoTradeStat"
					}, {
						text:"lang.menuTradesStatPreviousDay",
						type:"coinTradeStat",
						value:"PREVIOUS_DAY",
						action:"nav:cryptoTradeStat"
					}, 
				],
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			cryptoTradeStat: {
				desc:"lang.cryptoTradesStatDesc",
				item: {
					type:"showTradeStat",
					value:"@@1"
				},
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			cryptoRDActions: {
				desc:"lang.cryptoRDActionsDesc",
				item: {
					type:"showRD",
					selection:"@@1"
				},
				menu:[
					{
						text:"lang.menuCancelRDWithPenalty",
						action:"nav:cryptoRDCancelConfirm"
					}
				],
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			cryptoRDActionsNothing: {
				desc:"lang.cryptoRDActionsDesc",
				item: {
					type:"showRD",
					selection:"@@1"
				},
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			cryptoRDActionsB: {
				desc:"lang.cryptoRDActionsDesc",
				item: {
					type:"showRD",
					selection:"@@1"
				},
				menu:[
					{
						text:"lang.menuCancelRDWithPenalty",
						action:"nav:cryptoRDCancelConfirm"
					}, {
						text:"lang.menuCheckAddressETH",
						type:"BCCheckETH"
					}
				],
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			cryptoRDActionsBC: {
				desc:"lang.cryptoRDActionsDesc",
				item: {
					type:"showRD",
					selection:"@@1"
				},
				menu:[
					{
						text:"lang.menuCheckAddressETH",
						type:"BCCheckETH"
					}
				],
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			cryptoRDCancelConfirm: {
				desc:"lang.confirmRDCancelWithPenaltyDesc",
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}, {
						text:"lang.buttonConfirm",
						action:"nav:cancelRDConfirmed"
					}
				]
			},
			
			cryptoRDCancelConfirmNonPen: {
				desc:"lang.confirmRDCancelWithoutPenaltyDesc",
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}, {
						text:"lang.buttonConfirm",
						action:"nav:cancelRDConfirmed"
					}
				]
			},
			
			cancelRDConfirmed: {
				desc:"lang.confirmedCryptoRDCancel lang.otherOperation",
				isLast: true,
				buttons: [
					{
						text:"lang.buttonYes",
						action:"nav:main"
					}, {
						text:"lang.buttonNo",
						action:"app:back"
					}
				]
			},
			
			cryptoRewardsDepositeTypes: {
				desc:"lang.selectRewardDesc",
				menuLayout:"vertical",
				menu:[
					{
						text:"lang.menuRDCoin",
						textForUser:"lang.itemBCDeposite",
						type:"cryptoRewardDeposite",
						value:"0",
						action:"nav:cryptoRewardsDepositeConfirm"
					}, {
						text:"lang.menuRDFiat",
						textForUser:"lang.itemBCDeposite",
						type:"cryptoRewardDeposite",
						value:"1",
						action:"nav:cryptoRewardsDepositeConfirm"
					}
				],
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			cryptoTransfer: {
				desc:"lang.sendMoneyDesc",
				menuLayout:"vertical",
				menu:[
					{
						text:"lang.menuToPhone",
						keywords:"money,send,phones",
						textForUser:"lang.itemSendMoneyPhone",
						type:"cryptoSendPhone",
						action:"nav:transactionConfirm"
					}, {
						text:"lang.menuToContact",
						keywords:"money,send,contacts",
						textForUser1:"lang.itemSendMoney",
						textForUser2:"lang.itemSendMoneyPhone",
						type:"cryptoSelectContact",
						action:"nav:transactionConfirm"
					}
				],
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			blockchainOps: {
				desc:"lang.blockchainOperationsDesc",
				menuLayout:"vertical",
				menu:[
					{
						text:"lang.menuCryptoWithdrawal",
						action:"nav:cryptoBCWithdrawal"
					}, {
						text:"lang.menuCryptoDeposit",
						action:"nav:cryptoBCDeposite"
					}, {
						text:"lang.menuRDReadConditions",
						type:"cryptoBCTerms"
					}
				],
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			cryptoBCDeposite: {
				desc:"lang.bcDepositeDesc",
				menuLayout:"vertical",
				buttons: [
					{
						text:"lang.buttonOk",
						textForUser:"lang.itemBCDeposite",
						type:"BCDepositeAddress",
						action:"nav:bcDepositeConfirm"
					}, {
						text:"lang.buttonBack",
						action:"cmd:back"
					}
				]
			},
			
			cryptoBCWithdrawal: {
				desc:"lang.bcWithdrawalDesc",
				menuLayout:"vertical",
				buttons: [
					{
						text:"lang.buttonOk",
						textForUser:"lang.itemBCWithdrawal",
						type:"BCWithdrawal",
						action:"nav:bcWithdrawalConfirm"
					}, {
						text:"lang.buttonBack",
						action:"cmd:back"
					}
				]
			},
			
			bcDepositeConfirm: {
				desc:"lang.confirmBCDeposite",
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}, {
						text:"lang.buttonConfirm",
						action:"nav:bcDepositeAddressConfirmed"
					}
				]
			},
			
			bcWithdrawalConfirm: {
				desc:"lang.confirmBCWithdrawal",
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}, {
						text:"lang.buttonConfirm",
						action:"nav:bcWithdrawalConfirmed"
					}
				]
			},
			
			bcDeliveryConfirm: {
				desc:"lang.confirmBCWithdrawal",
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}, {
						text:"lang.buttonConfirm",
						action:"nav:bcDeliveryConfirmed"
					}
				]
			},
			
			bcDepositeAddressConfirmed: {
				desc:"lang.confirmedBCAddressDeposite",
				buttons: [
					{
						text:"lang.buttonCopyAddress",
						type:"BCDepositeCopyAddress",
						value:"@@1"
					}, {
						text:"lang.buttonOk",
						action:"system:cancel"
					}
				]
			},
			
			bcWithdrawalConfirmed: {
				desc:"lang.confirmedBCWithdrawal lang.otherOperation",
				isLast:true,
				value:"@@1",
				buttons: [
					{
						text:"lang.buttonYes",
						action:"nav:main"
					}, {
						text:"lang.buttonNo",
						action:"app:back"
					}
				]
			},
			
			bcDeliveryConfirmed: {
				desc:"lang.confirmedBCDelivery lang.otherOperation",
				isLast:true,
				buttons: [
					{
						text:"lang.buttonYes",
						action:"nav:main"
					}, {
						text:"lang.buttonNo",
						action:"app:back"
					}
				]
			},
			
			bcDepositeConfirmed: {
				desc:"lang.confirmedBCDeposite lang.otherOperation",
				isLast:true,
				buttons: [
					{
						text:"lang.buttonYes",
						action:"nav:main"
					}, {
						text:"lang.buttonNo",
						action:"app:back"
					}
				]
			},
			
			cryptoDeals: {
				isItem: true,
				item: {
					value:"@@1",
					command:"cmd:back",
					type:"cryptoDeals"
				}
			},
			
			cryptoDealsMy: {
				isItem: true,
				item: {
					value:"MINE",
					command:"cmd:back",
					type:"cryptoDeals"
				}
			},
			
			cryptoOperations: {
				desc:"lang.cryptoBuySellDesc",
				menuLayout:"vertical",
				item: {
					type:"cryptoBestPrice",
					value:"@@3"
				},
				menu:[
					{
						text:"lang.createOffer",
						value:"@@3",
						type:"createCryptoOffer",
						action:"nav:createOfferConfirm"
					}, {
						text:"lang.menuMyShowOffers",
						action:"nav:myCryptoOffers"
					},
					{
						text:"lang.cryptoSellBuyMarket",
						value:"@@3",
						type:"marketPrice"
					}
				],
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			cryptoNotesOpen: {
				desc:"lang.cryptoNotesDesc",
				menuLayout:"vertical",
				menu:[
					{
						text:"lang.cryptoNotesBuy",
						type:"cryptoNotesBS",
						val:"b"
					}, {
						text:"lang.cryptoNotesSell",
						type:"cryptoNotesBS",
						val:"s"
					}
				],
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			myCryptoOffers: {
				desc:"lang.myCryptoOffersDesc",
				menuLayout:"vertical",
				item: {
					text:"lang.itemShowCryptoOfferOperations",
					type:"cryptoOfferSelect",
					value:"@@2",
					action:"nav:offerOperations"
				},
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			myAllCryptoOffers: {
				desc:"lang.myAllCryptoOffersDesc",
				menuLayout:"vertical",
				item: {
					text:"lang.itemShowCryptoOfferOperations",
					type:"cryptoOfferSelect",
					action:"nav:offerOperations"
				},
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			offerOperationsActive: {
				desc:"lang.cryptoOfferOperationsDesc",
				menuLayout:"vertical",
				item: {
					type:"cryptoOfferShow",
					value:"@@1"
				},
				menu:[
					{
						text:"lang.menuCryptoOfferRemove",
						action:"nav:deleteOfferConfirm"
					}
				],
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			offerOperationsInactive: {
				desc:"lang.cryptoOfferOperationsDesc",
				menuLayout:"vertical",
				item: {
					type:"cryptoOfferShow",
					value:"@@1"
				},
				menu:[{
						text:"lang.menuCryptoOfferRemove",
						action:"nav:deleteOfferConfirm"
					}
				],
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			cryptoRewardsDepositeConfirm: {
				desc:"lang.confirmBCRewardDeposite",
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}, {
						text:"lang.buttonConfirm",
						action:"nav:cryptoRewardDepositeConfirmed"
					}
				]
			},
			
			cryptoRewardsDepositeConfirmNonPen: {
				desc:"lang.confirmBCRewardDepositeNonPen",
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}, {
						text:"lang.buttonConfirm",
						action:"nav:cryptoRewardDepositeConfirmed"
					}
				]
			},
			
			createOfferConfirm: {
				desc:"lang.confirmCreateOffer",
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}, {
						text:"lang.buttonConfirm",
						action:"nav:createOfferConfirmed"
					}
				]
			},
			
			cryptoRewardDepositeConfirmed: {
				desc:"lang.confirmedRewardDeposite lang.otherOperation",
				isLast:true,
				buttons: [
					{
						text:"lang.buttonYes",
						action:"nav:main"
					}, {
						text:"lang.buttonNo",
						action:"app:back"
					}
				]
			},
			
			createOfferConfirmed: {
				desc:"lang.confirmedCreateOffer lang.otherOperation",
				buttons: [
					{
						text:"lang.buttonYes",
						action:"cmd:back:cryptoOperations"
					}, {
						text:"lang.buttonNo",
						action:"app:back"
					}
				]
			},
			
			activateOfferConfirm: {
				desc:"lang.confirmOfferActivate",
				back:false,
				buttons: [
					{
						text:"lang.buttonYes",
						action:"nav:activateOfferConfirmed"
					}, {
						text:"lang.buttonNo",
						action:"cmd:back"
					}
				]
			},
			
			deleteOfferConfirm: {
				desc:"lang.confirmOfferDelete",
				buttons: [
					{
						text:"lang.buttonYes",
						action:"nav:deleteOfferConfirmed"
					}, {
						text:"lang.buttonNo",
						action:"cmd:back"
					}
				]
			},
			
			deactivateOfferConfirm: {
				desc:"lang.confirmOfferDeactivate",
				buttons: [
					{
						text:"lang.buttonYes",
						action:"nav:deactivateOfferConfirmed"
					}, {
						text:"lang.buttonNo",
						action:"cmd:back"
					}
				]
			},
			
			deactivateOfferConfirmed: {
				desc:"lang.confirmedDeactivateOffer lang.otherOperation",
				isLast: true,
				buttons: [
					{
						text:"lang.buttonYes",
						action:"nav:main"
					}, {
						text:"lang.buttonNo",
						action:"app:back"
					}
				]
			},
			
			activateOfferConfirmed: {
				desc:"lang.confirmedActivateOffer lang.otherOperation",
				isLast: true,
				buttons: [
					{
						text:"lang.buttonYes",
						action:"nav:main"
					}, {
						text:"lang.buttonNo",
						action:"app:back"
					}
				]
			},
			
			deleteOfferConfirmed: {
				desc:"lang.confirmedDeleteOffer lang.otherOperation",
				buttons: [
					{
						text:"lang.buttonYes",
						action:"cmd:back:myCryptoOffers"
					}, {
						text:"lang.buttonNo",
						action:"app:back"
					}
				]
			},
			
			cryptoOffers: {
				desc:"lang.cryptoOffersDesc",
				menuLayout:"vertical",
				menu:[
					{
						text:"lang.menuByBestPrice",
						action:"nav:notReadyYet"
					}, {
						text:"lang.menuByVolume",
						action:"nav:notReadyYet"
					}, {
						text:"lang.menuByFilter",
						action:"nav:notReadyYet"
					}
				],
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			investments: {
				desc:"lang.investmentsDesc",
				menuLayout:"vertical",
				item: {
					type:"investments"
				},
				menu:[
					{
						text:"lang.menuInvestmentBuy",
						action:"nav:investMoney"
					}, {
						text:"lang.menuInvestmentSell",
						action:"nav:investmentsListSell"
					}, {
						text:"lang.menuInvestmentPortfolio",
						action:"nav:investmentsList"
					}, {
						text:"lang.menuInvestmentCurrency",
						action:"nav:investmentDisclaimer"
					}
				],
				buttons: [
					{
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			investmentsBack: {
				desc:"lang.investmentsDesc",
				menuLayout:"vertical",
				menu:[
					{
						text:"lang.menuInvestmentBuy",
						action:"nav:investMoney"
					}, {
						text:"lang.menuInvestmentSell",
						action:"nav:investmentsListSell"
					}, {
						text:"lang.menuInvestmentPortfolio",
						action:"nav:investmentsList"
					}
				],
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			investmentsList: {
				desc:"lang.investmentsListDesc",
				item: {
					type:"investmentSelect",
					action:"nav:investmentOperations"
				},
				menu:[
					{
						text:"lang.menuInvestmentPortfolioAll",
						action:"nav:investmentsListAll"
					}
				],
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			investmentsListAll: {
				desc:"lang.investmentsListDesc",
				item: {
					type:"investmentSelectAll",
					action:"nav:investmentOperations"
				},
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			investmentsListSell: {
				desc:"lang.investmentsSellDesc",
				item: {		
					textForUser1:"lang.itemInvestmentSell1",
					textForUser2:"lang.itemInvestmentSell2",
					type:"paymentsInvestmentsSell",		
					action:"nav:investmentSellConfirm"
				},
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			investmentOperations: {
				desc:"lang.investmentDesc",
				item: {
					type:"showInvestment",
					selection:"@@1"
				},
				menuLayout:"vertical",
				menu:[
					{
						text:"lang.menuInvestmentDetails",
						action:"nav:investmentDetails",
						selection:"@@1"
					}, {
						text:"lang.menuHistory",
						action:"app:historyInvestment",
						selection:"@@2"
					}, {
						text:"lang.menuInvestmentBuy",
						type:"paymentsInvestments",
						textForUser1:"lang.itemInvestmentBuy1",
						textForUser2:"lang.itemInvestmentBuy2",
						action:"nav:investmentConfirm",
						value:"@@2"
					}, {
						text:"lang.menuInvestmentSellAll",
						action:"nav:investmentSellAllConfirm",
						type:"paymentsInvestmentsSellAll",
						textForUser1:"lang.itemInvestmentSell1",
						selection:"@@1"
					}, {
						text:"lang.menuInvestmentDeliveryBC",
						type:"BCWithdrawalInvestment",
						action:"nav:bcDeliveryConfirm",
						textForUser:"lang.itemInvestmentDeliveryBC",
						selection:"@@2",
						selectionAcc:"@@1",
						disabled:true
					}
				],
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			investmentDetails: {
				desc:"lang.itemInvestmentDetails",
				item: {
					type:"showInvestmentDetails",
					selection:"@@1"
				},
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			investMoney: {
				desc:"lang.investmentBuyDesc",
				selection:"lastSelectedCard",
				menuLayout:"vertical",
				menu:[
					{
						text:"lang.menuInvestmentIndexes",
						action:"nav:selectIndexes"
					}, {
						text:"lang.menuInvestmentShares",
						action:"nav:selectShares"
					}, {
						text:"lang.menuInvestmentCommodities",
						action:"nav:selectCommodities"
					}, {
						text:"lang.menuInvestmentCrypto",
						action:"nav:selectCrypto"
					}
				],
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			selectIndexes: {
				desc:"lang.investmentBuySelectIndexDesc",
				menuLayout:"vertical",
				menu:[
					{
						text:"USA 30 lang.investmentIndex",
						value:"USA",
						type:"paymentsInvestments",
						textForUser1:"lang.itemInvestmentBuy1",
						textForUser2:"lang.itemInvestmentBuy2",
						action:"nav:investmentConfirm"
					}, {
						text:"Swiss 20 lang.investmentIndex",
						value:"CHE",
						type:"paymentsInvestments",
						textForUser1:"lang.itemInvestmentBuy1",
						textForUser2:"lang.itemInvestmentBuy2",
						action:"nav:investmentConfirm"
					}, {
						text:"UK 100 lang.investmentIndex",
						value:"GBR",
						type:"paymentsInvestments",
						textForUser1:"lang.itemInvestmentBuy1",
						textForUser2:"lang.itemInvestmentBuy2",
						action:"nav:investmentConfirm"
					}, {
						text:"France 40 lang.investmentIndex",
						value:"FRA",
						type:"paymentsInvestments",
						textForUser1:"lang.itemInvestmentBuy1",
						textForUser2:"lang.itemInvestmentBuy2",
						action:"nav:investmentConfirm"
					}, {
						text:"Germany 30 lang.investmentIndex",
						value:"DEU",
						type:"paymentsInvestments",
						textForUser1:"lang.itemInvestmentBuy1",
						textForUser2:"lang.itemInvestmentBuy2",
						action:"nav:investmentConfirm"
					}, {
						text:"Japan 225 lang.investmentIndex",
						value:"JPN",
						type:"paymentsInvestments",
						textForUser1:"lang.itemInvestmentBuy1",
						textForUser2:"lang.itemInvestmentBuy2",
						action:"nav:investmentConfirm"
					}
				],
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			selectShares: {
				desc:"lang.investmentBuySelectSharesDesc",
				menuLayout:"vertical",
				menu:[
					{
						text:"Amazon",
						value:"AMZ",
						type:"paymentsInvestments",
						textForUser1:"lang.itemInvestmentBuy1",
						textForUser2:"lang.itemInvestmentBuy2",
						action:"nav:investmentConfirm"
					}, {
						text:"Facebook (Class A)",
						value:"FBU",
						type:"paymentsInvestments",
						textForUser1:"lang.itemInvestmentBuy1",
						textForUser2:"lang.itemInvestmentBuy2",
						action:"nav:investmentConfirm"
					},/* {
						text:"Microsoft",
						value:"MSF",
						type:"paymentsInvestments",
						textForUser1:"lang.itemInvestmentBuy1",
						textForUser2:"lang.itemInvestmentBuy2",
						action:"nav:investmentConfirm"
					}, */{
						text:"Alphabet (Class A)",
						value:"GOO",
						type:"paymentsInvestments",
						textForUser1:"lang.itemInvestmentBuy1",
						textForUser2:"lang.itemInvestmentBuy2",
						action:"nav:investmentConfirm"
					}, {
						text:"Netflix",
						value:"NFL",
						type:"paymentsInvestments",
						textForUser1:"lang.itemInvestmentBuy1",
						textForUser2:"lang.itemInvestmentBuy2",
						action:"nav:investmentConfirm"
					}, {
						text:"Tesla",
						value:"TSL",
						type:"paymentsInvestments",
						textForUser1:"lang.itemInvestmentBuy1",
						textForUser2:"lang.itemInvestmentBuy2",
						action:"nav:investmentConfirm"
					}, {
						text:"Apple",
						value:"AAP",
						type:"paymentsInvestments",
						textForUser1:"lang.itemInvestmentBuy1",
						textForUser2:"lang.itemInvestmentBuy2",
						action:"nav:investmentConfirm"
					}, {
						text:"Nvidia",
						value:"NVD",
						type:"paymentsInvestments",
						textForUser1:"lang.itemInvestmentBuy1",
						textForUser2:"lang.itemInvestmentBuy2",
						action:"nav:investmentConfirm"
					} 
				],
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			selectCommodities: {
				desc:"lang.investmentBuySelectCommoditiesDesc",
				menuLayout:"vertical",
				menu:[
					{
						text:"lang.investmentSilver",
						value:"XAG",
						type:"paymentsInvestments",
						textForUser1:"lang.itemInvestmentBuy1",
						textForUser2:"lang.itemInvestmentBuy2",
						action:"nav:investmentConfirm"
					}, {
						text:"lang.investmentGold",
						value:"XAU",
						type:"paymentsInvestments",
						textForUser1:"lang.itemInvestmentBuy1",
						textForUser2:"lang.itemInvestmentBuy2",
						action:"nav:investmentConfirm"
					}, {
						text:"lang.investmentNaturalGas",
						value:"GAS",
						type:"paymentsInvestments",
						textForUser1:"lang.itemInvestmentBuy1",
						textForUser2:"lang.itemInvestmentBuy2",
						action:"nav:investmentConfirm"
					}, {
						text:"lang.investmentBrentOil",
						value:"OIL",
						type:"paymentsInvestments",
						textForUser1:"lang.itemInvestmentBuy1",
						textForUser2:"lang.itemInvestmentBuy2",
						action:"nav:investmentConfirm"
					}
				],
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			selectCrypto: {
				desc:"lang.investmentBuySelectCryptoDesc",
				menuLayout:"vertical",
				menu:[
					{
						text:"lang.investmentBitcoin",
						value:"BTC",
						type:"paymentsInvestments",
						textForUser1:"lang.itemInvestmentBuy1",
						textForUser2:"lang.itemInvestmentBuy2",
						action:"nav:investmentConfirm"
					}, {
						text:"lang.investmentEthereum",
						value:"ETH",
						type:"paymentsInvestments",
						textForUser1:"lang.itemInvestmentBuy1",
						textForUser2:"lang.itemInvestmentBuy2",
						action:"nav:investmentConfirm"
					}/*, {
						text:"Litecoin",
						value:"LTC",
						type:"paymentsInvestments",
						textForUser1:"lang.itemInvestmentBuy1",
						textForUser2:"lang.itemInvestmentBuy2",
						action:"nav:investmentConfirm"
					}*/
				],
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			investmentConfirm: {
				desc:"lang.confirmInvestment",
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}, {
						text:"lang.buttonConfirm",
						action:"nav:investmentConfirmed"
					}
				]
			},
			
			investmentTransactionConfirm: {
				desc:"lang.confirmInvestment",
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}, {
						text:"lang.buttonConfirm",
						action:"nav:investmentTransactionConfirmed"
					}
				]
			},
			
			investmentSellConfirm: {
				desc:"lang.confirmInvestmentSell",
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}, {
						text:"lang.buttonConfirm",
						action:"nav:investmentSellConfirmed"
					}
				]
			},
			
			investmentSellAllConfirm: {
				desc:"lang.confirmInvestmentSellAll",
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}, {
						text:"lang.buttonConfirm",
						action:"nav:investmentSellAllConfirmed"
					}
				]
			},
			
			investmentSellConfirmed: {
				desc:"lang.confirmedInvestmentSell lang.otherOperation",
				isLast: true,
				buttons: [
					{
						text:"lang.buttonYes",
						action:"nav:main"
					}, {
						text:"lang.buttonNo",
						action:"app:back"
					}
				]
			},
			
			investmentSellAllConfirmed: {
				desc:"lang.confirmedInvestmentSellAll lang.otherOperation",
				isLast: true,
				buttons: [
					{
						text:"lang.buttonYes",
						action:"nav:main"
					}, {
						text:"lang.buttonNo",
						action:"app:back"
					}
				]
			},
			
			investmentCurrencyConfirm: {
				desc:"lang.confirmInvestmentCurrency",
				buttons: [
					{
						text:"lang.buttonNo",
						type:"selectCurrency",
						action:"nav:investmentCurrencyConfirm"
					}, {
						text:"lang.buttonConfirm",
						action:"nav:investMoneyAfterReferalCurrency"
					}
				]
			},
			
			chooseAccountToOpen: {
				desc:"lang.accountOpening",
				menuLayout:"vertical",
				menu:[
					{
						text:"lang.menuForexCFD",
						type:"selectCurrencyAccount",
						value:"0",
						action:"nav:openTradingAccountConfirm"
					}, {
						text:"lang.menuBinaryOptions",
						type:"selectCurrencyAccount",
						value:"1",
						action:"nav:openTradingAccountConfirm"
					}
				],
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			investmentDisclaimer: {
				desc:"lang.investmentDisclaimerNew",
				menuLayout:"vertical",
				menu:[
					{
						text:"lang.menuAcceptAndProceed",
						type:"selectCurrency",
						action:"nav:investmentCurrencyConfirm",
						textForUser:"lang.itemInvestmentCurrency"
					}
				],
				buttons: [
					{
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			orderCard: {
				desc:"lang.cardOrder",
				menuLayout:"vertical",
				menu:[
					{
						text:"lang.menuCardVirtual",
						keywords:"order,card,virtuals",
						action:"nav:orderCardV",
						value:"v"
					}, {
						text:"lang.menuCardPlastic",
						keywords:"order,card,plastics",
						//keywords:"money,send,contacts",
						action:"nav:orderCardP",
						value:"p"
					},
				],
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			transactionOut: {
				desc:"lang.whatWant",
				menu: [
					{
						text:"lang.menuRecipientProfile",
						action:"app:profile"
					}, {
						text:"lang.menuRepeatTransaction",
						textForUser:"lang.itemSendMoney",
						type:"paymentsSend",
						action:"nav:transactionConfirm"
					}, {
						text:"lang.menuUserTransactions",
						action:"app:historyUser"
					}, {
						text:"lang.menuOperationDetails",
						action:"nav:operationDetails"
					}, {
						text:"lang.menuTransactions",
						action:"nav:operationTransactions"
					}, {
						text:"lang.menuInviteConsultant",
						action:"app:support"
					}
				],
				buttons: [
					{
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			transactionOutNoUser: {
				desc:"lang.whatWant",
				menuLayout:"vertical",
				menu: [
					{
						text:"lang.menuOperationDetails",
						action:"nav:operationDetails"
					}, {
						text:"lang.menuTransactions",
						action:"nav:operationTransactions"
					}, {
						text:"lang.menuInviteConsultant",
						action:"app:support"
					}
				],
				buttons: [
					{
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			transactionInNoUser: {
				desc:"lang.whatWant",
				menu: [
					{
						text:"lang.menuOperationDetails",
						action:"nav:operationDetails"
					}, {
						text:"lang.menuTransactions",
						action:"nav:operationTransactions"
					}, {
						text:"lang.menuInviteConsultant",
						action:"app:support"
					}
				],
				buttons: [
					{
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			transactionIn: {
				desc:"lang.whatWant",
				menu: [
					{
						text:"lang.menuSenderProfile",
						action:"app:profile"
					}, {
						text:"lang.menuSendMoney",
						textForUser:"lang.itemSendMoney",
						type:"paymentsSend",
						action:"nav:transactionConfirm"
					}, {
						text:"lang.menuSendInvoice",
						textForUser:"lang.itemInvoice",
						type:"invoiceSend",
						action:"nav:invoiceConfirm"
					}, {
						text:"lang.menuOperationDetails",
						action:"nav:operationDetails"
					}, {
						text:"lang.menuTransactions",
						action:"nav:operationTransactions"
					}, {
						text:"lang.menuUserTransactions",
						action:"app:historyUser"
					}
				],
				buttons: [
					{
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			passwordEnter: {
				isItem: true,
				back:false,
				item: {
					type:"passwordEnter",
					action:"payments:pwdCheck",
					action1:"cmd:pwdForgot",
					action2:"nav:obligatoryPass",
					action3:"cmd:back",
					action4:"cmd:pwdIgnore"
				}
			},
			
			passwordForgot: {
				isItem: true,
				back:false,
				item: {
					type:"passwordForgot"
				}
			},
			
			passwordChange: {
				isItem: true,
				item: {
					type:"passwordChange",
					action:"payments:pwdChange"
				}
			},
			
			linkCard: {
				isItem: true,
				item: {
					value:"@@1",
					command:"cmd:back",
					type:"linkCard"
				}
			},
			
			clearCards: {
				isItem: true,
				back: false,
				item: {
					type:"clearCards"
				}
			},
			
			clearCrypto: {
				isItem: true,
				back: false,
				item: {
					type:"clearCrypto"
				}
			},
			
			clearCryptoAccount: {
				isItem: true,
				back: false,
				item: {
					type:"clearCryptoAccount"
				}
			},
			
			clearCryptoRD: {
				isItem: true,
				back: false,
				item: {
					type:"clearCryptoRD"
				}
			},
			
			action: {
				isItem: true,
				back: false,
				item: {
					type:"action",
					action:"@@1"
				}
			},
			
			clearWallets: {
				isItem: true,
				back: false,
				item: {
					type:"clearWallets"
				}
			},
			
			clearInvestments: {
				isItem: true,
				back: false,
				item: {
					type:"clearInvestments"
				}
			},
			
			orderCardP: {
				isItem: true,
				back: false,
				item: {
					value:"p",
					command:"cmd:last",
					type:"orderCard"
				}
			},
			
			orderCardV: {
				isItem: true,
				back: false,
				item: {
					value:"v",
					command:"cmd:last",
					type:"orderCard"
				}
			},
			
			paymentsErrorDataNull: {
				isItem: true,
				item: {
					type:"dialogShow",
					text:"lang.errorWrongData"
				}
			},
			
			paymentsErrorNotApproved: {
				isItem: true,
				item: {
					type:"dialogShow",
					text:"lang.errorAccountNotApproved"
				}
			},
			
			paymentsErrorBlocked: {
				isItem: true,
				item: {
					type:"dialogShow",
					text:"lang.errorAccountBlocked"
				}
			},
			
			paymentsErrorPwdManyTimes: {
				isItem: true,
				item: {
					type:"dialogShow",
					text:"lang.errorPwdManyTimes"
				}
			},
			
			paymentsLimits: {
				desc:"lang.accountLimits",
				item: {
					type:"showLimits"
				},
				menu: [
					{
						text:"lang.menuIncreaseLimits",
						action:"app:limits"
					}
				],
				buttons: [
					{
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			operationDetails: {
				desc:"lang.operationDetails",
				item: {
					type:"operationDetails"
				},
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			openTradingAccountConfirm: {
				desc:"lang.confirmAccountOpening",
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}, {
						text:"lang.buttonConfirm",
						action:"nav:openTradingAccountConfirmed"
					}
				]
			},
			
			invoiceConfirm: {
				desc:"lang.confirmInvoice",
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}, {
						text:"lang.buttonConfirm",
						action:"nav:invoiceConfirmed"
					}
				]
			},
			
			actionProgress: {
				desc:"lang.actionInProgress",
				back:false
			},
			
			obligatoryPass: {
				desc:"lang.obligatoryPass",
				back:false,
				menu: [
					{
						text:"lang.menuEnterPwd",
						action:"nav:needPwdCheck"
					}
				],
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:last"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			pinCodeCompleted: {
				desc:"lang.confirmedPinRequest lang.otherOperation",
				isLast: true,
				buttons: [
					{
						text:"lang.buttonYes",
						action:"nav:main"
					}, {
						text:"lang.buttonNo",
						action:"app:back"
					}
				]
			},
			
			openTradingAccountConfirmed: {
				desc:"lang.confirmedTradingAccountOpen lang.otherOperation",
				isLast: true,
				buttons: [
					{
						text:"lang.buttonYes",
						action:"nav:main"
					}, {
						text:"lang.buttonNo",
						action:"app:back"
					}
				]
			},
			
			investmentCurrencyConfirmed: {
				desc:"lang.confirmedInvestmentCurrency",
				isLast: true,
				buttons: [
					{
						text:"lang.menuInvestmentBuy",
						action:"nav:investMoney"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			otherOperation: {
				desc:"lang.otherOperation",
				isLast: true,
				buttons: [
					{ 
						text:"lang.buttonYes",
						action:"nav:main"
					}, {
						text:"lang.buttonNo",
						action:"app:back"
					}
				]
			},
			
			investmentConfirmed: {
				desc:"lang.confirmedInvestmentBuy lang.otherOperation",
				isLast: true,
				buttons: [
					{ 
						text:"lang.buttonYes",
						action:"nav:main"
					}, {
						text:"lang.buttonNo",
						action:"app:back"
					}
				]
			},
			
			investmentTransactionConfirmed: {
				desc:"lang.confirmedInvestmentBuy lang.otherOperation",
				isLast: true,
				buttons: [
					{
						text:"lang.buttonYes",
						action:"nav:main"
					}, {
						text:"lang.buttonNo",
						action:"app:back"
					}
				]
			},
			
			walletConfirmed: {
				desc:"lang.confirmedAccountOpening lang.otherOperation",
				isLast: true,
				buttons: [
					{
						text:"lang.buttonYes",
						action:"nav:main"
					}, {
						text:"lang.buttonNo",
						action:"app:back"
					}
				]
			},
			
			walletSavingsConfirmed: {
				desc:"lang.confirmedAccountOpening lang.otherOperation",
				isLast: true,
				buttons: [
					{
						text:"lang.buttonYes",
						action:"nav:main"
					}, {
						text:"lang.buttonNo",
						action:"app:back"
					}
				]
			},
			
			changeCurrencyConfirmed: {
				desc:"lang.confirmedChangeCurrency lang.otherOperation",
				isLast: true,
				buttons: [
					{
						text:"lang.buttonYes",
						action:"nav:main"
					}, {
						text:"lang.buttonNo",
						action:"app:back"
					}
				]
			},
			
			invoiceConfirmed: {
				desc:"lang.confirmedInvoice lang.otherOperation",
				isLast: true,
				buttons: [
					{
						text:"lang.buttonYes",
						action:"nav:main"
					}, {
						text:"lang.buttonNo",
						action:"app:back"
					}
				]
			},
			
			whatElse: {
				desc:"lang.otherOperation",
				buttons: [
					{
						text:"lang.buttonYes",
						action:"nav:main"
					}, {
						text:"lang.buttonNo",
						action:"app:back"
					}
				]
			},
			
			payError: {
				desc:"@@1",
				isError: true,
				isItem: true,
				item: {
					value:"@@2",
					type:"error"
				},
				buttons: [
					{
						text:"lang.buttonOk",
						action:"nav:main"
					}
				]
			},
			
			rdErrorNotEnoughMoney: {
				desc:"@@1",
				isError: true,
				isItem: true,
				item: {
					type:"error"
				},
				menu: [
					{
						text:"lang.menuCryptoWithdrawal",
						action:"nav:cryptoBCWithdrawal"
					}
				],
				buttons: [
					{
						text:"lang.buttonOk",
						action:"nav:main"
					}
				]
			},
			
			notReadyYet: {
				desc:"lang.notReadyYet",
				buttons: [
					{
						text:"lang.buttonBack",
						action:"cmd:back"
					}, {
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			},
			
			cryptoNotAvailabe: {
				desc:"lang.cyptoNotAvailableDesc",
				buttons: [
					{
						text:"lang.buttonOk",
						action:"nav:main"
					}
				]
			},
			
			search: {
				desc:"lang.pleaseChoose",
				back: false,
				menu: "@@1",
				buttons: [
					{
						text:"lang.buttonCancel",
						action:"system:cancel"
					}
				]
			}
		}
	}
}

// to those whom you already pay and received
/* Те, с кем были фин. отношения (платил или получал)
		часто используемые / фавориты
		редко используемые
		Вашему chat mate
		на карты (список транзакций на карты)
		external recepiens
 * Tе, с кем не было фин. отношений (не платил, не получал)
		конткаты
		chat mate
		by phone number
		external transaction
		на карту
 * */