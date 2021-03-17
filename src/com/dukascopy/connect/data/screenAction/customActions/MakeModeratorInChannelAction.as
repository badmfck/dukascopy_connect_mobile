package com.dukascopy.connect.data.screenAction.customActions {
	
	import assets.ModeratorIcon;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.langs.Lang;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class MakeModeratorInChannelAction extends ScreenAction implements IScreenAction {
		
		public function MakeModeratorInChannelAction(userUID:String, channelUID:String) {
			setIconClass(ModeratorIcon);
			setData(Lang.promoteToModerator);
		}
		
		public function execute():void {
			S_ACTION_SUCCESS.invoke();
		}
	}
}