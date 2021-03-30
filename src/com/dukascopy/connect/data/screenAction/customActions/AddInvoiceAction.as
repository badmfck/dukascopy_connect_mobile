package com.dukascopy.connect.data.screenAction.customActions {
	
	import assets.AttachInvoiceIcon;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.screens.dialogs.ScreenAddInvoiceDialog;
	import com.dukascopy.connect.screens.dialogs.ScreenAlertDialog;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
//	import com.dukascopy.connect.screens.dialogs.paymentDialogs.InvoicePopup;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.type.InvoiceStatus;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.connect.vo.ChatVO;
	import com.dukascopy.connect.vo.QuestionVO;
	import com.dukascopy.connect.vo.chat.ChatMessageInvoiceData;
	import com.dukascopy.connect.vo.users.adds.ChatUserVO;

	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class AddInvoiceAction extends ScreenAction implements IScreenAction {
		
		private var currentData:Object;
		
		public var amount:Number;
		public var currency:String;
		public var comment:String;
		public var confirm:String;
		public var disposeAction:Boolean = true;
		public var blockInputs:Boolean = false;
		
		public function AddInvoiceAction() {
			setIconClass(Style.icon(Style.ICON_ATTACH_INVOICE));
		}
		
		public function execute():void {
			
			var invoiceData:Object = new Object();
			invoiceData.amount = amount;
			invoiceData.currency = currency;
			invoiceData.message = comment;
			invoiceData.confirm = confirm;
			invoiceData.block = blockInputs;
			invoiceData.callback = callBackAddInvoice;
			
			var currentChat:ChatVO = ChatManager.getCurrentChat();
			if (currentChat != null)
			{
				var chatUser:ChatUserVO = UsersManager.getInterlocutor(currentChat);
				invoiceData.user = chatUser.userVO;
			}
			
			ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, ScreenAddInvoiceDialog, invoiceData, 0.5, 0.5, 3);
			
			if (disposeAction)
			{
				dispose();
			}
		}
		
		private function callBackAddInvoice(i:int, paramsObj:Object):void {
			if (i != 1)
			{
				if (S_ACTION_FAIL != null)
				{
					S_ACTION_FAIL.invoke();
				}
				return;
			}
			var currentChat:ChatVO = ChatManager.getCurrentChat();
			if (currentChat == null)
			{
				if (S_ACTION_FAIL != null)
				{
					S_ACTION_FAIL.invoke();
				}
				return;
			}
			var chatUser:ChatUserVO = UsersManager.getInterlocutor(currentChat);
			if (chatUser == null)
			{
				if (S_ACTION_FAIL != null)
				{
					S_ACTION_FAIL.invoke();
				}
				return;
			}
			
			if (confirm != null)
			{
				currentData = paramsObj;
				
				TweenMax.delayedCall(1, showConfirm, null, true);
			}
			else
			{
				send(paramsObj);
			}
		}
		
		private function showConfirm():void 
		{
			DialogManager.alert(Lang.pleaseConfirm, confirm, onConfirmCallback, Lang.textOk, Lang.textBack);
		}
		
		private function onConfirmCallback(i:int):void 
		{
			if (i != 1)
			{
				if (S_ACTION_FAIL != null)
				{
					S_ACTION_FAIL.invoke();
				}
				return;
			}
			send(currentData);
		}
		
		private function send(paramsObj:Object):void 
		{
			var currentChat:ChatVO = ChatManager.getCurrentChat();
			if (currentChat == null)
			{
				if (S_ACTION_FAIL != null)
				{
					S_ACTION_FAIL.invoke();
				}
				return;
			}
			var chatUser:ChatUserVO = UsersManager.getInterlocutor(currentChat);
			if (chatUser == null)
			{
				if (S_ACTION_FAIL != null)
				{
					S_ACTION_FAIL.invoke();
				}
				return;
			}
			
			var qVO:QuestionVO = currentChat.getQuestion();
			var fromIncognitoQuestion:Boolean = (qVO != null && qVO.incognito == true && qVO.userUID == Auth.uid);
			var myPhone:String = "+" + Auth.countryCode + Auth.getMyPhone();
			var myUserName:String = "";
			if (fromIncognitoQuestion){
				myUserName = "Secret";
			}else{
				myUserName  = TextUtils.checkForNumber(Auth.username);				
			}
			
			if (paramsObj != null &&
				"amount" in paramsObj == true &&
				"currency" in paramsObj == true) {
					var data:ChatMessageInvoiceData = ChatMessageInvoiceData.create(Number(paramsObj.amount),
						paramsObj.currency,
						paramsObj.message,
						myUserName,
						Auth.uid,
						(chatUser.secretMode == true) ? "Secret" : chatUser.name,
						chatUser.uid,
						myPhone,
						InvoiceStatus.NEW
					);
					ChatManager.sendInvoiceByData(data);
				if (S_ACTION_SUCCESS != null)
				{
					S_ACTION_SUCCESS.invoke();
				}
				
			}
			else
			{
				if (S_ACTION_FAIL != null)
				{
					S_ACTION_FAIL.invoke();
				}
			}
		}
	}
}