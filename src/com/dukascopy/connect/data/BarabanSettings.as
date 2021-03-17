package com.dukascopy.connect.data 
{
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class BarabanSettings 
	{
		public var maxLateMinutes:Number = 5;
		public var freeSlotsMinutesGap:Number = 60;
		
		public function BarabanSettings(rawData:Object = null) 
		{
			if (rawData != null)
			{
				parse(rawData);
			}
		}
		
		private function parse(rawData:Object):void 
		{
			if ("maxLateMinutes" in rawData)
			{
				maxLateMinutes = parseInt(rawData.maxLateMinutes);
			}
			if ("freeSlotsMinutesGap" in rawData)
			{
				freeSlotsMinutesGap = parseInt(rawData.freeSlotsMinutesGap);
			}
		}
	}
}