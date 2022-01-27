package com.dukascopy.connect.data.screenAction.customActions {
	
	import assets.Icon911;
	import assets.JailedIllustrationClip;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.PopupData;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.screens.EmergencyScreen;
	import com.dukascopy.connect.screens.RootScreen;
	import com.dukascopy.connect.screens.innerScreens.InnerEscrowInstrumentScreen;
	import com.dukascopy.connect.screens.serviceScreen.BottomPopupScreen;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.type.BankPhaze;
	import com.dukascopy.langs.Lang;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class Open911ScreenAction extends ScreenAction implements IScreenAction {
		
		public function Open911ScreenAction() {
			setIconClass(Style.icon(Style.ICON_911));
		}
		
		public function execute():void {
			if (additionalData != null && additionalData is Function) {
				additionalData(RootScreen.QUESTIONS_SCREEN_ID);
				return;
			}
			/*if (Auth.bank_phase != BankPhaze.ACC_APPROVED) {
				var popupData:PopupData;
				var action:IScreenAction;
				popupData = new PopupData();
				action = new OpenBankAccountAction();
				action.setData(Lang.openBankAccount);
				popupData.action = action;
				popupData.illustration = JailedIllustrationClip;				
				popupData.title = Lang.noBankAccount;
				popupData.text = Lang.featureNoPaments;
				ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, BottomPopupScreen, popupData);
				return;
			}*/
			var screenData:Object = { };
			screenData.backScreen = MobileGui.centerScreen.currentScreenClass;
			screenData.backScreenData = MobileGui.centerScreen.currentScreen.data;
			screenData.temp = Math.random();
			screenData.selectedTab = RootScreen.QUESTIONS_SCREEN_ID;
			MobileGui.changeMainScreen(RootScreen, screenData);
			dispose();
		}
		
		override public function getIconScale():Number {
			return 30/30;
		}
		
		override public function getIconColor():Number {
			return 0x6E92AF;
		}
		
		override public function dispose():void {
			super.dispose();
		}
	}
}