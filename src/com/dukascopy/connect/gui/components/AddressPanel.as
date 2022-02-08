package com.dukascopy.connect.gui.components
{
	import assets.EditGeoIcon;
	import assets.GeoIconRed;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.CardDeliveryAddress;
	import com.dukascopy.connect.data.ChangeCardReason;
	import com.dukascopy.connect.data.CountriesData;
	import com.dukascopy.connect.data.SelectorItemData;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.gui.button.DDFieldButton;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.renderers.ListCountrySimple;
	import com.dukascopy.connect.gui.list.renderers.ListLink;
	import com.dukascopy.connect.gui.list.renderers.ListSimpleText;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.screens.dialogs.ScreenLinksDialog;
	import com.dukascopy.connect.screens.dialogs.ScreenPayDialog;
	import com.dukascopy.connect.screens.dialogs.x.base.bottom.ListSelectionPopup;
	import com.dukascopy.connect.screens.dialogs.paymentDialogs.elements.InputField;
	import com.dukascopy.connect.screens.dialogs.x.base.bottom.SearchListSelectionPopup;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.payments.PayManager;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import com.dukascopy.langs.LangManager;
	import com.greensock.TweenMax;
	import fl.controls.TextInput;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin
	 */
	public class AddressPanel extends Sprite
	{
		private var tfAddressTitleBitmap:Bitmap;
		private var tfAddressBitmap:Bitmap;
		private var errorBitmap:Bitmap;
		private var tfAddressIcon:Bitmap;
	//	private var tfAdressContactBitmap:Bitmap;
		private var saveButton:BitmapButton;
		private var cancelButton:BitmapButton;
		private var changeButton:BitmapButton;
		private var onChacnge:Function;
		private var itemWidth:int;
		private var streetInput:InputField;
		private var cityInput:InputField;
		private var nameInput:InputField;
		private var codeInput:InputField;
		private var countrySelector:DDFieldButton;
		private var reasonSelector:DDFieldButton;
		private var container:Sprite;
		private var maskClip:Sprite;
		private var collapsed:Boolean;
		private var minContentHeight:int;
		private var contentHeight:int = -1;
		private var locked:Boolean;
		private var animation:Object;
		private var maxContentHeight:int;
		private var selectedReason:SelectorItemData;
		private var scrollCall:Function;
		private var expandedDrawn:Boolean;
		private var padding:int;
		private var controlHeight:int;
		private var lastSelectedCountry:Array;
		public var addressData:CardDeliveryAddress;
		public var addressUpdated:Boolean;
		
		public function AddressPanel(onChacnge:Function, scrollCall:Function)
		{
			padding = Config.FINGER_SIZE * .2;
			controlHeight = Config.FINGER_SIZE * .7;
			
			this.onChacnge = onChacnge;
			this.scrollCall = scrollCall;
			
			container = new Sprite();
			addChild(container);
			
			maskClip = new Sprite()
			addChild(maskClip);
			
			container.mask = maskClip;
			
			tfAddressTitleBitmap = new Bitmap();
			tfAddressBitmap = new Bitmap();
			errorBitmap = new Bitmap();
			tfAddressIcon = new Bitmap();
		//	tfAdressContactBitmap = new Bitmap();
			
			container.addChild(tfAddressTitleBitmap);
			container.addChild(tfAddressBitmap);
			container.addChild(errorBitmap);
			container.addChild(tfAddressIcon);
		//	container.addChild(tfAdressContactBitmap);
			
			saveButton = new BitmapButton();
			saveButton.setStandartButtonParams();
			saveButton.cancelOnVerticalMovement = true;
			saveButton.setDownScale(1);
			saveButton.setOverlay(HitZoneType.BUTTON);
			saveButton.tapCallback = onSaveClick;
			container.addChild(saveButton);
			
			cancelButton = new BitmapButton();
			cancelButton.setStandartButtonParams();
			cancelButton.cancelOnVerticalMovement = true;
			cancelButton.setDownScale(1);
			cancelButton.setOverlay(HitZoneType.BUTTON);
			cancelButton.tapCallback = onCancelClick;
			container.addChild(cancelButton);
			
			changeButton = new BitmapButton();
			changeButton.setStandartButtonParams();
			changeButton.cancelOnVerticalMovement = true;
			changeButton.setDownScale(1);
			changeButton.setOverlay(HitZoneType.BUTTON);
			changeButton.tapCallback = onChangeClick;
			container.addChild(changeButton);
			
			var icon:Sprite = new GeoIconRed();
			UI.scaleToFit(icon, int(Config.FINGER_SIZE * .4), int(Config.FINGER_SIZE * .4));
			tfAddressIcon.bitmapData = UI.getSnapshot(icon);
			UI.destroy(icon);
			
			icon = new EditGeoIcon();
			UI.scaleToFit(icon, int(Config.FINGER_SIZE * .6), int(Config.FINGER_SIZE * .6));
			changeButton.setBitmapData(UI.getSnapshot(icon), true);
			UI.destroy(icon);
			
			streetInput = new InputField(-1, Input.MODE_INPUT);
			streetInput.onSelectedFunction = onStreetSelected;
			streetInput.underlineColor = Style.color(Style.COLOR_LINE);
			streetInput.restrict = "a-z A-z 0-9 ^[^] \\-\\_,.";
			streetInput.onChangedFunction = onInputChangeStreet;
			streetInput.setMaxChars(70);
			streetInput.setPadding(0);
			container.addChild(streetInput);
			var tf:TextFormat = new TextFormat();
			tf.size = FontSize.BODY;
			tf.color = Style.color(Style.COLOR_TEXT);
			tf.font = Config.defaultFontName;
			streetInput.updateTextFormat(tf);
			
			cityInput = new InputField( -1, Input.MODE_INPUT);
			cityInput.onSelectedFunction = onCitySelected;
			cityInput.underlineColor = Style.color(Style.COLOR_LINE);
			cityInput.onChangedFunction = onInputChangeCity;
			cityInput.setMaxChars(20);
			cityInput.restrict = "a-z A-z 0-9 ^[^] \\_,.";
			cityInput.setPadding(0);
			container.addChild(cityInput);
			cityInput.updateTextFormat(tf);
			
			nameInput = new InputField( -1, Input.MODE_INPUT);
			nameInput.onSelectedFunction = onCitySelected;
			nameInput.underlineColor = Style.color(Style.COLOR_LINE);
			nameInput.onChangedFunction = onInputChangeName;
			nameInput.setMaxChars(20);
			nameInput.restrict = "a-z A-z \\- \\' \\.";
			nameInput.setPadding(0);
			container.addChild(nameInput);
			nameInput.updateTextFormat(tf);
			
			codeInput = new InputField( -1, Input.MODE_INPUT);
			codeInput.onSelectedFunction = onCodeSelected;
			codeInput.underlineColor = Style.color(Style.COLOR_LINE);
			codeInput.onChangedFunction = onInputChangeCode;
			codeInput.setMaxChars(10);
			codeInput.restrict = "a-z A-z 0-9 ^[^] \\_,.";
			codeInput.setPadding(0);
			container.addChild(codeInput);
			codeInput.updateTextFormat(tf);
			
			countrySelector = new DDFieldButton(onCountrySelect, "", true, Style.color(Style.COLOR_LINE), Lang.country);
			container.addChild(countrySelector);
			
			reasonSelector = new DDFieldButton(onReasonSelect, "", true, Style.color(Style.COLOR_LINE), Lang.deliveryChangeReason);
			container.addChild(reasonSelector);
			
			collapsed = true;
		}
		
		private function onCitySelected():void 
		{
			/*if (scrollCall != null)
			{
				TweenMax.delayedCall(0.4, scrollCall, [cityInput.y  - Config.DOUBLE_MARGIN]);
				TweenMax.delayedCall(0.1, scrollCall, [cityInput.y  - Config.DOUBLE_MARGIN]);
				scrollCall(cityInput.y  - Config.DOUBLE_MARGIN);
			}*/
		}
		
		private function onCodeSelected():void 
		{
			/*if (scrollCall != null)
			{
				TweenMax.delayedCall(0.4, scrollCall, [codeInput.y  - Config.DOUBLE_MARGIN]);
				TweenMax.delayedCall(0.1, scrollCall, [codeInput.y  - Config.DOUBLE_MARGIN]);
				scrollCall(codeInput.y  - Config.DOUBLE_MARGIN);
			}*/
		}
		
		private function onStreetSelected():void 
		{
			/*if (scrollCall != null)
			{
				TweenMax.delayedCall(0.4, scrollCall, [streetInput.y  - Config.DOUBLE_MARGIN]);
				TweenMax.delayedCall(0.1, scrollCall, [streetInput.y  - Config.DOUBLE_MARGIN]);
				scrollCall(streetInput.y  - Config.DOUBLE_MARGIN);
			}*/
		}
		
		private function onInputChangeStreet(e:Event = null):void
		{
			streetInput.valid();
		}
		
		private function onInputChangeCity(e:Event = null):void
		{
			cityInput.valid();
		}
		
		private function onInputChangeName(e:Event = null):void
		{
			nameInput.valid();
		}
		
		private function onInputChangeCode(e:Event = null):void
		{
			codeInput.valid();
		}
		
		private function onCountrySelect(e:Event = null):void
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
		//	addSaveButtons();
		}
		
		private function onReasonSelect(e:Event = null):void
		{
		//	DialogManager.showDialog(ScreenLinksDialog, {callback: callBackOnSelectReason, data: getReasons(), itemClass: ListSimpleText, title: Lang.deliveryChangeReason, multilineTitle: true});
			
			DialogManager.showDialog(
				ListSelectionPopup,
				{
					items:getReasons(),
					title:Lang.deliveryChangeReason,
					renderer:ListSimpleText,
					callback:callBackOnSelectReason
				}, DialogManager.TYPE_SCREEN
			);
		}
		
		private function getReasons():Array
		{
			var result:Array = new Array();
			result.push(new SelectorItemData("1. " + Lang.reason_work_addresses, "This is one of my work addresses"));
			result.push(new SelectorItemData("2. " + Lang.reason_trusted_address, "This is the address of a trusted/close person and my residence address is unchanged"));
			result.push(new SelectorItemData("3. " + Lang.reason_secondary_address, "This is my secondary residence address where I spend less than 6 months a year"));
			result.push(new SelectorItemData("4. " + Lang.reason_new_address, "This is my new primary residence address, please update your records"));
			result.push(new SelectorItemData("5. " + Lang.reason_temporary_address, "This is a temporary address where I am in business trip / vacation / studying, etc."));
			return result;
		}
		
		private function callBackOnSelectReason(reason:Object):void
		{
			if (reason != null && reason is SelectorItemData)
			{
				reasonSelector.valid();
				selectedReason = reason as SelectorItemData;
				reasonSelector.setValue(selectedReason.label);
			}
		}
		
		private function onInputChange():void
		{
		
		}
		
		private function onChangeClick():void
		{
			if (locked == true)
			{
				return;
			}
			
			if (collapsed == true)
			{
				expand();
			}
			else
			{
				collapse();
			}
		}
		
		private function collapse():void
		{
			locked = true;
			collapsed = true;
			
			animation = new Object();
			animation.height = contentHeight;
			TweenMax.to(animation, 0.5, {height: minContentHeight, onComplete: unlock, onUpdate: onUpdated});
		}
		
		private function onUpdated():void
		{
			if (animation != null)
			{
				contentHeight = animation.height;
				updateMask();
				
				if (onChacnge != null)
				{
					onChacnge();
				}
			}
		}
		
		private function unlock(clear:Boolean = true):void
		{
			if (clear)
			{
				clearFields();
			}
			
			locked = false;
		}
		
		private function expand(animate:Boolean = true):void
		{
			locked = true;
			collapsed = false;
			
			if (expandedDrawn == false)
			{
				expandedDrawn = true;
				drawExpanded();
				updatePositions();
			}
			
			animation = new Object();
			animation.height = contentHeight;
			if (animate)
			{
				TweenMax.to(animation, 0.5, {height: maxContentHeight, onComplete: onExpanded, onUpdate: onUpdateExpand});
			}
			else
			{
				contentHeight = maxContentHeight;
				updateMask();
				if (onChacnge != null)
				{
					onChacnge();
				}
				if (scrollCall != null)
				{
					scrollCall(tfAddressTitleBitmap.y);
				}
				unlock(false);
			}
		}
		
		private function onUpdateExpand():void 
		{
			onUpdated();
			if (scrollCall != null)
			{
				scrollCall(tfAddressTitleBitmap.y);
			}
		}
		
		private function onExpanded():void 
		{
			unlock();
		}
		
		private function drawExpanded():void 
		{
			this.itemWidth = itemWidth;
			
			countrySelector.setSize(itemWidth - padding * 2, controlHeight);
			reasonSelector.setSize(itemWidth - padding * 2, controlHeight);
			
			countrySelector.setValue(getCountry(getCountryCode()));
		//	countrySelector.alpha = 0.5;
			
			streetInput.draw(itemWidth - padding * 2, Lang.streetAddress, null, null, null, Style.color(Style.FILTER_TABS_COLOR_TAB_BG_SELECTED));
			cityInput.draw(itemWidth - padding * 2, Lang.city, null, null, null, Style.color(Style.FILTER_TABS_COLOR_TAB_BG_SELECTED));
			codeInput.draw(itemWidth - padding * 2, Lang.postalCode, null, null, null, Style.color(Style.FILTER_TABS_COLOR_TAB_BG_SELECTED));
			nameInput.draw(itemWidth - padding * 2, Lang.card_delivery_name, null, null, null, Style.color(Style.FILTER_TABS_COLOR_TAB_BG_SELECTED));
			
			var textSettings:TextFieldSettings = new TextFieldSettings(Lang.textSave, Style.color(Style.COLOR_BACKGROUND), FontSize.BODY, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, Color.GREEN, 1, -1, NaN, ((itemWidth - padding * 3) * .5), -1, Style.size(Style.SIZE_BUTTON_CORNER));
			saveButton.setBitmapData(buttonBitmap, true);
			
			textSettings = new TextFieldSettings(Lang.textCancel, Style.color(Style.COLOR_TEXT), FontSize.BODY, TextFormatAlign.CENTER);
			buttonBitmap = TextUtils.createbutton(textSettings, Style.color(Style.COLOR_BACKGROUND), 1, -1, Style.color(Style.COLOR_LINE_SSL), ((itemWidth - padding * 3) * .5), -1, Style.size(Style.SIZE_BUTTON_CORNER));
			cancelButton.setBitmapData(buttonBitmap, true);
		}
		
		private function onCancelClick():void
		{
			clearFields();
			collapse();
		}
		
		private function clearFields():void
		{
			return;
			
			selectedReason = null;
			reasonSelector.setValue(null);
			streetInput.valueString = null;
			cityInput.valueString = null;
			nameInput.valueString = null;
			codeInput.valueString = null;
		}
		
		private function onSaveClick():void
		{
			if (validate() == true)
			{
				addressData = new CardDeliveryAddress();
				if (PayManager.accountInfo != null)
				{
					addressData.country = getAccountCountry(); 
				}
				if (lastSelectedCountry != null)
				{
					addressData.country = lastSelectedCountry[2];
					lastSelectedCountry = null;
				}
				addressData.address = streetInput.valueString;
				addressData.city = cityInput.valueString;
				addressData.name = nameInput.valueString;
				addressData.code = codeInput.valueString;
				if (selectedReason != null)
				{
					addressData.reason = selectedReason.data as String;
				}
				
				addressUpdated = true;
				
				var errorExist:Boolean = drawAddress();
				updatePositions();
			//	draw(itemWidth);
				
				collapse();
			}
		}
		
		private function fillExistingData():void 
		{
			if (cityInput != null && getAccountCity() != null)
			{
				cityInput.valueString = getAccountCity();
				if (getAccountCity().length > PayManager.accountInfo.cardIssuanceCityMaxLength)
				{
					cityInput.invalid();
				}
			}
			
			if (nameInput != null && getAccountName() != null)
			{
				nameInput.valueString = getAccountName();
				if (getAccountName().length > PayManager.accountInfo.cardIssuanceFullnameMaxLength)
				{
					nameInput.invalid();
				}
			}
			
			if (streetInput != null && getAccountCity() != null)
			{
				streetInput.valueString = getAccountAddress();
				if (getAccountAddress().length > PayManager.accountInfo.cardIssuanceStreetMaxLength)
				{
					streetInput.invalid();
				}
			}
			
			if (codeInput != null && getAccountZip() != null)
			{
				codeInput.valueString = getAccountZip();
			}
		}
		
		private function getAccountCountry():String 
		{
			if (PayManager.accountInfo.country_card != null)
			{
				return PayManager.accountInfo.country_card;
			}
			return PayManager.accountInfo.country;
		}
		
		public function getAccountCity():String 
		{
			if (PayManager.accountInfo.city_card != null)
			{
				return PayManager.accountInfo.city_card;
			}
			return PayManager.accountInfo.city;
		}
		
		public function getAccountAddress():String 
		{
			if (PayManager.accountInfo.address_card != null)
			{
				return PayManager.accountInfo.address_card;
			}
			return PayManager.accountInfo.address;
		}
		
		public function getAccountName():String 
		{
			if (PayManager.accountInfo.fullname_card != null)
			{
				return PayManager.accountInfo.fullname_card;
			}
			return PayManager.accountInfo.firstName + " " + PayManager.accountInfo.lastName;
		}
		
		private function getAccountZip():String 
		{
			if (PayManager.accountInfo.zip_card != null)
			{
				return PayManager.accountInfo.zip_card;
			}
			return PayManager.accountInfo.zip;
		}
		
		private function validate():Boolean
		{
			if (PayManager.accountInfo != null)
			{
				if (cityInput.valueString != null && cityInput.valueString.length > PayManager.accountInfo.cardIssuanceCityMaxLength)
				{
					if (scrollCall != null)
					{
						scrollCall(cityInput.y - Config.FINGER_SIZE);
					}
					cityInput.invalid();
					return false;
				}
				if (nameInput.valueString != null && nameInput.valueString.length > PayManager.accountInfo.cardIssuanceFullnameMaxLength)
				{
					if (scrollCall != null)
					{
						scrollCall(nameInput.y - Config.FINGER_SIZE);
					}
					nameInput.invalid();
					return false;
				}
				if (streetInput.valueString != null && streetInput.valueString.length > PayManager.accountInfo.cardIssuanceStreetMaxLength)
				{
					if (scrollCall != null)
					{
						scrollCall(streetInput.y - Config.FINGER_SIZE);
					}
					streetInput.invalid();
					return false;
				}
			}
			
			if (nameInput.valueString == "" || nameInput.valueString == null)
			{
				if (scrollCall != null)
				{
					scrollCall(nameInput.y - Config.FINGER_SIZE);
				}
				nameInput.invalid();
				return false;
			}
			if (streetInput.valueString == "" || streetInput.valueString == null)
			{
				if (scrollCall != null)
				{
					scrollCall(streetInput.y - Config.FINGER_SIZE);
				}
				streetInput.invalid();
				return false;
			}
			if (cityInput.valueString == "" || cityInput.valueString == null)
			{
				if (scrollCall != null)
				{
					scrollCall(cityInput.y - Config.FINGER_SIZE);
				}
				cityInput.invalid();
				return false;
			}
			if (codeInput.valueString == "" || codeInput.valueString == null)
			{
				if (scrollCall != null)
				{
					scrollCall(codeInput.y - Config.FINGER_SIZE);
				}
				codeInput.invalid();
				return false;
			}
			if (selectedReason == null)
			{
				if (scrollCall != null)
				{
					scrollCall(reasonSelector.y - Config.FINGER_SIZE);
				}
				reasonSelector.invalid();
				return false;
			}
			return true;
		}
		
		public function draw(itemWidth:int):void
		{
			var padding:int = Config.FINGER_SIZE * .2;
			var controlHeight:int = Config.FINGER_SIZE * .7;
			
			this.itemWidth = itemWidth;
			
			if (tfAddressTitleBitmap.bitmapData == null)
			{
				tfAddressTitleBitmap.bitmapData = TextUtils.createTextFieldData(
																		Lang.TEXT_HISTORY_VERIFY_ADDRESES, itemWidth, 
																		10, true, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
																		FontSize.BODY, true, Style.color(Style.COLOR_TEXT));
			}
			
			var errorExist:Boolean = drawAddress();
					
			if (errorExist)
			{
				expand(false);
				fillExistingData();
			}
			else
			{
				collapse();
			}
			
			
			/*var contactText:String = Lang.TEXT_HISTORY_CONTACT + "<a href='mailto:" + Lang.TEXT_HISTORY_CONTACT_EMAIL + "'> <font color='#000000'><u>" + Lang.TEXT_HISTORY_CONTACT_EMAIL + "</u></font></a>" + Lang.TEXT_HISTORY_CONTACT_PART_TWO;
			if (tfAdressContactBitmap.bitmapData != null)
			{
				tfAdressContactBitmap.bitmapData.dispose();
				tfAdressContactBitmap.bitmapData = null;
			}
			tfAdressContactBitmap.bitmapData = TextUtils.createTextFieldData(contactText, itemWidth, 10, true, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, FontSize.BODY, true, Style.color(Style.COLOR_TEXT), Style.color(Style.COLOR_BACKGROUND), false, true);
			*/
			updatePositions();
		}
		
		private function drawAddress():Boolean 
		{
			var realAddress:String = "";
			var error:Boolean = false;
			if (PayManager.accountInfo != null)
			{
				realAddress = getAddressString();
				
				var text:String;
				var errorMessage:String = "";
				
				if (getAccountCity() != null && getAccountCity().length > PayManager.accountInfo.cardIssuanceCityMaxLength)
				{
					text = LangManager.replace(Lang.regExtValue, Lang.card_delivery_city_long, String(PayManager.accountInfo.cardIssuanceCityMaxLength));
					error = true;
					errorMessage += "<font color='" + "#" + Color.RED.toString(16) + "'>" + text + "</font>";
				}
				if (getAccountName() != null && getAccountName().length > PayManager.accountInfo.cardIssuanceFullnameMaxLength)
				{
					text = LangManager.replace(Lang.regExtValue, Lang.card_delivery_name_long, String(PayManager.accountInfo.cardIssuanceFullnameMaxLength));
					error = true;
					errorMessage += "<br/><br/><font color='" + "#" + Color.RED.toString(16) + "'>" + text + "</font>";
				}
				if (getAccountAddress() != null && getAccountAddress().length > PayManager.accountInfo.cardIssuanceStreetMaxLength)
				{
					text = LangManager.replace(Lang.regExtValue, Lang.card_delivery_address_long, String(PayManager.accountInfo.cardIssuanceStreetMaxLength));
					error = true;
					errorMessage += "<br/><br/><font color='" + "#" + Color.RED.toString(16) + "'>" + text + "</font>";
				}
				
				if (errorMessage != "")
				{
					drawError(errorMessage);
				}
			}
			if (tfAddressBitmap.bitmapData != null)
			{
				tfAddressBitmap.bitmapData.dispose();
				tfAddressBitmap.bitmapData = null;
			}
			tfAddressBitmap.bitmapData = TextUtils.createTextFieldData(realAddress, itemWidth - changeButton.width - tfAddressIcon.width - padding * 4, 10, true, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, FontSize.BODY, true, Style.color(Style.COLOR_TEXT), Style.color(Style.FILTER_TABS_COLOR_TAB_BG_SELECTED), false, true);
			
			return error;
		}
		
		private function drawError(value:String):void 
		{
			if (errorBitmap.bitmapData != null)
			{
				errorBitmap.bitmapData.dispose();
				errorBitmap.bitmapData = null;
			}
			errorBitmap.bitmapData = TextUtils.createTextFieldData(value, itemWidth - padding * 2, 10, true, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, FontSize.SUBHEAD_14, true, Style.color(Style.COLOR_TEXT), Style.color(Style.FILTER_TABS_COLOR_TAB_BG_SELECTED), false, true);
		}
		
		private function updatePositions():void 
		{
			streetInput.x = padding;
			cityInput.x = padding;
			nameInput.x = padding;
			codeInput.x = padding;
			countrySelector.x = padding;
			reasonSelector.x = padding;
			
			var position:int = 0;
			
			tfAddressTitleBitmap.y = position;
			position += tfAddressTitleBitmap.height + Config.FINGER_SIZE * .3;
			
			var startFillPosition:int = position;
			position += Config.FINGER_SIZE * .3;
			
			tfAddressIcon.y = position;
			tfAddressIcon.x = padding;
			tfAddressBitmap.y = position;
			tfAddressBitmap.x = int(tfAddressIcon.x + tfAddressIcon.width + padding);
			
			changeButton.x = itemWidth - changeButton.width - padding;
			changeButton.y = position;
			
			position += Math.max(changeButton.height, tfAddressBitmap.height, tfAddressIcon.height) + Config.FINGER_SIZE * .4;
			
			if (errorBitmap != null && errorBitmap.height > 0)
			{
				errorBitmap.y = position;
				errorBitmap.x = int(padding);
				position += errorBitmap.height + Config.FINGER_SIZE * .4;
			}
			
			minContentHeight = position;
			
			nameInput.y = position;
			position += nameInput.height + Config.FINGER_SIZE * .1;
			
			streetInput.y = position;
			position += streetInput.height + Config.FINGER_SIZE * .1;
			
			cityInput.y = position;
			position += cityInput.height + Config.FINGER_SIZE * .1;
			
			codeInput.y = position;
			position += codeInput.height + Config.FINGER_SIZE * .1;
			
			countrySelector.y = position;
			position += countrySelector.height + Config.FINGER_SIZE * .45;
			
			reasonSelector.y = position;
			position += reasonSelector.height + Config.FINGER_SIZE * .4;
			
			cancelButton.x = padding;
			cancelButton.y = position;
			saveButton.y = position;
			saveButton.x = int(itemWidth - saveButton.width - padding);
			
			position += saveButton.height + Config.FINGER_SIZE * .3;
			
			container.graphics.clear();
			container.graphics.beginFill(Style.color(Style.FILTER_TABS_COLOR_TAB_BG_SELECTED));
			container.graphics.drawRoundRect(0, startFillPosition, itemWidth, position - startFillPosition, Config.FINGER_SIZE * .15);
			container.graphics.endFill();
			
			position += Config.FINGER_SIZE * .4;
			
		//	tfAdressContactBitmap.y = position;
		//	position += tfAdressContactBitmap.height + Config.FINGER_SIZE * .3;
			
			if (contentHeight == -1)
			{
				contentHeight = minContentHeight;	
			}
			if (collapsed == false)
			{
				maxContentHeight = position;
			}
			
			updateMask();
		}
		
		private function getCountryCode():String
		{
			if (addressData != null)
			{
				return addressData.country;
			}
			if (PayManager.accountInfo != null)
			{
				return getAccountCountry();
			}
			return "";
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
		
		private function getAddressString():String
		{
			if (addressData != null)
			{
				return addressData.name + ",<br/>" + addressData.address + ",<br/>" + addressData.city + ", " + addressData.code + "<br/>" + getCountry(addressData.country);
			}
			return getAccountName() + ",<br/>" + getAccountAddress() + ",<br/>" + getAccountCity() + ", " + getAccountZip() + "<br/>" + getCountry(getAccountCountry());
		}
		
		private function updateMask():void
		{
			maskClip.graphics.clear();
			maskClip.graphics.beginFill(Style.color(Style.FILTER_TABS_COLOR_TAB_BG_SELECTED));
			maskClip.graphics.drawRoundRect(0, 0, itemWidth, contentHeight, Config.FINGER_SIZE * .15);
			maskClip.graphics.endFill();
			container.scrollRect = new Rectangle(0, 0, maskClip.width, maskClip.height);
		}
		
		override public function get height():Number
		{
			return contentHeight;
		}
		
		public function dispose():void
		{
			TweenMax.killDelayedCallsTo(scrollCall);
			
			onChacnge = null;
			scrollCall = null;
			
			if (tfAddressTitleBitmap != null)
			{
				UI.destroy(tfAddressTitleBitmap);
				tfAddressTitleBitmap = null;
			}
			if (container != null)
			{
				UI.destroy(container);
				container = null;
			}
			if (maskClip != null)
			{
				UI.destroy(maskClip);
				maskClip = null;
			}
			if (tfAddressBitmap != null)
			{
				UI.destroy(tfAddressBitmap);
				tfAddressBitmap = null;
			}
			if (errorBitmap != null)
			{
				UI.destroy(errorBitmap);
				errorBitmap = null;
			}
			if (tfAddressIcon != null)
			{
				UI.destroy(tfAddressIcon);
				tfAddressIcon = null;
			}
			/*if (tfAdressContactBitmap != null)
			{
				UI.destroy(tfAdressContactBitmap);
				tfAdressContactBitmap = null;
			}*/
			if (cancelButton != null)
			{
				cancelButton.dispose();
				cancelButton = null;
			}
			if (changeButton != null)
			{
				changeButton.dispose();
				changeButton = null;
			}
			if (streetInput != null)
			{
				streetInput.dispose();
				streetInput = null;
			}
			if (cityInput != null)
			{
				cityInput.dispose();
				cityInput = null;
			}
			if (nameInput != null)
			{
				nameInput.dispose();
				nameInput = null;
			}
			if (codeInput != null)
			{
				codeInput.dispose();
				codeInput = null;
			}
			if (countrySelector != null)
			{
				countrySelector.dispose();
				countrySelector = null;
			}
			if (reasonSelector != null)
			{
				reasonSelector.dispose();
				reasonSelector = null;
			}
		}
		
		public function activate():void
		{
			cancelButton.activate();
			saveButton.activate();
			changeButton.activate();
			
			streetInput.activate();
			cityInput.activate();
			nameInput.activate();
			codeInput.activate();
			
			countrySelector.activate();
			reasonSelector.activate();
		}
		
		public function deactivate():void
		{
			cancelButton.deactivate();
			saveButton.deactivate();
			changeButton.deactivate();
			
			streetInput.deactivate();
			cityInput.deactivate();
			nameInput.deactivate();
			codeInput.deactivate();
			
			countrySelector.deactivate();
			reasonSelector.deactivate();
		}
		
		public function getSelectedInput():InputField
		{
			if (streetInput != null && streetInput.isSelected())
			{
				return streetInput;
			}
			if (codeInput != null && codeInput.isSelected())
			{
				return codeInput;
			}
			if (cityInput != null && cityInput.isSelected())
			{
				return cityInput;
			}
			if (nameInput != null && nameInput.isSelected())
			{
				return nameInput;
			}
			return null;
		}
	}
}