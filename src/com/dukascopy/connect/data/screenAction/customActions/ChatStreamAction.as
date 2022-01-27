package com.dukascopy.connect.data.screenAction.customActions{
	import com.dukascopy.connect.GD;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.style.Style;
	
	public class ChatStreamAction extends ScreenAction implements IScreenAction{
		public function ChatStreamAction(){
		}
		
		public function execute():void{
			GD.CHAT_START_STREAM.invoke();
		}
		
		override public function getIconClass():Class {
			
			return Style.icon(Style.ICON_STREAM);
		}
	}
}