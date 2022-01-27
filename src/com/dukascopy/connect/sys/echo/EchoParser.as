package com.dukascopy.connect.sys.echo {
	
	import com.dukascopy.connect.Config;
import com.dukascopy.connect.GD;
import com.dukascopy.connect.MobileGui;
import com.dukascopy.dccext.DCCExt;
import com.dukascopy.dccext.DCCExtCommand;
import com.dukascopy.dccext.DCCExtMethod;
import com.dukascopy.dukascopyextension.DukascopyExtensionAndroid;
import com.greensock.TweenMax;
import com.worlize.websocket.WebSocket;
import com.worlize.websocket.WebSocketEvent;

import flash.display.Sprite;

import flash.display.Stage;
import flash.events.ErrorEvent;
import flash.events.IOErrorEvent;
import flash.system.Capabilities;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author ...
	 */
	
	public class EchoParser {
		
		static private var stage:Stage;
		static private var tf:TextField;
		static private var str:String;
		static private var _stock:Array = [];
		static private var remoteDebugger:WebSocket=null;
		static private var isInitialized:Boolean=false;
		static private var connectionRetries:int=0;
		static private var maxConnectionRetries:int=10;

		static private var isShown:Boolean=false;

		static private var btnClose:Sprite;
		static private var btnBitmaps:Sprite;


		public static function init(stage:Stage=null):void {
			EchoParser.stage = stage;

			GD.S_SHOW_SYSTEM_TRACE.add(function():void{
				if(!isShown) {
					if (stage != null) {
						if (tf == null) {
							tf = new TextField();
							tf.defaultTextFormat = new TextFormat("Tahoma", Config.FINGER_SIZE_DOT_25);
							tf.mouseEnabled = false;
							tf.mouseWheelEnabled = false;
							tf.backgroundColor = 0;
							tf.background = true;
							tf.alpha = .7;
							tf.textColor = 0xFFFFFF;
							tf.y = Config.FINGER_SIZE_DOT_75 * 3;
							tf.x = 0;
							tf.width = stage.stageWidth;
							tf.height = stage.stageHeight - Config.FINGER_SIZE_DOT_75 * 3;
							tf.wordWrap = true;
						}
						stage.addChild(tf);
						showTraceInTF();
						isShown=true;
					}
				}else{
					isShown=false;
					if(tf.parent)
						tf.parent.removeChild(tf);
				}
			})

			/**/


		}

		private static function connectToDebugger():void{

			/*if(remoteDebugger){
				remoteDebugger.removeEventListener(WebSocketEvent.OPEN, onDebuggerOpen);
				remoteDebugger.removeEventListener(WebSocketEvent.CLOSED, onDebuggerClosed);
				remoteDebugger.removeEventListener(WebSocketEvent.MESSAGE, onDebuggerMessage);
				remoteDebugger.removeEventListener(IOErrorEvent.IO_ERROR, onDebuggerError);
				remoteDebugger.close();
			}

			remoteDebugger=new WebSocket(Config.URL_REMOTE_DEBUGGER,"DCC");

			remoteDebugger.addEventListener(WebSocketEvent.OPEN, onDebuggerOpen);
			remoteDebugger.addEventListener(WebSocketEvent.CLOSED, onDebuggerClosed);
			remoteDebugger.addEventListener(WebSocketEvent.MESSAGE, onDebuggerMessage);
			remoteDebugger.addEventListener(IOErrorEvent.IO_ERROR, onDebuggerError);

			remoteDebugger.connect("Remote debugger");*/
		}

		private static function onDebuggerOpen(e:WebSocketEvent):void{
			remoteDebugger.sendUTF("HELLO");
		}

		private static function onDebuggerClosed(e:WebSocketEvent):void{
			TweenMax.delayedCall(10,function ():void {
				connectionRetries++;
				if(connectionRetries>maxConnectionRetries){
					connectionRetries=0;
					return;
				}
				connectToDebugger();
			})
		}

		private static function onDebuggerError(e:ErrorEvent):void{
			trace(e.toString());
		}

		private static function onDebuggerMessage(e:WebSocketEvent):void{

		}

		public static function pewPrew(target:String, method:String, data:*,error:Boolean,line:int):void {

			if(!isInitialized){
				isInitialized=true;
				if(Config.isTF() || Capabilities.isDebugger)
					connectToDebugger();
			}

			if (data == null)
				data = "null";
			if ("toString" in data)
				data = data.toString();
			if (!(data is String))
				data = data + "";
			if (target == null)
				target = "UNKNOWN";
			if (method == null)
				method = "UNKNOWN";
			var d:Date = new Date();
			var h:String = d.getHours().toString();
			if (h.length == 1)
				h = "0" + h;
			var m:String = d.getMinutes().toString();
			if (m.length == 1)
				m = "0" + m;
			var s:String = d.getSeconds().toString();
			if (s.length == 1)
				s = "0" + s;
			str ="| "+h+":"+m+":"+s+" | "+((error==true)?"{color:red}ERR{color} | ":"LOG | ")+ target + " | " + method + " | " + data+" |";

			if (Capabilities.isDebugger)
				trace(str);


			if(Config.PLATFORM_APPLE && Config.APPLE_LOG==true){
				if(DCCExt.isContextCreated()){
					DCCExt.call(new DCCExtCommand(DCCExtMethod.LOG, {
						text:str
					} ))
				}
			}
			else if(Config.PLATFORM_ANDROID && Config.ANDROID_LOG==true){
				if (MobileGui.androidExtension != null){
					MobileGui.androidExtension.log(str);
				}
			}


			if(remoteDebugger && remoteDebugger.connected){
				try{
					remoteDebugger.sendUTF(str);
				}catch (e:Error) {}
			}

			_stock.push(str);
			if (_stock.length > 50)
				_stock.shift();
			
			if (tf != null && stage != null) {
				showTraceInTF();
			}
		}

		static private function showTraceInTF():void{
			if(tf==null || tf.stage==null)
				return;
			var txt:String="";
			for(var i:int=0;i<_stock.length;i++){
				if(i>0)
					txt+="\n";
				txt+=_stock[i];
			}
			tf.text=txt;
			tf.scrollV=tf.maxScrollV;
		}
		
		static public function clearStock():void{
			_stock = [];
		}


		public static function get lastMessage():String {
			if (_stock != null && _stock.length > 1)
				return _stock[_stock.length - 2];
			return "";
		}
	}
}