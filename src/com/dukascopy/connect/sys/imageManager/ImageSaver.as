package com.dukascopy.connect.sys.imageManager {
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.crypter.Crypter;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.store.Store;
	import com.greensock.TweenMax;
	import flash.display.BitmapData;
	import flash.filesystem.File;
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author Igor Bloom
	 */
	public class ImageSaver {
		static public const PREFIX:String = "!";
		static public const JPEG_PRREFIX:String = "~";
		
		static private var queue:Array = [];
		static private var busy:Boolean = false;
		static private var inited:Boolean = false;
		static private var currentSaveProcess:Array;
		
		public function ImageSaver() {
			
		}
		
		public static function init():void {
			if (inited)
				return;
			inited = true;
			Auth.S_NEED_AUTHORIZATION.add(onAuthNeeded);
		}
		
		static public function stopSaveAll():void {
			onAuthNeeded();
		}
		
		static private function onAuthNeeded():void {
			if (queue != null) {
				var l:int = queue.length;
				var n:int = 0;
				for (n; n < l; n++) {
					if(queue[n]!=null && queue[n][1]!=null && queue[n][1] is ImageBitmapData){
						var bmp:ImageBitmapData = queue[n][1];
						bmp.saving = false;
					}
				}
			}
			queue = [];
		}
		
		static public function saveImage(cachedFileName:String, bmp:ImageBitmapData, imageURL:String):void {
			init();
			
			if (bmp.isDisposed)
			{
				processNext();
				return;
			}
				
			if (bmp.isAsset)
			{
				processNext();
				return;
			}
			
			//FIND IN QUEUE
			var n:int = 0;
			var l:int = queue.length;
			for (n; n < l; n++) {
				if (queue[n] != null && queue[n][0] == cachedFileName) {
					echo("ImageSaver", "saveImage", "IMAGE ALREADY SAVING: " + cachedFileName);
					processNext();
					return;
				}
			}
			
			if (currentSaveProcess != null && currentSaveProcess[0] == cachedFileName)
			{
				processNext();
				return;
			}
			
			bmp.saving = true;
			echo("ImageSaver","saveImage", "SAVE IMAGE TO DISK! " + cachedFileName);
			// IF BUSY, ADD TO QUEUE
			if (busy == true) {
				queue.push([cachedFileName, bmp, imageURL]);
				return;
			}
			
			busy = true;
			
			var prefix:String = bmp.decrypted?PREFIX:"";
			
			var ba:ByteArray = new ByteArray();
			ba.writeUnsignedInt(bmp.width); // write Width
			ba.writeUnsignedInt(bmp.height); // write Height
			ba.writeBytes(bmp.getPixels(bmp.rect)); // Write pixels
			
			currentSaveProcess = [cachedFileName, bmp, imageURL];
			processSaveBytes(ba, prefix, cachedFileName, bmp, imageURL);
		}
		
		static private function processNext():void 
		{
			if (busy == true)
			{
				return;
			}
			
			if (queue.length > 0) {
				var q:Array = queue.pop();
				if (q != null && q.length == 3)
				{
					if (q[1] is ImageBitmapData)
					{
						saveImage(q[0], q[1], q[2]);
					}
					else if(q[1] is ByteArray)
					{
						saveJPEGImageData(q[0], q[1], q[2]);
					}
					else
					{
						processNext();
					}
				}
				else
				{
					processNext();
				}
			}
			else
			{
				currentSaveProcess = null;
			}
		}
		
		static private function processSaveBytes(ba:ByteArray, prefix:String, cachedFileName:String, bmp:ImageBitmapData = null, imageURL:String = null):void 
		{
			TweenMax.delayedCall(1, function():void {
				echo("ImageSaver", "saveImage", "TweenMax.delayedCall");
				
				Store.saveFile(Store.storeDirectory.nativePath + File.separator + prefix+cachedFileName, ba,
					function(data:Object,err:Boolean):void {
						// IMAGE SAVED OR NOT
						if (currentSaveProcess != null && currentSaveProcess[1] != null && 
							(currentSaveProcess[1] is ImageBitmapData))
						{
							(currentSaveProcess[1] as ImageBitmapData).saving = false;
						}
						currentSaveProcess = null;
						ba.clear();
						ImageManager.S_IMAGE_SAVED.invoke(imageURL);
						TweenMax.delayedCall(1, function():void {
							echo("ImageSaver","saveImage","TweenMax.delayedCall internal TweenMax.delayedCall");
							busy = false;
							
							processNext();
						}, null, true);
					},
				false);
			},null, true);
		}
		
		static public function stopSave(cachedFileName:String):void {
			init();
			
			// todo - check if currently saving some?
				// todo - if curently saving given url - then stop saving
			// todo - check given url in queue, if exits - remove
			
			if (queue == null)
				return;
			var n:int = 0;
			var l:int = queue.length;
			for (n; n < l; n++) {
				if (queue[n] != null && queue[n][0] == cachedFileName) {
					queue.splice(n, 1);
					return;
				}
			}
		}
		
		static public function saveJPEGImageData(cachedFileName:String, imageData:ByteArray, imageURL:String):void 
		{
			if (currentSaveProcess != null && currentSaveProcess[0] == cachedFileName)
			{
				processNext();
				return;
			}
			currentSaveProcess = [cachedFileName, imageData, imageURL];
			init();
			
			//FIND IN QUEUE
			var n:int = 0;
			var l:int = queue.length;
			for (n; n < l; n++)
			{
				if (queue[n] != null && queue[n][0] == cachedFileName)
				{
					echo("ImageSaver","saveJPEGImageData","IMAGE ALREADY SAVING: " + cachedFileName);
					return;
				}
			}
			
			echo("ImageSaver","saveJPEGImageData", "SAVE IMAGE TO DISK! " + cachedFileName);
			// IF BUSY, ADD TO QUEUE
			if (busy == true) {
				queue.push([cachedFileName, imageData, imageURL]);
				return;
			}
			
			busy = true;
			processSaveBytes(imageData, JPEG_PRREFIX, cachedFileName, null, imageURL);
		}
		
		static public function getItemInSaveProcess(cachedFileName:String):* 
		{
			if (currentSaveProcess && currentSaveProcess[0] == cachedFileName)
			{
				return currentSaveProcess[1];
			}
			
			if (queue)
			{
				var l:int = queue.length;
				for (var i:int = 0; i < l; i++) 
				{
					if ((queue[i] is Array) && (queue[i] as Array).length == 2 && (queue[i] as Array)[0] == cachedFileName)
					{
						return (queue[i] as Array)[1];
					}
					else if ((queue[i] is Array) && (queue[i] as Array).length == 3 && (queue[i] as Array)[0] == cachedFileName)
					{
						return (queue[i] as Array)[1];
					}
				}
			}
			return null;
		}
		
		static public function isInSaveProcess(name:String):Boolean 
		{
			if (currentSaveProcess != null && currentSaveProcess[2] == name)
			{
				return true;
			}
			
			if (queue)
			{
				var l:int = queue.length;
				for (var i:int = 0; i < l; i++) 
				{
					if ((queue[i] is Array) && (queue[i] as Array).length == 3 && (queue[i] as Array)[2] == name)
					{
						return true;
					}
				}
			}
			return false;
		}
	}
}