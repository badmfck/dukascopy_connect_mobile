package com.dukascopy.connect.data.escrow 
{
	import com.dukascopy.connect.Config;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class EscrowMessageData 
	{
		public var price:Number;
		public var amount:Number;
		
		public function EscrowMessageData() 
		{
			
		}
		
		public function toJsonString():String 
		{
			var result:Object = new Object();
			result.price = price;
			result.amount = amount;
			
			return Config.BOUNDS + JSON.stringify(result);
		}
	}
}