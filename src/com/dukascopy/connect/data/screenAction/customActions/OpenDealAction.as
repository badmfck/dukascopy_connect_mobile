package com.dukascopy.connect.data.screenAction.customActions {
	
	import com.dukascopy.connect.data.escrow.EscrowMessageData;
	import com.dukascopy.connect.data.escrow.EscrowScreenNavigation;
	import com.dukascopy.connect.data.escrow.EscrowStatus;
	import com.dukascopy.connect.data.escrow.TradeDirection;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.managers.escrow.vo.EscrowOfferVO;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.vo.ChatVO;
	import com.dukascopy.connect.vo.EscrowDealVO;
	import com.dukascopy.connect.vo.users.UserVO;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class OpenDealAction extends OpenOfferAction implements IScreenAction {
		private var dealData:EscrowDealVO;
		private var getChatAction:GetChatAction;
		
		public function OpenDealAction(dealData:EscrowDealVO) {
			
			var escrowData:EscrowMessageData = new EscrowMessageData();
			escrowData.amount = dealData.amount;
			escrowData.chatUID = dealData.chatUID;
			escrowData.crypto_user_uid = dealData.cryptoUserUID;
			escrowData.cryptoWallet = dealData.cryptoWallet;
			escrowData.currency = dealData.currency;
			escrowData.deal_uid = dealData.uid;
			escrowData.debit_account = dealData.debitAccount;
			escrowData.direction = TradeDirection.getDirection(dealData.side);
			escrowData.instrument = dealData.instrument;
			escrowData.mca_user_uid = dealData.mcaUserUID;
			escrowData.msg_id = dealData.messageId;
			escrowData.price = dealData.price;
		//	escrowData.priceID
			escrowData.setStatus(dealData.status); 
			escrowData.transactionId = dealData.cryptoTransactionId;
		//	escrowData.type
		//	escrowData.userUID
			
			super(escrowData, dealData.created.time, dealData.messageId);
			
			setIconClass(null);
		}
	}
}