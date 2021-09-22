package com.dukascopy.connect.data.escrow.filter 
{
	import com.dukascopy.connect.data.IFilterData;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class EscrowFilter implements IFilterData
	{
		public var field:String;
		public var value:String;
		
		public function EscrowFilter(field:String, value:String) 
		{
			this.field = field;
			this.value = value;
		}
		
		
		/* INTERFACE com.dukascopy.connect.data.IFilterData */
		
		public function getLabel():String 
		{
			return value;
		}
	}
}