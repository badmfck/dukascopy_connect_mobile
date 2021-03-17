package com.dukascopy.connect.data.screenAction.customActions {
	
	import assets.IconCardBG;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.screens.RootScreen;
	import com.dukascopy.connect.screens.userProfile.StartChatByPhoneScreen;
	import com.dukascopy.connect.sys.theme.AppTheme;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class PayWithCardAction extends ScreenAction implements IScreenAction {
		
		public function PayWithCardAction() {
			setIconClass(IconCardBG);
		}
		
		public function execute():void {
			MobileGui.changeMainScreen(
				StartChatByPhoneScreen,
				{
					data: { payCard:true },
					backScreen:RootScreen,
					backScreenData:null
				}
			);
		}
		
		override public function getIconColor():Number {
			return AppTheme.GREEN_LIGHT;
		}
		
		override public function dispose():void {
			super.dispose();
		}
	}
}