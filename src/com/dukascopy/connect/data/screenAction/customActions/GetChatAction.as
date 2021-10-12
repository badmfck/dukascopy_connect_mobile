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
			var existingChat:ChatVO = ChatManager.getChatByUID(chatUid);
			if (existingChat != null && existingChat.uid != null && existingChat.uid.length != 0)
			{
				onSuccess(existingChat);
			}
			else
			{
				ChatManager.S_CHAT_PREPARED.add(onChatLoaded);
				ChatManager.S_CHAT_PREPARED_FAIL.add(onChatLoadFail);
				ChatManager.loadChatFromPHP(chatUid, false);
			}
		}
		
		private function onChatLoaded(chatVO:ChatVO):void 
		{
			ChatManager.S_CHAT_PREPARED.remove(onChatLoaded);
			ChatManager.S_CHAT_PREPARED_FAIL.remove(onChatLoadFail);
			onSuccess(chatVO);
		}
		
		private function onChatLoadFail(chatUID:String):void 
		{
			if (chatUid == chatUID)
			{
				onFail();
			}
		}
		
		private function onSuccess(chatVO:ChatVO):void 
		{
			ChatManager.S_CHAT_PREPARED.remove(onChatLoaded);
			ChatManager.S_CHAT_PREPARED_FAIL.remove(onChatLoadFail);
			if (S_ACTION_SUCCESS != null)
			{
				S_ACTION_SUCCESS.invoke(chatVO);
			}
		}
		
		private function onChatLoadedFromPHPAndOpen(phpRespond:PHPRespond):void {
			if (phpRespond.error == true)
			{
				onFail();
			}
			else if (phpRespond.data == null)
			{
				onFail();
			}
			else
			{
				var c:ChatVO = ChatManager.getChatByUID(phpRespond.data.uid);
				
				if (c == null) {
					c = new ChatVO(phpRespond.data);
					ChatManager.addChatToLatest(c, false);
				} else
					c.setData(phpRespond.data);
				
				onSuccess(c);
			}
			
			phpRespond.dispose();
			dispose();
		}
		
		private function onFail():void 
		{
			ChatManager.S_CHAT_PREPARED.remove(onChatLoaded);
			ChatManager.S_CHAT_PREPARED_FAIL.remove(onChatLoadFail);
			if (S_ACTION_FAIL != null)
			{
				S_ACTION_FAIL.invoke();
			}
		}
		
		override public function dispose():void
		{
			super.dispose();
			ChatManager.S_CHAT_PREPARED.remove(onChatLoaded);
			ChatManager.S_CHAT_PREPARED_FAIL.remove(onChatLoadFail);
		}
	}
}