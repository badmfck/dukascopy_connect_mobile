package com.dukascopy.connect.gui.textedit {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.softKeyboard.SoftKeyboard;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.freshplanet.ane.KeyboardSize.MeasureKeyboard;
	import com.greensock.TweenMax;
	import com.telefision.utils.Loop;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.FocusDirection;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.FocusEvent;
	import flash.events.SoftKeyboardEvent;
	import flash.events.StatusEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.AutoCapitalize;
	import flash.text.StageText;
	import flash.text.StageTextInitOptions;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author Alexey Skuryat
	 */
	
	public class TextComposer extends Sprite {
		
		private var _horizontalLayout:Boolean = false;
		
		private var _viewWidth:int = 0;
		private var _viewHeight:int = 0;		
		
		private var HEADER_SIZE:int = 70; // header is the title and separator container
		private var FOOTER_SIZE:int = 70; // header is the title and separator container
		private var SEPARATOR_HEIGHT:int = 5; // height of separator line 
		private var _MAX_CHARS:int = 205;		
		private var BUTTON_SIZE:int = 50;
		private var SPACING:int = Config.MARGIN * 2;
		
		private var OK_BMD:BitmapData;
		private var CANCEL_BMD:BitmapData;
		
		private var backgroundOverlay:Bitmap;
		private var titleBitmap:Bitmap;
		private var titleSeparator:Bitmap;
		private var stageText:TextField;
		
		private var _isShown:Boolean = false;
		
		private var callback:Function;
		private var contentText:String = "";
		
		private var isDisposed:Boolean  = false;
		private var isFocused:Boolean = false;
		
		public function TextComposer() {
			super();
			createView();
		}
		
		private function createView():void {
			HEADER_SIZE = Config.FINGER_SIZE + Config.DOUBLE_MARGIN;
			FOOTER_SIZE = Config.FINGER_SIZE;
			if (backgroundOverlay == null) {
				var bmd:ImageBitmapData = new ImageBitmapData("TextComposer.backgroundOverlay", 1, 1, false, 0x000000);
				backgroundOverlay = new Bitmap(bmd);
				addChild(backgroundOverlay);
			}
			if (titleBitmap == null) {
				titleBitmap = new Bitmap();
				addChild(titleBitmap);
			}
			if (titleSeparator == null) {
				var separatorBMD:ImageBitmapData = UI.getHorizontalLine(UI.getLineThickness(), Style.color(Style.COLOR_SUBTITLE));
				titleSeparator = new Bitmap(separatorBMD);
				addChild(titleSeparator);
			}
			// render buttons 
			BUTTON_SIZE =  int(Config.FINGER_SIZE * .65);
			// generate bitmap icons
			
			
			// start publish button
			okButton = new BitmapButton();
				OK_BMD ||= UI.getIconByFrame(16, BUTTON_SIZE, BUTTON_SIZE);
			okButton.setBitmapData(OK_BMD);
			okButton.hide(0);
			okButton.setOverflow(15, 5, 15, 15);
			addChild(okButton);		
			okButton.tapCallback = onOkTap;		
			
			
			cancelButton = new BitmapButton();
				CANCEL_BMD ||= UI.getIconByFrame(19, BUTTON_SIZE, BUTTON_SIZE);
			cancelButton.setBitmapData(CANCEL_BMD);
			cancelButton.hide(0);
			cancelButton.setOverflow(15, 15, 5, 15);
			addChild(cancelButton);		
			cancelButton.tapCallback = onCancelTap;
		}
		
		// BUTTON HANDLERS ======================================
		private function onOkTap():void {
			echo("TextComposer", "onOkTap");
			var result:String = stageText.text;
			if (callback != null)
				callback( true, result);		
			
		}
		
		private function onCancelTap():void {
			echo("TextComposer", "onCancelTap");
			var result:String = stageText.text;
			if (callback != null)
				callback( false,result);		
		}
		
		/** SHOW */
		public function show(callback:Function, title:String= "", contentText:String =""):void {
			if (isDisposed) return;
			
			SoftKeyboard.S_REAL_HEIGHT_DETECTED.add(updateViewPort);
			listenKeyboard();
			
			this.callback = callback;
			_title = title;
			this.contentText = contentText;
			
			// Init buttons
			cancelButton.hide(0);
			okButton.hide(0);
			
			// BACKGROUND 
			backgroundOverlay.visible = true;
			backgroundOverlay.alpha = 0;
			TweenMax.killTweensOf(backgroundOverlay);
			TweenMax.to(backgroundOverlay, .3, { alpha:.9, delay:0.1, onComplete:onShowComplete } );
			
			// SEPARATOR 
			TweenMax.killTweensOf(titleSeparator);
			titleSeparator.x = Config.DOUBLE_MARGIN;
			TweenMax.to(titleSeparator, .3, { width:_viewWidth - Config.DOUBLE_MARGIN*2} );
			
			// TITLE
			disposeTitle();
			titleBitmap.bitmapData = renderBitmapText(_title, _viewWidth - Config.DOUBLE_MARGIN * 2 - Config.FINGER_SIZE*2, getTitleFormat());
			titleBitmap.x = Config.DOUBLE_MARGIN;
			titleBitmap.y = (HEADER_SIZE- titleBitmap.height) - Config.DOUBLE_MARGIN + Config.APPLE_TOP_OFFSET;
				
			TweenMax.killTweensOf(titleBitmap);
			titleBitmap.alpha = 0;
			TweenMax.to(titleBitmap, .3, { alpha:1 , delay:.4} );
		}
		
		private function listenKeyboard():void 
		{
			if (Config.PLATFORM_ANDROID == true)
			{
			//	MobileGui.androidExtension.addEventListener(StatusEvent.STATUS, extensionAndroidStatusHandler);
			}
			else if (Config.PLATFORM_APPLE == true)
			{
				MobileGui.dce.addEventListener(StatusEvent.STATUS, statusHandlerApple);
			}
		}
		
		private function extensionAndroidStatusHandler(e:StatusEvent):void
		{
			if (e.code == "keyboardHeight")
			{
				keyboardHeight = parseInt(e.level);
				updateOnNative();
			}
		}
		
		private function updateOnNative():void 
		{
			TweenMax.killDelayedCallsTo(updateViewPort);
			TweenMax.delayedCall(0.5, updateViewPort);
		}
		
		private function statusHandlerApple(e:StatusEvent):void {
			var data:Object;
			switch (e.code) {
				case "inputViewHeightChangeStart":
				case "inputViewKeyboardShowStart":
				case "inputViewKeyboardHideStart":
				case "inputViewHeightChangeEnd":
				case "inputViewKeyboardShowEnd":
				case "inputViewKeyboardHideEnd": {
					data = JSON.parse(e.level);
					if ("inputViewHeight" in data)
						keyboardHeight = data.inputViewHeight;
					updateOnNative();
					break;
				}
			}
		}
		
		/** Show Complete **/
		private function onShowComplete():void
		{
			echo("TextComposer", "onShowComplete");
			// activate events ui 
			// remove stagetext snapshot and add stagetext instead and do focus 
			_isShown = true;
			addStageText();
		}
		
		private function disposeTitle():void
		{
			if (titleBitmap!=null && titleBitmap.bitmapData!=null) {
				titleBitmap.bitmapData.dispose();
				titleBitmap.bitmapData = null;
			}
		}
		
		/** HIDE */
		public function hide(onOk:Boolean =false):void
		{
			//save all data 
			removeStageText();
			
			
			
			TweenMax.killDelayedCallsTo(updateFocus);
			stopListenKeyboard();
			TweenMax.killDelayedCallsTo(updateViewPort);
			SoftKeyboard.S_REAL_HEIGHT_DETECTED.remove(updateViewPort);
			
			Input.S_SOFTKEYBOARD.invoke(false);
			
			MobileGui.stage.focus = null;
			MobileGui.stage.assignFocus(null, FocusDirection.TOP);
			
			cancelButton.deactivate();
			okButton.deactivate();
			
			// deactivate 
			// make snapshot of text
			if (onOk) {
				okButton.hide(.3);
				cancelButton.hide(.3, .1);
			}else {
				okButton.hide(.3,.1);
				cancelButton.hide(.3);
			}
			
			// BACKGROUND 
			TweenMax.killTweensOf(backgroundOverlay);
			TweenMax.to(backgroundOverlay, .3, { alpha:0 , delay:.3,onComplete:onHideComplete } );
			
			// SEPARATOR 
			TweenMax.killTweensOf(titleSeparator);
			TweenMax.to(titleSeparator, .3, { width:0, x:_viewWidth-Config.DOUBLE_MARGIN, delay:0});			
			
			// TITLE 
			TweenMax.killTweensOf(titleBitmap);
			TweenMax.to(titleBitmap, .3, { alpha:0} );						
			_isShown = false;
		}
		
		/** Hide Complete */
		private function onHideComplete():void 	{
			echo("TextComposer", "onHideComplete");
			// call complete callback 
			if(backgroundOverlay!=null)
				backgroundOverlay.visible = false;			
			//trace("On hide complete ");
			// clear all previous data 
			UI.safeRemoveChild(this);
		}
		
		public function freeze():void	{
			//if (!isUsed) return;			
			if (stageText) {
			//	stageText.stage = null;			
			}
		}
		
		public function unfreeze():void	{
			if (stageText) {
			//	stageText.stage = MobileGui.stage;			
			}
			updateStageTextPosition();				
		}
		
		private function onSKActivate(e:SoftKeyboardEvent):void {
			Input.S_SOFTKEYBOARD.invoke(true);
		}
		
		private function onSKActivating(e:SoftKeyboardEvent):void {
			Input.S_SOFTKEYBOARD.invoke(true);
		}
		
		private function onSKDeactivating(e:SoftKeyboardEvent):void {
			Input.S_SOFTKEYBOARD.invoke(false);
		}
		
		/** MSG CREATION VIEW **/
		private function addStageText():void
		{
			SoftKeyboard.startDetectHeight();
			if(stageText==null){		
				var opt:StageTextInitOptions = new StageTextInitOptions(true);
				stageText = new TextField();
				stageText.type = TextFieldType.INPUT;
				stageText.multiline = true;
				stageText.wordWrap = true;
				stageText.addEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_ACTIVATE, onSKActivate);
				stageText.addEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_ACTIVATING, onSKActivating);
				stageText.addEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_DEACTIVATE, onSKDeactivating);
			//	stageText.autoCorrect = true;
			//	stageText.editable = true;
			//	stageText.autoCapitalize = AutoCapitalize.SENTENCE;
			//	stageText.visible = true;
			//	stageText.fontFamily = "Tahoma";// TextFormatStyles.chatStyle.font;				
				var itemHeight:int = Config.FINGER_SIZE * .8;					
		//		stageText.fontSize = itemHeight * .7 - Config.MARGIN * 2;// TextFormatStyles.chatStyle.size as Number;
		//		stageText.color = 0xffffff;
				
				var tf:TextFormat = new TextFormat();
				tf.color = 0xFFFFFF;
				tf.size = itemHeight * .7 - Config.MARGIN * 2;// TextFormatStyles.chatStyle.size as Number;
				tf.font = Config.defaultFontName;
				stageText.defaultTextFormat = tf;
			}
			stageText.maxChars = _MAX_CHARS;
			stageText.text = contentText;// initText != null?initText:""; TODO
		//	stageText.viewPort = TextComposer.getRect(getGlobalX()+Config.DOUBLE_MARGIN, getGlobalY() + HEADER_SIZE+Config.DOUBLE_MARGIN, _viewWidth-Config.DOUBLE_MARGIN*2, getFreeHeight());
		//	stageText.stage = MobileGui.stage;
			stageText.width = _viewWidth - Config.DOUBLE_MARGIN * 2;
			stageText.height = getFreeHeight();
			stageText.x = Config.DIALOG_MARGIN;
			stageText.y = HEADER_SIZE+Config.DOUBLE_MARGIN + Config.APPLE_TOP_OFFSET;
			addChild(stageText);
			updateFocus();
			
			if(!Config.PLATFORM_WINDOWS){
				stageText.addEventListener(FocusEvent.FOCUS_IN, onFocusIn);
				stageText.addEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
				stageText.addEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_DEACTIVATE, onKeyboardDeactivate);		
			}
			TweenMax.killDelayedCallsTo(updateFocus);
			TweenMax.delayedCall(1, updateFocus, null, true);
		//	stageText.selectRange(stageText.text.length, stageText.text.length);	
		//	stageText.assignFocus();	
			
			// Add chars counter if needed 
			//addCharsDisplay();
			lastChars = -1;
			calculateCharsLeft();
			Loop.add(calculateCharsLeft);
			TweenMax.delayedCall(.7,delayedShowButtons);
		}
		
		private function updateFocus():void 
		{
			stageText.requestSoftKeyboard();
			TweenMax.killDelayedCallsTo(updateFocus);
			/*if (MobileGui.stage != null)
			{
				MobileGui.stage.focus = stageText;
				MobileGui.stage.assignFocus(stageText, FocusDirection.TOP);
			}
			trace("focus:", MobileGui.stage.focus);
			SoftKeyboard.openKeyboard();*/
		}
		
		private function delayedShowButtons():void {
			echo("TextComposer", "delayedShowButtons");
			if (isDisposed) return;
			updateViewPort();
			okButton.show(.3,.2);
			cancelButton.show(.3);
			okButton.activate();
			cancelButton.activate();
		}
		
		/** REMOVE CREATION VIEW **/
		private function removeStageText():void {		
			SoftKeyboard.stopDetectHeight();
			if (stageText != null) {
				stageText.removeEventListener(FocusEvent.FOCUS_IN, onFocusIn);
				stageText.removeEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
				stageText.removeEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_ACTIVATE, onSKActivate);
				stageText.removeEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_ACTIVATING, onSKActivating);
				stageText.removeEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_DEACTIVATE, onSKDeactivating);
				//MobileGui.stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				//stageText.removeEventListener(FocusEvent.FOCUS_IN, onFocusIn);
				//stageText.removeEventListener(Event.CHANGE, onInputTextChange);
			//	stageText.stage = null;
				//stageText.viewPort = null;
				removeChild(stageText);
				stageText = null;
			}			
			// chars counter
			Loop.remove(calculateCharsLeft);			
			lastChars = -1;	
		}
		
		/** Focus In **/
		private function onFocusIn(e:FocusEvent):void {	
			isFocused = true;
			//var textViewPort:Rectangle = TextComposer.getRect(getGlobalX(), getGlobalY() +HEADER_SIZE, _viewWidth, getFreeHeight());
			// position buttons to top 
			
			TweenMax.killDelayedCallsTo(updateViewPort);
			TweenMax.delayedCall(.3, updateViewPort);
		}
		
		/** Focus Out **/
		private function onFocusOut(e:FocusEvent):void 
		{
			isFocused = false;
			
			e.preventDefault();	
			e.stopImmediatePropagation();	
			if (cancelButton.containsCords(MobileGui.stage.mouseX, MobileGui.stage.mouseY) || okButton.containsCords(MobileGui.stage.mouseX, MobileGui.stage.mouseY)) {
				/*if(!Config.PLATFORM_ANDROID)
					stageText.assignFocus();	*/
			}
			//updateViewPort();
			TweenMax.killDelayedCallsTo(updateViewPort);
			TweenMax.delayedCall(.3,updateViewPort);			
		}
		
		private function delayedAssignFocus():void
		{
		//	stageText.assignFocus();
		}
		
		private function onKeyboardDeactivate(e:SoftKeyboardEvent):void 
		{
			//trace("deactivate !!!");
			e.preventDefault();	
			e.stopImmediatePropagation();				
			//stageText.assignFocus();				
		}
		
		private function updateStageTextPosition():void
		{
			if (_viewWidth <= 1) return;
			if (_viewHeight <= 1) return;
			
			if (stageText != null ) {
				var destWidth:int = _horizontalLayout? _viewWidth-300-Config.DOUBLE_MARGIN*2:_viewWidth-Config.DOUBLE_MARGIN*2;
			//	stageText.viewPort = TextComposer.getRect(getGlobalX() + Config.DOUBLE_MARGIN, getGlobalY() + HEADER_SIZE+Config.DOUBLE_MARGIN, destWidth, getFreeHeight());
				stageText.width = _viewWidth - Config.DOUBLE_MARGIN * 2;
				stageText.height = getFreeHeight();
				stageText.x = Config.DIALOG_MARGIN;
				stageText.y = HEADER_SIZE+Config.DOUBLE_MARGIN + Config.APPLE_TOP_OFFSET;
			}
			
			okButton.x = _viewWidth - BUTTON_SIZE - Config.DOUBLE_MARGIN;
			cancelButton.x = okButton.x - BUTTON_SIZE - SPACING;			
			updateButtonsPosition();
		}
		
		private function updateButtonsPosition():void 
		{
			if (_horizontalLayout == true)
			{
				okButton.y = cancelButton.y = HEADER_SIZE + Config.DOUBLE_MARGIN;
			}
			else
			{
				okButton.y = cancelButton.y = int(HEADER_SIZE * .5 - okButton.height * .5) + Config.APPLE_TOP_OFFSET;
			}
			/*if (Config.PLATFORM_APPLE == true)
			{
				okButton.y = cancelButton.y = _viewHeight - SoftKeyboard.getRealKeyboardHeight() - Config.FINGER_SIZE - Config.MARGIN;
			}*/
		}
		
		private var lastChars:int = -1;
		private function calculateCharsLeft():void
		{
			var charsLeft:int = 0;
			if (stageText) {
				var cur:int = stageText.text.length;
				charsLeft = _MAX_CHARS - cur;
			}else {
				//if(initText!=null)
					//charsLeft = _MAX_CHARS - initText.length;
			}
			
			if (lastChars == charsLeft) return;
			lastChars = charsLeft;
			//trace(lastChars + "chars left");
			//trace("CHECK FOCUS "+ MobileGui.stage.focus);
			//if (charsLeftTextField != null) {
				//charsLeftTextField.text  = "" + charsLeft;
			//}
			//trace("Chars left: ",charsLeft);
			
		}
		
		private function updateViewPort():void 
		{
			echo("TextComposer", "updateViewPort");
			TweenMax.killDelayedCallsTo(updateViewPort);
			_horizontalLayout = _viewWidth > _viewHeight;
			_horizontalLayout = false;
			if (isDisposed) return;
			
			if (backgroundOverlay) {
				backgroundOverlay.width = _viewWidth;
				if (backgroundOverlay.height < _viewHeight)
				{
					backgroundOverlay.height = _viewHeight;
				}
			}
			
			if (titleBitmap) {
				titleBitmap.x = Config.DOUBLE_MARGIN;
				titleBitmap.y = (HEADER_SIZE- titleBitmap.height) - Config.DOUBLE_MARGIN + Config.APPLE_TOP_OFFSET;
			}
			
			if (titleSeparator) {
				titleSeparator.y = HEADER_SIZE + Config.APPLE_TOP_OFFSET;
				titleSeparator.x = Config.DOUBLE_MARGIN;
				if (_isShown) {
					titleSeparator.width = _viewWidth - Config.DOUBLE_MARGIN*2;
				}
			}
			
			//inputBounds.width = _horizontalLayout? _viewWidth-300:_viewWidth;
			//inputBounds.y = HEADER_SIZE;
			//inputBounds.height = getFreeHeight();
			
			updateStageTextPosition();
			
			okButton.x = _viewWidth - BUTTON_SIZE - Config.DOUBLE_MARGIN;
			cancelButton.x = okButton.x - BUTTON_SIZE - SPACING;			
			
			updateButtonsPosition();
		}
		
		public function setSize(w:int, h:int):void {
			
			_viewWidth = w;
			_viewHeight = h;
			if (_viewWidth < 1) _viewWidth = 1;
			if (_viewHeight < 1) _viewHeight = 1;
			updateViewPort();
		}
		
		private var textRenderer:TextField;
		
		/** Render textsnapshot **/
		private function renderBitmapText(s:String, maxW:int = 800, format:TextFormat = null , autoSize:String = TextFieldAutoSize.LEFT, multiline:Boolean = false,wordWrap:Boolean = false):BitmapData
		{
			var fmt:TextFormat = format != null?format:new TextFormat("Tahoma", 14, 0x000000);
			textRenderer ||= new TextField();
			var lastAutosize:String = textRenderer.autoSize;
			textRenderer.width = maxW;			
			textRenderer.autoSize = autoSize;
			textRenderer.multiline = multiline;
			textRenderer.wordWrap = wordWrap;
			textRenderer.defaultTextFormat = fmt;			
			textRenderer.text = s;		
			textRenderer.textColor = 0x999999;	
			textRenderer.height = textRenderer.textHeight + 4;		
			
			var destWidth:int = textRenderer.width;
			if (destWidth> maxW) {
				destWidth = maxW;
			}			
			
			var destHeight:Number = textRenderer.height;			
			var bmd:ImageBitmapData = new ImageBitmapData("TextComposer.textRenderer", destWidth, destHeight, true, 0xffffff);
			bmd.draw(textRenderer);
			
			//textRenderer.autoSize = lastAutosize;
			//textRenderer = null;			
			return bmd;
		}
		
		private static var tempRect:Rectangle  = new Rectangle();
		private static function getRect(x:int=0, y:int=0, w:int=0, h:int=0):Rectangle {
			tempRect.x = x;
			tempRect.y = y;
			tempRect.width = w;
			tempRect.height = h;			
			return tempRect;	
		}
		
		/*private static var _stageText:StageText;		
		public static function getStageText():StageText {
			_stageText ||= new StageText(new StageTextInitOptions(true));
			return _stageText;
		}*/
		
		private var tempFormat:TextFormat = new TextFormat();
		private function getTitleFormat():TextFormat {
			tempFormat.font = Config.defaultFontName;
			tempFormat.size = FontSize.BODY;
			tempFormat.color = Style.color(Style.COLOR_BACKGROUND);
			return tempFormat;
		}
		
		private static var tempPoint:Point = new Point();
		private var okButton:BitmapButton;
		private var cancelButton:BitmapButton;
		private var _title:String="";
		private var keyboardHeight:Number = 0;
		
		public static function getGlobalCoords(obj:DisplayObject, stage:Stage):Point {
			var result:Boolean  = false;
			tempPoint.x = 0;
			tempPoint.y = 0;
			var coord:Point =  obj.localToGlobal(tempPoint);
			return coord;					
		}
		
		public function setTitle(string:String):void 
		{
			_title = string;
			// TITLE
			disposeTitle();
			titleBitmap.bitmapData = renderBitmapText(_title, _viewWidth, getTitleFormat());	
		}
		
		public function get MAX_CHARS():int { return _MAX_CHARS; }		
		public function set MAX_CHARS(value:int):void {
			_MAX_CHARS = value;
			if (stageText != null)
				stageText.maxChars = _MAX_CHARS;
		}
		
		public function get horizontalLayout():Boolean 	{	return _horizontalLayout;	}		
		public function set horizontalLayout(value:Boolean):void 
		{
			if (value == _horizontalLayout) return;
			_horizontalLayout = value;
			updateViewPort();
		}
		
		private function getGlobalX():Number {
			return getGlobalCoords(this, MobileGui.stage).x;
		}
		
		private function getGlobalY():Number {
			return getGlobalCoords(this, MobileGui.stage).y;
		}
		
		private function getFreeHeight():Number {	
			var androidKeyboardHeigt:Number = 0;
			var iosKeyboardHeigt:Number = 0;
			
			var maxHeight:int = _viewHeight - Config.APPLE_BOTTOM_OFFSET;
			if (keyboardHeight > 100)
			{
				maxHeight = maxHeight - keyboardHeight;
			}
				
			var freeHeight:Number = maxHeight - HEADER_SIZE - FOOTER_SIZE - Config.DOUBLE_MARGIN * 2;
			if (_horizontalLayout) return maxHeight;			
			if (freeHeight <= 0) freeHeight = 1;
			return freeHeight;
		}	
		
		public function dispose():void {
			if (isDisposed == true)
				return;
			
			TweenMax.killDelayedCallsTo(updateFocus);
			stopListenKeyboard();
			TweenMax.killDelayedCallsTo(updateViewPort);
			SoftKeyboard.S_REAL_HEIGHT_DETECTED.remove(updateViewPort);
			isDisposed = true;			
			removeStageText();
			Input.S_SOFTKEYBOARD.invoke(false);
			
			MobileGui.stage.focus = null;
			MobileGui.stage.assignFocus(null, FocusDirection.TOP);
			
			TweenMax.killDelayedCallsTo(delayedShowButtons);
			if (titleBitmap != null) 
				UI.destroy(titleBitmap);
			titleBitmap = null;
			if (backgroundOverlay != null)
				UI.destroy(backgroundOverlay);
			backgroundOverlay = null;
			if (titleSeparator != null)
				UI.destroy(titleSeparator);
			titleSeparator = null;
			if (okButton != null)
				okButton.dispose();
			okButton = null;
			if (cancelButton != null)
				cancelButton.dispose();
			cancelButton = null;
			if (OK_BMD != null)
				OK_BMD.dispose();
			OK_BMD = null;
			if (CANCEL_BMD != null)
				CANCEL_BMD.dispose();
			CANCEL_BMD = null;
			tempFormat = null;
		}
		
		private function stopListenKeyboard():void 
		{
			if (Config.PLATFORM_ANDROID == true)
			{
				MobileGui.androidExtension.removeEventListener(StatusEvent.STATUS, extensionAndroidStatusHandler);
			}
			else if (Config.PLATFORM_APPLE == true)
			{
				MobileGui.dce.removeEventListener(StatusEvent.STATUS, statusHandlerApple);
			}
		}
	}
}