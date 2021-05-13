package com.dukascopy.connect.sys.ws {

	import com.dukascopy.connect.Config;
import com.dukascopy.connect.GD;
import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.connectionManager.NetworkManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.nativeExtensionController.NativeExtensionController;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import com.telefision.sys.signals.Signal;
	import com.worlize.websocket.WebSocket;
	import com.worlize.websocket.WebSocketErrorEvent;
	import com.worlize.websocket.WebSocketEvent;
	import com.worlize.websocket.WebSocketMessage;

	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
import flash.system.Capabilities;
import flash.utils.getTimer;


	/**
	 * @author Igor Bloom.
	 */
	
	public class WS {
		
		static public const S_START_CONNECTING:Signal = new Signal("WS.S_START_CONNECTING");
		static public const S_CONNECTED:Signal = new Signal("WS.S_CONNECTED");
		static public const S_DISCONNECTED:Signal = new Signal("WS.S_DISCONNECTED");
		static public const STATE_CLOSING:int = 2;
		static public const STATE_CLOSED:int = 3;
		
		static private var ws:IWebSocket;
		
		static private var _inited:Boolean;
		static private var _connected:Boolean;
		static private var _connecting:Boolean;
		
		static private var loopDelay:int = 60 * 5; //fps * sec
		static private var pingDelay:Number = 1000 * 15; //fps * sec
		static private var loopCount:int = 0; 
		static private var lastMessageTime:Number = 0;

		static private var currentHost:String=null;
		static private var hostReachable:Boolean=false;
		static private var sendStat:Boolean=true;

		static public function init():void {
			if (_inited == true)
				return;
			_inited = true;
			Auth.S_AUTHORIZED.add(onAuthSuccess);
			Auth.S_NEED_AUTHORIZATION.add(onNeedAuthorization);
			WSClient.S_AUTHORIZED.add(onWSAuthorized);
			WSClient.S_AUTHORIZED_ERROR.add(onWSAuthorizedError);
			NetworkManager.S_CONNECTION_CHANGED.add(onConnectionChanged);
			NetworkManager.S_CONNECTION_UPDATED.add(onConnectionUpdated);
			TweenMax.delayedCall(loopDelay/60, checkConnection);
			PHP.S_COMPLETE.add(onPhpAnyRequestSuccess);
			
			NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, onActivate);
			NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, onDeativate);
		}

        static private function onDeativate(e:Event):void{
        //    hostReachable=false;
			sendStat=true;
        }

		static private function onActivate(e:Event):void 
		{
			lastMessageTime = getTimer();
		}
		
		static private function onAuthSuccess():void {
			connect(false, "onAuthSuccess");
		}
		
		static private function onPhpAnyRequestSuccess():void {
			if (canConnect() == false)
				return;
			if (_connected == false && _connecting == false && Auth.key != "web")
			{
				connect(false, "onPhpAnyRequestSuccess");
			}
		}
		
		static private function canConnect():Boolean 
		{
			if (allowGuestConnection == true && Auth.key == "web")
			{
				return true;
			}
			else if (Auth.isAuthorized == false || Auth.key == null || Auth.key.length < 20)
			{
				return false;
			}
			else
			{
				return true;
			}
		}
		
		static private function onNeedAuthorization():void {
			onClose("onNeedAuthorization", false);
		}
		
		static private function checkConnection():void {
			TweenMax.killDelayedCallsTo(checkConnection);
			TweenMax.delayedCall(loopDelay/60, checkConnection);
			if (canConnect() == false)
				return;
			if (getTimer() - lastMessageTime >= pingDelay) {
				echo("WS", "checkConnection", "Probably dead, NetworkManager.isConnected=" + NetworkManager.isConnected);
				if (NetworkManager.isConnected == true)
				{
					connect(true, "checkConnection");
				}
			}
		}
		
		static private function connect(ignoreCurrentConnection:Boolean = false, reason:String = ""):void {

			GD.S_DEBUG_WS.invoke("C: connect, ignore current:"+ignoreCurrentConnection+", reason: "+reason);

			if (canConnect() == false) {
				GD.S_DEBUG_WS.invoke("C: Can't connect - no auth key");
				return;
			}
			
			var text:String = "";
			
			if (_connecting) {
				startTimeout();
				GD.S_DEBUG_WS.invoke("C: Can't connect - already connecting");
				return;
			}

			
			if (ws != null)
			{
				echo("WS", "connect", "getReadyState=" + ws.getReadyState() + " ignoreCurrentConnection=" + ignoreCurrentConnection);

				if (ws.getReadyState() == 0){
					GD.S_DEBUG_WS.invoke("C: Can't connect - ready state 0");
					return;
				}
				
				if (ignoreCurrentConnection == false && ws.getReadyState() == 1){
					GD.S_DEBUG_WS.invoke("C: Can't connect - connecting, ready state 1");
					return;
				}
				

				/*if (ws.getReadyState() == 2){
					if(!Config.PLATFORM_APPLE) {
						GD.S_DEBUG_WS.invoke("C: Can't connect - closing, ready state 2");
						return;
					}
				}*/

			}
			
			if ( NetworkManager.isConnected == false)
			{
				GD.S_DEBUG_WS.invoke("C: no network");
				return;
			}
			
			clearTimeout();
			if (ws != null)
			{
				GD.S_DEBUG_WS.invoke("C: closing prew");
				ws.close(false, "close on connect call");
			}
			_connecting = true;
			_connected = false;
			if (ws == null)
			{
				createSocket();
			}
			
			MobileGui.S_WS_EVENT.invoke("Connecting to WS");
			S_START_CONNECTING.invoke();
			GD.S_DEBUG_WS.invoke("C: do connect");
			ws.connect("main connect", ignoreCurrentConnection);

		}
		
		static private function createSocket():void 
		{


			ws = getWebSocket();

			ws.addEventListener(WebSocketEvent.OPEN, onWSOpened);
			ws.addEventListener(WebSocketEvent.CLOSED, onWSClosed);
			ws.addEventListener(WebSocketEvent.MESSAGE, onWSMessage);
			ws.addEventListener(WebSocketEvent.PING, onWSPing);
			ws.addEventListener(WebSocketEvent.PONG, onWSPong);
			ws.addEventListener(WebSocketErrorEvent.CONNECTION_FAIL, onConnectionFail);
			ws.addEventListener(WebSocketErrorEvent.ABNORMAL_CLOSE, onWSAbnormalClose);
			ws.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
		}
		
		static private function startTimeout():void {
			clearTimeout();
			TweenMax.delayedCall(5, onConnectingTimeout);
		}
		
		static private function clearTimeout():void {
			TweenMax.killDelayedCallsTo(onConnectingTimeout);
		}
		
		static private function onConnectingTimeout():void {
			/*MobileGui.S_WS_EVENT.invoke("Connecting timeout");
			if (_connecting == true) {
				_connecting = false;
				connect(true);
			}*/
			connect(false, "onConnectingTimeout");
		}
		
		static private function onWSSHostResponse(phpRespond:PHPRespond):void {
			
		}
		
		static private function getWebSocket():IWebSocket {


			if(currentHost==null)
				currentHost=Config.URL_WS_HOST_1;
			else {
				if (hostReachable == false) {
					if (currentHost == Config.URL_WS_HOST_1)
						currentHost = Config.URL_WS_HOST_2;
					else
						currentHost = Config.URL_WS_HOST_1
				}
			}

			if(!Config.PLATFORM_APPLE && !Config.PLATFORM_ANDROID ){
				if (!Config.isTest())
				{
					currentHost="ws://ws.site.dukascopy.com:8080";
				}
			}


			GD.S_DEBUG_WS.invoke("G: get websocket, url: "+currentHost);

			if (Config.PLATFORM_APPLE)
				return IosWebSocket.getSocket(currentHost, "TelefisionMobile");
			else if (Config.PLATFORM_ANDROID)
				return AndroidWebSocket.getSocket(currentHost, "TelefisionMobile");
			return new WebSocket(currentHost,"TelefisionMobile");

		}
		
		static private function onWSOpened(e:Event):void {
			echo("WS", "onWSOpened");
			hostReachable = true;
			MobileGui.S_WS_EVENT.invoke("WS Opened");
			clearTimeout();
			WSClient.call_authorize(Auth.key);
			NetworkManager.checkConnection();
			NetworkManager.S_CONNECTION_CHANGED.invoke();
		}
		
		static private function onWSAuthorized():void {
			echo("WS", "onWSAuthorized");
			MobileGui.S_WS_EVENT.invoke("WS Authorized");
			_connected = true;
			_connecting = false;
			S_CONNECTED.invoke();
		}
		
		static private function onWSClosed(e:WebSocketEvent):void {
			_connected = false;
			_connecting = false;
			MobileGui.S_WS_EVENT.invoke("Closed (" + ((e != null && e.message != null) ? e.message : "") + ")");
			/*if (Config.PLATFORM_APPLE == false)
			{
				clearTimeout();
				onClose("onWSClosed event " + ((e != null && e.message != null) ? e.message.utf8Data : "! " + e));
			}*/
		}
		
		/**
		 * DO NOT USE!!!! Ilya Shcherbakov 12.06.2020
		 * ONLY FOR TF USERS
		 */
		static public function closeByUser():void {
			onClose("Close By User");
			connect(true, "closeByUser");
		}
		
		static private function onClose(reason:String, clear:Boolean = false):void {
			echo("WS", "onClose", reason);
			NativeExtensionController.sendToMe("onClose reason=" + reason);
			var connectedOld:Boolean = _connected;
			_connecting = false;
			_connected = false;
			clearTimeout();
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
					ws.close(true, reason, clear);
				} catch (err:Error) {
					echo("WS", "disconnect", "Error. ID: " + err.errorID + "; Message: " + err.message, true);
				}
				if (connectedOld == true)
					S_DISCONNECTED.invoke();
			}
			ws = null;

			if(sendStat) {
				sendStat=false;
				sendVIStat("Close: " + reason);
			}
		}
		
		static private function onConnectionChanged(ignoreCurrentConnection:Boolean = false):void {
			clearTimeout();
			echo("WS", "onConnectionChanged", "Online: " + NetworkManager.isConnected);
			MobileGui.S_WS_EVENT.invoke("Connection changed (NET: " + NetworkManager.isConnected+"), icc: "+ignoreCurrentConnection);
			if (NetworkManager.isConnected == false) {
				onClose(" close onConnectionChanged");
				return;
			}
			if (canConnect() == false) {
				echo("WS", "onConnectionChanged", "No auth key");
				return;
			}
			connect(ignoreCurrentConnection, "onConnectionChanged");
		}
		
		static private function onConnectionUpdated():void {
			
			echo("WS", "onConnectionUpdated", "Online: " + NetworkManager.isConnected);
			if (NetworkManager.isConnected == true) {
				clearTimeout();
				connect(false, "onConnectionUpdated");
			}
		}
		
		static private function onIOError(e:IOErrorEvent):void {
			clearTimeout();
			MobileGui.S_WS_EVENT.invoke("IO Error");
			echo("WS", 'onIOError');
			hostReachable = false;
			onClose("close onIOError", true);
			startTimeout();
		}
		
		static private function onConnectionFail(e:Event):void {
			_connecting = false;
			_connected = false;
			clearTimeout();
			MobileGui.S_WS_EVENT.invoke("Connection Failed (" + ((e != null && e.type != null) ? e.type : "") + ")");
			echo("WS", "onConnectionFail");
			hostReachable = false;
			onClose("close onConnectionFail", true);
			startTimeout();
		}
		
		static private function onWSAbnormalClose(e:Event):void {
			_connecting = false;
			_connected = false;
			clearTimeout();
			MobileGui.S_WS_EVENT.invoke("Abnormal Close (" + ((e != null && e.type != null) ? e.type : "") + ")");
			echo("WS", "onWSAbnormalClose");
			hostReachable = false;
			onClose("close onWSAbnormalClose", true);
			startTimeout();
		}
		
		static private function onWSAuthorizedError(err:String):void {
			_connecting = false;
			MobileGui.S_WS_EVENT.invoke("Auth Error (" + err + ")");
			echo("WS", "onWSAuthorizedError", "Error: " + err);
			DialogManager.alert(Lang.textError, err);
			Auth.clearAuthorization(err);
			_connected = false;
		}
		
		static public function send(method:String, data:Object):Boolean {
			if (ws == null) {
				echo("WS", "send", "WS is null; Method: " + method);
				return false;
			}
			if (ws.getReadyState() != 1) {
				echo("WS", "send", "WS ready state wrong (" + ws.getReadyState() + "); Method: " + method);
				return false;
			}
			if (method == 'msgAdd') {
				if (_connected == false)
					return false;
				if (data == null)
					return false;
				if (!("chatUID" in data))
					return false;
			}
			var packet:String = JSON.stringify( { method:method, data:data } );
			ws.sendUTF(packet);
			return true;
		}
		
		static public function connectAsGuest():void 
		{
			allowGuestConnection = true;
			connect();
		}
		
		static public function disableGuestConnection():void
		{
			allowGuestConnection = false;
		}

		static private function onWSMessage(e:WebSocketEvent):void {
			clearTimeout();
			lastMessageTime = getTimer();
			if (e is WebSocketEvent && e.message.type == WebSocketMessage.TYPE_UTF8) {
				var data:Object = null;
				try {
					data = JSON.parse(e.message.utf8Data);
				} catch (err:Error) {
					echo("WS", "onWSMessage",'Can not parse JSON');
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


		static private var __ts:Number=0;
		static private var allowGuestConnection:Boolean;
		static private function sendVIStat(str:String):void{

		}

		/*static public function disconnectByUser():void {
			PHP.S_COMPLETE.remove(onPhpAnyRequestSuccess);
			Loop.remove(onWSCheck);
			onClose();
		}
		
		static public function connectByUser():void {
			PHP.S_COMPLETE.add(onPhpAnyRequestSuccess);
			Loop.add(onWSCheck);
		}*/
	}
}