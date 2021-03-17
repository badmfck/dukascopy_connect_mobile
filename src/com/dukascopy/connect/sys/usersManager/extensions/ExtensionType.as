package com.dukascopy.connect.sys.usersManager.extensions 
{
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class ExtensionType 
	{
		private var _value:String;
		
		static public const FLOWER_1:String = "flower1";
		static public const FLOWER_2:String = "flower2";
		static public const FLOWER_3:String = "flower3";
		static public const FLOWER_4:String = "flower4";
		
		public function get value():String 
		{
			return _value;
		}
		
		public function ExtensionType(value:String) 
		{
			//TODO проверку на валидность типа
			this._value = value;
		}
	}
}