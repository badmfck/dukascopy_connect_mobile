package com.dukascopy.connect.sys.imageManager {
	import com.adobe.crypto.MD5;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.LocalAvatars;
	import com.dukascopy.connect.sys.crypter.ImageCrypter;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.store.Store;
	import com.dukascopy.connect.utils.ImageCrypterOld;
	import com.greensock.TweenMax;
	import com.telefision.sys.signals.Signal;
	import com.telefision.utils.Loop;
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filesystem.File;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.ImageDecodingPolicy;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author Igor Bloom
	 */
	public class ImageLoader {
 
		private var callBacks:Array=[]
		private var loader:URLLoader = new URLLoader();
		private var _url:String;
		private var cachedFileName:String;
		public var saveToDisk:Boolean;
		
		static private var incVal:Number= new Date().getTime();
		static private var imageLoaded:Function;
		static private var loaderCntx:LoaderContext = null;
		static private var EXTENSION:String = ".bmd";// saving cached image under extension tmp
		private static var _urlRequest:URLRequest;
		
		public var S_LOAD_PROGRESS:Signal = new Signal("ImageLoader.S_LOAD_PROGRESS");
		public var disposed:Boolean = false;
		
		private static function urlRequest(url:String):URLRequest
		{
			_urlRequest ||= new URLRequest();
			_urlRequest.url = url;
			return _urlRequest;
		}
		
		private static var _point:Point;
		private static function point(x:int, y:int):Point
		{
			_point ||= new Point();
			_point.x = x;
			_point.y = y;
			return _point;
		}
		
		private static var _rectangle:Rectangle;
		private var httpStatus:int=-1;
		private var decrypted:Boolean;
		private var cryptKey:String;
		private var originURL:String;
		private var isJPEGXOR:Boolean;
		private static function rectangle(x:int, y:int, width:int, height:int):Rectangle
		{
			_rectangle ||= new Rectangle();
			_rectangle.x = x;
			_rectangle.y = y;
			_rectangle.width= width;
			_rectangle.height = height;
			return _rectangle;
		}
		
		public function ImageLoader(imageLoaded:Function, saveToDisk:Boolean = true)
		{
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			this.saveToDisk = saveToDisk;
			if (ImageLoader.imageLoaded == null)
				ImageLoader.imageLoaded = imageLoaded;
				
			if (ImageLoader.loaderCntx == null) {
				ImageLoader.loaderCntx=new LoaderContext();
				ImageLoader.loaderCntx.imageDecodingPolicy = ImageDecodingPolicy.ON_LOAD; //on DEMAND - декодим когда используется, oN_LOAD - Декодим сразу (скачок памяти!)
			}
		}
		
		private function addListeners():void
		{
			if (loader == null)
				return;
			loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecError);
			loader.addEventListener(ProgressEvent.PROGRESS, onLoadProgress);
			loader.addEventListener(Event.COMPLETE, onComplete);
		}
		
		private function onLoadProgress(e:ProgressEvent):void 
		{
			if (S_LOAD_PROGRESS != null)
			{
				S_LOAD_PROGRESS.invoke(url, Math.round(e.bytesLoaded*100/e.bytesTotal));
			}
		}
		
		private function removeListener():void {
			if (loader == null)
				return;
			loader.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
			loader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, onHttpStatus);
			loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecError);
			loader.removeEventListener(Event.COMPLETE, onComplete);
		}
		
		private function onHttpStatus(e:HTTPStatusEvent):void
		{
			httpStatus = e.status;
		}
		
		public function load(url:String, callback:Function, fromLocalStoreOnly:Boolean = false):Boolean
		{
			originURL = url;
			
			callBacks = [];
			
			callBacks.push(callback);
			if (LocalAvatars.isLocal(url))
			{
				_url = url;
				
				var localAvatar:ImageBitmapData = LocalAvatars.getAvatar(url);
				if (localAvatar != null)
				{
					fireCallbacks(localAvatar, true);
					return true;
				}
				else
				{
					//echo("ImageLoader", "error", "need local avatar for", url);
					
					callEmptyBitmap();
					return true;
				}
			}
			
			if (url.indexOf(ImageCrypterOld.imageKeyFlag) != -1)
			{
				var pathElements:Array = url.split(ImageCrypterOld.imageKeyFlag);
				_url = pathElements[0];
				cryptKey = (pathElements[1] as String);
			}
			else
			{
				_url = url;
			}
			
			
			addListeners();
			
			// check decrypted file
			var cachedFileName:String = MD5.hash(_url) + EXTENSION;
			
			var itemInSaveProcess:* = ImageSaver.getItemInSaveProcess(cachedFileName)
			if (itemInSaveProcess)
			{
				if (itemInSaveProcess is ByteArray)
				{
					if (itemInSaveProcess != null)
					{
						var bytes:ByteArray = new ByteArray();
						(itemInSaveProcess as ByteArray).readBytes(bytes, 0);
						onLocalJPEGFileLoaded(bytes, false);
						return true;
					}
				}
				else if (itemInSaveProcess is ImageBitmapData && (itemInSaveProcess as ImageBitmapData).isDisposed == false)
				{
					fireCallbacks((itemInSaveProcess as ImageBitmapData), true);
					return true;
				}
			}
			
			var f:File = new File(Store.storeDirectory.nativePath + File.separator + ImageSaver.JPEG_PRREFIX + cachedFileName);
			if (f.exists)
			{
				// loade decrypted file
				Store.loadFile(f.nativePath, onLocalJPEGFileLoaded);
				return true;
			}
			
			f = new File(Store.storeDirectory.nativePath + File.separator + ImageSaver.PREFIX + cachedFileName);
			if (f.exists)
			{
				// loade decrypted file
				Store.loadFile(f.nativePath, onLocalFileLoaded);
			}
			else
			{
				// decrypted file not exists
				f = new File(Store.storeDirectory.nativePath + File.separator + cachedFileName);
				if (f.exists)
				{
					Store.loadFile(f.nativePath, onLocalFileLoaded);
				}
				else
				{
					if (fromLocalStoreOnly == false)
					{
						doLoad();
					}
					else
					{
						return false;
					}
				}
			}
			return true;
		}
		
		public function stopLoading():void
		{
			try {
				removeListener();
				if (loader != null)
				{
					loader.close();
				}
			}catch (e:Error) {
			//	ok
			};
			if(callBacks!=null)
				callBacks = [];
			dispose();
		}
		
		private function onLocalJPEGFileLoaded(ba:ByteArray, err:Boolean, fileName:String = null):void
		{
			if (err || ba==null || ba.bytesAvailable==0) {
				// need to load image from server
				doLoad();
				return;
			}
			
			/*ba.position = 0;
			var searchByte:ByteArray = new ByteArray();
			
			searchByte.writeByte(0xFF);
			searchByte.writeByte(0xFF);
			searchByte.writeByte(0x33);
			searchByte.writeByte(0x33);
			searchByte.writeByte(0x33);
			searchByte.writeByte(0x33);
			searchByte.position = 0;*/
			
		//	var position:uint = ImageCrypter.searchBytes(searchByte, ba, 0);
			
			var endFileBytes:ByteArray = new ByteArray();
			var jpegXorFlag:ByteArray = ImageCrypterOld.getJpegXORFlag();
			
			ba.position = ba.length - jpegXorFlag.length;
			ba.readBytes(endFileBytes, 0, jpegXorFlag.length);
			
			endFileBytes.position = 0;
			jpegXorFlag.position = 0;
			var length:int = jpegXorFlag.length;
			var isJPEGXOR:Boolean = true;
			if (endFileBytes.length == jpegXorFlag.length)
			{
				for (var i:int = 0; i < length; i++) 
				{
					if (endFileBytes.readByte() != jpegXorFlag.readByte())
					{
						isJPEGXOR = false;
					}
				}
			}
			
			if (isJPEGXOR)
			{
				ImageManager.S_DECRYPT_START.invoke(originURL);
				ba.length = ba.length - length;
				
				ImageCrypter.decrypt(ba, cryptKey, 
					function(decryptedImageData:ByteArray):void
					{
						//!TODO: проверить на длинну = 0;
						decrypted = true;
						var bytesLoader:Loader = new Loader();
						bytesLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onBytesLoaded);
						bytesLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
						bytesLoader.loadBytes(decryptedImageData);
						ba.clear();
						ba = null;
					});
			}
			else
			{
				if (ba != null)
				{
					//echo("ImageLoader","onLocalJPEGFileLoaded",'Image from store loaded, but damaged! Load image from server! ' + ba.length);
					ba.clear();
					ba = null;
				}
				
				doLoad();
			}
		}
		
		private function onLocalFileLoaded(ba:ByteArray, err:Boolean, fileName:String = null):void
		{
			if (err || ba==null || ba.bytesAvailable==0) {
				// need to load image from server
				doLoad();
				return;
			}
			
			ba.position = 0;
			var w:uint = ba.readUnsignedInt();
			var h:uint = ba.readUnsignedInt();
			if (w > 2000 || h > 2000) {
				//echo("ImageLoader","onLocalFileLoaded",'Image from store loaded, but damaged! Load image from server! ' + ba.length);
				doLoad();
				return;
			}
			
			var ibd:ImageBitmapData = new ImageBitmapData('fromStore.' + url, w, h, true, 0, false, false);
			// TODO - load bytes async ?
			var bmp:ByteArray = new ByteArray();
			
			bmp.writeBytes(ba, ba.position, ba.bytesAvailable);
			
			bmp.position = 0;
			
			try{
				ibd.setPixels(new Rectangle(0, 0, w, h), bmp);
				
				
			}catch (e:Error) {
				//echo("ImageLoader","onLocalFileLoaded",'Image from store loaded, but damaged! Load image from server! ');
				doLoad();
				return;
			}
			
			if (fileName != null){
				var fname:String = fileName.split(File.separator).pop();
				if(fname.charAt(0)=="!")
					ibd.setDecryptionStatus();
			}
			
			fireCallbacks(ibd);
		}
		
		private function doLoad():void {
			if (disposed || loader == null)
			{
				return;
			}
			
			var sep:String = '?';
			if (_url.indexOf('?') != -1)
				sep = '&';
			var u:String = _url;
			if (u != null && u.indexOf("air.com.iswfx.connect/app_tempFiles/tempFilemrz") == -1)
			{
				u = _url + sep + 'rand=' +incVal;
			}
			else{
				if (u != null && u.length >= 5 && u.slice(0, 5) == "app:/")
				{
					u = u.substr(5);
					
					var f:File = new File(u);
					if (f.exists)
					{
						// loade decrypted file
						Store.loadFile(f.nativePath, onLocalFileLoaded);
					}
					return;
				}
			}
			/*if (u.substr(0, 4) != 'http')
				u = 'https:' + u.substr(0, 4);*/
				
			if (u.toLowerCase().indexOf("http://www.dukascopy") == 0)
				u = "https" + u.substr(4);
				
			if (u.toLowerCase().indexOf("http://dccapi.dukascopy") == 0)
				u = "https" + u.substr(4);
				
			incVal++;
			//echo("ImageLoader", "doLoad", u);
			loader.load(urlRequest(u));
		}
		
		private function onComplete(e:Event = null):void
		{
			var imageData:ByteArray = loader.data;
			
			if (imageData == null || imageData.length == 0)
			{
				onLoadError();
				return;
			}
			
			// image not found/delete
			if (imageData.length == 330)
			{
				onLoadError();
				return;
			}
			
			if (cryptKey)
			{
				var sourceData:ByteArray = new ByteArray();
				imageData.position = 0;
				imageData.readBytes(sourceData);
				sourceData.position = 0;
				imageData.position = 0;
				
				var endFileBytes:ByteArray = new ByteArray();
				var jpegXorFlag:ByteArray = ImageCrypterOld.getJpegXORFlag();
				
				imageData.position = imageData.length - jpegXorFlag.length;
				imageData.readBytes(endFileBytes, 0);
				
				endFileBytes.position = 0;
				jpegXorFlag.position = 0;
				var length:int = jpegXorFlag.length;
				isJPEGXOR = true;
				if (endFileBytes.length == jpegXorFlag.length) {
					for (var i:int = 0; i < length; i++) {
						if (endFileBytes.readByte() != jpegXorFlag.readByte()) {
							isJPEGXOR = false;
						}
					}
				} else {
					isJPEGXOR = false;
				}
				isJPEGXOR = true;
				
				if (isJPEGXOR) {
					ImageManager.S_DECRYPT_START.invoke(originURL);
					imageData.length = imageData.length - length;
					ImageCrypter.decrypt(imageData, cryptKey, 
						function(decryptedData:ByteArray):void {
							decrypted = true;
							decryptedData.position = 0;
							
							loadBytesToImage(decryptedData);
						});
					if (saveToDisk) {
						var cachedFileName:String = MD5.hash(url) + EXTENSION;
						ImageSaver.saveJPEGImageData(cachedFileName, sourceData, originURL);
						sourceData = null;
					}
					return;
				}
			}
			imageData.position = 0;
			loadBytesToImage(imageData);
		}
		
		private function loadBytesToImage(imageData:ByteArray):void 
		{
			if (imageData.bytesAvailable > 0)
			{
				var bytesLoader:Loader = new Loader();
				bytesLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onBytesLoaded);
				bytesLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
				bytesLoader.loadBytes(imageData);
				imageData = null;
			}
			else
			{
				onLoadError();
			}
		}
		
		private function onLoadError(e:IOErrorEvent = null):void 
		{
			callEmptyBitmap();
		}
		
		private function onBytesLoaded(e:Event):void 
		{
			var bmp:ImageBitmapData = new ImageBitmapData(url, (e.target as LoaderInfo).loader.content.width, (e.target as LoaderInfo).loader.content.height);
			
			
			
			var isImageError:Boolean = false;
			try {
				isImageError = bmp.width == 24 && bmp.height == 24 && ((e.target as LoaderInfo).loader.contentLoaderInfo.bytesTotal == 330 || (e.target as LoaderInfo).loader.contentLoaderInfo.bytesTotal == 324);
			} catch (e:Error) {
				//echo("ImageLoader", "onComplete", e.message);
			}
			
			if (isImageError)
			{
				bmp.dispose();
				bmp = null;
			}
			
			
			
			try {
				if (bmp)
					bmp.copyPixels(Bitmap((e.target as LoaderInfo).loader.content).bitmapData, rectangle(0, 0, (e.target as LoaderInfo).loader.content.width, (e.target as LoaderInfo).loader.content.height), point(0, 0));
			} catch (e:Error) {
				//echo("ImageLoader", "onComplete", e.message);
			}
			
			Bitmap((e.target as LoaderInfo).loader.content).bitmapData.dispose();
			Bitmap((e.target as LoaderInfo).loader.content).bitmapData = null;
			(e.target as LoaderInfo).loader.unload();
			
			if (saveToDisk == true && isImageError == false && !isJPEGXOR)
			{
				var cachedFileName:String = MD5.hash(url) + EXTENSION;
				ImageSaver.saveImage(cachedFileName, bmp, originURL);
				//echo("ImageLoader", "onComplete", "save image to disk");
			}
			
			if (decrypted && bmp)
			{
				bmp.setDecryptionStatus();
			}
			
			fireCallbacks(bmp, !isImageError);
		}
		
		private function fireCallbacks(bmp:ImageBitmapData, loadingSuccess:Boolean = true):void {
			if (imageLoaded != null && imageLoaded is Function) {
				if ((imageLoaded as Function).length == 2) {
					imageLoaded(bmp, url);
				} else if ((imageLoaded as Function).length == 3) {
					imageLoaded(bmp, url, loadingSuccess);
				}
			}
			
			if (callBacks == null || callBacks.length == 0) {
				return;
			}
			
			var n:int = 0;
			var m:int = callBacks.length;
			
			/**
			//SYNC
			for (n; n < m;n++){
				bmp.incUseCount();
				if(callBacks[n]!=null && callBacks[n] is Function)
					callBacks[n](url, bmp);
			}
			
			return;
			/**/
			// ASYNC
			var __fireCallbacks:Function = function():void {
				if (n == m) {
					Loop.remove(__fireCallbacks);
					callBacks = null;
					dispose();
					return;
				}
				
				if (callBacks == null || callBacks.length == 0)
				{
					Loop.remove(__fireCallbacks);
					dispose();
					return;
				}
				
				if (bmp != null)
				{
					bmp.incUseCount("fireCallbacks");
				}
				
				if (callBacks != null && callBacks[n] != null && callBacks[n] is Function) {
					if ((callBacks[n] as Function).length == 2) {
						callBacks[n](originURL, bmp);
					} else if ((callBacks[n] as Function).length == 3) {
						callBacks[n](originURL, bmp, loadingSuccess);
					}
				}
				n++;
			}
			TweenMax.delayedCall(1, function():void { 
				//echo("ImageLoader","fireCallbacks", "TweenMax.delayedCall");
				Loop.add(__fireCallbacks); 		
			}, null, true);
			/**/
		}
		
		private function dispose():void {
			
			if (disposed == true)
			{
				return;
			}
			
			removeListener();
			disposed = true;
			if (loader != null)
			{
				try {
					loader.close();
				}
				catch (e:Error)
				{
					
				}
			}
			callBacks = null;
			cachedFileName = null;
			loader = null;
			if (S_LOAD_PROGRESS != null)
			{
				S_LOAD_PROGRESS.dispose();
				S_LOAD_PROGRESS = null;
			}
		}
		
		private function onSecError(e:SecurityErrorEvent):void {
			//echo("ImageLoader","onSecError","Image not loaded -> SEC -> "+e.text);
			callEmptyBitmap();
		}
		
		private function onIOError(e:IOErrorEvent = null):void {
			
			//echo("ImageLoader","onIOError","Image not loaded -> IO ->"+url+" > "+e.text+' > '+httpStatus);
			callEmptyBitmap();
		}
		
		private function callEmptyBitmap():void {
			if (callBacks == null) {
				return;
			}
			var l:int = callBacks.length;
		//	fireCallbacks(Assets.getAsset(Assets.NO_IMAGE), false);
			fireCallbacks(null, false);
		}
		
		
		public function addCallback(callBack:Function):Boolean {
			if (callBack == null)
				return false;
			if (callBacks == null)
				callBacks = [];
			var l:int = callBacks.length;
			for (var n:int = 0; n < l; n++) {
				if (callBacks[n] == callBack)
					return false;
			}
			callBacks.push(callBack);
			return true;
		}
		
		public function cancelLoad(url:String, callBack:Function):void 
		{
			if (callBacks != null)
			{
				var l:int = callBacks.length;
				for (var i:int = 0; i < l; i++) 
				{
					if (callBacks[i] == callBack)
					{
						callBacks.splice(i, 1)
						break;
					}
				}
			}
		}
		
		public function existCallbacks():Boolean 
		{
			if (callBacks == null || callBacks.length == 0)
			{
				return false;
			}
			return true;
		}
		
		public function get url():String {
			return _url;
		}
	
	}
}