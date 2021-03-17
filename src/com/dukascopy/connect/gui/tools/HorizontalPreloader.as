package com.dukascopy.connect.gui.tools 
{
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.greensock.TweenMax;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev
	 */
	public class HorizontalPreloader extends Sprite
	{
		private var itemWidth:int;
		private var itemHeight:int;
		private var loader:Sprite;
		private var stopped:Boolean;
		private var color:Number = 0xA8A8A8;
		private var started:Boolean;
		
		public function HorizontalPreloader(color:Number = NaN) 
		{
			if (!isNaN(color))
			{
				this.color = color;
			}
			
			loader = new Sprite();
			addChild(loader);
		}
		
		public function setSize(itemWidth:int, itemHeight:int):void 
		{
			this.itemWidth = itemWidth;
			this.itemHeight = itemHeight;
		}
		
		public function start():void {
			if (started)
			{
				return;
			}
			stopped = false;
			started = true;
			loader.scaleX = 1;
			loader.scaleY = 1;
			
			TweenMax.killTweensOf(loader);
			loader.alpha = 1;
			
			loader.graphics.clear();
			loader.graphics.beginFill(color);
			loader.graphics.drawRect(0, 0, 1, itemHeight);
			loader.graphics.endFill();
			tickPreloaderShow(0);
		}
		
		private function tickPreloaderShow(delay:Number = 0.5):void {
			if (loader == null)
			{
				return;
			}
			loader.x = 0;
			if (stopped)
			{
				return;
			}
			
			TweenMax.to(loader, 0.8, {width:itemWidth, onComplete:tickPreloaderHide, delay:delay});
		}
		
		private function tickPreloaderHide():void {
			if (loader == null)
			{
				return;
			}
			TweenMax.to(loader, 0.3, {width:0, onComplete:tickPreloaderShow, delay:0.5, onUpdate:repositon});
		}
		
		private function repositon():void {
			if (loader != null)
			{
				loader.x = itemWidth - loader.width;
			}
		}
		
		public function stop(immediately:Boolean = true):void
		{
			started = false;
			stopped = true;
		//	TweenMax.killTweensOf(loader);
			if (immediately == true)
			{
				TweenMax.to(loader, 0.1, {alpha:0});
			}
		}
		
		public function dispose():void
		{
			started = false;
			stop();
			TweenMax.killTweensOf(loader)
			if (loader != null)
			{
				UI.destroy(loader);
				loader = null;
			}
		}
	}
}