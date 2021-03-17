package com.dukascopy.connect.sys.php {
	
	import flash.net.URLRequestMethod;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public interface IDataLoader {
		
		function load(url:String, 
			callBack:Function = null, 
			data:Object = null, 
			method:String = URLRequestMethod.POST, 
			headers:/*URLRequestHeader*/Array = null, 
			rawRespond:Boolean = false, 
			crypt:Boolean = true):void;
		function loadAsStream(url:String, 
			callBack:Function = null, 
			data:Object = null, 
			method:String = URLRequestMethod.POST,  
			headers:Array = null, 
			rawRespond:Boolean = false, 
			crypt:Boolean = true):void;
		function setAdditionalData(ad:Object):void;
		function dispose():void;
		function getID():int;
	}
}