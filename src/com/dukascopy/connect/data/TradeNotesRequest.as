package com.dukascopy.connect.data 
{
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class TradeNotesRequest 
	{
		public var side:String;
		public var currency:String;
		public var amount:Number;
		public var wallet:String;
		public var creditAccount:Object;
		
		public function TradeNotesRequest() 
		{
			
		}
	}
}