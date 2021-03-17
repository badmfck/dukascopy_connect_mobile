package com.dukascopy.connect.vo {
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.sys.auth.Auth;
	
	/**
	 * ...
	 * @author ...
	 */
	public class EntryPointVO {
		
		public var avatar:String;
		public var message:String;
		public var onDutyCount:String;
		public var membersCount:int=-1;
		public var description:String;
		public var title:String = '';
		public var id:int = 0;
		public var short:String = '';
		public var visibility:Boolean = false;
		public var status:int = 0;
		public var vi:int = 0;
		
		public function EntryPointVO(data:Object) {
			if (data == null) {
				id = -1;
				return;
			}
			title = data.full;
			id = data.ep;
			short = data.short;
			membersCount = -1;
			message = data.msg;
			avatar = data.ava;
			description = data.description;
			visibility = data.visibility == 'visible';
			status = data.status;
			vi = data.vi;
		}
		
		public function get name():String {
			return title;
		}
		
		public function get avatarURL():String {
			if (!avatar || avatar == "")
				return null;
			return Config.URL_PHP_CORE_SERVER_FILE + "?method=files.get&key=web&uid=" + avatar + "&type=image";
		}
		
		public function dispose():void { }
	}
}