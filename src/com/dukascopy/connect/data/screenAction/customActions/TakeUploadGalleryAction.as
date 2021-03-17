package com.dukascopy.connect.data.screenAction.customActions
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.photoGaleryManager.PhotoGaleryManager;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class TakeUploadGalleryAction extends ScreenAction implements IScreenAction
	{
		public function TakeUploadGalleryAction()
		{
			setIconClass(null);
		}
		
		public function execute():void
		{
			PhotoGaleryManager.S_GALLERY_IMAGE_LOADED.add(onImageSelected);
			PhotoGaleryManager.takeImage(false);
		}
		
		override public function dispose():void
		{
			PhotoGaleryManager.S_GALLERY_IMAGE_LOADED.remove(onImageSelected);
			super.dispose();
		}
		
		private function onImageSelected(success:Boolean, image:ImageBitmapData, message:String):void
		{
			PhotoGaleryManager.S_GALLERY_IMAGE_LOADED.remove(onImageSelected);
			if (success && image && !isNaN(image.width))
			{
				S_ACTION_SUCCESS.invoke(image);
			}
			else
			{
				S_ACTION_FAIL.invoke(message);
			}
		}
	}
}