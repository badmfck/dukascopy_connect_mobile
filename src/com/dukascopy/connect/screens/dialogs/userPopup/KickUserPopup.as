package com.dukascopy.connect.screens.dialogs.userPopup 
{
	import assets.IconKickPopup;
	import com.dukascopy.langs.Lang;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class KickUserPopup extends UserPopup
	{
		public function KickUserPopup() 
		{
			
		}
		
		override protected function preinitialize():void 
		{
			messageText = Lang.wantKickUser;
			buttonRejectText = Lang.textCancel;
			buttonAcceptText = Lang.textKick;
			iconClass = IconKickPopup;
			
			acceptButtonColor = 0xAD1F1E;
			acceptButtonColor2 = 0x8B1718;
		}
	}
}