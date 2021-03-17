package com.dukascopy.connect.sys.ws{
	import flash.utils.ByteArray;
	
	/**
	 * ...
	 * @author Igor Bloom. Telefision TEAM Riga.
	 */
	
	public class WSNewClient {
		
		static public function authorize(key:String):void {
			send(1, key);
		}
		
		static public function ticketAdd(pageID:int, name:String = "Ilya", mail:String = "ilja.sherbakovs@dukascopy.com"):void {
			send(20, pageID, name, mail);
		}
		
		static private function send(...rest):Boolean {
			if (rest == null || rest.length == 0 || rest[0] is int != true)
				return false;
			var res:ByteArray = new ByteArray();
			var temp:ByteArray;
			res.writeInt(rest[0]);
			for (var i:int = 1; i < rest.length; i++) {
				if (rest[i] is int) {
					res.writeInt(rest[0]);
					continue;
				}
				if (rest[i] is String) {
					temp ||= new ByteArray();
					temp.writeUTFBytes(rest[i]);
					res.writeInt(temp.length);
					res.writeBytes(temp);
					temp.clear();
				}
			}
			return WSNew.send(res);
		}
	}
}