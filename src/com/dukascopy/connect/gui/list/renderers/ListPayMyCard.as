package com.dukascopy.connect.gui.list.renderers {

	import com.dukascopy.connect.gui.list.ListItem;

	import flash.display.IBitmapDrawable;

	/**
	 * ...
	 * @author aleksei.leschenko
	 */
	public class ListPayMyCard extends ListPayCard {
		
		public function ListPayMyCard() {
			super();
		}
		
		override public function getView(li:ListItem, h:int, width:int, highlight:Boolean=false):IBitmapDrawable {
			super.getView(li,h,width,highlight);
//			var data:Object = li.data;
			tfInteger.visible = false;
			tfFraction.visible = false;
//			tfCurrency.visible = true;
//			tfStatus.visible = true;
			return this;
		}

	}
}