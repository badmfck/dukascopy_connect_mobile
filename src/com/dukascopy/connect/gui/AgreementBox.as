package com.dukascopy.connect.gui {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.scrollPanel.ScrollPanel;
	import com.dukascopy.connect.utils.TextUtils;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Alexey
	 */
	
	public class AgreementBox extends Sprite {
		
		private var scrollPanel:ScrollPanel;
		private var textBitmap:Bitmap;
		private var _viewWidth:int = 100;
		private var _viewHeight:int = 100;
		
		private var _textValue:String = "";
		
		public function AgreementBox() {
			super();
			scrollPanel = new ScrollPanel();
			scrollPanel.background = false;			
			addChild(scrollPanel.view);
			textBitmap = new Bitmap();
			scrollPanel.addObject(textBitmap);
		}
		
		public function setText(value:String):void {
			if (_textValue == value)
				return;
			_textValue = value;
			renderText();
		}
		
		public function activate():void {
			if (scrollPanel != null)
				scrollPanel.enable();
		}
		
		public function deactivate():void {
			if (scrollPanel != null)
				scrollPanel.disable();
		}
		
		public function setSize(w:int, h:int, isHeightMaxSize:Boolean = false):void {
			if (_viewWidth == w && _viewHeight == h)
				return;
			_viewWidth = w;
			_viewHeight = h;
			scrollPanel.setWidthAndHeight(_viewWidth, _viewHeight);
			renderText();
			if (isHeightMaxSize) {
				if (scrollPanel.itemsHeight < _viewHeight) {
					_viewHeight = scrollPanel.itemsHeight;
					scrollPanel.setWidthAndHeight(_viewWidth, _viewHeight);
				}
			}
		}
		
		private function renderText():void {
			if (textBitmap != null) {
				UI.disposeBMD(textBitmap.bitmapData);
				if (_textValue != "") {
					var fontSize:Number = 	Config.FINGER_SIZE * 0.28;
					textBitmap.bitmapData = TextUtils.createTextFieldData(_textValue, _viewWidth, 10, true, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, fontSize, true, 0xFFFFFF, 0x222533, false, false, false);
				} else
					textBitmap.bitmapData = null;
				scrollPanel.updateObjects();			
			}
		}
		
		public function dispose():void {
			deactivate();
			UI.destroy(textBitmap);
			textBitmap = null;
			if ( scrollPanel != null) 
				scrollPanel.dispose();
			scrollPanel = null;
		}
		
		public function getHeight():int {
			return scrollPanel.height;
		}
	}
}