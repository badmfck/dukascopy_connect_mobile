package com.dukascopy.connect.data 
{
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class Separator 
	{
		public static const HORIZONTAL:int = 0;
		public static const VERTICAL:int = 1;
		
		public var type:int;
		
		public function Separator(type:int) 
		{
			this.type = type;
		}
	}
}