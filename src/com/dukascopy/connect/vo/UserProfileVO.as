package com.dukascopy.connect.vo {
	
	import com.dukascopy.connect.data.UserBanData;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.type.UserType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.connect.vo.users.adds.UserBan911VO;
	import com.dukascopy.connect.vo.users.adds.UserMediaVO;
	import com.dukascopy.connect.vo.users.adds.ContactVO;
	import com.dukascopy.connect.vo.users.adds.MemberVO;
	import com.dukascopy.connect.vo.users.adds.PhonebookUserVO;
	import com.dukascopy.langs.Lang;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class UserProfileVO {
		
		public var preferredName:String;
		public var created:Number;
		
		private var _invited:Boolean;
		private var _userUID:String;
		
		private var contact:ContactVO;
		private var phoneBook:PhonebookUserVO;
		private var member:MemberVO;
		
		private var _customName:String;
		private var _customAvatarURL:String;
		private var _customFxId:uint = 0;
		private var _customFxName:String;
		public var media:UserMediaVO;
		private var _payRating:int = -1;
		
		public function UserProfileVO(userUID:String) {
			_userUID = userUID;
			if (uidExist() == true)
				UsersManager.registrateUserUID(_userUID);
		}
		
		public function set name(value:String):void {
			_customName = value;
		}
		
		public function get rawName():String {
			var nameValue:String;
			if (phoneBook != null)
				nameValue = phoneBook.name;
			if (nameValue == null) {
				if (member != null && member.name && member.name != "")
					nameValue = member.name;
				if (nameValue == null) {
					if (contact != null && contact.name && contact.name != "")
						nameValue = contact.name;
				}
			}
			if (nameValue != null)
				return nameValue;
			else if (_customName != null)
				return _customName;
			return "";
		}
		
		public function get name():String {
			if (uid == Auth.uid) {
				var self:String = Auth.hasFXName() ? Auth.getFXName() : Auth.username;
				return "(" + Lang.notebookName + ") " + self;
			}
			if (phoneBook != null && phoneBook.name) {
				return phoneBook.name;
			}
			
			var nameValue:String;
			
			if (preferredName) {
				nameValue = preferredName;
			}
			
			if (nameValue == null) {
				if (member != null && member.name && member.name != "") {
					nameValue = member.name;
				}
				if (nameValue == null) {
					if (contact != null) {
						if (contact.name && contact.name != "") {
							nameValue = contact.name;
						} else {
							if (contact.type == UserType.SHADOW && (contact.name == "" || !contact.name)) {
								if (!isNaN(contact.getPhone()) && contact.getPhone().toString() && contact.getPhone().toString().length > 5) {
									nameValue = "user " + contact.getPhone().toString();
								} else {
									nameValue = Lang.nameNotSet;
								}
							} else {
								nameValue = Lang.nameNotSet;
							}
						}
					}
				}
			}
			if (nameValue == null) {
				nameValue =  _customName;
			}
			if (nameValue != null)
			{
				if (!phoneBook || !phoneBook.phone || phoneBook.phone == "")
				{
					nameValue = TextUtils.checkForNumber(nameValue);
				}
				
				return nameValue;
			}
			return "";
		}
		
		public function get avatarLargeURL():String {
			var avatarPath:String;
			if (contact)
				avatarPath = contact.avatarURL;
			else if (phoneBook)
				avatarPath = phoneBook.avatarURL;
			else if (member)
				avatarPath = member.avatarURL;
			if (!avatarPath)
				avatarPath = _customAvatarURL;
			if (avatarPath) {
				var thumbFlag:String = "&thumb=1";
				if (avatarPath.indexOf(thumbFlag) == avatarPath.length - thumbFlag.length)
					avatarPath = avatarPath.slice(0, avatarPath.length - thumbFlag.length);
			}
			return avatarPath;
		}
		
		public function get avatarURL():String {
			if (phoneBook && phoneBook.avatarURL)
				return phoneBook.avatarURL;
			else if (contact && contact.avatarURL)
				return contact.avatarURL;
			else if (member && member.avatarURL)
				return member.avatarURL;
			return _customAvatarURL;
		}
		
		public function set avatarURL(value:String):void {
			
			if (value && value.indexOf("no_photo") == -1)
			{
				_customAvatarURL = value;
			}
		}
		
		public function get uid():String {
			if (phoneBook != null)
				return phoneBook.uid;
			return _userUID;
		}
		
		public function uidExist():Boolean {
			if (_userUID != null && _userUID != "" && _userUID != "0")
				return true;
			return false;
		}
		
		public function get phone():String {
			if (phoneBook)
				return phoneBook.phone;
			/*else if (contact && !isNaN(contact.getPhone()) && contact.getPhone().toString() != null)
				return contact.getPhone().toString();*/
			return null;
		}
		
		public function get fxName():String {
			if (contact)
				return contact.fxName;
			else if (phoneBook)
				return phoneBook.fxName;
			else if (member && member.fxName && member.fxName != "")
				return member.fxName;
			else if (_customFxName != null)
				return _customFxName;
			return null;
		}
		
		public function set fxName(value:String):void {
			_customFxName = value;
		}
		
		public function set fxId(value:uint):void {
			_customFxId = value;
		}
		
		public function get fxId():uint {
			if (contact)
				return contact.fxID;
			else if (phoneBook)
				return phoneBook.fxID;
			else if (member)
				return member.fxID;
			return _customFxId;
		}
		
		public function get invited():Boolean {
			if (phoneBook)
				return phoneBook.invited;
			return false;
		}
		
		public function get depID():int {
			if (member)
				return member.depID;
			return -1;
		}
		
		public function get city():String {
			if (member)
				return member.city;
			return null;
		}
		
		public function set phonebookData(value:PhonebookUserVO):void {
			phoneBook = value;
		}
		
		public function get phonebookData():PhonebookUserVO {
			return phoneBook;
		}
		
		public function get departmentInfo():String {
			if (member) {
				var depVO:DepartmentVO;
				if (Auth.company)
					depVO = Auth.company.getDepByID(depID);
				if (depVO)
					return depVO.short;
				if (city && city != "")
					return (depVO.short + ", " + city).toUpperCase();
			}
			return null;
		}
		
		public function set companyUserData(value:MemberVO):void {
			member = value
		}
		
		public function set contactData(value:ContactVO):void {
			contact = value;
		}
		
		public function get contactData():ContactVO {
			return contact;
		}
		
		public function get companyUserData():MemberVO {
			return member;
		}
		
		public function get payRating():int 
		{
			return _payRating;
		}
		
		public function set payRating(value:int):void 
		{
			_payRating = value;
		}
		
		public function hasPhone():Boolean {	
			if (phoneBook != null && phoneBook.phone != null)
				return true;
			if (contact != null && !isNaN(contact.getPhone()) && contact.getPhone() > 0)
				return true;
			return false;
		}
		
		public function isCompanyMember():Boolean {
			return member != null;
		}
	}
}