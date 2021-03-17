package com.dukascopy.connect.utils.crypt 
{
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class Salsa20
	{
		private static var tau:Vector.<int> = new Vector.<int>();
			tau.push(0x61707865);
			tau.push(0x3120646e);
			tau.push(0x79622d36);
			tau.push(0x6b206574);
		
		// encryption states
		private var input:Vector.<int> = new Vector.<int>(16);
		private var output:Vector.<int> = new Vector.<int>();
		private var tmp1:Vector.<int> = new Vector.<int>(); // not used outside
		
		// parameter
		private var doubleRounds:int; // salsa20/20 is 10 double-rounds
		
		// positions
		private var posBlock:Number = 0; // 64-byte block number
		private var posRemainder:int = 0; // 0..63
		
		/**
		 * @param key 16 byte (128 bit)
		 * @param nonce 8 byte (64 bit)
		 * @param rounds Must be even. 20 is the full Salsa20 with 20 rounds (or 10 double-rounds) 
		 */
		public function Salsa20(key:ByteArray, nonce:ByteArray, rounds:int = 20):void
		{
			if (key == null || key.length != 16) {
				throw new Error("key is not 16 bytes");
			}
			if (nonce == null || nonce.length != 8) {
				throw new Error("nonce is not 8 bytes");
			}
			
			doubleRounds = rounds >> 1;
			if (doubleRounds + doubleRounds != rounds) {
				throw new Error("rounds must be even");
			}
			
			setup(key, nonce);
		}
		
		///////////////////////////////////////////////////////////////////////////
		
		private function calcEncryptionOutputFromInput():void
		{
			var _input:Vector.<int> = this.input;
			var _output:Vector.<int> = this.output;
			var x:Vector.<int> = _input.concat();
			
			var s:int;
			for (var i:int = doubleRounds; i > 0; i--) {
				s = x[ 0] + x[12]; x[ 4] ^= (s <<  7) | (s >>> (32 -  7));
				s = x[ 4] + x[ 0]; x[ 8] ^= (s <<  9) | (s >>> (32 -  9));
				s = x[ 8] + x[ 4]; x[12] ^= (s << 13) | (s >>> (32 - 13));
				s = x[12] + x[ 8]; x[ 0] ^= (s << 18) | (s >>> (32 - 18));
				s = x[ 5] + x[ 1]; x[ 9] ^= (s <<  7) | (s >>> (32 -  7));
				s = x[ 9] + x[ 5]; x[13] ^= (s <<  9) | (s >>> (32 -  9));
				s = x[13] + x[ 9]; x[ 1] ^= (s << 13) | (s >>> (32 - 13));
				s = x[ 1] + x[13]; x[ 5] ^= (s << 18) | (s >>> (32 - 18));
				s = x[10] + x[ 6]; x[14] ^= (s <<  7) | (s >>> (32 -  7));
				s = x[14] + x[10]; x[ 2] ^= (s <<  9) | (s >>> (32 -  9));
				s = x[ 2] + x[14]; x[ 6] ^= (s << 13) | (s >>> (32 - 13));
				s = x[ 6] + x[ 2]; x[10] ^= (s << 18) | (s >>> (32 - 18));
				s = x[15] + x[11]; x[ 3] ^= (s <<  7) | (s >>> (32 -  7));
				s = x[ 3] + x[15]; x[ 7] ^= (s <<  9) | (s >>> (32 -  9));
				s = x[ 7] + x[ 3]; x[11] ^= (s << 13) | (s >>> (32 - 13));
				s = x[11] + x[ 7]; x[15] ^= (s << 18) | (s >>> (32 - 18));
				s = x[ 0] + x[ 3]; x[ 1] ^= (s <<  7) | (s >>> (32 -  7));
				s = x[ 1] + x[ 0]; x[ 2] ^= (s <<  9) | (s >>> (32 -  9));
				s = x[ 2] + x[ 1]; x[ 3] ^= (s << 13) | (s >>> (32 - 13));
				s = x[ 3] + x[ 2]; x[ 0] ^= (s << 18) | (s >>> (32 - 18));
				s = x[ 5] + x[ 4]; x[ 6] ^= (s <<  7) | (s >>> (32 -  7));
				s = x[ 6] + x[ 5]; x[ 7] ^= (s <<  9) | (s >>> (32 -  9));
				s = x[ 7] + x[ 6]; x[ 4] ^= (s << 13) | (s >>> (32 - 13));
				s = x[ 4] + x[ 7]; x[ 5] ^= (s << 18) | (s >>> (32 - 18));
				s = x[10] + x[ 9]; x[11] ^= (s <<  7) | (s >>> (32 -  7));
				s = x[11] + x[10]; x[ 8] ^= (s <<  9) | (s >>> (32 -  9));
				s = x[ 8] + x[11]; x[ 9] ^= (s << 13) | (s >>> (32 - 13));
				s = x[ 9] + x[ 8]; x[10] ^= (s << 18) | (s >>> (32 - 18));
				s = x[15] + x[14]; x[12] ^= (s <<  7) | (s >>> (32 -  7));
				s = x[12] + x[15]; x[13] ^= (s <<  9) | (s >>> (32 -  9));
				s = x[13] + x[12]; x[14] ^= (s << 13) | (s >>> (32 - 13));
				s = x[14] + x[13]; x[15] ^= (s << 18) | (s >>> (32 - 18));
			}
			
			for (i = 0; i < 16; i++){
				var value:int = x[i] + _input[i];
				var nOfs:int = i << 2;
				_output[nOfs] = value;
				_output[nOfs + 1] = (value >>> 8);
				_output[nOfs + 2] = (value >>> 16);
				_output[nOfs + 3] = (value >>> 24);
			}
		}
		
		/* this.input is int32[16] (from key int32[4], offset int32[2], nonce int32[2]):
		 * [0] = constants[0]
		 * [1] = key[0]
		 * [2] = key[1]
		 * [3] = key[2]
		 * [4] = key[3]
		 * [5] = constants[1]
		 * [6] = nonce[0]
		 * [7] = nonce[1]
		 * [8] = offset[0]
		 * [9] = offset[1]
		 * [10] = constants[2]
		 * [11] = key[0]
		 * [12] = key[1]
		 * [13] = key[2]
		 * [14] = key[3]
		 * [15] = constants[3]
		 */
		private function setup(key:ByteArray, nonce:ByteArray):void
		{
			var constants:Vector.<int>;
			
			// setup from key
			input[1] = readInt32LE(key, 0);
			input[2] = readInt32LE(key, 4);
			input[3] = readInt32LE(key, 8);
			input[4] = readInt32LE(key, 12);
			
			if (key.length == 16) { // only 128 bit key supported here
				constants = tau; 
			} else {
				throw new Error("key not 128 bit");
			}
			
			// setup from key
			input[11] = readInt32LE(key, 0);
			input[12] = readInt32LE(key, 4);
			input[13] = readInt32LE(key, 8);
			input[14] = readInt32LE(key, 12);
			
			// setup from constants
			input[0] = constants[0];
			input[5] = constants[1];
			input[10] = constants[2];
			input[15] = constants[3];
			
			// setup from nonce
			input[6] = readInt32LE(nonce, 0);
			input[7] = readInt32LE(nonce, 4);
			input[8] = 0; // data offset is 0
			input[9] = 0; // data offset is 0
			
			calcEncryptionOutputFromInput();
		}
		
		private static function readInt32LE(data:ByteArray, nOfs:int):int
		{
			data.position = nOfs;
			return data.readUnsignedInt();
			
			/*return (data[nOfs + 3] << 24) |
			((data[nOfs + 2] & 0xff) << 16) |
			((data[nOfs + 1] & 0xff) << 8) |
			(data[nOfs] & 0xff);*/
		}
		
		public function getPosition():Number
		{
			return (posBlock << 6) | posRemainder;
		}
		
		public function setPosition(pos:Number):void
		{
			setBlockPosition(pos >> 6);
			posRemainder = int(pos & 0x3f);
		}
		
		private function setBlockPosition(block:Number):void
		{
			// only recalculate when it changes
			if (posBlock != block)
			{
				posBlock = block;
				input[8] = int(block & 0x00000000ffffffff);
				input[9] = int(block >>> 32);
				calcEncryptionOutputFromInput();
			}
		}
		
		private function increaseBlockPosition():void
		{
			posBlock++;
			var block:Number = posBlock;
			input[8] = int(block & 0x00000000ffffffff);
			input[9] = int(block >>> 32);
			calcEncryptionOutputFromInput();
		}
		
		public function crypt(inputData:ByteArray, inOffset:int, outOffset:int, len:int):ByteArray
		{
			var _posRemainder:int = posRemainder;
			var _output:Vector.<int> = output;
			var out:ByteArray = new ByteArray();
			
			inputData.position = inOffset;
			
			for (var i:int = 0; i < len; i++)
			{
				out.writeByte((inputData.readByte() ^ _output[_posRemainder]));
				
				// increase our position
				_posRemainder++;
				if (_posRemainder == 64)
				{
					_posRemainder = 0;
					increaseBlockPosition();
				}
			}
			
			posRemainder = _posRemainder;
			
			return out;
		}
	}
}