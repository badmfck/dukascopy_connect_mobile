package com.dukascopy.connect.sys.viManager.actions 
{
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.screens.chat.video.FloatVideo;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.sys.viManager.data.VIAction;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import com.hurlant.util.Base64;
	import flash.display.JPEGEncoderOptions;
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class TakeMRZAction implements IBotAction
	{
		private var video:FloatVideo;
		public var action:VIAction;
		private var onSuccess:Function;
		private var onFail:Function;
		private var localData:ImageBitmapData;
		
		public function TakeMRZAction(video:FloatVideo, action:VIAction) 
		{
			this.video = video;
			this.action = action;
		}
		
		public function getResult():Vector.<ImageBitmapData>
		{
			var result:Vector.<ImageBitmapData> = new Vector.<ImageBitmapData>();
			result.push(localData);
			return result;
		}
		
		public function execute(onSuccess:Function, onFail:Function):void 
		{
			this.onSuccess = onSuccess;
			this.onFail = onFail;
			video.switchCamera(action.camera);
			
			TweenMax.killDelayedCallsTo(showCamera);
			TweenMax.delayedCall(0.5, showCamera);
		}
		
		private function showCamera():void 
		{
			TweenMax.killDelayedCallsTo(showCamera);
			video.takePhoto(onResponsePhoto, action.description, FloatVideo.MRZ);
		}
		
		public function getAction():VIAction 
		{
			return action;
		}
		
		private function onResponsePhoto(success:Boolean, result:ImageBitmapData = null):void 
		{
			localData = result;
			
			if (success == true)
			{
				if (result != null && result.isDisposed == false)
				{
					video.showLoadingState();
					processServerMRZ();
				}
			}
			else
			{
				video.onSuccess();
				if (onFail != null)
				{
					onFail(this);
				}
			}
		}
		
		private function processServerMRZ():void {
			var mrzImage:ByteArray = localData.encode(localData.rect, new JPEGEncoderOptions(87));
			var mrzImageString:String = "data:image/jpeg;base64," + Base64.encodeByteArray(mrzImage);
			PHP.call_mrzUpload(onServerResponse, mrzImageString);
		}
		
		private function onServerResponse(phpRespond:PHPRespond):void {
			if (video != null) {
				video.hideLoadingState();
			}
			if (phpRespond.error == true) {
				if (phpRespond.errorMsg.indexOf("mrz..03") == 0 &&
					phpRespond.errorMsg.toLowerCase().indexOf("failed to recognize mrz") != -1) {
						/*if (callCount > CALL_COUNT)
							addSkipButton();*/
						ToastMessage.display(Lang.failedToRecognizeMRZ);
				} else {
					ToastMessage.display(Lang.somethingWentWrong);
				}
				video.toStartState();
			} else if ("result" in phpRespond.data == true) {
				var mrzData:Object = JSON.parse(phpRespond.data.result as String).data;
				var valid:Boolean = true;
				for (var n:String in mrzData) {
					if (n.indexOf("_valid") != -1) {
						if (n == "document_valid")
							continue;
						if (n == "nationality_valid" && mrzData[n] == false) {
							if (mrzData["issuing_country"] == "LVA")
								continue;
						}
						if (mrzData[n] == false) {
							valid = false;
							break;
						}
					}
				}
				if (valid == false) {
					ToastMessage.display(Lang.somethingWentWrong);
					video.toStartState();
				} else {
					video.onSuccess();
					if (onSuccess != null) {
						action.data = { mrz: JSON.parse(phpRespond.data.result as String).data };
						onSuccess(this);
					}
				}
			}
			phpRespond.dispose();
		}
		
		public function dispose():void
		{
			TweenMax.killDelayedCallsTo(showCamera);
		}
		
		
		/* INTERFACE com.dukascopy.connect.sys.viManager.actions.IBotAction */
		
		public function getData():String 
		{
			return null;
		}
	}
}