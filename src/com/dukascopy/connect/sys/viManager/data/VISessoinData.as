package com.dukascopy.connect.sys.viManager.data 
{
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class VISessoinData 
	{
		private var images:Object;
		private var messages:Vector.<RemoteMessage>;
		
		public function VISessoinData() 
		{
			images = new Object();
		}
		
		public function addPhoto(key:String, data:Vector.<ImageBitmapData>):void 
		{
			if (images != null)
			{
				images[key] = data;
			}
			else
			{
				ApplicationErrors.add();
			}
		}
		
		public function dispose():void 
		{
			if (images != null)
			{
				for (var key:String in images) 
				{
					if (images[key] is ImageBitmapData)
					{
						(images[key] as ImageBitmapData).dispose();
					}
				}
			}
			messages = null;
			images = null;
		}
		
		public function addMessage(message:RemoteMessage):void 
		{
			if (messages == null)
			{
				messages = new Vector.<RemoteMessage>();
			}
			messages.push(message);
		}
		
		public function hasMessages():Boolean 
		{
			return (messages != null && messages.length > 0);
		}
		
		public function getMessages():Vector.<RemoteMessage> 
		{
			return messages;
		}
	}
}