package com.dukascopy.connect.utils 
{
	/**
	 * ...
	 * @author David Gnatkivskij. Telefision TEAM Kiev.
	 */
	public class UniqueIDDispatcher 
	{
		private static var  _currentInt:int = 1;
		
		public static function get newUniqueNumberID():Number
		{
			_currentInt++;
			return _currentInt + Math.random();
		}
		public static function get newUniqueStringID():String
		{
			return newUniqueNumberID.toString();
		}
	}

}