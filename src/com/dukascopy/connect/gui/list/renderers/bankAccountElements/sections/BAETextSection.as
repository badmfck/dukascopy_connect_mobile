package com.dukascopy.connect.gui.list.renderers.bankAccountElements.sections {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.gui.list.renderers.CodeProtectionSprite;
	import com.dukascopy.connect.sys.bankManager.BankManager;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.langs.Lang;
	import flash.display.Sprite;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class BAETextSection extends BankAccountElementSectionBase {
		
		protected var textColor:uint;
		
		protected var textFormat:TextFormat;
		private var codeProtection:CodeProtectionSprite;
		
		protected var leftTextField:TextField;
		
		protected const V_PADDING:int = Config.FINGER_SIZE * .1;
		protected const H_PADDING:int = Config.FINGER_SIZE * .25;
		protected const FONT_SIZE_NORMAL:int = Config.FINGER_SIZE * .29;
		
		protected var dataField:String;
		
		protected var _fitToContent:Boolean;
		
		public function BAETextSection() {
			super();
			
			createTextFormat();
			createTextField();
		}
		
		protected function createTextField():void 
		{
			leftTextField = new TextField();
			leftTextField.x = BIRD_SIZE + H_PADDING;
			leftTextField.y = V_PADDING;
			leftTextField.defaultTextFormat = textFormat;
			leftTextField.multiline = true;
			leftTextField.wordWrap = true;
			addChild(leftTextField);
		}
		
		protected function createTextFormat():void 
		{
			textFormat = new TextFormat();
			textFormat.font = "Tahoma";
			textFormat.size = FONT_SIZE_NORMAL;
			textFormat.align = TextFormatAlign.LEFT;
		}
		
		public function setFitToContent(val:Boolean = true):void {
			_fitToContent = val;
		}
		
		override public function setWidth(w:int):void {
			super.setWidth(w);
		}
		
		override public function setData(data:Object, field:String = null):Boolean {
			dataField = field;
			if (dataField == null)
				dataField = "desc";
			if (dataField in data == false)
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
		
		protected function renderContent(li:ListItem):void {
			if ("type" in data == true && data.type == "coinTrade") {
				var index:int = data[dataField].indexOf("(");
				if (index > 0)
					leftTextField.text = data[dataField].substring(0, index - 1) + "\n" + data[dataField].substring(index);
				else
					leftTextField.text = data[dataField];
			} else
				leftTextField.htmlText = data[dataField];
			leftTextField.width = trueWidth - BIRD_SIZE_DOUBLE - H_PADDING * 2;
			leftTextField.height = leftTextField.textHeight + 4;
			leftTextField.textColor = textColor;
			if (leftTextField.height + V_PADDING * 2 < CORNER_RADIUS_DOUBLE)
				leftTextField.y = int((CORNER_RADIUS_DOUBLE - leftTextField.height) * .5) + 1;
			else
				leftTextField.y = V_PADDING;
			
			contentHeight = leftTextField.height + leftTextField.y * 2;
			
			if ("withCode" in li.data && li.data.withCode == true) {
				showCodeProtectionItem();
				contentHeight += codeProtection.getHeight() + V_PADDING * 1.5;
			} else {
				hideCodeProtectionItem();
			}
			
			fitToContent();
		}
		
		private function hideCodeProtectionItem():void 
		{
			if (codeProtection != null)
			{
				codeProtection.visible = false;
			}
		}
		
		private function showCodeProtectionItem():void {
			if (codeProtection == null) {
				codeProtection = new CodeProtectionSprite(widthWithoutCorners);
				addChild(codeProtection);
			}
			codeProtection.visible = true;
			codeProtection.x = BIRD_SIZE + H_PADDING;
			codeProtection.y = leftTextField.height + leftTextField.y * 2;
			codeProtection.setText(Lang.enterProtectionCode, bgColor == COLOR_GRAY_DARK ? 0xFFFFFF : 0xCD3E44);
		}
		
		protected function fitToContent():void {
			if (_fitToContent == false)
				return
			trueWidth = leftTextField.textWidth + 4 + H_PADDING * 2 + BIRD_SIZE_DOUBLE;
			widthWithoutCorners = trueWidth - CORNER_RADIUS_DOUBLE - BIRD_SIZE_DOUBLE;
			right = trueWidth - BIRD_SIZE;
		}
		
		override protected function setColorScheme():void {
			if ("type" in data == true) {
				if (data.type == "exchange" || data.type == ")!2exchange") {
					bgColor = COLOR_GRAY_MEDIUM;
					textColor = COLOR_BLACK;
				} else if (data.type == "investment" || data.type == ")!2investment") {
					bgColor = COLOR_BLUE_LIGHT;
					textColor = COLOR_WHITE;
				} else if (data.type == "coinTrade" || data.type == "RD") {
					bgColor = COLOR_WHITE;
					textColor = COLOR_BLACK;
					lineColor = COLOR_BLACK;
				} else if (data.type == "savingsTransfer") {
					bgColor = COLOR_BLUE_LIGHT;
					textColor = COLOR_WHITE;
				}
				lineColor = bgColor;
				lineAlpha = 1;
				return;
			}
			if ("bankBot" in data == true && data.bankBot == true) {
				bgColor = COLOR_WHITE;
				lineColor = COLOR_BLACK;
				lineAlpha = LINE_OPACITY_1;
				textColor = COLOR_BLACK;
				return
			}
			textColor = COLOR_GRAY_LIGHT;
			if (data.acc == "DCO" && data.userAccNumber == BankManager.rewardAccount) {
				
			} else if ("user" in data == false || data.user == null) {
				bgColor = COLOR_GRAY_DARK;
				lineColor = COLOR_WHITE;
				lineAlpha = LINE_OPACITY_2;
				return
			}
			bgColor = COLOR_WHITE;
			lineColor = COLOR_BLACK;
			lineAlpha = LINE_OPACITY_1;
		}
		
		override public function dispose():void {
			textFormat = null;
			
			UI.destroy(leftTextField);
			leftTextField = null;
			
			if (codeProtection != null)
			{
				codeProtection.dispose();
				if (contains(codeProtection))
				{
					removeChild(codeProtection);
				}
				codeProtection = null;
			}
			
			UI.destroy(this);
			super.dispose();
		}
		
		override public function getTextLineY():int {
			return leftTextField.y + leftTextField.getLineMetrics(0).ascent + 2;
		}
	}
}