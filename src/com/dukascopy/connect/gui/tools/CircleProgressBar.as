package com.dukascopy.connect.gui.tools 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class CircleProgressBar extends Sprite
	{
		public function CircleProgressBar()
		{
			
		}
		
		public function drawWedge(x:Number, y:Number, radius:Number, arc:Number, startAngle:Number=0, yRadius:Number=0):void
		{
			graphics.lineStyle(1, 0x0000ff, 0.25);
			graphics.beginFill(0x123456, 0.25);
			
			if (yRadius == 0)
				yRadius = radius;
			
			graphics.moveTo(x, y);
			
			var segAngle:Number, theta:Number, angle:Number, angleMid:Number, segs:Number, ax:Number, ay:Number, bx:Number, by:Number, cx:Number, cy:Number;
			
			if (Math.abs(arc) > 360)
				arc = 360;
			
			segs = Math.ceil(Math.abs(arc) / 45);
			segAngle = arc / segs;
			theta = -(segAngle / 180) * Math.PI;
			angle = -(startAngle / 180) * Math.PI;
			if (segs > 0)
			{
				ax = x + Math.cos(startAngle / 180 * Math.PI) * radius;
				ay = y + Math.sin(-startAngle / 180 * Math.PI) * yRadius;
				graphics.lineTo(ax, ay);
				for (var i:int = 0; i < segs; ++i)
				{
					angle += theta;
					angleMid = angle - (theta / 2);
					bx = x + Math.cos(angle) * radius;
					by = y + Math.sin(angle) * yRadius;
					cx = x + Math.cos(angleMid) * (radius / Math.cos(theta / 2));
					cy = y + Math.sin(angleMid) * (yRadius / Math.cos(theta / 2));
					graphics.curveTo(cx, cy, bx, by);
				}
				graphics.lineTo(x, y);
			}
			graphics.endFill();
		}
	}

}