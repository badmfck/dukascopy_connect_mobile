package com.dukascopy.connect.data.escrow 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.GD;
	import com.dukascopy.connect.managers.escrow.vo.EscrowInstrument;
	import com.dukascopy.connect.screens.dialogs.escrow.AcceptOfferScreen;
	import com.dukascopy.connect.screens.dialogs.escrow.EscrowOfferScreen;
	import com.dukascopy.connect.screens.dialogs.escrow.RegisterBlockchainScreen;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
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
					if (message.userUID == Auth.uid)
					{
						screenData.callback = onSelfOfferCommand;
						ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, EscrowOfferScreen, screenData);
					}
					else
					{
						lastRequestData = new Request();
						lastRequestData.escrow = escrow;
						lastRequestData.message = message;
						lastRequestData.userVO = userVO;
						lastRequestData.chatVO = chatVO;
						GD.S_START_LOAD.invoke();
						GD.S_ESCROW_INSTRUMENTS.add(showAcceptScreen);
						GD.S_ESCROW_INSTRUMENTS_REQUEST.invoke();
					}
				}
				else if (escrow.status == EscrowStatus.offer_cancelled)
				{
					ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, EscrowOfferScreen, screenData);
				}
				else if (escrow.status == EscrowStatus.offer_rejected)
				{
					
				}
				else if (escrow.status == EscrowStatus.offer_accepted)
				{
					//!TODO:;
				}
			}
			else
			{
				ApplicationErrors.add();
			}
		}
		
		private static function showAcceptScreen(instruments:Vector.<EscrowInstrument>):void 
		{
			GD.S_STOP_LOAD.invoke();
			
			if (lastRequestData != null && lastRequestData.escrow != null && lastRequestData.escrow.status == EscrowStatus.offer_created)
			{
				var instrumentExist:Boolean = false;
				if (lastRequestData.escrow.instrument != null && instruments != null)
				{
					for (var i:int = 0; i < instruments.length; i++) 
					{
						if (instruments[i].code == lastRequestData.escrow.instrument)
						{
							instrumentExist = true;
							break;
						}
					}
				}
				instrumentExist = false;
				var screenData:Object = new Object();
				if (instrumentExist)
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
		
		static private function onOfferCommand(escrow:EscrowMessageData, message:ChatMessageVO, chatVO:ChatVO, command:OfferCommand = null):void 
		{
			var messageData:EscrowMessageData;
			var text:String;
			
			if (command == OfferCommand.accept)
			{
				if (escrow != null)
				{
					messageData = new EscrowMessageData();
					messageData.type = ChatSystemMsgVO.TYPE_ESCROW_OFFER;
					messageData.price = escrow.price;
					messageData.amount = escrow.amount;
					messageData.currency = escrow.currency;
					messageData.instrument = escrow.instrument;
					messageData.direction = escrow.direction;
					messageData.status = EscrowStatus.offer_accepted; 
					
					text = messageData.toJsonString();
					WSClient.call_updateTextMessage(chatVO.uid, Config.BOUNDS_INVOICE + ChatManager.cryptTXT(text, chatVO.chatSecurityKey), message.id);
				}
				else
				{
					ApplicationErrors.add();
				}
				
				//!TODO:;
			}
			else if (command == OfferCommand.reject)
			{
				if (escrow != null)
				{
					messageData = new EscrowMessageData();
					messageData.type = ChatSystemMsgVO.TYPE_ESCROW_OFFER;
					messageData.price = escrow.price;
					messageData.amount = escrow.amount;
					messageData.currency = escrow.currency;
					messageData.instrument = escrow.instrument;
					messageData.direction = escrow.direction;
					messageData.status = EscrowStatus.offer_rejected; 
					
					text = messageData.toJsonString();
					WSClient.call_updateTextMessage(chatVO.uid, Config.BOUNDS_INVOICE + ChatManager.cryptTXT(text, chatVO.chatSecurityKey), message.id);
				}
				else
				{
					ApplicationErrors.add();
				}
				
				//!TODO:;
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
					var messageData:EscrowMessageData = new EscrowMessageData();
					messageData.type = ChatSystemMsgVO.TYPE_ESCROW_OFFER;
					messageData.price = escrow.price;
					messageData.amount = escrow.amount;
					messageData.currency = escrow.currency;
					messageData.instrument = escrow.instrument;
					messageData.direction = escrow.direction;
					messageData.status = EscrowStatus.offer_cancelled; 
					
					var text:String = messageData.toJsonString();
					WSClient.call_updateTextMessage(chatVO.uid, Config.BOUNDS_INVOICE + ChatManager.cryptTXT(text, chatVO.chatSecurityKey), message.id);
				}
				else
				{
					ApplicationErrors.add();
				}
				
				//!TODO:;
			}
		}
		
		static public function isExpired(escrow:EscrowMessageData, created:Number):Boolean 
		{
			if (escrow.status == EscrowStatus.offer_created)
			{
				return (((new Date()).time / 1000 - created) / 60) > EscrowSettings.offerMaxTime;
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