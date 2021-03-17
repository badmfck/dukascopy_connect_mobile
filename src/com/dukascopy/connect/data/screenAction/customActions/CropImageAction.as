package com.dukascopy.connect.data.screenAction.customActions {
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.gui.tools.ImagePreviewCrop;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.langs.Lang;
	import flash.geom.Point;

	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class CropImageAction extends ScreenAction implements IScreenAction
	{
		private var aspectRatio:Number;
		private var imageMaxHeight:int;
		private var imageMaxWidth:int;
		private var imageCropper:ImagePreviewCrop;
		private var croppingImage:ImageBitmapData;
		
		public function CropImageAction(imageMaxWidth:int = 0, imageMaxHeight:int = 0, aspectRatio:Number = NaN) 
		{
			this.imageMaxWidth = imageMaxWidth;
			this.imageMaxHeight = imageMaxHeight;
			this.aspectRatio = aspectRatio;
			
			if (imageMaxWidth == 0)
			{
				imageMaxWidth = Config.BITMAP_SIZE_MAX;
			}
			if (imageMaxHeight == 0)
			{
				imageMaxHeight = Config.BITMAP_SIZE_MAX;
			}
			
			setIconClass(null);
		}
		
		public function execute():void
		{
			var image:ImageBitmapData = getData() as ImageBitmapData;
			
			if (image)
			{
				imageCropper = new ImagePreviewCrop(aspectRatio);
				
				croppingImage = new ImageBitmapData("CropImageAction.croppingImage", image.width, image.height);
				croppingImage.copyPixels(image, image.rect, new Point(0, 0));
				image.dispose();
				image = null;
				
				imageCropper.display(croppingImage, onCropDone, onCropCancel);
			}
			else
			{
				S_ACTION_FAIL.invoke(Lang.galleryError);
			}
		}
		
		private function onCropDone(imageData:ImageBitmapData):void
		{
			if (imageData.width > imageMaxWidth || imageData.height > imageMaxHeight)
			{
				imageData = ImageManager.resize(imageData, imageMaxWidth, imageMaxHeight, ImageManager.SCALE_INNER_PROP);
			}
			
			S_ACTION_SUCCESS.invoke(imageData);
		}
		
		override public function dispose():void
		{
			if (imageCropper)
			{
				imageCropper.dispose();
				imageCropper.clearCurrent();
				imageCropper = null;
			}
			
			if (croppingImage)
			{
				croppingImage.dispose();
				croppingImage = null;
			}
			super.dispose();
		}
		
		private function onCropCancel():void
		{
			S_ACTION_FAIL.invoke();
		}
	}
}