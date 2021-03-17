package com.dukascopy.connect.sys.imageManager {
	
	import com.dukascopy.connect.utils.ImageCrypterOld;
	import com.telefision.sys.signals.Signal;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class DefaultImageManager implements IImageManager {
		
		private const _S_LOAD_PROGRESS:Signal = new Signal("DefaultImageManager.S_LOAD_PROGRESS");
		
		private var imageLoaders:Array = [];
		private var imageCache:Array = [];
		private var cleanImagesTimer:Timer;
		private var currentStickers:Array;
		
		public function DefaultImageManager() {
			cleanImagesTimer = new Timer(5000);
			cleanImagesTimer.addEventListener(TimerEvent.TIMER, checkImages);
		}
		
		private function checkImages(e:TimerEvent):void {
			ImageBitmapData.checkImages();
		}
		
		public function loadImage(url:String, callBack:Function, saveToDisk:Boolean, fromLocalStoreOnly:Boolean):Boolean {
			var plainImageURL:String;
			if (url.indexOf(ImageCrypterOld.imageKeyFlag) != -1) {
				var pathElements:Array = url.split(ImageCrypterOld.imageKeyFlag);
				plainImageURL = pathElements[0];
			} else {
				plainImageURL = url;
			}
			var l:int = imageCache.length;
			var n:int;
			for (n = 0; n < l; n++) {
				if (imageCache[n][0] == plainImageURL) {
					if (imageCache[n][1] && ImageBitmapData(imageCache[n][1]).isDisposed == false) {
						imageCache[n][1].incUseCount("loadImage.fromCache");
						if ((callBack as Function).length == 2) {
							callBack(url, imageCache[n][1])
						} else if ((callBack as Function).length == 3) {
							callBack(url, imageCache[n][1], true)
						}
						return true;					
					} else {
						imageCache.splice(n, 1);
						break;
					}
				}
			}
			l = imageLoaders.length;
			for (n = 0; n < l; n++) {
				if (imageLoaders[n].url == url) {
					if ((imageLoaders[n] as ImageLoader).disposed)
						imageLoaders.splice(n, 1);
					else
						imageLoaders[n].addCallback(callBack);
					return false;
				}
			}
			var loader:ImageLoader = new ImageLoader(imageLoaded, saveToDisk);
			loader.S_LOAD_PROGRESS.add(onLoadProgress);
			var startLoad:Boolean = loader.load(url, callBack, fromLocalStoreOnly);
			if (startLoad == true) {
				imageLoaders.push(loader);
				loader.saveToDisk = saveToDisk;
			}
			return startLoad;
		}
		
		private function onLoadProgress(url:String, loadPercent:int):void {
			S_LOAD_PROGRESS.invoke(url, loadPercent);
		}
		
		public function unloadImage(url:String):void {
			if (url.length > 10 && url.substr(0, 10) == "fromStore.") {
				url = url.slice(10);
			}
			if (url.indexOf(ImageCrypterOld.imageKeyFlag) != -1) {
				var pathElements:Array = url.split(ImageCrypterOld.imageKeyFlag);
				url = pathElements[0];
			}
			var l:int = imageLoaders.length;
			var n:int;
			for (n = 0; n < l; n++){
				if (imageLoaders[n].url == url) {
					imageLoaders[n].stopLoading();
					imageLoaders.splice(n, 1);
					break;
				}
			};
			l = imageCache.length;
			var imageURL:String;
			for (n = 0; n < l; n++) {
				imageURL = imageCache[n][0];
				if (imageURL != null && imageURL.length > 10 && imageURL.substr(0, 10) == "fromStore.")
					imageURL = imageURL.slice(10);
				if (imageURL == url) {
					if (imageCache[n][1] != null) {
						if (imageCache[n][1].isDisposed == false)
							(imageCache[n][1] as ImageBitmapData).dispose();
						if ((imageCache[n][1] as ImageBitmapData).useCount < 1) {
							imageCache[n][1] = null;
							imageCache.splice(n, 1);
						}
						break;
					}
				}
			}
		}
		
		public function getImageFromCache(url:String):ImageBitmapData {
			var n:int;
			var l:int = imageCache.length;
			for (n = 0; n < l; n++) {
				if (imageCache[n][0] == url) {
					if (imageCache[n][1] && imageCache[n][1].isDisposed == false)
						return imageCache[n][1];
					else
						return null;
				}
			}
			return null;
		}
		
		public function getImageLoadersCount():int {
			return imageLoaders.length;
		}
		
		public function disposeNowAllImages():void {
			if (imageCache == null)
				return;
			while (imageCache.length) {
				imageCache[0][1].disposeNow();
				imageCache.splice(0, 1);
			}
		}
		
		public function cacheSticker(stickerId:String, stickerBD:ImageBitmapData):void {
			if (imageCache != null) {
				if (currentStickers == null)
					currentStickers = new Array();
				currentStickers.push(stickerId);
				imageCache.push([stickerId, stickerBD]);
			}
		}
		
		public function disposeCurrentStickers():void {
			if (currentStickers && currentStickers.length > 0) {
				var l:int = currentStickers.length;
				for (var i:int = 0; i < l; i++) 
					unloadImage(currentStickers[i]);
				currentStickers.length = 0;
			}
		}
		
		public function cancelLoad(url:String, callBack:Function):void {
			var l:int = imageLoaders.length;
			var n:int;
			for (n = 0; n < l; n++) {
				if ((imageLoaders[n] as ImageLoader).url == url) {
					(imageLoaders[n] as ImageLoader).cancelLoad(url, callBack)
					if ((imageLoaders[n] as ImageLoader).existCallbacks() == false) {
						imageLoaders[n].stopLoading();
						imageLoaders.splice(n, 1);
					}
					break;
				}
			};
		}
		
		private function imageLoaded(bmd:ImageBitmapData, url:String, success:Boolean = true):void {
			n = 0;
			l = imageLoaders.length;
			for (n = 0; n < l; n++) {
				if (imageLoaders[n].url == url) {
					if ((imageLoaders[n] as ImageLoader).S_LOAD_PROGRESS != null)
						(imageLoaders[n] as ImageLoader).S_LOAD_PROGRESS.remove(onLoadProgress);
					if ((imageLoaders[n] as ImageLoader).disposed == true) {
						if (bmd != null && bmd.useCount < 1)
							bmd.dispose();
						return;
					}
					imageLoaders.splice(n, 1);
					break;
				}
			}
			if (success == true) {
				var l:int = imageCache.length;
				var n:int;
				for (n = 0; n < l; n++) {
					if (imageCache[n][0] == url) {
						if (imageCache[n][1].isDisposed == true)
							imageCache[n][1] = bmd;
						return;
					}
				}
				imageCache.push([url, bmd]);
			}
		}
		
		public function get S_LOAD_PROGRESS():Signal {
			return _S_LOAD_PROGRESS;
		}
	}
}