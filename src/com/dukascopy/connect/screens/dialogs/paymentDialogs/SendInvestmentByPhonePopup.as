package com.dukascopy.connect.screens.dialogs.paymentDialogs 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.GiftData;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.renderers.ListPayCurrency;
	import com.dukascopy.connect.gui.list.renderers.ListPayInvestmentItem;
	import com.dukascopy.connect.gui.list.renderers.ListPayWalletItem;
	import com.dukascopy.connect.screens.dialogs.x.base.bottom.BottomAlertPopup;
	import com.dukascopy.connect.screens.dialogs.x.base.bottom.ListSelectionPopup;
	import com.dukascopy.connect.screens.payments.card.TypeCurrency;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.payments.InvoiceManager;
	import com.dukascopy.connect.sys.payments.PayManager;
	import com.dukascopy.connect.sys.payments.PaymentsManager;
	import com.dukascopy.connect.sys.paymentsManagerNew.PaymentsManagerNew;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.softKeyboard.SoftKeyboard;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import com.telefision.sys.signals.Signal;
	import flash.events.Event;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	
	public class SendInvestmentByPhonePopup extends SendMoneyByPhonePopup {
		
		private var cryptoWallets:Array;
		
		public function SendInvestmentByPhonePopup() {
			
		}
		
		override protected function createView():void {
			super.createView();
		}
		
		override protected function selectCurrencyTap():void 
		{
			var currencies:Array = new Array();
			
			var l:int = cryptoWallets.length;
			var walletItem:Object;
			for (var i:int = 0; i < l; i++)
			{
				walletItem = cryptoWallets[i];
				currencies.push(walletItem.INSTRUMENT)
			//	currencies.push(walletItem)
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
		
		override protected function showWalletsDialog():void
		{
			if (cryptoWallets.length > 0)
			{
				DialogManager.showDialog(
					ListSelectionPopup,
					{
						items:cryptoWallets,
						title:Lang.TEXT_SELECT_ACCOUNT,
						renderer:ListPayWalletItem,
						callback:onWalletSelect
					}, DialogManager.TYPE_SCREEN
				);
			}
			else
			{
				DialogManager.showDialog(
					BottomAlertPopup,
					{
						title:Lang.TEXT_SELECT_ACCOUNT,
						message:Lang.noFundedAccounts
					}, DialogManager.TYPE_SCREEN
				);
			}
		}
		
		override public function initScreen(data:Object = null):void
		{
			if (data != null && "giftData" in data && data.giftData is GiftData) {
				giftData = data.giftData as GiftData;
			}
			
			if (giftData != null)
			{
				if (giftData.wallets != null)
				{
					cryptoWallets = giftData.wallets;
				}
			}
			
			super.initScreen(data);
		}
		
		override protected function checkData():void {
			onDataReady();
		}
		
		override protected function selectAccount(currency:String):void {
			if (cryptoWallets != null) {
				var defaultAccount:Object;
				var currencyNeeded:String = currency;
				var l:int = cryptoWallets.length;
				var walletItem:Object;
				for (var i:int = 0; i < l; i++) {
					walletItem = cryptoWallets[i];
					if (currencyNeeded == walletItem.INSTRUMENT) {
						defaultAccount = walletItem;
						break;
					}
				}
				if (defaultAccount != null) {
					onWalletSelect(defaultAccount);
				} else {
					//drawNoAccountMessage();
					onWalletSelect(null, true);
				}
			}
		}
		
		override protected function nextClick():void {
			SoftKeyboard.closeKeyboard();
			
			if (compareEnterAndRepeatSC() == false) {
				return;
			}
			
			if (iAmountCurrency != null)
			{
				iAmountCurrency.forceFocusOut();
			}
			
			if (giftData != null)
			{
				giftData.accountNumber = selectedAccount.ACCOUNT_NUMBER;
				giftData.currency = selectorCurrency.value;
				giftData.customValue = Number(iAmountCurrency.value);
				if (secureCodeManager.view != null && secureCodeManager.view.parent != null && secureCodeManager.code != null && secureCodeManager.code != "")
				{
					giftData.pass = secureCodeManager.code;
				}
				
				giftData.credit_account_number = UI.isEmpty(inptCodeAndPhone.getInfoBoxValue()) ? inptCodeAndPhone.value : inptCodeAndPhone.getInfoBoxValue() + inptCodeAndPhone.value;
				
				if (giftData.callback != null)
				{
					giftData.callback(giftData);
				}
			}
			
			ServiceScreenManager.closeView();
		}
		
		override protected function onWalletSelect(account:Object, cleanCurrent:Boolean = false):void
		{
			if (account == null)
			{
				if (cleanCurrent == true)
				{
					selectedAccount = account;
				//	selectorCurrency.setValue();
					walletSelected = false;
				}	
			}
			else{
				selectedAccount = account;
				selectorCurrency.setValue(account.INSTRUMENT);
			}
			if (account != null || cleanCurrent == true)
			{
				selectorDebitAccont.setValue(account);
			}
		}
		
		override protected function selectBigAccount():void 
		{
			var l:int = cryptoWallets.length;
			
			if (giftData != null && giftData.accountNumber != null)
			{
				selectDebitAccountByNumber(giftData.accountNumber);
			}
			else{
				var bigAccount:Object;
				if (cryptoWallets != null && cryptoWallets.length > 0)
				{
					bigAccount = cryptoWallets[0];
				}
				for (var i:int = 0; i < l; i++)
				{
					if (Number(bigAccount.BALANCE) < Number(cryptoWallets[i].BALANCE))
					{
						bigAccount = cryptoWallets[i];
					}
				}
				if (bigAccount != null)
				{
					onWalletSelect(bigAccount);
				}
			}
		}
		
		override protected function selectDebitAccountByNumber(accountNumber:String):void 
		{
			var account:Object;
			
			var l:int = cryptoWallets.length;
			var walletItem:Object;
			for (var i:int = 0; i < l; i++)
			{
				walletItem = cryptoWallets[i];
				if (accountNumber == walletItem.IBAN)
				{
					account = walletItem;
					break;
				}
			}
			if (account != null)
			{
				selectedAccount = account;
				selectorDebitAccont.setValue(account);
				selectorCurrency.setValue(account.CURRENCY);
			}
		}
		
		override protected function setDefaultWallet():void
		{
			if (PayManager.accountInfo == null) return;
			var defaultAccount:Object;
			
			var currencyNeeded:String = TypeCurrency.EUR;
			var l:int = cryptoWallets.length;
			var walletItem:Object;
			for (var i:int = 0; i < l; i++)
			{
				walletItem = cryptoWallets[i];
				if (currencyNeeded == walletItem.CURRENCY)
				{
					defaultAccount = walletItem;
					break;
				}
			}
			if (defaultAccount != null)
			{
				onWalletSelect(defaultAccount);
			}
		}
	}
}