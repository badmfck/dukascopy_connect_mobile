package com.dukascopy.connect.screens.dialogs {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.gui.button.DDFieldButton;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.gui.list.renderers.ContactListRenderer;
	import com.dukascopy.connect.gui.list.renderers.IListRenderer;
	import com.dukascopy.connect.gui.list.renderers.ListPayCurrency;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.textedit.TextComposer;
	import com.dukascopy.connect.screens.dialogs.x.base.bottom.ListSelectionPopup;
	import com.dukascopy.connect.screens.dialogs.paymentDialogs.elements.InputField;
	import com.dukascopy.connect.screens.layout.ScrollScreen;
	import com.dukascopy.connect.screens.payments.card.TypeCurrency;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.payments.PayManager;
	import com.dukascopy.connect.sys.payments.PayRespond;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.display.CapsStyle;
	import flash.display.JointStyle;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */

	public class ScreenAddInvoiceDialog extends ScrollScreen {
		
		private var inputAmount:InputField;
		private var iCurrency:DDFieldButton;
		private var labelBitmapFullName:Bitmap;
		
		private var messageComposer:TextComposer;
		
		private var commentField:TextField;
		private var nextButton:BitmapButton;
		private var cancelButton:BitmapButton;
		private var userClip:Bitmap;
		private var line:Sprite;
		
		public function ScreenAddInvoiceDialog() { }
		
		
		override protected function createView():void {
			super.createView();
			
			createInputAmount();
			
			iCurrency = new DDFieldButton(selectCurrency, "", true, NaN, Lang.currency);
			addObject(iCurrency);
			
			createComment();
			createNextButton();
			createCancelButton();
		}
		
		private function createCancelButton():void 
		{
			cancelButton = new BitmapButton();
			cancelButton.setStandartButtonParams();
			cancelButton.tapCallback = onCancelClick;
			cancelButton.disposeBitmapOnDestroy = true;
			cancelButton.setDownScale(1);
			cancelButton.setOverlay(HitZoneType.BUTTON);
			view.addChild(cancelButton);
		}
		
		private function onCancelClick():void 
		{
			onBack();
		}
		
		private function createNextButton():void 
		{
			nextButton = new BitmapButton();
			nextButton.setStandartButtonParams();
			nextButton.tapCallback = onNextClick;
			nextButton.disposeBitmapOnDestroy = true;
			nextButton.setDownScale(1);
			nextButton.setOverlay(HitZoneType.BUTTON);
			view.addChild(nextButton);
		}
		
		private function onNextClick():void 
		{
			if (inputAmount.value == 0)
			{
				inputAmount.invalid();
				return;
			}
			if (iCurrency.value == Lang.currency)
			{
				if (PayManager.systemOptions == null)
				{
					PayManager.callGetSystemOptions(null);
				}
				
				return;
			}
			
			close(1);
			
			/*if (iCurrency.value == Lang[TypeCurrency.DCO])
			{
				close(1);
			}
			else
			{
				getCommission();
			}*/
		}
		
		private function getCommission():void 
		{
			showPreloader();
			
			PayManager.S_SEND_MONEY_COMMISSION_RESPOND.add(onSendMoneyCommissionRespond);
			PayManager.callGetSendMoneyCommission(inputAmount.value, iCurrency.value, "");
		}
		
		private function onSendMoneyCommissionRespond(respond:PayRespond):void {
			
			PayManager.S_SEND_MONEY_COMMISSION_RESPOND.remove(onSendMoneyCommissionRespond);
			if (isDisposed)
			{
				respond.dispose();
				return;
			}
			hidePreloader();
			
			if (!respond.error) {
				close(1);
			} else if (respond.hasAuthorizationError) {
				close(1);
			} 
			else if (respond.hasTrialVersionError) {
				close(1);
			}
			else{
				showMessage(respond.errorMsg, false);
			}
		}
		
		private function createComment():void 
		{
			var tf:TextFormat = new TextFormat();
			tf.size = FontSize.BODY;
			tf.color = Style.color(Style.COLOR_SUBTITLE);
			tf.font = Config.defaultFontName;
			commentField = new TextField();
			
			commentField.defaultTextFormat = tf;
			commentField.wordWrap = true;
			commentField.maxChars = 255;
			commentField.multiline = true;
			commentField.setTextFormat(tf);
			commentField.type = TextFieldType.INPUT;
			commentField.text = getCommentPromt();
			commentField.addEventListener(FocusEvent.FOCUS_IN, onCommentFocused);
			commentField.addEventListener(FocusEvent.FOCUS_OUT, onCommentFocusOut);
			addObject(commentField);
		}
		
		private function onCommentFocusOut(e:FocusEvent):void 
		{
			if (commentField.text == "" || commentField.text == null)
			{
				commentField.text = getCommentPromt();
			}
		}
		
		private function onCommentFocused(e:FocusEvent):void 
		{
			if (commentField.text == getCommentPromt())
			{
				commentField.text = "";
			}
		}
		
		private function getCommentPromt():String 
		{
			return Lang.addYourDescription;
		}
		
		private function createInputAmount():void 
		{
			var tf:TextFormat = new TextFormat();
			tf.size = FontSize.BODY;
			tf.color = Style.color(Style.COLOR_TEXT);
			tf.font = Config.defaultFontName;
			
			inputAmount = new InputField( -1, Input.MODE_DIGIT_DECIMAL);
			inputAmount.onChangedFunction = onAmountChange;
			inputAmount.setPadding(0);
			inputAmount.updateTextFormat(tf);
			addObject(inputAmount);
		}
		
		private function onAmountChange():void 
		{
			inputAmount.valid();
			checkDataValid();
		}
		
		private function checkDataValid():void 
		{
			
		}
		
		private function drawControls():void
		{
			var textSettings:TextFieldSettings = new TextFieldSettings(Lang.create, Color.WHITE, FontSize.BODY, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, Color.GREEN, 1, -1, NaN, getButtonWidth(), -1, Style.size(Style.SIZE_BUTTON_CORNER));
			nextButton.setBitmapData(buttonBitmap, true);
			
			textSettings = new TextFieldSettings(Lang.textCancel, Style.color(Style.COLOR_TEXT), FontSize.BODY, TextFormatAlign.CENTER);
			buttonBitmap = TextUtils.createbutton(textSettings, Style.color(Style.COLOR_BACKGROUND), 1, -1, Style.color(Style.COLOR_LINE_SSL), getButtonWidth(), -1, Style.size(Style.SIZE_BUTTON_CORNER));
			cancelButton.setBitmapData(buttonBitmap, true);
			
			iCurrency.setSize(Config.FINGER_SIZE * 2, Config.FINGER_SIZE * .8);
			inputAmount.draw(_width - Config.DIALOG_MARGIN * 3 - iCurrency.width, Lang.textAmount, 0);
		}
		
		private function getButtonWidth():int 
		{
			return (_width - Config.DIALOG_MARGIN * 3) * .5;
		}
		
		override protected function getBottomConfigHeight():int 
		{
			var result:int = nextButton.height + Config.DIALOG_MARGIN * 2;
			return result;
		}
		
		override protected function getScrollBottomMargin():int 
		{
			return 0;
		}
		
		override protected function drawView():void {
			updatePositions();
			super.drawView();
		}
		
		private function updatePositions():void 
		{
			var position:int = 0;
			
			if (userClip != null)
			{
				userClip.y = position;
				line.y = position + userClip.height;
				position += userClip.height + Config.FINGER_SIZE * .4;
			}
			else
			{
				position = Config.FINGER_SIZE * .6;
			}
			
			inputAmount.y = position;
			inputAmount.x = Config.DIALOG_MARGIN;
			
			iCurrency.y = position;
			iCurrency.x = _width - Config.DIALOG_MARGIN - iCurrency.width;
			
			position += Math.max(iCurrency.fullHeight, iCurrency.height) + Config.FINGER_SIZE * .5;
			
			commentField.x = Config.DIALOG_MARGIN;
			commentField.y = position;
			commentField.width = _width - Config.DIALOG_MARGIN * 2;
			commentField.height = getCommentHeight(position);
			position += commentField.height + Config.FINGER_SIZE * .3;
			
			if (labelBitmapFullName != null){
				labelBitmapFullName.y = int(Math.max(position, _height - getBottomConfigHeight() - getContentPosition() - labelBitmapFullName.height - Config.FINGER_SIZE * .1));
				labelBitmapFullName.x = Config.DIALOG_MARGIN;
			}
			
			cancelButton.x = Config.DIALOG_MARGIN;
			nextButton.x = int(cancelButton.x + cancelButton.width + Config.DIALOG_MARGIN);
			
			nextButton.y = cancelButton.y = int(_height - Config.DIALOG_MARGIN - nextButton.height);
		}
		
		private function getCommentHeight(position:int):int 
		{
			var result:int = _height - getBottomConfigHeight() - getContentPosition() - position;
			if (labelBitmapFullName != null)
			{
				result -= labelBitmapFullName.height + Config.FINGER_SIZE * .3;
			}
			result = Math.max(result, Config.FINGER_SIZE);
			result = Math.min(result, Config.FINGER_SIZE * 2);
			return result;
		}
		
		override public function onBack(e:Event = null):void {
			close(0);
		}
		
		private function close(closeCode:int):void 
		{
			var callBackFunction:Function;
			
			if (data != null && "callback" in data && data.callback != null)
			{
				callBackFunction = data.callback;
			}
			
			if (callBackFunction != null)
			{
				
				if (closeCode != 1)
				{
					callBackFunction(closeCode, null);
				}
				else
				{
					var result:Object = new Object();
					result.amount = inputAmount.value;
					result.currency = iCurrency.value;
					if (data != null && "additionalData" in data)
					{
						result.additionalData = data.additionalData;
					}
					if (commentField.text != getCommentPromt())
					{
						result.message = commentField.text;
					}
					
					callBackFunction(closeCode, result);
				}
			}
			
			
			//
			ServiceScreenManager.closeView();
		}
		
		override public function initScreen(data:Object = null):void {
			
			if (data == null)
			{
				data = new Object();
			}
			if ("title" in data == false || data.title == null)
			{
				data.title = Lang.addInvoice;
			}
			
			super.initScreen(data);
			
			overrideOnBack(onBack);
			
			drawControls();
			
			if (data != null) {
				if ("amount" in data == true && data.amount != null && !isNaN(Number(data.amount))) {
					inputAmount.value = data.amount;
				}
				if ("currency" in data == true && data.currency != null) {
					iCurrency.setValue(data.currency);
				}
				if ("message" in data == true && data.message != null) {
					setComment(data.message);
				}
				
				if ("user" in data && data.user != null) {
					addUserClip(data.user);
				}
			}
			
			showPreloader();
			PayManager.callGetSystemOptions(onSystemOptions);
			
			if (data.thirdparty == true) {
				addFullNameDescription();
			}
		}
		
		private function addUserClip(userData:Object):void 
		{
			var clipWidth:int = _width - Config.FINGER_SIZE * .2;
			var userClipRenderer:IListRenderer = new ContactListRenderer();
			(userClipRenderer as ContactListRenderer).hideBack();
			var listItem:ListItem = new ListItem("", 0, 0, clipWidth, userClipRenderer, userData, null);
			userClip = new Bitmap();
			addObject(userClip);
			
			line = new Sprite();
			line.graphics.lineStyle(UI.getLineThickness(), Style.color(Style.COLOR_SEPARATOR_TOP_BAR), 1, false, "none", CapsStyle.SQUARE, JointStyle.MITER);
			line.graphics.moveTo(0, 0);
			line.graphics.lineTo(_width, 0);
		//	addObject(line);
			
			var clipHeight:int = userClipRenderer.getHeight(listItem, clipWidth);
			userClip.bitmapData = new ImageBitmapData("", _width, clipHeight, false, Style.color(Style.COLOR_SEPARATOR));
			var targetDB:ImageBitmapData = UI.getSnapshot(userClipRenderer.getView(listItem, clipHeight, clipWidth) as Sprite);
			userClip.bitmapData.copyPixels(targetDB, targetDB.rect, new Point(), null, null, true);
			targetDB.dispose();
			targetDB = null;
			userClipRenderer.dispose();
		}
		
		private function setComment(value:String):void 
		{
			commentField.text = value;
		}
		
		private function addFullNameDescription():void 
		{
			labelBitmapFullName = new Bitmap();
			addObject(labelBitmapFullName);
			labelBitmapFullName.bitmapData = TextUtils.createTextFieldData(Lang.textFullNameInvoice, _width - Config.DIALOG_MARGIN * 2, 10, 
																			true, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, FontSize.SUBHEAD, true, 
																			Style.color(Style.COLOR_SUBTITLE), Style.color(Style.COLOR_BACKGROUND));
		}
		
		private function onSystemOptions():void {
			if (_isDisposed == true)
				return;
			hidePreloader();
			if (PayManager.systemOptions == null)
				return;
			if (PayManager.systemOptions.currencyList == null || PayManager.systemOptions.currencyList.length == 0)
				return;
			if (iCurrency.value == iCurrency.getDefaultlabel())
			{
				iCurrency.setValue(PayManager.systemOptions.currencyList[0]);
			}
			
			checkDataValid();
		}
		
		private function selectCurrency(e:Event = null):void {
			if (PayManager.systemOptions != null && PayManager.systemOptions.currencyList != null)
			{
				var currencies:Array = PayManager.systemOptions.currencyList.concat();
				if (!("thirdparty" in data) || data.thirdparty == false)
					currencies.unshift(TypeCurrency.DCO);
				
				DialogManager.showDialog(
					ListSelectionPopup,
					{
						items:currencies,
						title:Lang.selectCurrency,
						renderer:ListPayCurrency,
						callback:onCurrencySelected
					}, ServiceScreenManager.TYPE_SCREEN
				);
			}
		}
		
		private function onCurrencySelected(currency:String):void
		{
			if (currency != null)
			{
				iCurrency.setValue(currency);
			}
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			
			var locked:Boolean = false;
			if (data != null && "block" in data == true && data.block == true) {
				locked = true;
			}
			
			if (locked == false)
			{
				if (inputAmount != null) {
					inputAmount.activate();
				}
				if (iCurrency != null)
					iCurrency.activate();
			}
			
			nextButton.activate();
			cancelButton.activate();
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (inputAmount != null) {
				inputAmount.forceFocusOut();
				inputAmount.deactivate();
			}
			if (iCurrency != null)
				iCurrency.deactivate();
			
			nextButton.deactivate();
			cancelButton.deactivate();
		}
		
		override public function dispose():void {
			super.dispose();
			PayManager.S_SEND_MONEY_COMMISSION_RESPOND.remove(onSendMoneyCommissionRespond);
			if (labelBitmapFullName != null)
				UI.destroy(labelBitmapFullName);
			labelBitmapFullName = null;
			if (iCurrency != null)
				iCurrency.dispose();
			iCurrency = null;
			if (inputAmount != null)
				inputAmount.dispose();
			inputAmount = null;
			if (userClip != null)
				UI.destroy(userClip);
			userClip = null;
			if (line != null)
				UI.destroy(line);
			line = null;
		}
	}
}