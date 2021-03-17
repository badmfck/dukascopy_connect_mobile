package com.dukascopy.connect.data.screenAction.customActions {
	
	import assets.Icon911;
	import assets.JailedIllustrationClip;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.PopupData;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.screens.EmergencyScreen;
	import com.dukascopy.connect.screens.RootScreen;
	import com.dukascopy.connect.screens.serviceScreen.BottomPopupScreen;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.langs.Lang;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class OpenScreenAction extends ScreenAction implements IScreenAction {
		
		private var screen:Class;
		
		public function OpenScreenAction(screen:Class) {
			this.screen = screen;
		}
		
		public function execute():void {
			var screenData:Object = { };
			screenData.backScreen = MobileGui.centerScreen.currentScreenClass;
			screenData.backScreenData = MobileGui.centerScreen.currentScreen.data;
			MobileGui.changeMainScreen(screen, screenData);
			dispose();
		}
		
		override public function dispose():void {
			super.dispose();
		}
	}
}