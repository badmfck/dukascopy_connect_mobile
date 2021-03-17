package com.dukascopy.connect.data.screenAction.customActions 
{
	import assets.DeleteIcon;
	import com.dukascopy.connect.data.coinMarketplace.TradingOrder;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.sys.bankManager.BankManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.langs.Lang;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class RemoveOrderAction extends ScreenAction implements IScreenAction
	{
		private var order:TradingOrder;
		
		public function RemoveOrderAction(order:TradingOrder) {
			this.order = order;
			setIconClass(DeleteIcon);
			setData(Lang.textRemove);
		}
		
		public function execute():void {
			DialogManager.alert(Lang.textConfirm, Lang.alertConformDeleteOrder, onDialogResponse, Lang.textRemove, Lang.textCancel);
		}
		
		private function onDialogResponse(val:int):void {
			if (val != 1)
				return;
			
			BankManager.deleteCryptoLot(order.uid);
			order = null;
		}
		
		override public function dispose():void {
			super.dispose();
		//	order = null
		}
	}
}