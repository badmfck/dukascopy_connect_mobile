package com.dukascopy.connect.sys.paymentsManagerNew {
	
	import com.adobe.crypto.MD5;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.crypter.Crypter;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.payments.PayAPIManager;
	import com.dukascopy.connect.sys.payments.PayConfig;
	import com.dukascopy.connect.sys.payments.PayRespond;
	import com.dukascopy.connect.sys.payments.PayServer;
	import com.dukascopy.langs.Lang;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class PaymentsManagerNewAuth {
		
		static private var tokenEncrypted:String;
		
		static private var isInitialized:Boolean;
		
		static private var failedRequests:Array;
		
		public function PaymentsManagerNewAuth() { }
		
		static public function init():void {
			if (isInitialized == true)
				return;
			createToken();
			Auth.S_AUTHORIZED.add(createToken);
		}
		
		static private function createToken():void {
			tokenEncrypted = Crypter.crypt(Auth.key, MD5.hash("someMd5key"));
		}
		
		static public function checkForError(respond:PayRespond):Object {
			if (respond == null)
				return null;
			if (respond.error == false)
				return respond.data;
			if (respond.errorCode == PayRespond.ERROR_NOT_APPROVED_ACCOUNT ||
				respond.errorCode == PayRespond.ERROR_CODE_ACCOUNT_IS_BLOCKED ||
				respond.errorCode == PayRespond.ERROR_CODE_TOO_MANY_WRONG_PASSWORD_ENTERED) {
					return { type:"error", code:respond.errorCode };
			}
			if (respond.errorCode == PayRespond.ERROR_NEED_PASSWORD_CHANGE ||
				respond.errorCode == PayRespond.ERROR_NEED_PASSWORD ||
				respond.errorCode == PayRespond.ERROR_PASSWORD_INVALID) {
					return { type:"type", code:respond.errorCode };
			}
			if (respond.errorCode == PayRespond.ERROR_CODE_SESSION_INVALID) {
				return { type:"request", code:respond.errorCode };
			}
			return respond.errorCode;
		}
	}
}