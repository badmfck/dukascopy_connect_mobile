package com.dukascopy.connect.screens.dialogs.userPopup 
{
	import assets.IconModeratorPopup;
	import com.dukascopy.langs.Lang;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class RemoveModeratorUserPopup extends UserPopup
	{
		public function RemoveModeratorUserPopup() 
		{
			
		}
		
		override protected function preinitialize():void 
		{
			messageText = Lang.wantRemoveUserModerator;
			buttonRejectText = Lang.textCancel;
			buttonAcceptText = Lang.textRemove;
			iconClass = IconModeratorPopup;
			
			acceptButtonColor = 0x77C043;
			acceptButtonColor2 = 0x62943F;
		}
	}
}