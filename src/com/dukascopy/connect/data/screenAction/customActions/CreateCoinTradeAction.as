package com.dukascopy.connect.data.screenAction.customActions {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.escrow.EscrowDealData;
	import com.dukascopy.connect.data.escrow.EscrowMessageData;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.screens.dialogs.CreateEscrowScreen;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.sys.ws.WSClient;
	import com.dukascopy.connect.type.InvoiceStatus;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.connect.vo.ChatVO;
	import com.dukascopy.connect.vo.QuestionVO;
	import com.dukascopy.connect.vo.chat.ChatMessageInvoiceData;
	import com.dukascopy.connect.vo.users.adds.ChatUserVO;
	import com.dukascopy.langs.Lang;

	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class CreateCoinTradeAction extends ScreenAction implements IScreenAction {
		
		public var chat:ChatVO;
		
		public function CreateCoinTradeAction() {
			setIconClass(Style.icon(Style.ICON_ATTACH_DEAL));
		}
		
		public function execute():void {
			
			var screenData:Object = new Object();
			screenData.title = Lang.makeOffer;
			screenData.headerColor = Style.color(Style.COLOR_BACKGROUND);
			ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, CreateEscrowScreen, screenData);
		}
		
		private function callBackCreateDeal(dealData:EscrowDealData):void {
			if (chat != null && ChatManager.getCurrentChat() && chat.uid == ChatManager.getCurrentChat().uid)
			{
				if (dealData != null)
				{
					sendDeal(dealData);
				}
				else
				{
					ApplicationErrors.add();
					onFail();
				}
			}
			else
			{
				ApplicationErrors.add();
				onFail();
			}
		}
		
		private function onFail():void 
		{
			if (S_ACTION_FAIL != null)
			{
				S_ACTION_FAIL.invoke();
			}
		}
		
		private function sendDeal(dealData:EscrowDealData):void 
		{
			var chatUser:ChatUserVO = UsersManager.getInterlocutor(chat);
			if (chatUser == null)
			{
				onFail();
				return;
			}
			var messageData:EscrowMessageData = new EscrowMessageData();
			messageData.price = dealData.price;
			messageData.amount = dealData.amount;
			
			var text:String = messageData.toJsonString();
			WSClient.call_sendTextMessage(chat.uid, Config.BOUNDS_INVOICE + ChatManager.cryptTXT(text));
			
			if (S_ACTION_SUCCESS != null)
			{
				S_ACTION_SUCCESS.invoke();
			}
		}
	}
}