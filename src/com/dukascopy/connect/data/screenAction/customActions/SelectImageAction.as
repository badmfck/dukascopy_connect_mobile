package com.dukascopy.connect.data.screenAction.customActions {
	import assets.GalleryIcon;
	import assets.PhotoShotIcon;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.gui.list.renderers.ListLinkWithIcon;
	import com.dukascopy.connect.screens.dialogs.ScreenLinksDialog;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.photoGaleryManager.PhotoGaleryManager;
	import com.dukascopy.langs.Lang;

	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class SelectImageAction extends ScreenAction implements IScreenAction
	{
		public function SelectImageAction() 
		{
			setIconClass(null);
		}
		
		public function execute():void
		{
			var menuItems:Array = [];
			
			menuItems.push( { fullLink:Lang.selectFromGallery, id:0, icon:GalleryIcon } );
			menuItems.push( { fullLink:Lang.makePhoto, id:1, icon:PhotoShotIcon } );
			
			DialogManager.showDialog(ScreenLinksDialog, 
				{
					callback: onDialogResult,
					data: menuItems,
					itemClass: ListLinkWithIcon,
					title: Lang.selectImage,
					multilineTitle: true
				});
		}
		
		private function onDialogResult(data:Object):void
		{
			if (data.id == 0)
			{
				PhotoGaleryManager.S_GALLERY_IMAGE_LOADED.add(onImageSelected);
				PhotoGaleryManager.takeImage(false);
				return;
			}
			if (data.id == 1)
			{
				PhotoGaleryManager.S_GALLERY_IMAGE_LOADED.add(onImageSelected);
				PhotoGaleryManager.takeCamera(false);
				return;
			}
			
			S_ACTION_FAIL.invoke();
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