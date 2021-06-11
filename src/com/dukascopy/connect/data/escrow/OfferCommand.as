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
		
		public static const cancel:OfferCommand = new OfferCommand(OfferCommand.CANCEL);
		public static const accept:OfferCommand = new OfferCommand(OfferCommand.ACCEPT);
		public static const reject:OfferCommand = new OfferCommand(OfferCommand.REJECT);
		
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