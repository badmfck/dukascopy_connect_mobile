package com.dukascopy.connect.sys.network 
{
	import com.dukascopy.connect.data.RemoteFileData;
	import com.dukascopy.connect.data.screenAction.IAction;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.net.URLRequest;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class DocumentUploader 
	{
		static public const FILE_NOT_FOUND:String = "fileNotFound";
		static public const SERVER_RESPONSE_WRONG_FORMAT:String = "serverResponseWrongFormat";
		static public const SERVER_RESPONSE_MISS_ARGUMENT:String = "serverResponseMissArgument";
		static public const NETWORK_ERROR:String = "networkError";
		
		static public const TYPE_DOCUMENT:String = "doc";
		
		private var successAction:IAction;
		private var failAction:IAction;
		
		private var localFile:File;
		private var started:Boolean;
		private var fileData:RemoteFileData;
		
		public function DocumentUploader(fileData:RemoteFileData, successAction:IAction, failAction:IAction = null) 
		{
			this.fileData = fileData;
			this.successAction = successAction;
			this.failAction = failAction;
		}
		
		public function start(filePath:String, uploadURL:String):void 
		{
			if (started)
			{
				return;
			}
			
			started = true;
			
			localFile = new File();
			try {
				if (filePath.indexOf("file:/") != -1)
				{
					filePath = filePath.substr(6)
				}	
				
				localFile = localFile.resolvePath(filePath);
			}
			catch (e:Error)
			{
				onError(FILE_NOT_FOUND);
				return;
			}
			if (localFile)
			{
				localFile.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, onUploadCompleteData);
				localFile.addEventListener(Event.COMPLETE, onUploadComplete);
				localFile.addEventListener(ProgressEvent.PROGRESS, onUploadProgress);
				localFile.addEventListener(IOErrorEvent.IO_ERROR, onUploadError);
				
				var request:URLRequest = new URLRequest(uploadURL);
				localFile.upload(request, TYPE_DOCUMENT, false);
			}
			else
			{
				onError(FILE_NOT_FOUND);
			}
		}
		
		private function onUploadError(e:IOErrorEvent):void 
		{
			onError(NETWORK_ERROR);
		}
		
		private function onUploadProgress(e:Event):void 
		{
			
		}
		
		private function onUploadComplete(e:Event):void 
		{
			
		}
		
		private function onUploadCompleteData(e:DataEvent):void 
		{
			var uploadResult:Object;
					
			try
			{
				uploadResult = JSON.parse(e.data);
			}
			catch (e:Error) 
			{
				onError(SERVER_RESPONSE_WRONG_FORMAT);
			}
			if (uploadResult && uploadResult.data && uploadResult.data.uid)
			{
				if (fileData)
				{
					
				}
				fileData.id = uploadResult.data.uid;
				successAction.setData(fileData);
				successAction.execute();
				clean();
			}
			else
			{
				onError(SERVER_RESPONSE_MISS_ARGUMENT);
			}
		}
		
		private function clean():void 
		{
			fileData = null;
			failAction = null;
			successAction = null;
			
			if (localFile)
			{
				localFile.removeEventListener(DataEvent.UPLOAD_COMPLETE_DATA, onUploadCompleteData);
				localFile.removeEventListener(Event.COMPLETE, onUploadComplete);
				localFile.removeEventListener(ProgressEvent.PROGRESS, onUploadProgress);
				localFile.removeEventListener(IOErrorEvent.IO_ERROR, onUploadError);
				
				localFile = null;
			}
		}
		
		private function onError(reason:String):void 
		{
			if (failAction)
			{
				//!TODO: унифицировать сообщения ошибок;
				failAction.setData(reason);
				failAction.execute();
			}
			clean();
		}
	}
}