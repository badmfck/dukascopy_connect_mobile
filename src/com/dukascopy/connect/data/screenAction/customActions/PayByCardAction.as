package com.dukascopy.connect.data.screenAction.customActions {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.list.renderers.ListPayWalletItem;
	import com.dukascopy.connect.screens.dialogs.ScreenPayWebviewDialog;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.errors.ErrorLocalizer;
	import com.dukascopy.connect.sys.nativeExtensionController.NativeExtensionController;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.type.InvoiceStatus;
	import com.dukascopy.connect.vo.ChatMessageVO;
	import com.dukascopy.connect.vo.users.UserVO;
	import com.dukascopy.langs.Lang;
	import com.dukascopy.langs.LangManager;
	import flash.events.StatusEvent;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class PayByCardAction extends ScreenAction implements IScreenAction {
		
		private var userUID:String;
		private var currency:String;
		private var amount:Number;
		private var message:ChatMessageVO;
		private var _lastCallID:String;
		private var user:UserVO;
		private var popupTitle:String;
		private var comment:String;
		private var accountExist:Boolean;
		
		public function PayByCardAction(userUID:String, currency:String, amount:Number, message:ChatMessageVO, comment:String, accountExist:Boolean) {
			this.userUID = userUID;
			this.message = message;
			this.currency = currency;
			this.amount = amount;
			this.comment = comment;
			this.accountExist = accountExist;
			setIconClass(null);
			popupTitle = Lang.payInvoice;
		}
		
		public function execute():void {
			
			user = UsersManager.getUserByUID(userUID);
			if (user != null)
			{
				PHP.payThirdParty(onLinkGenerated, user.uid, currency, amount, comment, accountExist);
			}
			else
			{
				ToastMessage.display(Lang.errorUserNotFound);
				dispose();
			}
		}
		
		private function onLinkGenerated(r:PHPRespond):void 
		{
			if (r.error == true || r.data == null || !(r.data is String))
			{
				if (r.errorMsg != null)
				{
					//"pay..07 Error on transaction. HTTP code: 0; Amount must be less than 150 EUR or equivalent in other currency :: 3614"
					if (r.errorMsg.indexOf("pay..07") != -1 && r.errorMsg.indexOf("code: 0") != -1)
					{
						DialogManager.alert(Lang.textError, Lang.sendMoneyErrorNoAccount);
					}
					else
					{
						ToastMessage.display(ErrorLocalizer.getText(r.errorMsg));
					}
				}
				else
				{
					ToastMessage.display(Lang.serverError);
				}
				
				dispose();
			}
			else
			{
				var currentLang:String = LangManager.model.getCurrentLanguageID();
				if (currentLang == "fr" ||
					currentLang == "ru" ||
					currentLang == "de" ||
					currentLang == "zh" ||
					currentLang == "pl" ||
					currentLang == "ar" ||
					currentLang == "it" ||
					currentLang == "es")
				{
					
				}
				else
				{
					currentLang = "en";
				}
				var url:String = (r.data as String) + "&l=" + currentLang;
				
				if (Config.PLATFORM_ANDROID == true)
				{
					MobileGui.androidExtension.addEventListener(StatusEvent.STATUS, extensionAndroidStatusHandler);
					NativeExtensionController.showWebView(url, popupTitle);
				}
				else
				{
					DialogManager.showDialog(
						ScreenPayWebviewDialog,
						{
							title: popupTitle,
							url:url,
							callback: onWebViewInvoiceCallback
						}, DialogManager.TYPE_SCREEN
					);
				}
			}
			r.dispose();
		}
		
		private function onWebViewInvoiceCallback(success:Boolean, popupData:Object):void
		{
			if (disposed == true)
			{
				return;
			}
			if (success == true && popupData != null && "message" in popupData && popupData.message is ChatMessageVO)
			{
				finishInvoice(popupData.message as ChatMessageVO);
			}
			dispose();
		}
		
		private function finishInvoice(msgVO:ChatMessageVO):void 
		{
			if (msgVO != null && msgVO.systemMessageVO &&  msgVO.systemMessageVO.invoiceVO != null) {				
				msgVO.systemMessageVO.invoiceVO.status = InvoiceStatus.ACCEPTED;
				ChatManager.updateInvoce(Config.BOUNDS + JSON.stringify(msgVO.systemMessageVO.invoiceVO.getData()), msgVO.id);
			} else {
				//trace("Cannot mark Invoice as complete because messageVO is null or messageVO.invoiceData is null");
			}
		}
		
		private function extensionAndroidStatusHandler(e:StatusEvent):void
		{
			if (e.code == "webViewClose") {
				trace("dukascopy.test", "GiftByCardAction.", e.level);
				//trace("!!!!!!!!!!!! extensionAndroidStatusHandler  ", e.level);
				if (e.level != null && e.level.indexOf("status=success")> -1) {
					finishInvoice(message);
				}
				dispose();
			}
		}
		
		override public function dispose():void
		{
			super.dispose();
			if (MobileGui.androidExtension != null)
			{
				MobileGui.androidExtension.removeEventListener(StatusEvent.STATUS, extensionAndroidStatusHandler);
			}
		}
	}
}