package com.dukascopy.connect.gui.list.renderers.bankAccountElements.sections {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.gui.list.renderers.CodeProtectionSprite;
	import com.dukascopy.connect.sys.bankManager.BankManager;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
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
	
	public class BAEButtonSection extends BAETextSection {
		
		public function BAEButtonSection() {
			super();
		}
		
		override protected function createTextFormat():void 
		{
			textFormat = new TextFormat();
			textFormat.color = Color.WHITE;
			textFormat.font = Config.defaultFontName;
			textFormat.size = Config.FINGER_SIZE * .2;
			textFormat.align = TextFormatAlign.LEFT;
		}
		
		override protected function setColorScheme():void {
			super.setColorScheme();
			textColor = Color.WHITE;
		}
		
		public function getHeight():int 
		{
			return int(leftTextField.height + V_PADDING * 2 + Config.FINGER_SIZE * .4);
		}
		
		public function getButtonX():int 
		{
			return leftTextField.x - Config.FINGER_SIZE * .2;
		}
		
		public function getButtonY():int 
		{
			return leftTextField.y - V_PADDING;
		}
		
		public function getButtonWidth():int 
		{
			return leftTextField.width + Config.FINGER_SIZE * .4;
		}
		
		public function getButtonHeight():int 
		{
			return leftTextField.height + V_PADDING * 2;
		}
		
		override protected function renderContent(li:ListItem):void {
			
			leftTextField.width = trueWidth - Config.FINGER_SIZE * .8;
			leftTextField.text = data[dataField].toUpperCase();
			
			leftTextField.height = leftTextField.textHeight + 4;
			leftTextField.width = leftTextField.textWidth + 8;
			leftTextField.textColor = textColor;
			leftTextField.y = V_PADDING + Config.FINGER_SIZE * .2;
			
			contentHeight = leftTextField.height + leftTextField.y * 2;
			
			fitToContent();
			
			leftTextField.x = int(trueWidth * .5 - leftTextField.width * .5);
			
			graphics.clear();
			graphics.beginFill(Color.GREEN);
			graphics.drawRoundRect(int(leftTextField.x - Config.FINGER_SIZE * .2), int(leftTextField.y - V_PADDING), 
									int(leftTextField.width + Config.FINGER_SIZE * .4), int(leftTextField.height + V_PADDING * 2), 
									int(leftTextField.height + Config.FINGER_SIZE * .2), int(leftTextField.height + Config.FINGER_SIZE * .2));
			graphics.endFill();
		}
	}
}