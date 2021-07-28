package com.dukascopy.connect.sys 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.FileUploadData;
	import com.dukascopy.connect.data.MediaFileData;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.imageManager.FileUploader;
	import com.dukascopy.connect.sys.nativeExtensionController.NativeExtensionController;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.vo.ChatSystemMsgVO;
	import com.dukascopy.langs.Lang;
	import com.telefision.sys.signals.Signal;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	/**
	 * ...
	 * @author ...
	 */
	public class DocumentUploader implements FileUploader
	{
		public static var S_UPLOAD_STATUS:Signal = new Signal("DocumentUploader.S_UPLOAD_STATUS");
		
		private static var filesToUpload:Array = null;
		static private var stock:/*VideoUploader*/Array;
		
		private static var _point:Point;
		private static function point(x:int, y:int):Point {
			_point ||= new Point();
			_point.x = x;
			_point.y = y;
			return _point;
		}
		
		private static var _rectangle:Rectangle;
		private static function rectangle(x:int, y:int, width:int, height:int):Rectangle {
			_rectangle ||= new Rectangle();
			_rectangle.x = x;
			_rectangle.y = y;
			_rectangle.width= width;
			_rectangle.height = height;
			return _rectangle;
		}
		
		/**
		 * 
		 * @param	bmp			ImageBitmapData - resized to proper size
		 * @param	chatUID		String
		 * @param	title		String
		 * @param	imageKey	String
		 */
		static public function upload(media:MediaFileData, chatUID:String):void {
			if (filesToUpload == null)
				filesToUpload = [];
			if (stock == null)
				stock = [];
			
			var uploader:DocumentUploader = new DocumentUploader(media, chatUID);;
			uploader.loadFile();
			stock.push(uploader);
		}
		
		static public function cancelUpload(id:String):void 
		{
			var uploader:DocumentUploader;
			if (stock != null && stock.length > 0)
			{
				var l:int = stock.length;
				for (var i:int = 0; i < l; i++) 
				{
					uploader = stock[i] as DocumentUploader;
					if (uploader.unicalID == id)
					{
						uploader.cancelUpload();
						stock.splice(i, 1);
						break;
					}
				}
			}
		}
		
		//////////////////////////////////////
		///////////// instance ///////////////
		//////////////////////////////////////
		
		public var chatUID:String;
		private var videoFile:ByteArray;
		private var _unicalID:String;
		private var mediaData:MediaFileData;
		
		public function get unicalID():String{return _unicalID; }
		
		public function DocumentUploader(mediaData:MediaFileData, chatUID:String){
			_unicalID = Math.random().toString();
			this.chatUID = chatUID;
			this.mediaData = mediaData;
		}
		
		public function getChatUID():String
		{
			return chatUID;
		}
		
		private function cancelUpload():void 
		{
			S_UPLOAD_STATUS.invoke(getUploadData(FileUploadData.CANCEL));
			completed();
		}
		
		private function getUploadData(status:String):FileUploadData
		{
			var result:FileUploadData = new FileUploadData();
			result.status = status;
			result.id = unicalID;
			if (mediaData)
			{
				result.fileName = mediaData.name;
			}
			else
			{
				result.fileName = "";
			}
			return result;
		}
		
		private function loadFile():void 
		{
			if (mediaData.path != null)
			{
				var file:File = new File(mediaData.path);
				if (file.exists)
				{
					var zStream:FileStream = new FileStream();
					zStream.open(file, FileMode.READ);
					var bytes:ByteArray = new ByteArray();
					bytes.endian = Endian.LITTLE_ENDIAN; 
					zStream.readBytes(bytes);
					zStream.close();
					zStream = null;
					file = null;
					
					videoFile = bytes;
					
					sendFile();
					
					S_UPLOAD_STATUS.invoke(getUploadData(FileUploadData.START));
				}
				else
				{
					completed(true);
				}
			}
		}
		
		private function sendFile():void 
		{
			PHP.addDocument(onUploaded, mediaData.chatUID, videoFile, mediaData.name);
		}
		
		private function onUploaded(respond:PHPRespond):void 
		{
			echo("file:", "onUploaded: ");
			if (respond.error)
			{
				ToastMessage.display(respond.errorMsg);
			}
			else
			{
				if (respond.data != null && "uid" in respond.data && respond.data.uid != null)
				{
					sendMessage(respond.data.uid, respond.data.size);
				}
				else
				{
					ToastMessage.display(Lang.serverError);
				}
			}
			completed(respond.error);
			respond.dispose();
		}
		
		private function sendMessage(fileUID:String, size:Number):void 
		{
			var message:Object = new Object();
			message.type = ChatSystemMsgVO.TYPE_FILE;
			message.method = ChatSystemMsgVO.METHOD_FILE_SENDED;
			message.fileType = ChatSystemMsgVO.FILETYPE_GENERAL;
			message.additionalData = fileUID;
			message.size = size;
			message.title = mediaData.name;
			
			ChatManager.sendMessageToOtherChat(Config.BOUNDS + JSON.stringify(message), chatUID, mediaData.key, false);
		}
		
		private function completed(err:Boolean = false):void
		{
			NativeExtensionController.removeFile(mediaData.path);
			
			if (err)
			{
				S_UPLOAD_STATUS.invoke(getUploadData(FileUploadData.FAIL));
			}
			else
			{
				S_UPLOAD_STATUS.invoke(getUploadData(FileUploadData.DONE));
			}
			
			var l:int = stock.length;
			for (var i:int = 0; i < l; i++) {
				if (stock[i] == this) {
					stock.splice(i, 1);
					break;
				}
			}
		}
	}
}