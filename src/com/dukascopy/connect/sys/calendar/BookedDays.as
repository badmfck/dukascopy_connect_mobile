package com.dukascopy.connect.sys.calendar 
{
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class BookedDays 
	{
		private var holder:Object;
		
		public function BookedDays() 
		{
			
		}
		
		public function add(index:int):void
		{
			if (holder == null)
			{
				holder = new Object();
			}
			holder[index.toString()] = 1;
		}
		
		public function isBooked(index:int):Boolean
		{
			if (holder == null)
			{
				return false;
			}
			if (index.toString() in holder && holder[index.toString()] == 1)
			{
				return true;
			}
			return false;
		}
	}
}