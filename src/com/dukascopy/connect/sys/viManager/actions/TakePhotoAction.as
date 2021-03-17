package com.dukascopy.connect.sys.viManager.actions 
{
	import com.dukascopy.connect.screens.chat.video.FloatVideo;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.viManager.data.VIAction;
	import com.greensock.TweenMax;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class TakePhotoAction implements IBotAction
	{
		private var video:FloatVideo;
		public var action:VIAction;
		private var onSuccess:Function;
		private var onFail:Function;
		private var localData:ImageBitmapData;
		
		public function TakePhotoAction(video:FloatVideo, action:VIAction) 
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
			video.takePhoto(onResponsePhoto, action.description, FloatVideo.SELFIE);
		}
		
		public function getAction():VIAction 
		{
			return action;
		}
		
		public function dispose():void 
		{
			video = null;
			action = null;
			onSuccess = null;
			onFail = null;
			localData = null;
		}
		
		
		/* INTERFACE com.dukascopy.connect.sys.viManager.actions.IBotAction */
		
		public function getData():String 
		{
			return null;
		}
		
		private function onResponsePhoto(success:Boolean, result:ImageBitmapData = null):void 
		{
			localData = result;
			
			if (success == true)
			{
				if (onSuccess != null)
				{
					video.onSuccess();
					onSuccess(this);
				}
			}
			else
			{
				if (onFail != null)
				{
					onFail(this);
				}
			}
		}
	}
}