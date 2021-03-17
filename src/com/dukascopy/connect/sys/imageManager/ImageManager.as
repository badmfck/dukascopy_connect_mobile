package com.dukascopy.connect.sys.imageManager {
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.telefision.sys.signals.Signal;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.StageQuality;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import com.adobe.crypto.MD5;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.geom.Matrix;
	import flash.system.Capabilities;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	/**
	 * ...
	 * @author Igor Bloom
	 */
	public class ImageManager {
		
		static public const SCALE_NONE:int = 0;
		static public const SCALE_PORPORTIONAL:int = 1;
		static public const SCALE_PORPORTIONAL_CENTER:int = 4;
		static public const SCALE_EXACT_FIT:int = 2;
		static public const SCALE_INNER_PROP:int = 3;
		
		public static const ANGLE_90:Number = 90 * (Math.PI / 180);
		public static const ANGLE_180:Number = 180 * (Math.PI / 180);
		public static const ANGLE_270:Number = 270 * (Math.PI / 180);
		
		public static var S_DECRYPT_START:Signal = new Signal('Auth.S_DECRYPT_START');
		public static var S_LOAD_PROGRESS:Signal = new Signal("ImageManager.S_LOAD_PROGRESS");
		public static var S_IMAGE_SAVED:Signal = new Signal("ImageManager.S_IMAGE_SAVED");
		 
		private static var _point:Point;
		private static function point(x:int, y:int):Point {
			_point ||= new Point();
			_point.x = x;
			_point.y = y;
			return _point;
		}
		
		private static var _rectangle:Rectangle;
		private static function rectangle(x:int, y:int, width:int, height:int):Rectangle
		{
			_rectangle ||= new Rectangle();
			_rectangle.x = x;
			_rectangle.y = y;
			_rectangle.width= width;
			_rectangle.height = height;
			return _rectangle;
		}
		
		private static var _matrix:Matrix;
		private static function get matrix():Matrix
		{
			_matrix ||= new Matrix();
			_matrix.identity();
			return _matrix;
		}
		
		public function ImageManager() { }
		
		static public function init():void {
			Auth.S_NEED_AUTHORIZATION.add(disposeNowAllImages);
		}
		
		/**
		 * Resize image
		 * @param	image BitmapData
		 * @param	width	int
		 * @param	height 	int
		 * @param	scaleMode int ImageManager.SCALE_ ...
		 */
		static public function resize(image:ImageBitmapData, width:int, height:int, scaleMode:int, crop:Boolean = false,clone:Boolean=false, customName:String = ""):ImageBitmapData {
			if (width == 0 || height == 0) {
				trace("ImageManager.resize()", 'WRONG IMAGE SIZE TO RESIZE', width, height)
				return image;
			}
			
			if (image.width == width && image.height == height)
				return image;
			
			var size:Array = getSize(image.width, image.height, width, height, scaleMode);
			
			// CROP IMAGE TO SIZE
			var bmp:ImageBitmapData;
			var m:Matrix = matrix;
			if (crop == true) {
				bmp = new ImageBitmapData(image.name,width, height, true, 0);
				m.scale(size[2], size[3]);
				m.tx = size[4];
				m.ty = size[5];
				bmp.drawWithQuality(image, m, null, null, null, true, StageQuality.HIGH);
				if(clone==false)
					image.dispose();
				return bmp;
			}
			
			bmp = new ImageBitmapData("ImageManager -> resize()." + customName, size[0], size[1], true, 0);
			m.scale(size[2], size[3]);
			size.inUse = false;
			bmp.drawWithQuality(image, m, null, null, null, true, StageQuality.HIGH);
			if(clone==false)
				image.dispose();
			return bmp;
		}
		
		/**
		 * Rotate image 
		 * @param	angle int - use ANGLE_XX static const from ImageBitmapData
		 */
		static 	public function rotate(src:ImageBitmapData, angle:Number):ImageBitmapData
		{
			var w:int = src.width;
			var h:int = src.height;
			if (angle == ANGLE_90 || angle == ANGLE_270){
				w = src.height;
				h = src.width;
			}
			var newimg:ImageBitmapData = new ImageBitmapData(src.name,w, h);
						
			var hW:Number = src.width * .5;
			var hH:Number = src.height * .5;
			var m:Matrix = matrix;
			m.translate(-hW, -hH);
			m.rotate(angle);
			m.translate(hH, hW);
			newimg.draw(src, m);
			src.dispose();
			src = null;
			return newimg;
		}
		
		/**
		 * Set Bitmap size and return array of sizes
		 * @param	image
		 * @param	width
		 * @param	height
		 * @param	scaleMode
		 * @return
		 */
		static public function resizeBitmap(image:Bitmap, width:int, height:int, scaleMode:int):Array
		{
			if (width == 0 || height == 0) {
				trace("ImageManager.resize()", 'WRONG IMAGE SIZE TO RESIZE', width, height)
				return [0,0,0,0,0,0];
			}

			var size:Array = getSize(image.width, image.height, width, height, scaleMode);
			image.width = size[0];
			image.height = size[1];
			return size;
		}
		
		/**
		 * Calculates size
		 * @param	originalW	int original width
		 * @param	originalH	int original height 
		 * @param	targetW		int target width
		 * @param	targetH		int target height
		 * @param	scaleMode	int ImageManager.SCALE_ ...
		 * @return	an array with sizes: 0 - width, 1 - height, 2 - width scale factor, 3 - height scale factor, 4 - center x offset, 5 - center y offset
		 */
		static public function getSize(originalW:int, originalH:int, targetW:int, targetH:int, scaleMode:int = ImageManager.SCALE_PORPORTIONAL):Array
		{
			if (scaleMode == SCALE_EXACT_FIT)
				return [targetW, targetH, targetW / originalW, targetH / originalH,0,0];
				
			if (scaleMode == SCALE_NONE)
				return [originalW, originalH, 1, 1,0,0];
			
			var resultW:int = 0;
			var resultH:int = 0;
			
			if (scaleMode == SCALE_PORPORTIONAL || scaleMode == SCALE_PORPORTIONAL_CENTER){
				resultW = targetW;
				resultH = originalH * (targetW / originalW);
				if (resultH < targetH) {
					resultH = targetH;
					resultW = originalW * (targetH / originalH);
				}
			}
			
			if (scaleMode == SCALE_INNER_PROP) {
				resultW = targetW;
				resultH = originalH * (targetW / originalW);
				if (resultH > targetH) {
					resultH = targetH;
					resultW = originalW * (targetH / originalH);
				}
			}
			
			var x:int = (targetW - resultW) * .5;
			var y:int = (targetH - resultH) * .5;
			
			return [resultW,resultH,resultW/originalW,resultH/originalH,x,y];
		}
		
		/**
		 * 
		 * @param	graphics
		 * @param	drawingRect
		 * @param	bmp
		 * @param	scaleMode
		 */
		static public function drawGraphicImage(graphics:Graphics, x:int, y:int, width:int, height:int, bmp:BitmapData, scaleMode:int = ImageManager.SCALE_PORPORTIONAL, bgColor:int = -1,crop:Boolean=false):void {
			if (bmp == null)
				return;
			var tmpS:Array = getSize(bmp.width, bmp.height, width, height, scaleMode);
			var m:Matrix = matrix;
			m.scale(tmpS[2], tmpS[3]);
			m.tx = x;
			m.ty = y;
			
			if (scaleMode == ImageManager.SCALE_PORPORTIONAL_CENTER && x == 0 && y == 0)
			{
			//	m.tx = -width * .5 + tmpS[2] * .5;
				m.ty = -height * .5 + tmpS[3] * .5;
			}
			
			var tw:int = tmpS[0];
			var th:int = tmpS[1];
			if (crop == true){
				if (tw > width)
					tw = width;
				if (th > height)
					th = height;
				
				//m.ty = (height - tmpS[1]) * .5;
				//m.tx = (width - tmpS[0]) * .5;
				
			}
			
			if (bgColor > -1) {
				graphics.beginFill(bgColor);
			
				graphics.drawRect(x, y, tw, th);
			}
			graphics.beginBitmapFill(bmp, m,false,true);
			graphics.drawRect(x, y, tw, th);
			tmpS.inUse = false;
			tmpS = null;
		}
		
		/**
		 * 
		 * @param	graphics
		 * @param	drawingRect
		 * @param	bmp
		 * @param	scaleMode
		 */
		static public function drawGraphicCircleImage(graphics:Graphics, x:int, y:int, radius:Number, bmp:BitmapData, scaleMode:int):void
		{
			if (bmp is ImageBitmapData && ImageBitmapData(bmp).isDisposed)
				return;
			if (bmp == null)
				return;			
			var side:Number = radius * 2;
			var scaleFactor:Number = UI.getMaxScale(bmp.width, bmp.height, side, side);
			var m:Matrix = matrix;
			//var tmpS:Array = getSize(bmp.width, bmp.height, radius * 2, radius * 2, scaleMode);
			m.scale(scaleFactor, scaleFactor);
			m.tx = (side-bmp.width * scaleFactor)*.5;// x - radius;
			m.ty = (side-bmp.height * scaleFactor)*.5;// y - radius;
			//m.scale(tmpS[2], tmpS[3]);
			//m.tx = x - radius;
			//m.ty = y - radius;		
			//graphics.beginBitmapFill(bmp, m, false, true);
			//graphics.drawCircle(x, y, radius);
			UI.drawElipseSquare(graphics, radius*2,radius,0x000000,bmp,m);
			graphics.endFill();
		}
		
		static public function drawGraphicRectangleImage(graphics:Graphics, x:int, y:int, width:Number, height:Number, radius:Number, bmp:BitmapData):void
		{
			if (bmp is ImageBitmapData && ImageBitmapData(bmp).isDisposed)
				return;
			if (bmp == null)
				return;			
			
			UI.drawRoundRectSuperEllipse(graphics, x, y, width, height, radius, 0x000000, bmp, null);
			graphics.endFill();
		}

		/**
		 * 
		 * @param	graphics
		 * @param	drawingBitmapedElipseRect
		 * @param	bmp
		 * @param	scaleMode
		 */
		static private var circleGraphics:Shape;
		static public function drawCircleImageToBitmap(target:BitmapData, bmp:BitmapData, x:int, y:int, r:int):void
		{
			//var tmpS:Array = getSize(bmp.width, bmp.height, r*2, r*2, ImageManager.SCALE_PORPORTIONAL);
			//var m:Matrix = matrix;
			//m.scale(tmpS[2], tmpS[3]);
			//m.tx = tmpS[4];
			//m.ty = tmpS[5];			
			circleGraphics ||= new Shape();
			//circleGraphics.graphics.clear();
			//circleGraphics.graphics.beginBitmapFill(bmp, m, false, true);
			//circleGraphics.graphics.drawCircle(r, r, r);
			//m = matrix;
			//m.tx = x;
			//m.ty = y;
			drawGraphicCircleImage(circleGraphics.graphics, 0, 0, r, bmp, ImageManager.SCALE_PORPORTIONAL);			
			target.drawWithQuality(circleGraphics, null, null, null, null, true, StageQuality.HIGH);
			//target.drawWithQuality(circleGraphics, m, null, null, null, true, StageQuality.HIGH);
			circleGraphics.graphics.clear();
		}		
		
		static private var roundedRectangleGraphics:Shape;
		static public function drawRoundedRectImageToBitmap(target:BitmapData, bmp:BitmapData, width:int, height:int, r:int):void
		{
			var tmpS:Array = getSize(bmp.width, bmp.height, width, height, ImageManager.SCALE_PORPORTIONAL);
			var m:Matrix = matrix;
			m.scale(tmpS[2], tmpS[3]);
			m.tx = tmpS[4];
			m.ty = tmpS[5];
			
			roundedRectangleGraphics ||= new Shape();
			roundedRectangleGraphics.graphics.clear();
			roundedRectangleGraphics.graphics.beginBitmapFill(bmp, m, false, false);
			roundedRectangleGraphics.graphics.drawRoundRect(0, 0, width, height, r, r);
			m = matrix;
		//	m.tx = x;
		//	m.ty = y;
			target.draw(roundedRectangleGraphics, m, null, null, null, true);
			roundedRectangleGraphics.graphics.clear();
		}
		
		static private var _tf:TextField;
		static private var _ta:TextFormat=new TextFormat("Tahoma");
		
		static public function drawTextFieldToGraphic(graphics:Graphics, x:int, y:int, text:String, textWidth:int, ta:TextFormat = null):ImageBitmapData
		{
			if (_tf == null) {
				_tf = new TextField();
				_tf.autoSize = TextFieldAutoSize.LEFT;
				_tf.wordWrap = true;
				_tf.multiline = true;
			}
			if (text == null)
				text = '';
			_tf.width = textWidth;
			if (ta == null) {
				_ta.size = Config.FINGER_SIZE * .15;
				ta = _ta;
			}
			_tf.defaultTextFormat = ta;
			_tf.text = text;
			var tempBmp1:ImageBitmapData=new ImageBitmapData("textField."+text.substr(0,12),_tf.width, _tf.height, true, 0);
			tempBmp1.draw(_tf, null, null, null, null, true);
			var mat:Matrix = matrix;
			mat.tx = x;
			mat.ty = y;
			graphics.beginBitmapFill(tempBmp1, mat, false, true);
			graphics.drawRect(mat.tx, mat.ty, tempBmp1.width, tempBmp1.height);
			_tf.text = '';
			return tempBmp1;
		}
		
		static public function drawTextFieldToBitmapData(bmp:BitmapData, point:Point, tf:TextField):void
		{
			var mat:Matrix = matrix;
			mat.tx = point.x;
			mat.ty = point.y;
			bmp.draw(tf, mat, null, null, null, true);
		}
		
		static public function drawImageToBitmap(target:BitmapData, bmd:BitmapData, rect:Rectangle, scaleMode:int, clipRect:Rectangle = null):void
		{
			if (bmd is ImageBitmapData && ImageBitmapData(bmd).isDisposed) {
				trace('\n3:ERROR!   Can`t draw disposed image!\n');
				return;
			}
			if (target == null)
				return;
			target.lock();
			var tmpS:Array = getSize(bmd.width, bmd.height, rect.width, rect.height, scaleMode);
			var m:Matrix = matrix;
			m.scale(tmpS[2], tmpS[3]);
			m.tx = rect.x;
			m.ty = rect.y;
			target.draw(bmd, m ,null,null,clipRect,true);
			target.unlock();
		}
		
		static public function drawImageToBitmapWithAngle(target:BitmapData, bmd:BitmapData, rect:Rectangle, scaleMode:int, clipRect:Rectangle = null,angle:Number=0):void {
			if (bmd is ImageBitmapData && ImageBitmapData(bmd).isDisposed) {
				//trace('\n3:ERROR!   Can`t draw disposed image!\n');
				return;
			}
			if (target == null)
				return;
			target.lock();
			var tmpS:Array = getSize(bmd.width, bmd.height, rect.width, rect.height, scaleMode);
			var m:Matrix = matrix;
			m.scale(tmpS[2], tmpS[3]);
			m.tx = rect.x;
			m.ty = rect.y;
			m.rotate(angle);
			target.draw(bmd, m ,null,null,clipRect,true);
			target.unlock();
		}
		
		//
		// IMAGE LOADER -----------------------------------------------------------------------
		//
		static private var currentImageManagerRealization:IImageManager;
		
		static private function getImageManagerRealization():IImageManager 
		{
			if (!currentImageManagerRealization)
			{
				/*if (Config.PLATFORM_APPLE && IOSImageLoader.isAvaliable())
				{
					currentImageManagerRealization = new IOSImageLoader(); 
				}
				else
				{
					currentImageManagerRealization = new DefaultImageManager();
				}*/
					
				currentImageManagerRealization = new DefaultImageManager();
				currentImageManagerRealization.S_LOAD_PROGRESS.add(onImageLoadProgress);
			}
			
			return currentImageManagerRealization;
		}
		
		static private function onImageLoadProgress(url:String, percent:int):void 
		{
			S_LOAD_PROGRESS.invoke(url, percent);
		}
		
		//D:\Projects\DukascopyConnect\src\com\dukascopy\connect\vo\MemberVO.as:33:Warning: Illogical comparison with NaN.  This statement always evaluates to false.
		
		/**
		 * 
		 * @param	url
		 * @param	callBack function(bmd,url);
		 * @return
		 */
		static public function loadImage(url:String, callBack:Function, saveToDisk:Boolean = true, fromLocalStoreOnly:Boolean = false):Boolean
		{
			if (url == null || url == "") {
				if ((callBack as Function).length == 2) {
					callBack(url, null);
				} else if ((callBack as Function).length == 3) {
					callBack(url, null, false);
				}
				return false;
			}
			return getImageManagerRealization().loadImage(url, callBack, saveToDisk, fromLocalStoreOnly);
		}
		
		static public function disposeNowAllImages():void
		{
			getImageManagerRealization().disposeNowAllImages();
		}
		
		static public function unloadImage(url:String):void
		{
			getImageManagerRealization().unloadImage(url);
		}
		
		static public function getImageFromCache(url:String):ImageBitmapData
		{
			return getImageManagerRealization().getImageFromCache(url);
		}
		
		static public function cancelLoad(url:String, callBack:Function):void 
		{
			getImageManagerRealization().cancelLoad(url, callBack);
		}
		static public function cacheSticker(stickerId:String, stickerBD:ImageBitmapData):void 
		{
			getImageManagerRealization().cacheSticker(stickerId, stickerBD);
		}
		
		static public function disposeCurrentStickers():void 
		{
			getImageManagerRealization().disposeCurrentStickers();
		}
		
		static public function get imageLoadersCount():int
		{
			return getImageManagerRealization().getImageLoadersCount();
		}
	}
}