package com.dukascopy.connect.screens.topbar {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.sys.mobileClip.MobileClip;
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author IgorBloom
	 */
	
	public class Topbar extends MobileClip {
		
		private var _width:int = 320;
		private var _height:int = Config.FINGER_SIZE;
		
		public function Topbar(){
			createView();
		}
		
		private function createView():void {
			_view = new Sprite();
			drawView();
		}
		
		private function drawView():void{
			_view.graphics.clear();
			_view.graphics.beginFill(0xFF0000, 1);
			_view.graphics.drawRect(0, 0, _width, _height);
		}
		
		public function set width(value:int):void {
			if (_width == value)
				return;
			_width = value;
			drawView();
		}
		
		public function get width():int{
			return _width;
		}
		
		public function get height():int{
			return _height;
		}
	}
}