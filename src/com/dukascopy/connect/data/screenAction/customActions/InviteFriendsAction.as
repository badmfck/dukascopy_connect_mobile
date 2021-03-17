package com.dukascopy.connect.data.screenAction.customActions 
{
	import assets.BankBotAvatar;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.sys.promoEvents.PromoEvents;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class InviteFriendsAction extends ScreenAction implements IScreenAction
	{
		public function InviteFriendsAction() 
		{
			setIconClass(BankBotAvatar);
		}
		
		public function execute():void {
			PromoEvents.inviteFriends();
		}
		
		override public function dispose():void {
			super.dispose();
		}
	}
}