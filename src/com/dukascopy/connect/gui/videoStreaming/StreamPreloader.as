package com.dukascopy.connect.gui.videoStreaming 
{
	import assets.CinemaIllustration;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class StreamPreloader extends Sprite
	{
		private var preloadArea:flash.display.Sprite;
		private var back:flash.display.Sprite;
		private var illustration:flash.display.Bitmap;
		
		public function StreamPreloader() 
		{
			createPreloadArea();
			createBack();
			createIllustration();
			
			start();
		}
		
		private function createIllustration():void 
		{
			illustration = new Bitmap();
			addChild(illustration);
			
			var source:Sprite = new CinemaIllustration();
			UI.scaleToFit(source, Config.FINGER_SIZE * 3.7, Config.FINGER_SIZE * 3.7);
			
			illustration.bitmapData = UI.getSnapshot(source, StageQuality.HIGH, "StreamPreloader.illustration");
			
			illustration.x = int( -illustration.width * .5);
			illustration.y = int( -illustration.height * .5);
		}
		
		private function createBack():void 
		{
			back = new Sprite();
			addChild(back);
			
			preloadArea.graphics.beginFill(0x4A5566);
			preloadArea.graphics.drawCircle(0, 0, Config.FINGER_SIZE * 1.76);
			preloadArea.graphics.endFill();
		}
		
		private function createPreloadArea():void 
		{
			preloadArea = new Sprite();
			addChild(preloadArea);
			
			preloadArea.graphics.beginFill(0x4A5566);
			preloadArea.graphics.drawCircle(0, 0, Config.FINGER_SIZE * 2.2);
			preloadArea.graphics.endFill();
		}
		
		private function start():void 
		{
			
		}
	}
}