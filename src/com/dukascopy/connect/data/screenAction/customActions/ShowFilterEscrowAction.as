package com.dukascopy.connect.data.screenAction.customActions {
	
	import com.dukascopy.connect.GD;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.managers.escrow.vo.EscrowAdsFilterVO;
	import com.dukascopy.connect.screens.dialogs.escrow.EscrowFilterScreen;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.langs.Lang;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class ShowFilterEscrowAction extends ScreenAction implements IScreenAction {
		
		public function ShowFilterEscrowAction() {
			setIconClass(Style.icon(Style.ICON_FILTERS));
		}
		
		public function execute():void {
			getCurrentFilter();
			
		//	dispose();
		}
		
		private function getCurrentFilter():void 
		{
			GD.S_ESCROW_ADS_FILTER_REQUEST.invoke(onFilter);
		}
		
		private function onFilter(filter:EscrowAdsFilterVO):void 
		{
			if (!disposed)
			{
				ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, EscrowFilterScreen, {title:Lang.escrow_filter_title, callback:onFilters, filter:filter.clone()});
			}
		}
		
		private function onFilters(filter:EscrowAdsFilterVO):void 
		{
			GD.S_ESCROW_ADS_FILTER_SETTED.invoke(filter);
		}
		
		override public function getIconScale():Number {
			return 20/30;
		}
	}
}