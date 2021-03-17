package com.dukascopy.connect.gui.shapes {
	
	import flash.display.Graphics;
	import flash.display.Shape;

	/**
	 * ...
	 * @author Aleksej Skurjat. Telefision TEAM Riga.
	 */
	
	public class BoxShape extends Shape {
		
		private var _color:uint;
		private var _width:Number;
		private var _height:Number;
		private var _x:Number;
		private var _y:Number;
		private var _originalWidth:Number;
		private var _originalHeight:Number;
		private var _radius:Number;
		private var _transparency:Number;
		private var _gfx:Graphics;
		
		public function BoxShape(gfx:Graphics, color:uint, width:Number, height:Number, transparency:Number = 1) {
			_transparency = transparency;
			_color = color;
			_width = _originalWidth = width;
			_height = _originalHeight = height;
			_radius = 0;
			_x = 0;
			_y = 0;
			_gfx = gfx;
			redraw();
		}
		
		protected function redraw():void {
			_gfx.clear();
			_gfx.beginFill(_color, _transparency);
			if (_radius == 0)
				_gfx.drawRect(_x, _y, _width, _height)
			else
				_gfx.drawRoundRect(_x, _y, _width, _height, _radius);
			_gfx.endFill();
		}
		
		override public function get width():Number { return _width; }
		override public function set width(value:Number):void {
			if (value == _width)
				return;
			_width = value;
			redraw();
		}
		
		override public function get height():Number { return _height; }
		override public function set height(value:Number):void {
			if (value == _height)
				return;
			_height = value;
			redraw();
		}
		
		override public function get x():Number { return _x; }
		override public function set x(value:Number):void {
			if (value == _x)
				return;
			_x = value;
			redraw();
		}
		
		override public function get y():Number { return _y; }
		override public function set y(value:Number):void {
			if (value == _y)
				return;
			_y = value;
			redraw();
		}
		
		override public function get scaleX():Number { return _width / _originalWidth; }
		override public function set scaleX(value:Number):void {
			_width = _originalWidth * value;
			redraw();
		}
		
		override public function get scaleY():Number { return _height / _originalHeight; }
		override public function set scaleY(value:Number):void {
			_height = _originalHeight * value;
			redraw();
		}
		
		public function get color():uint { return _color; }
		public function set color(value:uint):void {
			if (_color == value)
				return;
			_color = value;
			redraw();
		}
		
		public function get radius():Number { return _radius; }
		public function set radius(value:Number):void {
			if (_radius == value)
				return;
			_radius = value;
			redraw();
		}
		
		public function get transparency():Number { return _transparency; }
		public function set transparency(value:Number):void {
			if (_transparency == value)
				return;
			_transparency = value;
			redraw();
		}
		
		public function render(_w:int, _h:int, _c:uint, _t:Number = -1):void {
			_width = _w;
			_height = _h;
			_color = _c;
			if (_t != -1)
				_transparency = _t;
			redraw();
		}
	}
}