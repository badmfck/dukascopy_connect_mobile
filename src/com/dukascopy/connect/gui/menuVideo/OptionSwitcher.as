package com.dukascopy.connect.gui.menuVideo {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.preloader.Preloader;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.langs.Lang;
	import com.telefision.sys.signals.Signal;
	import fl.motion.Color;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;

	/**
	 * ...
	 * @author Alexey
	 */
	
	public class OptionSwitcher extends Sprite {
		
		static public var S_CLICK:Signal = new Signal("OptionSwitcher.S_CLICK");
		
		static private var instanceCount:int = 0;
		
		static private var TOGGLER_BMD:ImageBitmapData;
		static private var TOGGLERBG_BMD:ImageBitmapData;
		
		protected var _isDisposed:Boolean = false;
		protected var _isCreated:Boolean = false;
		
		public var toggler:BitmapToggleSwitch;
		protected var iconBitmap:Bitmap;
		protected var textBitmap:Bitmap;
		
		protected var MIN_ICON_WIDTH:int = Config.FINGER_SIZE * .6;
		protected var COMPONENT_WIDTH:int = Config.FINGER_SIZE * 1.2;
		protected var FONT_SIZE:Number = Config.FINGER_SIZE * .34;
		
		protected var _labelText:String = "";
		protected var _viewWidth:int = 340;
		protected var _viewHeight:int = Config.FINGER_SIZE;
		protected var _iconBmd:BitmapData;
		protected var _isSelected:Boolean = false;
		protected var _expand:Boolean = true;
		protected var _isLoading:Boolean;
		
		public var onSwitchCallback:Function;
		
		private var _textColor:int = AppTheme.GREY_DARK;
		private var preloader:Preloader;
		private var paddingValue:int;
		
		public function OptionSwitcher() {
			instanceCount++;
			var icon:Sprite = new SWFToggleBg2();
			UI.colorize(icon, Style.color(Style.TOGGLER_UNSELECTED));
			TOGGLERBG_BMD ||= UI.renderAssetExtended(icon, int(Config.FINGER_SIZE * .6), int(Config.FINGER_SIZE * .4), true, "OptionSwitcher.TOGGLERBG_BMD");
			icon = new SWFToggler();
			UI.colorize(icon, Style.color(Style.COLOR_TOGGLER));
			TOGGLER_BMD ||= UI.renderAssetExtended(icon, int(Config.FINGER_SIZE * .38), int(Config.FINGER_SIZE * .38), true, "OptionSwitcher.TOGGLER_BMD");
			paddingValue = Config.DOUBLE_MARGIN;
		}
		
		public function create(w:int , h:int, iconBitmapData:BitmapData = null, labelText:String = "",  
								selected:Boolean = false, expand:Boolean = true, textColor:int = -1, fontSize:Number = NaN, padding:Number = NaN):void {
			if (textColor !=-1)
				_textColor = textColor;
			if (labelText == "")
				labelText = Lang.noLabbel;
			_labelText = labelText;
			_viewHeight = h;
			_viewWidth = w;
			_isSelected = selected;
			_iconBmd = iconBitmapData;
			_expand = expand;
			
			if (!isNaN(padding))
			{
				paddingValue = padding;
			}
			
			if (_iconBmd != null && iconBitmap == null) {
				iconBitmap = new Bitmap();
				iconBitmap.bitmapData = _iconBmd;
				addChild(iconBitmap);
			}
			
			if (textBitmap == null) {
				textBitmap = new Bitmap();
				addChild(textBitmap);
			}
			
			if (!isNaN(fontSize))
			{
				FONT_SIZE = fontSize;
			}
			
			if (toggler == null) {
				toggler = new BitmapToggleSwitch();
				toggler.setDownScale(1);
				toggler.setDownColor(0x000000);
				toggler.setOverflow(5, Config.FINGER_SIZE_DOT_25, Config.FINGER_SIZE_DOT_25, 5);
				toggler.show(0);
				if (TOGGLERBG_BMD.isDisposed)
				{
					var icon:Sprite = new SWFToggleBg2();
					UI.colorize(icon, Style.color(Style.TOGGLER_UNSELECTED));
					TOGGLERBG_BMD = UI.renderAsset(icon, int(Config.FINGER_SIZE * .6), int(Config.FINGER_SIZE * .4));
				}
				if (TOGGLER_BMD.isDisposed)
				{
					icon = new SWFToggler();
					UI.colorize(icon, Style.color(Style.COLOR_TOGGLER));
					TOGGLER_BMD ||= UI.renderAsset(icon, int(Config.FINGER_SIZE * .38), int(Config.FINGER_SIZE * .38));
				}
				toggler.setDesignBitmapDatas(TOGGLERBG_BMD, TOGGLER_BMD, true);
				toggler.setOverflow(Config.FINGER_SIZE*.2, Config.FINGER_SIZE*.2,Config.FINGER_SIZE*.2, Config.FINGER_SIZE*.2);
				toggler.isSelected = selected;
				toggler.tapCallback = onTogglerTap;
				toggler.disposeBitmapOnDestroy = false;// because we dispose commonly used bitmap data, it can break switcher inside other screen with same assset reference (static asset)
				addChild(toggler);
			}
			
			updateViewPort();
			updateSelection();
			
			_isCreated = true;
		}
		
		private function onTogglerTap():void {
			S_CLICK.invoke(_labelText);
			if (onSwitchCallback != null) {
				onSwitchCallback(toggler.isSelected);
				_isSelected = toggler.isSelected;
			}
		}
		
		public function activate():void {
			if (toggler != null)
				toggler.activate();
		}
		
		public function deactivate():void {
			if (toggler != null)
				toggler.deactivate();
		}
		
		protected function updateViewPort():void {
			if (_isDisposed)
				return;
			if (_viewWidth < Config.FINGER_SIZE_DOUBLE)
				return;
			if (iconBitmap != null) {
				iconBitmap.y = (_viewHeight - iconBitmap.height ) * .5;
				iconBitmap.x = paddingValue;
			}
			if (_labelText == "")
				_labelText = Lang.noText;
			if (textBitmap != null) {
				var textX:int = paddingValue;
				if (iconBitmap != null && iconBitmap.bitmapData != null)
					textX = int(Config.FINGER_SIZE * .8);
				var textWidth:int = _viewWidth - textX - COMPONENT_WIDTH;
				
				UI.disposeBMD(textBitmap.bitmapData);
				textBitmap.bitmapData = null;
				textBitmap.bitmapData = UI.renderText(
					_labelText,
					textWidth,
					_viewHeight,
					true,
					TextFormatAlign.LEFT,
					TextFieldAutoSize.LEFT,
					FONT_SIZE,
					true,
					_textColor,
					Style.color(Style.COLOR_BACKGROUND),
					true
				);
				textBitmap.x = textX;
				textBitmap.y = (_viewHeight- textBitmap.height )*.5;
			}
			
			toggler.x = _viewWidth - toggler.width - paddingValue;
			
			toggler.y = (_viewHeight - toggler.height) * .5;
		}
		
		private function updateSelection():void {
			if (_isDisposed)
				return;
			if (toggler != null)
				toggler.isSelected = _isSelected;
		}
		
		public function get isSelected():Boolean { return _isSelected; }
		public function set isSelected(value:Boolean):void {
			_isSelected = value;
			updateSelection();
		}
		
		public function get viewWidth():int { return _viewWidth; }
		public function set viewWidth(value:int):void {
			if (value == _viewWidth)
				return;
			_viewWidth = value;
			updateViewPort();
		}
		
		public function get viewHeight():int { return _viewHeight; }
		public function set viewHeight(value:int):void {
			if (value == _viewHeight)
				return;
			_viewHeight = value;
			updateViewPort();
		}
		
		public function get trueWidth():int {
			if (toggler != null)
				return toggler.x + toggler.width;
			return 0;
		}
		
		public function get isLoading():Boolean {
			return _isLoading;
		}
		
		public function set isLoading(value:Boolean):void {
			if (_isLoading == value)
				return;
			_isLoading = value;
			if (_isLoading == true) {
				toggler.alpha = 0.6;
				showPreloader();
			} else {
				toggler.alpha = 1;
				hidePreloader();
			}
		}
		
		private function showPreloader():void {		
			if (preloader == null) {
				preloader = new Preloader(int(toggler.height * .7));
				UI.colorize(preloader, 0x6e92af);
			}
			preloader.x = int(toggler.x - preloader.width * .5) - Config.MARGIN;
			preloader.y = int(toggler.y + toggler.height * .5);
			addChild(preloader);
			preloader.show();
		}

		private function hidePreloader():void {
			if (preloader != null) {
				preloader.hide();
				if (preloader.parent)
					preloader.parent.removeChild(preloader);
			}
		}
		
		public function setSize(w:int, h:int):void {
			_viewWidth = w;
			_viewHeight = h;
			updateViewPort();
		}
		
		public function setFontSize(value:int):void	{
			FONT_SIZE = value;
		}
		
		public function dispose():void {
			if (_isDisposed)
				return;
			_isDisposed = true;
			
			if (toggler != null)
				toggler.dispose();
			toggler = null;
			
			if (preloader != null) {
				hidePreloader();
				preloader.dispose();
			}
			preloader = null;
			
			
			_iconBmd = null;
			
			UI.destroy(textBitmap);
			textBitmap = null;
			
			UI.destroy(iconBitmap);
			iconBitmap = null;
			
			instanceCount--;
			
			if (instanceCount <= 0) {
				instanceCount = 0;
				UI.disposeBMD(TOGGLER_BMD);
				UI.disposeBMD(TOGGLERBG_BMD);
				TOGGLER_BMD = null;
				TOGGLERBG_BMD = null;
			}
		}
		
		public function setLabel(value:String):void 
		{
			_labelText = value;
			updateViewPort();
		}
		
		public function get padding():int
		{
			return paddingValue;
		}
	}
}