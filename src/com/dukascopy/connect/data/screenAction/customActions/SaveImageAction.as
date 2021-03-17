package com.dukascopy.connect.data.screenAction.customActions 
{
	import assets.DownloadIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.Enums.E_IosImagesAccesState;
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
	public class SaveImageAction extends ScreenAction implements IScreenAction
	{
		private var bitmapSource:IBitmapProvider;
		private var url:String;
		
		public function SaveImageAction(bitmapSource:IBitmapProvider, url:String) 
		{
			this.url = url;
			this.bitmapSource = bitmapSource;
			setIconClass(DownloadIcon);
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
			
			ToastMessage.display(Lang.textSaving);
			var bmd:BitmapData = bitmapSource.getBitmapData();
			FilesSaveUtility.signalOnImageSaved.add(onSaveSuccess);
			FilesSaveUtility.saveFileToForGallery(bmd, url, false);
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