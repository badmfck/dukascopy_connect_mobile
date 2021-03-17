package com.dukascopy.connect.sys.applicationShop.parser {
	
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.applicationShop.product.ProductCost;
	import com.dukascopy.connect.sys.applicationShop.product.ProductType;
	import com.dukascopy.connect.sys.applicationShop.product.ShopProduct;
	import com.dukascopy.connect.sys.applicationShop.product.SubscriptionDuration;
	import com.dukascopy.connect.sys.applicationShop.product.SubscriptionDurationType;
	import com.dukascopy.connect.sys.chatManager.typesManagers.ChannelsManager;
	import com.dukascopy.connect.vo.ChatVO;
	
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev
	 */
	
	public class ShopProductDataParser {
		
		public function ShopProductDataParser() { }
		
		public function parse(data:Object, productType:ProductType):ShopProduct {
			var result:ShopProduct;
			if (valid(data)) {
				result = new ShopProduct(
					productType, 
					new SubscriptionDuration(new SubscriptionDurationType(data.type)), 
					new ProductCost(data.amount, data.curr),
					data.id
				);
				if (result.productType.value == ProductType.TYPE_PAID_CHANNEL_SUBSCRIPTION && data.context != null)	{
					var chatSettings:Object = new Object();
					chatSettings[ChannelsManager.CHANNEL_SETTINGS_INFO] = data.context.info;
					result.targetData = (new ChatVO({uid : data.context.chat_uid, avatar : data.context.avatar, title : data.context.title,	settings : chatSettings})) as Object;
				}
				if (data.hasOwnProperty("yearn"))
					result.earnings = data.yearn;
				if (data.hasOwnProperty("chat_uid"))
					result.chatUID = data.chat_uid;
			} else
				ApplicationErrors.add("wrong data format");
			return result;
		}
		
		private function valid(data:Object):Boolean {
			var result:Boolean = true;
			if (data != null) {
				if (data.hasOwnProperty("amount") == false)
					result = false;
				if (data.hasOwnProperty("curr") == false)
					result = false;
				if (data.hasOwnProperty("type") == false)
					result = false;
			} else
				result = false;
			return result;
		}
	}
}