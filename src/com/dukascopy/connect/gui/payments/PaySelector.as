package com.dukascopy.connect.gui.payments {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.langs.Lang;

	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision AG.
	 */
	
	public class PaySelector extends Sprite {
		
		private var _onlyBottomBorder:Boolean;
		private var _noBorder:Boolean;
		private var _noBG:Boolean;
		private var _enabled:Boolean = true;
		
		protected var birdColor:uint = 0;
		
		static protected var itemHeight:int = Config.FINGER_SIZE * 0.8;
		static protected var arrowHeight:int = itemHeight * 0.15;
		static protected var arrowCathetus:int = itemHeight * 0.12;
		
		protected var tfLabel:TextField;
		
		protected var defaultFormat:TextFormat;
		protected var defaultText:String = "";
		
		protected var w:int;
		protected var h:int = itemHeight;
		
		public function PaySelector() {
			super();
			
			defaultFormat = new TextFormat("Tahoma", itemHeight * .7 - Config.MARGIN * 2);
			updateDefaultLabel();

			tfLabel = new TextField();
			tfLabel.autoSize = TextFieldAutoSize.LEFT;
			tfLabel.defaultTextFormat = defaultFormat;
			tfLabel.text = defaultText;
			tfLabel.multiline = false;
			tfLabel.wordWrap = false;
			tfLabel.x = Config.DOUBLE_MARGIN;
			
			addChild(tfLabel);
		}

		public function updateDefaultLabel():void {
			defaultText  = Lang.textChoose +"...";
			if (tfLabel != null)
			{
				tfLabel.text = defaultText;
				drawView();
			}
		}
		
		override public function get width():Number { return w; }
		override public function set width(value:Number):void {
			w = value;
			if (h == 0)
				return;
			drawView();
		}
		
		override public function get height():Number { return h; }
		override public function set height(value:Number):void {
			h = value;
			if (w == 0)
				return;
			drawView();
		}
		
		private function drawView():void {
			graphics.clear();

			if (_noBorder == true) {
				if (_noBG == true)
					graphics.beginFill(0, 0);
				else
					graphics.beginFill(0xFFFFFF);
				graphics.drawRect(0, 0, w, h);
			} else {
				if (_onlyBottomBorder) {
					if (_noBG == true)
						graphics.beginFill(0, 0);
					else
						graphics.beginFill(0xFFFFFF);
					graphics.drawRect(0, 0, w, h - 1);
					graphics.beginFill(AppTheme.GREY_SEMI_LIGHT);
					graphics.drawRect(0, h - 1, w, 1);
				} else {
					graphics.beginFill(AppTheme.GREY_SEMI_LIGHT);
					graphics.drawRect(0, 0, w, h);
					if (_noBG == true) {
						graphics.drawRect(1, 1, w - 2, h - 2);
						graphics.beginFill(0, 0);
						graphics.drawRect(1, 1, w - 2, h - 2);
					} else {
						graphics.beginFill(0xFFFFFF);
						graphics.drawRect(1, 1, w - 2, h - 2);
					}
				}
			}
			
			graphics.beginFill(birdColor);
			graphics.moveTo(w - Config.DOUBLE_MARGIN, int((itemHeight - arrowHeight) * .5));
			graphics.lineTo(w - Config.DOUBLE_MARGIN - arrowCathetus, int((itemHeight + arrowHeight) * .5));
			graphics.lineTo(w - Config.DOUBLE_MARGIN - arrowCathetus * 2, int((itemHeight - arrowHeight) * .5));
			graphics.lineTo(w - Config.DOUBLE_MARGIN, int((itemHeight - arrowHeight) * .5));
			graphics.endFill();
			
			positionateTFs();
		}
		
		protected function positionateTFs():void {
			if(tfLabel != null)
			{
				tfLabel.width = w - tfLabel.x - Config.DOUBLE_MARGIN;
				tfLabel.y = int((h - tfLabel.height) * .5);
			}
		}
		
		public function setData(data:Object = null):void {
			if (data == null)
				tfLabel.text = defaultText;
			else
				tfLabel.text = String(data);
			positionateTFs();
		}
		
		public function update():void {
			
		}
		
		public function disable():void {
			_enabled = false;
			tfLabel.textColor = 0x999999;
			birdColor = AppTheme.GREY_MEDIUM;
			drawView();
		}
		
		public function enable():void {
			_enabled = true;
			tfLabel.textColor = 0;
			birdColor = 0;
			drawView();
		}
		
		public function dispose():void {
			graphics.clear();
			if (tfLabel != null)
				tfLabel.text = "";
			tfLabel = null;
			defaultFormat = null;
			defaultText = "";
		}
		
		public function set onlyBottomBorder(val:Boolean):void {
			_onlyBottomBorder = val;
		}
		
		public function set noBorder(val:Boolean):void {
			_noBorder = val;
		}
		
		public function set noBG(val:Boolean):void {
			_noBG = val;
		}
		
		public function get enabled():Boolean {
			return _enabled;
		}
	}
}