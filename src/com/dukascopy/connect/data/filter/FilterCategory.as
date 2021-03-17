package com.dukascopy.connect.data.filter {
	
	import com.dukascopy.connect.type.FinanceFilterCategoryType;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class FilterCategory {
		
		public var ready:Boolean = true;
		public var text:String;
		private var _type:FinanceFilterCategoryType;
		private var _filters:Vector.<FilterData>;
		
		public function FilterCategory(text:String, type:FinanceFilterCategoryType) {
			this.text = text;
			this._type = type;
		}
		
		public function get filters():Vector.<FilterData> {
			return _filters;
		}
		
		public function get type():FinanceFilterCategoryType {
			return _type;
		}
		
		public function add(filter:FilterData):void {
			if (_filters == null) {
				_filters = new Vector.<FilterData>();
			}
			_filters.push(filter);
		}
	}
}