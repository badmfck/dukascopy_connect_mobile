package com.dukascopy.connect.screens.dialogs.paidBan 
{
	import assets.DoneRoundIcon;
	import assets.PaidBanCircleIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.data.paidBan.PaidBanReasons;
	import com.dukascopy.connect.data.paidBan.config.PaidBanConfig;
	import com.dukascopy.connect.gui.button.DDAccountButton;
	import com.dukascopy.connect.gui.chat.CircleAvatar;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.renderers.ListPayWalletItem;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.preloader.Preloader;
	import com.dukascopy.connect.gui.scrollPanel.ScrollPanel;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.dialogs.ScreenPayDialog;
	import com.dukascopy.connect.screens.payments.card.TypeCurrency;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.applicationShop.serverTask.ShopServerTask;
	import com.dukascopy.connect.sys.configManager.ConfigManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.payments.InvoiceManager;
	import com.dukascopy.connect.sys.payments.PayManager;
	import com.dukascopy.connect.sys.payments.PaymentsManager;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.usersManager.paidBan.PaidBan;
	import com.dukascopy.connect.utils.DateUtils;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.connect.vo.users.UserVO;
	import com.dukascopy.connect.vo.users.adds.UserBan911VO;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import com.greensock.easing.Power3;
	import fl.motion.Color;
	import flash.display.Bitmap;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	
	public class PaidUnbanUserPopup extends BaseScreen
	{
		static public const STATE_RESULT:String = "stateResult";
		static public const STATE_NEW:String = "stateNew";
		
		protected var container:Sprite;
		private var bg:Shape;
		private var userName:Bitmap;
		private var fxName:Bitmap;
		private var dateField:Bitmap;
		private var acceptButton:BitmapButton;
		private var avatar:CircleAvatar;
		private var userModel:UserVO;
		private var avatarSize:int;
		private var accountText:Bitmap;
		private var backButton:BitmapButton;
		private var selectorDebitAccont:DDAccountButton;
		private var preloader:Preloader;
		private var screenLocked:Boolean;
		private var currentState:String = STATE_NEW;
		private var verticalMargin:Number;
		private var walletSelected:Boolean;
		private var selectedAccount:Object;
		private var resultAccount:String;
		private var newAmount:Number;
		private var footer:Bitmap;
		private var finishFooterMask:Sprite;
		private var preloaderShown:Boolean = false;
		private var accountBitmapDataPosition:Point;
		private var balanceFooterBDPosition:Point;
		private var scrollPanel:ScrollPanel;
		private var resultAmountTitle:Bitmap;
		private var config:PaidBanConfig;
		private var banIcon:PaidBanCircleIcon;
		private var banInfoClip:Sprite;
		private var reason:Bitmap;
		private var payerName:Bitmap;
		private var banDataPreloader:Sprite;
		protected var componentsWidth:int;
		private var finishImage:Bitmap;
		private var finishImageMask:Sprite;
		private var banData:UserBan911VO;
		
		public function PaidUnbanUserPopup() {
			
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
			
			avatar = new CircleAvatar();
			container.addChild(avatar);
			
			userName = new Bitmap();
			container.addChild(userName);
			
			fxName = new Bitmap();
			container.addChild(fxName);
			
			scrollPanel = new ScrollPanel();
			container.addChild(scrollPanel.view);
			
			dateField = new Bitmap();
			scrollPanel.addObject(dateField);
			
			accountText = new Bitmap();
			scrollPanel.addObject(accountText);
			
			resultAmountTitle = new Bitmap();
			scrollPanel.addObject(resultAmountTitle);
			
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
			
			selectorDebitAccont = new DDAccountButton(openWalletSelector);
			scrollPanel.addObject(selectorDebitAccont);
			
			banInfoClip = new Sprite();
			scrollPanel.addObject(banInfoClip);
			
			banIcon = new PaidBanCircleIcon();
			UI.scaleToFit(banIcon, Config.FINGER_SIZE * .8, Config.FINGER_SIZE * .8);
			banInfoClip.addChild(banIcon);
			banIcon.x = Config.DIALOG_MARGIN
			banIcon.y = int(Config.FINGER_SIZE * .17);
			
			reason = new Bitmap();
			banInfoClip.addChild(reason);
			
			payerName = new Bitmap();
			banInfoClip.addChild(payerName);
			
			banDataPreloader = new Sprite();
			banInfoClip.addChild(banDataPreloader);
			
			finishImage = new Bitmap();
			container.addChild(finishImage);
			
			finishImageMask = new Sprite();
			container.addChild(finishImageMask);
			
			_view.addChild(container);
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
		
		private function showWalletsDialog():void {
			DialogManager.showDialog(ScreenPayDialog, {callback: onWalletSelect, data: PayManager.accountInfo.accountsAll, itemClass: ListPayWalletItem/*ListPayAccount*/, label: Lang.TEXT_SELECT_ACCOUNT});
		}
		
		private function showPreloader():void {
			preloaderShown = true;
			
			var color:Color = new Color();
			color.setTint(0xFFFFFF, 0.7);
			container.transform.colorTransform = color;
			
			if (preloader == null)
			{
				preloader = new Preloader();
			}
			preloader.x = _width * .5;
			preloader.y = _height * .5;
			view.addChild(preloader);
			preloader.show();
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
			if (config != null) {
				var days:int = 0;
				if (banData != null && !isNaN(banData.canceled)) {
					var date:Date = new Date();
					var difference:Number = banData.canceled*1000 - date.getTime();
					if (difference > 0) {
						days = Math.floor((difference / (1000 * 60 * 60)) / 24);
						if (days * 1000 * 60 * 60 < difference) {
							days ++;
						}
					}
				}
				return days;
			}
			return 0;
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
			if (currentState == STATE_NEW) {
				if (isNextButtonAvaliable() && selectedAccount != null) {
					// V sluchae esli sessija zalochena to mi sosnem s obrabotkoj-> nado chtob InvoiceManager.processInvoice(taskVO); bil vizvan 
					
					if (banData != null && banData.user_uid != null) {
						lockScreen();
						PaidBan.S_BAN_REMOVE_RESPONSE.add(onRequestUnbanResponse);
						PaidBan.processUnban(banData, selectedAccount.ACCOUNT_NUMBER);
					}
					else {
						ToastMessage.display(Lang.somethingWentWrong);
						onBack();
					}
				}
			}
			else if (currentState == STATE_RESULT) {
				InvoiceManager.stopProcessInvoice();
				ServiceScreenManager.closeView();
			}
		}
		
		private function onRequestUnbanResponse(success:Boolean, userUid:String = null, errorMessage:String = null, taskCanBeRequestedAgain:Boolean = true):void {
			if (isDisposed) {
				return;
			}
			
			if (userModel != null && userModel.uid != userUid) {
				return;
			}
			
			if (taskCanBeRequestedAgain) {
				PaidBan.S_BAN_REMOVE_RESPONSE.remove(onRequestUnbanResponse);
				unlockScreen();
				if (success == false) {
					if (errorMessage != null) {
						ToastMessage.display(errorMessage);
					}
				}
				else {
					toState(STATE_RESULT);
				}
			}
			else {
				PaidBan.onFailedFinishRequest(ShopServerTask.BUY_UNBAN);
				DialogManager.alert(Lang.textError, Lang.somethingWentWrong);
				onBack();
			}
		}
		
		private function onAccountInfo():void {
		//	PaymentsManager.S_ACCOUNT.remove(onAccountInfo);
			if (isDisposed == true)
				return;
			if (PayManager.accountInfo == null)
				return;
				
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
					
					footer.bitmapData.copyPixels(newBalanceBD, new Rectangle(0, 0, newBalanceBD.width, newBalanceBD.height), balanceFooterBDPosition, null, null, true);
					newBalanceBD.dispose();
					newBalanceBD = null;
				}
			}
		}
		
		private function getDefaultAccount():Object 
		{
			var currencyNeeded:String = TypeCurrency.DCO;
			var wallets:Array = PayManager.accountInfo.coins;
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
		
		override public function clearView():void
		{
			super.clearView();
			InvoiceManager.stopProcessInvoice();
		}
		
		private function toState(newState:String):void
		{
			var oldState:String = currentState;
			currentState = newState;
			
			screenLocked = true;
			
			acceptButton.deactivate();
			backButton.deactivate();
			
			var hideTime:Number = 0.3;
			var showTime:Number = 0.3;
			var position:int;
			var currency:String = "€";
			
			if (newState == STATE_NEW)
			{
				
			}
			else if (newState == STATE_RESULT)
			{
				avatar.update();
				
				TweenMax.to(backButton, hideTime, {alpha: 0});
				TweenMax.to(acceptButton, hideTime, {alpha: 0});
				TweenMax.to(scrollPanel.view, hideTime, {alpha: 0});
				TweenMax.to(fxName, hideTime, {alpha: 0});
				
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
				
				var thanksText:ImageBitmapData = TextUtils.createTextFieldData(Lang.banRemoved, _width - Config.DIALOG_MARGIN, 10, false, TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * 0.27, false, 0xFFFFFF, 0x999999, true);
				
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
					position += fxName.height;
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
				
				if (accountNumber != null) {
					
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
				
				if (!isNaN(newAmount)){
					var balance:Number = newAmount;
					balance = Math.floor(balance * 100) / 100;
					var newBalanceBD:ImageBitmapData = TextUtils.createTextFieldData(selectedAccount.COIN + " " + balance.toString(), _width - Config.DIALOG_MARGIN, 10, false, TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * 0.25, false, 0xAAB8C5, 0xFBFBFB);
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
				
				var resizeTime:Number = 0.8;
				TweenMax.to(finishFooterMask, resizeTime, {y: bg.y + bg.height - finishFooterMask.height, delay: hideTime, ease: Power3.easeInOut});
				TweenMax.to(finishImageMask, resizeTime, {height: finishImageHeight, delay: hideTime, onUpdate: repositionElements, ease: Power3.easeInOut});
				TweenMax.to(acceptButton, showTime, {alpha: 1, delay: (hideTime + resizeTime), onComplete: activateAcceptButton, onStart: repositionAcceptButton});
				
				onAccountInfo();
			}
		}
		
		private function repositionElements():void {
			avatar.y = finishImageMask.height;
			userName.y = avatar.y + verticalMargin + avatarSize * 2;
			
			if (userModel.login != null) {
				fxName.y = userName.height + userName.y + verticalMargin * .5;
			}
		}
		
		private function activateButtons():void {
			activateBackButton();
			activateAcceptButton();
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
			if (state == STATE_NEW)	{
				scrollPanel.view.visible = false;
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
			var avatarUrl:String = userModel.getAvatarURLProfile(avatarSize);
			//!TODO: инкогнито
			avatar.x = int(_width * .5 - avatarSize);
			avatar.setData(userModel, avatarSize);
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			InvoiceManager.isProcessingInvoice = true;
			
			if (data != null && "user" in data && data.user != null && data.user is UserVO) {
				userModel = data.user as UserVO;
			}
			
			if (userModel == null || userModel.ban911VO == null) {
				ServiceScreenManager.closeView();
				ApplicationErrors.add("empty userModel");
				return;
			}
			
			banData = userModel.ban911VO;
			
			config = PaidBan.getConfig();
			
			componentsWidth = _width - Config.DIALOG_MARGIN * 2;
			
			drawAvatar();
			drawUserName();
			drawFxName();
			drawBanData();
			drawExpireTime();
			drawPrice();
			drawAccountSelector();
			drawAccountText(Lang.chooseAccount);
			drawAcceptButton(Lang.textNext);
			acceptButton.deactivate();
			acceptButton.alpha = 0.5;
			
			drawBackButton();
			
			PaymentsManager.S_ACCOUNT.add(onAccountInfo);
			PaymentsManager.S_ERROR.add(onPayError);
			if (PaymentsManager.activate() == false && PayManager.accountInfo != null)
				onAccountInfo();
			
			if (config != null) {
				acceptButton.activate();
			} else {
				lockScreen();
				PaidBan.S_UPDATED.add(onConfigReady);
			}
		}
		
		private function onPaidBanChanged(userUID:String):void {
			if (isDisposed)
				return;
			
			if (userModel.uid == userUID) {
				TweenMax.killTweensOf(banDataPreloader);
				banDataPreloader.visible = false;
				if (currentState == STATE_NEW) {
					drawBanData(false);
					drawView();
					drawPrice();
					drawExpireTime();
				}
			}
		}
		
		private function drawBanData(loadData:Boolean = true):void {
			if (banData.fullData == false && loadData == true) {
				startBanDataPreloader();
				PaidBan.S_USER_BAN_UPDATED.add(onPaidBanChanged);
				PaidBan.getBanFullData(banData.id);
			}
			
			var maxWidth:int = _width - banIcon.y - banIcon.width - Config.FINGER_SIZE * .5;
			
			if (banData.reason != -1) {
				var resonText:String = PaidBanReasons.getReason(banData.reason);
				if (resonText != null) {
					
					if (reason.bitmapData != null) {
						reason.bitmapData.dispose();
						reason.bitmapData = null;
					}
					
					reason.bitmapData = TextUtils.createTextFieldData(
																		'"' + resonText + '"', maxWidth, 10, false, TextFormatAlign.CENTER, 
																		TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .30, 
																		true, 0x4A5364, 0xDEDEDE, true);
				}
			}
			
			if (banData.payer != null && banData.payerName != null) {
				if (payerName.bitmapData != null) {
					payerName.bitmapData.dispose();
					payerName.bitmapData = null;
				}
				
				var text:String = "";
				if (banData.incognito == true) {
					text = Lang.textIncognito;
				}
				else {
					text = banData.payerName
				}
				
				payerName.bitmapData = TextUtils.createTextFieldData(
																		Lang.banBy + " " + text, maxWidth, 10, false, TextFormatAlign.CENTER, 
																		TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .24, 
																		true, 0x4A5364, 0xDEDEDE, true);
			}
		}
		
		private function startBanDataPreloader():void {
			banDataPreloader.graphics.clear();
			banDataPreloader.graphics.beginFill(0xA8A8A8);
			banDataPreloader.graphics.drawRect(0, 0, 1, int(Config.FINGER_SIZE * .05));
			banDataPreloader.graphics.endFill();
			tickPreloaderShow();
		}
		
		private function tickPreloaderShow():void {
			if (isDisposed)
				return;
			
			banDataPreloader.x = 0;
			
			TweenMax.to(banDataPreloader, 0.8, {width:_width, onComplete:tickPreloaderHide, delay:0.5});
		}
		
		private function tickPreloaderHide():void {
			if (isDisposed)
				return;
			
			TweenMax.to(banDataPreloader, 0.3, {width:0, onComplete:tickPreloaderShow, delay:0.5, onUpdate:repositonBanLoader});
		}
		
		private function repositonBanLoader():void {
			if (isDisposed)
				return;
			
			banDataPreloader.x = _width - banDataPreloader.width;
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
					config = PaidBan.getConfig();
					if (config != null) {
						updateAmount();
					}
				}
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
		
		private function updateAmount():void 
		{
			drawPrice();
		}
		
		private function drawPrice():void 
		{
			if (resultAmountTitle.bitmapData != null) {
				resultAmountTitle.bitmapData.dispose();
				resultAmountTitle.bitmapData = null;
			}
			resultAmountTitle.x = Config.DIALOG_MARGIN;
			var text:String = Lang.banRemovalPrice + ": ";
			
			if (config != null) {
				var currencyString:String = getCoinCurrency();
				if (currencyString == TypeCurrency.EUR) {
					currencyString = "€";
				}
				text += getAmount() + " " + currencyString;
			}
			
			resultAmountTitle.bitmapData = TextUtils.createTextFieldData(text, componentsWidth, 10, 
															true, TextFormatAlign.LEFT, 
															TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .28, 
															true, 0x3C4350, 0xFFFFFF);
		}
		
		private function drawExpireTime():void {
			if (dateField.bitmapData != null) {
				dateField.bitmapData.dispose();
				dateField.bitmapData = null;
			}
			dateField.x = Config.DIALOG_MARGIN;
			var textDate:String = Lang.banEndsIn + " ";
			if (!isNaN(banData.canceled)) {
				var date:Date = new Date();
				var difference:Number = banData.canceled*1000 - date.getTime();
				if (difference > 0) {
					textDate += DateUtils.getComfortTimeRepresentation(difference);
					
				}
			}
			dateField.bitmapData = TextUtils.createTextFieldData(textDate, componentsWidth, 10, 
															true, TextFormatAlign.LEFT, 
															TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .28, 
															true, 0x3C4350, 0xFFFFFF);
		}
		
		private function hidePreloader():void {
			preloaderShown = false;
			container.transform.colorTransform = new ColorTransform();
			
			if (preloader != null)
			{
				preloader.hide();
				if (preloader.parent)
				{
					preloader.parent.removeChild(preloader);
				}
			}
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
			selectorDebitAccont.x = Config.DIALOG_MARGIN
			selectorDebitAccont.setSize(componentsWidth, Config.FINGER_SIZE * .8);
			selectorDebitAccont.setValue(Lang.walletToCharge);
		}
		
		private function drawAcceptButton(text:String):void {
			var textSettings:TextFieldSettings = new TextFieldSettings(text, 0xFFFFFF, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, 0x78C043, 1, Config.FINGER_SIZE * .8, NaN, (componentsWidth - Config.DIALOG_MARGIN) * .5);
			acceptButton.setBitmapData(buttonBitmap, true);
			acceptButton.x = int(acceptButton.width + Config.DIALOG_MARGIN * 2);
		}
		
		private function drawBackButton():void {
			var textSettings:TextFieldSettings = new TextFieldSettings(Lang.textBack, 0, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, 0x78C043, 0, Config.FINGER_SIZE * .8, NaN, (componentsWidth - Config.DIALOG_MARGIN) * .5);
			backButton.setBitmapData(buttonBitmap, true);
			backButton.x = Config.DIALOG_MARGIN;
		}
		
		private function drawAccountText(text:String):void {
			if (accountText.bitmapData != null) {
				accountText.bitmapData.dispose();
				accountText.bitmapData = null;
			}
			accountText.bitmapData = TextUtils.createTextFieldData(text, componentsWidth, 10, true, TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .3, true, 0xABB8C1, 0xffffff, false);
		
			accountText.x = int(_width * .5 - accountText.width * .5);
		}
		
		private function drawFxName():void {
			
			var fxNameText:String;
			if (userModel.phone != null && userModel.phone != "") {
				fxNameText = "+" + userModel.phone;
			} else if (userModel.login != null) {
				fxNameText = userModel.login;
			}
			
			if (fxName.bitmapData != null) {
				fxName.bitmapData.dispose();
				fxName.bitmapData = null;
			}
			
			if (fxNameText != null)	{
				fxName.bitmapData = TextUtils.createTextFieldData(fxNameText, componentsWidth, 10, false, TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .30, false, 0xDA2627, 0xffffff, false);
				fxName.x = int(_width * .5 - fxName.width * .5);
			}
		}
		
		private function drawUserName():void {
			var userNameText:String;
			
			userNameText = userModel.getDisplayName();
			
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
			
			verticalMargin = Config.MARGIN * 1.5;
			
			var position:int;
			
			if (currentState == STATE_NEW) {
				position = verticalMargin + avatarSize * 2;
				
				userName.y = position;
				position += userName.height;
				
				if (userModel.login != null) {
					position += verticalMargin * .5;
					fxName.y = position;
					position += fxName.height;
				}
				position += verticalMargin * 1.3;
				
				scrollPanel.view.y = position;
				
				var maxContentHeight:int = _height - position - acceptButton.height - verticalMargin * 1.8 * 2;
				var contentPosition:int = 0;
				
				if (reason.height > 0) {
					reason.y = int(Config.FINGER_SIZE * .25);
					reason.x = int(banIcon.x + banIcon.width + Config.FINGER_SIZE * .2);
					if (payerName.height > 0) {
						payerName.y = int(reason.y + reason.height + Config.FINGER_SIZE * .08);
						payerName.x = reason.x;
					}
				}
				banDataPreloader.y = 0;
				var banClipHeight:int = Math.max(banIcon.y + banIcon.height + Config.FINGER_SIZE * 0.17, payerName.y + payerName.height + Config.FINGER_SIZE * .15);
				banInfoClip.graphics.clear();
				banInfoClip.graphics.beginFill(0xDEDEDE);
				banInfoClip.graphics.drawRect(0, 0, _width, banClipHeight);
				contentPosition += banClipHeight + Config.DOUBLE_MARGIN;
				
				if (banDataPreloader != null) {
					banDataPreloader.y = banInfoClip.height - banDataPreloader.height;
				}
				
				dateField.y = contentPosition;
				contentPosition += dateField.height * .5 + Config.FINGER_SIZE * .3;
				
				resultAmountTitle.y = contentPosition;
				contentPosition +=  resultAmountTitle.height + Config.MARGIN;
				
				selectorDebitAccont.y = contentPosition;
				contentPosition += selectorDebitAccont.height + verticalMargin;
				
				accountText.y = contentPosition;
				contentPosition += accountText.height + verticalMargin * 1.8;
				
				scrollPanel.setWidthAndHeight(_width, Math.min(maxContentHeight, scrollPanel.itemsHeight));
				scrollPanel.update();
				position += scrollPanel.height + verticalMargin;
				
				acceptButton.y = position;
				backButton.y = position;
				position += acceptButton.height + verticalMargin * 1.8;
				
				bg.height = position - avatarSize;
				
				bg.y = avatarSize;
				
				container.y = _height - position;
			}
		}
		
		override public function activateScreen():void
		{
			if (_isDisposed == true)
				return;
			
			super.activateScreen();
			
			if (screenLocked == true)
				return;
			
			if (isNextButtonAvaliable()) {
				acceptButton.activate();
				acceptButton.alpha = 1;
			}
			
			if (backButton.visible) {
				backButton.activate();
			}
			
			if (selectorDebitAccont.visible) {
				selectorDebitAccont.activate();
			}
			
			scrollPanel.enable();
		}
		
		private function isNextButtonAvaliable():Boolean {
			if (currentState == STATE_NEW){
				return (walletSelected == true);
			}
			return false;
		}
		
		override public function deactivateScreen():void {
			if (_isDisposed == true)
				return;
			
			super.deactivateScreen();
			
			acceptButton.deactivate();
			backButton.deactivate();
			selectorDebitAccont.deactivate();
			
			scrollPanel.disable();
		}
		
		override public function dispose():void {
			if (_isDisposed == true)
				return;
			super.dispose();
			
			PaymentsManager.S_ACCOUNT.remove(onAccountInfo);
			PaymentsManager.S_ERROR.remove(onPayError);
			PaymentsManager.deactivate();
			
			TweenMax.killDelayedCallsTo(hideElemetsFromState);
			
			TweenMax.killTweensOf(avatar);
			TweenMax.killTweensOf(scrollPanel.view);
			TweenMax.killTweensOf(fxName);
			TweenMax.killTweensOf(finishFooterMask);
			TweenMax.killTweensOf(acceptButton);
			TweenMax.killTweensOf(backButton);
			TweenMax.killTweensOf(banDataPreloader);
			
			if (finishImageMask != null) {
				UI.destroy(finishImageMask);
				finishImageMask = null;
			}
			if (finishImage != null) {
				UI.destroy(finishImage);
				finishImage = null;
			}
			if (banDataPreloader != null) {
				UI.destroy(banDataPreloader);
				banDataPreloader = null;
			}
			if (payerName != null)	{
				UI.destroy(payerName);
				payerName = null;
			}
			if (reason != null)	{
				UI.destroy(reason);
				reason = null;
			}
			if (banInfoClip != null)	{
				UI.destroy(banInfoClip);
				banInfoClip = null;
			}
			if (banIcon != null)	{
				UI.destroy(banIcon);
				banIcon = null;
			}
			if (resultAmountTitle != null)	{
				UI.destroy(resultAmountTitle);
				resultAmountTitle = null;
			}
			if (scrollPanel != null) {
				scrollPanel.dispose();
				scrollPanel = null;
			}
			if (footer != null)	{
				UI.destroy(footer);
				footer = null;
			}
			if (finishFooterMask != null) {
				UI.destroy(finishFooterMask);
				finishFooterMask = null;
			}
			if (preloader != null) {
				preloader.dispose();
				preloader = null;
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
			if (dateField != null) {
				UI.destroy(dateField);
				dateField = null;
			}
			if (fxName != null) {
				UI.destroy(fxName);
				fxName = null;
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
			userModel = null;
			selectedAccount = null;
			config = null;
			banData = null;
			
			PaidBan.S_BAN_REMOVE_RESPONSE.remove(onRequestUnbanResponse);
			PaidBan.S_UPDATED.remove(onConfigReady);
		}
	}
}