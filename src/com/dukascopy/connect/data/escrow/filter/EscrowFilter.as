package com.dukascopy.connect.data.escrow.filter 
{
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class EscrowFilter 
	{
		public var field:String;
		public var value:String;
		
		public function EscrowFilter(field:String, value:String) 
		{
			this.field = field;
			this.value = value;
		}
	}
}