package com.dukascopy.connect.vo {
	/**
	 * ...
	 * @author ...
	 */
	public class ChatStreamVO {
		private var _name:String;
		private var _uid:String;
		private var _instance:String;
		
		public function ChatStreamVO(name:String,uid:String, instance:String) {
			_uid = uid;
			_name = name;
			_instance = instance;
			
		}
		
		public function get name():String {
			return _name;
		}	
		public function get instance():String {
			return _instance;
		}
		
		public function get uid():String {
			return _uid;
		}
		
	
	}

}