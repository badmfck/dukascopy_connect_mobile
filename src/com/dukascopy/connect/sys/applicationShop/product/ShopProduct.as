package com.dukascopy.connect.sys.applicationShop.product 
{
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.vo.ChatVO;
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev
	 */
	public class ShopProduct 
	{
		public var productType:ProductType;
		public var duration:SubscriptionDuration;
		public var cost:ProductCost;
		public var count:int = 1;
		public var targetData:Object;
		public var earnings:Number = 0;
		public var id:Number;
		public var chatUID:String;
		public var qUID:String;
		public var userUID:String;
		
		public function ShopProduct(productType:ProductType, duration:SubscriptionDuration, cost:ProductCost, id:Number) 
		{
			this.productType = productType;
			this.duration = duration;
			this.cost = cost;
			this.id = id;
		}
		
		public function getDescription():String 
		{
			if (productType != null && targetData != null && targetData is ChatVO)
			{
				switch(productType.value)
				{
					case ProductType.TYPE_PAID_CHANNEL_SUBSCRIPTION:
					{
						return "Purchase channel subscription: " + (targetData as ChatVO).uid + ", for " + count.toString() + " " + duration.getLabel();
					}
					default:
					{
						return "Purchase";
						ApplicationErrors.add("wrong type");
					}
				}
			}
			else{
				return "";
				ApplicationErrors.add("crit");
			}
		}
		
		public function getEarnings():String 
		{
			return earnings.toString() + " " + cost.currency;
		}
		
		public function get avatarURL():String
		{
			if (targetData != null && targetData is ChatVO)
			{
				return targetData.avatarURL;
			}
			return null;
		}
	}
}