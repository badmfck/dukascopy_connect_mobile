package com.dukascopy.connect.data {
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class ResponseResolver {
		
		public var callback:Function;
		public var data:Object;
		
		public function ResponseResolver() { }
		
		public function dispose():void {
			callback = null;
			data = null;
		}
	}
}