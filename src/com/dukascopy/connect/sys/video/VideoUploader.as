package com.dukascopy.connect.sys.video 
{
	import com.adobe.crypto.MD5;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.MediaFileData;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.crypter.ImageCrypter;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.imageManager.FileUploader;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.imageManager.ImageUploader;
	import com.dukascopy.connect.sys.nativeExtensionController.NativeExtensionController;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.sys.ws.WSClient;
	import com.dukascopy.connect.utils.ImageCrypterOld;
	import com.dukascopy.connect.vo.ChatMessageVO;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import com.telefision.sys.signals.Signal;
	import flash.display.Bitmap;
	import flash.display.JPEGEncoderOptions;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.StatusEvent;
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
	public class VideoUploader implements FileUploader
	{
		public static const STATUS_START:String = 'startCrypt';
		public static const STATUS_START_UPLOAD:String = 'startUploading';
		public static const STATUS_PROGRESS:String = 'uploading';
		public static const STATUS_ERROR:String = 'error';
		public static const STATUS_COMPLETED:String = 'completed';
		
		public static var S_FILE_UPLOAD_STATUS:Signal = new Signal("VideoUploader.S_FILE_UPLOAD_STATUS");
		public static var S_FILE_UPLOADED_PROGRESS:Signal = new Signal("VideoUploader.S_FILE_UPLOADED_PROGRESS");
		public static var S_FILE_UPLOADED_FINISH:Signal = new Signal("VideoUploader.S_FILE_UPLOADED_FINISH");
		public static var S_FILE_UPLOADED:Signal = new Signal("VideoUploader.S_FILE_UPLOADED");
		public static var S_ON_FILE_UPLOAD_SUCCESS:Signal = new Signal("VideoUploader.S_ON_FILE_UPLOAD_SUCCESS");
		
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
		static public function uploadVideo(media:MediaFileData, chatUID:String, title:String, imageKey:String, unicalID:String = ""):void {
			if (filesToUpload == null)
				filesToUpload = [];
			if (stock == null)
				stock = [];
			
			var videoUploader:VideoUploader;
			for (var i:int = 0; i < stock.length; i++) 
			{
				if ((stock[i] as VideoUploader).getId() == media.id)
				{
					videoUploader = stock[i] as VideoUploader;
				}
			}
			if (videoUploader == null)
			{
				videoUploader = new VideoUploader(media, imageKey, chatUID, title, unicalID);
				videoUploader.start();
				stock.push(videoUploader);
			}
			else
			{
				videoUploader.updateData(media);
			}
		}
		
		private function updateData(media:MediaFileData):void 
		{
			mediaData.path = media.path;
			if (mediaData.localResource == null)
			{
				mediaData.localResource = media.localResource;
			}
			
			mediaData.duration = media.duration;
			
			if (videoData != null)
			{
				videoData.localResource = mediaData.localResource;
				videoData.path = mediaData.path;
				videoData.duration = mediaData.duration;
			}
			
			if (imageUploaded)
			{
				loadVideo();
			}
		}
		
		static public function getProcessingVideos():Array {
			if (stock == null)
				return null;
			if (ChatManager.getCurrentChat() == null)
				return null;
			var chatUID:String = ChatManager.getCurrentChat().uid;
			var l:int = stock.length;
			var res:Array = [];
			for (var n:int = 0; n < l; n++)
				if (stock[n].chatUID == chatUID && stock[n].thumbUploaded == false)
					res.push(stock[n]);
			return res;
		}
		
		static public function getProcessingVideosThumbnail():Array {
			if (stock == null)
				return null;
			if (ChatManager.getCurrentChat() == null)
				return null;
			var chatUID:String = ChatManager.getCurrentChat().uid;
			var l:int = stock.length;
			var res:Array = [];
			for (var n:int = 0; n < l; n++)
				if (stock[n].chatUID == chatUID)
				{
					if ((stock[n] as VideoUploader).thumbUploaded == false)
					{
						res.push(stock[n]);
					}
				}
			return res;
		}
		
		static public function checkMessage(message:Object, mid:Number):void 
		{
			var uploader:VideoUploader;
			if (stock != null && stock.length > 0)
			{
				var l:int = stock.length;
				for (var i:int = 0; i < l; i++) 
				{
					uploader = stock[i] as VideoUploader;
					if (uploader != null)
					{
						if (uploader.messageMid == mid && message.chatUID == uploader.chatUID)
						{
							uploader.setMessageData(message.id);
						}
					}
				}
			}
		}
		
		static public function existUploaderWithId(id:Number):Boolean 
		{
			var uploader:VideoUploader;
			if (stock != null && stock.length > 0)
			{
				var l:int = stock.length;
				for (var i:int = 0; i < l; i++) 
				{
					uploader = stock[i] as VideoUploader;
					if (uploader.messageID == id)
					{
						return true;
					}
				}
			}
			return false;
		}
		
		static public function getUploaderByMessageId(id:Number):VideoUploader 
		{
			var uploader:VideoUploader;
			if (stock != null && stock.length > 0)
			{
				var l:int = stock.length;
				for (var i:int = 0; i < l; i++) 
				{
					uploader = stock[i] as VideoUploader;
					if (uploader.messageID == id)
					{
						return uploader;
					}
				}
			}
			return null;
		}
		
		static public function cancelUploadVideo(id:Number):void 
		{
			var uploader:VideoUploader;
			if (stock != null && stock.length > 0)
			{
				var l:int = stock.length;
				for (var i:int = 0; i < l; i++) 
				{
					uploader = stock[i] as VideoUploader;
					if (uploader.messageID == id)
					{
						uploader.cancelUpload();
						stock.splice(i, 1);
						break;
					}
				}
			}
		}
		
		static public function resendVideo(message:ChatMessageVO):void 
		{
			if (message != null && message.systemMessageVO != null && message.systemMessageVO.videoVO != null)
			{
				var uploader:VideoUploader = getUploaderByMessageId(message.id);
				
				var mediaData:MediaFileData = new MediaFileData();
					mediaData.rejected = true;
					mediaData.path = message.systemMessageVO.videoVO.localResource;
					mediaData.localResource = message.systemMessageVO.videoVO.localResource;
					mediaData.error = false;
					mediaData.id = (new Date()).getTime().toString();
					mediaData.loaded = false;
					mediaData.name = message.systemMessageVO.videoVO.title;
					mediaData.percent = 0;
					mediaData.size = message.systemMessageVO.videoVO.size;
					mediaData.localResource = message.systemMessageVO.videoVO.localResource;
					mediaData.duration = message.systemMessageVO.videoVO.duration;
					mediaData.type = MediaFileData.MEDIA_TYPE_VIDEO;
					mediaData.thumbWidth = message.systemMessageVO.videoVO.thumbWidth;
					mediaData.thumbHeight = message.systemMessageVO.videoVO.thumbHeight;
					mediaData.thumbUID = message.systemMessageVO.videoVO.thumbUID;
				
				if (uploader == null)
				{
					uploader = new VideoUploader(mediaData, null, message.chatUID, "", "");
					uploader.setMessageData(message.id);
					if (stock == null)
						stock = [];
					stock.push(uploader);	
				}
				uploader.resend(mediaData);
			}
		}
		
		//////////////////////////////////////
		///////////// instance ///////////////
		//////////////////////////////////////
		
		private var thumb:ImageBitmapData;
		public var chatUID:String;
		private var currentPosition:int = 0;
		private var chunkSize:int = Config.CHUNK_SIZE;
		private var currentFileToSend:ByteArray;
		private var fileName:String;
		private var pngThumb:ByteArray;
		private var currentLength:int;
		public var currentImageUID:String;
		private var _unicalID:String;
		private var imageWidth:int;
		private var imageHeight:int;
		private var thumbLoader:Loader;
		private var videoFile:ByteArray;
		private var mediaData:MediaFileData;
		private var imageKey:String;
		private var currentFile:int = 1;
		private var videoData:MediaFileData;
		private var imageUploaded:Boolean = false;
		private var messageMid:Number;
		public var thumbUploaded:Boolean = false;
		public var messageID:Number = NaN;
		private var currentEncodeProgress:int = 0
		private var cancelled:Boolean;
		
		public function get unicalID():String{return _unicalID; }
		
		public function VideoUploader(mediaData:MediaFileData, imageKey:String, chatUID:String, title:String, unicalID:String = ""){
			_unicalID = unicalID;
			this.imageKey = imageKey;
			this.chatUID = chatUID;
			
			this.mediaData = mediaData;
		}
		
		public function start():void
		{
			loadThumb();
		}
		
		public function getChatUID():String
		{
			return chatUID;
		}
		
		public function resend(currentMediaData:MediaFileData):void 
		{
			thumbUploaded = true;
			if (fileName == null)
			{
				fileName = "f_" + MD5.hash(new Date().getTime() + '') + "" + MD5.hash(Auth.key).substr(0, 8);
			}
			
			if (!isNaN(messageID))
			{
				currentFile = 0;
				currentImageUID = mediaData.thumbUID;
				
				if (videoData == null)
				{
					videoData = currentMediaData;
				}
				videoData.rejected = false;
				videoData.error = false;
				if (!isNaN(messageID))
				{
					S_FILE_UPLOADED_PROGRESS.invoke(this, videoData);
				}
				
				loadVideo();
			}
		}
		
		public function getId():String
		{
			return mediaData.id;
		}
		
		private function cancelUpload():void 
		{
			cancelled = true;
			if (!isNaN(messageID))
			{
				videoData.rejected = true;
				S_FILE_UPLOADED_PROGRESS.invoke(this, videoData);
			}
			
			if (thumbUploaded == true)
			{
				
			}
			else
			{
				// кинуть ивент про окончание самба
			}
			TweenMax.killDelayedCallsTo(updateVideoEncodeProgress);
		}
		
		private function setMessageData(id:Number):void 
		{
			messageID = id;
		}
		
		private function loadVideo():void 
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
					
					onVideoLoaded();
				}
				else
				{
					if (videoData != null)
					{
						videoData.error = true;
						
						if (!isNaN(messageID))
						{
							S_FILE_UPLOADED_PROGRESS.invoke(this, videoData);
						}
					}
					else
					{
						//crit error;
					}
				}
			}
			else
			{
				mediaData.error = true;
				videoData.error = true;
				if (!isNaN(messageID))
				{
					S_FILE_UPLOADED_PROGRESS.invoke(this, videoData);
				}
			}
		}
		
		private function onVideoLoaded():void 
		{
			TweenMax.killDelayedCallsTo(updateVideoEncodeProgress);
			sendChunk();
		}
		
		private function loadThumb():void 
		{
			var file:File = new File(mediaData.thumb);
			try
			{
				if (file.exists)
				{
					S_FILE_UPLOAD_STATUS.invoke(STATUS_START, this, null);
					fileName = "f_" + MD5.hash(new Date().getTime() + '') + "" + MD5.hash(Auth.key).substr(0, 8);
					
					var zStream:FileStream = new FileStream();
					zStream.open(file, FileMode.READ);
					var bytes:ByteArray = new ByteArray();
					bytes.endian = Endian.LITTLE_ENDIAN; 
					zStream.readBytes(bytes);
					zStream.close();
					zStream = null;
					file = null;
					
					thumbLoader = new Loader();
					thumbLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onImageBytesLoaded);
					thumbLoader.loadBytes(bytes);
					bytes = null;
				}
				else
				{
					//remove uploader;
					var l:int = stock.length;
					for (var i:int = 0; i < l; i++) {
						if (stock[i] == this) {
							stock.splice(i, 1);
							break;
						}
					}
				}
			}
			catch (e:Error)
			{
				mediaData.error = true;
				videoData.error = true;
				if (!isNaN(messageID))
				{
					S_FILE_UPLOADED_PROGRESS.invoke(this, videoData);
				}
			}
		}
		
		private function onImageBytesLoaded(e:Event):void {
			
			thumb = new ImageBitmapData("uploadedImage", (e.target.content as Bitmap).bitmapData.width, (e.target.content as Bitmap).bitmapData.height, true, 0xFFFFFF);
			thumb.copyBitmapData((e.target.content as Bitmap).bitmapData);
			
			(e.target.content as Bitmap).bitmapData.dispose();
			(e.target.content as Bitmap).bitmapData = null;
			
			if(thumbLoader!=null){ // 
				thumbLoader.removeEventListener(Event.COMPLETE, onImageBytesLoaded);
				thumbLoader.unload();
				thumbLoader = null;
			}
			
			thumb = ImageManager.resize(thumb, Config.MAX_UPLOAD_THUMB_SIZE, Config.MAX_UPLOAD_THUMB_SIZE, ImageManager.SCALE_PORPORTIONAL, false, true, "VideoUploader.thumb");
			
			imageWidth = thumb.width;
			imageHeight = thumb.height;
			
			ImageCrypter.encrypt(thumb.encode(thumb.rect, new JPEGEncoderOptions(87)), imageKey, onThumbCrypted);
		}
		
		private function onThumbCrypted(ba:ByteArray):void 
		{
			thumb.dispose();
			thumb = null;
			
			onImageCrypted(ba);
		}
		
		private function onImageCrypted(thumbCrypted:ByteArray):void {
			pngThumb = thumbCrypted;
			pngThumb.position = pngThumb.length;
			pngThumb.writeBytes(ImageCrypterOld.getJpegXORFlag());
			pngThumb.position = 0;
			
			var t:VideoUploader = this;
			TweenMax.delayedCall(1, function():void{
				TweenMax.delayedCall(1, function():void {
					S_FILE_UPLOAD_STATUS.invoke(STATUS_START_UPLOAD, t, null);
					pngThumb.position = 0;
					sendChunk();
				}, null, true);
			}, null, true);
		}
		
		private function onBytesLoaded(e:Event):void {
			var bmp:ImageBitmapData = new ImageBitmapData("123", (e.target as LoaderInfo).loader.content.width, (e.target as LoaderInfo).loader.content.height);
			if (bmp)
				bmp.copyPixels(Bitmap((e.target as LoaderInfo).loader.content).bitmapData, rectangle(0, 0, (e.target as LoaderInfo).loader.content.width, (e.target as LoaderInfo).loader.content.height), point(0, 0));
			Bitmap((e.target as LoaderInfo).loader.content).bitmapData.dispose();
			Bitmap((e.target as LoaderInfo).loader.content).bitmapData = null;
			(e.target as LoaderInfo).loader.unload();
			
			MobileGui.stage.addChild(new Bitmap(bmp));
		}
		
		private function onUploadStatus(e:StatusEvent):void {
			trace("STATUS UPLOAD", e.toString());
		}
		
		private function sendChunk():void {
			echo("ImageUploader", "setChunk");
			
			currentFileToSend = (currentFile == 0)?videoFile:pngThumb;
			var currentPosition:Number = currentFileToSend.position;
			var chunk:ByteArray = new ByteArray();
			currentLength = chunkSize;
			if (currentFileToSend.position + currentLength > currentFileToSend.length)
				currentLength = currentFileToSend.length - currentFileToSend.position;
				
			currentFileToSend.readBytes(chunk, 0, currentLength);
			//trace('READ BYTES FROM: ' + currentFileToSend.position + ' ' + currentLength+', file size: '+chunk.length);
			var type:String = (currentFile == 0)?"doc":'png';
			var isVideo:Boolean = false;
			if (currentFile == 0)
			{
				isVideo = true;
			}
			
			if (videoData != null && videoData.error == true)
			{
				videoData.error = false;
				if (!isNaN(messageID))
				{
					S_FILE_UPLOADED_PROGRESS.invoke(this, videoData);
				}
			}
			
			PHP.file_chunkUpload(onChunkUploaded, chunk, fileName, currentFile, chunk.length, currentFileToSend.length, currentPosition, chatUID, type, true, currentImageUID, isVideo);
		}
		
		private function onChunkUploaded(r:PHPRespond):void {
		//	trace('RESPOND FROM SERVER ');
			
			if (cancelled == true)
			{
				r.dispose();
				return;
			}
			
			if (r.error == false) {
				if (r.data.status == 'progress') {
					var total:int = videoFile.length;
					if (pngThumb != null)
					{
						total += pngThumb.length;
					}
					var uploaded:int = currentFileToSend.position;
					if (currentFile == 1)
						uploaded += videoFile.length;
					if (currentFile == 1)
					{
						S_FILE_UPLOAD_STATUS.invoke(STATUS_PROGRESS, this, [total, uploaded]);
					}
					
				//	trace('progress:' + total + ',' + uploaded);
					
					if (currentFile == 0)
					{
						videoData.percent = uploaded * 360 / total;
						if (!isNaN(messageID))
						{
							S_FILE_UPLOADED_PROGRESS.invoke(this, videoData);
						}
					}
					
					sendChunk();
				}
				if (r.data.status == 'complete')
				{
					if (currentFile == 1)
					{
						//thumbnail uploaded;
						
						if (r.data.err == true) {
							S_FILE_UPLOAD_STATUS.invoke(STATUS_ERROR, this, null);
							DialogManager.alert(Lang.textWarning, Lang.fileSendingError);
							return;
						}
						
						thumbUploaded = true;
						S_FILE_UPLOAD_STATUS.invoke(STATUS_COMPLETED,this,null);
						
						if (r.data.completionData != null)
						{
							imageUploaded = true;
							
							currentImageUID = r.data.completionData.uid;
							r.data.completionData.width = imageWidth;
							r.data.completionData.height = imageHeight;
							
							videoData = new MediaFileData();
							videoData.thumbWidth = imageWidth;
							videoData.thumbHeight = imageHeight;
							videoData.thumbUID = currentImageUID;
							videoData.id = mediaData.id;
							videoData.localResource = mediaData.localResource;
							videoData.duration = mediaData.duration;
							videoData.path = mediaData.path;
							videoData.loaded = false;
							videoData.percent = 0;
							videoData.encodeProgress = currentEncodeProgress;
							
							WSClient.S_MESSAGE_SENT_ADDITIONAL.add(onMessageSent);
							
							TweenMax.delayedCall(0.3, updateVideoEncodeProgress);
							
							S_FILE_UPLOADED.invoke(this, videoData);
						}
						else
						{
							//!TODO: обработать;
						}
						currentFile = 0;
						if (mediaData.path != null)
						{
							loadVideo();
						}
					}
					else
					{
						completed(false, r.data.completionData);
					}
				}
				if (r.data.status == 'error') {
					completed(true);
				}
				r.dispose();
				return;
			}
			
			if (r.errorMsg == PHP.NETWORK_ERROR) {
				if(currentFileToSend.position > 0)
					currentFileToSend.position -= currentLength;
				TweenMax.delayedCall(5, sendChunk);
			} else {
				completed(true);
			}
			// TODO - RESEND CHUNK!!
			r.dispose();
		}
		
		private function updateVideoEncodeProgress():void 
		{
			currentEncodeProgress ++;
			videoData.encodeProgress = currentEncodeProgress;
			
			if (!isNaN(messageID))
			{
				S_FILE_UPLOADED_PROGRESS.invoke(this, videoData);
			}
			
			TweenMax.delayedCall(0.3, updateVideoEncodeProgress);
		}
		
		private function onMessageSent(senderId:String, mid:Number):void 
		{
			if (senderId != null && senderId == videoData.id)
			{
			//	WSClient.S_MESSAGE_SENT_ADDITIONAL.remove(onMessageSent);
				messageMid = mid;
			}
		}
		
		private function completed(err:Boolean = false, data:Object = null):void {
			
			NativeExtensionController.removeFile(videoData.path);
			NativeExtensionController.removeFile(videoData.thumb);
			
			TweenMax.killDelayedCallsTo(updateVideoEncodeProgress);
		//	trace('FILES UPLOADED!');
			WSClient.S_MESSAGE_SENT_ADDITIONAL.remove(onMessageSent);
			videoData.percent = 100;
			videoData.loaded = true;
			videoData.duration = mediaData.duration;
			videoData.path = mediaData.path;
			videoData.localResource = mediaData.localResource;
			
			if (videoFile != null)
			{
				videoData.size = videoFile.length;
			}
			
			if (!isNaN(messageID))
			{
				if (err == true)
				{
					videoData.error = true;
					S_FILE_UPLOADED_PROGRESS.invoke(this, videoData);
				}
				else
				{
					S_FILE_UPLOADED_FINISH.invoke(this, videoData);
				}
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