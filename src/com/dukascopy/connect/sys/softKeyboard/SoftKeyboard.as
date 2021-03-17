package com.dukascopy.connect.sys.softKeyboard {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.HitZoneData;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.screens.serviceScreen.Overlay;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.nativeExtensionController.NativeExtensionController;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.type.HitZoneType;
	import com.greensock.TweenMax;
	import com.telefision.sys.signals.Signal;
	import com.telefision.utils.Loop;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.StatusEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextLineMetrics;
	
	/**
	 * ...
	 * @author IgorBloom
	 */
	
	public class SoftKeyboard {
		
		[Embed(source = "icon/icon_backspace.png")] static public var ASSET_ICON_BACKSPACE:Class;
		
		private static var _extensionKeyboardHeightDetected:Boolean = false;
		private static var _detectedKeyboardHeight:int = -1;
		
		static public var S_KEY:Signal = new Signal("SoftKeyboard.S_KEY");
		static public var S_OPENING:Signal = new Signal("SoftKeyboard.S_OPENING");
		static public var S_OPENED:Signal = new Signal("SoftKeyboard.S_OPENED");
		static public var S_CLOSING:Signal = new Signal("SoftKeyboard.S_CLOSING");
		static public var S_CLOSED:Signal = new Signal("SoftKeyboard.S_CLOSED");
		static public var S_REAL_HEIGHT_DETECTED:Signal = new Signal("SoftKeyboard.S_REAL_HEIGHT_DETECTED");
		
		static public const NEWLINE:int = -1;
		static public const DONE:int = 1001;
		static public const BACKSPACE:int = 1002;
		static public const ZERO:int = 1003;
		
		static private var highlightBox:Bitmap = new Bitmap(new ImageBitmapData("SoftKeyboard.highlightBox", 2, 2, false, 0x000000));
		static private var instance:SoftKeyboard;
		static private var stage:Stage;
		static private var busy:Boolean = false;
		
		public static function openKeyboard(input:Input):void{
			if (instance == null)
				instance = new SoftKeyboard(new Sinit());
			stage = input.view.stage;
			if (stage == null)
				return;
			instance.show(input);
		}
		
		public static function openKeyboardImmediately(input:Input):void{
			if (instance == null)
				instance = new SoftKeyboard(new Sinit());
			stage = input.view.stage;
			if (stage == null)
				return;
			instance.showImmediately(input);
		}
		
		public static function getInstance():SoftKeyboard {
			return instance;
		}
		
		static public function get height():int {
			var targetDimm:int = MobileGui.stage.stageHeight;
			if (MobileGui.stage.stageHeight < MobileGui.stage.stageWidth)
				targetDimm = MobileGui.stage.stageWidth;
			
			return Config.FINGER_SIZE * 4 + Config.APPLE_BOTTOM_OFFSET;	
			return Math.round(targetDimm * .387);
		}
		
		static public function get contentHeight():int {
			return height - Config.APPLE_BOTTOM_OFFSET;
		}
		
		static public function closeKeyboard():void{
			if (instance == null)
				return;
			dehighlightKey();
			instance.hide();
		}
		
		static public function closeKeyboardImmediately():void{
			if (instance == null)
				return;
			dehighlightKey();
			instance.hideImmediately();
		}
		
		private static var __rr:Rectangle = null;
		private static function __rectangle(x:int, y:int, w:int, h:int):Rectangle{
			if (__rr == null){
				__rr = new Rectangle(x, y, w, h);
				return __rr;
			}
			__rr.x = x;
			__rr.y = y;
			__rr.width = w;
			__rr.height = h;
			return __rr;
		}
		
		private static var __pp:Point = null;
		private static function __point(x:int, y:int):Point{
			if (__pp == null){
				__pp = new Point(x, y);
				return __pp;
			}
			__pp.x = x;
			__pp.y = y;
			return __pp;
		}
		
		private static var __mat:Matrix = null;
		private static function get __matrix():Matrix {
			if (__mat == null){
				__mat = new Matrix();
				return __mat;
			}
			__mat.identity();
			return __mat;
		}
		
		private var view:Sprite;
		private var keyMap:Bitmap;
		private var wasCreated:Boolean = false;
		private var currentTextField:TextField;
		private var carret:Shape;
		private var oldCarretIndex:int=-1;
		private var stageOldNumChildren:int=-1;
		private var oldTextFieldHeight:int=-1;
		private var oldTextFieldY:int=-1;
		private var oldTextFieldX:int=-1;
		private var input:Input;
		private var _width:int = 400;
		private var buttonH:int;
		private var buttonW:int;
		private var currentKeys:Array;
		private var flatButton:SoftKeyboardFlatButton;
		private var currentCarretIndex:int = 0;
		private var _showed:Boolean = false;
		
		public function SoftKeyboard(sinit:Sinit) { }
		
		private function createView():void {
			
			if (view == null)
				view = new Sprite();
			view.buttonMode = true;
			_width = stage.stageWidth;
			
			
			if (keyMap == null){
				keyMap = new Bitmap();
				keyMap.y = height + 1;
			}
			view.addChild(keyMap);
			
			if (input.getMode() == Input.MODE_PHONE) {
				// DRAW PHONE KEYBOARD
				var keys:Array = ['1', ['2','ABC'], ['3','DEF'], SoftKeyboard.NEWLINE, ['4','GHI'], ['5','JKL'], ['6','MNO'],  SoftKeyboard.NEWLINE, ['7','PQRS'], ['8','TUV'], ['9','WXYZ'],  SoftKeyboard.NEWLINE,SoftKeyboard.BACKSPACE ,  ['0','+'],  SoftKeyboard.DONE];
				buildKeys(keys,'digit');
			}
			
			if (input.getMode() == Input.MODE_DIGIT) {
				// DRAW DIGIT KEYBOARD
				var keys2:Array = ['1', ['2','ABC'], ['3','DEF'], SoftKeyboard.NEWLINE, ['4','GHI'], ['5','JKL'], ['6','MNO'],  SoftKeyboard.NEWLINE, ['7','PQRS'], ['8','TUV'], ['9','WXYZ'],  SoftKeyboard.NEWLINE,SoftKeyboard.BACKSPACE , SoftKeyboard.ZERO,  SoftKeyboard.DONE];
				buildKeys(keys2,'digit');
			}
			
			if (input.getMode() == Input.MODE_DIGIT_DECIMAL) {
				// DRAW DIGIT KEYBOARD
				var keys3:Array = ["","",SoftKeyboard.DONE,SoftKeyboard.NEWLINE, '1', ['2','ABC'], ['3','DEF'], SoftKeyboard.NEWLINE, ['4','GHI'], ['5','JKL'], ['6','MNO'],  SoftKeyboard.NEWLINE, ['7','PQRS'], ['8','TUV'], ['9','WXYZ'],  SoftKeyboard.NEWLINE, '.', SoftKeyboard.ZERO, SoftKeyboard.BACKSPACE ];
				buildKeys(keys3,'digit');
			}
		}
		
		private function buildKeys(keys:Array, type:String):void {
			var n:int;
			var l:int = keys.length;
			
			// CALCL ROWS COUNT
			var rowsCount:int = 0;
			var colsCount:int = 0;
			var wasColsCounted:Boolean = false;
			
			for (n = 0; n < l; n++) {
				if (keys[n] == SoftKeyboard.NEWLINE) {
					wasColsCounted = true;
					rowsCount++;
				}
				if (wasColsCounted == false)
					colsCount++;
			}
			rowsCount++;
			buttonH = contentHeight / rowsCount;
			buttonW = _width / colsCount;
			
			var needCreateBMD:Boolean = true;
			if (keyMap.bitmapData != null) {
				if (keyMap.bitmapData.width == _width && keyMap.bitmapData.height != height){
					keyMap.bitmapData.fillRect(keyMap.bitmapData.rect, 0);
					needCreateBMD = false;
				}else{
					keyMap.bitmapData.dispose();
					keyMap.bitmapData = null;
				}
			}
			if(needCreateBMD)
				keyMap.bitmapData = new ImageBitmapData("keyboard keymap", _width, height, true, 0xFFFFFFFF);
			
			// DRAW BUTTONS
			flatButton = new SoftKeyboardFlatButton();
			currentKeys = [];
			var y:int = 0;
			var x:int = 0;
			var mat:Matrix;
			for (n = 0; n < l; n++) {
				if (keys[n] == SoftKeyboard.NEWLINE){
					y += buttonH;
					x = 0;
					continue;
				}
				currentKeys[currentKeys.length] =[x,y,buttonW,buttonH,keys[n]];
				mat= __matrix;
				mat.tx = x;
				mat.ty = y;
				keyMap.bitmapData.drawWithQuality(
					flatButton.getView(buttonW, buttonH, keys[n],isSystemKey(keys[n]))
					,mat, null, null, null, true, StageQuality.HIGH);
				x += buttonW;
			}
			
		}
		
		private function isSystemKey(key:Object):Boolean{
			return false;
		}
		
		private function clearView():void {
			if (keyMap != null && keyMap.bitmapData != null) {
				keyMap.bitmapData.dispose();
				keyMap.bitmapData = null;
			}
			if (view != null)
				view.graphics.clear();
		}
		
		public function showImmediately(input:Input):void {
			if (_showed == true)
				return;
			busy = true;
			NativeExtensionController.S_ORIENTATION_CHANGE.add(onOrientationChange);
			
			this.input = input;
			if (stage == null)
				return;
			
			if (wasCreated == true)
				return;
			
			wasCreated = true;
			createView();
			
			stage.addChild(view);
			view.y = stage.stageHeight - height;
			currentTextField = input.getTextField();
			
			//TODO SAVE INITED PARAMS BEFORE
			currentTextField.selectable = true;
			currentTextField.mouseEnabled = true;
			S_OPENING.invoke(0);
			TweenMax.killTweensOf(keyMap);
			
			keyMap.y = 0;
			onShowUpdate();
		//	showed();
			TweenMax.to(keyMap, 0.2, { y:0,onComplete:showed,onUpdate:onShowUpdate,useFrames:false} );
		}
		
		public function show(input:Input):void {
			if (_showed == true)
				return;
			busy = true;
			NativeExtensionController.S_ORIENTATION_CHANGE.add(onOrientationChange);
			
			this.input = input;
			if (stage == null)
				return;
			
			if (wasCreated == true)
				return;
			
			wasCreated = true;
			createView();
			
			stage.addChild(view);
			view.y = stage.stageHeight - height;
			currentTextField = input.getTextField();
			
			//TODO SAVE INITED PARAMS BEFORE
			currentTextField.selectable = true;
			currentTextField.mouseEnabled = true;
			S_OPENING.invoke(0);
			TweenMax.killTweensOf(keyMap);
			TweenMax.to(keyMap, 0.2, { y:0,onComplete:showed,onUpdate:onShowUpdate,useFrames:false} );
		}
		
		private function onOrientationChange():void {
			removeCarret();
			hided();
			TweenMax.killTweensOf(keyMap);
			NativeExtensionController.S_ORIENTATION_CHANGE.remove(onOrientationChange);
		}
		
		private function onShowUpdate():void {
			S_OPENING.invoke(height - keyMap.y);
		}
		
		private function showed():void {
			busy = false;
			_showed = true;
			currentCarretIndex = currentTextField.caretIndex;
			setCarret();
			PointerManager.addDown(view, onDown);
			PointerManager.addUp(view.stage, onUp);
			S_OPENED.invoke(height);
		}
		
		private function hideImmediately():void {
			NativeExtensionController.S_ORIENTATION_CHANGE.remove(onOrientationChange);
			removeCarret();
			TweenMax.killTweensOf(keyMap);
			if (carret != null) {
				TweenMax.killTweensOf(carret);
				carret.graphics.clear();
			}
			PointerManager.removeDown(view, onDown);
			PointerManager.removeUp(view.stage, onUp);
			busy = true;
			keyMap.y = height;
			hided();
		}
		
		private function hide():void {
			NativeExtensionController.S_ORIENTATION_CHANGE.remove(onOrientationChange);
			removeCarret();
			TweenMax.killTweensOf(keyMap);
			if (carret != null) {
				TweenMax.killTweensOf(carret);
				carret.graphics.clear();
			}
			PointerManager.removeDown(view, onDown);
			PointerManager.removeUp(view.stage, onUp);
			busy = true;
			TweenMax.to(keyMap, 12, { y:height, onComplete:hided, onUpdate:onHideUpdate, useFrames:true } );
		}
		
		private function hided():void {
			busy = false;
			clearView();
			currentTextField = null;
			currentKeys = [];
			if (flatButton != null)
				flatButton.dispose();
			flatButton = null;
			wasCreated = false;
			removeCarret();
			if (view != null && view.parent != null)
				view.parent.removeChild(view);
			view = null;
			instance = null;
			_showed = false;
			S_CLOSED.invoke();
		}
		
		private function onHideUpdate():void{
			S_CLOSING.invoke(height - keyMap.y);
		}
		
		private function setCarretIndex():void {
			if (currentTextField == null)
				removeCarret();
			else
				setCarret();
		}
		
		private function onDown(e:Object = null):void {
			if (busy == true)
				return;
			var paramsObj:Array = getParamsUnderPoint(e.localX, e.localY);
			TweenMax.killDelayedCallsTo(onLongPress);
			if (paramsObj != null) {
				paramsObj[paramsObj.length] = e.stageX;
				paramsObj[paramsObj.length] = e.stageY;
				highlightKey(paramsObj);
				sendKeyToTextFiled(paramsObj[4]);
				TweenMax.delayedCall(1,onLongPress,[paramsObj[4]]);
			}
		}
		
		private function onLongPress(key:Object):void {
			var trueKey:String = '';
			if (key is Number) {
				trueKey = Number(key).toString();
				// CHECK FOR SYSKEYS
				if (Number(key) == SoftKeyboard.BACKSPACE) {
					delText();
					S_KEY.invoke(key);
					TweenMax.killDelayedCallsTo(dellayedDelText);
					TweenMax.delayedCall(.1, dellayedDelText);
					return;
				}
			}
		}
		
		private function dellayedDelText():void {
			TweenMax.killDelayedCallsTo(dellayedDelText);
			TweenMax.delayedCall(.07, dellayedDelText);
			delText();
			S_KEY.invoke(SoftKeyboard.BACKSPACE);
		}
		
		private static function onUp(e:Event = null):void {
			if (busy == true)
				return;
			dehighlightKey();
			if (instance != null) {
				TweenMax.killDelayedCallsTo(instance.onLongPress);
				TweenMax.killDelayedCallsTo(instance.dellayedDelText);
			}
		}
	
		private  function highlightKey(params:Array):void {
			if (params != null && params[4] != "") {
				highlightBox.alpha = .2;
				highlightBox.x = params[0];
				highlightBox.y = params[1];
				highlightBox.width = params[2];
				highlightBox.height = params[3];
				highlightBox.visible = true;
				view.addChild(highlightBox);
				
				/*var zone:HitZoneData = new HitZoneData();
				var touch:Point = new Point(params[0], params[1]);
				touch = view.localToGlobal(touch);
				zone.x = touch.x;
				zone.y = touch.y;
				zone.width = params[2];
				zone.height = params[3];
				zone.touchPoint = new Point(params[4], params[5]);
				Overlay.displayTouch(zone);*/
			}			
		}
		
		private static  function dehighlightKey():void	{
			highlightBox.visible = false;
		}
		
		private function sendKeyToTextFiled(key:Object):void{
			if (key == null)
				return;
			var trueKey:String = '';
			if (key is Array){
				trueKey = key[0];
			} else if (key is Number) {
				trueKey = Number(key).toString();
				if (Number(key) == SoftKeyboard.BACKSPACE) {
					delText();
					S_KEY.invoke(key);
					return;
				}
				if (Number(key) == SoftKeyboard.DONE) {
					S_KEY.invoke(key);
					return;
				}
				if (Number(key) == SoftKeyboard.ZERO)
					trueKey = '0';
			} else
				trueKey = key as String;
			if (trueKey == null)
				return;
			setText(trueKey);
			S_KEY.invoke(trueKey);
		}
		
		private  function getParamsUnderPoint(mx:int, my:int):Array {
			var n:int = 0;
			var l:int = currentKeys.length;
			for (n; n < l; n++) {
				if (__rectangle(currentKeys[n][0], 
								currentKeys[n][1], 
								currentKeys[n][2], 
								currentKeys[n][3]).containsPoint(__point(mx, my))) {
					return currentKeys[n];
				}
			}
			return null;
		}
		
		private function getKeyUnderPoint():Object{
			var n:int = 0;
			var l:int = currentKeys.length;
			for (n; n < l; n++) {
				if(__rectangle(currentKeys[n][0], currentKeys[n][1], currentKeys[n][2], currentKeys[n][3]).containsPoint(__point(view.mouseX, view.mouseY))) {
					return currentKeys[n][4];
				}
			}
			
			return null;
		}
		
		/*
		private function startFastBackSpace():void {
			backSpaceTimer ||= new Timer(40, 0);
			backSpaceTimer.reset();
			backSpaceTimer.start();
			backSpaceTimer.addEventListener(TimerEvent.TIMER, onFastBackSpace);
		}*/
		
		/*private function onFastBackSpace(e:TimerEvent):void {
			delText(true);
		}*/
		
		/*private function stopFastBackSpace():void {
			if (backSpaceTimer == null)
				return;
			backSpaceTimer.reset();
			backSpaceTimer.stop();
		}*/
		
		/*public function setTextOnLongPress(str:String):void {
			if (currentTextField == null)
				return;
			if (str == null || str=='')
				return;
			if (str == "0" && currentTextField.text.charAt(0) == "0" && currentCarretIndex == 1) {
				if (input!= null && input.getMode() == Input.MODE_PHONE) {
					currentTextField.text = "+" + currentTextField.text.substr(1);
					setCarret();
				}
				return;
			}
		}*/
		
		private function setText(str:String):void {
			if (currentTextField == null)
				return;
			if (str == null || str == '')
				return;
			
			var startSelIndex:int = currentTextField.selectionBeginIndex;
			var endSelIndex:int = currentTextField.selectionEndIndex;
			if (startSelIndex == endSelIndex) {
				startSelIndex = currentCarretIndex;
				endSelIndex = currentCarretIndex;
			}
			var currentText:String = currentTextField.text;
			var currentTextFirstPart:String = currentText.substring(0, startSelIndex);
			var currentTextSecondPart:String = currentText.substring(endSelIndex);
			
			if (input != null) {
				if (input.getMode() == Input.MODE_DIGIT_DECIMAL) {
					if (str == "." && (currentTextFirstPart.indexOf(str) != -1 || currentTextSecondPart.indexOf(str) != -1))
						return;
					currentText = currentTextFirstPart + str + currentTextSecondPart;
					if (checkForLimits(currentText, true)) {
						input.setIncorrect(false);
					} else {
						input.setIncorrect(true);
					}
				} else if (input.getMode() == Input.MODE_DIGIT) {
					if (str == ".")
						return;
					currentText = currentTextFirstPart + str + currentTextSecondPart;
				} else {
					if (currentText.charAt(0) == "+" && currentCarretIndex == 0)
						return;
					currentText = currentText.substr(0, currentCarretIndex) + str + currentText.substr(currentCarretIndex);
				}
			} else {
				if (currentText.charAt(0) == "+" && currentCarretIndex == 0)
					return;
				currentText = currentText.substr(0, currentCarretIndex) + str + currentText.substr(currentCarretIndex);
			}
			currentTextField.text = currentText;
			currentCarretIndex = startSelIndex + str.length;
			currentTextField.scrollH = currentTextField.maxScrollH;
			
			setCarret();
		}
		
		private function checkForLimits(val:String, chechDecimals:Boolean = false):Boolean {
			if (val == null || val.length == 0)
				return false;
			if (val == ".")
				return false;
			if (val == "0")
				return true;
			if (val.length > 1)
				if (val.charAt(0) == "0" && val.charAt(1) != ".")
					return false;
			if (chechDecimals == true && input.getDecimals() != -1) {
				var ind:int = val.indexOf(".");
				if (ind != -1 && val.length - ind - 2 == input.getDecimals())
					return false;
			}
			var value:Number = Number(val);
			if (isNaN(value) == true)
				return false;
			if (isNaN(input.getMaxValue()) == false && value > input.getMaxValue())
				return false;
			if (isNaN(input.getMinValue()) == false) {
				if (val.length > 1 && val.charAt(0) == "0" && val.charAt(1) == ".") {
					var valueTemp:Number = Number(val + "1");
					if (valueTemp < input.getMinValue())
						return false;
				} else if (input.getMinValue() > value)
					return false;
			}
			return true;
		}
		
		private function delText(byWord:Boolean = false):void {
			if (currentTextField == null)
				return;
			if (currentCarretIndex < 1)
				return;
			var val:String = currentTextField.text.substr(0, currentCarretIndex - 1) + currentTextField.text.substr(currentCarretIndex);
			if (checkForLimits(val, true) == true)
				input.setIncorrect(false);
			else
				input.setIncorrect(true);
			currentTextField.text = val;
			currentCarretIndex--;
			currentTextField.scrollH = currentTextField.maxScrollH;
			setCarret();
		}
		
		public static function startDetectHeight():void	{
			if (Config.PLATFORM_ANDROID)
			{
			//	Loop.add(checkHeight);
				
				if (MobileGui.androidExtension != null)
				{
					MobileGui.androidExtension.addEventListener(StatusEvent.STATUS, extensionAndroidStatusHandler);
				}
			}
		}
		
		public static function stopDetectHeight():void	{
			if (Config.PLATFORM_ANDROID)
			{
			//	Loop.remove(checkHeight);	
				
				if (MobileGui.androidExtension != null)
				{
					MobileGui.androidExtension.removeEventListener(StatusEvent.STATUS, extensionAndroidStatusHandler);
				}
			}
		}
		
		private static function extensionAndroidStatusHandler(e:StatusEvent):void
		{
			if (e.code == "keyboardHeight") {
				if (int(e.level) > 0) {
					stopDetectHeight();
					_detectedKeyboardHeight = int(e.level);
					_extensionKeyboardHeightDetected = true;
					S_REAL_HEIGHT_DETECTED.invoke();
				}
			}
			if (e.code == "keyboardHeightReal") {
				if (int(e.level) > 0) {
					stopDetectHeight();
					_detectedKeyboardHeight = int(e.level);
					_extensionKeyboardHeightDetected = true;
					S_REAL_HEIGHT_DETECTED.invoke();
				}
			}
		}
		
		static private function checkHeight():void 	{
			var h:int = NativeExtensionController.getKeyboardHeightDeprecated();
			if (h > 200) {
				stopDetectHeight();
				_detectedKeyboardHeight = h;
				//_extensionKeyboardHeightDetected = true;
				S_REAL_HEIGHT_DETECTED.invoke();
			}
		}
		
		static public function getRealKeyboardHeight():int {
			return NativeExtensionController.getKeyboardHeightDeprecated();
		}
		
		static public function get extensionKeyboardHeightDetected():Boolean 	{ return _extensionKeyboardHeightDetected; }		
		static public function get detectedKeyboardHeight():int { return _detectedKeyboardHeight; }
		
		public function get isShowed():Boolean {
			return _showed;
		}
	
		
		public static function getPrecalculatedKeyboardHeight():int
		{
			if(Config.PLATFORM_ANDROID){
				var targetDimm:int = MobileGui.stage.stageHeight;
				if (MobileGui.stage.stageHeight < MobileGui.stage.stageWidth)
					targetDimm = MobileGui.stage.stageWidth;			
				// TODO - SET ANDROID KEYBOARD HEIGHT
				return Math.round(targetDimm * .387); 
			}else {
				return 550;	
			}
			
		}
		
	
		// ------------------------------------------------------------------ CARRET
		private function setCarret():void {
			if (carret == null)
				carret = new Shape();
			
			TweenMax.killTweensOf(carret);
			
			var pt:Point = new Point();
			if (currentTextField.parent) {
				pt.x = currentTextField.x;
				pt.y = currentTextField.y;
				if (carret.parent == null)
					currentTextField.parent.addChild(carret);
			}
			
			carret.alpha = 1;
			onCarretAlpha0();
			
			var lm:TextLineMetrics = currentTextField.getLineMetrics(0);
			var h:int = lm.height;
			
			var charBounds:Rectangle = currentTextField.getCharBoundaries(currentCarretIndex/*currentTextField.caretIndex*/);
			if (charBounds == null) {
				if(currentTextField.text.length>0){
					charBounds = currentTextField.getCharBoundaries(currentTextField.text.length - 1);
					if(charBounds!=null)
						charBounds.x += charBounds.width;
				}
			}
			
			if (charBounds == null)
				charBounds = __rectangle(0, 0, 20, 20);
			
			carret.visible = true;
			carret.x = pt.x
			carret.y = pt.y;
			carret.graphics.clear();
			carret.graphics.beginFill(0xFF0000, 1);
			carret.graphics.drawRect(charBounds.x - currentTextField.scrollH, charBounds.y, 2, h);
		}
		
		private function onCarretAlpha0():void {
			TweenMax.to(carret, 20, { useFrames:true,alpha:0,onComplete:onCarretAlpha1 } );
		}

		private function onCarretAlpha1():void {
			TweenMax.to(carret, 20, { useFrames:true,alpha:1,onComplete:onCarretAlpha0 } );
		}
		
		public function removeCarret():void {
			if (carret) {
				carret.visible = false;
				TweenMax.killTweensOf(carret);
				if (carret.parent)
					carret.parent.removeChild(carret);
				carret.graphics.clear();
				carret = null;
			}
		}
		
		public function updateCarretIndex():void {
			currentCarretIndex = currentTextField.caretIndex;
			setCarret();
		}
	}
}

class Sinit {}