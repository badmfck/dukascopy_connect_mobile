package com.dukascopy.connect.data.escrow 
{
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class EscrowEventType 
	{
		static public const CREATED:String = "deal_created";
		static public const HOLD_MCA:String = "hold_mca";
		static public const CRYPTO_ACCEPTED:String = "crypto_accepted";
		static public const PAID_CRYPTO:String = "paid_crypto";
		
		public function EscrowEventType() 
		{
			
		}
	}
}