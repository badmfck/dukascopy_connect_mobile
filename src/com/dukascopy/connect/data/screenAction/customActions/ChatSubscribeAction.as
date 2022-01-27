package com.dukascopy.connect.data.screenAction.customActions{
	import com.dukascopy.connect.GD;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.type.ChatRoomType;
	
	public class ChatSubscribeAction extends ScreenAction implements IScreenAction{
		public function ChatSubscribeAction(){
		}
		
		public function execute():void{
			if (ChatManager.getCurrentChat() != null && ChatManager.getCurrentChat().type == ChatRoomType.CHANNEL) {
				GD.CHAT_SUBSCRIBE_REQUEST.invoke(ChatManager.getCurrentChat().uid);
			}
		}
		
		override public function getIconClass():Class {
			return Style.icon(Style.ICON_SUBSCRIBE);
		}
	}
}