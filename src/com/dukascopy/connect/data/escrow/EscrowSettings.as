package com.dukascopy.connect.data.escrow 
{
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class EscrowSettings 
	{
		static private var _refundableFee:Number = 0.03;
		static private var _commission:Number = 0.03;
		static public var offerMaxTime:Number = 200;
		static public var dealMaxTime:Number = 30;
		
		static public function get commission():Number 
		{
			return _commission;
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