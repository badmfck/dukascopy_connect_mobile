package com.dukascopy.connect.sys.math
{
	import com.dukascopy.connect.gui.graph.lineChart.LinePoint;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class RamerDouglasPeuckerFilter
	{
		public static function reduce(points:Vector.<LinePoint>, epsilon:Number):Vector.<LinePoint>
		{
			
			var furthestPointDistance:Number = 0.0;
			var furthestPointIndex:Number = 0;
			
			var line:Line = new Line(points[0], points[points.length - 1]);
			
			var l:int = points.length - 1;
			var distance:Number;
			
			for (var i:int = 1; i < l; i++)
			{
				distance = line.distance(points[i]);
				if (distance > furthestPointDistance)
				{
					furthestPointDistance = distance;
					furthestPointIndex = i;
				}
			}
			if (furthestPointDistance > epsilon)
			{
				var reduced1:Vector.<LinePoint> = reduce(points.slice(0, furthestPointIndex + 1), epsilon);
				var reduced2:Vector.<LinePoint> = reduce(points.slice(furthestPointIndex, points.length), epsilon);
				
				var result:Vector.<LinePoint> = new Vector.<LinePoint>();
				result = result.concat(reduced1);
				result = result.concat(reduced2.slice(1, reduced2.length));
				return result;
			}
			else
			{
				var res:Vector.<LinePoint> = new Vector.<LinePoint>();
				res.push(line.start, line.end);
				return res;
			}
		}
		
		static public function reduceByNum(points:Vector.<LinePoint>, startEpsilon:Number, maxPoints:Number):Vector.<LinePoint> 
		{
			var result:Vector.<LinePoint> = reduce(points, startEpsilon);
			
			if (result.length > maxPoints)
			{
			//	trace("EPSILON", startEpsilon);
				return reduceByNum(result, startEpsilon * 1.2, maxPoints);
			}
		//	trace("EPSILON", startEpsilon);
			return result;
		}
	}
}