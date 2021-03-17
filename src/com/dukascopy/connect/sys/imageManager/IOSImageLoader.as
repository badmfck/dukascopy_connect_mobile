package com.dukascopy.connect.sys.imageManager 
{
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.echo.echo;
	import com.greensock.TweenMax;
	import com.telefision.utils.Loop;
	import connect.DukascopyExtension;
	import flash.display.BitmapData;
	import flash.events.StatusEvent;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class IOSImageLoader implements IImageManager
	{
		private var nativeBriedge:*;
		private var imageCallbacks:Dictionary;
		
		public function IOSImageLoader() 
		{
			nativeBriedge = MobileGui.dce;
			
			imageCallbacks = new Dictionary;
			
			if (nativeBriedge)
			{
				nativeBriedge.addEventListener(StatusEvent.STATUS, onNativeResponce);
			}
			else
			{
				ApplicationErrors.add("native extension missed");
			}
		}
		
		private function onNativeResponce(e:StatusEvent):void 
		{
			const eventCodeSuccess:String = "ios_images_didLoadImage";
			const eventCodeFailed:String = "ios_images_didFailToLoadImage";
		//	const eventCodeFailedGeneral:String = "didFailToLoad";
			
			if (e.code == eventCodeSuccess || e.code == eventCodeFailed)
			{
				if (e.level != null)
				{
					if (e.code == eventCodeSuccess)
					{
						fireCallbacks(e.level, true);
					}
					else if (e.code == eventCodeFailed)
					{
						fireCallbacks(e.level, false);
					}
				}
			}
		}
		
		private function fireCallbacks(url:String, loadingSuccess:Boolean = true):void
		{
			var callbacks:Array;
			if (!imageCallbacks[url] || imageCallbacks[url].length == 0)
			{
				return;
			}
			
			var image:BitmapData = nativeBriedge.image(url);
			
			if (!image)
			{
				loadingSuccess = false;
				ApplicationErrors.add("empty image from native side");
			}
			
			var result:ImageBitmapData;
			
			if (image)
			{
				result = new ImageBitmapData("Image from DE: " + url, image.width, image.height, true);
				result.copyBitmapData(image);
				image.dispose();
				image = null;
			}
			
			var n:int = 0;
			var m:int = imageCallbacks[url].length;
			
			var __fireCallbacks:Function = function():void {
				if (n == m) {
					Loop.remove(__fireCallbacks);
					imageCallbacks[url] = null;
					delete imageCallbacks[url];
					return;
				}
				if (n > 0)
				{
					if (result)
					{
						result.incUseCount();
					}
				}
				if (imageCallbacks[url][n] != null && imageCallbacks[url][n] is Function) {
					if ((imageCallbacks[url][n] as Function).length == 2) {
						imageCallbacks[url][n](url, result);
					} else if ((imageCallbacks[url][n] as Function).length == 3) {
						imageCallbacks[url][n](url, result, loadingSuccess);
					}
				}
				n++;
			}
			TweenMax.delayedCall(1, function():void { 
				echo("IOSImageLoader","fireCallbacks", "TweenMax.delayedCall");
				Loop.add(__fireCallbacks); 		
			}, null, true);
		}
		
		static public function isAvaliable():Boolean 
		{
			return MobileGui.dce != null;
		}
		
		/* INTERFACE com.dukascopy.connect.sys.imageManager.IImageManager */
		
		public function loadImage(url:String, callBack:Function, saveToDisk:Boolean, fromLocalStoreOnly:Boolean):Boolean 
		{
			if (!imageCallbacks[url])
			{
				imageCallbacks[url] = new Array();
				addCallback(imageCallbacks[url], callBack);
			}
			else
			{
				addCallback(imageCallbacks[url], callBack);
				return false;
			}
			
			nativeBriedge.loadImage(url, saveToDisk);
			return true;
		}
		
		private function addCallback(callbacks:Array, callBack:Function):void 
		{
			var l:int = callbacks.length;
			var exist:Boolean = false;
			
			for (var i:int = 0; i < l; i++) 
			{
				if (callbacks[i] == callBack)
				{
					exist = true;
					break;
				}
			}
			
			if (!exist)
			{
				callbacks.push(callBack);
			}
		}
		
		public function unloadImage(url:String):void 
		{
			nativeBriedge.unloadImage(url, false);
		}
		
		public function getImageFromCache(url:String):ImageBitmapData 
		{
			var image:BitmapData = nativeBriedge.image(url);
			
			var result:ImageBitmapData;
			
			if (image)
			{
				result = new ImageBitmapData("Image from DE: " + url, image.width, image.height, true);
				result.copyBitmapData(image);
				image.dispose();
				image = null;
			}
			
			return result;
		}
		
		/* INTERFACE com.dukascopy.connect.sys.imageManager.IImageManager */
		
		public function getImageLoadersCount():int 
		{
			return 0;
		}
		
		/* INTERFACE com.dukascopy.connect.sys.imageManager.IImageManager */
		
		public function disposeNowAllImages():void 
		{
			//!TIDO: сделать поддержку из расширения;
		}
	}
}