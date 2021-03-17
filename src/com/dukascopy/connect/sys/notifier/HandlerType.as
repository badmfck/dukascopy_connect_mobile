package com.dukascopy.connect.sys.notifier 
{
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class HandlerType
	{
		public var value:String;
		
		public static const LATEST:String = "unread_LATEST";
		public static const CHANNELS:String = "unread_CHANNELS";
		public static const CHAT_911:String = "unread_CHAT_911";
		public static const CHANNELS_TRASH:String = "unread_CHANNELS_TRASH";
		
		public function HandlerType(value:String) 
		{
			this.value = value;
		}
	}
}