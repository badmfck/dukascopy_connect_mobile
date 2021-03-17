package com.dukascopy.connect.sys.applicationShop.product {
	
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev
	 */
	
	public class ProductType {
		
		public static const TYPE_PAID_CHANNEL_SUBSCRIPTION:String = "chatAccess";
		static public const TYPE_FLOWER:String = "typeFlower";
		static public const TYPE_PAID_CHANNEL:String = "typePaidChannel";
		
		private var _value:String;
		
		public function ProductType(value:String) {
			if (value != TYPE_PAID_CHANNEL_SUBSCRIPTION &&
				value != TYPE_PAID_CHANNEL &&
				value != TYPE_FLOWER)
				ApplicationErrors.add();
			this._value = value;
		}
		
		public function get value():String {
			return _value;
		}
	}
}