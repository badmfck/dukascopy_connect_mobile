package com.dukascopy.connect.vo.chat 
{
	import com.dukascopy.connect.Config;
	/**
	 * ...
	 * @author ...
	 */
	public class NewsMessageVO 
	{
		private var contentType:String;
		public var title:String;
		public var text:String;
		public var image:String;
		public var original:String;
		public var link:String;
		public var type:int = 0;
		
		public static const TYPE_VIDEO:String = "video";
		public static const TYPE_IMAGE:String = "image";
		
		public static var regexp:RegExp = new RegExp("vp.*\/.{32}\/.{8}\/");
		
		public static const TYPE_INSTAGRAM:int = 1;
		
		public function NewsMessageVO(rawData:Object = null) {
			if (rawData != null) {
				parse(rawData);
			}
		}
		
		private function parse(rawData:Object):void {
			if (rawData != null) {
				if ("additionalData" in rawData && rawData.additionalData != null){
					text = rawData.additionalData;
				}
				if ("title" in rawData && rawData.title != null) {
					title = rawData.title;
				}
				if ("img" in rawData && rawData.img != null) {
					image = rawData.img;
				}
				if ("url" in rawData && rawData.url != null) {
					link = rawData.url;
				}
				if ("original" in rawData && rawData.original != null) {
					original = rawData.original;
				//	original = original.replace(regexp, "");
				}
				if ("content_type" in rawData && rawData.content_type != null) {
					contentType = rawData.content_type;
				}
				
				if (image != null && image.indexOf("instagram") !=  -1) {
					type = TYPE_INSTAGRAM;
					image = Config.URL_PHP_CORE_SERVER + "?method=img.get&url=" + escape(image) + "&key=web";
					if (original != null) {
						original = Config.URL_PHP_CORE_SERVER + "?method=img.get&url=" + escape(original) + "&key=web";
					}
					
				//	image = image.replace(regexp, "");
				}
			}
		}
	}
}