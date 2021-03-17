package com.dukascopy.connect.sys.applicationShop 
{
	import com.dukascopy.connect.sys.applicationShop.product.ProductType;
	import com.dukascopy.connect.sys.applicationShop.product.ShopProduct;
	import com.dukascopy.connect.utils.DateUtils;
	import com.dukascopy.connect.vo.ChatVO;
	import com.dukascopy.connect.vo.users.UserVO;
	import com.dukascopy.langs.Lang;
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev
	 */
	public class Order 
	{
		public var product:ShopProduct;
		public var startTime:Number;
		public var endTime:Number;
		public var id:Number;
		public var receiver:UserVO;
		
		public function Order() 
		{
			
		}
		
		public function getDescription():String 
		{
			if (product != null && product.productType.value == ProductType.TYPE_PAID_CHANNEL_SUBSCRIPTION)
			{
				return Lang.subscriptionToChannel;
			}
			return "";
		}
		
		public function getExpireTime():String
		{
			if (!isNaN(endTime) && endTime > 0)
			{
				var currentTime:Number = Math.round((new Date()).getTime() / 1000);
				var difference:Number = endTime - currentTime;
				if (difference > 0)
				{
					return DateUtils.getComfortTimeRepresentation(difference * 1000);
				}
			}
			
			return null;
		}
		
		public function get avatarURL():String
		{
			if (product != null && product.targetData != null && product.targetData is ChatVO)
			{
				return (product.targetData as ChatVO).avatarURL;
			}
			if (receiver != null)
			{
				return receiver.getAvatarURL();
			}
			return null;
		}
		
		public function dispose():void
		{
			if (receiver != null)
			{
				receiver.dispose();
				receiver = null;
			}
		}
	}
}