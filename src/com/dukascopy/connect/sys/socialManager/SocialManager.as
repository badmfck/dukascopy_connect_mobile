package com.dukascopy.connect.sys.socialManager {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.CountriesData;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.store.Store;
	import com.dukascopy.langs.Lang;
	import flash.data.EncryptedLocalStore;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class SocialManager {
		
		static private const STORE_KEY:String = "socialAvaliable";
		static private const STORE_KEY_FIRST_TIME:String = "SM_FirstTime";
		static private const COUNTRIES_AVALIABLE:Array = [7, 380, 375, 996];
		
		static private var socialAvailable:Boolean = false;
		static private var initCallback:Function;
		static private var checkerState:int;
		
		static public function init(callback:Function):void {
			initCallback = callback;
			if (Config.socialAvailable == false) {
				invokeInitCallback();
				return;
			}
			socialAvailable = false;
			if (Auth.isFirstInstall() == false) {
				onKeyFTLoaded(Auth.getItem(STORE_KEY_FIRST_TIME));
				return;
			}
			checkForSocialContinue();
		}
		
		static private function onKeyFTLoaded(data:String):void {
			if (data == null) {
				Auth.setItem(STORE_KEY_FIRST_TIME, "1");
				socialAvailable = true;
				invokeInitCallback();
				return;
			}
			checkForSocial();
		}
		
		static public function invokeInitCallback():void {
			if (initCallback == null)
				return;
			initCallback();
			initCallback = null;
		}
		
		static private function checkForSocial():void {
			onKeyLoaded(Auth.getItem(STORE_KEY));
		}
		
		static private function onKeyLoaded(data:String):void {
		//	Auth.setItem(STORE_KEY_FIRST_TIME, "1");
			if (data == null) {
				checkForSocialContinue();
				return;
			}
			if (data == "1")
				socialAvailable = true;
			else
				socialAvailable = false;
			invokeInitCallback();
		}
		
		static private function checkForSocialContinue():void {
			checkForCountry();
			invokeInitCallback();
		}
		
		static private function checkForCountry():void {
			for (var i:int = 0; i < COUNTRIES_AVALIABLE.length; i++) {
				if (Auth.countryCode == COUNTRIES_AVALIABLE[i]) {
					socialAvailable = true;
					return;
				}
			}
		}
		
		static public function changeState(val:Boolean):void {
			Auth.setItem(STORE_KEY, (val == true) ? "1" : "2");
			if (val == true)
				checkerState = 1;
			else
				checkerState = 2;
			DialogManager.alert(Lang.information, Lang.restartForApply);
		}
		
		static public function getCheckerState():int {
			return checkerState;
		}
		
		static public function get available():Boolean {
			if (Config.socialAvailable == false)
				return false;
			return socialAvailable;
		}
	}
}