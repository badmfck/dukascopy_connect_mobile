package com.dukascopy.connect.data.screenAction.customActions.chatMessageAction {
	
	import assets.EditIcon;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.vo.ChatMessageVO;
	import com.dukascopy.langs.Lang;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class EditMessageAction extends ScreenAction implements IScreenAction {
		
		private var msgVO:ChatMessageVO;
		
		public function EditMessageAction(msgVO:ChatMessageVO) {
			this.msgVO = msgVO;
			setIconClass(EditIcon);
			setData(Lang.textEdit);
		}
		
		public function execute():void {
			ChatManager.editChatMessage(msgVO);
		}
		
		override public function dispose():void {
			super.dispose();
			msgVO = null;
		}
	}
}