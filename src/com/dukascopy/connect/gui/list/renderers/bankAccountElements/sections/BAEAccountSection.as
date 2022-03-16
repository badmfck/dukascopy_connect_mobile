package com.dukascopy.connect.gui.list.renderers.bankAccountElements.sections {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.sys.bankManager.BankManager;
	import com.dukascopy.connect.sys.payments.CurrencyHelpers;
	import com.dukascopy.langs.Lang;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class BAEAccountSection extends BankAccountElementSectionBase {
		
		private var textColor:uint = COLOR_GREEN;
		
		private var textFormat:TextFormat;
		
		private var leftTextField:TextField;
		private var rightTextField:TextField;
		
		private const V_PADDING:int = Config.FINGER_SIZE * .1;
		private const H_PADDING:int = Config.FINGER_SIZE * .25;
		private const FONT_SIZE_NORMAL:int = Config.FINGER_SIZE * .26;
		private const FONT_SIZE_SMALL:int = Config.FINGER_SIZE * .18;
		
		public function BAEAccountSection() {
			super();
			
			textFormat = new TextFormat();
			textFormat.font = "Tahoma";
			textFormat.size = FONT_SIZE_NORMAL;
			textFormat.align = TextFormatAlign.LEFT;
			textFormat.italic = false;
			textFormat.bold = false;
			
			leftTextField = new TextField();
			leftTextField.x = BIRD_SIZE + H_PADDING;
			leftTextField.y = V_PADDING;
			leftTextField.defaultTextFormat = textFormat;
			leftTextField.multiline = true;
			leftTextField.wordWrap = true;
			addChild(leftTextField);
			
			rightTextField = new TextField();
			rightTextField.y = V_PADDING;
			rightTextField.defaultTextFormat = textFormat;
			rightTextField.multiline = false;
			rightTextField.wordWrap = false;
			addChild(rightTextField);
		}
		
		override public function setWidth(w:int):void {
			super.setWidth(w);
		}
		
		override public function setData(data:Object, field:String = null):Boolean {
			if ("acc" in data == false)
				return false;
			this.data = data;
			return true;
		}
		
		override public function fillData(li:ListItem):void {
			isFirst = false;
			isLast = false;
			
			setColorScheme();
			renderContent(li);
			
			bottomCornerY = contentHeight - CORNER_RADIUS;
			trueHeight = contentHeight;
		}
		
		private function renderContent(li:ListItem):void {
			rightTextField.htmlText = UI.renderCurrencyAdvanced(
				data.amount,
				data.acc,
				Config.FINGER_SIZE * .25,
				Config.FINGER_SIZE * .19
			);
			rightTextField.width = rightTextField.textWidth + 4;
			rightTextField.height = rightTextField.textHeight + 4;
			rightTextField.x = trueWidth - rightTextField.width - H_PADDING - BIRD_SIZE;
			
			leftTextField.text = (data.title != null) ? data.title : "undefined";
			leftTextField.width = rightTextField.x - leftTextField.x;
			if (leftTextField.textWidth + 6 < leftTextField.width)
				leftTextField.width = leftTextField.textWidth + 6;
			leftTextField.height = leftTextField.textHeight + 4;
			leftTextField.textColor = rightTextField.textColor = textColor;
			
			if (leftTextField.height + V_PADDING * 2 < CORNER_RADIUS_DOUBLE)
				leftTextField.y = rightTextField.y = int((CORNER_RADIUS_DOUBLE - leftTextField.height) * .5) + 1;
			
			contentHeight = int(leftTextField.height + leftTextField.y * 2) + 1;
		}
		
		override protected function setColorScheme():void {
			if (data.mine == true) {
				if ("type" in data && data.type == "getcashSwap") {
					bgColor = COLOR_ORANGE;
					textColor = COLOR_WHITE;
				} else if ("type" in data && data.type.indexOf(")!2") != 0) {
					if (data.type == "coinTrade") {
						bgColor = COLOR_BLUE_LIGHT;
						textColor = COLOR_WHITE;
					} else if (data.type == "RD") {
						bgColor = COLOR_BLUE_RD;
						textColor = COLOR_WHITE;
					} else {
						bgColor = COLOR_WHITE;
						textColor = COLOR_BLACK;
					}
				} else {
					if (data.acc == "DCO" && data.userAccNumber == BankManager.rewardAccount)
						bgColor = COLOR_BLUE;
					else
						bgColor = COLOR_RED;
					textColor = COLOR_WHITE;
				}
				lineColor = COLOR_BLACK;
				lineAlpha = LINE_OPACITY_1;
				return;
			}
			bgColor = COLOR_GREEN;
			lineColor = COLOR_BLACK;
			lineAlpha = LINE_OPACITY_1;
			textColor = COLOR_WHITE;
		}
		
		override public function dispose():void {
			super.dispose();
			
			textFormat = null;
			UI.destroy(leftTextField);
			leftTextField = null;
			UI.destroy(rightTextField);
			rightTextField = null;
			UI.destroy(this);
		}
		
		override public function getTextLineY():int {
			return rightTextField.y + rightTextField.getLineMetrics(0).ascent + 2;
		}
	}
}