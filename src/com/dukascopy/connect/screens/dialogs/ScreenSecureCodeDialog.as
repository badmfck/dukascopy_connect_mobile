package com.dukascopy.connect.screens.dialogs {
	
	import assets.LockClosedGrey;
	import com.adobe.utils.StringUtil;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.StageQuality;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
	 * ...
	 * @author Aleksei L
	 */
	
	public class ScreenSecureCodeDialog extends ScreenAlertDialog {
		
		private var passInput:Input;
		private var inputBottom:Bitmap;
		private var labelBitmapLock:Bitmap;
		public static const ENTER:String = "Enter";
		public static const REPEAT:String = "Repeat";
		private var _value:String = "";
		private var _isEnter:Boolean = true;
		private var _isStars:Boolean = true;
		private var additionalData:Object;

		public function ScreenSecureCodeDialog() {
			super();
		}
		
		override protected function createView():void {
			super.createView();
			
			passInput = new Input();
			passInput.setMode(Input.MODE_PASSWORD);
			passInput.setLabelText(/*Lang.enterPassword*/Lang.TEXT_SECURITY_CODE);
			passInput.setBorderVisibility(false);
			passInput.setRoundBG(false);
			passInput.getTextField().textColor = Style.color(Style.COLOR_TEXT);
			passInput.setRoundRectangleRadius(0);
			passInput.inUse = true;
			
			var hLineBitmapData:ImageBitmapData = UI.getHorizontalLine(2);
			inputBottom = new Bitmap(hLineBitmapData);
			
			var mc:MovieClip = new LockClosedGrey;
			labelBitmapLock = new Bitmap(UI.getSnapshot(mc, StageQuality.HIGH, "ImageFrames.frame"));
			labelBitmapLock.smoothing = true;
			labelBitmapLock.scaleX = labelBitmapLock.scaleY = 0.6;
		}
			
		private function focusOnInput():void 
		{
			passInput.setFocus();
			passInput.getTextField().requestSoftKeyboard();
		}
		
		override public function initScreen(data:Object = null):void {
			if (data != null){
				_isEnter = data.isEnter;
				_isStars = data.isStars;
				additionalData = data.additionalData;
				_value = _isStars ? data.value:"";
			}

			passInput.setMode(_isStars ? Input.MODE_INPUT: Input.MODE_PASSWORD);
			passInput.value = _value;
			data.buttonOk = Lang.textOk;
			data.buttonSecond = Lang.textCancel.toUpperCase();
			if (_isEnter == false){
				data.title = Lang.repeatSecurityCode;
				////data.text = /*Lang.pleaseEnterPassword*/"Repeat security";
			}else{ // _type == ENTER
				////data.text = /*Lang.pleaseEnterPassword*/"Enter security";
				data.title = Lang.enterSecurityCode;
			}
			//data.text =""; data.text +" code that you got from payment sender.";
			super.initScreen(data);
			
		}
		
		override protected function fireCallbackFunctionWithValue(value:int):void 
		{
			var callBackFunction:Function = callback;
			callback = null;
			if (callBackFunction != null && callBackFunction.length == 3)
			{
				callBackFunction(value, passInput.value, additionalData);
			}
			else
			{
				callBackFunction(value, passInput.value);
			}
		}
		
		override protected function getMaxContentHeight():Number 
		{
			return _height - padding * 2 - headerHeight - buttonsAreaHeight;
		}
		
		override protected function drawView():void {
			super.drawView();
			// todo add check for valid input 
			onChangeInputValue();
			//button0.alpha = 0.7;
			//button0.deactivate();
		}
		
		override protected function repositionButtons():void 
		{
			contentBottomPadding = 0;
			super.repositionButtons();
		}
		
		override protected function updateScrollArea():void 
		{
			if (!content.fitInScrollArea())
			{
				content.scrollToPosition(passInput.view.y - (Config.MARGIN));
				content.enable();
			}
			else {
				content.disable();
			}
			
			content.update();
		}
		
		override protected function recreateContent(padding:Number):void 
		{
			super.recreateContent(padding);
			
			//labelBitmapLock.x = ;
			passInput.width = _width - (labelBitmapLock.x+labelBitmapLock.width + padding /* * 2*/);
			passInput.view.y = (content.itemsHeight == 0 )? 0 :int(content.itemsHeight + padding);//padding*.5
			labelBitmapLock.y = passInput.view.y  + (passInput.view.height - labelBitmapLock.height )*.5;
			passInput.view.x = labelBitmapLock.x + labelBitmapLock.width;

			inputBottom.width = _width - padding * 2;
			inputBottom.y = passInput.view.y + passInput.view.height;
			
			content.addObject(passInput.view);
			content.addObject(labelBitmapLock);
			content.addObject(inputBottom);
		}
		
		private function onChangeInputValue():void 
		{
			if(passInput!=null){
				var currentValue:String =  StringUtil.trim(passInput.value);
				var defValue:String =  passInput.getDefValue();
				if (currentValue != "" && currentValue != passInput.getDefValue()) {					
					// activate button
					//btn0TF.alpha = 1;
					button0.activate();
					button0.alpha = 1;
					
				}else {
					button0.alpha = .7;
					button0.deactivate();
				}
			}
		}
		
		override protected function updateContentHeight():void 
		{
			contentHeight = (padding*1.3 * 3 + headerHeight + buttonsAreaHeight + content.itemsHeight);
		}
		
		override public function activateScreen():void {
			passInput.activate();
			super.activateScreen();
			
			if (passInput.value && passInput.value != "" && passInput.value != passInput.getDefValue())
			{
				button0.alpha = 1;
				button0.activate();
			}
			else
			{
				button0.alpha = 0.7;
				button0.deactivate();
			}
			
			passInput.S_CHANGED.add(onChangeInputValue);
			
			focusOnInput();
		}
		
		override public function deactivateScreen():void {
			if (passInput)
			{
				passInput.deactivate();
			}
			super.deactivateScreen();
			
			passInput.S_CHANGED.add(onChangeInputValue);
		}
		
		override protected function btn0Clicked():void {
			if (callback != null) {
				fireCallbackFunctionWithValue(1);
			}
			if (passInput){
				passInput.setLabelText("");
			}
			DialogManager.closeDialog();
		}
		
		override protected function onCloseButtonClick():void {
			if (callback != null) {
				fireCallbackFunctionWithValue(0);
			}
			passInput.setLabelText("");
			DialogManager.closeDialog();
		}
		
		override public function dispose():void {
			super.dispose();
			
			if (passInput)
			{
				passInput.dispose();
				passInput = null;
			}
			
			if (labelBitmapLock){
				UI.destroy(labelBitmapLock);
				labelBitmapLock = null;
			}
			if (inputBottom)
			{
				UI.destroy(inputBottom);
				inputBottom = null;
			}
		}
	}
}