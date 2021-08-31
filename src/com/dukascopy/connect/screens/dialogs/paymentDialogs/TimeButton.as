package com.dukascopy.connect.screens.dialogs.paymentDialogs 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.utils.TextUtils;
	import flash.geom.Point;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class TimeButton extends BitmapButton
	{
		
		public function TimeButton() 
		{
			
		}
		
		public function draw(date:Date):void
		{
			var hours:String = date.getHours().toString();
			if (hours.length == 1)
			{
				hours = "0" + hours;
			}
			var minutes:String = date.getMinutes().toString();
			if (minutes.length == 1)
			{
				minutes = "0" + minutes;
			}
			
			var bd:ImageBitmapData = TextUtils.createTextFieldData(hours + ":" + minutes, Config.FINGER_SIZE*5, 10, false, TextFormatAlign.LEFT, 
																	TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .36, false, 0x47515B, 0xFFFFFF, false, true);
			var line:ImageBitmapData = UI.getHorizontalLine(0x33CC00, bd.width);
			var result:ImageBitmapData = new ImageBitmapData("", bd.width, bd.height + Config.MARGIN + line.height, false, 0xFFFFFF);
			result.copyPixels(bd, bd.rect, new Point(), null, new Point(), true);
			result.copyPixels(line, line.rect, new Point(0, bd.height + Config.MARGIN), null, new Point(), true);
			setBitmapData(result, true);
			
			line.dispose();
			bd.dispose();
			
			line = null;
			bd = null;
		}
	}
}