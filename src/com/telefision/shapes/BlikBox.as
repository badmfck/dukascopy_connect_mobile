package com.telefision.shapes
{


	import flash.display.Sprite;

	
	public class BlikBox extends Sprite
	{
		
		// ----------------------------------------------------
		// PUBLIC VARIABLES
		// ----------------------------------------------------
		
		// ----------------------------------------------------
		// PRIVATE AND PROTECTED VARIABLES
		// ----------------------------------------------------
		protected var _color : uint;
		
		protected var _width : Number;
		
		protected var _height : Number;
		
		protected var _originalWidth : Number;
		
		protected var _originalHeight : Number;
		
		protected var _radius : Number;
		
		private var _transparency:Number;
		// ----------------------------------------------------
		// CONSTRUCTOR
		// ----------------------------------------------------
		/**
		 * @constructor
		 */
		public function BlikBox(color : uint, width : Number, height : Number, transparency:Number=1)
		{
			_transparency = transparency;
			_color = color;
			_width = _originalWidth = width;
			_height = _originalHeight = height;
			_radius = 0;
			
			redraw();
		}
		
		// ----------------------------------------------------
		// PRIVATE AND PROTECTED METHODS
		// ----------------------------------------------------
		protected function redraw() : void
		{
			this.graphics.clear();
			this.graphics.beginFill(_color, _transparency);
			if (_radius == 0 ) {
				this.graphics.moveTo(0, 0 );
				this.graphics.lineTo( _width,0);
				this.graphics.lineTo(_width, _height * .36);
				this.graphics.lineTo(0, _height);
				
			}else {
				this.graphics.drawRoundRect(0, 0, _width, _height, _radius);
			}
			this.graphics.endFill();
		}
		
		// ----------------------------------------------------
		// GETTERS AND SETTERS
		// ----------------------------------------------------
		/**
		 * Width
		 */
		override public function get width() : Number{	return _width;	}		
		override public function set width(value : Number) : void
		{
			if (_width == value) return;
			_width = value;
			redraw();
		}
			
	
		/**
		 * Height
		 */
		override public function get height() : Number{		return _height;	}
		override public function set height(value : Number) : void
		{
			if (_height == value) return;
			_height = value;
			redraw();
		}
			
		
		
		/**
		 * Scale X
		 * 
		 */
		override public function get scaleX() : Number{		return _width / _originalWidth;	}
		override public function set scaleX(value : Number) : void
		{
			_width = _originalWidth * value;			
			redraw();
		}
			
	
		
		/**
		 * Scale Y
		 */
		override public function get scaleY() : Number	{		return _height / _originalHeight;	}
		override public function set scaleY(value : Number) : void
		{
			_height = _originalHeight * value;
			redraw();
		}
			
		
		
		/**
		 * Color
		 */
		public function get color() : uint	{		return _color;	}
		public function set color(value : uint) : void
		{
			if (_color == value) return;
			_color = value;
			redraw();
		}
		
		
		
		/**
		 * Radius
		 */
		public function get radius() : Number	{		return _radius;	}
		public function set radius(value : Number) : void
		{
			if (_radius == value) return;
			_radius = value;
			redraw();
		}
		
				/**
		 * Transparency
		 */
		public function get transparency():Number {		return _transparency;	}		
		public function set transparency(value:Number):void 
		{
			if (_transparency == value) return;
			_transparency = value;
			redraw();
		}
		
			

	}
}
