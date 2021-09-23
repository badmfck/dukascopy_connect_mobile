package com.dukascopy.connect.data.screenAction.customActions {
	
	import assets.StarIcon3;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.GD;
	import com.dukascopy.connect.data.AlertScreenData;
	import com.dukascopy.connect.data.ErrorData;
	import com.dukascopy.connect.data.escrow.EscrowDealData;
	import com.dukascopy.connect.data.escrow.EscrowMessageData;
	import com.dukascopy.connect.data.escrow.EscrowScreenNavigation;
	import com.dukascopy.connect.data.escrow.EscrowSettings;
	import com.dukascopy.connect.data.escrow.EscrowStatus;
	import com.dukascopy.connect.data.escrow.OfferCommand;
	import com.dukascopy.connect.data.escrow.TradeDirection;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.gui.chatInput.ChatInputAndroid;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
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
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.sys.ws.WSClient;
	import com.dukascopy.connect.type.BankPhaze;
	import com.dukascopy.connect.type.ChatRoomType;
	import com.dukascopy.connect.vo.ChatMessageVO;
	import com.dukascopy.connect.vo.ChatSystemMsgVO;
	import com.dukascopy.connect.vo.ChatVO;
	import com.dukascopy.connect.vo.QuestionVO;
	import com.dukascopy.connect.vo.users.adds.ChatUserVO;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;

	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class CreateCoinTradeAction extends ScreenAction implements IScreenAction {
		
		private var pendingOfferData:EscrowDealData;
		public var chat:ChatVO;
		public var direction:TradeDirection;
		public var currency:String;
		public var price:String;
		public var instrument:String;
		public var amount:Number;
		
		public function CreateCoinTradeAction() {
			setIconClass(Style.icon(Style.ICON_ATTACH_DEAL));
		}
		
		public function execute():void {
			
			checkCurrentQuestion();
			
			if (Config.PLATFORM_ANDROID == true || Config.PLATFORM_WINDOWS)
			{
				ChatInputAndroid.S_CLOSE_MEDIA_KEYBOARD.invoke();
			}
			if (Auth.bank_phase == BankPhaze.ACC_APPROVED)
			{
				if (direction != null)
				{
					createOffer(direction);
				}
				else
				{
					ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, StartEscrowScreen, {callback:createOffer});
				}
			}
			else
			{
				ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, RegisterEscrowScreen);
			}
		}
		
		private function checkCurrentQuestion():void 
		{
			if (ChatManager.getCurrentChat() != null && ChatManager.getCurrentChat().type == ChatRoomType.QUESTION)
			{
				var question:QuestionVO = ChatManager.getCurrentChat().getQuestion();
				if (question != null)
				{
					if (question.subtype == "sell")
					{
						if (question.userUID == Auth.uid)
						{
							direction = TradeDirection.sell;
						}
						else
						{
							direction = TradeDirection.buy;
						}
					}
					else
					{
						if (question.userUID == Auth.uid)
						{
							direction = TradeDirection.buy;
						}
						else
						{
							direction = TradeDirection.sell;
						}
					}
				}
				
				currency = question.priceCurrency;
				price = question.price;
				instrument = question.tipsCurrency;
				amount = question.tipsAmount;
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
			
			if (currency != null)
			{
				screenData.currency = currency;
			}
			if (price != null)
			{
				screenData.price = price;
			}
			if (instrument != null)
			{
				screenData.instrument = instrument;
			}
			if (!isNaN(amount))
			{
				screenData.amount = amount;
			}
			
			ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, CreateEscrowScreen, screenData);
		}
		
		private function createQuestionOffer():void 
		{
			var tradeAction:CreateCoinTradeAction = new CreateCoinTradeAction();
			tradeAction.chat = ChatManager.getCurrentChat();
			
			tradeAction.setData(Lang.escrow);
			tradeAction.execute();
		}
		
		private function createEscrowOffer(command:OfferCommand, offer:EscrowDealData):void 
		{
			if (command == OfferCommand.register_blockchain)
			{
				EscrowScreenNavigation.registerBlockchain(offer.instrument);
			}
			else if (command == OfferCommand.create_offer)
			{
				if (chat != null && ChatManager.getCurrentChat() && chat.uid == ChatManager.getCurrentChat().uid)
				{
					if (offer != null)
					{
						reservePriceId(offer);
						
						
					//	sendDeal(offer);
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
		}
		
		private function reservePriceId(offer:EscrowDealData):void 
		{
			var request:Object = new Object();
			request.ccy = offer.currency;
			request.crypto = offer.instrument;
			if (offer.isPercent)
			{
				request.price = offer.price + "%";
			//	request.percent_price = true;
			}
			else
			{
				request.price = offer.price;
			}
			PHP.escrow_requestPrice(onPriceReady, request, offer);
		}
		
		private function onPriceReady(respond:PHPRespond):void 
		{
			trace("PRICE ID:", respond.data.id);
			if (respond.error)
			{
				onFail();
			}
			else
			{
				if (respond.additionalData != null && respond.additionalData is EscrowDealData)
				{
					var offer:EscrowDealData = respond.additionalData as EscrowDealData;
					sendDeal(offer, respond.data.id);
				}
				else
				{
					ApplicationErrors.add();
					onFail();
				}
			}
			respond.dispose();
		}
		
		private function showCreateSuccessPopup(offer:EscrowDealData):void 
		{
			if (offer == null)
			{
				ApplicationErrors.add();
				return;
			}
			
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
				sum = (offer.amount * offer.price -offer.amount * offer.price * EscrowSettings.getCommission(offer.instrument)).toFixed(decimals) + " " + offer.currency;
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
			hidePreloader();
			TweenMax.killDelayedCallsTo(hidePreloader);
			if (S_ACTION_FAIL != null)
			{
				S_ACTION_FAIL.invoke();
			}
			
			removeListeners();
		}
		
		private function sendDeal(dealData:EscrowDealData, priceID:int):void 
		{
			var chatUser:ChatUserVO = UsersManager.getInterlocutor(chat);
			if (chatUser == null)
			{
				onFail();
				return;
			}
			var messageData:EscrowMessageData = new EscrowMessageData();
			messageData.type = ChatSystemMsgVO.TYPE_ESCROW_OFFER;
		//	messageData.price = dealData.price;
			messageData.amount = dealData.amount;
			messageData.priceID = priceID;
			messageData.currency = dealData.currency;
			messageData.instrument = dealData.instrument;
			messageData.direction = dealData.direction;
			messageData.userUID = Auth.uid;
			messageData.status = EscrowStatus.offer_created;
			if (dealData.accountNumber != null)
			{
				messageData.debit_account = dealData.accountNumber;
			}
			
		//	var text:String = Config.BOUNDS + messageData.toJsonString();
		//	WSClient.call_sendTextMessage(chat.uid, Config.BOUNDS_ESCROW + ChatManager.cryptTXT(text));
			
			pendingOfferData = dealData;
			
			WSClient.S_OFFER_CREATED.add(onOfferCreateSuccess);
			WSClient.S_OFFER_CREATE_FAIL.add(onOfferCreateFail);
			
			showPreloader();
			TweenMax.killDelayedCallsTo(hidePreloader);
			TweenMax.delayedCall(10, hidePreloader);
			WSClient.call_create_offer(messageData.toServerObject(chat.uid));
		}
		
		private function showPreloader():void 
		{
			GD.S_START_LOAD.invoke();
		}
		
		private function hidePreloader():void 
		{
			TweenMax.killDelayedCallsTo(hidePreloader);
			
			GD.S_STOP_LOAD.invoke();
		}
		
		private function onOfferCreateFail(error:ErrorData):void 
		{
			if (error != null && error.message != null)
			{
				ToastMessage.display(error.message);
			}
			onFail();
		}
		
		private function onOfferCreateSuccess(offerData:Object = null):void 
		{
			showCreateSuccessPopup(pendingOfferData);
			onSuccuss();
		}
		
		private function onSuccuss():void 
		{
			hidePreloader();
			TweenMax.killDelayedCallsTo(hidePreloader);
			if (S_ACTION_SUCCESS != null)
			{
				S_ACTION_SUCCESS.invoke();
			}
			
			removeListeners();
		}
		
		private function removeListeners():void 
		{
			WSClient.S_OFFER_CREATED.remove(onOfferCreateSuccess);
			WSClient.S_OFFER_CREATE_FAIL.remove(onOfferCreateFail);
		}
	}
}