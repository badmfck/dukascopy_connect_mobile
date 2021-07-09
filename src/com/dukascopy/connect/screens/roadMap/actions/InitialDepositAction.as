package com.dukascopy.connect.screens.roadMap.actions 
{
	import com.dukascopy.connect.GD;
	import com.dukascopy.connect.data.screenAction.BaseAction;
	import com.dukascopy.connect.data.screenAction.IAction;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.screens.dialogs.ScreenWebviewDialogBase;
	import com.dukascopy.connect.screens.dialogs.bottom.implementation.BottomConfirmPopup;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.store.Store;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.type.BankPhaze;
	import com.dukascopy.langs.Lang;
	import com.dukascopy.langs.LangManager;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class InitialDepositAction extends BaseAction implements IAction 
	{
		private var inProgress:Boolean;
		public var price:String;
		
		public function InitialDepositAction(price:String = null) 
		{
			this.price = price;
			if (S_ACTION_SUCCESS)
				S_ACTION_SUCCESS.dispose();
			S_ACTION_SUCCESS = null;
			if (S_ACTION_FAIL)
				S_ACTION_FAIL.dispose();
			S_ACTION_FAIL = null;
		}
		
		public function execute():void 
		{
			showDescription();
		}
		
		public function remove():void 
		{
			GD.S_STOP_LOAD.invoke();
			super.dispose();
		}
		
		override public function dispose():void
		{
			GD.S_STOP_LOAD.invoke();
		//	super.dispose();
		}
		
		private function getLink(proceed:Boolean = true):void 
		{
			if (inProgress == false && proceed == true)
			{
				inProgress = true;
				var service:String;
				if (Auth.bank_phase == BankPhaze.WIRE_DEPOSIT)
				{
					service = "wire";
				}
				GD.S_START_LOAD.invoke();
				PHP.call_loyaltyRegister(onLoyaltyRegister, service);
			}
		}
		
		private function showDescription():void 
		{
			var textValue:String = getDescription();
			textValue = LangManager.replace(/%@/g, textValue, price);
			
			ServiceScreenManager.showScreen(
				ServiceScreenManager.TYPE_SCREEN,
				BottomConfirmPopup,
				{
					illustration:Style.icon(Style.TRANSFER_ILLUSTRATION),
					rejectButton:Lang.textBack,
					callback:getLink,
					title:getTitle(),
					message:textValue
				}
			);
		}
		
		private function getTitle():String 
		{
			if (Auth.bank_phase == BankPhaze.WIRE_DEPOSIT)
			{
				return Lang.solvency_wire_deposit;
			}
			return Lang.initialDeposit;
		}
		
		private function getDescription():String 
		{
			if (Auth.bank_phase == BankPhaze.WIRE_DEPOSIT)
			{
				return Lang.wireDepositDescription;
			}
			return Lang.initialDepositDescription;
		}
		
		private function onLoyaltyRegister(respond:PHPRespond):void {
			GD.S_STOP_LOAD.invoke();
			if (disposed == false)
			{
				if (respond.error == true) {
					ToastMessage.display(Lang.serverError + ": " + respond.errorMsg);
					ApplicationErrors.add(respond.errorMsg);
					inProgress = false;
				} else if (respond.data == null || ("link" in respond.data) == false) {
					ToastMessage.display(Lang.serverError);
				} else {
					var link:String = respond.data.link;
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
					link = link + "&l=" + currentLang;
					
					showWebView(link as String);
				}
			}
			
			respond.dispose();
		}
		
		private function showWebView(url:String):void {
			PHP.call_statVI("fastTrackRequest", "underage");
			var title:String;
			if (Auth.bank_phase == BankPhaze.WIRE_DEPOSIT)
			{
				title = Lang.wireTransfer;
			}
			else
			{
				title = Lang.sendByCart;
			}
			DialogManager.showDialog(
				ScreenWebviewDialogBase, 
				{
					preventCloseOnBgTap: true, 
					url:url, 
					callback: onWebViewCallback, 
					label: title
				}
			);
		}
		
		private function onWebViewCallback(success:Boolean):void{
			inProgress = false;
			if (success == true) {
				//	thank you your transaction in progress
				Store.save(Store.LOYALTY_PENDING, (new Date()).getTime().toString());
				ServiceScreenManager.closeView();
				DialogManager.closeDialog();
				PHP.call_statVI("fastTrackSuccess","underage");
			} else {
				ServiceScreenManager.closeView();
				DialogManager.closeDialog();
			}
		}
	}
}