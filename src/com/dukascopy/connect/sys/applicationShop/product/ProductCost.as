package com.dukascopy.connect.sys.applicationShop.product 
{
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class ProductCost 
	{
		public var value:Number;
		public var currency:String;
		
		public function ProductCost(value:Number, currency:String) {
			this.value = value;
			this.currency = currency;
		}
	}
}