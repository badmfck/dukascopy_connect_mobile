package com.dukascopy.connect.data.screenAction.customActions 
{
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.sys.promoEvents.PromoEvents;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class RefreshLotteryDataAction extends ScreenAction implements IScreenAction
	{
		private var fxName:String;
		
		public function RefreshLotteryDataAction() 
		{
			setIconClass(SWFPaymentsRefreshIcon);
		}
		
		public function execute():void {
			PromoEvents.refreshImmediately();
		}
		
		override public function dispose():void {
			super.dispose();
		}
	}
}