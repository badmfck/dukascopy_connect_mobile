package com.dukascopy.connect.data 
{
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class SelectorItemData 
	{
		public var data:Object;
		public var label:String;
		public var selected:Boolean = false;
		
		public function SelectorItemData(label:String, data:Object) {
			this.label = label;
			this.data = data;
		}
	}
}