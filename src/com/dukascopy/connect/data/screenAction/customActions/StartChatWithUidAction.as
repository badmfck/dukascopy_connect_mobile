package com.dukascopy.connect.data.screenAction.customActions {
	
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.type.ChatInitType;
	import com.dukascopy.connect.vo.screen.ChatScreenData;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class StartChatWithUidAction extends ScreenAction implements IScreenAction {
		public function StartChatWithUidAction() {
			setIconClass(SWFEmptyAvatar);
		}
		
		public function execute():void
		{
			var chatScreenData:ChatScreenData = new ChatScreenData();
			chatScreenData.usersUIDs = [additionalData];
			chatScreenData.type = ChatInitType.USERS_IDS;
			chatScreenData.backScreen = MobileGui.centerScreen.currentScreenClass;
			chatScreenData.backScreenData = MobileGui.centerScreen.currentScreen.data;
			MobileGui.showChatScreen(chatScreenData);
		}
	}
}