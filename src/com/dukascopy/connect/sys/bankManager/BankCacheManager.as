package com.dukascopy.connect.sys.bankManager {
	
	import com.dukascopy.connect.GD;
	import com.dukascopy.connect.utils.Services;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class BankCacheManager {
		
		private static var cacheTS:int = -1;
		
		private static var cacheAccountInfo:Object; // { ts:Number, data:String }
		
		public function BankCacheManager() { }
		
		public static function init():void {
			GD.S_BANK_CACHE_ACCOUNT_INFO_REQUEST.add(getAccountInfoCache, "BankCacheManager");
			GD.S_BANK_CACHE_ACCOUNT_INFO_SAVE.add(setAccountInfoCache, "BankCacheManager");
			
			onConfigUpdated();
		}
		
		private static function onConfigUpdated():void {
			GD.S_BANK_CACHE_CONFIG_REQUEST.invoke(setConfig);
		}
		
		private static function setConfig(val:int):void {
			traceDebugInfo("setConfig", "val: " + val);
			cacheTS = val * 60 * 1000;
		}
		
		private static function setAccountInfoCache(dataString:String):void {
			traceDebugInfo("setAccountInfoCache", "Cache save");
			if (cacheAccountInfo == null) {
				traceDebugInfo("setAccountInfoCache", "Cache write");
				cacheAccountInfo = {
					ts: new Date().getTime(),
					data: dataString
				}
			} else {
				traceDebugInfo("setAccountInfoCache", "Cache rewrite");
				cacheAccountInfo.ts = new Date().getTime();
				cacheAccountInfo.data = dataString;
			}
			var cacheString:String;
			try {
				cacheString = JSON.stringify(cacheAccountInfo);
			} catch (err:Error) {
				traceDebugInfo("setAccountInfoCache", "JSON Error (" + err.errorID + "): " + err.message);
			}
			if (cacheString == null) {
				traceDebugInfo("setAccountInfoCache", "Cache string is null");
				return;
			}
			Services.ELS.save("bankAccountInfo", cacheString);
		}
		
		private static function getAccountInfoCache(callback:Function = null):void {
			if (cacheTS == -1) {
				traceDebugInfo("getAccountInfoCache", "cacheTS is -1");
				callback(null, true);
				return;
			}
			if (cacheAccountInfo != null) {
				var currentTS:int = new Date().getTime();
				if (cacheAccountInfo.ts + cacheTS > currentTS) {
					traceDebugInfo("getAccountInfoCache", "Cache exists");
					callback(cacheAccountInfo.data, true);
					return;
				}
				traceDebugInfo("getAccountInfoCache", "Cache expired");
				if (cacheAccountInfo.data != null) {
					traceDebugInfo("getAccountInfoCache", "Cache need to remove");
					cacheAccountInfo.data = null;
					Services.ELS.remove("bankAccountInfo");
				}
				traceDebugInfo("getAccountInfoCache", "Cache removed");
				callback(null, true);
				return;
			}
			traceDebugInfo("getAccountInfoCache", "Cache load from ELS");
			var cacheString:String = Services.ELS.load("bankAccountInfo");
			if (cacheString == null) {
				traceDebugInfo("getAccountInfoCache", "Cache from ELS not exists");
				callback(null, true);
				return;
			}
			traceDebugInfo("getAccountInfoCache", "Cache from ELS exists");
			try {
				cacheAccountInfo = JSON.parse(cacheString);
			} catch (err:Error) {
				traceDebugInfo("getAccountInfoCache", "JSON Error (" + err.errorID + "): " + err.message);
			}
			if (cacheAccountInfo == null) {
				traceDebugInfo("getAccountInfoCache", "Cache error");
				callback(null, true);
				return;
			}
			getAccountInfoCache(callback);
		}
		
		private static function traceDebugInfo(method:String, info:String):void {
			//trace("BankCacheManager :: " + method + " :: " + info);
		}
	}
}