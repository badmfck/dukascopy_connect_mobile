package com.dukascopy.connect.data.paidBan.dataParser 
{
	import com.dukascopy.connect.data.paidBan.config.PaidBanConfig;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.applicationShop.product.ProductCost;
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	public class PaidBanConfigParser 
	{
		public function PaidBanConfigParser() {
			
		}
		
		public function parse(data:Object):PaidBanConfig {
			var result:PaidBanConfig;
			
			if (valid(data)) {
				result = new PaidBanConfig();
				result.protect = new ProductCost(data.protect[0], data.protect[1]);
				result.remove = new ProductCost(data.remove[0], data.remove[1]);
				result.setCost = new ProductCost(data.set[0], data.set[1]);
				result.setAsAnon = new ProductCost(data.setAsAnon[0], data.setAsAnon[1]);
			}
			else {
				ApplicationErrors.add("wrong data format");
			}
			
			return result;
		}
		
		private function valid(data:Object):Boolean {
			var result:Boolean = true;
			if (data == null) {
				result = false;
			}
			if (data.hasOwnProperty("protect") == false || data.protect == null || (data.protect is Array) == false || (data.protect as Array).length != 2) {
				result = false;
			}
			if (data.hasOwnProperty("remove") == false || data.remove == null || (data.remove is Array) == false || (data.remove as Array).length != 2) {
				result = false;
			}
			if (data.hasOwnProperty("set") == false || data.set == null || (data.set is Array) == false || (data.set as Array).length != 2) {
				result = false;
			}
			if (data.hasOwnProperty("setAsAnon") == false || data.setAsAnon == null || (data.setAsAnon is Array) == false || (data.setAsAnon as Array).length != 2) {
				result = false;
			}
			
			return result;
		}
	}
}