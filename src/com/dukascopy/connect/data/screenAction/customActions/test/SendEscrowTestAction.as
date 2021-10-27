package com.dukascopy.connect.data.screenAction.customActions.test 
{
	import com.dukascopy.connect.GD;
	import com.dukascopy.connect.data.SelectorItemData;
	import com.dukascopy.connect.data.escrow.EscrowEventType;
	import com.dukascopy.connect.data.escrow.EscrowMessageData;
	import com.dukascopy.connect.data.escrow.EscrowScreenNavigation;
	import com.dukascopy.connect.data.escrow.TradeDirection;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.ws.WSClient;
	import com.dukascopy.connect.type.ChatItemContextMenuItemType;
	import com.greensock.TweenMax;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class SendEscrowTestAction extends ScreenAction implements IScreenAction
	{
		private var escrow:EscrowMessageData;
		private var command:String;
		private var messageId:Number;
		
		public function SendEscrowTestAction(escrow:EscrowMessageData, command:String, messageId:Number, text:String) 
		{
			this.escrow = escrow;
			this.command = command;
			this.messageId = messageId;
			
			setData(text);
		}
		
		public function execute():void
		{
			if (command == ChatItemContextMenuItemType.OFFER_ACCEPT)
			{
				callAccept();
			}
			else if (command == ChatItemContextMenuItemType.OFFER_ACCEPT_2)
			{
				callAccept2();
			}
			else if (command == ChatItemContextMenuItemType.OFFER_CANCEL)
			{
				callCancel();
			}
			else if (command == ChatItemContextMenuItemType.OFFER_CANCEL_2)
			{
				callCancel2();
			}
			else if (command == ChatItemContextMenuItemType.OFFER_REJECT)
			{
				calReject();
			}
			else if (command == ChatItemContextMenuItemType.OFFER_REJECT_2)
			{
				calReject2();
			}
			
			else if (command == ChatItemContextMenuItemType.DEAL_ACCEPT_CRYPTO)
			{
				PHP.escrow_addEvent(null, {event_type: EscrowEventType.CRYPTO_ACCEPTED.value, deal_uid: escrow.deal_uid, notifyWS: true});
			}
			else if (command == ChatItemContextMenuItemType.DEAL_CLAIM)
			{
				EscrowScreenNavigation.requestInvestigation(escrow, new SelectorItemData("test claim", "5"));
			}
			else if (command == ChatItemContextMenuItemType.DEAL_SEND_ID)
			{
				PHP.escrow_addEvent(null, {event_type: EscrowEventType.PAID_CRYPTO.value, transaction:"test_id", deal_uid: escrow.deal_uid, notifyWS: true});
			}
			else if (command == ChatItemContextMenuItemType.DEAL_SEND_ID)
			{
				PHP.escrow_addEvent(null, {event_type: EscrowEventType.HOLD_MCA.value, data:{mca_trn_id:"qPTUotIJ", price:escrow.price}, deal_uid: escrow.deal_uid, notifyWS: true});
			}
			else if (command == ChatItemContextMenuItemType.DEAL_FAIL_HOLD)
			{
				PHP.escrow_addEvent(null, {event_type: EscrowEventType.HOLD_MCA_FAIL.value, deal_uid: escrow.deal_uid, notifyWS: true});
			}
		}
		
		private function calReject2():void 
		{
			calReject();
			TweenMax.delayedCall(0.05, calReject);
		}
		
		private function callCancel2():void 
		{
			callCancel();
			TweenMax.delayedCall(0.05, callCancel);
		}
		
		private function calReject():void 
		{
			WSClient.call_cancel_offer(messageId);
		}
		
		private function callCancel():void 
		{
			WSClient.call_cancel_offer(messageId);
		}
		
		private function callAccept():void 
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
			
			GD.S_START_LOAD.invoke();
			WSClient.call_accept_offer(messageId, debitAccount, cryptoWallet);
		}
		
		private function callAccept2():void 
		{
			callAccept();
			TweenMax.delayedCall(0.1, callAccept);
		}
	}
}