package com.dukascopy.connect.data.escrow 
{
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.auth.Auth;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class EscrowMessageData 
	{
		public var state:EscrowState;
		public var mca_user_uid:String;
		public var crypto_user_uid:String;
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
		public var msg_id:Number;
		public var transactionConfirmShown:Boolean;
		public var priceID:int;
		public var created:Number = 0;
		
		public function EscrowMessageData(data:Object = null) 
		{
			if (data != null)
			{
				parse(data);
			}
		}
		
		private function parse(data:Object):void 
		{
			if ("created_at" in data)
			{
				created = data.created_at;
			}
			if ("lifeTime" in data)
			{
				created = data.lifeTime;
			}
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
				setStatus(data.status);
			}
			if ("userUID" in data)
			{
				userUID = data.userUID;
			}
			if ("crypto_wallet" in data)
			{
				cryptoWallet = data.crypto_wallet;
			}
			if ("mca_user_uid" in data)
			{
				mca_user_uid = data.mca_user_uid;
			}
			if ("crypto_user_uid" in data)
			{
				crypto_user_uid = data.crypto_user_uid;
			}
			if ("chat_uid" in data)
			{
				chatUID = data.chat_uid;
			}
			else if ("chatUID" in data)
			{
				chatUID = data.chatUID;
			}
			if ("state" in data)
			{
				state = EscrowState.getStatus(data.state);
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
			
			return JSON.stringify(result);
		}
		
		public function toServerObject(chatUID:String):Object 
		{
			var result:Object = new Object();
			result.amount = amount;
			result.mca_ccy = currency;
			result.side = direction.type;
			result.instrument = instrument;
			result.price = price;
			result.chatUID = chatUID;
			
			result.priceID = priceID;
			
			if (debit_account != null)
			{
				result.debit_account = debit_account;
			}
			
			return result;
		}
		
		public function setStatus(value:String):void 
		{
			if (value != null && (value as String).indexOf("_inactive") != -1)
			{
				inactive = true;
				value = (value as String).substring(0, (value as String).length - "_inactive".length);
			}
			status = EscrowStatus.getStatus(value);
		}
	}
}