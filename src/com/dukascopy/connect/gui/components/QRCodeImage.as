package com.dukascopy.connect.gui.components 
{
	import com.d_project.qrcode.ErrorCorrectLevel;
	import com.d_project.qrcode.QRCode;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.gui.lightbox.IBitmapProvider;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.utils.TextUtils;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class QRCodeImage implements IBitmapProvider
	{
		private var result:ImageBitmapData;
		
		public function QRCodeImage(link:String, description:String, width:int, height:int) 
		{
			var size:int = Math.min(width - Config.FINGER_SIZE * 2, height - Config.FINGER_SIZE * 2);
				size = Math.max(size, Config.FINGER_SIZE * 2);
				var qr : QRCode = QRCode.getMinimumQRCode(link, ErrorCorrectLevel.L);
				var cs : Number = size / qr.getModuleCount();
				
				var target:Sprite = new Sprite();
				var g : Graphics = target.graphics;
				
			for (var row : int = 0; row < qr.getModuleCount(); row++) {
				for (var col : int = 0; col < qr.getModuleCount(); col++) {
					g.beginFill( (qr.isDark(row, col)? Color.GREY_DARK : 0xffffff) );
					g.drawRect(cs * col, cs * row,  cs, cs);
					g.endFill();
				}
			}
			var code:ImageBitmapData = new ImageBitmapData("QRCodeImage.QRCode", size, size);
			code.draw(target);
			UI.destroy(target);
			
			var text:ImageBitmapData
			if (description != null)
			{
				text = TextUtils.createTextFieldData(description, code.width - Config.DIALOG_MARGIN * 2, 10, true, 
													TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, 
													FontSize.BODY, true, Style.color(Style.COLOR_TEXT), 
													Style.color(Style.COLOR_BACKGROUND));
				
				
			}
			
			var resultWidth:int = code.width + Config.FINGER_SIZE;
			var resultHeight:int = code.height + Config.FINGER_SIZE;
			if (text != null)
			{
				resultHeight += text.height + Config.FINGER_SIZE * .5;
			}
			
			result = new ImageBitmapData("QRCodeImage.result", resultWidth, resultHeight, false, 0xFFFFFF);
			var position:int = Config.FINGER_SIZE * .5;
			if (text != null)
			{
				result.copyPixels(text, text.rect, new Point(int(resultWidth * .5 - text.width * .5), int(Config.FINGER_SIZE * .5)), null, null, true);
				position += text.height + Config.FINGER_SIZE * .5;
			}
			result.copyPixels(code, code.rect, new Point(int(resultWidth * .5 - code.width * .5), position), null, null, true);
			
		//	MobileGui.stage.addChild(new Bitmap(result));
		}
		
		
		/* INTERFACE com.dukascopy.connect.gui.lightbox.IBitmapProvider */
		
		public function getBitmapData():BitmapData 
		{
			return result;
		}
		
		public function dispose():void
		{
			//!TODO:;
		}
	}
}