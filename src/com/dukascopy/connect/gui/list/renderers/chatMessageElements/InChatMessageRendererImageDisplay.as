package com.dukascopy.connect.gui.list.renderers.chatMessageElements {
	
	import assets.PhotoShotIcon;
	import assets.VideoIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	
	/**
	 * Отображает картинку в рендерере изображения
	 * @author David Gnatkivskij. Telefision TEAM Kiev.
	 */
	
	public class InChatMessageRendererImageDisplay extends Sprite {
		
		private var imageContainer:Sprite;
		private var imageIcon:PhotoShotIcon;
		private var image:Sprite;
		private var imageMask:Shape;
		
		private var _boxRadius:int = 5;
		private var videoIcon:VideoIcon;
		private var currentIcon:Sprite;
		
		public function InChatMessageRendererImageDisplay(boxRadius:int) {
			_boxRadius = boxRadius;
			var bgSize:int = _boxRadius * 3;
			
			imageContainer = new Sprite();
			addChild(imageContainer);
			
			imageIcon = new PhotoShotIcon();
			var ct:ColorTransform = new ColorTransform();
			ct.color = 0;
			imageIcon.transform.colorTransform = ct;
			imageIcon.alpha = 0.4;
			imageContainer.addChild(imageIcon);
			UI.scaleToFit(imageIcon, Config.FINGER_SIZE, Config.FINGER_SIZE);
			
			videoIcon = new VideoIcon();
			
			videoIcon.transform.colorTransform = ct;
			videoIcon.alpha = 0.4;
			imageContainer.addChild(videoIcon);
			UI.scaleToFit(videoIcon, Config.FINGER_SIZE, Config.FINGER_SIZE);
			
			image = new Sprite();
				imageMask = new Shape();
				imageContainer.addChild(imageMask);
			image.mask = imageMask;
			imageContainer.addChild(image);
			
			videoIcon.visible = false;
			imageIcon.visible = false;
			currentIcon = imageIcon;
			currentIcon.visible = true;
		}
		
		public function drawImage(loadedImg:ImageBitmapData, bgW:int, bgH:int, key:Array = null):void {
			
		//	graphics.beginFill(0);
		//	graphics.drawRect(0, 0, 1000, 1000);
			
			imageMask.graphics.clear();
			imageMask.graphics.beginFill(0);
			imageMask.graphics.drawRoundRect(0, 0, bgW, bgH, _boxRadius, _boxRadius);
			imageMask.graphics.endFill();		
			imageContainer.visible = true;
			
			videoIcon.visible = false;
			imageIcon.visible = false;
			
			if (currentIcon != null) {
				currentIcon.visible = true;
			}
			
			imageMask.visible = true;
			image.mask = imageMask;
			image.visible = true;	
			
			image.graphics.clear();
			
			if (loadedImg != null && loadedImg.isDisposed == false && image != null) {
				if (key != null)
					loadedImg.decrypt(key);
				image.graphics.lineStyle(4, 0, 0.15);
				ImageManager.drawGraphicImage(image.graphics, 0, 0, bgW, bgH, loadedImg, ImageManager.SCALE_PORPORTIONAL, -1, true);
			}
		}
		
		public function clearImage():void {
			image.graphics.clear();
		}
		
		public function setSize(itemWidth:int, itemHeight:int):void {
			if (imageIcon) {
				imageIcon.x = int(itemWidth * .5 - imageIcon.width * .5);
				imageIcon.y = int(itemHeight * .5 - imageIcon.height * .5);
			}
			
			if (videoIcon) {
				videoIcon.x = int(itemWidth * .5 - videoIcon.width * .5);
				videoIcon.y = int(itemHeight * .5 - videoIcon.height * .5);
			}
		}
		
		public function dispose():void {
			UI.destroy(imageContainer);
			imageContainer = null;
			UI.destroy(imageIcon);
			imageIcon = null;
			UI.destroy(image);
			image = null;
			UI.destroy(imageMask);
			imageMask = null;
			UI.destroy(videoIcon);
			videoIcon = null;
		}
		
		public function setVideoIcon():void 
		{
			currentIcon = videoIcon;
			
			videoIcon.visible = false;
			imageIcon.visible = false;
			currentIcon.visible = true;
		}
		
		public function setPhotoIcon():void 
		{
			currentIcon = imageIcon;
			
			videoIcon.visible = false;
			imageIcon.visible = false;
			currentIcon.visible = true;
		}
		
		public function hideIcon():void 
		{
			currentIcon = null;
			
			videoIcon.visible = false;
			imageIcon.visible = false;
		}
	}
}