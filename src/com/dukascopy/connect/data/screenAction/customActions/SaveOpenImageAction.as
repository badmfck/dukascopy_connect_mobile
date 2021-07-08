package com.dukascopy.connect.data.screenAction.customActions 
{
	import assets.DownloadIcon;
	import assets.PhotoIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.Enums.E_IosImagesAccesState;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.lightbox.IBitmapProvider;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.utils.FilesSaveUtility;
	import com.dukascopy.langs.Lang;
	import flash.display.BitmapData;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class SaveOpenImageAction extends ScreenAction implements IScreenAction
	{
		private var url:String;
		private var bitmapSource:IBitmapProvider;
		
		public function SaveOpenImageAction(url:String, bitmapSource:IBitmapProvider = null) {
			this.url = url;
			this.bitmapSource = bitmapSource;
		//	setIconClass(AttachImageIcon);
		}
		
		override public function getIconClass():Class {
			if (isSaveAvaliable()) {
				return DownloadIcon;
			}
			return PhotoIcon;
		}
		
		public function execute():void {
			if (isSaveAvaliable()){
				save();
			}
			else {
				open();
			}
		}
		
		private function open():void {
			if (FilesSaveUtility.getIsFileExists(url)) {
				FilesSaveUtility.openGalleryIfFileExists(url);
			}
		}
		
		private function save():void {
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
			if (bitmapSource != null)
			{
				ToastMessage.display(Lang.textSaving);
				var bmd:BitmapData = bitmapSource.getBitmapData();
				FilesSaveUtility.signalOnImageSaved.add(onSaveSuccess);
				FilesSaveUtility.saveFileToForGallery(bmd, url, true, false);
			}
			else
			{
				trace("123");
			}
		}
		
		private function onSaveSuccess():void {
			echo("FILE!", "SaveOpenImageAction.onSaveSuccess");
			FilesSaveUtility.signalOnImageSaved.remove(onSaveSuccess);
			ToastMessage.display(Lang.textSaved);
		}
		
		private function isSaveAvaliable():Boolean {
			return !FilesSaveUtility.getIsFileExists(url);
		}
		
		override public function dispose():void {
			super.dispose();
			FilesSaveUtility.signalOnImageSaved.remove(onSaveSuccess);
			bitmapSource = null;
		}
	}
}