package com.dukascopy.connect.gui.label {
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.mobileClip.MobileClip;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.system.Capabilities;
	import flash.text.TextField;
	import flash.text.TextFormat;
	/**
	 * ...
	 * @author ...
	 */
	public class Label extends MobileClip {
		private static var ta:TextFormat;
		private var tf:TextField;
		private var src:Sprite;
		private var bmd:ImageBitmapData;
		private var _value:String;
		private var _width:int=100;
		public function Label(value:String = null) {
			if (ta == null) {
				var tfSize:int = Config.FINGER_SIZE_DOT_25;
				if (tfSize < 9)
					tfSize = 9;
				ta = new TextFormat(null, tfSize);
			}
				
			tf = new TextField();
			_view = new Sprite();
			src = new Sprite();
			src.addChild(tf);
			setValue(value);
		}
		
		public function setValue(value:String):void {
			if (value == _value)
				return;
			if (value != null)
				_value = value;
					else 
						_value = '';
				
			updateView();
		}
		
		private function updateView():void {
			tf.wordWrap = true;
			tf.defaultTextFormat = ta;
			tf.text = _value;
			tf.width = _width;
			
			var bmdW:int = _width;
			var bmdH:int = tf.textHeight+4;
			var createBMP:Boolean = bmd==null || bmd.isDisposed;
			if (createBMP == false) {
				// CHECK DIMM
				if (bmd.width != bmdW || bmd.height != bmdH)
					createBMP = true;
			}
			
			
			if(createBMP){
				if (bmd != null)
					bmd.dispose();
				bmd = new ImageBitmapData('label ' + _value, bmdW, bmdH, true, 0);
			}else {
				bmd.fillRect(bmd.rect, 0);
			}
			
			bmd.drawWithQuality(src, null, null, null, null, true, StageQuality.BEST);
			ImageManager.drawGraphicImage(_view.graphics, 0, 0, bmd.width, bmd.height, bmd, ImageManager.SCALE_NONE,((Capabilities.isDebugger)?0xFFCC00:0));
		}
		
		public function setWidth(w:int):void {
			_width = w;
			updateView();
		}
		
		public function get width():int {
			return _width;
		}
		public function get height():int {
			return bmd.height;
		}
		
		override public function dispose():void {
			super.dispose();
			if(tf!=null)
				tf.text = '';
			tf = null;
			if (src != null)
				src.graphics.clear();
			src = null;
			if (bmd != null)
				bmd.dispose();
			bmd = null;
			_value = null;
		}
		
	}

}