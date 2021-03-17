package com.dukascopy.connect.data.paidBan.dataParser 
{
	import com.dukascopy.connect.data.paidBan.PaidBanProtectionData;
	import com.dukascopy.connect.data.paidBan.config.PaidBanConfig;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class PaidBanProtectionDataParser 
	{
		public function PaidBanProtectionDataParser() {
			
		}
		
		public function parse(data:Object):PaidBanProtectionData {
			var result:PaidBanProtectionData;
			
			if (valid(data)) {
				result = new PaidBanProtectionData();
				result.canceled = data.canceled;
				result.id = data.id;
				result.payer_uid = data.payer_uid;
				
				if (data.hasOwnProperty("name") == true) {
					result.name = data.name;
				}
				
				if (data.hasOwnProperty("user_uid") == true) {
					result.user_uid = data.user_uid;
				}
				
				if (data.hasOwnProperty("created") == true) {
					result.created = data.created;
				}
				
				if (data.hasOwnProperty("days") == true) {
					result.days = data.days;
				}
				
				if (data.hasOwnProperty("avatar") == true) {
					result.avatar = data.avatar;
				}
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
			if (data.hasOwnProperty("canceled") == false) {
				result = false;
			}
			if (data.hasOwnProperty("id") == false) {
				result = false;
			}
			if (data.hasOwnProperty("payer_uid") == false || data.payer_uid == null) {
				result = false;
			}
			
			return result;
		}
	}
}