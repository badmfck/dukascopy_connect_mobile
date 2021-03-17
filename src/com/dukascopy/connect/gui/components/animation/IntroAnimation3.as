package com.dukascopy.connect.gui.components.animation 
{
	import assets.Anim3Mask;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class IntroAnimation3 extends Sprite
	{
		private var back:Bitmap;
		private var back2:Bitmap;
		private var anim:Sprite;
		private var anim2:Sprite;
		private var _width:int;
		private var startPosition:Number;
		private var _height:int;
		
		public function IntroAnimation3(_width:int, _height:int) 
		{
			this._width = _width;
			this._height = _height;
			
			var illustration:Sprite = new IntroClip3();
		//	UI.scaleToFit(illustration, _width, _height * 2);
			
			UI.scaleToFit(illustration.getChildAt(0), _width, _height * 2);
			UI.scaleToFit(illustration.getChildAt(1), _width, _height * 2);
			UI.scaleToFit(illustration.getChildAt(2), _width, _height * 2);
			
			var bitmapData1:ImageBitmapData = UI.getSnapshot(illustration.getChildAt(1), StageQuality.HIGH, "intro_3_1");
			var result1:ImageBitmapData = new ImageBitmapData("intro_3", _width, int(_height * .5 + Config.FINGER_SIZE * .0));
			result1.copyPixels(bitmapData1, new Rectangle(0, int( -_height * .5 - Config.FINGER_SIZE * .0) + bitmapData1.height, result1.width, result1.height), new Point());
			
			var bitmapData2:ImageBitmapData = UI.getSnapshot(illustration.getChildAt(2), StageQuality.HIGH, "intro_3_1");
			var result2:ImageBitmapData = new ImageBitmapData("intro_4", _width, int(_height * .5 + Config.FINGER_SIZE * .0));
			result2.copyPixels(bitmapData2, new Rectangle(0, int( -_height * .5 - Config.FINGER_SIZE * .0) + bitmapData2.height, result2.width, result2.height), new Point());
			
			back = new Bitmap();
			addChild(back);
			
			back2 = new Bitmap();
			addChild(back2);
			
			anim = new Anim3Mask();
			UI.scaleToFit(anim, _width, _height * 2);
			addChild(anim);
			anim.y = _height * .5 - anim.height;
			startPosition = anim.y;
			
			anim2 = new Anim3Mask();
			UI.scaleToFit(anim2, _width, _height * 2);
			addChild(anim2);
			anim2.y = _height * .5 - anim2.height;
			
			back.bitmapData = result1;
			back2.bitmapData = result2;
			
			back.mask = anim;
			back2.mask = anim2;
		}
		
		public function dispose():void
		{
			if (back != null)
			{
				UI.destroy(back);
				back = null;
			}
			if (back2 != null)
			{
				UI.destroy(back2);
				back2 = null;
			}
			if (anim != null)
			{
				UI.destroy(anim);
				anim = null;
			}
			if (anim2 != null)
			{
				UI.destroy(anim2);
				anim2 = null;
			}
		}
		
		public function update(position:Number):void 
		{
			back2.x = -position * Config.FINGER_SIZE * 5 / _width;
			back.alpha = 1 - Math.abs(position) / _width;
			anim.y = startPosition - Math.abs(position) * _height * .5 / _width;
			anim2.y = anim.y;
		}
	}
}