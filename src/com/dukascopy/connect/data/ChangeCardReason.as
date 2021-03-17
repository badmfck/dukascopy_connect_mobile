package com.dukascopy.connect.data 
{
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class ChangeCardReason 
	{
		public var label:String;
		public var value:String;
		
		public function ChangeCardReason(label:String, value:String) 
		{
			this.value = value;
			this.label = label;
		}
	}
}