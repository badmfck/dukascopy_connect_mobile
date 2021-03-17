package com.dukascopy.connect.data.screenAction.customActions {
	
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.sys.bankManager.BankManager;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class OpenMarketplaceAction extends ScreenAction implements IScreenAction {
		
		public function OpenMarketplaceAction() {
			setIconClass(SWFUpDownArrows);
		}
		
		public function execute():void {
			BankManager.openMarketPlace();
		}
		
		override public function getIconColor():Number {
			return 0x6E92AF;
		}
		
		override public function dispose():void {
			super.dispose();
		}
	}
}