package com.dukascopy.connect.sys.ws {
import com.worlize.websocket.WebSocket;

import flash.events.Event;
import flash.utils.ByteArray;

public class ProxyWS {

        private var ws:WebSocket;
        public function ProxyWS(url:String,origin:String) {
           // ws=new WebSocket("ws://127.0.0.1:8090",origin);
           /* ws.addEventListener(WebSocketEvent.OPEN, onWSOpened);
            ws.addEventListener(WebSocketEvent.CLOSED, onWSClosed);
            ws.addEventListener(WebSocketEvent.MESSAGE, onWSMessage);
            ws.addEventListener(WebSocketEvent.PING, onWSPing);
            ws.addEventListener(WebSocketEvent.PONG, onWSPong);
            ws.addEventListener(WebSocketErrorEvent.CONNECTION_FAIL, onConnectionFail);
            ws.addEventListener(WebSocketErrorEvent.ABNORMAL_CLOSE, onWSAbnormalClose);
            ws.addEventListener(IOErrorEvent.IO_ERROR, onIOError);*/
            //ws.connect();
        }

        public function isAutoreconnect():Boolean {
            return false;
        }

        public  function  isOpen():Boolean{

        }

        public function close(waitForServer:Boolean = true):void {
        }

        public function connect():void {
        }

        public function getReadyState():int {
            return 0;
        }

        public function sendUTF(packet:String):void {
        }

        public function sendBytes(packet:ByteArray):void {

        }

        public function isConnecting():Boolean {
            return false;
        }

        public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void {
        }

        public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void {
        }

        public function dispatchEvent(event:Event):Boolean {
            return false;
        }

        public function hasEventListener(type:String):Boolean {
            return false;
        }

        public function willTrigger(type:String):Boolean {
            return false;
        }
    }
}
