package com.dukascopy.connect.data 
{
	/**
	 * ...
	 * @author ...
	 */
	public class MediaFileData 
	{
		static public const MEDIA_TYPE_IMAGE:String = "image";
		static public const MEDIA_TYPE_VIDEO:String = "video";
		static public const MEDIA_TYPE_FILE:String = "mediaTypeFile";
		public var type:String;
		public var thumb:String;
		public var path:String;
		
		public var thumbWidth:int;
		public var thumbHeight:int;
		public var thumbUID:String;
		public var id:String= null;
		public var loaded:Boolean = false;
		public var percent:Number = 0;
		public var size:uint = 0;
		public var encodeProgress:int = 0;
		public var localResource:String;
		public var rejected:Boolean = false;
		public var error:Boolean = false;
		public var duration:Number = 0;
		public var chatUID:String;
		public var key:String;
		private var _name:String = "";
		
		public function MediaFileData() 
		{
			
		}
		
		public function get name():String 
		{
			if (_name == "" || _name == null)
			{
				return thumbUID + ".mp4";
			}
			return _name;
		}
		
		public function setOriginalName(value:String):void
		{
			_name = value;
		}
		
		public function set name(value:String):void 
		{
			if (value == null)
			{
				return;
			}
			
			if (value.indexOf(".") != -1)
			{
				var segments:Array = value.split(".");
				if (segments.length > 0 && segments[0] != null && segments[0] != "")
				{
					value = segments[0] + ".mp4";
				}
			}
			if (value.indexOf(".mp4") == -1)
			{
				value = value + ".mp4";
			}
			_name = value;
		}
	}
}