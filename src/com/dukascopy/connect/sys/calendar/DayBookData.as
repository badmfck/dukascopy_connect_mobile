package com.dukascopy.connect.sys.calendar 
{
	import com.dukascopy.connect.Config;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class DayBookData 
	{
		public var ranges:Vector.<TimeRange>;
		public var slot:Number;
		public var startHours:int = 0;
		public var startMinutes:int = 0;
		
		public function DayBookData(rawData:Object, difference:Number, start:Date) 
		{
			if (rawData != null)
			{
				slot = rawData.slot;
				
				/*if (rawData.start != null)
				{
					var time:Array = (rawData.start as String).split(":");
					if (time != null && time.length == 2)
					{
						startHours = parseInt(time[0]) - Math.floor(difference / 60);
						startMinutes = parseInt(time[1]) - difference % 60;
					}
				}*/
				
				var now:Date = new Date();
				
				var nextAvaliableHour:int = -1;
				var nextAvaliableMin:int = -1;
				
				startHours = start.getHours();
				startMinutes = start.getMinutes();
				
				if (start.getFullYear() == now.getFullYear() && 
					start.getMonth() == now.getMonth() && 
					start.getDate() == now.getDate())
				{
					var diff:Number = (start.getTime() - now.getTime()) / (1000 * 60);
					if (diff < Config.barabanSettings.freeSlotsMinutesGap)
					{
						nextAvaliableMin = now.getMinutes() + Config.barabanSettings.freeSlotsMinutesGap;
						nextAvaliableHour = now.getHours();
						if (nextAvaliableMin > 59)
						{
							nextAvaliableMin = nextAvaliableMin - 60;
							nextAvaliableHour ++;
						}
					}
				}
				
				if (rawData.desc != null)
				{
					var rangeHours:TimeRange;
					var rangeMinutes:TimeRange;
					ranges = new Vector.<TimeRange>();
					
					var index:int = 0;
					var slotLength:int = (rawData.desc as String).length;
					
					var min:int = 0;
					
					for (var i:int = startHours; i < 24; i++) 
					{
						min = 0;
						if (i == startHours)
						{
							min = startMinutes;
						}
						rangeHours = new TimeRange(i, slot);
						for (var j:int = min; j < 60; j = j+slot) 
						{
							if (index < slotLength)
							{
								if ((rawData.desc as String).charAt(index) == "0")
								{
									if (nextAvaliableMin != -1 && nextAvaliableHour == i && nextAvaliableMin > j)
									{
										
									}
									else
									{
										if (nextAvaliableHour != -1 && i < nextAvaliableHour)
										{
											
										}
										else
										{
											rangeMinutes = new TimeRange(j, slot);
											rangeHours.addSubrange(rangeMinutes);
										}
									}
								}
							}
							else
							{
								break;
							}
							index++;
						}
						if (rangeHours.ranges != null && rangeHours.ranges.length > 0)
						{
							ranges.push(rangeHours);
						}
					}
				}
			}
		}
	}
}