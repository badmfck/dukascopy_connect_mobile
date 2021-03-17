package com.dukascopy.connect.sys.crypter{
	
	import com.telefision.utils.Loop;
	import flash.utils.ByteArray;
	
	/**
	 * @author Igor Bloom
	 */
	
	public class ImageCrypter{
		
		public function ImageCrypter(){
			
		}
		
		public static function decrypt(file:ByteArray, key:String, callback:Function):void{
			file.position = 0;
			var ver:int = file.readByte();
			if(ver!=1){
				trace('unsupported algorythm!');
				callback(file);
				return;
			}
			
			var ba:ByteArray = new ByteArray();
			var perFrame:int = 5000;
			var m:int = 0;
			var n:int = 0;
			
			var __onLoop:Function = function():void{
				n = 0;
				for (n; n < perFrame;n++){
					if (file.bytesAvailable == 0){
						Loop.remove(__onLoop);
						callback(ba);
						return;
					}
					
					var payload:int = key.charCodeAt(m);
					m++;
					if (m == key.length)
						m = 0;
					var byte:uint = file.readUnsignedByte();
					ba.writeByte(byte - payload);
				}
			}
			
			Loop.add(__onLoop);
		}
		
		
		public static function encrypt(file:ByteArray, key:String, callback:Function):void{
			file.position = 0;
			var ba:ByteArray = new ByteArray();
			ba.writeByte(1); // algorythm version
			var perFrame:int = 5000;
			var m:int = 0;
			var n:int = 0;
			
			var __onLoop:Function = function():void{
				n = 0;
				for (n; n < perFrame;n++){
					if (file.bytesAvailable == 0){
						Loop.remove(__onLoop);
						callback(ba);
						return;
					}
					
					var payload:int = key.charCodeAt(m);
					m++;
					if (m == key.length)
						m = 0;
					var byte:uint = file.readUnsignedByte();
					ba.writeByte(byte + payload);
				}
			}
			
			Loop.add(__onLoop);
		}
	}
}