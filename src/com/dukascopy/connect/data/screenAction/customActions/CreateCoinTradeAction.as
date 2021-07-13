package com.dukascopy.connect.data.screenAction.customActions {
	
	import assets.StarIcon3;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.AlertScreenData;
	import com.dukascopy.connect.data.escrow.EscrowDealData;
	import com.dukascopy.connect.data.escrow.EscrowMessageData;
	import com.dukascopy.connect.data.escrow.EscrowSettings;
	import com.dukascopy.connect.data.escrow.EscrowStatus;
	import com.dukascopy.connect.data.escrow.TradeDirection;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.screens.dialogs.escrow.CreateEscrowScreen;
	import com.dukascopy.connect.screens.dialogs.x.base.float.FloatAlert;
	import com.dukascopy.connect.screens.dialogs.escrow.RegisterEscrowScreen;
	import com.dukascopy.connect.screens.dialogs.escrow.StartEscrowScreen;
	import com.dukascopy.connect.screens.payments.card.TypeCurrency;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.payments.PayManager;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.sys.ws.WSClient;
	import com.dukascopy.connect.type.BankPhaze;
	import com.dukascopy.connect.vo.ChatMessageVO;
	import com.dukascopy.connect.vo.ChatSystemMsgVO;
	import com.dukascopy.connect.vo.ChatVO;
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
			
			if (Auth.bank_phase == BankPhaze.ACC_APPROVED)
			{
				ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, StartEscrowScreen, {callback:createOffer});
			}
			else
			{
				ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, RegisterEscrowScreen);
			}
		}
		
		private function createOffer(selectedDirection:TradeDirection):void 
		{
			var screenData:Object = new Object();
			if (selectedDirection == TradeDirection.buy)
			{
				screenData.title = Lang.create_buy_offer;
			}
			else if (selectedDirection == TradeDirection.sell)
			{
				screenData.title = Lang.create_sell_offer;
			}
			screenData.selectedDirection = selectedDirection;
			screenData.callback = createEscrowOffer;
			
			/*screenData.price = "5";
			screenData.amount = "15";
			screenData.instrument = TypeCurrency.BTC;
			screenData.currency = TypeCurrency.USD;*/
			
			ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, CreateEscrowScreen, screenData);
		}
		
		private function createEscrowOffer(offer:EscrowDealData):void 
		{
			if (chat != null && ChatManager.getCurrentChat() && chat.uid == ChatManager.getCurrentChat().uid)
			{
				if (offer != null)
				{
					sendDeal(offer);
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
			
			showCreateSuccessPopup(offer);
		}
		
		private function showCreateSuccessPopup(offer:EscrowDealData):void 
		{
			var chatUser:ChatUserVO = UsersManager.getInterlocutor(chat);
			var userName:String = Lang.user;
			if (chatUser != null)
			{
				userName = chatUser.userVO.getDisplayName();
			}
			
			var screenData:AlertScreenData = new AlertScreenData();
			screenData.icon = StarIcon3;
			screenData.callback = finishOffer;
			
			var decimals:int = 2;
			if (PayManager.systemOptions != null && PayManager.systemOptions.currencyDecimalRules != null && !isNaN(PayManager.systemOptions.currencyDecimalRules[offer.currency]))
			{
				decimals = PayManager.systemOptions.currencyDecimalRules[offer.currency];
			}
			
			var sum:String;
			var description:String;
			if (offer.direction == TradeDirection.buy)
			{
				sum = (offer.amount * offer.price * EscrowSettings.refundableFee + offer.amount * offer.price).toFixed(decimals) + " " + offer.currency;
				description = Lang.sent_buy_offer_description;
				description = description.replace("%@1", sum);
				description = description.replace("%@2", userName);
				description = description.replace("%@3", EscrowSettings.offerMaxTime);
				description = description.replace("%@4", EscrowSettings.offerMaxTime);
				description = description.replace("%@5", userName);
				screenData.text = description;
			}
			else
			{
				sum = (offer.amount * offer.price -offer.amount * offer.price * EscrowSettings.commission).toFixed(decimals) + " " + offer.currency;
				description = Lang.sent_sell_offer_description;
				description = description.replace("%@1", userName);
				description = description.replace("%@2", EscrowSettings.offerMaxTime);
				description = description.replace("%@3", EscrowSettings.dealMaxTime);
				description = description.replace("%@4", EscrowSettings.offerMaxTime);
				description = description.replace("%@5", userName);
				screenData.text = description;
			}
			
			if (offer.direction == TradeDirection.buy)
				screenData.title = Lang.you_sent_buy_offer;
			else
				screenData.title = Lang.you_sent_sell_offer;
			
			screenData.button = Lang.ok_understood;
			
			ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, FloatAlert, screenData);
		}
		
		private function finishOffer():void 
		{
			trace("123");
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
			messageData.type = ChatSystemMsgVO.TYPE_ESCROW_OFFER;
			messageData.price = dealData.price;
			messageData.amount = dealData.amount;
			messageData.currency = dealData.currency;
			messageData.instrument = dealData.instrument;
			messageData.direction = dealData.direction;
			messageData.userUID = Auth.uid;
			messageData.status = EscrowStatus.offer_created; 
			
			var text:String = messageData.toJsonString();
			WSClient.call_sendTextMessage(chat.uid, Config.BOUNDS_ESCROW + ChatManager.cryptTXT(text));
			
			if (S_ACTION_SUCCESS != null)
			{
				S_ACTION_SUCCESS.invoke();
			}
		}
	}
}