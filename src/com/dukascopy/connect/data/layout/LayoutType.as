package com.dukascopy.connect.data.layout 
{
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class LayoutType 
	{
		private static const HORIZONTAL:int = 0;
		private static const VERTICAL:int = 1;
		private var type:int;
		
		public static const horizontal:LayoutType = new LayoutType(HORIZONTAL);
		public static const vertical:LayoutType = new LayoutType(VERTICAL);
		
		public function LayoutType(dontUse:int) 
		{
			type = dontUse;
		}
	}
}