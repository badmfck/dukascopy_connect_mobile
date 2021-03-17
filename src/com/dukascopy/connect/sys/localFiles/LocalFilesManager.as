package com.dukascopy.connect.sys.localFiles 
{
	import assets.FileIconArchive;
	import assets.FileIconGeneral;
	import assets.FileIconPdf;
	import assets.FileTypeIconDoc;
	import com.adobe.crypto.MD5;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.sys.notificationManager.InnerNotificationManager;
	import com.dukascopy.connect.sys.notificationManager.NotificationVO;
	import com.dukascopy.connect.type.FileFormat;
	import com.dukascopy.connect.type.LocalFileStatus;
	import com.dukascopy.langs.Lang;
	import com.telefision.sys.signals.Signal;
	import flash.filesystem.File;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class LocalFilesManager 
	{
		static private var filesStatuses:Array = new Array();
		static private var filesLoaders:Vector.<FileLoader> = new Vector.<FileLoader>();
		static private var _storeDirectory:String;
		
		static public const S_FILE_LOAD_STATUS:Signal = new Signal("LocalFilesManager.S_FILE_LOAD_STATUS");
		
		public function LocalFilesManager() 
		{
			
		}
		
		static public function get storeDirectory():String {
			if (_storeDirectory == null)
				if (Config.PLATFORM_ANDROID)
				{
					_storeDirectory = File.documentsDirectory.nativePath + File.separator + "download";
				}
				else if (Config.PLATFORM_APPLE)
				{
					_storeDirectory = File.applicationStorageDirectory.nativePath;
				}
				else {
					_storeDirectory = File.applicationStorageDirectory.nativePath;
				}
				
			return _storeDirectory;
		}
		
		
		static public function isFileWithNameExist(fileId:String, fileName:String):Boolean 
		{
			var f:File = new File(storeDirectory + File.separator + MD5.hash(fileId) + File.separator + fileName);
			if (f)
			{
				return f.exists;
			}
			return false;
		}
		
		static public function getFileByName(fileId:String, fileName:String):String 
		{
			var f:File = new File(storeDirectory + File.separator + MD5.hash(fileId) + File.separator + fileName);
			if (f.exists)
				return f.url;
			else
				return null;
		}
		
		static public function getFileIconClassByName(fileName:String):Class 
		{
			var iconClass:Class;
			var fileType:String = getFileType(fileName);
			
			if (fileType)
			{
				fileType = fileType.toLowerCase();
				switch(fileType)
				{
					case FileFormat.DOC:
					{
						iconClass = FileTypeIconDoc;
						break
					}
					case FileFormat.ARC:
					{
						iconClass = FileIconArchive;
						break
					}
					case FileFormat.PDF:
					{
						iconClass = FileIconPdf;
						break
					}
					default:
					{
						iconClass = FileIconGeneral;
						break
					}
				}
			}
			else {
				iconClass = FileIconGeneral;
			}
			return iconClass;
		}
		
		static public function getFileType(fileName:String):String 
		{
			if (fileName)
			{
				var fileTypeArray:Array = fileName.split(".");
				if (fileTypeArray && fileTypeArray.length > 0)
				{
					return fileTypeArray[fileTypeArray.length - 1];
				}
			}
			return "";
		}
		
		static public function getFileStatus(fileId:String, fileName:String):String 
		{
			if (filesStatuses[fileId])
			{
				return filesStatuses[fileId];
			}
			else {
				var f:File = new File(storeDirectory + File.separator + MD5.hash(fileId) + File.separator + fileName);
				if (f && f.exists)
				{
					filesStatuses[fileId] = LocalFileStatus.LOADED;
					return LocalFileStatus.LOADED;
				}
				else {
					return LocalFileStatus.NOT_FOUND;
				}
			}
			return LocalFileStatus.LOAD_ERROR;
		}
		
		static public function loadFile(fileId:String, fileName:String):void 
		{
			filesStatuses[fileId] = LocalFileStatus.LOADING;
			var fileLoader:FileLoader = new FileLoader(onFileLoaded);
			filesLoaders.push(fileLoader);
			fileLoader.loadRemoteFile(fileId, fileName);
		}
		
		static public function cancelLoadFile(fileId:String):void 
		{
			if (filesStatuses[fileId])
			{
				filesStatuses[fileId] = null;
				delete filesStatuses[fileId];
			}
			
			removeLoader(fileId);
		}
		
		static private function removeLoader(fileId:String):void 
		{
			var loader:FileLoader = getFileLoader(fileId);
			if (!loader)
			{
				return;
			}
			
			var itemIndex:int = filesLoaders.indexOf(loader);
			
			if (itemIndex != -1)
			{
				filesLoaders[itemIndex].cancelLoad()
				filesLoaders[itemIndex].dispose();
				filesLoaders.splice(itemIndex, 1);
			}
		}
		
		static private function getFileLoader(fileId:String):FileLoader 
		{
			var l:int = filesLoaders.length;
			for (var i:int = 0; i < l; i++) 
			{
				if (filesLoaders[i].fileId == fileId)
				{
					return filesLoaders[i];
				}
			}
			return null;
		}
		
		static private function onFileLoaded(fileId:String, status:String, data:Object = null):void 
		{
			if (status == FileLoader.LOAD_ERROR)
			{
				filesStatuses[fileId] = LocalFileStatus.LOAD_ERROR;
				S_FILE_LOAD_STATUS.invoke(new LoadFileData(fileId, LocalFileStatus.LOAD_ERROR, data));
			}
			if (status == FileLoader.LOAD_IO_ERROR)
			{
				//not save error status if no internet connection avaliable;
			//	filesStatuses[fileId] = LocalFileStatus.LOAD_ERROR;
				S_FILE_LOAD_STATUS.invoke(new LoadFileData(fileId, LocalFileStatus.LOAD_ERROR, data));
			}
			else if (status == FileLoader.FILE_SIZE)
			{
				S_FILE_LOAD_STATUS.invoke(new LoadFileData(fileId, LocalFileStatus.FILE_SIZE, data));
			}
			else if (status == FileLoader.PROGRESS)
			{
				S_FILE_LOAD_STATUS.invoke(new LoadFileData(fileId, LocalFileStatus.PROGRESS, data));
			}
			else if (status == FileLoader.COMPLETE)
			{
				var loader:FileLoader = getFileLoader(fileId);
				var fileName:String;
				if (loader)
				{
					fileName = loader.getFileName();
				}
				displayNotificationLoadComplete(fileId, fileName);
				
				filesStatuses[fileId] = LocalFileStatus.LOADED;
				removeLoader(fileId);
				S_FILE_LOAD_STATUS.invoke(new LoadFileData(fileId, LocalFileStatus.LOADED, data));
			}
		}
		
		static private function displayNotificationLoadComplete(fileId:String, fileName:String):void 
		{
			var text:String = Lang.fileLoadedNotificationTitle;
			if (fileName)
			{
				text += ": " + fileName;
			}
			InnerNotificationManager.pushNewMessageNotification(text, onFileSelectedFromNotification, {fileId:fileId, fileName:fileName}, NotificationVO.TYPE_FILE);
		}
		
		static private function onFileSelectedFromNotification(notificationData:NotificationVO):void 
		{
			if (!notificationData || !notificationData.callbackData)
			{
				return;
			}
			var fileLink:String = LocalFilesManager.getFileByName(notificationData.callbackData.fileId, notificationData.callbackData.fileName);
			if (fileLink)
			{
				navigateToURL(new URLRequest(fileLink));
			}
		}
	}
}