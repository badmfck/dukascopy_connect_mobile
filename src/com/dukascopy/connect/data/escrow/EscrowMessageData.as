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
		public var inactive:Boolean;
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
		
		public var chatUID:String;
		public var deal_uid:String;
		public var debit_account:String;
		public var msg_id:String;
		
		public function EscrowMessageData(data:Object = null) 
		{
			if (data != null)
			{
				parse(data);
			}
		}
		
		private function parse(data:Object):void 
		{
			if ("crypto_trn_id" in data)
			{
				transactionId = data.crypto_trn_id;
			}
			
			if ("chatUID" in data)
			{
				chatUID = data.chatUID;
			}
			if ("deal_uid" in data)
			{
				deal_uid = data.deal_uid;
			}
			if ("debit_account" in data)
			{
				debit_account = data.debit_account;
			}
			if ("msg_id" in data)
			{
				msg_id = data.msg_id;
			}
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
				if (data.status != null && (data.status as String).indexOf("_inactive") != -1)
				{
					inactive = true;
					data.status = (data.status as String).substring(0, (data.status as String).length - "_inactive".length);
				}
				
				status = EscrowStatus.getStatus(data.status);
			}
			if ("userUID" in data)
			{
				userUID = data.userUID;
			}
			if ("crypto_wallet" in data)
			{
				cryptoWallet = data.crypto_wallet;
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
			
			
			if (debit_account != null)
			{
				result.debit_account = debit_account;
			}
			
			result.mca_ccy = currency;
			result.instrument = instrument;
			
			return Config.BOUNDS + JSON.stringify(result);
		}
	}
}