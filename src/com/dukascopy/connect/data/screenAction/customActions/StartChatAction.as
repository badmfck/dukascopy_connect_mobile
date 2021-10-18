package com.dukascopy.connect.data.screenAction.customActions {
	
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.type.ChatInitType;
	import com.dukascopy.connect.vo.ChatVO;
	import com.dukascopy.connect.vo.screen.ChatScreenData;
	import white.SoundMessages;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class StartChatAction extends ScreenAction implements IScreenAction {
		
		private var chatUID:String;
		private var chatVO:ChatVO;
		
		public function StartChatAction(chatUID:String, chatVO:ChatVO) {
			this.chatUID = chatUID;
			this.chatVO = chatVO;
			setIconClass(SoundMessages);
		}
		
		public function execute():void
		{
			var chatScreenData:ChatScreenData = new ChatScreenData();
			chatScreenData.chatUID = chatUID;
			chatScreenData.chatVO = chatVO;
			chatScreenData.type = ChatInitType.CHAT;
			chatScreenData.backScreen = MobileGui.centerScreen.currentScreenClass;
			chatScreenData.backScreenData = MobileGui.centerScreen.currentScreen.data;
			MobileGui.showChatScreen(chatScreenData);
		}
	}
}