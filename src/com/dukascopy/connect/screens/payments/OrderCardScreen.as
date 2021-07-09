package com.dukascopy.connect.screens.payments {
	
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.CardDeliveryAddress;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.gui.button.DDAccountButton;
	import com.dukascopy.connect.gui.button.DDFieldButton;
	import com.dukascopy.connect.gui.components.AddressPanel;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.renderers.ListPayCardType;
	import com.dukascopy.connect.gui.list.renderers.ListPayCurrency;
	import com.dukascopy.connect.gui.list.renderers.ListPayWalletItem;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.preloader.Preloader;
	import com.dukascopy.connect.gui.scrollPanel.ScrollPanel;
	import com.dukascopy.connect.gui.tabs.FilterTabs;
	import com.dukascopy.connect.gui.topBar.TopBarScreen;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.dialogs.bottom.ListSelectionPopup;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.payments.PayManager;
	import com.dukascopy.connect.sys.payments.PaymentsManager;
	import com.dukascopy.connect.sys.paymentsManagerNew.PaymentsManagerNew;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	/**
	 * Screen for ordering payments cards (Virtual and Plastic)
	 * @author Ilya Shcherbakov. Telefision AG.
	 */
	
	public class OrderCardScreen extends BaseScreen {
		
		static public const CARD_TYPE_VIRTUAL:String = "VIRTUAL";
		static public const CARD_TYPE_PLASTIC:String = "PLASTIC";
		
		// View
		private var bg:Shape;
		private var topBar:TopBarScreen;
		private var tabs:FilterTabs;
		private var scrollPanel:ScrollPanel;
			private var tfType:Bitmap;
			private var iType:DDFieldButton;
			private var tfCurrency:Bitmap;
			private var iCurrency:DDFieldButton;
			private var tfAccountsTitle:Bitmap;
			private var iAccounts:DDAccountButton;
			private var tfCommission:Bitmap;
			private var tfCommissionAmount:Bitmap;
			// Additional fields for plastic card delivery
			private var tfDelivery:Bitmap;
			private var iDelivery:DDFieldButton;
			private var addressBox:AddressPanel;
		private var btnContinue:BitmapButton;
			private var busyIndicator:Preloader;
		
		private var paramsObj:Object = { type:CARD_TYPE_VIRTUAL, cardType:"VISA", delivery:"STANDARD" };
		private var lastCallIDOrderCard:String = "";
		private var lastCallIDFee:String = "";
		private var feeReceived:Boolean = false;
		private var feeWaiting:Boolean = false;
		private var ocWaiting:Boolean = false;
		private var firstActivate:Boolean = true;
		
		private var description:Bitmap;
		
		public function OrderCardScreen() {
			super();
		}
		
		override protected function createView():void {
			super.createView();
			
			bg = new Shape();
			bg.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			bg.graphics.drawRect(0, 0, 1, 1);
			_view.addChild(bg);
			
			topBar = new TopBarScreen();
			topBar.y = 0;
			_view.addChild(topBar);
			
			tabs = new FilterTabs();
			
			tabs.view.x = Config.MARGIN;
			tabs.add(Lang.TEXT_VIRTUAL_CARD, CARD_TYPE_VIRTUAL, true, "l");
			tabs.add(Lang.TEXT_PLASTIC_CARD, CARD_TYPE_PLASTIC, false,"r");
			tabs.setBackgroundColor(Style.color(Style.COLOR_BACKGROUND));
			tabs.S_ITEM_SELECTED.add(onTabSelected);
			_view.addChild(tabs.view);
			
			scrollPanel = new ScrollPanel();
			// Config.FINGER_SIZE
			
			scrollPanel.background = false;
			scrollPanel.mask = true;
				tfCurrency = new Bitmap();
				tfCurrency.x = Config.DIALOG_MARGIN;
			scrollPanel.addObject(tfCurrency);
				iCurrency = new DDFieldButton(onSelectCurrency);
				iCurrency.x = Config.DIALOG_MARGIN;
			scrollPanel.addObject(iCurrency);
				tfAccountsTitle = new Bitmap();
				tfAccountsTitle.x = Config.DIALOG_MARGIN;
			scrollPanel.addObject(tfAccountsTitle);
				iAccounts = new DDAccountButton(onSelectAccount);
				iAccounts.x = Config.DIALOG_MARGIN;
			scrollPanel.addObject(iAccounts);
				tfCommission = new Bitmap();
				tfCommission.x = Config.DIALOG_MARGIN;
			scrollPanel.addObject(tfCommission);
				tfCommissionAmount = new Bitmap();
				tfCommissionAmount.x = Config.DIALOG_MARGIN;
			scrollPanel.addObject(tfCommissionAmount);
			_view.addChild(scrollPanel.view);
			
			btnContinue = new BitmapButton();
			btnContinue.setStandartButtonParams();
			btnContinue.cancelOnVerticalMovement = true;
			btnContinue.setDownScale(1);
			btnContinue.setOverlay(HitZoneType.BUTTON);
			btnContinue.tapCallback = onContinueClick;
			btnContinue.x = Config.DOUBLE_MARGIN;
			btnContinue.hide();
			_view.addChild(btnContinue);
			
			description = new Bitmap();
			scrollPanel.addObject(description);
		}
		
		override public function setInitialSize(width:int, height:int):void {
			setWidthAndHeight(width, height);
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			if (data != null && "autofillData" in data && data.autofillData != null) {
				if ("tabID" in data.autofillData && data.autofillData.tabID != null) {
					paramsObj.type = (data.autofillData.tabID == CARD_TYPE_PLASTIC) ? CARD_TYPE_PLASTIC : CARD_TYPE_VIRTUAL;
				}
				if (tabs != null) {
					if (paramsObj.type == CARD_TYPE_PLASTIC)
						tabs.setSelection(CARD_TYPE_PLASTIC, true);
				}
			}
			PaymentsManager.S_ACCOUNT.add(onPaymentAccountReady);
			PaymentsManager.activate();
		}
		
		private function onPaymentAccountReady():void {
			if (PayManager.accountInfo == null)
				return;
			checkForCardTypeNeeded(true);
			if (_isActivated == true) {
				iCurrency.activate();
				iAccounts.activate();
			}
			if (addressBox != null && addressBox.parent != null)
				addressBox.draw(_width - Config.DOUBLE_MARGIN * 2);
		}
		
		override public function setWidthAndHeight(width:int, height:int):void {
			var needToDrawView:Boolean = false;
			if (_width != width) {
				needToDrawView = true;
				_width = width;
				updateComponentSizes();
			}
			if (_height != height) {
				needToDrawView = true;
				_height = height;
			}
			if (needToDrawView == true)
				drawView();
			if (_sw != null)
				_sw.setBounds(width, height, _view);
		}
		
		private function updateComponentSizes():void {
			topBar.setData(Lang.TEXT_CREATE_CARD, true);
			topBar.drawView(_width);
			
			tabs.view.y = topBar.y + topBar.trueHeight;
			
			tabs.setWidthAndHeight(_width - Config.DOUBLE_MARGIN, Config.TOP_BAR_HEIGHT);
			
			scrollPanel.view.y = tabs.view.y + tabs.height + Config.MARGIN;
			
			if (tfType != null)
				tfType.bitmapData = createLabelBMD(Lang.TEXT_CARD_TYPE, FontSize.CAPTION_1);
			if (iType != null)
				iType.setSize(_width - Config.DIALOG_MARGIN * 2, Config.FINGER_SIZE_DOT_75);
			tfCurrency.bitmapData = createLabelBMD(Lang.textCurrency, FontSize.CAPTION_1);
			iCurrency.setSize(_width - Config.DIALOG_MARGIN * 2, Config.FINGER_SIZE_DOT_75);
			tfAccountsTitle.bitmapData = createLabelBMD(Lang.TEXT_PAY_WITH, FontSize.CAPTION_1);
			iAccounts.setSize(_width - Config.DIALOG_MARGIN * 2, Config.FINGER_SIZE_DOT_75);
			if (feeWaiting == true)
				tfCommissionAmount.bitmapData = createLabelBMD(getCommissionText() + ": " + Lang.loading + "…", FontSize.BODY);
			if (tfDelivery != null)
				tfDelivery.bitmapData = createLabelBMD(Lang.textCardDelivery, FontSize.CAPTION_1);
			if (iDelivery != null)
				iDelivery.setSize(_width - Config.DIALOG_MARGIN * 2, Config.FINGER_SIZE_DOT_75);
			if (addressBox != null)
				addressBox.draw(_width - Config.DIALOG_MARGIN * 2);
			
			var textSettings:TextFieldSettings = new TextFieldSettings(
				Lang.BTN_CONTINUE,
				Style.color(Style.COLOR_BACKGROUND),
				FontSize.BODY,
				TextFormatAlign.CENTER
			);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(
				textSettings,
				Color.GREEN,
				1,
				-1,
				NaN,
				(_width - Config.DOUBLE_MARGIN * 2),
				-1,
				Style.size(Style.SIZE_BUTTON_CORNER)
			);
			btnContinue.setBitmapData(buttonBitmap, true);
			btnContinue.setOverflow(10, Config.FINGER_SIZE, Config.FINGER_SIZE, 10);
		}
		
		private function createLabelBMD(label:String, fontSize:int):ImageBitmapData {
			return TextUtils.createTextFieldData(
				label,
				_width - Config.DIALOG_MARGIN * 2,
				10,
				true,
				TextFormatAlign.LEFT,
				TextFieldAutoSize.LEFT,
				fontSize,
				true,
				Style.color(Style.COLOR_SUBTITLE),
				Style.color(Style.COLOR_BACKGROUND)
			);
		}
		
		override protected function drawView():void {
			if (_isDisposed == true)
				return;
			bg.width = _width;
			bg.height = _height;
			if (tfType != null && tfType.parent != null) {
				tfType.y = 0;
				iType.y = tfType.y + tfType.height;
			}
			tfCurrency.y = (tfType == null) ? 0 : iType.y + iType.viewHeight + Config.DOUBLE_MARGIN;
			iCurrency.y = tfCurrency.y + tfCurrency.height;
			tfAccountsTitle.y = iCurrency.y + iCurrency.height + Config.DOUBLE_MARGIN;
			iAccounts.y = tfAccountsTitle.y + tfAccountsTitle.height;
			if (paramsObj.type == CARD_TYPE_VIRTUAL) {
				tfCommissionAmount.y = iAccounts.y + iAccounts.height + Config.MARGIN;
				drawDescription(null);
			} else {
				if (tfDelivery != null && tfDelivery.parent != null) {
					tfDelivery.y = iAccounts.y + iAccounts.height + Config.DOUBLE_MARGIN;
					iDelivery.y = tfDelivery.y + tfDelivery.height;
					tfCommissionAmount.y = iDelivery.y + iDelivery.height + Config.MARGIN;
				} else {
					tfCommissionAmount.y = iAccounts.y + iAccounts.height + Config.MARGIN;
				}
				
				var position:int = tfCommissionAmount.y + tfCommissionAmount.height + Config.DIALOG_MARGIN + Config.MARGIN;
				description.y = position;
				description.x = Config.DIALOG_MARGIN;
				if (description.height > 0)
				{
					position += description.height + Config.DIALOG_MARGIN + Config.MARGIN;
				}
				addressBox.y = position;
			}
			
			btnContinue.y = _height - Config.FINGER_SIZE;
			
			scrollPanel.setWidthAndHeight(_width, _height - scrollPanel.view.y - Config.FINGER_SIZE - Config.MARGIN, false, true);
			if (addressBox != null && addressBox.getSelectedInput() != null)
			{
				scrollPanel.scrollToPosition(addressBox.y + addressBox.getSelectedInput().y - Config.MARGIN * 2, false);
			}
			scrollPanel.update(true);
		}
		
		override public function activateScreen():void {
			super.activateScreen();
			if (_isDisposed == true)
				return;
			if (topBar != null)
				topBar.activate();
			if (tabs != null)
				tabs.activate();
			if (firstActivate == true) {
				if (btnContinue != null) {
					btnContinue.show(.3, .15);
					checkForActivateContinueButton();
				}
			}
			if (iType != null)
				iType.activate();
			if (iCurrency != null)
				iCurrency.activate();
			if (iAccounts != null)
				iAccounts.activate();
			if (iDelivery != null)
				iDelivery.activate();
			if (addressBox != null)
				addressBox.activate();
			scrollPanel.enable();
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			if (_isDisposed == true)
				return;
			if (topBar != null)
				topBar.deactivate();
			if (tabs != null)
				tabs.deactivate();
			if (iType != null)
				iType.deactivate();
			if (iCurrency != null)
				iCurrency.deactivate();
			if (iAccounts != null)
				iAccounts.deactivate();
			if (iDelivery != null)
				iDelivery.deactivate();
			if (btnContinue != null)
				btnContinue.deactivate();
			if (addressBox != null)
				addressBox.deactivate();
			scrollPanel.disable();
		}
		
		private function onTabSelected(id:String):void {
			paramsObj.type = id;
			if (id == CARD_TYPE_PLASTIC)
			{
				addAdditionalFieldsForPlasticCard();
			}
			else
			{
				hideAdditionalFieldsForPlasticCard();
			}
			checkForCardTypeNeeded();
			drawView();
			getCommission();
		}
		
		private function drawDescription(text:String):void 
		{
			if (description.bitmapData != null)
			{
				description.bitmapData.dispose();
				description.bitmapData = null;
			}
			if (text != null)
			{
				description.bitmapData = TextUtils.createTextFieldData(text, _width - Config.DIALOG_MARGIN*2, 10, true, 
							TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, FontSize.BODY, 
							true, Style.color(Style.COLOR_TEXT), Style.color(Style.COLOR_BACKGROUND));
			}
		}
		
		private function checkForActivateContinueButton():void {
			btnContinue.deactivate();
			btnContinue.alpha = .7;
			if (feeReceived == false)
				return;
			if (ocWaiting == true)
				return;
			if ("from" in paramsObj == false || paramsObj.from == null)
				return;
			if (_isActivated == true) {
				btnContinue.activate();
				btnContinue.alpha = 1;
			}
		}
		
		private function checkForCardTypeNeeded(needToRedrawView:Boolean = false):void {
			var needToShow:Boolean = paramsObj.type == CARD_TYPE_PLASTIC && PayManager.accountInfo.plasticMC == true;
			if (needToShow == false)
				needToShow = paramsObj.type == CARD_TYPE_VIRTUAL && PayManager.accountInfo.virtualMC == true;
			if (needToShow == false)
				return;
			if (tfType == null) {
				tfType = new Bitmap();
				tfType.x = Config.DIALOG_MARGIN;
				tfType.bitmapData = createLabelBMD(Lang.TEXT_CARD_TYPE, FontSize.CAPTION_1);
			}
			scrollPanel.addObject(tfType);
			if (iType == null) {
				iType = new DDFieldButton(onSelectType);
				iType.x = Config.DIALOG_MARGIN;
				iType.setSize(_width - Config.DIALOG_MARGIN * 2, Config.FINGER_SIZE_DOT_75);
				iType.setValue("Visa");
			}
			scrollPanel.addObject(iType);
			if (_isActivated == true)
				iType.activate();
			if (needToRedrawView == true)
				drawView();
		}
		
		private function addAdditionalFieldsForPlasticCard():void {
			showCardDelivery();
			showAddress();
		}
		
		private function hideAdditionalFieldsForPlasticCard():void {
			hideCardDelivery();
			hideAddress();
		}
		
		private function showCardDelivery():void {
			if (PayManager.accountInfo == null || PayManager.accountInfo.deliveryExpedited == false)
				return;
			if (tfDelivery == null) {
				tfDelivery = new Bitmap();
				tfDelivery.x = Config.DIALOG_MARGIN;
				tfDelivery.bitmapData = createLabelBMD(Lang.textCardDelivery, FontSize.CAPTION_1);
			}
			scrollPanel.addObject(tfDelivery);
			if (iDelivery == null) {
				iDelivery = new DDFieldButton(onSelectDelivery);
				iDelivery.x = Config.DIALOG_MARGIN;
				iDelivery.setSize(_width - Config.DIALOG_MARGIN * 2, Config.FINGER_SIZE_DOT_75);
				iDelivery.setValue("textDeliveryStandard");
				drawDescription(Lang.cardDeliveryDescriptionStandard);
			}
			scrollPanel.addObject(iDelivery);
			if (_isActivated == true)
				iDelivery.activate();
			
			if (paramsObj != null && "delivery" in paramsObj && paramsObj.delivery == "EXPEDITED")
			{
			//	drawDescription(Lang.cardDeliveryDescriptionExpress);
				drawDescription(null);
			}
			else
			{
				drawDescription(Lang.cardDeliveryDescriptionStandard);
			}
		}
		
		private function hideCardDelivery():void {
			if (tfDelivery != null)
				scrollPanel.removeObject(tfDelivery);
			if (iDelivery != null)
				scrollPanel.removeObject(iDelivery);
		}
		
		private function showAddress():void {
			if (addressBox == null) {
				addressBox = new AddressPanel(scrollPanel.update, scrollCall);
				addressBox.x = Config.DIALOG_MARGIN;
			}
			addressBox.draw(_width - Config.DIALOG_MARGIN * 2);
			scrollPanel.addObject(addressBox);
			if (_isActivated == true)
				addressBox.activate();
		}
		
		private function hideAddress():void {
			scrollPanel.removeObject(addressBox);
		}
		
		private function scrollCall(position:int):void {
			scrollPanel.scrollToPosition(addressBox.y + position - Config.MARGIN * 2, true);
		}
		
		private function onSelectType(e:Event = null):void {
			PayManager.callGetSystemOptions(
				function():void {
					/*DialogManager.showDialog(
						ScreenPayDialog,
						{
							callback:callBackOnSelectType,
							data:PayManager.systemOptions.ppcardsTypes,
							itemClass:ListPayCardType,
							label:Lang.selectCardType
						}
					);*/
					DialogManager.showDialog(
						ListSelectionPopup,
						{
							items:PayManager.systemOptions.ppcardsTypes,
							title:Lang.selectCardType,
							renderer:ListPayCardType,
							callback:callBackOnSelectType
						}, DialogManager.TYPE_SCREEN
					);
				}
			);
		}
		
		private function callBackOnSelectType(cardType:Object):void {
			if (cardType == null)
				return;
			paramsObj.cardType = cardType.type;
			iType.setValue(cardType.title);
			getCommission();
		}
		
		private function onSelectCurrency(e:Event = null):void {
			PayManager.callGetSystemOptions(
				function():void {
					/*DialogManager.showDialog(
						ScreenPayDialog,
						{
							callback:callBackOnSelectCurrency, 
							data:PayManager.systemOptions.ppcardsCurrencies,
							itemClass:ListPayCurrency, 
							label:Lang.selectCurrency
						}
					);*/
					DialogManager.showDialog(
						ListSelectionPopup,
						{
							items:PayManager.systemOptions.ppcardsCurrencies,
							title:Lang.selectCurrency,
							renderer:ListPayCurrency,
							callback:callBackOnSelectCurrency
						}, DialogManager.TYPE_SCREEN
					);
				}
			);
		}
		
		private function callBackOnSelectCurrency(currency:String):void {
			if (currency == null)
				return;
			paramsObj.currency = currency;
			iCurrency.setValue(currency);
			getCommission();
			iCurrency.valid();
		}
		
		private function onSelectAccount(e:Event = null):void {
			if (PayManager.accountInfo == null) {
				PaymentsManager.updateAccount();
				return;
			}
			
			var wallets:Array = PaymentsManagerNew.filterEmptyWallets(PayManager.accountInfo.accounts);
			
			DialogManager.showDialog(
				ListSelectionPopup,
				{
					items:wallets,
					title:Lang.TEXT_SELECT_ACCOUNT,
					renderer:ListPayWalletItem,
					callback:callBackOnSelectAccount
				}, DialogManager.TYPE_SCREEN
			);
		}
		
		private function callBackOnSelectAccount(account:Object):void {
			if (account == null)
				return;
			paramsObj.from = account.ACCOUNT_NUMBER;
			paramsObj.debitCurrency = account.CURRENCY;
			iAccounts.setValue(account);
			iAccounts.valid();
			getCommission();
			checkForActivateContinueButton();
		}
		
		private function onSelectDelivery(e:Event = null):void {
			PayManager.callGetSystemOptions(
				function():void {
					DialogManager.showDialog(
						ListSelectionPopup,
						{
							items:PayManager.systemOptions.ppDelivery,
							title:Lang.selectDelivery,
							renderer:ListPayCardType,
							callback:callBackOnSelectDelivery
						}, DialogManager.TYPE_SCREEN
					);
				}
			);
		}
		
		private function callBackOnSelectDelivery(delivery:Object):void {
			if (delivery == null)
				return;
			paramsObj.delivery = delivery.type;
			iDelivery.setValue(delivery.title);
			
			if (delivery.type == "STANDARD") {
				drawDescription(Lang.cardDeliveryDescriptionStandard);
			} else {
			//	drawDescription(Lang.cardDeliveryDescriptionExpress);
				drawDescription(null);
			}
			drawView();
			
			getCommission();
		}
		
		private function getCommission():void {
			if ("currency" in paramsObj == false)
				return;
			feeWaiting = true;
			feeReceived = false;
			lastCallIDFee = new Date().getTime().toString();
			tfCommissionAmount.bitmapData = createLabelBMD(getCommissionText() + ": " + Lang.loading + "…", FontSize.BODY);
			PayManager.S_PPCARD_COMMISSION_RECEIVE.add(onCommissionReceived);
			PayManager.callGetCardCommission(paramsObj.type, paramsObj.currency, paramsObj.debitCurrency, paramsObj.cardType, paramsObj.delivery, lastCallIDFee);
		}
		
		private function onCommissionReceived(data:Object, callID:String):void {
			if (lastCallIDFee != callID)
				return;
			feeWaiting = false;
			feeReceived = true;
			if (data == null) {
				tfCommissionAmount.bitmapData = createLabelBMD(getCommissionText() + ": " + "-", FontSize.BODY);
				return;
			}
			var commissionText:String = "";
			var firstPart:Array = data[0];
			var secondPart:Array = data[1];
			if (firstPart[1] == secondPart[1])
				commissionText = firstPart[0] + " " + firstPart[1];
			else
				commissionText = firstPart[0] + " " + firstPart[1] + " (" + secondPart[0] + " " + secondPart[1] + ")";

			if (data.length > 2)
			{
				commissionText += "\n" + Lang.monthlyFee + ": " + data[2][0] + " " + data[2][1];
			}

			tfCommissionAmount.bitmapData = createLabelBMD(getCommissionText() + ": " + commissionText, FontSize.BODY);
			PayManager.S_PPCARD_COMMISSION_RECEIVE.remove(onCommissionReceived);
			checkForActivateContinueButton();
			drawView();
		}
		
		private function getCommissionText():String 
		{
			if (paramsObj != null && paramsObj.type == CARD_TYPE_VIRTUAL) {
				return Lang.textCommission;
			}
			
			if (paramsObj != null && "delivery" in paramsObj && paramsObj.delivery == "EXPEDITED")
			{
				return Lang.cardOrderDelivery;
			} else {
				return Lang.textCommission;
			}
		}
		
		private function onContinueClick(...rest):void {
			var termText:String = PayManager.systemOptions.terms;
			if (termText == null)
				termText = " ";
			DialogManager.alert(
				Lang.TEXT_TERMS_CONDITIONS,
				termText,
				onTermsAndConditionsCallback,
				Lang.confirm,
				Lang.textCancel,
				null,
				TextFormatAlign.LEFT,
				true
			);
		}
		
		private function onTermsAndConditionsCallback(value:int):void {
			if (value != 1)
				return;
			ocWaiting = true;
			btnContinue.deactivate();
			btnContinue.alpha = 0.7;
			showLoadingIndicator()
			lastCallIDOrderCard = new Date().getTime().toString();
			PayManager.S_PPCARD_ISSUE_RECEIVE.add(onCardCreateComplete);
			var newDeliveryAddress:CardDeliveryAddress;
			if (addressBox != null && addressBox.addressUpdated == true)
				newDeliveryAddress = addressBox.addressData;
			PayManager.callIssueNewCard(
				Number(paramsObj.from),
				paramsObj.type,
				paramsObj.currency,
				paramsObj.cardType,
				paramsObj.delivery,
				lastCallIDOrderCard,
				newDeliveryAddress
			);
		}
		
		private function onCardCreateComplete(callID:String , data:Object):void {
			if (lastCallIDOrderCard != callID)
				return;
			ocWaiting = false;
			hideLoadingIndicator();
			PayManager.S_PPCARD_ISSUE_RECEIVE.remove(onCardCreateComplete);
			btnContinue.activate();
			btnContinue.alpha = 1;
			if (data != null)
				DialogManager.alert(Lang.textSuccess , Lang.cardHasBeenIssued, onAlertOk);
		}
		
		private function showLoadingIndicator():void {
			if (busyIndicator == null)
				busyIndicator = new Preloader(Config.FINGER_SIZE * .4);
			if (btnContinue != null) {
				busyIndicator.y = btnContinue.height * .5;
				busyIndicator.x = btnContinue.width - Config.FINGER_SIZE * .4 - 10;
				btnContinue.addChild(busyIndicator);
				busyIndicator.show();
			}
		}
		
		private function hideLoadingIndicator():void {
			if (busyIndicator != null)
				busyIndicator.hide(true);
			busyIndicator = null;
		}
		
		private function onAlertOk(i:int):void 	{
			MobileGui.S_DIALOG_CLOSED.add(onDialogClose);
		}
		
		private function onDialogClose():void {
			MobileGui.S_BACK_PRESSED.invoke();
		}
		
		override public function clearView():void {
			super.clearView();
			if (bg != null)
				UI.destroy(bg);
			bg = null;
			if (topBar != null)
				topBar.dispose();
			topBar = null;
			if (tabs != null)
				tabs.dispose();
			tabs = null;
			if (tfType != null)
				UI.destroy(tfType);
			tfType = null;
			if (iType != null)
				iType.dispose();
			iType = null;
			if (tfCurrency != null)
				UI.destroy(tfCurrency);
			tfCurrency = null;
			if (iCurrency != null)
				iCurrency.dispose();
			iCurrency = null;
			if (tfAccountsTitle != null)
				UI.destroy(tfAccountsTitle);
			tfAccountsTitle = null;
			if (iAccounts != null)
				iAccounts.dispose();
			iAccounts = null;
			if (tfDelivery != null)
				UI.destroy(tfDelivery);
			tfDelivery = null;
			if (iDelivery != null)
				iDelivery.dispose();
			iDelivery = null;
			if (tfCommissionAmount != null)
				UI.destroy(tfCommissionAmount);
			tfCommissionAmount = null;
			if (addressBox != null)
				addressBox.dispose();
			addressBox = null;
			if (btnContinue != null)
				btnContinue.dispose();
			btnContinue = null;
			if (busyIndicator != null)
				busyIndicator.dispose();
			busyIndicator = null;
			if (description != null)
				UI.destroy(description);
			description = null;
		}
		
		override public function dispose():void {
			MobileGui.S_DIALOG_CLOSED.remove(onDialogClose);
			PayManager.S_PPCARD_COMMISSION_RECEIVE.remove(onCommissionReceived);
			PayManager.S_PPCARD_ISSUE_RECEIVE.remove(onCardCreateComplete);
			PaymentsManager.S_ACCOUNT.remove(onPaymentAccountReady);
			PaymentsManager.deactivate();
			paramsObj = null;
			lastCallIDOrderCard = "";
			lastCallIDFee = "";
			super.dispose();
		}
	}
}