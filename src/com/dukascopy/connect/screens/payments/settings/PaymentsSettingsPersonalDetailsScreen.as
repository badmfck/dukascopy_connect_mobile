package com.dukascopy.connect.screens.payments.settings {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.CountriesData;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.gui.button.DDFieldButton;
	import com.dukascopy.connect.gui.components.WhiteToast;
	import com.dukascopy.connect.gui.components.WhiteToastSmall;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.renderers.ListCountry;
	import com.dukascopy.connect.gui.list.renderers.ListCountrySimple;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.tools.HorizontalPreloader;
	import com.dukascopy.connect.screens.dialogs.bottom.SearchListSelectionPopup;
	import com.dukascopy.connect.screens.dialogs.paymentDialogs.elements.InputField;
	import com.dukascopy.connect.screens.layout.ScrollScreen;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.payments.PayAPIManager;
	import com.dukascopy.connect.sys.payments.PayManager;
	import com.dukascopy.connect.sys.payments.PayRespond;
	import com.dukascopy.connect.sys.payments.PaymentsManager;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.softKeyboard.SoftKeyboard;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import com.greensock.easing.Power3;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class PaymentsSettingsPersonalDetailsScreen extends ScrollScreen {
		
		private var accountNumber:InputField;
		private var firstNameControl:InputField;
		private var lastNameControl:InputField;
		private var phoneControl:InputField;
		private var emailControl:InputField;
		private var streetControl:InputField;
		private var cityControl:InputField;
		private var postalControl:InputField;
		private var countrySelector:DDFieldButton;
		private var saveButton:BitmapButton;
		private var cancelButton:BitmapButton;
		
		private var padding:int;
		private var allowChange:Boolean;
		private var mailPattern:RegExp = /([a-z0-9._-]+)@([a-z0-9.-]+)\.([a-z]{2,4})/g;
		private var locked:Boolean;
		private var lastSelectedCountry:Array;
		private var filled:Boolean;
		
		public function PaymentsSettingsPersonalDetailsScreen() {
			super();
		}
		
		override public function initScreen(data:Object = null):void {
			PaymentsManager.activate();
			
			if (data == null) {
				data = new Object();
			}
			if ("title" in data == false || data.title == null) {
				data.title = Lang.personalDetails;
			}
			super.initScreen(data);
			
			countrySelector.setSize(_width - padding * 2, Config.FINGER_SIZE * .7);
			
			//if (PayManager.accountInfo == null) {
				drawControls();
				showPreloader();
				PayManager.callGetAccountInfo(fillData);
			//} else {
			//	fillData();
			//}
		}
		
		private function drawControls():void 
		{
			accountNumber.drawString(    _width - padding * 2, Lang.customerNumber, getUserValue("customerNumber"));
			firstNameControl.drawString( _width - padding * 2, Lang.firstName,      getUserValue("firstName"));
			lastNameControl.drawString(  _width - padding * 2, Lang.secondName,     getUserValue("lastName"));
			phoneControl.drawString(     _width - padding * 2, Lang.textPhone,      getUserValue("phone"));
			emailControl.drawString(     _width - padding * 2, Lang.email,          getUserValue("email"));
			streetControl.drawString(    _width - padding * 2, Lang.streetAddress,  getUserValue("address"));
			cityControl.drawString(      _width - padding * 2, Lang.city,           getUserValue("city"));
			postalControl.drawString(    _width - padding * 2, Lang.postalCode,     getUserValue("zip"));
			
			countrySelector.setValue(getCountry(getUserValue("country")));
		}
		
		private function getCountry(code:String):String
		{
			var countryName:String = CountriesData.getByCode(code);
			if (countryName != null)
			{
				return countryName;
			}
			return code;
		}
		
		private function getUserValue(key:String):String 
		{
			if (PayManager.accountInfo != null && key in PayManager.accountInfo && PayManager.accountInfo[key] != null)
			{
				return PayManager.accountInfo[key];
			}
			return null;
		}
		
		private function updatePositions():void 
		{
			var position:int = Config.FINGER_SIZE * .5;
			var gap:int = Config.FINGER_SIZE * .3;
			
			accountNumber.y = position;
			position += accountNumber.getFullHeight() + gap;
			
			firstNameControl.y = position;
			position += firstNameControl.getFullHeight() + gap;
			
			lastNameControl.y = position;
			position += lastNameControl.getFullHeight() + gap;
			
			phoneControl.y = position;
			position += phoneControl.getFullHeight() + gap;
			
			emailControl.y = position;
			position += emailControl.getFullHeight() + gap;
			
			streetControl.y = position;
			position += streetControl.getFullHeight() + gap;
			
			cityControl.y = position;
			position += cityControl.getFullHeight() + gap;
			
			postalControl.y = position;
			position += postalControl.getFullHeight() + gap + Config.FINGER_SIZE * .2;
			
			countrySelector.y = position;
			position += countrySelector.height + gap + Config.FINGER_SIZE * .3;
			
			if (cancelButton != null)
			{
				cancelButton.x = padding;
				cancelButton.y = position;
			}
			if (cancelButton != null)
			{
				saveButton.y = position;
				saveButton.x = int(_width - saveButton.width - padding);
			}
		}
		
		override protected function createView():void {
			super.createView();
			
			padding = Config.DIALOG_MARGIN;
			
			var tf:TextFormat = new TextFormat();
			tf.size = FontSize.BODY;
			tf.color = Style.color(Style.COLOR_TEXT);
			tf.font = Config.defaultFontName;
			
			accountNumber = new InputField( -1, Input.MODE_INPUT);
			accountNumber.setPadding(0);
			accountNumber.updateTextFormat(tf);
			accountNumber.x = padding;
			addObject(accountNumber);
			accountNumber.disable();
			
			firstNameControl = new InputField( -1, Input.MODE_INPUT);
			firstNameControl.onSelectedFunction = onInputSelected;
			firstNameControl.onChangedFunction = onFirstNameChange;
			firstNameControl.setMaxChars(100);
			firstNameControl.restrict = "a-z A-z 0-9 ^[^] \\_,.";
			firstNameControl.setPadding(0);
			firstNameControl.updateTextFormat(tf);
			firstNameControl.x = padding;
			addObject(firstNameControl);
			
			lastNameControl = new InputField( -1, Input.MODE_INPUT);
			lastNameControl.onSelectedFunction = onInputSelected;
			lastNameControl.onChangedFunction = onSecondNameChange;
			lastNameControl.setMaxChars(100);
			lastNameControl.restrict = "a-z A-z 0-9 ^[^] \\_,.";
			lastNameControl.setPadding(0);
			lastNameControl.updateTextFormat(tf);
			lastNameControl.x = padding;
			addObject(lastNameControl);
			
			phoneControl = new InputField( -1, Input.MODE_INPUT);
			phoneControl.onSelectedFunction = onInputSelected;
			phoneControl.onChangedFunction = onPhoneChange;
			phoneControl.setMaxChars(100);
			phoneControl.restrict = "0-9 +";
			phoneControl.setPadding(0);
			phoneControl.updateTextFormat(tf);
			phoneControl.x = padding;
			addObject(phoneControl);
			
			emailControl = new InputField( -1, Input.MODE_INPUT);
			emailControl.onSelectedFunction = onInputSelected;
			emailControl.onChangedFunction = onEmailChange;
			emailControl.setMaxChars(100);
		//	emailControl.restrict = "a-z A-z 0-9 ^[^] \\_,.";
			emailControl.setPadding(0);
			emailControl.updateTextFormat(tf);
			emailControl.x = padding;
			addObject(emailControl);
			
			cityControl = new InputField( -1, Input.MODE_INPUT);
			cityControl.onSelectedFunction = onInputSelected;
			cityControl.onChangedFunction = onCityChange;
			cityControl.setMaxChars(100);
			cityControl.restrict = "a-z A-z 0-9 ^[^] \\_,.";
			cityControl.setPadding(0);
			cityControl.updateTextFormat(tf);
			cityControl.x = padding;
			addObject(cityControl);
			
			streetControl = new InputField( -1, Input.MODE_INPUT);
			streetControl.onSelectedFunction = onInputSelected;
			streetControl.onChangedFunction = onAddressChange;
			streetControl.setMaxChars(200);
			streetControl.restrict = "a-z A-z 0-9 ^[^] \\_,.";
			streetControl.setPadding(0);
			streetControl.updateTextFormat(tf);
			streetControl.x = padding;
			addObject(streetControl);
			
			postalControl = new InputField( -1, Input.MODE_INPUT);
			postalControl.onSelectedFunction = onInputSelected;
			postalControl.onChangedFunction = onPostChange;
			postalControl.setMaxChars(50);
			postalControl.restrict = "a-z A-z 0-9 ^[^] \\_,.";
			postalControl.setPadding(0);
			postalControl.updateTextFormat(tf);
			postalControl.x = padding;
			addObject(postalControl);
			
			countrySelector = new DDFieldButton(onCountrySelect, "", true, Style.color(Style.CONTROL_INACTIVE));
			addObject(countrySelector);
			countrySelector.x = padding;
		}
		
		private function onInputSelected():void 
		{
		//	SoftKeyboard.openKeyboard();
			
			/*TweenMax.delayedCall(10, function():void {
					Input.S_SOFTKEYBOARD.invoke(true);
			}, null, true);*/
		}
		
		override public function activateScreen():void {
			if (_isDisposed)
				return;
			super.activateScreen();
			
			if (locked == false)
			{
				firstNameControl.activate();
				lastNameControl.activate();
				phoneControl.activate();
				emailControl.activate();
				streetControl.activate();
				cityControl.activate();
				postalControl.activate();
				countrySelector.activate();
				countrySelector.activate();
				
				if (cancelButton != null) {
					cancelButton.activate();
				}
				/*if (saveButton != null) {
					saveButton.activate();
				}*/
			}
		}
		
		override public function deactivateScreen():void {
			if (_isDisposed)
				return;
			super.deactivateScreen();
			
			firstNameControl.deactivate();
			lastNameControl.deactivate();
			phoneControl.deactivate();
			emailControl.deactivate();
			streetControl.deactivate();
			cityControl.deactivate();
			postalControl.deactivate();
			countrySelector.deactivate();
			
			if (cancelButton != null) {
				cancelButton.deactivate();
			}
			/*if (saveButton != null) {
				saveButton.activate();
			}*/
		}
		
		override public function onBack(e:Event = null):void
		{
			if (PayManager.accountInfo != null && isDataChanged() && isDataValid() && canSaveChanges())
			{
				DialogManager.alert(Lang.personalDetails, Lang.saveChangesQuestion, saveChangesPromptResponse, Lang.textSave, Lang.textCancel);
			}
			else
			{
				super.onBack();
			}
		}
		
		private function isDataValid():Boolean 
		{
			if (firstNameControl.valueString == null || firstNameControl.valueString == "") {
				return false;
			}
			if (lastNameControl.valueString == null || lastNameControl.valueString == "") {
				return false;
			}
			if (postalControl.valueString == null || postalControl.valueString == "") {
				return false;
			}
			if (streetControl.valueString == null || streetControl.valueString == "") {
				return false;
			}
			if (cityControl.valueString == null || cityControl.valueString == "") {
				return false;
			}
			if (phoneControl.valueString == null || phoneControl.valueString == "") {
				return false;
			}
			
			if (emailControl.valueString == null || emailControl.valueString == "" || emailControl.valueString.match(mailPattern) == false) {
				return false;
			}
			
			return true;
		}
		
		private function isDataChanged():Boolean 
		{
			if (firstNameControl.valueString != getUserValue("firstName")) {
				return true;
			}
			if (lastNameControl.valueString != getUserValue("lastName")) {
				return true;
			}
			if (postalControl.valueString != getUserValue("zip")) {
				return true;
			}
			if (emailControl.valueString != getUserValue("email")) {
				return true;
			}
			if (cityControl.valueString != getUserValue("city")) {
				return true;
			}
			if (streetControl.valueString != getUserValue("address")) {
				return true;
			}
			if (phoneControl.valueString != getUserValue("phone")) {
				return true;
			}
			if (countrySelector.value != getCountry(getUserValue("country"))) {
				return true;
			}
			
			return false;
		}
		
		private function saveChangesPromptResponse(val:int):void 
		{
			if (val == 1)
			{
				saveChanges();
			}
			else
			{
				discardChanges();
				onBack();
			}
		}
		
		private function saveChanges():void 
		{
			if (canSaveChanges() == false)
			{
				showMessage(Lang.updateInfoTimeout, false);
			}
			else
			{
				lock();
				showPreloader();
				PayManager.S_ACCOUNT_UPDATE_RESPOND.add(onDataUpdated);
				PayManager.S_ACCOUNT_UPDATE_ERROR.add(onDataUpdateError);
				
				PayManager.callAccountUpdate(getUserData());
			}
		}
		
		private function canSaveChanges():Boolean 
		{
			if (PayManager.accountInfo != null && PayManager.accountInfo.updatePersonalInfo == false && (new Date()).getTime() - PayManager.accountInfo.updateTime < 1000*60*60*12)
			{
				return false;
			}
			return true;
		}
		
		private function getUserData():Object 
		{
			var result:Object = new Object();
			if (firstNameControl.valueString != getUserValue("firstName") || lastNameControl.valueString != getUserValue("lastName"))
			{
				result.first_name = firstNameControl.valueString;
				result.last_name = lastNameControl.valueString;
			}
			if (streetControl.valueString != getUserValue("address") || 
				postalControl.valueString != getUserValue("zip") || 
				countrySelector.value != getCountry(getUserValue("country")) || 
				cityControl.valueString != getUserValue("city"))
			{
				result.address = streetControl.valueString;
				result.city = cityControl.valueString;
				result.zip = postalControl.valueString;
				if (lastSelectedCountry != null)
				{
					result.country = lastSelectedCountry[2];
				}
				else
				{
					result.country = getUserValue("country");
				}
			}
			if (emailControl.valueString != getUserValue("email"))
			{
				result.email = emailControl.valueString;
			}
			if (phoneControl.valueString != getUserValue("phone"))
			{
				result.phone = phoneControl.valueString;
			}
			
			return result;
		}
		
		private function onDataUpdateError(errorMessage:String, callId:String = null):void 
		{
			hidePreloader();
			unlock();
			showMessage(errorMessage, false);
		}
		
		private function onDataUpdated(r:PayRespond, callId:String = null):void 
		{
			hidePreloader();
			unlock();
			discardChanges();
			showMessage(Lang.accountInfoUpdated, true);
		}
		
		private function lock():void 
		{
			locked = true;
			
			firstNameControl.disable();
			lastNameControl.disable();
			postalControl.disable();
			emailControl.disable();
			streetControl.disable();
			cityControl.disable();
			phoneControl.disable();
			countrySelector.deactivate();
		}
		
		private function unlock():void 
		{
			locked = false;
			
			firstNameControl.enable();
			lastNameControl.enable();
			postalControl.enable();
			emailControl.enable();
			streetControl.enable();
			cityControl.enable();
			phoneControl.enable();
			if (isActivated)
			{
				countrySelector.deactivate();
			}
		}
		
		private function discardChanges():void 
		{
			lastSelectedCountry = null;
			drawControls();
		}
		
		private function onCountrySelect():void 
		{
			var oldDelimiter:String = "";
			var newDelimiter:String = "";
			var cData:Array = CountriesData.COUNTRIES;
			var cDataNew:Array = [];
			for (var i:int = 0; i < cData.length; i++) {
				newDelimiter = String(cData[i][0]).substr(0, 1).toUpperCase();
				if (newDelimiter != oldDelimiter) {
					oldDelimiter = newDelimiter;
					cDataNew.push([oldDelimiter.toLowerCase(), oldDelimiter]);
				}
				cDataNew.push(cData[i]);
			}
			
			DialogManager.showDialog(
					SearchListSelectionPopup,
					{
						items:cDataNew,
						title:Lang.selectCountry,
						renderer:ListCountrySimple,
						callback:onCountryListSelected
					}, ServiceScreenManager.TYPE_SCREEN
				);
		}
		
		private function onCountryListSelected(country:Array):void
		{
			if (country.length == 2)
				return;
			
			lastSelectedCountry = country;
			countrySelector.setValue(country[4]);
			addSaveButtons();
		}
		
		private function onFirstNameChange(e:Event = null):void
		{
			if (firstNameControl != null)
			{
				if (firstNameControl.valueString == null || firstNameControl.valueString == "")
				{
					firstNameControl.invalid();
				}
				else
				{
					firstNameControl.valid();
					if (firstNameControl.valueString == getUserValue("firstName"))
					{
						firstNameControl.drawUnderlineValue(null);
					}
					else
					{
						firstNameControl.drawUnderlineValue(Lang.changed);
					}
					firstNameControl.updatePositions();
				}
			}
			addSaveButtons();
		}
		
		private function addSaveButtons():void
		{
			if (saveButton == null)
			{
				saveButton = new BitmapButton();
				saveButton.setStandartButtonParams();
				saveButton.cancelOnVerticalMovement = true;
				saveButton.setDownScale(1);
				saveButton.setOverlay(HitZoneType.BUTTON);
				saveButton.tapCallback = onSaveClick;
				saveButton.alpha = .7;
				addObject(saveButton);
				
				cancelButton = new BitmapButton();
				cancelButton.setStandartButtonParams();
				cancelButton.cancelOnVerticalMovement = true;
				cancelButton.setDownScale(1);
				cancelButton.setOverlay(HitZoneType.BUTTON);
				cancelButton.tapCallback = onCancelClick;
				addObject(cancelButton);
				
				var textSettings:TextFieldSettings = new TextFieldSettings(Lang.textSave, Color.WHITE, FontSize.BODY, TextFormatAlign.CENTER);
				var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, Color.GREEN, 1, -1, NaN, ((_width - padding * 3) * .5), -1, Style.size(Style.SIZE_BUTTON_CORNER));
				saveButton.setBitmapData(buttonBitmap, true);
				
				textSettings = new TextFieldSettings(Lang.textCancel, Style.color(Style.COLOR_TEXT), FontSize.BODY, TextFormatAlign.CENTER);
				buttonBitmap = TextUtils.createbutton(textSettings, Style.color(Style.COLOR_BACKGROUND), 1, -1, Style.color(Style.COLOR_LINE_SSL), ((_width - padding * 3) * .5), -1, Style.size(Style.SIZE_BUTTON_CORNER));
				cancelButton.setBitmapData(buttonBitmap, true);
				
				if (isActivated) {
					if (filled == true && PayManager.accountInfo.updatePersonalInfo == true) {
						if (saveButton != null) {
							saveButton.activate();
							saveButton.alpha = 1;
						}
					}
					cancelButton.activate();
				}
				drawView();
			}
		}
		
		private function onCancelClick():void {
			if (locked == false) {
				discardChanges();
				onBack();
			}
		}
		
		private function onSaveClick():void {
			if (isDataValid() && locked == false) {
				saveChanges();
			}
		}
		
		private function onSecondNameChange(e:Event = null):void
		{
			if (lastNameControl != null)
			{
				if (lastNameControl.valueString == null || lastNameControl.valueString == "")
				{
					lastNameControl.invalid();
				}
				else
				{
					lastNameControl.valid();
					if (lastNameControl.valueString == getUserValue("lastName"))
					{
						lastNameControl.drawUnderlineValue(null);
					}
					else
					{
						lastNameControl.drawUnderlineValue(Lang.changed);
					}
					lastNameControl.updatePositions();
				}
			}
			addSaveButtons();
		}
		
		private function onPostChange(e:Event = null):void
		{
			if (postalControl != null)
			{
				if (postalControl.valueString == null || postalControl.valueString == "")
				{
					postalControl.invalid();
				}
				else
				{
					postalControl.valid();
					if (postalControl.valueString == getUserValue("zip"))
					{
						postalControl.drawUnderlineValue(null);
					}
					else
					{
						postalControl.drawUnderlineValue(Lang.changed);
					}
					postalControl.updatePositions();
				}
			}
			addSaveButtons();
		}
		
		private function onEmailChange(e:Event = null):void
		{
			if (emailControl != null)
			{
				if (emailControl.valueString == null || emailControl.valueString == "" || emailControl.valueString.match(mailPattern) == false)
				{
					emailControl.invalid();
				}
				else
				{
					emailControl.valid();
					if (emailControl.valueString == getUserValue("email"))
					{
						emailControl.drawUnderlineValue(null);
					}
					else
					{
						emailControl.drawUnderlineValue(Lang.changed);
					}
					emailControl.updatePositions();
				}
			}
			addSaveButtons();
		}
		
		private function onCityChange(e:Event = null):void
		{
			if (cityControl != null)
			{
				if (cityControl.valueString == null || cityControl.valueString == "")
				{
					cityControl.invalid();
				}
				else
				{
					cityControl.valid();
					if (cityControl.valueString == getUserValue("city"))
					{
						cityControl.drawUnderlineValue(null);
					}
					else
					{
						cityControl.drawUnderlineValue(Lang.changed);
					}
					cityControl.updatePositions();
				}
			}
			addSaveButtons();
		}
		
		private function onAddressChange(e:Event = null):void
		{
			if (streetControl != null)
			{
				if (streetControl.valueString == null || streetControl.valueString == "")
				{
					streetControl.invalid();
				}
				else
				{
					streetControl.valid();
					if (streetControl.valueString == getUserValue("address"))
					{
						streetControl.drawUnderlineValue(null);
					}
					else
					{
						streetControl.drawUnderlineValue(Lang.changed);
					}
					streetControl.updatePositions();
				}
			}
			addSaveButtons();
		}
		
		private function onPhoneChange(e:Event = null):void
		{
			if (phoneControl != null)
			{
				if (phoneControl.valueString == null || phoneControl.valueString == "")
				{
					phoneControl.invalid();
				}
				else
				{
					phoneControl.valid();
					if (phoneControl.valueString == getUserValue("phone"))
					{
						phoneControl.drawUnderlineValue(null);
					}
					else
					{
						phoneControl.drawUnderlineValue(Lang.changed);
					}
					phoneControl.updatePositions();
				}
			}
			addSaveButtons();
		}
		
		private function fillData():void {
			if (_isDisposed == true)
				return;
			
			hidePreloader();
			allowChange = true;
			
			if (PayManager.accountInfo == null) {
				onBack();
				return;
			}
			if (PayManager.accountInfo.updatePersonalInfo == true) {
				if (_isActivated == true && saveButton != null) {
					saveButton.activate();
					saveButton.alpha = 1;
				}
			}
			filled = true;
			drawControls();
			drawView();
		}
		
		override protected function drawView():void {
			if (_isDisposed == true)
				return;
			
			updatePositions();
			
			super.drawView();
			
			var selectedInput:InputField = getSelectedControl();
			if (selectedInput != null && !isVisible(selectedInput))
			{
				scrollToPosition(selectedInput.y - Config.MARGIN * 2);
			}
		}
		
		private function getSelectedControl():InputField {
			if (firstNameControl != null && firstNameControl.isSelected()) {
				return firstNameControl;
			}
			if (lastNameControl != null && lastNameControl.isSelected()) {
				return lastNameControl;
			}
			if (phoneControl != null && phoneControl.isSelected()) {
				return phoneControl;
			}
			if (emailControl != null && emailControl.isSelected()) {
				return emailControl;
			}
			if (streetControl != null && streetControl.isSelected()) {
				return streetControl;
			}
			if (cityControl != null && cityControl.isSelected()) {
				return cityControl;
			}
			if (postalControl != null && postalControl.isSelected()) {
				return postalControl;
			}
			
			return null;
		}
		
		override public function clearView():void {
			super.clearView();
		}
		
		override public function dispose():void {
			super.dispose();
			
			PayManager.S_ACCOUNT_UPDATE_RESPOND.remove(onDataUpdated);
			PayManager.S_ACCOUNT_UPDATE_ERROR.remove(onDataUpdateError);
			PaymentsManager.deactivate();
			
			if (accountNumber != null) {
				accountNumber.dispose();
				accountNumber = null;
			}
			if (firstNameControl != null) {
				firstNameControl.dispose();
				firstNameControl = null;
			}
			if (lastNameControl != null) {
				lastNameControl.dispose();
				lastNameControl = null;
			}
			if (phoneControl != null) {
				phoneControl.dispose();
				phoneControl = null;
			}
			if (emailControl != null) {
				emailControl.dispose();
				emailControl = null;
			}
			if (streetControl != null) {
				streetControl.dispose();
				streetControl = null;
			}
			if (cityControl != null) {
				cityControl.dispose();
				cityControl = null;
			}
			if (postalControl != null) {
				postalControl.dispose();
				postalControl = null;
			}
			if (countrySelector != null) {
				countrySelector.dispose();
				countrySelector = null;
			}
			if (saveButton != null) {
				saveButton.dispose();
				saveButton = null;
			}
			if (cancelButton != null) {
				cancelButton.dispose();
				cancelButton = null;
			}
		}
	}
}