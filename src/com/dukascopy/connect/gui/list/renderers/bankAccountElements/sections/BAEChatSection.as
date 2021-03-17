package com.dukascopy.connect.gui.list.renderers.bankAccountElements.sections {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.langs.Lang;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class BAEChatSection extends BankAccountElementSectionBase {
		
		private var textColor:uint;
		
		private var textFormat:TextFormat;
		
		private var leftTextField:TextField;
		private var rightTextField:TextField;
		
		private const V_PADDING:int = Config.FINGER_SIZE * .1;
		private const H_PADDING:int = Config.FINGER_SIZE * .25;
		private const FONT_SIZE_NORMAL:int = Config.FINGER_SIZE * .26;
		
		private var bbRight:int;
		private var tbLeft:int;
		
		public function BAEChatSection() {
			super();
			
			bbRight = BIRD_SIZE + CORNER_RADIUS_DOUBLE + Config.FINGER_SIZE_DOT_5;
			tbLeft = bbRight - CORNER_RADIUS_DOUBLE * .7;
			
			textFormat = new TextFormat();
			textFormat.font = "Tahoma";
			textFormat.size = FONT_SIZE_NORMAL;
			textFormat.align = TextFormatAlign.LEFT;
			
			leftTextField = new TextField();
			leftTextField.x = BIRD_SIZE + H_PADDING;
			leftTextField.defaultTextFormat = textFormat;
			leftTextField.multiline = false;
			leftTextField.wordWrap = false;
			addChild(leftTextField);
			
			rightTextField = new TextField();
			rightTextField.x = tbLeft + H_PADDING;
			rightTextField.defaultTextFormat = textFormat;
			rightTextField.multiline = true;
			rightTextField.wordWrap = true;
			addChild(rightTextField);
		}
		
		override public function setWidth(w:int):void {
			super.setWidth(w);
		}
		
		override public function setData(data:Object, field:String = null):Boolean {
			if ("chat" in data == false || data.chat == false)
				return false;
			this.data = data;
			return true;
		}
		
		override public function fillData(li:ListItem):void {
			isFirst = false;
			isLast = false;
			
			setColorScheme();
			renderContent(li);
			
			trueHeight = contentHeight + Config.FINGER_SIZE_DOT_25;
		}
		
		private function renderContent(li:ListItem):void {
			contentHeight = CORNER_RADIUS_DOUBLE * 1.5;
			
			rightTextField.text = Lang.talkWithABankBot;
			rightTextField.width = trueWidth - tbLeft - H_PADDING * 2 - BIRD_SIZE;
			rightTextField.height = rightTextField.textHeight + 4;
			rightTextField.textColor = COLOR_WHITE;
			
			if (rightTextField.height + V_PADDING * 2 < CORNER_RADIUS_DOUBLE)
				rightTextField.y = int((CORNER_RADIUS_DOUBLE - rightTextField.height) * .5) + 1;
			else
				rightTextField.y = V_PADDING;
			contentHeight = rightTextField.height + rightTextField.y * 2;
			
			leftTextField.text = "...";
			leftTextField.width = leftTextField.textWidth + 4;
			leftTextField.height = leftTextField.textHeight + 4;
			leftTextField.y = contentHeight - CORNER_RADIUS_DOUBLE + Config.FINGER_SIZE_DOT_25 + int((CORNER_RADIUS_DOUBLE - leftTextField.height) * .5);
			leftTextField.textColor = COLOR_BLACK;
		}
		
		override protected function setColorScheme():void {
			/*if (data.mine == true) {
				if ("toUser" in data == false || data.toUser == null) {
					bgColor = COLOR_GRAY_DARK;
					lineColor = COLOR_WHITE;
					lineAlpha = LINE_OPACITY_2;
				} else {
					bgColor = COLOR_WHITE;
					lineColor = COLOR_BLACK;
					lineAlpha = LINE_OPACITY_1;
				}
				return;
			}
			if ("fromUser" in data == false || data.fromUser == null) {
				bgColor = COLOR_GRAY_DARK;
				lineColor = COLOR_WHITE;
				lineAlpha = LINE_OPACITY_2;
			} else {
				bgColor = COLOR_WHITE;
				lineColor = COLOR_BLACK;
				lineAlpha = LINE_OPACITY_1;
			}
			textColor = COLOR_GRAY_LIGHT;*/
		}
		
		override public function dispose():void {
			textFormat = null;
			
			UI.destroy(leftTextField);
			leftTextField = null;
			
			UI.destroy(rightTextField);
			rightTextField = null;
			
			UI.destroy(this);
			super.dispose();
		}
		
		override protected function drawBG():void {
			var tbCornerAnchorY1:int = contentHeight - CORNER_RADIUS * .5;
			var tbCornerAnchorY2:int = contentHeight - CORNER_RADIUS * .1;
			var tbBirdY:int = contentHeight - CORNER_RADIUS * .3;
			var tbLeftWithCorner:int = tbLeft + CORNER_RADIUS;
			var tbRightWithoutCorner:int = right - CORNER_RADIUS;
			var tbBottomWithoutCorner:int = contentHeight - CORNER_RADIUS;
			
			var bbY:int = contentHeight - CORNER_RADIUS_DOUBLE + Config.FINGER_SIZE_DOT_25;
			var bbCornerAnchorY1:int = trueHeight - CORNER_RADIUS * .5;
			var bbCornerAnchorY2:int = trueHeight - CORNER_RADIUS * .1;
			var bbBirdY:int = trueHeight - CORNER_RADIUS * .3;
			var bbRightWithoutCorner:int = bbRight - CORNER_RADIUS;
			var bbCornerEndY:int = CORNER_RADIUS + bbY;
			
			var bgGfx:Graphics = bg.graphics;
			
			bgGfx.clear();
			
			bgGfx.beginFill(COLOR_WHITE);
			
			bgGfx.moveTo(LEFT_WITH_CORNER, bbY);
			bgGfx.lineTo(bbRightWithoutCorner, bbY);
			bgGfx.curveTo(bbRight, bbY, bbRight, bbCornerEndY);
			bgGfx.curveTo(bbRight, trueHeight, bbRightWithoutCorner, trueHeight);
			bgGfx.lineTo(LEFT_WITH_CORNER, trueHeight);
			bgGfx.curveTo(BIRD_SIZE + CORNER_RADIUS * .5, trueHeight, BIRD_SIZE + CORNER_RADIUS * .2, bbBirdY);
			bgGfx.curveTo(BIRD_SIZE * .65, bbCornerAnchorY2, 0 , bbCornerAnchorY1);
			bgGfx.curveTo(BIRD_SIZE, bbCornerAnchorY1, BIRD_SIZE, bbCornerEndY);
			bgGfx.curveTo(BIRD_SIZE, bbY, LEFT_WITH_CORNER, bbY);
			
			bgGfx.beginFill(COLOR_GREEN);
			
			bgGfx.moveTo(tbLeftWithCorner, 0);
			bgGfx.lineTo(tbRightWithoutCorner, 0);
			bgGfx.curveTo(right, 0, right, CORNER_RADIUS);
			bgGfx.lineTo(right, tbBottomWithoutCorner);
			bgGfx.curveTo(right, tbCornerAnchorY1, trueWidth, tbCornerAnchorY1);
			bgGfx.curveTo(right + BIRD_SIZE * .35, tbCornerAnchorY2, right - CORNER_RADIUS * .2, tbBirdY);
			bgGfx.curveTo(tbRightWithoutCorner + CORNER_RADIUS * .5, contentHeight, tbRightWithoutCorner, contentHeight);
			bgGfx.lineTo(tbLeftWithCorner, contentHeight);
			bgGfx.curveTo(tbLeft, contentHeight, tbLeft, tbBottomWithoutCorner);
			bgGfx.lineTo(tbLeft, CORNER_RADIUS);
			bgGfx.curveTo(tbLeft, 0, tbLeftWithCorner, 0);
			
			bgGfx.endFill();
		}
		
		override public function getTextLineY():int {
			return rightTextField.y + rightTextField.getLineMetrics(0).ascent + 2;
		}
	}
}