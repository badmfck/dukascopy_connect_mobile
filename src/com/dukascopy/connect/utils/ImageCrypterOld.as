package com.dukascopy.connect.utils 
{
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.utils.crypt.Salsa20;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	import gibberishAES.AESCrypter;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class ImageCrypterOld 
	{
		static public var imageKeyFlag:String = "[~~!!!~~]";
		
		public function ImageCrypterOld() 
		{
			
		}
		
		public static function encodeXOR(binaryData:ByteArray, key:Array):void
		{
			var newValue:Number;
            var keyIndex:Number=0;
            for (var i:Number = 0; i < binaryData.length; i++) {
				binaryData[i] = binaryData[i] ^ key[keyIndex];
                keyIndex++;
                if(keyIndex>=key.length)
                    keyIndex=0;
            }
        }
		
		public static function encode(binaryData:ByteArray, key:Array):void
		{
			var keyBytes:ByteArray = new ByteArray();
			
			for (var i:int = 0; i < 16; i++) 
			{
				keyBytes.writeByte(key[i]);
			}
			
			var nounceBytes:ByteArray = new ByteArray();
			
			for ( ; i < 24; i++) 
			{
				nounceBytes.writeByte(key[i]);
			}
			
			var crypter:Salsa20 = new Salsa20(keyBytes, nounceBytes);
			var result:ByteArray = crypter.crypt(binaryData, 0, 0, binaryData.length);
			binaryData.length = 0;
			binaryData.writeBytes(result);
        }
		
		static public function cryptJPEG(pngImage:ByteArray, key:Array):ByteArray 
		{
			pngImage.position = 0;
			var positionsDB:Array = new Array();
			var positionsFF:Array = new Array();
			var positions00:Array = new Array();
			
			var startPosition:uint;
			var searchByte:ByteArray;
			var position:uint = 0;
			
			
			// if image crypted find presaved positions of original 0xFF markers in the end of file;
			pngImage.position = 0;
			searchByte = new ByteArray();
			
			searchByte.writeByte(0xDD);
			searchByte.writeByte(0xDD);
			searchByte.writeByte(0xFF);
			searchByte.writeByte(0xFF);
			searchByte.writeByte(0xFF);
			searchByte.writeByte(0xFF);
			searchByte.writeByte(0xDD);
			searchByte.writeByte(0xDD);
			
			
			searchByte.position = 0;
			startPosition = 0;
			position = 0;
			
			var crypting:Boolean = false;
			
			
			position = searchBytes(searchByte, pngImage, startPosition);
			if (position <= pngImage.length - 1 && position > 0)
			{
				pngImage.position = position + 8;
				if (pngImage.bytesAvailable > 0)
				{
					var itemsFF:uint = pngImage.readUnsignedInt();
					for (var l:int = 0; l < itemsFF; l++) 
					{
						try
						{
							positionsFF.push(pngImage.readUnsignedInt());
						}
						catch (e:Error)
						{
							break;
						}
					}
					var itemsDB:uint = pngImage.readUnsignedInt();
					for (var m:int = 0; m < itemsDB; m++) 
					{
						try
						{
							positionsDB.push(pngImage.readUnsignedInt());
						}
						catch (e:Error)
						{
							break;
						}
					}
					var items00:uint = pngImage.readUnsignedInt();
					for (m = 0; m < items00; m++) 
					{
						try
						{
							positions00.push(pngImage.readUnsignedInt());
						}
						catch (e:Error)
						{
							break;
						}
					}
				}
				pngImage.length = position + 2;
			}
			
			if (positionsFF.length == 0)
			{
				crypting = true;
				pngImage.position = 0;
				searchByte = new ByteArray();
				searchByte.writeByte(0xFF);
				searchByte.position = 0;
				startPosition = 0;
				position = 0;
				while (position != -1)
				{
					position = searchBytes(searchByte, pngImage, startPosition);
					if (position <= pngImage.length - 1)
					{
						if (position != -1)
						{
							positionsFF.push(position);
						}
						startPosition = position + 1;
					}
					else
					{
						break;
					}
				}
			}
			
			if (crypting)
			{
				pngImage.position = 0;
				searchByte = new ByteArray();
				searchByte.writeByte(0xFF);
				searchByte.writeByte(0xDB);
				searchByte.position = 0;
				startPosition = 0;
				position = 0;
				while (position != -1)
				{
					position = searchBytes(searchByte, pngImage, startPosition);
					if (position <= pngImage.length - 1)
					{
						if (position != -1)
						{
							positionsDB.push(position + 5);
						}
						startPosition = position + 1;
					}
					else {
						break;
					}
				}
				
				pngImage.position = 0;
				searchByte = new ByteArray();
				searchByte.writeByte(0xFF);
				searchByte.writeByte(0x00);
				searchByte.position = 0;
				startPosition = 0;
				position = 0;
				while (position != -1)
				{
					position = searchBytes(searchByte, pngImage, startPosition);
					if (position <= pngImage.length - 1)
					{
						if (position != -1)
						{
							positions00.push(position + 2);
						}
						startPosition = position + 1;
					}
					else {
						break;
					}
				}
			}
			
			var linesToCrypt:Array = new Array();
			var nearestFF:uint
			for (var i3:uint = 0; i3 < positionsDB.length; i3++) 
			{
				nearestFF = -1;
				for (var j:uint = 0; j < positionsFF.length; j++) 
				{
					if (positionsFF[j] > positionsDB[i3])
					{
						nearestFF = positionsFF[j];
						break;
					}
				}
				if (nearestFF != 4294967295 && nearestFF != -1)
				{
					linesToCrypt.push(new Point(positionsDB[i3], nearestFF));
				}
			}
			
			for (var i2:uint = 0; i2 < positions00.length; i2++) 
			{
				nearestFF = -1;
				for (j = 0; j < positionsFF.length; j++) 
				{
					if (positionsFF[j] > positions00[i2])
					{
						nearestFF = positionsFF[j];
						break;
					}
				}
				if (nearestFF != 4294967295 && nearestFF != -1)
				{
					linesToCrypt.push(new Point(positions00[i2], nearestFF));
				}
			}
			
			var pos:uint = 0;
			var toDecode:ByteArray = new ByteArray();
			
			var endOfImage:ByteArray = new ByteArray();
			
			for (var k:int = 0; k < linesToCrypt.length; k++) 
			{
				toDecode.length = 0;
				pngImage.position = linesToCrypt[k].x;
				pngImage.readBytes(toDecode, 0, linesToCrypt[k].y - linesToCrypt[k].x);
				var start:int = toDecode.length;
				encode(toDecode, key)
				pngImage.position = linesToCrypt[k].x;
				pngImage.writeBytes(toDecode);
			}
			
			if (crypting)
			{
				pngImage.position = pngImage.length;
				
				pngImage.writeByte(0xDD);
				pngImage.writeByte(0xDD);
				pngImage.writeByte(0xFF);
				pngImage.writeByte(0xFF);
				pngImage.writeByte(0xFF);
				pngImage.writeByte(0xFF);
				pngImage.writeByte(0xDD);
				pngImage.writeByte(0xDD);
				
				pngImage.writeUnsignedInt(positionsFF.length);
				for (var i:int = 0; i < positionsFF.length; i++) 
				{
					pngImage.writeUnsignedInt(positionsFF[i]);
				}
				
				pngImage.writeUnsignedInt(positionsDB.length);
				for (i = 0; i < positionsDB.length; i++) 
				{
					pngImage.writeUnsignedInt(positionsDB[i]);
				}
				
				pngImage.writeUnsignedInt(positions00.length);
				for (i = 0; i < positions00.length; i++) 
				{
					pngImage.writeUnsignedInt(positions00[i]);
				}
			}
			
			return pngImage;
		}
		
		static public function decryptJPEG(imageData:ByteArray, key:Array):Boolean 
		{
			var startSize:int = imageData.length;
			imageData.position = 0;
			var searchByte:ByteArray = new ByteArray();
			
			searchByte.writeByte(0xDD);
			searchByte.writeByte(0xDD);
			searchByte.writeByte(0xFF);
			searchByte.writeByte(0xFF);
			searchByte.writeByte(0xFF);
			searchByte.writeByte(0xFF);
			searchByte.writeByte(0xDD);
			searchByte.writeByte(0xDD);
			
			
			searchByte.position = 0;
			var startPosition:int = 0;
			var position:uint = 0;
			
			position = searchBytes(searchByte, imageData, startPosition);
			
			if (position <= imageData.length - 1 && position > 0)
			{
				var decrypted:ByteArray = cryptJPEG(imageData, key);
				imageData.position = 0;
				imageData.writeBytes(decrypted);
				decrypted = null;
				trace("DECRYPT", startSize, imageData.length);
				return true;
			}
			else
			{
				return false;
			}
		}
		
		public static function searchBytes(needle:ByteArray, heystack:ByteArray, startPosition:uint = 0):uint
        {
            var position:uint = startPosition;
            var trackback:uint;
            var searcheable:uint;
            var head:uint;
            var headFound:Boolean;
            var hasTrackBack:Boolean;
            var needlePosition:uint;
            var current:uint;
			
            if (!needle || !needle.length || !heystack || !heystack.length ||
                needle.length > heystack.length)
                return -1;
            searcheable = heystack.length - needle.length;
            head = needle[0];
			
            for (; position < searcheable; position++)
            {
                current = heystack[position];
                if (!headFound)
                {
                    if (current == head)
                    {
						headFound = true;
						needlePosition = 1;
                    }
                }
                else
                {
                    if (needlePosition == needle.length)
                    {
                        position -= needlePosition;
                        break;
                    }
					
                    if (needle[needlePosition] == current)
                    {
                        needlePosition++;
                    }
                    else
                    {
                        headFound = false;
                        position = position - needlePosition + 1;
                    }
                }
            }
            if (position == searcheable) 
			{
				position = -1;
			}
            return position;
        }
		
		static public function cryptJpegXOR(data:ByteArray, imageKey:Array):ByteArray 
		{
			encodeXOR(data, imageKey);
			return data;
		}
		
		static public function getJpegXORFlag():ByteArray 
		{
			var bytes:ByteArray = new ByteArray();
			bytes.writeByte(0xFF);
			bytes.writeByte(0xFF);
			bytes.writeByte(0xDD);
			bytes.writeByte(0xDD);
			bytes.writeByte(0xFF);
			bytes.writeByte(0xFF);
			
			bytes.position = 0;
			return bytes;
		}
		
		static public function decryptJpegXOR(imageData:ByteArray, cryptKey:Array):void 
		{
			encodeXOR(imageData, cryptKey);
		}
	}
}