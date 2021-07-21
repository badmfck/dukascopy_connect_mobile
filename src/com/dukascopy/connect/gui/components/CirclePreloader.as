package com.dukascopy.connect.gui.components 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.utils.BaseGraphicsUtils;
	import com.greensock.TweenMax;
	import com.greensock.easing.Power2;
	import com.greensock.easing.Power3;
	import flash.display.CapsStyle;
	import flash.display.LineScaleMode;
	import flash.display.Sprite;
	import flash.geom.Point;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class CirclePreloader extends Sprite
	{
		private var item_1:Sprite;
		private var animationData:Object;
		private var increse:Number = 1.3;
		private var stayIncreased:Number = .1;
		private var discrease:Number = 1.3;
		private var stayDiscreased:Number = 0.1;
		private var radius:Number;
		private var thickness:Number;
		private var color:Number;
		
		public function CirclePreloader(radius:Number = NaN, thickness:Number = NaN, color:Number = NaN) 
		{
			cacheAsBitmap = true;
			this.radius = radius;
			this.thickness = thickness;
			this.color = color;
			
			if (isNaN(this.radius))
			{
				this.radius = Config.FINGER_SIZE * .35;
			}
			
			if (isNaN(this.thickness))
			{
				this.thickness = int(Config.FINGER_SIZE * .08);
			}
			
			if (isNaN(this.color))
			{
				this.color = 0x6AAAF1;
			}
			
			item_1 = new Sprite();
			addChild(item_1);
			
			animationData = new Object();
			
			animationData.angle = 0;
			animationData.value = 20;
			
			TweenMax.to(animationData, increse, {value:290, ease:Power2.easeOut, onComplete:onIncreaseComplete, onUpdate:onUpdate});
		}
		
		public function dispose():void
		{
			TweenMax.killTweensOf(animationData);
			animationData = null;
			item_1.graphics.clear();
		}
		
		private function onIncreaseComplete():void 
		{
			onStayIncreaseComplete();
		//	TweenMax.to(animationData, stayIncreased, {value:295, onComplete:onStayIncreaseComplete, onUpdate:onUpdate});
		}
		
		private function onStayIncreaseComplete():void 
		{
			TweenMax.to(animationData, discrease, {value:30, ease:Power2.easeOut, onComplete:onDiscreaseComplete, onUpdate:onUpdateDiscrease});
		}
		
		private function onUpdateDiscrease():void
		{
			if (animationData == null)
			{
				return;
			}
			
			animationData.angle += 4;
			
			animationData.angle += animationData.value / 25;
			item_1.graphics.clear();
			item_1.graphics.lineStyle(thickness, color, 1, false, LineScaleMode.NORMAL, CapsStyle.SQUARE);
			BaseGraphicsUtils.drawCircleSegment(item_1.graphics, new Point(0, 0), animationData.angle * Math.PI / 180, (animationData.angle + animationData.value) * Math.PI / 180, radius, 1, 1);
		}
		
		private function onDiscreaseComplete():void 
		{
			onStayDiscreaseComplete();
		//	TweenMax.to(animationData, stayDiscreased, {value:35, onComplete:onStayDiscreaseComplete, onUpdate:onUpdate});
		}
		
		private function onStayDiscreaseComplete():void 
		{
			TweenMax.to(animationData, increse, {value:290, ease:Power3.easeOut, onComplete:onIncreaseComplete, onUpdate:onUpdate});
		}
		
		private function onUpdate():void
		{
			if (animationData == null)
			{
				return;
			}
			animationData.angle += 4;
			item_1.graphics.clear();
			item_1.graphics.lineStyle(thickness, color, 1, false, LineScaleMode.NORMAL, CapsStyle.SQUARE);
			BaseGraphicsUtils.drawCircleSegment(item_1.graphics, new Point(0, 0), animationData.angle * Math.PI / 180, (animationData.angle + animationData.value) * Math.PI / 180, radius, 1, 1);
		}
	}
}