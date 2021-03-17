package com.dukascopy.connect.gui.list.renderers.viBot.sections {
	
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
	 * @author Sergey Dobarin
	 */
	
	public class ViImageRenderer extends Sprite {
		
		private var imageContainer:Sprite;
		private var image:Sprite;
		private var imageMask:Shape;
		
		private var _boxRadius:int = 5;
		
		public function ViImageRenderer(boxRadius:int) {
			_boxRadius = boxRadius;
			
			imageContainer = new Sprite();
			addChild(imageContainer);
			
			image = new Sprite();
			imageContainer.addChild(image);
			
			imageMask = new Shape();
			imageContainer.addChild(imageMask);
			
			image.mask = imageMask;
		}
		
		public function drawImage(loadedImg:ImageBitmapData, bgW:int, bgH:int, key:Array = null):void {
			
			imageMask.graphics.clear();
			imageMask.graphics.beginFill(0);
			imageMask.graphics.drawRoundRect(0, 0, bgW - Config.MARGIN, bgH - Config.MARGIN, _boxRadius * .7, _boxRadius * .7);
			imageMask.graphics.endFill();
			
			imageContainer.graphics.clear();
			imageContainer.graphics.beginFill(0xFFFFFF);
			imageContainer.graphics.drawRoundRect(0, 0, bgW, bgH, _boxRadius, _boxRadius);
			imageContainer.graphics.endFill();
			
			image.x = int(Config.MARGIN * .5);
			image.y = int(Config.MARGIN * .5);
			
			imageMask.x = int(Config.MARGIN * .5);
			imageMask.y = int(Config.MARGIN * .5);
			
			image.graphics.clear();
			
			if (loadedImg != null && loadedImg.isDisposed == false && image != null) {
				ImageManager.drawGraphicImage(image.graphics, 0, 0, bgW - Config.MARGIN, bgH - Config.MARGIN, loadedImg, ImageManager.SCALE_PORPORTIONAL_CENTER, -1, true);
			}
		}
		
		public function clearImage():void {
			image.graphics.clear();
		}
		
		public function dispose():void {
			UI.destroy(imageContainer);
			imageContainer = null;
			UI.destroy(image);
			image = null;
			UI.destroy(imageMask);
			imageMask = null;
		}
	}
}