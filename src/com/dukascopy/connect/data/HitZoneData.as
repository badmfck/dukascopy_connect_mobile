package com.dukascopy.connect.data 
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class HitZoneData 
	{
		public var type:String;
		public var x:int;
		public var y:int;
		public var width:int;
		public var height:int;
		public var visibilityRect:Rectangle;
		public var touchPoint:Point;
		public var radius:int;
		public var disabled:Boolean;
		public var color:uint = 0;
		public var alpha:Number = 0.1;
		
		public function HitZoneData() 
		{
			
		}
		
	}

}