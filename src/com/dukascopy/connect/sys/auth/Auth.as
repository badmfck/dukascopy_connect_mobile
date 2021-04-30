package com.dukascopy.connect.sys.auth {
	
	import com.adobe.crypto.MD5;
	import com.adobe.crypto.SHA1;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.CountriesData;
	import com.dukascopy.connect.data.UserBanData;
	import com.dukascopy.connect.screens.serviceScreen.AppIntroScreen;
	import com.dukascopy.connect.screens.serviceScreen.FillUserInfoScreen;
	import com.dukascopy.connect.sys.calendar.Calendar;
	import com.dukascopy.connect.sys.configManager.ConfigManager;
	import com.dukascopy.connect.sys.connectionManager.NetworkManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.errors.ErrorLocalizer;
	import com.dukascopy.connect.sys.nativeExtensionController.NativeExtensionController;
	import com.dukascopy.connect.sys.notificationManager.PushNotificationsNative;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.sys.promocodes.ReferralProgram;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.settings.GlobalSettings;
	import com.dukascopy.connect.sys.sqlite.SQLite;
	import com.dukascopy.connect.sys.store.Store;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.sys.ws.WSClient;
	import com.dukascopy.connect.type.BankPhaze;
	import com.dukascopy.connect.type.UserBlockStatusType;
	import com.dukascopy.connect.type.UserType;
	import com.dukascopy.connect.utils.ArrayUtils;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.connect.vo.CompanyVO;
	import com.dukascopy.connect.vo.users.UserVO;
	import com.dukascopy.connect.vo.users.adds.MemberVO;
	import com.dukascopy.langs.Lang;
	import com.hurlant.crypto.hash.IHash;
	import com.telefision.sys.etc.Print_r;
	import com.telefision.sys.signals.Signal;
	import flash.data.EncryptedLocalStore;
	import flash.system.Capabilities;
	import flash.utils.ByteArray;
	
	/**
	 * @author Igor Bloom
	 */
	
	public class Auth {
		
		public static var S_AUTHORIZED:Signal = new Signal('Auth.S_AUTHORIZED');
		public static var S_SMS_CODE_VERIFICATION_RESPOND:Signal = new Signal('Auth.S_SMS_CODE_VERIFICATION_RESPOND');
		public static var S_GET_SMS_CODE_RESPOND:Signal = new Signal('Auth.S_GET_SMS_CODE_RESPOND');
		public static var S_NEED_AUTHORIZATION:Signal = new Signal('Auth.S_NEED_AUTHORIZATION');
		public static var S_SYS_ERROR_DEVICE_NOT_SUPPORTED:Signal = new Signal('Auth.S_SYS_ERROR_DEVICE_NOT_SUPPORTED');
		public static var S_AUTH_DATA_UPDATED:Signal = new Signal('Auth.S_AUTH_DATA_UPDATED');
		public static var S_LOGOUT:Signal = new Signal('Auth.S_LOGOUT');
		public static var S_PHAZE_CHANGE:Signal = new Signal('Auth.S_PHAZE_CHANGE');
		public static var S_PHAZE_DATA_CHANGE:Signal = new Signal('Auth.S_PHAZE_DATA_CHANGE');
		public static var S_DEVICES:Signal = new Signal('Auth.S_DEVICES');
		public static var S_AUTH_CODE:Signal = new Signal('Auth.S_AUTH_CODE');
		
		static private var _authKey:String = 'web';// null;
		static private var _devID:String = null;
		
		static private var _username:String = null;
		static private var _login:String = null;
		static private var _showRating:int = 1;
		static private var _companyID:String = null;
		static private var _company:CompanyVO = null;
		static private var _type:String = null;
		static private var _gender:String = "";
		static private var _avatar:String = null;
		static private var _uid:String =null;
		static private var _fxcommID:uint=0;
		static private var _phone:Number = 0;
		static private var _languages:Array=[];
		static private var _ignoreGuests:Boolean=false;
		static private var _friendsOnly:Boolean;
		static private var _blocked:Array = [];
		static private var _fxFirstName:String=null;
		static private var _fxLastName:String=null;
		static private var _created:String = null;
		static private var _country:String = null;
		static private var _countryCode:int = 0;
		static private var _countryIso1:String='';
		static private var _countryIso2:String = '';
		static private var authorizationClearing:Boolean = false;
		static private var _isExpired:Boolean = false;
		static private var lastLoadedDataObject:Object;
		static private var laststoredDataHash:String;
		static private var tempAvatarId:String;
		static private var _avatarLarge:String;
		static private var _pushNitificationsAllowed:Boolean = true;
		static private var _firstInstall:Boolean = false;
		static private var busy:Boolean = false;
		
		static public var myProfile:UserVO;
		
		static public var S_PROFILE_CHANGE:Signal = new Signal('Auth.S_AVATAR_CHANGE');
		
		static public const AVATAR:String = "avatar";
		static public const NAME:String = "name";
		
		static private var _ch_phaseData:String = null; //mca / general
		static private var _eu_phaseData:String = null; //mca / general
		static private var _bank_phaseData:String = null; //mca / general
		static private var _ch_phase:String = "UNKNOWN";
		static private var _eu_phase:String = "UNKNOWN";
		static private var _bank_phase:String = "UNKNOWN";
		
		static private var phasesEP:Object = {};
		static private var _ratingSaving:Boolean;
		
		public function Auth() { }
		
		static public function init():void {
			S_NEED_AUTHORIZATION.add(clearAllAuthData);
			if (!EncryptedLocalStore.isSupported) {
				S_SYS_ERROR_DEVICE_NOT_SUPPORTED.invoke();
				return;
			}
			_authKey = getItem('dc_connect_authKey');
			if (_authKey == null || _authKey == "web") {
				clearAuthorization("");
				return;
			}
			var storedData:String = getItem('dc_connect_profile');
			laststoredDataHash = getItem('dc_connect_profile_hash');
			if (storedData == null) {
				trace('Auth -> no stored data object');
				clearAuthorization("");
				return;
			}
			var data:Object = null;
			try {
				data = JSON.parse(storedData);
			} catch (e:Error) {
				trace('Auth -> wrong json stored data object');
				clearAuthorization("");
				return;
			}
			if (data == null) {
				trace('Auth -> stored data object is null');
				clearAuthorization("");
				return;
			}
			currentRawProfileData = data;
			setAuthData(data);
			authorizationClearing = false;
			_isExpired = false;
			ConfigManager.init(function():void {
				updateFromPhp();
				authorized();
			});
		}
		
		private static function authorized():void {
			
			_isAuthorized = true;
			WSClient.S_USER_BLOCK_STATUS.add(onUserBlockStatusChangedFromWS);
			WSClient.S_PUSH_GLOBAL_STATUS.add(onPushNotifocationsChanged);
			WSClient.S_UPDATE_ENTRY_POINTS.add(updateFromPhp);
			WSClient.S_USER_PROFILE_UPDATE.add(updateFromWS);
			WSClient.S_USER_PHASE_CHANGED.add(onUserPhaseChanged);
			UsersManager.USER_BLOCK_CHANGED.add(onUserBlockStatusChanged);
			S_AUTHORIZED.invoke();
		}
		
		static private function onUserPhaseChanged(data:Object):void{
			if (data == null)
				return;
			
			if ("steps" in data && data.steps != null && data.steps != "")
			{
				regSteps = data.steps;
			}
			
			if ("name" in data == true && data.name == "ch_bank") {
				if ("phase" in data == true && data.phase != null) {
					_bank_phase = data.phase;
					S_PHAZE_CHANGE.invoke();
				}
			} else if ("name" in data == true && data.name == "ch_pp") {
				if ("phase" in data == true && data.phase != null) {
					_ch_phase = data.phase;
					S_PHAZE_CHANGE.invoke();
				}
			} else if ("name" in data == true && data.name == "eu_pp") {
				if ("phase" in data == true && data.phase != null) {
					_eu_phase = data.phase;
					S_PHAZE_CHANGE.invoke();
				}
			}

			if(_bank_phase=="VIDID_READY"){
				PHP.call_regDev();
			}
		}
		
		
		static private function updateFromWS(data:Object):void {
			if (data == null)
				return;
			if (uid != data.userUID)
				return;
			if ("payRating" in data == true && data.payRating != null && isNaN(data.payRating) == false) {
				if (data.payRating != -1)
					_showRating = 1;
				else
					_showRating = 0;
			}
			lastLoadedDataObject.profile.showRating = _showRating;
			
			if ("gift" in data == true)
			{
				if (myProfile != null)
				{
					myProfile.addGiftData(data.gift);
				}
				if (lastLoadedDataObject.profile.gifts == null)
				{
					lastLoadedDataObject.profile.gifts = new Array();
				}
				if (lastLoadedDataObject.profile.gifts is Array)
				{
					lastLoadedDataObject.profile.gifts.push(data.gift);
				}
			}
			
			updateDataInStorage();
			S_AUTH_DATA_UPDATED.invoke();
		}
		
		static private function onPushNotifocationsChanged(result:Object):void {
			_pushNitificationsAllowed = result.status;
			updateDataInStorage();
		}
		
		static private function onUserBlockStatusChangedFromWS(data:Object):void {
			if (data.block)
				blockUser(data.uid);
			else
				unblockUser(data.uid);
		}
		
		static private function onUserBlockStatusChanged(data:Object):void {
			if (data.status == UserBlockStatusType.BLOCK)
				blockUser(data.uid);
			else if (data.status == UserBlockStatusType.UNBLOCK)
				unblockUser(data.uid);
		}
		
		static private function unblockUser(uid:String):void {
			var index:int = _blocked.indexOf(uid);
			if (index != -1)
				_blocked.removeAt(index);
			//!TODO: internal error, new unblocked status for the user that not stored as blocked one;	
			updateDataInStorage();
		}
		
		static private function blockUser(uid:String):void {
			if (_blocked.indexOf(uid) == -1)
				_blocked.push(uid);
			updateDataInStorage();
		}
		
		static public function clearAllAuthData():void {
			_isAuthorized = false;
			_authKey = 'web';
			_companyID = null;
			_company = null;
			_username = null;
			_type = null;
			_gender = null;
			_avatarLarge = null;
			_avatar = null;
			_uid = null;
			_fxcommID = 0;
			tempAvatarId = null;
			_phone = 0;
			_languages = [];
			_ignoreGuests = false;
			_friendsOnly;
			_blocked = [];
			_pushNitificationsAllowed = true;
			_fxFirstName = null;
			_fxLastName = null;
			_created = null;
			_country = null;
			_countryCode = 0;
			_countryIso1 = '';
			_countryIso2 = '';
			bansData = null;
			currentRawProfileData = null;
			
			WSClient.S_USER_BLOCK_STATUS.remove(onUserBlockStatusChangedFromWS);
			WSClient.S_PUSH_GLOBAL_STATUS.remove(onPushNotifocationsChanged);
			WSClient.S_UPDATE_ENTRY_POINTS.remove(updateFromPhp);
			WSClient.S_USER_PROFILE_UPDATE.remove(updateFromWS);
			WSClient.S_USER_PHASE_CHANGED.remove(onUserPhaseChanged);
			UsersManager.USER_BLOCK_CHANGED.remove(onUserBlockStatusChanged);
			
			NativeExtensionController.setAuthKey(null);
		}
		
		public static function getItem(name:String):String {
			if (!EncryptedLocalStore.isSupported)
				return null;
			var ba:ByteArray=null;
			try{
				ba= EncryptedLocalStore.getItem(name);
			}catch(e:Error){
				trace("GOT ELS ERROR: "+e.message);
			}
			if (ba == null || ba.length == 0 || ba.bytesAvailable == 0)
				return null;
			try {
				ba.uncompress();
			} catch (e:Error) {
				echo("Auth", "getItem", 'Can`t uncompress bytes!', true);
				return null;
			}
			ba.position = 0;
			var str:String = ba.readUTFBytes(ba.length);
			ba.clear();
			ba = null;
			return str;
		}
		
		public static function removeItem(name:String):void{
			if (!EncryptedLocalStore.isSupported)
				return;
			try{
				EncryptedLocalStore.removeItem(name);
			}catch(e:Error){
				trace("GOT ELS error: "+e.message);
			}
		}

		public static function setItem(name:String, value:String):void {
			if (!EncryptedLocalStore.isSupported)
				return;
			if (value == null)
				value = "";
			echo("Auth", "setItem", "name:" + name+", value:" + escape(value.substr(0, 256)));
			var ba:ByteArray = new ByteArray();
			ba.writeUTFBytes(value);
			ba.compress();
			try{
				EncryptedLocalStore.setItem(name, ba);
			}catch(e:Error){
				trace("Got ELS error: "+e.message);
			}
			ba.clear();
		}
		
		static public function authorize_requestCode(phone:String, attempt:int = 0):void {
			PHP.auth_requestCode(onRequestCodeResponse, phone, devID, { phone:phone, attempt:attempt } );
		}
		
		static public function authorize_requestCall(phone:String):void{
			currentPhone = phone;
			PHP.auth_requestCall(onRequestCallResponse, phone, devID);
		}
		
		static public function authorize_sendCode(phone:String, code:String, attempt:int = 0):void {
			PHP.auth_sendCode(onReceiveCodeRespond, phone, devID, code, Config.PLATFORM_TYPE, Capabilities.manufacturer, { phone:phone, code:code, attempt:attempt } );
		}
		
		static private function onRequestCodeResponse(r:PHPRespond):void {
			if (r.error == true) {
				if (r.errorMsg == "io") {
					if (NetworkManager.isConnected == false) {
						DialogManager.alert(Lang.textAlert, Lang.alertProvideInternetConnection);
					} else {
						if (r.additionalData != null && "attempt" in r.additionalData && r.additionalData.attempt < 3) {
							echo("Auth", "onRequestCodeResponse", "Attempt -> " + r.additionalData.attempt);
							if ("phone" in r.additionalData)
								authorize_requestCode(r.additionalData.phone, r.additionalData.attempt + 1);
							r.dispose();
							return;
						}
						DialogManager.alert(Lang.textAlert, Lang.alertServerUnderMaintenance);
					}
					S_GET_SMS_CODE_RESPOND.invoke(r.error);
					r.dispose();
					return;
				}
				S_GET_SMS_CODE_RESPOND.invoke(r.error, r.errorMsg.substr(0, 7));
				DialogManager.alert(Lang.alertAuthorisationError , ErrorLocalizer.getText(r.errorMsg, "AUTH"));
				r.dispose();
				return;
			}
			
			echo("Auth", "onRequestCodeResponse", Print_r.show(r.data));
			if ("code" in r.data && Config.isTest() == true)
			{
				S_AUTH_CODE.invoke(r.data.code);
			//	authorize_sendCode(r.data.to, r.data.code);
			}
			S_GET_SMS_CODE_RESPOND.invoke(r.error);
		//	DialogManager.alert(Lang.information, Lang.smsCodeSent);
			
			if (("data" in r) && ("isCallable" in r.data)) {
				_isCallableToObtainLoginCode = Boolean(r.data.isCallable);
			} else {
				_isCallableToObtainLoginCode = true;
			}
			r.dispose();
		}
		
		static private function onRequestCallResponse(r:PHPRespond):void {
			if (r.error == true) {
				if (r.errorMsg == "io") {
					if (NetworkManager.isConnected == false)
						DialogManager.alert(Lang.textAlert, Lang.alertProvideInternetConnection);
					else
						DialogManager.alert(Lang.textAlert, Lang.alertServerUnderMaintenance);
					r.dispose();
					return;
				}
				DialogManager.alert(Lang.alertAuthorisationError , ErrorLocalizer.getText(r.errorMsg, "AUTH"));
				r.dispose();
				return;
			}
			var phoneString:String = currentPhone;
			if (phoneString != null && phoneString.length > 0 && phoneString.indexOf("p") == 0)
			{
				phoneString = phoneString.substring(1);
			}
			DialogManager.alert(Lang.information, Lang.verificationCodeVoiceCall + phoneString);
			r.dispose();
		}
		
		static private function onReceiveCodeRespond(r:PHPRespond):void {
			if (r.error == true) {
				PHP.call_statVI("SMSCodeWrong", (r.errorMsg) ? r.errorMsg : "unknown error");
				if (r.errorMsg == "io") {
					if (NetworkManager.isConnected == false) {
						DialogManager.alert(Lang.textAlert, Lang.alertProvideInternetConnection);
					} else {
						if (r.additionalData != null && "attempt" in r.additionalData && r.additionalData.attempt < 3) {
							echo("Auth", "onRequestCodeResponse", "Attempt -> " + r.additionalData.attempt);
							if ("phone" in r.additionalData && "code" in r.additionalData)
								authorize_sendCode(r.additionalData.phone, r.additionalData.code, r.additionalData.attempt + 1);
							r.dispose();
							return;
						}
						DialogManager.alert(Lang.textAlert, Lang.alertServerUnderMaintenance);
					}
					S_SMS_CODE_VERIFICATION_RESPOND.invoke(true);
					r.dispose();
					return;
				}
				S_SMS_CODE_VERIFICATION_RESPOND.invoke(true);
				DialogManager.alert(Lang.alertAuthorisationError , ErrorLocalizer.getText(r.errorMsg, "AUTH"));
				r.dispose();
				return;
			}
			var isAuth:String=("authKey" in r.data && r.data.authKey!=null)?"ok "+r.data.authKey.length:"bad auth key";
			var isProfile:String=("profile" in r.data && r.data.profile!=null)?"ok ":"bad profile";
			PHP.call_statVI("SMSCodeSuccess", "auth:"+isAuth+", profile: "+isProfile);
			if (!('authKey' in r.data)) {
				S_SMS_CODE_VERIFICATION_RESPOND.invoke(true);
				DialogManager.alert(Lang.alertAuthorisationError, Lang.serverError + Lang.noAuthKey);
				r.dispose();
				return;
			}
			if (!('profile' in r.data)) {
				S_SMS_CODE_VERIFICATION_RESPOND.invoke(true);	
				DialogManager.alert(Lang.alertAuthorisationError, Lang.serverError + Lang.noProfileData);
				r.dispose();
				return;
			}

			S_SMS_CODE_VERIFICATION_RESPOND.invoke(false);

			setAuthData(r.data, true);
			
			//отправляем запрос на добавление первого вопроса от своего имени при регистрации
			if (phone.toString().indexOf("5555000") !=-1)
				r.data.firstInstall = true;

			if ('firstInstall' in r.data && Boolean(r.data.firstInstall) == true) {
				PHP.call_statVI("firstInstall", Config.PLATFORM);
				if (Config.socialAvailable == true) {
					if(Auth.phone!=155550987)
						ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, AppIntroScreen);
				} else {
					if(Auth.phone!=155550987) {
						ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, FillUserInfoScreen);
						ReferralProgram.promptEnterCode();
					}
				}
				
				_firstInstall = true;
				Store.save("ShowQueInfo", { val:true } );
			}
			if ('newUser' in r.data && Boolean(r.data.newUser) == true){
				_newUser = Boolean(r.data.newUser);
				PHP.call_statVI("newUser", Config.PLATFORM);
			}
			setItem('dc_connect_authKey', _authKey);
			var newHash:String = ArrayUtils.getObjectHash(r.data, ["authorized"]);
			if (laststoredDataHash != newHash) {
				laststoredDataHash = newHash;
				var dataToSave:String = JSON.stringify(r.data);
				setItem('dc_connect_profile_hash', laststoredDataHash);
				setItem('dc_connect_profile', dataToSave);
			}
			authorizationClearing = false;
			_isExpired = false;
			ConfigManager.init(function():void {
				authorized();
			});
			r.dispose();
		}
		
		static public function updateFromPhp(...rest):void {
			if (busy == true)
				return;
			var onProfileFromPHPGained:Function = function(phpRespond:PHPRespond):void {
				busy = false;
				if (phpRespond.error) {
					echo("Auth", "updateFromPhp::onProfileFromPHPGained", "");
					phpRespond.dispose();
					return;
				}
				if (phpRespond.data) {
					currentRawProfileData = phpRespond.data;
					updateLocalProfileData();
					setAuthData(phpRespond.data, true);
				}
				phpRespond.dispose();
			}
			busy = true;
			PHP.auth_getCurrentUser(onProfileFromPHPGained, laststoredDataHash);
		}
		
		static private function updateLocalProfileData():void {
			if (currentRawProfileData != null) {
				var newHash:String = ArrayUtils.getObjectHash(currentRawProfileData, ["authorized"]);
				if (laststoredDataHash != newHash) {
					laststoredDataHash = newHash;
					var dataToSave:String = JSON.stringify(currentRawProfileData);
					setItem('dc_connect_profile_hash', laststoredDataHash);
					setItem('dc_connect_profile', dataToSave);
				}
			}
		}
		
		static public function updateAfterPhasePush():void {
			if (_authKey == "web")
				return;
			updateFromPhp();
		}
		
		static private function _connectToWS():void {
			//WS.connect();
		}
		
		static private function updateDataInStorage():void {
			var dataToSave:Object;
			if (lastLoadedDataObject)
				dataToSave = lastLoadedDataObject;
			else {
				var loadedData:String = getItem('dc_connect_profile');
				try {
					dataToSave = JSON.parse(loadedData);
				} catch (e:Error) {
					// TODO: critical error;
					return;
				}
			}
			if (dataToSave) {
				updateDataObjectWithCurrentValues(dataToSave);

				var newHash:String = ArrayUtils.getObjectHash(dataToSave, ["authorized"]);
				if (laststoredDataHash != newHash)
				{
					laststoredDataHash = newHash;
					var newDataString:String = JSON.stringify(dataToSave);
					setItem('dc_connect_profile', newDataString);
					setItem('dc_connect_profile_hash', laststoredDataHash);
				}
			}
		}
		
		static private function updateDataObjectWithCurrentValues(dataToSave:Object):void {
			dataToSave.profile.blocks = _blocked;
			dataToSave.profile.pushAllowed = _pushNitificationsAllowed;
		}
		
		static private function setAuthData(data:Object, fromPHP:Boolean = false):void {
			bansData = new Array();
			lastLoadedDataObject = data;
			
			_authKey = data['authKey'];
			_uid = null;
			_username = null;
			_phone = 0;
			pizdec = null;


			if ('profile' in data) {
				_login = data.profile.username;
				_showRating = data.profile.showRating;
				_companyID = data.profile.companyID;
				_uid = data.profile.uid;
				echo("Auth", "setAuthData", "PROFILE UID: " + _uid);
				_phone = data.profile.phone;
				_type = data.profile.type;
				_username = data.profile.name;
				_created = data.profile.created;
				
				_fxcommID = parseInt(data.profile.fxid);
				_blocked = data.profile.blocks;
				
				if ("gender" in data.profile == true)
					_gender = data.profile.gender;
				if ("pushAllowed" in data.profile) {
					_pushNitificationsAllowed = data.profile.pushAllowed;
				}
				
				setPhases(data.profile, fromPHP);
			}
			
			var fxData:Object = null;
			if ('fxcomm' in data.profile && data.profile.fxcomm != null) {
				fxData = data.profile.fxcomm;
				if ("avatar" in fxData)
					_avatar = data.profile.fxcomm.avatar;
				if ("avatar_large" in fxData)
					avatarLarge = data.profile.fxcomm.avatar_large;
				if ("friendsOnly" in fxData)
					_friendsOnly = (data.profile.fxcomm.friendsOnly == "1") ? true : false;
				if ("ignoreGuests" in fxData)
					_ignoreGuests = (data.profile.fxcomm.ignoreGuests == "1") ? true : false;
				if ("spoken_languages" in fxData)
					_languages = data.profile.fxcomm.spoken_languages;
				if ("firstname" in fxData)
					_fxFirstName = data.profile.fxcomm.firstname;
				if ("lastname" in fxData)
					_fxLastName = data.profile.fxcomm.lastname;
			}
			
			if (_avatar != null)
				_avatar = _avatar.replace("http://www.dukascopy.com", "https://www.dukascopy.com");
			
			if (myProfile == null) {
				myProfile = new UserVO();
				myProfile.incUseCounter();
			}
			myProfile.setData(data.profile);

			//SET PAY RATING
			if(_bank_phase.toLowerCase()=="acc_approved" && myProfile.payRating==0)
				myProfile.setPayRating(1);


			if (_uid == null || _username == null || _phone == 0) {
				DialogManager.alert(Lang.alertAuthorisationError, Lang.wrongOrDamagedUser, function(choose:int):void {
					clearAuthorization();
				});
				return;
			}
			
			var c:Array = CountriesData.getCountryByPhoneNumber(_phone+'');
			if (c == null) {
				trace('TODO - WRONG PHONE PROVIDED. CAN`T FIND COUNTRY CODE');
				return;
			}
			
			_country = c[0];
			_countryCode = c[3];
			_countryIso1 = c[1];
			_countryIso2 = c[2];
			
			NativeExtensionController.setAuthKey(_authKey);
			
			S_AUTH_DATA_UPDATED.invoke();
		}
		
		static private function setPhases(data:Object, fromPHP:Boolean = false):void {
			

			var old_ch_phase:String = _ch_phase;
			var old_eu_phase:String = _eu_phase;
			var old_bank_phase:String = _bank_phase;


			// ch_phase - Швейцарский пеймент
			
			// CH_PP - Европейские пейменты
			_ch_phase = "UNKNOWN";
			if ('ch_pp' in data == true && data.ch_pp != null)
				_ch_phase = data.ch_pp;
			_ch_phaseData = null;
			if ("ch_pp_data" in data)
				_ch_phaseData = data.ch_pp_data;
				
			// EU_PP - Европейский трейдинг
			_eu_phase = "UNKNOWN";
			if ('eu_pp' in data && data.eu_pp != null)
				_eu_phase = data.eu_pp;
			_eu_phaseData = null;
			if ("eu_pp_data" in data)
				_eu_phaseData = data.eu_pp_data;
				
			// CH_BANK - Швейцарские пейменты, швейцарский трейдинг
			_bank_phase = "UNKNOWN";
			if ('bank_pp' in data && data.bank_pp != null)
				_bank_phase = data.bank_pp;


			var changed:Boolean = false;
			if (old_ch_phase != _ch_phase || old_eu_phase != _eu_phase || old_bank_phase != _bank_phase)
			{
				changed = true;
			}



			_bank_phaseData = null;
			if ("bank_pp_data" in data)
				_bank_phaseData = data.bank_pp_data;



			S_PHAZE_CHANGE.invoke(changed);
			S_PHAZE_DATA_CHANGE.invoke();

			var epID:int;
			if ((_bank_phase == "VIDID" ||  _bank_phase == "VIDID_READY" ||  _bank_phase == "VIDID_QUEUE" || _bank_phase=="VIDID_PROGRESS") && fromPHP == true) {
				viExist = true;
				epID = Config.EP_VI_DEF;
				PushNotificationsNative.setNotificationDataForSupport(epID);
				if (fromPHP == true && _bank_phaseData != null && _bank_phaseData.toLowerCase() == "mca" && _bank_phase == "VIDID_QUEUE") {
					Calendar.checkAppointmentData();
				}
				return;
			}

			if ((_eu_phase == "VIDID" ||  _eu_phase == "VIDID_READY" || _eu_phase=="VIDID_PROGRESS") && fromPHP == true) {
				viExist = true;
				epID= Config.EP_VI_EUR;
				PushNotificationsNative.setNotificationDataForSupport(epID);
				return;
			}
		}
		
		static public function hasFXName():Boolean {
			if (_fxFirstName == null && _fxLastName == null)
				return false;
			if ((_fxFirstName == null || _fxFirstName == "") && _fxLastName == _username)
				return false;
			if (_fxFirstName == _username && (_fxLastName == null || _fxLastName == ""))
				return false;
			return true;
		}
		
		static public function getFXName():String {
			var res:String = "";
			if (_fxFirstName != null && _fxFirstName != "")
				res = _fxFirstName;
			if (_fxLastName != null && _fxLastName != "") {
				if (res != "")
					res += " ";
				res += _fxLastName;
			}
			return res;
		}
		
		static public function getFirstName():String {
			if (_fxFirstName != null)
				return _fxFirstName;
			return "";
		}
		
		static public function getLastName():String {
			if (_fxLastName != null)
				return _fxLastName;
			return "";
		}
		
		static public function clearAuthorization(err:String = null, force:Boolean = false):void {
			if (authorizationClearing && force == false)
				return;
			if (err == null) {
				S_LOGOUT.invoke();
				PHP.auth_logout(null);
			}
			NativeExtensionController.clearFingerprint();
			_isExpired = true;
			authorizationClearing = true;

			UsersManager.removeUser(myProfile, null, true);
			myProfile = null;
			_authKey = "web";
			viExist = false;
			_newUser = false;
			needToAskFirstQuestion = false;
			pizdec = null;
			laststoredDataHash = "";
			GlobalSettings.reset();

            if(EncryptedLocalStore.isSupported) {
				try{
					var dID:ByteArray = EncryptedLocalStore.getItem('dc_connect_devID');
					EncryptedLocalStore.reset();
					if (dID != null)
						EncryptedLocalStore.setItem('dc_connect_devID', dID);
				}catch(e:Error){
					trace("GOT ELS ERROR: "+e.message);
				}
            }

			SQLite.clear();
			_isCallableToObtainLoginCode = true;
			Store.clearAll(function():void {
				echo("Auth", "clearAuthorization", "store cleared");
				S_NEED_AUTHORIZATION.invoke();
			});
		}
		
		static public function setMyPhone(value:String):void {
			if (isNaN(Number(value)))
				return;
			setItem("myPhone", value);
		}
		
		static public function getMyPhone():String {
			var myPhone:String = getItem("myPhone");
			if (myPhone == null)
				myPhone = "";
			return myPhone;
		}
		
		static public function get devID():String {
			/*if (_devID == null)
				_devID = MD5.hash(Capabilities.serverString) + MD5.hash(new Date().getTime() + ',' + Math.round(Math.random() * 10000));
			return _devID;*/
			if (_devID == null)
			{
				if (Config.PLATFORM_APPLE || Config.PLATFORM_ANDROID) {
					_devID = getItem('dc_connect_devID');
					if (_devID == null) {
						_devID = NativeExtensionController.getDeviceId();
						if (_devID == null) {
							_devID = MD5.hash(Capabilities.serverString) + MD5.hash(new Date().getTime() + ',' + Math.round(Math.random() * 10000));
						} else {
							_devID = SHA1.hash(_devID);
						}
						setItem('dc_connect_devID', _devID);
					}
				} else {
					_devID = MD5.hash(new Date().getTime() + "");
				}
			}
			
			// ADD PLATFORM TO DEVID
			var dev:String = "w_";
			if(Config.PLATFORM_APPLE)
				dev = "i_";
			else if(Config.PLATFORM_ANDROID)
				dev = "a_";
			return dev + "" + _devID;
		}
		
		static public function get key():String {
			if (_authKey == null)
				_authKey = 'web';
			return _authKey;
		}
		
		static public function get username():String { return _username; }
		static public function get type():String { return _type; }
		
		static public function get avatar():String {
			if (tempAvatarId != null && tempAvatarId != "") {
				return Config.URL_PHP_CORE_SERVER_FILE + "?method=files.get&key=web&uid=" + tempAvatarId + "&type=image";
			}
			return _avatar;
		}
		
		static public function get uid():String { return _uid; }
		static public function get fxcommID():uint { return _fxcommID; }
		static public function get blocked():Array { return _blocked; }
		static public function get countryCode():int { return _countryCode; }
		static public function get companyID():String { return _companyID; }
		static public function get company():CompanyVO { return _company; }
		static public function get phone():Number { return _phone; }
		
		static public function get isExpired():Boolean 	{ return _isExpired; }
		static public function set isExpired(value:Boolean):void {
			_isExpired = value;
		}
		
		static private var pizdec:String = null;
		static private var currentPhone:String;
		static private var _isCallableToObtainLoginCode:Boolean = true;
		static private var bansData:Array;
		static private var currentRawProfileData:Object;
		static private var viExist:Boolean;
		static private var _newUser:Boolean;
		static private var dialogShowed:Boolean;
		static private var devices:Array;
		static private var _isAuthorized:Boolean;
		static public var regSteps:String;
		static public var needToAskFirstQuestion:Boolean = false;
		
		static public function get avatarLarge():String{
			if (tempAvatarId != null && tempAvatarId != "")
			{
				return Config.URL_PHP_CORE_SERVER_FILE + "?method=files.get&key=web&uid=" + tempAvatarId + "&type=image";
			}
			//return _avatar;
			
			if (pizdec != null)
				return pizdec;
			
			try{
				var path:String = Auth.avatar;
				var kostil:Array = path.split("uid=http:");
				if (kostil.length > 0)
					path = "https:"+kostil[kostil.length - 1];
				
				if (path.indexOf("method=files.get") != -1){
					path = _avatarLarge;
				}else{
					if (path.toLocaleLowerCase().indexOf("www.dukascopy.com/imageserver/img/")){
						var tmp:Array = path.split("www.dukascopy.com/imageserver/img/");
						if(tmp.length>0){
							var tmp2:Array = tmp[1].split("/");
							var uid:String = tmp2[0];
							if (uid.length > 0){
								path = "https://www.dukascopy.com/imageserver/img/" + uid + "/240_3/image.jpg";
							}
						}	
					}
				}
				
				pizdec = path;
				
				if (path==null)
					return _avatar;
				
				return path;
				
			}catch (e:Error) {
				return _avatar;
			}
			return _avatar;
		}
		
		static public function set avatarLarge(value:String):void 
		{
			_avatarLarge = value;
		}
		
		static public function get fxFirstName():String 
		{
			return _fxFirstName;
		}
		
		static public function get fxLastName():String 
		{
			return _fxLastName;
		}
		
		static public function get isCallableToObtainLoginCode():Boolean 
		{
			return _isCallableToObtainLoginCode;
		}
		
		static public function get login():String {
			return _login;
		}
		
		static public function get showRating():int 
		{
			return _showRating;
		}
		
		static public function get newUser():Boolean {
			return _newUser;
		}
		
		
		static public function getPushNitificationsAllowed():Boolean 
		{
			return _pushNitificationsAllowed;
		}
		
		public static function getLargeAvatar(size:int):String
		{
			if (tempAvatarId != null && tempAvatarId != "")
			{
				return Config.URL_PHP_CORE_SERVER_FILE + "?method=files.get&key=web&uid=" + tempAvatarId + "&type=image";
			}
		//	return _avatar;
			
			if (pizdec != null)
				return pizdec;
			
			try{
				var path:String = Auth.avatar;
				var kostil:Array = path.split("uid=http:");
				if (kostil.length > 0)
					path = "https:" + kostil[kostil.length - 1];
				
				if (path.indexOf("method=files.get") != -1){
					path = _avatarLarge;
				}else{
					if (path.toLocaleLowerCase().indexOf("www.dukascopy.com/imageserver/img/")){
						var tmp:Array = path.split("www.dukascopy.com/imageserver/img/");
						if(tmp.length>0){
							var tmp2:Array = tmp[1].split("/");
							var uid:String = tmp2[0];
							if (uid.length > 0){
								path = "https://www.dukascopy.com/imageserver/img/" + uid + "/" + size + "_3/image.jpg";
							}
						}	
					}
				}
				
				pizdec = path;
				
				if (path==null)
					return _avatar;
				
				return path;
				
			}catch (e:Error) {
				return _avatar;
			}
			return _avatar;
		}
		
		static public function getCompanyMemberByUID(userUID:String):MemberVO {
			if (_company == null)
				return null;
			if (_company.members == null)
				return null;
			var l:int = _company.members.length;
			for (var i:int = 0; i < l; i++) {
				if (_company.members[i].userUID == userUID)
					return _company.members[i];
			}
			return null;
		}
		
		static public function changeAvatar(image:String, changeAvatarRequest:String):void {
			var __onRespond:Function = function(phpRespond:PHPRespond):void {
				if (phpRespond.error) {
					S_PROFILE_CHANGE.invoke({success:false, requestId:changeAvatarRequest});
					DialogManager.alert(Lang.textWarning, Lang.alertChangeUserAvatar + "\n" + phpRespond.errorMsg);
					phpRespond.dispose();
					return;
				}
				saveCurrentProfile(phpRespond.data.toString(), AVATAR, null, null, changeAvatarRequest);
				phpRespond.dispose();
			}
			PHP.changeUserAvatar(image, __onRespond);
		}
		
		static public function changeUsername(firstName:String, secondName:String, requestId:String = null):void {
			if (firstName == "") {
				_fxFirstName = null;
			} else {
				_fxFirstName = firstName;
			}
			
			if (secondName == "") {
				_fxLastName = null;
			} else {
				_fxLastName = secondName;
			}
			
			saveCurrentProfile(null, NAME, firstName, secondName, requestId);
		}
		
		// ЗАПРЕЩЕНО ИСПОЛЬЗОВАТЬ. КОСТЫЛЬ. СПАСИБО СЕРЁЖКЕ
		static public function not_recomendet_setAuth(key:String):void{
			_authKey = key;
		}
		
		static public function changeNotifications(value:Boolean):void {
			WSClient.call_changeNotoficationsMode(value);
		}
		
		static private function saveCurrentProfile(avatarId:String, dataType:String, firstName:String = null, secondName:String = null, requestId:String = null):void {
			var firstNameNew:String = firstName;
			var secondNameNew:String = secondName;
			
			var __onRespond:Function = function(phpRespond:PHPRespond):void {
				if (phpRespond.error) {
					S_PROFILE_CHANGE.invoke( { success:false, requestId:requestId } );
					if (dataType == AVATAR) {
						if (phpRespond.errorMsg == "io") {
							DialogManager.alert(Lang.textAlert, Lang.pleaseTryLater);
							phpRespond.dispose();
							return;
						}
						DialogManager.alert(Lang.textWarning, Lang.alertChangeUserAvatar + "\n" + phpRespond.errorMsg);
					}
					phpRespond.dispose();
					return;
				}
				
				if (dataType == AVATAR) {
					tempAvatarId = avatarId;
				}
				else if(dataType == NAME){
					if (currentRawProfileData != null && 
						"profile" in currentRawProfileData && 
						currentRawProfileData.profile != null &&
						"fxcomm" in currentRawProfileData.profile &&
						currentRawProfileData.profile.fxcomm != null) {
							currentRawProfileData.profile.fxcomm.firstname = firstNameNew;
							currentRawProfileData.profile.fxcomm.lastname = secondNameNew;
							updateLocalProfileData();
					}
				}
				S_PROFILE_CHANGE.invoke( { success:true, requestId:requestId } );
				phpRespond.dispose();
			}
			
			if (type == UserType.SHADOW) {
				if (firstName == null || firstName == "") {
					firstName = TextUtils.NULL;
				}
				if (secondName == null || secondName == "") {
					secondName = TextUtils.NULL;
				}
				PHP.saveProfile(avatarId, firstName, secondName, __onRespond, dataType);
			} else {
				PHP.saveProfile(avatarId, _fxFirstName, _fxLastName, __onRespond, dataType);
			}
		}
		
		/*static public function getPhases():Array {
			return phases;
		}
		
		static public function getPhaseByID(val:int):EntryPointVO {
			if (phases == null)
				return null;
			var l:int = phases.length;
			for (var i:int = 0; i < l; i++)
				if (phases[i].id == val)
					return phases[i];
			return null;
		}*/
		
		static public function addBan(channelUID:String, banData:UserBanData):void {
			bansData[channelUID] = banData;
		}
		
		static public function isBanned(chatUID:String):Boolean {
			if (!bansData)
				return false;
			if ((chatUID in bansData) && bansData[chatUID] && (bansData[chatUID] is UserBanData)) {
				var endBanTime:Date = new Date();
				endBanTime.setTime((bansData[chatUID] as UserBanData).banEndTime * 1000);
				if (endBanTime.getTime() < (new Date()).getTime()) {
					bansData[chatUID] = null;
					delete bansData[chatUID];
				}
			}
			return (chatUID in bansData);
		}
		
		static public function getBanData(chatUID:String):UserBanData {
			if (bansData && (chatUID in bansData))
				return bansData[chatUID];
			return null;
		}
		
		static public function removeBan(chatUID:String):void {
			if (bansData && (chatUID in bansData)) {
				bansData[chatUID] = null;
				delete bansData[chatUID];
			}
		}
		
		static public function setShowRating(value:Boolean, callback:Function):void {
			if (_ratingSaving == true)
				return;
			_ratingSaving = true;
			PHP.auth_showRating(onRatingSaved, value, callback);
		}
		
		static private function onRatingSaved(phpRespond:PHPRespond):void {
			_ratingSaving = false;
			if (phpRespond.error == true)
				return;
			_showRating = int(phpRespond.data);
			lastLoadedDataObject.profile.showRating = _showRating;
			updateDataInStorage();
			if ("callback" in phpRespond.additionalData == true && phpRespond.additionalData.callback != null)
				phpRespond.additionalData.callback();
			phpRespond.dispose();
		}
		
		static public function get ch_phase():String {
		//	return BankPhaze.VIDID;
			return _ch_phase; }
		static public function get eu_phase():String {
		//	return BankPhaze.VIDID;
			return _eu_phase; }
		static public function get bank_phase():String {
			return BankPhaze.ACC_APPROVED;
			if (_bank_phase == BankPhaze.SCAN)
			{
				return BankPhaze.SOLVENCY_CHECK;
			}
			return _bank_phase;
		}
		
		static public function get ch_phaseData():String{
			return _ch_phaseData;
		}
		
		static public function get bank_phaseData():String 
		{
			return _bank_phaseData;
		}
		
		static public function get ratingSaving():Boolean {
			return _ratingSaving;
		}
		
		static public function get countryISO():String {
			return _countryIso2;
		}
		
		static public function get isAuthorized():Boolean 
		{
			return _isAuthorized;
		}
		
		static public function isDialogOpened():Boolean { return dialogShowed; }
		
		static public function isVIDIDInProgress():Boolean {
			var res:Boolean = _bank_phase == "VIDID" || _bank_phase == "VIDID_READY" || _bank_phase == "VIDID_PROGRESS";
			return res;
		}
		
		static public function isRTOStarted():Boolean {
			return !(_bank_phase == "EMPTY" || _bank_phase == "UNKNOWN");
		}
		
		static public function rtoStarted():void{
			if (Auth._bank_phase == "EMPTY" || Auth._bank_phase == "UNKNOWN") {
				_bank_phase = "RTO_STARTED";
				PHP.api_yiPhase("RTO_STARTED");
				S_PHAZE_CHANGE.invoke();
			}
		}
		
		static public function isFirstInstall():Boolean{
			return _firstInstall;
		}
		
		static public function isFromSNG():Boolean {
			if (_countryCode == 380 ||
				_countryCode == 994 ||
				_countryCode == 995 ||
				_countryCode == 375 ||
				_countryCode == 996 ||
				_countryCode == 373 ||
				_countryCode == 992 ||
				_countryCode == 998 ||
				_countryCode == 374 ||
				_countryCode == 7) {
					return true;
			}
			return false;
		}

		static public function existBans():Boolean
		{
			return bansData != null && bansData.length > 0;
		}
		
		static public function getDevices():Array 
		{
			if (devices == null)
			{
				PHP.getDevices(onDevices);
			}
			return devices;
		}
		
		static public function tradingPhazeInVidid():Boolean 
		{
			if (Auth.ch_phase == BankPhaze.VIDID || Auth.ch_phase == BankPhaze.VIDID_PROGRESS || Auth.ch_phase == BankPhaze.VIDID_READY || Auth.ch_phase == BankPhaze.VI_FAIL)
			{
				return true;
			}
			if (Auth.eu_phase == BankPhaze.VIDID || Auth.eu_phase == BankPhaze.VIDID_PROGRESS || Auth.eu_phase == BankPhaze.VIDID_READY || Auth.eu_phase == BankPhaze.VI_FAIL)
			{
				return true;
			}
			return false;
		}
		
		static public function setGuestAuthData(data:Object):void 
		{
			setAuthData(data, true);
		}
		
		static public function setGuestUID(guestUID:String):void 
		{
			_uid = guestUID;
		}

		static private function onDevices(respond:PHPRespond):void
		{
			if(respond.error == true)
			{
				
			}
			else
			{
				devices = new Array();
			}
			respond.dispose();
		}
	}
}