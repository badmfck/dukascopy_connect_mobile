package com.dukascopy.connect.vo.chat 
{
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class QuestionUserReactions 
	{
		public var username:String;
		public var totalMessages:int;
		public var avatar:String;
		public var uid:String;
		public var mine:int;
		public var all:int;
		public var secretMode:Boolean = false;
		public var filter:String;
		
		public function QuestionUserReactions(data:Object) {
			if (data != null) {
				if ("all" in data)	{
					all = int(data.all);
				}
				if ("mine" in data)	{
					mine = int(data.mine);
				}
				if ("user" in data && data.user != null)
				{
					if ("uid" in data.user)	{
						uid = data.user.uid;
					}
					if ("avatar" in data.user)	{
						avatar = data.user.avatar;
					}
					if ("totalMessages" in data.user)	{
						totalMessages = int(data.user.totalMessages);
					}
					if ("username" in data.user)	{
						username = data.user.username;
					}
				}
			}
		}
	}
}