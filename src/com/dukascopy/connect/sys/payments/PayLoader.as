package com.dukascopy.connect.sys.payments {

	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.screenAction.customActions.DownloadFileAction;
	import com.dukascopy.connect.gui.components.WhiteToast;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.configManager.ConfigManager;
	import com.dukascopy.connect.sys.connectionManager.NetworkManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.vo.chat.FileMessageVO;
	import com.dukascopy.langs.Lang;
	import com.dukascopy.langs.LangManager;
	import com.greensock.TweenMax;
	import com.hurlant.crypto.hash.HMAC;
	import com.hurlant.crypto.hash.SHA256;
	import com.hurlant.util.Base64;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.URLStream;
	import flash.net.URLVariables;
	import flash.utils.ByteArray;
	import gibberishAES.AESCrypter;
	
	/**
	 * This class send request to Payments API and automatically add language param "l"
	 * if in data not exist other ("ln", "lang");
	 * @author Alexey Skuryat
	 */
	
	public class PayLoader {
		
		static private var counter:int = 0;
		
		private var urlRequest:URLRequest;
		private var urlLoader:URLStream;
		private var callBack:Function;
		private var respond:PayRespond;	
		
		private var _urlLoaderClosed:Boolean = false;
		private var _savedRequestData:Object; // Object for secondary request if error was occured.
		private var _debugData:Object = { };
		private var _id:int; // Call ID, need for debug.
		
		public function PayLoader() {
			urlRequest = new URLRequest();
			urlLoader = new URLStream();
			respond = new PayRespond(this);
			
			PayLoader.counter += 1;
			_id = PayLoader.counter;
		}
		
		public function load(url:String, callBack:Function = null, data:Object = null, method:String = URLRequestMethod.POST, openMethod:Boolean = false):void {
			if (url == null)
				return;
			this.callBack = callBack;
			if (url.length > 2 && url.substr(url.length - 1, 1) == "/")
				url = url.substr(0, url.length - 1);
			urlRequest.url = url;
			urlRequest.method = method;
			if (openMethod == false) {
				urlRequest.data = addSignature(createURLVars(data));
			} else {
				urlRequest.data = data;
			}
			urlRequest.requestHeaders.push(new URLRequestHeader("Device-UID", Auth.devID));
			if (method === URLRequestMethod.DELETE) {
				// Cтавим  header о подмене DELETE на POST и подменяем метод на POST,
				// иначе на некоторых платформах не передаются переменные.
				urlRequest.requestHeaders.push(new URLRequestHeader("X-HTTP-Method-Override", URLRequestMethod.DELETE));
				urlRequest.method = URLRequestMethod.POST;
			}
			_savedRequestData ||= { };
			_savedRequestData.url = url;
			_savedRequestData.data = data;
			_savedRequestData.method = method;
			_savedRequestData.callBack = callBack;
			respond.setSavedRequestData(_savedRequestData);
			if (NetworkManager.isConnected) {
				urlLoader.addEventListener(Event.COMPLETE, onComplete);
				urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
				urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
				urlLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, onHTTPStatus);
				urlLoader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, onHTTPStatus);
				echo("PayLoader (" + id + ")", "load", "\n	url: " + urlRequest.url + "\n	method: " + method + "\n	data:\n" + UI.tracedObj(urlRequest.data));
				urlLoader.load(urlRequest);
			} else
				callback(respond.setData(true, Lang.noInternetConnection, null, -2));
		}
		
		public function loadAsFile(url:String, callBack:Function = null, data:Object = null, method:String = URLRequestMethod.POST, openMethod:Boolean = false):void {
			if (url == null)
				return;
			this.callBack = callBack;
			if (url.length > 2 && url.substr(url.length - 1, 1) == "/")
				url = url.substr(0, url.length - 1);
			urlRequest.url = url;
			urlRequest.method = method;
			
			data["duid"] = Auth.devID;
			if (openMethod == false) {
				urlRequest.data = addSignature(createURLVars(data));
			} else {
				urlRequest.data = data;
			}
			if (method === URLRequestMethod.DELETE) {
				urlRequest.requestHeaders.push(new URLRequestHeader("X-HTTP-Method-Override", URLRequestMethod.DELETE));
				urlRequest.method = URLRequestMethod.POST;
			}
			_savedRequestData ||= { };
			_savedRequestData.url = url;
			_savedRequestData.data = data;
			_savedRequestData.method = method;
			_savedRequestData.callBack = callBack;
			respond.setSavedRequestData(_savedRequestData);
			
			echo("PayLoader", "loadAsFile", "\n" + urlRequest.url + "\n" + UI.tracedObj(urlRequest.data));
			
			var fmVO:FileMessageVO = new FileMessageVO();
			fmVO.title = "paymentsReport";
			var action:DownloadFileAction = new DownloadFileAction(urlRequest, fmVO);
			action.execute();
		}
		
		private function addSignature(variables:URLVariables):URLVariables {
			var addonTime:Number = PayConfig.TIMESTAMP_DIFF;
			var timestamp:Number = new Date().time + addonTime;
			var nonce:String = timestamp.toString() + uint(Math.random() * uint.MAX_VALUE);
			if (ConfigManager.config != null && ConfigManager.config.useNewPayLoader == true)
				nonce = "nh-" + nonce;
			
			variables['session_id'] = PayConfig.PAY_SESSION_ID;
			variables['_api_client_id'] = PayConfig.PAY_CLIENT_ID;
			variables['_api_timestamp'] = int(timestamp / 1000);
			variables['_api_nonce'] = nonce;
			
			var arr:Array = [];
			for (var value:* in variables)
				arr[arr.length] =  { key:rawURLEncode(value), value:rawURLEncode(variables[value]) } ;
			arr.sortOn(["key"]);
			
			var dataString:String = "";
			var leng:int = arr.length;
			for (var i:int = 0; i < leng; i++) {
				if (dataString != "")
					dataString += "&";
				dataString += arr[i].key + "=" + arr[i].value;
			}
			
			var signatureBase:String = urlRequest.method.toUpperCase() + "&";
			if (ConfigManager.config != null && ConfigManager.config.useNewPayLoader == true)
				signatureBase += rawURLEncode(urlRequest.url.substr(PayConfig.PAY_API_URL.length)) + "&";
			else
				signatureBase += rawURLEncode(urlRequest.url) + "&";
			signatureBase += rawURLEncode(dataString);
			
			btSigBase ||= new ByteArray();
			btSigBase.writeUTFBytes(signatureBase);
			
			var signatureKey:String = rawURLEncode(PayConfig.PAY_CLIENT_SECRET) + "&" + rawURLEncode(PayConfig.PAY_SESSION_ID);
			btSigKey ||= new ByteArray();
			btSigKey.writeUTFBytes(signatureKey);
			
			var sha256:SHA256 = new SHA256();
			var hmac:HMAC = new HMAC(sha256);
			variables['_api_signature'] = Base64.encodeByteArray(hmac.compute(btSigKey, btSigBase));
			if (Config.isTest() == true) {
				_debugData.variables = { };
				for (var n :String in variables) {
					_debugData.variables[n] = variables[n];
				}
				_debugData.arr = [];
				for (var j:int = 0; j < arr.length; j++) {
					_debugData.arr.push(arr[j]);
				}
				_debugData.sigBase = signatureBase;
			}
			
			arr.length = 0;
			arr = null;
			
			dataString = "";
			
			signatureBase = "";
			btSigBase.clear();
			
			signatureKey = "";
			btSigKey.clear();
			
			sha256 = null;
			
			hmac.dispose();
			hmac = null;
			
			return variables;
		}
		
		private function rawURLEncode(val:String):String {
			return encodeURIComponent(val).replace(/!/g, '%21').replace(/'/g, '%27').replace(/\(/g, '%28').replace(/\)/g, '%29').replace(/\*/g, '%2A');
		}
		
		private function onHTTPStatus(e:HTTPStatusEvent):void {
			if (e.status == 0)
				finish("err");
		}
		
		private function onComplete(e:Event):void {
			finish();
		}
		
		private function onIOError(e:IOErrorEvent):void {
			finish('io');
		}
		
		private function onSecurityError(e:SecurityErrorEvent):void {
			finish('sec');
		}
		
		private function finish(error:String = null):void {
			if (error != null) {
				callback(respond.setData(true, Lang.TEXT_SERVER_CANNT_RESPOND, null, -2));
				return;
			}
			var data:Object = null;
			var rawData:String;
			try {
				rawData = urlLoader.readMultiByte(urlLoader.bytesAvailable, "UTF-8");
				data = JSON.parse(rawData);
			} catch (err:Error) {
				var errorText:String = rawData;
				if (errorText != null && errorText.length > 200) {
					errorText = errorText.substr(0, 200);
				}
				callback(respond.setData(true, "JSON Error: " + errorText, null));
				closeURLLoader();
				return;
			}
			if ("error" in data  && data.error != null) {
				var errorCode:int = data.code != null ? data.code : -1;
				callback(respond.setData(true, data.error, data, errorCode));
				if (errorCode == 1040) {
					if (Config.isTest() == true)
						displayMessage("Error 1040: " + data.error);
					var key:String = Auth.uid;
					for (var i:int = Auth.uid.length; i > 0; i--) {
						key = key + Auth.uid.charAt(i - 1);
					}
					var value:String = AESCrypter.enc(JSON.stringify(_debugData), key);
					PHP.call_statVI("PayError1040", AESCrypter.enc(JSON.stringify(_debugData), key));
				}
				closeURLLoader();
				return;
			}
			callback(respond.setData(false, "", data));
			closeURLLoader();
		}
		
		private var toast:WhiteToast;
		private function displayMessage(message:String):void {
			var toastTime:Number = 5;
			toast = new WhiteToast(message, MobileGui.stage.stageWidth, MobileGui.stage.stageHeight, null, toastTime);
			MobileGui.stage.addChild(toast);
			TweenMax.delayedCall(toastTime + 0.5, onTostMessageHided);
		}
		
		private function onTostMessageHided():void {
			if (toast != null) {
				toast.dispose();
				if (toast.parent != null) {
					toast.parent.removeChild(toast);
				}
				toast = null;
			}
		}
		
		private function callback(payRespond:PayRespond):void {
			echo("PayLoader (" + id + ")", "callback", "");
			if (callBack != null)
				callBack(payRespond);
			callBack = null;
		}
		
		private function closeURLLoader():void {
			if (urlLoader == null || _urlLoaderClosed == true)
				return;
			try {
				urlLoader.close();
			} catch (err:Error) {
				echo("PayLoader", "closeURLLoader", "ERROR: URLLoader not closed (Reason: " + err.message + ")");
			}
			urlLoader.removeEventListener(Event.COMPLETE, onComplete);
			urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
			urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			urlLoader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, onHTTPStatus);
			urlLoader.removeEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, onHTTPStatus);
			_urlLoaderClosed = true;
		}
		
		public function dispose():void {
			echo("PayLoader (" + id + ")", "dispose");
			closeURLLoader();	
			_savedRequestData = null;
			_id = 0;
			callBack = null;
			urlLoader = null;
			urlRequest = null;
			respond = null;	
		}
		
		public function get savedRequestData():Object { return _savedRequestData; }
		public function get id():int { return _id; }
		
		////////////////////
		// STATIC METHODS //
		////////////////////
		
		static private var btSigKey:ByteArray;
		static private var btSigBase:ByteArray;
		
		static private var reA:RegExp = /[^_a-zA-Z]/g;
		static private var reN:RegExp = /[^_0-9]/g;
		
		static private function sortAlphaNum(first:Object, second:Object):int {
			var a:String = first.key;
			var b:String = second.key;
			var aA:String = a.replace(reA, "");
			var bA:String = b.replace(reA, "");
			if (aA === bA) {
				var aN:Number = parseInt(a.replace(reN, ""), 10);
				var bN:Number = parseInt(b.replace(reN, ""), 10);
				return aN === bN ? 0 : aN > bN ? 1 : -1;
			} else
				return aA > bA ? 1 : -1;
		}
		
		/** 
		 * @param	data - объект с данными
		 * @return	сформированные URLVariables
		 */
		static private function createURLVars(data:Object):URLVariables {
			var endRes:URLVariables = new URLVariables();
			var langExist:Boolean = false;
			var loop:Function = function(data:Object, name:String = ""):void {
				for (var n:* in data) {
					var key:String = (name.length < 1) ? n : name + '[' + n + ']';
					if (typeof(data[n]) == 'object') {
						loop(data[n], key);
					} else {
						if (n == "l" || n == "ln" || n == "lang") {
							if (langExist == true)
								return;
							langExist = true;
						}
						endRes[key] = data[n];
					}
				}
			}
			loop(data);
			if (langExist == false)
				loop( { l:LangManager.model.getCurrentLanguageID() } );
			return endRes;
		}
	}
}