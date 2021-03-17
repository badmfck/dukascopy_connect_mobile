package com.dukascopy.connect.vo {
	
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * @author David Gnatkivskij. Telefision TEAM Kiev.
	 */
	
	public class AnimatedZoneVO {
		
		private var _name:String;
		private var _rect:Rectangle;
		private var _isAnimateImmeliately:Boolean;
		
		public function get name():String { return _name; }
		public function get rect():Rectangle { return _rect; }
		public function get isAnimateImmeliately():Boolean { return _isAnimateImmeliately; }
		
		public function AnimatedZoneVO(name:String, rect:Rectangle, isAnimateImmediately:Boolean) {
			_name = name;
			_rect = rect;
			_isAnimateImmeliately = isAnimateImmediately;
		}
	}
}