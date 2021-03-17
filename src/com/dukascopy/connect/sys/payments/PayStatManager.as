package com.dukascopy.connect.sys.payments {
	
	import com.dukascopy.connect.sys.configManager.ConfigManager;
	import com.dukascopy.connect.sys.crypter.Crypter;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class PayStatManager {
		
		static private var uidsByPhone:Object = {};
		static private var deferredRequests:Object = {};
		
		static private var inProcess:Array = [];
		static private var waitingForResponse:Object;
		
		static private var busy:Boolean = false;
		
		static public function sendStat(data:Object):void {
			if (data.to_type == "tfuid") {
				inProcess.push(data);
				processStat();
				return;
			}
			if (data.to_type == "phone") {
				if (data.to in uidsByPhone) {
					inProcess.push(data);
					processStat();
				}
				var cryptedPhone:String = Crypter.getBaseNumber(data.to);
				if (cryptedPhone in deferredRequests == false) {
					deferredRequests[cryptedPhone] = [];
					getUidByPhone(data);
				}
				deferredRequests[cryptedPhone].push(data);
			}
		}
		
		static private function getUidByPhone(data:Object):void {
			PHP.getUserByPhone(Crypter.getBaseNumber(data.to), onUserLoaded);
		}
		
		static private function onUserLoaded(phpRespond:PHPRespond):void {
			if (phpRespond.error == false)
				if (phpRespond.data != null)
					uidsByPhone[phpRespond.additionalData.phone] = phpRespond.data.uid;
				else
					uidsByPhone[phpRespond.additionalData.phone] = null;
			var l:int = deferredRequests[phpRespond.additionalData.phone].length;
			for (var i:int = 0; i < l; i++)
				inProcess.push(deferredRequests[phpRespond.additionalData.phone][i]);
			processStat();
			delete deferredRequests[phpRespond.additionalData.phone];
		}
		
		static private function processStat():void {
			if (busy == true)
				return;
			if (inProcess.length == 0)
				return;
			busy = true;
			waitingForResponse = inProcess.shift();
			if (checkForCurrencyLimit(waitingForResponse.currency, waitingForResponse.amount) == false) {
				waitingForResponse = null;
				processStat();
				return;
			}
			var method:String = waitingForResponse.currency + "_Pay";
			var to:String;
			if (waitingForResponse.to_type == "tfuid")
				to = waitingForResponse.to;
			else if (waitingForResponse.to_type == "phone") {
				if (uidsByPhone[Crypter.getBaseNumber(waitingForResponse.to)] == null)
					to = "#" + Crypter.crypt(waitingForResponse.to, "ZhpvMDK");
				else
					to = uidsByPhone[Crypter.getBaseNumber(waitingForResponse.to)];
			}
			PHP.call_statVI(method, to, onStatResponse);
		}
		
		static private function checkForCurrencyLimit(currency:String, amount:Number):Boolean {
			if (ConfigManager.config.payStatLimits == null)
				return false;
			var l:int = ConfigManager.config.payStatLimits.length;
			for (var i:int = 0; i < l; i++) {
				if (ConfigManager.config.payStatLimits[i].currency != currency)
					continue;
				if (amount >= ConfigManager.config.payStatLimits[i].min &&
					amount <= ConfigManager.config.payStatLimits[i].max)
						return true;
				return false;
			}
			return false;
		}
		
		static private function onStatResponse(phpRespond:PHPRespond):void {
			busy = false;
			var data:Object = JSON.parse(phpRespond.data as String);
			if (data.status.error == true)
				inProcess.unshift(waitingForResponse);
			waitingForResponse = null;
			processStat();
		}
	}
}