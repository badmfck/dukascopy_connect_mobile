package com.dukascopy.connect.sys.connectionManager {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.sys.nativeExtensionController.NativeExtensionController;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.greensock.TweenMax;
	import com.telefision.sys.signals.Signal;
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import com.dukascopy.dccext.DCCExt;
	import com.dukascopy.dccext.dccNetWatcher.DCCNetStatus;
	import com.dukascopy.dccext.dccNetWatcher.DCCNetWatcher;
	import com.dukascopy.connect.GD;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	/**
	 * 
	 * @author Igor Bloom.
	 */
	
	public class NetworkManager {
		
		public static var S_CONNECTION_CHANGED:Signal = new Signal("NetworkManager.S_CONNECTION_CHANGED");
		public static var S_CONNECTION_UPDATED:Signal = new Signal("NetworkManager.S_CONNECTION_UPDATED");
		
		static private var isOnline:Boolean = false;
		static private var iosNetworkType:String="";
		
		static public var timeDifference:Number;
		
		public function NetworkManager() { }
		
		public static function init():void {

			GD.S_LOG.invoke("NetworkManager init")

			GD.S_REQUEST_NET_STATUS.add(function(callback:Function):void{
				if(callback!=null && callback is Function && callback.length==1)
					callback(isConnected)
			})


			// DEBUG
			if(Config.PLATFORM_WINDOWS){
				 NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_DOWN,function(e:KeyboardEvent):void{
					 var s:DCCNetStatus=new DCCNetStatus();
					if((e.controlKey || e.ctrlKey) && e.keyCode==Keyboard.E){
						// EMULATE NETWORK ON
						isOnline=true;
						S_CONNECTION_CHANGED.invoke();
						
						s=new DCCNetStatus()
						s.setStatus({
							status:"online",
							net:"wifi"
						});
						s.updateInternetAccessStatus(true);
						GD.S_NETWORK_STATUS.invoke(s);
						e.preventDefault();
						return;
					}
					
					if((e.controlKey || e.ctrlKey) && e.keyCode==Keyboard.R){
						// EMULATE NETWORK OFF
						isOnline=false;
						S_CONNECTION_CHANGED.invoke();
						s=new DCCNetStatus()
						s.setStatus({
							status:"offline",
							net:"unknown"
						});
						s.updateInternetAccessStatus(false);
						GD.S_NETWORK_STATUS.invoke(s);
						e.preventDefault();
						return;
					}
				})
			}
			// EOF DEBUG

			if (Config.PLATFORM_APPLE) {
				if(!DCCExt.isContextCreated())
					return;

				DCCNetWatcher.init();
            	DCCNetWatcher.addNetStatusEvent(onIOSNetStatus);
            	DCCNetWatcher.requestStatus();
				DCCNetWatcher.registrateInternetCheckerURL("https://dccapi.dukascopy.com/?key=web&method=auth.serverTime");
				
				// REGISTRATE INTERNET ACTIVITY
				GD.S_HTTP_REQUEST_COMPLETED.add(function(...rest):void{
	                DCCNetWatcher.registrateInternetActivity();
            	})

				return;
			}

			if (Config.PLATFORM_ANDROID == true){
				NativeExtensionController.S_NETWORK.add(onAndroidNetworkChange);
				NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, onActivate);
			}
		}
		
		static private function onActivate(e:Event):void{
			var oldStatus:Boolean = isOnline;
			checkConnection();
			if (oldStatus == false && isOnline == true){
				S_CONNECTION_CHANGED.invoke();
			}else{
				checkPHP();
			}
		}
		
		static private function onAndroidNetworkChange(connected:Boolean):void {
			/*if (Config.isTF() == true)
				ToastMessage.display("Connected: " + connected);*/
			if (isOnline == connected)
			{
				S_CONNECTION_UPDATED.invoke();
			}
			else{
				isOnline = connected;
				S_CONNECTION_CHANGED.invoke();
			}
			if (connected == false)
			{
				checkPHP();
			}
		}
		
 		
		 
		static private function onIOSNetStatus(stat:DCCNetStatus):void{
            // ON STATUS EVENT
			isOnline=stat.internet==DCCNetStatus.INTERNET_STATUS_AVAILABLE;
			iosNetworkType=stat.network;
			S_CONNECTION_CHANGED.invoke();
			GD.S_NETWORK_STATUS.invoke(stat);
        }
		



		
		static private function checkPHP():void {
			
			TweenMax.killDelayedCallsTo(checkPHP);

			PHP.call_ping(function(r:PHPRespond):void {
				if (r.errorMsg == PHP.NETWORK_ERROR) {
					TweenMax.delayedCall(5, checkPHP);
					isOnline = false;
					r.dispose();
					return;
				}
				timeDifference = Number(r.data) - (int(new Date().getTime() / 1000));
				if (isOnline == false)
				{
					isOnline = true;
					S_CONNECTION_CHANGED.invoke();
				}
				
				r.dispose();
			});
		}
		
		/**
		 * DEPRECATED!
		 */
		static public function checkConnection():void {
			isOnline = true;
			
			if (Config.PLATFORM_APPLE)
				isOnline = DCCNetWatcher.getStatus().internet==DCCNetStatus.INTERNET_STATUS_AVAILABLE;

			if (Config.PLATFORM_ANDROID == true)
				isOnline = getNetworkType() != 0;
		}
		
		public static function getNetworkType():int {

			if (Config.PLATFORM_ANDROID == true) {
				var nativeType:int = MobileGui.androidExtension.getNetworkType();
				if (nativeType == 1)
					return 1; // WIFI
				else if (nativeType == 0)
					return 2; // MOBILE
				return 0;
			}
			
			var networkType:int = 1;

			if (Config.PLATFORM_APPLE == true) {
				networkType=0;
				if(iosNetworkType=="wwan")
					networkType=2;
				if(iosNetworkType=="wifi")
					networkType=1;
			}

			return networkType;
		}
		
		static public function reconnect():void {
			if (Config.PLATFORM_APPLE == true)
				return;
			if (isOnline == false)
				checkPHP();
		}
		
		public static function get isConnected():Boolean {
			if(Config.PLATFORM_APPLE)
				isOnline = DCCNetWatcher.getStatus().internet==DCCNetStatus.INTERNET_STATUS_AVAILABLE;
			return isOnline;
		}
	}
}