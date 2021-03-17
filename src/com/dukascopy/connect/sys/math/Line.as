package com.dukascopy.connect.sys.math
{
	import com.dukascopy.connect.gui.graph.lineChart.LinePoint;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class Line
	{
		public var start:LinePoint;
		public var end:LinePoint;
		
		private var dx:Number;
		private var dy:Number;
		private var sxey:Number;
		private var exsy:Number;
		private var length:Number;
		
		public function Line(start:LinePoint, end:LinePoint)
		{
			this.start = start;
			this.end = end;
			dx = start.data.key - end.data.key;
			dy = start.data.value - end.data.value;
			sxey = start.data.key * end.data.value;
			exsy = end.data.key * start.data.value;
			length = Math.sqrt(dx * dx + dy * dy);
		}
		
		public function distance(p:LinePoint):Number
		{
			return Math.abs(dy * p.data.key - dx * p.data.value + sxey - exsy) / length;
		}
	}
}