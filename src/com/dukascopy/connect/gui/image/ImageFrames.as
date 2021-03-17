package com.dukascopy.connect.gui.image
{
	import com.dukascopy.connect.gui.lightbox.UI;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class ImageFrames extends Sprite
	{
		private var frames:Object = new Object();
		private var _currentFrame:String;
		private var maxWidth:Number = 0;
		private var maxHeight:Number = 0;
		
		public function ImageFrames()
		{
			//!TODO: implement frame removing, in case of it - recalculate maxWidth;
		}
		
		public function addFrame(displayObject:DisplayObject, frameName:String):void
		{
			if (frames[frameName])
			{
				clearFrameData(frameName);
			}
			var image:Bitmap = new Bitmap(UI.getSnapshot(displayObject, StageQuality.HIGH, "ImageFrames.frame"));
			image.smoothing = true;
			frames[frameName] = image;
			addChild(image);
			image.visible = false;
			maxWidth = Math.max(maxWidth, image.width);
			maxHeight = Math.max(maxHeight, image.height);
		}
		
		public function getWidth():Number
		{
			return maxWidth * scaleX;
		}
		
		public function getHeight():Number
		{
			return maxHeight * scaleY;
		}
		
		private function clearFrameData(frameName:String):void
		{
			if (frames[frameName])
			{
				UI.destroy(frames[frameName]);
			}
			frames[frameName] = null;
			delete frames[frameName];
		}
		
		public function toFrame(frameName:String):void
		{
			if (_currentFrame != frameName)
			{
				hideFrame(_currentFrame);
				_currentFrame = frameName;
				showFrame(_currentFrame);
			}
		}
		
		private function showFrame(frameName:String):void
		{
			if (frames[frameName])
			{
				frames[frameName].visible = true;
			}
		}
		
		private function hideFrame(frameName:String):void
		{
			if (!frameName)
			{
				return;
			}
			
			if (frames[frameName])
			{
				frames[frameName].visible = false;
			}
		}

		public function getCurrentBitmap():Bitmap{
			return	getBitmapByName(_currentFrame);
		}

		public function getBitmapByName(name:String = ""):Bitmap
		{
			var bm:Bitmap = frames[name];
			if (bm != null)
			{
				bm.visible = true;
				return bm;
			}
			return null;
		}


		public function dispose():void
		{
			_currentFrame = null;
			for (var key:String in frames)
			{
				clearFrameData(key);
				delete frames[key];
			}
			frames = null;
		}

		public function get currentFrame():String {
			return _currentFrame || "";
		}
	}
}