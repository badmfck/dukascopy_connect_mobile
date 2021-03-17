package com.dukascopy.connect.vo {
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.LocalAvatars;
	import com.dukascopy.connect.vo.users.UserVO;
	import com.dukascopy.connect.vo.users.adds.ChatUserVO;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class ChatUserlistModel  {
		
		public var contact:UserVO;
		public var statusText:String;
		public var status:int;
		public var chatUid:String;
		
		public function ChatUserlistModel() { }
		
		public function dispose():void 
		{
			statusText = null;
			status = 0;
			chatUid = null;
			contact = null;
		}
		
		public function get avatarURL():Object { 
			if (contact != null)
			{
				var avatar:String = contact.getAvatarURL();
				if (contact.type == UserVO.TYPE_BOT)
				{
					if (LocalAvatars.isLocal(avatar))
					{
						return avatar;
					}
					else{
						if (avatar != null && avatar != "")
						{
							return Config.URL_PHP_CORE_SERVER_FILE + "?method=files.get&key=web&uid=" + avatar + "&type=image";
						}
					}
				}
				return avatar;
			}
			
			return null;
		}
	}
}