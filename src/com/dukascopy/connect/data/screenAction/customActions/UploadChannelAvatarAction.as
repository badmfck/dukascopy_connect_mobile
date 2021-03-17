package com.dukascopy.connect.data.screenAction.customActions {
	
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.sys.chatManager.typesManagers.ChannelsManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
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
	
	public class UploadChannelAvatarAction extends ScreenAction implements IScreenAction {
		
		private var channelUID:String;
		
		public function UploadChannelAvatarAction(channelUID:String) {
			this.channelUID = channelUID;
			setIconClass(null);
		}
		
		public function execute():void {
			var image:ImageBitmapData = getData() as ImageBitmapData;
			if (image) {
				
				var imageWithBack:ImageBitmapData = new ImageBitmapData("UploadChannelAvatarAction.ImageToSend", image.width, image.height, false, 0xFFFFFF);
				imageWithBack.copyBitmapData(image);
				var pngImage:ByteArray = imageWithBack.encode(imageWithBack.rect, new JPEGEncoderOptions(87));
				
				imageWithBack.dispose();
				imageWithBack = null;
				
				image.dispose();
				image = null;
				
				var imageString:String = "data:image/jpeg;base64," + Base64.encodeByteArray(pngImage);
				upload(imageString);
				imageString = null;
				pngImage = null;
			} else
				S_ACTION_FAIL.invoke();
		}
		
		private function upload(imageString:String):void {
			PHP.irc_setAvatar(onServerResponse, channelUID, imageString);
		}
		
		private function onServerResponse(phpRespond:PHPRespond):void {
			if (disposed) {
				phpRespond.dispose();
				return;
			}
			if (phpRespond.error) {
				var message:String;
				if (phpRespond.errorMsg == PHP.NETWORK_ERROR)
					message = Lang.alertProvideInternetConnection;
				else
					message = Lang.textWarning + " " + phpRespond.errorMsg;
				S_ACTION_FAIL.invoke(message);
			} else if (phpRespond.data) {
				ChannelsManager.S_CHANNEL_UPDATED.invoke(ChannelsManager.getChannel(channelUID));
				S_ACTION_SUCCESS.invoke(phpRespond.data.toString());
			}
			phpRespond.dispose();
		}
		
		override public function dispose():void {
			super.dispose();
		}
	}
}