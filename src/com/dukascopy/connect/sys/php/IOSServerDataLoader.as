package com.dukascopy.connect.sys.php 
{
	import com.adobe.crypto.MD5;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.crypter.Crypter;
	import com.dukascopy.connect.sys.echo.echo;
	import com.greensock.TweenMax;
	import connect.DukascopyExtension;
	import flash.events.StatusEvent;
	import flash.net.URLRequestMethod;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class IOSServerDataLoader extends BaseServerLoader implements IDataLoader 
	{
		private static var currentRequestId:uint = 0;
		private var sendData:String;
		private var respond:PHPRespond;
		public var requestId:int;
		public var url:String;
		public var data:Object;
		public var method:String;
		public var headers:Array/*URLRequestHeader*/;
		public var crypt:Boolean;
		
		public function IOSServerDataLoader() 
		{
			respond = new PHPRespond(this);
		}
		
		/* INTERFACE com.dukascopy.connect.sys.php.IDataLoader */
		
		public function load(url:String, callBack:Function = null, data:Object = null, method:String = URLRequestMethod.POST, headers:Array/*URLRequestHeader*/ = null, rawRespond:Boolean = false, crypt:Boolean = true):void 
		{
			this.url = url;
			this.callBack = callBack;
			this.data = data;
			this.method = method;
			this.headers = headers;
			this.rawRespond = rawRespond;
			this.crypt = crypt;
			
			requestId = generateNewRequestId();
			
			if (url == null)
				return;
			
			sendData = JSON.stringify(data);
		//	MobileGui.writeMessage({type:"request1", requestId:requestId});
			if (crypt) {
				
				// Generate key
				Crypter.cryptAsync(MD5.hash((Auth.key) + ' ' + new Date().getTime()), Auth.key, function(res1:String):void {
				//	MobileGui.writeMessage({type:"request2", requestId:requestId});
					// CRYPT DATA
					res1 = res1.substr(0, 32);
					TweenMax.delayedCall(1, function():void {
					//	MobileGui.writeMessage({type:"request3", requestId:requestId});
						echo("IOSServerDataLoader", "load", "TweenMax.delayedCall (crypt data)");
						Crypter.cryptAsync(sendData, res1, function(res2:String):void {
							// DATA PREPARED;
							sendData = res1 + '' + res2;
							readyToSend();
							echo("IOSServerDataLoader", "load", "Send crypted data, method=" + data.method);
						});
					},null, true);
				});
			}
			else {
				readyToSend();
			}
		}
		
		private function readyToSend():void 
		{
			IosServerLoadersManager.processCall(this);
		}
		
		private function finish(data:Object, error:String = null):void {
			echo("IOSServerDataLoader","finish","TweenMax.delayedCall");
			createRespond(error, JSON.stringify(data), callBack, respond, rawRespond);
		}
		
		private function generateNewRequestId():int 
		{
			currentRequestId ++;
			return currentRequestId;
		}
		
		public function loadAsStream(url:String, callBack:Function = null, data:Object = null, method:String = URLRequestMethod.POST, headers:Array = null, rawRespond:Boolean = false, crypt:Boolean = true):void 
		{
			
		}
		
		override public function dispose():void 
		{
			super.dispose();
			callBack = null;
			sendData = null;
			data = null;
			headers = null;
		}
		
		public function onDataLoaded(dataObject:Object):void 
		{
			if ((dataObject is Object) && ("data" in dataObject))
			{
				finish(dataObject);
			}
			else {
			//	MobileGui.writeMessage({type_message:"DATA ERROR", method:this.data.method});
			}
			dispose();
		}
		
		public function onDataLoadFailed(dataObject:Object):void 
		{
			finish(dataObject, "io");
			dispose();
		}
		
		public function getRequestData():String 
		{
			return sendData;
		}
		
		static public function isSupported():Boolean 
		{
			return (MobileGui.dce != null);
		}
	}
}