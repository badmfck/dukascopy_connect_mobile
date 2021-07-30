package com.dukascopy.connect.data.screenAction.customActions {
	
	import assets.IconInfoClip;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.ScreenAction;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.screens.ChatScreen;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.softKeyboard.SoftKeyboard;
	import com.greensock.TweenMax;
	import flash.events.Event;
	import flash.events.FocusEvent;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	
	public class GetNumericKeyboardAction extends ScreenAction implements IScreenAction {
		private var digitPressed:Number;
		private var _isFocused:Boolean;
		private var openKeyboardImmediately:Boolean;
		private var customKeyboardOpening:Boolean;
		private var downX:Number;
		private var downY:Number;
		private var input:Input;
		
		public function GetNumericKeyboardAction() {
			
		}
		
		public function execute():void {
			
			addListenersForDigitMode();
			digitPressed = 0;
			onFocusIn();
			
			input = new Input(Input.MODE_DIGIT_DECIMAL);
			input.setMode(Input.MODE_DIGIT_DECIMAL);
			input.view.visible = false;
			MobileGui.stage.addChild(input.view);
			
			if (openKeyboardImmediately == true)
			{
				openKeyboardImmediately = false;
				SoftKeyboard.openKeyboardImmediately(input);
			}
			else{
				SoftKeyboard.openKeyboard(input);
			}
		}
		
		override public function dispose():void
		{
			super.dispose();
			removeListenersForDigitMode();
			if (input != null && input.view != null)
			{
				if (MobileGui.stage.contains(input.view))
				{
					MobileGui.stage.removeChild(input.view);
				}
				input.dispose();
				input = null;
			}
		}
		
		private function onFocusIn(e:FocusEvent = null):void {
			//trace("!!!");
			_isFocused = true;
			
			// Zapuskaem mehanizm proverki visoti klaviaturi
			if (!SoftKeyboard.extensionKeyboardHeightDetected) {
				SoftKeyboard.startDetectHeight();
			}
			
			if (MobileGui.softKeyboardOpened && SoftKeyboard.getInstance()!=null)
				SoftKeyboard.getInstance().updateCarretIndex(); 
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
		
		private function onDigitModeSoftClosed():void {
			removeListenersForDigitMode();
			
			customKeyboardOpening = false;
			invokeSoftkeyboard(false);
			
			S_ACTION_FAIL.invoke();
		}
		
		private function invokeSoftkeyboard(val:Boolean):void{
			TweenMax.delayedCall(1, function():void {
				if (Input.S_SOFTKEYBOARD != null)
					Input.S_SOFTKEYBOARD.invoke(val);
				if (val == false)
					onFocusOut();
			}, null, true);
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
				
				S_ACTION_SUCCESS.invoke(key);
				
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
			
			onFocusOut();
			
			SoftKeyboard.closeKeyboardImmediately();
		}
		
		protected function onFocusOut(e:FocusEvent = null):void {
			
			if (customKeyboardOpening == true && e != null) {
				e.preventDefault();
				e.stopPropagation();
				return;
			}
		}
		
		private function onDigitModeStageDown(e:Event):void {
			downX = e.target.mouseX;
			downY = e.target.mouseY;
		}
	}
}