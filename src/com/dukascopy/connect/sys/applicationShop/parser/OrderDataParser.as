package com.dukascopy.connect.sys.applicationShop.parser 
{
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.applicationShop.Order;
	import com.dukascopy.connect.sys.applicationShop.product.ProductType;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev
	 */
	public class OrderDataParser 
	{
		public function OrderDataParser() 
		{
			
		}
		
		public function parse(data:Object):Order {
			var result:Order;
			
			if (valid(data)) {
				result = new Order();
				result.startTime = data.ctime;
				result.endTime = data.till;
				result.id = data.id;
				if ("item" in data && data.item != null)
				{
					result.product = new ShopProductDataParser().parse(data.item, new ProductType(data.productName));
				}
				if ("receiver" in data && data.receiver != null)
				{
					result.receiver = UsersManager.getUserByContactObject(data.receiver);
					result.receiver.incUseCounter();
				}
			}
			else {
				ApplicationErrors.add("wrong data format");
			}
			
			return result;
		}
		
		private function valid(data:Object):Boolean {
			var result:Boolean = true;
			if (data != null) {
				if (data.hasOwnProperty("ctime") == false) {
					result = false;
				}
				if (data.hasOwnProperty("till") == false) {
					result = false;
				}
				if (data.hasOwnProperty("id") == false) {
					result = false;
				}
				if (data.hasOwnProperty("productName") == false) {
					result = false;
				}
			}
			else {
				result = false;
			}
			
			return result;
		}
	}
}