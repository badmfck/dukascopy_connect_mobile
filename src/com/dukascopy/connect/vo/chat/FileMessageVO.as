package com.dukascopy.connect.vo.chat {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.utils.TextUtils;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class FileMessageVO {
		
		public var size:uint = 0;
		public var title:String;
		public var fileType:String;
		public var uid:String;
		
		public function FileMessageVO(data:Object = null) {
			if (data == null)
				return;
			
			if ("size" in data && data.size != null)
				size = data.size;
			
			if ("title" in data && data.title != null)
				title = data.title;
			
			if ("fileType" in data && data.fileType != null)
				fileType = data.fileType;
			
			if ("additionalData" in data && data.additionalData != null)
				uid = data.additionalData;
		}
		
		public function getSize():String {
			return TextUtils.toReadbleFileSize(size);
		}
		
		public function getFileUrl():String {
			if (uid != null && uid != "") {
				return Config.URL_PHP_CORE_SERVER + '?method=files.get&key=' + Auth.key +'&uid=' + uid;
			}
			return null;
		}
		
		public function dispose():void {
			title = null;
		}
	}
}