package com.dukascopy.connect.screens.dialogs.paymentDialogs 
{
	import com.dukascopy.connect.screens.dialogs.x.base.bottom.ListSelectionPopup;
	import com.dukascopy.connect.type.HitZoneType;
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	public class TransactionPresetsPopup extends ListSelectionPopup
	{
		
		public function TransactionPresetsPopup()
		{
			super();
		}
		
		override protected function createView():void {
			super.createView();
			
			list.setContextAvaliable(true);
		}
		
		override protected function onItemTap(dataObject:Object, n:int):void {
			
			var lastHitzoneObject:Object =  list.getItemByNum(n).getLastHitZoneObject();
			var lhz:String = lastHitzoneObject != null ? lastHitzoneObject.type : null;
			if (lhz == HitZoneType.DELETE) {
				
				if (data != null && "deleteTemplate" in data && data.deleteTemplate != null && data.deleteTemplate is Function && (data.deleteTemplate as Function).length == 1)
				{
					(data.deleteTemplate as Function)(n);
					updateContent();
				}
				return;
			}
			
			super.onItemTap(dataObject, n);
		}
	}
}