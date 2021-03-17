package com.telefision.shapes {
	
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class PatternShapeBox extends ShapeBox {
		
		protected var _bitmapData:BitmapData;
		protected var _patternScaleFactor:Number = -1;
		
		public function PatternShapeBox(bitmapData:BitmapData, width:Number, height:Number) {
			_bitmapData = bitmapData;
			super(0, width, height);
		}
		
		override protected function redraw():void {
			graphics.clear();
			if (_bitmapData == null)
				return;
			if (_patternScaleFactor != -1)
				graphics.beginBitmapFill(_bitmapData, new Matrix(_patternScaleFactor, 0, 0, _patternScaleFactor, 0, 0), true, true);
			else
				graphics.beginBitmapFill(_bitmapData);
			if (_radius == 0)
				graphics.drawRect(0, 0, _width, _height)
			else
				graphics.drawRoundRect(0, 0, _width, _height, _radius);
			graphics.endFill();
		}
		
		public function get bitmapData():BitmapData { return _bitmapData; }
		public function set bitmapData(value:BitmapData):void {
			if (_bitmapData == value)
				return;
			_bitmapData = value;
			redraw();
		}
		
		public function get patternScaleFactor():Number { return _patternScaleFactor; }
		public function set patternScaleFactor(value:Number):void {
			if (_patternScaleFactor == value)
				return;
			_patternScaleFactor = value;
			redraw();
		}
	}
}