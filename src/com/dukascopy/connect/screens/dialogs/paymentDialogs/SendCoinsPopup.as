package com.dukascopy.connect.screens.dialogs.paymentDialogs 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.CountriesData;
	import com.dukascopy.connect.data.GiftData;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.gui.button.DDAccountButton;
	import com.dukascopy.connect.gui.button.DDFieldButton;
	import com.dukascopy.connect.gui.chat.CircleAvatar;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.input.InputWithPrompt;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.renderers.ListLink;
	import com.dukascopy.connect.gui.list.renderers.ListPayCurrency;
	import com.dukascopy.connect.gui.list.renderers.ListPayWalletItem;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.preloader.Preloader;
	import com.dukascopy.connect.gui.textedit.PayMessagePreviewBox;
	import com.dukascopy.connect.gui.textedit.TextComposer;
	import com.dukascopy.connect.gui.tools.HorizontalPreloader;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.dialogs.ScreenCountryPicker;
	import com.dukascopy.connect.screens.dialogs.ScreenLinksDialog;
	import com.dukascopy.connect.screens.dialogs.ScreenPayDialog;
	import com.dukascopy.connect.screens.payments.card.TypeCurrency;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.payments.InvoiceManager;
	import com.dukascopy.connect.sys.payments.PayAPIManager;
	import com.dukascopy.connect.sys.payments.PayManager;
	import com.dukascopy.connect.sys.payments.PayRespond;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.softKeyboard.SoftKeyboard;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.theme.AppTheme;
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
	
	public class SendCoinsPopup extends BaseScreen {
		
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
		private var avatarSize:int;
		private var avatar:CircleAvatar;
		private var avatarBD:ImageBitmapData;
		private var _lastCommissionCallID:String;
		protected var componentsWidth:int;
		private var messageComposerIsOppened:Boolean = false;
		private var messageComposer:TextComposer;
		private var descriptionBox:PayMessagePreviewBox;
		private var userName:String;
		private var startPhoneNumber:String;
		private var accounts:Array;
		
		public function SendCoinsPopup() {
			
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
			
			accountText = new Bitmap();
			container.addChild(accountText);
			
			avatar = new CircleAvatar();
			container.addChild(avatar);
			
			acceptButton = new BitmapButton();
			acceptButton.setStandartButtonParams();
			acceptButton.setDownScale(1);
			acceptButton.setDownColor(0);
			acceptButton.tapCallback = nextClick;
			acceptButton.disposeBitmapOnDestroy = true;
			container.addChild(acceptButton);
			
			backButton = new BitmapButton();
			backButton.setStandartButtonParams();
			backButton.setDownScale(1);
			backButton.setDownColor(0);
			backButton.tapCallback = backClick;
			backButton.disposeBitmapOnDestroy = true;
			container.addChild(backButton);
			
			selectorDebitAccont = new DDAccountButton(openWalletSelector, null, false);
			container.addChild(selectorDebitAccont);
			
			_view.addChild(container);
			
			iAmountCurrency = new Input(Input.MODE_DIGIT_DECIMAL);
			iAmountCurrency.setParams(Lang.textAmount, Input.MODE_DIGIT_DECIMAL);
			iAmountCurrency.S_CHANGED.add(onChangeInputValueCurrency);
			iAmountCurrency.S_FOCUS_IN.add(onInputSelected);
			iAmountCurrency.setRoundBG(false);
			iAmountCurrency.getTextField().textColor = Style.color(Style.COLOR_TEXT);
			iAmountCurrency.setRoundRectangleRadius(0);
			iAmountCurrency.inUse = true;
			container.addChild(iAmountCurrency.view);
			
			selectorCurrency = new DDFieldButton(selectCurrencyTap, "", false);
			container.addChild(selectorCurrency);
			
			sendSectionTitle = new Bitmap();
			container.addChild(sendSectionTitle);
			
			accountsPreloader = new HorizontalPreloader();
			container.addChild(accountsPreloader);
			
			descriptionBox = new PayMessagePreviewBox();
			descriptionBox.emptyLabelText = Lang.addYourDescription;//"Add your description...";
			descriptionBox.textValue = "";
			descriptionBox.updateCallback = onDescriptionBoxUpdate;
			descriptionBox.init();
			container.addChild(descriptionBox);
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
		
		private function checkDataValid():void
		{
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
			
			var wallets:Array = getAccounts();
			if (wallets != null && wallets.length > 0)
			{
				var l:int = wallets.length;
				var walletItem:Object;
				var value:String;
				for (var i:int = 0; i < l; i++)
				{
					walletItem = wallets[i];
					if ("COIN" in walletItem)
					{
						value = walletItem.COIN;
						if (Lang[value] != null)
						{
							value = Lang[value];
						}
						currencies.push(walletItem.COIN);
					}
				}
				
				DialogManager.showDialog(ScreenPayDialog, {callback: callBackSelectCurrency, data: currencies, itemClass: ListPayCurrency, label: Lang.selectCurrency});
			}
		}
		
		private function getAccounts():Array 
		{
			if (giftData != null)
			{
				return giftData.wallets;
			}
			return null;
		}
		
		private function openWalletSelector(e:Event = null):void
		{
			SoftKeyboard.closeKeyboard();
			if (iAmountCurrency != null)
			{
				iAmountCurrency.forceFocusOut();
			}
			
			showWalletsDialog();
		}
		
		private function showWalletsDialog():void
		{
			var wallets:Array = getAccounts();
			if (wallets != null && wallets.length > 0)
			{
				DialogManager.showDialog(ScreenPayDialog, {callback: onWalletSelect, data: wallets, itemClass: ListPayWalletItem/*ListPayAccount*/, label: Lang.TEXT_SELECT_ACCOUNT});
			}
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
				selectorCurrency.setValue(account.COIN);
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
		
		private function nextClick():void {
			SoftKeyboard.closeKeyboard();
			if (iAmountCurrency != null)
			{
				iAmountCurrency.forceFocusOut();
			}
			
			if (giftData != null)
			{
				giftData.accountNumber = selectedAccount.ACCOUNT_NUMBER;
				giftData.currency = selectedAccount.COIN;
				giftData.customValue = Number(iAmountCurrency.value);
				
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
			
			avatarSize = Config.FINGER_SIZE;
			
			if (data != null && "giftData" in data && data.giftData is GiftData) {
				giftData = data.giftData as GiftData;
			}
			
			if (giftData.user != null)
			{
				this.userName = giftData.user.getDisplayName();
			}
			
			componentsWidth = _width - Config.DIALOG_MARGIN * 2;
			
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
			
			selectInitialData();
			
			if (getAccounts() != null && getAccounts().length == 1)
			{
				selectorCurrency.deactivate();
				selectorDebitAccont.deactivate();
			}
		}
		
		private function selectInitialData():void 
		{
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
		
		private function drawAvatar():void 
		{
			if (giftData != null && giftData.user != null)
			{
				var avatarUrl:String = giftData.user.getAvatarURLProfile(avatarSize * 2);
				avatar.setData(giftData.user, avatarSize, false, false, avatarUrl);
			}
		}
		
		private function selectAccount(currency:String):void {
			
			var defaultAccount:Object;
			var currencyNeeded:String = currency;
			var wallets:Array = getAccounts();
			if (wallets != null && wallets.length > 0)
			{
				var l:int = wallets.length;
				var walletItem:Object;
				for (var i:int = 0; i < l; i++) {
					walletItem = wallets[i];
					if (currencyNeeded == walletItem.COIN) {
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
		
		private function selectBigAccount():void 
		{
			var wallets:Array = getAccounts();
			if (wallets != null && wallets.length > 0)
			{
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
				selectorCurrency.setValue(account.COIN);
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
				value = Lang.transferCoinsTo + " " + userName;
			}
			else
			{
				value = Lang.transferCoins;
			}
			
			sendSectionTitle.bitmapData = TextUtils.createTextFieldData(value, componentsWidth, 10, false, 
															TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .3, false, 0x777E8A, 0xFFFFFF, false, true);
			sendSectionTitle.x = int(_width * .5 - sendSectionTitle.width * .5);
			
			drawView();
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
			currentCommision = 0;
			TweenMax.killDelayedCallsTo(checkCommision);
			
			var needUpdate:Boolean = true;
			
			if (Number(iAmountCurrency.value) <= 0 || selectAccount == null)
			{
				return;
			}
			
			if (needUpdate)
			{
			//	drawAccountText(Lang.commisionWillBe + "...");
				
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
			return;
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
				}
			}
		}
		
		private function setDefaultWallet():void
		{
			if (PayManager.accountInfo == null) return;
			var defaultAccount:Object;
			
			var currencyNeeded:String = TypeCurrency.DCO;
			var wallets:Array = PayManager.accountInfo.accounts;
			var l:int = wallets.length;
			var walletItem:Object;
			for (var i:int = 0; i < l; i++)
			{
				walletItem = wallets[i];
				defaultAccount = walletItem;
				break;
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
			
			var position:int;
			
			position = verticalMargin + avatarSize;
			
			position += verticalMargin * 1.5;
			
			// SEND
			sendSectionTitle.y = position;
			position += sendSectionTitle.height + verticalMargin * 1.5;
			sendSectionTitle.x = int(_width * .5 - sendSectionTitle.width * .5);
			
			// AMOUNT
			iAmountCurrency.view.y = position;
			selectorCurrency.y = position;
			position += iAmountCurrency.height + verticalMargin * 1.5;
			
			
			descriptionBox.x = Config.DIALOG_MARGIN;
			descriptionBox.y = position;
			descriptionBox.viewWidth = componentsWidth;
			position += descriptionBox.height +  + verticalMargin * 1;
			
			
			// ACCOUNT
			selectorDebitAccont.y = position;
			position += selectorDebitAccont.height + verticalMargin * 3;
			accountsPreloader.y = selectorDebitAccont.y + selectorDebitAccont.height;
			accountsPreloader.x = selectorDebitAccont.x;
			accountText.y = position - verticalMargin * 2.5;
			
			//	position += accountText.height + verticalMargin * 1.8;
		//	accountText.visible = false;
			
			acceptButton.y = position;
			backButton.y = position;
			position += acceptButton.height + verticalMargin * 1.8;
			
			bg.height = position;
			
			container.y = _height - position;
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
			
			checkDataValid();
			
			backButton.activate();
			PointerManager.addTap(descriptionBox, onAddMessageClick);
			
			if (getAccounts() != null && getAccounts().length > 1)
			{
				selectorDebitAccont.activate();
				selectorCurrency.activate();
			}
		}
		
		private function onAddMessageClick(e:Event = null):void {
			showMessageComposer();
		}
		
		override public function deactivateScreen():void
		{
			if (_isDisposed == true)
				return;
			
			super.deactivateScreen();
			
			PointerManager.removeTap(descriptionBox, onAddMessageClick);
			iAmountCurrency.deactivate();
			acceptButton.deactivate();
			backButton.deactivate();
			selectorDebitAccont.deactivate();
			selectorCurrency.deactivate();
		}
		
		protected function onCloseTap():void
		{
			DialogManager.closeDialog();
		}
		
		override public function dispose():void
		{
			if (_isDisposed == true)
				return;
			super.dispose();
			
			if (PayManager.S_SEND_MONEY_COMMISSION_RESPOND != null)  {
				PayManager.S_SEND_MONEY_COMMISSION_RESPOND.remove(onSendMoneyCommissionRespond);
			}
			
			if (messageComposer != null) {
				UI.safeRemoveChild(messageComposer);
				messageComposer.dispose();
				messageComposer = null;
				messageComposerIsOppened = false;
			}
			
			TweenMax.killDelayedCallsTo(checkCommision);
			
			if (descriptionBox != null) {
				UI.safeRemoveChild(descriptionBox);
				descriptionBox.dispose();
				descriptionBox = null;
			}
			
			if (sendSectionTitle != null)
			{
				UI.destroy(sendSectionTitle);
				sendSectionTitle = null;
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
			if (avatarBD != null)
			{
				UI.disposeBMD(avatarBD);
				avatarBD = null;
			}
			if (avatar != null)
			{
				avatar.dispose();
				avatar = null;
			}
			
			giftData = null;
		}
	}
}