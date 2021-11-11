package com.dukascopy.connect.data.escrow 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.managers.escrow.vo.EscrowInstrument;
	import com.dukascopy.connect.screens.payments.card.TypeCurrency;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.configManager.ConfigManager;
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
		
		static public function get offerMaxTime():Number 
		{
			return ConfigManager.config.escrowTimeOfferAccepted;
		}
		
		static public function get dealMaxTime():Number 
		{
			return ConfigManager.config.escrowTimeDealCompleted;
		}
		
		static public function get dealCryptoInvestigationTime():Number 
		{
			return ConfigManager.config.escrowTimeDealExpired;
		}
		
		static public function get receiptConfirmationTime():Number 
		{
			return ConfigManager.config.escrowTimeDealConfirmCrypto;
		}
		
		static public var penalty:Number = 0.01;
		static public var limitAmountKoef:Number = 0.9;
		
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
		
		public static function getTime(escrow:EscrowMessageData):Number 
		{
			var timeNow:Number = (new Date()).time / 1000;
			var difference:Number = 0;
			
			if (escrow.status == EscrowStatus.offer_created)
			{
				difference = EscrowSettings.offerMaxTime * 60 - (timeNow - escrow.created);
			}
			else if (escrow.status == EscrowStatus.deal_mca_hold)
			{
				difference = EscrowSettings.dealMaxTime * 60 - (timeNow - escrow.created);
			}
			else if (escrow.status == EscrowStatus.paid_crypto)
			{
				difference = EscrowSettings.receiptConfirmationTime * 60 - (timeNow - escrow.created);
			}
			else if (escrow.status == EscrowStatus.deal_crypto_send_wait_investigation)
			{
				difference = EscrowSettings.dealCryptoInvestigationTime * 60 - (timeNow - escrow.created);
			}
			
			if (isNaN(difference))
			{
				difference = 0;
				ApplicationErrors.add();
			}
			return Math.max(difference, 0);
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