package com.dukascopy.connect.gui.shapes 
{
	/**
	 * @author 
	 */
	public class BorderBox extends Box
	{

		// ----------------------------------------------------
		// PUBLIC VARIABLES
		// ----------------------------------------------------
		// ----------------------------------------------------
		// PRIVATE AND PROTECTED VARIABLES
		// ----------------------------------------------------
		protected var _thickness : Number;
		
		protected var _innerStroke : Boolean;
		
		private var _borderColor:uint;
		
		private var _borderTransparency:Number = 1;

		// ----------------------------------------------------
		// CONSTRUCTOR
		// ----------------------------------------------------
		/**
		 * @constructor
		 */
		public function BorderBox(color : uint, bordercolor:uint, width : Number, height : Number, thickness : Number, radius:Number = 0, innerStroke : Boolean = true)
		{
			_thickness = thickness;

			_innerStroke = innerStroke;
			_borderColor = bordercolor;
			super(color, width, height);
			super.radius = radius;
			this.mouseChildren = false;
		}

		// ----------------------------------------------------
		// PRIVATE AND PROTECTED METHODS
		// ----------------------------------------------------
		override protected function redraw() : void
		{
			this.graphics.clear();
			this.graphics.beginFill(_borderColor,_borderTransparency);
			
			
			if(_innerStroke)
			{
				_radius == 0 ? this.graphics.drawRect(0, 0, _width, _height) : this.graphics.drawRoundRect(0, 0, _width, _height, _radius);
				_radius == 0 ? this.graphics.drawRect(_thickness, _thickness, _width - _thickness * 2, _height - _thickness * 2) : this.graphics.drawRoundRect(_thickness, _thickness, _width - _thickness * 2, _height - _thickness * 2, _radius-_thickness);
			}
			else
			{
				_radius == 0 ? this.graphics.drawRect(-_thickness, -_thickness, _width + _thickness * 2, _height + _thickness * 2) : this.graphics.drawRoundRect(-_thickness, -_thickness, _width + _thickness * 2, _height + _thickness * 2, _radius);
				_radius == 0 ? this.graphics.drawRect(0, 0, _width, _height) : this.graphics.drawRoundRect(0, 0, _width, _height, _radius);
			}
			
			this.graphics.beginFill(_color,_transparency);
			if(_innerStroke)
			{
				_radius == 0 ? this.graphics.drawRect(_thickness, _thickness, _width - _thickness * 2, _height - _thickness * 2) : this.graphics.drawRoundRect(_thickness, _thickness, _width - _thickness * 2, _height - _thickness * 2, _radius-_thickness);
			}
			else
			{
				_radius == 0 ? this.graphics.drawRect(0, 0, _width, _height) : this.graphics.drawRoundRect(0, 0, _width, _height, _radius);
			}
			
			
			this.graphics.endFill();
		}

		// ----------------------------------------------------
		// EVENT HANDLERS
		// ----------------------------------------------------
		// ----------------------------------------------------
		// PUBLIC METHODS
		// ----------------------------------------------------
		// ----------------------------------------------------
		// GETTERS AND SETTERS
		// ----------------------------------------------------
		public function get thickness() : Number	{		return _thickness;	}
		public function set thickness(value : Number) : void
		{
			_thickness = value;
			redraw();
		}
		
		public function get borderColor():uint 	{	return _borderColor;	}		
		public function set borderColor(value:uint):void 
		{
			_borderColor = value;
			redraw();
		}
		
		
		
		public function get borderTransparency():Number {		return _borderTransparency;	}		
		public function set borderTransparency(value:Number):void 
		{
			_borderTransparency = value;
			redraw();
		}

		
		public function setSize(w:int, h:int ):void
		{
			_width = w;
			_height = h;
			redraw();
		}
	
		
		
		
	}
}

