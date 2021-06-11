package com.dukascopy.connect.data.escrow 
{
	import com.dukascopy.connect.screens.dialogs.escrow.EscrowOfferScreen;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.vo.ChatMessageVO;
	import com.dukascopy.connect.vo.users.UserVO;
	import com.dukascopy.langs.Lang;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class EscrowScreenNavigation 
	{
		
		public function EscrowScreenNavigation() 
		{
			
		}
		
		static public function showScreen(escrow:EscrowMessageData, message:ChatMessageVO, userVO:UserVO):void 
		{
			if (escrow != null)
			{
				var screenData:Object = new Object();
				screenData.escrowOffer = escrow;
				screenData.created = message.created;
				screenData.callback = onSelfOfferCommand;
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
						ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, EscrowOfferScreen, screenData);
					}
					else
					{
						//!TODO:;
					}
					
				}
				else if (escrow.status == EscrowStatus.offer_cancelled)
				{
					ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, EscrowOfferScreen, screenData);
				}
				else if (escrow.status == EscrowStatus.offer_rejected)
				{
					ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, EscrowOfferScreen, screenData);
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
		
		static private function onSelfOfferCommand(command:OfferCommand = null):void 
		{
			if (command == OfferCommand.cancel)
			{
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