package com.dukascopy.connect.sys.ws {

import com.dukascopy.connect.GD;
import com.dukascopy.connect.MobileGui;
import com.dukascopy.connect.sys.nativeExtensionController.NativeExtensionController;
import com.worlize.websocket.WebSocketEvent;
import com.worlize.websocket.WebSocketMessage;

import connect.DukascopyExtension;

import flash.events.EventDispatcher;
import flash.events.StatusEvent;
import flash.utils.ByteArray;

	/**
	 * ...
	 * @author SergeyDobarin
	 */
	
	public class IosWebSocket extends EventDispatcher implements IWebSocket {
		
		private var uri:String;
		private var origin:String;
		private var socket:DukascopyExtension;
		private var listenForClose:Boolean = true;
		private var opened:Boolean;
		static private var instance:IosWebSocket;
		private var needReconnectOnClose:Boolean;
		private var connecting:Boolean;
		
		public function IosWebSocket(uri:String, origin:String) {
			opened = false;
			this.uri = uri;
			this.origin = origin;
			
			socket = MobileGui.dce;
			socket.addEventListener(StatusEvent.STATUS, statusHandler);
		}
		
		private function statusHandler(e:StatusEvent):void  {
			var event:WebSocketEvent;

			var str:String=("level" in e && e.level!=null)?e.level:"";
			if(e.code=="webSocket")
				GD.S_DEBUG_WS.invoke("IOS: code: " + e.code + ", level: " + str);

			switch (e.code) {
				case "webSocket": {
					
					if (e.level == "didOpen") {
						
						NativeExtensionController.sendToMe("    IOS EVENT " + e.level + " | getReadyState = " + getReadyState());
						
						connecting = false;
						opened = true;
						event = new WebSocketEvent(WebSocketEvent.OPEN);
						dispatchEvent(event);
						MobileGui.S_WS_EVENT.invoke("Open (" + e.code + ")");
					} else if (e.level == "didClose") {
						
						NativeExtensionController.sendToMe("    IOS EVENT " + e.level + " | getReadyState = " + getReadyState());
						
						opened = false;
						connecting = false;
						
						MobileGui.S_WS_EVENT.invoke("Close (" + e.code + ")");
						
						event = new WebSocketEvent(WebSocketEvent.CLOSED);
						dispatchEvent(event);
						
						if (needReconnectOnClose == true)
						{
							needReconnectOnClose = false;
							connect("reconnect after close", false);
						}
						
					} else {
						NativeExtensionController.sendToMe("------------------------- " + e.level);
						MobileGui.S_WS_EVENT.invoke(e.level);
					}
					break;
				}
				case "webSocketMessage": {
					event = new WebSocketEvent(WebSocketEvent.MESSAGE);
					event.message = new WebSocketMessage();
					event.message.type = WebSocketMessage.TYPE_UTF8;
					event.message.utf8Data = e.level;
					dispatchEvent(event);
					break;
				}

				case "webSocketStatus": {
					NativeExtensionController.sendToMe("    IOS EVENT " + e.level + " | getReadyState = " + getReadyState());
					
					if (e.level == "fail")
					{
						opened = false;
						connecting = false;
						
						MobileGui.S_WS_EVENT.invoke("Fail (" + e.code + ")");
						
						event = new WebSocketEvent(WebSocketEvent.CLOSED);
						dispatchEvent(event);
						
						if (needReconnectOnClose == true)
						{
							needReconnectOnClose = false;
							connect("reconnect after fail", false);
						}
					}
					
					break;
				}
			}
		}
		
		public function isAutoreconnect():Boolean {
			return false;
		}
		
		public function close(waitForServer:Boolean = true, reason:String = null, clear:Boolean = false):void {
			
			NativeExtensionController.sendToMe("        ---IOS close request:" + reason + " | getReadyState = " + getReadyState());
			connecting = false;
			if (getReadyState() != 1)
			{
				return;
			}
			MobileGui.S_WS_EVENT.invoke(reason);
			
			NativeExtensionController.sendToMe("        ---IOS close START:" + reason + " | getReadyState = " + getReadyState());
			socket.closeWebSocket();
			GD.S_DEBUG_WS.invoke("IOS: close ws ");
		}
		
		public function connect(reason:String, anyway:Boolean):void {

			GD.S_DEBUG_WS.invoke("IOS: connect");
			if (getReadyState() == 3)
			{
				connecting = false;
				opened = false;
			}
			
			if (connecting == true)
			{
				GD.S_DEBUG_WS.invoke("IOS: can't connect - connecting");
				return;
			}
				
			if (getReadyState() == 2)
			{
				GD.S_DEBUG_WS.invoke("IOS: can't connect - ready state 2");
				/*needReconnectOnClose = true;
				return;*/
			}
			
			if (getReadyState() == 1)
			{
				if (anyway == false)
				{
					GD.S_DEBUG_WS.invoke("IOS: can't connect - connected");
					return;
				}
			}
			
			needReconnectOnClose = false;
			connecting = true;
			
			MobileGui.S_WS_EVENT.invoke("Connecting");
			GD.S_DEBUG_WS.invoke("IOS: do connect "+uri);
			socket.connectWebSocket(uri, origin);

		}
		
		public function getReadyState():int {
			return socket.webSocketReadyState();
		}
		
		public function sendUTF(packet:String):void {
			socket.sendWebSocketPacket(packet);
		}
		
		public function sendBytes(ba:ByteArray):void {
			return;
		}
		
		static public function getSocket(urlWsHost:String, origin:String):IosWebSocket 
		{
			if (instance == null)
			{
				instance = new IosWebSocket(urlWsHost, origin);
			}
			return instance;
		}
		
		/* INTERFACE com.dukascopy.connect.sys.ws.IWebSocket */
		
		public function isConnecting():Boolean 
		{
			return connecting;
		}
		
		
		/* INTERFACE com.dukascopy.connect.sys.ws.IWebSocket */
		
		public function isOpen():Boolean 
		{
			return opened;
		}
	}
}