package com.dukascopy.connect.sys.viManager {
	
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.echo.echo;
	import com.greensock.TweenMax;
	import com.worlize.websocket.WebSocket;
	import com.worlize.websocket.WebSocketErrorEvent;
	import com.worlize.websocket.WebSocketEvent;
	import com.worlize.websocket.WebSocketMessage;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class VIServerConnection {
		
		static public const METHOD_CLIENT:String = "client";
		static public const METHOD_AUTHORIZED:String = "authorized";
		static public const COMMAND:String = "command";
		
		private var onInitialConnect:Function;
		private var onDisconnect:Function;
		private var onMessageFunction:Function;
		private var ws:WebSocket;
		private var chatUID:String;
		private var authorized:Boolean;
		private var closed:Boolean;
		
		public function VIServerConnection(onInitialConnect:Function, onDisconnect:Function, onMessageFunction:Function) {
			this.onInitialConnect = onInitialConnect;
			this.onDisconnect = onDisconnect;
			this.onMessageFunction = onMessageFunction;
		}
		
		public function connect(chatUID:String):void {
			this.chatUID = chatUID;
			TweenMax.delayedCall(2, establishConection);
		}
		
		private function establishConection():void {
			closed = false;
			ws = new WebSocket("ws://172.18.31.108:8090", "TelefisionMobile");
			ws.addEventListener(WebSocketEvent.OPEN, onWSOpened);
			ws.addEventListener(WebSocketEvent.CLOSED, onWSClosed);
			ws.addEventListener(WebSocketEvent.MESSAGE, onWSMessage);
			ws.addEventListener(WebSocketEvent.PING, onWSPing);
			ws.addEventListener(WebSocketEvent.PONG, onWSPong);
			ws.addEventListener(WebSocketErrorEvent.CONNECTION_FAIL, onSocketConnectionFail);
			ws.addEventListener(WebSocketErrorEvent.ABNORMAL_CLOSE, onWSAbnormalClose);
			ws.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			ws.connect();
		}
		
		private function onWSOpened(e:Event):void {
			autorize();
		}
		
		private function autorize():void {
			ws.sendUTF(
				JSON.stringify( {
					method: "client",
					data: {
						key: Auth.key,
						chatUID: chatUID
					}
				} )
			);
		}
		
		private function onWSClosed(e:WebSocketEvent):void {
			authorized = false;
			if (closed == false)
				TweenMax.delayedCall(10, reconnect);
		}
		
		private function reconnect():void {
			TweenMax.killDelayedCallsTo(reconnect);
			connect(chatUID);
		}
		
		private function onWSMessage(e:WebSocketEvent):void {
			if (e is WebSocketEvent == true && e.message.type == WebSocketMessage.TYPE_UTF8) {
				var data:Object = null;
				try {
					data = JSON.parse(e.message.utf8Data);
				} catch (err:Error) {
					echo("VIServerConnection", "onWSMessage", "Error " + err.errorID + " (" + err.name + "): " + err.message, true);
					return;
				}
				if (data != null) {
					echo("VIServerConnection", "onWSMessage");
					parseIncomeData(data);
				}
			}
		}
		
		private function parseIncomeData(data:Object):void {
			if ("method" in data == true && data.method != null) {
				switch (data.method) {
					case METHOD_AUTHORIZED: {
						if ("data" in data == true && data.data == true)
							onConnectionSuccess();
						break;
					}
					case METHOD_CLIENT: {
						break;
					}
					case COMMAND: {
						if ("data" in data == true) {
							onMessage(data.data);
						}
						break;
					}
				}
			}
		}
		
		private function onConnectionSuccess():void {
			if (authorized == true) {
				return;
			}
			authorized = true;
			if (onInitialConnect != null && onInitialConnect.length == 1) {
				onInitialConnect(true);
			}
		}
		
		private function onMessage(message:Object):void {
			trace("VI_SERVER -> onMessage");
			if (onMessageFunction != null && onMessageFunction.length == 1) {
				onMessageFunction(message);
			}
		}
		
		private function onWSPing(e:Event):void {}
		private function onWSPong(e:Event):void {}
		
		private function onSocketConnectionFail(err:WebSocketErrorEvent):void {
			echo("VIServerConnection", "onSocketConnectionFail", "Error " + err.errorID + " (" + err.type + "): " + err.text, true);
			onConnectionFail();
		}
		
		private function onWSAbnormalClose(err:WebSocketErrorEvent):void {
			echo("VIServerConnection", "onWSAbnormalClose", "Error " + err.errorID + " (" + err.type + "): " + err.text, true);
			onConnectionFail();
		}
		
		private function onIOError(err:IOErrorEvent):void {
			echo("VIServerConnection", "onIOError", "Error " + err.errorID + " (" + err.type + "): " + err.text, true);
			onConnectionFail();
		}
		
		private function onConnectionFail():void {
			if (onDisconnect != null && onDisconnect.length == 0) {
				onDisconnect();
			}
			TweenMax.delayedCall(10, reconnect);
		}
		
		public function close():void {
			closed = true;
			onInitialConnect = null;
			onDisconnect = null;
			onMessageFunction = null;
			if (ws != null) {
				try {
					ws.close();
				} catch (err:Error) {
					echo("VIServerConnection", "close", "Error " + err.errorID + " (" + err.name + "): " + err.message, true);
					ApplicationErrors.add();
				}
				ws.removeEventListener(WebSocketEvent.OPEN, onWSOpened);
				ws.removeEventListener(WebSocketEvent.CLOSED, onWSClosed);
				ws.removeEventListener(WebSocketEvent.MESSAGE, onWSMessage);
				ws.removeEventListener(WebSocketEvent.PING, onWSPing);
				ws.removeEventListener(WebSocketEvent.PONG, onWSPong);
				ws.removeEventListener(WebSocketErrorEvent.CONNECTION_FAIL, onSocketConnectionFail);
				ws.removeEventListener(WebSocketErrorEvent.ABNORMAL_CLOSE, onWSAbnormalClose);
				ws.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
				ws = null;
			}
		}
		
		public function sendMessage(message:String):void {
			if (isOnline() == true) {
				echo("VIServerConnection", "sendMessage", message);
				ws.sendUTF(message);
			} else if (onDisconnect != null) {
				onDisconnect();
			}
		}
		
		private function isOnline():Boolean { return ws != null && ws.connected == true; }
	}
}