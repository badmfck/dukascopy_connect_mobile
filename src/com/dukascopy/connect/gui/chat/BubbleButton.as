package com.dukascopy.connect.gui.chat 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.type.HitZoneType;
	import flash.display.BitmapData;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class BubbleButton extends BitmapButton
	{
		private var textColor:uint = 0x0051ca;
		private var bgColor:uint = 0xc4def1;
		private var borderColor:uint = 0x0051ca;
		private var borderThickness:int = 2;
		private var bgOpacity:Number = 1;
		private var borderRadius:Number = Config.FINGER_SIZE_DOT_25;
		private var vPadding:int = Config.MARGIN;
		private var hPadding:int = Config.MARGIN * 2;
		private var textAlign:String  =  TextFormatAlign.LEFT;
		
		public function BubbleButton() 
		{
			setOverlay(HitZoneType.BUTTON);
		}
		public function setParams(_textColor:uint = 0x0051ca, _bgColor:uint = 0xffffff, _bgOpacity:Number = 0.1, _borderColor:uint = 0x0051ca, _borderThickness:int = 1, _textAlign:String =  TextFormatAlign.LEFT):void{
			textColor = _textColor;
			bgColor = _bgColor;
			borderColor= _borderColor;
			borderThickness= _borderThickness;
			bgOpacity = _bgOpacity;
			textAlign = _textAlign;
		}
		
		public function setText(txt:String, w:int):void
		{
			var tempBmd:BitmapData =  UI.renderTextPlane(txt , w, int(Config.FINGER_SIZE*.9), true, textAlign, TextFieldAutoSize.LEFT, FontSize.BODY, true, textColor, bgColor, borderColor, borderRadius, borderThickness, hPadding, vPadding, null, false, true);
			super.setBitmapData(tempBmd, true, true);
		}
	}
}