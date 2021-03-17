package com.dukascopy.connect.data.screenAction.customActions.chatMessageAction {
	
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.sys.chatManager.ForwardingManager;
	import com.dukascopy.connect.vo.ChatMessageVO;
	import com.dukascopy.langs.Lang;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class ForwardMessageAction extends ScreenAction implements IScreenAction {
		
		private var msgVO:ChatMessageVO;
		
		public function ForwardMessageAction(msgVO:ChatMessageVO) {
			this.msgVO = msgVO;
			setIconClass(IconSend);
			setData(Lang.forwardMessage);
		}
		
		public function execute():void {
			ForwardingManager.openSelectAdresseeScreenForForwardingMessage(msgVO, data);
		}
		
		override public function dispose():void {
			super.dispose();
			msgVO = null;
		}
	}
}