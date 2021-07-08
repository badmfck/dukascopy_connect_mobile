package com.dukascopy.connect.utils {
	
	import com.adobe.crypto.MD5;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.Enums.E_IosImagesAccesState;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.nativeExtensionController.NativeExtensionController;
	import com.dukascopy.langs.Lang;
	import com.telefision.sys.signals.Signal;
	import connect.DukascopyExtension;
	import flash.display.BitmapData;
	import flash.display.PNGEncoderOptions;
	import flash.events.StatusEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileStream;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.ByteArray;
	
	/**
	 * ...
	 * @author David Gnatkivskij. Telefision TEAM Kiev.
	 */
	
	public class FilesSaveUtility {
		
		private static const onSuccessSaveImageCode:String = "didSaveImageToGallery";
		private static const onFailSaveImageCode:String = "didFailToSaveImageToGallery";
		
		static private const dukascopyFolderPath:String = "dukascopy/";
		
		static private var _signalOnImageSaved:Signal = new Signal("FilesSaveUtility._signalOnImageSaved");
		
		private static var _dukascopyExtension:DukascopyExtension;
		
		private static var savingImageName:String = "";
		
		static private var currentBytearray:ByteArray;
		static private var currentFileUrl:String;
		static private var needOpenFile:Boolean;
		
		public static function init(dce:DukascopyExtension):void {
			if (_dukascopyExtension != null) {
				return;
			}
			_dukascopyExtension = dce;
			_dukascopyExtension.removeEventListener(StatusEvent.STATUS, onCameraRollStatusEvent);
			_dukascopyExtension.addEventListener(StatusEvent.STATUS, onCameraRollStatusEvent);
		}
		
		private static function onPermissionsResult(type:String, success:Boolean):void {
			if (type == NativeExtensionController.STORAGE_PERMISSIONS) {
				NativeExtensionController.S_PERMISSION.remove(onPermissionsResult);
				if (success == true) {
					var fl:File = File.applicationStorageDirectory.resolvePath(dukascopyFolderPath + currentFileUrl);
					var fs:FileStream = new FileStream();
					fs.open(fl,"write");
					fs.writeBytes(currentBytearray);
					fs.close();
					var path:String = NativeExtensionController.saveFileToDownloadFolder(fl.nativePath, needOpenFile);
					if (path != null) {
						path += currentFileUrl;
					}
					refreshGallarey(new File(path));
					signalOnImageSaved.invoke();
				} else {
					ToastMessage.display(Lang.providePermission);
				}
			}
		}
		
		public static function saveFileToForGallery(image:BitmapData, fileUrl:String, hashName:Boolean = true, openFile:Boolean = true):void {
			if (createDukascopyDirectoryIfNotExist() == false || image == null) {
				return;
			}
			var fileName:String = getMD5ByUrl(fileUrl) + ".png";
			if (hashName == false)
			{
				fileName = fileUrl;
			}
			needOpenFile = openFile;
			var byteArray:ByteArray = image.encode(image.rect, new PNGEncoderOptions(true));
			if (Config.PLATFORM_ANDROID) {
				currentFileUrl = fileName;
				currentBytearray = byteArray;
				NativeExtensionController.S_PERMISSION.add(onPermissionsResult);
				NativeExtensionController.requestStoragePermission();
			}
			if (Config.PLATFORM_APPLE) {
				if (currentIosImageAccessState == E_IosImagesAccesState.notDetermined) {
					requestAuthorizationForSaveImages();
					return;
				}
				if (isPossibleToSaveImage) {
					if (_dukascopyExtension != null && !_dukascopyExtension.isImageAvailableInConnectFolder(fileName)) {
						savingImageName = fileName;
						_dukascopyExtension.saveImageToConnectFolderInPhotos(fileName, byteArray);
					}
				}
			}
		}
		
		private static function onCameraRollStatusEvent(e:StatusEvent):void {
			if (e.level == savingImageName && savingImageName != "") {
				if (e.code == onSuccessSaveImageCode) {
					signalOnImageSaved.invoke();
				} else if (e.code == onFailSaveImageCode) {
					DialogManager.alert(Lang.permissionInfo, Lang.somethingWentWrong);
				}
				savingImageName = "";
			}
		}
		
		public static function get signalOnImageSaved():Signal {
			return _signalOnImageSaved;
		}
		
		public static function openGalleryIfFileExists(fileUrl:String):void {
			echo("!!!", "OPREN GALLERY");
			var url:String;
			if (getIsFileExists(fileUrl)) {
				if (Config.PLATFORM_ANDROID) {
					
					NativeExtensionController.openFileInDownloads(getMD5ByUrl(fileUrl) + ".png")
					
					/*url = ("intent:#Intent;" +
						   "action=android.intent.action.ACTION_VIEW;" +
						   "type=image/*;" +
						   "end"
					);
					navigateToURL(new URLRequest(url));*/
				}
				if (Config.PLATFORM_APPLE) {
					if (_dukascopyExtension != null) {
						_dukascopyExtension.showConnectAlbumFolderInPhotos();
					}
				}
			}
		}
		
		public static function getIsFileExists(fileUrl:String):Boolean {
			var fileName:String = getMD5ByUrl(fileUrl) + ".png";
			var res:Boolean = false;
			if (Config.PLATFORM_ANDROID) {
				var fl:File = new File(getGalleryFolder() + "/" + fileName);
				if (fl.exists) {
					echo("FILE! exist", fl.nativePath, fl.url);
					res = true;
				}
				else
				{
					echo("FILE!", fileName, NativeExtensionController.existInDownloadFolder(fileName));
					
					if (NativeExtensionController.existInDownloadFolder(fileName))
					{
						res = true;
					}
				}
				
			}
			if (Config.PLATFORM_APPLE) {
				if (isPossibleToSaveImage) {
					if (_dukascopyExtension != null) {
						res = _dukascopyExtension.isImageAvailableInConnectFolder(fileName);
					}
				}
			}
			return res;
		}
		
		static private function getGalleryFolder():String {
			return MobileGui.androidExtension.getGallery();
		}
		
		private static function createDukascopyDirectoryIfNotExist():Boolean {
			if (Config.PLATFORM_APPLE == true) {
				try {
					var fl:File = File.documentsDirectory.resolvePath(dukascopyFolderPath);
					if (fl.exists) {
						return true;
					}
					fl.createDirectory();
				} catch (err:Error) {
					return false;
				}
				return true;
			} else if (Config.PLATFORM_ANDROID == true) {
				return true;
			}
			return true;
		}
		
		private static function refreshGallarey(fl:File):void {
			if (Config.PLATFORM_ANDROID) {
				if (fl != null) {
					MobileGui.androidExtension.refreshGallery(fl.nativePath);
				}
			}
		}
		
		private static function getMD5ByUrl(url:String):String {
			return MD5.hash(url);
		}
		
		public static function get currentIosImageAccessState():String {
			if (_dukascopyExtension == null)
				return E_IosImagesAccesState.denied;
			var authorizationStatus:Number = _dukascopyExtension.authorizationStatusForPhotos();
			switch(authorizationStatus) {
				case 0:
					return E_IosImagesAccesState.notDetermined;
				case 1:
					return E_IosImagesAccesState.restricted;
				case 2:
					return E_IosImagesAccesState.denied;
				case 3:
					return E_IosImagesAccesState.authorized;
				default:
					break;
			}
			return E_IosImagesAccesState.denied;
		}
		
		public static function get isPossibleToSaveImage():Boolean {
			return getIsPossibleToSaveImage();
		}
		
		public static function requestAuthorizationForSaveImages():void {
			if (Config.PLATFORM_APPLE) {
				if (currentIosImageAccessState == E_IosImagesAccesState.notDetermined) {
					if (_dukascopyExtension != null)
						_dukascopyExtension.requestAuthorizationForPhotos();
				}
			}
		}
		
		private static function getIsPossibleToSaveImage(iterationsCount:int = 0):Boolean {
			if (Config.PLATFORM_ANDROID) {
				return true;
			}
			if (Config.PLATFORM_APPLE) {
				if (iterationsCount > 2) {
					return false;
				}
				iterationsCount++;
				switch(currentIosImageAccessState) {
					case E_IosImagesAccesState.authorized:
						return true;
					case E_IosImagesAccesState.denied:
					case E_IosImagesAccesState.restricted:
						return false;
					case E_IosImagesAccesState.notDetermined:
						return false;
					default:
						break;
				}
			}
			return false;
		}
	}
}