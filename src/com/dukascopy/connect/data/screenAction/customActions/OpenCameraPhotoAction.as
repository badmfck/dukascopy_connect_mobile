package com.dukascopy.connect.data.screenAction.customActions 
{
	import assets.AttachCamIcon;
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
	public class OpenCameraPhotoAction extends ScreenAction implements IScreenAction
	{
		public function OpenCameraPhotoAction() 
		{
			setIconClass(Style.icon(Style.ICON_ATTACH_CAMERA));
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
			PhotoGaleryManager.takeCamera(false, false);
			dispose();
		}
	}
}