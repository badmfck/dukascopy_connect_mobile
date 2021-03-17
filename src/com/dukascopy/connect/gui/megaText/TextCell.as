package com.dukascopy.connect.gui.megaText {
	
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Pavel Karpov Telefision TEAM Kiev.
	 */
	
	public class TextCell extends Sprite {
		
		static public const TAB_LEFT:String = "tab_left";
		static public const ALIGN_BOTTOM:String = "align_down";
		static public const COLOMN_LEFT:String = "colomn_left";
		private var labelBMP:Bitmap;
		private var valueBMP:Bitmap;
		private var labelSettings:Object;	//{ size:int, color:uint, text:String, ascent:int, tab:(TAB_RIGHT:TAB_RIGHT) }
		private var valueSettings:Object; 	//{ size:int, color:uint, complex:int, text:String, ascent:int }
		private var _colomn:Boolean = false;
		private var smallSize:int = 0;
		
		public function TextCell(txt:String, label:Object, info:Object) {
			var nm:String;
			valueSettings = info;
			valueBMP = new Bitmap();
			addChild(valueBMP);
			labelSettings = label;
			labelSettings.text = txt;
			labelBMP = new Bitmap();
			drawTextBMP(labelSettings, labelBMP);
			addChild(labelBMP);
		}
		
		public function setPositionLine(gap:int, useful:int, align:String):void {
			switch (align) {
				case TAB_LEFT: {
					labelBMP.y = -Math.round(labelBMP.height * .5);
					valueBMP.y = -Math.round(valueBMP.height * .5);
					labelBMP.x = 0;
					valueBMP.x = labelBMP.width + gap - valueBMP.width;
					break;
				}
				case ALIGN_BOTTOM: {
					if ((labelBMP.width + valueBMP.width + gap) > useful) {
						labelBMP.y = - labelBMP.height;
						valueBMP.y = 0;
						labelBMP.x = 0;
						valueBMP.x = Math.round((labelBMP.width - valueBMP.width) * .5);
						_colomn = true;
					} else {
						valueBMP.y = -Math.round(valueBMP.height * .5);
						labelBMP.y = valueBMP.y + Math.round(valueSettings.ascent - labelSettings.ascent);
						labelBMP.x = 0;
						valueBMP.x = labelBMP.width + gap;
					}
					break;
				}
				case COLOMN_LEFT: {
					labelBMP.y = - labelBMP.height;
					valueBMP.y = 0;
					labelBMP.x = 0;
					valueBMP.x = 0;
					_colomn = true;
					break;
				}
			}
		}
		
		private function drawValueBMP():void {
			var box:Sprite = new Sprite();
			var tfV:TextField;
			var tf1:TextField;
			var tf2:TextField;
			if (valueBMP.bitmapData != null) 
				valueBMP.bitmapData.dispose();
			if (valueSettings.complex == 0) {
				tfV = newTextField(valueSettings.text, valueSettings.size, valueSettings.color);
				box.addChild(tfV);
			} else {
				var aa:Array = Number(valueSettings.text).toFixed(2).split(".");
				tfV = newTextField(aa[0], valueSettings.size, valueSettings.color);
				box.addChild(tfV);
				if (Number(aa[1]) != 0) {
					tf1 = newTextField("." + aa[1], valueSettings.size *.5, valueSettings.color);
					tf1.x = tfV.width;
					tf1.y = tfV.y + tfV.getLineMetrics(0).descent - tf1.getLineMetrics(0).descent;
					tf2 = newTextField(" DUK+", Math.round(valueSettings.size * .7), valueSettings.color);
					tf2.alpha = .7;
					tf2.x = tf1.x + tf1.width;
					tf2.y = tfV.y + tfV.getLineMetrics(0).ascent - tf2.getLineMetrics(0).ascent;
					box.addChild(tf1);
					box.addChild(tf2);
				} else {
					tf1 = newTextField(" DUK+", Math.round(valueSettings.size * .7), valueSettings.color);
					tf1.y = tfV.y + tfV.getLineMetrics(0).ascent - tf1.getLineMetrics(0).ascent;
					tf1.alpha = .7;
					tf1.x = tfV.width
					box.addChild(tf1);
				}
			}
			valueSettings.ascent = tfV.getLineMetrics(0).ascent;
			valueBMP.bitmapData = new ImageBitmapData("TextCell_value" + "." + name, box.width, tfV.height);	
			valueBMP.bitmapData.draw(box);
		}
		
		public function dispose():void {
			labelSettings = null;
			valueSettings = null;
			if (parent != null)
				parent.removeChild(this);
				
			if (labelBMP != null) {
				removeChild(labelBMP);
				if (labelBMP.bitmapData != null)
					labelBMP.bitmapData.dispose();
				labelBMP = null;
			}
			
			if (valueBMP != null) {
				removeChild(valueBMP);
				if (valueBMP.bitmapData != null)
					valueBMP.bitmapData.dispose();
				valueBMP = null;
			}
		}
		
		public function cellTuning(info:Object, label:Object = null):void {
			var name:String;
			var text:String;
			if (info != null) {
				text = valueSettings.text;
				for (name in info) 
					valueSettings[name] = info[name];
				
				if (info.text != null && info.text != text)
					drawValueBMP();
			}
			if (label != null) {
				text = labelSettings.text;
				for (name in label) 
					labelSettings[name] = label[name];
					
				if (label.text != null && label.text != text)
					drawTextBMP(labelSettings, labelBMP);
			}
		}
		
		private function newTextField(text:String, size:int, color:uint,  ml:Boolean = false, align:String = TextFormatAlign.RIGHT):TextField {
			var tf:TextField = new TextField();
			tf.defaultTextFormat = new TextFormat("Tahoma", size, color, null, null, null, null, null, align);
			tf.selectable = false;
			tf.background = false;
			tf.multiline = ml;
			tf.autoSize = TextFieldAutoSize.LEFT;
			tf.text = text;
			tf.cacheAsBitmap = true;
			return tf;
		}
		
		private function drawTextBMP(settings:Object, canvas:Bitmap, ml:Boolean = false, align:String = TextFormatAlign.RIGHT):void {
			if (canvas.bitmapData != null)
				canvas.bitmapData.dispose();
			var tf:TextField = new TextField();
			tf.defaultTextFormat = new TextFormat("Tahoma", settings.size, settings.color, null, null, null, null, null, align);
			tf.multiline = ml;
			tf.autoSize = TextFieldAutoSize.LEFT;
			tf.text = settings.text;
			settings.ascent = tf.getLineMetrics(0).ascent;
			canvas.bitmapData = new ImageBitmapData("TextCell_label" + "." + name, tf.width, tf.height);
			canvas.bitmapData.draw(tf);
		}
		
		public function setMultilineForLabel():int {
			var st:String = labelSettings.text; 
			if (st.indexOf("\r") == -1 && st.indexOf(" ") > -1) {
				var ll:int = st.length * .5;
				var n1:int = -1;
				var n2:int = -1;
				do {
					n1 = n2 + 1;
					n2 = st.indexOf(" ", n1);
				} while (n2 > -1 && n2 < ll);
				if (n1 == 0) {
					labelSettings.text = st.slice(0, n2) + "\r" + st.slice(n2 + 1);
				} else if (n2 == -1) {
					labelSettings.text = st.slice(0, n1-1) + "\r" + st.slice(n1);
				} else if (Math.abs(ll - n1) < Math.abs(ll - n2)) {
					labelSettings.text = st.slice(0, n1 - 1) + "\r" + st.slice(n1);
				} else {
					labelSettings.text = st.slice(0, n2) + "\r" + st.slice(n2 + 1);
				}
				drawTextBMP(labelSettings, labelBMP, true);
			}
			return labelBMP.width;
		}
		
		public function setSmallSizeForValue(size:int):int {
			if (valueSettings.size != size) {
				valueSettings.size = size;
				drawTextBMP(valueSettings, valueBMP);
			}
			return valueBMP.width;
		}
		
		public function get infoComplex():int { return valueSettings.complex; }
		public function get valueWidth():int {	return valueBMP.width; }
		public function get labelWidth():int {	return labelBMP.width; }
		public function get isColomn():Boolean { return _colomn; }
	}
}