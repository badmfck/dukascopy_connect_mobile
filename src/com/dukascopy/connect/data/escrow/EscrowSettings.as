package com.dukascopy.connect.data.escrow 
{
	import com.dukascopy.connect.managers.escrow.vo.EscrowInstrument;
	import com.dukascopy.connect.screens.payments.card.TypeCurrency;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class EscrowSettings 
	{
		static private var _refundableFee:Number = 0.03;
		static private var defaultCommission:Number = 0.03;
		static private var commission_DCO:Number = 0.03;
		static private var commission_BTC:Number = 0.01;
		static private var commission_ETH:Number = 0.01;
		static private var commission_UST:Number = 0.01;
		
		static public var offerMaxTime:Number = 5;
		static public var dealMaxTime:Number = 30;
		static public var confirmTransactionTime:Number = 1440;
		static public var penalty:Number = 0.01;
		static public var limitAmountKoef:Number = 0.9;
		static public var receiptConfirmationTime:Number = 24*60;
		
		static public function getCommission(instrument:String):Number 
		{
			switch (instrument) 
			{
				case TypeCurrency.DCO:
					return commission_DCO;
				break;
				
				case TypeCurrency.ETH:
					return commission_ETH;
				break;
				
				case TypeCurrency.BTC:
					return commission_BTC;
				break;
				
				case TypeCurrency.USDT:
					return commission_UST;
				break;
			}
			
			ApplicationErrors.add();
			return defaultCommission;
		}
		
		static public function get refundableFee():Number
		{
			return _refundableFee;
		}
		
		public function EscrowSettings() 
		{
			
		}
	}
}