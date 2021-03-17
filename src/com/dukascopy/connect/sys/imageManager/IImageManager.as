package com.dukascopy.connect.sys.imageManager 
{
	import com.telefision.sys.signals.Signal;
	import flash.display.BitmapData;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public interface IImageManager 
	{ 
		function loadImage(url:String, callBack:Function, saveToDisk:Boolean, fromLocalStoreOnly:Boolean):Boolean;
		function unloadImage(url:String):void;
		function getImageFromCache(url:String):ImageBitmapData;
		function getImageLoadersCount():int;
		function disposeNowAllImages():void;
		function cacheSticker(stickerId:String, stickerBD:ImageBitmapData):void;
		function disposeCurrentStickers():void;
		function cancelLoad(url:String, callBack:Function):void;
		
		function get S_LOAD_PROGRESS():Signal
	}
}