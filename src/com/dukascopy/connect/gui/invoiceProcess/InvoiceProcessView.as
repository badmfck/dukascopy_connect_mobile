package com.dukascopy.connect.gui.invoiceProcess 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.SelectorButtonData;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.data.coinMarketplace.PaymentsAccountsProvider;
	import com.dukascopy.connect.gui.button.DDAccountButton;
	import com.dukascopy.connect.gui.button.SelectorButton;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.renderers.ListPayWalletItem;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.menuVideo.BitmapToggleSwitch;
	import com.dukascopy.connect.screens.dialogs.bottom.ListSelectionPopup;
	import com.dukascopy.connect.screens.layout.ScrollScreen;
	import com.dukascopy.connect.screens.payments.card.TypeCurrency;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.payments.InvoiceManager;
	import com.dukascopy.connect.sys.payments.PayManager;
	import com.dukascopy.connect.sys.payments.PayRespond;
	import com.dukascopy.connect.sys.payments.advancedPayments.vo.PayTaskVO;
	import com.dukascopy.connect.sys.phonebookManager.PhonebookManager;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.store.Store;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.style.presets.Color;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import com.dukascopy.langs.LangManager;
	import com.greensock.TweenMax;
	import com.greensock.easing.Expo;
	import com.greensock.easing.Quint;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	public class InvoiceProcessView extends ScrollScreen 
	{
		private var btnSend:BitmapButton;
		private var selectorDebitAccont:DDAccountButton;
		private var paramsObj:Object;
		private var _isInited:Boolean  = false;
		private var _commissionReady:Boolean = false;
		private var _inTransactionProcess:Boolean = false;
		private var INVOICE_LAST_CALL_ID:String = "";
		private var accounts:PaymentsAccountsProvider;
		private var toggler:BitmapToggleSwitch;
		private var needCheckbox:Boolean;
		private var togglerDescription:Bitmap;
		private var target:Sprite;
		private var recepientTitle:Bitmap;
		private var amountTitle:Bitmap;
		private var commissionTitle:Bitmap;
		private var recepient:Bitmap;
		private var amount:Bitmap;
		private var commission:Bitmap;
		private var dataBack:Sprite;
		private var purposeSelector:SelectorButton;
		private var created:Boolean;
		
		public function InvoiceProcessView() {
			if (false) super();
		}
		
		public function initialize(target:Sprite):void
		{
			this.target = target;
			
			InvoiceManager.S_START_PROCESS_INVOICE.add(onStartProcessInvoice);
			InvoiceManager.S_STOP_PROCESS_INVOICE.add(onStopProcessInvoice);
		}
		
		public function setSizes(_width:int, _height:int):void
		{
			this._width = _width;
			this._height = _height;
		}
		
		public function init():void	{			
			if (_isInited) return;
			_isInited = true;
			createView();
			target.addChild(view);
			setInitialSize(_width, _height);
			setWidthAndHeight(_width, _height);
			initScreen();
			drawView();
		}
		
		override protected function getBottomConfigHeight():int 
		{
			return btnSend.height + Config.DIALOG_MARGIN * 2;
		}
		
		override public function initScreen(data:Object = null):void
		{
			var titleText:String = "";
			var currentInvoiceData:Object = InvoiceManager.getCurrentInvoiceData();
			
			if (currentInvoiceData.customDialogTitle !=""){
				titleText = currentInvoiceData.customDialogTitle;
			}else{
				titleText = Lang.processingInvoiceTitle;
			}
			
			super.initScreen({title:titleText});
			overrideOnBack(onBack);
			
			recepientTitle.bitmapData = TextUtils.createTextFieldData(Lang.recepient, 
												_width - Config.DIALOG_MARGIN * 2, 10, true, 
												TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, FontSize.BODY, true, Style.color(Style.COLOR_SUBTITLE));
			amountTitle.bitmapData = TextUtils.createTextFieldData(Lang.amount, 
												_width - Config.DIALOG_MARGIN * 2, 10, true, 
												TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, FontSize.BODY, true, Style.color(Style.COLOR_SUBTITLE));
			commissionTitle.bitmapData = TextUtils.createTextFieldData(Lang.textCommission, 
												_width - Config.DIALOG_MARGIN * 2, 10, true, 
												TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, FontSize.BODY, true, Style.color(Style.COLOR_SUBTITLE));
			
			var userName:String = "";
			if (currentInvoiceData.destinationUserName != null)
			{
				userName = currentInvoiceData.destinationUserName;
			}
			recepient.bitmapData = TextUtils.createTextFieldData(userName, 
												_width -Config.DIALOG_MARGIN * 2, 10, true, 
												TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, FontSize.AMOUNT, true, Style.color(Style.COLOR_TEXT));
			var currency:String = currentInvoiceData.currency;
			if (Lang[currency])
			{
				currency = Lang[currency];
			}
			amount.bitmapData = TextUtils.createTextFieldData(currentInvoiceData.amount + " " + currency, 
												_width -Config.DIALOG_MARGIN * 2, 10, true, 
												TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, FontSize.AMOUNT, true, Style.color(Style.COLOR_TEXT));
			drawCommission("");
			
			selectorDebitAccont.setSize(_width - Config.DIALOG_MARGIN * 2, Config.FINGER_SIZE * .8);
			
			drawButton(Lang.sendMoney);
			
			updatePositions();
			
			updateCommissionText();
		}
		
		private function updateCommissionText():void 
		{
			var invoiceData:PayTaskVO = InvoiceManager.getCurrentInvoiceData();		
			if (invoiceData.currency != TypeCurrency.DCO)
			{
				if (commissionTitle != null)
				{
					addObject(commissionTitle);
				}
				if (commission != null)
				{
					addObject(commissionTitle);
				}
			}
			else
			{
				if (commissionTitle != null)
				{
					removeObject(commissionTitle);
				}
				if (commission != null)
				{
					removeObject(commissionTitle);
				}
			}
		}
		
		private function drawCommission(text:String):void 
		{
			if (commission.bitmapData != null)
			{
				commission.bitmapData.dispose();
				commission.bitmapData = null;
			}
			commission.bitmapData = TextUtils.createTextFieldData(text, 
												_width -Config.DIALOG_MARGIN * 2, 10, true, 
												TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, FontSize.AMOUNT, true, Style.color(Style.COLOR_TEXT));
		}
		
		private function drawButton(text:String):void {
			var textSettings:TextFieldSettings = new TextFieldSettings(text, Style.color(Style.COLOR_BACKGROUND), FontSize.BODY, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, Color.GREEN, 1, -1, NaN, _width - Config.DIALOG_MARGIN * 2, int(Config.FINGER_SIZE * .3), Style.size(Style.SIZE_BUTTON_CORNER));
			btnSend.setBitmapData(buttonBitmap, true);
			btnSend.x = int(_width * .5 - btnSend.width * .5);
		}
		
		private function updatePositions():void 
		{
			dataBack.graphics.clear();
			
			var position:int = Config.FINGER_SIZE * .5;
			
			recepientTitle.x = Config.DIALOG_MARGIN;
			recepientTitle.y = position;
			position += recepientTitle.height + Config.FINGER_SIZE * .2;
			
			recepient.x = Config.DIALOG_MARGIN;
			recepient.y = position;
			position += recepient.height + Config.FINGER_SIZE * .5;
			
			amountTitle.x = Config.DIALOG_MARGIN;
			commissionTitle.x = int(_width * .5) + Config.DIALOG_MARGIN;
			amountTitle.y = position;
			commissionTitle.y = position;
			position += amountTitle.height + Config.FINGER_SIZE * .2;
			
			amount.x = Config.DIALOG_MARGIN;
			commission.x = int(_width * .5) + Config.DIALOG_MARGIN;
			amount.y = position;
			commission.y = position;
			position += amount.height + Config.FINGER_SIZE * .45;
			
			dataBack.graphics.beginFill(Style.color(Style.COLOR_LIST_SPECIAL));
			dataBack.graphics.drawRect(0, 0, _width, position);
			position += Config.FINGER_SIZE * .3;
			
			selectorDebitAccont.y = position;
			position += selectorDebitAccont.height + Config.FINGER_SIZE * .4;
			
			if (purposeSelector != null)
			{
				purposeSelector.y = position;
				position += purposeSelector.height + Config.FINGER_SIZE * .6;
			}
			
			if (toggler != null)
			{
				togglerDescription.y = position;
				toggler.y = int(togglerDescription.y + togglerDescription.height * .5 - toggler.height * .5);
				toggler.x = int(_width - toggler.width - Config.DIALOG_MARGIN);
			}
			
			drawView();
		}
		
		private function onLoad(data:Object, error:Boolean):void 
		{
			if (_isDisposed == true)
			{
				return;
			}
			needCheckbox = false;
			if (error == true || data == null)
			{
				needCheckbox = true;
			}
			else if (data != null)
			{
				needCheckbox = false;
			}
			if (PhonebookManager.getUserModelByUserUID("123") != null)
			{
				needCheckbox = false;
			}
			
			if (needCheckbox == true && toggler == null) {
				toggler = new BitmapToggleSwitch();
				toggler.setDownScale(1);
				toggler.setDownColor(0x000000);
				toggler.setOverflow(5, Config.FINGER_SIZE_DOT_25, Config.FINGER_SIZE_DOT_25, 5);
				toggler.show(0);
				
				var icon:Sprite = new SWFToggleBg2();
				UI.colorize(icon, Style.color(Style.TOGGLER_UNSELECTED));
				
				toggler.setDesignBitmapDatas(UI.renderAssetExtended(icon, Config.FINGER_SIZE * 0.60, Config.FINGER_SIZE * .4, true, "OptionSwitcher.TOGGLERBG_BMD"), 
											 UI.renderAssetExtended(new SWFToggler2(), Config.FINGER_SIZE * .55, Config.FINGER_SIZE * .55, true, "OptionSwitcher.TOGGLER_BMD"));
				toggler.setOverflow(8, 25,25, 8);
				toggler.isSelected = false;
				toggler.tapCallback = onTogglerTap;
				toggler.activate();
				toggler.disposeBitmapOnDestroy = false;// because we dispose commonly used bitmap data, it can break switcher inside other screen with same assset reference (static asset)
				addObject(toggler);
				
				toggler.x = Config.DIALOG_MARGIN;
				
				togglerDescription = new Bitmap();
				togglerDescription.x = Config.DIALOG_MARGIN;
				togglerDescription.bitmapData = TextUtils.createTextFieldData(Lang.invoiceDescription, 
												_width - toggler.width - Config.MARGIN - Config.DIALOG_MARGIN * 2, 10, true, 
												TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, FontSize.BODY, true, Style.color(Style.COLOR_TEXT));
				addObject(togglerDescription);
				updatePositions();
			}
			updateSendButtonVisibility();
		}
		
		private function onTogglerTap():void 
		{
			updateSendButtonVisibility();
		}
		
		override protected function createView():void {
			if (!created)
			{
				super.createView();
				created = true;
			}
			
			
			dataBack = new Sprite();
			addObject(dataBack);
			
			selectorDebitAccont = new DDAccountButton(openWalletSelector);
			selectorDebitAccont.x = Config.DIALOG_MARGIN;
			addObject(selectorDebitAccont);
			
			btnSend = new BitmapButton();
			btnSend.setStandartButtonParams();
			btnSend.setDownScale(1);
			btnSend.usePreventOnDown = false;
			btnSend.cancelOnVerticalMovement = true;
			btnSend.tapCallback = onSendClick;
			btnSend.setOverlay(HitZoneType.BUTTON);
			btnSend.x = Config.DIALOG_MARGIN;
			view.addChild(btnSend);
			btnSend.hide();
			
			recepientTitle = new Bitmap();
			addObject(recepientTitle);
			amountTitle = new Bitmap();
			addObject(amountTitle);
			commissionTitle = new Bitmap();
			addObject(commissionTitle);
			
			recepient = new Bitmap();
			addObject(recepient);
			
			amount = new Bitmap();
			addObject(amount);
			
			commission = new Bitmap();
			addObject(commission);
		}
		
		override protected function drawView():void {
			super.drawView();
			btnSend.y = _height - Config.APPLE_BOTTOM_OFFSET - btnSend.height - Config.DIALOG_MARGIN;
		}
		
		//===========================================================================================================
		// START PROCESS
		//===========================================================================================================
		private function onStartProcessInvoice():void {
			var currentTask:PayTaskVO  = InvoiceManager.getCurrentInvoiceData();
			if (currentTask != null && currentTask.handleInCustomScreenName != ""){
				return;
			}
			
			addToScreen();
			
			selectorDebitAccont.setValue(null);
			paramsObj = {from: "", to: "", amount: "", currency: "", toType: 0, message: "", code: ""};
			
			//showPreloader();
			//activate();		
			addEvents();
		}
		
		private function addToScreen():void 
		{
			if (target != null)
			{
				init();
				showScreen();
			}
			else
			{
				ApplicationErrors.add();
			}
		}
		
		//===========================================================================================================
		// STOP PROCESS
		//===========================================================================================================
		private function onStopProcessInvoice():void {
			
			var currentTask:PayTaskVO  = InvoiceManager.getCurrentInvoiceData();
			if (currentTask != null && currentTask.handleInCustomScreenName != ""){
				return;
			}
			_inTransactionProcess  = false;	
			if(DialogManager.hasOpenedDialog)
				DialogManager.closeDialog();			
			removeEvents();
			hidePreloader();				
			hideScreen();
			deactivateScreen();
		}	
		
		//===========================================================================================================
		// ADD / REMOVE EVENTS/ SIGNALS
		//===========================================================================================================	
		private function addEvents():void {
			InvoiceManager.S_ACCOUNT_READY.add(onWalletsReady);
			InvoiceManager.S_CALL_GET_COMMISSION.add(onStartLoadCommission);
			InvoiceManager.S_RECEIVED_COMMISSION.add(onCommissionLoadComplete);
			InvoiceManager.S_RECEIVE_COMMISSION_ERROR.add(onCommissionLoadError);
			InvoiceManager.S_ERROR_MESSAGE.add(showMessage);
			InvoiceManager.S_TRANSFER_RESPOND.add(onTransferRespond);
			InvoiceManager.S_TRANSACTION_STATE_CHANGED.add(onTransactionStateChange);
		}
		
		private function removeEvents():void{			
			InvoiceManager.S_ACCOUNT_READY.remove(onWalletsReady);
			InvoiceManager.S_CALL_GET_COMMISSION.remove(onStartLoadCommission);
			InvoiceManager.S_RECEIVED_COMMISSION.remove(onCommissionLoadComplete);
			InvoiceManager.S_RECEIVE_COMMISSION_ERROR.remove(onCommissionLoadError);
			InvoiceManager.S_TRANSFER_RESPOND.remove(onTransferRespond);
			InvoiceManager.S_ERROR_MESSAGE.remove(showMessage);
			InvoiceManager.S_TRANSACTION_STATE_CHANGED.remove(onTransactionStateChange);
		}
		
		private function onTransactionStateChange():void {
			if (InvoiceManager.isMakingTransaction){
				showPreloader();
			}else{
				hidePreloader();
			}
		}
		
		//===========================================================================================================
		// COMISSION DATA LOADING
		//===========================================================================================================	
		
	
		private function onStartLoadCommission():void {
			_commissionReady = false; // listen for authorization errors to reset this shit
			drawCommission("");
			updateSendButtonVisibility();
		}
		
		private function onCommissionLoadError():void {
			_commissionReady = false;
			hidePreloader();
			
			showMessage(Lang.failedToLoadCommission, false);
		}
		
		private function onCommissionLoadComplete():void {
			
			if (InvoiceManager.getCurrentInvoiceData() != null)
			{
				Store.load(Store.FIRST_TRANSACTIONS + " " + InvoiceManager.getCurrentInvoiceData().to_uid, onLoad);
			}
			
			_commissionReady = true;
			// if is last commisiion respond==> hide preloader 
			hidePreloader();
			
			drawCommission(InvoiceManager.getCurrentInvoiceData().commissionText);
			if (InvoiceManager.getCurrentInvoiceData().requestClarification)
			{
				addClarificationSelector();
			}
			
			updateSendButtonVisibility();
		}
		
		private function onPurposeSelected():void 
		{
			updateSendButtonVisibility();
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
		
		
		private function addClarificationSelector():void 
		{
			if (purposeSelector == null)
			{
				purposeSelector = new SelectorButton(onPurposeSelected, getTransferPurposes(), Lang.SPECIFY_PURPOSE_OF_MONEY_TRANSFER_TITLE);
				purposeSelector.activate();
				purposeSelector.setSize(_width - Config.DIALOG_MARGIN * 2);
				addObject(purposeSelector);
			}
			
			purposeSelector.x = Config.DIALOG_MARGIN;
			updatePositions();
			drawView();
		}
		
		private function updateSendButtonVisibility():void {
			if (_inTransactionProcess ){ // and is active
				selectorDebitAccont.deactivate();
			}else{ 
				//TODO if is active screen then activate
				selectorDebitAccont.activate();
			}
			if (_commissionReady && !_inTransactionProcess){ // and not in transaction 
				btnSend.show(.3, 0, true, 0.95);
				btnSend.activate();
			}else{
			//	btnSend.hide();
			}
			
			var active:Boolean = true;
			
			if (toggler != null)
			{
				if (!toggler.isSelected)
				{
					active = false;
				}
			}
			
			if (purposeSelector != null)
			{
				if (purposeSelector.getSelected() == null)
				{
					active = false;
				}
			}
			
			if (active)
			{
				btnSend.alpha = 1;
				btnSend.activate();
			}
			else
			{
				btnSend.alpha = 0.6;
				btnSend.deactivate();
			}
		}
		
		private function onSendClick(...rest):void {
			
			if (!isDataValid())
			{
				return;
			}
			
			if (paramsObj.from != ""){
				var invoiceData:PayTaskVO = InvoiceManager.getCurrentInvoiceData();
				if (invoiceData != null) {
					
					if (purposeSelector != null)
					{
						if (purposeSelector.getSelected() == null)
						{
							return;
						}
						else
						{
							invoiceData.purpose = purposeSelector.getSelected();
						}
					}
					
					var dialogTilte:String = Lang.invoiceDialogWarningTitle;
					var dialogBody:String = "";					
					var bodyLine1:String = Lang.invoiceDialogWarningText1;
					//var bodyLine2:String = "<font color='#cd3f43'><b>" + Lang.invoiceDialogWarningText2 +" " + invoiceData.amount +" " + invoiceData.currency + "</b></font>";
					var bodyLine2:String = Lang.invoiceDialogWarningText2;										
						bodyLine2 = LangManager.replace(Lang.regExtValue, bodyLine2, invoiceData.amount + "" );
						
						var currency:String = invoiceData.currency;
						if (Lang[currency] != null)
						{
							currency = Lang[currency];
						}
						
						bodyLine2 = LangManager.replace(Lang.regExtValue, bodyLine2, currency + "");
						dialogBody = bodyLine1 + bodyLine2;
					DialogManager.alert(dialogTilte, dialogBody, onSendAlertCallback, Lang.yesPayText, Lang.textCancel, null, TextFormatAlign.LEFT, true);
				}		
			}
		}		
		
		private function isDataValid():Boolean 
		{
			if (_inTransactionProcess)
			{
				return false;
			}
			return true;
		}
		
		private function onSendAlertCallback(val:int):void {	
			if (val == 1){
				if (paramsObj.from != ""){
					Store.save(Store.FIRST_TRANSACTIONS + " " + InvoiceManager.getCurrentInvoiceData().to_uid, "1");
					var invoiceData:PayTaskVO = InvoiceManager.getCurrentInvoiceData();		
					INVOICE_LAST_CALL_ID = new Date().time + "_inv";
					invoiceData.from_wallet = paramsObj.from;					
					//showPreloader(); // TODO remove from here
					_inTransactionProcess = true;
					updateSendButtonVisibility();								
					InvoiceManager.sendPaymentToPayServer(invoiceData,INVOICE_LAST_CALL_ID);				
					// show preloader 
					// PayManager.callExternalTransfer(paramsObj); // v sluchae alerta, nifiga ne pokazhet poskolku mi ne v pajmentah  poetomu ispolzuem tut svoju logiku
					// onComplete-> mark as complete
					// on Error -> Display Error 
				}			
			}
		}
		
		override public function onBack(e:Event = null):void {
			InvoiceManager.stopProcessInvoice();
		}
		
		private function openWalletSelector(e:Event = null):void {
			
			if (InvoiceManager.getCurrentInvoiceData() != null && InvoiceManager.getCurrentInvoiceData().currency == TypeCurrency.DCO)
			{
				return;
			}
			
			if (PayManager.accountInfo == null) return;	
			
			DialogManager.showDialog(
				ListSelectionPopup,
				{
					items:PayManager.accountInfo.accounts,
					title:Lang.TEXT_SELECT_ACCOUNT,
					renderer:ListPayWalletItem,
					callback:onWalletSelect
				}, ServiceScreenManager.TYPE_SCREEN
			);
		}
		
		private function onWalletSelect(account:Object):void {
			if (account == null) return;
			showPreloader();
			paramsObj.from = account.ACCOUNT_NUMBER;
			selectorDebitAccont.setValue(account);
			InvoiceManager.setFromAccount(paramsObj.from);
			var invoiceData:PayTaskVO = InvoiceManager.getCurrentInvoiceData();		
			if (invoiceData.currency != TypeCurrency.DCO)
			{
				InvoiceManager.getCommission();	
				
				if (commissionTitle != null)
				{
					addObject(commissionTitle);
				}
				if (commission != null)
				{
					addObject(commissionTitle);
				}
			}
			else
			{
				if (commissionTitle != null)
				{
					removeObject(commissionTitle);
				}
				if (commission != null)
				{
					removeObject(commissionTitle);
				}
				onCommissionLoadComplete();
			}
		}
		
		//===========================================================================================================
		// WALLETS READY 
		//===========================================================================================================	
		
		private function onWalletsReady():void {			
			setDefaultWallet();
			updateSendButtonVisibility();
			
			if (!PayManager.accountInfo.settings.PWP_IS_EMPTY && !PayManager.accountInfo.settings.PWP_ENABLED ){ // todo check if swiss
				var termsBodyText:String = Lang.oneClickPaymentsDescSWISS;				
				DialogManager.alert(Lang.oneClickPayments  + " " + Lang.termsAndConditions,termsBodyText, InvoiceManager.onPWPDialog, Lang.iAgree, Lang.textCancel);
			}
		}
	
		private function setDefaultWallet():void {
			if (PayManager.accountInfo == null)
				return;
			var defaultAccount:Object;
			var currentInvoice:PayTaskVO = InvoiceManager.getCurrentInvoiceData();
			if (currentInvoice != null) {
				var currencyNeeded:String = currentInvoice.currency;
				var wallets:Array = PayManager.accountInfo.accounts;
				if (currencyNeeded == TypeCurrency.DCO) {
					if (accounts == null) {
						accounts = new PaymentsAccountsProvider(onAccountsDataReady, false, onGetAccountFail);
					}
					if (accounts.ready == true) {
						if (accounts.coinsAccounts != null && accounts.coinsAccounts.length > 0) {
							defaultAccount = accounts.coinsAccounts[0];
							onWalletSelect(defaultAccount);
						} else {
							ApplicationErrors.add();
						}
					} else {
						accounts.getData();
					}
				} else {
					var l:int = wallets.length;
					// TODO show if no wallets in account 
					if (l == 0) {
						hidePreloader();
						DialogManager.alert("No wallets", "You have no created wallets in your account");
						return;
					}
					var walletItem:Object;
					for (var i:int = 0; i < l; i++) {
						walletItem = wallets[i];
						if (currencyNeeded == walletItem.CURRENCY) {
							defaultAccount = walletItem;
							break;
						}					
					}				
					if (defaultAccount == null && l > 0) {
						defaultAccount = wallets[0];
					}
					onWalletSelect(defaultAccount);
				}
			}
		}
		
		private function onGetAccountFail():void 
		{
			if (_isDisposed == true)
				return;
			
			onBack();
		}
		
		private function onAccountsDataReady():void {
			if (_isDisposed == true)
				return;
			if (accounts != null && accounts.ready == true && accounts.coinsAccounts != null && accounts.coinsAccounts.length > 0) {
				onWalletSelect(accounts.coinsAccounts[0]);
			}
		}
		
		//===========================================================================================================
		// TRANSACTION RESPOND 
		//===========================================================================================================	
		
		
		//public function onTransferRespond(isLast:Boolean, error:Boolean):void {
		public function onTransferRespond(respond:PayRespond):void {
			// TODO Check error type and then mark as complete...
			//if(!error){
				//updateSendButtonVisibility();
			//}
			// check if we are inside View !? 				
			if (respond.hasAuthorizationError){
				// if canceled authorization then close processing invoice
				return;	
			}
			if (respond.error){
				_inTransactionProcess  = false;
				selectorDebitAccont.activate();
				hidePreloader();
			}else{
				_inTransactionProcess  = false;
				hidePreloader();
			}
		}
		
		//===========================================================================================================
		// SHOW SCREEN / HIDE SCREEN
		//===========================================================================================================	
		
		public function showScreen():void {
			/// if is shown			
			TweenMax.killTweensOf(this);
			view.y = MobileGui.stage.stageHeight*.6;
			TweenMax.to(view, .3, {y:0,
									ease:Expo.easeOut, 
									onComplete:function():void{
										if (_isDisposed) return;
										// if walet is selected do not show preloader 
										if(paramsObj.from == ""){
											showPreloader();
										}
										activateScreen();	
										updateSendButtonVisibility();
									}});
		}
		
		public function hideScreen():void {
			// deactivate UI
			if(view != null)
			{
				TweenMax.killTweensOf(this);	
				TweenMax.to(view , .3, { y:_height, 
										ease:Quint.easeOut, 
										onComplete:onScreenHided});
				selectorDebitAccont.deactivate();
			}
		}
		
		private function onScreenHided():void 
		{
			clearView();
		}
		
		override public function clearView():void {
			if (_view != null)
				_view.graphics.clear();
			
			_isInited = false;
			
			if (btnSend != null){
				btnSend.dispose();
				btnSend = null;
			}
			
			if (toggler != null){
				toggler.dispose();
				toggler = null;
			}
			if (togglerDescription != null){
				UI.destroy(togglerDescription);
				togglerDescription = null;
			}
			if (selectorDebitAccont != null){
				if (selectorDebitAccont.parent != null){
					selectorDebitAccont.parent.removeChild(selectorDebitAccont);
				}
				selectorDebitAccont.dispose();				
				selectorDebitAccont = null;
			}
			if (accounts != null){
				accounts.dispose();
				accounts = null;
			}
			if (recepientTitle != null){
				UI.destroy(recepientTitle);
				recepientTitle = null;
			}
			if (amountTitle != null){
				UI.destroy(amountTitle);
				amountTitle = null;
			}
			if (commissionTitle != null){
				UI.destroy(commissionTitle);
				commissionTitle = null;
			}
			if (recepient != null){
				UI.destroy(recepient);
				recepient = null;
			}
			if (amount != null){
				UI.destroy(amount);
				amount = null;
			}
			if (commission != null){
				UI.destroy(commission);
				commission = null;
			}
			if (dataBack != null){
				UI.destroy(dataBack);
				dataBack = null;
			}
			if (purposeSelector != null){
				purposeSelector.dispose();
				purposeSelector = null;
			}
		}
		
		//===========================================================================================================
		// ACTIVATE  / DEACTIVATE VIEW
		//===========================================================================================================		
		
		override public function activateScreen():void	{
			super.activateScreen();
			
			if (selectorDebitAccont != null)
			{
				selectorDebitAccont.activate();
				updateSendButtonVisibility();
				
				if (toggler != null)
				{
					toggler.activate();
				}
			}
			else
			{
				ApplicationErrors.add();
			}
		}
		
		override public function deactivateScreen():void {
			super.deactivateScreen();
			
			if (selectorDebitAccont != null)
			{
				selectorDebitAccont.deactivate();
				btnSend.deactivate();
				if (toggler != null)
				{
					toggler.deactivate();
				}
			}
			else
			{
				ApplicationErrors.add();
			}
		}
		
		//===========================================================================================================
		// DISPOSE
		//===========================================================================================================
		
		override public function dispose():void {
			if (_isDisposed) return;
			_isDisposed = true;
			
			target = null;
			clearView();
			
			InvoiceManager.S_START_PROCESS_INVOICE.remove(onStartProcessInvoice);
			InvoiceManager.S_STOP_PROCESS_INVOICE.remove(onStopProcessInvoice);	
		}
	}
}