package com.dukascopy.connect.sys.ws 
{
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.dukascopyextension.DukascopyExtensionAndroid;
	import com.worlize.websocket.WebSocketErrorEvent;
	import com.worlize.websocket.WebSocketEvent;
	import com.worlize.websocket.WebSocketMessage;
	import connect.DukascopyExtension;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author SergeyDobarin
	 */
	public class AndroidWebSocket extends EventDispatcher implements IWebSocket
	{
		private var uri:String;
		private var origin:String;
		private var socket:DukascopyExtensionAndroid;
		private var listenForClose:Boolean = true;
		private var opened:Boolean;
		private var connecting:Boolean;
		static private var instance:AndroidWebSocket;
		private var needReconnectOnClose:Boolean;
		private var needClear:Boolean;
		
		public function AndroidWebSocket(uri:String, origin:String) 
		{
			opened = false;
			this.uri = uri;
			this.origin = origin;
			
			socket = MobileGui.androidExtension;
			socket.addEventListener(StatusEvent.STATUS, statusHandler);
		}
		
		private function statusHandler(e:StatusEvent):void
		{
			var event:Event;
			
			switch (e.code)
			{
				case "webSocket":
				{
					if (e.level == "didOpen")
					{
						connecting = false;
						opened = true;
						event = new WebSocketEvent(WebSocketEvent.OPEN);
						dispatchEvent(event);
					}
					else if (e.level == "didClose")
					{
						connecting = false;
						
						if (needClear == true)
						{
							needClear = false;
							socket.closeWebSocket();
						}
						
						if (needReconnectOnClose == true)
						{
							needReconnectOnClose = false;
							connect("reconnect after close", false);
						}
						else{
							event = new WebSocketEvent(WebSocketEvent.CLOSED);
							dispatchEvent(event);
						}
					}
					else if (e.level == "connectionFail")
					{
						connecting = false;
						event = new WebSocketErrorEvent(WebSocketErrorEvent.CONNECTION_FAIL);
						dispatchEvent(event);
					}
					
					else if (e.level == "ioError")
					{
						connecting = false;
					//	dispatchEvent(event);
					}
					else if (e.level == "sendError")
					{
					//	dispatchEvent(event);
					}
					break;
				}
				case "webSocketMessage":
				{
					event = new WebSocketEvent(WebSocketEvent.MESSAGE);
					(event as WebSocketEvent).message = new WebSocketMessage();
					(event as WebSocketEvent).message.type = WebSocketMessage.TYPE_UTF8;
					(event as WebSocketEvent).message.utf8Data = e.level;
					dispatchEvent(event);
				}
			}
		}
		
		/* INTERFACE com.dukascopy.connect.sys.ws.IWebSocket */
		
		public function isAutoreconnect():Boolean 
		{
			return false;
		}
		
		public function close(waitForServer:Boolean = true, reason:String = null, andClear:Boolean = false):void 
		{
			connecting = false;
			
			if (getReadyState() == WS.STATE_CLOSED && andClear == false)
			{
				return;
			}
			if (getReadyState() == WS.STATE_CLOSING)
			{
				needClear = andClear;
				return;
			}
			
			socket.closeWebSocket();
		}
		
		public function connect(reason:String, anyway:Boolean):void 
		{
			trace("DukascopyExtension socket connect ", connecting, getReadyState() == WS.STATE_CLOSING);
			if (connecting == true)
			{
				return;
			}
			if (getReadyState() == WS.STATE_CLOSING)
			{
				needReconnectOnClose = true;
				return;
			}
			connecting = true;
			socket.connectWebSocket(uri, origin);
		}
		
		/* INTERFACE com.dukascopy.connect.sys.ws.IWebSocket */
		
		public function getReadyState():int 
		{
			return socket.webSocketReadyState();
		}
		
		/* INTERFACE com.dukascopy.connect.sys.ws.IWebSocket */
		
		public function sendUTF(packet:String):void 
		{
			socket.sendWebSocketPacket(packet);
		}
		
		public function sendBytes(ba:ByteArray):void {
			return;
		}
		
		static public function getSocket(urlWsHost:String, origin:String):AndroidWebSocket 
		{
			if (instance == null)
			{
				instance = new AndroidWebSocket(urlWsHost, origin);
			}
			else
			{
				instance.setUrl(urlWsHost);
			}
			return instance;
		}
		
		private function setUrl(urlWsHost:String):void 
		{
			uri = urlWsHost;
		}
		
		/* INTERFACE com.dukascopy.connect.sys.ws.IWebSocket */
		
		public function isConnecting():Boolean 
		{
			return connecting;
		}
		
		
		/* INTERFACE com.dukascopy.connect.sys.ws.IWebSocket */
		
		public function isOpen():Boolean 
		{
			return false;
		}
	}
}