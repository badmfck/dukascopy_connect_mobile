package com.dukascopy.connect.sys.calendar 
{
	import com.dukascopy.langs.Lang;
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	public class Month 
	{
		public var lastDay:int;
		public var days:int;
		public var firstDay:int;
		public var monthIndex:int;
		public var year:int;
		
		public function Month(date:Date) 
		{
			monthIndex = date.getMonth();
			date.setDate(1);
			firstDay = date.getDay();
			if (firstDay == 0)
			{
				firstDay = 7;
			}
			date.setMonth(monthIndex + 1);
			date.setDate(0);
			lastDay = date.getDay();
			days = date.getDate();
			year = date.getFullYear();
		}
	}
}