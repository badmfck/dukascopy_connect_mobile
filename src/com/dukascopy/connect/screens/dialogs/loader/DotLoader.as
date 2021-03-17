/**
 * Created by aleksei.leschenko on 04.04.2017.
 */
package com.dukascopy.connect.screens.dialogs.loader {
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.greensock.TweenMax;
	import flash.display.Shape;
	import flash.display.Sprite;


	public class DotLoader extends Sprite {

		private var _counter:int = 0;
		private var _s1:Shape;
		private var _s2:Shape;
		private var _s3:Shape;
		private var _s:Shape;
		private var _isAnimating:Boolean = false;

		public function DotLoader() {
			super();
			drawGrayDots();
		}

		private function drawGrayDots():void {
			var xPos:int = 0;
			var size:Number = Config.FINGER_SIZE * .1;

			_s1 = createPoint(size, AppTheme.GREY_LIGHT);
			xPos = xPos + size;
			_s1.x = xPos;
			this.addChild(_s1);
			xPos = xPos + _s1.width;

			_s2 = createPoint(size, AppTheme.GREY_LIGHT);
			xPos = xPos + size;
			 _s2.x= xPos;
			this.addChild(_s2);
			xPos = xPos  + _s2.width;

			_s3 = createPoint(size, AppTheme.GREY_LIGHT);
			xPos = xPos + size;
			_s3.x = xPos;

			this.addChild(_s3);
			_s = createPoint(size, AppTheme.GREY_MEDIUM);
			_s.x = _s2.x;
			this.addChild(_s);
		}


		// param must be >= 1
		private function createPoint(radio:uint, color:uint):Shape {
			var s:Shape = new Shape();
			s.graphics.beginFill(color, 1);
			s.graphics.drawCircle(radio, radio, radio);
			s.graphics.endFill();

			return s;
		}

		public function startAnim():void {
			if (_isAnimating) return;
			_isAnimating = true;
			timerHandler();

		}

		private function timerHandler():void {
			if (_counter == 3) {
				_counter = 0;
				_s.visible = false;
				return;
			}

			switch (_counter) {
				case 0: {
					_s.x = _s1.x;
					_s.visible = true;
					break;
				}
				case 1: {
					_s.x = _s2.x;
					_s.visible = true;
					break;
				}
				case 2: {
					_s.x = _s3.x;
					_s.visible = true;
					break;
				}
				case 3: {
					break;
				}
			}
			
			_counter++;
			TweenMax.delayedCall(.3, timerHandler)
		}

		public function stopAnim():void {
			_isAnimating = false;
			TweenMax.killDelayedCallsTo(timerHandler)
		}

		public function dispose():void {
			stopAnim();
			removeChildren();
		}
	}
}
