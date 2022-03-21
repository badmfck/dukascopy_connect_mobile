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
		public var color:Number;
		
		public function FilterData(text:String, type:FinanceFilterType, iconClass:Class = null, color:Number = NaN) {
			this.text = text;
			this.type = type;
			this.iconClass = iconClass;
			this.color = color;
		}
	}
}