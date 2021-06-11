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
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.geom.ColorTransform;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	import flash.text.TextLineMetrics;

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
		private var titleClip:Bitmap;

		static private var arrowHeight:int;
		static private var arrowCathetus:int;
		
		private var w:int = 0;
		private var h:int = 0;
		private var arrowShow:Boolean;
		private var underlineColor:Number;
		private var title:String;
		private var container:Sprite;
		private var selectedData:Object;
		private var icon:Bitmap;
		private var innerHeight:int;
		private var lineThickness:int;

		public function DDFieldButton(callBack:Function, value:String = "", showArrow:Boolean = true, underlineColor:Number = NaN, title:String = null, fontSize:Number = NaN) {
			this._value = value;
			this.arrowShow = showArrow;
			this.title = title;
			if (isNaN(fontSize))
			{
				fontSize = FontSize.BODY;
			}
			
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
			
			container = new Sprite();
			titleClip = new Bitmap();
			
			box = new Sprite();
			tf = UIFactory.createTextField(fontSize);
			tf.textColor = Style.color(Style.COLOR_TEXT);
			if (showArrow == false)
			{
				tf.textColor = Style.color(Style.COLOR_SUBTITLE);
			}
			box.addChild(tf);
			setOverlay(HitZoneType.MENU_MIDDLE_ELEMENT);
			
			if (title != null)
			{
				drawTitle(title);
			}
			
			container.addChild(titleClip);
			container.addChild(box);
		}
		
		private function createIcon(iconClip:Sprite):void 
		{
			if (iconClip != null)
			{
				var iconSize:int = Config.FINGER_SIZE * .5;
				UI.scaleToFit(iconClip, iconSize, iconSize);
				if (icon == null)
				{
					icon = new Bitmap();
					box.addChild(icon);
				}
				if (icon.bitmapData != null)
				{
					icon.bitmapData.dispose();
					icon.bitmapData = null;
				}
				icon.bitmapData = UI.getSnapshot(iconClip);
			}
		}
		
		private function drawTitle(value:String):void
		{
			if (titleClip.bitmapData)
			{
				titleClip.bitmapData.dispose();
				titleClip.bitmapData = null;
			}
			if (value != null)
			{
				titleClip.bitmapData = TextUtils.createTextFieldData(value, Config.FINGER_SIZE * 3, 10,
																false, TextFormatAlign.LEFT,
																TextFieldAutoSize.LEFT,
																FontSize.SUBHEAD,
																false, Style.color(Style.COLOR_SUBTITLE), Style.color(Style.COLOR_BUTTON_RED_DOWN), false, true);
			}
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
				_value = getDefaultlabel();
			}
			setSize(w, h);
		}
		
		public function getDefaultlabel():String
		{
			return Lang.textChoose + "...";
		}

		public function setSize(w:int, h:int):void {
			if (w < 1 || h < 1)
				return;
			
			this.w = w;
			this.h = h;
			
			lineThickness = int(Math.max(1, Config.FINGER_SIZE * .03));

			if (generatedBitmap != null) {
				if (generatedBitmap.height != h || generatedBitmap.width != w) {
					generatedBitmap.dispose();
					generatedBitmap = null;
				}
			}
			
			tf.x = 0;
			tf.text = _value;
			tf.width = int(w - arrowHeight * 2 - Config.MARGIN);
			if (icon != null && icon.width > 0)
			{
				tf.x = int(icon.x + icon.width + Config.FINGER_SIZE * .15);
				icon.y = int(tf.y + tf.height * .5 - icon.height * .5);
				tf.width -= icon.x + icon.width - Config.FINGER_SIZE * .15;
			}
			
			var resultheight:int = h;
			innerHeight = h;
			if (titleClip.height > 0)
			{
				box.y = int(FontSize.SUBHEAD - Config.FINGER_SIZE * .1);
				tf.y = Math.round((h - tf.height) * .5);

				resultheight = box.y + h - Config.FINGER_SIZE * .1 + lineThickness;
				innerHeight = h - Config.FINGER_SIZE * .1;
			}
			else
			{
				resultheight = h;
				innerHeight = h;
				tf.y = (h - tf.height) * .5;
			}

			box.graphics.clear();
				box.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND), 0);
				box.graphics.drawRect(1, 1, w, h);
				box.graphics.endFill();
			//	box.graphics.lineStyle(lineThickness, underlineColor);

				box.graphics.beginFill(underlineColor);
				box.graphics.drawRect(0, innerHeight - lineThickness, w, lineThickness);
				box.graphics.endFill();
			//	box.graphics.lineTo(w, innerHeight - lineThickness / 2);
			//	box.graphics.lineStyle();
			
			// arrow
			var xOffset:int = w;
			
			if (arrowShow == true) {
				arrowHeight = Config.FINGER_SIZE * .8 * 0.15;
				arrowCathetus = Config.FINGER_SIZE * .8 * 0.12;
				box.graphics.beginFill(Style.color(Style.COLOR_SUBTITLE));
				box.graphics.moveTo(xOffset, int((innerHeight - arrowHeight) * .5));
				box.graphics.lineTo(xOffset - arrowCathetus, int((innerHeight + arrowHeight) * .5));
				box.graphics.lineTo(xOffset - arrowCathetus * 2, int((innerHeight - arrowHeight) * .5));
				box.graphics.lineTo(xOffset, int((innerHeight - arrowHeight) * .5));
				box.graphics.endFill();
			}
			
			if (generatedBitmap == null) {
				generatedBitmap = new ImageBitmapData("DDFieldButton.generatedBitmap", w, resultheight, true, 0);
			} else {
				generatedBitmap.fillRect(generatedBitmap.rect, 0);
			}
			
			generatedBitmap.drawWithQuality(container, null, null, null, null, true, StageQuality.BEST);
			setBitmapData(generatedBitmap);
		}
		
		/**
		 *
		 * @param value set null for set default value // Choosing...
		 */
		public function setValue(value:String = null, clearIcon:Boolean = true):void {
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
			if (clearIcon)
			{
				clearIconFun();
			}
			
			selectedData = null;
		}
		
		private function clearIconFun():void 
		{
			if (icon != null)
			{
				if (icon.bitmapData != null)
				{
					icon.bitmapData.dispose();
					icon.bitmapData = null;
				}
				if (box != null && box.contains(icon))
				{
					try
					{
						box.removeChild(icon);
					}
					catch (e:Error)
					{
						
					}
					icon = null;
				}
			}
		}
		
		public function setValueExtend(value:String = null, data:Object = null, iconClip:Sprite = null):void {
			if (iconClip != null)
			{
				createIcon(iconClip);
			}
			setValue(value, iconClip == true);
			selectedData = data;
		}
		
		override public function dispose():void {
			UI.safeRemoveChild(tf);
			tf = null;
			selectedData = null;
			
			if (box != null) {
				box.graphics.clear();
				box = null;
			}
			if (titleClip != null)
			{
				UI.destroy(titleClip);
				titleClip = null;
			}
			if (container != null)
			{
				UI.destroy(container);
				container = null;
			}
			if (icon != null)
			{
				UI.destroy(icon);
				icon = null;
			}
			if (generatedBitmap != null) {
				generatedBitmap.dispose();
				generatedBitmap = null;
			}
			super.dispose();
		}
		
		public function linePosition():int 
		{
			return innerHeight - lineThickness;
		}
		
		public function getFieldHeight():int 
		{
			var line:TextLineMetrics = tf.getLineMetrics(0);
			return line.ascent + 2;
		}
		
		public function getFieldPosition():int 
		{
			return tf.y + box.y + 1;
		}
		
		public function get value():String {
			return _value;
		}
	}
}