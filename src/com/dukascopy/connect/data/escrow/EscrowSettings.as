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
		static public var offerMaxTime:Number = 5;
		static public var dealMaxTime:Number = 30;
		static public var confirmTransactionTime:Number = 1440;
		static public var penalty:Number = 0.01;
		
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