package com.dukascopy.connect.screens.payments.settings {
	
	import assets.SelectIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.screens.dialogs.paymentDialogs.elements.InputField;
	import com.dukascopy.connect.screens.layout.ScrollScreen;
	import com.dukascopy.connect.screens.payments.card.TypeCurrency;
	import com.dukascopy.connect.screens.roadMap.SelectorClip;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.payments.PayManager;
	import com.dukascopy.connect.sys.payments.PayRespond;
	import com.dukascopy.connect.sys.payments.PaymentsManager;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import com.dukascopy.langs.LangManager;
	import com.greensock.TweenMax;
	import com.greensock.easing.Power3;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.TextEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class PaymentsSettingsIncreaseLimitsScreen extends ScrollScreen {
		
		private var requestButton:BitmapButton;
		private var regularType:SelectorClip;
		private var accumulatedType:SelectorClip;
		private var title:Bitmap;
		private var message:TextField;
		private var amountInput:InputField;
		private var successClip:Bitmap;
		
		private var locked:Boolean;
		private var state:String;
		private var requestSent:Boolean;
		
		public function PaymentsSettingsIncreaseLimitsScreen() {
			
		}
		
		override protected function createView():void {
			super.createView();
			
			title = new Bitmap();
			addObject(title);
			
			createButton();
		}
		
		private function selectRegular(ignoreLocked:Boolean = false):void 
		{
			if (locked)
			{
				return;
			}
			
			regularType.select();
			accumulatedType.unselect();
			
			addAmountInput();
			checkAmount();
		}
		
		private function addAmountInput():void 
		{
			if (amountInput == null)
			{
				var tf:TextFormat = new TextFormat();
				tf.size = FontSize.BODY;
				tf.color = Style.color(Style.COLOR_TEXT);
				tf.font = Config.defaultFontName;
				
				amountInput = new InputField();
				amountInput.onChangedFunction = onAmountChange;
				addObject(amountInput);
				
				if (isActivated == true)
				{
					amountInput.activate();
				}
			}
			drawAmountInput();
		}
		
		private function drawAmountInput():void 
		{
			amountInput.draw(regularType.width, getInputTitle(), NaN, null, TypeCurrency.USD); 
			updatePositions();
			drawView();
		}
		
		private function getInputTitle():String 
		{
			if (regularType.isSelected())
			{
				return Lang.increaseLimits_amountRegular;
			}
			else if (accumulatedType.isSelected())
			{
				return Lang.increaseLimits_amountAccumulated;
			}
			else
			{
				ApplicationErrors.add();
			}
			return "";
		}
		
		private function onAmountChange():void 
		{
			TweenMax.killDelayedCallsTo(checkAmount);
			TweenMax.delayedCall(0.5, checkAmount, null, false);
		}
		
		private function checkAmount():void 
		{
			TweenMax.killDelayedCallsTo(checkAmount);
			PayManager.callGetSystemOptions(onOptionsReady);
			
			if (dataValid())
			{
				requestButton.alpha = 1;
			}
			else
			{
				requestButton.alpha = 0.5;
			}
		}
		
		private function onOptionsReady():void 
		{
			if (_isDisposed) {
				return;
			}
			
			if (amountInput != null && !isNaN(amountInput.value) && amountInput.value > 0)
			{
				var text:String;
				if (regularType.isSelected())
				{
					text = Lang.increaseLimits_quarterlyLimitIncrease;
					//text = LangManager.replace(Lang.regExtValue, text, (PayManager.systemOptions.incomingQuarterlyLimitCoefficient*amountInput.value).toString() + " " + TypeCurrency.USD);
					displayMessage(text);
				}
				else if (accumulatedType.isSelected())
				{
					if (amountInput.value > PayManager.systemOptions.equityLimitThreshold)
					{
						text = Lang.increaseLimits_recommendSavingsAccount;
						text = LangManager.replace(Lang.regExtValue, text, PayManager.systemOptions.equityLimitThreshold.toString() + " " + TypeCurrency.USD);
						displayMessage(text);
					}
					else
					{
						displayMessage(Lang.increaseLimits_equityLimitIncrease);
					}
				}
			}
			else
			{
				displayMessage("");
			}
		}
		
		private function displayMessage(text:String):void 
		{
			if (message == null)
			{
				message = new TextField();
				var tf:TextFormat = new TextFormat();
				tf.font = Config.defaultFontName;
				tf.size = FontSize.BODY;
				tf.color = Style.color(Style.COLOR_TEXT);
				message.defaultTextFormat = tf;
				message.multiline = true;
				message.wordWrap = true;
				message.width = _width - Config.DIALOG_MARGIN * 2;
				addObject(message);
				message.addEventListener(TextEvent.LINK, openLink);
				
				var link:Object = new Object();
			//	link.fontWeight = "bold";
				link.textDecoration= "underline";
				link.color = "#36A1DC";
				var style:StyleSheet = new StyleSheet();
				style.setStyle("a", link);

				message.styleSheet = style;
			}
			/*var r:RegExp = /<a href/g;
			var r2:RegExp = /<\/a>/g;
			text = text.replace(r, "<font color='#5DC269'><a  href");
			text = text.replace(r2, "</a></font>");*/
			
			message.htmlText = text;
			message.height = message.textHeight + 6;
			message.selectable = false;
			/*if (message.bitmapData != null)
			{
				message.bitmapData.dispose();
				message.bitmapData = null;
			}
			message.bitmapData = TextUtils.createTextFieldData(text, 
																_width - Config.DIALOG_MARGIN * 2, 10, true, 
																TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
																FontSize.BODY, true, Style.color(Style.COLOR_TEXT), Style.color(Style.COLOR_BACKGROUND), false, true);*/
			updatePositions();
			drawView();
		}
		
		private function openLink(e:TextEvent):void 
		{
			navigateToURL(new URLRequest(e.text));
		}
		
		private function selectAccumulated(ignoreLocked:Boolean = false):void 
		{
			if (locked)
			{
				return;
			}
			regularType.unselect();
			accumulatedType.select();
			
			addAmountInput();
			checkAmount();
		}
		
		private function createButton():void {
			requestButton = new BitmapButton();
			requestButton.setStandartButtonParams();
			requestButton.tapCallback = onRequestButtonClick;
			requestButton.disposeBitmapOnDestroy = true;
			requestButton.setDownScale(1);
			requestButton.setOverlay(HitZoneType.BUTTON);
			view.addChild(requestButton);
		}
		
		private function drawButton(text:String):void {
			var textSettings:TextFieldSettings = new TextFieldSettings(text, Color.WHITE, FontSize.BODY, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, Color.GREEN, 1, -1, NaN, -1, -1, Style.size(Style.SIZE_BUTTON_CORNER));
			requestButton.setBitmapData(buttonBitmap, true);
			requestButton.y = _height - Config.APPLE_BOTTOM_OFFSET - requestButton.height - Config.DIALOG_MARGIN;
			requestButton.x = (_width * .5 - requestButton.width * .5);
		}
		
		private function onRequestButtonClick():void {
			PayManager.callGetSystemOptions(processRequest);
		}
		
		private function processRequest():void {
			if (_isDisposed) {
				return;
			}
			if (locked == true) {
				return;
			}
			if (requestSent) {
				onBack();
			}
			if (dataValid()) {
				showPreloader();
				lock();
				var request:Object = new Object();
				if (regularType.isSelected()) {
					request.limit_type = "incoming_quarterly_limit";
				} else if (accumulatedType.isSelected()) {
					if (amountInput.value > PayManager.systemOptions.equityLimitThreshold) {
						request.limit_type = "equity_limit";
					} else {
						request.limit_type = "equity_limit";
					}
				}
				request.amount = amountInput.valueString;
				request.currency = "USD";
				PayManager.S_LIMITS_INCREASE_RESPOND.add(onDataUpdated);
				PayManager.S_LIMITS_INCREASE_ERROR.add(onDataUpdateError);
				PayManager.callLimitsIncrease(request);
			}
		}
		
		private function onDataUpdateError(errorMessage:String, callId:String = null):void 
		{
			hidePreloader();
			unlock();
			showMessage(errorMessage, false);
		}
		
		private function unlock():void 
		{
			locked = false;
		}
		
		private function onDataUpdated(r:PayRespond, callId:String = null):void 
		{
			hidePreloader();
			unlock();
			
			if (r.data != null && "success" in r.data && r.data.success == true)
			{
				showSuccessResult();
			}
			else
			{
				showMessage(Lang.textError, false);
			}
		}
		
		private function showSuccessResult():void 
		{
			lock();
			var hideTime:Number = 0.2;
			TweenMax.to(title, hideTime, {x:title.x - _width});
			TweenMax.to(regularType, hideTime, {x:title.x - _width, delay:0.05, ease:Power3.easeIn});
			TweenMax.to(accumulatedType, hideTime, {x:title.x - _width, delay:0.1, ease:Power3.easeIn});
			TweenMax.to(amountInput, hideTime, {x:title.x - _width, delay:0.15, ease:Power3.easeIn});
			TweenMax.to(message, hideTime, {x:title.x - _width, delay:0.2, ease:Power3.easeIn});
			TweenMax.to(requestButton, hideTime, {x:title.x - _width, delay:0.25, onComplete:showFinalState, ease:Power3.easeIn});
		}
		
		private function showFinalState():void 
		{
			if (isDisposed)
			{
				return;
			}
			drawButton(Lang.textOk);
			
			var successText:String = "";
			if (regularType.isSelected())
			{
				successText = Lang.increaseLimits_quarterlySuccess
			}
			else if (accumulatedType.isSelected())
			{
				successText = Lang.increaseLimits_equitySuccess;
			}
			
			if (regularType != null)
				regularType.dispose();
			regularType = null;
			
			if (accumulatedType != null)
				accumulatedType.dispose();
			accumulatedType = null;
			
			if (amountInput != null)
				amountInput.dispose();
			amountInput = null;
			
			if (title != null)
				UI.destroy(title);
			title = null;
			
			drawSuccessIcon();
			successClip.x = int(_width * .5 - successClip.width * .5) + _width;
			displayMessage(successText);
			
			message.x = message.x + _width;
			requestButton.x = (_width * .5 - requestButton.width * .5) + _width;
			
			
			var showTime:Number = 0.2;
			TweenMax.to(successClip, showTime, {x:int(_width * .5 - successClip.width * .5), ease:Power3.easeOut});
			TweenMax.to(message, showTime, {x:Config.DIALOG_MARGIN, delay:0.05, ease:Power3.easeOut});
			TweenMax.to(requestButton, showTime, {x:int(_width * .5 - requestButton.width * .5), delay:0.1, ease:Power3.easeOut});
			requestSent = true;
			unlock();
		}
		
		private function drawSuccessIcon():void 
		{
			if (successClip == null)
			{
				successClip = new Bitmap();
				addObject(successClip);
				
				var source:Sprite = new SelectIcon();
				var size:int = Config.FINGER_SIZE;
				UI.scaleToFit(source, size, size);
				successClip.bitmapData = UI.getSnapshot(source);
			}
		}
		
		private function dataValid():Boolean 
		{
			if (amountInput != null && !isNaN(amountInput.value) && amountInput.value > 0)
			{
				return true;
			}
			return false;
		}
		
		private function lock():void 
		{
			locked = true;
		}
		
		override protected function drawView():void {
			super.drawView();
			requestButton.y = _height - Config.APPLE_BOTTOM_OFFSET - requestButton.height - Config.DIALOG_MARGIN;
		}
		
		override protected function getBottomConfigHeight():int 
		{
			return requestButton.height + Config.DIALOG_MARGIN * 2;
		}
		
		override public function initScreen(data:Object = null):void {
			
			if (data == null) {
				data = new Object();
			}
			if ("title" in data == false || data.title == null) {
				data.title = Lang.increaseLimits;
			}
			super.initScreen(data);
			PaymentsManager.activate();
			drawButton(Lang.request);
			drawTitle();
			
			var itemWidth:int = Math.min(_width - Config.DIALOG_MARGIN * 2, Config.FINGER_SIZE * 5);
			var itemHeight:int = Config.FINGER_SIZE * 1.3;
			
			regularType = new SelectorClip(null, Lang.increaseLimits_typeRegular, itemWidth, itemHeight, selectRegular);
			accumulatedType = new SelectorClip(null, Lang.increaseLimits_typeAccumulated, itemWidth, itemHeight, selectAccumulated);
			
			regularType.x = int(_width * .5 - regularType.width * .5);
			accumulatedType.x = int(_width * .5 - accumulatedType.width * .5);
			
			addObject(regularType);
			addObject(accumulatedType);
			
			updatePositions();
			
			checkAmount();
		}
		
		private function drawTitle():void 
		{
			if (title.bitmapData != null)
			{
				title.bitmapData.dispose();
				title.bitmapData = null;
			}
			title.bitmapData = TextUtils.createTextFieldData(Lang.increaseLimits_purpose, _width - Config.DIALOG_MARGIN * 2, 10, true, TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, FontSize.BODY, true, Style.color(Style.COLOR_TEXT));
			
			title.x = int(_width * .5 - title.width * .5);
		}
		
		private function updatePositions():void 
		{
			var position:int = Config.FINGER_SIZE * .5;
			
			if (title != null)
			{
				title.y = position;
				position += title.height + Config.FINGER_SIZE * .5;
			}
			
			if (successClip != null)
			{
				position += Config.FINGER_SIZE * 1.3;
				successClip.y = position;
				position += successClip.height + Config.FINGER_SIZE * 1.3;
			}
			
			if (regularType != null)
			{
				regularType.y = position;
				position += regularType.height + Config.FINGER_SIZE * .3;
			}
			
			if (accumulatedType != null)
			{
				accumulatedType.y = position;
				position += accumulatedType.height + Config.FINGER_SIZE * .3;
			}
			
			if (amountInput != null)
			{
				amountInput.x = int(_width * .5 - amountInput.width * .5);
				amountInput.y = position;
				position += amountInput.height + Config.FINGER_SIZE * .3;
			}
			
			if (message != null)
			{
				message.x = int(_width * .5 - message.width * .5);
				message.y = position;
			}
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			if (_isDisposed == true)
				return;
			if (requestButton != null)
				requestButton.activate();
			
			if (regularType != null)
				regularType.activate();
			if (accumulatedType != null)
				accumulatedType.activate();
			if (amountInput != null)
				amountInput.activate();
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed == true)
				return;
			if (requestButton != null)
				requestButton.deactivate();
			
			if (regularType != null)
				regularType.deactivate();
			if (accumulatedType != null)
				accumulatedType.deactivate();
		}
		
		override public function dispose():void {
			super.dispose();
			PaymentsManager.deactivate();
			PayManager.S_LIMITS_INCREASE_RESPOND.remove(onDataUpdated);
			PayManager.S_LIMITS_INCREASE_ERROR.remove(onDataUpdateError);
			TweenMax.killDelayedCallsTo(checkAmount);
			
			if (regularType != null)
				regularType.dispose();
			regularType = null;
			
			if (accumulatedType != null)
				accumulatedType.dispose();
			accumulatedType = null;
			
			if (amountInput != null)
				amountInput.dispose();
			amountInput = null;
			
			if (requestButton != null)
				requestButton.dispose();
			requestButton = null;
			
			if (title != null)
				UI.destroy(title);
			title = null;
			
			if (message != null)
			{
				message.removeEventListener(TextEvent.LINK, openLink);
				UI.destroy(message);
			}
			message = null;
			
			if (successClip != null)
				UI.destroy(successClip);
			successClip = null;
		}
	}
}