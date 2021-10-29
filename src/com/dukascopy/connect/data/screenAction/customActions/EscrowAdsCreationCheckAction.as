package com.dukascopy.connect.data.screenAction.customActions {
	
	import com.dukascopy.connect.data.coinMarketplace.PaymentsAccountsProvider;
	import com.dukascopy.connect.data.escrow.EscrowSettings;
	import com.dukascopy.connect.data.escrow.TradeDirection;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.managers.escrow.vo.EscrowAdsVO;
	import com.dukascopy.connect.managers.escrow.vo.EscrowInstrument;
	import com.dukascopy.connect.screens.dialogs.escrow.RegisterEscrowScreen;
	import com.dukascopy.connect.screens.payments.card.TypeCurrency;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.payments.PayManager;
	import com.dukascopy.connect.sys.payments.PaymentsManager;
	import com.dukascopy.connect.sys.payments.vo.AccountLimitVO;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.type.BankPhaze;
	import com.dukascopy.langs.Lang;

	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class EscrowAdsCreationCheckAction extends ScreenAction implements IScreenAction {
		
		private var escrowAdsVO:EscrowAdsVO;
		private var checkPaymentsAction:TestCreateOfferAction;
		public var disposeOnResult:Boolean;
		
		public function EscrowAdsCreationCheckAction(escrowAdsVO:EscrowAdsVO) {
			setIconClass(null);
			
			this.escrowAdsVO = escrowAdsVO;
		}
		
		public function execute():void {
			//TODO: side;
			if (Auth.bank_phase != BankPhaze.ACC_APPROVED) {
				ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, RegisterEscrowScreen);
				S_ACTION_FAIL.invoke(null);
				return;
			}
			var selectedDirection:TradeDirection = (escrowAdsVO.side == "buy") ? TradeDirection.buy : TradeDirection.sell;
			var price:Number = 0;
			if (escrowAdsVO.percent == null || escrowAdsVO.percent.indexOf("%") == -1) {
				price = escrowAdsVO.price;
			} else {
				for (var i:int = 0; i < escrowAdsVO.instrument.price.length; i++) {
					if (escrowAdsVO.instrument.price[i].name == escrowAdsVO.currency) {
						price = escrowAdsVO.instrument.price[i].value + escrowAdsVO.instrument.price[i].value * Number(escrowAdsVO.percent.substr(0, escrowAdsVO.percent.length -1));
						break;
					}
				}
				if (price == 0) {
					onFail(Lang.escrow_price_zero_error);
					return;
				}
			}
			var fiatAmount:Number = Number(escrowAdsVO.amount) * price;
			var resultAmount:Number = fiatAmount + ((escrowAdsVO.side == "buy") ?  fiatAmount * EscrowSettings.refundableFee : fiatAmount * EscrowSettings.getCommission(escrowAdsVO.instrument.code));
			
			checkPaymentsAction = new TestCreateOfferAction(selectedDirection, resultAmount, escrowAdsVO.currency, escrowAdsVO.instrument);
			checkPaymentsAction.getFailSignal().add(onPaymentsBuyCheckFail);
			checkPaymentsAction.getSuccessSignal().add(onPaymentsBuyCheckSuccess);
			checkPaymentsAction.execute();
		}
		
		private function onPaymentsBuyCheckSuccess():void 
		{
			onSuccess();
		}
		
		private function onPaymentsBuyCheckFail(errorMessage:String):void 
		{
			onFail(errorMessage);
		}
		
		private function onSuccess():void {
			if (S_ACTION_SUCCESS != null) {
				S_ACTION_SUCCESS.invoke(escrowAdsVO);
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
			super.dispose();
			if (checkPaymentsAction != null)
			{
				checkPaymentsAction.dispose();
				checkPaymentsAction = null;
			}
		}
	}
}