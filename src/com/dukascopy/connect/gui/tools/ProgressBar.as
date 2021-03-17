package com.dukascopy.connect.gui.tools 
{
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class ProgressBar extends Sprite
	{
		private var content:Sprite;
		private var itemHeight:int;
		private var colorBack:Number;
		private var colorTop:Number;
		private var itemWidth:int;
		private var currentProgress:int = 0;
		
		public function ProgressBar(colorBack:Number, colorTop:Number)
		{
			this.colorBack = colorBack;
			this.colorTop = colorTop;
		}
		
		public function setSize(itemWidth:int, itemHeight:int):void
		{
			var oldWidth:int = this.itemWidth;
			var oldHeight:int = this.itemHeight;
			
			this.itemWidth = itemWidth;
			this.itemHeight = itemHeight;
			
			if (oldWidth != this.itemWidth || oldHeight != this.itemHeight)
			{
				setProgress(currentProgress);
			}
		}
		
		public function dispose():void
		{
			currentProgress = 0;
			graphics.clear();
		}
		
		public function setProgress(value:int):void
		{
			currentProgress = value;
			
			graphics.clear();
			graphics.beginFill(colorBack);
			graphics.drawRect(0, 0, itemWidth, itemHeight);
			graphics.beginFill(colorTop);
			graphics.drawRect(0, 0, itemWidth * currentProgress / 100, itemHeight);
			graphics.endFill();
		}
	}
}