package com.dukascopy.connect.sys.applicationError 
{
	import flash.system.Capabilities;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class ApplicationErrors 
	{
		static private var errors:Vector.<ApplicationErrorData>;
		
		public function ApplicationErrors() {
			
		}
		
		static public function add(details:String = null):void {
			if (Capabilities.isDebugger == true) {
			//	throw(new Error());
			}
			
			if (errors == null) {
				errors = new Vector.<ApplicationErrorData>();
			}
			
			if (errors.length > 50) {
				send();
				return;
			}
			
			var e:Error = new Error();
			var s:String = e.getStackTrace();
			
			var error:ApplicationErrorData = new ApplicationErrorData();
			if (details != null) {
				error.details = details;
			}
			error.stack = s;
			errors.push(error);
		}
		
		static private function send():void {
			
		}
	}
}