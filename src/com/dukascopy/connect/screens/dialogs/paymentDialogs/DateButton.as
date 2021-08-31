package com.dukascopy.connect.screens.dialogs.paymentDialogs 
{
	import assets.CalendarIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.utils.TextUtils;
	import flash.display.Bitmap;
	import flash.geom.Point;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class DateButton extends BitmapButton
	{
		
		public function DateButton() 
		{
			
		}
		
		public function draw(date:Date):void
		{
			var month:String = (date.getMonth() + 1).toString();
			if (month.length == 1)
			{
				month = "0" + month;
			}
			var day:String = date.getDate().toString();
			if (day.length == 1)
			{
				day = "0" + day;
			}
			
			var bd:ImageBitmapData = TextUtils.createTextFieldData(date.getFullYear() + "-" + month + "-" + day, Config.FINGER_SIZE*5, 10, false, TextFormatAlign.LEFT, 
																	TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .36, false, 0x47515B, 0xFFFFFF, false, true);
			
			var icon:CalendarIcon = new CalendarIcon();
			UI.scaleToFit(icon, Config.FINGER_SIZE, bd.height);
			UI.colorize(icon, 0x93A2AE);
			
			var iconBD:ImageBitmapData = UI.getSnapshot(icon);
			
			var line:ImageBitmapData = UI.getHorizontalLine(0x33CC00, bd.width + iconBD.width + Config.FINGER_SIZE * .2);
			
			var result:ImageBitmapData = new ImageBitmapData("", bd.width + iconBD.width + Config.FINGER_SIZE * .2, bd.height + Config.MARGIN + line.height, false, 0xFFFFFF);
			
			result.copyPixels(iconBD, iconBD.rect, new Point(), null, new Point(), true);
			result.copyPixels(bd, bd.rect, new Point(iconBD.width + Config.FINGER_SIZE * .1, 0), null, new Point(), true);
			result.copyPixels(line, line.rect, new Point(0, bd.height + Config.MARGIN), null, new Point(), true);
			setBitmapData(result, true);
			
			line.dispose();
			bd.dispose();
			iconBD.dispose();
			
			line = null;
			bd = null;
			iconBD = null;
		}
	}
}