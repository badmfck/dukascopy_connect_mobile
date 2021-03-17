package com.dukascopy.connect.sys.calendar 
{
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class TimeRange 
	{
		public var ranges:Vector.<TimeRange>;
		public var value:int;
		public var duration:int;
		
		public function TimeRange(value:int, duration:int) 
		{
			this.value = value;
			this.duration = duration;
		}
		
		public function addSubrange(range:TimeRange):void 
		{
			if (ranges == null)
			{
				ranges = new Vector.<TimeRange>();
			}
			ranges.push(range);
		}
	}
}