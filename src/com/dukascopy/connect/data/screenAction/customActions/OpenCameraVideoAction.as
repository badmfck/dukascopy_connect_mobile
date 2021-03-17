package com.dukascopy.connect.data.screenAction.customActions 
{
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.screens.ChatScreen;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.photoGaleryManager.PhotoGaleryManager;
	import com.dukascopy.connect.sys.style.Style;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class OpenCameraVideoAction extends ScreenAction implements IScreenAction
	{
		public function OpenCameraVideoAction() 
		{
			setIconClass(Style.icon(Style.ICON_ATTACH_VIDEO));
		}
		
		public function execute():void
		{
			if (ChatManager.getCurrentChat() != null && ChatManager.getCurrentChat().uid == ChatScreen.EVENTS_CHANNEL)
			{
				if (Auth.myProfile != null && Auth.myProfile.payRating < 3)
				{
					return;
				}
			}
			
			PhotoGaleryManager.takeCamera(false, true);
			dispose();
		}
	}
}