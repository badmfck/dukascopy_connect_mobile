package com.dukascopy.connect.sys.crypter {
	import com.adobe.crypto.SHA256;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.greensock.motionPaths.RectanglePath2D;
	import com.hurlant.crypto.Crypto;
	import com.hurlant.crypto.symmetric.AESKey;
	import com.hurlant.crypto.symmetric.ICipher;
	import com.hurlant.crypto.symmetric.IPad;
	import com.hurlant.crypto.symmetric.IVMode;
	import com.hurlant.crypto.symmetric.NullPad;
	import com.hurlant.util.Base64;
	import com.hurlant.util.Hex;
	import com.telefision.utils.Loop;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	import flash.utils.ByteArray;
	import gibberishAES.AESCrypter;
	
	/**
	 * ...
	 * @author Igor bloom
	 */
	public class Crypter {

	
	private static var base:String = 'qIWDHpg9FCzUAQNJ8XfML0yORZeY5B4PT7anmkjGE1bv6dxoh3lrS2tVwiscKu';
	
	
	static public function parseImageKey(securityKey:String):Array{
		if (securityKey == null){
			echo("Crypter","parseImageKey",'Security key null!',true);
			return null;
		}
			
		if (securityKey.length % 3 != 0) {
			echo("Crypter","parseImageKey",'Security key damaged!',true);
			return null;
		}
		
		var tiles:Array= [];
		var n:int = 0;
		var l:int = securityKey.length;
		for (n; n < l; n += 3) {
			var num:String = securityKey.substr(n, 3).replace(/\./g, '');
			tiles.push(Crypter.getNumberByBase(num));
		}
		return tiles;
	}
	
	static public function decryptImage(bmd:ImageBitmapData, key:Array):ImageBitmapData {
		var res:ImageBitmapData = new ImageBitmapData('uncrypted image', bmd.width, bmd.height, true, 0xFF1100FF);
		// DECRYPT
		var tilesRow:int =  Math.floor(Math.sqrt(key.length));
		var tileW:int =  Math.floor(bmd.width / tilesRow);
		var tileH:int =  Math.floor(bmd.height / tilesRow);
		var inRow:int =  Math.floor(bmd.width / tileW);
	
		var z:int = key.length;
		var n:int = 0;
		
		var srcPT:Point = new Point();
		var rect:Rectangle = new Rectangle(0, 0, tileW, tileH);
		
		while (n < z) {
			
			// Позиция для рисования
			srcPT.x = int(n % inRow) * tileW;
			srcPT.y =  int(n / inRow) * tileH;
			
			
			// позиция элемента в зашифрованной картинке
			rect.x =  int(key[n] % inRow) * tileW;
			rect.y =  int(key[n] / inRow) * tileH;

			res.copyPixels(bmd, rect, srcPT);
			n++;
		}
		
		srcPT.x = 0;
		srcPT.y = 0;
		srcPT = null;
		rect.x = 0;
		rect.y = 0;
		rect.width = 0;
		rect.height = 0;
		rect = null;

		return res;
	}
	
	
	static public function cryptImage(img:ImageBitmapData, key:Array,callBack:Function,progressCallback:Function=null):void{
		
		
		
		if (key == null) {
			echo("Crypter","cryptImage",'no key!',true);
			return;
		}
			
		if (img == null) {
			echo("Crypter","cryptImage",'no image!',true);
			return;
		}
			
	
		
		
		var tilesRow:int = Math.floor(Math.sqrt(key.length));
		var tw:int = Math.floor(img.width / tilesRow) * tilesRow;
		var th:int = Math.floor(img.height / tilesRow) * tilesRow;
		
		var src:ImageBitmapData = ImageManager.resize(img, tw, th, ImageManager.SCALE_PORPORTIONAL, true);
		
		var tileW:int = Math.floor(src.width / tilesRow);
		var tileH:int = Math.floor(src.height / tilesRow);
		var inRow:int = Math.floor(src.width / tileW);
		
		var res:ImageBitmapData = new ImageBitmapData(src.name+'.crypted', tw, th, true);
		
		
		var len:int = key.length;
		var perFrame:int = 500;
		var z:int = perFrame;
		var n:int = 0;
		var py:int = 0;
		var px:int = 0;
		var srcY:int = 0;
		var srcX:int = 0;
		var rect:Rectangle = new Rectangle(0,0,tileW,tileH);
		var pt:Point = new Point();
		
		
		
		var __crypt:Function=function():void{
				
			if (n == len) {
				src.dispose();
				img.dispose();
				Loop.remove(__crypt);
				callBack(res);
				return;
			}
			
			if (z > len)
				z = len;
			
			while (n < z) {
				
				rect.x =  Math.floor((n % inRow) * tileW);
				rect.y =  Math.floor(n / inRow) * tileH;
				pt.x =  Math.floor((key[n] % inRow) * tileW);
				pt.y = Math.floor(key[n] / inRow) * tileH;
				res.copyPixels(src, rect, pt);
				n++;
			}
			
			z += perFrame;
		}
		
		Loop.add(__crypt);
	}
	
	static public function getBaseNumber(sourceNumber:Number):String {
		if (isNaN(sourceNumber))
			return'';
		var r:int = sourceNumber % 62;
		var result:String='';
		if (sourceNumber-r == 0)
			result = base.charAt(r);
				else
					result = getBaseNumber((sourceNumber-r)/62 )+''+base.charAt(r);
		return result;
	}
	

	/**
	* @params str - String to crypt
	* @return crypted string
	*/
	static public function decrypt(str:String, key:String):String {
		if (key == null || key.length==0)
			return str;
		var keyLen:int = key.length;
		var strLen:int = str.length;
		if (strLen % 2 != 0)
			return str;
		var m:int = 0;
		var n:int = 0;
		var decoded:String = "";
		var i:String;
		var mStep:int;
		var code:int;
		while (m < strLen) {
			mStep = 2;
			if (str.charAt(m) == '-') {
				i = str.charAt(m + 1) + '' + str.charAt(m + 2) + '' + str.charAt(m + 3);
				mStep = 4;
			} else {
				i = str.charAt(m) + '' + str.charAt(m + 1);
				if (str.charAt(m) == '.')
					i = str.charAt(m + 1);
			}
			code = getNumberByBase(i) - key.charCodeAt(n);
			decoded += String.fromCharCode(code);
			n++;
			if (n == keyLen)
				n = 0;
			m += mStep;
		}
		return decoded;
	}
	
	static public function decryptAsync(str:String, key:String,callBack:Function):void {
		
		var keyLen:int = key.length;
		var strLen:int = str.length;
		
		if(strLen % 2!=0){
			callBack(str);
			return;
		}

		var m:int = 0;
		var n:int = 0;
		var perFrame:int = 50;
		var start:int=0;
		var decoded:String = "";
		
		var __decode:Function = function():void{
			if (start >= strLen) {
				Loop.remove(__decode);
				callBack(decoded);
				return;
			}
			
			var len:int = perFrame;
			if ( (start + perFrame) > strLen)
				len = strLen-start;
			
			for (n = start; n < len; n+=2){
				var i:String=str.charAt(n)+''+str.charAt(n+1);
				if(str.charAt(n)=='.')
					i=str.charAt(n+1);
				var code:int=getNumberByBase(i);
				code-=key.charCodeAt(m);
				decoded+=String.fromCharCode(code);
				m++;
				if(m==keyLen)
					m=0;
			}
			
			start += len;
		}
		Loop.add(__decode);
	}
	
	static public function cryptAsync(str:String, key:String, callBack:Function):void {
		if (key == null || key.length == 0){
			if(callBack!=null)
				callBack(str);
			return;
		}
		
		if (str == null){
			if(callBack!=null)
				callBack("");
			return;
		}
			
        // CRYPT STRING
        var keyLen:int = key.length;
        var perFrame:int = 90;
		var start:int=0;
		var n:int;
		var strLen:int = str.length;
		var encoded:String = '';
		var chr:String;
		var m:int = 0;
		var __code:Function = function():void {
			if (start == strLen) {
				Loop.remove(__code);
				if(callBack!=null)
					callBack(encoded);
				return;
			}
			
			var len:int = perFrame;
			var bnds:int=start + perFrame
			if ( bnds > strLen)
				len = strLen-start;
			for (n = 0; n < len; n++) {
				chr = getBaseNumber(str.charCodeAt(start+n) + key.charCodeAt(m));
				encoded += chr;
				m++;
				if (m == keyLen)
					m = 0;
			}
			start += len;
			
		};
		Loop.add(__code);
	}
	
	/**
	 * Decrypt
	 * @param	str	Base64 String
	 * @param	keyString
	 * @return
	 */
	static public function decryptAES(str:String, keyString:String):String {
		trace('Crypter -> decryptAES -> try to decrypt: ' + str + " " + keyString);
		var res:String = null;
		try{
			res = AESCrypter.dec(str, keyString);
		}catch (e:Error) {
			echo("Crypter","decryptAES",e.message,true);
		}
		return res;
	}
	
	
	static public function cryptAES(str:String, keyString:String):String {
		return AESCrypter.enc(str, keyString);
	}
	
	static public function crypt(str:String, key:String):String {
		
		if (str == null)
		{
			return "";
		}
		
		if (key == null){
			if (Config.isTest && Capabilities.isDebugger)
				return "NO KEY FOR " + str;
			return "NO KEY!";
		}
			
        // CRYPT STRING
        var keyLen:int = key.length;
				
        var encoded:String = '';
		var m:int=0;
		var n:int = 0;
		while (n < str.length) {
			var chr:String = getBaseNumber(str.charCodeAt(n++) + key.charCodeAt(m));
			
			if (chr.length == 1)
				chr = '.' + chr;
				
			if (chr.length == 3) {
				encoded += '-' + chr;
			}else{
				encoded += chr;
			}
			m++;
			
            if (m == keyLen)
				m = 0;
		}
        return encoded;
    }
	

	/**
	* @param baseString - string to decode
	* @return number;
	*/
	static public function getNumberByBase(baseString:String):Number{
		 var m:int=baseString.length-1;
		 var res:Number=0;
		 var pow:Number=0;
		 while (m > -1)
			res += base.indexOf(baseString.charAt(m--)) * Math.pow(62, (pow++));
		return res;
	}
	
	
	}
}