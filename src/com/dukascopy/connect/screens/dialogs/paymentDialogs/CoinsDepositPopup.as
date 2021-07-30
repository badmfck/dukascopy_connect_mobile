package com.dukascopy.connect.screens.dialogs.paymentDialogs {
	import assets.QrIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.GiftData;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.gui.button.Checkbox;
	import com.dukascopy.connect.gui.button.DDAccountButton;
	import com.dukascopy.connect.gui.button.DDFieldButton;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.renderers.ListPayCurrency;
	import com.dukascopy.connect.gui.list.renderers.ListPayWalletItem;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.scrollPanel.ScrollPanel;
	import com.dukascopy.connect.gui.tools.HorizontalPreloader;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.dialogs.ScreenPayDialog;
	import com.dukascopy.connect.screens.dialogs.ScreenWebviewDialogBase;
	import com.dukascopy.connect.screens.dialogs.x.base.bottom.BottomAlertPopup;
	import com.dukascopy.connect.screens.dialogs.x.base.bottom.ListSelectionPopup;
	import com.dukascopy.connect.screens.payments.card.TypeCurrency;
	import com.dukascopy.connect.screens.serviceScreen.Overlay;
	import com.dukascopy.connect.sys.bankManager.BankManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.payments.InvoiceManager;
	import com.dukascopy.connect.sys.payments.PayManager;
	import com.dukascopy.connect.sys.paymentsManagerNew.PaymentsManagerNew;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.softKeyboard.SoftKeyboard;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	
	public class CoinsDepositPopup extends BaseScreen {
		
		protected var container:Sprite;
		private var bg:Shape;
		private var text:Bitmap;
		private var acceptButton:BitmapButton;
		private var useAllButton:Checkbox;
		private var accountText:Bitmap;
		private var commissionAccountText:Bitmap;
		private var backButton:BitmapButton;
		private var selectorDebitAccont:DDAccountButton;
		private var selectorFiatAccont:DDAccountButton;
		private var screenLocked:Boolean;
		private var verticalMargin:Number;
		private var walletSelected:Boolean;
		private var selectedAccount:Object;
		private var currentCommision:Number = 0;
		private var preloaderShown:Boolean = false;
		private var iAmountCurrency:Input;
		private var selectorCurrency:DDFieldButton;
		private var accountsPreloader:HorizontalPreloader;
		private var giftData:GiftData;
		private var _lastCommissionCallID:String;
		protected var componentsWidth:int;
		private var accounts:Array;
		private var title:Bitmap;
		private var lockedValues:Boolean;
		private var wallet:Bitmap;
		private var walletDescription:Bitmap;
		private var moreInfo:TextField;
		private var walletBG:Sprite;
		private var changeAddressButton:BitmapButton;
		private var commissionLoaded:Boolean;
		private var commissionText:Bitmap;
		private var investmentData:Object;
		private var selectedFiatAccount:Object;
		private var scroll:ScrollPanel;
		private var scrollTop:Sprite;
		
		public function CoinsDepositPopup() {
			
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
			
			scroll = new ScrollPanel();
			container.addChild(scroll.view);
			
			scrollTop = new Sprite();
			scroll.addObject(scrollTop);
			scrollTop.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			scrollTop.graphics.drawRect(0, 0, 1, 1);
			scrollTop.graphics.endFill();
			
			accountText = new Bitmap();
			scroll.addObject(accountText);
			
			moreInfo = new TextField();
			moreInfo.defaultTextFormat = new TextFormat(Config.defaultFontName, Config.FINGER_SIZE * .26, Style.color(Style.COLOR_TEXT));
			moreInfo.multiline = true;
			moreInfo.wordWrap = true;
			scroll.addObject(moreInfo);
			
			commissionAccountText = new Bitmap();
			scroll.addObject(commissionAccountText);
			
			title = new Bitmap();
			container.addChild(title);
			
			acceptButton = new BitmapButton();
			acceptButton.setStandartButtonParams();
			acceptButton.setDownScale(1);
			acceptButton.setDownColor(0);
			acceptButton.tapCallback = nextClick;
			acceptButton.disposeBitmapOnDestroy = true;
			acceptButton.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
			container.addChild(acceptButton);
			
			useAllButton = new Checkbox(Lang.deliverAll);
			useAllButton.tapCallback = useAllClick;
			scroll.addObject(useAllButton);
			
			backButton = new BitmapButton();
			backButton.setStandartButtonParams();
			backButton.setDownScale(1);
			backButton.setDownColor(0);
			backButton.tapCallback = backClick;
			backButton.disposeBitmapOnDestroy = true;
			backButton.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
			container.addChild(backButton);
			
			selectorDebitAccont = new DDAccountButton(openWalletSelector, null, false, -1, Style.color(Style.CONTROL_INACTIVE));
			scroll.addObject(selectorDebitAccont);
			
			_view.addChild(container);
			
			iAmountCurrency = new Input(Input.MODE_DIGIT_DECIMAL);
			iAmountCurrency.setParams(Lang.textAmount, Input.MODE_DIGIT_DECIMAL);
			iAmountCurrency.S_CHANGED.add(onChangeInputValueCurrency);
			iAmountCurrency.S_FOCUS_IN.add(onInputSelected);
			iAmountCurrency.setRoundBG(false);
			iAmountCurrency.getTextField().textColor = Style.color(Style.COLOR_TEXT);
			iAmountCurrency.setRoundRectangleRadius(0);
			iAmountCurrency.inUse = true;
			scroll.addObject(iAmountCurrency.view);
			
			selectorCurrency = new DDFieldButton(selectCurrencyTap, "", false, Style.color(Style.CONTROL_INACTIVE));
			scroll.addObject(selectorCurrency);
			
			accountsPreloader = new HorizontalPreloader();
			container.addChild(accountsPreloader);
			
			walletBG = new Sprite();
			walletBG.graphics.beginFill(0xE5F3FF);
			walletBG.graphics.drawRect(0, 0, 10, 10);
			walletBG.graphics.endFill();
			scroll.addObject(walletBG);
			
			commissionText = new Bitmap();
			scroll.addObject(commissionText);
			
			wallet = new Bitmap();
			scroll.addObject(wallet);
			
			changeAddressButton = new BitmapButton();
			changeAddressButton.setStandartButtonParams();
			changeAddressButton.setDownScale(1);
			changeAddressButton.setDownColor(0);
			changeAddressButton.tapCallback = changeAddress;
			changeAddressButton.disposeBitmapOnDestroy = true;
			changeAddressButton.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
			scroll.addObject(changeAddressButton);
			
			walletDescription = new Bitmap();
			scroll.addObject(walletDescription);
			
			var icon:QrIcon = new QrIcon();
			UI.scaleToFit(icon, Config.FINGER_SIZE * .6, Config.FINGER_SIZE * .6);
		}
		
		private function useAllClick():void 
		{
			if (selectedAccount != null)
			{
				if (useAllButton.isSelected())
				{
					iAmountCurrency.value = selectedAccount.BALANCE;
					checkDataValid();
				}
			}
		}
		
		private function changeAddress():void {
			if (screenLocked == true)
				return;
			lockScreen();
			accountsPreloader.start();
			BankManager.S_DECLARE_ETH_LINK.add(registerAddressLinkReady);
			BankManager.S_PAYMENT_ERROR.add(onError);
			BankManager.getDeclareETHAddressLink(getCurrency());
		}
		
		private function onError(error:Object = null):void {
			BankManager.S_DECLARE_ETH_LINK.remove(registerAddressLinkReady);
			BankManager.S_PAYMENT_ERROR.remove(onError);
			
			walletBG.visible = true;
			changeAddressButton.visible = true;
			
			accountsPreloader.stop();
			
			if (error != null && "text" in error && error.text != null)
			{
				ToastMessage.display(error.text);
			}
			
			unlockScreen();
		}
		
		private function lockScreen():void 
		{
			screenLocked = true;
		}
		
		private function registerAddressLinkReady(url:Object):void 
		{
			unlockScreen();
			accountsPreloader.stop();
			BankManager.S_DECLARE_ETH_LINK.remove(registerAddressLinkReady);
			BankManager.S_PAYMENT_ERROR.remove(onError);
		//	ServiceScreenManager.closeView();
			
			DialogManager.showDialog(ScreenWebviewDialogBase, 
										{
											preventCloseOnBgTap: true, 
											url:url.url, 
											callback: onWebViewCallback, 
											label: Lang.registerBlockchainAddress
										});
		}
		
		private function unlockScreen():void 
		{
			screenLocked = false;
		}
		
		private function onWebViewCallback(success:Boolean):void
		{
			if (success == true)
			{
				
			}
			lockScreen();
			accountsPreloader.start();
			
			if (wallet.bitmapData != null)
			{
				wallet.bitmapData.dispose();
				wallet.bitmapData = null;
			}
			if (walletDescription.bitmapData != null)
			{
				walletDescription.bitmapData.dispose();
				walletDescription.bitmapData = null;
			}
			walletBG.visible = false;
			changeAddressButton.visible = false;
			
			BankManager.S_WALLETS.add(onNewWallets);
			BankManager.getWallets(false);
		}
		
		private function onNewWallets(data:Array, local:Boolean):void 
		{
			walletBG.visible = true;
			changeAddressButton.visible = true;
			
			BankManager.S_WALLETS.remove(onNewWallets);
			unlockScreen();
			accountsPreloader.stop();
			
			drawWalletDescription(getDescription());
			if (BankManager.getDCOWallet(getCurrency()) != null)
			{
				drawChangeButton(Lang.changeWallet);
				if (changeAddressButton != null && container.contains(changeAddressButton))
				{
					scroll.removeObject(changeAddressButton);
				}
				
				drawWalletAddress();
			}
			else
			{
				scroll.addObject(changeAddressButton);
				drawChangeButton(Lang.addAddress);
			}
			drawView();
		}
		
		private function onChangeInputCoins():void 
		{
			
		}
		
		private function onInputSelected():void 
		{
			
		}
		
		private function checkDataValid():Boolean {
			
			TweenMax.killDelayedCallsTo(loadComission);
			TweenMax.killDelayedCallsTo(getInvestmentCommission);
			
			if (giftData != null && giftData.type == 3)
			{
				if (isActivated && 
					avaliableBalance() &&
					iAmountCurrency.value != null && 
					iAmountCurrency.value != "" &&
					!isNaN(Number(iAmountCurrency.value)) &&
					BankManager.getDCOWallet(getCurrency()) != null)
				{
					acceptButton.activate();
					acceptButton.alpha = 1;
					iAmountCurrency.unselectBorder();
				//	commissionLoaded = false;
					TweenMax.delayedCall(2, getInvestmentCommission);
					return true;
				} else {
					acceptButton.deactivate();
					acceptButton.alpha = 0.5;
					iAmountCurrency.selectBorder();
					return false;
				}
			}
			
			if (isActivated && 
				selectedAccount != null &&
				avaliableBalance() &&
				iAmountCurrency.value != null && 
				iAmountCurrency.value != "" &&
				!isNaN(Number(iAmountCurrency.value)) &&
				BankManager.getDCOWallet(getCurrency()) != null) {
				acceptButton.activate();
				acceptButton.alpha = 1;
				iAmountCurrency.unselectBorder();
				commissionLoaded = false;
				TweenMax.delayedCall(2, loadComission);
				return true;
			} else {
				acceptButton.deactivate();
				acceptButton.alpha = 0.5;
				iAmountCurrency.selectBorder();
				return false;
			}
			return true;
		}
		
		private function avaliableBalance():Boolean 
		{
			if (giftData != null && giftData.type == 0)
			{
				return true;
			}
			if (selectedAccount != null)
			{
				if ("BALANCE" in selectedAccount && !isNaN(Number(iAmountCurrency.value)) && selectedAccount.BALANCE >= Number(iAmountCurrency.value) && Number(iAmountCurrency.value) > 0)
				{
					return true;
				}
				else
				{
					return false;
				}
			}
			else
			{
				return true;
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
		
		private function getFiatAccounts():Array 
		{
			if (giftData != null)
			{
				return PaymentsManagerNew.filterEmptyWallets(giftData.cards);
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
		
		private function openWalletFiatSelector(e:Event = null):void
		{
			SoftKeyboard.closeKeyboard();
			if (iAmountCurrency != null)
			{
				iAmountCurrency.forceFocusOut();
			}
			
			showWalletsFiatDialog();
		}
		
		private function showWalletsDialog():void
		{
			var wallets:Array = getAccounts();
			if (wallets != null && wallets.length > 0)
			{
				DialogManager.showDialog(ScreenPayDialog, {callback: onWalletSelect, data: wallets, itemClass: ListPayWalletItem/*ListPayAccount*/, label: Lang.TEXT_SELECT_ACCOUNT});
			}
		}
		
		private function showWalletsFiatDialog():void
		{
			var wallets:Array = getFiatAccounts();
			if (wallets != null && wallets.length > 0)
			{
				DialogManager.showDialog(
					ListSelectionPopup,
					{
						items:wallets,
						title:Lang.TEXT_SELECT_ACCOUNT,
						renderer:ListPayWalletItem,
						callback:onWalletFiatSelect
					}, DialogManager.TYPE_SCREEN
				);
			}
			else
			{
				DialogManager.showDialog(
					BottomAlertPopup,
					{
						title:Lang.TEXT_SELECT_ACCOUNT,
						message:Lang.noFundedAccounts
					}, DialogManager.TYPE_SCREEN
				);
			}
		}
		
		private function onWalletFiatSelect(account:Object, cleanCurrent:Boolean = false):void
		{
			if (account != null)
			{
				selectedFiatAccount = account;
				selectorFiatAccont.setValue(account);
				getInvestmentCommission();
			}
		}
		
		private function getInvestmentCommission():void 
		{
			if (isDisposed == true)
			{
				return;
			}
			if (giftData != null && giftData.type == 3 && getCurrency() != null && !isNaN(Number(iAmountCurrency.value)) && Number(iAmountCurrency.value) > 0)
			{
				drawCommissionText(" \n ");
				_lastCommissionCallID = new Date().getTime().toString() + "bcDeposite";
				if (PayManager.S_INVESTMENT_COMMISSION_RECEIVED != null)
					PayManager.S_INVESTMENT_COMMISSION_RECEIVED.add(onCommissionInvestmentRespond);
				accountsPreloader.start();
				PayManager.callGetInvestmentBlockchainCommission(Number(iAmountCurrency.value), getCurrency(), _lastCommissionCallID);
			}
		}
		
		private function onCommissionInvestmentRespond(callID:String, data:Object):void {
			if (isDisposed == true)
				return;
			if (_lastCommissionCallID != callID)
				return;
			accountsPreloader.stop();
			if (data is String)
			{
				showToastMessage(data as String);
			}
			if (data is Number)
			{
				showToastMessage(getError(data as Number));
			}
			else if (data is Object)
			{
				drawCommissionInvestment(data);
			}
		}
		
		private function drawCommissionInvestment(data:Object):void 
		{
			drawAccountCommissionText(Lang.selectCommissionAccount, NaN, data.fee);
			drawView();
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
			if (screenLocked == true)
			{
				return;
			}
			if (giftData != null && giftData.type == 0 && commissionLoaded == false)
			{
				return;
			}
			if (iAmountCurrency != null)
			{
				iAmountCurrency.forceFocusOut();
			}
			
			if (giftData != null && giftData.type != 3)
			{
				giftData.accountNumber = selectedAccount.ACCOUNT_NUMBER;
				giftData.currency = selectedAccount.COIN;
				giftData.customValue = Number(iAmountCurrency.value);
				
				if (giftData.callback != null)
				{
					giftData.callback(giftData);
				}
			}
			else
			{
				giftData.accountNumber = selectedAccount.ACCOUNT_NUMBER;
				giftData.currency = selectedAccount.INSTRUMENT;
				giftData.customValue = Number(iAmountCurrency.value);
				giftData.credit_account_number = selectedFiatAccount.ACCOUNT_NUMBER;
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
		
		private function drawAccountCommissionText(text:String, maxWidth:Number = NaN, commissionValue:String = "..."):void
		{
			var maxTextWidth:Number = maxWidth;
			if (isNaN(maxTextWidth))
			{
				maxTextWidth = componentsWidth;
			}
			
			if (commissionAccountText.bitmapData != null)
			{
				commissionAccountText.bitmapData.dispose();
				commissionAccountText.bitmapData = null;
			}
			
			text = text.replace("@1", commissionValue);
			
			commissionAccountText.bitmapData = TextUtils.createTextFieldData(
															text, maxTextWidth, 10, true, 
															TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
															FontSize.SUBHEAD, true, Style.color(Style.COLOR_SUBTITLE), Style.color(Style.COLOR_BACKGROUND), true);
			commissionAccountText.x = Config.DIALOG_MARGIN;
		}
		
		private function drawTitle(text:String, maxWidth:Number = NaN):void
		{
			if (Lang[text] != null)
			{
				text = Lang[text];
			}
			var maxTextWidth:Number = maxWidth;
			if (isNaN(maxTextWidth))
			{
				maxTextWidth = componentsWidth;
			}
			
			if (title.bitmapData != null)
			{
				title.bitmapData.dispose();
				title.bitmapData = null;
			}
			
			title.bitmapData = TextUtils.createTextFieldData(
															text, maxTextWidth, 10, true, 
															TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
															Config.FINGER_SIZE * .34, true, 0x47515B, 0xFFFFFF, true);
		}
		
		override public function initScreen(data:Object = null):void
		{
			super.initScreen(data);
			
			componentsWidth = _width - Config.DIALOG_MARGIN * 2;
			
			if (data != null && "giftData" in data && data.giftData is GiftData) {
				giftData = data.giftData as GiftData;
			}
			
			var titleValue:String = "";
			if (data != null && "title" in data && data.title != null)
			{
				titleValue = data.title;
			}
			
			if (giftData != null && (giftData.type == 0 || giftData.type == 2))
			{
				scroll.removeObject(selectorDebitAccont);
				scroll.removeObject(useAllButton);
				selectorDebitAccont.visible = false;
			}
			
			if (giftData != null && giftData.type == 0)
			{
				drawCommissionText(" \n ");
			}
			else if (giftData != null && giftData.type == 3)
			{
				drawCommissionText("");
			}
			
			if (giftData != null && giftData.type == 3)
			{
				if (giftData.wallets != null && giftData.wallets.length > 0)
				{
					investmentData = giftData.wallets[0];
				}
				
				drawAccountCommissionText(Lang.selectCommissionAccount);
				drawFiatAccountSelector();
			}
			
			drawTitle(titleValue);
			
			drawAccountSelector();
		//	drawAccountText(Lang.chooseAccount);
			drawAcceptButton(Lang.textNext);
			acceptButton.deactivate();
			acceptButton.alpha = 0.5;
			
			drawWalletDescription(getDescription());
			if (BankManager.getDCOWallet(getCurrency()) != null)
			{
				if (changeAddressButton != null )
				{
					scroll.removeObject(changeAddressButton);
				}
				drawChangeButton(Lang.changeWallet);
				drawWalletAddress();
				moreInfo.visible = true;
				moreInfo.htmlText = Lang.investmentDeliveryLink;
				moreInfo.width = componentsWidth;
				moreInfo.height = moreInfo.textHeight + 4;
				moreInfo.x = Config.DIALOG_MARGIN;
			}
			else
			{
				moreInfo.visible = false;
				scroll.addObject(changeAddressButton);
				scroll.removeObject(moreInfo);
				drawChangeButton(Lang.addAddress);
			}
			if (giftData != null && giftData.type != 3)
			{
				moreInfo.visible = false;
				scroll.removeObject(moreInfo);
			}
			
			var valueWallet:String = "";
			if (giftData != null && giftData.txTransaction != null)
			{
				lockedValues = true;
				if (giftData.txTransaction.length > 2)
				{
					valueWallet = giftData.txTransaction[2];
					iAmountCurrency.value = giftData.txTransaction[0];
				}
			}
			drawBackButton();
			drawUseAllButton();
			
			var itemWidth:int = (componentsWidth - Config.MARGIN * 2) / 2;
			
			title.x = Config.DIALOG_MARGIN;
			
			iAmountCurrency.width = itemWidth;
			iAmountCurrency.view.x = Config.DIALOG_MARGIN;
			
			selectorCurrency.x = iAmountCurrency.view.x + itemWidth + Config.MARGIN * 2;
			selectorCurrency.setSize(itemWidth, Config.FINGER_SIZE * .8);
			
			accountsPreloader.setSize(_width, int(Config.FINGER_SIZE * .05));
			
			selectInitialData();
			
			if (getAccounts() != null && getAccounts().length == 1)
			{
				selectorCurrency.deactivate();
				selectorDebitAccont.deactivate();
			}
			
			if (data.giftData.type != 1 && data.giftData.type != 3) {
				selectorDebitAccont.deactivate();
				scroll.removeObject(selectorDebitAccont);
				scroll.removeObject(useAllButton);
				selectorDebitAccont.visible = false;
			}
		}
		
		private function getCurrency():String 
		{
			if (investmentData != null && "INSTRUMENT" in investmentData && investmentData.INSTRUMENT != null)
			{
				return investmentData.INSTRUMENT;
			}
			return null;
		}
		
		private function getDescription():String 
		{
			var value:String = Lang.selectedBlockchainAddress;
			if (data != null && "description" in data && data.description != null)
			{
				value = data.description;
			}
			return value;
		}
		
		private function drawWalletDescription(defaultValue:String):void 
		{
			var text:String;
			if (BankManager.getDCOWallet(getCurrency()) != null)
			{
				text = defaultValue + ":";
				if (data != null && "description" in data && data.description != null && Lang[data.description] != null)
				{
					text = Lang[data.description];
				}
			}
			else
			{
				text = Lang.blockchainAddressNeeded;
				if (data != null && "addrNeed" in data && data.addrNeed != null && Lang[data.addrNeed] != null)
				{
					text = Lang[data.addrNeed];
				}
			}
			
			var itemWidth:int = _width - Config.DIALOG_MARGIN * 2;
			if (BankManager.getDCOWallet(getCurrency()) == null)
			{
				itemWidth -= Config.DOUBLE_MARGIN;
			}
			if (walletDescription.bitmapData != null)
			{
				walletDescription.bitmapData.dispose();
				walletDescription.bitmapData = null;
			}
			walletDescription.bitmapData = TextUtils.createTextFieldData(
															text, _width - Config.DIALOG_MARGIN * 3, 10, true, 
															TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
															FontSize.SUBHEAD, true, Style.color(Style.COLOR_TEXT), Style.color(Style.COLOR_BACKGROUND), true);
		}
		
		private function drawWalletAddress():void 
		{
			if (wallet.bitmapData != null)
			{
				wallet.bitmapData.dispose();
				wallet.bitmapData = null;
			}
			wallet.bitmapData = TextUtils.createTextFieldData(
															BankManager.getDCOWallet(getCurrency()), _width - Config.DIALOG_MARGIN*2 - Config.MARGIN*2, 10, true, 
															TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, 
															FontSize.BODY, true, Style.color(Style.COLOR_TEXT), Style.color(Style.COLOR_BACKGROUND), true);
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
			
			if (giftData != null && giftData.customValue != 0 && (giftData.txTransaction == null))
			{
				iAmountCurrency.value = giftData.customValue.toString();
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
			if (giftData != null && giftData.type == 3)
			{
				selectFiatAccount();
				selectInstrumentAccount();
				return;
			}
			
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
		
		private function selectFiatAccount():void 
		{
			var wallets:Array = getFiatAccounts();
			if (wallets != null && wallets.length > 0)
			{
				var l:int = wallets.length;
				
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
					onWalletFiatSelect(bigAccount);
				}
			}
		}
		
		private function selectInstrumentAccount():void 
		{
			if (giftData != null && giftData.wallets != null && giftData.wallets.length > 0)
			{
				selectedAccount = giftData.wallets[0];
				selectorCurrency.setValue(selectedAccount.INSTRUMENT);
				selectorDebitAccont.setValue(selectedAccount);
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
		
		private function localSelectCurrency(currency:String):void {
			selectorCurrency.setValue(currency);
			if (lockedValues == false)
			{
				selectorCurrency.activate();
			}
		}
		
		private function callBackSelectCurrency(currency:String):void {
			if (currency == null)
			{
				return;
			}
			if (selectorCurrency != null && currency != null) {
				selectorCurrency.setValue(currency);
			}
			
			selectAccount(currency);
		}
		
		private function showToastMessage(errorText:String = null):void {
			if (errorText == null)
			{
				errorText = Lang.connectionError;
			}
			ToastMessage.display(errorText);
		}
		
		private function onChangeInputValueCurrency():void {
			if (useAllButton != null)
			{
				useAllButton.unselect();
			}
			if (checkDataValid())
			{
				/*if (giftData != null && giftData.type == 3)
				{
					getInvestmentCommission();
				}*/
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
		
		private function drawFiatAccountSelector():void 
		{
			selectorFiatAccont = new DDAccountButton(openWalletFiatSelector, null, true);
			scroll.addObject(selectorFiatAccont);
			
			selectorFiatAccont.setSize(componentsWidth, Config.FINGER_SIZE * .8);
			selectorFiatAccont.setValue(Lang.TEXT_SELECT_ACCOUNT);
			selectorFiatAccont.x = Config.DIALOG_MARGIN;
		}
		
		private function drawUseAllButton():void 
		{
			useAllButton.draw(_width);
		}
		
		private function drawAcceptButton(text:String):void 
		{
			var textSettings:TextFieldSettings = new TextFieldSettings(text, Style.color(Style.COLOR_BACKGROUND), Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, 0x78C043, 1, Config.FINGER_SIZE * .8, NaN, (componentsWidth - Config.DIALOG_MARGIN) * .5);
			acceptButton.setBitmapData(buttonBitmap, true);
			acceptButton.x = int(acceptButton.width + Config.DIALOG_MARGIN * 2);
		}
		
		private function drawChangeButton(text:String):void 
		{
			var textSettings:TextFieldSettings = new TextFieldSettings(text, Style.color(Style.COLOR_TEXT), Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, 0xF6F9FC, 1, Config.FINGER_SIZE * .8, NaN);
			changeAddressButton.setBitmapData(buttonBitmap, true);
		}
		
		private function drawBackButton():void
		{
			var textSettings:TextFieldSettings = new TextFieldSettings(Lang.textBack, 0, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, Style.color(Style.COLOR_TEXT), 0, Config.FINGER_SIZE * .8, NaN, (componentsWidth - Config.DIALOG_MARGIN) * .5);
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
			
			verticalMargin = Config.MARGIN * 1.5;
			
			var position:int = Config.FINGER_SIZE * .35;
			
			title.y = position;
			position += title.height + Config.FINGER_SIZE * .3;
			
			scroll.view.y = position;
			var contentPosition:int = Config.FINGER_SIZE * .4;
			
			// AMOUNT
			iAmountCurrency.view.y = contentPosition;
			selectorCurrency.y = contentPosition;
			contentPosition += iAmountCurrency.height + verticalMargin * 1.5;
			
			if (giftData != null && (giftData.type == 0))
			{
				contentPosition -= verticalMargin
				commissionText.y = contentPosition;
				contentPosition += commissionText.height + verticalMargin * 1;
			}
			
			if ((scroll.view as Sprite).contains(selectorDebitAccont))
			{
				// ACCOUNT
				selectorDebitAccont.y = contentPosition;
				contentPosition += selectorDebitAccont.height + verticalMargin * 0.0;
				useAllButton.y = contentPosition;
				useAllButton.x = Config.DIALOG_MARGIN;
				contentPosition += useAllButton.height + verticalMargin * 1.5;
				accountText.y = contentPosition - verticalMargin * 1;
			}
			else
			{
				contentPosition += verticalMargin;
			}
			
			if (selectorFiatAccont != null && (scroll.view as Sprite).contains(selectorFiatAccont))
			{
				commissionAccountText.y = contentPosition;
				contentPosition += commissionAccountText.height + Config.FINGER_SIZE * .0;
				selectorFiatAccont.y = contentPosition;
				contentPosition += selectorFiatAccont.height + Config.FINGER_SIZE * .1;
			//	accountText.y = position - verticalMargin * 1;
			}
			else
			{
				contentPosition += verticalMargin;
			}
			
			if (BankManager.getDCOWallet(getCurrency()) != null)
			{
				walletDescription.x = Config.DIALOG_MARGIN;
				walletDescription.y = contentPosition;
				contentPosition += walletDescription.height + verticalMargin;
				
				contentPosition += Config.MARGIN;
				wallet.x = Math.max(Config.DIALOG_MARGIN + Config.MARGIN, _width * .5 - wallet.width * .5);
				wallet.y = contentPosition;
				contentPosition += wallet.height + Config.MARGIN * 1.5;
				walletBG.x = Config.DIALOG_MARGIN;
				walletBG.y = wallet.y - Config.MARGIN;
				
				if (changeAddressButton.parent != null)
				{
					changeAddressButton.x = int(_width * .5 - changeAddressButton.width * .5);
					changeAddressButton.y = contentPosition;
					contentPosition += changeAddressButton.height + Config.MARGIN + verticalMargin * 2;
					walletBG.height = wallet.height + Config.MARGIN * 4 + changeAddressButton.height;
				}
				else
				{
					contentPosition += Config.MARGIN * 2;
					walletBG.height = wallet.height + Config.MARGIN * 2;
				}
				
				walletBG.width = _width - Config.DIALOG_MARGIN * 2;
				
				if (giftData != null && giftData.type == 3)
				{
					moreInfo.y = contentPosition;
					contentPosition += moreInfo.height + Config.FINGER_SIZE * .35;
				}
			}
			else
			{
				contentPosition += Config.MARGIN;
				walletDescription.x = Config.DIALOG_MARGIN + Config.MARGIN;
				walletDescription.y = contentPosition;
				contentPosition += walletDescription.height + Config.MARGIN;
				walletBG.x = Config.DIALOG_MARGIN;
				walletBG.y = walletDescription.y - Config.MARGIN;
				
				if (changeAddressButton.parent != null)
				{
					changeAddressButton.x = int(_width * .5 - changeAddressButton.width * .5);
					changeAddressButton.y = contentPosition;
					
					contentPosition += changeAddressButton.height + Config.MARGIN + verticalMargin * 2;
					walletBG.height = walletDescription.height + Config.MARGIN * 4 + changeAddressButton.height;
				}
				else
				{
					contentPosition += Config.MARGIN * 2;
					walletBG.height = walletDescription.height + Config.MARGIN * 2;
				}
				
				walletBG.width = _width - Config.DIALOG_MARGIN * 2;
			}
			
			scroll.setWidthAndHeight(_width, Math.min(scroll.itemsHeight, _height - (title.y + title.height + Config.FINGER_SIZE * .3 + acceptButton.height + verticalMargin * 1.8 + Config.MARGIN * 2)));
			position += scroll.height + Config.MARGIN * 2;
			
			acceptButton.y = position;
			backButton.y = position;
			position += acceptButton.height + verticalMargin * 1.8;
			
			var bdDrawPosition:int = title.y + title.height + Config.FINGER_SIZE * .3;
			
			bg.graphics.clear();
			bg.graphics.beginFill(0xD9E5F0);
			bg.graphics.drawRect(0, 0, _width, bdDrawPosition);
			bg.graphics.endFill();
			
			accountsPreloader.y = bdDrawPosition;
			
			bg.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			bg.graphics.drawRect(0, bdDrawPosition, _width, position - bdDrawPosition);
			bg.graphics.endFill();
			
			container.y = _height - position;
		}
		
		override public function activateScreen():void {
			if (_isDisposed == true)
				return;
			super.activateScreen();
			if (lockedValues == false) {
				iAmountCurrency.activate();
				if (getAccounts() != null && getAccounts().length > 1) {
					selectorDebitAccont.activate();
					selectorCurrency.activate();
				}
			}
			scroll.enable();
			if (selectorFiatAccont != null)
			{
				selectorFiatAccont.activate();
			}
			changeAddressButton.activate();
			useAllButton.activate();
			checkDataValid();
			backButton.activate();
		}
		
		override public function deactivateScreen():void {
			if (_isDisposed == true)
				return;
			super.deactivateScreen();
			iAmountCurrency.deactivate();
			acceptButton.deactivate();
			changeAddressButton.deactivate();
			backButton.deactivate();
			selectorDebitAccont.deactivate();
			selectorCurrency.deactivate();
			useAllButton.deactivate();
			scroll.disable();
			if (selectorFiatAccont != null)
			{
				selectorFiatAccont.deactivate();
			}
		}
		
		protected function onCloseTap():void {
			DialogManager.closeDialog();
		}
		
		private function loadComission():void {
			commissionLoaded = false;
			if (giftData != null && giftData.type == 0)
			{
				drawCommissionText(" \n ");
				_lastCommissionCallID = new Date().getTime().toString() + "bcDeposite";
				if (PayManager.S_BCD_COINS_COMMISSION_RECEIVED != null)
					PayManager.S_BCD_COINS_COMMISSION_RECEIVED.add(onCommissionRespond);
				accountsPreloader.start();
				PayManager.callGetBCDCoinsCommission(Number(iAmountCurrency.value), _lastCommissionCallID);
			}
		}
		
		private function onCommissionRespond(callID:String, data:Object):void {
			if (isDisposed == true)
				return;
			if (_lastCommissionCallID != callID)
				return;
			accountsPreloader.stop();
			if (data is Number)
			{
				showToastMessage(getError(data as Number));
			}
			else if (data is Object)
			{
				commissionLoaded = true;
				drawCommission(data);
			}
		}
		
		private function getError(data:Number):String {
			if (isNaN(data) == true) {
				return Lang.somethingWentWrong;
			} else {
				switch(data) {
					case 3005: {
						return Lang.errorDepositSmallAmount;
					}
					case 3012: {
						return Lang.reachedIncomingLimit;
					}
				}
			}
			return Lang.somethingWentWrong;
		}
		
		private function drawCommission(data:Object):void 
		{
			drawCommissionText(Lang.textCommission + ": " + data.readable + "\n" + Lang.toBeCredited + ": " + (parseFloat(iAmountCurrency.value) - parseFloat(data.amount)).toString() + " " + data.ccy_symbol);
			drawView();
		}
		
		private function drawCommissionText(text:String):void 
		{
			if (commissionText.bitmapData != null)
			{
				commissionText.bitmapData.dispose();
				commissionText.bitmapData = null;
			}
			commissionText.bitmapData = TextUtils.createTextFieldData(text, componentsWidth, 10, true, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .24, true, 0x47515B, 0xffffff, false);
			commissionText.x = Config.DIALOG_MARGIN;
		}
		
		override public function dispose():void {
			if (_isDisposed == true)
				return;
			super.dispose();
			
			BankManager.S_WALLETS.remove(onNewWallets);
			BankManager.S_DECLARE_ETH_LINK.remove(registerAddressLinkReady);
			BankManager.S_PAYMENT_ERROR.remove(onError);
			if (PayManager.S_BCD_COINS_COMMISSION_RECEIVED != null)
				PayManager.S_BCD_COINS_COMMISSION_RECEIVED.remove(onCommissionRespond);
			if (PayManager.S_INVESTMENT_COMMISSION_RECEIVED != null)
				PayManager.S_INVESTMENT_COMMISSION_RECEIVED.remove(onCommissionInvestmentRespond);
			TweenMax.killDelayedCallsTo(loadComission);
			TweenMax.killDelayedCallsTo(getInvestmentCommission);
			
			Overlay.removeCurrent();
			
			if (moreInfo != null)
				UI.destroy(moreInfo);
			moreInfo = null;
			if (scrollTop != null)
				UI.destroy(scrollTop);
			scrollTop = null;
			if (selectorCurrency != null)
				selectorCurrency.dispose();
			selectorCurrency = null;
			if (iAmountCurrency != null)
				iAmountCurrency.dispose();
			iAmountCurrency = null;
			if (title != null)
				UI.destroy(title);
			title = null;
			if (commissionText != null)
				UI.destroy(commissionText);
			commissionText = null;
			if (text != null)
				UI.destroy(text);
			text = null;
			if (selectorDebitAccont != null)
				selectorDebitAccont.dispose();
			selectorDebitAccont = null;
			if (selectorFiatAccont != null)
				selectorFiatAccont.dispose();
			selectorFiatAccont = null;
			if (backButton != null)
				backButton.dispose();
			backButton = null;
			if (accountText != null)
				UI.destroy(accountText);
			accountText = null;
			if (acceptButton != null)
				acceptButton.dispose();
			acceptButton = null;
			if (bg != null)
				UI.destroy(bg);
			bg = null;
			if (commissionText != null)
				UI.destroy(commissionText);
			commissionText = null;
			if (container != null)
				UI.destroy(container);
			container = null;
			if (accountsPreloader != null)
				accountsPreloader.dispose();
			accountsPreloader = null;
			if (wallet != null)
				UI.destroy(wallet);
			wallet = null;
			if (walletDescription != null)
				UI.destroy(walletDescription);
			walletDescription = null;
			if (walletBG != null)
				UI.destroy(walletBG);
			walletBG = null;
			if (changeAddressButton != null)
				changeAddressButton.dispose();
			changeAddressButton = null;
			if (scroll != null)
				scroll.dispose();
			scroll = null;
			if (useAllButton != null)
				useAllButton.dispose();
			useAllButton = null;
			giftData = null;
		}
	}
}