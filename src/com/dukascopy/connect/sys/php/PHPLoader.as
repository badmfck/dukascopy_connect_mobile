package com.dukascopy.connect.sys.php {
	
	import avmplus.finish;
	import com.adobe.crypto.MD5;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.ResponseResolver;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.crypter.Crypter;
	import com.dukascopy.connect.sys.echo.echo;
	import com.greensock.TweenMax;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestDefaults;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.URLStream;
	import flash.net.URLVariables;

	/**
	 * ...
	 * @author Igor Bloom
	 */
	
	public class PHPLoader extends BaseServerLoader implements IDataLoader {
		
		private var _inUse:Boolean = false;
		private var urlRequest:URLRequest;
		private var urlLoader:URLLoader;
		private var urlStream:URLStream;
		private var _busy:Boolean = false;
		private var respond:PHPRespond;
		private var additionalData:Object;
		private var data:Object;
		private var key:String;
		
		private static var counter:int = 0;
		private static var defaultUserAgent:String;
		public var id:int;
		
		public function PHPLoader() {
			urlRequest = new URLRequest();
			urlLoader = new URLLoader();
			respond = new PHPRespond(this);
			
			PHPLoader.counter += 1;
			id = PHPLoader.counter;
		}
		
		public function setAdditionalData(ad:Object):void {
			additionalData = ad;
		}
		
		/**
		 * 
		 * @param	url
		 * @param	callBack
		 * @param	data
		 * @param	method
		 * @param	headers array of URLRequest
		 * @param	rawRespond
		 * @param	crypt
		 */
		public function loadAsStream(url:String, callBack:Function = null, data:Object = null, method:String = URLRequestMethod.POST,  headers:Array = null, rawRespond:Boolean = false, crypt:Boolean = true):void {
			
			// DEPRECATED!!
			
			this.rawRespond = rawRespond;
			this.callBack = callBack;
			if (_busy == true)
				return;
			_busy = true;
			if (url == null)
				return;
			urlRequest.url = url;
			urlRequest.method = method;
			urlRequest.requestHeaders = headers;
			
			// Generate key
			Crypter.cryptAsync(MD5.hash((Auth.key) + ' ' + new Date().getTime()), Auth.key, function(res1:String):void {
				// CRYPT DATA
				res1 = res1.substr(0, 32);
				var sendData:String = JSON.stringify(data); // LONG!
				Crypter.cryptAsync(sendData, res1, function(res2:String):void {
					// DATA PREPARED;
					//echo("PHPLoader (" + id + ")", "loadAsStream", 'DATA PREPARED! '+res2);
					var uv:URLVariables = new URLVariables();
					uv['cdata'] = res1+''+res2;
					urlRequest.data = uv;
					if (urlStream == null)
						urlStream = new URLStream();
					urlStream.addEventListener(Event.COMPLETE, onURLStreamComplete);
					urlStream.addEventListener(IOErrorEvent.IO_ERROR, onStreamIOError);
					urlStream.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onStreamSecurityError);
					TweenMax.delayedCall(1, urlStream.load, [urlRequest], true);
				});
			});
		}
		
		private function onStreamIOError(e:IOErrorEvent):void {
			streamFinish(PHP.NETWORK_ERROR, null);
		}
		
		private function onStreamSecurityError(e:SecurityErrorEvent):void {
			streamFinish('sec', null);
		}
		
		private function onURLStreamComplete(e:Event):void {
			streamFinish(null, urlStream.readUTFBytes(urlStream.bytesAvailable));
		}
		
		private function streamFinish(err:String, data:String):void {
			urlStream.removeEventListener(Event.COMPLETE, onURLStreamComplete);
			urlStream.removeEventListener(IOErrorEvent.IO_ERROR, onStreamIOError);
			urlStream.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onStreamSecurityError);
			PHP.S_COMPLETE.invoke();
			createRespond(err, data, callBack, respond, rawRespond, id, additionalData);
		}
		
		public function load(url:String, callBack:Function=null, data:Object=null, method:String = URLRequestMethod.POST,  headers:/*URLRequestHeader*/Array = null, rawRespond:Boolean = false, crypt:Boolean = true):void {
			if (defaultUserAgent == null) {
				defaultUserAgent = URLRequestDefaults.userAgent;
			}
			if (url == null) {
				//echo("PHPLoader (" + id + ")", "load", "URL IS EMPTY", true);
				createRespond("flash.01 NO METHOD PROVIDED", "", callBack, null, false, id, additionalData);
				return;
			}
			if (data == null) {
				//echo("PHPLoader (" + id + ")", "load", "DATA IS EMPTY", true);
				createRespond("flash.02 NO DATA PROVIDED", "", callBack, null, false, id, additionalData);
				return;
			}
			if ("method" in data == false && rawRespond == false) {
				//echo("PHPLoader (" + id + ")", "load", "NO METHOD IN DATA", true);
				createRespond("flash.03 NO METHOD IN DATA PROVIDED", "", callBack, null, false, id, additionalData);
				return;
			}
			
			if (_busy == true)
				return;
			_busy = true;
			
			echo("PHPLoader (" + id + ")", "load", url + "?method=" + data.method + " CRYPTED: " + crypt);
			
			this.rawRespond = rawRespond;
			this.callBack = callBack;
			
			URLRequestDefaults.userAgent = defaultUserAgent + " | version=" + Config.VERSION + " | user=" + Auth.username;
			
			

			urlRequest.url = url;
			urlRequest.method = method;
			urlRequest.requestHeaders = headers;
			urlLoader.addEventListener(Event.COMPLETE, onComplete);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			urlLoader.addEventListener(Event.OPEN, onOpen);
			urlLoader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, onHTTPResponseStatus);
			urlLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, onHTTPStatus);
			urlLoader.addEventListener(ProgressEvent.PROGRESS, onProgress);
			urlLoader.dataFormat = URLLoaderDataFormat.TEXT;
			
			if (crypt == false) {
				if (data is String) {
					if (urlRequest.requestHeaders == null)
						urlRequest.requestHeaders = [];
					urlRequest.requestHeaders.push(new URLRequestHeader("Content-type", "application/json"));
					urlRequest.data = data;
				} else {
					urlRequest.data = createURLVars(data);
				}
				TweenMax.delayedCall(
					1,
					function():void {
						//echo("PHPLoader (" + id + ")", "loading start");
						if (urlLoader != null){
							urlLoader.load(urlRequest);
						}
					},
					null,
					true
				);
				return;
			}
			this.data = data;
			//echo("PHPLoader (" + id + ")", "createKey call");
			createKey(onKeyCreated);
		}
		
		static private function createKey(callback:Function):void {
			var str:String = MD5.hash((Auth.key) + ' ' + new Date().getTime());
			Crypter.cryptAsync(str, Auth.key, callback);
		}
		
		private function onKeyCreated(val:String):void {
			//echo("PHPLoader (" + id + ")", "onKeyCreated", val);
			key = val.substr(0, 32);
			TweenMax.delayedCall(1, cryptData, null, true);
		}
		
		private function cryptData():void {
			//echo("PHPLoader (" + id + ")", "cryptData");
			var str:String = JSON.stringify(data);
			Crypter.cryptAsync(str, key, onCryptedDataCreated);
		}
		
		private function onCryptedDataCreated(val:String):void {
			var uv:URLVariables = new URLVariables();
			uv['cdata'] = key + '' + val;
			urlRequest.data = uv;
			//echo("PHPLoader (" + id + ")", "onCryptedDataCreated; loading start");
			urlLoader.load(urlRequest);
			data = null;
			key = null;
		}
		
		override public function dispose():void {
			super.dispose();
			//echo("PHPLoader (" + id + ")", "dispose");
			_inUse = false;
			_busy = false;
			TweenMax.killDelayedCallsTo(preCreateRespond);
			if (urlLoader != null) {
				try {
					urlLoader.close();
				} catch (err:Error) {
					//echo("PHPLoader", "dispose", "ERROR: URLLoader not closed (Reason: " + err.message + ")");
				}
				urlLoader.removeEventListener(Event.COMPLETE, onComplete);
				urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
				urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
				urlLoader.removeEventListener(Event.OPEN, onOpen);
				urlLoader.removeEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, onHTTPResponseStatus);
				urlLoader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, onHTTPStatus);
				urlLoader.removeEventListener(ProgressEvent.PROGRESS, onProgress);
			}
			urlLoader = null;
			if (urlStream != null) {
				try {
					urlStream.close();
				} catch (err:Error) {
					//echo("PHPLoader", "dispose", "ERROR: URLStream not closed (Reason: " + err.message + ")");
				}
				urlStream.removeEventListener(Event.COMPLETE, onURLStreamComplete);
				urlStream.removeEventListener(IOErrorEvent.IO_ERROR, onStreamIOError);
				urlStream.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onStreamSecurityError);
				urlLoader.removeEventListener(Event.OPEN, onOpen);
				urlLoader.removeEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, onHTTPResponseStatus);
				urlLoader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, onHTTPStatus);
				urlLoader.removeEventListener(ProgressEvent.PROGRESS, onProgress);
			}
			urlStream = null;
			urlRequest = null;
			if (additionalData is ResponseResolver)
				additionalData.dispose();
			additionalData = null;
			data = null;
			respond = null;
		}
		
		private function finish(error:String = null):void {
			urlLoader.removeEventListener(Event.COMPLETE, onComplete);
			urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
			urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			urlLoader.removeEventListener(Event.OPEN, onOpen);
			urlLoader.removeEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, onHTTPResponseStatus);
			urlLoader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, onHTTPStatus);
			urlLoader.removeEventListener(ProgressEvent.PROGRESS, onProgress);
			TweenMax.delayedCall(1, preCreateRespond, [error], true);
		}
		
		private function onProgress(e:ProgressEvent):void {
			//echo("PHPLoader (" + id + ")", "onProgress", new Date().getTime() + "; " + e.bytesLoaded);
		}
		
		private function onHTTPStatus(e:HTTPStatusEvent):void {
			//echo("PHPLoader (" + id + ")", "onHTTPStatus", new Date().getTime() + "; " + e.status);
		}
		
		private function onHTTPResponseStatus(e:HTTPStatusEvent):void {
			//echo("PHPLoader (" + id + ")", "onHTTPResponseStatus", new Date().getTime() + "; " + e.status);
		}
		
		private function onOpen(e:Event):void {
			//echo("PHPLoader (" + id + ")", "onOpen", new Date().getTime());
		}
		
		private function preCreateRespond(error:String = null):void {
			_busy = false;
			createRespond(error, (urlLoader == null) ? "" : urlLoader.data, callBack, respond, rawRespond, id, additionalData);
		}
		
		private function onComplete(e:Event):void {
			//echo("PHPLoader (" + id + ")", "onComplete", new Date().getTime());
			PHP.S_COMPLETE.invoke();
			finish();
		}
		
		private function onIOError(e:IOErrorEvent):void {
			PHP.S_ERROR.invoke();
			finish(PHP.NETWORK_ERROR);
		}
		
		private function onSecurityError(e:SecurityErrorEvent):void {
			PHP.S_ERROR.invoke();
			finish('sec');
		}
		
		/** 
		 * @param	data - объект с данными
		 * @return	сформированные URLVariables
		 */
		static	public function createURLVars(data:Object):URLVariables {
			if (data == null)
				return new URLVariables();
			var endRes:URLVariables = new URLVariables();
			var loop:Function = function(data:Object, name:String):void {
				for (var n:* in data) {
					var key:String = (name.length < 1) ? n : name + '[' + n + ']';
					if (typeof(data[n]) == 'object') {
						loop(data[n], key);
					} else {
						endRes[key] = data[n];
					}
				}
			}
			loop(data, '');
			return endRes;
		}
		
		public function get inUse():Boolean {
			return _inUse;
		}
		
		public function get busy():Boolean {
			return _busy;
		}
		
		public function getID():int {
			return id;
		}
	}
}