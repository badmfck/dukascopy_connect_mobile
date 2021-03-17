package com.dukascopy.connect.vo.chat {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.utils.TextUtils;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class VideoMessageVO {
		
		private var _thumbUID:String;
		public var duration:Number = 0;
		public var localResource:String;
		public var error:Boolean = false;
		public var rejected:Boolean = false;
		public var size:uint = 0;
		public var title:String;
		public var thumbWidth:int;
		public var thumbHeight:int;
		
		public var percent:int = 0;
		public var loaded:Boolean = false;
		public var encodeProgress:int;
		public var saveAvaliable:Boolean = true;
		
		public function VideoMessageVO(thumbUID:String, data:Object) {
			if (data == null)
				return;
			
			_thumbUID = thumbUID;
			
			if ("percent" in data)
				percent = int(data.percent);
			if ("percent" in data)
				percent = int(data.percent);
			if ("title" in data)
				title = data.title;
			if ("size" in data)
				size = uint(data.size);
			if ("duration" in data)
				duration = Number(data.duration);
			if ("encodeProgress" in data)
				encodeProgress = uint(data.encodeProgress);
			if ("loaded" in data && data.loaded != null)
				loaded = (data.loaded.toString() == "true");
			if ("rejected" in data && data.rejected != null)
				rejected = (data.rejected.toString() == "true");
			if ("error" in data && data.error != null)
				error = (data.error.toString() == "true");
			if ("localResource" in data && data.localResource != null)
				localResource = data.localResource;	
		}
		
		public function getSize():String {
			return TextUtils.toReadbleFileSize(size);
		}
		
		public function getVideo():String {
			if (_thumbUID != null && _thumbUID != "")
			{
				return Config.URL_PHP_CORE_SERVER + '?method=files.get&key=' + Auth.key +'&uid=' + _thumbUID;
			}
			return null;
		}
		
		public function dispose():void {
			_thumbUID = null;
			title = null;
		}
		
		public function get thumbUID():String 
		{
			return _thumbUID;
		}
		
		public function set thumbUID(value:String):void 
		{
			_thumbUID = value;
		}
	}
}