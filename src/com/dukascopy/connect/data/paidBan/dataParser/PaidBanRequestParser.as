package com.dukascopy.connect.data.paidBan.dataParser 
{
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.usersManager.paidBan.PaidBan;
	import com.dukascopy.connect.vo.users.adds.UserBan911VO;
	import com.dukascopy.connect.vo.users.adds.UserBan911VO;
	/**
	 * ...
	 * @author ...
	 */
	public class PaidBanRequestParser 
	{
		
		public function PaidBanRequestParser() {
			
		}
		
		public function parse(data:Object):UserBan911VO {
			var result:UserBan911VO;
			
			if (valid(data)) {
				if (data.status == PaidBan.SERVER_STATUS_PAID) {
					var parser:PaidBanParser = new PaidBanParser();
					result = parser.parse(data.info);
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
			if (data.hasOwnProperty("status") == false || data.status == null) {
				result = false;
			}
			if (data.hasOwnProperty("info") == false || data.info == null) {
				result = false;
			}
			
			return result;
		}
	}
}