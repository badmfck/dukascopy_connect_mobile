package com.dukascopy.connect.sys.chatManager {
	
	/**
	 *@author David Gnatkivskij. Telefision TEAM Kiev.
	 */
	
	public class UnreadedChatsCounter {
		
		private static var unreadedChatIDs:Vector.<String> = new Vector.<String>();
		
		public static function notifyChatUnreadedMessagesCount(chatID:String, unreadedMessagesCount:int):void {
			/*var isWasChanged:Boolean = false;
			if (unreadedChatIDs.indexOf(chatID) == -1) {
				if (unreadedMessagesCount > 0) {
					unreadedChatIDs.push(chatID);
					isWasChanged = true;
				}
			} else {
				if (unreadedMessagesCount <= 0) {
					unreadedChatIDs.splice(unreadedChatIDs.indexOf(chatID), 1);
					isWasChanged = true;
				}
			}
			if (isWasChanged) {
				if (Config.PLATFORM_ANDROID) {
					MobileGui.androidExtension.showIconBadge(unreadedChatIDs.length);
				}
			}*/
		}
	}
}