package com.dukascopy.connect.data.screenAction.customActions 
{
	import assets.DownloadIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.Enums.E_IosImagesAccesState;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.screenAction.BaseAction;
	import com.dukascopy.connect.data.screenAction.IAction;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.lightbox.IBitmapProvider;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.utils.FilesSaveUtility;
	import com.dukascopy.langs.Lang;
	import flash.display.BitmapData;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class SaveImageToGalleryAction extends BaseAction implements IAction
	{
		private var bitmapSource:IBitmapProvider;
		private var url:String;
		
		public function SaveImageToGalleryAction(bitmapSource:IBitmapProvider, url:String) 
		{
			this.url = url;
			this.bitmapSource = bitmapSource;
		}
		
		public function execute():void
		{
			if (Config.PLATFORM_APPLE) {
				var imageAcsessState:String = FilesSaveUtility.currentIosImageAccessState;
				switch(imageAcsessState)
				{
					case E_IosImagesAccesState.denied:
					case E_IosImagesAccesState.restricted:
						DialogManager.alert(Lang.permissionInfo, Lang.acsessToPhotosDenied);
						return;
					case E_IosImagesAccesState.authorized:
					case E_IosImagesAccesState.notDetermined:
					default:
						break;
				}
			}
			MobileGui.androidExtension.getCameraPermissions
			
			ToastMessage.display(Lang.textSaving);
			var bmd:BitmapData = bitmapSource.getBitmapData();
			FilesSaveUtility.signalOnImageSaved.add(onSaveSuccess);
			FilesSaveUtility.saveFileToForGallery(bmd, url);
		}
		
		private function onSaveSuccess():void {
			FilesSaveUtility.signalOnImageSaved.remove(onSaveSuccess);
			ToastMessage.display(Lang.textSaved);
		}
		
		override public function dispose():void
		{
			super.dispose();
			FilesSaveUtility.signalOnImageSaved.remove(onSaveSuccess);
			bitmapSource = null;
		}
	}
}