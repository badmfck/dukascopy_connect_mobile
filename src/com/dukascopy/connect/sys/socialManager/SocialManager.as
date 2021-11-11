package com.dukascopy.connect.sys.socialManager {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.CountriesData;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.store.Store;
	import com.dukascopy.connect.type.BankPhaze;
	import com.dukascopy.langs.Lang;
	import flash.data.EncryptedLocalStore;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class SocialManager {
		
		static public function init(callback:Function):void {
			callback();
		}
		
		static public function get available():Boolean {
			if (Config.socialAvailable == false)
				return false;
			return Auth.bank_phase == BankPhaze.ACC_APPROVED;
		}
	}
}