package com.dukascopy.connect.data.screenAction.customActions {
	
	import assets.IconInfoClipSmall;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.sys.promoEvents.PromoEvents;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class OpenPromoEventsInfoAction extends ScreenAction implements IScreenAction {
		
		public function OpenPromoEventsInfoAction() {
			setIconClass(IconInfoClipSmall);
		}
		
		public function execute():void {
			PromoEvents.showRules();
			dispose();
		}
	}
}