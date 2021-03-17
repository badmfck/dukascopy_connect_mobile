package com.dukascopy.connect.data.filter {
	
	import com.dukascopy.connect.type.FinanceFilterType;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class FilterData {
		
		public var text:String;
		public var type:FinanceFilterType;
		public var iconClass:Class;
		public var selected:Boolean;
		
		public function FilterData(text:String, type:FinanceFilterType, iconClass:Class = null) {
			this.text = text;
			this.type = type;
			this.iconClass = iconClass;
		}
	}
}