package com.dukascopy.connect.sys.applicationShop.product 
{
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev
	 */
	public class SubscriptionDurationType 
	{
		private var _value:String;
		
		static public const DAY:String = "DAY";
		static public const WEEK:String = "WEEK";
		static public const MOUNTH:String = "MNTH";
		static public const ONCE:String = "ONCE";
		static public const SESSION:String = "SESSION";
		static public const FREE:String = "FREE";
		static public const DAY_2:String = "DAY_2";
		static public const DAY_3:String = "DAY_3";
		static public const DAY_4:String = "DAY_4";
		static public const DAY_5:String = "DAY_5";
		static public const DAY_6:String = "DAY_6";
		
		public function SubscriptionDurationType(value:String) 
		{
			// type validation; 
			if (value != DAY &&
				value != WEEK &&
				value != MOUNTH &&
				value != ONCE &&
				value != SESSION &&
				value != FREE)
			{
				ApplicationErrors.add();
			}
			this._value = value;
		}
		
		public function get value():String 
		{
			return _value;
		}
	}
}