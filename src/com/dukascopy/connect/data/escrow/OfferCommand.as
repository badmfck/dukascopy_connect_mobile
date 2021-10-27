package com.dukascopy.connect.data.escrow 
{
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class OfferCommand
	{
		private var _type:String;
		
		private static const CANCEL:String = "cancel";
		private static const ACCEPT:String = "accept";
		private static const REJECT:String = "reject";
		private static const REGISTER:String = "register";
		private static const SEND_TRANSACTION_ID:String = "sendTransactionId";
		private static const CONFIRM_CRYPTO_RECIEVE:String = "confirm_crypto_recieve";
		private static const REQUEST_INVESTIGATION:String = "request_imvestigation";
		private static const CREATE_OFFER:String = "create_offer";
		private static const CLAIM_CRYPTO:String = "CLAIM_CRYPTO";
		
		public static const cancel:OfferCommand = new OfferCommand(OfferCommand.CANCEL);
		public static const accept:OfferCommand = new OfferCommand(OfferCommand.ACCEPT);
		public static const reject:OfferCommand = new OfferCommand(OfferCommand.REJECT);
		public static const register_blockchain:OfferCommand = new OfferCommand(OfferCommand.REGISTER);
		public static const send_transaction_id:OfferCommand = new OfferCommand(OfferCommand.SEND_TRANSACTION_ID);
		public static const confirm_crypto_recieve:OfferCommand = new OfferCommand(OfferCommand.CONFIRM_CRYPTO_RECIEVE);
		public static const request_imvestigation:OfferCommand = new OfferCommand(OfferCommand.REQUEST_INVESTIGATION);
		public static const create_offer:OfferCommand = new OfferCommand(OfferCommand.CREATE_OFFER);
		public static const send_crypti_claim:OfferCommand = new OfferCommand(OfferCommand.CLAIM_CRYPTO);
		
		public function get type():String 
		{
			return _type;
		}
		
		public function OfferCommand(type:String) 
		{
			this._type = type;
		}
	}
}