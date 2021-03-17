package com.dukascopy.connect.gui.list.renderers.viBot.sections {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.langs.Lang;
	import flash.display.Graphics;
	import flash.filters.DropShadowFilter;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class MenuForVIMessageSection extends VITextSection {
		
		private var isHorizontal:Boolean;
		private var index:int;
		
		public function MenuForVIMessageSection() {
			super();
			
			var tFormat:TextFormat = leftTextField.defaultTextFormat;
			tFormat.align = TextFormatAlign.CENTER;
			leftTextField.defaultTextFormat = tFormat;
			leftTextField.x = H_PADDING;
			
			LEFT_WITH_CORNER = CORNER_RADIUS;
			
			
			var k:Number = Config.FINGER_SIZE / 70;
			
			var shadow:DropShadowFilter = new DropShadowFilter(int(k*2), 90, 0x000000, 0.3, int(k*6), int(k*6));
			filters = [shadow];
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
			var text:String;
			if (data != null &&
				data[dataField] != null &&
				data[dataField] != "" &&
				data[dataField] in Lang.viText == true &&
				Lang.viText[data[dataField]] != null &&
				Lang.viText[data[dataField]] != "") {
					text = Lang.viText[data[dataField]];
			} else {
				text = data[dataField].replace(/_/, " ");
			}
			leftTextField.text = text;
			leftTextField.width = trueWidth - H_PADDING * 2;
			leftTextField.height = leftTextField.textHeight + 4;
			leftTextField.textColor = textColor;
			if (leftTextField.height + V_PADDING * 2 < CORNER_RADIUS_DOUBLE)
				leftTextField.y = int((CORNER_RADIUS_DOUBLE - leftTextField.height) * .5) + 1;
			else
				leftTextField.y = V_PADDING;
			contentHeight = leftTextField.height + V_PADDING * 2;
		}
		
		override protected function setColorScheme():void {
			if (data != null)
			{
				if ("textColor" in data == true)
					textColor = data.textColor;
				else
					textColor = 0x71808C;
			}
			else
			{
				textColor = 0x71808C;
			}
			bgColor = 0xE8FFDB;
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
		
		override public function fillData(li:ListItem):void {
			super.fillData(li);
			
			trueHeight = contentHeight;
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
				bgGfx.beginFill(0xB5BEC6, 1);
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