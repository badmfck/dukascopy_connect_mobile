package com.dukascopy.connect.utils 
{
	import flash.geom.Point;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class GeometryUtils 
	{
		
		public function GeometryUtils() 
		{
			
		}
		
		public static function distance(p1:Point, p2:Point):Number
		{
			return Math.sqrt((p2.x - p1.x) * (p2.x - p1.x) + (p2.y - p1.y) * (p2.y - p1.y))
		}
	}
}