package com.dukascopy.connect.gui.list.renderers.bankAccountElements.sections {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class BankAccountElementSectionBase extends Sprite {
		
		protected const COLOR_WHITE:uint = 0xFFFFFF;
		protected const COLOR_BLACK:uint = 0;
		protected const COLOR_GRAY_DARK:uint = 0x373E4E;
		protected const COLOR_GRAY_LIGHT:uint = 0x7DA0BB;
		protected const COLOR_GREEN:uint = 0x46C36A;
		protected const COLOR_RED:uint = 0xCD3F43;
		protected const COLOR_BLUE:uint = 0x3F6DCD;
		protected const COLOR_BLUE_LIGHT:uint = 0x718FD0;
		protected const COLOR_BLUE_RD:uint = 0x2A7CA9;
		protected const COLOR_YELLOW:uint = 0xCDB63F;
		protected const COLOR_GRAY_LIGHTER:uint = 0xf7f8f9;
		protected const COLOR_GRAY_MEDIUM:uint = 0xE2E3E4;
		
		protected const LINE_OPACITY_1:Number = .1;
		protected const LINE_OPACITY_2:Number = .2;
		
		static public const CORNER_RADIUS:int = Config.FINGER_SIZE / 2.5;
		static public const CORNER_RADIUS_DOUBLE:int = CORNER_RADIUS * 2;
		public const BIRD_SIZE:int = CORNER_RADIUS * .7;
		protected const BIRD_SIZE_DOUBLE:int = BIRD_SIZE * 2;
		
		protected var LEFT_WITH_CORNER:int;
		
		protected var widthWithoutCorners:int;
		protected var right:int;
		protected var bottomCornerY:int;
		protected var lineHeight:int;
		
		protected var bgColor:uint = COLOR_WHITE;
		protected var lineColor:uint = COLOR_BLACK;
		protected var lineAlpha:Number = LINE_OPACITY_1;
		
		protected var bg:Shape;
		protected var bgGradient:Shape;
		
		protected var isFirst:Boolean;
		protected var isLast:Boolean;
		protected var isMine:Boolean;
		
		protected var contentHeight:int;
		protected var contentWidth:int;
		
		protected var trueHeight:int;
		protected var trueWidth:int;
		
		protected var data:Object;
		
		public function BankAccountElementSectionBase() {
			bg = new Shape();
			addChild(bg);
			
			/*bgGradient = new Shape();
			addChild(bgGradient);*/
			
			lineHeight = Config.FINGER_SIZE * .03;
			if (lineHeight == 0)
				lineHeight = 1;
			
			LEFT_WITH_CORNER = CORNER_RADIUS + BIRD_SIZE;
		}
		
		public function setWidth(w:int):void {
			if (trueWidth == w)
				return;
			trueWidth = w;
			widthWithoutCorners = trueWidth - CORNER_RADIUS_DOUBLE - BIRD_SIZE_DOUBLE;
			right = trueWidth - BIRD_SIZE;
		}
		
		public function setData(data:Object, field:String = null):Boolean {
			return true;
		}
		
		public function fillData(li:ListItem):void {
			isFirst = false;
			isLast = false;
			
			bottomCornerY = CORNER_RADIUS + contentHeight;
			trueHeight = contentHeight + CORNER_RADIUS_DOUBLE;
		}
		
		public function setFirst(val:Boolean):void {
			isFirst = val;
		}
		
		public function setLast(val:Boolean):void {
			isLast = val;
		}
		
		public function setMine(val:Boolean):void {
			isMine = val;
		}
		
		public function draw():void {
			renderBG();
		}
		
		protected function renderBG():void {
			drawBG();
		}
		
		protected function setColorScheme():void { }
		
		protected function getBgIBMDBy():ImageBitmapData {
			return null;
		}
		
		protected function drawBG():void {
			var cornerAnchorY1:int = trueHeight - CORNER_RADIUS * .5;
			var cornerAnchorY2:int = trueHeight - CORNER_RADIUS * .1;
			var birdY:int = trueHeight - CORNER_RADIUS * .3;
			
			var bgGfx:Graphics = bg.graphics;
			
			bgGfx.clear();
			
			var bmd:ImageBitmapData = getBgIBMDBy();
			if (bmd != null)
				bgGfx.beginBitmapFill(bmd, null, true, true);
			else
				bgGfx.beginFill(bgColor);
			
			if (isFirst == true) {
				bgGfx.moveTo(LEFT_WITH_CORNER, 0);
				bgGfx.lineTo(LEFT_WITH_CORNER + widthWithoutCorners, 0);
				bgGfx.curveTo(right, 0, right, CORNER_RADIUS);
			} else {
				bgGfx.moveTo(BIRD_SIZE, 0);
				bgGfx.lineTo(right, 0);
			}
			if (isLast == true) {
				bgGfx.lineTo(right, bottomCornerY);
				if (isMine == true) {
					bgGfx.curveTo(right, cornerAnchorY1, trueWidth, cornerAnchorY1);
					bgGfx.curveTo(right + BIRD_SIZE * .35, cornerAnchorY2, right - CORNER_RADIUS * .2, birdY);
					bgGfx.curveTo(LEFT_WITH_CORNER + widthWithoutCorners + CORNER_RADIUS * .5, trueHeight, LEFT_WITH_CORNER + widthWithoutCorners, trueHeight);
				} else {
					bgGfx.curveTo(trueWidth - BIRD_SIZE, trueHeight, LEFT_WITH_CORNER + widthWithoutCorners, trueHeight);
				}
				bgGfx.lineTo(LEFT_WITH_CORNER, trueHeight);
				if (isMine == true) {
					bgGfx.curveTo(BIRD_SIZE, trueHeight, BIRD_SIZE, bottomCornerY);
				} else {
					bgGfx.curveTo(BIRD_SIZE + CORNER_RADIUS * .5, trueHeight, BIRD_SIZE + CORNER_RADIUS * .2, birdY);
					bgGfx.curveTo(BIRD_SIZE * .65, cornerAnchorY2, 0 , cornerAnchorY1);
					bgGfx.curveTo(BIRD_SIZE, cornerAnchorY1, BIRD_SIZE, bottomCornerY);
				}
			} else {
				bgGfx.lineTo(right, trueHeight);
				bgGfx.lineTo(BIRD_SIZE, trueHeight);
			}
			if (isFirst == true) {
				bgGfx.lineTo(BIRD_SIZE, CORNER_RADIUS);
				bgGfx.curveTo(BIRD_SIZE, 0, LEFT_WITH_CORNER, 0);
			} else {
				bgGfx.lineTo(BIRD_SIZE, 0);
			}
			
			if (isFirst == false && bmd == null) {
				bgGfx.beginFill(lineColor, lineAlpha);
				bgGfx.drawRect(BIRD_SIZE, 0, trueWidth - BIRD_SIZE_DOUBLE, lineHeight);
			}
			bgGfx.endFill();
		}
		
		public function getTrueHeight():int {
			return trueHeight;
		}
		
		public function getTrueWidth():int {
			return trueWidth;
		}
		
		public function getCornerEnd():int {
			return LEFT_WITH_CORNER;
		}
		
		public function getTextLineY():int {
			return 0;
		}
		
		public function getContentWidth():int {
			return contentWidth;
		}
		
		public function getBirdSize():int {
			return BIRD_SIZE;
		}
		
		public function dispose():void {
			if (bg != null) {
				bg.graphics.clear();
				if (bg.parent != null)
					bg.parent.removeChild(bg);
			}
			bg = null;
			if (bgGradient != null) {
				bgGradient.graphics.clear();
				if (bgGradient.parent != null)
					bgGradient.parent.removeChild(bgGradient);
			}
			bgGradient = null;
		}
		
		public function getData():Object {
			return data;
		}
	}
}