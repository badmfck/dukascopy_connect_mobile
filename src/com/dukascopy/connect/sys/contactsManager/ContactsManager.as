package com.dukascopy.connect.sys.contactsManager {

	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.sys.store.Store;
	import com.dukascopy.connect.sys.ws.WS;
	import com.dukascopy.connect.sys.ws.WSClient;
	import com.dukascopy.connect.type.ChatInitType;
	import com.dukascopy.connect.utils.ArrayUtils;
	import com.dukascopy.connect.vo.users.UserVO;
	import com.dukascopy.connect.vo.users.adds.ChatUserVO;
	import com.dukascopy.connect.vo.CompanyMemberVO;
	import com.dukascopy.connect.vo.users.adds.ContactVO;
	import com.dukascopy.connect.vo.screen.ChatScreenData;
	import com.greensock.TweenMax;
	import com.telefision.sys.signals.Signal;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;

	/**
	 * ...
	 * @author ...
	 */
	public class ContactsManager {
		
		static public const S_CONTACTS:Signal = new Signal("ContactsManager.S_CONTACTS");
		static public const S_CONTACTS_UPDATE:Signal = new Signal("ContactsManager.S_CONTACTS_UPDATE");
		static public const S_CONTACTS_FINISHED_LOADING:Signal = new Signal("ContactsManager.S_CONTACTS_FINISHED_LOADING");
		
		static private var _contacts:Array/*ContactVO*/ = null;
		static private var _companyMembers:CompanyMemberVO = null;
		static private var currentHash:String = "";
		
		static private var inited:Boolean = false;
		static private var active:Boolean = false;
		static private var busy:Boolean = false;
		static private var _contactsResponded:Boolean = false;
		static private var con:flash.utils.Dictionary;
		
		public function ContactsManager() { }
		
		public static function activate():void {
			active = true;
		}
		
		public static function deactivate():void {
			active = false;
		}
		
		static private function init():void {
			if (inited == true)
				return;
			inited = true;
			WS.S_CONNECTED.add(onWSConnected);
			Auth.S_NEED_AUTHORIZATION.add(onAuthNeeded);
		}
		
		static private function onAuthNeeded():void {
			// TODO - NEED DISPOSE CONTACTS, ILYA
			_contacts = null;
			_companyMembers = null;
			currentHash = "";
			inited = false;
			active = false;
			busy = false;
			_contactsResponded = false;
		}
		
		static private function onWSConnected():void {
			if (active == false)
				return;
			TweenMax.delayedCall(1, function():void {
				echo("ContactsManager","onWSConnected", "TweenMax.delayedCall");
				if (currentHash != null && currentHash != "") {
					loadContactsFromPHP(currentHash);
					return;
				}
				Store.load(Store.VAR_CONTACTS_HASH, onLoadHashFromStore);
			}, null, true);
		}
		
		static public function getContacts():void {
			init();
			if (_contacts != null) {
				S_CONTACTS.invoke(_contacts);
				return;
			}
			onLoadContacts();
		}
		
		static private function onLoadContacts():void {
			TweenMax.delayedCall(1, function():void {
				echo("ContactsManager","getContacts", "TweenMax.delayedCall");
				Store.load(Store.VAR_CONTACTS, onLoadContactsFromStore);
			}, null, true);
		}
		
		static private function onLoadContactsFromStore(data:Object, error:Boolean):void {
			TweenMax.delayedCall(1, function():void {
				echo("ContactsManager", "onLoadContactsFromStore", "TweenMax.delayedCall");
				if (data != null) {
					if (_contacts != null)
						clear();
					_contacts = [];
					var contactsCount:int = data.length;
					for (var i:int = 0; i < contactsCount; i++)
						addContact(new ContactVO(data[i]));
					_contacts = ArrayUtils.sortArray(_contacts, "name");
					_contactsResponded = true;
					S_CONTACTS.invoke(_contacts);
				}
				TweenMax.delayedCall(1, function():void {
					echo("ContactsManager", "onLoadContactsFromStore", "TweenMax.delayedCall (data is null)");
					Store.load(Store.VAR_CONTACTS_HASH, onLoadHashFromStore);
				}, null, true);
			}, null, true);
		}
		
		static private function onLoadHashFromStore(data:String, error:Boolean):void {
			TweenMax.delayedCall(1, function():void {
				echo("ContactsManager", "onLoadHashFromStore", "TweenMax.delayedCall");
				if (_contacts == null || _contacts.length == 0)
					data = "";
				loadContactsFromPHP(data);
			}, null, true);
		}
		
		static private function loadContactsFromPHP(hash:String):void {
			TweenMax.delayedCall(1, function():void {
				echo("ContactsManager", "loadContactsFromPHP", "TweenMax.delayedCall");
				PHP.contacts_get(onLoadContactsFromPHP, null);
			}, null, true);
		}
		
		static private function onLoadContactsFromPHP(phpRespond:PHPRespond):void {
			_contactsResponded = true;
			S_CONTACTS_FINISHED_LOADING.invoke(phpRespond.error);
			if (phpRespond.error == true) {
				S_CONTACTS.invoke(_contacts);
				busy = false;
				phpRespond.dispose();
				return;
			}
			if (phpRespond.data == null) {
				S_CONTACTS.invoke(_contacts);
				busy = false;
				phpRespond.dispose();
				return;
			}
			if (phpRespond.data.contacts == null) {
				S_CONTACTS.invoke(_contacts);
				busy = false;
				phpRespond.dispose();
				return;
			}
			TweenMax.delayedCall(1, function():void {
				echo("ContactsManager", "onLoadContactsFromPHP", "TweenMax.delayedCall");
				busy = false;
				
				var allData:Array = new Array();
				if (phpRespond.data.contacts)
					allData = allData.concat(phpRespond.data.contacts);
				if (phpRespond.data.memo && (phpRespond.data.memo is Array) && phpRespond.data.memo.length > 0)
					allData = allData.concat(phpRespond.data.memo);
				if (("system" in phpRespond.data) && phpRespond.data.system && (phpRespond.data.system is Array) && phpRespond.data.system.length > 0)
					allData = allData.concat(phpRespond.data.system);
				Store.save(Store.VAR_CONTACTS, allData);
				if (phpRespond.data.hash != null)
					Store.save(Store.VAR_CONTACTS_HASH, phpRespond.data.hash);
				if (_contacts == null)
					_contacts = [];
				
				var contactsByUID:Array = new Array();
				var l:int = _contacts.length;
				for (var j:int = 0; j < l; j++) 
				{
					contactsByUID[_contacts[j].uid] = true;
				}
				
				var contactsCount:int = phpRespond.data.contacts.length;
				
				var contactRawData:Object;
				
				for (var i:int = 0; i < contactsCount; i++)
				{
					contactRawData = phpRespond.data.contacts[i];
					if (contactRawData != null && contactRawData.hasOwnProperty("uid") && contactsByUID[contactRawData.uid] != true){
						addContact(new ContactVO(contactRawData));
					}
				}
				/*if (("memo" in phpRespond.data) && (phpRespond.data.memo) && (phpRespond.data.memo as Array)) {
					var memoCount:int = phpRespond.data.memo.length;
					for (var i2:int = 0; i2 < memoCount; i2++)
					{
						contactRawData = phpRespond.data.memo[i2];
						if (contactRawData != null && contactRawData.hasOwnProperty("uid") && contactsByUID[contactRawData.uid] != true){
							addContact(new ContactVO(contactRawData));
						}
					}
				}*/
				if (("system" in phpRespond.data) && (phpRespond.data.system) && (phpRespond.data.system as Array)) {
					var systemCount:int = phpRespond.data.system.length;
					for (var i3:int = 0; i3 < systemCount; i3++)
					{
						contactRawData = phpRespond.data.system[i3];
						if (contactRawData != null && contactRawData.hasOwnProperty("uid") && contactsByUID[contactRawData.uid] != true){
							addContact(new ContactVO(contactRawData));
						}
					}
				}
				contactsByUID = null;
				_contacts = ArrayUtils.sortArray(_contacts, "name");
				S_CONTACTS.invoke(_contacts);
				phpRespond.dispose();
			}, null, true);
		}
		
		static private function addContact(cvo:ContactVO):void
		{
			/*if (con == null)
			{
				con = new Dictionary();
			}
			if (cvo.fxID == 154007)
			{
				trace("123");
			}*/
			
			_contacts.push(cvo);
		}
		
		static private function clear():void {
			if (_contacts != null) {
				while (contacts.length != 0) {
					contacts[0].dispose();
					contacts[0] = null;
					contacts.splice(0, 1);
				}
			}
			_contacts = null;
		}
		
		static public function get contacts():Array {
			return _contacts;
		}
		
		static public function get contactsResponded():Boolean 	{
			return _contactsResponded;
		}
		
		static public function getUsernameByUserUID(userUID:String):String {
			if (_contacts == null)
				return "";
			var l:int = _contacts.length;
			for (var i:int = 0; i < l; i++)
				if (_contacts[i].uid == userUID)
					return _contacts[i].name;
			return "";
		}
		
		static public function getUserModelByUserUID(userUID:String):ContactVO {
			var l:int;
			if (_contacts) {
				l = _contacts.length;
				for (var i:int = 0; i < l; i++) {
					if (_contacts[i].uid == userUID)
						return _contacts[i];
				}
			}
			return null;
		}
		
		static public function addMemoUser(contact:ContactVO):void {
			if (contact != null) {
				var exist:Boolean = false;
				var l:int = _contacts.length;
				for (var i:int = 0; i < l; i++) {
					if (_contacts[i].uid == contact.uid) {
						exist = true;
						break;
					}
				}
				if (!exist)	{
					
					_contacts.push(contact);
					S_CONTACTS_UPDATE.invoke();
				}
			}
		}
		
		static public function addContactByChatUserVO(data:ChatUserVO):void {
			var exist:Boolean = false;
			if (_contacts == null)
				_contacts = [];
			var l:int = _contacts.length;
			for (var i:int = 0; i < l; i++) {
				if (_contacts[i].uid == data.uid) {
					exist = true;
					break;
				}
			}
			if (exist == false) {
				var cVO:ContactVO = new ContactVO(data);
				_contacts.push(cVO);
				S_CONTACTS_UPDATE.invoke();
			}
		}
		
		static public function getUserByPhone(phone:String):ContactVO {
			var l:int;
			if (_contacts) {
				l = _contacts.length;
				for (var i:int = 0; i < l; i++) {
					if (_contacts[i].getPhone().toString() == phone)
						return _contacts[i];
				}
			}
			return null;
		}
		
		static public function get companyMembers():CompanyMemberVO { return _companyMembers; }
	}
}