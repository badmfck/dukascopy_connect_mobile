package com.dukascopy.connect.gui.graph.lineChart 
{
	import com.dukascopy.connect.data.coinMarketplace.stat.StatPointData;
	import flash.display.Bitmap;
	import flash.display.Shape;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class LineData 
	{
		public var index:Number;
		public var value:StatPointData;
		public var clip:Shape;
		public var title:Bitmap;
		
		public function LineData(index:Number) 
		{
			this.index = index;
		}
	}
}