package com.dukascopy.connect.vo.chat 
{
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class ChatMessageReaction 
	{
		public var id:Number;
		public var reaction:String;
		public var userUID:String;
		public var username:String;
		public var chatUID:String;
		
		public function ChatMessageReaction(data:Object = null) {
			if (data != null) {
				if ("chatUID" in data && data.chatUID != null) {
					chatUID = data.chatUID;
				}
				if ("id" in data) {
					id = data.id;
				}
				if ("reaction" in data && data.reaction != null) {
					reaction = data.reaction;
				}
				if ("username" in data && data.username != null) {
					username = data.username;
				}
				if ("userUID" in data && data.userUID != null) {
					userUID = data.userUID;
				}
			}
		}
	}
}