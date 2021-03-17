package com.dukascopy.connect.screens.roadMap.actions 
{
	import com.dukascopy.connect.data.screenAction.BaseAction;
	import com.dukascopy.connect.data.screenAction.IAction;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.screens.roadMap.SolvencyMethodData;
	import com.dukascopy.connect.screens.roadMap.VerificationMethodsPopup;
	import com.dukascopy.connect.screens.roadMap.VerifyCryptodepositPopup;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.errors.ErrorLocalizer;
	import com.dukascopy.connect.sys.php.PHP;
	import com.dukascopy.connect.sys.php.PHPRespond;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.store.Store;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class SolvencyCheckAction extends BaseAction implements IAction 
	{
		private var lastSelectedCode:String;
		private var needCallback:Boolean;
		public var allowZBX:Boolean = false;
		
		public function SolvencyCheckAction() 
		{
			
		}
		
		override public function dispose():void {
			
		}
		
		public function execute():void 
		{
			Store.load(Store.SOLVENCY_CHECK_CMETHOD, onMethodLoaded);
		}
		
		public function remove():void 
		{
			super.dispose();
		}
		
		private function onMethodLoaded(data:String, err:Boolean):void {
			if (disposed)
			{
				return;
			}
			var selectedMethod:String;
			if (err == false && data != null)
				selectedMethod = data;
			
			ServiceScreenManager.showScreen(
				ServiceScreenManager.TYPE_SCREEN,
				VerificationMethodsPopup,
				{
					allowZBX:allowZBX,
					title:Lang.verificationMethods,
					callback:methodSelected,
					selected:selectedMethod
				}
			);
		}
		
		private function methodSelected(method:String):void
		{
			Store.save(Store.SOLVENCY_CHECK_CMETHOD, method);
			
			if (method == SolvencyMethodData.METHOD_CRYPTO_DEPOSIT)
			{
				TweenMax.delayedCall(1, showVerifyCryptoPopup);
			}
			else
			{
				needCallback = true;
			}
			
			lastSelectedCode = method;
				
			var code:String;
			if (method == SolvencyMethodData.METHOD_ASK_FRIEND)
			{
				code = "DONATE";
			}
			else if (method == SolvencyMethodData.METHOD_CRYPTO_DEPOSIT)
			{
				code = "ZBX";
			}
			else if (method == SolvencyMethodData.METHOD_CARD_DEPOSIT)
			{
				code = "CARD";
			}
			
			if (code != null)
			{
				PHP.call_selectSolvencyMethod(onSolvencySaved, code);
			}
			else
			{
				ApplicationErrors.add();
			}
		}
		
		private function onSolvencySaved(respond:PHPRespond):void 
		{
			if (respond.error)
			{
				ToastMessage.display(ErrorLocalizer.getText(respond.errorMsg));
			}
			else
			{
				if (needCallback && lastSelectedCode != SolvencyMethodData.METHOD_CRYPTO_DEPOSIT)
				{
					if (S_ACTION_SUCCESS != null)
					{
						S_ACTION_SUCCESS.invoke(lastSelectedCode);
					}
					else
					{
						ApplicationErrors.add();
					}
				}
			}
			
			respond.dispose();
		}
		
		private function showVerifyCryptoPopup():void 
		{
			ServiceScreenManager.showScreen(
				ServiceScreenManager.TYPE_SCREEN,
				VerifyCryptodepositPopup,
				{
					title:Lang.verifyWithCtyptoDeposit,
					callback:verifyCtyptoClosed
				}
			);
		}
		
		private function verifyCtyptoClosed(success:Boolean = false):void 
		{
			if (S_ACTION_SUCCESS != null)
			{
				S_ACTION_SUCCESS.invoke(SolvencyMethodData.METHOD_CRYPTO_DEPOSIT, success);
			}
			else
			{
				ApplicationErrors.add();
			}
		}
	}
}