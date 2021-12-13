package com.dukascopy.connect.gui.input 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.button.LongClick;
	import com.dukascopy.connect.sys.softKeyboard.SoftKeyboard;
	import com.dukascopy.connect.sys.style.Style;
	import com.greensock.TweenMax;
	import com.telefision.sys.signals.Signal;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;
		import com.dukascopy.connect.sys.echo.echo;
	/**
	 * ...
	 * @author Anton Bodrychenko
	 */
	public class InputWithPrompt extends Input
	{
		public var S_LONG_TAPPED:Signal = new Signal("InputWithPrompt.S_LONG_TAPPED");
		
		private var promptTextField:TextField = new TextField();
		private var labelText:String;
		private var longClick:LongClick;
		private var isSoftKeyboardShowed:Boolean = false;
		
		public function InputWithPrompt(type:String = 'mobile') 
		{
			super(type);
			
			longClick = new LongClick(_view, onLongClick);
			_view.addChildAt(promptTextField, 0);
			promptTextField.mouseEnabled = false;
			//activate();
			SoftKeyboard.S_CLOSED.add(onCloseSoftKeyboard);
			SoftKeyboard.S_OPENED.add(onShowSoftKeyboard);
		}
		
		private function onShowSoftKeyboard(h:int):void 
		{
			isSoftKeyboardShowed = true;
		}
		
		private function onCloseSoftKeyboard():void 
		{
			isSoftKeyboardShowed = false;
		}
		
		private function onLongClick():void 
		{
			if (isSoftKeyboardShowed && Config.PLATFORM_ANDROID) return;
			S_LONG_TAPPED.invoke();
		}
		
		private function onSoftKeyboardKeyPress(key:int):void 
		{
			TweenMax.killDelayedCallsTo(onTextInput);
			TweenMax.delayedCall(0.1, onTextInput);
		}
		
		private function onInputChanged(e:Event = null):void {
			onTextInput();
		}
		
		override public function setMode(mode:String):void {
			super.setMode(mode);
			textField.mouseEnabled = true;
			_view.buttonMode = false;
		}
		
		private function onTextInput():void {
			echo("InputWithPrompt", "onTextInput");
			if(promptTextField){
				promptTextField.text = textField.text.length == 0 ? labelText : "";
			}
			S_CHANGED.invoke();
		}
		
		override protected function setFormat(format:TextFormat):void {
			super.setFormat(format);
			promptTextField.defaultTextFormat = textField.defaultTextFormat;
			promptTextField.textColor = Style.color(Style.COLOR_SUBTITLE);
		}
		
		override public function setLabelText(value:String, textColor:Number = NaN):void {
			labelText = value;
			promptTextField.text = labelText;
			onTextInput();
		}
		
		override protected function drawView():void {
			super.drawView();
			promptTextField.x = textField.x;
			promptTextField.y = textField.y;
			promptTextField.width = textField.width;
			promptTextField.height = textField.height;
		}
		
		override public function set value(v:String):void{
			super.value = v;
			onTextInput();
		}
		
		override public function activate():void 
		{
			super.activate();
			//S_CHANGED.add(onTextInput);
			SoftKeyboard.S_KEY.add(onSoftKeyboardKeyPress);
			longClick.activate();
		}
		
		override public function deactivate():void 
		{
			super.deactivate();
			//S_CHANGED.remove(onTextInput);
			SoftKeyboard.S_KEY.remove(onSoftKeyboardKeyPress);
			longClick.deactivate();
		}
		
		override public function dispose():void 
		{
			super.dispose();
			SoftKeyboard.S_KEY.remove(onSoftKeyboardKeyPress);
			SoftKeyboard.S_CLOSED.remove(onCloseSoftKeyboard);
			SoftKeyboard.S_OPENED.remove(onShowSoftKeyboard);
			//S_CHANGED.remove(onTextInput);
			promptTextField = null;
			longClick.dispose();
			longClick = null;
		}
		
		override public function toMaterialStyle():void 
		{
			super.toMaterialStyle();
		}
	}

}