package com.dukascopy.connect.gui.list.renderers.viBot.sections {
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class TextForVIMessageSection extends VITextSection {
		
		public function TextForVIMessageSection() {
			super();
		}
		
		override protected function setColorScheme():void {
			if (isMine == true) {
				textColor = COLOR_WHITE;
				bgColor = COLOR_GREEN;
			} else {
				textColor = 0x71808C;
				bgColor = COLOR_WHITE;
			}
		}
		
		override public function getContentWidth():int {
			return leftTextField.width + H_PADDING * 2 + BIRD_SIZE_DOUBLE;
		}
	}
}