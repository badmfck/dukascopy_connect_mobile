package com.dukascopy.connect.data.screenAction.customActions {
	
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.screens.base.ScreenManager;
	import com.dukascopy.connect.screens.userProfile.FindUserScreen;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class AddNewContactAction extends ScreenAction implements IScreenAction {
		public function AddNewContactAction() {
			setIconClass(SWFEmptyAvatar);
		}
		
		public function execute():void
		{
			MobileGui.changeMainScreen(FindUserScreen, null, ScreenManager.DIRECTION_RIGHT_LEFT);
		}
	}
}