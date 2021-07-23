package com.dukascopy.connect.data.escrow
{
	import assets.EscrowSuccess;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.GD;
	import com.dukascopy.connect.data.AlertScreenData;
	import com.dukascopy.connect.data.SelectorItemData;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.managers.escrow.vo.EscrowInstrument;
	import com.dukascopy.connect.screens.dialogs.escrow.AcceptOfferScreen;
	import com.dukascopy.connect.screens.dialogs.escrow.EscrowOfferScreen;
	import com.dukascopy.connect.screens.dialogs.escrow.EscrowPriceScreen;
	import com.dukascopy.connect.screens.dialogs.escrow.EscrowReportScreen;
	import com.dukascopy.connect.screens.dialogs.escrow.ReceiveCryptoScreen;
	import com.dukascopy.connect.screens.dialogs.escrow.RegisterBlockchainScreen;
	import com.dukascopy.connect.screens.dialogs.escrow.SendCryptoExpiredScreen;
	import com.dukascopy.connect.screens.dialogs.escrow.SendCryptoScreen;
	import com.dukascopy.connect.screens.dialogs.escrow.WaitCryptoScreen;
	import com.dukascopy.connect.screens.dialogs.x.base.float.FloatAlert;
	import com.dukascopy.connect.screens.payments.card.TypeCurrency;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
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
		
		public function EscrowScreenNavigation()
		{
		
		}
		
		static private function confirmCryptoReceiveCommand(escrow:EscrowMessageData, message:ChatMessageVO, chatVO:ChatVO, command:OfferCommand = null):void
		{
			if (command == OfferCommand.request_imvestigation)
			{
				var screenData:Object = new Object();
				screenData.escrowOffer = escrow;
				screenData.created = message.created;
				screenData.chat = chatVO;
				screenData.message = message;
				screenData.callback = requestInvestigation;
				screenData.title = Lang.indicate_issue_type;
				ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, EscrowReportScreen, screenData);
			}
			else if (command == OfferCommand.confirm_crypto_recieve)
			{
				trace("123");
			}
		}
		
		static public function showScreen(escrow:EscrowMessageData, message:ChatMessageVO, userVO:UserVO, chatVO:ChatVO):void
		{
			GD.S_STOP_LOAD.invoke();
			lastRequestData = null;
			if (escrow != null)
			{
				
				var screenData:Object = new Object();
				screenData.escrowOffer = escrow;
				screenData.created = message.created;
				screenData.chat = chatVO;
				screenData.message = message;
				
				
				
				/*screenData.title = Lang.indicate_issue_type;
				   ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, EscrowReportScreen, screenData);
				   return;*/
				
				/*ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, WaitCryptoScreen, screenData);
				   return;*/
				
				/*ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, SendCryptoExpiredScreen, screenData);
				   return;*/
				
				/*escrow.transactionId = "xf345dfg545hfgh65nmqgh390gghj90w2j45bv";
				   escrow.status = EscrowStatus.deal_created;
				   screenData.callback = confirmCryptoReceiveCommand;
				   ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, ReceiveCryptoScreen, screenData);
				   return;*/
				
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
					if (!isExpired(escrow, message.created))
					{
						if (message.userUID == Auth.uid)
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
							lastRequestData.message = message;
							lastRequestData.userVO = userVO;
							lastRequestData.chatVO = chatVO;
							GD.S_START_LOAD.invoke();
							GD.S_ESCROW_INSTRUMENTS.remove(showAcceptScreen);
							//	GD.S_ESCROW_INSTRUMENTS.remove(showCryptoScreen);
							GD.S_ESCROW_INSTRUMENTS.add(showAcceptScreen);
							GD.S_ESCROW_INSTRUMENTS_REQUEST.invoke();
						}
					}
				}
				else if (escrow.status == EscrowStatus.offer_cancelled)
				{
					
				}
				else if (escrow.status == EscrowStatus.offer_rejected)
				{
					
				}
				else if (escrow.status == EscrowStatus.offer_accepted)
				{
					
				}
				else if (escrow.status == EscrowStatus.deal_created)
				{
					if (isExpired(escrow, message.created))
					{
						ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, SendCryptoExpiredScreen, screenData);
					}
					else
					{
						if (escrow.direction == TradeDirection.sell)
						{
							if (escrow.userUID == Auth.uid)
							{
								
								//!TODO: check exist escrow.cryptoWallet;
								screenData.callback = onSendTransactionCommand;
								ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, SendCryptoScreen, screenData);
								
								/*if (lastRequestData != null)
								   {
								   ApplicationErrors.add("crit lastRequestData != null");
								   }
								
								   lastRequestData = new Request();
								   lastRequestData.escrow = escrow;
								   lastRequestData.message = message;
								   lastRequestData.userVO = userVO;
								   lastRequestData.chatVO = chatVO;
								   GD.S_START_LOAD.invoke();
								   GD.S_ESCROW_INSTRUMENTS.remove(showAcceptScreen);
								   GD.S_ESCROW_INSTRUMENTS.remove(showCryptoScreen);
								   GD.S_ESCROW_INSTRUMENTS.add(showCryptoScreen);
								   GD.S_ESCROW_INSTRUMENTS_REQUEST.invoke();*/
							}
							else
							{
								ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, WaitCryptoScreen, screenData);
							}
						}
					}
				}
			}
			else
			{
				ApplicationErrors.add();
			}
		}
		
		/*private static function showCryptoScreen(instruments:Vector.<EscrowInstrument>):void
		   {
		   GD.S_STOP_LOAD.invoke();
		   GD.S_ESCROW_INSTRUMENTS.remove(showCryptoScreen);
		
		   if (lastRequestData != null && lastRequestData.escrow != null && lastRequestData.escrow.status == EscrowStatus.deal_created)
		   {
		   var instrumentExist:Boolean = false;
		   var selectedInstrument:EscrowInstrument;
		   if (lastRequestData.escrow.instrument != null && instruments != null)
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
		
		   var screenData:Object = new Object();
		   if (selectedInstrument != null)
		   {
		   screenData.escrowOffer = lastRequestData.escrow;
		   if (lastRequestData.message != null)
		   {
		   screenData.created = lastRequestData.message.created;
		   }
		   else
		   {
		   ApplicationErrors.add();
		   }
		
		   screenData.chat = lastRequestData.chatVO;
		   screenData.message = lastRequestData.message;
		
		   if (lastRequestData.userVO != null)
		   {
		   screenData.userName = lastRequestData.userVO.getDisplayName();
		   }
		   else
		   {
		   screenData.userName = Lang.chatmate;
		   }
		
		   screenData.escrowOffer.cryptoWallet = selectedInstrument.wallet;
		   screenData.callback = onSendTransactionCommand;
		   ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, SendCryptoScreen, screenData);
		   }
		   else
		   {
		   //!TODO: not possible;
		   }
		
		   lastRequestData = null;
		   }
		   else
		   {
		   ApplicationErrors.add();
		   }
		   }*/
		
		static private function requestInvestigation(escrow:EscrowMessageData, reason:SelectorItemData):void
		{
			if (escrow != null && reason != null)
			{
				GD.S_START_LOAD.invoke();
				sendInvestigationRequest(reason.label, escrow.deal_uid);
			}
		}
		
		static private function sendInvestigationRequest(label:String, dealId:String):void
		{
			PHP.escrow_requestInvestigation(onRequestInvestigation, {reason: label, supporterChatUID: Config.EP_911, deal_uid: dealId});
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
				description = Lang.escrow_deal_completed_sell;
				description = description.replace("%@", (EscrowSettings.commission * 100));
			}
			else
			{
				description = Lang.escrow_deal_completed_buy;
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
			
			var selectedInstrument:EscrowInstrument;
			if (lastRequestData != null && lastRequestData.escrow != null && lastRequestData.escrow.status == EscrowStatus.offer_created)
			{
				if (lastRequestData.escrow.instrument != null && instruments != null)
				{
					for (var i:int = 0; i < instruments.length; i++)
					{
						//!TODO:?
						if (instruments[i].code == lastRequestData.escrow.instrument && instruments[i].isLinked)
						{
							selectedInstrument = instruments[i];
							break;
						}
					}
				}
				
				var screenData:Object = new Object();
				if (selectedInstrument != null)
				{
					lastRequestData.escrow.cryptoWallet = selectedInstrument.wallet;
					screenData.escrowOffer = lastRequestData.escrow;
					if (lastRequestData.message != null)
					{
						screenData.created = lastRequestData.message.created;
					}
					else
					{
						ApplicationErrors.add();
					}
					
					screenData.chat = lastRequestData.chatVO;
					screenData.message = lastRequestData.message;
					
					if (lastRequestData.userVO != null)
					{
						screenData.userName = lastRequestData.userVO.getDisplayName();
					}
					else
					{
						screenData.userName = Lang.chatmate;
					}
					
					screenData.callback = onOfferCommand;
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
		
		static private function onSendTransactionCommand(escrow:EscrowMessageData, message:ChatMessageVO, chatVO:ChatVO, command:OfferCommand = null):void
		{
			if (command == OfferCommand.send_transaction_id)
			{
				if (escrow != null)
				{
					PHP.escrow_addEvent(onEvent, {event_type: "paid_crypto", data: escrow.transactionId, deal_uid: escrow.deal_uid, notifyWS: true});
				}
				else
				{
					ApplicationErrors.add();
				}
			}
		}
		
		static private function onEvent(respond:PHPRespond):void
		{
			trace("123");
		}
		
		static private function onOfferCommand(escrow:EscrowMessageData, message:ChatMessageVO, chatVO:ChatVO, command:OfferCommand = null):void
		{
			var messageData:EscrowMessageData;
			var text:String;
			
			if (command == OfferCommand.accept)
			{
				if (escrow != null)
				{
					WSClient.call_accept_offer(message.id, escrow.debitAccount, escrow.cryptoWallet);
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
					WSClient.call_cancel_offer(message.id);
				}
				else
				{
					ApplicationErrors.add();
				}
			}
			else if (command == OfferCommand.register_blockchain)
			{
				//!TODO:;
			}
		}
		
		static private function onSelfOfferCommand(escrow:EscrowMessageData, message:ChatMessageVO, chatVO:ChatVO, command:OfferCommand = null):void
		{
			if (command == OfferCommand.cancel)
			{
				if (escrow != null)
				{
					WSClient.call_cancel_offer(message.id);
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
import com.dukascopy.connect.vo.ChatMessageVO;
import com.dukascopy.connect.vo.ChatVO;
import com.dukascopy.connect.vo.users.UserVO;
import com.dukascopy.connect.data.escrow.EscrowMessageData;

class Request
{
	public var escrow:EscrowMessageData;
	public var message:ChatMessageVO;
	public var userVO:UserVO;
	public var chatVO:ChatVO;
}