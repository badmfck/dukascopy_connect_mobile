package com.dukascopy.connect.gui.components.animation 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class IntroAnimation2 extends Sprite
	{
		private var back:Bitmap;
		private var anim:Bitmap;
		private var _width:int;
		
		public function IntroAnimation2(_width:int, _height:int) 
		{
			this._width = _width;
			
			var illustration:Sprite = new IntroClip2();
		//	UI.scaleToFit(illustration, _width, _height);
			
			back = new Bitmap();
			addChild(back);
			
			anim = new Bitmap();
			addChild(anim);
			
			UI.scaleToFit(illustration.getChildAt(0), _width, _height);
			UI.scaleToFit(illustration.getChildAt(1), _width, _height);
			
			back.bitmapData = UI.getSnapshot(illustration.getChildAt(0), StageQuality.HIGH, "intro_1_1");
			anim.bitmapData = UI.getSnapshot(illustration.getChildAt(1), StageQuality.HIGH, "intro_1_2");
		}
		
		public function dispose():void
		{
			if (back != null)
			{
				UI.destroy(back);
				back = null;
			}
			if (anim != null)
			{
				UI.destroy(anim);
				anim = null;
			}
		}
		
		public function update(position:Number):void 
		{
			anim.x = position * Config.FINGER_SIZE * 4 / _width;
			back.x = -position * Config.FINGER_SIZE * 1 / _width;
		}
	}
}