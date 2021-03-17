package com.dukascopy.connect.vo.users.adds {
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.businessListManager.BusinessListManager;
import com.dukascopy.connect.sys.contactsManager.ContactsManager;
import com.dukascopy.connect.sys.crypter.Crypter;
import com.dukascopy.connect.vo.DepartmentVO;

	/**
	 * @author Igor Bloom
	 */

	public class MemberVO {
		
		public var memberID:int;
		public var userUID:String;
		public var fxID:uint;
		public var phone:String;
		public var depID:int;
		public var fxName:String;
		public var _avatarURL:String;
		public var points:Array;
		public var city:String;
		public var companyPhone:String;
		public var name:String;

		private var department:DepartmentVO;
		private var entryPointsShorts:String;
		
		public function MemberVO(data:Object) {
			
			setData(data);
		}
		
		public function setData(data:Object):void 
		{
			if ("id" in data)
			{
				memberID = data.id;
			}
			
			userUID = data.uid;
			
			if ("fxid" in data)
			{
				fxID = data.fxid;
			}
			
			
			if(("phone" in data) && data.phone != null){
				//TODO: Crypter - нужно понять почему возвращается NaN
				var value:Number = Crypter.getNumberByBase(data.phone);
				phone = (isNaN(value)) ? null : String(value);
			}
			if ("companyPhone" in data)
			{
				companyPhone = data.companyPhone;
			}
			if ("department_id" in data)
			{
				depID = data.department_id;
			}
			name = data.name || "";
			
			if ("username" in data)
			{
				fxName = data.username;
			}
			else
			{
				fxName = "";
			}
			if ("avatar" in data)
			{
				_avatarURL = data.avatar;
			}
			
			
			//!TODO: хак, замена дурацкой пережатой заглушки от коммуны;
			if (_avatarURL && _avatarURL.indexOf("no_photo") != -1)
			{
				_avatarURL = null;
			}
			if (_avatarURL != null)
			{
				_avatarURL = _avatarURL.replace("http://www.dukascopy.com", "https://www.dukascopy.com");
			}
			if ("points" in data)
			{
				points = data.points;
			}
			if ("city" in data)
			{
				city = data.city;
			}
		}
		
		public function get avatarURL():String
		{
			if (!_avatarURL)
			{
				return null;
			}
			if (_avatarURL.indexOf("graph.facebook.com") != -1)
			{
				var userCode:Array = _avatarURL.split("/");
				if (userCode.length > 4)
				return "http://graph.facebook.com/" + userCode[3] + "/" + userCode[4];
			}
			return _avatarURL
		}
		
		public function getDepartment():DepartmentVO {
			if (department == null)
				ContactsManager.companyMembers.getDepByID(depID); /*department = BusinessListManager.getDepartment(depID);*/
			return department;
		}
		
		public function getEntryPointsShorts():String {
			if (entryPointsShorts == null)
				entryPointsShorts = BusinessListManager.getNamesOfEntryPointsAsString(points);
			return entryPointsShorts;
		}

		public function get uid():String {
			return userUID;
		}
	}
}