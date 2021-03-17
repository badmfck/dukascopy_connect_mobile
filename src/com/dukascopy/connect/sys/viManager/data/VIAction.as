package com.dukascopy.connect.sys.viManager.data 
{
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.hurlant.util.Base64;
	import flash.display.PNGEncoderOptions;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class VIAction 
	{
		static public const CAMERA_REAR:String = "rear";
		static public const CAMERA_FRONT:String = "front";
		
		public var text:String;
		public var action:String;
		public var title:String;
		public var tapped:Boolean = false;
		public var disabled:Boolean = false;
		public var camera:String;
		public var description:String;
		public var type:String;
		public var photoSize:String;
		public var photoNum:int;
		private var images:Array;
		public var destination:String;
		public var data:Object;
		
		public function VIAction(rawData:Object = null) 
		{
			if (rawData != null)
			{
				parse(rawData);
			}
		}
		
		private function parse(rawData:Object):void 
		{
			if ("text" in rawData && rawData.text != null)
			{
				text = rawData.text;
			}
			if ("key" in rawData && rawData.key != null)
			{
				text = rawData.key;
			}
			if ("action" in rawData && rawData.action != null)
			{
				action = rawData.action;
			}
			if ("camera" in rawData && rawData.camera != null)
			{
				camera = rawData.camera;
			}
			if ("description" in rawData && rawData.description != null)
			{
				description = rawData.description;
			}
			if ("destination" in rawData && rawData.destination != null)
			{
				destination = rawData.destination;
			}
			if ("photoCount" in rawData)
			{
				photoNum = rawData.photoCount;
			}
			if ("photoSize" in rawData && rawData.photoSize != null)
			{
				photoSize = rawData.photoSize;
			}
			if ("type" in rawData && rawData.type != null)
			{
				type = rawData.type;
			}
			if ("data" in rawData && rawData.data != null)
			{
				data = rawData.data;
			}
		}
		
		public function getRaw():Object 
		{
			var raw:Object = new Object()
			if (text != null)
			{
				raw.text = text;
			}
			if (action != null)
			{
				raw.action = action;
			}
			if (camera != null)
			{
				raw.camera = camera;
			}
			if (description != null)
			{
				raw.description = description;
			}
			if (!isNaN(photoNum))
			{
				raw.photoNum = photoNum;
			}
			if (images != null)
			{
				raw.photo = images;
			}
			if (type != null)
			{
				raw.type = type;
			}
			
			return raw;
		}
		
		public function addPhoto(imageBitmapData:ImageBitmapData):void {
			images ||= new Array();
			
			var width:int = 1024;
			var height:int = 1024;
			
			if (photoSize != null && photoSize.indexOf("x") != -1)
			{
				var sizes:Array = photoSize.split("x");
				if (sizes != null && sizes.length > 1 && !isNaN(Number(sizes[0])) && !isNaN(Number(sizes[1])))
				{
					width = Number(sizes[0]);
					height = Number(sizes[1]);
				}
			}
			
			imageBitmapData = ImageManager.resize(imageBitmapData, width, height, ImageManager.SCALE_INNER_PROP);
			images.push(
				"image/png;base64," + Base64.encodeByteArray(
					imageBitmapData.encode(
						imageBitmapData.rect,
						new PNGEncoderOptions(true)
					)
				)
			);
			data ||= {};
			data.photos = images;
		}
		
		public function getCopy():VIAction 
		{
			return new VIAction(getRaw());
		}
		
		public function getPhoto():Array 
		{
			return images;
		}
	}
}