package com.dukascopy.connect.utils {
	
	import flash.display.Graphics;
	import flash.geom.Point;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class BaseGraphicsUtils {
		
		public function BaseGraphicsUtils() { }
		 
		public static function drawDash(target:Graphics, x1:Number, y1:Number, x2:Number, y2:Number, dashLength:Number = 5, spaceLength:Number = 5):void {
			var x:Number = x2 - x1;
			var y:Number = y2 - y1;
			var hyp:Number = Math.sqrt((x) * (x) + (y) * (y));
			var units:Number = hyp / (dashLength + spaceLength);
			var dashSpaceRatio:Number = dashLength / (dashLength + spaceLength);
			var dashX:Number = (x / units) * dashSpaceRatio;
			var spaceX:Number = (x / units) - dashX;
			var dashY:Number = (y / units) * dashSpaceRatio;
			var spaceY:Number = (y / units) - dashY;
			target.moveTo(x1, y1);
			while (hyp > 0) {
				x1 += dashX;
				y1 += dashY;
				hyp -= dashLength;
				if (hyp < 0) {
					x1 = x2;
					y1 = y2;
				}
				target.lineTo(x1, y1);
				x1 += spaceX;
				y1 += spaceY;
				target.moveTo(x1, y1);
				hyp -= spaceLength;
			}
			target.moveTo(x2, y2);
		}
		
		public static function curvedBox(target:Object, x:Number, y:Number, w:Number,h:Number,radius:Number):void
		{
			var circ:Number = 0.707107;
			var off:Number = 0.6;
			target.moveTo(x+0,y+radius);
			target.lineTo(x+0,y+h-radius);
			target.curveTo(x+0,y+(h-radius)+radius*(1-off),x+0+(1-circ)*radius,y+h-(1-circ)*radius);
			target.curveTo(x+(0+radius)-radius*(1-off),y+h,x+radius,y+h);
			target.lineTo(x+w-radius,y+h);
			target.curveTo(x+(w-radius)+radius*(1-off),y+h,x+w-(1-circ)*radius,y+h-(1-circ)*radius);
			target.curveTo(x+w,y+(h-radius)+radius*(1-off),x+w,y+h-radius);
			target.lineTo(x+w,y+0+radius);
			target.curveTo(x+w, y+radius-radius*(1-off),x+w-(1-circ)*radius,y+0+(1-circ)*radius);
			target.curveTo(x+(w-radius)+radius*(1-off),y+0,x+w-radius,y+0);
			target.lineTo(x+radius,y+0);
			target.curveTo(x+radius-radius*(1-off),y+0,x+(1-circ)*radius,y+(1-circ)*radius);
			target.curveTo(x+0, y+radius-radius*(1-off),x+0,y+radius);
		}
		
		public static function drawCircleSegment(target:Graphics, center:Point, start:Number, end:Number, r:Number, hRatio:Number = 1, vRatio:Number = 1, newDrawing:Boolean = true):void {
			var x:Number = center.x;
			var y:Number = center.y;
			if (newDrawing == true)
				target.moveTo(x + Math.cos(start) * r * hRatio, y + Math.sin(start) * r * vRatio);
			var segments:uint = 8;
			var theta:Number = (end - start) / segments; 
			var angle:Number = start;
			var ctrlRadius:Number = r / Math.cos(theta / 2);
			var angleMid:Number;
			var cx:Number;
			var cy:Number;
			var px:Number;
			var py:Number;
			for (var i:int = 0; i<segments; i++) {
				angle += theta;
				angleMid = angle - (theta / 2);
				cx = x + Math.cos(angleMid) * (ctrlRadius * hRatio);
				cy = y + Math.sin(angleMid) * (ctrlRadius * vRatio);
				px = x + Math.cos(angle) * r * hRatio;
				py = y + Math.sin(angle) * r * vRatio;
				target.curveTo(cx, cy, px, py);
			}
		}
	}
}