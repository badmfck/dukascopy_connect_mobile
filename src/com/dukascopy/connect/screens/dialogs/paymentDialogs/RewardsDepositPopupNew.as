package com.dukascopy.connect.screens.dialogs.paymentDialogs 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.GiftData;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.gui.button.DDAccountButton;
	import com.dukascopy.connect.gui.button.DDFieldButton;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.renderers.ListPayCurrency;
	import com.dukascopy.connect.gui.list.renderers.ListPayWalletItem;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.menuVideo.OptionSwitcher;
	import com.dukascopy.connect.gui.preloader.Preloader;
	import com.dukascopy.connect.gui.scrollPanel.ScrollPanel;
	import com.dukascopy.connect.gui.tools.HorizontalPreloader;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.dialogs.ScreenPayDialog;
	import com.dukascopy.connect.screens.dialogs.paymentDialogs.elements.DepositVariantClip;
	import com.dukascopy.connect.screens.payments.card.TypeCurrency;
	import com.dukascopy.connect.screens.serviceScreen.Overlay;
	import com.dukascopy.connect.sys.bankManager.BankBotController;
	import com.dukascopy.connect.sys.bankManager.BankManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.payments.InvoiceManager;
	import com.dukascopy.connect.sys.payments.PayManager;
	import com.dukascopy.connect.sys.payments.PayRespond;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.softKeyboard.SoftKeyboard;
	import com.dukascopy.connect.sys.style.FontSize;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.connect.vo.BankMessageVO;
	import com.dukascopy.langs.Lang;
	import com.dukascopy.langs.LangManager;
	import com.greensock.TweenMax;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	
	public class RewardsDepositPopupNew extends BaseScreen {
	
		static public const STATE_VARIANTS:String = "stateVariants";
		static public const STATE_START:String = "stateStart";
		
		protected var container:Sprite;
		private var bg:Shape;
		private var text:Bitmap;
		private var acceptButton:BitmapButton;
		private var backButton:BitmapButton;
		private var selectorDebitAccont:DDAccountButton;
		private var selectorBlockchainAccont:DDAccountButton;
		private var preloader:Preloader;
		private var screenLocked:Boolean;
		private var verticalMargin:Number;
		private var walletSelected:Boolean;
		private var selectedAccount:Object;
		private var preloaderShown:Boolean = false;
		private var iAmountCurrency:Input;
		private var selectorCurrency:DDFieldButton;
		private var sendSectionTitle:Bitmap;
		private var accountsPreloader:HorizontalPreloader;
		private var giftData:GiftData;
		private var _lastCommissionCallID:String;
		protected var componentsWidth:int;
		private var accounts:Array;
		private var title:Bitmap;
		private var scroll:ScrollPanel;
		private var variants:Vector.<DepositVariantClip>;
		private var state:String;
		//private var description:Bitmap;
		private var bankTitle:Bitmap;
		private var blockchainTitle:Bitmap;
		
		public function RewardsDepositPopupNew() {
			
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
			
			title = new Bitmap();
			container.addChild(title);
			
			/*description = new Bitmap();
			container.addChild(description);*/
			
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
			
			selectorDebitAccont = new DDAccountButton(openWalletSelector, null, false);
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
			
			selectorCurrency = new DDFieldButton(selectCurrencyTap, "", false);
			scroll.addObject(selectorCurrency);
			
			sendSectionTitle = new Bitmap();
			scroll.addObject(sendSectionTitle);
			
			accountsPreloader = new HorizontalPreloader();
			container.addChild(accountsPreloader);
			
			bankTitle = new Bitmap();
			scroll.addObject(bankTitle);
			
			blockchainTitle = new Bitmap();
			scroll.addObject(blockchainTitle);
		}
		
		private function onInputSelected():void 
		{
			
		}
		
		private function checkDataValid():void {
			
			var valid:Boolean = true;
			
			/*if (isActivated && 
				selectedAccount != null && 
				iAmountCurrency.value != null && 
				iAmountCurrency.value != "" && 
				!isNaN(Number(iAmountCurrency.value)) && 
				Number(iAmountCurrency.value) >= giftData.minAmount)
			{
				if (giftData.maxAmount > 0)
				{
					if (Number(iAmountCurrency.value) <= giftData.maxAmount)
					{
						valid = true;
					}
					else
					{
						valid = false;
					}
				}
				else
				{
					valid = true;
				}
			}
			else
			{
				valid = false;
			}*/
			
			if (selectedAccount != null && 
				iAmountCurrency.value != null && 
				iAmountCurrency.value != "" && 
				!isNaN(Number(iAmountCurrency.value)) &&
				Number(iAmountCurrency.value) > 0)
			{
				valid = true;
			}
			else
			{
				valid = false;
			}
			
			if (valid == true)
			{
				acceptButton.activate();
				acceptButton.alpha = 1;
				iAmountCurrency.unselectBorder();
			}
			else
			{
				acceptButton.deactivate();
				acceptButton.alpha = 0.5;
				iAmountCurrency.selectBorder();
			}
		}
		
		private function selectCurrencyTap():void 
		{
			return;
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
			return;
			
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
					//selectorCurrency.setValue();
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
				if (state == STATE_START) {
					ServiceScreenManager.closeView();
				} else if (state == STATE_VARIANTS) {
					acceptButton.x = int(acceptButton.width + Config.DIALOG_MARGIN * 2);
					acceptButton.visible = true;
					acceptButton.tapCallback = nextClick;
					backButton.x = Config.DIALOG_MARGIN;
					
					drawTitle(Lang.rewardsDeposit);
					state = STATE_START;					
					clearVariants();
					scroll.removeAllObjects();
					scroll.addObject(selectorDebitAccont);
					scroll.addObject(iAmountCurrency.view);
					scroll.addObject(selectorCurrency);
					scroll.addObject(sendSectionTitle);
					scroll.addObject(selectorBlockchainAccont);
					scroll.addObject(blockchainTitle);
					scroll.addObject(bankTitle);
					
					scroll.addObject(selectorDebitAccont);
					
					drawView();
				}
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
				
				
				BankManager.getPossibleRewardDeposites(giftData);
				accountsPreloader.start();
				
				/*if (giftData.callback != null)
				{
					giftData.callback(giftData);
				}*/
			}
			
		//	ServiceScreenManager.closeView();
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
		
		private function drawTitle(text:String, maxWidth:Number = NaN):void
		{
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
			
			/*var bdDrawPosition:int = title.y + title.height + Config.FINGER_SIZE * .3;
			
			var h:int = bg.height;
			
			bg.graphics.clear();
			bg.graphics.beginFill(0xD9E5F0);
			bg.graphics.drawRect(0, 0, _width, bdDrawPosition);
			bg.graphics.endFill();
			
			bg.graphics.beginFill(Style.color(Style.COLOR_BACKGRIUND));
			bg.graphics.drawRect(0, bdDrawPosition, _width, h - bdDrawPosition);
			bg.graphics.endFill();*/
		}
		
		override public function initScreen(data:Object = null):void
		{
			super.initScreen(data);
			
			if (data != null && "giftData" in data && data.giftData is GiftData) {
				giftData = data.giftData as GiftData;
			}
			
			componentsWidth = _width - Config.DIALOG_MARGIN * 2;
			
			drawTitle(Lang.rewardsDeposit);
			
			drawSendTitle();
			drawAccountSelector();
			if (giftData != null && giftData.wallets != null && giftData.wallets.length > 1)
			{
				drawAccountBlockchainSelector();
			}
		//	drawAccountText(Lang.chooseAccount);
			drawAcceptButton(Lang.textNext);
			acceptButton.deactivate();
			acceptButton.alpha = 0.5;
		//	drawDescription();
			
			drawBackButton();
			
			var itemWidth:int = (componentsWidth - Config.MARGIN) / 2;
			
			title.x = Config.DIALOG_MARGIN;
			
			iAmountCurrency.width = itemWidth;
			iAmountCurrency.view.x = Config.DIALOG_MARGIN;
			
			selectorCurrency.x = iAmountCurrency.view.x + itemWidth + Config.MARGIN;
			selectorCurrency.setSize(itemWidth, Config.FINGER_SIZE * .8);
			
			accountsPreloader.setSize(_width, int(Config.FINGER_SIZE * .05));
			
			selectInitialData();
			
			if (getAccounts() != null && getAccounts().length == 1)
			{
				selectorCurrency.deactivate();
				selectorDebitAccont.deactivate();
			}
			
			BankManager.S_POSSIBLE_RD.add(drawDepositVariants);
			BankManager.S_PAYMENT_ERROR.add(onPaymentsError);
			
			state = STATE_START;
		}
		
		private function onPaymentsError(lastMessage:BankMessageVO):void 
		{
			if (lastMessage != null && lastMessage.text != null)
			{
				ToastMessage.display(lastMessage.text);
			}
			
			accountsPreloader.stop();
		}
		
		private function drawDepositVariants(deposits:Array):void 
		{
			accountsPreloader.stop();
			
			state = STATE_VARIANTS;
			drawTitle(Lang.rewardsDepositOptions);
			
			acceptButton.tapCallback = chooseSelected;
			
			/*acceptButton.visible = false;
			
			backButton.x = int(_width*.5 - backButton.width*.5);*/
			
			clearVariants();

			// variants
			//

			//1598362609 (0x5f4513f1)

			if (deposits != null) {
				if (deposits.length == 1) {
					onVariantSelected(deposits[0]);
					return;
				}
				variants = new Vector.<DepositVariantClip>();
				scroll.removeAllObjects();
				var clip:DepositVariantClip;
				var position:int;
				for (var i:int = 0; i < deposits.length; i++) {
					clip = new DepositVariantClip(_width, deposits[i], onVariantChoised);
					clip.activate();
					variants.push(clip);
					position = scroll.itemsHeight;
					scroll.addObject(clip);
					clip.y = position;
				}
				drawView();
			}
		}
		
		private function chooseSelected():void {
			var clip:DepositVariantClip;
			for (var i:int = 0; i < variants.length; i++) {
				clip = variants[i];
				if (clip.selected == true) {
					onVariantSelected(clip.data);
					return;
				}
			}
			ToastMessage.display(Lang.chooseRDVariant);
		}
		
		private function onVariantChoised(variantData:Object):void {
			var clip:DepositVariantClip;
			for (var i:int = 0; i < variants.length; i++) {
				clip = variants[i];
				if (clip.data == variantData) {
					clip.select();
					continue;
				}
				clip.deselect();
			}
		}
		
		private function onVariantSelected(variantData:Object):void {
			if (giftData != null && giftData.callback != null) {
				giftData.rewardDeposit = variantData;
				giftData.callback(giftData);
				ServiceScreenManager.closeView();
			}
		}
		
		private function clearVariants():void 
		{
			if (variants != null)
			{
				for (var i:int = 0; i < variants.length; i++) 
				{
					variants[i].dispose();
				}
			}
		}
		
	/*	private function drawDescription():void 
		{
			description.bitmapData = TextUtils.createTextFieldData(Lang.amountAvaliable, componentsWidth, 10, false, 
															TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .28, false, 0x999999, 0xFFFFFF, false, true);
			description.x = componentsWidth - description.width + Config.DIALOG_MARGIN;
		}*/
		
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
						if (wallets[i] != null && Number(bigAccount.BALANCE) < Number(wallets[i].BALANCE) && "ACCOUNT_NUMBER" in wallets[i])
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
		
		private function drawSendTitle():void {
			if (sendSectionTitle.bitmapData) {
				sendSectionTitle.bitmapData.dispose();
				sendSectionTitle.bitmapData = null;
			}
			var value:String = Lang.enterDepositAmount;
			
			sendSectionTitle.bitmapData = TextUtils.createTextFieldData(
				value,
				componentsWidth,
				10,
				false,
				TextFormatAlign.LEFT,
				TextFieldAutoSize.LEFT,
				Config.FINGER_SIZE * .28,
				true,
				0x777E8A,
				0xFFFFFF,
				true,
				true
			);
			sendSectionTitle.x = Config.DIALOG_MARGIN;
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
			checkDataValid();
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
		
		private function drawAccountBlockchainSelector():void 
		{
			if (giftData != null && giftData.wallets != null && giftData.wallets.length > 1)
			{
				for (var i:int = 0; i < giftData.wallets.length; i++) 
				{
					if ("ADDRESS" in giftData.wallets[i])
					{
						selectorBlockchainAccont = new DDAccountButton(null, null, false);
						scroll.addObject(selectorBlockchainAccont);
						
						selectorBlockchainAccont.setSize(componentsWidth, Config.FINGER_SIZE * .8);
						selectorBlockchainAccont.x = Config.DIALOG_MARGIN;

						selectorBlockchainAccont.setValue(giftData.wallets[i]);
						
						drawBankTitle();
						drawBlockchainTitle();
						break;
					}
				}
			}
		}
		
		private function drawBlockchainTitle():void 
		{
			blockchainTitle.bitmapData = TextUtils.createTextFieldData(Lang.textInBank, _width - Config.DIALOG_MARGIN*2, 
																10, true, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
																FontSize.CAPTION_1, true, Style.color(Style.COLOR_SUBTITLE), 
																Style.color(Style.COLOR_BACKGROUND));
		}
		
		private function drawBankTitle():void 
		{
			bankTitle.bitmapData = TextUtils.createTextFieldData(Lang.textInBlockchain, _width - Config.DIALOG_MARGIN*2, 
																10, true, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, 
																FontSize.CAPTION_1, true, Style.color(Style.COLOR_SUBTITLE), 
																Style.color(Style.COLOR_BACKGROUND));
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
		
		override protected function drawView():void 
		{
			if (_isDisposed == true)
				return;
			
		//	bg.width = _width;
			
			verticalMargin = Config.MARGIN * 1.5;
			
			var position:int = Config.FINGER_SIZE * .35;
			
			title.y = position;
			position += title.height + Config.FINGER_SIZE * .75;
			
			var bdDrawPosition:int = title.y + title.height + Config.FINGER_SIZE * .3;
			
			scroll.view.y = bdDrawPosition;
			position = Config.DIALOG_MARGIN;
			
			if (state == STATE_START)
			{
				sendSectionTitle.y = position;
				position += sendSectionTitle.height + verticalMargin * 1.5;
				
				iAmountCurrency.view.y = position;
				selectorCurrency.y = position;
				position += iAmountCurrency.height + verticalMargin * 1.5;
				
				if (selectorBlockchainAccont != null)
				{
					bankTitle.x = selectorBlockchainAccont.x;
					bankTitle.y = position;
					position += bankTitle.height;
					
					selectorBlockchainAccont.y = position;
					position += selectorBlockchainAccont.height + Config.FINGER_SIZE * .1;
					
					blockchainTitle.x = selectorDebitAccont.x;
					blockchainTitle.y = position;
					position += blockchainTitle.height;
				}
				
				selectorDebitAccont.y = position;
				position += selectorDebitAccont.height + Config.FINGER_SIZE * .0;
				
				scroll.setWidthAndHeight(_width, Math.min(scroll.itemsHeight + Config.FINGER_SIZE * .50, _height - acceptButton.height - Config.FINGER_SIZE * .75 - Config.FINGER_SIZE * 1.5));
				position = scroll.view.y + scroll.height + verticalMargin * 1.6;
			}
			else if (state == STATE_VARIANTS)
			{
				scroll.setWidthAndHeight(_width, Math.min(scroll.itemsHeight + Config.FINGER_SIZE * .50, _height - acceptButton.height - Config.FINGER_SIZE * .75 - Config.FINGER_SIZE * 1.5));
				position = scroll.view.y + scroll.height + verticalMargin * 0.5;
			}
			
			acceptButton.y = position;
			backButton.y = position;
			position += acceptButton.height + verticalMargin * 1.8;
			
			bg.graphics.clear();
			bg.graphics.beginFill(0xD9E5F0);
			bg.graphics.drawRect(0, 0, _width, bdDrawPosition);
			bg.graphics.endFill();
			
			accountsPreloader.y = bdDrawPosition;
			
			bg.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			bg.graphics.drawRect(0, bdDrawPosition, _width, position - bdDrawPosition);
			bg.graphics.endFill();
			
			container.y = _height - position;
			scroll.update();
			
			var point:Point = new Point(scroll.view.x, scroll.view.y);
			point = container.localToGlobal(point);
			var cropRectangle:Rectangle = new Rectangle(point.x, point.y, _width, scroll.height);
			if (variants != null)
			{
				for (var i:int = 0; i < variants.length; i++) 
				{
					variants[i].setOverlaySize(cropRectangle);
				}
			}
		}
		
		override public function activateScreen():void 
		{
			if (_isDisposed == true)
				return;
			
			super.activateScreen();
			
			iAmountCurrency.activate();
			checkDataValid();
			scroll.enable();
			
			backButton.activate();
			
			if (getAccounts() != null && getAccounts().length > 1)
			{
			//	selectorDebitAccont.activate();
			//	selectorCurrency.activate();
			}
			
			if (variants != null)
			{
				for (var i:int = 0; i < variants.length; i++) 
				{
					variants[i].activate();
				}
			}
		}
		
		override public function deactivateScreen():void 
		{
			if (_isDisposed == true)
				return;
			
			super.deactivateScreen();
			
			scroll.disable();
			iAmountCurrency.deactivate();
			acceptButton.deactivate();
			backButton.deactivate();
			selectorDebitAccont.deactivate();
			selectorCurrency.deactivate();
			
			if (variants != null)
			{
				for (var i:int = 0; i < variants.length; i++) 
				{
					variants[i].activate();
				}
			}
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
			
			BankManager.S_POSSIBLE_RD.remove(drawDepositVariants);
			BankManager.S_PAYMENT_ERROR.remove(onPaymentsError);
			Overlay.removeCurrent();
			
			if (sendSectionTitle != null)
			{
				UI.destroy(sendSectionTitle);
				sendSectionTitle = null;
			}
			if (selectorCurrency != null)
			{
				selectorCurrency.dispose();
				selectorCurrency = null;
			}
			if (iAmountCurrency != null)
			{
				iAmountCurrency.dispose();
				iAmountCurrency = null;
			}
			if (title != null)
			{
				UI.destroy(title);
				title = null;
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
			if (selectorBlockchainAccont != null)
			{
				selectorBlockchainAccont.dispose();
				selectorBlockchainAccont = null;
			}
			if (backButton != null)
			{
				backButton.dispose();
				backButton = null;
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
			if (bankTitle != null)
			{
				UI.destroy(bankTitle);
				bankTitle = null;
			}
			if (blockchainTitle != null)
			{
				UI.destroy(blockchainTitle);
				blockchainTitle = null;
			}
			/*if (description != null)
			{
				UI.destroy(description);
				description = null;
			}*/
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
			if (variants != null)
			{
				for (var i:int = 0; i < variants.length; i++) 
				{
					variants[i].dispose();
				}
				variants = null;
			}
			
			giftData = null;
		}
	}
}