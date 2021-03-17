package com.dukascopy.connect.data.screenAction.customActions {
	
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.connectionManager.NetworkManager;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.type.UserBlockStatusType;
	import com.dukascopy.langs.Lang;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class BlockUserAction extends ScreenAction implements IScreenAction {
		
		public function BlockUserAction() {
			setIconClass(null);
		}
		
		public function execute():void {
			if (NetworkManager.isConnected == false)
			{
				ToastMessage.display(Lang.alertProvideInternetConnection);
				return;
			}
			UsersManager.changeUserBlock(data.uid, UserBlockStatusType.BLOCK);
			ChatManager.removeUser(ChatManager.getCurrentChat().uid);
			S_ACTION_SUCCESS.invoke();
		}
	}
}