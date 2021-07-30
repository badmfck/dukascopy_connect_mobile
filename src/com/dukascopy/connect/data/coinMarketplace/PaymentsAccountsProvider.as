package com.dukascopy.connect.data.coinMarketplace {
	
	import com.dukascopy.connect.screens.payments.card.TypeCurrency;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.payments.PayManager;
	import com.dukascopy.connect.sys.payments.PaymentsManager;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class PaymentsAccountsProvider {
		
		private var _coinsAccounts:Array;
		private var _moneyAccounts:Array;
		
		private var readyCallback:Function;
		private var allMoneyAccounts:Boolean;
		private var failCallback:Function;
		
		public function PaymentsAccountsProvider(readyCallback:Function, allMoneyAccounts:Boolean = false, failCallback:Function = null) {
			this.readyCallback = readyCallback;
			this.failCallback = failCallback;
			this.allMoneyAccounts = allMoneyAccounts;
		}
		
		public function get ready():Boolean {
			return (PayManager.accountInfo != null);
		}
		
		public function get coinsAccounts():Array {
			if (_coinsAccounts != null) {
				return _coinsAccounts;
			}
			if (_coinsAccounts == null && PayManager.getCoins() != null) {
				_coinsAccounts = PayManager.getCoins();
			} else {
				PaymentsManager.activate();
				PaymentsManager.updateAccount();
			}
			return _coinsAccounts;
		}
		
		public function get moneyAccounts():Array {
			if (_moneyAccounts == null) {
				if (allMoneyAccounts == true && PayManager.accountInfo != null) {
					_moneyAccounts = PayManager.accountInfo.accounts;
				} else if (PayManager.accountInfo != null && PayManager.accountInfo.accounts != null) {
					var l:int = PayManager.accountInfo.accounts.length;
					for (var i:int = 0; i < l; i++) {
						if (PayManager.accountInfo.accounts[i].CURRENCY == TypeCurrency.EUR) {
							_moneyAccounts = [PayManager.accountInfo.accounts[i]];
							break;
						}
					}
				}
			}
			return _moneyAccounts;
		}
		
		public function getData():void {
			_moneyAccounts = null;
			_coinsAccounts = null;
			if (PaymentsManager.S_ACCOUNT != null)
			{
				PaymentsManager.S_ACCOUNT.add(onAccountReady);
			}
			else
			{
				ApplicationErrors.add("crit");
			}
			
			if (PaymentsManager.S_BACK != null)
			{
				PaymentsManager.S_BACK.add(onAuthCancelled);
			}
			else
			{
				ApplicationErrors.add("crit");
			}
			
			if (PayManager.S_CANCEL_AUTH != null)
			{
				PayManager.S_CANCEL_AUTH.add(onAuthCancelled);
			}
			else
			{
				ApplicationErrors.add("crit");
			}
			
			if (PayManager.accountInfo != null && (PayManager.getCoins() == null || PayManager.accountInfo.accounts == null)) {
				if (PayManager.S_ACCOUNT == null)
				{
					PaymentsManager.activate();
				}
				
				if (PayManager.S_CANCEL_AUTH != null)
				{
					PayManager.S_CANCEL_AUTH.add(onAuthCancelled);
				}
				else
				{
					ApplicationErrors.add("crit");
				}
				
				if (PayManager.S_ACCOUNT != null)
				{
					PayManager.S_ACCOUNT.add(onAccountUpdated);
					PayManager.callGetAccountInfo();
				}
				else
				{
					ApplicationErrors.add("crit");
				}
			} else {
				PaymentsManager.activate();
			}
		}
		
		private function onAuthCancelled():void 
		{
			PaymentsManager.deactivate();
			if (failCallback != null) {
				failCallback();
			}
		}
		
		private function onAccountUpdated():void {
			if (PayManager.S_ACCOUNT == null)
			{
				PaymentsManager.activate();
			}
			if (PayManager.S_ACCOUNT != null)
			{
				PayManager.S_ACCOUNT.remove(onAccountUpdated);
			}
			else
			{
				ApplicationErrors.add("crit");
			}
			if (PayManager.S_CANCEL_AUTH != null)
			{
				PayManager.S_CANCEL_AUTH.remove(onAuthCancelled);
			}
			else
			{
				ApplicationErrors.add("crit");
			}
			
			onAccountReady();
		}
		
		private function onAccountReady():void {
			PaymentsManager.deactivate();
			checkReady();
		}
		
		private function checkReady():void {
			if (PayManager.getCoins() != null && PayManager.accountInfo != null) {
				if (readyCallback != null) {
					readyCallback();
				}
			}
		}
		
		public function dispose():void {
			PaymentsManager.deactivate();
			if (PayManager.S_CANCEL_AUTH != null)
				PayManager.S_CANCEL_AUTH.remove(onAuthCancelled);
			if (PayManager.S_ACCOUNT != null)
				PaymentsManager.S_ACCOUNT.remove(onAccountReady);
			if (PayManager.S_ACCOUNT != null)
				PayManager.S_ACCOUNT.remove(onAccountUpdated);
			if (PaymentsManager.S_BACK != null)
				PaymentsManager.S_BACK.remove(onAuthCancelled);
			readyCallback = null;
			failCallback = null;
		}
	}
}