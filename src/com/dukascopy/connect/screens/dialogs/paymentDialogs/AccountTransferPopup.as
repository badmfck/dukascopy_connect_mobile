package com.dukascopy.connect.screens.dialogs.paymentDialogs 
{
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.GiftData;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.gui.button.DDAccountButton;
	import com.dukascopy.connect.gui.button.DDFieldButton;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.renderers.ListPayCurrency;
	import com.dukascopy.connect.gui.list.renderers.ListPayWalletItem;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.dialogs.ScreenPayDialog;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.softKeyboard.SoftKeyboard;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
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
	
	public class AccountTransferPopup extends BaseScreen {
		
		protected var container:Sprite;
		private var bg:Shape;
		private var text:Bitmap;
		private var acceptButton:BitmapButton;
		private var backButton:BitmapButton;
		private var selectorFromAccont:DDAccountButton;
		private var selectorToAccont:DDAccountButton;
		private var verticalMargin:Number;
		private var iAmount:Input;
		private var selectorCurrency:DDFieldButton;
		private var amountSectionTitle:Bitmap;
		private var accountToTitle:Bitmap;
		private var accountFromTitle:Bitmap;
		private var id:String;
		private var giftData:GiftData;
		private var fromAccounts:Array;
		private var toAccounts:Array;
		private var selectedToAccount:Object;
		private var selectedFromAccount:Object;
		protected var componentsWidth:int;
		
		public function AccountTransferPopup() {
			
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
			
			selectorFromAccont = new DDAccountButton(openFromWalletSelector, null, DDAccountButton.STYLE_1);
			container.addChild(selectorFromAccont);
			
			selectorToAccont = new DDAccountButton(openToWalletSelector, null, DDAccountButton.STYLE_1);
			container.addChild(selectorToAccont);
			
			_view.addChild(container);
			
			iAmount = new Input(Input.MODE_DIGIT_DECIMAL);
			iAmount.setParams(Lang.textAmount, Input.MODE_DIGIT_DECIMAL);
			iAmount.S_CHANGED.add(onChangeInputValueCurrency);
			iAmount.setRoundBG(false);
			iAmount.getTextField().textColor = Style.color(Style.COLOR_TEXT);
			iAmount.setRoundRectangleRadius(0);
			iAmount.inUse = true;
			container.addChild(iAmount.view);
			
			selectorCurrency = new DDFieldButton(selectCurrencyTap, "", true);
			container.addChild(selectorCurrency);
			
			amountSectionTitle = new Bitmap();
			container.addChild(amountSectionTitle);
			
			accountToTitle = new Bitmap();
			container.addChild(accountToTitle);
			
			accountFromTitle = new Bitmap();
			container.addChild(accountFromTitle);
		}
		
		private function selectCurrencyTap():void {
			if (fromAccounts != null && toAccounts != null)
			{
				var currencies:Array = new Array();
				/*var l:int = fromAccounts.length;
				
				var walletItem:Object;
				for (var i:int = 0; i < l; i++)
				{
					walletItem = fromAccounts[i];
					var exist:Boolean = false;
					for (var j:int = 0; j < currencies.length; j++) 
					{
						if (currencies[j] == walletItem.CURRENCY)
						{
							exist = true;
						}
					}
					if (exist == false)
					{
						currencies.push(walletItem.CURRENCY);
					}
				}*/
				currencies.push(selectedFromAccount.CURRENCY);
				if (selectedFromAccount.CURRENCY != selectedToAccount.CURRENCY)
				{
					currencies.push(selectedToAccount.CURRENCY);
				}
				
				DialogManager.showDialog(ScreenPayDialog, {callback: callBackSelectCurrency, data: currencies, itemClass: ListPayCurrency, label: Lang.selectCurrency});
			}
		}
		
		private function checkDataValid():void
		{
			if (isActivated && selectedFromAccount != null && selectedToAccount != null && iAmount.value != null && iAmount.value != "" && !isNaN(Number(iAmount.value)))
			{
				acceptButton.activate();
				acceptButton.alpha = 1;
			}
			else{
				acceptButton.deactivate();
				acceptButton.alpha = 0.5;
			}
		}
		
		private function openFromWalletSelector(e:Event = null):void
		{
			if (fromAccounts != null)
			{
				SoftKeyboard.closeKeyboard();
				if (iAmount != null)
				{
					iAmount.forceFocusOut();
				}
				
				DialogManager.showDialog(ScreenPayDialog, {callback: onWalletFromSelect, data: fromAccounts, itemClass: ListPayWalletItem/*ListPayAccount*/, label: Lang.TEXT_SELECT_ACCOUNT});
			}
		}
		
		private function onWalletFromSelect(account:Object, updateCards:Boolean = true, cleanCurrent:Boolean = false):void
		{
			if (account == null)
			{
				if (cleanCurrent == true)
				{
					selectedFromAccount = account;
				}	
			}
			else
			{
				selectedFromAccount = account;
			}
			if (account != null || cleanCurrent == true)
			{
				selectorFromAccont.setValue(account);
			}
			if (selectedFromAccount != null)
			{
				if (selectorCurrency.value != selectedFromAccount && selectorCurrency.value != selectedToAccount)
				{
					selectorCurrency.setValue(selectedFromAccount.CURRENCY);
				}
			}
		}
		
		private function openToWalletSelector(e:Event = null):void
		{
			if (toAccounts != null)
			{
				SoftKeyboard.closeKeyboard();
				if (iAmount != null)
				{
					iAmount.forceFocusOut();
				}
				
				DialogManager.showDialog(ScreenPayDialog, {callback: onWalletToSelect, data: toAccounts, itemClass: ListPayWalletItem/*ListPayAccount*/, label: Lang.TEXT_SELECT_ACCOUNT});
			}
		}
		
		private function onWalletToSelect(account:Object, updateCards:Boolean = true, cleanCurrent:Boolean = false):void
		{
			if (account == null)
			{
				if (cleanCurrent == true)
				{
					selectedToAccount = account;
				}	
			}
			else
			{
				selectedToAccount = account;
			}
			if (account != null || cleanCurrent == true)
			{
				selectorToAccont.setValue(account);
			}
			if (selectedFromAccount != null)
			{
				if (selectorCurrency.value != selectedFromAccount && selectorCurrency.value != selectedToAccount)
				{
					selectorCurrency.setValue(selectedFromAccount.CURRENCY);
				}
			}
		}
		
		override public function onBack(e:Event = null):void {
			ServiceScreenManager.closeView();
		}
		
		private function backClick():void {
			onBack();
		}
		
		private function nextClick():void {
			SoftKeyboard.closeKeyboard();
			if (iAmount != null)
			{
				iAmount.forceFocusOut();
			}
			if (giftData != null)
			{
				giftData.credit_account_number = selectedFromAccount.ACCOUNT_NUMBER;
				giftData.accountNumber = selectedToAccount.ACCOUNT_NUMBER;
				giftData.currency = selectorCurrency.value;
				giftData.customValue = Number(iAmount.value);
				
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
			
			if (data != null) {
				if ("fromAccounts" in data && data.fromAccounts != null && data.fromAccounts is Array)
				{
					fromAccounts = data.fromAccounts as Array;
				}
				if ("toAccounts" in data && data.toAccounts != null && data.toAccounts is Array)
				{
					toAccounts = data.toAccounts as Array;
				}
				if ("giftData" in data && data.giftData != null && data.giftData is GiftData)
				{
					giftData = data.giftData as GiftData;
				}
			}
			
			componentsWidth = _width - Config.DIALOG_MARGIN * 2;
			
			drawAmountTitle();
			drawAccountFromSectionTitle();
			drawAccountToSectionTitle();
			
			drawAccountFromSelector();
			drawAccountToSelector();
			
			drawAcceptButton(Lang.textNext);
			acceptButton.deactivate();
			acceptButton.alpha = 0.5;
			
			drawBackButton();
			
			var itemWidth:int = (componentsWidth - Config.MARGIN) / 2;
			
			iAmount.width = itemWidth;
			iAmount.view.x = Config.DIALOG_MARGIN;
			
			selectorCurrency.x = iAmount.view.x + itemWidth + Config.MARGIN;
			selectorCurrency.setSize(itemWidth, Config.FINGER_SIZE * .8);
			
			selectDefaultFromAccount();
			selectDefaultToAccount();
		}
		
		private function selectDefaultToAccount():void 
		{
			if (giftData != null && giftData.accountNumber != null && toAccounts != null)
			{
				var l:int = toAccounts.length;
				for (var i:int = 0; i < l; i++) 
				{
					if (toAccounts[i].ACCOUNT_NUMBER == giftData.accountNumber)
					{
						selectedToAccount = toAccounts[i];
						selectorToAccont.setValue(selectedToAccount);
						return;
					}
				}
			}
			
			if (toAccounts != null && toAccounts.length > 0)
			{
				selectedToAccount = toAccounts[0];
				selectorToAccont.setValue(selectedToAccount);
			}
		}
		
		private function selectDefaultFromAccount():void 
		{
			if (giftData != null && giftData.credit_account_number != null && fromAccounts != null)
			{
				var l:int = fromAccounts.length;
				for (var i:int = 0; i < l; i++) 
				{
					if (fromAccounts[i].ACCOUNT_NUMBER == giftData.credit_account_number)
					{
						selectedFromAccount = fromAccounts[i];
						selectorFromAccont.setValue(selectedFromAccount);
						selectorCurrency.setValue(selectedFromAccount.CURRENCY);
						return;
					}
				}
			}
			
			if (fromAccounts != null && fromAccounts.length > 0)
			{
				selectedFromAccount = fromAccounts[0];
				selectorFromAccont.setValue(selectedFromAccount);
				selectorCurrency.setValue(selectedFromAccount.CURRENCY);
			}
		}
		
		private function drawAccountFromSectionTitle():void 
		{
			if (accountFromTitle.bitmapData)
			{
				accountFromTitle.bitmapData.dispose();
				accountFromTitle.bitmapData = null;
			}
			accountFromTitle.bitmapData = TextUtils.createTextFieldData("<b>" + Lang.fromAccount + "</b>", componentsWidth, 10, false, TextFormatAlign.LEFT, 
																	TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .3, false, 0x777E8A, 0xFFFFFF, false, true);
		}
		
		private function drawAccountToSectionTitle():void 
		{
			if (accountToTitle.bitmapData)
			{
				accountToTitle.bitmapData.dispose();
				accountToTitle.bitmapData = null;
			}
			accountToTitle.bitmapData = TextUtils.createTextFieldData("<b>" + Lang.toAccount + "</b>", componentsWidth, 10, false, TextFormatAlign.LEFT, 
																	TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .3, false, 0x777E8A, 0xFFFFFF, false, true);
		}
		
		private function drawAmountTitle():void{
			if (amountSectionTitle.bitmapData){
				amountSectionTitle.bitmapData.dispose();
				amountSectionTitle.bitmapData = null;
			}
			amountSectionTitle.bitmapData =
				TextUtils.createTextFieldData("<b>" + Lang.transfer + "</b>",
				componentsWidth,
				10,
				false,
				TextFormatAlign.LEFT,
				TextFieldAutoSize.LEFT,
				Config.FINGER_SIZE * .3,
				false,
				0x777E8A,
				0xFFFFFF,
				false,
				true
			);
			
			amountSectionTitle.x = int(_width * .5 - amountSectionTitle.width * .5);
		}
		
		private function callBackSelectCurrency(currency:String):void {
			if (selectorCurrency != null && currency != null) {
				selectorCurrency.setValue(currency);
			}
		}
		
		private function onChangeInputValueCurrency():void {
			checkDataValid();
		}
		
		private function drawAccountFromSelector():void
		{
			selectorFromAccont.setSize(componentsWidth, Config.FINGER_SIZE * .8);
			selectorFromAccont.setValue(Lang.walletToCharge);
			selectorFromAccont.x = Config.DIALOG_MARGIN;
		}
		
		private function drawAccountToSelector():void
		{
			selectorToAccont.setSize(componentsWidth, Config.FINGER_SIZE * .8);
			selectorToAccont.setValue(Lang.walletToCharge);
			selectorToAccont.x = Config.DIALOG_MARGIN;
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
			
			bg.width = _width;
			
			verticalMargin = Config.MARGIN * 1.5;
			
			var position:int;
			
			position = verticalMargin;
			
			position += verticalMargin * 1.5;
			
			// WITHDRAW
			amountSectionTitle.y = position;
			position += amountSectionTitle.height + verticalMargin * 1.5;
			amountSectionTitle.x = int(_width * .5 - amountSectionTitle.width * .5);
			
			// AMOUNT
			iAmount.view.y = position;
			selectorCurrency.y = position;
			position += iAmount.height + verticalMargin * 2.5;
			
			// FROM ACCOUNT
			accountFromTitle.y = position;
			accountFromTitle.x = int(_width * .5 - accountFromTitle.width * .5);
			position += accountFromTitle.height + verticalMargin * .6;
			
			// ACCOUNT
			selectorFromAccont.y = position;
			position += selectorFromAccont.height + verticalMargin * 3;
			
			// TO
			accountToTitle.y = position;
			accountToTitle.x = int(_width * .5 - accountToTitle.width * .5);
			position += accountToTitle.height + verticalMargin * .6;
			
			// CARD
			selectorToAccont.y = position;
			position += selectorToAccont.height + verticalMargin * 3;
			
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
			
			super.activateScreen();
			
			iAmount.activate();
			
			checkDataValid();
			
			backButton.activate();
			selectorCurrency.activate();
			selectorFromAccont.activate();
			selectorToAccont.activate();
		}
		
		override public function deactivateScreen():void
		{
			if (_isDisposed == true)
				return;
			
			super.deactivateScreen();
			
			iAmount.deactivate();
			acceptButton.deactivate();
			backButton.deactivate();
			selectorFromAccont.deactivate();
			selectorCurrency.deactivate();
			selectorToAccont.deactivate();
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
			
			if (amountSectionTitle != null)
			{
				UI.destroy(amountSectionTitle);
				amountSectionTitle = null;
			}
			if (accountToTitle != null)
			{
				UI.destroy(accountToTitle);
				accountToTitle = null;
			}
			if (accountFromTitle != null)
			{
				UI.destroy(accountFromTitle);
				accountFromTitle = null;
			}
			if (iAmount != null)
			{
				iAmount.dispose();
				iAmount = null;
			}
			if (text != null)
			{
				UI.destroy(text);
				text = null;
			}
			if (selectorFromAccont != null)
			{
				selectorFromAccont.dispose();
				selectorFromAccont = null;
			}
			if (selectorToAccont != null)
			{
				selectorToAccont.dispose();
				selectorToAccont = null;
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
			if (container != null)
			{
				UI.destroy(container);
				container = null;
			}
			
			giftData = null;
		}
	}
}