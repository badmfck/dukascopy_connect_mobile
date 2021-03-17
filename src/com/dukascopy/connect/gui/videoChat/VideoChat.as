package com.dukascopy.connect.gui.videoChat {
	import com.dukascopy.connect.sys.mobileClip.MobileClip;
	import flash.display.Sprite;
	/**
	 * @author ...
	 */
	public class VideoChat extends MobileClip{
		private var _height:int = 240;
		private var _width:int = 320;
		public function VideoChat() {
			createView();
		}
		
		private function createView():void {
			_view = new Sprite();
			
			updateView();
		}
		
		private function updateView():void {
			_view.graphics.clear();
			_view.graphics.beginFill(0);
			_view.graphics.drawRect(0, 0, _width, _height);
		}
		
		public function setWidth(w:int):void {
			_width = w;
			updateView();
		}
		
		public function get height():int {
			return _height;
		}
		
		
	}

}