package com.dukascopy.connect.sys.ws {
	
	import flash.events.IEventDispatcher;
	import flash.utils.ByteArray;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public interface IWebSocket extends IEventDispatcher {
		
		function isAutoreconnect():Boolean;
		function close(waitForServer:Boolean = true, reason:String = null, clear:Boolean = false):void;
		function connect(reason:String, anyway:Boolean):void;
		function getReadyState():int;
		function sendUTF(packet:String):void;
		function sendBytes(packet:ByteArray):void;
		function isConnecting():Boolean;
		function isOpen():Boolean;
	}
}