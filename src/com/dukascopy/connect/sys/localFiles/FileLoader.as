package com.dukascopy.connect.sys.localFiles 
{
	import com.adobe.crypto.MD5;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.store.Store;
	import com.dukascopy.connect.sys.workers.WorkerMain;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filesystem.File;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class FileLoader 
	{
		public static const LOAD_ERROR:String = "loadError";
		public static const PROGRESS:String = "progress";
		static public const FILE_SIZE:String = "fileSize";
		static public const COMPLETE:String = "complete";
		static public const LOAD_IO_ERROR:String = "loadIoError";
		
		private var loadResultCallback:Function;
		private var loader:URLLoader;
		public var fileId:String;
		private var fileSize:int = -1;
		private var fileName:String;
		
		public function FileLoader(loadResultCallback:Function) 
		{
			this.loadResultCallback = loadResultCallback;
		}
		
		public function loadRemoteFile(fileId:String, fileName:String):void 
		{
			this.fileId = fileId;
			this.fileName = fileName;
			
			if (loader)
			{
				throw new Error("FileLoader: load already started in this instance");
			}
			
			loader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE, onLoadComplete);
			loader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, onResponseStatus);
			loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, onStatus);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onLoadIOError);
			loader.addEventListener(ProgressEvent.PROGRESS, onLoadProgress);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			var path:String;
			if (fileId != null && fileId != "")
			{
				path = Config.URL_PHP_CORE_SERVER_FILE + "?method=files.get&uid=" + fileId + "&key=" + Auth.key;
			}
			
			loader.load(new URLRequest(path));
		}
		
		private function onLoadIOError(e:IOErrorEvent):void 
		{
			cancelLoad();
			if (loadResultCallback != null)
			{
				loadResultCallback(new LoadFileData(fileId, LOAD_IO_ERROR, null));
			}
		}
		
		public function cancelLoad():void 
		{
			if (loader)
			{
				removeListeners();
				
				try 
				{
					loader.close();
				}
				catch(e:Error) 
				{
					//trace("An error occurred " + e.toString());
				}
			}
			loader = null;
		}
		
		public function dispose():void 
		{
			cancelLoad();
			loadResultCallback = null;
		}
		
		public function getFileName():String 
		{
			return fileName;
		}
		
		private function removeListeners():void 
		{
			loader.removeEventListener(Event.COMPLETE, onLoadComplete);
			loader.removeEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, onResponseStatus);
			loader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, onStatus);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, onLoadIOError);
			loader.removeEventListener(ProgressEvent.PROGRESS, onLoadProgress);
			loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
		}
		
		private function onSecurityError(e:SecurityErrorEvent):void 
		{
			cancelLoad();
			if (loadResultCallback != null)
			{
				loadResultCallback(new LoadFileData(fileId, LOAD_ERROR, null));
			}
		}
		
		private function onResponseStatus(e:HTTPStatusEvent):void 
		{
			
		}
		
		private function onStatus(e:HTTPStatusEvent):void 
		{
			
		}
		
		private function onLoadProgress(e:ProgressEvent):void 
		{
			if (loadResultCallback != null)
			{
				if (fileSize == -1)
				{
					loadResultCallback(new LoadFileData(fileId, FILE_SIZE, null, e.bytesTotal));
					fileSize = e.bytesTotal;
				}
				loadResultCallback(new LoadFileData(fileId, PROGRESS, null, Math.round(e.bytesLoaded * 100 / e.bytesTotal)));
			}
		}
		
		private function onLoadError(e:IOErrorEvent):void 
		{
			cancelLoad();
			if (loadResultCallback != null)
			{
				loadResultCallback(new LoadFileData(fileId, LOAD_ERROR));
			}
		}
		
		private function onLoadComplete(e:Event):void 
		{
			loadResultCallback(new LoadFileData(fileId, COMPLETE, (e.target as URLLoader).data));
			
			cancelLoad();
		}
		
		private function onFileSaveResult(resultFileId:String, isError:Boolean):void 
		{
			if (resultFileId == fileId)
			{
				if (isError)
				{
					loadResultCallback(new LoadFileData(fileId, LOAD_ERROR));
				}
				else {
					loadResultCallback(new LoadFileData(fileId, COMPLETE));
				}
				
				WorkerMain.S_FILE_SAVE_RESULT.remove(onFileSaveResult);
			}
		}
	}
}