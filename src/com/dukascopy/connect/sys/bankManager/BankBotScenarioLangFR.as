package com.dukascopy.connect.sys.bankManager {
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class BankBotScenarioLangFR {
		
		// OTHER
		static public const otherOperation:String = "Voulez-vous faire une autre opération?";
		static public const actionInProgress:String = "Action en cours…";
		static public const notReadyYet:String = "Cette fonctionnalité est en cours de développement.";
		static public const obligatoryPass:String = "Confirmez l'opération avec votre mot de passe.";
		static public const whatWant:String = "Qu'aimeriez-vous faire?";
		static public const pleaseChoose:String = "Choisissez s'il vous plaît.";
		
		static public const buy:String = "Achat";
		static public const sell:String = "Vendre";
		static public const buy1:String = "Achat";
		static public const sell1:String = "Vendre";
		static public const bid:String = "Offre";
		static public const ask:String = "Demnade";
		
		// BUTTONS
		static public const buttonCancel:String = "Annuler";
		static public const buttonBack:String = "Retour";
		static public const buttonConfirm:String = "Confirmer";
		static public const buttonYes:String = "Oui";
		static public const buttonNo:String = "No";
		static public const buttonOk:String = "Ok";
		static public const buttonCopyAddress:String = "Copier l'adresse";
		
		// MENU DESCRIPTIONS
		static public const mainDesc:String = "Qu'aimeriez-vous faire?";
		static public const cardsDesc:String = "Veuillez sélectionner une carte ou une autre opération.";
		static public const cardOpsDesc:String = "Sélectionnez l'opération souhaitée.";
		static public const accountsDesc:String = "Sélectionnez l'opération souhaitée.";
		static public const accountsSelectDesc:String = "Sélectionnez le compte.";
		static public const withdrawalsDesc:String = "Retraits";
		static public const depositsDesc:String = "Dépôts";
		static public const sendMoneyDesc:String = "Sélectionnez le destinataire.";
		static public const investmentsDesc:String = "Choisissez s'il vous plaît.";
		static public const investmentsListDesc:String = "Veuillez sélectionner un instrument d'investissement.";
		static public const investmentsSellDesc:String = "Veuillez sélectionner un investissement à vendre.";
		static public const investmentDesc:String = "Veuillez sélectionner l'opération d'investissement.";
		static public const investmentBuyDesc:String = "Sélectionnez les investissements à acheter.";
		static public const investmentBuySelectIndexDesc:String = "Sélectionnez l'indice.";
		static public const investmentBuySelectCommoditiesDesc:String = "Sélectionnez les matières premières.";
		static public const investmentBuySelectCryptoDesc:String = "Sélectionnez la crypto-monnaie.";
		static public const accountOpening:String = "Choisissez le type de compte à ouvrir.";
		static public const accountLimits:String = "Toutes les limites.";
		static public const cardOrder:String = "Veuillez sélectionner le type de carte.";
		static public const cryptoDesc:String = "Sélectionnez la crypto-monnaie.";
		static public const cryptoOpenDesc:String = "Vous n'avez pas encore un compte Dukascoins. Souhaitez-vous le créer maintenant?";
		static public const cryptoOffersDesc:String = "Choissez s'il vous plaît.";
		static public const cryptoBuySellDesc:String = "@@1 Dukascoins";
		static public const rewardsDepositesDesc:String = "Dépôts de récompense";
		static public const blockchainOperationsDesc:String = "Opérations de blockchain";
		static public const myCryptoOffersDesc:String = "Mes “@@1” lots conditionnels"; // @@2 (@@1)
		static public const myAllCryptoOffersDesc:String = "Mes lots conditionnels"; // @@2 (@@1)
		static public const cryptoOfferOperationsDesc:String = "Opérations d'ordre";
		static public const selectRewardDesc:String = "Sélectionnez le type de récompense";
		static public const rewardsDepositesConditionsDesc:String = "RConditions des dépôts de récompense";
		static public const cyptoNotAvailableDesc:String = "Dukascoins non disponible pour votre compte.";
		static public const otherDepositesDesc:String = "Veuillez sélectionner un autre compte Dukascopy pour y déposer de l'argent.";
		static public const otherWithdrawalDesc:String = "Veuillez sélectionner un autre compte Dukascopy pour y retirer de l'argent.";
		
		static public const bcDepositeDesc:String = "Utilisez ce formulaire pour déposer des pièces DUK+ à partir de votre porte-monnaie externe.\\n\\n"
			+ "Soyez prêt à fournir l'adresse du portefeuille de l'expéditeur avant d'effectuer le dépôt et signalez l'ID de la transaction après l'envoi des pièces DUK+.\\n\\n"
			+ "En utilisant cette fonction vous confirmez que vous êtes l'unique propriétaire effectif du portefeuille crypto externe utilisé pour le dépôt DUK + dans cette opération.";
		
		static public const bcWithdrawalDesc:String = "Veuillez remplir le formulaire pour retirer DUK+ sur votre porte-monnaie externe (compatible ERC20).\\n\\n"
			+ "Remarque: lors de la phase de démarrage du nouveau service, toutes les demandes de retrait sont traitées manuellement pendant les heures ouvrables.";
		
		// CONFIRM DESCRIPTIONS
		static public const confirmCardDeposite:String = "Veuillez confirmer le déchargement de la carte";
		static public const confirmCardWithdrawal:String = "Confirmez le retrait de la carte.";
		static public const confirmCardEnable:String = "Confirmez pour activer la carte.";
		static public const confirmCardDisable:String = "Confirmez pour désactiver la carte.";
		static public const confirmCardRemove:String = "Confirmerz la suppression de la carte.";
		static public const confirmAccountOpen:String = "Veuillez confirmer l'ouverture du compte.";
		static public const confirmTransaction:String = "Confirmez votre transaction.";
		static public const confirmExchange:String = "Confirmez votre transfert.";
		static public const confirmInvestment:String = "Confirmez votre investissement.";
		static public const confirmInvestmentSell:String = "Confirmez la vente de l'investissement.";
		static public const confirmInvestmentSellAll:String = "Confirmez la vente de tous les investissements";
		static public const confirmInvoice:String = "Confirmez votre facture.";
		static public const confirmInvestmentCurrency:String = "Voulez-vous que @@1 soit votre devise de référence pour les investissements?";
		static public const confirmAccountOpening:String = "Veuillez confirmer l'ouverture du compte de trading.";
		static public const confirmCreateOffer:String = "Veuillez confirmer l’ordre suivant: @@1 @@2 DUK+ at @@3 EUR";
		static public const confirmBCDeposite:String = "Confirmer cette opération";
		static public const confirmBCWithdrawal:String = "Confirmer cette opération";
		static public const confirmCryptoTrade:String = "Confirmer cette opération";
		static public const confirmBCRewardDeposite:String = "Montant: @@1 DUK+\\nRécompense:\\n@@2\\nReward:\\n@@3\\n\\nImportant:\\nnSi vous annulez le dépôt avant sa date d’expiration, vous devrez payer une amende de @@4 et la récompense vous sera retirée\\n\\nConfirmez s’il vous plait";
		static public const confirmOfferActivate:String = "Voulez-vous l’activer?";
		static public const confirmOfferDeactivate:String = "Voulez-vous le désactiver?";
		static public const confirmOfferDelete:String = "Voulez-vous le supprimer?";
		
		// CONFIRMED DESCRIPTIONS
		static public const confirmedCardDeposite:String = "Votre dépôt est abouti.";
		static public const confirmedCardEnable:String = "Maintenant, votre carte est activée.";
		static public const confirmedCardDisable:String = "Votre carte a été désactivée.";
		static public const confirmedCardRemove:String = "Votre carte a été retirée.";
		static public const confirmedCardWithdrawal:String = "Votre retrait est terminé.";
		static public const confirmedCardActivate:String = "Votre carte a été activée.";
		static public const confirmedCardVerify:String = "Votre carte a été vérifiée.";
		static public const confirmedAccountOpening:String = "Votre compte a été ouvert.";
		static public const confirmedTransaction:String = "Votre transaction a été complétée.";
		static public const confirmedExchange:String = "Votre transfert est terminé.";
		static public const confirmedInvestmentSell:String = "Votre vente d’investissement est terminée.";
		static public const confirmedInvestmentSellAll:String = "La vente de vos investissements est terminés.";
		static public const confirmedInvestmentBuy:String = "Votre investissement est exécuté.";
		static public const confirmedInvestmentCurrency:String = "La devise de référence de votre investissement est sélectionnée.";
		static public const confirmedInvoice:String = "Votre facture a été complétée.";
		static public const confirmedTradingAccountOpen:String = "La demande a été soumise avec succès. Votre responsable de compte vous contactera.";
		static public const confirmedCreateOffer:String = "L’ordre a été créé et publié sur le marché.";
		static public const confirmedActivateOffer:String = "L’ordre a été activé.";
		static public const confirmedDeactivateOffer:String = "L’ordre a été désactivé.";
		static public const confirmedDeleteOffer:String = "L’ordre a été supprimé.";
		static public const confirmedBCWithdrawal:String = "Votre demande de retrait a été acceptée.";
		static public const confirmedBCDeposite:String = "Votre demande de dépôt a été acceptée.";
		static public const confirmedCryptoTrade:String = "Votre transaction est accomplie.";
		static public const confirmedRewardDeposite:String = "Récompense de dépôt a été créee.";
		static public const confirmedBCAddressDeposite:String = "Maintenant, veuillez saisir le montant de DUK+ précédemment déclaré à l’adresse de dépôt suivante:\\n@@1\\n\\nnNous vous informons que tout transfert non-valide (le montant ou l’adresse du portefeuille de l’expéditeur ne correspondent pas à celui déclaré précédemment) ne peuvent pas être remboursé.\\n\\nDès que le montant a été envoyé, appuyez sur ìOkî et saisissez l’ID de la transaction blockchain de votre transfert.";
		
		// MENU ITEMS
		static public const menuCardsOps:String = "Opérations de cartes";
		static public const menuAccOps:String = "Opérations de compte";
		static public const menuSendMoney:String = "Envoyer de l'argent";
		static public const menuLoadMoney:String = "Charger de l’argent (Dépôt)";
		static public const menuSendInvoice:String = "Envoyer une facture";
		static public const menuExchangeMoney:String = "Bureau de change";
		static public const menuInvestments:String = "Investissements";
		static public const menuOpenTradingAccount:String = "Ouvrir un compte trading";
		static public const menuOpenP2P:String = "911 Crypto P2P";
		static public const menuCheckAccLimits:String = "Vérifier les limites du compte";
		static public const menuOpenEBank:String = "Ouvrir e-bank";
		static public const menuOrderCard:String = "Commander une carte";
		static public const menuLinkCard:String = "Lier carte";
		static public const menuCardDetails:String = "Détails de la carte";
		static public const menuCardTopUp:String = "Recharger la carte";
		static public const menuCardUnload:String = "Décharger la carte";
		static public const menuCardDisable:String = "Désactiver la carte";
		static public const menuCardEnable:String = "Activer la carte";
		static public const menuCardRemove:String = "Retirer la carte";
		static public const menuCardActivate:String = "Activer la carte";
		static public const menuCardVerify:String = "Vérifier la carte";
		static public const menuShowAccounts:String = "Afficher tous les comptes";
		static public const menuOpenAccount:String = "Ouvrir un nouveau compte";
		static public const menuDepositeAccount:String = "Dépôts";
		static public const menuWithdrawalAccount:String = "Retraits";
		static public const menuToCard:String = "À la carte";
		static public const menuFromCard:String = "De la carte";
		static public const menuBankTransfer:String = "Virement bancaire";
		static public const menuCardTransfer:String = "Recharger carte";
		static public const menuHistory:String = "Historique";
		static public const menuAccountHistory:String = "Account history";
		static public const menuFromTransaction:String = "De la liste des transactions";
		static public const menuToPhone:String = "Vers le numéro de téléphone";
		static public const menuToContact:String = "De mes contacts";
		static public const menuToChatmate:String = "To chatmate";
		static public const menuExternalRecipient:String = "Destinataire externe";
		static public const menuRepeatTransaction:String = "Répéter la transaction";
		static public const menuRepeatExchange:String = "Répétez l'échange";
		static public const menuRepeatDeposit:String = "Répéter le dépôt";
		static public const menuRepeatWithdrawal:String = "Répéter le retrait";
		static public const menuInviteConsultant:String = "Inviter Consultant";
		static public const menuInvestmentBuy:String = "Investir";
		static public const menuInvestmentSell:String = "Vendre des investissements";
		static public const menuInvestmentPortfolio:String = "Mon portfolio";
		static public const menuInvestmentDetails:String = "Détails";
		static public const menuInvestmentSellAll:String = "Tout vendre";
		static public const menuInvestmentIndexes:String = "Indices";
		static public const menuInvestmentCommodities:String = "Matières premières";
		static public const menuInvestmentCrypto:String = "Crypto";
		static public const menuForexCFD:String = "Forex/CFD";
		static public const menuBinaryOptions:String = "Options binaires";
		static public const menuIncreaseLimits:String = "Augmenter les limites";
		static public const menuAcceptAndProceed:String = "Accepter et continuer";
		static public const menuCardVirtual:String = "Carte virtuelle";
		static public const menuCardPlastic:String = "Carte plastifiée ";
		static public const menuUserTransactions:String = "Transactions avec Utilisateur";
		static public const menuEnterPwd:String = "Entrer le mot de passe";
		static public const menuRecipientProfile:String = "Profil du destinataire";
		static public const menuSenderProfile:String = "Profil expéditeur";
		static public const menuCryptoMarket:String = "Dukascoins";
		static public const menuDukasnotes:String="Dukasnotes";
		static public const menuCryptoBuy:String = "Achat";
		static public const menuCryptoSell:String = "Vendre";
		static public const menuCryptoOrders:String = "Mes opérations";
		static public const menuCryptoWithdrawal:String = "Retrait sur mon portefeuille blockchain";
		static public const menuCryptoDeposit:String = "Dépôt depuis mon portefeuille blockchain";
		static public const menuCryptoTransfer:String = "Envoyer des Dukascoins";
		static public const menuShowOffers:String = "Le Marché";
		static public const createOffer:String = 'D ì “@@1” Lot'; //"Placer @@2 (@@1) ) ordre";
		static public const menuMyShowOffers:String = 'Mes ì “@@2” Lot'; // "Mes @@2 (@@1) ordre";
		static public const menuByBestPrice:String = "Meilleur prix";
		static public const menuByVolume:String = "Plus grande taille";
		static public const menuByFilter:String = "Filtre poussé";
		static public const menuBlockchainOperations:String = "Opérations blockchain";
		static public const menuRewardsDeposite:String = "Dépôts de récompense";
		static public const menuRDReadConditions:String = "Lire les conditions";
		static public const menuRDCreateNew:String = "Nouveau dépôt";
		static public const menuRDCoin:String = "Récompenses en jetons (DUK+)";
		static public const menuRDFiat:String = "Récompenses en fiat (EUR)";
		static public const cryptoSellBuyMarket:String = "@@1 au prix du marché";
		static public const menuCryptoOfferDeactivate:String = "Deactivate";
		static public const menuCryptoOfferActivate:String = "Activer";
		static public const menuCryptoOfferRemove:String = "Désactiver";
		static public const menuRDCoinConditions:String = "Conditions des récompenses en jetons";
		static public const menuRDFiatConditions:String = "Conditions des récompenses en fiat";
		static public const menuShowMyOffers:String = "Montrer mes lots";
		static public const menuRequestChatmate:String = "Demander à un ami";
		static public const menuVisitDukascoin:String = "Visiter dukascoin.com";
		
		static public const investmentIndex:String = "Indice";
		static public const investmentSilver:String = "Argent";
		static public const investmentGold:String = "Or";
		static public const investmentNaturalGas:String = "Gaz naturel";
		static public const investmentBrentOil:String = "Brent oil";
		static public const investmentBitcoin:String = "Bitcoin";
		static public const investmentEthereum:String = "Ethereum";
		
		static public const itemShowCardOps:String = "Afficher les opérations de la carte.";
		static public const itemUnloadCard:String = "Transférez @1 @2 de la carte @3 vers le compte @4.";
		static public const itemSendToCard:String = "Rechargez la carte @3 du compte @4 par le compte @1 @2.";
		static public const itemOpenAccount:String = "Ouvrir un nouveau compte @1.";
		static public const itemExchange:String = "Transférez @1 @2 du compte @3 vers le compte @4.";
		static public const itemOpenAccountAuto:String = "@1 le compte sera ouvert automatiquement.";
		static public const itemInvestmentSell1:String = "Vendre @1.";
		static public const itemInvestmentSell2:String = "Vendre @1 vaut @2.";
		static public const itemInvestmentBuy1:String = "Achat @1.";
		static public const itemInvestmentBuy2:String = "Achetez @1 valeur de @2.";
		static public const itemInvestmentDetails:String = "@@1 détail.";
		static public const itemInvestmentCurrency:String = "Appliquer @1 pour ma devise d'investissement";
		static public const itemClickOnTransaction:String = "Cliquez sur la transaction dans la liste et procédez aux paiements";
		static public const itemInvoice:String = "Envoyer la facture pour @1 à @2";
		static public const itemSendMoney:String = "Envoyer @1 à @2";
		static public const itemSendMoneyPhone:String = "Envoyer @1 à @2";
		static public const itemShowCryptoOfferOperations:String = "Montrer mes opérations d’investissement";
		
		static public const errorPwdManyTimes:String = "Mot de passe bloquée. Trop de tentatives infructueuses pendant une courte période. Réessayez plus tard.";
		static public const errorAccountBlocked:String = "Le compte est bloqué";
		static public const errorAccountNotApproved:String = "Compte non approuvé";
		static public const errorWrongData:String = "Quelque chose a mal tourné";
		
		static public const investmentDisclaimer:String = "Toutes les opérations d'investissements doivent être effectuées dans une devise de référence. Toutes les autres opérations liées aux investissements (achat, vente, dividendes et frais de garde) seront effectuées uniquement dans cette devise. La devise de référence ne peut être changée que lorsque tous les actifs sont vendus.";
		
		public function BankBotScenarioLangFR() {
			
		}
	}
}