package com.dukascopy.connect.gui.input {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.shapes.Box;
	import com.dukascopy.connect.sys.echo.echo;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.mobileClip.MobileClip;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.pool.IPoolItem;
	import com.dukascopy.connect.sys.softKeyboard.SoftKeyboard;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.greensock.TweenMax;
	import com.telefision.sys.signals.Signal;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.SoftKeyboardEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextLineMetrics;
	import flash.ui.Keyboard;
	
	/**
	 * @author Igor Bloom
	 */
	
	public class Input extends MobileClip implements IPoolItem {
		
		public static const MODE_INPUT:String = 'input';
		public static const MODE_PASSWORD:String = 'password';
		public static const MODE_DIGIT:String = 'digit';
		public static const MODE_DIGIT_DECIMAL:String = 'digitdecimal';
		public static const MODE_PHONE:String = 'phone';
		public static const MODE_BUTTON:String = 'button';
		
		public static var S_SOFTKEYBOARD:Signal = new Signal("Input.S_SOFTKEYBOARD");
		
		private var _ignoreSwipe:Boolean = false;
		private var _inUse:Boolean;
		protected var textField:TextField;
		
		protected var _width:int = 320;
		
		private var wasChanged:Boolean = false;
		private var labelValue:String = "";
		private var mode:String;
		
		protected var padding:int = Config.FINGER_SIZE * .2;
		static protected var _height:int = Config.FINGER_SIZE * .8;
		static protected var inputFormatBig:TextFormat;// = new TextFormat('Tahoma', _height * .83 - padding * 2);
		static private var infoBoxFormatBig:TextFormat;// = new TextFormat('Tahoma', _height * .3);
		private var textHeight:int = -1;
		private var activated:Boolean=false;
		
		public var S_TAPPED:Signal = new Signal('Input.S_TAPPED');
		public var S_INFOBOX_TAPPED:Signal = new Signal('Input.S_INFOBOX_TAPPED');
		public var S_CHANGED:Signal = new Signal('Input.S_CHANGED');
		public var S_FOCUS_OUT:Signal = new Signal('Input.S_FOCUS_OUT');
		public var S_FOCUS_LOST:Signal = new Signal('Input.S_FOCUS_LOST');
		public var S_FOCUS_IN:Signal = new Signal('Input.S_FOCUS_IN');
		public var S_DONE:Signal = new Signal('Input.S_DONE');
		public var S_KEYBOARD_CLOSED:Signal = new Signal('Input.S_KEYBOARD_CLOSED');
		
		public static var emulateSoftKeyboard:Boolean = false;
		
		private  var _value:String=null;
		private var _textColor:uint = 0;
		
		// INFOBOX
		protected var infoBox:Sprite;
		protected var infoBoxSrc:Sprite;
		protected var infoBoxTf:TextField;
		private var infoBoxValue:String;
		
		private var customKeyboardOpening:Boolean;
		private var type:String;
		private var isPassword:Boolean = false;
		protected var rounded:Boolean = false;
		private var downX:int;
		private var downY:int;
		protected var digitPressed:int = 0;
		protected var downBorder:Boolean = false;
		protected var borderVisibility:Boolean = true;
		private var oldType:String;
		
		// helpers do not dispose them, they are static 
		private static var tempPoint:Point = new Point();
		private static var tempRect:Rectangle = new Rectangle();
		private var hitzoneBox:Box = new Box(0xff0000, 1, 1, .6);
		private var _isFocused:Boolean = false;
		private var decimals:int = -1;
		private var maxValue:Number = NaN;
		private var minValue:Number = NaN;
		private var incorrect:Boolean;
		private var canBeIncorrect:Boolean;
		private var labelColor:Number;
		private var currentColor:Number = NaN;
		private var borderSelected:Boolean = false;
		private var line:Bitmap;
		private var rightClicker:Sprite;
		public var backgroundColor:int = 0xFFFFFF;
		private var _backgroundAlpha:Number = 1;
		
		public function get currentFontSize():Number 
		{
			return _currentFontSize;
		}
		
		private var _currentFontSize:Number = FontSize.BODY;
		private var textStart:int = 0;
		
		public function set backgroundAlpha(value:Number):void 
		{
			_backgroundAlpha = value;
		}
		protected var _roundRectangleRadius:Number = Config.DOUBLE_MARGIN;
		public var openKeyboardImmediately:Boolean;
		
		public function Input(type:String = 'mobile') {
			
			backgroundColor = Style.color(Style.COLOR_BACKGROUND);
			
			this.type = type;
			if (inputFormatBig == null)
				inputFormatBig = new TextFormat(Config.defaultFontName, FontSize.AMOUNT);
			if (infoBoxFormatBig == null)
				infoBoxFormatBig = new TextFormat(Config.defaultFontName, FontSize.BODY);
			_view = new ViewContainer(this);
			textField = new TextField();
			setFormat(inputFormatBig);
			rightClicker = new Sprite();
			/*rightClicker.graphics.beginFill(0, 1);
			rightClicker.graphics.drawRect(0, 0, 10, 10);
			rightClicker.graphics.endFill();*/
			_view.addChild(rightClicker);
		//	rightClicker.addEventListener(MouseEvent.MOUSE_DOWN, selectTextField);
			drawView();
		}
		
		public function setTextStart(value:int):void
		{
			textStart = value;
		}
		
		private function selectTextField(e:MouseEvent):void 
		{
			TweenMax.delayedCall(2.6, selectLastPosition);
		}
		
		private function selectLastPosition():void 
		{
			if (textField != null && MobileGui.stage != null)
			{
				setFocus();
				invokeSoftkeyboard(true);
				if (textField.length > 0)
				{
					textField.setSelection(0, textField.length - 1);
				}
				else{
					textField.setSelection(0, 0);
				}
			}
		}
		
		protected function setFormat(format:TextFormat):void {
			var sv:String = textField.text;
			textField.defaultTextFormat = format;
			if (textHeight == -1){
				textField.text = 'Qp`';
				textHeight = textField.textHeight + 4;
				textField.text = '';
			}
			textField.textColor = _textColor;
			textField.height = textHeight;
			textField.text = sv;
			
			updateFontSizeValue(format);
		}
		
		private function updateFontSizeValue(format:TextFormat):void 
		{
			if (format != null && format.size != null && !isNaN(Number(format.size)))
			{
				_currentFontSize = Number(format.size);
			}
		}
		
		public function updateTextFormat(format:TextFormat):void {
			var sv:String = textField.text;
			textField.defaultTextFormat = format;
			textField.text = 'Qp`';
			textField.setTextFormat(format);
			textHeight = textField.textHeight + 4;
			textField.text = '';
			
			textField.height = textHeight;
			textField.text = sv;
			
			updateFontSizeValue(format);
		}
		
		public function setInfoBox(text:String = 'info'):void {
			if (infoBox == null) {
				infoBox = new Sprite();
				infoBoxSrc = new Sprite();
				infoBoxTf = new TextField();
				infoBoxTf.selectable = false;
				infoBoxTf.mouseEnabled = false;
				infoBoxTf.defaultTextFormat = infoBoxFormatBig;
				infoBox.addChild(infoBoxSrc);
				infoBox.addChild(infoBoxTf);
				_view.addChild(infoBox);
			}
			infoBoxValue = text;
			infoBoxTf.text = infoBoxValue;
		//	infoBoxTf.border = Capabilities.isDebugger;
			
			deactivate();
			activate();
			drawView();
		}
		
		public function removeInfoBox(redrawView:Boolean = true):void {
			if (redrawView)
				deactivate();
			if (infoBoxSrc != null){
				infoBoxSrc.graphics.clear();
				infoBoxSrc = null;
				if (infoBox != null) {
					if (infoBox.parent != null)
						infoBox.parent.removeChild(infoBox);
					infoBox = null;
				}
				if (infoBoxTf != null)
					infoBoxTf.text = '';
				infoBoxTf = null;
				
				infoBoxValue = null;
			}
			if (redrawView) {
				activate();
				drawView();
			}
		}
		
		/**
		 * Sets element mode by MODE_INPUT or MODE_BUTTON constants.
		 * if mode button, input starts works as button, othercase as inputfield
		 * @param	mode String 
		 */
		public function setMode(mode:String):void {
			this.mode = mode;
			isPassword = false;
			if (mode == MODE_PASSWORD) {
				isPassword = true;
				mode = MODE_INPUT;
			}
			this.mode = mode;
			if (mode == MODE_INPUT)
				textField.type = TextFieldType.INPUT;
			else
				textField.type = TextFieldType.DYNAMIC;
			var _val:String = value != getDefValue()? value:"";
			if (_val != "") {
				setLabelText(getDefValue());
				value = _val;
			} else {
				onFocusOut();
			}
			if (activated) {
				deactivate();
				activate();
			}
		}
		
		/**
		 * Sets base params of elements. need to invoke after constructor
		 * @param	labelValue
		 * @param	mode
		 */
		public function setParams(labelValue:String = "",mode:String=MODE_INPUT):void {
			setMode(mode);
			setLabelValue(labelValue, labelColor);
		}

		private function setLabelValue(labelValue:String, textColor:Number = NaN):void {
			this.labelValue = labelValue;
			if (textField.text == "")
			{
				textField.text = labelValue;
				if (!isNaN(textColor)){
					labelColor = textColor;
					currentColor = textField.textColor;
					textField.textColor = textColor;
				}
			}
		}
		
		public function setLabelText(val:String, textColor:Number = NaN):void {
			labelValue = val;
			if (wasChanged == false) {
				if (textField.stage != null) {
					if(textField.stage.focus != textField)
						textField.text = labelValue;
				} else {
					textField.text = labelValue;
				}
				if (!isNaN(textColor)){
					labelColor = textColor;
					currentColor = textField.textColor;
					textField.textColor = textColor;
				}
			}
		}

		public function updateLabelVulue(labelValue:String = ""):void {
			this.labelValue = labelValue;
			setLabelValue(labelValue, labelColor);
			if (value == "") {
				// To force default label to redraw we call this method
				forceFocusOut();
			}
			drawView();
		}
		
		protected function drawView():void {
			if (isDisposed == true)
			{
				return;
			}
			
			_view.graphics.clear();
			_view.graphics.beginFill(backgroundColor, _backgroundAlpha);
			if (borderVisibility == true) {
				var colorBorder:Number = getBorderColor();
				_view.graphics.drawRect(0, 0, _width, int(_height));
				var lineThickness:int = int(Math.max(1, Config.FINGER_SIZE * .03));
				_view.graphics.lineStyle(lineThickness, colorBorder);
				_view.graphics.moveTo(0, int(_height) - lineThickness / 2);
				_view.graphics.lineTo(_width, int(_height) - lineThickness / 2);
			}
			else {
				_view.graphics.drawRect(0, 0, _width, _height);
			}
			_view.graphics.endFill();
			
			textField.y = Math.round(_height - _currentFontSize - Config.FINGER_SIZE * .2);
			
			var iboxPadd:int = 0;
			if (infoBox != null) {
				
				var padd:int = padding * .5;
				infoBoxTf.x = padd;
				infoBoxTf.width = infoBoxTf.textWidth + 4;
				infoBoxTf.height = infoBoxTf.textHeight + 4;
				infoBoxTf.y = Math.round(textField.y + textField.height * .5 - infoBoxTf.height * .5);
				
				infoBoxSrc.graphics.clear();
				
				infoBoxSrc.graphics.beginFill(Color.GREY_SSL, 1);
				infoBoxSrc.graphics.drawRoundRect(0, 0, int(infoBoxTf.width + padd * 2), infoBoxTf.height + padd, padd * 2, padd * 2);
				infoBoxSrc.x = int(infoBoxTf.x - padd);
				infoBoxSrc.y = int(infoBoxTf.y - padd * .5);
				iboxPadd = infoBoxSrc.width + Config.FINGER_SIZE * .15;
			}
			_view.addChild(hitzoneBox);
			
			textField.x = textStart + iboxPadd;
			textField.width = _width - textStart - iboxPadd;
			
			_view.addChild(textField);
			
			if (line != null)
			{
				if (line.bitmapData != null)
				{
					line.bitmapData.dispose();
					line.bitmapData = null;
				}
				line.bitmapData = UI.getHorizontalLine(0x33CC00, _width);
				line.y = linePosition;
			}
			rightClicker.x = textField.x + textField.width;
			rightClicker.y = textField.y;
			rightClicker.width = Config.FINGER_SIZE * .3;
			rightClicker.height = textField.height;
		}
		
		private function getBorderColor():Number 
		{
			if (borderSelected)
			{
				return Style.color(Style.ERROR_COLOR);
			}
			else{
				if (_isFocused == true)
				{
					return Color.GREEN;
				}
				else
				{
					return Style.color(Style.CONTROL_INACTIVE);
				}
			}
		}
		
		public function activate():void {
			if (activated == true)
				return;
			activated = true;
			if (textField != null && oldType != null)
				textField.type = oldType;
			if (mode == MODE_INPUT) {
				textField.needsSoftKeyboard = true;
				textField.mouseEnabled = true;
				_view.buttonMode = false;
				textField.addEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_ACTIVATE, onSKActivate);
				textField.addEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_ACTIVATING, onSKActivating);
				textField.addEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_DEACTIVATE, onSKDeactivating);
				textField.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPressed);
				textField.addEventListener(Event.CHANGE, onInputChanged);
				textField.addEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
				textField.addEventListener(FocusEvent.FOCUS_IN, onFocusIn);
				if (emulateSoftKeyboard) {
					textField.addEventListener(FocusEvent.FOCUS_IN, onESKFocusIn);
					textField.addEventListener(FocusEvent.FOCUS_OUT, onESKFocusOut);
				}
				
			} else if (mode == MODE_DIGIT || mode == MODE_PHONE || mode == MODE_DIGIT_DECIMAL) {
				textField.needsSoftKeyboard = false;
				textField.mouseEnabled = true;
				_view.buttonMode = true;
				textField.addEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
				textField.addEventListener(Event.CHANGE, onInputChanged);
				PointerManager.addTap(textField, onDigitModeTap);
			} else {
				textField.mouseEnabled = false;
				_view.buttonMode = true;
				PointerManager.addTap(view, onButtonModeViewTap);
			}
			if (infoBox != null)
				PointerManager.addTap(infoBox, onInfoBoxTap);
		}
		
		private function onKeyPressed(e:KeyboardEvent):void 
		{
			// done for ios
			if (e.keyCode == 13) {
				S_DONE.invoke();
			}
		}
		
		private function onInputChanged(e:Event):void {
			S_CHANGED.invoke();
		}
		
		public function deactivate():void {
			if (activated == false)
				return;
			activated = false;
			TweenMax.killDelayedCallsTo(selectLastPosition);
			SoftKeyboard.stopDetectHeight();
			
			
			if (MobileGui.stage.focus != null && MobileGui.stage.focus is TextField && MobileGui.stage.focus.parent != null && MobileGui.stage.focus.parent is Input)
			{
				
			}
			
			SoftKeyboard.closeKeyboard();
			
			if (textField != null) {
				oldType = textField.type;
				textField.type = TextFieldType.DYNAMIC;
			}
			textField.removeEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_ACTIVATE, onSKActivate);
			textField.removeEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_ACTIVATING, onSKActivating);
			textField.removeEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_DEACTIVATE, onSKDeactivating);
			
			textField.removeEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
			textField.removeEventListener(FocusEvent.FOCUS_IN, onFocusIn);
			
			textField.removeEventListener(FocusEvent.FOCUS_IN, onESKFocusIn);
			textField.removeEventListener(FocusEvent.FOCUS_OUT, onESKFocusOut);
			
			PointerManager.removeTap(view, onButtonModeViewTap);
			if (infoBox != null)
				PointerManager.removeTap(infoBox, onInfoBoxTap);
			PointerManager.removeTap(view, onDigitModeTap);
			PointerManager.removeTap(textField, onDigitModeTap);
			PointerManager.removeDown(MobileGui.stage, onDigitModeStageDown);
			PointerManager.removeUp(MobileGui.stage, onDigitModeStageUp);
			SoftKeyboard.S_KEY.remove(onDigitModeSoftKey);
			
			SoftKeyboard.S_OPENING.remove(onDigitModeSoftOpening);
			SoftKeyboard.S_OPENED.remove(onDigitModeSoftOpened);
			SoftKeyboard.S_CLOSING.remove(onDigitModeSoftOpened);
			SoftKeyboard.S_CLOSED.remove(onDigitModeSoftClosed);
			
			// hitzone 
			//PointerManager.removeUp(MobileGui.stage,onHitzoneStageUp);
			//PointerManager.removeDown(MobileGui.stage,onHitzoneDown);
		}
		
		// POINTER EVENTS===============================================
		//private function onHitzoneDown(e:Event = null):void 	{
			//_wasDown = true;
			//downPressed = true;
			//
			////if(usePreventOnDown){
				////e.preventDefault();
				////e.stopImmediatePropagation();
			////}
			//if (e is TouchEvent) {
				 //lastTouchID = (e as TouchEvent).touchPointID;
			//}
			//
			//downHitX =  MobileGui.stage.mouseX;
			//downHitY = MobileGui.stage.mouseY;
			//var isOverHitzone:Boolean = buttonHitTest(hitzoneBox,MobileGui.stage, TOP_OVERFLOW,LEFT_OVERFLOW ,MobileGui.stage.mouseX, MobileGui.stage.mouseY);
				//if (isOverHitzone) { 
					//trace("OVER INPUT HITZONE ON UP ");
					//MobileGui.stage.focus = textField;
					//if(mode == MODE_DIGIT || mode == MODE_DIGIT_DECIMAL) {
						//onDigitModeTap(null);
					//}
				//}
			////if (cancelOnVerticalMovement || cancelOnHorizontalMovement) {				
				////Loop.add(checkForMoved);
			////}
			////downState();
			////PointerManager.addUp(MobileGui.stage, onHitzoneStageUp);
		//
		//}
		
				
		//private function onHitzoneStageUp(e:Event = null):void 	{
			//
			//PointerManager.removeUp(MobileGui.stage, onHitzoneStageUp);
			//if (e!=null && e is TouchEvent) {
				//var newID:int = (e as TouchEvent).touchPointID;
				//if(newID == lastTouchID){
					////DialogManager.alert("tapped", e.toString());	
				//}else {
					////upState();
					//_wasDown =  false;
					//return; // you touched with another finger 	
				//}
			//}
			////upState();
			//if (_wasDown) {
				//// hittest 
				//var isOverHitzone:Boolean = buttonHitTest(hitzoneBox,MobileGui.stage, TOP_OVERFLOW,LEFT_OVERFLOW ,MobileGui.stage.mouseX, MobileGui.stage.mouseY);
				//if (isOverHitzone) { 
					//trace("OVER INPUT HITZONE ON UP ");
					//MobileGui.stage.focus = textField;
				//}
			//}
			//_wasDown =  false;
		//
		//}
		
		/** HIT TEST */
		public static function buttonHitTest(obj:DisplayObject,stage:Stage,  t:Number= 0, l:Number=0, x:Number = 0, y:Number = 0):Boolean {
			var result:Boolean  = false;
			tempPoint.x = 0;
			tempPoint.y = 0;
			var coord:Point =  obj.localToGlobal(tempPoint);
			//trace("Global coords", coord);
			//trace("Mouse coords", x, y);
			var rectX:int = coord.x -l;
			var rectY:int =  coord.y- t;
			var rectWidth:int = obj.width;
			var rectHeight:int = obj.height;			
			tempRect.x = rectX;
			tempRect.y = rectY;
			tempRect.width = rectWidth;
			tempRect.height = rectHeight;
			var hitRect:Rectangle = tempRect;
			tempPoint.x = x;
			tempPoint.y = y;
			result = hitRect.containsPoint(tempPoint);
			hitRect = null;
			coord = null;
			return result;					
		}
		
		public static function abs( value:Number ):Number {
			return 	(value ^ (value >> 31)) - (value >> 31);	
		}
		
		private function onDigitModeSoftClosed():void {
			removeListenersForDigitMode();
			
			customKeyboardOpening = false;
			invokeSoftkeyboard(false);
			S_KEYBOARD_CLOSED.invoke();
		}
		
		private function onDigitModeSoftOpening(h:int):void {
			customKeyboardOpening = true;
		}
		
		private function onDigitModeSoftOpened(h:int):void {
			customKeyboardOpening = false;
		}
		
		private function onDigitModeSoftKey(key:Object):void {
			if (key == SoftKeyboard.DONE) {
				onFocusOut();
				SoftKeyboard.closeKeyboard();
			} else {
				_isFocused = true;
				drawView();
				S_CHANGED.invoke();
				digitPressed++;
			}
		}
		
		private function onDigitModeStageUp(e:Event):void {
			if (digitPressed) {
				digitPressed--;
				return;
			}
			if (downX < e.target.mouseX - Config.FINGER_SIZE_DOT_5 || downX > e.target.mouseX + Config.FINGER_SIZE_DOT_5 ||
				downY < e.target.mouseY - Config.FINGER_SIZE_DOT_5 || downY > e.target.mouseY + Config.FINGER_SIZE_DOT_5)
					return;
			if (textField != null && textField.stage != null && textField.stage.focus == textField)
				return;
			onFocusOut();
			
			if (MobileGui.stage.focus != null && 
				MobileGui.stage.focus is TextField && 
				MobileGui.stage.focus.parent != null && 
				MobileGui.stage.focus.parent is ViewContainer && 
				(MobileGui.stage.focus.parent as ViewContainer).target is Input && 
				(MobileGui.stage.focus.parent as ViewContainer).target != this)
			{
				forceFocusOut();
				//another input opened
				SoftKeyboard.closeKeyboardImmediately();
				((MobileGui.stage.focus.parent as ViewContainer).target as Input).openKeyboardImmediately = true;
			//	SoftKeyboard.openKeyboard((MobileGui.stage.focus.parent as ViewContainer).target as Input);
			}
			else{
				SoftKeyboard.closeKeyboard();
			}
		}
		
		private function onDigitModeStageDown(e:Event):void {
			downX = e.target.mouseX;
			downY = e.target.mouseY;
		}
		
		public function requestKeyboard():void{
			setFocus();
			onDigitModeTap();
		}
		
		private function onDigitModeTap(e:Event=null):void {
			addListenersForDigitMode();
			digitPressed = 0;
			onFocusIn();
			if (openKeyboardImmediately == true)
			{
				openKeyboardImmediately = false;
				SoftKeyboard.openKeyboardImmediately(this);
			}
			else{
				SoftKeyboard.openKeyboard(this);
			}
		}
		
		private function addListenersForDigitMode():void {
			PointerManager.addDown(MobileGui.stage, onDigitModeStageDown);
			PointerManager.addUp(MobileGui.stage, onDigitModeStageUp);
			SoftKeyboard.S_KEY.add(onDigitModeSoftKey);
			SoftKeyboard.S_OPENING.add(onDigitModeSoftOpening);
			SoftKeyboard.S_OPENED.add(onDigitModeSoftOpened);
			SoftKeyboard.S_CLOSED.add(onDigitModeSoftClosed);
		}
		
		private function removeListenersForDigitMode():void {
			PointerManager.removeDown(MobileGui.stage, onDigitModeStageDown);
			PointerManager.removeUp(MobileGui.stage, onDigitModeStageUp);
			SoftKeyboard.S_KEY.remove(onDigitModeSoftKey);
			SoftKeyboard.S_OPENING.remove(onDigitModeSoftOpening);
			SoftKeyboard.S_OPENED.remove(onDigitModeSoftOpened);
			SoftKeyboard.S_CLOSED.remove(onDigitModeSoftClosed);
		}
		
		private function onInfoBoxTap(e:Event):void {
			S_INFOBOX_TAPPED.invoke();
		}
		
		private function onButtonModeViewTap(e:Event):void {
			S_TAPPED.invoke();
		}
		
		protected function onFocusOut(e:FocusEvent = null):void {
			if (isDisposed == true)
			{
				return;
			}
			
			if (_isFocused == true)
			{
				S_FOCUS_LOST.invoke();
			}
			
			/*if (mode == MODE_PHONE && MobileGui.softKeyboardOpened)
				updateLabelVisibility();*/
			
			_isFocused = false;
			drawView();
			
			if (MobileGui.stage.focus != textField)
				return;
			
			if (customKeyboardOpening == true && e != null && (mode == MODE_DIGIT || mode== MODE_DIGIT_DECIMAL || mode == MODE_PHONE) ) {
				e.preventDefault();
				e.stopPropagation();
				MobileGui.stage.focus = textField;
				return;
			}
			if (mode == MODE_DIGIT_DECIMAL && MobileGui.softKeyboardOpened)
				return;
			if (mode == MODE_DIGIT && MobileGui.softKeyboardOpened)
				return;
			if (mode == MODE_PHONE && MobileGui.softKeyboardOpened)
				return;
			forceFocusOut();
			
			S_FOCUS_OUT.invoke();
		}
		
		/**
		 * Attention!
		 * Use this method acurately!
		 * It is made to force default label to redraw in case inputfield contains only empty string
		 * We use this method to simulate focus out if needed, because there are situations 
		 * where get called deactivate method without focusing out, which in result cause BUG with label text 
		 */
		public function forceFocusOut():void {
		//	TweenMax.killDelayedCallsTo(selectLastPosition);
			if (textField == null) 
				return;
			
			updateLabelVisibility();
			
			S_FOCUS_OUT.invoke();
		}
		
		public function updateLabelVisibility():void 
		{
			var v:String = textField.text.replace(' ', '');
			if (v.length == 0){
				wasChanged = false;
				textField.displayAsPassword = false;
				if (labelValue == null) {
					textField.text = '';
				}
				else {
					textField.text = labelValue+'';
					if (!isNaN(labelColor)){
						textField.textColor = labelColor;
					}
				}
			}
		}
		
		private function onFocusIn(e:FocusEvent = null):void {
			//trace("!!!");
			_isFocused = true;
			TweenMax.killDelayedCallsTo(selectLastPosition);
			if (!activated) return; // Alexey addded inache posle deactivate focus opjatj rabotaet
			if (wasChanged == false) {
				wasChanged = true;
				textField.text = '';
				textField.displayAsPassword = isPassword;
			}
			// Zapuskaem mehanizm proverki visoti klaviaturi
			if (!SoftKeyboard.extensionKeyboardHeightDetected) {
				SoftKeyboard.startDetectHeight();
			}
			
			if (MobileGui.softKeyboardOpened && SoftKeyboard.getInstance()!=null)
				SoftKeyboard.getInstance().updateCarretIndex(); 
			S_FOCUS_IN.invoke();
			setCurrentColor();
			drawView();
		}
		
		public function setCurrentColor():void
		{
			if (!isNaN(currentColor)){
				textField.textColor = currentColor;
			}
		}
		
		private function onESKFocusIn(e:FocusEvent):void {
			invokeSoftkeyboard(true);
		}
		
		private function onESKFocusOut(e:FocusEvent):void {
			invokeSoftkeyboard(false);
		}
		
		private function onSKActivate(e:SoftKeyboardEvent):void {
			invokeSoftkeyboard(true);
		}
		
		private function onSKActivating(e:SoftKeyboardEvent):void {
			invokeSoftkeyboard(true);
		}
		
		private function onSKDeactivating(e:SoftKeyboardEvent):void {
			invokeSoftkeyboard(false);
		}
		
		private function invokeSoftkeyboard(val:Boolean):void{
			TweenMax.delayedCall((Config.PLATFORM_ANDROID && mode == MODE_INPUT && val == false) ? 10 : 1, function():void {
				echo("Input","invokeSoftkeyboard", "TweenMax.delayedCall");
				if (S_SOFTKEYBOARD != null)
					S_SOFTKEYBOARD.invoke(val);
				if (val == false)
					onFocusOut();
			}, null, true);
		}
		
		override public function dispose():void {
			deactivate();
			TweenMax.killDelayedCallsTo(selectLastPosition);
			if (_view is ViewContainer)
			{
				(_view as ViewContainer).target = null;
			}
			
			removeListenersForDigitMode();
			
			if (line != null)
			{
				UI.destroy(line);
				line = null;
			}
			
			removeInfoBox(false);
			invokeSoftkeyboard(false);
			
			S_TAPPED.dispose();
			S_INFOBOX_TAPPED.dispose();
			S_CHANGED.dispose();
			S_FOCUS_OUT.dispose();
			S_FOCUS_LOST.dispose();
			S_FOCUS_IN.dispose();
			
			super.dispose();
		}
		
		public function get inUse():Boolean { return _inUse; }
		public function set inUse(value:Boolean):void {
			_inUse = value;
			if (_inUse == false)
				dispose();
		}
		
		public function getTextField():TextField {
			return textField;
		}
		
		public function getMode():String{
			return mode;
		}
		
		public function getInfoBoxValue():String{
			return infoBoxValue;
		}
		
		public function get value():String{
			if (textField.text == labelValue)
				return "";
			return textField.text;
		}
		
		public function set value(value:String):void {
			if (value == null) {
				textField.text = '';
				wasChanged = false;
				return;
			}
			textField.text = value;
			if (textField.displayAsPassword != isPassword)
				textField.displayAsPassword = isPassword;
			setIncorrect(false);
			wasChanged = true;
		}
		
		public function get width():int { return _width; }
		public function set width(value:int):void {
			_width = value;
			drawView();
		}
		
		public function get height():int
		{
			return view.height;
		}
		
		public function setRoundRectangleRadius(value:Number):void {
			_roundRectangleRadius = value;
		}
		
		public function setRoundBG(val:Boolean):void {
			rounded = true;
			drawView();
		}
		
		public function setDownBorder(val:Boolean):void {
			downBorder = val;
		}
		
		public function setBorderVisibility(val:Boolean):void {
			borderVisibility = val;
		}
		
		public function setFocus():void {
			if (textField != null)
				MobileGui.stage.focus = textField;
		}
		
		public function getDefValue():String {
			return labelValue;
		}
		
		public function getWasChanged():Boolean {
			return wasChanged;
		}
		
		public function setTextColor(col:uint):void{
			_textColor = col;
			if (textField != null){
				textField.textColor = _textColor;
			}
		}
		
		/**
		 * clear value and show deff value (labelValue) // "Amount";
		 */
		public function resetValue():void {
			value = null;
			forceFocusOut();
		}
		
		public function getDecimals():int { return decimals; }
		public function setDecimals(val:int):void {
			decimals = val;
		}
		
		public function getMaxValue():Number { return maxValue; }
		public function setMaxValue(val:Number):void {
			canBeIncorrect = true;
			maxValue = val;
		}
		
		public function getMinValue():Number { return minValue; }
		public function setMinValue(val:Number):void {
			canBeIncorrect = true;
			minValue = val;
		}
		
		public function getIncorrect():Boolean { return incorrect; }
		public function setIncorrect(val:Boolean):void {
			incorrect = val;
			if (canBeIncorrect == true) {
				if (value == "")
					textField.textColor = _textColor;
				else
					textField.textColor = (val == true) ? 0xFF0000 : _textColor;
			}
		}
		
		public function selectBorder():void {
			borderSelected = true;
			drawView();
		}
		
		public function unselectBorder():void {
			borderSelected = false;
			drawView();
		}
		
		public function toMaterialStyle():void 
		{
			borderVisibility = false;
			line = new Bitmap();
			_view.addChild(line);
		}
		
		public function disable():void 
		{
			if (textField != null)
			{
				textField.type = TextFieldType.DYNAMIC;
			}
		}
		
		public function enable():void 
		{
			if (textField != null)
			{
				textField.type = TextFieldType.INPUT;
			}
		}
		
		public function getTextWidth():int 
		{
			if (textField != null)
			{
				return textField.textWidth;
			}
			return 0;
		}
		
		public function get textAscent():int 
		{
			if (textField != null)
			{
				var line:TextLineMetrics = textField.getLineMetrics(0);
				return line.ascent + 2;
			}
			return 0;
		}
		
		public function get linePosition():int
		{
			return _height - Style.getLineThickness();
		}
	}
}