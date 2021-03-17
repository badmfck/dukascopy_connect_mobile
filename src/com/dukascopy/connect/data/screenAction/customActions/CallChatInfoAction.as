package com.dukascopy.connect.data.screenAction.customActions 
{
	import assets.IconInfoClip;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.screens.ChatScreen;
	import com.dukascopy.connect.screens.base.BaseScreen;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class CallChatInfoAction extends ScreenAction implements IScreenAction
	{
		public function CallChatInfoAction() 
		{
			setIconClass(IconInfoClip);
		}
		
		public function execute():void
		{
			var screen:BaseScreen = MobileGui.centerScreen.currentScreen;
			if (screen && (screen is ChatScreen)) {
				(screen as ChatScreen).showInfo();
			}
			dispose();
		}
	}

}