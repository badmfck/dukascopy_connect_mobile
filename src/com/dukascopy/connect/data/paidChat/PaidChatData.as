package com.dukascopy.connect.data.paidChat 
{
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class PaidChatData 
	{
		public var title:String;
		public var description:String;
		public var cost:Number;
		public var currency:String;
		public var photo:String;
		public var chatUid:String;
		public var userUid:String;
		
		public function PaidChatData(rawData:Object = null) 
		{
			if (rawData != null)
			{
				if ("amount" in rawData)
				{
					cost = rawData.amount;
				}
				if ("currency" in rawData)
				{
					currency = rawData.currency;
				}
				if ("info" in rawData && rawData.info != null)
				{
					if ("description" in rawData.info)
					{
						description = rawData.info.description;
					}
					if ("title" in rawData.info)
					{
						title = rawData.info.title;
					}
					if ("photo" in rawData.info)
					{
						photo = rawData.info.photo;
					}
				}
			}
		}
	}
}