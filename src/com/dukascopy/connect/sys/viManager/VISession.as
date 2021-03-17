package com.dukascopy.connect.sys.viManager 
{
	import com.adobe.crypto.MD5;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.viManager.data.VISessoinData;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class VISession 
	{
		private var connection:VIServerConnection;
		private var onStarted:Function;
		private var onFailed:Function;
		private var sessionData:VISessoinData;
		private var videoConnection:VideoConnection;
		
		public var bot:VIBot;
		
		public function VISession(onStarted:Function, onFailed:Function) 
		{
			this.onStarted = onStarted;
			this.onFailed = onFailed;
			
			create();
		}
		
		private function create():void 
		{
			
		}
		
		public function start(chatId:String):void 
		{
			sessionData = new VISessoinData();
			bot = new VIBot(sessionData, sendMessage);
			
			videoConnection = new VideoConnection(MD5.hash(chatId + "_" + Auth.uid));
			bot.videoConnection = videoConnection;
			
			connection = new VIServerConnection(onInitial, onDisconnected, onMessage);
			connection.connect(chatId);
		}
		
		public function close():void 
		{
			if (bot != null)
			{
				bot.onExit();
			}
			if (sessionData != null)
			{
				sessionData.dispose();
				sessionData = null;
			}
			onStarted = null;
			onFailed = null;
			if (connection != null)
			{
				connection.close();
				connection = null;
			}
			if (videoConnection != null)
			{
				videoConnection.dispose();
				videoConnection = null;
			}
		}
		
		public function resume():void 
		{
			if (sessionData.hasMessages())
			{
				bot.setMessages(sessionData.getMessages());
			}
		}
		
		private function sendMessage(message:String):void 
		{
			if (connection != null)
			{
				connection.sendMessage(message);
			}
			else
			{
				ApplicationErrors.add();
			}
		}
		
		private function onMessage(message:Object):void 
		{
			trace("VI_SESSION -> onMessage");
			bot.remoteMessage(message);
		}
		
		private function onInitial(success:Boolean):void 
		{
			if (onStarted != null && onStarted.length == 1)
			{
				onStarted(success);
			}
			else
			{
				ApplicationErrors.add();
			}
		}
		
		private function onDisconnected():void 
		{
			if (onFailed != null && onFailed.length == 0)
			{
				onFailed();
			}
			else
			{
				ApplicationErrors.add();
			}
		}
	}
}