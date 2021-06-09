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
		private static const OFFER_CANCELLED:String = "offer_cancelled";
		private static const OFFER_REJECTED:String = "offer_rejected";
		private static const OFFER_ACCEPTED:String = "offer_accepted";
		
		static public var offer_created:EscrowStatus = new EscrowStatus(EscrowStatus.OFFER_CREATED);
		static public var offer_cancelled:EscrowStatus = new EscrowStatus(EscrowStatus.OFFER_CANCELLED);
		static public var offer_rejected:EscrowStatus = new EscrowStatus(EscrowStatus.OFFER_REJECTED);
		static public var offer_accepted:EscrowStatus = new EscrowStatus(EscrowStatus.OFFER_ACCEPTED);
		
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
			}
			return null;
		}
	}
}