package com.dukascopy.connect.type 
{
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class FinanceFilterCategoryType 
	{
		static public const TYPE:String = "type";
		static public const STATUS:String = "status";
		static public const ACCOUNT:String = "account";
		static public const DATE:String = "date";
		
		private var value:String;
		
		public function FinanceFilterCategoryType(value:String) 
		{
			this.value = value;
		}
		
		public function get type():String
		{
			return value;
		}
	}
}