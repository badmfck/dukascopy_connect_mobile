package com.dukascopy.connect.data.escrow 
{
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class EscrowEventType 
	{
		static public const CREATED:EscrowEventType = new EscrowEventType("deal_created");
		static public const HOLD_MCA:EscrowEventType = new EscrowEventType("hold_mca");
		static public const HOLD_MCA_FAIL:EscrowEventType = new EscrowEventType("hold_mca_failed");
		static public const CRYPTO_ACCEPTED:EscrowEventType = new EscrowEventType("crypto_accepted");
		static public const PAID_CRYPTO:EscrowEventType = new EscrowEventType("paid_crypto");
		static public const CANCEL:EscrowEventType =new EscrowEventType("cancel");
		static public const OFFER_CREATED:EscrowEventType = new EscrowEventType("offerCreated");
		static public const DEAL_EXPIRED:EscrowEventType = new EscrowEventType("expired");
		static public const DEAL_FAILED:EscrowEventType = new EscrowEventType("failed");
		
		private var type:String;
		public function EscrowEventType(type:String){
			this.type=type;
		}

		public function get value():String{return type;}
		public function toString():String{return type;}
	}
}
