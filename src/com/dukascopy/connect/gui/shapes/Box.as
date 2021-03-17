package com.dukascopy.connect.gui.shapes {
	
	import flash.display.Sprite;
	
	public class Box extends Sprite {
		
		protected var _color:uint;
		protected var _width:Number;
		protected var _height:Number;
		protected var _originalWidth:Number;
		protected var _originalHeight:Number;
		protected var _radius:Number;
		protected var _transparency:Number;
		
		public function Box(color:uint, width:Number, height:Number, transparency:Number = 1) {
			_transparency = transparency;
			_color = color;
			_width = _originalWidth = width;
			_height = _originalHeight = height;
			_radius = 0;
			redraw();
		}
		
		protected function redraw():void {
			this.graphics.clear();
			this.graphics.beginFill(_color, _transparency);
			if (_radius == 0)
				this.graphics.drawRect(0, 0, _width, _height)
			else
				this.graphics.drawRoundRect(0, 0, _width, _height, _radius);
			this.graphics.endFill();
		}
		
		override public function get width():Number { return _width; }
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
			_transparency = value;
			redraw();
		}
		
		public function dipose():void {
			if (this.parent != null)
				this.parent.removeChild(this);
			this.graphics.clear();
		}
	}
}