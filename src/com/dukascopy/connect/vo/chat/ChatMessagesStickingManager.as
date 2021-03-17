package com.dukascopy.connect.vo.chat {

	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.type.ChatMessageType;
	import com.dukascopy.connect.vo.ChatMessageVO;
	import com.dukascopy.connect.vo.ChatVO;
	
	/**
	 * ...
	 * @author David Gnatkivskij. Telefision TEAM Kiev.
	 */

	public class ChatMessagesStickingManager {
		
		public static const stickingMessageTimeLimitSeconds:int = 900;
		
		public static function updateMessagesStickingByIndex(message:ChatMessageVO, prewMessage:ChatMessageVO):void {
			var currState:int = ChatMessageVO.STICKING_NO;
			if (message.typeEnum == ChatMessageType.TEXT && prewMessage.typeEnum == ChatMessageType.TEXT) {
				if (message.userUID == prewMessage.userUID) {
					var timeDifferenceSeconds:int = Math.abs(message.created - prewMessage.created);
					if (timeDifferenceSeconds < stickingMessageTimeLimitSeconds)
						currState = ChatMessageVO.STICKING_YES;
				}
			}
			message.stiking = currState;
		}
	}
}