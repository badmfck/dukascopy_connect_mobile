package com.dukascopy.connect.sys.chat 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.vo.ChatMessageVO;
	import com.dukascopy.connect.vo.ChatSystemMsgVO;
	import com.dukascopy.connect.vo.ChatVO;
	import flash.events.StatusEvent;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class RichMessageDetector 
	{
		static public var lastSentMessage:Number;
		
		static public var linkPattern:RegExp = /\b((?:https?:\/\/|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}\/)(?:[^\s()<>]+|\(([^\s()<>]+|(\([^\s()<>]+\)))*\))+(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:'".,<>?«»“”‘’]))/ig;
		static private var tasks:Dictionary;
		static private var nativeListener:Boolean;
		
		public function RichMessageDetector() 
		{
			
		}
		
		static public function newMessage(message:ChatMessageVO, chat:ChatVO, mid:Number):void 
		{
			if (lastSentMessage == mid)
			{
				lastSentMessage = -1;
				
				if (Config.PLATFORM_ANDROID == true)
				{
					checkNative();
					
					if (tasks == null)
					{
						tasks = new Dictionary();
					}
					if (tasks[message.id] == null)
					{
						echo("link: task ", lastSentMessage.toString());
						var task:LinkPreviewTask = new LinkPreviewTask(message);
						tasks[message.id] = task;
						task.execute(chat.securityKey);
					}
					else
					{
						ApplicationErrors.add();
					}
				}
				else if(Config.PLATFORM_WINDOWS)
				{
					/*var messageRaw:Object = new Object();
					messageRaw.method = ChatSystemMsgVO.METHOD_NEWS;
					messageRaw.additionalData = "description";
					messageRaw.title = "title";
					messageRaw.img = "https://i.ytimg.com/vi/FLpTv-U4Is8/hqdefault.jpg?t=" + Math.random();
					messageRaw.url = "google.com";
					messageRaw.text = "google.com";
					messageRaw.type = ChatSystemMsgVO.TYPE_CHAT_SYSTEM;
					var result:String = Config.BOUNDS + JSON.stringify(messageRaw);
					ChatManager.updateMessage(result, message.id);*/
				}
			}
		}
		
		static private function checkNative():void 
		{
			if (nativeListener == false)
			{
				nativeListener = true;
				MobileGui.androidExtension.addEventListener(StatusEvent.STATUS, extensionAndroidStatusHandler);
			}
		}
		
		private static function extensionAndroidStatusHandler(e:StatusEvent):void
		{
			switch (e.code) {
				case "linkPreview": {
					echo("link: linkPreview", e.level);
					var linkData:Object;
					try
					{
						linkData = JSON.parse(e.level);
						
						if ("messageId" in linkData)
						{
							if (tasks != null && tasks[linkData.messageId] != null)
							{
								delete tasks[linkData.messageId];
							}
							
							if (linkData.success && linkData.url != null && linkData.url != "")
							{
								var messageRaw:Object = new Object();
								messageRaw.method = ChatSystemMsgVO.METHOD_NEWS;
								if ("description" in linkData)
								{
									messageRaw.additionalData = linkData.description;
								}
								if ("title" in linkData)
								{
									messageRaw.title = linkData.title;
								}
								if ("image" in linkData)
								{
									messageRaw.img = linkData.image;
								}
								if ("url" in linkData)
								{
									messageRaw.url = linkData.url;
									messageRaw.text = linkData.url;
								}
								
								messageRaw.type = ChatSystemMsgVO.TYPE_CHAT_SYSTEM;
							//	message.original = "";
							//	message.content_type = "";
								var result:String = Config.BOUNDS + JSON.stringify(messageRaw);
								ChatManager.updateMessage(result, linkData.messageId);
							}
						}
						else
						{
							ApplicationErrors.add();
						}
						
						if (linkData.success)
						{
							echo("link: image ", linkData.image);
						}
					}
					catch (error:Error)
					{
						
					}
					
					break;
				}
			}
		}
		
		static public function detectLink(message:String):Boolean 
		{
			if (message != null && message.search(linkPattern) == 0 && message.indexOf(" ") == -1)
			{
				return true;
			}
			return false;
		}
	}
}