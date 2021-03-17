package com.dukascopy.connect.gui.list.renderers.bankAccountElements.sections {
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class BAETextForBankMessageSection extends BAETextSection {
		
		public function BAETextForBankMessageSection() {
			super();
		}
		
		override protected function setColorScheme():void {
			if (isMine == true) {
				textColor = COLOR_WHITE;
				bgColor = COLOR_GREEN;
			} else {
				textColor = COLOR_BLACK;
				bgColor = COLOR_WHITE;
			}
		}
		
		override public function getContentWidth():int {
			return leftTextField.width + H_PADDING * 2 + BIRD_SIZE_DOUBLE;
		}
	}
}