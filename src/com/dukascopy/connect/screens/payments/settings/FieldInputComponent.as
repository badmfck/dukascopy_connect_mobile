/**
 * Created by aleksei.leschenko on 17.04.2017.
 */
package com.dukascopy.connect.screens.payments.settings {
	import com.adobe.utils.StringUtil;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.langs.Lang;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;

	public class FieldInputComponent extends Sprite {
		private var passInput:Input;
		private var labelBitmap:Bitmap;
		private var labelBitmapIcon:Bitmap;
		private var inputBottom:Bitmap;

		private var _callback:Function;
		private var _tFormat:String;
		private var _mode:String;
		private var _label:String = "";
		private var _width:Number = 320;
		protected var padding:Number =  Config.MARGIN * 2.5;
		private var eyeButton:BitmapButton;

		public function FieldInputComponent(label:String, mode:String, callback:Function, icon:DisplayObjectContainer, tFormat:String, isRedInfo:Boolean = false) {
			_label=label;
			super();
			_callback = callback;
			_tFormat = tFormat;
			_mode = mode;

			labelBitmap = new Bitmap();
			/*if (labelBitmap.bitmapData != null) {
				UI.disposeBMD(labelBitmap.bitmapData);
			}*/
			labelBitmap.bitmapData = UI.renderTextShadowed(label, _width, Config.FINGER_SIZE, false, false, 
															TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .3, 
															false, 
															Style.color(Style.COLOR_BACKGROUND), 
															AppTheme.BLACK, 
															Style.color(Style.COLOR_SUBTITLE), true, 1, false);
			addChild(labelBitmap);

			passInput = new Input();
			passInput.setMode(_mode);
			passInput.setLabelText(label);
			passInput.setBorderVisibility(false);
			passInput.setRoundBG(false);
			passInput.getTextField().textColor = Style.color(Style.COLOR_TEXT);
			passInput.setRoundRectangleRadius(0);
			passInput.inUse = true;
			passInput.backgroundAlpha = 0;
			addChild(passInput.view);

//			passInput.deactivate();

			var hLineBitmapData:ImageBitmapData = UI.getHorizontalLine(2, Style.color(Style.COLOR_SUBTITLE));
			var hLineBD:BitmapData = new BitmapData(1, Config.DOUBLE_MARGIN * 1.6, true, Style.color(Style.COLOR_BACKGROUND));
			hLineBD.copyPixels(hLineBitmapData as BitmapData, new Rectangle(0, 0, hLineBitmapData.width, hLineBitmapData.height), new Point(0, 0));
			hLineBitmapData.dispose();
			inputBottom = new Bitmap(hLineBD);
			addChild(inputBottom);

			if(icon != null)
			{
				UI.colorize(icon, Style.color(Style.COLOR_ICON_LIGHT));
				labelBitmapIcon = new Bitmap(UI.getSnapshot(icon, StageQuality.HIGH, "ImageFrames.frame"));
				labelBitmapIcon.smoothing = true;
				labelBitmapIcon.scaleX = labelBitmapIcon.scaleY = 0.6;
				//addChild(labelBitmapIcon);
			}
			eyeButton = new BitmapButton();
			eyeButton.setStandartButtonParams();
			eyeButton.setDownScale(1.3);
			eyeButton.setDownColor(0xFFFFFF);
			eyeButton.tapCallback = onBtnSettingsTap;
			eyeButton.disposeBitmapOnDestroy = true;
			eyeButton.setBitmapData(labelBitmapIcon.bitmapData,true);
			eyeButton.y = 0;//destY;
			eyeButton.setOverflow(Config.MARGIN, Config.MARGIN, Config.MARGIN, Config.MARGIN);
			eyeButton.deactivate();
			addChild(eyeButton);
			if(_mode == Input.MODE_PASSWORD){
				eyeButton.alpha = .5;
			}else{

				eyeButton.alpha = 1;
			}
			activateScreen();
		}

		public function drawView():void {
			labelBitmap.x = 0;
			passInput.view.x = 0;
			inputBottom.x = 0;

			if(eyeButton/*labelBitmapIcon*/){
				//eyeButton.x = Config.DOUBLE_MARGIN;
				eyeButton.x = _width - eyeButton.width;
				passInput.width = /*_width -*/ (eyeButton.x - Config.MARGIN );
				eyeButton.y = passInput.view.y  + (passInput.view.height - labelBitmapIcon.height )*.5;
			}else{
				passInput.width = _width;
				//labelBitmapIcon.y = passInput.view.y  + (passInput.view.height - labelBitmapIcon.height )*.5;
			}

			passInput.view.y =  padding - Config.MARGIN;
			inputBottom.width = _width;
			inputBottom.y = passInput.view.y + passInput.view.height;

			onChangeInputValue();
		}

		public function activateScreen():void {
			passInput.activate();
			drawView();
			/*if (passInput.value && passInput.value != "" && passInput.value != passInput.getDefValue())
			{
				button0.alpha = 1;
				button0.activate();
			}
			else
			{
				button0.alpha = 0.7;
				button0.deactivate();
			}*/

			passInput.S_CHANGED.add(onChangeInputValue);

			if(eyeButton)eyeButton.activate();
			focusOnInput();
		}

		private function onChangeInputValue():void
		{
			if(passInput!=null){
				var currentValue:String =  StringUtil.trim(passInput.value);
				var defValue:String =  passInput.getDefValue();
				if (currentValue != "" && currentValue != passInput.getDefValue()) {
					// activate button
					//btn0TF.alpha = 1;
//					button0.activate();
//					button0.alpha = 1;
				}else {
//					button0.alpha = .7;
//					button0.deactivate();
				}
				if(_callback != null){
					_callback();
				}
			}
		}
		private var _isMode:Boolean;
		private function onBtnSettingsTap(e:Event = null):void {
			//view
			if(eyeButton.alpha == .5){
				_isMode = false;
			/*	passInput.setMode(Input.MODE_INPUT);
//				var v:String = passInput.value;
//				passInput.setParams(,Input.MODE_INPUT);*/
			}else{
				_isMode = true;
				/*passInput.setMode(Input.MODE_PASSWORD);
//				passInput.setParams(passInput.value,Input.MODE_PASSWORD);*/
			}
			//
			isMode = _isMode;
			if(_callback != null){
				_callback(_isMode);
			}
		}

		private function focusOnInput():void
		{
			passInput.setFocus();
			passInput.getTextField().requestSoftKeyboard();
		}

		public function dispose():void {
			if (passInput){
				passInput.dispose();
				passInput = null;
			}
			/*if (labelBitmapIcon){
				UI.destroy(labelBitmapIcon);
				labelBitmapIcon = null;
			}*/
			if(eyeButton){
				eyeButton.dispose();
				eyeButton = null;
			}
			if (labelBitmap){
				UI.destroy(labelBitmap);
				labelBitmap = null;
			}
			if (inputBottom)
			{
				UI.destroy(inputBottom);
				inputBottom = null;
			}
			if(eyeButton){
				eyeButton.dispose();
				eyeButton = null;
			}
		}

		public function setWidthAndHeight(width:int):void {
			_width = width;
			if(labelBitmap.bitmapData){
				UI.disposeBMD(labelBitmap.bitmapData);
			}
			labelBitmap.bitmapData = UI.renderTextShadowed(_label, _width, Config.FINGER_SIZE, false, false, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .3, false, Style.color(Style.COLOR_BACKGROUND), AppTheme.BLACK, Style.color(Style.COLOR_SUBTITLE), true, 1, false);
			drawView();
		}

		public function deactivateScreen():void {
			if (passInput)
			{
				passInput.deactivate();
			}

			if(eyeButton)eyeButton.deactivate();
			passInput.S_CHANGED.add(onChangeInputValue);
		}

		public function get value():String {
			return (passInput && passInput.value != passInput.getDefValue())?passInput.value:"";
		}

		public function set isMode(value:Boolean):void {
			_isMode = value;
//			var _value:String = this.value;
//			passInput.value ="";
			if(_isMode){
				eyeButton.alpha = .5;
//				passInput.setParams(passInput.value,Input.MODE_PASSWORD);
				passInput.setMode(Input.MODE_PASSWORD);
			}else{
				eyeButton.alpha = 1;
//				passInput.setParams(passInput.value,Input.MODE_INPUT);
				passInput.setMode(Input.MODE_INPUT);
			}
//			passInput.setLabelText(passInput.getDefValue());

//			if(_value != ""){
//				passInput.value = _value;
//			}
		}

		public function get isMode():Boolean {
			return _isMode;
		}
	}
}
