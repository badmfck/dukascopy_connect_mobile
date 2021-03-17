package com.dukascopy.connect.data.screenAction.customActions {
	
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.langs.Lang;
	import com.hurlant.util.Base64;
	import flash.display.JPEGEncoderOptions;
	import flash.utils.ByteArray;

	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class UploadPublicImageAction extends ScreenAction implements IScreenAction {
		
		private var maxWidth:int;
		private var maxHeight:int;
		private var sendThumb:Boolean;
		
		public function UploadPublicImageAction(maxWidth:int = -1, maxHeight:int = -1, sendThumb:Boolean = true) {
			this.maxWidth = maxWidth;
			this.maxHeight = maxHeight;
			this.sendThumb = sendThumb;
			setIconClass(null);
		}
		
		public function execute():void {
			var image:ImageBitmapData = getData() as ImageBitmapData;
			if (image) {
				var thumb:ImageBitmapData = ImageManager.resize(image, 100, 100, ImageManager.SCALE_INNER_PROP, false, true);
				
				if (maxWidth != -1 && maxHeight != -1)
				{
					image = ImageManager.resize(image, maxWidth, maxHeight, ImageManager.SCALE_INNER_PROP, false, false);
				}
				
				var imageWithBack:ImageBitmapData = new ImageBitmapData("UploadChannelAvatarAction.ImageToSend", image.width, image.height, false, 0xFFFFFF);
				imageWithBack.copyBitmapData(image);
				
				if (sendThumb == true)
				{
					var thumbWithBack:ImageBitmapData = new ImageBitmapData("UploadChannelAvatarAction.thumbToSend", thumb.width, thumb.height, false, 0xFFFFFF);
					thumbWithBack.copyBitmapData(thumb);
				}
				
				if (sendThumb == true)
				{
					var thumbImage:ByteArray = thumbWithBack.encode(thumbWithBack.rect, new JPEGEncoderOptions(87));
				}
				
				var mainImage:ByteArray = imageWithBack.encode(imageWithBack.rect, new JPEGEncoderOptions(87));
				image.dispose();
				image = null;
				thumb.dispose();
				thumb = null;
				
				if (sendThumb == true)
				{
					thumbWithBack.dispose();
					thumbWithBack = null;
				}
				
				imageWithBack.dispose();
				imageWithBack = null;
				
				var imageString:String = "data:image/jpeg;base64," + Base64.encodeByteArray(mainImage);
				var thumbString:String;
				if (sendThumb == true)
				{
					thumbString = "data:image/jpeg;base64," + Base64.encodeByteArray(thumbImage);
				}
				upload(imageString, thumbString);
				imageString = null;
				mainImage = null;
			} else {
				S_ACTION_FAIL.invoke();
			}
		}
		
		private function upload(imageString:String, thumbString:String):void {
			PHP.files_savePublicImage(onServerResponse, imageString, thumbString);
		}
		
		private function onServerResponse(phpRespond:PHPRespond):void {
			if (disposed) {
				phpRespond.dispose();
				return;
			}
			if (phpRespond.error) {
				var message:String;
				if (phpRespond.errorMsg == PHP.NETWORK_ERROR) {
					message = Lang.alertProvideInternetConnection;
				} else {
					message = Lang.textWarning + " " + phpRespond.errorMsg;
				}
				S_ACTION_FAIL.invoke(message);
			} else if(phpRespond.data && ("uid" in phpRespond.data) && phpRespond.data.uid) {
				S_ACTION_SUCCESS.invoke(phpRespond.data.uid.toString());
			}
			phpRespond.dispose();
		}
		
		override public function dispose():void {
			super.dispose();
		}
	}
}