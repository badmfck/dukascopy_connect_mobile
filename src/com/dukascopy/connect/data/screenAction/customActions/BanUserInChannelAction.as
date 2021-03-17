package com.dukascopy.connect.data.screenAction.customActions {
	
	import assets.StatusRejectcon;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.langs.Lang;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class BanUserInChannelAction extends ScreenAction implements IScreenAction {
		
		public function BanUserInChannelAction(userUID:String, channelUID:String) {
			setIconClass(StatusRejectcon);
			setData(Lang.textBanUser);
		}
		
		public function execute():void {
			S_ACTION_SUCCESS.invoke();
		}
	}
}