package com.dukascopy.connect.gui.tools 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.utils.BaseGraphicsUtils;
	import flash.display.Sprite;
	import flash.geom.Point;
	/**
	 * ...
	 * @author ...
	 */
	public class CircleProgress extends Sprite
	{
		
		public function CircleProgress() 
		{
			graphics.lineStyle(int(Config.FINGER_SIZE * .03), 0xFFFFFF);
		}
		
		public function setValue(value:int):void
		{
			graphics.clear();
			BaseGraphicsUtils.drawCircleSegment(graphics, new Point(0, 0), 0, value * Math.PI*2 / 100, Config.FINGER_SIZE * .5, 1, 1, false);
		}
	}
}