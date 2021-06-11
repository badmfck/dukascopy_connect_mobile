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
		
		public static const cancel:OfferCommand = new OfferCommand(OfferCommand.CANCEL);
		
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