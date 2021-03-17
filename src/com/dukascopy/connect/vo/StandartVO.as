package com.dukascopy.connect.vo {
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class StandartVO {
		
		public var changed:Boolean;
		
		public function StandartVO() { }
		
		public function fillFieldObject(field:Object, data:Object, key:String, replace:Boolean = false):Object {
			if (data == null)
				return field;
			if (field != null && replace == false)
				return field;
			if (key in data == false)
				return field;
			changed = true;
			return data[key];
		}
		
		public function fillFieldNumber(field:Number, data:Object, key:String, replace:Boolean = false):Number {
			if (data == null)
				return field;
			if (isNaN(field) == false && replace == false)
				return field;
			if (key in data == false)
				return field;
			changed = true;
			return data[key];
		}
		
		public function fillFieldINT(field:int, data:Object, key:String, replace:Boolean = false):int {
			if (data == null)
				return field;
			if (field != int.MIN_VALUE && replace == false)
				return field;
			if (key in data == false)
				return field;
			changed = true;
			return data[key];
		}
		
		public function fillFieldBoolean(field:Boolean, data:Object, key:String, replace:Boolean = false, settedFlag:Boolean = false):int {
			if (data == null)
				return -1;
			if (settedFlag == true && replace == false)
				return (field == true) ? 1 : 0;
			if (key in data == false) {
				if (settedFlag == false)
					return -1;
				return (field == true) ? 1 : 0;
			}
			changed = true;
			return (data[key] == true) ? 1 : 0;
		}
	}
}