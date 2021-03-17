package com.dukascopy.connect.sys.applicationShop.product 
{
	import com.dukascopy.langs.Lang;
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev
	 */
	public class SubscriptionDurationCollection 
	{
		static private var paidChannelDurations:Vector;
		
		public function SubscriptionDurationCollection() 
		{
			
		}
		
		public static function getAvaliableDurations(productType:ProductType):Vector.<SubscriptionDuration>
		{
			switch(productType.value)
			{
				case ProductType.TYPE_PAID_CHANNEL_SUBSCRIPTION:
				{
					var paidChannelDurations:Vector.<SubscriptionDuration> = new Vector.<SubscriptionDuration>();
					paidChannelDurations.push(new SubscriptionDuration(new SubscriptionDurationType(SubscriptionDurationType.DAY)));
				//	paidChannelDurations.push(new SubscriptionDuration(new SubscriptionDurationType(SubscriptionDurationType.ONCE)));
				//	paidChannelDurations.push(new SubscriptionDuration(new SubscriptionDurationType(SubscriptionDurationType.SESSION)));
					paidChannelDurations.push(new SubscriptionDuration(new SubscriptionDurationType(SubscriptionDurationType.WEEK)));
					paidChannelDurations.push(new SubscriptionDuration(new SubscriptionDurationType(SubscriptionDurationType.MOUNTH)));
					return paidChannelDurations;
					break;
				}
			}
			return null;
		}
	}
}