package com.dukascopy.connect.sys.viManager.actions 
{
	import com.dukascopy.connect.screens.chat.video.FloatVideo;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.viManager.data.VIAction;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class TakePhotoGologrammAction implements IBotAction
	{
		private var video:FloatVideo;
		public var action:VIAction;
		private var onSuccess:Function;
		private var onFail:Function;
		private var localData:Vector.<ImageBitmapData>;
		
		public function TakePhotoGologrammAction(video:FloatVideo, action:VIAction) 
		{
			this.video = video;
			this.action = action;
		}
		
		public function getResult():Vector.<ImageBitmapData>
		{
			return localData;
		}
		
		public function execute(onSuccess:Function, onFail:Function):void 
		{
			this.onSuccess = onSuccess;
			this.onFail = onFail;
			
			video.takePhoto(onResponsePhoto, action.description, FloatVideo.GOLOGRAM);
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
			if (success == true)
			{
				if (localData == null)
				{
					localData = new Vector.<ImageBitmapData>();
				}
				localData.push(result);
				if (action.photoNum <= localData.length)
				{
					if (onSuccess != null)
					{
						video.onSuccess();
						onSuccess(this);
					}
				}
				else
				{
					video.toStartState();
				}
			}
			else
			{
				if (localData != null)
				{
					for (var i:int = 0; i < localData.length; i++) 
					{
						localData[i].dispose();
					}
					localData = null;
				}
				
				if (onFail != null)
				{
					onFail(this);
				}
			}
		}
	}
}