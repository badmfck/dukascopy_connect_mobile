package com.dukascopy.connect.data.screenAction.customActions {
	
	import com.dukascopy.connect.data.coinMarketplace.PaymentsAccountsProvider;
	import com.dukascopy.connect.data.escrow.EscrowSettings;
	import com.dukascopy.connect.data.escrow.TradeDirection;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.managers.escrow.vo.EscrowInstrument;
	import com.dukascopy.connect.screens.payments.card.TypeCurrency;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.payments.PayManager;
	import com.dukascopy.connect.sys.payments.PaymentsManager;
	import com.dukascopy.connect.sys.payments.vo.AccountLimitVO;
	import com.dukascopy.langs.Lang;

	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class TestCreateOfferAction extends ScreenAction implements IScreenAction {
		
		private var direction:TradeDirection;
		private var fiatAmount:Number;
		private var currency:String;
		private var accounts:PaymentsAccountsProvider;
		private var instrument:EscrowInstrument;
		public var disposeOnResult:Boolean;
		
		public function TestCreateOfferAction(direction:TradeDirection, fiatAmount:Number, currency:String, instrument:EscrowInstrument) {
			setIconClass(null);
			
			this.direction = direction;
			this.fiatAmount = fiatAmount;
			this.currency = currency;
			this.instrument = instrument;
		}
		
		public function execute():void {
			if (direction == TradeDirection.buy) {
				getAccounts();
			} else if (direction == TradeDirection.sell) {
				if (PaymentsManager.activate() == false) {
					onLimitsReady();
				} else {
					PaymentsManager.S_ACCOUNT.add(onLimitsReady);
					PaymentsManager.S_ERROR.add(onPayError);
					if (PaymentsManager.S_BACK != null) {
						PaymentsManager.S_BACK.add(onAuthCancelled);
					}
				}
			} else {
				onFail(Lang.escrow_offer_type_not_set);
				ApplicationErrors.add();
			}
		}
		
		private function onAuthCancelled():void {
			removePaymetsListeners();
			onFail();
		}
		
		private function onPayError(code:String = null, message:String = null):void {
			removePaymetsListeners();
			ToastMessage.display(message);
		}
		
		private function removePaymetsListeners():void {
			PaymentsManager.S_ACCOUNT.remove(onLimitsReady);
			PaymentsManager.S_ERROR.remove(onPayError);
			if (PaymentsManager.S_BACK != null) {
				PaymentsManager.S_BACK.remove(onAuthCancelled);
			}
		}
		
		private function onLimitsReady():void {
			removePaymetsListeners();
			if (disposed) {
				return;
			}
			if (PayManager.accountInfo != null && PayManager.accountInfo.limits != null) {
				var limits:Array = PayManager.accountInfo.limits;
				if (instrument != null && instrument.price != null) {
					var priceForCurrentCurrency:Number;
					var priceForUSDCurrency:Number;
					
					for (var i:int = 0; i < instrument.price.length; i++) {
						if (instrument.price[i].name == currency) {
							priceForCurrentCurrency = instrument.price[i].value;
						} if (instrument.price[i].name == TypeCurrency.USD) {
							priceForUSDCurrency = instrument.price[i].value;
						}
					}
					
					if (currency == TypeCurrency.EUR)
					{
						priceForUSDCurrency = priceForCurrentCurrency / 1.18;
					}
					else
					{
						//!TODO:;
					}
					
					if (!isNaN(priceForCurrentCurrency) && !isNaN(priceForUSDCurrency)) {
						var priceConvert:Number = priceForCurrentCurrency / priceForUSDCurrency;
						var creditAmount:Number = fiatAmount / priceConvert;
						var upLimit:Boolean;
						var limit:AccountLimitVO;
						for (var j:int = 0; j < limits.length; j++) {
							limit = limits[j];
							if (limit.type == "DUKAPAY_INCOMING_LIMIT_AMOUNT_Q" || limit.type == "TOTAL_EQUITY_USD")
							{
								if (limit.maxLimit - limit.current < creditAmount / EscrowSettings.limitAmountKoef) {
									upLimit = true;
								}
							}
						}
						if (upLimit == false) {
							onSuccess();
						} else {
							onFail(Lang.escrow_credit_amount_not_in_limits);
						}
					} else {
						//!TODO: плохой текст ошибки;
						onFail(Lang.pleaseTryLater);
					}
				} else {
					//!TODO: плохой текст ошибки;
					onFail(Lang.pleaseTryLater);
				}
			} else {
				onFail(Lang.escrow_cant_load_account_limits);
			}
		}
		
		private function getAccounts():void {
			accounts = new PaymentsAccountsProvider(onAccountsReady, true, onAccountsFail);
			if (accounts.ready) {
				onAccountsReady();
			} else {
				accounts.getData();
			}
		}
		
		private function onAccountsFail():void {
			onFail(Lang.escrow_account_not_found);
		}
		
		private function onAccountsReady():void {
			if (disposed) {
				return;
			}
			if (accounts != null) {
				var moneyAccounts:Array = accounts.moneyAccounts;
				if (moneyAccounts != null && moneyAccounts.length > 0) {
					var targetAccount:Object;
					for (var i:int = 0; i < moneyAccounts.length; i++) {
						if (moneyAccounts[i].CURRENCY == currency) {
							targetAccount = moneyAccounts[i];
							break;
						}
					}
					if (targetAccount != null) {
						if (Number(targetAccount.BALANCE) >= fiatAmount) {
							onSuccess();
						} else {
							onFail(Lang.escrow_not_enougth_money);
						}
					} else {
						onFail(Lang.escrow_account_not_found);
					}
				} else {
					onFail(Lang.escrow_account_not_found);
				}
			} else {
				onFail(Lang.escrow_account_not_found);
				ApplicationErrors.add();
			}
			if (accounts != null) {
				accounts.dispose();
			}
			accounts = null;
		}
		
		private function onSuccess():void {
			if (S_ACTION_SUCCESS != null) {
				S_ACTION_SUCCESS.invoke();
			}
			if (disposeOnResult) {
				dispose();
			}
		}
		
		private function onFail(message:String = null):void {
			if (S_ACTION_FAIL != null) {
				S_ACTION_FAIL.invoke(message);
			}
			if (disposeOnResult) {
				dispose();
			}
		}
		
		override public function dispose():void {
			instrument = null;
			direction = null;
			removePaymetsListeners();
			PaymentsManager.deactivate();
			if (accounts != null) {
				accounts.dispose();
				accounts = null;
			}
		}
	}
}