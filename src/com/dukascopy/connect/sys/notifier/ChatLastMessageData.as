package com.dukascopy.connect.sys.notifier 
{
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class ChatLastMessageData 
	{
		public var chatUid:String;
		public var lastReaded:uint;
		
		public function ChatLastMessageData(chatUid:String, lastReaded:uint) 
		{
			this.chatUid = chatUid;
			this.lastReaded = lastReaded;
		}
	}
}