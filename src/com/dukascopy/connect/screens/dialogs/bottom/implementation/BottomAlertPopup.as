package com.dukascopy.connect.screens.dialogs.bottom.implementation {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.screens.dialogs.bottom.ScrollAnimatedTitlePopup;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import flash.events.TextEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class BottomAlertPopup extends ScrollAnimatedTitlePopup {
		
		protected var needCallback:Boolean = true;
		protected var paddind:int;
		protected var okButton:BitmapButton;
		protected var messageText:TextField;
		
		public function BottomAlertPopup() { }
		
		override protected function createView():void {
			super.createView();
			
			okButton = new BitmapButton();
			okButton.setStandartButtonParams();
			okButton.setDownScale(1);
			okButton.setDownColor(NaN);
			okButton.setOverlay(HitZoneType.BUTTON);
			okButton.cancelOnVerticalMovement = false;
			okButton.ignoreHittest = true;
			okButton.tapCallback = onButtonOkClick;
			
			container.addChild(okButton);
			
			messageText = new TextField();
			messageText.multiline = true;
			messageText.wordWrap = true;
			
			var textFormat:TextFormat = new TextFormat();
			textFormat.font = Config.defaultFontName;
			textFormat.size = FontSize.BODY;
			messageText.selectable = false;
			textFormat.color = Style.color(Style.COLOR_TEXT);
			messageText.defaultTextFormat = textFormat;
			messageText.addEventListener(TextEvent.LINK, linkClicked);
			
			addItem(messageText);
			
			paddind = Config.FINGER_SIZE * 0.45;
		}
		
		private function linkClicked(e:TextEvent):void {
			navigateToURL(new URLRequest(e.text));
		}
		
		protected function onButtonOkClick():void {
			close();
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			if (data != null && "message" in data && data.message != null)
			{
				drawMessage();
			}
			
			drawButton();
			drawOtherContent();
			
			updatePositions();
		}
		
		protected function drawOtherContent():void 
		{
			
		}
		
		protected function updatePositions():void 
		{
			var position:int = Config.FINGER_SIZE * .3;
			
			messageText.y = position;
			messageText.x = paddind;
			position += messageText.height + Config.FINGER_SIZE * .3;
			
			scrollPanel.setWidthAndHeight(_width, getHeight() - headerHeight - okButton.height - Config.FINGER_SIZE * .7 - Config.APPLE_BOTTOM_OFFSET);
			
			okButton.x = paddind;
			okButton.y = getHeight() - paddind - Config.APPLE_BOTTOM_OFFSET - okButton.fullHeight;
			
			updateScroll();
		}
		
		private function drawMessage():void 
		{
			if (data != null && "message" in data && data.message != null)
			{
				messageText.width = _width - paddind * 2;
				
				var text:String = data.message;
				text = text.replace("<a href='http", "<a href='event:http");
				messageText.htmlText = text;
				
				messageText.height = messageText.textHeight + Config.FINGER_SIZE * .2;
				messageText.addEventListener(TextEvent.LINK, linkClicked);
			}
		}
		
		protected function getButtonWidth():int 
		{
			return _width - paddind * 2;
		}
		
		private function drawButton():void 
		{
			var textSettings:TextFieldSettings;
			var buttonBitmap:ImageBitmapData;
			
			textSettings = new TextFieldSettings(getButtonLabel(), Color.WHITE, FontSize.BODY, TextFormatAlign.CENTER);
			buttonBitmap = TextUtils.createbutton(textSettings, Color.GREEN, 1, -1, NaN, getButtonWidth(), Config.FINGER_SIZE * .3, Style.size(Style.SIZE_BUTTON_CORNER));
			
			okButton.setBitmapData(buttonBitmap, true);
		}
		
		protected function getButtonLabel():String 
		{
			return Lang.textBack;
		}
		
		override protected function drawView():void {
			if (_isDisposed == true)
				return;
			
			scrollBottom.y = scrollPanel.itemsHeight + Config.APPLE_BOTTOM_OFFSET + Config.FINGER_SIZE * .3;
			super.drawView();
		}
		
		private function getTextWidth():int 
		{
			return _width - paddind * 2;
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			if (_isDisposed) {
				return;
			}
			okButton.activate();
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed) {
				return;
			}
			okButton.deactivate();
		}
		
		override protected function onRemove():void 
		{
			if (needCallback == true)
			{
				needCallback = false;
				if (data != null && "callback" in data && data.callback != null && data.callback is Function && (data.callback as Function).length == 0)
				{
					(data.callback as Function)();
				}
			}
		}
		
		override public function dispose():void {
			super.dispose();
			TweenMax.killDelayedCallsTo(close);
			if (okButton != null)
				okButton.dispose();
			okButton = null;
			
			if (messageText != null)
			{
				messageText.removeEventListener(TextEvent.LINK, linkClicked);
				UI.destroy(messageText);
				messageText = null;
			}
		}
	}
}