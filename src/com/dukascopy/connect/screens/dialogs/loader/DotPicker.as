package com.dukascopy.connect.screens.dialogs.loader {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import flash.display.Shape;
	import flash.display.Sprite;
	
	public class DotPicker extends Sprite {
		
		private var _vector:Vector.<Shape>;
		private var _s:Shape;
		private var _lenght:int = 0;
		
		public function DotPicker(lenght:int) {
			super();
			_lenght = lenght;
			drawGrayDots();
		}

		private function drawGrayDots():void {
			var xPos:int = 0;
			var size:Number = Config.FINGER_SIZE * .1;
			var shape:Shape;
			_vector = new <Shape>[];
			_s = createPoint(size*.8, AppTheme.GREY_MEDIUM);
			_s.x = 0;
			for (var i:int = 0; i < _lenght; i++)
			{
				shape = createPoint(size*.8, AppTheme.GREY_LIGHT);
				shape.x = xPos;
				xPos = xPos + size*3;
				addChild(shape);
				_vector.push(shape);
			}
			this.addChild(_s);
		}
		
		private function createPoint(radio:uint, color:uint):Shape {
			var s:Shape = new Shape();
			s.graphics.beginFill(color, 1);
			s.graphics.drawCircle(radio, radio, radio);
			s.graphics.endFill();
			return s;
		}
		
		public function setPosByIndex(index:int):void {
			if (_vector.length > index && index >= 0) {
				_s.x = _vector[index].x;
			}
		}
		
		public function dispose():void {
			removeChildren();
			_vector=null;
		}
		
		public function setLegth(val:int):void {
			_lenght = val;
			drawGrayDots();
		}
	}
}