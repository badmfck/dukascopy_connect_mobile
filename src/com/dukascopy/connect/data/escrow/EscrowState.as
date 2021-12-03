package com.dukascopy.connect.data.escrow 
{
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class EscrowState 
	{
		private var _value:String;
		private static const EXPIRED_BY_BUYER:String = "expired_by_buyer";
		
		static public var expired_by_buyer:EscrowState = new EscrowState(EscrowState.EXPIRED_BY_BUYER);
		
		public function get value():String 
		{
			return _value;
		}
		
		public function EscrowState(value:String) 
		{
			this._value = value;
		}
		
		static public function getStatus(value:String):EscrowState 
		{
			switch(value)
			{
				case EXPIRED_BY_BUYER:
				{
					return expired_by_buyer;
					break;
				}
			}
			return null;
		}
	}
}