package com.dukascopy.connect.screens.dialogs.extensions 
{
	import assets.DoneRoundIcon;
	import assets.JailedIllustrationClip;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.PopupData;
	import com.dukascopy.connect.data.SelectorItemData;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.customActions.OpenBankAccountAction;
	import com.dukascopy.connect.gui.button.DDAccountButton;
	import com.dukascopy.connect.gui.button.DDFieldButton;
	import com.dukascopy.connect.gui.chat.CircleAvatar;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.components.slideSelector.SlideSelector;
	import com.dukascopy.connect.gui.components.slideSelector.SlideSelectorItemData;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.renderers.ListPayCurrency;
	import com.dukascopy.connect.gui.list.renderers.ListPayWalletItem;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.menuVideo.OptionSwitcher;
	import com.dukascopy.connect.gui.scrollPanel.ScrollPanel;
	import com.dukascopy.connect.gui.tools.HorizontalPreloader;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.dialogs.ScreenPayDialog;
	import com.dukascopy.connect.screens.payments.card.TypeCurrency;
	import com.dukascopy.connect.screens.serviceScreen.BottomPopupScreen;
	import com.dukascopy.connect.screens.serviceScreen.Overlay;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.applicationShop.product.SubscriptionDuration;
	import com.dukascopy.connect.sys.applicationShop.product.SubscriptionDurationType;
	import com.dukascopy.connect.sys.applicationShop.serverTask.ShopServerTask;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.configManager.ConfigManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.payments.PayManager;
	import com.dukascopy.connect.sys.payments.PaymentsManager;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.usersManager.extensions.Extension;
	import com.dukascopy.connect.sys.usersManager.extensions.ExtensionRequestData;
	import com.dukascopy.connect.sys.usersManager.extensions.UserExtensionsManager;
	import com.dukascopy.connect.sys.usersManager.extensions.config.FlowersConfig;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.connect.vo.users.UserVO;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import com.greensock.easing.Power3;
	import flash.display.Bitmap;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	
	public class PutUserExtensionPopup extends BaseScreen
	{
		static public const STATE_RESULT:String = "stateResult";
		static public const STATE_GENERAL:String = "stateGeneral";
		static public const STATE_TYPE:String = "stateReason";
		
		protected var container:Sprite;
		private var bg:Shape;
		private var userName:Bitmap;
		private var selectFlowerText:Bitmap;
		private var title:Bitmap;
		private var acceptButton:BitmapButton;
		private var avatar:CircleAvatar;
		private var userModel:UserVO;
		private var avatarSize:int;
		private var accountText:Bitmap;
		private var backButton:BitmapButton;
		private var selectorDebitAccont:DDAccountButton;
		private var screenLocked:Boolean;
		private var currentState:String = STATE_TYPE;
		private var verticalMargin:Number;
		private var walletSelected:Boolean;
		private var selectedAccount:Object;
		private var resultAccount:String;
		private var newAmount:Number;
		private var footer:Bitmap;
		private var finishFooterMask:Sprite;
		private var lockedAmount:Boolean = false;
		private var receiverSecret:Boolean;
		private var accountBitmapDataPosition:Point;
		private var balanceFooterBDPosition:Point;
		private var scrollPanel:ScrollPanel;
		private var daysTitle:Bitmap;
		private var selectorDays:DDFieldButton;
		private var incognitoSwitcher:OptionSwitcher;
		private var resultAmountText:Bitmap;
		private var resultAmountTitle:Bitmap;
		private var durationCollection:Array;
		private var reasonsList:SlideSelector;
		private var lastSelectedReason:SelectorItemData;
		private var currentRequestId:String;
		private var finishImage:Bitmap;
		private var finishImageMask:Sprite;
		private var config:FlowersConfig;
		private var currentSelectedFlower:int = -1;
		protected var componentsWidth:int;
		private var horizontalLoader:HorizontalPreloader;
		private var needShowWallets:Boolean;
		private var accountExist:Boolean;
		
		public function PutUserExtensionPopup() {
			
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
			
			avatarSize = Config.FINGER_SIZE;
			
			avatar = new CircleAvatar(true);
			container.addChild(avatar);
			
			userName = new Bitmap();
			container.addChild(userName);
			
			selectFlowerText = new Bitmap();
			container.addChild(selectFlowerText);
			
			scrollPanel = new ScrollPanel();
			container.addChild(scrollPanel.view);
			
			title = new Bitmap();
			scrollPanel.addObject(title);
			
			daysTitle = new Bitmap();
			scrollPanel.addObject(daysTitle);
			
			selectorDays = new DDFieldButton(selectDays);
			selectorDays.setSize(Config.FINGER_SIZE * 1.4, Config.FINGER_SIZE * .8);
			scrollPanel.addObject(selectorDays);
			
			incognitoSwitcher = new OptionSwitcher();
			incognitoSwitcher.onSwitchCallback = onIncognitoChanged;
			scrollPanel.addObject(incognitoSwitcher);
			
			accountText = new Bitmap();
			scrollPanel.addObject(accountText);
			
			resultAmountTitle = new Bitmap();
			scrollPanel.addObject(resultAmountTitle);
			
			resultAmountText = new Bitmap();
			scrollPanel.addObject(resultAmountText);
			
			footer = new Bitmap();
			container.addChild(footer);
			
			finishFooterMask = new Sprite();
			container.addChild(finishFooterMask);
			
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
			
			finishImage = new Bitmap();
			container.addChild(finishImage);
			
			finishImageMask = new Sprite();
			container.addChild(finishImageMask);
			
			selectorDebitAccont = new DDAccountButton(openWalletSelector);
			scrollPanel.addObject(selectorDebitAccont);
			
			horizontalLoader = new HorizontalPreloader(0xF6951D);
			container.addChild(horizontalLoader);
			
			_view.addChild(container);
		}
		
		private function onIncognitoChanged(selected:Boolean):void {
			//!TODO:пиздец;
			incognitoSwitcher.isSelected = selected;
			updateAmount();
		}
		
		public function getDays():int {
			if (selectorDays != null) {
				var days:int = int(selectorDays.value);
				if (days > 0){
					return days;
				}
			}
			return 0;
		}
		
		private function updateAmount():void {
			drawPrice();
		}
		
		private function selectDays(e:Event = null):void {
			if (durationCollection == null) {
				durationCollection = [];
				durationCollection.push("1 " + Lang.textDay);
				durationCollection.push("2 " + Lang.days);
				durationCollection.push("3 " + Lang.days);
				durationCollection.push("4 " + Lang.days);
				durationCollection.push("5 " + Lang.days);
				durationCollection.push("6 " + Lang.days);
				durationCollection.push("7 " + Lang.days);
			}
			
			DialogManager.showDialog(ScreenPayDialog, {callback: callBackSelectDays, data: durationCollection, itemClass: ListPayCurrency, label: Lang.setFlowerDuration});
		}
		
		private function callBackSelectDays(value:String):void {
			if (isDisposed) {
				return;
			}
			if (durationCollection != null){
				var index:int = durationCollection.indexOf(value);
				if (index != -1){
					drawDaysSelector(index + 1);
				}
			}
			updateAmount();
		}
		
		static private function createPaymentsAccount(val:int):void {
			if (val != 1) {
				return;
			}
			MobileGui.showRoadMap();
		}
		
		private function openWalletSelector(e:Event = null):void {
			if (PayManager.accountInfo != null)
				return;
			PaymentsManager.updateAccount();
		}
		
		private function onPaymentsError(errorCode:String = null, errorMessage:String = null):void 
		{
			if (isDisposed)
			{
				return;
			}
			
			needShowWallets = false;
			hidePreloader();
			
			if (Auth.bank_phase != "ACC_APPROVED")
			{
				ServiceScreenManager.closeView();
				
				var popupData:PopupData;
				var action:IScreenAction;
				
				popupData = new PopupData();
				action = new OpenBankAccountAction();
				action.setData(Lang.openBankAccount);
				popupData.action = action;
				popupData.illustration = JailedIllustrationClip;
				popupData.title = Lang.noBankAccount;
				popupData.text = Lang.needPaymentsAccount;
				ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, BottomPopupScreen, popupData);
			}
		}
		
		private function onAccountInfo():void {
			
			accountExist = true;
			
			if (isDisposed)
			{
				return;
			}
			
			if (currentState != STATE_RESULT)
			{
				setDefaultWallet();
			}
			else
			{
				redrawFinalAmount();
			}
		}
		
		private function redrawFinalAmount():void 
		{
			var currentAccount:Object = getDefaultAccount();
			
			if (currentAccount != null && currentAccount.ACCOUNT_NUMBER == selectedAccount.ACCOUNT_NUMBER) {
				resultAccount = selectedAccount.ACCOUNT_NUMBER;
				newAmount = Number(currentAccount.BALANCE);
				if (footer != null && footer.bitmapData != null) {
					var accountDB:ImageBitmapData = TextUtils.createTextFieldData("** " + resultAccount.substr(resultAccount.length - 4), _width - Config.DIALOG_MARGIN, 10, false, TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * 0.35, false, 0xAAB8C5, 0xFBFBFB);
					
					footer.bitmapData.copyPixels(accountDB, new Rectangle(0, 0, accountDB.width, accountDB.height), accountBitmapDataPosition, null, null, true);
					accountDB.dispose();
					accountDB = null;
					
					var balance:Number = newAmount;
					balance = Math.floor(balance * 100) / 100;
					
					var newBalanceBD:ImageBitmapData = TextUtils.createTextFieldData(getAccountCurrency(selectedAccount) + " " + balance.toString(), _width - Config.DIALOG_MARGIN, 10, false, TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * 0.25, false, 0xAAB8C5, 0xFBFBFB);
					balanceFooterBDPosition = new Point(int(_width - Config.DIALOG_MARGIN - newBalanceBD.width), int(Config.DIALOG_MARGIN + Config.FINGER_SIZE * .5));
					
					footer.bitmapData.copyPixels(newBalanceBD, new Rectangle(0, 0, newBalanceBD.width, newBalanceBD.height), balanceFooterBDPosition, null, null, false);
					newBalanceBD.dispose();
					newBalanceBD = null;
				}
			}
		}
		
		private function getAccountCurrency(account:Object):String 
		{
			if (account != null)
			{
				if ("COIN" in account && account.COIN != null)
				{
					if (Lang[account.COIN] != null)
					{
						return Lang[account.COIN];
					}
					else
					{
						return account.COIN;
					}
				}
			}
			return "";
		}
		
		private function getDefaultAccount():Object {
			if (PayManager.accountInfo == null)
				return null;
			var currencyNeeded:String = TypeCurrency.DCO;
			var wallets:Array = PayManager.accountInfo.coins;
			if (wallets == null)
				return null;
			var l:int = wallets.length;
			var walletItem:Object;
			if (wallets != null) {
				for (var i:int = 0; i < l; i++) {
					walletItem = wallets[i];
					if (currencyNeeded == walletItem.COIN) {
						return walletItem;
						break;
					}
				}
			}
			return null;
		}
		
		private function onDataReady():void {
			hidePreloader();
			if (_isDisposed == true) {
				return;
			}
			
			if (needShowWallets) {
				needShowWallets = false;
				DialogManager.showDialog(
					ScreenPayDialog,
					{
						callback: onWalletSelect, 
						data: PayManager.accountInfo.accountsAll, 
						itemClass: ListPayWalletItem, 
						label: Lang.TEXT_SELECT_ACCOUNT
					}
				);
			}
		}
		
		private function selectBigAccount():void {
			var wallets:Array = PayManager.accountInfo.accountsAll;
			var l:int = wallets.length;
			var bigAccount:Object;
			if (wallets != null && wallets.length > 0) {
				bigAccount = wallets[0];
			}
			for (var i:int = 0; i < l; i++) {
				if (Number(bigAccount.BALANCE) < Number(wallets[i].BALANCE))
					bigAccount = wallets[i];
			}
			if (bigAccount != null)
				onWalletSelect(bigAccount);
		}
		
		private function showWalletsDialog():void {
			DialogManager.showDialog(ScreenPayDialog, {callback: onWalletSelect, data: PayManager.accountInfo.accountsAll, itemClass: ListPayWalletItem/*ListPayAccount*/, label: Lang.TEXT_SELECT_ACCOUNT});
		}
		
		private function showPreloader():void {
			horizontalLoader.start();
		}
		
		private function onWalletSelect(account:Object):void {
			if (account == null) return;
			walletSelected = true;
			
			selectedAccount = account;
			selectorDebitAccont.setValue(account);
			
			acceptButton.activate();
			acceptButton.alpha = 1;
			
			drawAccountText("");
		}
		
		private function getAmount():Number {
			var amount:Number;
			if (config != null && config.getFlowerData(getSelectedFlower()) != null) {
				
				amount = getDays() * config.getFlowerData(getSelectedFlower()).pricePerDay;
				
				if (incognitoSwitcher.isSelected == true) {
					amount = amount * 2;
				}
			}
			else{
				amount = NaN;
			}
			amount = Math.round(amount * 10000) / 10000;
			return amount;
		}
		
		private function getSelectedFlower():int 
		{
			return (reasonsList.getSelected().data as Extension).getProductId();
		}
		
		private function getCurrency():String {
			var currency:String;
			if (config != null) {
				currency = config.getFlowerData(getSelectedFlower()).currency;
			}
			else{
				currency = TypeCurrency.EUR;
			}
			return currency;
		}
		
		override public function onBack(e:Event = null):void {
			if (screenLocked == false) {
				if (currentState == STATE_TYPE) {
					ServiceScreenManager.closeView();
				}
				else if (currentState == STATE_RESULT)
				{
					
				}
				else {
					toState(STATE_TYPE);
				}
			}
		}
		
		private function backClick():void {
			onBack();
		}
		
		private function nextClick():void {
			if (currentState == STATE_TYPE) {
				toState(STATE_GENERAL);
			}
			else if (currentState == STATE_GENERAL) {
				if (isNextButtonAvaliable() && selectedAccount != null) {
					
					lockScreen();
					TweenMax.to(scrollPanel.view, 0.2, {alpha:0.4});
					TweenMax.to(selectFlowerText, 0.2, {alpha:0.4});
					
					UserExtensionsManager.S_ADD_EXTENSION_RESPONSE.add(onRequestBanResponse);
					currentRequestId = Math.random().toString();
					var request:ExtensionRequestData = new ExtensionRequestData(currentRequestId);
					request.extension = reasonsList.getSelected().data as Extension;
					request.extension.incognito = incognitoSwitcher.isSelected;
					request.wallet = selectedAccount.ACCOUNT_NUMBER;
					request.duration = getDuration();
					request.userUID = userModel.uid;
					if (request.duration == null)
					{
						ApplicationErrors.add();
					}
					UserExtensionsManager.buyExtension(request);
				}
			}
			else if (currentState == STATE_RESULT) {
				ServiceScreenManager.closeView();
			}
		}
		
		private function getDuration():SubscriptionDuration 
		{
			var type:SubscriptionDurationType;
			var days:int = getDays();
			switch(days)
			{
				case 1:
				{
					type = new SubscriptionDurationType(SubscriptionDurationType.DAY);
					break;
				}
				case 2:
				{
					type = new SubscriptionDurationType(SubscriptionDurationType.DAY_2);
					break;
				}
				case 3:
				{
					type = new SubscriptionDurationType(SubscriptionDurationType.DAY_3);
					break;
				}
				case 4:
				{
					type = new SubscriptionDurationType(SubscriptionDurationType.DAY_4);
					break;
				}
				case 5:
				{
					type = new SubscriptionDurationType(SubscriptionDurationType.DAY_5);
					break;
				}
				case 6:
				{
					type = new SubscriptionDurationType(SubscriptionDurationType.DAY_6);
					break;
				}
				case 7:
				{
					type = new SubscriptionDurationType(SubscriptionDurationType.WEEK);
					break;
				}
			}
			if (type != null)
			{
				return new SubscriptionDuration(type);
			}
			else
			{
				ApplicationErrors.add();
			}
			return null;
		}
		
		private function onRequestBanResponse(success:Boolean, requestId:String = null, errorMessage:String = null, taskCanBeRequestedAgain:Boolean = true):void {
			if (isDisposed)
				return;
			
			if (currentRequestId != null && requestId != currentRequestId) {
				return;
			}
			
			if (taskCanBeRequestedAgain == true) {
				
				//TODO: remove signal
				
				unlockScreen();
				if (success == false) {
					if (errorMessage != null) {
						ToastMessage.display(errorMessage);
					}
					
					TweenMax.to(scrollPanel.view, 0.3, {alpha:1});
					TweenMax.to(selectFlowerText, 0.3, {alpha:1});
				}
				else {
					toState(STATE_RESULT);
				}
			}
			else {
				UserExtensionsManager.onFailedFinishRequest(ShopServerTask.BUY_EXTENSION_PRODUCT);
				DialogManager.alert(Lang.textError, Lang.somethingWentWrong);
				ServiceScreenManager.closeView();
			}
		}
		
		private function showTypesPage():void {
			toState(STATE_TYPE);
		}
		
		override public function clearView():void {
			super.clearView();
		}
		
		private function toState(newState:String):void {
			
			var oldState:String = currentState;
			currentState = newState;
			
			screenLocked = true;
			
			acceptButton.deactivate();
			backButton.deactivate();
			
			var hideTime:Number = 0.3;
			var showTime:Number = 0.3;
			var position:int;
			var currency:String = "€";
			
			TweenMax.delayedCall(hideTime + showTime, activateButtons);
			
			if (newState == STATE_GENERAL) {
				currentSelectedFlower = reasonsList.getSelectedIndex();
				TweenMax.delayedCall(hideTime, hideElemetsFromState, [oldState]);
				
				if (reasonsList != null) {
					TweenMax.to(reasonsList, hideTime, {alpha: 0});
				}
				TweenMax.to(selectFlowerText, hideTime, {alpha: 0});
				
				scrollPanel.view.visible = true;
				scrollPanel.view.alpha = 0;
				scrollPanel.enable();
				
				TweenMax.to(selectFlowerText, showTime, {delay: hideTime, alpha: 1});
				TweenMax.to(scrollPanel.view, showTime, {delay: hideTime, alpha: 1});
				
				updateAmount();
			}
			else if (newState == STATE_RESULT) {
				
				var resizeTime:Number = 0.8;
				
				backButton.deactivate();
				
				TweenMax.to(backButton, hideTime, {alpha: 0});
				TweenMax.to(acceptButton, hideTime, {alpha: 0});
				TweenMax.to(reasonsList, hideTime, {alpha: 0});
				TweenMax.to(selectFlowerText, hideTime, {alpha: 0});
				TweenMax.delayedCall(hideTime, hideElemetsFromState, [oldState]);
				
				var finishImageHeight:int = Config.FINGER_SIZE * 1.6 + avatarSize;
				var bd:ImageBitmapData = new ImageBitmapData("CreateGiftPopup.finishImage", _width, finishImageHeight);
				var finishImageClip:Sprite = new Sprite();
				
				var matrix:Matrix = new Matrix();
				matrix.createGradientBox(_width, finishImageHeight, Math.PI / 2);
				finishImageClip.graphics.beginGradientFill(GradientType.LINEAR, [0x91A3AD, 0x91A3AD], [1, 1], [0x00, 0xFF], matrix);
				finishImageClip.graphics.drawRect(0, 0, _width, finishImageHeight);
				
				var finishIcon:DoneRoundIcon = new DoneRoundIcon();
				UI.scaleToFit(finishIcon, Config.FINGER_SIZE*.7, Config.FINGER_SIZE*.7);
				finishImageClip.addChild(finishIcon);
				finishIcon.x = int(_width * .5 - finishIcon.width * .5);
				finishIcon.y = Config.FINGER_SIZE * .3;
				
				bd.draw(finishImageClip);
				
				var thanksText:ImageBitmapData = TextUtils.createTextFieldData(Lang.flowerSent, _width - Config.DIALOG_MARGIN, 10, false, TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * 0.27, false, 0xFFFFFF, 0x999999, true);
				
				bd.copyPixels(thanksText, new Rectangle(0, 0, thanksText.width + 100, thanksText.height), new Point(int(_width * .5 - thanksText.width * .5), int(Config.FINGER_SIZE * 1.2)), null, null, true);
				thanksText.dispose();
				thanksText = null;
				
				finishImage.bitmapData = bd;
				
				finishImageMask.graphics.clear();
				finishImageMask.graphics.beginFill(0, 1);
				finishImageMask.graphics.drawRect(0, 0, _width, finishImageHeight);
				finishImage.mask = finishImageMask;
				finishImageMask.height = 0;
				container.setChildIndex(finishImage, 0);
				container.setChildIndex(bg, 0);
				
				finishImageMask.y = finishImage.y = avatarSize;
				
				var verticalMargin:int = Config.MARGIN * 1.5;
				
				position = verticalMargin + avatarSize * 2;
				position += userName.height;
				
				if (userModel.login != null)
				{
					position += verticalMargin * .5;
					position += selectFlowerText.height;
				}
				position += verticalMargin * 3;
				
				position += Config.FINGER_SIZE * 2;
				
				position += acceptButton.height + verticalMargin * 1.8;
				
				var newBackHight:int = position - avatarSize;
				
				var bdFooter:ImageBitmapData = new ImageBitmapData("CreateGiftPopup.footer", _width, Config.FINGER_SIZE * 2.5);
				
				var accountClip:Sprite = new Sprite();
				
				var logoClip:IconLogo = new IconLogo();
				UI.scaleToFit(logoClip, Config.FINGER_SIZE * .35, Config.FINGER_SIZE * .35);
				logoClip.alpha = 0.6;
				
				accountClip.graphics.beginFill(0xFBFBFB);
				accountClip.graphics.drawRect(0, 0, _width, bdFooter.height);
				accountClip.graphics.endFill();
				
				accountClip.addChild(logoClip);
				logoClip.x = Config.DIALOG_MARGIN;
				logoClip.y = Config.DIALOG_MARGIN;
				
				bdFooter.draw(accountClip);
				UI.destroy(accountClip);
				accountClip = null;
				
				accountBitmapDataPosition = new Point(int(logoClip.x + logoClip.width + Config.MARGIN), int(Config.DIALOG_MARGIN));
				
				var accountNumber:String;
				if (selectedAccount != null) {
					accountNumber = selectedAccount.IBAN;
				} else if (resultAccount != null) {
					accountNumber = resultAccount;
				}
				
				if (accountNumber) {
					var accountDB:ImageBitmapData = TextUtils.createTextFieldData("** " + accountNumber.substr(accountNumber.length - 4), _width - Config.DIALOG_MARGIN, 10, false, TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * 0.35, false, 0xAAB8C5, 0xFBFBFB);
					
					bdFooter.copyPixels(accountDB, new Rectangle(0, 0, accountDB.width, accountDB.height), accountBitmapDataPosition, null, null, true);
					accountDB.dispose();
					accountDB = null;
				}
				
				UI.destroy(logoClip);
				logoClip = null;
				
				currency = "€";
				
				var minus:Number = getAmount();
				minus = Math.floor(minus * 100) / 100;
				
				var payValueBD:ImageBitmapData = TextUtils.createTextFieldData("-" + getCoinCurrency() + " " + minus.toString(), _width - Config.DIALOG_MARGIN, 10, false, TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * 0.4, false, 0xEAA6A7, 0xFBFBFB);
				
				bdFooter.copyPixels(payValueBD, new Rectangle(0, 0, payValueBD.width, payValueBD.height), new Point(int(_width - Config.DIALOG_MARGIN - payValueBD.width), int(Config.DIALOG_MARGIN)), null, null, true);
				payValueBD.dispose();
				payValueBD = null;
				
				if (!isNaN(newAmount)) {
					var balance:Number = newAmount;
					balance = Math.floor(balance * 100) / 100;
					var newBalanceBD:ImageBitmapData = TextUtils.createTextFieldData(selectedAccount.CURRENCY + " " + balance.toString(), _width - Config.DIALOG_MARGIN, 10, false, TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * 0.25, false, 0xAAB8C5, 0xFBFBFB);
					balanceFooterBDPosition = new Point(int(_width - Config.DIALOG_MARGIN - newBalanceBD.width), int(Config.DIALOG_MARGIN + Config.FINGER_SIZE * .5));
					
					
					bdFooter.copyPixels(newBalanceBD, new Rectangle(0, 0, newBalanceBD.width, newBalanceBD.height), balanceFooterBDPosition, null, null, true);
					newBalanceBD.dispose();
					newBalanceBD = null;
				}
				
				finishFooterMask.graphics.beginFill(0xFBFBFB);
				finishFooterMask.graphics.drawRect(0, 0, _width, bdFooter.height);
				finishFooterMask.graphics.endFill();
				
				footer.mask = finishFooterMask;
				footer.bitmapData = bdFooter;
				footer.y = int(bg.y + bg.height - finishFooterMask.height);
				
				finishFooterMask.y = bg.y + bg.height;
				
				TweenMax.to(finishImageMask, resizeTime, {height: finishImageHeight, delay: hideTime, onUpdate: repositionElements, ease: Power3.easeInOut});
				TweenMax.to(finishFooterMask, resizeTime, {y: bg.y + bg.height - finishFooterMask.height, delay: hideTime, ease: Power3.easeInOut});
				TweenMax.to(acceptButton, showTime, {alpha: 1, delay: (hideTime), onComplete: activateAcceptButton, onStart: repositionAcceptButton});
				
				onAccountInfo();
			}
			else if (newState == STATE_TYPE) {
			//	acceptButton.alpha = 0.5;
			//	acceptButton.deactivate();
				TweenMax.to(scrollPanel.view, hideTime, {alpha: 0});
				TweenMax.delayedCall(hideTime, hideElemetsFromState, [oldState]);
				
				
				TweenMax.to(selectFlowerText, hideTime, {alpha: 0});
				TweenMax.to(selectFlowerText, showTime, {delay: hideTime, alpha: 1});
				
				
				if (reasonsList == null) {
					reasonsList = new SlideSelector();
					container.addChild(reasonsList);
					reasonsList.x = int(Config.DIALOG_MARGIN * 1.5);
				}
				
				reasonsList.setData(getFlowers(), componentsWidth - Config.DIALOG_MARGIN, scrollPanel.height);
				reasonsList.select(currentSelectedFlower);
				reasonsList.alpha = 0;
				reasonsList.y = scrollPanel.view.y;
				if (isActivated) {
					reasonsList.activate();
				}
				reasonsList.visible = true;
				reasonsList.alpha = 0;
				TweenMax.to(reasonsList, showTime, {alpha:1, delay:hideTime});
			}
		}
		
		private function getFlowers():Vector.<SlideSelectorItemData> 
		{
			var result:Vector.<SlideSelectorItemData> = new Vector.<SlideSelectorItemData>();
			
			var types:Vector.<Extension> = UserExtensionsManager.getExtensions(UserExtensionsManager.FLOWERS);
			if (types != null)
			{
				var l:int = types.length;
				for (var i:int = 0; i < l; i++) 
				{
					result.push(new SlideSelectorItemData(types[i]));
				}
			}
			return result;
		}
		
		private function repositionElements():void {
			avatar.y = finishImageMask.height;
			userName.y = avatar.y + verticalMargin + avatarSize * 2;
		}
		
		private function activateButtons():void {
			screenLocked = false;
			activateBackButton();
			activateAcceptButton();
			if (currentState == STATE_GENERAL) {
				scrollPanel.enable();
			}
			else if (currentState == STATE_TYPE) {
				if (reasonsList != null) {
					reasonsList.activate();
				}
			}
		}
		
		private function activateBackButton():void {
			if (isDisposed)
				return;
			
			if (backButton != null && isActivated)
				backButton.activate();
		}
		
		private function repositionAcceptButton():void {
			drawAcceptButton(Lang.done);
			acceptButton.y = int(bg.height - Config.MARGIN * 1.5 * 1.8 - acceptButton.height + avatarSize);
			acceptButton.x = int(_width * .5 - acceptButton.width * .5);
		}
		
		private function hideElemetsFromState(state:String):void {
			if (state == STATE_GENERAL)	{
				scrollPanel.disable();
				scrollPanel.view.visible = false;
				drawFlowersTitle(Lang.selectFlower);
				if (currentState == STATE_RESULT)
				{
					backButton.visible = false;
				}
			}
			else if (state == STATE_TYPE) {
				drawFlowersTitle(Lang.sendFlower);
				if (currentState == STATE_GENERAL) {
					drawAcceptButton(Lang.textNext);
					acceptButton.visible = true;
					backButton.visible = true;
					
					if (reasonsList != null) {
						reasonsList.deactivate();
						reasonsList.visible = false;
					}
				}
				else {
					backButton.deactivate();
					backButton.visible = false;
					reasonsList.visible = false;
				}
			}
		}
		
		private function activateAcceptButton():void {
			if (isDisposed)
				return;
			
			if (acceptButton != null && isActivated) {
				acceptButton.activate();
				acceptButton.alpha = 1;
			}
		}
		
		private function drawAvatar():void {
			var avatarUrl:String = userModel.getAvatarURLProfile(avatarSize * 2);
			//!TODO: инкогнито
			avatar.x = int(_width * .5 - avatarSize);
			avatar.setData(userModel, avatarSize, false, false, avatarUrl);
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			if (data != null && "user" in data && data.user != null && data.user is UserVO) {
				userModel = data.user as UserVO;
			}
			
			if (userModel == null) {
				ServiceScreenManager.closeView();
				ApplicationErrors.add("empty userModel");
				return;
			}
			
			verticalMargin = Config.MARGIN * 1.5;
			componentsWidth = _width - Config.DIALOG_MARGIN * 2;
			
			drawAvatar();
			drawUserName();
			drawFlowersTitle(Lang.selectFlower);
		//	drawTitle();
			drawDaysSelector(1);
			drawIncognitoSelector();
			drawPrice();
			drawAccountSelector();
			drawAccountText(Lang.chooseAccount);
			drawAcceptButton(Lang.textNext);
			drawBackButton();
			
			if (reasonsList == null) {
				reasonsList = new SlideSelector();
				container.addChild(reasonsList);
				reasonsList.x = int(Config.DIALOG_MARGIN * 1.5);
			}
			
			config = UserExtensionsManager.getFlowersConfig();
			
			drawView();
			reasonsList.setData(getFlowers(), componentsWidth - Config.DIALOG_MARGIN, scrollPanel.height);
			reasonsList.select(currentSelectedFlower);
			reasonsList.y = scrollPanel.view.y;
			
			scrollPanel.view.visible = false;
			
			horizontalLoader.setSize(_width, int(Config.FINGER_SIZE * .07));
			
			PaymentsManager.S_ACCOUNT.add(onAccountInfo);
			PaymentsManager.S_ERROR.add(onPayError);
			if (PaymentsManager.activate() == false && PayManager.accountInfo != null)
				onAccountInfo();
			
			if (config != null) {
				acceptButton.activate();
			} else {
				
				lockScreen();
				UserExtensionsManager.S_UPDATED.add(onConfigReady);
			}
		}
		
		private function onPayError(code:String = null, message:String = null):void {
			if (code == PaymentsManager.NO_ACC) {
				TweenMax.delayedCall(1, function():void {
					DialogManager.alert(
						Lang.information,
						Lang.needPaymentsAccount,
						createPaymentsAccount,
						Lang.textOk,
						Lang.textCancel
					);
				});
			}
			unlockScreen();
		}
		
		private function lockScreen():void {
			screenLocked = true;
			showPreloader();
			deactivateScreen();
		}
		
		private function unlockScreen():void {
			screenLocked = false;
			hidePreloader();
			activateScreen();
		}
		
		private function onConfigReady(success:Boolean):void {
			if (!isDisposed) {
				unlockScreen();
				if (success == true) {
					config = UserExtensionsManager.getFlowersConfig();
					if (config != null) {
						updateAmount();
					}
				}
			}
		}
		
		private function drawPrice():void 
		{
			if (resultAmountTitle.bitmapData != null) {
				resultAmountTitle.bitmapData.dispose();
				resultAmountTitle.bitmapData = null;
			}
			resultAmountTitle.x = 4;
			resultAmountTitle.bitmapData = TextUtils.createTextFieldData(Lang.totalPrice.toUpperCase() + ":", componentsWidth - Config.FINGER_SIZE*3, 10, 
															true, TextFormatAlign.LEFT, 
															TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .3, 
															true, 0x1C2935, 0xFFFFFF);
			
			if (resultAmountText.bitmapData != null) {
				resultAmountText.bitmapData.dispose();
				resultAmountText.bitmapData = null;
			}
			
			if (!isNaN(getAmount())) {
				var currencyString:String = getCoinCurrency();
				if (currencyString == TypeCurrency.EUR) {
					currencyString = "€";
				}
				resultAmountText.bitmapData = TextUtils.createTextFieldData(getAmount().toString() + " " + currencyString, Config.FINGER_SIZE*3, 10, 
																			true, TextFormatAlign.LEFT, 
																			TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .3, 
																			true, 0x1C2935, 0xFFFFFF);
				resultAmountText.x = int(componentsWidth - resultAmountText.width);
			}
		}
		
		private function getCoinCurrency():String 
		{
			var result:String = getRealCurrency();
			if (Lang[result] != null)
			{
				return Lang[result];
			}
			else
			{
				return result;
			}
		}
		
		private function getRealCurrency():String 
		{
			var currency:String =  "€";
			if (ConfigManager.config != null && ConfigManager.config.innerCurrency != TypeCurrency.EUR) {
				currency = ConfigManager.config.innerCurrency;
			}
			return currency;
		}
		
		private function drawDaysSelector(value:int):void {
			selectorDays.setValue(value.toString());
			
			if (daysTitle.bitmapData != null) {
				daysTitle.bitmapData.dispose();
				daysTitle.bitmapData = null;
			}
			daysTitle.x = 4;
			daysTitle.bitmapData = TextUtils.createTextFieldData(Lang.days, componentsWidth, 10, 
															true, TextFormatAlign.LEFT, 
															TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .3, 
															true, 0x1C2935, 0xFFFFFF);
		}
		
		private function drawIncognitoSelector():void {
			incognitoSwitcher.create(componentsWidth, Config.FINGER_SIZE * .8, null, Lang.keepMeIncognito, false, true, -1, NaN, 0);
		}
		
		private function hidePreloader():void {
			horizontalLoader.stop();
		}
		
		private function setDefaultWallet():void {
			var defaultAccount:Object = getDefaultAccount();
			
			if (defaultAccount != null) {
				onWalletSelect(defaultAccount);
			} else {
				DialogManager.alert(Lang.information, "You do not have Dukascoins account. Please create it before buy some features.");
			}
		}
		
		private function drawAccountSelector():void {
			selectorDebitAccont.setSize(componentsWidth, Config.FINGER_SIZE * .8);
			selectorDebitAccont.setValue(Lang.walletToCharge);
		}
		
		private function drawAcceptButton(text:String):void {
			var textSettings:TextFieldSettings = new TextFieldSettings(text, 0xFFFFFF, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, 0x78C043, 1, Config.FINGER_SIZE * .8, NaN, (componentsWidth - Config.DIALOG_MARGIN) * .5);
			acceptButton.setBitmapData(buttonBitmap, true);
			acceptButton.x = int(acceptButton.width + Config.DIALOG_MARGIN * 2);
			
			acceptButton.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
		}
		
		private function drawBackButton():void {
			var textSettings:TextFieldSettings = new TextFieldSettings(Lang.textBack, 0, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, 0x78C043, 0, Config.FINGER_SIZE * .8, NaN, (componentsWidth - Config.DIALOG_MARGIN) * .5);
			backButton.setBitmapData(buttonBitmap, true);
			backButton.x = Config.DIALOG_MARGIN;
			
			backButton.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
		}
		
		private function drawAccountText(text:String):void {
			if (accountText.bitmapData != null) {
				accountText.bitmapData.dispose();
				accountText.bitmapData = null;
			}
			accountText.bitmapData = TextUtils.createTextFieldData(text, componentsWidth, 10, true, TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .27, true, 0xABB8C1, 0xffffff, false);
		
			accountText.x = int(componentsWidth * .5 - accountText.width * .5);
		}
		
		private function drawFlowersTitle(value:String):void {
			if (selectFlowerText.bitmapData != null) {
				selectFlowerText.bitmapData.dispose();
				selectFlowerText.bitmapData = null;
			}
			
			selectFlowerText.bitmapData = TextUtils.createTextFieldData(
																	value, componentsWidth, 
																	10, false, TextFormatAlign.CENTER, 
																	TextFieldAutoSize.LEFT, 
																	Config.FINGER_SIZE * .36, 
																	false, 0x6B757E, 
																	0xffffff, false);
			selectFlowerText.x = int(_width * .5 - selectFlowerText.width * .5);
		}
		
		private function drawUserName():void {
			var userNameText:String;
			if (receiverSecret == true)	{
				userNameText = Lang.textIncognito;
			}
			else {
				userNameText = userModel.getDisplayName();
			}
			
			if (userName.bitmapData != null) {
				userName.bitmapData.dispose();
				userName.bitmapData = null;
			}
			
			userName.bitmapData = TextUtils.createTextFieldData(userNameText, componentsWidth, 10, false, TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .40, false, 0x3E4756, 0xffffff, false);
			
			userName.x = int(_width * .5 - userName.width * .5);
		}
		
		override protected function drawView():void {
			if (_isDisposed == true)
				return;
			
			bg.width = _width;
			
			var position:int;
			
			if (currentState != STATE_RESULT)
			{
				position = verticalMargin + avatarSize * 2;
				
				userName.y = position;
				position += userName.height;
				
				position += verticalMargin * 3;
				selectFlowerText.y = position;
				position += selectFlowerText.height;
				
				position += verticalMargin * .1;
				
				scrollPanel.view.y = position;
				scrollPanel.view.x = Config.DIALOG_MARGIN;
				
				var maxContentHeight:int = _height - position - acceptButton.height - verticalMargin * 1.8 * 2;
				var contentPosition:int = 0;
				
				title.y = contentPosition;
				contentPosition += title.height * .5 + Config.FINGER_SIZE * .4;
				
				selectorDays.y = contentPosition;
				selectorDays.x = int(componentsWidth - selectorDays.width);
				daysTitle.y = int(selectorDays.y + selectorDays.height * .5 - daysTitle.height * .5);
				contentPosition += Config.FINGER_SIZE * .8;
				
				incognitoSwitcher.y = contentPosition;
				contentPosition += Config.FINGER_SIZE * .8;
				
				resultAmountTitle.y = contentPosition + Config.FINGER_SIZE * .4 - resultAmountTitle.height * .5;
				resultAmountText.y = contentPosition + Config.FINGER_SIZE * .4 - resultAmountTitle.height * .5;
				contentPosition +=  Config.FINGER_SIZE * .8;
				
				selectorDebitAccont.y = contentPosition;
				contentPosition += selectorDebitAccont.height + verticalMargin * .6;
				
				accountText.y = contentPosition;
				contentPosition += accountText.height + verticalMargin * 2.7;
				
				scrollPanel.setWidthAndHeight(componentsWidth, Math.min(maxContentHeight, scrollPanel.itemsHeight));
				scrollPanel.update();
				position += scrollPanel.height + verticalMargin * 2;
				
				
				acceptButton.y = position;
				backButton.y = position;
				position += acceptButton.height + verticalMargin * 1.8;
				
				bg.height = position - avatarSize;
				
				horizontalLoader.y = bg.y + bg.height - horizontalLoader.height;
				
				bg.y = avatarSize;
				
				container.y = _height - position;
			}
		}
		
		private function isIncognito():Boolean {
			if (incognitoSwitcher != null) {
				return incognitoSwitcher.isSelected;
			}
			return false;
		}
		
		private function getReason():int {
			if (lastSelectedReason != null) {
				return lastSelectedReason.data as int;
			}
			return 0;
		}
		
		private function updateButtonsState():void {
			if (isNextButtonAvaliable()) {
				acceptButton.activate();
				acceptButton.alpha = 1;
			} else {
				acceptButton.alpha = 0.5;
				acceptButton.deactivate();
			}
		}
		
		override public function activateScreen():void
		{
			if (_isDisposed == true)
				return;
			
			super.activateScreen();
			
			if (screenLocked == true)
				return;
			
			updateButtonsState();
			
			if (backButton.visible && currentState != STATE_RESULT) {
				backButton.activate();
			}
			
			if (selectorDebitAccont.visible) {
				selectorDebitAccont.activate();
			}
			
			if (selectorDays != null && selectorDays.visible == true) {
				selectorDays.activate();
			}
			
			if (incognitoSwitcher != null && incognitoSwitcher.visible == true) {
				incognitoSwitcher.activate();
			}
			
			if (reasonsList != null) {
				reasonsList.activate();
			}
			
			scrollPanel.enable();
		}
		
		private function isNextButtonAvaliable():Boolean {
			if (currentState == STATE_GENERAL) {
				return (walletSelected == true);
			}
			else if (currentState == STATE_TYPE) {
				return true;
			}
			return true;
		}
		
		override public function deactivateScreen():void {
			if (_isDisposed == true)
				return;
			
			super.deactivateScreen();
			
			acceptButton.deactivate();
			backButton.deactivate();
			selectorDebitAccont.deactivate();
			
			if (selectorDays != null) {
				selectorDays.deactivate();
			}
			
			if (incognitoSwitcher != null) {
				incognitoSwitcher.deactivate();
			}
			
			if (reasonsList != null) {
				reasonsList.deactivate();
			}
			
			scrollPanel.disable();
		}
		
		override public function dispose():void {
			if (_isDisposed == true)
				return;
			super.dispose();
			
			PaymentsManager.deactivate();
			PaymentsManager.S_ACCOUNT.remove(onAccountInfo);
			PaymentsManager.S_ERROR.remove(onPayError);
			PaymentsManager.S_READY.remove(onDataReady);
			
			Overlay.removeCurrent();
			
			TweenMax.killDelayedCallsTo(hideElemetsFromState);
			TweenMax.killDelayedCallsTo(activateButtons);
			
			if (reasonsList != null) {
				TweenMax.killTweensOf(reasonsList);
			}
			
			TweenMax.killTweensOf(scrollPanel.view);
			TweenMax.killTweensOf(avatar);
			TweenMax.killTweensOf(finishFooterMask);
			TweenMax.killTweensOf(finishImageMask);
			TweenMax.killTweensOf(acceptButton);
			TweenMax.killTweensOf(backButton);
			TweenMax.killTweensOf(title);
			TweenMax.killTweensOf(daysTitle);
			TweenMax.killTweensOf(accountText);
			TweenMax.killTweensOf(selectorDebitAccont);
			
			if (scrollPanel != null) {
				scrollPanel.dispose();
				scrollPanel = null;
			}
			if (selectorDays != null) {
				selectorDays.dispose();
				selectorDays = null;
			}
			if (incognitoSwitcher != null) {
				incognitoSwitcher.dispose();
				incognitoSwitcher = null;
			}
			if (resultAmountText != null)	{
				UI.destroy(resultAmountText);
				resultAmountText = null;
			}
			if (resultAmountTitle != null)	{
				UI.destroy(resultAmountTitle);
				resultAmountTitle = null;
			}
			if (reasonsList != null) {
				reasonsList.dispose();
				reasonsList = null;
			}
			if (finishImage != null)	{
				UI.destroy(finishImage);
				finishImage = null;
			}
			if (footer != null)	{
				UI.destroy(footer);
				footer = null;
			}
			if (finishFooterMask != null) {
				UI.destroy(finishFooterMask);
				finishFooterMask = null;
			}
			if (finishImageMask != null)
			{
				UI.destroy(finishImageMask);
				finishImageMask = null;
			}
			if (selectorDebitAccont != null) {
				selectorDebitAccont.dispose();
				selectorDebitAccont = null;
			}
			if (backButton != null) {
				backButton.dispose();
				backButton = null;
			}
			if (accountText != null) {
				UI.destroy(accountText);
				accountText = null;
			}
			if (acceptButton != null) {
				acceptButton.dispose();
				acceptButton = null;
			}
			if (avatar != null) {
				avatar.dispose();
				avatar = null;
			}
			if (title != null) {
				UI.destroy(title);
				title = null;
			}
			if (daysTitle != null) {
				UI.destroy(daysTitle);
				daysTitle = null;
			}
			if (selectFlowerText != null) {
				UI.destroy(selectFlowerText);
				selectFlowerText = null;
			}
			if (userName != null) {
				UI.destroy(userName);
				userName = null;
			}
			if (bg != null) {
				UI.destroy(bg);
				bg = null;
			}
			if (container != null) {
				UI.destroy(container);
				container = null;
			}
			if (horizontalLoader != null)
			{
				horizontalLoader.dispose();
				horizontalLoader = null;
			}
			
			config = null;
			userModel = null;
			config = null;
			lastSelectedReason = null;
			durationCollection = null;
			selectedAccount = null;
			
			UserExtensionsManager.S_UPDATED.remove(onConfigReady);
			UserExtensionsManager.S_ADD_EXTENSION_RESPONSE.remove(onRequestBanResponse);
		}
	}
}