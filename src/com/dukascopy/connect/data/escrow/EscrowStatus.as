package com.dukascopy.connect.data.escrow 
{
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class EscrowStatus 
	{
		private var _value:String;
		private static const OFFER_CREATED:String = "offer_created";
		private static const OFFER_CANCELLED:String = "canceled";
		private static const OFFER_REJECTED:String = "rejected";
		private static const OFFER_ACCEPTED:String = "accepted";
		private static const DEAL_CREATED:String = "created";
		private static const MCA_HOLD:String = "paid_mca";
		private static const PAID_CRYPTO:String = "paid_crypto";
		private static const DEAL_COMPLETED:String = "completed";
		private static const OFFER_EXPIRED:String = "outdated";
		
		static public var offer_created:EscrowStatus = new EscrowStatus(EscrowStatus.OFFER_CREATED);
		static public var offer_cancelled:EscrowStatus = new EscrowStatus(EscrowStatus.OFFER_CANCELLED);
		static public var offer_rejected:EscrowStatus = new EscrowStatus(EscrowStatus.OFFER_REJECTED);
		static public var offer_accepted:EscrowStatus = new EscrowStatus(EscrowStatus.OFFER_ACCEPTED);
		static public var offer_expired:EscrowStatus = new EscrowStatus(EscrowStatus.OFFER_EXPIRED);
		
		static public var deal_created:EscrowStatus = new EscrowStatus(EscrowStatus.DEAL_CREATED);
		static public var deal_mca_hold:EscrowStatus = new EscrowStatus(EscrowStatus.MCA_HOLD);
		static public var paid_crypto:EscrowStatus = new EscrowStatus(EscrowStatus.PAID_CRYPTO);
		static public var deal_completed:EscrowStatus = new EscrowStatus(EscrowStatus.DEAL_COMPLETED);
		
		public function get value():String 
		{
			return _value;
		}
		
		public function EscrowStatus(value:String) 
		{
			this._value = value;
		}
		
		static public function getStatus(value:String):EscrowStatus 
		{
			switch(value)
			{
				case OFFER_CREATED:
				{
					return offer_created;
					break;
				}
				case OFFER_EXPIRED:
				{
					return offer_expired;
					break;
				}
				case OFFER_CANCELLED:
				{
					return offer_cancelled;
					break;
				}
				case OFFER_REJECTED:
				{
					return offer_rejected;
					break;
				}
				case OFFER_ACCEPTED:
				{
					return offer_accepted;
					break;
				}
				case DEAL_CREATED:
				{
					return deal_created;
					break;
				}
				case MCA_HOLD:
				{
					return deal_mca_hold;
					break;
				}
				case PAID_CRYPTO:
				{
					return paid_crypto;
					break;
				}
				case DEAL_COMPLETED:
				{
					return deal_completed;
					break;
				}
			}
			return null;
		}
	}
}