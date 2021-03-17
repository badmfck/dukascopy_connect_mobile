package com.dukascopy.connect.screens.dialogs {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.button.RoundedButton;
	import com.dukascopy.connect.gui.button.RoundedButtonNew;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.scrollPanel.ScrollPanel;
	import com.dukascopy.connect.screens.base.ScreenParams;
	import com.dukascopy.connect.screens.serviceScreen.Overlay;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import com.greensock.easing.Back;
	import com.greensock.easing.Bounce;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class ScreenAlertDialog extends PopupDialogBase {
		
		public const BUTTONS_NO_LAYOUT:int = 0;
		public const BUTTONS_HORIZONTAL:int = 1;
		public const BUTTONS_VERTICAL:int = 2;
		
		protected var currentLayout:int = 0;
		protected var paddingRight:int = 0;
		
		protected var button0:RoundedButtonNew;
		protected var button1:RoundedButtonNew;
		protected var button2:RoundedButtonNew;
		protected var button4:RoundedButtonNew;
		
		protected var content:ScrollPanel;
		
		protected var callback:Function;
		protected var btnsCount:int;
		protected var buttons:Array;
		private var contentBitmapDatas:Vector.<ImageBitmapData>;
		private var contentBitmaps:Vector.<Bitmap>;
		private var shown:Boolean;
		protected var buttonsPadding:Number;
		protected var contentBottomPadding:Number;
		protected var realContentHeight:Number;
		protected var buttonsAreaHeight:Number;
		
		protected var onContentTap:Function;
		
		public function ScreenAlertDialog() {
			super();
		}
		
		protected function get headerHeight():int 
		{
			return title.trueHeight;
		}
		
		override public function onBack(e:Event = null):void {
			if (callback != null) {	
				fireCallbackFunctionWithValue(0);
			}
			TweenMax.killDelayedCallsTo(closeByTimer);
		}
		
		override protected function createView():void {
			buttonsPadding = Config.MARGIN * 1.6;
			super.createView();
			
			content = new ScrollPanel();
			content.backgroundColor = Style.color(Style.COLOR_BACKGROUND);
			
			btnsCount = 1;						
			container.addChild(content.view);
			_view.addChild(container);
			
			contentBitmaps = new Vector.<Bitmap>();
		}
		
		override protected function onCloseButtonClick():void {
			if (callback != null) {	
				fireCallbackFunctionWithValue(0);
			}
			DialogManager.closeDialog();
		}
		
		protected function fireCallbackFunctionWithValue(value:int):void {
			var callBackFunction:Function = callback;
			callback = null;
			callBackFunction(value);
		}
		
		override public function initScreen(data:Object = null):void {
			var message:String = "";
			if (data) {
				if (data.title)
					message += data.title + ", ";
				if (data.text)
					message += data.text;
				if (data.paddingRight)
					paddingRight = data.paddingRight;
			}
			echo("ScreenAlertDialog", "initScreen", message);
			super.initScreen(data);
			callback = data.callBack;
			onContentTap = data.onContentTap;
			
			buttons = new Array();
			
			createFirstButton();
			createSecondButton();
			createThirdButton();
			createFourthButton();
		}
		
		protected function createFirstButton():void {
			var okButtonText:String = Lang.textOk;
			if (data.buttonOk)
				okButtonText = data.buttonOk;
			button0  = new RoundedButtonNew(okButtonText, Color.GREEN, Color.WHITE);
			button0.setStandartButtonParams();
			button0.setDownScale(1);
			button0.cancelOnVerticalMovement = true;
			button0.tapCallback = btn0Clicked;
			button0.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
			_view.addChild(button0);
			buttons.push(button0);
		}
		
		private function createSecondButton():void {
			if (data.buttonSecond != null) {
				// CANCEL Button						
				button1  = new RoundedButtonNew(data.buttonSecond, Style.color(Style.COLOR_BUTTON_SECONDARY), Color.WHITE);
				button1.setStandartButtonParams();
				button1.setDownScale(1);
				button1.cancelOnVerticalMovement = true;
				button1.tapCallback = btn1Clicked;
				button1.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
				_view.addChild(button1);
				buttons.push(button1);
				btnsCount++;
			}
		}
		
		protected function createThirdButton():void 
		{
			if (data.buttonThird != null) {									
					button2  = new RoundedButtonNew(data.buttonThird, Style.color(Style.COLOR_SUBTITLE), Color.WHITE);
					button2.setStandartButtonParams();
					button2.setDownScale(1);
					button2.cancelOnVerticalMovement = true;
					button2.tapCallback = btn2Clicked;
					button2.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
					_view.addChild(button2);
				buttons.push(button2);
				btnsCount++;
			}
		}
		
		protected function createFourthButton():void 
		{
			if (data.buttonFourth != null) {									
				button4  = new RoundedButtonNew(data.buttonFourth, Style.color(Style.COLOR_SUBTITLE), Color.WHITE);
				button4.setStandartButtonParams();
				button4.setDownScale(1);
				button4.cancelOnVerticalMovement = true;
				button4.tapCallback = btn3Clicked;
				button4.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
				_view.addChild(button4);
				buttons.push(button4);
				btnsCount++;
			}
		}
		
		override protected function drawView():void {
			super.drawView();
			currentLayout = BUTTONS_NO_LAYOUT;
			resizeButtons(currentLayout);
			
			updateButtonsAreaHeight();
			
			content.view.y = positionDrawing + padding * 1.3;
			content.view.x = padding;
			
			recreateContent(padding);
			
			var maxContentHeight:int = getMaxContentHeight();
			
			realContentHeight = Math.min(content.itemsHeight + 1, maxContentHeight);
			
			content.setWidthAndHeight(_width - padding * 2, realContentHeight, false);
			
			updateContentHeight();
			
			updateBack();
			updateScrollArea();
			padding * 1.3
			contentBottomPadding = getContentBottomPadding();
			repositionButtons();
		}
		
		protected function getContentBottomPadding():Number 
		{
			return padding * 1.3;
		}
		
		protected function get padding():int 
		{
			return vPadding;
		}
		
		protected function updateScrollArea():void 
		{
			if (!content.fitInScrollArea())
			{
				content.enable();
			}
			else {
				content.disable();
			}
			content.update();
		}
		
		protected function updateContentHeight():void 
		{
			contentHeight = (padding * 3.6 + headerHeight + buttonsAreaHeight + content.itemsHeight);
		}
		
		protected function updateButtonsAreaHeight():void 
		{
			buttonsAreaHeight = 0;
			if (currentLayout == BUTTONS_HORIZONTAL)
			{
				buttonsAreaHeight = button0.getHeight();
			}
			else if(currentLayout == BUTTONS_VERTICAL){
				buttonsAreaHeight = button0.getHeight() * btnsCount + padding * (btnsCount - 1);
			}
		}
		
		override protected function getMaxContentHeight():Number {
			return _height - padding * 3.6 - headerHeight - buttonsAreaHeight;
		}
		
		protected function recreateContent(padding:Number):void 
		{
			content.removeAllObjects();
			
			var maxTextHeight:int = Math.min(1500, 16777000 / (_width - padding * 2 - paddingRight - content.getScrollBarWidth() - Config.MARGIN));
			
			contentBitmapDatas = new Vector.<ImageBitmapData>();
			if (data.text)
			{
				contentBitmapDatas = TextUtils.createTextFieldImage(data.text,
														_width - padding * 2 - paddingRight - content.getScrollBarWidth() - Config.MARGIN, 
														1,
														true, 
														TextFormatAlign.LEFT,
														TextFieldAutoSize.LEFT,
														Config.FINGER_SIZE * 0.30,
														true,
														Style.color(Style.COLOR_TEXT),
														Style.color(Style.COLOR_BACKGROUND),
														false,
														data.htmlText,
														maxTextHeight,
														false);
			}
			var i:int;
			var length:int = contentBitmaps.length;
			for (i = 0; i < length; i++) {
				if (contentBitmaps[i].bitmapData) {
					UI.destroy(contentBitmaps[i]);
				}
			}
			contentBitmaps = new Vector.<Bitmap>();
			
			length = contentBitmapDatas.length;
			var bitmap:Bitmap;
			
			for (i = 0; i < length; i++) {
				bitmap = new Bitmap(contentBitmapDatas[i]);
				bitmap.smoothing = true;
				bitmap.y = content.itemsHeight;
				content.addObject(bitmap);
				contentBitmaps.push(bitmap);
			}
		}
		
		protected function repositionButtons():void {
			var position:int = 0;
			
			var buttonsAreaWidth:int = 0;
			
			var i:int = 0;
			
			for (i = 0; i < btnsCount; i++ )
			{
				buttonsAreaWidth += (buttons[i] as RoundedButtonNew).getWidth();
			}
			buttonsAreaWidth += buttonsPadding * (btnsCount - 1);
			
			if (currentLayout == BUTTONS_HORIZONTAL)
			{
				for (i = btnsCount - 1; i >= 0 ; i-- )
				{
					//trace("!!!!!!!!!!!!!!", container.y, content.view.y, realContentHeight, getContentBottomPadding());
					(buttons[i] as RoundedButtonNew).y = (container.y + content.view.y + realContentHeight + getContentBottomPadding());
					(buttons[i] as RoundedButtonNew).x = int((i == btnsCount - 1)?(_width * .5 - buttonsAreaWidth * .5):((buttons[i + 1] as RoundedButtonNew).x + (buttons[i + 1] as RoundedButtonNew).getWidth()) + buttonsPadding);
				}
			}
			else if (currentLayout == BUTTONS_VERTICAL)
			{
				for (i = btnsCount - 1; i >= 0 ; i-- )
				{
					(buttons[i] as RoundedButtonNew).x = int(_width * .5 - (buttons[i] as RoundedButtonNew).getWidth() * .5);
					(buttons[i] as RoundedButtonNew).y = int((i == btnsCount - 1)?
												(container.y + content.view.y + content.height + getContentBottomPadding()):
												((buttons[i + 1] as RoundedButtonNew).y + (buttons[i + 1] as RoundedButtonNew).getHeight() + buttonsPadding));
				}
			}
		}
		
		protected function resizeButtons(layout:int):void 
		{
			if (layout == BUTTONS_NO_LAYOUT)
			{
				layout = BUTTONS_HORIZONTAL;
			}
			currentLayout = layout;
			
			var buttonsPadding:int = Config.MARGIN*1.6;
			
			var maxButtonWidth:int;
			var maxButtonsAreaWidth:int = (_width - buttonsPadding * (btnsCount - 1) - padding * 2);
			
			if (currentLayout == BUTTONS_HORIZONTAL)
			{
				maxButtonWidth = maxButtonsAreaWidth / btnsCount;
			}
			else if (currentLayout == BUTTONS_VERTICAL)
			{
				maxButtonWidth = maxButtonsAreaWidth;
			}
			
			if (button0)
				button0.setSizeLimits(Config.FINGER_SIZE * 3.5, maxButtonWidth);
			if (button1)
				button1.setSizeLimits(Config.FINGER_SIZE * 3.5, maxButtonWidth);
			if (button2 && button2 is RoundedButtonNew)
				(button2 as RoundedButtonNew).setSizeLimits(Config.FINGER_SIZE * 3.5, maxButtonWidth);
			if (button4 && button4 is RoundedButtonNew)
				(button4 as RoundedButtonNew).setSizeLimits(Config.FINGER_SIZE * 3.5, maxButtonWidth);
			
			var isTextCropped:Boolean = false;
			
			var i:int = 0;
			
			for (i = 0; i < btnsCount; i++ )
			{
				isTextCropped = isTextCropped?true:(buttons[i] as RoundedButtonNew).isTextCropped();
			}
			
			if (isTextCropped && currentLayout == BUTTONS_HORIZONTAL)
			{
				currentLayout = BUTTONS_VERTICAL;
				
				resizeButtons(currentLayout);
			}
			else
			{
				maxButtonWidth = 0;
				for (i = 0; i < btnsCount; i++ )
				{
					(buttons[i] as RoundedButtonNew).draw();
					maxButtonWidth = Math.max(maxButtonWidth, Math.ceil((buttons[i] as RoundedButtonNew).getWidth()));
				}
				for (i = 0; i < btnsCount; i++ )
				{
					(buttons[i] as RoundedButtonNew).setSizeLimits(maxButtonWidth, maxButtonWidth);
					(buttons[i] as RoundedButtonNew).draw();
				}
			}
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			if (!content.fitInScrollArea())
				content.enable();
			else
				content.disable();
			button0.activate();
			if (button1!=null) {
				button1.activate();
			}
			if (button2!=null) {
				button2.activate();
			}
			if (button4!=null) {
				button4.activate();
			}
			if (onContentTap != null)
				PointerManager.addTap(container, onCTap);
			if ("closeTimer" in data && data.closeTimer != 0)
				TweenMax.delayedCall(data.closeTimer, closeByTimer);
			
			
			if (shown == false)
			{
				shown = true;
				var newPosition:int = view.y;
				view.y += Config.FINGER_SIZE * .5;
				view.alpha = 0;
				TweenMax.to(view, 0.3, {y:newPosition, alpha:1, ease:Back.easeOut});
			}
		}
		
		private function closeByTimer():void {
			if (callback != null)
				callback(0);
			DialogManager.closeDialog();
		}
		
		private function onCTap(e:Event = null):void {
			if (e.target == content.containerBox)
				onContentTap();
		}
		
		override public function deactivateScreen():void {
			if (isDisposed) return;
			super.deactivateScreen();
			
			content.disable();
			button0.deactivate();
			if (button1!=null) {
				button1.deactivate();
			}
			if (button2!=null) {
				button2.deactivate();
			}
			if (button4!=null) {
				button4.deactivate();
			}
			TweenMax.killDelayedCallsTo(closeByTimer);
			
			PointerManager.removeTap(container, onCTap);
		}
		
		protected function btn0Clicked():void 
		{
			if (callback != null) {
				fireCallbackFunctionWithValue(1);
			}
			DialogManager.closeDialog();
		}
		
		protected function btn3Clicked():void 
		{
			if (callback != null) {
				fireCallbackFunctionWithValue(4);
			}
			DialogManager.closeDialog();
		}
		
		protected function btn1Clicked():void 
		{
			if (callback != null) {
				fireCallbackFunctionWithValue(2);
			}
			DialogManager.closeDialog();
		}
		
		protected function btn2Clicked():void 
		{
			if (callback != null) {				
				fireCallbackFunctionWithValue(3);
			}
			DialogManager.closeDialog();
		}
		
		override public function dispose():void {
			if (isDisposed) return;
			super.dispose();
			
			TweenMax.killTweensOf(view);
			
			if (button0 != null) {
				button0.dispose();
				button0 = 	null;
			}
			
			if (button1 != null) {
				button1.dispose();
				button1 = 	null;
			}
			
			if (button4 != null) {
				button4.dispose();
				button4 = 	null;
			}
			
			if (button2 != null) {
				button2.dispose();
				button2 = 	null;
			}
			var i:int;
			var length:int = contentBitmaps.length;
			for (i = 0; i < length; i++) 
			{
				UI.destroy(contentBitmaps[i]);
				contentBitmaps[i] = null;
			}
			
			TweenMax.killDelayedCallsTo(closeByTimer);
			contentBitmaps = null;
			
			//if (topTF != null)
				//topTF.text = "";
			//topTF = null;
			
			content.dispose();
			
			callback = null;
			
			Overlay.removeCurrent();
		}
	}
}