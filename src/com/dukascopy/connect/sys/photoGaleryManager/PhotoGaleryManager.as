package com.dukascopy.connect.sys.photoGaleryManager {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.MediaFileData;
	import com.dukascopy.connect.gui.lightbox.LightBox;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.nativeExtensionController.NativeExtensionController;
	import com.dukascopy.connect.sys.photoGaleryManager.exif.ExifInfo;
	import com.dukascopy.langs.Lang;
	import com.telefision.sys.signals.Signal;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.MediaEvent;
	import flash.events.PermissionEvent;
	import flash.events.StatusEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.media.CameraRoll;
	import flash.media.CameraUI;
	import flash.media.MediaPromise;
	import flash.media.MediaType;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.FileReferenceList;
	import flash.permissions.PermissionStatus;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.IDataInput;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision AG.
	 */
	
	public class PhotoGaleryManager {
		
		static private const LANDSCAPE:int = 1;
		static private const LANDSCAPE_REVERSE:int = 3;
		static private const PORTRAIT:int = 6;
		static private const PORTRAIT_REVERSE:int = 8;
		
		static public const PUZZLE:String = "puzzle";
		static public const PASSPORT:String = "passport";
		
		static private var cameraUI:CameraUI;
		static private var mediaSource:CameraRoll;
		
		static private var loadersPool:Vector.<Loader> = new Vector.<Loader>;
		static private var counter:int = 0;
		
		static private var imageRotation:Number;
		static private var loader:Loader;
		
		static private var ibd:ImageBitmapData;
		
		static private var busy:Boolean = false;
		static private var needLightBox:Boolean;
		static private var includeVideo:Boolean;
		static private var caller:String;
		
		public static var S_GALLERY_IMAGE_LOADED:Signal = new Signal("PhotoGaleryManager.S_GALLERY_IMAGE_LOADED");
		public static var S_GALLERY_IMAGE_LOADED_PASSPORT:Signal = new Signal("PhotoGaleryManager.S_GALLERY_IMAGE_LOADED_PASSPORT");
		public static var S_GALLERY_IMAGE_LOADED_PUZZLE:Signal = new Signal("PhotoGaleryManager.S_GALLERY_IMAGE_LOADED_PUZZLE");
		public static var S_GALLERY_MEDIA_LOADED:Signal = new Signal("PhotoGaleryManager.S_GALLERY_MEDIA_LOADED");
		
		public function PhotoGaleryManager() { }
		
		static public function takeCamera(showLightBox:Boolean, includeVideoSource:Boolean = false, target:String = null):void {
			caller = target;
			if (busy == true)
				return;
			needLightBox = showLightBox;
			
			if (includeVideoSource && Config.PLATFORM_ANDROID)
			{
				MobileGui.androidExtension.removeEventListener(StatusEvent.STATUS, statusHandler);
				MobileGui.androidExtension.addEventListener(StatusEvent.STATUS, statusHandler);
				MobileGui.androidExtension.showCamera(includeVideoSource, File.applicationStorageDirectory.url);
				return;
			}
			
			if (!CameraUI.isSupported) {
				dispatchImageResult(false, null, Lang.cameraNotSupported);
				return;
			}
			if (CameraUI.permissionStatus != PermissionStatus.GRANTED && (CameraUI as Object).permissionStatus  !== undefined) {
				var cui:CameraUI = new CameraUI();
				cui.addEventListener(PermissionEvent.PERMISSION_STATUS, function(e:PermissionEvent):void {
					doTakeCamera(showLightBox);
					return;
				});
				try {
					cui.requestPermission();
				} catch (err:Error) {
					echo("PhotoGaleryManager", "takeCamera", err.message, true);
					dispatchImageResult(false, null, err.message);
				}
			} else
				doTakeCamera(showLightBox);
		}
		
		static public function doTakeCamera(showLightBox:Boolean):void {
			if (CameraUI.permissionStatus != PermissionStatus.GRANTED && (CameraUI as Object).permissionStatus  !== undefined) {
				DialogManager.alert(Lang.information, Lang.providePermission);
				return;
			}
			
			if (cameraUI != null)
			{
				cameraUI.removeEventListener(MediaEvent.COMPLETE, onPhotoIsTaken);
				cameraUI.removeEventListener(Event.CANCEL, onCameraCancelled);
				cameraUI.removeEventListener(ErrorEvent.ERROR, onCameraError);
				cameraUI = null;
			}
			
			if (!cameraUI) {
				cameraUI ||= new CameraUI();
				cameraUI.addEventListener(MediaEvent.COMPLETE, onPhotoIsTaken);
				cameraUI.addEventListener(Event.CANCEL, onCameraCancelled);
				cameraUI.addEventListener(ErrorEvent.ERROR, onCameraError);
			}
			cameraUI.launch(MediaType.IMAGE);
		}
		
		static private function onCameraError(e:ErrorEvent):void {
			dispatchImageResult(false, null, Lang.cameraError);
		}
		
		static private function onCameraCancelled(e:Event):void {
			dispatchImageResult(false, null, null);
		}
		
		static public function takeImage(showLightBox:Boolean, includeVideoSource:Boolean = false, target:String = null):void {
			caller = target;
			includeVideo = includeVideoSource;
			if (busy == true)
				return
			needLightBox = showLightBox;
			if (Config.PLATFORM_WINDOWS) {
				browseWindowsFiles();
				return;
			}
			if (Config.PLATFORM_APPLE && MobileGui.dce != null) {
				MobileGui.dce.removeEventListener(StatusEvent.STATUS, statusHandler);
				MobileGui.dce.addEventListener(StatusEvent.STATUS, statusHandler);
				if (target == PUZZLE) {
					MobileGui.dce.showPuzzleImagePicker();
				}
				else {
					MobileGui.dce.showImagePicker();
				}
				
			} else if (Config.PLATFORM_ANDROID && MobileGui.androidExtension != null && includeVideo == true){
				if (NativeExtensionController.getVersion() <= 19)
				{
					DialogManager.alert("", Lang.unsupportedAndroidVersion);
					return;
				}
				MobileGui.androidExtension.removeEventListener(StatusEvent.STATUS, statusHandler);
				MobileGui.androidExtension.addEventListener(StatusEvent.STATUS, statusHandler);
				
				MobileGui.androidExtension.pickMedia(NativeExtensionController.getStrings(NativeExtensionController.PICK_MEDIA));
			} else {
				if (CameraRoll.permissionStatus != PermissionStatus.GRANTED) {
					var cr:CameraRoll = new CameraRoll();
					cr.addEventListener(PermissionEvent.PERMISSION_STATUS, function(e:PermissionEvent):void {
						doTakeImage(showLightBox);
						return;
					});
					try {
						cr.requestPermission();
					} catch (err:Error) {
					//	doTakeImage(showLightBox);
						echo("PhotoGaleryManager", "takeCamera", err.message, true);
					}
				} else
					doTakeImage(showLightBox);
			}
		}
		
		static private function doTakeImage(showLightBox:Boolean):void {
			if (CameraRoll.permissionStatus != PermissionStatus.GRANTED) {
				/*initMediaSourceIfNull();
				mediaSource.browseForImage();*/
				DialogManager.alert(Lang.information, Lang.providePermission);
				return;
			}
			
			if (!CameraRoll.supportsBrowseForImage) {
				dispatchImageResult(false, null, Lang.galleryNotSupported);
				
				return;
			}
			initMediaSourceIfNull();
			mediaSource.browseForImage();
		}
		
		static private function dispatchImageResult(res:Boolean, image:ImageBitmapData, message:String):void 
		{
			if (caller == PUZZLE)
			{
				S_GALLERY_IMAGE_LOADED_PUZZLE.invoke(true, ibd, message);
			}
			else if (caller == PASSPORT)
			{
				S_GALLERY_IMAGE_LOADED_PASSPORT.invoke(res, image, message);	
			}
			else
			{
				S_GALLERY_IMAGE_LOADED.invoke(res, image, message);	
			}
			
			removeListeners();
		}
		
		static private function statusHandler(e:StatusEvent):void {
			var mediaData:String
			var media:Object;
			switch (e.code) {
				case "puzzlePicker": {
					if (e.level == "didCancel") {
						clearAll();
						dispatchImageResult(false, null, null);
					} else if (e.level == "didPick") {
						if (Config.PLATFORM_APPLE && MobileGui.dce != null)
						{
							imageData = MobileGui.dce.pickedImage();
							
							if (imageData != null) {
								ibd = new ImageBitmapData("uploadedImage", imageData.width, imageData.height, true, 0xFFFFFF);
								ibd.copyBitmapData(imageData);
								
								imageData.dispose();
								imageData = null;
								onImagePrepared();
							} else {
								clearAll();
								dispatchImageResult(false, null, Lang.galleryError);
							}
						}
					}
					
					break;
				}
				
				
				case "imagePicker": {
					
					if (e.level == "didCancel") {
						clearAll();
						dispatchImageResult(false, null, null);
					} else if (e.level == "didPick") {
						
						var imageData:BitmapData;
						
						if (Config.PLATFORM_APPLE && MobileGui.dce != null)
						{
							imageData = MobileGui.dce.pickedImage();
							
							if (imageData != null) {
								ibd = new ImageBitmapData("uploadedImage", imageData.width, imageData.height, true, 0xFFFFFF);
								ibd.copyBitmapData(imageData);
								
								imageData.dispose();
								imageData = null;
								onImagePrepared();
							} else {
								clearAll();
								dispatchImageResult(false, null, Lang.galleryError);
							}
						}
						else if (Config.PLATFORM_ANDROID && MobileGui.androidExtension != null)
						{
							mediaData = MobileGui.androidExtension.getPickImage();
							
							if (mediaData != null)
							{
								media = JSON.parse(mediaData);
								
								var mediaFileData:MediaFileData = new MediaFileData();
								
								if (media.type == MediaFileData.MEDIA_TYPE_IMAGE)
								{
									mediaFileData.path = media.path;
									mediaFileData.type = MediaFileData.MEDIA_TYPE_IMAGE;
									
									var file:File = new File(mediaFileData.path);
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
										createTempFile(bytes);
									}
								}
								else if (media.type == MediaFileData.MEDIA_TYPE_VIDEO)
								{
									mediaFileData.path = media.path;
									mediaFileData.thumb = media.thumb;
									mediaFileData.id = media.id;
									if ("name" in media)
									{
										mediaFileData.name = media.name;
									}
									if ("duration" in media)
									{
										mediaFileData.duration = media.duration;
									}
									if ("path" in media)
									{
										mediaFileData.localResource = media.path;
									}
									mediaFileData.type = MediaFileData.MEDIA_TYPE_VIDEO;
									
									S_GALLERY_MEDIA_LOADED.invoke(mediaFileData);
								}
							}
						}
					}
					else if (e.level == "videoStart")
					{
						if (Config.PLATFORM_ANDROID && MobileGui.androidExtension != null)
						{
							mediaData = MobileGui.androidExtension.getPickImage();
							
							if (mediaData != null)
							{
								media = JSON.parse(mediaData);
								
								mediaFileData = new MediaFileData();
								
								if (media.type == MediaFileData.MEDIA_TYPE_VIDEO)
								{
									mediaFileData.path = media.path;
									mediaFileData.thumb = media.thumb;
									mediaFileData.id = media.id;
									if ("name" in media)
									{
										mediaFileData.name = media.name;
									}
									if ("path" in media)
									{
										mediaFileData.localResource = media.path;
									}
									mediaFileData.type = MediaFileData.MEDIA_TYPE_VIDEO;
									S_GALLERY_MEDIA_LOADED.invoke(mediaFileData);
								}
							}
						}
					}
					else if (e.level == "permissionMissed")
					{
						DialogManager.alert(Lang.information, Lang.providePermission);
					}
					break;
				}
				
				case "mediaPicker": {
					if (e.level == "didCancel") {
						clearAll();
						dispatchImageResult(false, null, null);
					} else if (e.level == "didPick") {
						
						mediaData = MobileGui.androidExtension.getPickMedia();
						
						if (mediaData != null) {
							
						} else {
							clearAll();
							dispatchImageResult(false, null, Lang.galleryError);
						}
					}
					else if (e.level == "permissionMissed")
					{
						DialogManager.alert(Lang.information, Lang.providePermission);
					}
					
					break;
				}
			}
		}
		
		static private function removeListeners():void 
		{
			if (MobileGui.dce != null)
			{
				MobileGui.dce.removeEventListener(StatusEvent.STATUS, statusHandler);
			}
			else if (MobileGui.androidExtension != null)
			{
			//	MobileGui.androidExtension.removeEventListener(StatusEvent.STATUS, statusHandler);
			//	MobileGui.androidExtension.clearPickImage();
			}
		}
		
		private static function initMediaSourceIfNull():void {
			if (mediaSource == null) {
				mediaSource = new CameraRoll();
				mediaSource.addEventListener(MediaEvent.SELECT, onFileIsTaken);
				mediaSource.addEventListener(Event.CANCEL, browseCanceled);
				mediaSource.addEventListener(ErrorEvent.ERROR, mediaError);
			}
		}
		
		static public function addImageToCameraRoll(image:BitmapData):void {
			initMediaSourceIfNull();
			mediaSource.addBitmapData(image);
		}
		
		static private function mediaError(e:ErrorEvent):void {
			dispatchImageResult(false, null, Lang.galleryError);
		}
		
		static private function browseCanceled(e:Event):void {
			dispatchImageResult(false, null, null);
		}
		
		static private function browseWindowsFiles():void {
			var fl:FileReferenceList = new FileReferenceList();
			
			var __onFileLoaded:Function=function(e:Event):void{
				var f:FileReference = e.currentTarget as FileReference;
				f.removeEventListener(Event.COMPLETE, __onFileLoaded);
				createTempFile(f.data);
			}
			
			var __onWinFileSelected:Function = function(e:Event):void {
				fl.removeEventListener(Event.SELECT,__onWinFileSelected);
				var l:int = fl.fileList.length;
				for (var n:int = 0; n < l; n++) {
					var f:FileReference = fl.fileList[n];
					f.addEventListener(Event.COMPLETE, __onFileLoaded);
					f.load();
					break;
				}
			}
			fl.addEventListener(Event.SELECT, __onWinFileSelected);
			fl.addEventListener(Event.CANCEL, onWinFileSelectCancel);
			fl.browse([new FileFilter("Images", "*.png;*.jpg;*.jpeg")]);
		}
		
		static private function onWinFileSelectCancel(e:Event):void {
			dispatchImageResult(false, null, null);
		}
		
		static private function onPhotoIsTaken(e:MediaEvent):void {
			needLightBox = false;
			if (Config.PLATFORM_APPLE || Config.PLATFORM_ANDROID) {
				createFile(e.data);
				return;
			}
		}
		
		static private function onFileIsTaken(e:MediaEvent):void {
			if (Config.PLATFORM_APPLE) {
				createFile(e.data);
				return;
			}
			if (Config.PLATFORM_ANDROID) {
				try {
					if (!(e.data.file.size is Error) && e.data.file.size > 26000000) {
						dispatchImageResult(false, null, null);
						return;
					}
				} catch (err:Error) {
					echo("PhotoGaleryManager", "onFileIsTaken", err.message, true);
					return;
				}
				createFile(e.data);
				return;
			}
		}
		
		static private function createFile(mediaPromise:MediaPromise, needViewBox:Boolean = false):void {
			busy = true;
			var dataSource:IDataInput = mediaPromise.open();
			var __readImage:Function = function ():void {
				var imageBytes:ByteArray = new ByteArray();
				dataSource.readBytes(imageBytes);
				createTempFile(imageBytes);
				imageBytes = null;
			}
			var __asyncImageLoaded:Function = function(e:Event):void {
				IEventDispatcher(dataSource).removeEventListener(Event.COMPLETE, __asyncImageLoaded);
				__readImage();
			}
			if (mediaPromise.isAsync) {
				IEventDispatcher(dataSource).addEventListener(Event.COMPLETE, __asyncImageLoaded); 
			} else {
				__readImage();
			}
		}
		
		/**
		 * Get exif data, load bitmap
		 * @param	imageBytes	Bytes of image file
		 */
		static private function createTempFile(imageBytes:ByteArray):void {
			try {
				var exifData:ExifInfo = new ExifInfo(imageBytes);
				var exifOrientation:int = "Orientation" in exifData.ifds.primary ? exifData.ifds.primary["Orientation"] : -1;
				imageRotation = getRotationByOrientation(exifOrientation);
				exifData.dispose();
				exifData = null;
			} catch (e:Error) {
				imageRotation = 0;
			}
			loader = getLoader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onImageBytesLoaded);
			loader.loadBytes(imageBytes);
			imageBytes = null;
		}
		
		static private function onImageBytesLoaded(e:Event):void {
			if (ibd) {
				ibd.dispose();
				ibd = null;
			}
			
			ibd = new ImageBitmapData("uploadedImage", (e.target.content as Bitmap).bitmapData.width, (e.target.content as Bitmap).bitmapData.height, true, 0xFFFFFF);
			ibd.copyBitmapData((e.target.content as Bitmap).bitmapData);
			
			(e.target.content as Bitmap).bitmapData.dispose();
			(e.target.content as Bitmap).bitmapData = null;
			
			if (imageRotation != 0)
				ibd = ImageManager.rotate(ibd, imageRotation);
			
			if(loader!=null){ // 
				loader.removeEventListener(Event.COMPLETE, onImageBytesLoaded);
				loader.unload();
				returnLoader(loader);
				loader = null;
			}
			
			onImagePrepared();
		}
		
		static private function onImagePrepared():void {
			if (needLightBox == true){
				var bmdCopy:ImageBitmapData = new ImageBitmapData("previewImg", ibd.width, ibd.height, true, 0xFFFFFF);
				bmdCopy.copyBitmapData(ibd.clone());
				LightBox.previewBitmap(bmdCopy, onOK, onCancel);
			}	else {
				onOK();
			}
		}
		
		static private function onOK():void {
			LightBox.close();
			
			var fileTitle:String = new Date().getTime() + ' ';
			
			dispatchImageResult(true, ibd, fileTitle);
			
			clearAll();
		}
		
		static private function clearAll():void {
			busy = false;
			if (ibd != null)
				ibd.dispose();
			ibd = null
		}
		
		static private function onCancel():void {
			LightBox.close();
			clearAll();
		}
		
		static private function getRotationByOrientation(exifOrientation:int):Number {
			if (exifOrientation == LANDSCAPE)
				return 0;
			if (exifOrientation == PORTRAIT)
				return ImageManager.ANGLE_90;
			if (exifOrientation == LANDSCAPE_REVERSE)
				return ImageManager.ANGLE_180;
			if (exifOrientation == PORTRAIT_REVERSE)
				return ImageManager.ANGLE_270;
			return 0;
		}
		
		static private function returnLoader(l:Loader):void {
			loadersPool[loadersPool.length] = l;
		}
		
		static private function getLoader():Loader {
			if (loadersPool.length > 0)
				return loadersPool.pop();
			counter++;
			return new Loader;
		}
	}
}