package com.dukascopy.connect.screens.roadMap.actions 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.screenAction.BaseAction;
	import com.dukascopy.connect.data.screenAction.IAction;
	import com.dukascopy.connect.type.ChatInitType;
	import com.dukascopy.connect.vo.screen.ChatScreenData;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class StartVideoidentificationAction extends BaseAction implements IAction 
	{
		public var EP:int;
		
		public function StartVideoidentificationAction(EP:int) 
		{
			this.EP = EP;
			
			if (S_ACTION_SUCCESS)
				S_ACTION_SUCCESS.dispose();
			S_ACTION_SUCCESS = null;
			if (S_ACTION_FAIL)
				S_ACTION_FAIL.dispose();
			S_ACTION_FAIL = null;
		}
		
		public function execute():void 
		{
			var chatScreenData:ChatScreenData = new ChatScreenData();
			chatScreenData.pid = EP;
			chatScreenData.type = ChatInitType.SUPPORT;
			chatScreenData.backScreen = MobileGui.centerScreen.currentScreenClass;
			chatScreenData.backScreenData = MobileGui.centerScreen.currentScreen.data;
			MobileGui.showChatScreen(chatScreenData);
		}
	}
}