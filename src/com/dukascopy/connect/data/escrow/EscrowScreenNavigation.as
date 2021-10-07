package com.dukascopy.connect.data.escrow
{
	import assets.EscrowSuccess;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.GD;
	import com.dukascopy.connect.data.AlertScreenData;
	import com.dukascopy.connect.data.EscrowScreenData;
	import com.dukascopy.connect.data.SelectorItemData;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.managers.escrow.vo.EscrowInstrument;
	import com.dukascopy.connect.screens.dialogs.ScreenWebviewDialogBase;
	import com.dukascopy.connect.screens.dialogs.escrow.AcceptOfferScreen;
	import com.dukascopy.connect.screens.dialogs.escrow.EscrowOfferScreen;
	import com.dukascopy.connect.screens.dialogs.escrow.EscrowPriceScreen;
	import com.dukascopy.connect.screens.dialogs.escrow.EscrowReportScreen;
	import com.dukascopy.connect.screens.dialogs.escrow.ReceiveCryptoScreen;
	import com.dukascopy.connect.screens.dialogs.escrow.RegisterBlockchainScreen;
	import com.dukascopy.connect.screens.dialogs.escrow.RejectOfferScreen;
	import com.dukascopy.connect.screens.dialogs.escrow.SendCryptoExpiredScreen;
	import com.dukascopy.connect.screens.dialogs.escrow.SendCryptoScreen;
	import com.dukascopy.connect.screens.dialogs.escrow.WaitConfirmScreen;
	import com.dukascopy.connect.screens.dialogs.escrow.WaitCryptoScreen;
	import com.dukascopy.connect.screens.dialogs.x.base.float.FloatAlert;
	import com.dukascopy.connect.screens.payments.card.TypeCurrency;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.bankManager.BankManager;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.errors.ErrorLocalizer;
	import com.dukascopy.connect.sys.payments.PayConfig;
	import com.dukascopy.connect.sys.payments.PayManager;
	import com.dukascopy.connect.sys.payments.PaymentsManager;
	import com.dukascopy.connect.sys.payments.advancedPayments.vo.PayTaskVO;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.sys.ws.WSClient;
	import com.dukascopy.connect.vo.ChatMessageVO;
	import com.dukascopy.connect.vo.ChatSystemMsgVO;
	import com.dukascopy.connect.vo.ChatVO;
	import com.dukascopy.connect.vo.users.UserVO;
	import com.dukascopy.langs.Lang;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class EscrowScreenNavigation
	{
		static private var lastRequestData:Request;
		static private var currentPayTask:PayTaskVO;
		private static var transactionId:String;
		static private var payId:String;
		static private var currenDealRawData:Object;
		
		public function EscrowScreenNavigation()
		{
		
		}
		
		public static function init():void
		{
			WSClient.S_ESCROW_DEAL_EVENT.add(onDealEvent);
		}
		
		static private function confirmCryptoReceiveCommand(escrow:EscrowMessageData, messageId:Number, chatVO:ChatVO, created:Number, command:OfferCommand = null):void
		{
			if (command == OfferCommand.request_imvestigation)
			{
				var screenData:EscrowScreenData = new EscrowScreenData();
				screenData.escrowOffer = escrow;
				screenData.created = created;
				screenData.messageId = messageId;
				screenData.callback = requestInvestigation;
				screenData.title = Lang.indicate_issue_type;
				ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, EscrowReportScreen, screenData);
			}
			else if (command == OfferCommand.confirm_crypto_recieve)
			{
				PHP.escrow_addEvent(onConfirmCryptoEvent, {event_type: EscrowEventType.CRYPTO_ACCEPTED, deal_uid: escrow.deal_uid, notifyWS: true});
			//	PHP.escrow_addEvent(onConfirmCryptoEvent, {event_type: "cp2p_crypto_accepted", deal_uid: escrow.deal_uid, notifyWS: true});
			}
		}
		
		static private function onConfirmCryptoEvent(respond:PHPRespond):void 
		{
			trace("123");
		}
		
		static public function showScreen(escrow:EscrowMessageData, created:Number, userVO:UserVO, chatVO:ChatVO, messageId:Number):void
		{
			GD.S_STOP_LOAD.invoke();
			lastRequestData = null;
			if (escrow != null)
			{
				if (escrow.inactive == true)
				{
					return;
				}
				
				var screenData:EscrowScreenData = new EscrowScreenData();
				screenData.escrowOffer = escrow;
				screenData.created = created;
				screenData.chat = chatVO;
				screenData.messageId = messageId;
				
				
				/*showFinishScreen(escrow);
				   return;*/
				
				if (userVO != null)
				{
					screenData.userName = userVO.getDisplayName();
				}
				else
				{
					screenData.userName = Lang.chatmate;
				}
				
				if (escrow.status == EscrowStatus.offer_created)
				{
					if (!isExpired(escrow, created))
					{
						if ((escrow.direction == TradeDirection.sell && escrow.crypto_user_uid == Auth.uid) || (escrow.direction == TradeDirection.buy && escrow.mca_user_uid == Auth.uid))
						{
							screenData.callback = onSelfOfferCommand;
							ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, EscrowOfferScreen, screenData);
						}
						else
						{
							if (lastRequestData != null)
							{
								ApplicationErrors.add("crit lastRequestData != null");
							}
							
							lastRequestData = new Request();
							lastRequestData.escrow = escrow;
							lastRequestData.messageId = messageId;
							lastRequestData.userVO = userVO;
							lastRequestData.chatVO = chatVO;
							lastRequestData.created = created;
							GD.S_START_LOAD.invoke();
							GD.S_ESCROW_INSTRUMENTS.remove(showAcceptScreen);
							//	GD.S_ESCROW_INSTRUMENTS.remove(showCryptoScreen);
							GD.S_ESCROW_INSTRUMENTS.add(showAcceptScreen);
							GD.S_ESCROW_INSTRUMENTS_REQUEST.invoke();
						}
					}
					/*else
					{
						screenData.callback = onSelfOfferCommand;
						ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, EscrowOfferScreen, screenData);
					}*/
				}
				else if (escrow.status == EscrowStatus.offer_cancelled)
				{
					
				}
				else if (escrow.status == EscrowStatus.offer_rejected)
				{
					ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, RejectOfferScreen, screenData);
				}
				else if (escrow.status == EscrowStatus.offer_accepted)
				{
					
				}
				else if (escrow.status == EscrowStatus.deal_created)
				{
					if (isExpired(escrow, created))
					{
						//!TODO:;
					//	ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, SendCryptoExpiredScreen, screenData);
					}
					else
					{
						//!TODO:;
					}
				}
				else if (escrow.status == EscrowStatus.deal_mca_hold)
				{
					if (!isExpired(escrow, created))
					{
						if (escrow.direction == TradeDirection.sell)
						{
							if (escrow.crypto_user_uid == Auth.uid)
							{
								//!TODO: check exist escrow.cryptoWallet;
								screenData.callback = onSendTransactionCommand;
								ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, SendCryptoScreen, screenData);
							}
							else
							{
								ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, WaitCryptoScreen, screenData);
							}
						}
						else
						{
							if (escrow.crypto_user_uid == Auth.uid)
							{
								//!TODO: check exist escrow.cryptoWallet;
								screenData.callback = onSendTransactionCommand;
								ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, SendCryptoScreen, screenData);
							}
							else
							{
								ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, WaitCryptoScreen, screenData);
							}
						}
					}
					else
					{
						ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, SendCryptoExpiredScreen, screenData);
					}
				}
				else if (escrow.status == EscrowStatus.paid_crypto)
				{
					if (isExpired(escrow, created))
					{
						//!TODO:;
					//	ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, SendCryptoExpiredScreen, screenData);
					}
					else
					{
						if (escrow.direction == TradeDirection.sell)
						{
							if (escrow.crypto_user_uid == Auth.uid)
							{
								ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, WaitConfirmScreen, screenData);
							}
							else
							{
								screenData.callback = confirmCryptoReceiveCommand;
								ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, ReceiveCryptoScreen, screenData);
							}
						}
						else
						{
							if (escrow.crypto_user_uid == Auth.uid)
							{
								ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, WaitConfirmScreen, screenData);
							}
							else
							{
								screenData.callback = confirmCryptoReceiveCommand;
								ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, ReceiveCryptoScreen, screenData);
							}
						}
					}
				}
				else if (escrow.status == EscrowStatus.deal_completed)
				{
					showFinishScreen(escrow);
				}
			}
			else
			{
				ApplicationErrors.add();
			}
		}
		
		static private function requestInvestigation(escrow:EscrowMessageData, reason:SelectorItemData):void
		{
			if (escrow != null && reason != null)
			{
				GD.S_START_LOAD.invoke();
				sendInvestigationRequest(String(reason.data), escrow.deal_uid);
			}
		}
		
		static private function sendInvestigationRequest(label:String, dealId:String):void
		{
			PHP.escrow_requestInvestigation(onRequestInvestigation, {reason: label, deal_uid: dealId});
		}
		
		static private function onRequestInvestigation(respond:PHPRespond):void
		{
			GD.S_STOP_LOAD.invoke();
			if (respond.error)
			{
				//!TODO:;
				ToastMessage.display(respond.errorMsg);
			}
			else
			{
				var screenData:AlertScreenData = new AlertScreenData();
				screenData.text = Lang.escrow_report_sent;
				screenData.button = Lang.textOk.toUpperCase();
				
				ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, FloatAlert, screenData);
			}
		}
		
		static private function showFinishScreen(escrow:EscrowMessageData):void
		{
			var screenData:AlertScreenData = new AlertScreenData();
			screenData.icon = EscrowSuccess;
			screenData.iconColor = Color.GREEN;
			//	screenData.callback = finishOffer;
			
			var description:String;
			if (escrow.direction == TradeDirection.buy)
			{
				if (escrow.crypto_user_uid == Auth.uid)
				{
					description = Lang.escrow_deal_completed_sell;
					description = description.replace("%@", (EscrowSettings.getCommission(escrow.instrument) * 100));
				}
				else
				{
					description = Lang.escrow_deal_completed_buy;
				}
			}
			else
			{
				if (escrow.crypto_user_uid == Auth.uid)
				{
					description = Lang.escrow_deal_completed_sell;
					description = description.replace("%@", (EscrowSettings.getCommission(escrow.instrument) * 100));
				}
				else
				{
					description = Lang.escrow_deal_completed_buy;
				}
			}
			screenData.text = description;
			screenData.title = Lang.operation_completed;
			screenData.button = Lang.textOk.toUpperCase();
			
			ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, FloatAlert, screenData);
		}
		
		private static function showAcceptScreen(instruments:Vector.<EscrowInstrument>):void
		{
			GD.S_ESCROW_INSTRUMENTS.remove(showAcceptScreen);
			GD.S_STOP_LOAD.invoke();
			
			if (instruments == null)
			{
				return;
			}
			
			var selectedInstrument:EscrowInstrument;
			if (lastRequestData != null && lastRequestData.escrow != null && lastRequestData.escrow.status == EscrowStatus.offer_created)
			{
				if (lastRequestData.escrow.instrument != null)
				{
					for (var i:int = 0; i < instruments.length; i++)
					{
						if (instruments[i].code == lastRequestData.escrow.instrument)
						{
							selectedInstrument = instruments[i];
							break;
						}
					}
				}
				
				var screenData:EscrowScreenData = new EscrowScreenData();
			//	if (selectedInstrument != null && selectedInstrument.isLinked)
				if (selectedInstrument != null)
				{
				//	lastRequestData.escrow.cryptoWallet = selectedInstrument.wallet;
					screenData.escrowOffer = lastRequestData.escrow;
					screenData.created = lastRequestData.created;
					screenData.chat = lastRequestData.chatVO;
					screenData.messageId = lastRequestData.messageId;
					
					if (lastRequestData.userVO != null)
					{
						screenData.userName = lastRequestData.userVO.getDisplayName();
					}
					else
					{
						screenData.userName = Lang.chatmate;
					}
					
					screenData.callback = onOfferCommand;
					screenData.instrument = selectedInstrument;
					ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, AcceptOfferScreen, screenData);
				}
				else
				{
					screenData.escrowOffer = lastRequestData.escrow;
					screenData.callback = onOfferCommand;
					ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, RegisterBlockchainScreen, screenData);
				}
				
				lastRequestData = null;
			}
			else
			{
				ApplicationErrors.add();
			}
		}
		
		static private function onSendTransactionCommand(escrow:EscrowMessageData, messageId:Number, chatVO:ChatVO, command:OfferCommand = null):void
		{
			if (command == OfferCommand.send_transaction_id)
			{
				if (escrow != null)
				{
					PHP.escrow_addEvent(onEventCryptoSend, {event_type: EscrowEventType.PAID_CRYPTO, data:escrow.transactionId, deal_uid: escrow.deal_uid, notifyWS: true}, 
										{transaction:escrow.transactionId, chatVO:chatVO});
				}
				else
				{
					ApplicationErrors.add();
				}
			}
		}
		
		static private function onEventCryptoSend(respond:PHPRespond):void
		{
			if (respond.additionalData != null)
			{
				if ("transaction" in respond.additionalData && "chatVO" in respond.additionalData)
				{
					sendTransactionId(respond.additionalData.transaction, respond.additionalData.chatVO);
				}
				else
				{
					ApplicationErrors.add();
				}
			}
		}
		
		static private function sendTransactionId(transaction:String, chatVO:ChatVO):void 
		{
			/*if (chatVO != null && transaction != null)
			{
				ChatManager.sendMessageToOtherChat("");
			}
			else
			{
				ApplicationErrors.add();
			}*/
		}
		
		static private function onOfferCommand(escrow:EscrowMessageData, messageId:Number, chatVO:ChatVO, command:OfferCommand = null):void
		{
			var messageData:EscrowMessageData;
			var text:String;
			
			if (command == OfferCommand.accept)
			{
				if (escrow != null)
				{
					var debitAccount:String;
					var cryptoWallet:String;
					
					var paymentsSessionId:String;
					
					if (escrow.direction == TradeDirection.sell)
					{
						if (escrow.mca_user_uid == Auth.uid)
						{
							cryptoWallet = escrow.cryptoWallet;
							debitAccount = escrow.debit_account;
						}
						else
						{
							//!TODO:
						}
					}
					
					WSClient.call_accept_offer(messageId, debitAccount, cryptoWallet);
				}
				else
				{
					ApplicationErrors.add();
				}
			}
			else if (command == OfferCommand.reject)
			{
				if (escrow != null)
				{
					WSClient.call_cancel_offer(messageId);
				}
				else
				{
					ApplicationErrors.add();
				}
			}
			else if (command == OfferCommand.register_blockchain)
			{
				registerBlockchain(escrow.instrument);
			}
		}
		
		static public function registerBlockchain(instrument:String):void 
		{
			PayManager.S_DECLARE_BLOCKCHAIN_ADDRESS_ERROR.add(registerAddressLinkError);
			PayManager.S_DECLARE_BLOCKCHAIN_ADDRESS_SUCCESS.add(registerAddressLinkReady);
			
			PayManager.getDeclareBlockchainAddressLink(instrument);
		}
		
		static private function registerAddressLinkReady(callId:String, url:Object):void 
		{
			PayManager.S_DECLARE_BLOCKCHAIN_ADDRESS_ERROR.remove(registerAddressLinkError);
			PayManager.S_DECLARE_BLOCKCHAIN_ADDRESS_SUCCESS.remove(registerAddressLinkReady);
			
			DialogManager.showDialog(ScreenWebviewDialogBase, 
										{
											preventCloseOnBgTap: true, 
											url:url.url, 
											callback: onRegisterblockchainFinish, 
											label: Lang.registerBlockchainAddress
										});
		}
		
		static private function onRegisterblockchainFinish(success:Boolean):void 
		{
			if (success)
			{
				PaymentsManager.updateAccount();
			}
		}
		
		static private function registerAddressLinkError(callId:String, message:String):void 
		{
			PayManager.S_DECLARE_BLOCKCHAIN_ADDRESS_ERROR.remove(registerAddressLinkError);
			PayManager.S_DECLARE_BLOCKCHAIN_ADDRESS_SUCCESS.remove(registerAddressLinkReady);
			
			if (message != null)
			{
				ToastMessage.display(message);
			}
		}
		
		static private function onDealEvent(escrowEventType:String, dealRawData:Object):void 
		{
			//!TODO:; - не использовать объект, получить deal;
			if (escrowEventType == EscrowEventType.CREATED)
			{
				onDealCreated(dealRawData);
			}
			else if (escrowEventType == EscrowEventType.HOLD_MCA)
			{
				//!TODO:;
			}
		}
		
		static private function onDealCreated(dealRawData:Object):void 
		{
			GD.S_ESCROW_DEAL_CREATE_REQUEST
			/*if (dealRawData != null && dealRawData.status == EscrowStatus.deal_created.value)
			{
				if (dealRawData.side == "SELL")
				{
					if (dealRawData.mca_user_uid == Auth.uid)
					{
						makeHold(dealRawData);
					}
				}
				else if (dealRawData.side == "BUY")
				{
					if (dealRawData.crypto_user_uid != Auth.uid)
					{
						makeHold(dealRawData);
					}
					
					//!TODO: проверять если был оффлайн или по нотификации;
				}
				else
				{
					ApplicationErrors.add();
				}
			}*/
		}
		
		static private function makeHold(dealRawData:Object):void 
		{
			//!TODO: добавить комиссию;
			
			currenDealRawData = dealRawData;
			
			currentPayTask = new PayTaskVO(PayTaskVO.TASK_TYPE_RESERVE_TIPS);
			currentPayTask.handleInCustomScreenName = "CreateDeal";
			//!TODO decimals;
			currentPayTask.amount = parseFloat((Number(dealRawData.amount) * Number(dealRawData.price)).toFixed(2));
			currentPayTask.currency = dealRawData.mca_ccy;
			//TODO: hash; 
			currentPayTask.to_uid = dealRawData.hash;
			currentPayTask.from_wallet = dealRawData.debit_account;
			
			var requestPayData:Object = currentPayTask.generateRequestObject();
			requestPayData.message = Lang.escrow_hold;
			requestPayData.description = "escrow hold, e=" + dealRawData.deal_uid;
			
			PaymentsManager.S_ERROR.add(onError);
			PaymentsManager.S_COMPLETE.add(onComplete);
			PaymentsManager.S_BACK.add(onError);
			payId = new Date().time + "_escrow";
			PaymentsManager.startTask(currentPayTask, payId);
		}
		
		private static function onError(errorCode:String = null, errorMessage:String = null):void {
			trace("123"); //!TODO:;
			
		//	S_ACTION_FAIL.invoke(ErrorLocalizer.getPaymentsError(errorCode, errorMessage));
		//	dispose();
		}
		
		private static function onComplete(data:Object, callID:String):void {
			if (payId != callID)
				return;
			if (data != null &&
				data is Array && 
				data.length > 1 &&
				data[1] != null &&
				(data[1] == "COMPLETED" || data[1] == "PENDING"))
					transactionId = (data as Array)[0];
			
			//!TODO:;
			if (currenDealRawData != null)
			{
				PHP.escrow_addEvent(onEventHoldMca, {event_type: EscrowEventType.HOLD_MCA, data: {price:false, mca_trn_id: transactionId}, deal_uid: currenDealRawData.deal_uid, notifyWS: true});
			}
		}
		
		static private function onEventHoldMca(respond:PHPRespond):void 
		{
			trace("123");
		}
		
		private function onRequestComplete():void {
			if (transactionId != null) {
			//	onPaidSuccess(transactionId);
			}
			else {
			//	S_ACTION_FAIL.invoke(Lang.serverError);
			//	dispose();
			}
		}
		
		static private function onSelfOfferCommand(escrow:EscrowMessageData, messageId:Number, chatVO:ChatVO, command:OfferCommand = null):void
		{
			if (command == OfferCommand.cancel)
			{
				if (escrow != null)
				{
					WSClient.call_cancel_offer(messageId);
				}
				else
				{
					ApplicationErrors.add();
				}
			}
		}
		
		static public function isExpired(escrow:EscrowMessageData, created:Number):Boolean
		{
			//!TODO:;
			if (escrow.status == EscrowStatus.offer_created)
			{
				return (((new Date()).time / 1000 - created) / 60) > EscrowSettings.offerMaxTime;
			}
			else if (escrow.status == EscrowStatus.deal_created)
			{
				//!TODO:;
				return (((new Date()).time / 1000 - created) / 60) > EscrowSettings.dealMaxTime;
			}
			else if (escrow.status == EscrowStatus.deal_mca_hold)
			{
				//!TODO:;
				return (((new Date()).time / 1000 - created) / 60) > EscrowSettings.dealMaxTime;
			}
			else if (escrow.status == EscrowStatus.paid_crypto)
			{
				//!TODO:;
				return (((new Date()).time / 1000 - created) / 60) > EscrowSettings.receiptConfirmationTime;
			}
			return false;
		}
	
	/*static public function getLeftTime(escrow:EscrowMessageData, created:Number):Number
	   {
	   if (escrow.status == EscrowStatus.offer_created)
	   {
	   return EscrowSettings.offerMaxTime * 60 - ((new Date()).time / 1000 - escrowOffer.created);
	   }
	   return 0;
	   }*/
	}
}
import com.dukascopy.connect.vo.ChatVO;
import com.dukascopy.connect.vo.users.UserVO;
import com.dukascopy.connect.data.escrow.EscrowMessageData;

class Request
{
	public var escrow:EscrowMessageData;
	public var userVO:UserVO;
	public var chatVO:ChatVO;
	public var messageId:Number;
	public var created:Number;
}