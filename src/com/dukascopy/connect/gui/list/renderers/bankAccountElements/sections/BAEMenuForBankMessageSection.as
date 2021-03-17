package com.dukascopy.connect.gui.list.renderers.bankAccountElements.sections {
	
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.langs.Lang;
	import flash.display.Graphics;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class BAEMenuForBankMessageSection extends BAETextSection {
		
		private var isHorizontal:Boolean;
		private var index:int;
		
		public function BAEMenuForBankMessageSection() {
			super();
			
			var tFormat:TextFormat = leftTextField.defaultTextFormat;
			tFormat.align = TextFormatAlign.CENTER;
			leftTextField.defaultTextFormat = tFormat;
			leftTextField.x = H_PADDING;
			
			LEFT_WITH_CORNER = CORNER_RADIUS;
		}
		
		override public function setWidth(w:int):void {
			super.setWidth(w);
			widthWithoutCorners = trueWidth - CORNER_RADIUS_DOUBLE;
		}
		
		public function setContentWidth(w:int):void {
			setWidth(w);
			
			leftTextField.width = trueWidth - H_PADDING * 2;
		}
		
		public function setHorizontal(val:Boolean):void {
			isHorizontal = val;
		}
		
		override protected function renderContent(li:ListItem):void {
			if (data[dataField] != "")
				leftTextField.text = data[dataField];
			else
				leftTextField.text = Lang.emptyLabel;
			leftTextField.width = trueWidth - H_PADDING * 2;
			leftTextField.height = leftTextField.textHeight + 4;
			leftTextField.textColor = textColor;
			if (leftTextField.height + V_PADDING * 2 < CORNER_RADIUS_DOUBLE)
				leftTextField.y = int((CORNER_RADIUS_DOUBLE - leftTextField.height) * .5) + 1;
			else
				leftTextField.y = V_PADDING;
			contentHeight = leftTextField.height + leftTextField.y * 2;
			
			fitToContent();
		}
		
		override protected function setColorScheme():void {
			if ("textColor" in data == true)
				textColor = data.textColor;
			else
				textColor = COLOR_RED;
			bgColor = COLOR_WHITE;
		}
		
		override public function getContentWidth():int {
			return leftTextField.width + H_PADDING * 2;
		}
		
		public function getTextfieldWithPaddingWidth():int {
			return leftTextField.textWidth + 6 + H_PADDING * 2;
		}
		
		public function setTextColor(val:uint):void {
			textColor = val;
		}
		
		override protected function drawBG():void {
			var bgGfx:Graphics = bg.graphics;
			bgGfx.clear();
			bgGfx.beginFill(bgColor);
			
			if (isFirst == true && isLast == true) {
				bgGfx.drawRoundRectComplex(0, 0, trueWidth, trueHeight, CORNER_RADIUS, CORNER_RADIUS, CORNER_RADIUS, CORNER_RADIUS);
			} else if (isFirst == true) {
				if (isHorizontal == true) {
					bgGfx.drawRoundRectComplex(0, 0, trueWidth, trueHeight, CORNER_RADIUS, 0, CORNER_RADIUS, 0);
				} else {
					bgGfx.drawRoundRectComplex(0, 0, trueWidth, trueHeight, CORNER_RADIUS, CORNER_RADIUS, 0, 0);
				}
			} else if (isLast == true) {
				if (isHorizontal == true) {
					bgGfx.drawRoundRectComplex(0, 0, trueWidth, trueHeight, 0, CORNER_RADIUS, 0, CORNER_RADIUS);
				} else {
					bgGfx.drawRoundRectComplex(0, 0, trueWidth, trueHeight, 0, 0, CORNER_RADIUS, CORNER_RADIUS);
				}
			} else {
				bgGfx.drawRect(0, 0, trueWidth, trueHeight);
			}
			if (isFirst == false) {
				bgGfx.beginFill(lineColor, lineAlpha);
				if (isHorizontal == true) {
					bgGfx.drawRect(0,0,lineHeight, trueHeight);
				} else {
					bgGfx.drawRect(0,0,trueWidth, lineHeight);
				}
			}
			bgGfx.endFill();
		}
		
		public function setIndex(val:int):void {
			index = val;
		}
		
		public function getIndex():int {
			return index;
		}
	}
}