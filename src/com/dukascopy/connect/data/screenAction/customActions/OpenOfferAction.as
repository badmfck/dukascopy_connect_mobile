package com.dukascopy.connect.data.screenAction.customActions {
	
	import com.dukascopy.connect.data.escrow.EscrowMessageData;
	import com.dukascopy.connect.data.escrow.EscrowScreenNavigation;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.managers.escrow.vo.EscrowOfferVO;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.vo.ChatVO;
	import com.dukascopy.connect.vo.users.UserVO;
	import flash.utils.getTimer;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class OpenOfferAction extends ScreenAction implements IScreenAction {
		protected var offerData:EscrowMessageData;
		private var getChatAction:GetChatAction;
		private var created:Number;
		private var messageId:Number;
		
		public function OpenOfferAction(offerData:EscrowMessageData, created:Number, messageId:Number) {
			
			this.offerData = offerData;
			if (offerData.created == 0)
			{
				offerData.created = created;
			}
			this.created = created;
			this.messageId = messageId;
			
			setIconClass(null);
		}
		
		public function execute():void {
			getChatAction = new GetChatAction(offerData.chatUID);
			getChatAction.S_ACTION_SUCCESS.add(onChatReady);
			getChatAction.S_ACTION_FAIL.add(onChatFail);
			getChatAction.execute();
		}
		
		private function onChatFail():void 
		{
			//!TODO:;
			ApplicationErrors.add();
			
			dispose();
		}
		
		private function onChatReady(chatVO:ChatVO):void 
		{
			var userVO:UserVO;
			
			if (chatVO != null && chatVO.users != null && chatVO.users.length > 0)
			{
				for (var i:int = 0; i < chatVO.users.length; i++) 
				{
					if (chatVO.users[i].uid != Auth.uid)
					{
						userVO = chatVO.users[i].userVO;
					}
				}
			}
			
			
			
			if (userVO == null)
			{
				ApplicationErrors.add();
			}
			
			EscrowScreenNavigation.showScreen(offerData, created, userVO, chatVO, messageId, true);
			
			dispose();
		}
		
		override public function dispose():void
		{
			super.dispose();
			if (getChatAction != null)
			{
				getChatAction.S_ACTION_SUCCESS.remove(onChatReady);
				getChatAction.S_ACTION_FAIL.remove(onChatFail);
				getChatAction.dispose();
				getChatAction = null;
			}
		}
	}
}