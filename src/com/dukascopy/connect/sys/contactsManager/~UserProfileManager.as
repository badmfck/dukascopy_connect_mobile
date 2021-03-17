package com.dukascopy.connect.sys.contactsManager 
{
	import com.adobe.crypto.MD5;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.errors.ApplicationError;
	import com.dukascopy.connect.sys.phonebookManager.PhonebookManager;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.vo.CallsHistoryItemVO;
	import com.dukascopy.connect.vo.ChatMessageVO;
	import com.dukascopy.connect.vo.users.adds.ContactVO;
	import com.dukascopy.connect.vo.users.adds.MemberVO;
	import com.dukascopy.connect.vo.users.adds.PhonebookUserVO;
	import com.dukascopy.connect.vo.UserProfileVO;
	import com.telefision.sys.signals.Signal;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class UserProfileManager 
	{ 
		static public var S_USER_PROFILE_UPDATE:Signal = new Signal('ChatManager.S_USER_PROFILE_UPDATE');
		
		static private var users:Dictionary;
		static private var initialized:Boolean;
		
		public function UserProfileManager() 
		{
			
		}
		
		public static function getUserData(value:Object, addToList:Boolean = true):UserProfileVO
		{	
			if (value == null)
				return null;
			checkInitialization();
			
			var userUID:String;
			var userKey:String;
		//	uid = "WMWxDXW5DLWI"
			if (value is String)
			{
				// value is UID;
				userUID = String(value);
				userKey = String(value);
				addToList = false;
			}
			else if (value is PhonebookUserVO)
			{
				if ((value as PhonebookUserVO).uid != null && (value as PhonebookUserVO).uid != "" && (value as PhonebookUserVO).uid != "0")
				{
					userUID = (value as PhonebookUserVO).uid;
					userKey = (value as PhonebookUserVO).uid;
				}
				else
				{
					userKey = value.hash;
				}
			}
			else if (value is ContactVO)
			{
				userUID = (value as ContactVO).uid;
				userKey = (value as ContactVO).uid;
			}
			
			else if (value is MemberVO)
			{
				userUID = (value as ContactVO).uid;
				userKey = (value as ContactVO).uid;
			}
			else if (value is ChatMessageVO)
			{
				userUID = (value as ChatMessageVO).userUID;
				userKey = (value as ChatMessageVO).userUID;
			}
			else if (value is CallsHistoryItemVO)
			{
				userUID = (value as CallsHistoryItemVO).userUID;
				userKey = (value as CallsHistoryItemVO).userUID;
			}
			else if (value is UserProfileVO)
			{
				userUID = (value as UserProfileVO).uid;
				
				if (userUID != null && users[userUID] == null && addToList == true)
				{
					users[userUID] = value;
				}
				return value as UserProfileVO;
			}
			else if (value is Object && ("name" in value) && ("uid" in value))
			{
				//CHAT USER FROM chat.users
				userUID = value.uid;
				userKey = value.uid;
			}
			else
			{
		//		throw new ApplicationError(ApplicationError.USER_DATA_MANAGER_WRONG_DATA);
			}
			
			if (users[userKey] == null)
			{
				var resultUserUID:String = userUID;
				if ((value is PhonebookUserVO) && (value as PhonebookUserVO).uid == "")
				{
					resultUserUID = "";
				}
				
				var item:UserProfileVO = new UserProfileVO(resultUserUID);
				if (addToList)
				{
					users[userKey] = item;
				}
				if (userUID == null)
				{
					if (value is PhonebookUserVO)
					{
						item.phonebookData = value as PhonebookUserVO;
					}
				}
				else
				{
					item.phonebookData = PhonebookManager.getUserModelByUserUID(userKey);
					item.contactData = ContactsManager.getUserModelByUserUID(userKey);
					
					//user not in contacts;
					if ((value is ContactVO) && !item.contactData)
					{
						item.contactData = value as ContactVO;
					}
					
					if (Auth.companyID)
					{
						if (Auth.company)
						{
							item.companyUserData = Auth.getCompanyMemberByUID(userKey);
						}
						else
						{
							
						}
					}
				}
				
				//update Custom Fields from semi-full data objects;
				if (value is ChatMessageVO)
				{
					item.name = (value as ChatMessageVO).name;
					item.avatarURL = (value as ChatMessageVO).avatar;
					item.fxId = (value as ChatMessageVO).fxId;
					
					if (item.fxId == 0 && ChatManager.getCurrentChat() != null)
					{
						item.fxId = UsersManager.getChatUserDataFxId(ChatManager.getCurrentChat(), (value as ChatMessageVO).userUID);
					}
					
					if (item.fxName == null && item.fxId != 0)
					{
						item.fxName = (value as ChatMessageVO).name;
					}
				}
				else if (value is CallsHistoryItemVO)
				{
					item.name = (value as CallsHistoryItemVO).title;
					item.avatarURL = (value as CallsHistoryItemVO).avatarURL;
				}
				else if (value is Object && ("name" in value) && ("uid" in value))
				{
					//CHAT USER FROM chat.users
					
					if (value.name != null)
					{
						item.name = value.name;
					}
					else if (("username" in value) && value.username != null)
					{
						item.name = value.username;
					}
					
					if ("avatar" in value)
					{
						item.avatarURL = value.avatar;
					}
					else if(("username" in value))
					{
						if (value.uid != null && (value.uid as String).length > 3)
						{
							item.avatarURL = Config.URL_PHP_CORE_SERVER_FILE + "ava/" + (value.uid as String).substr(0, 3) + "/" + (value.uid as String).substr(3);
						}
					}
					
					if ("created" in value)
					{
						item.created = value.created;
					}
					
					/*if (("name" in value) && ("username" in value))
					{
						item.fxName = value.username;
					}*/
					
					if ("fxid" in value)
					{
						item.fxId = value.fxid;
						
						if ("fxName" in value)
						{
							item.fxName = value.fxName;
						}
						else
						{
							if (item.fxName == null && item.fxId != 0)
							{
								if (("username" in value) && value.username != null)
								{
									item.fxName = value.username;
								}
								else
								{
									item.fxName = value.name;
								}
							}
						}
					}
					
					if (("cm" in value) && value.cm && ("username" in value.cm) && value.cm.username != null && value.cm.username != "")
					{
						var companyData:Object = {companyPhone:value.cm.company_phone, name:value.cm.username};
						
						if (item.companyUserData == null)
						{
							item.companyUserData = new MemberVO(companyData);
						}
						else
						{
							item.companyUserData.setData(companyData);
						}
					}
				}
				
				if (item.uid == Auth.uid)
				{
					item.preferredName = Auth.username;
				}
				
				if (!addToList)
				{
					return item;
				}
			}
			else
			{
				if (!(users[userKey] as UserProfileVO).contactData && value is ContactVO)
				{
					(users[userKey] as UserProfileVO).contactData = value as ContactVO;
				}
				else if (!(users[userKey] as UserProfileVO).phonebookData && value is PhonebookUserVO)
				{
					(users[userKey] as UserProfileVO).phonebookData = value as PhonebookUserVO;
				}
				else if (!(users[userKey] as UserProfileVO).companyUserData && value is MemberVO)
				{
					(users[userKey] as UserProfileVO).companyUserData = value as MemberVO;
				}
			}
			
			if ((value is String) == false && "payRating" in value && item != null)
			{
				item.payRating = value.payRating;
			}
			
			return users[userKey];
		}
		
		static public function addContactInfo(userInfo:Object):void {
			checkInitialization();
			
			var key:String;
			
			var updated:Boolean = false;
			
			if (userInfo is ContactVO)
			{
				key = (userInfo as ContactVO).uid;
				if (users[key] == null)
				{
					users[key] = new UserProfileVO(key);
				}
				updated = true;
				(users[key] as UserProfileVO).contactData = userInfo as ContactVO;
			}
			else if (userInfo is PhonebookUserVO)
			{
				if ((userInfo as PhonebookUserVO).uid != null && (userInfo as PhonebookUserVO).uid != "" && (userInfo as PhonebookUserVO).uid != "0")
				{
					key = (userInfo as PhonebookUserVO).uid;
				}
				else
				{
					key = userInfo.hash;
				}
				if (users[key] == null)
				{
					var resultUserUID:String = key;
					if ((userInfo is PhonebookUserVO) && (userInfo as PhonebookUserVO).uid == "")
					{
						resultUserUID = "";
					}
					users[key] = new UserProfileVO(null);
				}
				updated = true;
				(users[key] as UserProfileVO).phonebookData = userInfo as PhonebookUserVO;
			}
			else if (userInfo is MemberVO)
			{
				key = (userInfo as MemberVO).uid;
				if (users[key] == null)
				{
					users[key] = new UserProfileVO(key);
				}
				updated = true;
				(users[key] as UserProfileVO).companyUserData = userInfo as MemberVO;
			}
			if (userInfo is ChatMessageVO)
			{
				key = (userInfo as ChatMessageVO).userUID;
				if (users[key] != null)
				{
					if ((userInfo as ChatMessageVO).name && (users[key] as UserProfileVO).fxId != 0)
					{
					//	(users[key] as UserProfileVO).fxName = (userInfo as ChatMessageVO).name;
					}
				}
			}
			else if (userInfo is UserProfileVO)
			{
				key = (userInfo as UserProfileVO).uid;
				if (users[key] == null)
				{
					users[key] = userInfo;
				}
			}
			else if (userInfo is Object)
			{
				if ("uid" in userInfo)
				{
					key = userInfo.uid;
					if (users[key] == null)
					{
						users[key] = new UserProfileVO(key);
					}
					updated = true;
					
					if (("avatar" in userInfo) && userInfo.avatar)
					{
						(users[key] as UserProfileVO).avatarURL = userInfo.avatar;
					}
					if (("name" in userInfo) && userInfo.name)
					{
						//!TODO: preferredName
						(users[key] as UserProfileVO).name = userInfo.name;
					}
					if (("username" in userInfo) && userInfo.username && ("fxid" in userInfo) && userInfo.fxid)
					{
						(users[key] as UserProfileVO).fxName = userInfo.username;
					}
					if (("fxid" in userInfo) && userInfo.fxid != 0)
					{
						(users[key] as UserProfileVO).fxId = userInfo.fxid;
					}
					
					if ("created" in userInfo)
					{
						(users[key] as UserProfileVO).created = userInfo.created;
					}
					
					if (("cm" in userInfo) && userInfo.cm)
					{
						var companyData:Object = {companyPhone:userInfo.cm.company_phone, name:userInfo.cm.username};
						
						if ((users[key] as UserProfileVO).companyUserData == null)
						{
							(users[key] as UserProfileVO).companyUserData = new MemberVO(companyData);
						}
						else
						{
							(users[key] as UserProfileVO).companyUserData.setData(companyData);
						}
					}
				}
			}
			
			if (updated)
			{
				S_USER_PROFILE_UPDATE.invoke(key);
			}
		}
		
		static public function existUser(uid:String):Boolean 
		{
			return users[uid] != null;
		}
		
		static public function getUserByPhone(phone:String):UserProfileVO 
		{
			for each (var item:UserProfileVO in users) 
			{
				if (item.phone == phone)
				{
					return item;
				}
			}
			return null;
		}
		
		private static function checkInitialization():void 
		{
			if (initialized)
			{
				return;
			}
			users = new Dictionary();
			initialized = true;
			Auth.S_NEED_AUTHORIZATION.add(clear);
		}
		
		static private function clear():void 
		{
			//!TODO: clear data;
			users = new Dictionary();
		}
	}
}