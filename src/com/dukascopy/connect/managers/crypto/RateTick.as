package com.dukascopy.connect.managers.crypto 
{
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class RateTick 
	{
		public var ts:Number;
		public var val:Number;
		
		public function RateTick(raw:Object) 
		{
			if (raw != null)
			{
				ts = raw.ts;
				val = raw.val;
			}
		}
	}
}