package com.dukascopy.connect.utils.Debug {
	
	/**
	 * ...
	 * @author David Gnatkivskij. Telefision TEAM Kiev.
	 */
	
	public class Assert {
		
		public static function assert(bool:Boolean, messageOnFalse:String):void {
			if (bool == false) {
				var resString:String = "Unexpected error: " + messageOnFalse;
				trace(resString);
			}
		}
		
		public static function isNotNull(o:Object, messageOnFalse = "Unexpected null"):void {
			assert(o != null, messageOnFalse);
		}
		
		public static function isValueInBounds(minBound:Number, value:Number, maxBound:Number, messageOnOutOfBounds:String = "value out of bounds"):void {
			assert(maxBound > minBound, "unexpected bounds, min " + minBound + " max " + maxBound);
			assert(minBound <= value && maxBound >= value, messageOnOutOfBounds + " " + minBound + "|" + value + "|" + maxBound);
		}
	}
}