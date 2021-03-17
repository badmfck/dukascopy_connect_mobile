package com.dukascopy.connect.data.screenAction.customActions.chatMessageAction {
	
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.gui.lightbox.LightBox;
	import com.dukascopy.connect.screens.ChatScreen;
	import com.dukascopy.connect.screens.base.ScreenManager;
	import com.dukascopy.connect.screens.chat.selectAdressee.SelectAdresseeResultVO;
	import com.dukascopy.connect.screens.chat.selectAdressee.SelectAdresseeScreen;
	import com.dukascopy.connect.screens.chat.selectAdressee.SelectAresseeScreenDataVO;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.chatManager.ForwardingManager;
	import com.dukascopy.connect.type.ChatInitType;
	import com.dukascopy.connect.vo.ChatMessageVO;
	import com.dukascopy.connect.vo.screen.ChatScreenData;
	import com.dukascopy.langs.Lang;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class ResendMessageAction extends ScreenAction implements IScreenAction {
		
		private var msgVO:ChatMessageVO;
		
		public function ResendMessageAction(msgVO:ChatMessageVO) {
			this.msgVO = msgVO;
			setIconClass(IconSend);
			setData(Lang.resendMessage);
		}
		
		public function execute():void {
			ChatManager.resendMessage(msgVO);
		}
		
		override public function dispose():void {
			super.dispose();
			msgVO = null;
		}
	}
}