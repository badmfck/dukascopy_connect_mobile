package com.dukascopy.connect.utils 
{
	import com.greensock.TweenMax;
	import fl.motion.Color;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class Animator 
	{
		private var target:Sprite;
		private var color:Color;
		private var increaseTime:Number = 1;
		private var discreaseTime:Number = 0.7;
		private var animationData:Object;
		
		public function Animator(target:Sprite) 
		{
			this.target = target;
			animationData = new Object();
			animationData.value = 0;
			color = new Color();
			color.tintColor = 0xFFFFFF;
		}
		
		public function start():void
		{
			TweenMax.killTweensOf(animationData);
			increase();
		}
		
		private function increase():void 
		{
			TweenMax.to(animationData, increaseTime, { value:0.8, onUpdate:updateProperty, onComplete:descrease } );
		}
		
		private function updateProperty():void 
		{
			if (animationData != null && target != null)
			{
				color.tintMultiplier = animationData.value;
				target.transform.colorTransform = color;
			}
			else
			{
				TweenMax.killTweensOf(animationData);
				dispose();
			}
		}
		
		private function descrease():void 
		{
			TweenMax.to(animationData, discreaseTime, { value:0, onUpdate:updateProperty, onComplete:increase } );
		}
		
		public function dispose():void
		{
			TweenMax.killTweensOf(animationData);
			animationData = null;
			target = null;
		}
	}
}