package com.dukascopy.connect.screens.dialogs.bankBot 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.GiftData;
	import com.dukascopy.connect.gui.button.DDAccountButton;
	import com.dukascopy.connect.gui.button.DDFieldButton;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.renderers.ListPayCurrency;
	import com.dukascopy.connect.gui.list.renderers.ListPayWalletItem;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.preloader.Preloader;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.dialogs.ScreenPayDialog;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.payments.InvoiceManager;
	import com.dukascopy.connect.sys.payments.PayAPIManager;
	import com.dukascopy.connect.sys.payments.PayManager;
	import com.dukascopy.connect.sys.payments.PayServer;
	import com.dukascopy.connect.sys.payments.advancedPayments.vo.PayTaskVO;
	import com.dukascopy.connect.sys.softKeyboard.SoftKeyboard;
	import com.dukascopy.connect.vo.users.UserVO;
	import com.dukascopy.langs.Lang;
	import com.telefision.sys.etc.Print_r;
	import fl.motion.Color;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author Igor Bloom
	 */
	public class OrderCardDialog extends BaseScreen{
	
		private var tst_btnShowDialog:BitmapButton;
		private var selectorDebitAccont:DDAccountButton;
		private var preloaderShown:Boolean;
		private var preloader:com.dukascopy.connect.gui.preloader.Preloader;
		private var selectorCurrency:com.dukascopy.connect.gui.button.DDAccountButton;
		
		public function OrderCardDialog(){
			
		}
		
		override protected function createView():void {
			super.createView();
			
			
			//SHOW TERMS&CONDITIONS
			tst_btnShowDialog = new BitmapButton();
			tst_btnShowDialog.activate();
			tst_btnShowDialog.show();
			tst_btnShowDialog.tapCallback = function():void{
				PayManager.callGetSystemOptions(function():void{
					var termText:String = PayManager.systemOptions.terms;
					if (termText == null) {
						termText = " ";
					}
					DialogManager.alert(Lang.TEXT_TERMS_CONDITIONS, termText, onTermsAndConditionsCallback , Lang.confirm /*"I confirm"*/, Lang.textCancel);	
				});
				
			};
			tst_btnShowDialog.setBitmapData(UI.renderText("Show dialog"));
			view.addChild(tst_btnShowDialog);
			
			
			selectorDebitAccont = new DDAccountButton(openWalletSelector);
			selectorDebitAccont.show();
			selectorDebitAccont.activate();
			view.addChild(selectorDebitAccont);
			
			
			selectorCurrency = new DDAccountButton(openCurrencySelector);
			selectorCurrency.show();
			selectorCurrency.activate();
			view.addChild(selectorCurrency);
			
		}
		
		private function openCurrencySelector():void{
			DialogManager.showDialog(ScreenPayDialog, {callback: callBackSelectCurrency, data: PayManager.systemOptions.currencyList, itemClass: ListPayCurrency, label: Lang.selectCurrency});
		}
		
		private function callBackSelectCurrency(val:Object):void { }
		
		override protected function drawView():void{
			super.drawView();
			selectorDebitAccont.setSize(_width, Config.FINGER_SIZE);
			selectorDebitAccont.y = Config.FINGER_SIZE;
			
			selectorCurrency.y = Config.FINGER_SIZE * 2;
			selectorCurrency.setSize(_width, Config.FINGER_SIZE);
		}
		
		private function openWalletSelector():void{
			if (PayAPIManager.hasSwissAccount == false) {
				DialogManager.alert(Lang.information, Lang.featureNoPaments, createPaymentsAccount, Lang.registrate, Lang.textCancel);
				return;
			}
			
			if (PayManager.accountInfo == null){
				showPreloader();
				deactivateScreen();
			}else{
				showWalletsDialog();
			}
		}
		
		private function showPreloader():void
		{
			preloaderShown = true;
			
			var color:Color = new Color();
			color.setTint(0xFFFFFF, 0.7);
			view.transform.colorTransform = color;
			
			if (preloader == null)
			{
				preloader = new Preloader();
			}
			preloader.x = _width * .5;
			preloader.y = _height * .5;
			view.addChild(preloader);
			preloader.show();
		}
		
		private function createPaymentsAccount(val):void 
		{
		
			if (val != 1) {
				return;
			}
			PayAPIManager.openSwissRTO();
		
		}
		
		private function showWalletsDialog():void 
		{
			DialogManager.showDialog(ScreenPayDialog, {callback: onWalletSelect, data: PayManager.accountInfo.accounts, itemClass: ListPayWalletItem/*ListPayAccount*/, label: Lang.TEXT_SELECT_ACCOUNT});
		}
		
		private function onTermsAndConditionsCallback(i:int):void{
			// terms and conditions 
		}
		
		
		private function onWalletSelect(account:Object):void
		{
			if (account == null) return;
			/*walletSelected = true;
			
			selectedAccount = account;
			selectorDebitAccont.setValue(account);
			
			if (iAmount != null)
			{
				if (selfTransfer)
				{
					if (walletCreditSelected && iAmount.value != null && iAmount.value != "" && !isNaN(Number(iAmount.value)) && selectorCurrency != null && selectorCurrency.value != null)
					{
						acceptButton.activate();
						acceptButton.alpha = 1;
					}
				}
				else if (iAmount.value != null && iAmount.value != "" && !isNaN(Number(iAmount.value)) && selectorCurrency != null && selectorCurrency.value != null)
				{
					acceptButton.activate();
					acceptButton.alpha = 1;
				}
			}
			else
			{
				acceptButton.activate();
				acceptButton.alpha = 1;
			}
			
			loadCommision();*/
		}
		
	}

}