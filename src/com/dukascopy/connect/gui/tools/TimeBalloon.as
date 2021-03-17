package com.dukascopy.connect.gui.tools 
{
	import assets.BalloonArrowClip;
	import assets.TimeBalloonBack;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.assets.Assets;
	import com.dukascopy.connect.utils.DateUtils;
	import com.dukascopy.connect.utils.TextUtils;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class TimeBalloon extends Sprite
	{
		private var arrow:Bitmap;
		private var back:Bitmap;
		private var time:Bitmap;
		
		public function TimeBalloon() 
		{
			construct();
		}
		
		private function construct():void 
		{
			arrow = new Bitmap();
			back = new Bitmap();
			
			addChild(arrow);
			addChild(back);
			
			var clipBack:TimeBalloonBack = new TimeBalloonBack();
			var clipArrow:BalloonArrowClip = new BalloonArrowClip();
			
			clipBack.height = Config.FINGER_SIZE * .7;
			clipBack.scaleX = clipBack.scaleY;
			
			clipArrow.height = clipArrow.height * clipBack.scaleX;
			clipArrow.scaleX = clipArrow.scaleY;
			
			back.bitmapData = UI.getSnapshot(clipBack, StageQuality.HIGH, "TimeBalloon.back");
			arrow.bitmapData = UI.getSnapshot(clipArrow, StageQuality.HIGH, "TimeBalloon.back");
			
			arrow.x = int( -arrow.width * .5);
			arrow.y = int( -arrow.height);
			
			back.x = int(-back.width * .5);
			back.y = Math.ceil( -arrow.height - back.height);
			
			time = new Bitmap();
			addChild(time);
		}
		
		public function setTime(value:int):void
		{
			var timeString:String = Math.floor(value / 60).toString() + ":" + (value % 60).toString();
			
			if (time.bitmapData)
			{
				time.bitmapData.dispose();
				time.bitmapData = null;
			}
			
			time.bitmapData = TextUtils.createTextFieldData(timeString, back.width, 10, false, TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .3, false, 0x92A2AE, 0x3B4452, true);
			time.x = int(back.x + back.width * .5 - time.width * .5);
			time.y = int(back.y + back.height * .5 - time.height * .5);
		}
		
		public function show():void 
		{
			visible = true;
		}
		
		public function hide():void 
		{
			visible = false;
		}
	}
}