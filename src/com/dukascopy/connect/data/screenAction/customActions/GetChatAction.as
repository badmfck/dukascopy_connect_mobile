package com.dukascopy.connect.data.screenAction.customActions {
	
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.vo.ChatVO;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class GetChatAction extends ScreenAction implements IScreenAction {
		private var chatUid:String;
		
		public function GetChatAction(chatUid:String) {
			
			this.chatUid = chatUid;
			
			setIconClass(null);
		}
		
		public function execute():void {
			var existingChat:ChatVO = ChatManager.getChatWithUsersList([userUID]);
			if (existingChat != null && existingChat.uid != null && existingChat.uid.length != 0)
			{
				ChatManager.sendMessageToOtherChat(message, existingChat.uid, existingChat.securityKey, false);
			}
			else
			{
				PHP.chat_start(onChatLoadedFromPHPAndOpen, [userUID], false, "SendMessageToUserAction");
			}
		}
		
		private function onChatLoadedFromPHPAndOpen(phpRespond:PHPRespond):void {
			if (phpRespond.error == true)
			{
				
			}
			else if (phpRespond.data == null)
			{
				
			}
			else
			{
				var c:ChatVO = ChatManager.getChatByUID(phpRespond.data.uid);
				
				if (c == null) {
					c = new ChatVO(phpRespond.data);
					ChatManager.addChatToLatest(c, false);
				} else
					c.setData(phpRespond.data);
				
				ChatManager.updateLatestsInStore();
				
				ChatManager.sendMessageToOtherChat(message, c.uid, c.securityKey, false);
			}
			
			phpRespond.dispose();
			dispose();
		}
	}
}