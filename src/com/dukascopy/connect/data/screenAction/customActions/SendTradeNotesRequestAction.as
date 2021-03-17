package com.dukascopy.connect.data.screenAction.customActions {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.TradeNotesRequest;
	import com.dukascopy.connect.data.coinMarketplace.TradingOrder;
	import com.dukascopy.connect.data.screenAction.IAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.sys.bankManager.BankBotController;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.payments.vo.AccountInfoVO;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.type.ChatInitType;
	import com.dukascopy.connect.type.ChatRoomType;
	import com.dukascopy.connect.vo.ChatSystemMsgVO;
	import com.dukascopy.connect.vo.ChatVO;
	import com.dukascopy.connect.vo.screen.ChatScreenData;
	import com.dukascopy.langs.Lang;
	import com.dukascopy.langs.LangManager;
	import com.telefision.sys.signals.Signal;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class SendTradeNotesRequestAction extends ScreenAction implements IAction {
		
		static public var S_SUCCESS:Signal = new Signal("SendTradeNotesRequestAction.S_SUCCESS");
		static public var S_COMPLETED:Signal = new Signal("SendTradeNotesRequestAction.S_COMPLETED");
		
		private var request:TradeNotesRequest;
		private var account:AccountInfoVO;
		
		public function SendTradeNotesRequestAction(request:TradeNotesRequest, account:AccountInfoVO)
		{
			this.request = request;
			request = request;
			this.account = account;
		}
		
		public function execute():void {
			if (request.side == TradingOrder.SELL) {
				PHP.call_checkForCryptoCashAmount(proceed, getcontractsAddresByNote(request.currency), request.wallet);
				return;
			}
			S_SUCCESS.invoke();
			ChatManager.S_CHAT_OPENED.add(onChatOpened);
			
			var chatScreenData:ChatScreenData = new ChatScreenData();
			chatScreenData.pid = Config.EP_COINS_SUPPORT;
			chatScreenData.type = ChatInitType.SUPPORT;
			chatScreenData.backScreen = MobileGui.centerScreen.currentScreenClass;
			chatScreenData.backScreenData = MobileGui.centerScreen.currentScreen.data;
			MobileGui.showChatScreen(chatScreenData);
			
			dispose();
		}
		
		private function getcontractsAddresByNote(currency:String):String {
			for (var i:int = 0; i < BankBotController.cashContracts.length; i++) {
				if (BankBotController.cashContracts[i].title == request.currency.substr(0, request.currency.length - 1));
					return BankBotController.cashContracts[i].address;
			}
			return "";
		}
		
		private function proceed(phpRespond:PHPRespond):void {
			S_COMPLETED.invoke();
			var data:Object;
			try {
				data = JSON.parse(phpRespond.data as String);
			} catch (err:Error) {
				echo("SendTradeNotesRequestAction", "proceed", err.message);
			}
			if (data.status == "0") {
				DialogManager.alert(Lang.information, data.result);
				return;
			}
			if (isNaN(Number(data.result)) == true) {
				DialogManager.alert(Lang.information, Lang.somethingWentWrong);
				return;
			}
			if (request.amount > Number(data.result)) {
				DialogManager.alert(Lang.information, Lang.notesBCNotEnough);
				return;
			}
			S_SUCCESS.invoke();
			ChatManager.S_CHAT_OPENED.add(onChatOpened);
			
			var chatScreenData:ChatScreenData = new ChatScreenData();
			chatScreenData.pid = Config.EP_COINS_SUPPORT;
			chatScreenData.type = ChatInitType.SUPPORT;
			chatScreenData.backScreen = MobileGui.centerScreen.currentScreenClass;
			chatScreenData.backScreenData = MobileGui.centerScreen.currentScreen.data;
			MobileGui.showChatScreen(chatScreenData);
			
			dispose();
		}
		
		private function onChatOpened():void 
		{
			var currenChat:ChatVO = ChatManager.getCurrentChat();
			if (currenChat != null && currenChat.type == ChatRoomType.COMPANY && currenChat.pid == Config.EP_COINS_SUPPORT)
			{
				ChatManager.S_CHAT_OPENED.remove(onChatOpened);
				
				var systemData:Object = new Object();
				systemData.currency = request.currency;
				systemData.amount = request.amount;
				systemData.creditAccount = request.creditAccount;
				systemData.side = request.side;
				systemData.wallet = request.wallet;
				
				if (account != null)
				{
					systemData.customerNumber = account.customerNumber;
					systemData.phone = account.phone;
					systemData.appVersion = Config.VERSION;
					systemData.lang = LangManager.model.getCurrentLanguageID();
				}
				
				var messageObject:Object = new Object();
				messageObject.additionalData = systemData;
				messageObject.type = ChatSystemMsgVO.TYPE_MESSAGE;
				messageObject.method = ChatSystemMsgVO.DUKASNOTES_REQUEST;
				var initialText:String;
				if (request.side == TradingOrder.BUY)
				{
					initialText = Lang.dukasnotesBuyRequest;
				}
				else if (request.side == TradingOrder.SELL)
				{
					initialText = Lang.dukasnotesSellRequest;
				}
				
				initialText = LangManager.replace(Lang.regExtValue, initialText, request.amount.toString());
				initialText = LangManager.replace(Lang.regExtValue, initialText, request.currency);
				
				messageObject.title = initialText;
				
				ChatManager.sendMessageToOtherChat(Config.BOUNDS + JSON.stringify(messageObject), currenChat.uid, currenChat.securityKey, false);
			}
		}
		
		override public function dispose():void
		{
			super.dispose();
		}
	}
}