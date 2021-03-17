package com.dukascopy.connect.sys.ws {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.connectionManager.NetworkManager;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.telefision.sys.signals.Signal;
	import com.telefision.utils.Loop;
	import com.worlize.websocket.WebSocket;
	import com.worlize.websocket.WebSocketErrorEvent;
	import com.worlize.websocket.WebSocketEvent;
	import com.worlize.websocket.WebSocketMessage;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	
	/**
	 * @author Igor Bloom.
	 */
	
	public class WSNew {
		
		static public const S_START_CONNECTING:Signal = new Signal("WS.S_START_CONNECTING");
		static public const S_CONNECTED:Signal = new Signal("WS.S_CONNECTED");
		static public const S_DISCONNECTED:Signal = new Signal("WS.S_DISCONNECTED");
		
		static private var ws:IWebSocket;
		
		static private var _inited:Boolean;
		static private var _connected:Boolean;
		static private var _connecting:Boolean;
		
		static private var loopDelay:int = 60 * 5; //fps * sec
		static private var pingDelay:Number = 1000 * 15; //fps * sec
		static private var loopCount:int = 0; 
		static private var lastMessageTime:Number = 0;
		
		static public function init():void {
			if (_inited == true)
				return;
			_inited = true;
			Auth.S_AUTHORIZED.add(connect);
			Auth.S_NEED_AUTHORIZATION.add(onNeedAuthorization);
			NetworkManager.S_CONNECTION_CHANGED.add(onConnectionChanged);
			Loop.add(onWSCheck);
			PHP.S_COMPLETE.add(onPhpAnyRequestSuccess);
		}
		
		static private function onPhpAnyRequestSuccess():void {
			if (Auth.key == null || Auth.key.length < 20)
				return;
			if (_connected == false && _connecting == false)
				connect();
		}
		
		static private function onNeedAuthorization():void {
			onClose();
		}
		
		static private function onWSCheck(...rest):void {
			loopCount++;
			if (loopCount >= loopDelay) {
				loopCount = 0;
				if (Auth.key == null || Auth.key.length < 20)
					return;
				if (getTimer() - lastMessageTime >= pingDelay) {
					if (NetworkManager.isConnected == true)
						onConnectionChanged();
				}
			}
		}
		
		static private function connect():void {
			if (Auth.countryCode == 41) {
				Auth.S_AUTHORIZED.remove(connect);
				Auth.S_NEED_AUTHORIZATION.remove(onNeedAuthorization);
				NetworkManager.S_CONNECTION_CHANGED.remove(onConnectionChanged);
				Loop.remove(onWSCheck);
				PHP.S_COMPLETE.remove(onPhpAnyRequestSuccess);
				return;
			}
			if (_connecting)
				return;
			if (ws != null)
				onClose();
			
			_connecting = true;
			_connected = false;
			ws = getWebSocket();
			ws.addEventListener(WebSocketEvent.OPEN, onWSOpened);
			ws.addEventListener(WebSocketEvent.CLOSED, onWSClosed);
			ws.addEventListener(WebSocketEvent.MESSAGE, onWSMessage);
			ws.addEventListener(WebSocketEvent.PING, onWSPing);
			ws.addEventListener(WebSocketEvent.PONG, onWSPong);
			ws.addEventListener(WebSocketErrorEvent.CONNECTION_FAIL, onConnectionFail);
			ws.addEventListener(WebSocketErrorEvent.ABNORMAL_CLOSE, onWSAbnormalClose);
			ws.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			ws.connect();
			S_START_CONNECTING.invoke();
		}
		
		static private function onWSSHostResponse(phpRespond:PHPRespond):void {
			
		}
		
		static private function getWebSocket():IWebSocket {
			if (Config.PLATFORM_WINDOWS == true)
				return new WebSocket("ws://172.18.31.100:8090", "DCConnect911");
			return null;
		}
		
		static private function onWSOpened(e:Event):void {
			WSNewClient.authorize(Auth.key);
			WSNewClient.ticketAdd(133);
		}
		
		static private function onWSAuthorized():void {
			_connected = true;
			_connecting = false;
			S_CONNECTED.invoke();
		}
		
		static private function onWSClosed(e:Event):void {
			onClose();
		}
		
		static private function onClose():void {
			var connectedOld:Boolean = _connected;
			_connecting = false;
			_connected = false;
			if (ws != null) {
				ws.removeEventListener(WebSocketEvent.OPEN, onWSOpened);
				ws.removeEventListener(WebSocketEvent.CLOSED, onWSClosed);
				ws.removeEventListener(WebSocketEvent.MESSAGE, onWSMessage);
				ws.removeEventListener(WebSocketEvent.PING, onWSPing);
				ws.removeEventListener(WebSocketEvent.PONG, onWSPong);
				ws.removeEventListener(WebSocketErrorEvent.CONNECTION_FAIL, onConnectionFail);
				ws.removeEventListener(WebSocketErrorEvent.ABNORMAL_CLOSE, onWSAbnormalClose);
				ws.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
				try {
					ws.close();
				} catch (err:Error) {
				}
				if (connectedOld == true)
					S_DISCONNECTED.invoke();
			}
			ws = null;
		}
		
		static private function onConnectionChanged():void {
			if (NetworkManager.isConnected == false) {
				onClose();
				return;
			}
			if (Auth.key == null || Auth.key.length < 20) {
				return;
			}
			connect();
		}
		
		static private function onIOError(e:IOErrorEvent):void {
			onClose();
		}
		
		static private function onConnectionFail(e:Event):void {
			onClose();
		}
		
		static private function onWSAbnormalClose(e:Event):void {
			onClose();
		}
		
		static private function onWSAuthorizedError(err:String):void {
			_connected = false;
			_connecting = false;
		}
		
		static public function send(ba:ByteArray):Boolean {
			if (ws == null) {
				return false;
			}
			if (ws.getReadyState() != 1) {
				return false;
			}
			if (NetworkManager.isConnected == false) {
				return false;
			}
			ws.sendBytes(ba);
			return true;
		}
		
		static private function onWSMessage(e:WebSocketEvent):void {
			lastMessageTime = getTimer();
			if (e is WebSocketEvent && e.message.type == WebSocketMessage.TYPE_UTF8) {
				var data:Object = null;
				try {
					data = JSON.parse(e.message.utf8Data);
				} catch (err:Error) {
					return;
				}
				if (data != null)
					WSClient.handlePacket(data);
			}
		}
		
		static private function onWSPing(e:Event):void {}
		static private function onWSPong(e:Event):void {}
		
		static public function get connected():Boolean{
			return _connected;
		}
	}
}