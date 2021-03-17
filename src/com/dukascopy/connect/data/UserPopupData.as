package com.dukascopy.connect.data {
	
	import com.dukascopy.connect.vo.users.UserVO;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class UserPopupData {
		
		public var data:UserVO;
		public var callback:Function;
		public var resultData:Object;
		public var additionalData:Object;
		public var screenLayer:String;
		
		public function UserPopupData() { }
		
		public function dispose():void {
			data = null;
			callback = null;
		}
	}
}