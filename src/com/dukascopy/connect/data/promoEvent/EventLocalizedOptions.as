package com.dukascopy.connect.data.promoEvent 
{
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev
	 */
	public class EventLocalizedOptions 
	{
		public var banner_uid:String;
		public var lang:String;
		public var cuid:String;
		public var description:String;
		
		public function EventLocalizedOptions(rawData:Object) 
		{
			if (rawData != null)
			{
				parse(rawData);
			}
		}
		
		private function parse(rawData:Object):void 
		{
			if ("banner_uid" in rawData)
			{
				banner_uid = rawData.banner_uid;
			}
			if ("description" in rawData)
			{
				description = rawData.description;
			}
			if ("cuid" in rawData)
			{
				cuid = rawData.cuid;
			}
			if ("lng" in rawData)
			{
				lang = rawData.lng;
			}
		}
	}
}