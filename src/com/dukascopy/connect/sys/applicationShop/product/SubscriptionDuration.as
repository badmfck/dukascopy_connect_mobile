package com.dukascopy.connect.sys.applicationShop.product 
{
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.langs.Lang;
	import com.dukascopy.langs.Lang;
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev
	 */
	public class SubscriptionDuration 
	{
		public var type:SubscriptionDurationType;
		
		public function SubscriptionDuration(type:SubscriptionDurationType) 
		{
			this.type = type;
		}
		
		public function getLabel():String 
		{
			if (type == null)
			{
				ApplicationErrors.add();
				return "";
			}
			switch(type.value)
			{
				case SubscriptionDurationType.DAY:
				{
					return Lang.day;
					break;
				}
				case SubscriptionDurationType.MOUNTH:
				{
					return Lang.mounth;
					break;
				}
				case SubscriptionDurationType.FREE:
				{
					return Lang.free;
					break;
				}
				case SubscriptionDurationType.ONCE:
				{
					return Lang.once;
					break;
				}
				case SubscriptionDurationType.SESSION:
				{
					return Lang.session;
					break;
				}
				case SubscriptionDurationType.WEEK:
				{
					return Lang.week;
					break;
				}
				default:
				{
					ApplicationErrors.add("type of subscription not set");
					return "";
				}
			}
			return "";
		}
		
		public function getDays():int 
		{
			switch(type.value)
			{
				case SubscriptionDurationType.DAY:
				{
					return 1;
					break;
				}
				case SubscriptionDurationType.DAY_2:
				{
					return 2;
					break;
				}
				case SubscriptionDurationType.DAY_3:
				{
					return 3;
					break;
				}
				case SubscriptionDurationType.DAY_4:
				{
					return 4;
					break;
				}
				case SubscriptionDurationType.DAY_5:
				{
					return 5;
					break;
				}
				case SubscriptionDurationType.DAY_6:
				{
					return 6;
					break;
				}
				case SubscriptionDurationType.WEEK:
				{
					return 7;
					break;
				}
				default:
				{
					ApplicationErrors.add("type of subscription not set");
					return 0;
				}
			}
			
			return 0;
		}
	}
}