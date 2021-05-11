package com.dukascopy.connect.sys.imageManager {
	import com.adobe.crypto.MD5;
	import com.adobe.images.BitString;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.crypter.Crypter;
	import com.dukascopy.connect.sys.crypter.ImageCrypter;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.phonebookManager.PhonebookManager;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.utils.ImageCrypterOld;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import com.telefision.sys.signals.Signal;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.JPEGEncoderOptions;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.PNGEncoderOptions;
	import flash.events.Event;
	import flash.events.StatusEvent;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BlurFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author ...
	 */
	public class ImageUploader implements FileUploader {
		
		public static const STATUS_START:String = 'startCrypt';
		public static const STATUS_START_UPLOAD:String = 'startUploading';
		public static const STATUS_PROGRESS:String = 'uploading';
		public static const STATUS_ERROR:String = 'error';
		public static const STATUS_COMPLETED:String = 'completed';
		private var currentImageUID:String;

		private static var filesToUpload:Array = null;
		
		/**/
		static public const EXT:String = "png";
		static private var encoderOptions:PNGEncoderOptions = new PNGEncoderOptions(true);
		static private var stock:/*ImageUploader*/Array;
		/**
		static public const EXT:String = "jpg";
		static private var encoderOptions:JPEGEncoderOptions = new JPEGEncoderOptions(96);
		/**/
		
		public static var S_FILE_UPLOAD_STATUS:Signal = new Signal("ImageUploader.S_FILE_UPLOAD_STATUS");
		public static var S_FILE_UPLOADED:Signal = new Signal("ImageUploader.S_FILE_UPLOADED");
		
		public static var S_ON_FILE_UPLOAD_SUCCESS:Signal = new Signal("ImageUploader.S_ON_FILE_UPLOAD_SUCCESS");
		//public static var S_ON_FILE_UPLOAD_FAIL:Signal = new Signal("ImageUploader.S_ON_FILE_UPLOAD_FAIL");
		
		/**
		 * 
		 * @param	bmp			ImageBitmapData - resized to proper size
		 * @param	chatUID		String
		 * @param	title		String
		 * @param	imageKey	String
		 */
		static public function uploadChatImage(
												bmp:ImageBitmapData, 
												chatUID:String, 
												title:String, 
												imageKey:String, 
												unicalID:String = "",
												puzzleData:Object = null):void {
			if (bmp == null)
				return;
			if (filesToUpload == null)
				filesToUpload = [];
			if (stock == null)
				stock = [];
			var imgUpld:ImageUploader = new ImageUploader(new PewPew(), bmp, imageKey, chatUID, title, unicalID, puzzleData);
			stock.push(imgUpld);
		}
		
		static public function getProcessingImages():Array {
			if (stock == null)
				return null;
			if (ChatManager.getCurrentChat() == null)
				return null;
			var chatUID:String = ChatManager.getCurrentChat().uid;
			var l:int = stock.length;
			var res:Array = [];
			for (var n:int = 0; n < l; n++)
				if (stock[n].chatUID == chatUID)
					res.push(stock[n]);
			return res;
		}
		
		// INSTANCE
		//private var imageKey:String;
		private var bmp:ImageBitmapData;
		private var thumb:ImageBitmapData;
		public var chatUID:String;
		//private var title:String;
		private var currentPosition:int = 0;
		private var currentFile:int = 1;
		private var chunkSize:int = Config.CHUNK_SIZE;
		private var currentFileToSend:ByteArray;
		private var fileName:String;
		private var pngThumb:ByteArray;
		private var pngImage:ByteArray;
		private var currentLength:int;
		
		private var _unicalID:String;
		public function get unicalID():String{return _unicalID; }
		
		public function ImageUploader(pewPew:PewPew, bmp:ImageBitmapData, imageKey:String, chatUID:String, title:String, unicalID:String = "", puzzleData:Object = null){
			this.puzzleData = puzzleData;
			_unicalID = unicalID;
			//this.title = title;
			this.chatUID = chatUID;
			S_FILE_UPLOAD_STATUS.invoke(STATUS_START, this, null);
			//this.imageKey = imageKey;
			this.bmp = bmp;
			// create thumbnail
			fileName = "f_" + MD5.hash(new Date().getTime() + '') + "" + MD5.hash(Auth.key).substr(0, 8);
			
			if (bmp == null || bmp.isDisposed == true)
			{
				S_FILE_UPLOAD_STATUS.invoke(STATUS_ERROR, this, null);
				return;
			}
			
			thumb = ImageManager.resize(bmp, Config.MAX_UPLOAD_THUMB_SIZE, Config.MAX_UPLOAD_THUMB_SIZE, ImageManager.SCALE_PORPORTIONAL, false, true, "ImageUploader.thumb");
			
			if (puzzleData != null)
			{
				var blur:BlurFilter = new BlurFilter();
				blur.blurX = Config.FINGER_SIZE * .3;
				blur.blurY = Config.FINGER_SIZE * .3; 
				blur.quality = BitmapFilterQuality.MEDIUM;
				thumb.applyFilter(thumb, new Rectangle(0, 0, thumb.width, thumb.height), new Point(0, 0), blur);
			}
			
			imageWidth = bmp.width;
			imageHeight = bmp.height;
			
			ImageCrypter.encrypt(bmp.encode(bmp.rect, new JPEGEncoderOptions(87)), imageKey, 
				function(ba: ByteArray): void
				{
					bmp.dispose();
					bmp = null;
					ImageCrypter.encrypt(thumb.encode(thumb.rect, new JPEGEncoderOptions(87)), imageKey, 
						function(ba2: ByteArray): void
						{
							thumb.dispose();
							thumb = null;
							onImagesCrypted(ba, ba2);
						});
				});
		}
		
		private function onImagesCrypted(imageCrypted:ByteArray, thumbCrypted:ByteArray):void {
			pngImage = imageCrypted;
			pngThumb = thumbCrypted;
			pngImage.position = pngImage.length;
			pngThumb.position = pngThumb.length;
			pngImage.writeBytes(ImageCrypterOld.getJpegXORFlag());
			pngThumb.writeBytes(ImageCrypterOld.getJpegXORFlag());
			pngImage.position = 0;
			pngThumb.position = 0;
			var t:ImageUploader = this;
			TweenMax.delayedCall(1, function():void{
				TweenMax.delayedCall(1, function():void {
					S_FILE_UPLOAD_STATUS.invoke(STATUS_START_UPLOAD, t, null);
					pngImage.position = 0;
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
			
		//	MobileGui.stage.addChild(new Bitmap(bmp));
		}
		
		private static var _point:Point;
		private static function point(x:int, y:int):Point {
			_point ||= new Point();
			_point.x = x;
			_point.y = y;
			return _point;
		}
		
		private static var _rectangle:Rectangle;
		private var imageWidth:int;
		private var imageHeight:int;
		public var puzzleData:Object;
		
		private static function rectangle(x:int, y:int, width:int, height:int):Rectangle {
			_rectangle ||= new Rectangle();
			_rectangle.x = x;
			_rectangle.y = y;
			_rectangle.width= width;
			_rectangle.height = height;
			return _rectangle;
		}
		
		/*private function onUploadStatus(e:StatusEvent):void {
			trace("STATUS UPLOAD", e.toString());
		}*/
		
		private function sendChunk():void {
			echo("ImageUploader", "setChunk");
			currentFileToSend = (currentFile == 0)?pngImage:pngThumb;
			var chunk:ByteArray = new ByteArray();
			currentLength = chunkSize;
			if (currentFileToSend.position + currentLength > currentFileToSend.length)
				currentLength = currentFileToSend.length - currentFileToSend.position;
				
			currentFileToSend.readBytes(chunk, 0, currentLength);
			//trace('READ BYTES FROM: ' + currentFileToSend.position + ' ' + currentLength+', file size: '+chunk.length);
			PHP.file_chunkUpload(onChunkUploaded, chunk, fileName, currentFile, chunk.length, currentFileToSend.length, currentPosition,chatUID, 'png', true, currentImageUID);
		}
		
		public function getChatUID():String
		{
			return chatUID;
		}
		
		private function onChunkUploaded(r:PHPRespond):void {

			if (r.error == false) {
				if (r.data.status == 'progress') {
					var total:int = pngImage.length + pngThumb.length;
					var uploaded:int = currentFileToSend.position;
					if (currentFile == 1)
						uploaded += pngImage.length;
					S_FILE_UPLOAD_STATUS.invoke(STATUS_PROGRESS, this, [total, uploaded]);
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
						
						if (r.data.completionData)
						{
							currentImageUID = r.data.completionData.uid;
							r.data.completionData.width = imageWidth;
							r.data.completionData.height = imageHeight;
							S_FILE_UPLOADED.invoke(this, r.data.completionData);
							S_ON_FILE_UPLOAD_SUCCESS.invoke(this, r.data.completionData);
						}
						
						currentFile = 0;
						sendChunk();
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
				if(currentFileToSend.position>0)
					currentFileToSend.position -= currentLength;
				TweenMax.delayedCall(5, sendChunk);
			} else {
				completed(true);
			}
			// TODO - RESEND CHUNK!!
			r.dispose();
		}
		
		private function completed(err:Boolean = false, data:Object = null):void {

			var l:int = stock.length;
			for (var i:int = 0; i < l; i++) {
				if (stock[i] == this) {
					stock.splice(i, 1);
					break;
				}
			}
			S_FILE_UPLOAD_STATUS.invoke(STATUS_COMPLETED,this,null);
		}
	}
}

class PewPew { };