package com.dukascopy.connect.data.screenAction.customActions 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.LocalAvatars;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.type.ChatInitType;
	import com.dukascopy.connect.vo.screen.ChatScreenData;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class OpenSupportChatAction extends ScreenAction implements IScreenAction
	{
		public var pid:Number;
		
		public function OpenSupportChatAction(pid:Number) 
		{
			this.pid = pid;
			setIconClass(SWFSupportAvatar);
		}
		
		public function execute():void
		{
			var chatScreenData:ChatScreenData = new ChatScreenData();
			chatScreenData.pid = pid;
			chatScreenData.type = ChatInitType.SUPPORT;
			chatScreenData.backScreen = MobileGui.centerScreen.currentScreenClass;
			chatScreenData.backScreenData = MobileGui.centerScreen.currentScreen.data;
			MobileGui.showChatScreen(chatScreenData);
		}
		
		override public function get avatarURL():String {
			return LocalAvatars.SUPPORT;
		}
	}
}