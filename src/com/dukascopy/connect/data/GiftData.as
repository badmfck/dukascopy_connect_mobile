package com.dukascopy.connect.data 
{
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.Gifts;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.type.ChatRoomType;
	import com.dukascopy.connect.type.GiftType;
	import com.dukascopy.connect.vo.users.UserVO;
	import com.dukascopy.connect.vo.users.adds.ChatUserVO;
	import com.dukascopy.connect.vo.ChatVO;
	/**
	 * ...
	 * @author ...
	 */
	public class GiftData 
	{
		public var recieverSecret:Boolean;
		public var customValue:Number = 0;
		public var type:int;
		public var user:UserVO;
		public var comment:String = "";
		public var currency:String;
		public var chatUID:String;
		public var commentAvaliable:Boolean = true;
		public var currencyAvaliable:Boolean = true;
		public var callback:Function;
		public var accountNumber:String;
		public var accountNumberIBAN:String;
		public var additionalData:Object;
		public var credit_account_number:String;
		public var credit_account_numberIBAN:String;
		public var debit_account_currency:String;
		public var credit_account_currency:String;
		public var fixedCommodityValue:Boolean;
		public var cardType:int = 0;
		public var masked:String;
		public var userName:String;
		public var wallets:Array;
		public var txTransaction:Array;
		public var txHash:String;
		public var fiatReward:Boolean;
		public var minAmount:Number = NaN;
		public var maxAmount:Number = 10000;
		public var cards:Array;
		public var pass:String;
		public var rewardDeposit:Object;
		public var cvv:String;
		public var addConfirmDialog:Boolean = false;
		public var purpose:String;
		
		public var fromAccounts:Array;
		public var toAccounts:Array;
		public var currencies:Array;
		public var transferType:String;
		public var to:Object;
		public var from:Object;
		
		public function GiftData(rawData:Object = null, chatUid:String = null) 
		{
			if (rawData != null)
			{
				parse(rawData, chatUid);
			}
		}
		
		public function dispose():void {
			callback = null;
			additionalData = null;
		}
		
		private function parse(rawData:Object, chatUid:String):void 
		{
			type = int(rawData.type);
			customValue = Number(rawData.customValue);
			currency = rawData.currency;
			comment = rawData.comment;
			recieverSecret = rawData.recieverSecret;
			
			var chatVO:ChatVO = ChatManager.getChatByUID(chatUid);
			if (chatVO != null && (chatVO.type == ChatRoomType.PRIVATE || chatVO.type == ChatRoomType.QUESTION))
			{
				var chatUser:ChatUserVO = UsersManager.getInterlocutor(chatVO);
				if (chatUser != null){
					user = chatUser.userVO;
					if (chatUser.secretMode == true){
						recieverSecret = true;
					}
				}
			}
		}
		
		public function getValue():Number 
		{
			switch(type)
			{
				case GiftType.GIFT_1:
				{
					return Gifts.GIFT_VALUE_1;
					break;
				}
				case GiftType.GIFT_5:
				{
					return Gifts.GIFT_VALUE_5;
					break;
				}
				case GiftType.GIFT_10:
				{
					return Gifts.GIFT_VALUE_10;
					break;
				}
				case GiftType.GIFT_25:
				{
					return Gifts.GIFT_VALUE_25;
					break;
				}
				case GiftType.GIFT_50:
				{
					return Gifts.GIFT_VALUE_50;
					break;
				}
				case GiftType.GIFT_X:
				{
					return customValue;
					break;
				}
				case GiftType.MONEY_TRANSFER:
				{
					return customValue;
					break;
				}
				case GiftType.FIXED_TIPS:
				{
					return customValue;
					break;
				}
				case GiftType.MONEY_TRANSFER_CALLBACK:
				{
					return customValue;
					break;
				}
			}
			
			return 1;
		}
	}
}