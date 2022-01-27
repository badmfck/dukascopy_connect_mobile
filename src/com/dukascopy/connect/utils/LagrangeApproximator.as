package com.dukascopy.connect.utils 
{
	import flash.geom.Point;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class LagrangeApproximator 
	{
		private const points:Vector.<Point> = new Vector.<Point>();
        private const pointByArg:Dictionary = new Dictionary();

        private var isSorted:Boolean;

        public function LagrangeApproximator()
        {
			
        }
		
        public function addValue(argument:Number, value:Number):void
        {
            var point:Point;
            if (pointByArg[argument] != null) {
                trace("LagrangeApproximator.addValue("+arguments+"): ERROR duplicate function argument!");
                point = pointByArg[argument];
            } else {
                point = new Point();
                points.push(point);
                pointByArg[argument] = point;
            }
            point.x = argument;
            point.y = value;
            isSorted = false;
        }
		
        public function getApproximationValue(argument:Number):Number
        {
            if (!isSorted) {
                isSorted = true;
                points.sort(sortByArgument);
            }
            var listLength:uint = points.length;
            var point1:Point, point2:Point;
            var result:Number = 0;
            var coefficient:Number;
            for(var i:uint =0; i<listLength; i++) {
                coefficient = 1;
                point1 = points[i];
                for(var j:uint = 0; j<listLength; j++) {
                    if (i != j) {
                        point2 = points[j];
                        coefficient *= (argument-point2.x) / (point1.x-point2.x);
                    }
                }        
                result += point1.y * coefficient;
            }
            return result;
        }
		
        private function sortByArgument(a:Point, b:Point):int
        {
            if (a.x < b.x) {
                return -1;
            }
            if (a.x > b.x) {
                return 1;
            }            
            return 0;
        }
		
        public function get length():int
        {
            return points.length;            
        }
		
        public function clear():void
        {
            points.length = 0;
            var key:*;
            for (key in pointByArg) {
                delete pointByArg[key];
            }
        }
	}
}