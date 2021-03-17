package com.dukascopy.connect.gui.graph.lineChart 
{
	import com.dukascopy.connect.data.coinMarketplace.stat.StatPointData;
	import flash.geom.Point;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class LinePoint extends Point
	{
		public var startIndex:int;
		public var endIndex:int;
		public var key:Number;
		public var value:Number;
		
		public function LinePoint() 
		{
			
		}
	}
}