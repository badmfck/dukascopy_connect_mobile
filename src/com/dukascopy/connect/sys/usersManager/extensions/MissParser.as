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
	public class MissParser 
	{
		public function MissParser() 
		{
			
		}
		
		public function parse(data:Object):MissData {
			var result:MissData;
			
			if (valid(data)) {
				result = new MissData();
				
				if ("winner" in data && data.winner != null)
				{
					if (data.winner is Array && (data.winner as Array).length == 0)
					{
						return null;
					}
					
					if ("month" in data)
					{
						result.month = data.month;
					}
					if ("year" in data)
					{
						result.year = data.year;
					}
					if (data.winner && data.winner is Array && (data.winner as Array).length > 0)
					{
						data = data.winner[0];
						result.type = MissData.WINNER;
					}
				}
				result.user_uid = data.userUid;
				result.fxid = data.fxid;
				result.isMiss = data.isMiss;
				result.rank = data.rank;
				result.daySum = data.daySum;
				result.spent = data.spent;
				if (data.profile != null)
				{
					result.user = UsersManager.getUserByContactObject(data.profile);
					if (result.user != null)
					{
						result.user.setDataFromContactObject(data.profile);
					}
					if (result.isMiss == true)
					{
						result.user.missDC = true;
					}
				}
				else
				{
					return null;
				}
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