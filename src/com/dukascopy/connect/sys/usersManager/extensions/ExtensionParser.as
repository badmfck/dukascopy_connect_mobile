package com.dukascopy.connect.sys.usersManager.extensions 
{
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class ExtensionParser 
	{
		public function ExtensionParser() {
			
		}
		
		public function parse(data:Object):Extension {
			var result:Extension;
			
			if (valid(data)) {
				
				var type:ExtensionType;
				
				switch(data.code)
				{
					case 1:
					{
						type = new ExtensionType(ExtensionType.FLOWER_3)
						break;
					}
					case 2:
					{
						type = new ExtensionType(ExtensionType.FLOWER_4)
						break;
					}
					case 3:
					{
						type = new ExtensionType(ExtensionType.FLOWER_1)
						break;
					}
					case 4:
					{
						type = new ExtensionType(ExtensionType.FLOWER_2)
						break;
					}
				}
					
				result = new Extension(type);
				
				result.amount = data.amount;
				result.avatar = data.avatar;
				result.till = data.canceled;
				result.created = data.created;
				result.currency = data.currency;
				result.days = data.days;
				result.id = data.id;
				result.incognito = data.incognito;
				result.name = data.name;
				result.pavatar = data.pavatar;
				result.payer_uid = data.payer_uid;
				result.pname = data.pname;
				result.reason = data.reason;
				result.updated = data.updated;
				result.user_uid = data.user_uid;
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
			if (data.hasOwnProperty("amount") == false) {
				result = false;
			}
			
			if (data.hasOwnProperty("canceled") == false) {
				result = false;
			}
			//!TODO: all fields?;
			
			return result;
		}
	}
}