package com.dukascopy.connect.data 
{
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class MessageData 
	{
		public var chatUID:String;
		public var mid:Number;
		
		public function MessageData(chatUID:String, mid:Number) 
		{
			this.chatUID = chatUID;
			this.mid = mid;
		}
	}
}