package com.dukascopy.connect.data.screenAction.customActions {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.screens.RootScreen;
	import com.dukascopy.connect.sys.bankManager.BankManager;
	import com.dukascopy.connect.type.ChatInitType;
	import com.dukascopy.connect.vo.screen.ChatScreenData;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class TradingChannelAction extends ScreenAction implements IScreenAction {
		
		public function TradingChannelAction() {
			setIconClass(SWFBars);
		}
		
		public function execute():void {
			var chatScreenData:ChatScreenData = new ChatScreenData();
			chatScreenData.pid = Config.EP_TRADING;
			chatScreenData.type = ChatInitType.SUPPORT;
			chatScreenData.backScreen = RootScreen;
			chatScreenData.backScreenData = null;
			MobileGui.showChatScreen(chatScreenData);
		}
		
		override public function getIconColor():Number {
			return 0x6E92AF;
		}
		
		override public function dispose():void {
			super.dispose();
		}
	}
}