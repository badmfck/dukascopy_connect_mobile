package com.dukascopy.connect.gui.tabs
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.mobileClip.MobileClip;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	/**
	 * ...
	 * @author ...
	 */
	public class TabsItem extends MobileClip implements ITabsItem {
		private var _id:String;
		private var _name:String;
		private var _selection:Boolean = false;
		private var _num:int = 0;

		// STAMP
		static private var src:Sprite;
		static protected var tf:TextField;
		static protected var ta:TextFormat;
		static private var m:Matrix;

		static protected var margin:int = Config.FINGER_SIZE_DOT_5;
		private var _shiftMargin:Number = 0;

		private var bmp:ImageBitmapData;
		private var _icon:ImageBitmapData;
		private var _clr:uint;
		private var _bg:ImageBitmapData;
		private var bgAlpha:Number;
		private var textColor:uint;
		private var _doSelection:Boolean;

		public function TabsItem(name:String, id:String, num:int,icon:ImageBitmapData = null, bg:ImageBitmapData=null,clr:uint=0xFFFFFF,bgAlpha:Number=1,textColor:uint=0,doSelection:Boolean=true){
			_doSelection = doSelection;
			this.textColor = textColor;
			this.bgAlpha = bgAlpha;
			_bg = bg;
			_clr = clr;
			_icon = icon;
			_id = id;
			_name = name;
			_num=num;
			createView();
		}

		private function createView():void {
			if (tf == null) {
				tf = new TextField();
				var fontSize:int = Config.FINGER_SIZE * .22;
				if (fontSize < 9)
					fontSize = 9;
				if (ta == null)
					ta = new TextFormat("Tahoma",fontSize);
				tf.defaultTextFormat = ta;
				tf.autoSize = TextFieldAutoSize.LEFT;
				tf.textColor = textColor;
				if(src==null)
					src = new Sprite();
				src.addChild(tf);
			}

			_view = new Sprite();
			rebuild(Config.FINGER_SIZE);
		}

		public function rebuild(height:int):void {
			if (tf == null)
				return;
			if (height < 0)
				height = 1;
			if (_name != null){
				tf.text = _name;
				tf.visible = true;
			} else {
				tf.visible = false;
			}

			var w:int = getWidthTF();
			var h:int = height;

			if (_name == null)
			{
				w = Config.FINGER_SIZE*.6+getMargin()*2;
			}
			tf.width = tf.textWidth;
			tf.x = getMargin();
		//	if(tf.y == 0)
				tf.y = Math.round((height - (tf.textHeight + 4)) * .5);
			src.graphics.clear();
			src.graphics.beginFill(_clr, bgAlpha);
			src.graphics.drawRect(0, 0, w, h);

			if (_icon) {
				var btnS:int = h * .6;
				var x:int = (w - btnS) * .5;
				var y:int = (h - btnS) * .5;
				if (_icon.isDisposed == false)
					ImageManager.drawGraphicImage(src.graphics, x, y,btnS, btnS, _icon, ImageManager.SCALE_INNER_PROP);
			}

			if (bmp == null || bmp.height != h || bmp.width != w) {
				if (bmp != null)
					bmp.dispose();
				bmp = new ImageBitmapData("TabsItem."+id, w, h);
			} else {
				bmp.fillRect(bmp.rect, 0);
			}

			tf.textColor = textColor;
			//tf.width = tf.textWidth;
			bmp.draw(src);
			_view.graphics.clear();
			_view.graphics.beginBitmapFill(bmp, null, false, true);
			_view.graphics.drawRect(0, 0, w, h);

		}

		protected function getMargin():Number {
			var result:Number = margin + shiftMargin;
			return result >= 0 ? result : 0;
		}

		protected function getWidthTF():Number{
			return tf.textWidth + 4 + getMargin() * 2;
//			return tf.textWidth /*+ 4*/ + margin /* 2*/;
		}

		override public function dispose():void {
			_id = null;
			_name = null;
			_selection = false;
			_num = 0;
			_bg = null;

			// STAMP
			if (src != null)
				src.graphics.clear();

			src = null;

			if (tf != null)
				tf.text = '';
			tf = null;

			ta = null;
			if (bmp != null)
				bmp.dispose();
			bmp = null;

			if (_icon != null)
				_icon.dispose();
			_icon = null;
			super.dispose();
		}

		public function get id():String{
			return _id;
		}

		public function get selection():Boolean{
			return _selection;
		}

		public function get num():int {
			return _num;
		}

		public function get bg():ImageBitmapData{
			return _bg;
		}

		public function get doSelection():Boolean {
			return _doSelection;
		}

		public function setSelection(val:Boolean):void {
			_selection = val;
		}

		public function cutByLeft( cutWidth:Number):void {

		}

		public function get shiftMargin():Number {
			return _shiftMargin;
		}

		public function set shiftMargin(value:Number):void {
			if(value < 0 && margin < -1*value){
				_shiftMargin = -1*margin;
			}else{
				_shiftMargin = value;
			}
		}
	}
}