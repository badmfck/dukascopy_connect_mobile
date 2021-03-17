package com.dukascopy.connect.data.screenAction.customActions 
{
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.screens.dialogs.userPopup.BanInfoPopup;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class ShowBanInfoAction extends ScreenAction implements IScreenAction
	{
		public function ShowBanInfoAction() 
		{
			setIconClass(null);
		}
		
		public function execute():void
		{
			DialogManager.showDialog(BanInfoPopup, getData());
		}
	}
}