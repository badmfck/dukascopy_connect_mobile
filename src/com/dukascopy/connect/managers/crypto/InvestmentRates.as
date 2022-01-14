package com.dukascopy.connect.managers.crypto 
{
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class InvestmentRates 
	{
		public var time:Number;
		public var data:Vector.<RateTick>;
		public var instrument:String;
		public var currency:String;
		public var lastChange:Number = 3;
		public var max:Number = 0;
		public var min:Number = 0;
		
		public function InvestmentRates() 
		{
			
		}
	}
}