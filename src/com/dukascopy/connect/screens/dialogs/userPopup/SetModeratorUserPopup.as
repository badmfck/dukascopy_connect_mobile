package com.dukascopy.connect.screens.dialogs.userPopup 
{
	import assets.IconModeratorPopup;
	import com.dukascopy.langs.Lang;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class SetModeratorUserPopup extends UserPopup
	{
		public function SetModeratorUserPopup() 
		{
			
		}
		
		override protected function preinitialize():void 
		{
			messageText = Lang.wantMakeUserModerator;
			buttonRejectText = Lang.textCancel;
			buttonAcceptText = Lang.textModerator;
			iconClass = IconModeratorPopup;
			
			acceptButtonColor = 0x77C043;
			acceptButtonColor2 = 0x62943F;
		}
	}
}