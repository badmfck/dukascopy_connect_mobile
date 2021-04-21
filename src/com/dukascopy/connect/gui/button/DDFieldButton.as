package com.dukascopy.connect.gui.button {
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.uiFactory.UIFactory;
	import com.dukascopy.langs.Lang;
	import flash.geom.ColorTransform;

	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.text.TextField;

	/**
	 * ...
	 * @author IgorBloom
	 */
	public class DDFieldButton extends BitmapButton {
		private var generatedBitmap:ImageBitmapData;
		private var _value:String = Lang.textChoose + "...";
		
		private var box:Sprite;
		private var tf:TextField;
		
		static private var arrowHeight:int;
		static private var arrowCathetus:int;
		
		private var w:int = 0;
		private var h:int = 0;
		private var arrowShow:Boolean;
		private var underlineColor:Number;
		
		public function DDFieldButton(callBack:Function, value:String = "", showArrow:Boolean = true, underlineColor:Number = NaN) {
			this._value = value;
			this.arrowShow = showArrow;
			
			
			if (!isNaN(underlineColor))
			{
				this.underlineColor = underlineColor;
			}
			else
			{
				this.underlineColor = Style.color(Style.CONTROL_INACTIVE);
			}
			
			updateDefaultLabel();
			
			super();
			
			setStandartButtonParams();
			setDownScale(1);
			usePreventOnDown = true;
			cancelOnVerticalMovement = true;
			tapCallback = callBack;
			
			box = new Sprite();
			tf = UIFactory.createTextField(FontSize.BODY);
			tf.textColor = Style.color(Style.COLOR_TEXT);
			if (showArrow == false)
			{
				tf.textColor = Style.color(Style.COLOR_SUBTITLE);
			}
			box.addChild(tf);
			setOverlay(HitZoneType.MENU_MIDDLE_ELEMENT);
		}
		
		public function invalid():void
		{
			UI.colorize(this, 0xCD3F43);
		}
		
		public function valid():void
		{
			transform.colorTransform = new ColorTransform();
		}
		
		public function get placeholder():String
		{
			return Lang.textChoose + "...";
		}
		
		public function updateDefaultLabel(str:String = ""):void {
			if (_value == "" || _value == null) {
				_value = Lang.textChoose + "...";
			}
			setSize(w, h);
		}
		
		public function setSize(w:int, h:int):void {
			if (w < 1 || h < 1)
				return;
			
			this.w = w;
			this.h = h;
			
			if (generatedBitmap != null) {
				if (generatedBitmap.height != h || generatedBitmap.width != w) {
					generatedBitmap.dispose();
					generatedBitmap = null;
				}
			}
			
			if (generatedBitmap == null) {
				generatedBitmap = new ImageBitmapData("DDFieldButton.generatedBitmap", w, h, true, 0);
			} else {
				generatedBitmap.fillRect(generatedBitmap.rect, 0);
			}
			
			/*box.graphics.clear();
			box.graphics.beginFill(AppTheme.GREY_SEMI_LIGHT);
			box.graphics.drawRect(0, 0, w, h);
			box.graphics.beginFill(0xFFFFFF, 1);
			box.graphics.drawRect(1, 1, w - 2, h - 2);*/
			
			var lineThickness:int = int(Math.max(1, Config.FINGER_SIZE * .03));
			box.graphics.clear();
				box.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND), 0);
				box.graphics.drawRect(1, 1, w, h);
				box.graphics.lineStyle(lineThickness, underlineColor);
				box.graphics.moveTo(0, h - lineThickness / 2);
				box.graphics.lineTo(w, h - lineThickness / 2);
				box.graphics.lineStyle();
			
			// arrow
			var xOffset:int = w;
			
			if (arrowShow == true) {
				arrowHeight = h * 0.15;
				arrowCathetus = h * 0.12;
				box.graphics.beginFill(Style.color(Style.COLOR_TEXT));
				box.graphics.moveTo(xOffset, int((h - arrowHeight) * .5));
				box.graphics.lineTo(xOffset - arrowCathetus, int((h + arrowHeight) * .5));
				box.graphics.lineTo(xOffset - arrowCathetus * 2, int((h - arrowHeight) * .5));
				box.graphics.lineTo(xOffset, int((h - arrowHeight) * .5));
				box.graphics.endFill();
			}
			
		//	tf.x = (w - xOffset);
			tf.x = 0;
			tf.text = _value;
			tf.width = int(w - arrowHeight*2 - Config.DIALOG_MARGIN - Config.MARGIN);
			tf.y = (h - tf.height) * .5;
			
			generatedBitmap.drawWithQuality(box, null, null, null, null, true, StageQuality.BEST);
			
			setBitmapData(generatedBitmap);
		}
		
		/**
		 *
		 * @param value set null for set default value // Choosing...
		 */
		public function setValue(value:String = null):void {
			if (value == null || value == "") {			// Ljoha, pochemu zakomentiroval etu proverku? )))	-> ne pomny(, :)
				this._value = "";
				updateDefaultLabel();
			} else {
				if (Lang[value] != null)
				{
					value = Lang[value];
				}
				this._value = value;
				setSize(w, h);
			}
		}
		
		override public function dispose():void {
			UI.safeRemoveChild(tf);
			tf = null;
			if (box != null) {
				box.graphics.clear();
				box = null;
			}
			if (generatedBitmap != null) {
				generatedBitmap.dispose();
				generatedBitmap = null;
			}
			super.dispose();
		}
		
		public function get value():String {
			return _value;
		}
	}
}