package com.dukascopy.connect.data.escrow 
{
	import com.dukascopy.connect.screens.dialogs.escrow.EscrowOfferScreen;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.vo.ChatMessageVO;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class EscrowScreenNavigation 
	{
		
		public function EscrowScreenNavigation() 
		{
			
		}
		
		static public function showScreen(escrow:EscrowMessageData, message:ChatMessageVO):void 
		{
			if (escrow != null)
			{
				var screenData:Object = new Object();
				screenData.escrowOffer = escrow;
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
			}
			else
			{
				ApplicationErrors.add();
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
	}
}