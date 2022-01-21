package com.dukascopy.connect.sys.phonebookManager {
	
	import avmplus.finish;
	import com.adobe.errors.IllegalStateError;
	import com.adobe.utils.IntUtil;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.LocalAvatars;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.customActions.AddNewContactAction;
	import com.dukascopy.connect.data.screenAction.customActions.Open911ScreenAction;
	import com.dukascopy.connect.data.screenAction.customActions.OpenBankAccountAction;
	import com.dukascopy.connect.data.screenAction.customActions.OpenBankBotAction;
	import com.dukascopy.connect.data.screenAction.customActions.OpenMarketplaceAction;
	import com.dukascopy.connect.data.screenAction.customActions.OpenSupportChatAction;
	import com.dukascopy.connect.data.screenAction.customActions.PayWithCardAction;
	import com.dukascopy.connect.data.screenAction.customActions.TradingChannelAction;
	import com.dukascopy.connect.sys.addressbook.Addressbook;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.contactsManager.ContactsManager;
	import com.dukascopy.connect.sys.crypter.Crypter;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.permissionsManager.PermissionsManager;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.sys.store.Store;
	import com.dukascopy.connect.sys.ws.WSClient;
	import com.dukascopy.connect.utils.ArrayUtils;
	import com.dukascopy.connect.vo.ChatUserlistModel;
	import com.dukascopy.connect.vo.EntryPointVO;
	import com.dukascopy.connect.vo.users.UserVO;
	import com.dukascopy.connect.vo.users.adds.ContactSearchVO;
	import com.dukascopy.connect.vo.users.adds.ContactVO;
	import com.dukascopy.connect.vo.users.adds.PhonebookUserVO;
	import com.dukascopy.langs.Lang;
	import com.freshplanet.ane.airaddressbook.AirAddressBookContactsEvent;
	import com.greensock.TweenMax;
	import com.telefision.sys.signals.Signal;
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import connect.DukascopyExtension;
	import flash.events.StatusEvent;
	import white.Avatar911;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov
	 */
	
	public class PhonebookManager {
		
		static public var S_PHONES:Signal = new Signal("PhonebookManager.S_PHONES");
		static public var S_PHONES_UPDATE:Signal = new Signal("PhonebookManager.S_PHONES_UPDATE");
		static public var S_USER_INVITED:Signal = new Signal("PhonebookManager.S_USER_INVITED");
		
		static private var _phones:/*PhonebookUserVO*/Array = null;
		static private var busy:Boolean = false;
		static private var dataAvailable:Boolean = false;
		static private var data:Array = null;
		static private var invitations:Array;
		static private var hash:String = "";
		static private var inited:Boolean = false;
		static private var needToGetPhones:Boolean = true;
		static private var contactsGetted:Boolean = false;
		static private var phonesGetted:Boolean = false;
		static private var phonesToPHP:Array;
		static private var needToSync:Boolean = false;
		static private var viContact:ContactVO;
		static private var addNewContactAction:AddNewContactAction;

		public function PhonebookManager() { }
		
		static public function init():void {
			if (inited == true)
				return;
			inited = true;
			Auth.S_NEED_AUTHORIZATION.add(clearAllData);
			Auth.S_AUTHORIZED.add(onAutorized);
			NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, onActivate);
			ContactsManager.S_CONTACTS.add(onContactsGetted);
			
			WSClient.S_USER_CREATED.add(onUserAdded);
		}
		
		static private function onAutorized():void {
			Store.load("invitations", onInvitationsLoaded);
		}
		
		static public function onPhonesContactsTabOpened():void {
			/*if (PermissionsManager.isContactsPermissionGranted == false)
				getPhonebook();*/
		}
		
		static public function getUserModelByUserUID(userUID:String):PhonebookUserVO {
			var l:int;
			if (_phones) {
				l = _phones.length;
				for (var i:int = 0; i < l; i++) {
					if (_phones[i].uid == userUID)
						return _phones[i];
				}
			}
			return null;
		}
		
		static public function onUserAdded(phone:String, userName:String):void {
			updateUserByPhone(phone);
		}
		
		static public function updateUserByPhone(phone:String):void {
			if (phone == null)
				return;
			PHP.getUserByPhone(phone, onUserGotFromPHP);
		}
		
		static private function onUserGotFromPHP(phpRespond:PHPRespond):void {
			if (phpRespond.error) {
				//!TODO: обработка ошибки получения профиля нового пользователя
				ApplicationErrors.add();
				phpRespond.dispose();
				return;
			}
			if ("data" in phpRespond == false || phpRespond.data == null) {
				phpRespond.dispose();
				return;
			}
			if (_phones == null) {
				phpRespond.dispose();
				return;
			}
			if ("phone" in phpRespond.additionalData == false) {
				phpRespond.dispose();
				return;
			}
			var l:int = _phones.length;
			for (var i:int = 0; i < l; i++) {
				if (_phones[i].phone == Crypter.getNumberByBase(phpRespond.additionalData.phone).toString()) {
					_phones[i].addInfo(phpRespond.data);
					break;
				}
			}
			S_PHONES.invoke();
			S_PHONES_UPDATE.invoke();
			phpRespond.dispose();
		}
		
		static private function onActivate(e:Event):void {
			if (Auth.uid != null && Auth.uid.length > 0) {
				needToSync = true;
				getPhonebook();
				/*if (PermissionsManager.isContactsPermissionGranted == true)
					onPhonebookAccessGranted();*/
			}
		}
		
		static private function onInvitationsLoaded(data:Array, error:Boolean):void {
			if (error == false) {
				invitations = data;
				S_PHONES_UPDATE.invoke();
			}
			getPhonebook();
			getPhones();
		}
		
		static public function getPhones():void {
			if (busy == true)
				return;
			
			if (needToGetPhones == false) {
				S_PHONES.invoke();
				return;
			}
			ContactsManager.getContacts();
			needToGetPhones = false;
			busy = true;
			Store.load(Store.VAR_PHONEBOOK_USERS_HASH, onHashLoadedFromStore);
		}
		
		static private function onHashLoadedFromStore(data:Object, err:Boolean):void {
			if (err == true) {
				syncPhonebook();
				return;
			}
			if (data == null || data == "") {
				syncPhonebook();
				return;
			}
			hash = data as String;
			Store.load(Store.VAR_PHONEBOOK_USERS, onUsersLoadedFromStore);
		}
		
		static private function onUsersLoadedFromStore(datao:Object, err:Boolean):void {
			if (err == true) {
				hash = "";
				syncPhonebook();
				return;
			}
			
			if (Auth.phone && !isNaN(Auth.phone)) {
				datao = removePhones(datao as Array, [Crypter.getBaseNumber(Auth.phone)]);
			}
			
			data = datao as Array;
			if (_phones != null)
				repositionContactsIfExists();
			if (data == null || data.length == 0)
				hash = "";
			syncPhonebook();
		}
		
		static private function removePhones(phonesServer:Array, phonesToRemove:Array):Array 
		{
			if (!phonesServer || !phonesToRemove)
			{
				return phonesServer;
			}
			
			var result:Array = new Array();
			
			var l:int = phonesServer.length;
			var k:int = phonesToRemove.length;
			var needRemove:Boolean;
			
			for (var i:int = 0; i < l; i++) 
			{
				needRemove = false;
				
				if (phonesServer[i] && ("phone" in phonesServer[i]))
				{
					for (var j:int = 0; j < k; j++) 
					{
						var phone:Number = Crypter.getNumberByBase(phonesServer[i].phone);
						if (phonesServer[i].phone == phonesToRemove[j])
						{
							needRemove = true;
						}
					}
				}
				if (!needRemove)
				{
					result.push(phonesServer[i]);
				}
			}
			return result;
		}
		
		/*static private function getPhonebook():void {
			PermissionsManager.requestPermissionInitiation(PermissionsManager.PERMISSION_TYPE_CONTACTS);
		}*/
		
		public static function getPhonebook():void {
			echo("book:", "getPhonebook");
			if (!Addressbook.isSupported) {
				phonesGetted = true;
				return;
			}
			if (Addressbook.hasPermission() == 0) {
				phonesGetted = true;
				//DialogManager.alert(Lang.permissionInfo, Lang.acsessToContactsDenied);
				return;
			}
			echo("book:", "getPhonebook 2");
			_phones = null;
			Addressbook.addEventListener(Addressbook.CONTACTS_UPDATED, onPhonebookReceived);
			Addressbook.addEventListener(Addressbook.JOB_FINISHED, onPhonebookFinished);
			Addressbook.addEventListener(Addressbook.ACCESS_DENIED, onPhonebookDeniedDummy);
			Addressbook.initCache([]);
			Addressbook.check(1000);
			
			echo("book:", "getPhonebook 3");
		}
		
		public static function onPhonebookAccessDenied():void {
			phonesGetted = true;
		}
		
		static public function get isHasPermissionToContacts():Boolean {
			if (!Addressbook.isSupported)
				return true;
			if (Addressbook.hasPermission() == 0)
				return false;
			return true;
		}
		
		static private function onPhonebookDeniedDummy(e:Event):void {
			echo("book:", "onPhonebookDeniedDummy");
		}
		
		static private function onPhonebookFinished(e:Event):void {
			
			echo("book:", "onPhonebookFinished");
			
			if (_phones == null)
				_phones = [];
			repositionContactsIfExists();
		}
		
		static private function onPhonebookReceived(e:AirAddressBookContactsEvent):void {
			
			echo("book:", "onPhonebookReceived");
			
			var data:Object = e.contactsData;
			var regexp:RegExp = /[\u00A9]+/g;
			Addressbook.removeEventListener(Addressbook.CONTACTS_UPDATED, onPhonebookReceived);
			_phones = [];
			var phoneNumbers:Array = [];
			
			var phoneNumber:String;
			var contactName:String;
			
			phonesToPHP = [];
			
			var needToRemoveFromList:Boolean;
			
			for (var phone:String in data) {
				phoneNumber = phone.replace(/[^0-9\+]/gis, '');
				if ("compositeName" in data[phone])
					contactName = data[phone].compositeName;
				else if ("firstName" in data[phone])
					contactName = data[phone].firstName;
				if (phoneNumber.length < 6)
					continue;
				var start:String = phoneNumber.substr(0, 2);
				if (start.charAt(0) == "+")
					phoneNumber = phoneNumber.substr(1);
				else if (start == "00") {
					phoneNumber = phoneNumber.substr(2);
					if (phoneNumber.charAt(0) == "0")
						continue;
				} else if (start.charAt(0) == "0")
					phoneNumber = Auth.countryCode + phoneNumber.substr(1);
				else
					phoneNumber = Auth.countryCode + phoneNumber;
				
				if (phoneNumbers.indexOf(phoneNumber) != -1)
					continue;
				phoneNumbers.push(phoneNumber);
				
				//remove self number;
				
				needToRemoveFromList = false;
				if (!isNaN(Auth.phone)) {
					if (phoneNumber == Auth.phone.toString()) {
						needToRemoveFromList = true;
					}
				}
				
				if (!needToRemoveFromList) {
					phonesToPHP.push(Crypter.getBaseNumber(Number(phoneNumber)) + "," + escape(contactName.replace(regexp, "").substr(0, 200)));
				}
				
				var puVO:PhonebookUserVO = new PhonebookUserVO( { name:contactName, phone:phoneNumber } );
				if (invitations != null) {
					var invitationsCount:int = invitations.length;
					for (var i:int = 0; i < invitationsCount; i++) {
						if (puVO.phone == invitations[i]) {
							puVO.invited = true;
							break;
						}
					}
				}
				if (!needToRemoveFromList)
					_phones.push(puVO);
			}
			phoneNumbers = null;
			_phones.sort(sortPhones);
			
			if (needToSync == true)
				syncPhonebook();
		}
		
		static private function syncPhonebook():void {
			if (_phones == null) {
				busy = false;
				needToSync = true;
				return;
			}
			needToSync = false;
			if (!hash || hash == "")
				hash = "fakeHash";
			PHP.phonebook_sync(onPhonebookSync, phonesToPHP, hash, Auth.devID);
			phonesToPHP = null;
		}
		
		static private function sortPhones(a:PhonebookUserVO, b:PhonebookUserVO):int {
			if (a.name > b.name)
				return 1;
			if (a.name < b.name)
				return -1;
			return 0;
		}
		
		static private function onPhonebookSync(phpRespond:PHPRespond):void {
			if (phpRespond.error == true) {
				busy = false;
				phpRespond.dispose();
				return;
			}
			if (phpRespond.data == null) {
				busy = false;
				dataAvailable = true;
				repositionContactsIfExists();
				phpRespond.dispose();
				return;
			}
			if (!("users" in phpRespond.data) || phpRespond.data.users == null || !(phpRespond.data.users is Array)) {
				busy = false;
				dataAvailable = true;
				repositionContactsIfExists();
				phpRespond.dispose();
				return;
			}
			TweenMax.delayedCall(1, function():void {
				echo("PhonebookManager", "onPhonebookSync", "TweenMax.delayedCall");
				busy = false;
				dataAvailable = true;
				Store.save(Store.VAR_PHONEBOOK_USERS, phpRespond.data.users);
				if (phpRespond.data.hash != null) {
					hash = phpRespond.data.hash;
					Store.save(Store.VAR_PHONEBOOK_USERS_HASH, phpRespond.data.hash);
				}
				data = phpRespond.data.users;
				repositionContactsIfExists();
				phpRespond.dispose();
			}, null, true);
		}
		
		static private function onContactsGetted(...rest):void {
			contactsGetted = true;
			doFinish();
		}
		
		static private function repositionContactsIfExists():void {
			phonesGetted = true;
			if (data == null || data.length == 0) {
				doFinish();
				return;
			}
			if (_phones == null || _phones.length == 0) {
				data = null;
				doFinish();
				return;
			}
			var pushIndex:int = 0;
			var l:int = _phones.length;
			var puvo:PhonebookUserVO = null;
			for (var i:int = 0; i < l; i++) {
				puvo = _phones[i];
				puvo.collectInfo();
			}
			doFinish();
		}
		
		static private function doFinish():void {
			_phones = ArrayUtils.sortArray(_phones, "name");
			if (contactsGetted == true && phonesGetted == true)
				S_PHONES.invoke();
		}
		
		static public function updatePUVO(puVO:PhonebookUserVO):void {
			if (data == null)
				return;
			var usersCount:int = data.length;
			for (var i:int = 0; i < usersCount; i++) {
				if (data[i] && ("phone" in data[i]) && puVO.phone == Crypter.getNumberByBase(data[i].phone).toString()) {
					puVO.addInfo(data[i]);
					return;
				}
			}
		}
		
		static public function getPhoneByUID(uid:String):String {
			if (_phones == null)
				return null;
			var puVO:PhonebookUserVO = null;
			var phonesCount:int = _phones.length;
			for (var i:int = 0; i < phonesCount; i++) {
				puVO = _phones[i];
				if (puVO.uid == uid) {
					return puVO.phone;
				}
			}
			return null;
		}
		
		static public function invite(data:PhonebookUserVO, phone:String = "", showAlert:Boolean = true):void {
			var __onPHPResponde:Function = function(phpRespond:PHPRespond):void {
				if (phpRespond.error == true) {
					S_USER_INVITED.invoke( { data:data, success:false } );
					if (phpRespond.errorMsg.indexOf("pbk..02") == 0) {
						DialogManager.alert(Lang.textWarning, phpRespond.errorMsg.substring(7));
					} else if (phpRespond.errorMsg.indexOf("pbk..04") == 0) {
						updateUserByPhone(Crypter.getBaseNumber(Number((data != null) ? data.phone : phone)));
					} else {
						DialogManager.alert(Lang.textWarning, phpRespond.errorMsg.substring(7));
					}
					return;
				}
				phone = (data != null) ? data.phone : phone;
				phone = "+" + phone;
				if (phpRespond.data.link != undefined && phpRespond.data.link != "") {
					if (Config.PLATFORM_APPLE)
						navigateToURL(new URLRequest("sms:" + ((data != null) ? "+" + data.phone : phone) + "&body=" + Lang.invitationSmsText_appleWithLink + phpRespond.data.link));
					else if (Config.PLATFORM_ANDROID)
						navigateToURL(new URLRequest("sms:" + ((data != null) ? "+" + data.phone : phone) + "?body=" + Lang.invitationSmsText_appleWithLink + phpRespond.data.link));
				} else {
					if (Config.PLATFORM_APPLE)
						navigateToURL(new URLRequest("sms:" + ((data != null) ? "+" + data.phone : phone) + "&body=" + Lang.invitationSmsTextq_apple));
					else if (Config.PLATFORM_ANDROID)
						navigateToURL(new URLRequest("sms:" + ((data != null) ? "+" + data.phone : phone) + "?body=" + Lang.invitationSmsTextq_apple));
				}
				if (data != null) {
					data.invited = true;
					DialogManager.showInvitedNotification( { name:data.name } );
					invitations ||= [];
					if (invitations.indexOf(data.phone) == -1) {
						invitations.push(data.phone);
						Store.save("invitations", invitations);
					}
					S_USER_INVITED.invoke( { data:data, success:true } );
					S_PHONES_UPDATE.invoke();
				}
			};
			
			if (showAlert == true) {
				DialogManager.alert(Lang.information, Lang.alertSendInvitationText, function(val:int):void {
					if (val != 1) {
						S_USER_INVITED.invoke( { data:data, success:false } );
						return;
					}
					PHP.phonebook_invite(__onPHPResponde, Crypter.getBaseNumber(Number((data != null) ? data.phone : phone)));
				}, Lang.textOk, Lang.textCancel.toUpperCase());
				return;
			}
			PHP.phonebook_invite(__onPHPResponde, Crypter.getBaseNumber(Number((data != null) ? data.phone : phone)));
		}
		
		static public function checkPhoneNumberToExist(phoneNumber:String):String {
			if (dataAvailable == false)
				return "";
			var l:int = (data != null) ? data.length : 0;
			for (var i:int = 0; i < l; i++) {
				if (data[i].phone == phoneNumber)
					return data[i].uid;
			}
			return "";
		}
		
		static public function get isPHPDataAvailable():Boolean {
			return dataAvailable;
		}
		
		static public function get phones():Array {
			return _phones;
		}
		
		static public function getAllPhones():Array {
			var res:Array = [];
			var l:int = 0;
			var i:int = 0;
			
			if (Auth.bank_phase != "ACC_APPROVED")
				addEpAcc( { pid: -5, title:Lang.payWithCard }, res);
			
			if (ContactsManager.contacts != null && ContactsManager.contacts.length > 0) {
				l = ContactsManager.contacts.length;
				if (l > 0)
					res.push(Lang.textFriends);
				if (data == null || data.length == 0) {
					for (i = 0; i < l; i++) {
						if ((ContactsManager.contacts[i] as ContactVO).uid == Config.NOTEBOOK_USER_UID)
							res.unshift(ContactsManager.contacts[i]);
						else
							res.push(ContactsManager.contacts[i]);
					}
				} else {
					var j:int = 0;
					var l1:int = data.length;
					var wasIn:Boolean = false;
					for (i = 0; i < l; i++) {
						wasIn = false;
						for (j = 0; j < l1; j++) {
							if (ContactsManager.contacts[i].uid == data[j].uid) {
								wasIn = true;
								break;
							}
						}
						if (wasIn == false) {
							if (res.length == 0)
								res.push(Lang.textFriends);
							if ((ContactsManager.contacts[i] as ContactVO).uid == Config.NOTEBOOK_USER_UID)
								res.unshift(ContactsManager.contacts[i]);
							else
								res.push(ContactsManager.contacts[i]);
						}
					}
				}
			}
			if (_phones != null && _phones.length != 0) {
				l = _phones.length;
				var countForOther:int = (data == null) ? 0 : data.length;
				if (countForOther != 0) {
					res.push(Lang.categoryInConnect);
					var otherAdded:Boolean = false;
					var insertIndex:int = res.length;
					for (var m:int = 0; m < l; m++) {
						for (var k:int = 0; k < countForOther; k++) {
							if (data[k].phone == Crypter.getBaseNumber(Number(_phones[m].phone))) {
								res.insertAt(insertIndex, _phones[m]);
								insertIndex++;
								break;
							}
						}
						if (k == countForOther) {
							if (!otherAdded) {
								otherAdded = true;
								res.push(Lang.textOther);
							}
							res.push(_phones[m]);
						}
					}
					return res;
				} else {
					res.push(Lang.textOther);
					for (var n:int = 0; n < l; n++)
						res.push(_phones[n]);
				}
			}
		//	res.unshift(getAddContact());
			if (Auth.bank_phase != "EMPTY" && Auth.bank_phase != "ACC_APPROVED" && Auth.bank_phase != "UNKNOWN")
				res.unshift(getVIContact());
			return res;
		}
		
		static private function getAddContact():AddNewContactAction {
			if (addNewContactAction == null) {
				addNewContactAction = new AddNewContactAction();
				addNewContactAction.setData(Lang.addNewContact);
			}
			return addNewContactAction;
		}
		
		static private function getVIContact():ContactVO {
			if (viContact == null) {
				viContact = new ContactVO({name:Lang.chatWithBankTitle, avatar:LocalAvatars.SUPPORT_VI});
				viContact.action = new OpenSupportChatAction(Config.EP_VI_DEF);
				viContact.action.setData(Lang.chatWithBankTitle);
			}
			return viContact;
		}
		
		static public function getMyPhones(addCustomActions:Boolean = true):Array {
			var res:Array = [];
			var l:int = 0;
			var i:int = 0;
			if (_phones == null)
				return res;			
			l = _phones.length
			for (i = 0; i < l; i++)
				res.push(_phones[i]);
			/*if (addCustomActions == true)
				res.unshift(getAddContact());*/
			if (Auth.bank_phase != "EMPTY" && Auth.bank_phase != "ACC_APPROVED" && Auth.bank_phase != "UNKNOWN")
				res.unshift(getVIContact());
			return res;
		}
		
		static public function getEntrypointsContacts():Array {
			var res:Array = [];
			
			var wasPhase:Boolean = false;
				
			// SETUP BANK
			if (Auth.bank_phase != "EMPTY" && Auth.bank_phase != "UNKNOWN"){
				wasPhase = true;
				addEp( { pid:Config.EP_VI_DEF, title:Lang.chatWithBankTitle }, res);
				if (Auth.bank_phase == "ACC_APPROVED") {
					addEpAcc( { pid: -1, title:Lang.myAccount }, res);
					addEpAcc( { pid: -3, title:Lang.bankBot }, res );
					addEpAcc( { pid: -4, title:Lang.dukascoinMarketplace }, res);
					addEpAcc( { pid: -6, title:Lang.help_911_title }, res);
					//addEpAcc( { pid:Config.EP_TRADING, title:"911 Trading Channel" }, res);
				}
			} else {
				addEpAcc( { pid: -2, title:Lang.openAccount }, res, true);
			}
			if (Auth.bank_phase != "ACC_APPROVED")
				addEpAcc( { pid: -5, title:Lang.payWithCard }, res, true);
			// SETUP EUROPEAN TRADING PHASE
			if (Auth.eu_phase  != "EMPTY" && Auth.eu_phase != "UNKNOWN"){
				wasPhase = true;
				addEp( { pid:Config.EP_VI_EUR, title:Lang.chatWithBankEUTitle }, res);
			}
			// SETUP SUHOBOKOV
			if (Auth.ch_phase  != "EMPTY" && Auth.ch_phase != "UNKNOWN"){
				wasPhase = true;
				addEp( { pid:Config.EP_VI_PAY, title:Lang.chatWithPayEUTitle }, res);
			}
			if (!wasPhase)
				addEp( { pid:Config.EP_MAIN, title:Lang.chatWithBankTitle }, res);
			return res;
		}
		
		static private function addEpAcc(epData:Object, res:Array, toFirstPlace:Boolean = false):void {
			if (res == null)
				return;
			var model:IScreenAction;
			if (epData.pid == -1 || epData.pid == -2)
				model = new OpenBankAccountAction();
			else if (epData.pid == -3)
				model = new OpenBankBotAction();
			else if (epData.pid == -4)
				model = new OpenMarketplaceAction();
			else if (epData.pid == -5)
				model = new PayWithCardAction();
			else if (epData.pid == Config.EP_TRADING)
				model = new TradingChannelAction();
			else if (epData.pid == -6)
			{
				model = new Open911ScreenAction();
				model.setIconClass(Avatar911);
			}
			model.setData(epData.title);
			if (toFirstPlace == true)
				res.unshift(model);
			else
				res.push(model);
		}
		
		static private function addEp(epData:Object, res:Array, toFirstPlace:Boolean = false):void 
		{
			if (res != null)
			{
				var model:IScreenAction = new OpenSupportChatAction(epData.pid);
				model.setData(epData.title);
				
				if (toFirstPlace == true)
					res.unshift(model);
				else
					res.push(model);
			}
		}
		
		static public function getConnectContacts(onlyContacts:Boolean = false, withPhones:Boolean = false):Array {
			var res:Array = [];
			var l:int = 0;
			var i:int = 0;
			
			/*if (onlyContacts == false){
				if (Auth.getPhases() != null && Auth.getPhases().length > 0) {
					l = Auth.getPhases().length;
					res.push(Lang.textHelp);
					for (i = 0; i < l; i++)
						res.push(Auth.getPhases()[i]);
				}
			}*/
			
			var friends:Array = new Array();
			
			if (ContactsManager.contacts != null && ContactsManager.contacts.length > 0) {
				l = ContactsManager.contacts.length;
				if (data == null || data.length == 0) {
					for (i = 0; i < l; i++)
					{
						if ((ContactsManager.contacts[i] as ContactVO).uid == Config.NOTEBOOK_USER_UID)
						{
							if (onlyContacts == false)
								res.unshift(ContactsManager.contacts[i]);
						}
						else
						{
							friends.push(ContactsManager.contacts[i]);
						}
					}
				} else {
					var j:int = 0;
					var l1:int = data.length;
					var wasIn:Boolean = false;
					for (i = 0; i < l; i++) {
						wasIn = false;
						for (j = 0; j < l1; j++) {
							if (ContactsManager.contacts[i].uid == data[j].uid) {
								wasIn = true;
								break;
							}
						}
						if (wasIn == false) {
							
							if ((ContactsManager.contacts[i] as ContactVO).uid == Config.NOTEBOOK_USER_UID)
							{
								if (onlyContacts == false)
									res.unshift(ContactsManager.contacts[i]);
							}
							else
							{
								friends.push(ContactsManager.contacts[i]);
							}
						}
					}
				}
			}
			
			if (_phones == null)
			{
				if (friends.length > 0 && onlyContacts == false)
				{
					if (onlyContacts == false)
						res.push(Lang.textFriends);
				}
				res = res.concat(friends);
			}
			else{
				l = _phones.length
				var countForOther:int = (data == null) ? 0 : data.length;
				for (i = 0; i < l; i++) {
					if (withPhones == true || _phones[i].fxName!="") {
						friends.push(_phones[i]);
					}
				} 
				if (friends.length > 0)
				{
					if (onlyContacts == false)
						res.push(Lang.textFriends);
				}
				res = res.concat(friends);
			}	
			
			if (onlyContacts == false) {
			//	res.unshift(getAddContact());
				if (Auth.bank_phase != "EMPTY" && Auth.bank_phase != "ACC_APPROVED" && Auth.bank_phase != "UNKNOWN") {
					res.unshift(getVIContact());
				}
			}
			
			return res;
		}
		
		static public function getUsernameByUserUID(userUID:String):String {
			if (userUID == null)
			{
				return null;
			}
			if (data == null || data.length == 0)
				return ContactsManager.getUsernameByUserUID(userUID);
			if (_phones == null || _phones.length == 0)
				return ContactsManager.getUsernameByUserUID(userUID);
			var l:int = _phones.length;
			for (var i:int = 0; i < l; i++) {
				if (_phones[i].uid == "")
					return "";
				else if (_phones.uid == userUID)
					return _phones[i].name;
			}
			return "";
		}
		
		static public function filterByName(contacts:Array, filter:String, label:String = null):Array/*of ContactSearchVO*/ {
			if (contacts == null) return null;
			if (filter == "") return contacts;
			
			var result:Array = [];
			for (var i:int = 0; i < contacts.length; i++){
				var element:Object = contacts[i];
				
				
				if (element is ContactVO){
					var contact:ContactVO = element as ContactVO;
					if ((contact.fxName + contact.fxcommFN + contact.fxcommLN + contact.name).toLowerCase().indexOf(filter.toLowerCase()) != -1){
						var contactSearch:ContactSearchVO = new ContactSearchVO(filter, contact);
						result.push(contactSearch);
					}
				} else if (element is PhonebookUserVO){
					var phoneContact:PhonebookUserVO = element as PhonebookUserVO;
					if ((phoneContact.name).toLowerCase().indexOf(filter.toLowerCase()) != -1){
						contactSearch = new ContactSearchVO(filter, phoneContact);
						result.push(contactSearch);
					}
				} else if (element is ChatUserlistModel){
					var chatContact:UserVO = (element as ChatUserlistModel).contact;
					if (chatContact != null && (chatContact.getDisplayName()).toLowerCase().indexOf(filter.toLowerCase()) != -1){
					//	contactSearch = new ContactSearchVO(filter, phoneContact);
						result.push(element);
					}
				}
			}
			if (label && result.length > 0){
				result.unshift(label);
			}
			return result;
		}
		
		static public function filterBy(contacts:Array, filter:String, filterFields:Array):Array/*of ContactSearchVO*/ {
			if (contacts == null) return null;
			if (filter == "") return contacts;
			
			var result:Array = [];
			for (var i:int = 0; i < contacts.length; i++){
				var element:Object = contacts[i];
				if (element is ContactVO){
					var contact:ContactVO = element as ContactVO;
					for (var j:int = 0; j < filterFields.length; j++) 
					{
						if (contact.hasOwnProperty(filterFields[j]) && contact[filterFields[j]].toLowerCase().indexOf(filter.toLowerCase()) != -1){
							var contactSearch:ContactSearchVO = new ContactSearchVO(filter, contact);
							result.push(contactSearch);
							break;
						}
					}
					
				} else if (element is PhonebookUserVO){
					var phoneContact:PhonebookUserVO = element as PhonebookUserVO;
					for (j = 0; j < filterFields.length; j++) 
					{
						if (phoneContact.hasOwnProperty(filterFields[j]) && phoneContact[filterFields[j]].toLowerCase().indexOf(filter.toLowerCase()) != -1){
							contactSearch = new ContactSearchVO(filter, phoneContact);
							result.push(contactSearch);
							break;
						}
					}
				}
			}
			return result;
		}
		
		static public function getUsernameByPhone(userPhone:String):String {
			if (_phones == null || _phones.length == 0)
				return "";
			var l:int = _phones.length;
			for (var i:int = 0; i < l; i++) {
				if (userPhone.indexOf(_phones[i].phone + "") != -1)
					return _phones[i].name;
			}
			return "";
		}
		
		static public function get phonesAlreadyExist():Boolean {
			return needToGetPhones == false && phonesGetted == true;
		}
		
		static private function clearAllData():void {
			_phones = []
			_phones = null;
			busy = false;
			hash = "";
			dataAvailable = false;
			data = [];
			data = null;
			invitations = [];
			invitations = null;
			needToGetPhones = true;
			needToSync = false;
		}
		
		static public function openRequestContactsAcsessDialog():void {
			if (Config.PLATFORM_APPLE) {
				dukascopyExtension.addEventListener(StatusEvent.STATUS, onDukascopyExtensionStatusEventCallsPermission);
				dukascopyExtension.showAlert("", Lang.acsessToContactsDenied, Lang.textOk, Lang.textCancel.toUpperCase());
			}
		}
		
		static public function getUserByPhone(phone:String):PhonebookUserVO 
		{
			if (_phones == null || _phones.length == 0)
				return null;
			var l:int = _phones.length;
			for (var i:int = 0; i < l; i++) {
				if (phone.indexOf(_phones[i].phone + "") != -1)
					return _phones[i];
			}
			return null;
		}
		
		private static function onDukascopyExtensionStatusEventCallsPermission(e:StatusEvent):void
		{
			const eventCode:String = "alert_didTapAlertButton";
			const levelCancel:String = "cancelButton";
			const levelAction:String = "actionMutton";
			if (e.code != eventCode)
			{
				return;
			}
			dukascopyExtension.removeEventListener(StatusEvent.STATUS, onDukascopyExtensionStatusEventCallsPermission);
			if (e.level == levelCancel)
			{
				return;
			}
			if (e.level == levelAction)
			{
				dukascopyExtension.openDeviceSettings();
				return;
			}
		}

		static public function get dukascopyExtension():DukascopyExtension
		{
			return MobileGui.dce;
		}
	}
}