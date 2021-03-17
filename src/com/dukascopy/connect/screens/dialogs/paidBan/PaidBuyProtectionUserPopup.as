package com.dukascopy.connect.screens.dialogs.paidBan {
	
	import assets.DoneRoundIcon;
	import assets.ProtectionIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.data.paidBan.config.PaidBanConfig;
	import com.dukascopy.connect.gui.button.DDAccountButton;
	import com.dukascopy.connect.gui.button.DDFieldButton;
	import com.dukascopy.connect.gui.chat.CircleAvatar;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.renderers.ListLink;
	import com.dukascopy.connect.gui.list.renderers.ListPayCurrency;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.preloader.Preloader;
	import com.dukascopy.connect.gui.scrollPanel.ScrollPanel;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.dialogs.ScreenPayDialog;
	import com.dukascopy.connect.screens.dialogs.bottom.ListSelectionPopup;
	import com.dukascopy.connect.screens.payments.card.TypeCurrency;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.applicationShop.serverTask.PaidBanProtectionRequestData;
	import com.dukascopy.connect.sys.applicationShop.serverTask.ShopServerTask;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.configManager.ConfigManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.payments.PayManager;
	import com.dukascopy.connect.sys.payments.PaymentsManager;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.usersManager.paidBan.PaidBan;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.connect.vo.users.UserVO;
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
	
	
	 public class PaidBuyProtectionUserPopup extends BaseScreen {
		
		static public const STATE_RESULT:String = "stateResult";
		static public const STATE_NEW:String = "stateNew";
		
		private const avatarSize:int = Config.FINGER_SIZE;
		
		protected var container:Sprite;
		private var bg:Shape;
		private var userName:Bitmap;
		private var fxName:Bitmap;
		private var acceptButton:BitmapButton;
		private var avatar:CircleAvatar;
		private var userModel:UserVO;
		
		private var backButton:BitmapButton;
		private var selectorDebitAccont:DDAccountButton;
		private var preloader:Preloader;
		private var screenLocked:Boolean;
		private var currentState:String = STATE_NEW;
		private var verticalMargin:Number = Config.MARGIN * 1.5;
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
		private var protectionIcon:ProtectionIcon;
		private var protectionInfoClip:Sprite;
		private var description:Bitmap;
		protected var componentsWidth:int;
		private var finishImage:Bitmap;
		private var finishImageMask:Sprite;
		private var weeksTitle:Bitmap;
		private var selectorWeeks:DDFieldButton;
		private var durationCollection:Array;
		
		public function PaidBuyProtectionUserPopup() {
			
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
			bg.y = avatarSize;
			container.addChild(bg);
			
			scrollPanel = new ScrollPanel();
			container.addChild(scrollPanel.view);
			
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
			
			finishImage = new Bitmap();
			container.addChild(finishImage);
			
			finishImageMask = new Sprite();
			container.addChild(finishImageMask);
			
			_view.addChild(container);
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			if (data != null && "user" in data && data.user != null && data.user is UserVO)
				userModel = data.user as UserVO;
			if (userModel == null) {
				ServiceScreenManager.closeView();
				ApplicationErrors.add("empty userModel");
				return;
			}
			
			componentsWidth = _width - Config.DIALOG_MARGIN * 2;
			drawAvatar();
			drawUserName();
			drawFxName();
			drawProtectionInfo();
			drawWeeksSelector(1);
			
			drawAccountSelector();
			drawBackButton();
			drawAcceptButton(Lang.textNext);
			acceptButton.alpha = 0.5;
			
			PaymentsManager.S_ACCOUNT.add(onAccountInfo);
			PaymentsManager.S_ERROR.add(onPayError);
			if (PaymentsManager.activate() == false && PayManager.accountInfo != null)
				onAccountInfo();
			
			config = PaidBan.getConfig();
			drawPrice();
			if (config != null) {
				acceptButton.activate();
			} else {
				lockScreen();
				PaidBan.S_UPDATED.add(onConfigReady);
			}
		}
		
		private function drawAvatar():void {
			var avatarUrl:String;
			if (avatar == null) {
				avatar = new CircleAvatar();
				avatar.x = int(_width * .5) - avatarSize;
				avatarUrl = userModel.getAvatarURLProfile(avatarSize * 2);
				avatar.setData(userModel, avatarSize, false, false, avatarUrl);
			}
			if (avatar.parent == null)
				container.addChild(avatar);
		}
		
		private function drawUserName():void {
			userName ||= new Bitmap();
			if (userName.bitmapData != null)
				userName.bitmapData.dispose();
			userName.bitmapData = null;
			var userNameText:String = userModel.getDisplayName();
			userName.bitmapData = TextUtils.createTextFieldData(
				userNameText,
				componentsWidth,
				10,
				false,
				TextFormatAlign.CENTER,
				TextFieldAutoSize.LEFT,
				Config.FINGER_SIZE * .40,
				false,
				0x3E4756,
				0xffffff,
				false
			);
			userName.x = int((_width - userName.width) * .5);
			if (userName.parent == null)
				container.addChild(userName);
		}
		
		private function drawFxName():void {
			fxName ||= new Bitmap();
			if (fxName.bitmapData != null)
				fxName.bitmapData.dispose();
			fxName.bitmapData = null;
			var fxNameText:String;
			if (userModel.phone != null && userModel.phone != "")
				fxNameText = "+" + userModel.phone;
			else if (userModel.login != null)
				fxNameText = userModel.login;
			if (fxNameText == null)
				return;
			fxName.bitmapData = TextUtils.createTextFieldData(
				fxNameText,
				componentsWidth,
				10,
				false,
				TextFormatAlign.CENTER,
				TextFieldAutoSize.LEFT,
				Config.FINGER_SIZE * .30,
				false,
				0xDA2627,
				0xffffff,
				false
			);
			fxName.x = int(_width * .5 - fxName.width * .5);
			if (fxName.parent == null)
				container.addChild(fxName);
		}
		
		private function drawProtectionInfo():void {
			protectionInfoClip ||= new Sprite();
			if (protectionIcon == null) {
				protectionIcon = new ProtectionIcon();
				var color:Color = new Color();
				color.color = 0x76848C;
				protectionIcon.transform.colorTransform = color;
				UI.scaleToFit(protectionIcon, Config.FINGER_SIZE * .8, Config.FINGER_SIZE * 1.5);
			}
			protectionIcon.x = Config.DIALOG_MARGIN;
			if (protectionIcon.parent == null)
				protectionInfoClip.addChild(protectionIcon);
			description ||= new Bitmap();
			if (description.bitmapData != null)
				description.bitmapData.dispose();
			description.bitmapData = null;
			var maxDescWidth:int = _width - Config.DIALOG_MARGIN * 3 - protectionIcon.width;
			description.bitmapData = TextUtils.createTextFieldData(
				Lang.protectionDescription,
				maxDescWidth,
				10,
				false,
				TextFormatAlign.CENTER,
				TextFieldAutoSize.LEFT,
				Config.FINGER_SIZE * .25,
				true,
				0x4A5364,
				0xDEDEDE,
				true
			);
			var descOffset:int = protectionIcon.width + Config.DIALOG_MARGIN * 2;
			description.x = descOffset + int((maxDescWidth - description.width) * .5);
			var protectionInfoHeightMIN:int = protectionIcon.height + Config.DOUBLE_MARGIN;
			var protectionInfoHeight:int;
			if (description.height + Config.DOUBLE_MARGIN < protectionInfoHeightMIN) {
				protectionInfoHeight = protectionInfoHeightMIN;
				protectionIcon.y = Config.MARGIN;
				description.y = int((protectionInfoHeight - description.height) * .5);
			} else {
				protectionInfoHeight = Config.DOUBLE_MARGIN + description.height;
				description.y = Config.MARGIN;
				protectionIcon.y = int((protectionInfoHeight - protectionIcon.height) * .5);
			}
			if (description.parent == null)
				protectionInfoClip.addChild(description);
			protectionInfoClip.graphics.clear();
			protectionInfoClip.graphics.beginFill(0xDEDEDE);
			protectionInfoClip.graphics.drawRect(0, 0, _width, protectionInfoHeight);
			if (protectionInfoClip.parent == null)
				scrollPanel.addObject(protectionInfoClip);
		}
		
		private function drawWeeksSelector(value:int):void {
			weeksTitle ||= new Bitmap();
			if (weeksTitle.bitmapData != null)
				weeksTitle.bitmapData.dispose();
			weeksTitle.bitmapData = null;
			weeksTitle.x = Config.DIALOG_MARGIN;
			weeksTitle.bitmapData = TextUtils.createTextFieldData(
				Lang.textWeeks,
				componentsWidth,
				10,
				true,
				TextFormatAlign.LEFT,
				TextFieldAutoSize.LEFT,
				Config.FINGER_SIZE * .28,
				true,
				0x1C2935,
				0xFFFFFF
			);
			if (weeksTitle.parent == null)
				scrollPanel.addObject(weeksTitle);
			if (selectorWeeks == null) {
				selectorWeeks = new DDFieldButton(selectWeeks);
				selectorWeeks.setSize(Config.FINGER_SIZE * 1.4, Config.FINGER_SIZE * .8);
			}
			selectorWeeks.setValue(value.toString());
			if (selectorWeeks.parent == null)
				scrollPanel.addObject(selectorWeeks);
		}
		
		private function drawPrice():void {
			resultAmountTitle ||= new Bitmap();
			resultAmountTitle.x = Config.DIALOG_MARGIN;
			if (resultAmountTitle.bitmapData != null)
				resultAmountTitle.bitmapData.dispose();
			resultAmountTitle.bitmapData = null;
			var text:String = Lang.totalPrice + ": ";
			if (config != null) {
				var currency:String =  "€";
				if (ConfigManager.config != null && ConfigManager.config.innerCurrency != TypeCurrency.EUR) {
					currency = ConfigManager.config.innerCurrency;
					if (currency == "DCO")
						currency = "DUK+";
				}
				text += getAmount() + " " + currency;
			}
			resultAmountTitle.bitmapData = TextUtils.createTextFieldData(
				text,
				componentsWidth,
				10,
				true,
				TextFormatAlign.LEFT,
				TextFieldAutoSize.LEFT,
				Config.FINGER_SIZE * .28,
				true,
				0x3C4350,
				0xFFFFFF
			);
			if (resultAmountTitle.parent == null)
				scrollPanel.addObject(resultAmountTitle);
		}
		
		private function drawAccountSelector():void {
			if (selectorDebitAccont == null) {
				selectorDebitAccont = new DDAccountButton(openWalletSelector, null, false);
				selectorDebitAccont.setValue(Lang.walletToCharge);
				selectorDebitAccont.setSize(componentsWidth, Config.FINGER_SIZE * .8);
				selectorDebitAccont.x = Config.DIALOG_MARGIN;
			}
			if (selectorDebitAccont.parent == null)
				scrollPanel.addObject(selectorDebitAccont);
		}
		
		private function drawBackButton():void {
			if (backButton == null) {
				backButton = new BitmapButton();
				backButton.setStandartButtonParams();
				backButton.setDownScale(1);
				backButton.setDownColor(0);
				backButton.tapCallback = onBack;
				backButton.disposeBitmapOnDestroy = true;
				backButton.x = Config.DIALOG_MARGIN;
			}
			var textSettings:TextFieldSettings = new TextFieldSettings(
				Lang.textBack,
				0,
				Config.FINGER_SIZE * .3,
				TextFormatAlign.CENTER
			);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(
				textSettings,
				0x78C043,
				0,
				Config.FINGER_SIZE * .8,
				NaN,
				int((componentsWidth - Config.DIALOG_MARGIN) * .5)
			);
			backButton.setBitmapData(buttonBitmap, true);
			if (backButton.parent == null)
				container.addChild(backButton);
		}
		
		private function drawAcceptButton(text:String):void {
			var textSettings:TextFieldSettings = new TextFieldSettings(text, 0xFFFFFF, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, 0x78C043, 1, Config.FINGER_SIZE * .8, NaN, (componentsWidth - Config.DIALOG_MARGIN) * .5);
			acceptButton.setBitmapData(buttonBitmap, true);
			acceptButton.x = int(acceptButton.width + Config.DIALOG_MARGIN * 2);
		}
		
		override protected function drawView():void {
			if (_isDisposed == true)
				return;
			bg.width = _width;
			if (currentState != STATE_NEW)
				return;
			
			var position:int = verticalMargin + avatarSize * 2;
			
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
			
			contentPosition += protectionInfoClip.height + Config.MARGIN;
			
			selectorWeeks.y = contentPosition;
			selectorWeeks.x = int(_width - selectorWeeks.width - Config.DIALOG_MARGIN);
			weeksTitle.y = int(selectorWeeks.y + selectorWeeks.height * .5 - weeksTitle.height * .5);
			weeksTitle.x = Config.DIALOG_MARGIN;
			contentPosition += Config.FINGER_SIZE;
			
			resultAmountTitle.y = contentPosition;
			contentPosition +=  resultAmountTitle.height + Config.MARGIN;
			
			selectorDebitAccont.y = contentPosition;
			contentPosition += selectorDebitAccont.height + verticalMargin;
			
			scrollPanel.setWidthAndHeight(_width, Math.min(maxContentHeight, scrollPanel.itemsHeight));
			scrollPanel.update();
			position += scrollPanel.height + verticalMargin;
			
			acceptButton.y = position;
			backButton.y = position;
			position += acceptButton.height + verticalMargin * 1.8;
			
			bg.height = position - avatarSize;
			
			container.y = _height - position;
		}
		
		override public function activateScreen():void {
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
			if (selectorWeeks != null) {
				selectorWeeks.activate();
			}
			scrollPanel.enable();
		}
		
		override public function deactivateScreen():void {
			if (_isDisposed == true)
				return;
			super.deactivateScreen();
			acceptButton.deactivate();
			backButton.deactivate();
			selectorDebitAccont.deactivate();
			if (selectorWeeks != null) {
				selectorWeeks.deactivate();
			}
			scrollPanel.disable();
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
		
		private function createPaymentsAccount(val:int):void {
			onBack();
			if (val != 1)
				return;
			MobileGui.showRoadMap();
		}
		
		private function openWalletSelector(e:Event = null):void {
			if (PayManager.accountInfo != null)
				return;
			PaymentsManager.updateAccount();
		}
		
		private function getAmount():Number {
			if (config != null)
				return Math.round((getWeeks() * 7 * config.protect.value) * 100) / 100;
			return 0;
		}
		
		override public function onBack(e:Event = null):void {
			if (screenLocked == false)
				ServiceScreenManager.closeView();
		}
		
		private function nextClick():void {
			if (currentState == STATE_NEW) {
				if (isNextButtonAvaliable()) {
					lockScreen();
					PaidBan.S_ADD_PROTECTOION_RESPONSE.add(onRequestProtectionResponse);
					PaidBan.processAddProtection(new PaidBanProtectionRequestData(userModel.uid, getWeeks() * 7), selectedAccount.ACCOUNT_NUMBER);
				}
			} else if (currentState == STATE_RESULT) {
				ServiceScreenManager.closeView();
			}
		}
		
		private function onRequestProtectionResponse(success:Boolean, userUid:String = null, errorMessage:String = null, taskCanBeRequestedAgain:Boolean = true):void {
			if (isDisposed == true)
				return;
			if (userModel.uid != userUid)
				return;
			if (taskCanBeRequestedAgain) {
				PaidBan.S_ADD_PROTECTOION_RESPONSE.remove(onRequestProtectionResponse);
				unlockScreen();
				if (success == false) {
					if (errorMessage != null) {
						ToastMessage.display(errorMessage);
					}
				} else {
					Auth.updateFromPhp();
					toState(STATE_RESULT);
				}
			} else {
				PaidBan.onFailedFinishRequest(ShopServerTask.BUY_PROTECTION);
				DialogManager.alert(Lang.textError, Lang.somethingWentWrong);
				onBack();
			}
		}
		
		private function onAccountInfo():void {
			PaymentsManager.S_ACCOUNT.remove(onAccountInfo);
			if (isDisposed == true)
				return;
			if (PayManager.accountInfo == null)
				return;
			setDefaultWallet();
			if (currentState != STATE_RESULT)
				return;
			if (PayManager.accountInfo.coins == null)
				return;
			var l:int = PayManager.accountInfo.coins.length;
			for (var i:int = 0; i < l; i++) {
				if (PayManager.accountInfo.coins[i].ACCOUNT_NUMBER == selectedAccount.ACCOUNT_NUMBER) {
					resultAccount = selectedAccount.ACCOUNT_NUMBER;
					newAmount = Number(PayManager.accountInfo.coins[i].BALANCE);
					if (footer != null && footer.bitmapData != null) {
						var accountDB:ImageBitmapData = TextUtils.createTextFieldData(
							resultAccount.substr(0, 4) +  " … " + resultAccount.substr(resultAccount.length - 4),
							_width - Config.DIALOG_MARGIN,
							10,
							false,
							TextFormatAlign.CENTER,
							TextFieldAutoSize.LEFT,
							Config.FINGER_SIZE * 0.35,
							false,
							0xAAB8C5,
							0xFBFBFB
						);
						footer.bitmapData.copyPixels(
							accountDB,
							new Rectangle(0, 0, accountDB.width, accountDB.height),
							accountBitmapDataPosition,
							null,
							null,
							true
						);
						accountDB.dispose();
						accountDB = null;
						var balance:Number = newAmount;
						balance = Math.floor(balance * 100) / 100;
						var newBalanceBD:ImageBitmapData = TextUtils.createTextFieldData(
							balance.toString() + " DUK+",
							_width - Config.DIALOG_MARGIN,
							10,
							false,
							TextFormatAlign.CENTER,
							TextFieldAutoSize.LEFT,
							Config.FINGER_SIZE * 0.25,
							false,
							0xAAB8C5,
							0xFBFBFB
						);
						balanceFooterBDPosition = new Point(
							int(_width - Config.DIALOG_MARGIN - newBalanceBD.width),
							int(Config.DIALOG_MARGIN + Config.FINGER_SIZE * .5)
						);
						footer.bitmapData.copyPixels(
							newBalanceBD,
							new Rectangle(0, 0, newBalanceBD.width, newBalanceBD.height),
							balanceFooterBDPosition,
							null,
							null,
							true
						);
						newBalanceBD.dispose();
						newBalanceBD = null;
					}
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
		
		private function setDefaultWallet():void {
			var defaultAccount:Object;
			var currencyNeeded:String = TypeCurrency.DCO;
			var wallets:Array = PayManager.accountInfo.coins;
			if (wallets != null)
			{
				var l:int = wallets.length;
				var walletItem:Object;
				if (wallets != null) {
					for (var i:int = 0; i < l; i++) {
						walletItem = wallets[i];
						if (currencyNeeded == walletItem.COIN) {
							defaultAccount = walletItem;
							break;
						}
					}
				}
				if (defaultAccount != null) {
					onWalletSelect(defaultAccount);
				} else {
					DialogManager.alert(Lang.information, Lang.noCoinsAccount);
				}
			}
			else
			{
				onBack();
			}
		}
		
		private function onWalletSelect(account:Object):void {
			if (account == null)
				return;
			walletSelected = true;
			
			selectedAccount = account;
			selectorDebitAccont.setValue(account);
			
			acceptButton.activate();
			acceptButton.alpha = 1;
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
			
			if (newState == STATE_RESULT) {
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
				
				var thanksText:ImageBitmapData = TextUtils.createTextFieldData(Lang.protectionAdded, _width - Config.DIALOG_MARGIN, 10, false, TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * 0.27, false, 0xFFFFFF, 0x999999, true);
				
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
				
				if (userModel.login != null) {
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
				
				var payValueBD:ImageBitmapData = TextUtils.createTextFieldData("-" + minus.toString() + " DUK+", _width - Config.DIALOG_MARGIN, 10, false, TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * 0.4, false, 0xEAA6A7, 0xFBFBFB);
				
				bdFooter.copyPixels(payValueBD, new Rectangle(0, 0, payValueBD.width, payValueBD.height), new Point(int(_width - Config.DIALOG_MARGIN - payValueBD.width), int(Config.DIALOG_MARGIN)), null, null, true);
				payValueBD.dispose();
				payValueBD = null;
				
				if (!isNaN(newAmount)){
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
				
				var resizeTime:Number = 0.8;
				TweenMax.to(finishFooterMask, resizeTime, {y: bg.y + bg.height - finishFooterMask.height, delay: hideTime, ease: Power3.easeInOut});
				TweenMax.to(finishImageMask, resizeTime, {height: finishImageHeight, delay: hideTime, onUpdate: repositionElements, ease: Power3.easeInOut});
				TweenMax.to(acceptButton, showTime, {alpha: 1, delay: (hideTime + resizeTime), onComplete: activateAcceptButton, onStart: repositionAcceptButton});
				
				onAccountInfo();
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
		
		private function repositionElements():void {
			avatar.y = finishImageMask.height;
			userName.y = avatar.y + verticalMargin + avatarSize * 2;
			
			if (userModel.login != null) {
				fxName.y = userName.height + userName.y + verticalMargin * .5;
			}
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
			if (isDisposed == true)
				return;
			if (acceptButton != null && isActivated) {
				acceptButton.activate();
				acceptButton.alpha = 1;
			}
		}
		
		public function getWeeks():int {
			if (selectorWeeks != null) {
				var weeks:int = int(selectorWeeks.value);
				if (weeks > 0){
					return weeks;
				}
			}
			return 0;
		}
		
		private function selectWeeks(e:Event = null):void {
			if (durationCollection == null) {
				durationCollection = [];
				durationCollection.push({label:"1 " + Lang.textWeek});
				durationCollection.push({label:"2 " + Lang.textWeeks});
				durationCollection.push({label:"3 " + Lang.textWeeks});
				durationCollection.push({label:"4 " + Lang.textWeeks});
			}
			/*DialogManager.showDialog(
				ScreenPayDialog,
				{
					callback: callBackSelectWeeks,
					data: durationCollection,
					itemClass: ListPayCurrency,
					label: Lang.protectionDuration
				}
			);*/
			
			DialogManager.showDialog(
				ListSelectionPopup,
				{
					items:durationCollection,
					title:Lang.protectionDuration,
					renderer:ListLink,
					callback:callBackSelectWeeks
				}, ServiceScreenManager.TYPE_SCREEN
			);
		}
		
		private function callBackSelectWeeks(value:Object):void {
			if (isDisposed == true)
				return;
			if (durationCollection != null) {
				var index:int = durationCollection.indexOf(value);
				if (index != -1)
					drawWeeksSelector(index + 1);
			}
			drawPrice();
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
			if (isDisposed == true)
				return;
			unlockScreen();
			if (success == true) {
				config = PaidBan.getConfig();
				if (config != null) {
					drawPrice();
				}
			}
		}
		
		private function isNextButtonAvaliable():Boolean {
			if (currentState == STATE_NEW){
				return (walletSelected == true);
			}
			return false;
		}
		
		private function showPreloader():void {
			preloaderShown = true;
			
			var color:Color = new Color();
			color.setTint(0xFFFFFF, 0.7);
			container.transform.colorTransform = color;
			
			if (preloader == null) {
				preloader = new Preloader();
			}
			preloader.x = _width * .5;
			preloader.y = _height * .5;
			view.addChild(preloader);
			preloader.show();
		}
		
		private function hidePreloader():void {
			preloaderShown = false;
			container.transform.colorTransform = new ColorTransform();
			
			if (preloader != null) {
				preloader.hide();
				if (preloader.parent) {
					preloader.parent.removeChild(preloader);
				}
			}
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
			
			if (selectorWeeks != null)
				selectorWeeks.dispose();
			selectorWeeks = null;
			if (weeksTitle != null)
				UI.destroy(weeksTitle);
			weeksTitle = null;
			if (finishImageMask != null)
				UI.destroy(finishImageMask);
			finishImageMask = null;
			if (finishImage != null)
				UI.destroy(finishImage);
			finishImage = null;
			if (description != null)
				UI.destroy(description);
			description = null;
			if (protectionInfoClip != null)
				UI.destroy(protectionInfoClip);
			protectionInfoClip = null;
			if (protectionIcon != null)
				UI.destroy(protectionIcon);
			protectionIcon = null;
			if (resultAmountTitle != null)
				UI.destroy(resultAmountTitle);
			resultAmountTitle = null;
			if (scrollPanel != null)
				scrollPanel.dispose();
			scrollPanel = null;
			if (footer != null)
				UI.destroy(footer);
			footer = null;
			if (finishFooterMask != null)
				UI.destroy(finishFooterMask);
			finishFooterMask = null;
			if (preloader != null)
				preloader.dispose();
			preloader = null;
			if (selectorDebitAccont != null)
				selectorDebitAccont.dispose();
			selectorDebitAccont = null;
			if (backButton != null)
				backButton.dispose();
			backButton = null;
			if (acceptButton != null)
				acceptButton.dispose();
			acceptButton = null;
			if (avatar != null)
				avatar.dispose();
			avatar = null;
			if (fxName != null)
				UI.destroy(fxName);
			fxName = null;
			if (userName != null)
				UI.destroy(userName);
			userName = null;
			if (bg != null)
				UI.destroy(bg);
			bg = null;
			if (container != null)
				UI.destroy(container);
			container = null;
			userModel = null;
			selectedAccount = null;
			config = null;
			PaidBan.S_ADD_PROTECTOION_RESPONSE.remove(onRequestProtectionResponse);
			PaidBan.S_UPDATED.remove(onConfigReady);
		}
	}
}