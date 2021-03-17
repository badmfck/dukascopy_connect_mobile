package com.dukascopy.connect.data.screenAction.customActions {
	
	import assets.BankBotAvatar;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class OpenBankAccountAction extends ScreenAction implements IScreenAction {
		
		public function OpenBankAccountAction() {
			setIconClass(SWFAccountAvatar);
		}
		
		public function execute():void {
			MobileGui.openMyAccountIfExist();
		}
		
		override public function getIconColor():Number {
			return 0x6E92AF;
		}
		
		override public function dispose():void {
			super.dispose();
		}
	}
}