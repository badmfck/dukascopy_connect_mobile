package com.dukascopy.connect.sys.imageManager 
{
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	public class FxImageData implements IImageData
	{
		private var user_id:int;
		private var text:String;
		private var main:String;
		private var gallery_id:String;
		private var created:String;
		private var image_id:String;
		
		public function FxImageData(rawData:Object) 
		{
			if ("user_id" in rawData)
			{
				user_id = rawData.user_id;
			}
			
			if ("text" in rawData)
			{
				text = rawData.text;
			}
			
			if ("main" in rawData)
			{
				main = rawData.main;
			}
			
			if ("gallery_id" in rawData)
			{
				gallery_id = rawData.gallery_id;
			}
			
			if ("created" in rawData)
			{
				created = rawData.created;
			}
			
			if ("image_id" in rawData)
			{
				image_id = rawData.image_id;
			}
		}
		
		public function getURL():String
		{
			return "https://www.dukascopy.com/imageserver/img/" + image_id + "/1000-800_6/image.jpg";
		//	return "https://www.php-test.site.dukascopy.com/imageserver/img/" + image_id + "/1000-800_6/image.jpg"
		}
		
		public function getDescription():String
		{
			return text;
		}
	}
}