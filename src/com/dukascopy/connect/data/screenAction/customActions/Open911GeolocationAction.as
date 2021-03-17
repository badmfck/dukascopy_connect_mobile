package com.dukascopy.connect.data.screenAction.customActions {
	
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.screens.geolocation.Geolocation911Screen;
	import com.dukascopy.connect.sys.style.Style;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class Open911GeolocationAction extends ScreenAction implements IScreenAction {
		
		public function Open911GeolocationAction() {
			setIconClass(Style.icon(Style.ICON_GEO));
		}
		
		public function execute():void {
			var screenData:Object = { };
			screenData.backScreen = MobileGui.centerScreen.currentScreenClass;
			screenData.backScreenData = MobileGui.centerScreen.currentScreen.data;
			MobileGui.changeMainScreen(Geolocation911Screen, screenData);
		}
		
		override public function getIconScale():Number {
			return 15/30;
		}
	}
}