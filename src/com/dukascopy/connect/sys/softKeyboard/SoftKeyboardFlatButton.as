package com.dukascopy.connect.sys.softKeyboard 
{
	import com.adobe.protocols.dict.Database;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.IBitmapDrawable;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author IgorBloom
	 */
	public class SoftKeyboardFlatButton extends Sprite {
				
		private var mainTF:TextField;
		private var additionalText:TextField;
		private static var format:TextFormat = new TextFormat('Tahoma', null,0,null,null,null,null,null,TextFormatAlign.CENTER);
		private static var format2:TextFormat = new TextFormat('Tahoma',null,0,null,null,null,null,null,TextFormatAlign.CENTER);
		private var bmp:Bitmap;
		public function SoftKeyboardFlatButton() {
			
			mainTF = new TextField();
			addChild(mainTF);
			
			additionalText = new TextField();
			addChild(additionalText);
		}
		
		public function getView(w:int, h:int, data:Object,sys:Boolean=false):IBitmapDrawable {
			
			format.size = h * .4;
			format.font = 'Helvetica-2-UltraLight';
			format2.size = h * .2;
			format2.font = 'Helvetica-2-UltraLight';
			graphics.clear();
			
			// udaljaem v prowlom dobavlenij bitmap 
			if (bmp != null) {
				if (bmp.parent != null)
					bmp.parent.removeChild(bmp);
				if (bmp.bitmapData != null) {
					bmp.bitmapData.dispose();
					bmp.bitmapData = null;
				}
			}
			
			mainTF.width = w;
			additionalText.width = w;
			
			// SET POSITIONS
			mainTF.defaultTextFormat = format;
			additionalText.defaultTextFormat = format2;
			mainTF.text = '`Pp_';
			additionalText.text = '`Pp_';
			mainTF.y = Math.round((h - (mainTF.textHeight + 4 + additionalText.textHeight + 4)) * .5);
			additionalText.y = mainTF.y + mainTF.textHeight + 4;
			mainTF.text = '';
			additionalText.text = '';
			additionalText.alpha = .7;
			
			var addKey:String = '';
			var key:String = '';
			if (data is Array){
				key = data[0];
				addKey = data[1];
			}else if (data is Number) {
				key = Number(data).toString();
				if (data == SoftKeyboard.BACKSPACE){
					key = '';
					sys = true;
					bmp = new SoftKeyboard.ASSET_ICON_BACKSPACE();
					bmp.smoothing = true;
					var bh:int = h * .8;
					bmp.width = (bmp.width * bh) / bmp.height;
					bmp.height = bh;
					bmp.x = Math.round((w - bmp.width) * .5);
					bmp.y = Math.round((h - bmp.height) * .5);
					bmp.alpha = .7;
					addChild(bmp);
				}
				if (data == SoftKeyboard.DONE){
					key = 'DONE';
					sys = true;
				}
				if (data == SoftKeyboard.ZERO){
					key = '0';
					sys = true;
				}
				
			}else {
				key = data as String;
			}
			
			
			if (key == null)
				key = '---';
				
			if (addKey == null)
				addKey = '';
				
			mainTF.text = key
			additionalText.text = addKey;
			
			if (sys == true) {
				if(data != SoftKeyboard.ZERO) {
					graphics.beginFill(0xE6E6E6);
					graphics.drawRect(0, 1,w-1,h-1);
					graphics.endFill();
				}
				else{
					graphics.beginFill(0xFFFFFF);
					graphics.drawRect(0, 0, w, h);
					graphics.endFill();
				}
				graphics.beginFill(0xCCCCCC);
				graphics.drawRect(0, h - 1, w, 1);
				graphics.endFill();
				
				mainTF.y = Math.round((h - mainTF.textHeight) * .5);
			}
			else {
				graphics.beginFill(0xFFFFFF);
				graphics.drawRect(0, 0, w, h);
				graphics.endFill();
			}
			
			graphics.beginFill(0xCCCCCC);
			graphics.drawRect(0, 0, w, 1);
			graphics.endFill();
			
			graphics.beginFill(0xCCCCCC);
			graphics.drawRect(w - 1, 1, 1, h-1);
			graphics.endFill();
			
			return this;
		}
		
		public function dispose():void {
			if (bmp != null && bmp.bitmapData != null) {
				bmp.bitmapData.dispose();
				bmp.bitmapData = null;
			}
			graphics.clear();
			if(mainTF!=null)
				mainTF.text = '';
			if(additionalText!=null)
				additionalText.text = '';
			mainTF = null;
			additionalText = null;
		}
		
	}

}