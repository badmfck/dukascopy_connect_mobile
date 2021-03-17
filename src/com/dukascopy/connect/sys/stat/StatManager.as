package com.dukascopy.connect.sys.stat {
	
	import com.adobe.crypto.MD5;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.menuVideo.OptionSwitcher;
	import com.dukascopy.connect.screens.base.ScreenManager;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.crypter.Crypter;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPLoader;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.sys.store.Store;
	import com.dukascopy.connect.sys.ws.WS;
	import com.greensock.TweenMax;
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.net.URLRequestMethod;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class StatManager {
		
		static private const CRYPT_KEY:String = MD5.hash("Lua3agee Iekow9ie Ob5aevie Waush0vu");
		
		static private const STORE_NAME:String = "firstExecutionTS";
		
		static private var statTime:int = 600000;
		static private var firstTimeTS:Number;
		
		static private var initialized:Boolean = false;
		static private var signalsAdded:Boolean = false;
		
		static private var phpLoader:PHPLoader;
		static private var phpRespond:PHPRespond;
		
		static private var deferredRequests:Array;
		
		public function StatManager() { }
		
		static public function init():void {
			if (initialized == true)
				return;
			initialized = true;
			
			PHP.call_statVI("appStarted", Config.PLATFORM);
			
			if (Auth.newUser == true) {
				firstTimeTS = new Date().getTime();
				Store.save(STORE_NAME, firstTimeTS);
				addSignalListeners();
				return;
			}
			Store.load(STORE_NAME, onStoreRespond);
		}
		
		static private function onStoreRespond(data:Object, err:Boolean):void {
			if (err == true || data == null)
				return;
			firstTimeTS = data as Number;
			checkForStatTime();
		}
		
		static private function checkForStatTime():void {
			if (new Date().getTime() - firstTimeTS > statTime) {
				removeSignalListeners();
				return;
			}
			addSignalListeners();
		}
		
		static private function addSignalListeners():void {
			TweenMax.delayedCall(5, checkForStatTime);
			if (signalsAdded == true)
				return;
			signalsAdded = true;
			
			Auth.S_LOGOUT.add(onLogout);
			Auth.S_NEED_AUTHORIZATION.add(removeSignalListeners);
			WS.S_CONNECTED.add(sendMyInfo);
			WS.S_DISCONNECTED.add(onDisconnected);
			ScreenManager.S_SCREEN_INITED.add(sendScreenClassNameOnWS);
			NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, onActivate);
			NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, onDeativate);
			BitmapButton.S_CLICK.add(onButtonClick);
			OptionSwitcher.S_CLICK.add(onButtonClick);
			
			sendMyInfo(true);
		}
		
		static private function removeSignalListeners():void {
			TweenMax.killDelayedCallsTo(checkForStatTime);
			Store.remove(STORE_NAME);
			
			Auth.S_LOGOUT.remove(onLogout);
			Auth.S_NEED_AUTHORIZATION.remove(removeSignalListeners);
			WS.S_CONNECTED.remove(sendMyInfo);
			WS.S_DISCONNECTED.remove(onDisconnected);
			ScreenManager.S_SCREEN_INITED.remove(sendScreenClassNameOnWS);
			NativeApplication.nativeApplication.removeEventListener(Event.ACTIVATE, onActivate);
			NativeApplication.nativeApplication.removeEventListener(Event.DEACTIVATE, onDeativate);
			BitmapButton.S_CLICK.remove(onButtonClick);
			OptionSwitcher.S_CLICK.remove(onButtonClick);
			
			if (phpRespond != null)
				phpRespond.dispose();
			phpRespond = null;
			phpLoader = null;
		}
		
		static private function onButtonClick(val:String):void {
			sendToHTTP( { uid:Auth.uid, type:"button", action:val } );
		}
		
		static private function onLogout():void {
			sendToHTTP( { uid:Auth.uid, type:"action", action:"logout" } );
		}
		
		static private function onActivate(e:Event):void {
			sendToHTTP( { uid:Auth.uid, type:"action", action:"activate" } );
		}
		
		static private function onDeativate(e:Event):void {
			sendToHTTP( { uid:Auth.uid, type:"action", action:"deactivate" } );
		}
		
		static private function onDisconnected():void {
			sendToHTTP( { uid:Auth.uid, type:"action", action:"disconnect" } );
		}
		
		static private function sendScreenClassNameOnWS(name:String):void {
			name = name.substr(7);
			name = name.substr(0, name.length - 1);
			sendToHTTP( { uid:Auth.uid, type:"screen", action:name } );
		}
		
		static private function sendToHTTP(data:Object):void {
			if (phpLoader == null)
				phpLoader = new PHPLoader();
			if (phpLoader.busy == true) {
				deferredRequests ||= [];
				deferredRequests.push(data);
				return;
			}
			var dta:Object = {
				data:Crypter.crypt(JSON.stringify(data), CRYPT_KEY),
				method:""
			}
			phpLoader.load(Config.URL_PHP_STAT_SERVER, onPhpRespond, dta, URLRequestMethod.POST, null, false, false);
		}
		
		static private function onPhpRespond(phpRespond:PHPRespond):void {
			StatManager.phpRespond = phpRespond;
			if (deferredRequests != null && deferredRequests.length != 0)
				sendToHTTP(deferredRequests.shift());
		}
		
		static public function sendMyInfo(val:Boolean = false):void {
			sendToHTTP( { uid:Auth.uid, phone:Auth.phone, device:Auth.devID, type:"action", action:(val == true) ? "start" : "connect" } );
		}
	}
}