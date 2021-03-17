package com.dukascopy.connect.vo.users {
	
	import adobe.utils.ProductManager;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.paidBan.PaidBanProtectionData;
	import com.dukascopy.connect.data.paidBan.dataParser.PaidBanParser;
	import com.dukascopy.connect.data.paidBan.dataParser.PaidBanProtectionDataParser;
	import com.dukascopy.connect.data.paidBan.dataParser.PaidBanProtectionDataParser;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.crypter.Crypter;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.sys.usersManager.extensions.Extension;
	import com.dukascopy.connect.sys.usersManager.extensions.ExtensionType;
	import com.dukascopy.connect.sys.usersManager.extensions.UserExtensionsParser;
	import com.dukascopy.connect.utils.Base64Modified;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.connect.vo.ChatMessageVO;
	import com.dukascopy.connect.vo.ChatVO;
	import com.dukascopy.connect.vo.StandartVO;
	import com.dukascopy.connect.vo.users.adds.UserBan911VO;
	import com.dukascopy.connect.vo.users.adds.UserGifts;
	import com.dukascopy.connect.vo.users.adds.UserMediaVO;
	import com.dukascopy.connect.vo.users.adds.PhonebookUserVO;
	import flash.utils.ByteArray;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class UserVO extends StandartVO {
		
		static private const EMPTY_NAME:String = "fiF+";
		
		static public const TYPE_USER:String = "user";
		static public const TYPE_SHADOW:String = "shadow";
		static public const TYPE_TRADER:String = "trader";
		static public const TYPE_LDAP:String = "ldap";
		static public const TYPE_PAYER:String = "payer";
		static public const TYPE_BOT:String = "bot";
		
		static public const GENDER_MALE:String = "male";
		static public const GENDER_FEMALE:String = "female";
		
		static public const LABELS_TYPE_TOAD:String = "toad";
		
		
		
		// DATA FROM SERVER
		private var _hash:String;
		private var _uid:String;
		private var _login:String;
		private var _name:String;
		private var _created:Number;
		private var _type:String;
		private var _avatar:String;
		private var _gender:String;
		private var _newbie:Boolean;
		private var _payRating:int = 0;//int.MIN_VALUE;
		private var _age:int = int.MIN_VALUE;
		private var _dateOfBirth:Number;
		private var _labels:Array; // [ { id:int, type:String, img:int, start:Number, stop:Number }, ..., n]
		private var _immunity:Array; // { { }, ..., n }
		private var _atacks:Array; // { { }, ..., n }
		private var _missDC:Boolean;
		private var _geo:Array; // ["Ukrain", "UA", "UKR", "380"]
		private var _phone:String;
		private var _phoneName:String;
		private var _country:String;
		private var _md5sum:String;
		private var _sysBan:Boolean;
		private var _ban911:Boolean;
		// GENERATED FIELDS
		private var _displayName:String;
		private var _avatarSmall:String;
		private var _avatarProfile:String;
		// GENERATED VOS
		private var _userFXCommVO:UserFXCommVO;
		private var _userCompanyVO:UserCompanyVO;
		private var _mediaVO:UserMediaVO;
		private var _ban911VO:UserBan911VO;
		private var _paidPanProtection:PaidBanProtectionData;
		private var _gifts:UserGifts;
		// SETTED FLAGS
		private var _newbieSetted:Boolean = false;
		private var _missDCSetted:Boolean = false;
		private var _settedFromContact:Boolean = false;
		private var _settedFromQuestionUser:Boolean = false;
		private var _settedFromChatUser:Boolean = false;
		private var _settedFromMessage:Boolean = false;
		private var _setted:Boolean = false;
		// OTHER FIELDS
		
		
		private var useCounter:int;
		public var disposed:Boolean = false;
		
		public function UserVO() { }
		
		public function setData(data:Object):void {
			_setted = true;
			_hash = data.hash;
			_uid = data.uid;
			if (_uid == Config.NOTEBOOK_USER_UID && Auth.myProfile != null)
				data.avatar = Auth.myProfile.getAvatarURL();
			_login = data.username;
			_created = data.created;
			_type = data.type;
			_newbie = data.newbie;
			_avatar = data.avatar;
			if ("labels" in data == true)
				_labels = data.labels;
			if ("immunity" in data == true)
				_immunity = data.immunity;
			if ("atacks" in data == true)
				_atacks = data.atacks;
			if ("payRating" in data == true)
				_payRating = data.payRating;
			if ("gender" in data == true)
				_gender = data.gender;
			if ("md5sum" in data == true)
				_md5sum = data.md5sum;
			
			if ("age" in data == true)
				_age = data.age;
			if ("name" in data == true && data.name != TextUtils.NULL + " " + TextUtils.NULL) {
				
				_name = data.name;
				if (_name != null){
					_name.replace(TextUtils.NULL, "");
				}
			}
			if ("missDC" in data == true)
				_missDC = data.missDC;
			if ("geo" in data == true)
				_geo = data.geo;
			
			if ("fxid" in data == true) {
				_userFXCommVO ||= new UserFXCommVO(data.fxid);
				if ("fxcomm" in data == true && data.fxcomm != null)
					_userFXCommVO.setData(data.fxcomm);
			} else if ("fxcomm" in data == true && data.fxcomm != null) {
				var tmp:String;
				var tmpN:String = "";
				var tmpS:String = "";
				if ("name" in data.fxcomm && data.fxcomm.name != null && data.fxcomm.name != EMPTY_NAME)
					tmpN = decodeShadowName(data.fxcomm.name);
				if ("surname" in data.fxcomm && data.fxcomm.surname != null && data.fxcomm.surname != EMPTY_NAME)
					tmpS = decodeShadowName(data.fxcomm.surname);
				if (tmpN != "" && tmpS != "")
					tmp = tmpN + " " + tmpS;
				else
					tmp = tmpN + tmpS;
				if (tmp != "") {
					changed = true;
					_name = tmp;
				}
			}
			
			_ban911 = false;
			_sysBan = false;
			
			if ("ban911" in data == true)
				_ban911 = data.ban911;
			if ("sysBan" in data == true)
				_sysBan = data.sysBan;
			
			_displayName = null;
			
			fillPaidBanData(data);
			fillGiftsData(data);
			fillPaidBanProtection(data);
			/*if ("companyMemberID" in _data == true) {
				_memberID = _data.companyMemberID;
				if ("member" in _data == true) {
					_memberData = _data.member;
					if ("LDAPname" in _memberData == true)
						_memberName = _memberData.LDAPname;
					if ("companyLogin" in _memberData == true)
						_memberLogin = _memberData.companyLogin;
					if ("dep" in _memberData == true)
						_memberDepartment = _memberData.dep;
					if ("dob" in _memberData == true)
						_dateOfBirth = _memberData.dob;
					if ("city" in _memberData == true)
						_memberCity = _memberData.city;
					if ("phone" in _memberData == true)
						_memberPhone = _memberData.phone;
				}
			}*/
			
			clearGeneratedData();
		}
		
		public function get ban911():Boolean 
		{
			return _ban911;
		}
		
		public function get sysBan():Boolean 
		{
			return _sysBan;
		}

		public function setPayRating(val:int):void{
			_payRating=val;
		}
		
		public function fillPaidBanData(data:Object):void {
			if ("paidBan" in data && data.paidBan != null) {
				var parser:PaidBanParser = new PaidBanParser();
				if (_ban911VO != null) {
					_ban911VO.update(parser.parse(data.paidBan));
				}
				else {
					_ban911VO = parser.parse(data.paidBan);
				}
			}
		}
		
		public function fillGiftsData(data:Object):void {
			if ("gifts" in data && data.gifts != null) {
				var parser:UserExtensionsParser = new UserExtensionsParser();
				if (_gifts != null) {
					_gifts.update(parser.parse(data.gifts));
				}
				else {
					_gifts = parser.parse(data.gifts);
				}
			}
			/*_gifts = new UserGifts();
			var extension:Extension = new Extension(new ExtensionType(ExtensionType.FLOWER_3));
			_gifts.addExtension(extension);*/
		}
		
		public function fillPaidBanProtection(data:Object):void {
			if ("paidProtection" in data && data.paidProtection != null) {
				var protectionDataParser:PaidBanProtectionDataParser = new PaidBanProtectionDataParser();
				_paidPanProtection = protectionDataParser.parse(data.paidProtection);
				protectionDataParser = null;
			}
		}
		
		public function setDataFromPhonebookVO(puVO:PhonebookUserVO):void {
			_phone = puVO.phone;
			if (_phone == "")
				_phone = null;
			_phoneName = puVO.name;
			if (_phoneName == "")
				_phoneName = null;
		}
		
		public function setDataFromPhonebookObject(data:Object):Boolean {
			changed = false;
			_phoneName = fillFieldObject(_phoneName, data, "name") as String;
			_phone = fillFieldObject(_phone, data, "phone") as String;
			_displayName = null;
			return changed;
		}
		
		public function setDataFromMessageObject(data:ChatMessageVO):void {
			if (_uid != null)
				return;
			_uid = fillFieldObject(_uid, data, "userUID") as String;
			if (_uid != null && _uid.length != 0 && (_uid.charAt(0) == "!" || _uid == "WgDNWdIEW4I6IsWg"))
				_type = TYPE_BOT;
			_login = fillFieldObject(_login, data, "name") as String;
			_avatar = fillFieldObject(_avatar, data, "avatar") as String;
		}
		
		public function setDataFromBanObject(data:UserBan911VO):void {
			if (_uid != null && _uid != data.user_uid)
				return;
			_uid = fillFieldObject(_uid, data, "user_uid") as String;
			if (_uid != null && _uid.length != 0 && (_uid.charAt(0) == "!" || _uid == "WgDNWdIEW4I6IsWg"))
				_type = TYPE_BOT;
			_avatar = fillFieldObject(_avatar, data, "avatar") as String;
			_name = fillFieldObject(_name, data, "name") as String;
		}
		
		public function setDataFromExtesnsionObject(data:Extension):void {
			if (_uid != null && _uid != data.user_uid)
				return;
			_uid = fillFieldObject(_uid, data, "user_uid") as String;
			if (_uid != null && _uid.length != 0 && (_uid.charAt(0) == "!" || _uid == "WgDNWdIEW4I6IsWg"))
				_type = TYPE_BOT;
			_avatar = fillFieldObject(_avatar, data, "avatar") as String;
			_name = fillFieldObject(_name, data, "name") as String;
		}
		
		public function setDataFromBanPayerObject(data:UserBan911VO):void {
			if (_uid != null)
				return;
			_uid = fillFieldObject(_uid, data, "payer_uid") as String;
			if (_uid != null && _uid.length != 0 && (_uid.charAt(0) == "!" || _uid == "WgDNWdIEW4I6IsWg"))
				_type = TYPE_BOT;
			_avatar = fillFieldObject(_avatar, data, "pavatar") as String;
			_name = fillFieldObject(_name, data, "pname") as String;
		}
		
		public function setDataFromBanProtectionObject(data:PaidBanProtectionData):void {
			if (_uid != null && _uid != data.user_uid)
				return;
			if (data.user_uid != null) {
				_uid = fillFieldObject(_uid, data, "user_uid") as String;
			}
			if (_uid != null && _uid.length != 0 && (_uid.charAt(0) == "!" || _uid == "WgDNWdIEW4I6IsWg"))
				_type = TYPE_BOT;
			_avatar = fillFieldObject(_avatar, data, "avatar") as String;
			_name = fillFieldObject(_name, data, "name") as String;
		}
		
		public function setDataFromContactObject(data:Object):Boolean {
			if (_hash != null)
				return false;
			if (_settedFromContact == true)
				return false;
			_settedFromContact = true;
			changed = false;
			_uid = fillFieldObject(_uid, data, "uid") as String;
			
			_login = fillFieldObject(_login, data, "username") as String;
			_created = fillFieldNumber(_created, data, "created");
			_type = fillFieldObject(_type, data, "type") as String;
			_immunity = fillFieldObject(_immunity, data, "immunity") as Array;
			_labels = fillFieldObject(_labels, data, "labels") as Array;
			_age = fillFieldINT(_age, data, "age");
			_dateOfBirth = fillFieldNumber(_dateOfBirth, data, "dob");
			_payRating = fillFieldINT(_payRating, data, "payRating");
			_name = fillFieldObject(_name, data, "name") as String;
			_gender = fillFieldObject(_gender, data, "gender") as String;
			_country = fillFieldObject(_country, data, "country") as String;
			var res:int;
			res = fillFieldBoolean(_newbie, data, "newbie", false, _newbieSetted);
			if (res != -1) {
				_newbieSetted = true;
				_newbie = res == 1;
			}
			res = fillFieldBoolean(_missDC, data, "missDC", false, _missDCSetted);
			if (res != -1) {
				_missDCSetted = true;
				_missDC = res == 1;
			}
			var avatarOld:String = _avatar;
			_avatar = fillFieldObject(_avatar, data, "avatar") as String;
			if (avatarOld != _avatar) {
				_avatarSmall = null;
				_avatarProfile = null;
			}
			if ("fxid" in data == true) {
				_userFXCommVO ||= new UserFXCommVO(data.fxid);
				var fxChanged:Boolean;
				if ("fxcomm" in data == true && data.fxcomm != null)
					fxChanged = _userFXCommVO.setData(data.fxcomm);
				if (fxChanged == true)
					changed = true;
			} else if ("fxcomm" in data == true && data.fxcomm != null) {
				var tmp:String;
				var tmpN:String = "";
				var tmpS:String = "";
				if ("name" in data.fxcomm && data.fxcomm.name != null && data.fxcomm.name != EMPTY_NAME)
					tmpN = decodeShadowName(data.fxcomm.name);
				if ("surname" in data.fxcomm && data.fxcomm.surname != null && data.fxcomm.surname != EMPTY_NAME)
					tmpS = decodeShadowName(data.fxcomm.surname);
				if (tmpN != "" && tmpS != "")
					tmp = tmpN + " " + tmpS;
				else
					tmp = tmpN + tmpS;
				if (tmp != "") {
					changed = true;
					_name = tmp;
				}
			}
			fillPaidBanData(data);
			fillGiftsData(data);
			_displayName = null;
			return changed;
		}
		
		public function setDataFromQuestionUserObject(data:Object):Boolean {
			if (_hash != null)
				return false;
			if (_settedFromQuestionUser == true) {
				_country = fillFieldObject(_country, data, "country") as String;
				return false;
			}
			_settedFromQuestionUser = true;
			
			changed = false;
			
			_uid = fillFieldObject(_uid, data, "uid") as String;
			
			_login = fillFieldObject(_login, data, "username") as String;
			_created = fillFieldNumber(_created, data, "created");
			_type = fillFieldObject(_type, data, "type") as String;
			_immunity = fillFieldObject(_immunity, data, "immunity") as Array;
			_labels = fillFieldObject(_labels, data, "labels") as Array;
			_age = fillFieldINT(_age, data, "age");
			_payRating = fillFieldINT(_payRating, data, "payRating", true);
			_name = fillFieldObject(_name, data, "name") as String;
			_gender = fillFieldObject(_gender, data, "gender") as String;
			_country = fillFieldObject(_country, data, "country") as String;
			var res:int;
			res = fillFieldBoolean(_newbie, data, "newbie", false, _newbieSetted);
			if (res != -1) {
				_newbieSetted = true;
				_newbie = res == 1;
			}
			res = fillFieldBoolean(_missDC, data, "missDC", false, _missDCSetted);
			if (res != -1) {
				_missDCSetted = true;
				_missDC = res == 1;
			}
			var avatarOld:String = _avatar;
			_avatar = fillFieldObject(_avatar, data, "avatar") as String;
			if (avatarOld != _avatar) {
				_avatarSmall = null;
				_avatarProfile = null;
			}
			if ("fxid" in data == true) {
				_userFXCommVO ||= new UserFXCommVO(data.fxid);
				var fxChanged:Boolean;
				if ("fxcomm" in data == true && data.fxcomm != null)
					fxChanged = _userFXCommVO.setData(data.fxcomm);
				if (fxChanged == true)
					changed = true;
			} else if ("fxcomm" in data == true && data.fxcomm != null) {
				var tmp:String;
				var tmpN:String = "";
				var tmpS:String = "";
				if ("name" in data.fxcomm && data.fxcomm.name != null && data.fxcomm.name != EMPTY_NAME)
					tmpN = decodeShadowName(data.fxcomm.name);
				if ("surname" in data.fxcomm && data.fxcomm.surname != null && data.fxcomm.surname != EMPTY_NAME)
					tmpS = decodeShadowName(data.fxcomm.surname);
				if (tmpN != "" && tmpS != "")
					tmp = tmpN + " " + tmpS;
				else
					tmp = tmpN + tmpS;
				if (tmp != "") {
					changed = true;
					_name = tmp;
				}
			}
			fillPaidBanData(data);
			fillGiftsData(data);
			fillPaidBanProtection(data);
			_displayName = null;
			return changed;
		}
		
		public function setDataFromChatUserObject(data:Object):Boolean {
			if (_hash != null)
				return false;
			if (_settedFromChatUser == true)
				return false;
			_settedFromChatUser = true;
			changed = false;
			
			_uid = fillFieldObject(_uid, data, "uid") as String;
			
			_login = fillFieldObject(_login, data, "username") as String;
			_created = fillFieldNumber(_created, data, "created");
			_type = fillFieldObject(_type, data, "type") as String;
			_immunity = fillFieldObject(_immunity, data, "immunity") as Array;
			_labels = fillFieldObject(_labels, data, "labels") as Array;
			_age = fillFieldINT(_age, data, "age");
			_payRating = fillFieldINT(_payRating, data, "payRating");
			_name = fillFieldObject(_name, data, "name") as String;
			_gender = fillFieldObject(_gender, data, "gender") as String;
			
			var res:int;
			res = fillFieldBoolean(_newbie, data, "newbie", false, _newbieSetted);
			if (res != -1) {
				_newbieSetted = true;
				_newbie = res == 1;
			}
			res = fillFieldBoolean(_missDC, data, "missDC", false, _missDCSetted);
			if (res != -1) {
				_missDCSetted = true;
				_missDC = res == 1;
			}
			var avatarOld:String = _avatar;
			_avatar = fillFieldObject(_avatar, data, "avatar") as String;
			if (avatarOld != _avatar) {
				_avatarSmall = null;
				_avatarProfile = null;
			}
			if ("fxid" in data == true) {
				_userFXCommVO ||= new UserFXCommVO(data.fxid);
				var fxChanged:Boolean;
				if ("fxcomm" in data == true && data.fxcomm != null)
					fxChanged = _userFXCommVO.setData(data.fxcomm);
				if (fxChanged == true)
					changed = true;
			} else if ("fxcomm" in data == true && data.fxcomm != null) {
				var tmp:String;
				var tmpN:String = "";
				var tmpS:String = "";
				if ("name" in data.fxcomm && data.fxcomm.name != null && data.fxcomm.name != EMPTY_NAME)
					tmpN = decodeShadowName(data.fxcomm.name);
				if ("surname" in data.fxcomm && data.fxcomm.surname != null && data.fxcomm.surname != EMPTY_NAME)
					tmpS = decodeShadowName(data.fxcomm.surname);
				if (tmpN != "" && tmpS != "")
					tmp = tmpN + " " + tmpS;
				else
					tmp = tmpN + tmpS;
				if (tmp != "") {
					changed = true;
					_name = tmp;
				}
			}
			if ("cm" in data && data.cm != null && data.cm != false) {
				var companyChanged:Boolean;
				_userCompanyVO ||= new UserCompanyVO();
				companyChanged = _userCompanyVO.setDataFromChatUser(data.cm);
				if (companyChanged == true)
					changed = true;
			}
			fillPaidBanData(data);
			fillGiftsData(data);
			_displayName = null;
			return changed;
		}
		
		public function setDataFromCallUserObject(data:Object):Boolean {
			return setDataFromChatUserObject(data);
		}
		
		private function decodeShadowName(val:String):String {
			var recievedBytesName:ByteArray = Base64Modified.decode(val);
			recievedBytesName.position = 0;
			return recievedBytesName.readUTFBytes(recievedBytesName.length);
		}
		
		public function clearGeneratedData():void {
			_avatarSmall = null;
			_avatarProfile = null;
			_displayName = null;
		}
		
		public function getDisplayName():String {
			if (_displayName != null)
				return _displayName;
			_displayName = _phoneName;
			if (_userCompanyVO != null) {
				if (_displayName == null || _displayName.length == 0)
					_displayName = _userCompanyVO.name;
			}
			if (_userFXCommVO != null) {
				if (_displayName == null || _displayName.length == 0)
					_displayName = _userFXCommVO.name;
			}
			if (_displayName == null || _displayName.length == 0)
				_displayName = TextUtils.checkForNumber(_name);
			if (_displayName == null || _displayName.length == 0)
				_displayName = _login;
			if (_displayName == null)
				_displayName = "";
			return _displayName;
		}
		
		public function getAvatarURL():String {
			if (_avatarSmall != null) {
				if (_avatarSmall == "")
					return null;
				return _avatarSmall;
			}
			_avatarSmall = "";
			if (_avatar != null && _avatar.indexOf("no_photo") == -1)
				_avatarSmall = UsersManager.getSmallUserAvatarURL(_avatar);
			if (_avatarSmall == "")
				return null;
			return _avatarSmall;
		}
		
		public function getAvatarURLProfile(size:int):String {
			if (_avatarProfile != null) {
				if (_avatarProfile == "")
					return null;
			}
			_avatarProfile = "";
			if (_avatar != null)
				if (_avatar.indexOf("no_photo") == -1)
					_avatarProfile = UsersManager.getAvatarImage(this, _avatar, size, 3, false);
			if (_avatarProfile == "")
				return null;
			return _avatarProfile;
		}
		
		public function get hash():String { return _hash; }
		public function get uid():String { return (_uid == null) ? "" : _uid; }
		public function get login():String { return (_login == null) ? "" : _login; }
		public function get created():Number { return (isNaN(_created) == true) ? 0 : _created; }
		public function get phone():String { return (_phone == null) ? "" : _phone; }
		public function get type():String { return (_type == null) ? "" : _type; }
		public function get payRating():int { return (_payRating == int.MIN_VALUE) ? 0 : (_payRating == -1) ? 0 : _payRating; }
		public function get fxID():int { return (_userFXCommVO == null) ? 0 : _userFXCommVO.id; }
		public function get fxFN():String { return (_userFXCommVO == null) ? "" : _userFXCommVO.firstname; }
		public function get fxLN():String { return (_userFXCommVO == null) ? "" : _userFXCommVO.lastname; }
		public function get phoneName():String { return (_phoneName == null) ? "" : _phoneName; }
		public function get newbie():Boolean { return _newbie; }
		public function get missDC():Boolean { return _missDC; }
		
		public function set missDC(value:Boolean):void 
		{
			_missDC = value;
		}
		public function get gender():String { return (_gender == null) ? "" : _gender; }
		public function get country():String { return (_country == null) ? "" : _country; }
		public function get age():int { return (_age != int.MIN_VALUE) ? _age : 0 }
		public function get ban911VO():UserBan911VO { return _ban911VO; }
		
		public function get media():UserMediaVO {	return _mediaVO; }
		public function set media(value:UserMediaVO):void {	_mediaVO = value; }
		
		public function set ban911VO(value:UserBan911VO):void {	_ban911VO = value; }
			
		public function get setted():Boolean { return _setted; }
		
		public function get paidPanProtection():PaidBanProtectionData {	return _paidPanProtection; }
		public function set paidPanProtection(value:PaidBanProtectionData):void { _paidPanProtection = value; }
		
		public function dispose(imedeately:Boolean = false):Boolean {
			if (imedeately == true) {
				disposeContinue();
				return true;
			}
			useCounter--;
			if (useCounter != 0)
				return false;
			disposeContinue();
			return true;
		}
		
		public function get md5sum():String {
			if (_md5sum == null)
				return "";
			return _md5sum;
		}
		
		private function disposeContinue():void {
			if (_userFXCommVO != null)
				_userFXCommVO.dispose();
			_userFXCommVO = null;
			if (_userCompanyVO != null)
				_userCompanyVO.dispose();
			_userCompanyVO = null;
			if (_mediaVO != null)
				_mediaVO.dispose();
			_mediaVO = null;
			if (_ban911VO != null)
				_ban911VO.dispose();
			_ban911VO = null;
			
			_hash = null;
			_uid = null;
			_login = null;
			_name = null;
			_created = NaN;
			_type = null;
			_avatar = null;
			_gender = null;
			_payRating = 0;
			_age = NaN;
			_dateOfBirth = NaN;
			_labels = null;
			_immunity = null;
			_atacks = null;
			_geo = null;
			_phone = null;
			_phoneName = null;
			_country = null;
			
			_displayName = null;
			_avatarSmall = null;
			_avatarProfile = null;
			
			disposed = true;
		}
		
		public function incUseCounter():void {
			useCounter++;
		}
		
		public function updateRating(val:int):void {
			_payRating = val;
		}
		
		public function addExtension(extension:Extension):void 
		{
			if (_gifts == null)
			{
				_gifts = new UserGifts();
			}
			_gifts.addExtension(extension);
		}
		
		public function addGiftData(data:Object):void 
		{
			var parser:UserExtensionsParser = new UserExtensionsParser();
			if (_gifts != null) {
				_gifts.update(parser.parse(data));
			}
			else {
				_gifts = parser.parse(data);
			}
		}
		
		public function get gifts():UserGifts 
		{
			return _gifts;
		}
		
		public function get avatarURL():String {
			return getAvatarURL();
		}
	}
}