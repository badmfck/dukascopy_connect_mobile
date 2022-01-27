package com.dukascopy.connect.data.screenAction.customActions{
	import com.dukascopy.connect.GD;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.type.ChatRoomType;
	import com.dukascopy.langs.Lang;
	
	public class ChatUnSubscribeAction extends ScreenAction implements IScreenAction{
		public function ChatUnSubscribeAction(){
		}
		
		public function execute():void{
			if (ChatManager.getCurrentChat() != null && ChatManager.getCurrentChat().type == ChatRoomType.CHANNEL) {
				GD.CHAT_UNSUBSCRIBE_REQUEST.invoke(ChatManager.getCurrentChat().uid);
			}
		}
		
		private function onUnsubscribeResult(success:Boolean, uid:String, message:String = null):void {
			if (success) {
				message = Lang.channelUnsubscribeSuccess;
			}
			ToastMessage.display(message);
		}
		
		override public function getIconClass():Class {
			return Style.icon(Style.ICON_UNSUBSCRIBE);
		}
	}
}