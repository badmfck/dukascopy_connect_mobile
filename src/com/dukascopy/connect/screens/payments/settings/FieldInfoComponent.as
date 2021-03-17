package com.dukascopy.connect.screens.payments.settings {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class FieldInfoComponent extends Sprite {
		
		private var labelBitmap:Bitmap;
		private var textBitmap:Bitmap;
		
		private var _label:String;
		private var _text:String;
		
		private var _width:Number = 320;
		
		public function FieldInfoComponent(label:String, text:String = "") {
			_text = text;
			_label = label;
			
			labelBitmap = new Bitmap();
			labelBitmap.x = Config.DOUBLE_MARGIN;
			addChild(labelBitmap);
			
			textBitmap = new Bitmap();
			textBitmap.x = Config.DOUBLE_MARGIN;
			addChild(textBitmap);
		}
		
		private function drawLabel():void {
			if (labelBitmap.bitmapData != null)
				UI.disposeBMD(labelBitmap.bitmapData);
			labelBitmap.bitmapData = UI.renderTextShadowed(
				_label + ":",
				_width,
				Config.FINGER_SIZE,
				true,
				false,
				TextFormatAlign.LEFT,
				TextFieldAutoSize.LEFT,
				Config.FINGER_SIZE * .21,
				false,
				Style.color(Style.COLOR_BACKGROUND),
				AppTheme.BLACK,
				Style.color(Style.COLOR_SUBTITLE),
				true,
				1,
				false
			);
		}
		
		private function drawText():void {
			if (textBitmap.bitmapData != null)
				UI.disposeBMD(textBitmap.bitmapData);
			textBitmap.bitmapData = UI.renderTextShadowed(
				_text,
				_width,
				Config.FINGER_SIZE,
				true,
				false,
				TextFormatAlign.LEFT,
				TextFieldAutoSize.CENTER,
				Config.FINGER_SIZE * .36,
				true,
				Style.color(Style.COLOR_BACKGROUND),
				AppTheme.BLACK,
				Style.color(Style.COLOR_TEXT),
				true,
				1,
				false
			);
		}
		
		public function dispose():void {
			UI.destroy(labelBitmap);
			labelBitmap = null;
			UI.destroy(textBitmap);
			textBitmap = null;
		}
		
		public function setWidth(width:int):void {
			_width = width - Config.DOUBLE_MARGIN * 2;
			
			drawLabel();
			drawText();
			
			labelBitmap.y = Config.MARGIN;
			textBitmap.y = labelBitmap.y + labelBitmap.height;
		}
		
		public function drawViewLang(label:String = ""):void {
			_label = label;
			drawLabel();
		}
		
		public function setValue(val:String = ""):void {
			_text = val;
			drawText();
		}
	}
}