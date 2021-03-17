package com.dukascopy.connect.data.coinMarketplace.stat 
{
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class StatPointData 
	{
		public var index:int;
		public var key:Number;
		public var value:Number;
		
		public function StatPointData(index:int = -1, key:Number = NaN, value:Number = NaN) 
		{
			this.index = index;
			this.key = key;
			this.value = value;
		}
	}
}