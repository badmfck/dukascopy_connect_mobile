package com.dukascopy.connect.data.screenAction.customActions{
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.style.Style;
	
	public class ChatCallAction extends ScreenAction implements IScreenAction{
		public function ChatCallAction(){
		}
		
		public function execute():void{
			ChatManager.callToChatUser();
		}
		
		override public function getIconClass():Class {
			
			return Style.icon(Style.ICON_CALLS);
		}
	}
}