package com.dukascopy.connect.sys.connectionManager {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.nativeExtensionController.NativeExtensionController;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.greensock.TweenMax;
	import com.milkmangames.nativeextensions.CMNetworkType;
	import com.milkmangames.nativeextensions.CoreMobile;
	import com.milkmangames.nativeextensions.events.CMNetworkEvent;
	import com.telefision.sys.signals.Signal;
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	
	/**
	 * 
	 * @author Igor Bloom.
	 */
	
	public class NetworkManager {
		
		public static var S_CONNECTION_CHANGED:Signal = new Signal("NetworkManager.S_CONNECTION_CHANGED");
		public static var S_CONNECTION_UPDATED:Signal = new Signal("NetworkManager.S_CONNECTION_UPDATED");
		
		static private var isOnline:Boolean = false;
		
		static public var timeDifference:Number;
		
		public function NetworkManager() { }
		
		public static function init():void {
			if (Config.PLATFORM_APPLE) {
				if (CoreMobile.isSupported() == false)
					return;
				CoreMobile.create();
				CoreMobile.mobile.addEventListener(CMNetworkEvent.NETWORK_REACHABILITY_CHANGED, onNetworkChanged);
			}
			if (Config.PLATFORM_ANDROID == true)
				NativeExtensionController.S_NETWORK.add(onAndroidNetworkChange);
			onNetworkChanged();
			NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, onActivate);
		}
		
		static private function onActivate(e:Event):void 
		{
			var oldStatus:Boolean = isOnline;
			checkConnection();
			if (oldStatus == false && isOnline == true)
			{
				S_CONNECTION_CHANGED.invoke();
			}
			else
			{
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
		
		static private function onNetworkChanged(e:CMNetworkEvent = null):void {
			checkConnection();
			if (isOnline == false) {
				TweenMax.killDelayedCallsTo(checkPHP);
				S_CONNECTION_CHANGED.invoke();
				return;
			}
			checkPHP();
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
		
		static public function checkConnection():void {
			isOnline = true;
			if (Config.PLATFORM_APPLE)
				isOnline = (CoreMobile.mobile.getNetworkType() != CMNetworkType.NONE);
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
			var networkType:int = -1;
			if (Config.PLATFORM_APPLE == true) {
				try {
					networkType = CoreMobile.mobile.getNetworkType();
				} catch (err:Error) {
					echo("NetworkManager", "getNetworkType", "Error: " + err.message)
				}
			}
			return networkType;
		}
		
		static public function reconnect():void {
			if (isOnline == false)
				checkPHP();
		}
		
		public static function get isConnected():Boolean {
			return isOnline;
		}
	}
}