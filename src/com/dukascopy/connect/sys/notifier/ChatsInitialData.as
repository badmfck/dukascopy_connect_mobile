package com.dukascopy.connect.sys.notifier 
{
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class ChatsInitialData 
	{
		public var fromPHP:Boolean;
		public var chats:Array/*com.dukascopy.connect.vo.ChatVO*/;
		public var firstTime:Boolean;
		
		public function ChatsInitialData(chats:Array/*com.dukascopy.connect.vo.ChatVO*/, fromPHP:Boolean, firstTime:Boolean) 
		{
			this.chats = chats;
			this.fromPHP = fromPHP;
			this.firstTime = firstTime;
		}
	}
}