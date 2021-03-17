package com.dukascopy.connect.data.paidBan.dataParser 
{
	import com.dukascopy.connect.data.LocalAvatars;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.vo.users.adds.UserBan911VO;
	import com.dukascopy.langs.Lang;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class PaidBanParser 
	{
		public function PaidBanParser() {
			
		}
		
		public function parse(data:Object):UserBan911VO {
			var result:UserBan911VO;
			
			if (valid(data)) {
				result = new UserBan911VO();
				
				// mandatory fields;
				result.canceled = data.canceled;
				result.id = data.id;
				result.payer_uid = data.payer_uid;
				// full data additional fields;
				if (data.hasOwnProperty("amount") == true)
					result.amount = data.amount;
				if (data.hasOwnProperty("days") == true)
					result.days = data.days;
				if (data.hasOwnProperty("incognito") == true)
				{
					if (data.incognito is String && data.incognito != null) {
						if (data.incognito == "1") {
							result.incognito = true;
						}
						else if (data.incognito == "0") {
							result.incognito = false;
						}
						else if (data.incognito.toString() == "true") {
							result.incognito = true;
						}
					}
					else if (data.incognito is Boolean) {
						result.incognito = data.incognito;
					}
				}
				if (data.hasOwnProperty("reason") == true) {
					try	{
						var reasonData:Object = JSON.parse(data.reason);
						if (reasonData != null && reasonData.hasOwnProperty("id")) {
							result.reason = reasonData.id;
						}
						else {
							result.reason = data.reason;
						}
					}
					catch (e:Error) {
						result.reason = data.reason;
					}
				}
				if (data.hasOwnProperty("status") == true)
					result.status = data.status;
				if (data.hasOwnProperty("updated") == true)
					result.updated = data.updated;
				if (data.hasOwnProperty("created") == true)
					result.created = data.created;
				if (data.hasOwnProperty("user_uid") == true)
					result.user_uid = data.user_uid;
				if (data.hasOwnProperty("avatar") == true)
					result.avatar = data.avatar;
				if (data.hasOwnProperty("name") == true)
					result.name = data.name;
				
				if (data.hasOwnProperty("pname") == true)
					result.payer_Name = data.p_name;
				if (data.hasOwnProperty("pavatar") == true)
					result.payer_Avatar = data.p_avatar;
				if (result.incognito == true) {
					result.payer_Avatar = LocalAvatars.SECRET;
					result.payer_Name = Lang.textIncognito;
				}
					
				if (data.hasOwnProperty("users") == true && data.users != null && data.users is Array && (data.users as Array).length > 0) {
					var l:int = (data.users as Array).length;
					for (var i:int = 0; i < l; i++) {
						if ((data.users as Array)[i].uid == result.payer_uid) {
							result.payer = UsersManager.getUserByContactObject((data.users as Array)[i]);
						}
					}
				}
				
				if (data.hasOwnProperty("reqID") == true)
					result.reqID = data.reqID;
				
				if (data.hasOwnProperty("payHash") == true)
					result.payHash = data.payHash;
			}
			else {
				ApplicationErrors.add("wrong data format");
			}
			
			return result;
		}
		
		private function valid(data:Object):Boolean {
			var result:Boolean = true;
			if (data != null) {
				if (data.hasOwnProperty("canceled") == false) {
					result = false;
				}
				if (data.hasOwnProperty("id") == false) {
					result = false;
				}
				if (data.hasOwnProperty("payer_uid") == false) {
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