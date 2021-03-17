package com.dukascopy.connect.gui.menuVideo 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.style.Style;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;

	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class OptionSwitcherCustomLayout extends OptionSwitcher
	{
		public var iconPosition:int;
		public var textPosition:int;
		
		public function OptionSwitcherCustomLayout() 
		{
			
		}
		
		override protected function updateViewPort():void
		{
			if (_isDisposed) return;
			
			if (_viewWidth < Config.FINGER_SIZE_DOUBLE) return;
			
			iconBitmap.y = (_viewHeight- iconBitmap.height )*.5;
			iconBitmap.x = int(iconPosition - iconBitmap.width*.5);
			
			
			if (textBitmap != null) {
				
				var textX:int = textPosition;
				
				var textWidth:int = _viewWidth - textX - COMPONENT_WIDTH;
				
				UI.disposeBMD(textBitmap.bitmapData);
				textBitmap.bitmapData = null;				
				textBitmap.bitmapData =  UI.renderText(_labelText,
													textWidth, 
													_viewHeight,
													false,
													TextFormatAlign.LEFT,
													TextFieldAutoSize.LEFT,
													FONT_SIZE,
													false,
													Style.color(Style.COLOR_TEXT),
													Style.color(Style.COLOR_BACKGROUND),
													true);
								
				textBitmap.x = textX;
				textBitmap.y = (_viewHeight- textBitmap.height )*.5;
				
			}
			
			// update toggler position 
			toggler.x = _viewWidth - toggler.width;
			toggler.y = (_viewHeight - toggler.height) * .5;
			
		}
		
	}

}