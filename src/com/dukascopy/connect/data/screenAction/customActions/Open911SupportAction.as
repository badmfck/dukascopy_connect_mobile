package com.dukascopy.connect.data.screenAction.customActions {
	
	import assets.IconHelpClip3;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.screens.RootScreen;
	import com.dukascopy.connect.type.ChatInitType;
	import com.dukascopy.connect.vo.screen.ChatScreenData;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class Open911SupportAction extends ScreenAction implements IScreenAction {
		
		public function Open911SupportAction() {
			setIconClass(IconHelpClip3);
		}
		
		public function execute():void {
			var chatScreenData:ChatScreenData = new ChatScreenData();
			chatScreenData.pid = Config.EP_911;
			chatScreenData.type = ChatInitType.SUPPORT;
			chatScreenData.backScreen = RootScreen;
			chatScreenData.backScreenData = null;
			MobileGui.showChatScreen(chatScreenData);
			dispose();
		}
	}
}