package com.dukascopy.connect.data 
{
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class RateBotData 
	{
		public var data:Object;
		public var immediately:Boolean;
		public var link:String;
		public var action:String;
		public var botUID:String;
		
		public function RateBotData(rawData:Object) 
		{
			if (rawData != null)
			{
				if ("immediately" in rawData)
				{
					immediately = rawData.immediately;
				}
				if ("link" in rawData)
				{
					link = rawData.link;
				}
				/*if ("action" in rawData)
				{
					action = rawData.action;
				}
				if ("data" in rawData)
				{
					data = rawData.data;
				}*/
				action = "action";
			}
		}
	}
}