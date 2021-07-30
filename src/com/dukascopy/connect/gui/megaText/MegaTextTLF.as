package com.dukascopy.connect.gui.megaText {
	
	import adobe.utils.ProductManager;
	import com.adobe.utils.IntUtil;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.networkIndicator.NetworkIndicator;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.richTextField.RichTextSmilesCodes;
	import com.mteamapp.UnicodeStatic;
	import fl.text.TLFTextField;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author IgorBloom
	 */
	
	public class MegaTextTLF extends Sprite {
		
		private var textField:TLFTextField;
		private var defaultFormat:TextFormat;
		private var _width:int = 100;
		private var wasRendered:Boolean = false;
		private var trueCodes/*StockItem*/:Array=[];
		private var textHeight:Number = 0;
		private var smilesFound:Boolean = false;
		private var disposed:Boolean=false;
		
		public function MegaTextTLF(border:Boolean = false) {
			textField = new TLFTextField();
			textField.border = border;
			defaultFormat = new TextFormat(Config.defaultFontName, 12, 0x0);
			textField.selectable = false;
			textField.multiline = true;
			textField.wordWrap = true;
			textField.mouseEnabled = false;
			textField.autoSize = TextFieldAutoSize.LEFT;
			mouseEnabled = false;
			mouseChildren = false;
			addChild(textField);
		}
		
		public function getArray():Array {
			return trueCodes;
		}
		
		public function getMaxWidth():int
		{
			return _width;
		}
		
		public function setText(width:int, 
								txt:String, 
								color:uint = 0, 
								size:int = 12, 
								smileColor:String = "#FFFFFF", 
								smileSize:Number = 1.5,
								wasSmile:int = 0):int {
			if (disposed == true) {
				return 0;
			}
			clear();
			defaultFormat.size = size;
			defaultFormat.color = color;
			//textField.defaultTextFormat = defaultFormat;
			
			setWidth(width);
			
			if (wasSmile == 1) {
			
				textField.text = txt;
				textField.setTextFormat(defaultFormat);
				return textField.height;
			}
			smileSize = Math.round(size * smileSize);
			// do text parse
			var l:int = txt.length;
			var res:String = "";
			var tflength:int = 0;
			if (txt == ':))')
				echo("MegaText", "setText", "Problem! txt: " + txt);
			for (var n:int = 0; n < l; n++) {
				var smile:Boolean = false;
				var code:int = txt.charCodeAt(n);
				var smileBmp:Bitmap = null;
				if (code==55356 || code == 55357 || code==55358){
					code = (code - 0xD800) * 0x400 + txt.charCodeAt(n + 1) - 0xDC00 + 0x10000;
					smile = true;
					n++;
				}
				if (smile == false){
					smile = RichTextSmilesCodes.checkSmile(code);
					if (smile == true && txt.charCodeAt(n + 1) == 65039)
						n++;
				}
				tflength++;
				var cRect:Rectangle = null;
				if (smile == true) {
					smilesFound = true;
					res += "<font size='"+smileSize+"' color='"+smileColor+"'>—</FONT>";
				} else {
					res += txt.charAt(n);
				}
				trueCodes.push(new StockItem(code, code.toString(16), smile, null));
			}
			if (smilesFound) {
				textField.setTextFormat(defaultFormat);
				textField.htmlText = "<FONT FACE=\"" + defaultFormat.font + "\" SIZE=\"" + defaultFormat.size + "\" COLOR=\"#" + color.toString(16) + "\" LETTERSPACING=\"0\" KERNING=\"0\">" + res + "</FONT>";
			} else {
				textField.text = res;
				textField.setTextFormat(defaultFormat);
			}
			return textField.height;
		}
		
		private function clear():void {
			if (disposed == true)
				return;
			if (trueCodes == null || trueCodes.length == 0)
				return;
			var l:int = trueCodes.length;
			for (var n:int = 0; n < l; n++) {
				var si:StockItem = trueCodes[n];
				if (si.smileBmp != null && si.smileBmp.parent != null)
					si.smileBmp.parent.removeChild(si.smileBmp);
				si.smileBmp = null;
				si.hexCode = '';
				si.charCode = 0;
				si.smile = false;
			}
			wasRendered = false;
			smilesFound = false;
			trueCodes = [];
		}
		
		public function dispose():void {
			if (disposed == true)
				return;
			disposed = true;
			clear();
			trueCodes = null;
			textField.text = "";
			defaultFormat = null;
			_width = 0;
			if (parent != null)
				parent.removeChild(this);
			wasRendered = false;
			textHeight = 0;
			smilesFound = false;
		}
		
		public function render():void {
			if (disposed == true)
				return;
			if (wasRendered == true || smilesFound == false)
				return;
			var wasMovedToStage:Boolean = false;
			if (this.stage == null) {
				var ppar:DisplayObjectContainer = parent;
				var pvis:Boolean = visible;
				var px:Number = x;
				var py:Number = y;
				MobileGui.stage.addChild(this);
				wasMovedToStage = true;
			}
			wasRendered = true;
			var l:int = trueCodes.length;
			var tflength:int = 0;
			x = -_width;
			y = 0;
			visible = false;
			for (var n:int = 0; n < l; n++) {
				tflength++;
				var si:StockItem = trueCodes[n];
				if (si.smile == true) {
					var cRect:Rectangle = textField.getCharBoundaries(tflength - 1);
					if (cRect != null) {
						if (si.smileBmp == null)
							si.smileBmp = addChild(new Bitmap(RichTextSmilesCodes.getSmileByCode(si.hexCode), "auto", true)) as Bitmap;
						si.smileBmp.x = cRect.x;
						si.smileBmp.width = cRect.width;
						si.smileBmp.height = cRect.width;
						si.smileBmp.y = cRect.y + ((cRect.height - cRect.width) * .5);
					}
				}
			}
			if (wasMovedToStage == true) {
				if (ppar != null) {
					ppar.addChild(this);
				} else {
					if (this.parent != null)
						this.parent.removeChild(this);
				}
				x = px;
				y = py;
				visible = pvis;
				ppar = null;
			}
		}
		
		public function getTextField():TLFTextField {
			return textField;
		}
		
		public function getWasSmile():Boolean {
			return smilesFound;
		}
		
		private function checkSmileRange(code:int):Boolean {
			return true;
		}
		
		private function setWidth(width:int):void {
			if (_width == width)
				return;
			_width = width;
			textField.width = _width;
		}
		
		public function get tfTextWidth():Number {
			return textField.textWidth;
		}
		public function get tfWidth():Number {
			return textField.width;
		}
	}
}

import com.dukascopy.connect.utils.Debug.BloomDebugger;
import flash.display.Bitmap;
import flash.geom.Rectangle;


class StockItem {
	
	public var smileBmp:Bitmap;
	public var smile:Boolean;
	public var hexCode:String;
	public var charCode:int;

	public function StockItem(charCode:int, hexCode:String, smile:Boolean, smileBmp:Bitmap) {
		this.smileBmp = smileBmp;
		this.smile = smile;
		this.hexCode = hexCode;
		this.charCode = charCode;
	}
}