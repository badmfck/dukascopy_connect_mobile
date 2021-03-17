package com.telefision.shapes {
	
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class ShapeBox extends Sprite {
		
		protected var _color:uint;
		protected var _width:int;
		protected var _height:int;
		protected var _originalWidth:int;
		protected var _originalHeight:int;
		protected var _radius:Number = 0;
		protected var _transparency:Number;
		
		public function ShapeBox(color:uint, width:int, height:int, transparency:Number = 1) {
			_color = color;
			_width = _originalWidth = width;
			_height = _originalHeight = height;
			_transparency = transparency;
			
			redraw();
		}
		
		protected function redraw():void {
			graphics.clear();
			graphics.beginFill(_color, _transparency);
			if (_radius == 0)
				graphics.drawRect(0, 0, _width, _height)
			else
				this.graphics.drawRoundRect(0, 0, _width, _height, _radius);
			graphics.endFill();
		}
		
		override public function get width():int { return _width; }
		override public function set width(value:Number):void {
			if (_width == value)
				return;
			_width = value;
			redraw();
		}
		
		override public function get height():Number { return _height; }
		override public function set height(value:Number):void {
			if (_height == value)
				return;
			_height = value;
			redraw();
		}
		
		override public function get scaleX():Number { return _width / _originalWidth; }
		override public function set scaleX(value:Number):void {
			var newWidth:int = _originalWidth * value;
			if (_width == newWidth)
				return;
			_width = newWidth;
			redraw();
		}
		
		override public function get scaleY():Number { return _height / _originalHeight; }
		override public function set scaleY(value:Number):void {
			var newHeight:int = _originalHeight * value;
			if (_height == newHeight)
				return;
			_height = newHeight;
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
	}
}