package com.dukascopy.connect.data.screenAction.customActions {
	
	import assets.EditIcon;
	import com.dukascopy.connect.data.coinMarketplace.TradingOrder;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.langs.Lang;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class EditOrderAction extends ScreenAction implements IScreenAction {
		
		private var order:TradingOrder;
		
		public function EditOrderAction(order:TradingOrder) {
			this.order = order;
			setIconClass(EditIcon);
			setData(Lang.textEdit);
		}
		
		public function execute():void {
			
		}
		
		override public function dispose():void {
			super.dispose();
			order = null;
		}
	}
}