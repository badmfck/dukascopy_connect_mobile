package com.dukascopy.connect.sys.php {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.sys.echo.echo;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	/**
	 * ...
	 * @author Pavel Karpov then Aleksei L (Уёбок)
	 */
	
	public class SimpleDataLoader {
		
		private const LANG_URL_PART1:String = "out/dcc_lang/";
		private const LANG_URL_PART2:String = ".json?v=";
		
		private var _completeHandler:Function;
		private var _errorHandler:Function;
		private var _urlLoader:URLLoader;
		private var arrParts:Array = ["mobile", "common", "payments", "refCodes", "BankBot"];
		private var data:Object;
		private var _tempID:String;
		private var tempKey:String = "";
		
		public function SimpleDataLoader(tempID:String, completeCallBack:Function, errorCallBack:Function) {
			_tempID = tempID;
			_completeHandler = completeCallBack;
			_errorHandler = errorCallBack;
			
			data = {};
			
			_urlLoader = new URLLoader();
			_urlLoader.addEventListener(IOErrorEvent.IO_ERROR, loaderError);
			_urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, loaderError);
			_urlLoader.addEventListener(Event.COMPLETE, loadComlete);
			loadNext();
		}
		
		private function loadNext():void {
			var url:String;
			var num:Number = Math.random();
			if (arrParts.length > 0) {
				tempKey = arrParts.pop() as String;
				url = Config.URL_LANG + LANG_URL_PART1 + tempKey  + "/" + _tempID + LANG_URL_PART2 + num;
				_urlLoader.load(new URLRequest(url));
			} else {
				loaderError();
			}
		}
		
		private function loaderError(e:Event = null):void {
			clearAllListeners();
			if (_errorHandler != null) {
				_errorHandler();
				_errorHandler = null;
			}
		}
		
		private function loadComlete(e:Event):void {
			data[tempKey] = JSON.parse(e.target.data as String);
			if (arrParts.length > 0) {
				loadNext();
			} else {
				clearAllListeners();
				if (_completeHandler != null) {
					_completeHandler(data);
					_completeHandler = null;
				}
			}
		}
		
		private function clearAllListeners():void {
			if (_urlLoader == null)
				return;
			try {
				_urlLoader.close();
			} catch (err:Error) {
				echo("SimpleDataLoader", "clearAllListeners", "Try to close _urlLoader ERROR (" + err.message + ")");
			}
			_urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, loaderError);
			_urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, loaderError);
			_urlLoader.removeEventListener(Event.COMPLETE, loadComlete);
			_urlLoader = null;
		}
		
		public function disable():void {
			clearAllListeners();
			_errorHandler = null;
			_completeHandler = null;
		}
	}
}