package com.dukascopy.connect.data.screenAction.customActions 
{
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.sys.usersManager.paidBan.PaidBan;
	import com.dukascopy.langs.Lang;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class BuyBanProtectionAction extends ScreenAction implements IScreenAction
	{
		public function BuyBanProtectionAction()
		{
		//	setIconClass(IconGroupChat);
			setData(Lang.buyBanProtectionButtonSmall);
		}
		
		public function execute():void
		{
			PaidBan.buyProtection();
		}
	}
}