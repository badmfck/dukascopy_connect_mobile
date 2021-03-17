package com.dukascopy.connect.vo.users.adds {
	
	import com.dukascopy.connect.sys.imageManager.IImageData;
	
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	
	public class UserMediaVO {
		public var fxGallery:Array;
		
		public function UserMediaVO() { }
		
		public function dispose():void {
			fxGallery = null;
		}
	}
}