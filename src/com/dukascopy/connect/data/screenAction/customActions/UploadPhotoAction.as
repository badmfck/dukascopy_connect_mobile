package com.dukascopy.connect.data.screenAction.customActions 
{
	import assets.BankBotAvatar;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.screens.RootScreen;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class UploadPhotoAction extends ScreenAction implements IScreenAction
	{
		public function UploadPhotoAction() 
		{
			setIconClass(BankBotAvatar);
		}
		
		public function execute():void {
			MobileGui.changeMainScreen(
				RootScreen,
				{
					selectedTab:RootScreen.SETTINGS_SCREEN_ID
				}
			);
		}
		
		override public function dispose():void {
			super.dispose();
		}
	}
}