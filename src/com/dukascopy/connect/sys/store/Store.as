package com.dukascopy.connect.sys.store{
	import com.adobe.crypto.MD5;
	import com.adobe.utils.IntUtil;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.imageManager.ImageSaver;
	import com.dukascopy.connect.utils.Debug.DebugUtils;
	import com.greensock.TweenMax;
	import com.telefision.sys.signals.Signal;
	import com.telefision.utils.Loop;
	import flash.events.Event;
	import flash.events.FileListEvent;
	import flash.events.IOErrorEvent;
	import flash.events.OutputProgressEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.NetStreamAppendBytesAction;
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author IgorBloom
	 */
	public class Store {
		
		static public const VAR_CHATS:String = 'chats';
		static public const VAR_MESSAGES:String = "messages";
		static public const VAR_SECURITY_KEY:String = "securityKey";
		static public const VAR_CONTACTS:String = "contacts";
		static public const VAR_CONTACTS_HASH:String = "contactsHash";
		static public const VAR_MEMBERS:String = "members";
		static public const VAR_MEMBERS_HASH:String = "membersHash";
		static public const VAR_FINDATINGS:String = "findatings";
		static public const VAR_FINDATINGS_HASH:String = "findatingsHash";
		static public const VAR_STICKERS:String = "stickers";
		static public const VAR_STICKERS_HASH:String = "stickersHash";
		static public const VAR_PHONEBOOK_USERS:String = "phonebookUsers";
		static public const VAR_PHONEBOOK_USERS_HASH:String = "phonebookUsersHash";
		static public const CHAT_SETTINGS:String = "chatSettings";
		static public const VAR_ENTRYPOINTS_HASH:String = "varEntrypointsHash";
		static public const VAR_ENTRY_POINTS:String = "varEntryPoints";
		static public const VAR_CALLS_HASH:String = "varCallsHash";
		static public const VAR_CALLS:String = "varCalls";
		static public const VAR_QUESTIONS:String = "varQuestions";
		static public const VAR_QUESTIONS_HASH:String = "varQuestionsHash";
		static public const VAR_QUESTIONS_SELF:String = "varQuestionsSelf";
		static public const VAR_QUESTIONS_SELF_HASH:String = "varQuestionsSelfHash";
		static public const ANSWERS_FOR_QUESTION:String = "answersForQuestion";
		static public const VAR_CHANNELS:String = "channels";
		static public const VAR_ANSWERS:String = "answers";
		static public const VAR_LANGUAGE_HASHES:String = "language_hashes";
		static public const VAR_LANGUAGE_ID:String = "language_id";
		static public const VAR_LANGUAGE:String = "language";
		static public const VAR_SCREEN:String = "screen";
		static public const VAR_DO_NOT_SHOW_INFO:String = "doNotShowInfo";
		static public const VAR_ROOT_SCREEN_TAB:String = "rootScreenTab";
		static public const VAR_911_STAT_USER:String = "911StatUser";
		static public const VAR_911_STAT:String = "911StatMy";
		static public const CATEGORY_NEED_DISCLAIMER:String = "categoryNeedDisclaimer";
		static public const VAR_USER_FX_PHOTOS:String = "VAR_USER_FX_PHOTOS";
		static public const VAR_GIFTS_TUTORIAL_SHOWN:String = "varGiftsTutorialShown";
		static public const VAR_REQUEST_PERMISSION_ABILITY_STATES:String = "requestPermissionAbilityStates";
		static public const VAR_DO_NOT_SHOW_QUESTION_RULES:String = "varDoNotShowQuestionRules";
		static public const MY_REFERRAL_CODE:String = "myReferralCode";
		static public const FIRST_INSTALL_TIME:String = "firstInstallTime";
		static public const REFERRAL_PROGRAM_AGREEMENT_ACCEPTED:String = "referralProgramAgreementAccepted";
		static public const VAR_CHANNELS_HASH:String = "VAR_CHANNELS_HASH";
		static public const REFERRAL_PROGRAM_DATA:String = "referralProgramData";
		static public const VAR_BOTS_HASH:String = "varBotsHash";
		static public const VAR_BOTS:String = "varBots";
		static public const VAR_MY_BANS:String = "varMyBans";
		static public const VAR_TOP_BANS:String = "varTopBans";
		static public const VAR_TOP_BANS_HASH:String = "varTopBansHash";
		static public const VAR_BAN_PROTECTIONS:String = "varBanProtections";
		static public const VAR_BANS_PROTECTIONS_HASH:String = "varBansProtectionsHash";
		static public const BOT_HOME_BUTTON_SHOWN:String = "botHomeButtonShown";
		static public const BOT_MENU_BUTTON_SHOWN:String = "botMenuButtonShown";
		static public const BOT_MP_BUTTON_SHOWN:String = "botMPButtonShown";
		static public const VAR_CHANNELS_TRASH:String = "varChannelsTrash";
		static public const VAR_TRASH_CHANNELS_HASH:String = "varTrashChannelsHash";
		static public const SPAM_CHANNELS_INFO_POPUP_STATUS:String = "spamChannelsInfoPopupStatus";
		static public const PROMO_DISCLAMER_SHOWN:String = "promoDisclamerShown";
		static public const VAR_USERS_EXTENSIONS:String = "varUsersExtensions";
		static public const VAR_USERS_EXTENSIONS_HASH:String = "varUsersExtensionsHash";
		static public const VAR_TOP_EXTENSIONS:String = "varTopExtensions";
		static public const CRYPTO_EXISTS:String = "cryptoExist";
		static public const MARKETPLACE_LAYOUT:String = "marketplaceLayout";
		static public const LOYALTY_PENDING:String = "loyaltyPending";
		static public const VAR_CHAT_USERS_APPROVED:String = "chatUsersApproved";
		static public const NOT_SHOW_FAST_TRACK_PROPOSAL:String = "notShowFastTrackProposal";
		static public const BANK_TUTORIAL:String = "bankTutorial";
		static public const FIRST_TRANSACTIONS:String = "firstTransactions";
		static public const USE_FINGERPRINT:String = "USE_FINGERPRINT";
		static public const VAR_TOP_MISS:String = "varTopMiss";
		static public const VAR_TOP_CURRENT:String = "varTopCurrent";
		static public const VAR_TOP_CURRENT_MISS:String = "varTopCurrentMiss";
		static public const DONT_ASK_FINGERPRINT:String = "DONT_ASK_FINGERPRINT";
		static public const COIN_STAT:String = "coinStat";
		static public const SOLVENCY_CHECK_CMETHOD:String = "solvencyCheckCmethod";
		static public const ZBX_REQUEST_TIME:String = "zbxRequestTime";
		static public const GUEST_UID:String = "guestUid";
		static public const GUEST_NAME:String = "guestName";
		static public const GUEST_MAIL:String = "guestMail";

		static private const TYPE_SAVE:int = 0;
		static private const TYPE_LOAD:int = 1;
		static private const TYPE_REMOVE:int = 2;
		static private var clearing:Boolean = false;
		static private var fileworks:Boolean = false;
		static private var _storeDirectory:File;
		
		/**
		 * Save object to storage folder, 
		 * @param	name	String	File name to save	
		 * @param	data	Object	An data object to save (AM3);
		 * @param	callback function(data:Object,err:Boolean):void;
		 */
		static public function save(name:String, data:Object, callBack:Function = null):void {
			if (clearing)
				return;
			fileworks = true;
			new Store(resetFileworks,new StoreIniter(), name, data, TYPE_SAVE,callBack);
		}
		
		static public function clearAll(callBack:Function):void {
			if (clearing){
				return;
			}
			clearing = true;
			ImageSaver.stopSaveAll();
			var __waitForFileworks:Function = function():void {
				if (fileworks == false) {
					Loop.remove(__waitForFileworks);
					doClear(callBack);
					return;
				}
			}
			if (fileworks == true) {
				Loop.add(__waitForFileworks);
				return;
			}
			doClear(callBack);
		}
		
		static private function doClear(callBack:Function):void {
			var f:File = storeDirectory;
			if (!f.exists || !f.isDirectory) {
				clearing = false;
				callBack();
				return;	
			}
			var __removeListeners:Function = function():void {
				f.removeEventListener(FileListEvent.DIRECTORY_LISTING, __onDirectoryListed);
				f.removeEventListener(IOErrorEvent.IO_ERROR, __onDirIOError);
				f.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, __onDirSecError);
			}
			var __onDirIOError:Function = function(e:Event):void {
				__removeListeners();
				clearing = false;
				callBack();
			}
			var __onDirSecError:Function = function(e:Event):void {
				__removeListeners();
				clearing = false;
				callBack();
			}
			var __onDirectoryListed:Function = function(e:FileListEvent):void {
				__removeListeners();
				var l:int = e.files.length;
				var n:int = 0;
				var fle:File;
				for (n; n < l; n++) {
					fle = e.files[n];
					if (fle.exists) {
						trace(fle.name);
						/*if (fle.name == "#SharedObjects")
							continue;*/
						
						if (fle.name == MD5.hash(GUEST_UID) + ".dta")
							continue;
						if (fle.name == MD5.hash(GUEST_NAME) + ".dta")
							continue;
						if (fle.name == MD5.hash(GUEST_MAIL) + ".dta")
							continue;
						
						if (fle.isDirectory){
							fle.deleteDirectoryAsync(true);
						}else{
							fle.deleteFileAsync();
						}
					}
				}
				clearing = false;
				if (callBack != null)
					callBack();
			}
			
			f.addEventListener(FileListEvent.DIRECTORY_LISTING, __onDirectoryListed);
			f.addEventListener(IOErrorEvent.IO_ERROR, __onDirIOError);
			f.addEventListener(SecurityErrorEvent.SECURITY_ERROR, __onDirSecError);
			f.getDirectoryListingAsync();
		}
		
		/**
		 * Load object from storage folder, 
		 * @param	name	String	File name to save	
		 * @param	callback function(data:Object,err:Boolean):void;
		 */
		static public function load(name:String, callBack:Function):void {
			if (clearing)
				return;
			fileworks = true;
			new Store(resetFileworks,new StoreIniter(), name, null, TYPE_LOAD,callBack);
		}
		
		static public function remove(name:String, callBack:Function = null):void {
			if (clearing)
				return;
			fileworks = true;
			new Store(resetFileworks,new StoreIniter(), name, null, TYPE_REMOVE, callBack);
		}
		
		static public function loadFile(fileName:String, callBack:Function):void {
			if (clearing)
				return;
			fileworks = true;
			new Store(resetFileworks, new StoreIniter(), fileName, null, TYPE_LOAD, callBack, true);
		}
		
		static private function resetFileworks():void {
			fileworks = false;
		}
		
		/**
		 * Save file to local store
		 * @param	fileName	String - file name, will be transformed to new File(fileName)
		 * @param	data	ByteArray - data to store
		 * @param	callBack	Function with argument: (data:Object,err:Boolean)
		 */
		static public function saveFile(fileName:String, data:ByteArray, callBack:Function, disposeAfterSave:Boolean = true):void {
			if (clearing)
				return;
			fileworks = true;
			new Store(resetFileworks, new StoreIniter(), fileName, data, TYPE_SAVE, callBack, true, disposeAfterSave);
		}
		
		// instance
		private var name:String;
		private var data:Object;
		private var callBack:Function;
		private var f:File;
		private var fs:FileStream;
		private var type:int;
		private var resultBytes:ByteArray;
		private var bytesReaded:int;
		private var bytesToRead:int = 4048;
		private var fileSaver:Boolean;
		private var disposeAfterSave:Boolean;
		private var resetFileworks:Function;
		private var id:int;
		private static var counter:int;
		
		public function Store(resetFileworks:Function,si:StoreIniter, name:String, data:Object, type:int, callBack:Function,fileSaver:Boolean=false,disposeAfterSave:Boolean=true) {
			this.resetFileworks = resetFileworks;
			this.disposeAfterSave = disposeAfterSave;
			this.fileSaver = fileSaver;
			
			this.callBack = callBack;
			this.type = type;
			this.data = data;
			this.name = name;
			
			id = counter;
			counter++;
			
			TweenMax.delayedCall(1, start, null, true);
		}
		
		private function start():void {

			if (fileSaver == false)
				f = new File(getFilename(name));
			else
				f = new File(name);
			f.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecError);
			f.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			
			//save
			if (type == TYPE_SAVE) {
				
			//	Error #2044: Unhandled IOErrorEvent:. text=Error #3013: File or directory is in use.
				try
				{
					fs = new FileStream();
					fs.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
					fs.openAsync(f, FileMode.WRITE);
					if (fileSaver == true) {
						resultBytes = data as ByteArray;
						resultBytes.position = 0;
					} else {
						resultBytes = new ByteArray();
						resultBytes.writeObject(data);
						resultBytes.position = 0;
					}
					Loop.add(onLoopWriteAsync);
				}
				catch (e:Error){
					ApplicationErrors.add();
				}
				
				return;
			}
			
			if (type == TYPE_REMOVE) {
				// TRYING TO REMOVE - SOMETIMES IT FIE IO ERROR
				f.addEventListener(Event.COMPLETE, onFileDeleted);
				f.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
				f.deleteFileAsync();
				return;
			}
			
			//load
			fs = new FileStream();
			fs.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			fs.addEventListener(OutputProgressEvent.OUTPUT_PROGRESS, onProgress);
			fs.addEventListener(Event.COMPLETE, onLoadComplete);
			fs.openAsync(f, FileMode.READ);
		}
		
		private function getFilename(value:String):String 
		{
			return Store.storeDirectory.nativePath + File.separator + MD5.hash(name) + '.dta';
		}
		
		private function onLoopWriteAsync():void {
			var btr:int = bytesToRead;
			resultBytes.position = 0;
			if (btr+bytesReaded > resultBytes.bytesAvailable)
				btr = resultBytes.bytesAvailable-bytesReaded;
			
			if (btr == 0) {
				Loop.remove(onLoopWriteAsync);
				fs.close();
				if(disposeAfterSave==true)
					resultBytes.clear();
				resultBytes = null;
				
				finish(false, null);
				return;
			}
			if (btr < 0)
			{
				Loop.remove(onLoopWriteAsync);
				fs.close();
				if(disposeAfterSave==true)
					resultBytes.clear();
				resultBytes = null;
				
				finish(true, null);
				return;
			}
			fs.writeBytes(resultBytes, bytesReaded, btr);
			bytesReaded += btr;
		}
		
		private function onLoadComplete(e:Event):void {
			if (fileSaver==false){
				var data:Object = null;
				if (fs.bytesAvailable > 0) {
					try {
						data=fs.readObject()
					}catch (e:Error) {
						finish(true, null);
						return;
					}
				}
				finish(false, data);
			}else {
				var ba:ByteArray = new ByteArray();
				fs.readBytes(ba);
				finish(false, ba);
			}
		}
		
		private function onFileDeleted(e:Event):void {
			onComplete();
		}
		
		private function onComplete(e:Event = null):void{
			finish(false, (type == TYPE_LOAD)?f.data.readObject():null);
		}
		
		private function onProgress(e:OutputProgressEvent):void {
			if (e.bytesPending == 0)
				onComplete();
		}
		
		private function onIOError(e:IOErrorEvent):void{
			finish(true);
		}
		
		private function onSecError(e:SecurityErrorEvent):void{
			finish(true);
		}
		
		private function finish(err:Boolean = false, data:Object = null):void {
			if(f != null){
				f.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecError);
				f.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
				f.removeEventListener(Event.COMPLETE, onFileDeleted);
			}
			
			if(fs != null){
				fs.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
				fs.removeEventListener(OutputProgressEvent.OUTPUT_PROGRESS, onProgress);
				fs.removeEventListener(Event.COMPLETE, onComplete);
				fs.removeEventListener(Event.COMPLETE, onLoadComplete);
				fs.close();
			}
			f = null;
			fs = null;
			resetFileworks();
			Loop.remove(onLoopWriteAsync);
			
			TweenMax.delayedCall(1, function():void { 
				if (callBack != null) {
					if (callBack.length == 2)
						callBack(data, err);
					if (callBack.length == 3)
						callBack(data, err, name);
				}
				name = null;
				this.data = null;
				callBack = null;
			},null, true);
		}
		
		/*
		 * Data that can be downloaded again or regenerated should be stored in the <Application_Home>/Library/Caches directory. Examples of files you should put in the Caches directory include database cache files and downloadable content, such as that used by magazine, newspaper, and map applications.
			Data that is used only temporarily should be stored in the <Application_Home>/tmp directory. Although these files are not backed up to iCloud, remember to delete those files when you are done with them so that they do not continue to consume space on the user’s device.*/
		static public function get storeDirectory():File {
			if (_storeDirectory == null)
				_storeDirectory = File.applicationStorageDirectory;
			//trace(_storeDirectory.nativePath);
			return _storeDirectory;
		}
	}
}

class StoreIniter {}