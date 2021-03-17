package com.dukascopy.connect.data.screenAction.customActions.chatMessageAction {
	
	import assets.SendGiftIcon;
	import com.dukascopy.connect.data.GiftData;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.sys.Gifts;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.type.GiftType;
	import com.dukascopy.connect.vo.ChatMessageVO;
	import com.dukascopy.langs.Lang;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class SendGiftMessageAction extends ScreenAction implements IScreenAction {
		
		private var msgVO:ChatMessageVO;
		
		public function SendGiftMessageAction(msgVO:ChatMessageVO) {
			this.msgVO = msgVO;
			setIconClass(SendGiftIcon);
			setData(Lang.sendGift);
		}
		
		public function execute():void {
			var gift:GiftData = new GiftData();
			gift.chatUID = ChatManager.getCurrentChat().uid;
			gift.type = GiftType.GIFT_X;
			gift.user = msgVO.userVO;
			Gifts.startGift(-1, gift);
		}
		
		override public function dispose():void {
			super.dispose();
			msgVO = null;
		}
	}
}