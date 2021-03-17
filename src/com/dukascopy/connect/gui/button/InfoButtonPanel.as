package com.dukascopy.connect.gui.button {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author ...
	 */
	
	public class InfoButtonPanel extends Sprite {
		
		static private var closeIconData:BitmapData;
		
		private var _viewWidth:int = 400;
		
		private var textColor:uint = AppTheme.RED_MEDIUM;
		private var bgColor:uint = 0xf7f8fa;// 0xF22D2D;
		private var borderColor:uint = 0xf7f8fa;
		private var borderThickness:int = 2;
		private var borderRadius:Number = 0;
		private var vPadding:int = Config.MARGIN;
		private var hPadding:int = Config.MARGIN * 2;
		private var textAlign:String  =  TextFormatAlign.LEFT;
		private var textValue:String = "";
		
		private var closeButton:BitmapButton;
		private var infoButton:BitmapButton;
		
		public var tapCallback:Function;
		
		private var _isShown:Boolean  = false;
		
		private var _showUpdateCallback:Function = null;
		private var _hideUpdateCallback:Function = null;
		private var closeIconSize:int = Config.FINGER_SIZE * .32;
		
		public function InfoButtonPanel() {
			
			
			infoButton = new BitmapButton();
			infoButton.setStandartButtonParams();
			infoButton.setDownScale(1);
			infoButton.setDownColor(0x000000);
			infoButton.tapCallback = onInfoButtonClick;
			infoButton.disposeBitmapOnDestroy = true;
			infoButton.hide();
			infoButton.setOverflow();
			addChild(infoButton);
			
			closeButton = new BitmapButton();
			closeButton.setStandartButtonParams();
			closeButton.setDownScale(1.3);
			closeButton.setDownColor(0xFFFFFF);
			closeButton.tapCallback = onCloseBitmapClick;
			closeButton.disposeBitmapOnDestroy = true;
			closeButton.hide();
			renderCloseIcon();
			closeButton.setOverflow(10, 20, 20, 10);
			addChild(closeButton);
		}
		
		private function renderCloseIcon():void {
			if(closeButton!=null){
				closeButton.setBitmapData(getCloseIcon(closeIconSize), true);
			}
		}
		
		private  function getCloseIcon(size:int):BitmapData {
			if (closeIconData == null) {
				var asset:SWFCloseIconThin = new SWFCloseIconThin();
				var c:ColorTransform = new ColorTransform();
				c.color = textColor;
				asset.transform.colorTransform = c;
				closeIconData ||= UI.renderAsset(asset, size, size, true, "InerNotificationManager.closeIcon"); 
				c = null;
				asset = null;
			}
			return closeIconData;
		}
		
		public function setText(value:String):void {
			textValue = value;
			updateViewport();
		}
		
		public function show(time:Number = .2, delay:Number = 0):void {
			if (infoButton != null)
				infoButton.show(time, delay);
			if (closeButton != null)
				closeButton.show(time, delay + .2);
			_isShown  = true;
		}
		
		public function hide(time:Number = .2, delay:Number = 0):void {
			if (infoButton != null)
				infoButton.hide(time, delay + .2);
			if (closeButton != null)
				closeButton.hide(time, delay);
			_isShown = false;
		}
		
		public function activate():void {
			if (infoButton != null)
				infoButton.activate();
			if (closeButton != null)
				closeButton.activate();
		}
		
		public function deactivate():void {
			if (infoButton != null)
				infoButton.deactivate();
			if (closeButton != null)
				closeButton.deactivate();
		}
		
		public function updateViewport():void {
			var vOverflow:int = 10;
			if (infoButton != null) {
				var tempBmd:BitmapData;
				if(textValue != null) {
					tempBmd =  UI.renderTextPlane(
						textValue,
						_viewWidth,
						8,
						true,
						textAlign,
						TextFieldAutoSize.LEFT,
						Config.FINGER_SIZE * 0.28,
						true,
						textColor,
						bgColor,
						borderColor,
						borderRadius,
						borderThickness,
						hPadding,
						vPadding,
						null,
						false,
						true,
						50
					);
				}
				infoButton.setBitmapData(tempBmd, true, true);
				if (tempBmd != null)
					vOverflow = (tempBmd.height - closeButton.height) * .5;
			}
			if (closeButton != null) {
				closeButton.x = _viewWidth - closeButton.width - Config.DOUBLE_MARGIN;
				closeButton.y = int((infoButton.height - closeButton.height) * .5);
				closeButton.setOverflow(vOverflow, vOverflow, vOverflow, vOverflow);
			}
		}
		
		private function onInfoButtonClick():void {
			if (tapCallback != null)
				tapCallback(false);
		}
		
		private function onCloseBitmapClick():void {
			if (tapCallback != null)
				tapCallback(true);
		}
		
		public function dispose():void {
			if (infoButton != null)
				infoButton.deactivate();
			infoButton = null;
			if (closeButton != null)
				closeButton.deactivate();
			closeButton = null;
			tapCallback = null;
			_showUpdateCallback = null;
			_hideUpdateCallback = null;
		}
		
		public function get viewWidth():int { return _viewWidth; }
		public function set viewWidth(value:int):void {
			if (value == _viewWidth)
				return;
			_viewWidth = value;
			updateViewport();
		}
		
		public function get isShown():Boolean { return _isShown; }
		
		
		public function setBackgroundColor(color:uint):void {
			bgColor = color;
		}
		
		public function setTextColor(color:uint):void {
			textColor = color;
			
			UI.disposeBMD(closeIconData);
			closeIconData = null;
			renderCloseIcon();
		}
		
		public function setBorderThickness(value:int):void
		{
			borderThickness = value;
		}
	}
}