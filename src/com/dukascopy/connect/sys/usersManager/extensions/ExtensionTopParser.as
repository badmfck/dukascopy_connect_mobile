package com.dukascopy.connect.sys.usersManager.extensions 
{
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.vo.users.adds.UserGifts;
	import flash.profiler.profile;
	import flash.profiler.profile;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class ExtensionTopParser 
	{
		
		public function ExtensionTopParser() 
		{
			
		}
		
		public function parse(data:Object):ExtensionTopData {
			var result:ExtensionTopData;
			
			if (valid(data)) {
				result = new ExtensionTopData();
				
				result.amount = data.amount;
				result.code = data.code;
				result.days = data.days;
				result.requests = data.requests;
				result.user_uid = data.user_uid;
				result.user = UsersManager.getUserByContactObject(data.profile);
				
			}
			else {
				ApplicationErrors.add("wrong data format");
			}
			
			return result;
		}
		
		private function valid(data:Object):Boolean {
			var result:Boolean = true;
			
			//!TODO:;
			
			return result;
		}
	}
}