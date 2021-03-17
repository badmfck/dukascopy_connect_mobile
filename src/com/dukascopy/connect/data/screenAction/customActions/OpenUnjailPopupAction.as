package com.dukascopy.connect.data.screenAction.customActions {
	
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.usersManager.paidBan.PaidBan;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class OpenUnjailPopupAction extends ScreenAction implements IScreenAction {
		
		public function OpenUnjailPopupAction() {
			
		}
		
		public function execute():void {
			PaidBan.paidUnbanUser(Auth.myProfile);
		}
	}
}