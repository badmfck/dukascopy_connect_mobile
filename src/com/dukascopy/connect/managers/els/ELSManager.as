package com.dukascopy.connect.managers.els {
	
	import flash.data.EncryptedLocalStore;
	import flash.utils.ByteArray;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class ELSManager implements IELSManager {
		
		public function load(name:String):String {
			if (EncryptedLocalStore.isSupported == false)
				return null;
			var ba:ByteArray = null;
			try {
				ba = EncryptedLocalStore.getItem(name);
			} catch(err:Error) {
				trace("BankCacheManager -> getItem -> ELS Error (" + err.errorID + "): " + err.message);
			}
			if (ba == null || ba.length == 0 || ba.bytesAvailable == 0)
				return null;
			try {
				ba.uncompress();
			} catch (err:Error) {
				trace("BankCacheManager -> getItem -> ByteArray Uncompress Error (" + err.errorID + "): " + err.message, true);
				return null;
			}
			ba.position = 0;
			var str:String = ba.readUTFBytes(ba.length);
			ba.clear();
			ba = null;
			return str;
		}
		
		public function remove(name:String):void {
			if (EncryptedLocalStore.isSupported == false)
				return;
			try {
				EncryptedLocalStore.removeItem(name);
			} catch(err:Error) {
				trace("BankCacheManager -> removeItem -> ELS Error (" + err.errorID + "): " + err.message);
			}
		}
		
		public function save(name:String, value:String):void {
			if (EncryptedLocalStore.isSupported == false)
				return;
			if (value == null)
				value = "";
			var ba:ByteArray = new ByteArray();
			ba.writeUTFBytes(value);
			try {
				ba.compress();
			} catch (err:Error) {
				trace("BankCacheManager -> setItem -> ByteArray Compress Error (" + err.errorID + "): " + err.message, true);
				return;
			}
			try {
				EncryptedLocalStore.setItem(name, ba);
			} catch(err:Error) {
				trace("BankCacheManager -> setItem -> ELS Error (" + err.errorID + "): " + err.message);
			}
			ba.clear();
		}
	}
}