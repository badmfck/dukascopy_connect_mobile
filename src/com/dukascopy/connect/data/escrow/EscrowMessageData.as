package com.dukascopy.connect.data.escrow 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class EscrowMessageData 
	{
		public var price:Number;
		public var amount:Number;
		public var direction:String;
		public var type:String;
		public var status:EscrowStatus;
		public var currency:String;
		public var instrument:String;
		
		public function EscrowMessageData(data:Object = null) 
		{
			if (data != null)
			{
				parse(data);
			}
		}
		
		private function parse(data:Object):void 
		{
			if ("price" in data)
			{
				price = parseFloat(data.price);
			}
			if ("amount" in data)
			{
				amount = parseFloat(data.amount);
			}
			if ("direction" in data)
			{
				direction = data.direction;
			}
			if ("currency" in data)
			{
				currency = data.currency;
			}
			if ("instrument" in data)
			{
				instrument = data.instrument;
			}
			if ("status" in data)
			{
				status = EscrowStatus.getStatus(data.status);
			}
		}
		
		public function toJsonString():String 
		{
			var result:Object = new Object();
			result.price = price;
			result.amount = amount;
			result.type = type;
			result.direction = direction;
			if (status != null)
			{
				result.status = status.value;
			}
			else
			{
				ApplicationErrors.add();
			}
			result.currency = currency;
			result.instrument = instrument;
			
			return Config.BOUNDS + JSON.stringify(result);
		}
	}
}