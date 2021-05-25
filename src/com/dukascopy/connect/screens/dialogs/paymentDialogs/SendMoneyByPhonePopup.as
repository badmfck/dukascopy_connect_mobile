package com.dukascopy.connect.screens.dialogs.paymentDialogs 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.CountriesData;
	import com.dukascopy.connect.data.GiftData;
	import com.dukascopy.connect.data.SelectorButtonData;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.gui.button.DDAccountButton;
	import com.dukascopy.connect.gui.button.DDFieldButton;
	import com.dukascopy.connect.gui.button.SelectorButton;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.input.InputWithPrompt;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.renderers.ListCountry;
	import com.dukascopy.connect.gui.list.renderers.ListLink;
	import com.dukascopy.connect.gui.list.renderers.ListPayCurrency;
	import com.dukascopy.connect.gui.list.renderers.ListPayWalletItem;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.preloader.Preloader;
	import com.dukascopy.connect.gui.scrollPanel.ScrollPanel;
	import com.dukascopy.connect.gui.textedit.PayMessagePreviewBox;
	import com.dukascopy.connect.gui.textedit.TextComposer;
	import com.dukascopy.connect.gui.tools.HorizontalPreloader;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.dialogs.ScreenCountryPicker;
	import com.dukascopy.connect.screens.dialogs.ScreenLinksDialog;
	import com.dukascopy.connect.screens.dialogs.ScreenPayDialog;
	import com.dukascopy.connect.screens.dialogs.x.base.bottom.ListSelectionPopup;
	import com.dukascopy.connect.screens.dialogs.x.base.bottom.SearchListSelectionPopup;
	import com.dukascopy.connect.screens.payments.card.TypeCurrency;
	import com.dukascopy.connect.screens.payments.managers.SendMoneySecureCodeItem;
	import com.dukascopy.connect.screens.serviceScreen.Overlay;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.payments.InvoiceManager;
	import com.dukascopy.connect.sys.payments.PayManager;
	import com.dukascopy.connect.sys.payments.PayRespond;
	import com.dukascopy.connect.sys.payments.PaymentsManager;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.softKeyboard.SoftKeyboard;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import com.telefision.sys.signals.Signal;
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	
	public class SendMoneyByPhonePopup extends BaseScreen {
		
		protected var container:Sprite;
		private var bg:Shape;
		private var text:Bitmap;
		private var acceptButton:BitmapButton;
		private var accountText:Bitmap;
		private var backButton:BitmapButton;
		private var selectorDebitAccont:DDAccountButton;
		private var preloader:Preloader;
		private var screenLocked:Boolean;
		private var verticalMargin:Number;
		private var walletSelected:Boolean;
		private var selectedAccount:Object;
		private var currentCommision:Number = 0;
		private var preloaderShown:Boolean = false;
		private var iAmountCurrency:Input;
		private var selectorCurrency:DDFieldButton;
		private var sendSectionTitle:Bitmap;
		private var accountsPreloader:HorizontalPreloader;
		private var giftData:GiftData;
		private var dataRedy:Boolean;
		private var inptCodeAndPhone:InputWithPrompt;
		private var avatarSize:int;
		private var avatar:Sprite;
		private var avatarBD:ImageBitmapData;
		private var _lastCommissionCallID:String;
		protected var componentsWidth:int;
		private var messageComposerIsOppened:Boolean = false;
		private var messageComposer:TextComposer;
		private var descriptionBox:PayMessagePreviewBox;
		private var userName:String;
		private var startPhoneNumber:String;
		private var secureCodeManager:SendMoneySecureCodeItem = new SendMoneySecureCodeItem();
		private var scrollPanel:ScrollPanel;
		private var bottomClip:Sprite;
		private var purposeSelector:SelectorButton;
		private var needShowPuspoose:Boolean;
		private var needRecieveComission:Boolean;
		
		public function SendMoneyByPhonePopup() {
			
		}
		
		override protected function createView():void {
			super.createView();
			container = new Sprite();
			
			bg = new Shape();
			bg.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			var round:int = Config.FINGER_SIZE * .3;
			var round3:int = round * 3;
			bg.graphics.drawRect(0, 0, round3, round3);
			bg.scale9Grid = new Rectangle(round, round, round, round);
			container.addChild(bg);
			
			avatar = new Sprite();
			container.addChild(avatar);
			
			acceptButton = new BitmapButton();
			acceptButton.setStandartButtonParams();
			acceptButton.setDownScale(1);
			acceptButton.setDownColor(0);
			acceptButton.tapCallback = nextClick;
			acceptButton.disposeBitmapOnDestroy = true;
			acceptButton.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
			container.addChild(acceptButton);
			
			backButton = new BitmapButton();
			backButton.setStandartButtonParams();
			backButton.setDownScale(1);
			backButton.setDownColor(0);
			backButton.tapCallback = backClick;
			backButton.disposeBitmapOnDestroy = true;
			backButton.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
			container.addChild(backButton);
			
			scrollPanel = new ScrollPanel();
			container.addChild(scrollPanel.view);
			
			accountText = new Bitmap();
			scrollPanel.addObject(accountText);
			
			secureCodeManager.createView();
			
			selectorDebitAccont = new DDAccountButton(openWalletSelector);
			scrollPanel.addObject(selectorDebitAccont);
			
			_view.addChild(container);
			
			iAmountCurrency = new Input(Input.MODE_DIGIT_DECIMAL);
			iAmountCurrency.setParams(Lang.textAmount, Input.MODE_DIGIT_DECIMAL);
			iAmountCurrency.S_CHANGED.add(onChangeInputValueCurrency);
			iAmountCurrency.S_FOCUS_IN.add(onInputSelected);
			iAmountCurrency.setRoundBG(false);
			iAmountCurrency.getTextField().textColor = Style.color(Style.COLOR_TEXT);
			iAmountCurrency.setRoundRectangleRadius(0);
			iAmountCurrency.inUse = true;
			scrollPanel.addObject(iAmountCurrency.view);
			
			selectorCurrency = new DDFieldButton(selectCurrencyTap, "");
			scrollPanel.addObject(selectorCurrency);
			
			sendSectionTitle = new Bitmap();
			scrollPanel.addObject(sendSectionTitle);
			
			accountsPreloader = new HorizontalPreloader();
			scrollPanel.addObject(accountsPreloader);
			
			
			inptCodeAndPhone = new InputWithPrompt(Input.MODE_BUTTON);//Pool.getItem(Input) as Input;
			//inptCodeAndPhone.setMode(Input.MODE_DIGIT);
			inptCodeAndPhone.S_TAPPED.add(onInptCodeAndPhoneTap);
			inptCodeAndPhone.S_INFOBOX_TAPPED.add(onInptCodeAndPhoneTap);
			inptCodeAndPhone.S_LONG_TAPPED.add(onLongClick);
			inptCodeAndPhone.S_CHANGED.add(onChangeInputValueCurrency);
			scrollPanel.addObject(inptCodeAndPhone.view);
			
			inptCodeAndPhone.setInfoBox(Lang.textCode);
			inptCodeAndPhone.setLabelText(Lang.enterDestinationPhone);
			inptCodeAndPhone.activate();
			
			descriptionBox = new PayMessagePreviewBox();
			descriptionBox.emptyLabelText = Lang.addYourDescription;//"Add your description...";
			descriptionBox.textValue = "";
			descriptionBox.updateCallback = onDescriptionBoxUpdate;
			descriptionBox.init();
			scrollPanel.addObject(descriptionBox);
			
			bottomClip = new Sprite()
			scrollPanel.addObject(bottomClip);
			bottomClip.graphics.beginFill(0xFFFFFF);
			bottomClip.graphics.drawRect(0, 0, 1, 1);
			bottomClip.graphics.endFill();
			
			purposeSelector = new SelectorButton(onPurposeSelected, getTransferPurposes(), Lang.SPECIFY_PURPOSE_OF_MONEY_TRANSFER_TITLE);
			purposeSelector.alpha = 0;
			purposeSelector.mouseChildren = false;
			purposeSelector.mouseEnabled = false;
			scrollPanel.addObject(purposeSelector);
			purposeSelector.x = Config.DIALOG_MARGIN;
			
			if (Config.SECURE_MONEY_SEND == true)
			{
				scrollPanel.addObject(secureCodeManager.view);
			}
		}
		
		private function getTransferPurposes():Vector.<SelectorButtonData> 
		{
			var result:Vector.<SelectorButtonData> = new Vector.<SelectorButtonData>();
			result.push(new SelectorButtonData(Lang.PURPOSE_OF_MONEY_TRANSFER_TO_RELATIVES, "Transfer to relatives"));
			result.push(new SelectorButtonData(Lang.PURPOSE_OF_MONEY_TRANSFER_TO_FRIENDS,   "Transfer to friends"));
			result.push(new SelectorButtonData(Lang.PURPOSE_OF_MONEY_TRANSFER_FOR_GOODS,    "Payment for goods / services"));
			result.push(new SelectorButtonData(Lang.PURPOSE_OF_MONEY_TRANSFER_OTHER,        "Other"));
			return result;
		}
		
		private function onPurposeSelected():void 
		{
			
		}
		
		private function onInputSelected():void 
		{
			
		}
		
		private function onDescriptionBoxUpdate():void 
		{
			drawView();
		}
		
		private function createMessageComposer():void {
			if (messageComposer == null) {
				messageComposer = new TextComposer();
			}
			messageComposer.MAX_CHARS = 256;
		}
		
		public function showMessageComposer():void {
			messageComposerIsOppened = true;
			deactivateScreen();
			createMessageComposer();
			messageComposer.setSize(MobileGui.stage.stageWidth, MobileGui.stage.stageHeight);
			MobileGui.stage.addChild(messageComposer);
			var messageText:String = "";
			if (giftData != null && giftData.comment != null)
			{
				messageText = giftData.comment;
			}
			
			messageComposer.show(onMessageComposeComplete, Lang.TEXT_COMPOSE_MESSAGE, messageText);
		}
		
		public function hideMessageComposer():void {
			messageComposer.hide();
			activateScreen();
		}
		
		private function onMessageComposeComplete(isOk:Boolean, result:String = "", dataObject:Object = null):void {
			SoftKeyboard.closeKeyboard();
			drawView();
			messageComposerIsOppened = false;
			if (isOk) {
				if (giftData != null)
				{
					giftData.comment = result;
				}
				descriptionBox.textValue = result;
				messageComposer.hide(true);
			} else {
				messageComposer.hide();
			}
			
			activateScreen();
		}
		
		private function onLongClick():void {
			var menuItems:Array = [];
			var clipboardString:String = String(Clipboard.generalClipboard.getData(ClipboardFormats.TEXT_FORMAT));
			
			if (clipboardString == null || clipboardString == "") return;
			
			clipboardString = validatePhone(clipboardString);
			menuItems.push({fullLink: "PASTE FROM CLIPBOARD", id: 0, disabled: clipboardString == ""});
			
			DialogManager.showDialog(ScreenLinksDialog, {
				callback: function (data:Object):void {
					
					if (data.id == 0 && data.disabled == false) {
						var arr:Array = CountriesData.getCountryByPhoneNumber(clipboardString);
						inptCodeAndPhone.setInfoBox('+' + arr[3]);
						inptCodeAndPhone.value = clipboardString.substring(arr[3].length);
						inptCodeAndPhone.setMode(Input.MODE_DIGIT);
					}
				}, data: menuItems, itemClass: ListLink, title: Lang.TEXT_CLIPBOARD, multilineTitle: false
			});
		}
		
		private function validatePhone(value:String):String {
			if (value.length < 6) {
				return Auth.countryCode + value;
			} else if (value.charAt(0) == "0") {
				return Auth.countryCode + value.substr(1);
			}
			
			var arr:Array = CountriesData.getCountryByPhoneNumber(value);
			if (arr == null) {
				return "";
			}
			return value;
		}
		
		private function onInptCodeAndPhoneTap():void {
			
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
					renderer:ListCountry,
					callback:onCountrySelected
				}, ServiceScreenManager.TYPE_SCREEN
			);
			
		//	DialogManager.showDialog(ScreenCountryPicker, {onCountrySelected: onCountrySelected});
		}

		private function onCountrySelected(country:Array):void {
			if (country == null)
				return;
			inptCodeAndPhone.setInfoBox('+' + country[3]);
			inptCodeAndPhone.setMode(Input.MODE_DIGIT);
		}
		
		private function checkDataValid():void
		{
			if (UI.isEmpty(inptCodeAndPhone.value) || inptCodeAndPhone.value == Lang.enterDestinationPhone) {
				acceptButton.deactivate();
				acceptButton.alpha = 0.5;
				return;
			}
			
			if (isActivated && 
				selectedAccount != null && iAmountCurrency.value != null && 
				iAmountCurrency.value != "" && !isNaN(Number(iAmountCurrency.value)))
			{
				acceptButton.activate();
				acceptButton.alpha = 1;
			}
			else{
				acceptButton.deactivate();
				acceptButton.alpha = 0.5;
			}
		}
		
		private function selectCurrencyTap():void 
		{
			var currencies:Array = new Array();
			
			var wallets:Array = PayManager.accountInfo.accounts;
			var l:int = wallets.length;
			var walletItem:Object;
			for (var i:int = 0; i < l; i++)
			{
				walletItem = wallets[i];
				currencies.push(walletItem.CURRENCY)
			}
			
			DialogManager.showDialog(
				ListSelectionPopup,
				{
					items:currencies,
					title:Lang.selectCurrency,
					renderer:ListPayCurrency,
					callback:callBackSelectCurrency
				}, ServiceScreenManager.TYPE_SCREEN
			);
			
		//	DialogManager.showDialog(ScreenPayDialog, {callback: callBackSelectCurrency, data: currencies, itemClass: ListPayCurrency, label: Lang.selectCurrency});
		}
		
		private function openWalletSelector(e:Event = null):void
		{
			SoftKeyboard.closeKeyboard();
			if (iAmountCurrency != null)
			{
				iAmountCurrency.forceFocusOut();
				inptCodeAndPhone.forceFocusOut();
			}
			
			showWalletsDialog();
		}
		
		private function showWalletsDialog():void
		{
			DialogManager.showDialog(
				ListSelectionPopup,
				{
					items:PayManager.accountInfo.accounts.concat(PayManager.getCoins()),
					title:Lang.TEXT_SELECT_ACCOUNT,
					renderer:ListPayWalletItem,
					callback:onWalletSelect
				}, ServiceScreenManager.TYPE_SCREEN
			);
			
		//	DialogManager.showDialog(ScreenPayDialog, {callback: onWalletSelect, data: PayManager.accountInfo.accounts.concat(PayManager.getCoins()), itemClass: ListPayWalletItem/*ListPayAccount*/, label: Lang.TEXT_SELECT_ACCOUNT});
		}
		
		private function onWalletSelect(account:Object, cleanCurrent:Boolean = false):void
		{
			if (account == null)
			{
				if (cleanCurrent == true)
				{
					selectedAccount = account;
				//	selectorCurrency.setValue();
					walletSelected = false;
				}	
			}
			else{
				selectedAccount = account;
				selectorCurrency.setValue(account.CURRENCY);
			}
			if (account != null || cleanCurrent == true)
			{
				selectorDebitAccont.setValue(account);
			}
			checkCommision();
		}
		
		override public function onBack(e:Event = null):void {
			if (screenLocked == false) {
				InvoiceManager.stopProcessInvoice();
				ServiceScreenManager.closeView();
			}
		}
		
		private function backClick():void {
			onBack();
		}
		
		private function compareEnterAndRepeatSC():Boolean {
			var alert:String = secureCodeManager.compareEnterAndRepeatSC();
			var code:String = secureCodeManager.code;
			if (code != "" && alert == "") {
				return true;
			}
			
			if (alert != "") {
				DialogManager.alert(Lang.textAlert, alert);
				return false;
			}
			return true;
		}
		
		private function nextClick():void {
			SoftKeyboard.closeKeyboard();
			
			if (needRecieveComission == true)
			{
				ToastMessage.display(Lang.commisssionWaiting);
				return;
			}
			
			if (purposeSelector.getSelected() == null && needShowPuspoose == true)
			{
				purposeSelector.error();
				return;
			}
			
			if (compareEnterAndRepeatSC() == false) {
				return;
			}
			
			if (iAmountCurrency != null)
			{
				iAmountCurrency.forceFocusOut();
			}
			
			if (giftData != null)
			{
				giftData.accountNumber = selectedAccount.ACCOUNT_NUMBER;
				giftData.currency = selectorCurrency.value;
				giftData.customValue = Number(iAmountCurrency.value);
				if (secureCodeManager.view != null && secureCodeManager.view.parent != null && secureCodeManager.code != null && secureCodeManager.code != "")
				{
					giftData.pass = secureCodeManager.code;
				}
				
				giftData.credit_account_number = UI.isEmpty(inptCodeAndPhone.getInfoBoxValue()) ? inptCodeAndPhone.value : inptCodeAndPhone.getInfoBoxValue() + inptCodeAndPhone.value;
				
				if (purposeSelector.getSelected() != null && needShowPuspoose == true)
				{
					giftData.purpose = purposeSelector.getSelected();
				}
				
				if (giftData.callback != null)
				{
					giftData.callback(giftData);
				}
			}
			
			ServiceScreenManager.closeView();
		}
		
		override public function clearView():void
		{
			super.clearView();
			InvoiceManager.stopProcessInvoice();
		}
		
		private function activateButtons():void
		{
			activateBackButton();
			activateAcceptButton();
		}
		
		private function activateBackButton():void
		{
			if (isDisposed)
			{
				return;
			}
			
			if (backButton != null && isActivated)
			{
				backButton.activate();
			}
		}
		
		private function activateAcceptButton():void
		{
			if (isDisposed)
			{
				return;
			}
			
			if (acceptButton != null && isActivated)
			{
				acceptButton.activate();
				acceptButton.alpha = 1;
			}
		}
		
		override public function initScreen(data:Object = null):void
		{
			super.initScreen(data);
			accountsPreloader.start();
			avatarSize = Config.FINGER_SIZE;
			
			if (data != null && "giftData" in data && data.giftData is GiftData) {
				giftData = data.giftData as GiftData;
			}
			
			if (giftData.userName != null)
			{
				this.userName = giftData.userName;
			}
			
			purposeSelector.setSize(_width - Config.DIALOG_MARGIN * 2);
			
			componentsWidth = _width - Config.DIALOG_MARGIN * 2;
			
			if (giftData != null && giftData.credit_account_number)
			{
				var number:String = giftData.credit_account_number;
				number = number.replace("+", "");
				number = validatePhone(number);
				
				var arr:Array = CountriesData.getCountryByPhoneNumber(number);
				inptCodeAndPhone.setInfoBox('+' + arr[3]);
				inptCodeAndPhone.value = number.substring(arr[3].length);
				inptCodeAndPhone.setMode(Input.MODE_DIGIT);
				
				startPhoneNumber = UI.isEmpty(inptCodeAndPhone.getInfoBoxValue()) ? inptCodeAndPhone.value : inptCodeAndPhone.getInfoBoxValue() + inptCodeAndPhone.value;
			}
			else
			{
				inptCodeAndPhone.setInfoBox('+' + Auth.countryCode.toString());
				inptCodeAndPhone.setMode(Input.MODE_DIGIT);
			}
			
			drawSendTitle();
			drawAccountSelector();
			drawAvatar();
		//	drawAccountText(Lang.chooseAccount);
			drawAcceptButton(Lang.textNext);
			acceptButton.deactivate();
			acceptButton.alpha = 0.5;
			
			drawBackButton();
			
			var itemWidth:int = (componentsWidth - Config.MARGIN) / 2;
			
			iAmountCurrency.width = itemWidth;
			iAmountCurrency.view.x = Config.DIALOG_MARGIN;
			
			selectorCurrency.x = iAmountCurrency.view.x + itemWidth + Config.MARGIN;
			selectorCurrency.setSize(itemWidth, Config.FINGER_SIZE * .8);
			
			avatar.x = _width * .5 - avatar.width * .5;
			
			accountsPreloader.setSize(componentsWidth, int(Config.FINGER_SIZE * .05));
			
			secureCodeManager.initView(false, scrollPanel);
			secureCodeManager.callbackFunc = callbackSC;
			scrollPanel.updateObjects();
			
			if (giftData != null && !isNaN(giftData.minAmount))
			{
				iAmountCurrency.value = giftData.minAmount.toString();
			}
			if (giftData != null && giftData.comment != null)
			{
				descriptionBox.textValue = giftData.comment;
			}
			
			checkData();
		}
		
		
		private function callbackSC():void {
			updatePositions();
		}
		
		private function drawAvatar():void 
		{
			avatarBD = UI.getEmptyAvatarBitmapData(avatarSize * 2, avatarSize * 2);
			ImageManager.drawGraphicCircleImage(avatar.graphics, avatarSize, avatarSize, avatarSize, avatarBD, ImageManager.SCALE_INNER_PROP);
		}
		
		private function checkData():void {
			if (PayManager.accountInfo != null) {
				if (PayManager.systemOptions != null) {
					onDataReady();
				} else {
					accountsPreloader.start();
					getSystemOptions();
				}
			} else {
				PaymentsManager.S_ACCOUNT.add(onAccountLoaded);
				PaymentsManager.activate();
				
			//	accountsPreloader.start();
			//	PayManager.init();
			}
		//	PayManager.S_ACCOUNT.add(onAccountInfo);
		//	PayManager.callGetAccountInfo();
		}
		
		private function onAccountLoaded():void 
		{
			PaymentsManager.S_ACCOUNT.remove(onAccountLoaded);
			PaymentsManager.deactivate();
			
			if (PayManager.systemOptions != null) {
					onDataReady();
				} else {
					accountsPreloader.start();
					getSystemOptions();
				}
		}
		
		private function selectAccount(currency:String):void {
			if (PayManager.accountInfo && PayManager.accountInfo.accounts) {
				var defaultAccount:Object;
				var currencyNeeded:String = currency;
				var wallets:Array = PayManager.accountInfo.accounts;
				var l:int = wallets.length;
				var walletItem:Object;
				for (var i:int = 0; i < l; i++) {
					walletItem = wallets[i];
					if (currencyNeeded == walletItem.CURRENCY) {
						defaultAccount = walletItem;
						break;
					}
				}
				if (defaultAccount != null) {
					onWalletSelect(defaultAccount);
				} else {
					//drawNoAccountMessage();
					onWalletSelect(null, true);
				}
			}
		}
		
		private function onDataReady():void {
			if (_isDisposed) {
				return;
			}
			dataRedy = true;
			accountsPreloader.stop();
			
			dataRedy = true;
			if (isActivated == true)
			{
				selectorDebitAccont.activate();
				selectorCurrency.activate();
			}
			if (giftData != null && giftData.currency != null)
			{
				callBackSelectCurrency(giftData.currency);
			}
			else{
				selectBigAccount();
			}
			
			if (giftData != null && giftData.customValue != 0)
			{
				iAmountCurrency.value = giftData.customValue.toString();
			}
		}
		
		private function selectBigAccount():void 
		{
			var wallets:Array = PayManager.accountInfo.accounts;
			var l:int = wallets.length;
			
			if (giftData != null && giftData.accountNumber != null)
			{
				selectDebitAccountByNumber(giftData.accountNumber);
			}
			else{
				var bigAccount:Object;
				if (wallets != null && wallets.length > 0)
				{
					bigAccount = wallets[0];
				}
				for (var i:int = 0; i < l; i++)
				{
					if (Number(bigAccount.BALANCE) < Number(wallets[i].BALANCE))
					{
						bigAccount = wallets[i];
					}
				}
				if (bigAccount != null)
				{
					onWalletSelect(bigAccount);
				}
			}
		}
		
		private function selectDebitAccountByNumber(accountNumber:String):void 
		{
			var account:Object;
			
			var wallets:Array = PayManager.accountInfo.accounts;
			var l:int = wallets.length;
			var walletItem:Object;
			for (var i:int = 0; i < l; i++)
			{
				walletItem = wallets[i];
				if (accountNumber == walletItem.IBAN)
				{
					account = walletItem;
					break;
				}
			}
			if (account != null)
			{
				selectedAccount = account;
				selectorDebitAccont.setValue(account);
				selectorCurrency.setValue(account.CURRENCY);
			}
		}
		
		private function drawSendTitle():void 
		{
			if (sendSectionTitle.bitmapData)
			{
				sendSectionTitle.bitmapData.dispose();
				sendSectionTitle.bitmapData = null;
			}
			
			var value:String;
			if (userName != null)
			{
				var curentResultPhone:String = UI.isEmpty(inptCodeAndPhone.getInfoBoxValue()) ? inptCodeAndPhone.value : inptCodeAndPhone.getInfoBoxValue() + inptCodeAndPhone.value;
				if (startPhoneNumber != curentResultPhone)
				{
					value = Lang.transferMoneyToPhoneNumber;
				}
				else
				{
					value = Lang.transferMoneyTo + " " + userName;
				}
			}
			else
			{
				value = Lang.transferMoneyToPhoneNumber;
			}
			
			sendSectionTitle.bitmapData = TextUtils.createTextFieldData(value, componentsWidth, 10, true, 
															TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .3, true, 0x777E8A, 0xFFFFFF, false, true);
			sendSectionTitle.x = int(_width * .5 - sendSectionTitle.width * .5);
			
			drawView();
		}
		
		private function getSystemOptions():void 
		{
			if(PayManager.S_SYSTEM_OPTIONS_READY == null)
			{
				PayManager.S_SYSTEM_OPTIONS_READY = new Signal("PayManager.S_SYSTEM_OPTIONS_READY");
			}
			if (PayManager.S_SYSTEM_OPTIONS_ERROR == null)
			{
				PayManager.S_SYSTEM_OPTIONS_ERROR = new Signal("PayManager.S_SYSTEM_OPTIONS_ERROR");
			}
			PayManager.S_SYSTEM_OPTIONS_READY.add(onSystemOptions);
			PayManager.S_SYSTEM_OPTIONS_ERROR.add(onSystemOptions);
			
			callBackGetConfig();
		}
		
		private function onSystemOptions():void
		{
			onDataReady();
		}
		
		private function localSelectCurrency(currency:String):void {
			selectorCurrency.setValue(currency);
			selectorCurrency.activate();
		}
		
		private function callBackSelectCurrency(currency:String):void {
			if (currency == null)
			{
				return;
			}
			
			if (selectorCurrency != null && currency != null) {
				selectorCurrency.setValue(currency);
				
			//	selectAccount(currency);
			//	checkCommision();
			}
			
			selectAccount(currency);
		}
		
		private function callBackGetConfig():void
		{
			PayManager.callGetSystemOptions();
		}
		
		private function showToastMessage():void {
			ToastMessage.display(Lang.connectionError);
		}
		
		private function onChangeInputValueCurrency():void {
			checkCommision();
			checkDataValid();
			checkPhoneNumberChange();
		}
		
		private function checkPhoneNumberChange():void 
		{
			if (giftData != null)
			{
				drawSendTitle();
			}
		}
		
		private function checkCommision(immidiate:Boolean = false):void {
			needShowPuspoose = false;
			_lastCommissionCallID = null;
			currentCommision = 0;
			TweenMax.killDelayedCallsTo(checkCommision);
			
			var needUpdate:Boolean = true;
			
			if (Number(iAmountCurrency.value) <= 0 || selectAccount == null)
			{
				return;
			}
			
			if (needUpdate)
			{
				needRecieveComission = true;
				drawAccountText(Lang.commisionWillBe + "...");
				
				if (immidiate)
				{
					loadCommision();
				}
				else
				{
					TweenMax.delayedCall(1, checkCommision, [true]);
				}
			}
		}
		
		private function loadCommision():void
		{
			if (isDisposed)
			{
				return;
			}
			drawAccountText(Lang.commisionWillBe + "...");
			
			_lastCommissionCallID = new Date().getTime().toString() + "gift";
			
			if (PayManager.S_SEND_MONEY_COMMISSION_RESPOND != null)  {
				PayManager.S_SEND_MONEY_COMMISSION_RESPOND.add(onSendMoneyCommissionRespond);
			}
			
			PayManager.callGetSendMoneyCommission(Number(iAmountCurrency.value), selectorCurrency.value, _lastCommissionCallID);
		}
		
		private function onSendMoneyCommissionRespond(respond:PayRespond):void
		{
			if (isDisposed)
			{
				return;
			}
			
			if (!respond.error)
			{
				handleCommissionRespond(respond.savedRequestData.callID, respond.data);
			}
			else if (respond.hasAuthorizationError == false)
			{
				drawAccountText(Lang.textError + " " + respond.errorMsg);
			}
		}
		
		private function handleCommissionRespond(callID:String, data:Object):void
		{
			if (_lastCommissionCallID == callID)
			{
				needRecieveComission = false;
				
				if (data != null)
				{
					// poluchili kommisiiju
					var commissionObj:Array = data[0];
					
					if (data.length > 1)
					{
						commissionObj = data[1];
					}
					
					var commissionAmount:String = (commissionObj != null && commissionObj[0] != null) ? commissionObj[0] : "";
					
					currentCommision = Number(commissionAmount);
					
					var commissionCurrency:String = (commissionObj != null && commissionObj[1] != null) ? commissionObj[1] : "";
					var commissionText:String = commissionAmount + " " + commissionCurrency;
					
					drawAccountText(Lang.commisionWillBe + " " + commissionText);
					
					if (data.length > 2 && "request_clarification" in data[2] && data[2].request_clarification == true)
					{
						needShowPuspoose = true;
						purposeSelector.activate();
						purposeSelector.alpha = 1;
						purposeSelector.mouseEnabled = true;
					}
					else
					{
						needShowPuspoose = false;
						purposeSelector.deactivate();
						purposeSelector.alpha = 0;
						purposeSelector.mouseChildren = false;
						purposeSelector.mouseEnabled = false;
					}
					updatePositions();
				}
			}
		}
		
		private function onWalletsReady():void {
			if (isDisposed)
				return;
			
			activateScreen();
			setDefaultWallet();
			
			InvoiceManager.S_ACCOUNT_READY.remove(onWalletsReady);
		}
		
		private function setDefaultWallet():void
		{
			if (PayManager.accountInfo == null) return;
			var defaultAccount:Object;
			
			var currencyNeeded:String = TypeCurrency.EUR;
			var wallets:Array = PayManager.accountInfo.accounts;
			var l:int = wallets.length;
			var walletItem:Object;
			for (var i:int = 0; i < l; i++)
			{
				walletItem = wallets[i];
				if (currencyNeeded == walletItem.CURRENCY)
				{
					defaultAccount = walletItem;
					break;
				}
			}
			if (defaultAccount != null)
			{
				onWalletSelect(defaultAccount);
			}
		}
		
		private function drawAccountSelector():void
		{
			selectorDebitAccont.setSize(componentsWidth, Config.FINGER_SIZE * .8);
			selectorDebitAccont.setValue(Lang.TEXT_SELECT_ACCOUNT);
			selectorDebitAccont.x = Config.DIALOG_MARGIN;
		}
		
		private function drawAcceptButton(text:String):void
		{
			var textSettings:TextFieldSettings = new TextFieldSettings(text, 0xFFFFFF, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, 0x78C043, 1, Config.FINGER_SIZE * .8, NaN, (componentsWidth - Config.DIALOG_MARGIN) * .5);
			acceptButton.setBitmapData(buttonBitmap, true);
			acceptButton.x = int(acceptButton.width + Config.DIALOG_MARGIN * 2);
		}
		
		private function drawBackButton():void
		{
			var textSettings:TextFieldSettings = new TextFieldSettings(Lang.textBack, 0, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, 0x78C043, 0, Config.FINGER_SIZE * .8, NaN, (componentsWidth - Config.DIALOG_MARGIN) * .5);
			backButton.setBitmapData(buttonBitmap);
			backButton.x = Config.DIALOG_MARGIN;
		}
		
		private function drawAccountText(text:String):void
		{
			accountText.bitmapData = TextUtils.createTextFieldData(text, componentsWidth, 10, true, TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .24, true, 0xABB8C1, 0xffffff, false);
			accountText.x = int(_width * .5 - accountText.width * .5);
		}
		
		override protected function drawView():void
		{
			if (_isDisposed == true)
				return;
			
			bg.width = _width;
			
			avatar.y = -avatarSize;
			
			verticalMargin = Config.MARGIN * 1.5;
			
			secureCodeManager.drawView(componentsWidth + Config.DOUBLE_MARGIN * 2);
			
			var position:int;
			
			position = verticalMargin + avatarSize;
			
			position += verticalMargin * 0.5;
			
			scrollPanel.view.y = position;
			updatePositions();
			
			scrollPanel.setWidthAndHeight(_width, Math.min(_height - avatarSize * 2 - Config.FINGER_SIZE * 1.8, scrollPanel.itemsHeight));
			
			acceptButton.y = scrollPanel.view.y + scrollPanel.height + Config.DOUBLE_MARGIN;
			backButton.y = acceptButton.y;
			
			bg.height = int(scrollPanel.height + Config.FINGER_SIZE * .9 + backButton.height + avatarSize);
			
			container.y = _height - bg.height;
		}
		
		private function updatePositions():void 
		{
			var position:int = 0;
			// SEND
			sendSectionTitle.y = position;
			position += sendSectionTitle.height + verticalMargin * 3;
			sendSectionTitle.x = int(_width * .5 - sendSectionTitle.width * .5);
			
			
			inptCodeAndPhone.view.x = Config.DIALOG_MARGIN;
			inptCodeAndPhone.width = componentsWidth;
			inptCodeAndPhone.view.y = position;
			position += inptCodeAndPhone.height + verticalMargin;
			
			
			// AMOUNT
			iAmountCurrency.view.y = position;
			selectorCurrency.y = position;
			position += iAmountCurrency.height + verticalMargin * 3.5;
			
			if (purposeSelector != null && purposeSelector.alpha == 1)
			{
				purposeSelector.x = Config.DIALOG_MARGIN;
				purposeSelector.y = position;
				position += purposeSelector.height + verticalMargin * 3.5;
			}
			
			descriptionBox.x = Config.DIALOG_MARGIN;
			descriptionBox.y = position;
			descriptionBox.viewWidth = componentsWidth;
			position += descriptionBox.height +  + verticalMargin * 2;
			
			if (secureCodeManager.view != null && secureCodeManager.view.parent != null)
			{
				secureCodeManager.view.y = position;
				position += secureCodeManager.getRectangel().height + verticalMargin * 1;
				secureCodeManager.view.x = Config.DIALOG_MARGIN;
			}
			
			// ACCOUNT
			selectorDebitAccont.y = position;
			position += selectorDebitAccont.height + verticalMargin * 3;
			accountsPreloader.y = selectorDebitAccont.y + selectorDebitAccont.getHeight();
			accountsPreloader.x = selectorDebitAccont.x;
			accountText.y = position - verticalMargin * 3;
			
			bottomClip.y = accountText.y + accountText.height + Config.MARGIN;
			scrollPanel.updateObjects();
		}
		
		override public function activateScreen():void
		{
			if (_isDisposed == true)
				return;
			
			if (messageComposerIsOppened == true)
			{
				return;
			}
			super.activateScreen();
			
			iAmountCurrency.activate();
			scrollPanel.enable();
			checkDataValid();
			
			backButton.activate();
			secureCodeManager.activate();
			PointerManager.addTap(descriptionBox, onAddMessageClick);
			if (dataRedy == true)
			{
				selectorDebitAccont.activate();
				selectorCurrency.activate();
			}
			inptCodeAndPhone.activate();
		}
		
		private function onAddMessageClick(e:Event = null):void {
			showMessageComposer();
		}
		
		override public function deactivateScreen():void
		{
			if (_isDisposed == true)
				return;
			
			super.deactivateScreen();
			scrollPanel.disable();
			PointerManager.removeTap(descriptionBox, onAddMessageClick);
			iAmountCurrency.deactivate();
			acceptButton.deactivate();
			backButton.deactivate();
			selectorDebitAccont.deactivate();
			inptCodeAndPhone.deactivate();
			selectorCurrency.deactivate();
			secureCodeManager.deactivate();
		}
		
		protected function onCloseTap():void
		{
			DialogManager.closeDialog();
		}
		
		private function onAccountInfo():void {
			
			if (PayManager.systemOptions != null)
			{
				onDataReady();
			}
			else{
				getSystemOptions();
			}
		}
		
		override public function dispose():void
		{
			if (_isDisposed == true)
				return;
			super.dispose();
			
			Overlay.removeCurrent();
			
			if (messageComposer != null) {
				UI.safeRemoveChild(messageComposer);
				messageComposer.dispose();
				messageComposer = null;
				messageComposerIsOppened = false;
			}
			
			PaymentsManager.S_ACCOUNT.remove(onAccountLoaded);
			PaymentsManager.deactivate();
			
			TweenMax.killDelayedCallsTo(checkCommision);
			if (PayManager.S_ACCOUNT)
			{
				PayManager.S_ACCOUNT.remove(onAccountInfo);
			}
			if (PayManager.S_SYSTEM_OPTIONS_READY)
			{
				PayManager.S_SYSTEM_OPTIONS_READY.remove(onSystemOptions);
			}
			if (PayManager.S_SYSTEM_OPTIONS_ERROR){
				PayManager.S_SYSTEM_OPTIONS_ERROR.remove(onSystemOptions);
			}
			if (PayManager.S_SEND_MONEY_COMMISSION_RESPOND){
				PayManager.S_SEND_MONEY_COMMISSION_RESPOND.remove(onSendMoneyCommissionRespond);
			}
			if (purposeSelector != null)
			{
				purposeSelector.dispose();
				purposeSelector = null;
			}
			if(scrollPanel != null)
			{
				scrollPanel.dispose();
				scrollPanel = null;
			}
			if (descriptionBox != null) {
				UI.safeRemoveChild(descriptionBox);
				descriptionBox.dispose();
				descriptionBox = null;
			}
			if(secureCodeManager != null)
			{
				secureCodeManager.dispose();
				secureCodeManager = null;
			}
			if(selectorCurrency != null)
			{
				selectorCurrency.dispose();
				selectorCurrency = null;
			}
			if (sendSectionTitle != null)
			{
				UI.destroy(sendSectionTitle);
				sendSectionTitle = null;
			}
			if (bottomClip != null)
			{
				UI.destroy(bottomClip);
				bottomClip = null;
			}
			if (iAmountCurrency != null)
			{
				iAmountCurrency.dispose();
				iAmountCurrency = null;
			}
			if (text != null)
			{
				UI.destroy(text);
				text = null;
			}
			if (preloader != null)
			{
				preloader.dispose();
				preloader = null;
			}
			if (selectorDebitAccont != null)
			{
				selectorDebitAccont.dispose();
				selectorDebitAccont = null;
			}
			if (backButton != null)
			{
				backButton.dispose();
				backButton = null;
			}
			if (accountText != null)
			{
				UI.destroy(accountText);
				accountText = null;
			}
			if (acceptButton != null)
			{
				acceptButton.dispose();
				acceptButton = null;
			}
			if (bg != null)
			{
				UI.destroy(bg);
				bg = null;
			}
			if (container != null)
			{
				UI.destroy(container);
				container = null;
			}
			if (accountsPreloader != null)
			{
				accountsPreloader.dispose();
				accountsPreloader = null;
			}
			if (inptCodeAndPhone != null)
			{
				inptCodeAndPhone.dispose();
				inptCodeAndPhone = null;
			}
			if (avatarBD != null)
			{
				UI.disposeBMD(avatarBD);
				avatarBD = null;
			}
			if (avatar != null)
			{
				UI.destroy(avatar);
				avatar = null;
			}
			
			giftData = null;
		}
	}
}