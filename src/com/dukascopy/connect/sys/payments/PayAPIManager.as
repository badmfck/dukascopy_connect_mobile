package com.dukascopy.connect.sys.payments {
	
	import com.adobe.crypto.MD5;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.screens.ChatScreen;
	import com.dukascopy.connect.screens.dialogs.ScanMrzPopup;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.configManager.ConfigManager;
	import com.dukascopy.connect.sys.connectionManager.NetworkManager;
	import com.dukascopy.connect.sys.crypter.Crypter;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.mrz.MrzBridge;
	import com.dukascopy.connect.sys.mrz.MrzData;
	import com.dukascopy.connect.sys.mrz.MrzError;
	import com.dukascopy.connect.sys.mrz.MrzResult;
	import com.dukascopy.connect.sys.nativeExtensionController.NativeExtensionController;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.sys.store.Store;
	import com.dukascopy.langs.Lang;
	import com.dukascopy.langs.LangManager;
	import com.greensock.TweenMax;
	import com.telefision.sys.signals.Signal;
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import com.dukascopy.connect.sys.payments.PayServer;
	
	/**
	 * Class that checking Existance of SWISS PAYMENTS account
	 * @author Alexey Skuryat
	 */
	
	public class PayAPIManager {
		
		static public const SWISS_API_NAME:String = "api_swiss";
		
		static public var S_SWISS_API_CHECKED:Signal = new Signal("PayAPIManager.S_SWISS_API_CHECKED");
		static public var S_SESSION_LOCKED:Signal = new Signal("PayAPIManager.S_SESSION_LOCKED");
		static public var S_PASS_REMIND_ERROR:Signal = new Signal("PayAPIManager.S_PASS_REMIND_ERROR");
		static public var S_PASS_REMIND:Signal = new Signal("PayAPIManager.S_PASS_REMIND");
		static public var S_LOGIN_SUCCESS:Signal = new Signal("PayAPIManager.S_LOGIN_SUCCESS");
		
		static private var _swissConfig:Object;
		static private function get swissConfig():Object {
			if (_swissConfig != null)
				return _swissConfig;
			if (Config.isTest() == false) {
				_swissConfig = {
					PAY_API_URL:"https://api.dukascopy.bank/api/",
					PAY_CLIENT_ID:"58f22998ac5ee8953f3becc533f0767e",
					PAY_CLIENT_SECRET:"e476ad0c9eb81f072f2f0e585dd24f1d",
					RTO_LINK:"https://www.dukascopy.bank/open-account/?utm_source=app.connect911",
					FAQ_URL:"https://www.dukascopy.bank/swiss/faq/",
					TERMS_URL:"https://www.dukascopy.bank/swiss/terms-conditions/"
				}
			} else {
				_swissConfig = {
					PAY_API_URL:"https://pp2.dukascopy.com/api/",
					PAY_CLIENT_ID:"8e3ec5f32846a9b961f2f49dcdb9b5b3",
					PAY_CLIENT_SECRET:"826089b2e21463cafabac82b34bc2031",
					RTO_LINK: "https://pp.dukascopy.com/payrto/",
					FAQ_URL:"https://www.dukascopy.bank/swiss/faq/",
					TERMS_URL:"https://www.dukascopy.bank/swiss/terms-conditions/"
				}
			}
			return _swissConfig;
		}
		
		static private var firstTime:Boolean = true;
		static private var _allowTimeDiffCall:Boolean = false;
		static private var _configSeted:Boolean = false;
		static private var _isSwissApiInCheckingProcess:Boolean = false;
		static private var _isSwissApiChecked:Boolean = false;
		static private var _hasSwissAccount:Boolean = false;
		static private var _hasSwissTime:Boolean = false;
		static private var swissTimestampCallIDLast:String = "";
		static private var swissTimestampCallDate:Date;
		static private var swissTimestampCallSeconds:Number = 0;
		
		public function PayAPIManager() {}
		
		static public function init():void {
			setConfigParams();
			
			ConfigManager.S_CONFIG_READY.add(onConfig);
			Auth.S_NEED_AUTHORIZATION.add(onLogoutFromApplication);
			
			NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, onActivate);
		}

		static private function onActivate(e:Event):void {
            if (Config.PLATFORM_WINDOWS)
				return;
			if (_allowTimeDiffCall == true)
				checkForTimeDifference(null);
		}
		
		static private function onConfig():void {
			setupConfigs(ConfigManager.rawConfig);
			
			lockSessionIfExist(false);
		}
		
		static private function setupConfigs(loadedConfigData:Object):void {
			if (_configSeted == true)
				return;
			_configSeted = true;
			if (loadedConfigData == null)
				return;
			if ("PAY_RTO_URL" in loadedConfigData == true &&
				loadedConfigData.PAY_RTO_URL != null &&
				loadedConfigData.PAY_RTO_URL != "")
					swissConfig.RTO_LINK = loadedConfigData.PAY_RTO_URL;
			if ("PAY_CLIENT_ID" in loadedConfigData == true &&
				loadedConfigData.PAY_CLIENT_ID != null &&
				loadedConfigData.PAY_CLIENT_ID != "")
					swissConfig.PAY_CLIENT_ID = loadedConfigData.PAY_CLIENT_ID;
			if ("PAY_CLIENT_SECRET" in loadedConfigData == true &&
				loadedConfigData.PAY_CLIENT_SECRET != null &&
				loadedConfigData.PAY_CLIENT_SECRET != "")
					swissConfig.PAY_CLIENT_SECRET = loadedConfigData.PAY_CLIENT_SECRET;
			if ("PAY_API_URL" in loadedConfigData == true &&
				loadedConfigData.PAY_API_URL != null &&
				loadedConfigData.PAY_API_URL != "")
					swissConfig.PAY_API_URL = loadedConfigData.PAY_API_URL;
			if ("PAY_TERMS" in loadedConfigData == true &&
				loadedConfigData.PAY_TERMS != null &&
				loadedConfigData.PAY_TERMS != "")
					swissConfig.TERMS_URL = loadedConfigData.PAY_TERMS;
			if ("PAY_FAQ" in loadedConfigData == true &&
				loadedConfigData.PAY_FAQ != null &&
				loadedConfigData.PAY_FAQ != "")
					swissConfig.FAQ_URL = loadedConfigData.PAY_FAQ;
			setConfigParams();
		}
		
		static private function setConfigParams():void {
			PayConfig.PAY_API_URL = swissConfig.PAY_API_URL;
			PayConfig.PAY_CLIENT_ID = swissConfig.PAY_CLIENT_ID;
			PayConfig.PAY_CLIENT_SECRET = swissConfig.PAY_CLIENT_SECRET;
			PayConfig.RTO_LINK = swissConfig.RTO_LINK;
			PayConfig.TERMS_URL = swissConfig.TERMS_URL;
			PayConfig.FAQ_URL = swissConfig.FAQ_URL;
		}
		
		static private function onLogoutFromApplication():void {
			firstTime = true;
			_allowTimeDiffCall = false;
			_configSeted = false;
			swissTimestampCallIDLast = "";
			_hasSwissTime = false;
			_isSwissApiInCheckingProcess = false;
			_isSwissApiChecked = false;
			PayConfig.PAY_SESSION_ID = "";
			PayConfig.TIMESTAMP_DIFF = 0;
			Config.ENABLE_INVESTMENTS = false;
		}
		
		static private function lockSessionIfExist(obligatory:Boolean = true):void {
			if (firstTime == false && obligatory == false)
				return;
			firstTime = false;
			if (_hasSwissTime == false) {
				checkForTimeDifference(lockSessionIfExist);
				return;
			}
			Store.load("swissSession", onSwissSession);
		}
		
		static private function onSwissSession(data:Object, err:Boolean):void {
			if (err == true || data == null || data == "") {
				echo("PayAPIManager", "onSwissSession", "No session in STORE");
				return;
			}
			PayConfig.PAY_SESSION_ID = data as String;
			lockSession();
		}
		
		static public function lockSession():void {
			PayServer.call_lock(onSessionLock);
		}
		
		static private function onSessionLock(respond:PayRespond):void {
			if (respond.error == true && respond.errorCode == 2000) {
				Store.remove("swissSession");
				PayConfig.PAY_SESSION_ID = "";
				onSwissSession(null, true);
				respond.dispose();
				return;
			}
			_hasSwissAccount = true;
			onSwissAPICheckComplete();
			respond.dispose();
			S_SESSION_LOCKED.invoke();
		}
		
		static private function checkForTimeDifference(callback:Function, callback1:Function = null):void {
			_hasSwissTime = false;
			swissTimestampCallDate = new Date();
			swissTimestampCallSeconds = Math.floor(swissTimestampCallDate.time / 1000);
			swissTimestampCallIDLast = swissTimestampCallDate.time + "";
			PayServer.call_getServerTime(onSwissServerTimeRespond, swissTimestampCallIDLast, callback, callback1);
		}
		
		static private function onSwissServerTimeRespond(respond:PayRespond):void {
			if (respond.savedRequestData.callID != swissTimestampCallIDLast) {
				respond.dispose();
				return;
			}
			if (respond.error == false && respond.data != null) {
				_allowTimeDiffCall = true;
				_hasSwissTime = true;
				PayConfig.TIMESTAMP_DIFF = int(Number(respond.data) - swissTimestampCallSeconds);
				if ("callbackFunction" in respond.savedRequestData &&
					respond.savedRequestData.callbackFunction != null) {
						if ("callbackFunction1" in respond.savedRequestData == true &&
							respond.savedRequestData.callbackFunction1 != null)
								respond.savedRequestData.callbackFunction(respond.savedRequestData.callbackFunction1);
						else
							respond.savedRequestData.callbackFunction();
					}
			}
			respond.dispose();
			echo("PayAPIManager", "onSwissServerTimeRespond", "SWISS TIME DELTA: " + PayConfig.TIMESTAMP_DIFF);
		}
		
		static public function login(callback:Function = null, obligatory:Boolean = false):void {
			if (obligatory == false && PayConfig.PAY_SESSION_ID != "")
				return;
			if (_hasSwissTime == false) {
				checkForTimeDifference(login, callback);
				return;
			}
			if (MobileGui.touchIDManager != null) {
				MobileGui.touchIDManager.callbackFunction = function(val:int, secret:String = ""):void {
					if (val == 0) {
						showPassDialog(callback)
						return;
					}
					onPassDialogClosed(val, secret, {callback:callback});
				};
				if (MobileGui.touchIDManager.getSecretFrom() == false) {
					showPassDialog(callback);
					MobileGui.touchIDManager.callbackFunction = null;
				}
				return;
			}
			showPassDialog(callback);
		}
		
		static public function showPassDialog(callback:Function):void {
			DialogManager.showPayPass(onPassDialogClosed, { callback:callback } );
		}
		
		static private function onPassDialogClosed(val:int, pass:String, data:Object):void {
			if (val == 1) {
				var tokenEncrypted:String = Crypter.crypt(Auth.key, MD5.hash("someMd5key"));
				PayServer.call_loginWithToken(
					onLoginSwissResponse,
					tokenEncrypted,
					pass,
					(data != null && "callback" in data  == true && data.callback != null) ? data.callback : null
				);
				return;
			}
			if (data != null && "callback" in data  == true && data.callback != null) {
				TweenMax.delayedCall(
					.3,
					function():void {
						if (data.callback.length == 1 && val == 0)
						{
							// true == rejected bu user;
							data.callback(true);
						}
						else
						{
							data.callback();
						}
					}
				);
			}
		}
		
		static public function remindPassword(email:String, code:String = null, token:String = null):void {
			var data:Object = {
				email: email,
				phone: "+" + Auth.phone.toString()
			}
			if (code != null) {
				data.code = code;
				data.token = token;
			}
			PayServer.call_postForgot(passForgotReminded, data);
		}
		
		static private function passForgotReminded(respond:PayRespond):void {
			if (respond.error == true) {
				S_PASS_REMIND_ERROR.invoke(respond.errorCode);
				return;
			}
			S_PASS_REMIND.invoke(respond.data);
		}
		
		static private function onLoginSwissResponse(respond:PayRespond):void {
			echo("PayAPIManager", "onLoginSwissResponse", "SWISS API CHECKED");
			if (respond.error == true) {
				if (respond.data != null)
					echo("PayAPIManager", "onLoginSwissResponse", "ERROR: Code - " + respond.data.code + "; Msg - " + respond.data.error);
				else
					echo("PayAPIManager", "onSwissAPICheckError", "REASON: " + respond.errorCode);
				if (respond.errorCode == PayRespond.ERROR_PASSWORD_INVALID) {
					ToastMessage.display(Lang.wrongPassword);
					if (NativeExtensionController.payPassByFingerprint == true) {
						NativeExtensionController.payPassByFingerprint = false;
						NativeExtensionController.clearFingerprint();
					}
					login(respond.savedRequestData.callbackFunction);
					respond.dispose();
					return;
				}
				if (respond.errorCode == PayRespond.ERROR_VERIFICATION_BLOCKED) {
					ToastMessage.display(Lang.passwordVerificationLocked);
				} else if (respond.errorCode == PayRespond.ERROR_NOT_APPROVED_ACCOUNT)
				{
					
				} else if (respond.errorCode == -1) {
					
				} else if(respond.errorCode != 1999) {
					ToastMessage.display(Lang.somethingWentWrong);
				}
				onSwissAPICheckComplete();
				if (respond.savedRequestData != null &&
					"callbackFunction" in respond.savedRequestData &&
					respond.savedRequestData.callbackFunction != null)
					{
						if ((respond.savedRequestData.callbackFunction as Function).length == 1)
						{
							respond.savedRequestData.callbackFunction(respond.errorCode);
						}
						else
						{
							respond.savedRequestData.callbackFunction();
						}
					}
				respond.dispose();
				return;
			}
			_hasSwissAccount = true;
			var sid:String = encodeURIComponent(respond.data.session_id);
			Store.save("swissSession", sid);
			PayConfig.PAY_SESSION_ID = sid;
			onSwissAPICheckComplete();
			S_LOGIN_SUCCESS.invoke(respond.savedRequestData);
			if (respond.savedRequestData.data != null && respond.savedRequestData.data.password != null) {
				if (MobileGui.touchIDManager != null) {
					MobileGui.touchIDManager.changePassTouchID(respond.savedRequestData.data.password);
					MobileGui.touchIDManager.saveTouchID(respond.savedRequestData.data.password);
				}
			}
			if ("callbackFunction" in respond.savedRequestData && respond.savedRequestData.callbackFunction != null)
				respond.savedRequestData.callbackFunction();
			respond.dispose();
		}
		
		private static function onSwissAPICheckComplete():void {
			echo("PayAPIManager", "onSwissAPICheckComplete");
			_isSwissApiInCheckingProcess = false;
			_isSwissApiChecked = true;
			S_SWISS_API_CHECKED.invoke();
		}
		
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  API GETTERS AND SETTERS  -->  ////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		static public function get hasSwissAccount():Boolean { return Auth.bank_phase == "ACC_APPROVED"; }
		static public function get configSeted():Boolean { return _configSeted; }
		
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  RTO  -->  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		static public function openSwissRTO(promoCode:String = null):void {
			if (NetworkManager.isConnected == false) {
				DialogManager.alert(Lang.information, Lang.noInternetConnection);
				return;
			}
			PHP.call_statVI("tryRTO");
			/*if (Auth.phone % 2 != 0) {
				processOpenSwissRTO(promoCode);
				PHP.call_statVI("mrzIgnored");
				return;
			}*/
			
			if (Config.PLATFORM_ANDROID == true && NativeExtensionController.getVersion() > 22) {
				MrzBridge.startRecognition(onMrzScannedAndroid, promoCode);
			}
			else
			{
				MrzBridge.startRecognition(onMrzScanned, promoCode);
			}
		//	MrzBridge.startRecognition(onMrzScanned, promoCode);
		}
		
		static private function onMrzScannedAndroid(result:MrzResult):void {
			
			if (result.error == true && result.errorText == MrzError.ENGINE_INIT_FAILED)
			{
				ToastMessage.display(result.getErrorLocalized());
				PHP.call_statVI("tryRTOErr", "mrz engine fail, " + ((result.errorText != null)?result.errorText:""));
				// fallback to server recognition;
				MrzBridge.startRecognition(onMrzScanned, result.promoCode, true);
			}
			else
			{
				onMrzScanned(result);
			}
		}
		
		static private function onMrzScanned(result:MrzResult):void {
			if (result.error == false) {
				processOpenSwissRTO(result.promoCode, result.data);
			}
			else {
				ToastMessage.display(result.getErrorLocalized());
				PHP.call_statVI("tryRTOErr", "no mrz scanned, " + ((result.errorText != null) ? result.errorText : ""));
			}
		}
		
		static private function processOpenSwissRTO(promoCode:String, mrzData:MrzData = null):void {
			var mrzLink:String = "";
			var birthDate:String = "";
			var mrzHash:String;
			if (mrzData != null) {
				birthDate = mrzData.dateOfBirth;
				mrzLink = "first_name=" + mrzData.firstName + "&" +
						  "last_name=" + mrzData.lastName + "&" +
						  "birth_date=" + mrzData.dateOfBirth + "&" +
						  "gender=" + mrzData.gender + "&" +
						  "nationality=" + mrzData.nationality;
				mrzHash = MD5.hash(mrzLink);
				PHP.call_setMRZDataByPhone(MD5.hash(mrzData.mrzLines));
				ChatScreen.scannPassTime = new Date().getTime() + (1000 * 60 * 15);
				PHP.call_statVI("MRZ_SUCCESS", MD5.hash(JSON.stringify(mrzData.keys)));
			} else {
				PHP.call_statVI("mrzNull", "MRZ scanned but is null");
			}


			var notaryflow:Boolean = false;
			var coolPhone:Boolean = !Config.PLATFORM_ANDROID;
			if (Config.PLATFORM_ANDROID){
				var ver:int = NativeExtensionController.getVersion();
				coolPhone = ver >= Config.MIN_ANDROID_SDK;
			}
			var curDate:Date = new Date();
			var tmp:Array = birthDate.split(/\D/);
			if (tmp.length == 3) {
				var mrzY:int = parseInt(tmp[2]);
				var mrzM:int = parseInt(tmp[1]);
				var mrzD:int = parseInt(tmp[0]);
				var yearsPassed:int = curDate.getFullYear() - mrzY;
				if (yearsPassed < Config.MAX_OPEN_ACC_AGE) {
					notaryflow = true;
				} else if (yearsPassed == Config.MAX_OPEN_ACC_AGE) {
					if (mrzM > curDate.getMonth() + 1)
						notaryflow = true;
					if (mrzM == curDate.getMonth() + 1 && mrzD > curDate.getDate())
						notaryflow = true;
				}
				var cc:int = Auth.countryCode;
				var countryMinAge:int=0;
				for (var i:int = 0; i < Config.FT_COUNTRIES_AGES.length; i++) {
					if (cc == Config.FT_COUNTRIES_AGES[i].code) {
						countryMinAge = Config.FT_COUNTRIES_AGES[i].age;
						if (cc == 7 && Auth.phone.toString().indexOf("77") == 0)
							countryMinAge = 99;
                        if (yearsPassed < countryMinAge)
                            notaryflow = true;
                        break;
                    }
				}
				// SHIT PHONE
				if (Config.MIN_ANDROID_SDK > 0 && coolPhone == false && notaryflow == false && countryMinAge > 18 && countryMinAge < 90) {
					notaryflow = true;
				}
			}
			if (Auth.phone == 3807676868325) {
				notaryflow = true;
				coolPhone = true;
				promoCode = "6MZUW7";
				birthDate = "XXX";
			}
			PHP.call_stsGet(
				function(r:PHPRespond):void {
					var token:String = "";
					if (r.error == false && r.data != null) {
						if ("token" in r.data)
							token = r.data.token;
						if (token == null)
							token = "";
					}
					var link:String = swissConfig.RTO_LINK;
					if (link.indexOf("?") == -1)
						link += "?";
					link += "lang=" + LangManager.model.getCurrentLanguageID() + "&token=" + token;
					if (mrzLink == null || mrzLink.length == 0)
						mrzLink = "mrz_fail=1";
					link += "&" + mrzLink;
					PHP.call_statVI("openRTO","ft:"+notaryflow+", bd: "+(birthDate!=null)?birthDate:"unknown");
					navigateToURL(new URLRequest(link));
				},
				promoCode,
				notaryflow,
				coolPhone,
				birthDate,
				mrzData.docNumber,
				mrzData.docType,
				mrzData.dateExpired,
				mrzData.nationality,
				mrzData.country

			);
			Auth.rtoStarted();
		}
	}
}