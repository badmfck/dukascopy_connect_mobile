package com.dukascopy.connect.sys.applicationShop.commodity 
{
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev
	 */
	public class CommodityType 
	{
		public static const TYPE_OIL:String = "OIL";
		static public const TYPE_GOLD:String = "GOLD";
		static public const TYPE_BTC:String = "BTC";
		static public const TYPE_GAS:String = "GAS";
		
		private var _value:String;
		
		public function CommodityType(value:String) 
		{
			// every avaliable type should bed added here to validate;
			/*if (value != TYPE_OIL &&
				value != TYPE_GOLD &&
				value != TYPE_GAS &&
				value != TYPE_BTC)
			{
				ApplicationErrors.add();
			}*/
			this._value = value;
		}
		
		public function get value():String 
		{
			return _value;
		}
	}
}