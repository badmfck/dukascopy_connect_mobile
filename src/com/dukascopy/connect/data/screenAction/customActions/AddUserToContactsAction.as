package com.dukascopy.connect.data.screenAction.customActions {
	
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.sys.chatManager.ChatUsersManager;
	import com.dukascopy.connect.vo.users.adds.ChatUserVO;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class AddUserToContactsAction extends ScreenAction implements IScreenAction {
		
		public function AddUserToContactsAction() {
			setIconClass(null);
		}
		
		public function execute():void {
			var cuVO:ChatUserVO = getData() as ChatUserVO;
			ChatUsersManager.addUserApproved(cuVO.uid);
			S_ACTION_SUCCESS.invoke();
		}
	}
}