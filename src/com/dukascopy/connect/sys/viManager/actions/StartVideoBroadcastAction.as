package com.dukascopy.connect.sys.viManager.actions 
{
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.screens.chat.video.FloatVideo;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.sys.viManager.VideoConnection;
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
	public class StartVideoBroadcastAction implements IBotAction
	{
		private var connection:VideoConnection;
		public var action:VIAction;
		private var onSuccess:Function;
		private var onFail:Function;
		private var localData:String;
		private var video:FloatVideo;
		
		public function StartVideoBroadcastAction(connection:VideoConnection, action:VIAction, video:FloatVideo) 
		{
			this.connection = connection;
			this.action = action;
			this.video = video;
		}
		
		public function getResult():Vector.<ImageBitmapData>
		{
			return null;
		}
		
		public function getData():String
		{
			return localData;
		}
		
		public function execute(onSuccess:Function, onFail:Function):void 
		{
			this.onSuccess = onSuccess;
			this.onFail = onFail;
			
			if (connection.isConnected())
			{
				onConnectSuccess(connection.getStreamId());
			}
			else
			{
				connection.S_STREAM_READY.add(onConnectSuccess);
				connection.S_CONNECT_ERROR.add(onConnectError);
				connection.connect(video);
			}
		}
		
		private function onConnectError(errorMessage:String):void 
		{
			localData = errorMessage;
			onFail(this);
		}
		
		private function onConnectSuccess(streamID:String):void 
		{
			localData = streamID;
			onSuccess(this);
		}
		
		public function getAction():VIAction 
		{
			return action;
		}
		
		public function dispose():void
		{
			//!TODO:;
			video = null;
			connection = null;
			onSuccess = null;
			onFail = null;
		}
	}
}