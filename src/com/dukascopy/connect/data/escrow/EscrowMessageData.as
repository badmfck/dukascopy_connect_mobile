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
		public var direction:TradeDirection;
		public var type:String;
		public var status:EscrowStatus;
		public var currency:String;
		public var instrument:String;
		public var cryptoWallet:String;
		public var transactionId:String;
		public var userUID:String;
		public var debitAccount:String;
		
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
			if ("side" in data)
			{
				direction = TradeDirection.getDirection(data.side);
			}
			if ("mca_ccy" in data)
			{
				currency = data.mca_ccy;
			}
			if ("instrument" in data)
			{
				instrument = data.instrument;
			}
			if ("status" in data)
			{
				status = EscrowStatus.getStatus(data.status);
			}
			if ("userUID" in data)
			{
				userUID = data.userUID;
			}
		}
		
		public function toJsonString():String 
		{
			var result:Object = new Object();
			result.price = price;
			result.amount = amount;
			result.type = type;
			result.userUID = userUID;
			if (direction != null)
			{
				result.side = direction.type;
			}
			else
			{
				ApplicationErrors.add("direction");
			}
			
			if (status != null)
			{
				result.status = status.value;
			}
			else
			{
				ApplicationErrors.add("status");
			}
			result.mca_ccy = currency;
			result.instrument = instrument;
			
			return Config.BOUNDS + JSON.stringify(result);
		}
	}
}