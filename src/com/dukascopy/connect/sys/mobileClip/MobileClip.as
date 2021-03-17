package com.dukascopy.connect.sys.mobileClip {
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author Igor Bloom
	 */
	
	public class MobileClip {
		
		protected var _view:Sprite;
		protected var _isDisposed:Boolean;
		
		public function MobileClip() { }
		
		public function dispose():void{
			if (_view != null) {
				if (_view.parent != null)
					_view.parent.removeChild(_view);
				_view.graphics.clear();
			}
			_view = null;
			_isDisposed = true;
		}
		
		public function get view():DisplayObject { return _view; }
		public function get isDisposed():Boolean { return _isDisposed; }
	}
}