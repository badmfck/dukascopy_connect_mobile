package com.dukascopy.connect.data.screenAction.customActions {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.GiftData;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.list.renderers.ListPayWalletItem;
	import com.dukascopy.connect.screens.dialogs.ScreenAlertDialog;
	import com.dukascopy.connect.screens.dialogs.ScreenPayWebviewDialog;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.errors.ErrorLocalizer;
	import com.dukascopy.connect.sys.nativeExtensionController.NativeExtensionController;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.vo.users.UserVO;
	import com.dukascopy.langs.Lang;
	import com.dukascopy.langs.LangManager;
	import flash.events.StatusEvent;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class GiftByCardAction extends ScreenAction implements IScreenAction {
		
		private var _lastCallID:String;
		private var popupTitle:String;
		private var giftData:GiftData;
		private var user:UserVO;
		private var accountExist:Boolean;
		
		public function GiftByCardAction(giftData:GiftData, accountExist:Boolean) {
			this.giftData = giftData;
			this.accountExist = accountExist;
			setIconClass(null);
			popupTitle = Lang.sendByCart;
		}
		
		override public function getAdditionalData():Object { return giftData; }
		
		public function execute():void {
			user = giftData.user;
			if (user != null)
			{
				PHP.payThirdParty(onLinkGenerated, user.uid, giftData.currency, giftData.getValue(), giftData.comment, accountExist);
			}
			else
			{
				getFailSignal().invoke(this);
				ToastMessage.display(Lang.errorUserNotFound);
			}
		}
		
		private function onLinkGenerated(r:PHPRespond):void
		{
			if (r.error == true || r.data == null || !(r.data is String))
			{
				if (r.errorMsg != null)
				{
				//	"pay..07 Error on transaction. HTTP code: 0; Amount must be less than 150 EUR or equivalent in other currency :: 3614"
					
					if (r.errorMsg.indexOf("pay..07") != -1 && r.errorMsg.indexOf("code: 0") != -1)
					{
						var text:String = r.errorMsg;
						var marker:String = "pay..07 Error on transaction. HTTP code: 0; ";
						if (text.indexOf(marker) != -1){
							text = text.substr(marker.length);
						}
						if (text.indexOf(" :: ") != -1){
							text = text.substring(0, text.indexOf(" :: "));
						}
						
						ToastMessage.display(text);
						
						/*ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_DIALOG, ScreenAlertDialog, {
							title:Lang.textError, 
							text:text});*/
						
						
						
					//	DialogManager.alert(Lang.textError, Lang.sendMoneyErrorNoAccount);
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
				getFailSignal().invoke(this);
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
		
		private function onWebViewInvoiceCallback(success:Boolean, popupData:Object = null):void
		{
			if (disposed == true)
			{
				return;
			}
			
			if (success == true)
			{
				getSuccessSignal().invoke(this);
			}
			else
			{
				getFailSignal().invoke(this);
			}
		}
		
		private function extensionAndroidStatusHandler(e:StatusEvent):void
		{
			if (e.code == "webViewClose") {
				if (e.level != null && e.level.indexOf("status=success") != -1) {
					getSuccessSignal().invoke(this);
				}
				else
				{
					getFailSignal().invoke(this);
				}
			}
		}
		
		override public function dispose():void
		{
			super.dispose();
			user = null;
			if (MobileGui.androidExtension != null)
			{
				MobileGui.androidExtension.removeEventListener(StatusEvent.STATUS, extensionAndroidStatusHandler);
			}
		}
	}
}