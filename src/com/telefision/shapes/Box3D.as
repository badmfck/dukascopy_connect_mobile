package com.telefision.shapes
{

	import flash.display.Sprite;

	
	public class Box3D extends Sprite
	{
		
		// ----------------------------------------------------
		// PUBLIC VARIABLES
		// ----------------------------------------------------
		
		// ----------------------------------------------------
		// PRIVATE AND PROTECTED VARIABLES
		// ----------------------------------------------------
		protected var _color : uint;		
		
		protected var _sideColor : uint;
		
		protected var _width : Number;
		
		protected var _height : Number;
		
		protected var _sideHeight : uint;
		
		protected var _originalWidth : Number;
		
		protected var _originalHeight : Number;
		
		protected var _radius : Number;
		
		protected  var _transparency:Number;
		
		private var _allowRedraw:Boolean = false;
		// ----------------------------------------------------
		// CONSTRUCTOR
		// ----------------------------------------------------
		/**
		 * @constructor
		 */
		public function Box3D(color : uint, sideColor:uint,  width : Number, height : Number, sideHeight:int=4,transparency:Number=1)
		{
			_transparency = transparency;
			_color = color;
			_sideColor = sideColor;
			_sideHeight = sideHeight;
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
			if (!_allowRedraw) return;
			this.graphics.clear();
			this.graphics.beginFill(_sideColor, _transparency);
			_radius == 0 ? this.graphics.drawRect(0, 0, _width, _height) : this.graphics.drawRoundRect(0, 0, _width, _height, _radius);
			
			this.graphics.beginFill(_color, _transparency);
			_radius == 0 ? this.graphics.drawRect(0, 0, _width, _height-_sideHeight) : this.graphics.drawRoundRect(0, 0, _width, _height-_sideHeight, _radius);
		
			this.graphics.endFill();
		}
		
		// ----------------------------------------------------
		// GETTERS AND SETTERS
		// ----------------------------------------------------
		/**
		 * Width
		 */
		override public function set width(value : Number) : void
		{
			if (_width == value) return;
			_width = value;
			//
			redraw();
		}
			
		override public function get width() : Number
		{
			return _width;
		}
		
		/**
		 * Height
		 */
		override public function set height(value : Number) : void
		{
			if (_height == value) return;
			_height = value;
			//
			redraw();
		}
			
		override public function get height() : Number
		{
			return _height;
		}
		
		/**
		 * Scale X
		 */
		override public function set scaleX(value : Number) : void
		{
			_width = _originalWidth * value;
			//
			redraw();
		}
			
		override public function get scaleX() : Number
		{
			return _width / _originalWidth;
		}
		
		/**
		 * Scale Y
		 */
		override public function set scaleY(value : Number) : void
		{
			_height = _originalHeight * value;
			//
			redraw();
		}
			
		override public function get scaleY() : Number
		{
			return _height / _originalHeight;
		}
		
		/**
		 * Color
		 */
		public function set color(value : uint) : void
		{
			if (_color == value) return;
			_color = value;
			//
			redraw();
		}
		
		public function get color() : uint
		{
			return _color;
		}
		
		/**
		 * Side Color
		 */
		public function set sideColor(value : uint) : void
		{
			if (_sideColor == value) return;
			_sideColor = value;
			//
			redraw();
		}
		
		public function get sideColor() : uint
		{
			return _sideColor;
		}
		
		/**
		 * Radius
		 */
		public function set radius(value : Number) : void
		{
			if (_radius == value) return;
			_radius = value;
			//
			redraw();
		}
		
		public function get radius() : Number
		{
			return _radius;
		}
		
		public function get transparency():Number 
		{
			return _transparency;
		}
		
		public function set transparency(value:Number):void 
		{
			_transparency = value;
				redraw();
		}
		
		public function get allowRedraw():Boolean 	{		return _allowRedraw;	}
		
		public function set allowRedraw(value:Boolean):void 
		{
			_allowRedraw = value;			
			if (_allowRedraw) {
				redraw();
			}
		}
		
		public function get sideHeight():uint 		{		return _sideHeight;	}
		
		public function set sideHeight(value:uint):void 
		{
			if (_sideHeight == value) return;
			_sideHeight = value;
			redraw();
		}

	}
}
