package com.dukascopy.connect.gui.tools 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.LightboxMenu;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.lightbox.ZoomPanContainerExtended;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.type.ScaleMode;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class ImagePreviewCrop extends Sprite
	{
		private var callbackOk:Function;
		private var callbackCancel:Function;
		private var imagePreviewBack:Bitmap;
		private var viewWidth:int;
		private var viewHeight:int;
		private var lightBoxMenu:LightboxMenu;
		static private var stageRef:Stage;
		static public var isShowing:Boolean;
		private var leftLine:Bitmap;
		private var rightLine:Bitmap;
		private var topLine:Bitmap;
		private var bottomLine:Bitmap;
		private var appleHeader:Bitmap;
		private var startScale:Number;
		private var minPoint:Point;
		private var maxPoint:Point;
		private var zoomPanCont:ZoomPanContainerExtended;
		private static var instances:Vector.<ImagePreviewCrop> = new Vector.<ImagePreviewCrop>();
		
		private var aspectRatio:Number;
		
		public function ImagePreviewCrop(aspectRatio:Number = NaN) 
		{
			this.aspectRatio = aspectRatio;
			if (isNaN(this.aspectRatio))
			{
				this.aspectRatio = 1;
			}
			
			imagePreviewBack = new Bitmap(UI.getColorTexture(0));
			addChild(imagePreviewBack);
			
			viewWidth = stageRef.stageWidth;
			viewHeight = stageRef.stageHeight;
			
			zoomPanCont = new ZoomPanContainerExtended(stageRef, 0, 0);
			addChild(zoomPanCont);
			
			var outlineTexture:ImageBitmapData = UI.getColorTexture(AppTheme.RED_MEDIUM);
			leftLine = new Bitmap(outlineTexture);
			rightLine = new Bitmap(outlineTexture);
			topLine = new Bitmap(outlineTexture);
			bottomLine = new Bitmap(outlineTexture);
			outlineTexture = null;
			addChild(leftLine);
			addChild(rightLine);
			addChild(topLine);
			addChild(bottomLine);
			
			lightBoxMenu = new LightboxMenu();
			lightBoxMenu.stageRef = stageRef;
			lightBoxMenu.setSize(viewWidth, viewHeight);
			addChild(lightBoxMenu);
			
			appleHeader = new Bitmap(UI.getColorTexture(0));
			addChild(appleHeader);
			appleHeader.width = viewWidth;
			appleHeader.height = Config.APPLE_TOP_OFFSET;
		}
		
		public function display(imageData:ImageBitmapData, callbackOk:Function, callbackCancel:Function):void
		{
			isShowing = true;
			stageRef.addChild(this);
			this.callbackOk = callbackOk;
			this.callbackCancel = callbackCancel;
			lightBoxMenu.setCallbacks(onCancel, onOkPressed);
			lightBoxMenu.show();
			visible = true;
			
			imagePreviewBack.width = viewWidth;
			imagePreviewBack.height = viewHeight;
			
			var outlineThickness:int = Config.FINGER_SIZE * .05;
			
			leftLine.width = outlineThickness;
			rightLine.width = outlineThickness;
			topLine.height = outlineThickness;
			bottomLine.height = outlineThickness;
			
			var padding:int = Config.MARGIN * 6;
			
			var screenHeight:int = viewHeight - Config.APPLE_TOP_OFFSET - lightBoxMenu.height - padding * 2;
			var screenWidth:int = viewWidth - padding * 2;
			
			var minImageHeight:int;
			var minImageWidth:int;
			
			var screenRatio:Number = screenHeight / screenWidth;
			if (aspectRatio > screenRatio)
			{
				minImageHeight = screenHeight;
				minImageWidth = screenHeight / screenRatio;
			}
			else
			{
				minImageWidth = screenWidth;
				minImageHeight = screenWidth * aspectRatio;
			}
			
			
			
			leftLine.height = minImageHeight;
			rightLine.height = minImageHeight;
			topLine.width = minImageWidth;
			bottomLine.width = minImageWidth;
			
			var yCropPos:int = (viewHeight - Config.APPLE_TOP_OFFSET - lightBoxMenu.height - minImageHeight) * .5 + Config.APPLE_TOP_OFFSET;
			
			leftLine.x = padding;
			leftLine.y = yCropPos;
			rightLine.x = padding + minImageWidth - outlineThickness;
			rightLine.y = yCropPos;
			
			topLine.x = padding;
			topLine.y = yCropPos;
			bottomLine.x = padding;
			bottomLine.y = yCropPos + minImageHeight - outlineThickness;
			
			minImageWidth -= outlineThickness * 2;
			minImageHeight -= outlineThickness * 2;
			
			var koef:Number = Math.max(minImageWidth / imageData.width, minImageHeight / imageData.height);
			
			startScale = koef;
			
			
			minPoint = new Point(padding + outlineThickness + minImageWidth * .5 - imageData.width * startScale * .5, 
								yCropPos + outlineThickness + minImageHeight*.5 - imageData.height * startScale * .5);
			maxPoint = new Point(minPoint.x + minImageWidth, minPoint.y + minImageHeight);
			
			zoomPanCont.setViewportSize(minImageWidth, minImageHeight);
			zoomPanCont.setScaleMode(ScaleMode.FILL);
			zoomPanCont.usePagination = false;
			zoomPanCont.setAllowHide(false);
			zoomPanCont.topOffset = yCropPos + outlineThickness;
			zoomPanCont.leftOffset = padding + outlineThickness;
			zoomPanCont.show();
			zoomPanCont.setBitmapData(imageData, false);
			zoomPanCont.activate();
			zoomPanCont.forceCheckBounds();
			zoomPanCont.resetTouchPoints();
			
			addInstance(this);
		}
		
		private function addInstance(imagePreviewCrop:ImagePreviewCrop):void 
		{
			instances.push(imagePreviewCrop);
		}
		
		private function removeInstance(imagePreviewCrop:ImagePreviewCrop):void 
		{
			var index:int = instances.indexOf(imagePreviewCrop);
			if (index != -1)
			{
				instances.splice(index, 1);
			}
			else {
			//	ApplicationErrors.add("wrong state");
			}
		}
		
		private function onOkPressed():void 
		{
			if (callbackOk != null)
			{
				callbackOk(getCroppedImage());
			}
			hide();
		}
		
		private function getCroppedImage():ImageBitmapData 
		{
			var rect:Rectangle = zoomPanCont.getViewportRectForImage();
			var resultImage:ImageBitmapData = new ImageBitmapData("ImagePreviewCrop.resultCroppedImage", rect.width, rect.height);
			
			resultImage.copyPixels(zoomPanCont.getBitmapData(), rect, new Point(0, 0));
		//	sourceImage.dispose();
		//	sourceImage = null;
			return resultImage;
		}
		
		private function hide():void
		{
			isShowing = false;
			callbackOk = null;
			callbackCancel = null;
			if (zoomPanCont)
			{
				zoomPanCont.deactivate();
			}
			
			this.visible = false;
			
			if (parent)
			{
				parent.removeChild(this);
			}
			removeInstance(this);
		}
		
		public static function close():void
		{
			if (!instances)
			{
				return;
			}
			var l:int = instances.length;
			var currentInstances:Vector.<ImagePreviewCrop> = instances.concat();
			for (var i:int = 0; i < l; i++) 
			{
				currentInstances[i].onCancel();
				currentInstances[i].dispose();
			}
			currentInstances = null;
			instances = new Vector.<ImagePreviewCrop>();
		}
		
		public function onCancel():void 
		{
			if (callbackCancel != null)
			{
				callbackCancel();
			}
			hide();
		}
		
		public function dispose():void
		{
			removeInstance(this);
			deactivate();
			isShowing = false;
			if (parent)
			{
				parent.removeChild(this);
			}
			callbackOk = null;
			callbackCancel = null;
			
			callbackOk = null;
			
			if (lightBoxMenu)
			{
				lightBoxMenu.dispose();
				lightBoxMenu = null;
			}
			
			if (imagePreviewBack)
			{
				UI.destroy(imagePreviewBack);
				imagePreviewBack = null;
			}
			
			if (leftLine)
			{
				UI.destroy(leftLine);
				leftLine = null;
			}
			if (rightLine)
			{
				UI.destroy(rightLine);
				rightLine = null;
			}
			if (topLine)
			{
				UI.destroy(topLine);
				topLine = null;
			}
			if (bottomLine)
			{
				UI.destroy(bottomLine);
				bottomLine = null;
			}
			if (appleHeader)
			{
				UI.destroy(appleHeader);
				appleHeader = null;
			}
			if (zoomPanCont)
			{
				zoomPanCont.destroy();
				zoomPanCont = null;
			}
		}
		
		public function activate():void
		{
			if (zoomPanCont)
			{
				zoomPanCont.activate();
			}
		}
		
		public function deactivate():void
		{
			if (zoomPanCont)
			{
				zoomPanCont.deactivate();
			}
		}
		
		static public function setStage(stage:Stage):void 
		{
			stageRef = stage;
		}
		
		public function clearCurrent():void 
		{
			if (zoomPanCont)
			{
				zoomPanCont.clear();
			}
		}
		
	}

}