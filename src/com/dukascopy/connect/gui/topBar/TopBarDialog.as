package com.dukascopy.connect.gui.topBar {
	
	import assets.CloseButtonIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.HitZoneData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.type.MainColors;
	import com.dukascopy.connect.utils.TextUtils;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	/**
	 * Класс полностью завершен! Не трогать без спроса!!!
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class TopBarDialog extends Sprite {
		
		private var title:String;
		private var closeCallback:Function;
		
		private var titleBMP:Bitmap;
		private var buttonClose:BitmapButton;
		
		private var disposed:Boolean = false;
		private var created:Boolean = false;
		private var lastWidth:int = -1;
		private var _trueHeight:int;
		private var vPadding:int;
		private var hPadding:int;
		private var color:uint = Style.color(Style.COLOR_POPUP_HEADER);
		private var overrideHeight:Number;
		
		public function TopBarDialog(padding:int = -1) {
			vPadding = Config.FINGER_SIZE * .3;
			hPadding = Config.DIALOG_MARGIN;
			
			if (padding != -1)
				this.hPadding = padding;
		}
		
		public function setColor(value:Number):void
		{
			color = value;
		}
		
		public function init(title:String, closeCallback:Function):void {
			if (disposed == true)
				return;
			this.closeCallback = closeCallback;
			this.title = title;
		}
		
		private function create():void {
			if (disposed == true)
				return;
			if (created == true)
				return;
			created = true;
			
			titleBMP = new Bitmap();
			titleBMP.y = vPadding;
			titleBMP.x = hPadding;
			addChild(titleBMP);
			buttonClose = new BitmapButton();
			buttonClose.setStandartButtonParams();
			buttonClose.setDownScale(1.3);
			buttonClose.setDownColor(0xFFFFFF);
			buttonClose.tapCallback = closeCallback;
		//	buttonClose.setOverlay(HitZoneType.MENU_MIDDLE_ELEMENT);
			buttonClose.disposeBitmapOnDestroy = true;
			buttonClose.hide();
			addChild(buttonClose);
			
			if (buttonClose.currentBitmapData == null) {
				var iconClose:Sprite = new CloseButtonIcon();
				UI.colorize(iconClose, Style.color(Style.COLOR_ICON_SETTINGS))
				var hh:int = Config.FINGER_SIZE * .34;
				iconClose.width = hh;
				iconClose.height = hh;
				buttonClose.setBitmapData(UI.getSnapshot(iconClose, StageQuality.HIGH, "TopBarDialog - iconClose"), true);
				var vv:int = (Config.FINGER_SIZE - hh) * .5;
				buttonClose.setOverflow(Config.DIALOG_MARGIN, vv, vv, Config.DIALOG_MARGIN);
				UI.destroy(iconClose);
				iconClose = null;
			}
		}
		
		public function draw(newWidth:int, multiline:Boolean = false):void {
			if (disposed == true)
				return;
			create();
			if (lastWidth == newWidth)
				return;
			var maxTitleWidth:int = newWidth - hPadding * 2 - buttonClose.width - Config.MARGIN;
			if (titleBMP.bitmapData != null)
				titleBMP.bitmapData.dispose();
			
			if (title == null)
			{
				title = "";
			}
			
			titleBMP.bitmapData = TextUtils.createTextFieldData(
																	title, 
																	maxTitleWidth, 
																	10, 
																	multiline, 
																	TextFormatAlign.LEFT, 
																	TextFieldAutoSize.LEFT, 
																	Config.FINGER_SIZE * .32, 
																	multiline, 
																	Style.color(Style.COLOR_TEXT), 
																	color, false, false, true);
			
			_trueHeight = titleBMP.height + vPadding * 2;
			
			if (!isNaN(overrideHeight))
			{
				_trueHeight = overrideHeight;
			}
			
			graphics.clear();
			graphics.beginFill(color);
			graphics.drawRect (0, 0, newWidth, _trueHeight);
			graphics.endFill();
			
			buttonClose.y = Math.min(Math.round((_trueHeight - buttonClose.height) * .5), vPadding);
			buttonClose.x = int(newWidth - Math.min(hPadding, buttonClose.y) - buttonClose.width);
			
			lastWidth = newWidth;
		}
		
		public function activate():void {
			if (disposed == true)
				return;
			if (buttonClose == null)
				return;
			if (buttonClose.getIsShown() == false)
				buttonClose.show(.3);
			buttonClose.activate();
		}
		
		public function deactivate():void {
			if (disposed == true)
				return;
			if (buttonClose == null)
				return;
			buttonClose.deactivate();
		}
		
		public function dispose():void {
			if (disposed == true)
				return;
			if (titleBMP != null) {
				if (titleBMP.bitmapData != null)
					titleBMP.bitmapData.dispose();
				titleBMP.bitmapData = null;
				if (titleBMP.parent != null)
					titleBMP.parent.removeChild(titleBMP);
			}
			titleBMP = null;
			if (buttonClose != null)
				buttonClose.dispose();
			buttonClose = null;
			closeCallback = null;
		}
		
		public function setHeight(value:Number):void 
		{
			overrideHeight = value;
		}
		
		public function getColor():Number 
		{
			return color;
		}
		
		public function get trueHeight():int { return _trueHeight};
	}
}