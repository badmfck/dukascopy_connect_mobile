package com.dukascopy.connect.screens.dialogs.gifts
{
	
	import assets.Confeti;
	import assets.DoneRoundIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.GD;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.GiftData;
	import com.dukascopy.connect.data.LocalAvatars;
	import com.dukascopy.connect.data.SelectorButtonData;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.data.coinMarketplace.PaymentsAccountsProvider;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.customActions.GiftByCardAction;
	import com.dukascopy.connect.gui.button.DDAccountButton;
	import com.dukascopy.connect.gui.button.DDFieldButton;
	import com.dukascopy.connect.gui.button.SelectorButton;
	import com.dukascopy.connect.gui.components.CirclePreloader;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.components.textEditors.FullscreenTextEditor;
	import com.dukascopy.connect.gui.input.Input;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.List;
	import com.dukascopy.connect.gui.list.renderers.ListPayCurrency;
	import com.dukascopy.connect.gui.list.renderers.ListPayWalletItem;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.menuVideo.OptionSwitcher;
	import com.dukascopy.connect.gui.preloader.Preloader;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.dialogs.ScreenPayDialog;
	import com.dukascopy.connect.screens.dialogs.x.base.bottom.ListSelectionPopup;
	import com.dukascopy.connect.screens.payments.card.TypeCurrency;
	import com.dukascopy.connect.screens.payments.managers.SendMoneySecureCodeItem;
	import com.dukascopy.connect.sys.Gifts;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.payments.InvoiceManager;
	import com.dukascopy.connect.sys.payments.PayAPIManager;
	import com.dukascopy.connect.sys.payments.PayManager;
	import com.dukascopy.connect.sys.payments.PayRespond;
	import com.dukascopy.connect.sys.payments.advancedPayments.vo.PayTaskVO;
	import com.dukascopy.connect.sys.pointerManager.PointerManager;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.softKeyboard.SoftKeyboard;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.sys.theme.AppTheme;
	import com.dukascopy.connect.sys.usersManager.UsersManager;
	import com.dukascopy.connect.type.GiftType;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.connect.vo.users.UserVO;
	import com.dukascopy.langs.Lang;
	import com.dukascopy.langs.LangManager;
	import com.greensock.TweenMax;
	import com.greensock.easing.Power3;
	import com.telefision.sys.signals.Signal;
	import fl.motion.Color;
	import flash.display.Bitmap;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.MouseEvent;
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
	
	public class CreateGiftPopup extends BaseScreen
	{
		
		static public const STATE_GIFT_SENT:String = "stateGiftSent";
		static public const STATE_NEW:String = "stateNew";
		static public const STATE_COMMENTS:String = "stateComments";
		
		protected var container:Sprite;
		private var bg:Shape;
		private var giftImage:Bitmap;
		private var userName:Bitmap;
		private var fxName:Bitmap;
		private var text:Bitmap;
		private var acceptButton:BitmapButton;
		private var avatar:Bitmap;
		private var userModel:UserVO;
		private var avatarBD:ImageBitmapData;
		private var avatarSize:int;
		private var giftType:int;
		private var giftData:GiftData;
		private var accountText:Bitmap;
		private var backButton:BitmapButton;
		private var selectorDebitAccont:DDAccountButton;
		private var preloader:Preloader;
		private var _lastCommissionCallID:String;
		private var screenLocked:Boolean;
		private var finishImage:Bitmap;
		private var finishImageMask:Sprite;
		private var currentState:String = STATE_NEW;
		private var verticalMargin:Number;
		private var walletSelected:Boolean;
		private var iAmount:Input;
		private var selectorCurrency:DDFieldButton;
		private var commentsBitmap:Bitmap;
		private var commentsBitmapContainer:Sprite;
		private var currentTextEditor:FullscreenTextEditor;
		private var selectedAccount:Object;
		private var currentPayTask:PayTaskVO;
		private var payId:String;
		private var resultAccount:String;
		private var newAmount:Number;
		private var footer:Bitmap;
		private var finishFooterMask:Sprite;
		private var currentCommision:Number = 0;
		private var preloaderShown:Boolean = false;
		private var lockedAmount:Boolean = false;
		private var receiverSecret:Boolean;
		private var accountBitmapDataPosition:Point;
		private var balanceFooterBDPosition:Point;
		private var inPaymentProcess:Boolean;
		private var selectorCreditAccont:DDAccountButton;
		private var selfTransfer:Boolean;
		private var walletCreditSelected:Boolean;
		private var selectedCreditAccount:Object;
		private var openCreditSelectorWaiting:Boolean;
		private var needShowCurrencies:Boolean;
		private var openSelectorWaiting:Boolean;
		private var accountInfoLoading:Boolean;
		private var accounts:PaymentsAccountsProvider;
		private var accountsUpdated:Boolean;
		private var wasFinalDraw:Boolean;
		protected var componentsWidth:int;
		private var secureCodeManager:SendMoneySecureCodeItem = new SendMoneySecureCodeItem();
		private var warningSwitcher:OptionSwitcher;
		private var needRecieveComission:Boolean;
		private var needShowPuspoose:Boolean;
		private var purposeSelector:SelectorButton;
		private var lockNextButton:Boolean;
		private var loader:CirclePreloader;
		
		public function CreateGiftPopup()
		{
		
		}
		
		override protected function createView():void
		{
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
			
			avatar = new Bitmap();
			container.addChild(avatar);
			
			giftImage = new Bitmap();
			giftImage.smoothing = true;
			container.addChild(giftImage);
			
			userName = new Bitmap();
			container.addChild(userName);
			
			fxName = new Bitmap();
			container.addChild(fxName);
			
			text = new Bitmap();
			container.addChild(text);
			
			accountText = new Bitmap();
			container.addChild(accountText);
			
			footer = new Bitmap();
			container.addChild(footer);
			
			finishFooterMask = new Sprite();
			container.addChild(finishFooterMask);
			
			acceptButton = new BitmapButton();
			acceptButton.setStandartButtonParams();
			acceptButton.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
			acceptButton.setDownScale(1);
			acceptButton.setDownColor(0);
			acceptButton.tapCallback = nextClick;
			acceptButton.disposeBitmapOnDestroy = true;
			container.addChild(acceptButton);
			
			backButton = new BitmapButton();
			backButton.setStandartButtonParams();
			backButton.setDownScale(1);
			backButton.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
			backButton.setDownColor(0);
			backButton.tapCallback = backClick;
			backButton.disposeBitmapOnDestroy = true;
			container.addChild(backButton);
			
			selectorDebitAccont = new DDAccountButton(openWalletSelector);
			container.addChild(selectorDebitAccont);
			
			finishImage = new Bitmap();
			container.addChild(finishImage);
			
			finishImageMask = new Sprite();
			container.addChild(finishImageMask);
			
			_view.addChild(container);
			
			commentsBitmap = new Bitmap();
			commentsBitmapContainer = new Sprite();
			container.addChild(commentsBitmapContainer);
			commentsBitmapContainer.addChild(commentsBitmap);
			commentsBitmapContainer.visible = false;
			
			secureCodeManager.createView();
		}
		
		override public function isModal():Boolean
		{
			if (giftData != null && giftData.callback != null)
			{
				return false;
			}
			return true;
		}
		
		private function openWalletSelector(e:Event = null):void {
			SoftKeyboard.closeKeyboard();
			if (iAmount != null) {
				iAmount.forceFocusOut();
			}
			if (PayAPIManager.hasSwissAccount == false) {
				DialogManager.alert(Lang.information, Lang.featureNoPaments, createPaymentsAccount, Lang.registrate, Lang.textCancel);
				return;
			}
			if (PayManager.accountInfo == null) {
				openSelectorWaiting = true;
				showPreloader();
				deactivateScreen();
				var preGiftModel:PayTaskVO = new PayTaskVO(PayTaskVO.TASK_TYPE_PAY_GIFT_BY_UID);
				preGiftModel.from_uid = Auth.uid;
				preGiftModel.handleInCustomScreenName = "CreateGiftPopup";
				preGiftModel.to_uid = giftData.user.uid;
				InvoiceManager.preProcessInvoce(preGiftModel);
			} else
				showWalletsDialog();
		}
		
		private function openWalletCreditSelector(e:Event = null):void {
			SoftKeyboard.closeKeyboard();
			if (iAmount != null)
				iAmount.forceFocusOut();
			if (PayAPIManager.hasSwissAccount == false) {
				DialogManager.alert(Lang.information, Lang.featureNoPaments, createPaymentsAccount, Lang.registrate, Lang.textCancel);
				return;
			}
			if (PayManager.accountInfo == null) {
				openCreditSelectorWaiting = true;
				showPreloader();
				deactivateScreen();
				var preGiftModel:PayTaskVO = new PayTaskVO(PayTaskVO.TASK_TYPE_PAY_GIFT_BY_UID);
				preGiftModel.from_uid = Auth.uid;
				preGiftModel.handleInCustomScreenName = "CreateGiftPopup";
				preGiftModel.to_uid = giftData.user.uid;
				InvoiceManager.preProcessInvoce(preGiftModel);
			} else
				showWalletsCreditDialog();
		}
		
		static private function createPaymentsAccount(val:int):void
		{
			if (val != 1)
			{
				return;
			}
			MobileGui.showRoadMap();
		}
		
		private function showWalletsDialog():void
		{
			var acc:Array;
			if (PayManager.accountInfo.accounts != null)
			{
				acc = PayManager.accountInfo.accounts.concat();
			}
			if (giftData == null || 
				(
				giftData.type != GiftType.GIFT_1 && 
				giftData.type != GiftType.GIFT_10 && 
				giftData.type != GiftType.GIFT_25 && 
				giftData.type != GiftType.GIFT_5 && 
				giftData.type != GiftType.GIFT_50 && 
				
				giftData.type != GiftType.FIXED_TIPS))
			{
				if (accounts != null && accounts.coinsAccounts != null && accounts.coinsAccounts.length > 0)
				{
					if (acc != null)
					{
						acc.unshift(accounts.coinsAccounts[0]);
					}
					else
					{
						acc = new Array();
						acc.push(accounts.coinsAccounts[0]);
					}
				}
			}
			
			DialogManager.showDialog(
				ListSelectionPopup,
				{
					items:acc,
					title:Lang.TEXT_SELECT_ACCOUNT,
					renderer:ListPayWalletItem,
					callback:onWalletSelect
				}, ServiceScreenManager.TYPE_SCREEN
			);
			
		//	DialogManager.showDialog(ScreenPayDialog, {callback: onWalletSelect, data: acc, itemClass: ListPayWalletItem/*ListPayAccount*/, label: Lang.TEXT_SELECT_ACCOUNT});
		}
		
		private function showWalletsCreditDialog():void
		{
			DialogManager.showDialog(
				ListSelectionPopup,
				{
					items:PayManager.accountInfo.accounts,
					title:Lang.TEXT_SELECT_ACCOUNT,
					renderer:ListPayWalletItem,
					callback:onWalletCreditSelect
				}, ServiceScreenManager.TYPE_SCREEN
			);
			
		//	DialogManager.showDialog(ScreenPayDialog, {callback: onWalletCreditSelect, data: PayManager.accountInfo.accounts, itemClass: ListPayWalletItem, label: Lang.TEXT_SELECT_ACCOUNT, additionalButton: {label: Lang.showMoreCurrencies, callback: onShowMoreCurrenciesTapped}});
		}
		
		private function onShowMoreCurrenciesTapped(list:List):void {
			if (list == null) {
				return;
			}
			if (PayManager.systemOptions && PayManager.systemOptions.currencyList) {
				var newCurrencies:Array = new Array();
				var l:int = PayManager.systemOptions.currencyList.length;
				var walletItem:Object;
				var currencyAccount:Object;
				for (var i:int = 0; i < l; i++) {
					var exist:Boolean = false;
					for (var j:int = 0; j < PayManager.accountInfo.accounts.length; j++) {
						walletItem = PayManager.accountInfo.accounts[j];
						if (PayManager.systemOptions.currencyList[i] == walletItem.CURRENCY) {
							exist = true;
						}
					}
					if (!exist) {
						currencyAccount = new Object();
						
						currencyAccount.ACCOUNT_NUMBER = PayManager.systemOptions.currencyList[i];
						currencyAccount.CURRENCY = PayManager.systemOptions.currencyList[i];
						
						newCurrencies.push(currencyAccount);
					}
				}
				for (var k:int = 0; k < newCurrencies.length; k++) {
					list.appendItem(newCurrencies[k], ListPayWalletItem);
				}
			}
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
			if (userModel == null)
			{
				preloader.y = container.y + bg.y + bg.height * .5;
			}
			view.addChild(preloader);
			preloader.show();
		}
		
		private function onWalletSelect(account:Object):void
		{
			if (account == null) return;
			walletSelected = true;
			
			selectedAccount = account;
			selectorDebitAccont.setValue(account);
			
			var currency:String;
			if ("CURRENCY" in account)
			{
				currency = account.CURRENCY;
			}
			if ("COIN" in account)
			{
				currency = account.COIN;
			}
			
			var needUpdateCurrency:Boolean = false;
			if (selfTransfer)
			{
				needUpdateCurrency = true;
			}
			if ("COIN" in account)
			{
				needUpdateCurrency = true;
			}
			if ("CURRENCY" in account && selectorCurrency != null && selectorCurrency.value == "DUK+")
			{
				if (giftData == null || giftData.currency == null)
				{
					needUpdateCurrency = true;
				}
			}
			if (needUpdateCurrency == true && selectorCurrency != null)
			{
				selectorCurrency.setValue(currency);
			}
			
			if (iAmount != null)
			{
				if (selfTransfer)
				{
					if (walletCreditSelected && iAmount.value != null && iAmount.value != "" && !isNaN(Number(iAmount.value)) && isCurrrencySelected())
					{
						acceptButton.activate();
						acceptButton.alpha = 1;
					}
				}
				else if (iAmount.value != null && iAmount.value != "" && !isNaN(Number(iAmount.value)) && isCurrrencySelected())
				{
					acceptButton.activate();
					acceptButton.alpha = 1;
				}
			}
			else
			{
				acceptButton.activate();
				acceptButton.alpha = 1;
			}
			checkWarningSelection();
			
			loadCommision();
		}
		
		private function onWalletCreditSelect(account:Object):void
		{
			if (account == null) return;
			walletCreditSelected = true;
			
			selectedCreditAccount = account;
			selectorCreditAccont.setValue(account);
			
			if (iAmount != null)
			{
				if (iAmount.value != null && iAmount.value != "" && walletSelected && !isNaN(Number(iAmount.value)) && isCurrrencySelected())
				{
					acceptButton.activate();
					acceptButton.alpha = 1;
				}
			}
			else
			{
				acceptButton.activate();
				acceptButton.alpha = 1;
			}
			checkWarningSelection();
			
			loadCommision();
		}
		
		private function loadCommision():void
		{
			needRecieveComission = false;
			if (selfTransfer == true)
			{
				drawAccountText(" ");
				return;
			}
			
			if (selectorCurrency == null || selectorCurrency.value == null || selectorCurrency.value == Lang.textChoose + "..." || selectorCurrency.value == "DUK+")
			{
				drawAccountText(" ");
				return;
			}
			needRecieveComission = true;
			_lastCommissionCallID = new Date().getTime().toString() + "gift";
			
			if (PayManager.S_SEND_MONEY_COMMISSION_RESPOND != null)
			{
				PayManager.S_SEND_MONEY_COMMISSION_RESPOND.add(onSendMoneyCommissionRespond);
			}
			
			var currency:String = TypeCurrency.EUR;
			if (giftData.type == GiftType.GIFT_X || giftData.type == GiftType.MONEY_TRANSFER || giftData.type == GiftType.MONEY_TRANSFER_CALLBACK)
			{
				currency = selectorCurrency.value;
			}
			
			var amount:Number = giftData.getValue();
			if ((giftData.type == GiftType.GIFT_X || giftData.type == GiftType.MONEY_TRANSFER || giftData.type == GiftType.MONEY_TRANSFER_CALLBACK) && iAmount != null && iAmount.value != null && iAmount.value != "" && !isNaN(Number(iAmount.value)))
			{
				amount = Number(iAmount.value);
			}
			if (amount == 0 || isNaN(amount))
			{
				drawAccountText(" ");
				return;
			}
			drawAccountText(Lang.commisionWillBe + "...");
			PayManager.callGetSendMoneyCommission(amount, currency, _lastCommissionCallID);
		}
		
		private function onSendMoneyCommissionRespond(respond:PayRespond):void {
			if (isDisposed == true) {
				return;
			}
			if (respond.error == false) {
				handleCommissionRespond(respond.savedRequestData.callID, respond.data);
			} else if (respond.hasAuthorizationError == false) {
				drawAccountText(Lang.textError + " " + respond.errorMsg);
			} else
			{
				
			}
		}
		
		private function handleCommissionRespond(callID:String, data:Object):void {
			if (_lastCommissionCallID == callID) {
				if (data != null) {
					
					needRecieveComission = false;
					
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
					
					if (selectorCurrency != null && selectorCurrency.value == "DUK+") {
						
					} else {
						drawAccountText(Lang.commisionWillBe + " " + commissionText);
					}
					
					if (data.length > 2 && "request_clarification" in data[2] && data[2].request_clarification == true)
					{
						needShowPuspoose = true;
					}
					else
					{
						needShowPuspoose = false;
					}
				}
			}
		}
		
		override public function onBack(e:Event = null):void
		{
			if (screenLocked == false)
			{
				if (currentState == STATE_COMMENTS)
				{
					toState(STATE_NEW);
				}
				else
				{
					InvoiceManager.stopProcessInvoice();
					ServiceScreenManager.closeView();
				}
			}
		}
		
		private function backClick():void
		{
			onBack();
		}
		
		private function nextClick():void
		{
			SoftKeyboard.closeKeyboard();
			if (iAmount != null)
			{
				iAmount.forceFocusOut();
			}
			
			if (currentState == STATE_NEW)
			{
				if (secureCodeManager != null && secureCodeManager.view != null && secureCodeManager.view.parent != null && compareEnterAndRepeatSC() == false) {
					return;
				}
				
				if (secureCodeManager != null && secureCodeManager.view != null && secureCodeManager.view.parent != null && secureCodeManager.code != null && secureCodeManager.code != "")
				{
					giftData.pass = secureCodeManager.code;
				}
				
				if (giftType == GiftType.GIFT_X || giftType == GiftType.MONEY_TRANSFER || giftType == GiftType.FIXED_TIPS || giftType == GiftType.MONEY_TRANSFER_CALLBACK)
				{
					if (iAmount != null && iAmount.value != null && iAmount.value != "" && !isNaN(Number(iAmount.value)) && isCurrrencySelected())
					{
						giftData.customValue = Number(iAmount.value);
						giftData.currency = selectorCurrency.value;
						if (giftData.currency == "DUK+")
						{
							giftData.currency = "DCO";
						}
					}
					else
					{
						return;
					}
				}
				else
				{
					giftData.currency = TypeCurrency.EUR;
				}
				
				if (giftData != null && giftData.commentAvaliable == false)
				{
					if (warningSwitcher != null && warningSwitcher.isSelected == false)
					{
						return;
					}
					sendGift();
				}
				else if (selfTransfer == true)
				{
					if (giftData != null && giftData.type == GiftType.MONEY_TRANSFER_CALLBACK)
					{
						if (giftData.callback != null)
						{
							if (purposeSelector != null && purposeSelector.visible == true && purposeSelector.alpha > 0 && purposeSelector.getSelected() != null && needShowPuspoose == true)
							{
								giftData.purpose = purposeSelector.getSelected();
							}
							
							giftData.accountNumber = selectedAccount.ACCOUNT_NUMBER;
							giftData.credit_account_number = selectedCreditAccount.ACCOUNT_NUMBER;
							
							giftData.debit_account_currency = selectedAccount.CURRENCY;
							giftData.credit_account_currency = selectedCreditAccount.CURRENCY;
							
							giftData.callback(giftData);
							ServiceScreenManager.closeView();
						}
					}
					else
					{
						sendGift();
					}
				}
				else
				{
					if (warningSwitcher != null && warningSwitcher.isSelected == false)
					{
						return;
					}
					showCommentsPage();
				}
			}
			else if (currentState == STATE_COMMENTS)
			{
				var purpose:String = null;
				if (purposeSelector != null && purposeSelector.visible == true && purposeSelector.alpha > 0)
				{
					if (purposeSelector.getSelected() == null)
					{
						return;
					}
					else
					{
						purpose = purposeSelector.getSelected();
					}
				}
				
				if (giftData != null && giftData.type == GiftType.MONEY_TRANSFER_CALLBACK)
				{
					if (giftData.callback != null)
					{
						giftData.accountNumber = selectedAccount.ACCOUNT_NUMBER;
						if (purposeSelector != null && purposeSelector.visible == true && purposeSelector.alpha > 0 && purposeSelector.getSelected() != null && needShowPuspoose == true)
						{
							giftData.purpose = purposeSelector.getSelected();
						}
						giftData.callback(giftData);
						ServiceScreenManager.closeView();
					}
				}
				else
				{
					if (isSimpleGift() && !isAccountAvaliable())
					{
						if (lockNextButton == false)
						{
							if (giftData != null && giftData.addConfirmDialog == true)
							{
								var alert:String = Lang.sendMoneyConfirm;
								alert = LangManager.replace(Lang.regExtValue, alert, giftData.getValue() + " " + giftData.currency);
								DialogManager.alert(Lang.sendMoneyQuestion, alert, sendmoneyConfirmSimple, Lang.okSend, Lang.textCancel, null, TextFormatAlign.LEFT, true);
								
								return;
							}
							lockNextButton = true;
							
							addLoader();
							var action:GiftByCardAction = new GiftByCardAction(giftData, isAccountAvaliable());
							action.getSuccessSignal().add(onGiftByCardSent);
							action.getFailSignal().add(onGiftByCardSentFail);
							action.execute();
						}
					}
					else
					{
						sendGift(purpose);
					}
				}
			}
			else if (currentState == STATE_GIFT_SENT)
			{
				Gifts.onGiftPopupSuccess();
				InvoiceManager.stopProcessInvoice();
				ServiceScreenManager.closeView();
			}
		
			//	Gifts.onGiftSent(giftData);
		}
		
		private function addLoader():void 
		{
			if (loader == null && container != null)
			{
				loader = new CirclePreloader();
				container.addChild(loader);
				loader.x = int(_width * .5);
				loader.y = int(container.height * .5);
			}
		}
		
		private function sendmoneyConfirmSimple(value:int):void 
		{
			if (isDisposed == true)
			{
				return;
			}
			if (value == 1)
			{
				lockNextButton = true;
				
				addLoader();

				var action:GiftByCardAction = new GiftByCardAction(giftData, isAccountAvaliable());
				action.getSuccessSignal().add(onGiftByCardSent);
				action.getFailSignal().add(onGiftByCardSentFail);
				action.execute();
			}
		}
		
		private function onGiftByCardSentFail(action:IScreenAction):void 
		{
			removeLoder();
			lockNextButton = false;
			action.dispose();
			onCloseTap();
		}
		
		private function onGiftByCardSent(action:IScreenAction):void 
		{
			removeLoder();
			lockNextButton = false;
			toState(STATE_GIFT_SENT);
			Gifts.onGiftSend(giftData);
			action.dispose();
		}
		
		private function removeLoder():void 
		{
			if (loader != null)
			{
				loader.dispose();
				if (container != null && container.contains(loader))
				{
					container.removeChild(loader);
				}
				loader = null;
			}
		}
		
		private function onAlertClose(val:int):void
		{
		
		}
		
		private function showCommentsPage():void
		{
			if (needRecieveComission == false)
			{
				toState(STATE_COMMENTS);
			}
			else
			{
				ToastMessage.display(Lang.commisssionWaiting);
			}
		}
		
		public function onTransferRespond(respond:PayRespond):void {
			if (isDisposed)
				return;
			if (respond.error == true) {
				if (respond.hasAuthorizationError == false) {
					inPaymentProcess = false;
					activateScreen();
					hidePreloader();
				}
				return;
			}
			if ("data" in respond && respond.data != null &&
				respond.data is Array && 
				respond.data.length > 1 &&
				respond.data[1] != null &&
				(respond.data[1] == "COMPLETED" || respond.data[1] == "PENDING")) {
					PayManager.S_ACCOUNT.add(onAccountInfo);
			}
		}
		
		private function onAccountInfo():void
		{
			if (currentState == STATE_GIFT_SENT && accountsUpdated == true)
			{
				if (giftData.currency == "DCO" && accounts != null && accounts.ready == false)
				{
					// update for crypto still not recieved;
					return;
				}
			}
			
			if (currentState == STATE_GIFT_SENT && accountsUpdated == false)
			{
				if (giftData.currency == "DCO")
				{
					if (accounts != null)
					{
						accountsUpdated = true;
						accounts.getData();
						return;
					}
				}
			}
			
			accountInfoLoading = false;
			if (PayManager.accountInfo != null && PayManager.accountInfo.accounts != null && selectedAccount != null)
			{
				var acc:Array;
				if (PayManager.accountInfo.accounts != null)
				{
					acc = PayManager.accountInfo.accounts.concat();
				}
				if (giftData == null || 
					(giftData.type != GiftType.GIFT_1 && 
					giftData.type != GiftType.GIFT_10 && 
					giftData.type != GiftType.GIFT_25 && 
					giftData.type != GiftType.GIFT_5 && 
					giftData.type != GiftType.GIFT_50 && 
					giftData.type != GiftType.FIXED_TIPS))
				{
					if (accounts != null && accounts.coinsAccounts != null && accounts.coinsAccounts.length > 0)
					{
						if (acc != null)
						{
							acc.unshift(accounts.coinsAccounts[0]);
						}
						else
						{
							acc = new Array();
							acc.push(accounts.coinsAccounts[0]);
						}
					}
				}
				
				var l:int = acc.length;
				for (var i:int = 0; i < l; i++)
				{
					var accountDB:ImageBitmapData;
					if (acc[i].ACCOUNT_NUMBER == selectedAccount.ACCOUNT_NUMBER)
					{
						resultAccount = selectedAccount.ACCOUNT_NUMBER;
						newAmount = Number(acc[i].BALANCE);
						
						if (footer != null && footer.bitmapData != null)
						{
							wasFinalDraw = true;
							
							accountDB = TextUtils.createTextFieldData("** " + resultAccount.substr(8), _width - Config.DIALOG_MARGIN, 10, false, TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * 0.35, false, 0xAAB8C5, 0xFBFBFB);
							
							footer.bitmapData.copyPixels(accountDB, new Rectangle(0, 0, accountDB.width, accountDB.height), accountBitmapDataPosition, null, null, true);
							accountDB.dispose();
							accountDB = null;
							
							var balance:Number = newAmount;
							balance = Math.floor(balance * 100) / 100;
							
							var currency:String;
							if (selectedAccount != null && "COIN" in selectedAccount)
							{
								currency = "DUK+"
							}
							else
							{
								currency = selectedAccount.CURRENCY;
							}
							
							var newBalanceBD:ImageBitmapData = TextUtils.createTextFieldData(Lang.textAvailable + " " + currency + " " + balance.toString(), _width - Config.DIALOG_MARGIN, 10, false, TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * 0.25, false, 0xAAB8C5, 0xFBFBFB);
							balanceFooterBDPosition = new Point(int(_width - Config.DIALOG_MARGIN - newBalanceBD.width), int(Config.DIALOG_MARGIN + Config.FINGER_SIZE * .5));
							
							footer.bitmapData.copyPixels(newBalanceBD, new Rectangle(0, 0, newBalanceBD.width, newBalanceBD.height), balanceFooterBDPosition, null, null, true);
							newBalanceBD.dispose();
							newBalanceBD = null;
						}
					}
					else if(selectedAccount != null && "COIN" in selectedAccount)
					{
						resultAccount = selectedAccount.ACCOUNT_NUMBER;
						
						if (footer != null && footer.bitmapData != null)
						{
							accountDB = TextUtils.createTextFieldData("** " + resultAccount.substr(8), _width - Config.DIALOG_MARGIN, 10, false, TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * 0.35, false, 0xAAB8C5, 0xFBFBFB);
							
							footer.bitmapData.copyPixels(accountDB, new Rectangle(0, 0, accountDB.width, accountDB.height), accountBitmapDataPosition, null, null, true);
							accountDB.dispose();
							accountDB = null;
						}
					}
				}
			}
			if (needShowCurrencies)
			{
				selectCurrency();
			}
		}
		
		private function sendGift(purpose:String = null):void
		{
			if (giftData != null && giftData.addConfirmDialog == true)
			{
				var alert:String = Lang.sendMoneyConfirm;
				alert = LangManager.replace(Lang.regExtValue, alert, giftData.getValue() + " " + giftData.currency);
				DialogManager.alert(Lang.sendMoneyQuestion, alert, sendmoneyConfirm, Lang.okSend, Lang.textCancel);
				
				return;
			}
			processSend(purpose);
		}
		
		private function processSend(purpose:String = null):void 
		{
			inPaymentProcess = true;
			showPreloader();
			deactivateScreen();
			
			if (selfTransfer)
			{
				currentPayTask = new PayTaskVO(PayTaskVO.TASK_TYPE_SELF_TRANSFER);
			}
			else
			{
				currentPayTask = new PayTaskVO(PayTaskVO.TASK_TYPE_PAY_GIFT_BY_UID);
			}
			currentPayTask.from_uid = Auth.uid;
			currentPayTask.handleInCustomScreenName = "CreateGiftPopup";
			currentPayTask.to_uid = giftData.user.uid;
			if (giftData.user.uid == null || giftData.user.uid == "" && giftData.user.phone != "" && giftData.user.phone != null)
			{
				currentPayTask.to_phone = "+" + giftData.user.phone;
				currentPayTask.taskType = PayTaskVO.TASK_TYPE_PAY_BY_PHONE;
			}
			
			currentPayTask.amount = giftData.getValue();
			currentPayTask.updateAccount = false;
			currentPayTask.currency = giftData.currency;
			currentPayTask.purpose = purpose;
			currentPayTask.pass = giftData.pass;
			
			if (currentPayTask.currency == "DUK+")
			{
				currentPayTask.currency = "DCO";
			}
			
			currentPayTask.messageText = giftData.comment;
			currentPayTask.from_wallet = selectedAccount.ACCOUNT_NUMBER;
			
			if (giftData.type == 6 && (currentPayTask.messageText == null|| currentPayTask.messageText == ""))
			{
				currentPayTask.messageText = "Transfer";
			}
			
			InvoiceManager.S_TRANSFER_RESPOND.remove(onTransferRespond);
			InvoiceManager.S_PAY_TASK_COMPLETED.remove(onGiftSent);
			
			InvoiceManager.S_TRANSFER_RESPOND.add(onTransferRespond);
			InvoiceManager.S_PAY_TASK_COMPLETED.add(onGiftSent);
			
			payId = new Date().time + "_gift";
			InvoiceManager.processInvoice(currentPayTask);
			if (selfTransfer)
			{
				currentPayTask.to_wallet = selectedCreditAccount.ACCOUNT_NUMBER;
			}
			
			InvoiceManager.sendPaymentToPayServer(currentPayTask, payId);
		}
		
		private function sendmoneyConfirm(value:int):void 
		{
			if (value == 1)
			{
				processSend();
			}
		}
		
		private function onGiftSent(task:PayTaskVO):void
		{
			inPaymentProcess = false;
			
			if (isDisposed)
				return;
			
			if (task == currentPayTask)
			{
				hidePreloader();
				screenLocked = false;
				activateScreen();
				toState(STATE_GIFT_SENT);
				
				Gifts.onGiftSend(giftData);
			}
		}
		
		//tftoken:  uth.ke
		
		override public function clearView():void
		{
			super.clearView();
			InvoiceManager.stopProcessInvoice();
		}
		
		private function toState(newState:String):void
		{
			TweenMax.killDelayedCallsTo(checkCommision);
			
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
				PointerManager.removeTap(commentsBitmapContainer, editComment);
				
				TweenMax.to(commentsBitmapContainer, hideTime, {alpha: 0});
				if (purposeSelector != null)
				{
					TweenMax.to(purposeSelector, hideTime, {alpha: 0});
					purposeSelector.deactivate();
				}
				//	TweenMax.to(acceptButton, hideTime, {alpha: 0});
				
				TweenMax.delayedCall(hideTime, hideElemetsFromState, [oldState]);
				
				TweenMax.to(acceptButton, showTime, {delay: hideTime, alpha: 1});
				//	TweenMax.to(backButton, showTime, {delay: hideTime, alpha: 1});
				TweenMax.to(giftImage, showTime, {delay: hideTime, alpha: 1});
				TweenMax.to(selectorDebitAccont, showTime, {delay: hideTime, alpha: 1});
				if (selectorCreditAccont != null)
				{
					TweenMax.to(selectorCreditAccont, showTime, {delay: hideTime, alpha: 1});
				}
				
				TweenMax.to(text, showTime, {delay: hideTime, alpha: 1});
				TweenMax.to(accountText, showTime, {delay: hideTime, alpha: 1});
				if (iAmount != null)
				{
					TweenMax.to(iAmount.view, showTime, {delay: hideTime, alpha: 1});
				}
				if (selectorCurrency != null)
				{
					TweenMax.to(selectorCurrency, showTime, {delay: hideTime, alpha: 1});
				}
				if (warningSwitcher != null)
				{
					TweenMax.to(warningSwitcher, showTime, {delay: hideTime, alpha: 1});
				}
				
				if (!isAccountAvaliable() && isSimpleGift())
				{
					secureCodeManager.view.visible = false;
				}
				else
				{
					if (secureCodeManager != null && secureCodeManager.view != null && secureCodeManager.view.parent != null)
					{
						TweenMax.to(secureCodeManager.view, showTime, {delay: hideTime, alpha: 1});
					}
				}
			}
			else if (newState == STATE_GIFT_SENT)
			{
				PointerManager.removeTap(commentsBitmapContainer, editComment);
				
				TweenMax.to(commentsBitmapContainer, hideTime, {alpha: 0});
				if (purposeSelector != null)
				{
					TweenMax.to(purposeSelector, hideTime, {alpha: 0});
					purposeSelector.deactivate();
				}
				TweenMax.to(backButton, hideTime, {alpha: 0});
				TweenMax.to(acceptButton, hideTime, {alpha: 0});
				TweenMax.to(giftImage, hideTime, {alpha: 0});
				TweenMax.to(text, hideTime, {alpha: 0});
				TweenMax.to(accountText, hideTime, {alpha: 0});
				TweenMax.to(selectorDebitAccont, hideTime, {alpha: 0});
				if (selectorCreditAccont)
				{
					TweenMax.to(selectorCreditAccont, hideTime, {alpha: 0});
				}
				
				TweenMax.delayedCall(hideTime, hideElemetsFromState, [oldState]);
				
				var finishImageHeight:int = Config.FINGER_SIZE * 2.5 + avatarSize;
				var bd:ImageBitmapData = new ImageBitmapData("CreateGiftPopup.finishImage", _width, finishImageHeight);
				var finishImageClip:Sprite = new Sprite();
				
				var colors:Array = Gifts.getColors(giftData.type);
				
				var matrix:Matrix = new Matrix();
				matrix.createGradientBox(_width, finishImageHeight, Math.PI / 2);
				finishImageClip.graphics.beginGradientFill(GradientType.LINEAR, colors, [1, 1], [0x00, 0xFF], matrix);
				finishImageClip.graphics.drawRect(0, 0, _width, finishImageHeight);
				
				if (giftData.type != GiftType.MONEY_TRANSFER && giftData.type != GiftType.FIXED_TIPS && giftData.type != GiftType.MONEY_TRANSFER_CALLBACK)
				{
					var confeti:Confeti = new Confeti();
					confeti.alpha = 0.3;
					UI.scaleToFit(confeti, _width - Config.DIALOG_MARGIN, _width - Config.DIALOG_MARGIN);
					finishImageClip.addChild(confeti);
				}
				
				var imageSource:Sprite
				
				if (giftData.type != GiftType.FIXED_TIPS)
				{
					imageSource = Gifts.getGiftImage(giftType);
				}
				
				if (imageSource != null)
				{
					UI.scaleToFit(imageSource, finishImageHeight * 1.5, finishImageHeight - Config.DOUBLE_MARGIN);
					
					finishImageClip.addChild(imageSource);
					imageSource.x = _width - imageSource.width * 0.6;
					imageSource.y = Config.MARGIN;
					
					var color:Color = new Color();
					color.setTint(colors[1], 0.20);
					imageSource.transform.colorTransform = color;
				}
				
				var finishIcon:DoneRoundIcon = new DoneRoundIcon();
				UI.scaleToFit(finishIcon, Config.FINGER_SIZE * .8, Config.FINGER_SIZE * .8);
				finishImageClip.addChild(finishIcon);
				finishIcon.x = int(_width * .5 - finishIcon.width * .5);
				finishIcon.y = Config.FINGER_SIZE * .4;
				
				bd.draw(finishImageClip);
				
				currency = "€";
				if ((giftData.type == GiftType.GIFT_X || giftData.type == GiftType.MONEY_TRANSFER || giftData.type == GiftType.FIXED_TIPS || giftData.type == GiftType.MONEY_TRANSFER_CALLBACK) && giftData.currency != TypeCurrency.EUR && giftData.currency != null && giftData.currency != "")
				{
					if (giftData.currency == "DCO")
					{
						currency = "DUK+ "
					}
					else
					{
						currency = giftData.currency + " ";
					}
				}
				
				var amountDB:ImageBitmapData = TextUtils.createTextFieldData(currency + giftData.getValue().toString(), _width - Config.DIALOG_MARGIN, 10, false, TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * 0.5, false, 0xFFFFFF, 0x999999, true);
				
				bd.copyPixels(amountDB, new Rectangle(0, 0, amountDB.width, amountDB.height), new Point(int(_width * .5 - amountDB.width * .5), int(Config.FINGER_SIZE * 1.5)), null, null, true);
				amountDB.dispose();
				amountDB = null;
				
				var successText:String;
				if (giftData.type != GiftType.MONEY_TRANSFER && giftData.type != GiftType.FIXED_TIPS && giftData.type != GiftType.MONEY_TRANSFER_CALLBACK)
				{
					successText = Lang.theGiftWasSent;
				}
				else
				{
					successText = Lang.theMoneyWasSent;
				}
				
				var thanksText:ImageBitmapData = TextUtils.createTextFieldData(successText, _width - Config.DIALOG_MARGIN, 10, false, TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * 0.27, false, 0xFFFFFF, 0x999999, true);
				
				bd.copyPixels(thanksText, new Rectangle(0, 0, thanksText.width + 100, thanksText.height), new Point(int(_width * .5 - thanksText.width * .5), int(Config.FINGER_SIZE * 2.1)), null, null, true);
				thanksText.dispose();
				thanksText = null;
				
				finishImage.bitmapData = bd;
				
				UI.destroy(confeti);
				confeti = null;
				
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
				
				if (resultAccount != null)
				{
					var accountDB:ImageBitmapData = TextUtils.createTextFieldData("** " + resultAccount.substr(8), _width - Config.DIALOG_MARGIN, 10, false, TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * 0.35, false, 0xAAB8C5, 0xFBFBFB);
					
					bdFooter.copyPixels(accountDB, new Rectangle(0, 0, accountDB.width, accountDB.height), accountBitmapDataPosition, null, null, true);
					accountDB.dispose();
					accountDB = null;
				}
				
				UI.destroy(logoClip);
				logoClip = null;
				
				currency = "";
				
				if (giftData.type == GiftType.GIFT_X || giftData.type == GiftType.MONEY_TRANSFER || giftData.type == GiftType.MONEY_TRANSFER_CALLBACK)
				{
					if (selectorCurrency.value == TypeCurrency.EUR)
					{
						currency = "€";
					}
					else
					{
						currency = selectorCurrency.value + " ";
					}
				}
				else if (giftData.type == GiftType.FIXED_TIPS)
				{
					if (giftData.currency == TypeCurrency.EUR)
					{
						currency = "€";
					}
					else
					{
						currency = giftData.currency + " ";
					}
				}
				else
				{
					currency = "€";
				}
				
				var minus:Number = giftData.getValue() + currentCommision;
				minus = Math.floor(minus * 100) / 100;
				
				var payValueBD:ImageBitmapData = TextUtils.createTextFieldData("-" + currency + minus.toString(), _width - Config.DIALOG_MARGIN, 10, false, TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * 0.4, false, 0xEAA6A7, 0xFBFBFB);
				
				bdFooter.copyPixels(payValueBD, new Rectangle(0, 0, payValueBD.width, payValueBD.height), new Point(int(_width - Config.DIALOG_MARGIN - payValueBD.width), int(Config.DIALOG_MARGIN)), null, null, true);
				payValueBD.dispose();
				payValueBD = null;
				
				if (!isNaN(newAmount))
				{
					var balance:Number = newAmount;
					balance = Math.floor(balance * 100) / 100;
					var newBalanceBD:ImageBitmapData = TextUtils.createTextFieldData(Lang.textAvailable + " " + selectedAccount.CURRENCY + " " + balance.toString(), _width - Config.DIALOG_MARGIN, 10, false, TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * 0.25, false, 0xAAB8C5, 0xFBFBFB);
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
				
			//	bg.height = footer.y + footer.height;
			//	container.y = _height - bg.height - Config.DIALOG_MARGIN;
				bg.height = position + Config.FINGER_SIZE * 1.7;
				footer.y = int(bg.y + bg.height - finishFooterMask.height);
				
				container.y = _height - bg.height - bg.y;
				
				finishFooterMask.y = bg.y + bg.height;
				TweenMax.to(finishFooterMask, resizeTime * 5, {y: bg.y + bg.height - finishFooterMask.height, delay: hideTime, ease: Power3.easeInOut});
				
				var resizeTime:Number = 0.8;
				//	TweenMax.to(bg, resizeTime, { height:newBackHight, delay:hideTime } );
				TweenMax.to(finishImageMask, resizeTime, {height: finishImageHeight, delay: hideTime, onUpdate: repositionElements, ease: Power3.easeInOut});
				
				TweenMax.to(acceptButton, showTime, {alpha: 1, delay: (hideTime + resizeTime), onComplete: activateAcceptButton, onStart: repositionAcceptButton});
				
			}
			else if (newState == STATE_COMMENTS)
			{
				TweenMax.to(giftImage, hideTime, {alpha: 0});
				TweenMax.to(text, hideTime, {alpha: 0});
				TweenMax.to(accountText, hideTime, {alpha: 0});
				TweenMax.to(selectorDebitAccont, hideTime, {alpha: 0});
				if (warningSwitcher != null)
				{
					TweenMax.to(warningSwitcher, hideTime, {alpha: 0});
				}
				if (selectorCreditAccont)
				{
					TweenMax.to((selectorCreditAccont), hideTime, {alpha: 0});
				}
				
				if (iAmount != null)
				{
					TweenMax.to(iAmount.view, hideTime, {alpha: 0});
				}
				
				if (secureCodeManager != null && secureCodeManager.view != null && secureCodeManager.view.parent != null)
				{
					TweenMax.to(secureCodeManager.view, hideTime, {alpha: 0});
				}
				
				if (selectorCurrency != null)
				{
					TweenMax.to(selectorCurrency, hideTime, {alpha: 0});
				}
				
				TweenMax.delayedCall(hideTime, hideElemetsFromState, [oldState]);
				
				if (needShowPuspoose == true)
				{
					if (purposeSelector == null)
					{
						purposeSelector = new SelectorButton(onPurposeSelected, getTransferPurposes(), Lang.SPECIFY_PURPOSE_OF_MONEY_TRANSFER_TITLE);
						purposeSelector.activate();
						purposeSelector.setSize(_width - Config.DIALOG_MARGIN * 2);
						container.addChild(purposeSelector);
						purposeSelector.x = Config.DIALOG_MARGIN;
					}
					else
					{
						purposeSelector.visible = true;
						purposeSelector.alpha = 1;
						purposeSelector.reset();
						purposeSelector.activate();
					}
				}
				else
				{
					if (purposeSelector != null)
					{
						if (container.contains(purposeSelector))
						{
							container.removeChild(purposeSelector);
							purposeSelector.dispose();
							purposeSelector = null;
						}
					}
				}
				
				if (giftData.comment != null && giftData.comment != "")
				{
					updateComments(giftData.comment);
				}
				else
				{
					updateComments(null);
				}
				
				commentsBitmapContainer.alpha = 0;
				commentsBitmapContainer.visible = true;
				
				TweenMax.to(commentsBitmapContainer, showTime, {alpha: 1, delay: hideTime, onComplete: activateButtons});
			}
		}
		
		private function onPurposeSelected():void 
		{
			
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
		
		private function activateButtons():void
		{
			PointerManager.addTap(commentsBitmapContainer, editComment);
			
			activateBackButton();
			activateAcceptButton();
		}
		
		private function editComment(e:MouseEvent):void
		{
			currentTextEditor = new FullscreenTextEditor();
			currentTextEditor.editText(giftData.comment, onCommentEditResult);
		}
		
		private function onCommentEditResult(isAccepted:Boolean, result:String = null):void
		{
			if (isAccepted)
			{
				updateComments(result);
			}
			currentTextEditor.dispose();
			currentTextEditor = null;
		}
		
		private function updateComments(result:String):void
		{
			var position:int = 0;
			var commentsBD:ImageBitmapData
			
			if (result == null || result == "")
			{
				var textSettings:TextFieldSettings = new TextFieldSettings(Lang.addComment, 0x75BB25, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
				commentsBD = TextUtils.createbutton(textSettings, 0xFFFFFF, 1, Config.FINGER_SIZE * .5, 0x75BB25);
				
				if (commentsBitmap.bitmapData != null)
				{
					commentsBitmap.bitmapData.dispose();
					commentsBitmap.bitmapData = null;
				}
				commentsBitmap.bitmapData = commentsBD;
				commentsBitmapContainer.x = int(_width * .5 - commentsBitmap.width * .5);
				
				position = 0;
				if (giftData.user.login != null || (giftData.user.phone != null && giftData.user.phone != ""))
				{
					position = (acceptButton.y - fxName.y - fxName.height) * .5 + fxName.y - commentsBitmap.height * .5;
				}
				else
				{
					position = (acceptButton.y - userName.y - userName.height) * .5 + userName.y - commentsBitmap.height * .5;
				}
				
				if (purposeSelector != null)
				{
					if (giftData.user.login != null || (giftData.user.phone != null && giftData.user.phone != ""))
					{
						position = fxName.y + fxName.height + Config.FINGER_SIZE * .4;
					}
					else
					{
						position = userName.y + userName.height + Config.FINGER_SIZE * .4;
					}
					purposeSelector.y = position;
					position += purposeSelector.height + Config.FINGER_SIZE * .4;
				}
				
				commentsBitmapContainer.y = position;
			}
			else
			{
				giftData.comment = result;
				commentsBitmapContainer.x = Config.DIALOG_MARGIN;
				var text:String = "<font color='#7E95A8' size='" + Config.FINGER_SIZE * 0.25 + "'>" + Lang.yourComment + "</font><br/>" + giftData.comment;
				
				var commentsHeight:int = Config.FINGER_SIZE * 3;
				var commentPosition:int = Config.DIALOG_MARGIN;
				
				if (giftData.user.login != null || (giftData.user.phone != null && giftData.user.phone != ""))
				{
					commentPosition = fxName.y + fxName.height + Config.DIALOG_MARGIN;
				}
				else
				{
					commentPosition = userName.y + userName.height + Config.DIALOG_MARGIN;
				}
				
				if (purposeSelector != null)
				{
					if (giftData.user.login != null || (giftData.user.phone != null && giftData.user.phone != ""))
					{
						position = fxName.y + fxName.height + Config.FINGER_SIZE * .4;
					}
					else
					{
						position = userName.y + userName.height + Config.FINGER_SIZE * .4;
					}
					purposeSelector.y = position;
					
					commentsHeight = acceptButton.y - purposeSelector.y - purposeSelector.height - Config.FINGER_SIZE;
					commentPosition = purposeSelector.y + purposeSelector.height + Config.FINGER_SIZE * .3;
				}
				
				commentsBD = TextUtils.createTextFieldData(text, _width - Config.DIALOG_MARGIN * 2, commentsHeight, true, TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .37, true, 0, 0xFFFFFF, false, true);
				if (commentsBitmap.bitmapData != null)
				{
					commentsBitmap.bitmapData.dispose();
					commentsBitmap.bitmapData = null;
				}
				commentsBitmap.bitmapData = commentsBD;
				
				commentsBitmapContainer.y = commentPosition;
			}
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
		
		private function repositionAcceptButton():void
		{
			drawAcceptButton(Lang.done);
			acceptButton.y = bg.height - Config.MARGIN * 1.5 * 1.8 - acceptButton.height + avatarSize;
			acceptButton.x = int(_width * .5 - acceptButton.width * .5);
		}
		
		private function hideElemetsFromState(state:String):void
		{
			screenLocked = false;
			if (state == STATE_NEW)
			{
				giftImage.visible = false;
				selectorDebitAccont.visible = false;
				selectorDebitAccont.deactivate();
				
				if (selectorCreditAccont)
				{
					selectorCreditAccont.visible = false;
					selectorCreditAccont.deactivate();
				}
				/*if (purposeSelector != null)
				{
					purposeSelector.visible = false;
					purposeSelector.deactivate();
				}*/
				text.visible = false;
				accountText.visible = false;
				
				if (iAmount != null)
				{
					iAmount.deactivate();
					iAmount.view.visible = false;
				}
				if (selectorCurrency != null)
				{
					selectorCurrency.deactivate();
					selectorCurrency.visible = false;
				}
				if (secureCodeManager != null && secureCodeManager.view != null && secureCodeManager.view.parent != null)
				{
					secureCodeManager.view.visible = false;
				}
			}
			else if (state == STATE_COMMENTS)
			{
				commentsBitmapContainer.visible = false;
				
				if (currentState == STATE_NEW)
				{
					drawAcceptButton(Lang.textNext);
					acceptButton.visible = true;
					backButton.visible = true;
					
					acceptButton.activate();
					backButton.activate();
					
					giftImage.visible = true;
					selectorDebitAccont.visible = true;
					selectorDebitAccont.activate();
					if (selectorCreditAccont)
					{
						selectorCreditAccont.visible = true;
						selectorCreditAccont.activate();
					}
					if (purposeSelector != null)
					{
						purposeSelector.visible = false;
						purposeSelector.deactivate();
					}
					
					text.visible = true;
					accountText.visible = true;
					if (iAmount != null)
					{
						if (lockedAmount == false)
						{
							iAmount.activate();
						}
						iAmount.view.visible = true;
					}
					if (selectorCurrency != null)
					{
						if (lockedAmount == false)
						{
							selectorCurrency.activate();
						}
						
						selectorCurrency.visible = true;
					}
					if (secureCodeManager != null && secureCodeManager.view != null && secureCodeManager.view.parent != null)
					{
						secureCodeManager.view.visible = true;
					}
					
					if (isAccountAvaliable() == false && isSimpleGift() == true)
					{
						selectorDebitAccont.visible = false;
						accountText.visible = false;
					}
				}
				else
				{
					backButton.deactivate();
					backButton.visible = false;
				}
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
			checkWarningSelection();
		}
		
		private function repositionElements():void
		{
			avatar.y = finishImageMask.height;
			
			userName.y = avatar.y + verticalMargin + avatarSize * 2;
			
			if (userModel.login != null)
			{
				fxName.y = userName.height + userName.y + verticalMargin * .5;
			}
		}
		
		private function drawAvatar():void
		{
			var avatarUrl:String = userModel.getAvatarURLProfile(avatarSize);
			
			if (receiverSecret == true)
			{
				avatarUrl = LocalAvatars.SECRET;
			}
			
			avatar.x = int(_width * .5 - avatarSize);
			avatar.y = 0;
			
			if (avatarUrl != null && avatarUrl != "")
			{
				var path:String;
				
				//!TODO: можно складывать все загруженные на данный момент аватарки относящиеся к пользователю в один менеджер и выбирать наиболее подходящую;
				var smallAvatarImage:ImageBitmapData;
				if (!smallAvatarImage)
				{
					//берём маленькую аватарку из списка контактов;
					path = UsersManager.getAvatarImage(userModel, avatarUrl, int(Config.FINGER_SIZE * .7), 3);
					smallAvatarImage = ImageManager.getImageFromCache(path);
				}
				if (!smallAvatarImage)
				{
					//берём маленькую аватарку по умолчанию (размер 60px если она из коммуны);
					smallAvatarImage = ImageManager.getImageFromCache(avatarUrl);
				}
				
				if (smallAvatarImage)
				{
					avatarBD = new ImageBitmapData("CreateGiftPopup.LOADED_AVATAR_BMD", avatarSize * 2, avatarSize * 2);
					ImageManager.drawCircleImageToBitmap(avatarBD, smallAvatarImage, 0, 0, int(avatarSize));
					avatar.bitmapData = avatarBD;
				}
				else
				{
					path = UsersManager.getAvatarImage(userModel, avatarUrl, avatarSize * 2, 3, false);
					ImageManager.loadImage(path, onAvatarLoaded);
				}
			}
			else
			{
				//!TODO;
			}
		}
		
		private function onAvatarLoaded(url:String, bmd:ImageBitmapData, success:Boolean):void
		{
			if (isDisposed)
			{
				return;
			}
			
			if (!success)
			{
				return;
			}
			if (bmd)
			{
				avatarBD = new ImageBitmapData("CreateGiftPopup.LOADED_AVATAR_BMD", avatarSize * 2, avatarSize * 2);
				ImageManager.drawCircleImageToBitmap(avatarBD, bmd, 0, 0, int(avatarSize));
				avatar.alpha = 0;
				TweenMax.to(avatar, 0.5, {alpha: 1});
				avatar.bitmapData = avatarBD;
			}
		}
		
		override public function initScreen(data:Object = null):void
		{
			super.initScreen(data);
			
			InvoiceManager.isProcessingInvoice = true;
			
			if (data != null && "receiverSecret" in data)
			{
				receiverSecret = data.receiverSecret;
			}
			
			if (data != null && "user" in data && data.user != null)
			{
				if (data.user is UserVO)
				{
					userModel = data.user as UserVO;
				}
				else if(data.user is String)
				{
					userModel = UsersManager.getUserByUID(data.user);
					if (userModel == null)
					{
						UsersManager.S_USERS_FULL_DATA.add(onusersLoaded);
						UsersManager.getFullUserData(data.user, true);
					}
				}
			}
			
			if (data != null && "giftType" in data && data.giftType is int)
			{
				giftType = data.giftType as int;
			}
			
			if (data != null && "giftData" in data && data.giftData is GiftData)
			{
				giftData = data.giftData as GiftData;
			}
			
			if (giftType == GiftType.FIXED_TIPS)
			{
				lockedAmount = true;
			}
			
			/*if (userModel == null)
			{
				ServiceScreenManager.closeView();
				
				ApplicationErrors.add("empty userModel");
				return;
			}*/
			
			componentsWidth = _width - Config.DIALOG_MARGIN * 2;
			
			if (giftData == null)
			{
				giftData = new GiftData();
			}
			
			giftData.user = userModel;
			giftData.type = giftType;
			
			if (userModel == null)
			{
				showPreloader();
			//	preloader.y = container.y + bg.y + bg.height * .5;
				return;
			}
			
			construct();
		}
		
		private function construct():void 
		{
			selfTransfer = (giftData.type == GiftType.MONEY_TRANSFER || giftData.type == GiftType.MONEY_TRANSFER_CALLBACK) && (Auth.uid == giftData.user.uid);
			if (selfTransfer == true)
			{
				selectorCreditAccont = new DDAccountButton(openWalletCreditSelector);
				container.addChild(selectorCreditAccont);
			}
			
			if (giftData != null && giftData.addConfirmDialog == true && warningSwitcher == null)
			{
				warningSwitcher = new OptionSwitcher();
				warningSwitcher.onSwitchCallback = warningSwitcherCallback;
				warningSwitcher.create(componentsWidth, Config.FINGER_SIZE * .8, null, Lang.confirmSendMoney);
				container.addChild(warningSwitcher);
				warningSwitcher.x = Config.DIALOG_MARGIN;
			}
			
			drawGift();
			drawAvatar();
			drawUserName();
			drawFxName();
			drawText();
			drawAccountSelector();
			if (selfTransfer == true)
			{
				drawAccountCreditSelector();
			}
			drawAccountText(Lang.chooseAccount);
			drawAcceptButton(Lang.textNext);
			acceptButton.deactivate();
			acceptButton.alpha = 0.5;
			
			drawBackButton();
			
			InvoiceManager.S_ACCOUNT_READY.add(onWalletsReady);
			InvoiceManager.S_STOP_PROCESS_INVOICE.add(onStopProcess);
			InvoiceManager.S_ERROR_PROCESS_INVOICE.add(onStopProcess);
			InvoiceManager.S_START_TRANSFER.add(onTransferStart);
			
			GD.S_PAYPASS_BACK_CLICK.add(onPayPassBackClick);
			
			accounts = new PaymentsAccountsProvider(onAccountsDataReady, true);
			if (accounts.ready == false)
			{
				accounts.getData();
			}
			
			if (giftData.type == GiftType.GIFT_X || giftData.type == GiftType.MONEY_TRANSFER || giftData.type == GiftType.MONEY_TRANSFER_CALLBACK)
			{
				iAmount = new Input(Input.MODE_DIGIT_DECIMAL);
				iAmount.setParams(Lang.textAmount, Input.MODE_DIGIT_DECIMAL);
				
				iAmount.S_CHANGED.add(onChangeInputValue);
				
				iAmount.setRoundBG(false);
				iAmount.getTextField().textColor = Style.color(Style.COLOR_TEXT);
				iAmount.setRoundRectangleRadius(0);
				iAmount.inUse = true;
				container.addChild(iAmount.view);
				
				var itemWidth:int = (componentsWidth - Config.MARGIN) / 2;
				
				iAmount.width = itemWidth;
				iAmount.view.x = Config.DIALOG_MARGIN;
				
				selectorCurrency = new DDFieldButton(selectCurrencyTap);
				if (selfTransfer)
				{
					selectorCurrency.setValue(Lang.currency);
				}
				container.addChild(selectorCurrency);
				selectorCurrency.x = iAmount.view.x + itemWidth + Config.MARGIN;
				selectorCurrency.setSize(itemWidth, Config.FINGER_SIZE * .8);
				
				if (lockedAmount == true || giftData.type == GiftType.MONEY_TRANSFER_CALLBACK)
				{
					if (!isNaN(giftData.customValue) && giftData.customValue > 0 && giftData.currency != null)
					{
						iAmount.value = giftData.customValue.toString();
						iAmount.deactivate();
					}
					if (giftData.currency != null)
					{
						selectorCurrency.setValue(giftData.currency);
						selectorCurrency.deactivate();
					}
				}
				
				if (!isNaN(giftData.minAmount))
				{
					iAmount.value = giftData.minAmount.toString();
				}
				
				if (PayManager.systemOptions != null && "currencyList" in PayManager.systemOptions)
				{
					onSystemOptions();
				}
				else
				{
					if (PayManager.S_SYSTEM_OPTIONS_READY == null)
					{
						PayManager.S_SYSTEM_OPTIONS_READY = new Signal("PayManager.S_SYSTEM_OPTIONS_READY");
					}
					if (PayManager.S_SYSTEM_OPTIONS_ERROR == null)
					{
						PayManager.S_SYSTEM_OPTIONS_ERROR = new Signal("PayManager.S_SYSTEM_OPTIONS_ERROR");
					}
					PayManager.S_SYSTEM_OPTIONS_READY.add(onSystemOptions);
					PayManager.S_SYSTEM_OPTIONS_ERROR.add(onSystemOptionsError);
					
					callBackGetConfig();
				}
			}
			
			if ((giftData.type == GiftType.MONEY_TRANSFER || giftData.type == GiftType.MONEY_TRANSFER_CALLBACK) && Config.SECURE_MONEY_SEND == true)
			{
				container.addChild(secureCodeManager.view);
				//!
				secureCodeManager.initView(false, null);
				secureCodeManager.callbackFunc = callbackSC;
			}
			
			getAccounts();
		}
		
		private function onSystemOptionsError():void {
			ToastMessage.display(Lang.serverError);
			onBack();
		}
		
		private function warningSwitcherCallback(selected:Boolean):void {
			warningSwitcher.isSelected = selected;
			onChangeInputValue();
		}
		
		private function onusersLoaded():void {
			if (_isDisposed == true) {
				return;
			}
			if (data != null && data.user != null) {
				var user:UserVO = UsersManager.getUserByUID(data.user);
				if (user != null) {
					UsersManager.S_USERS_FULL_DATA.add(onusersLoaded);
					userModel = user;
					giftData.user = user;
					
					drawAvatar();
					drawUserName();
					drawFxName();
					hidePreloader();
					construct();
					drawView();
				}
			}
			else
			{
				ToastMessage.display(Lang.textError);
				onCloseTap();
			}
		}
		
		private function callbackSC():void {
			drawView();
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

		private function onPayPassBackClick():void{
			onBack();
		}
		
		private function getAccounts():void 
		{
			/*if (PayManager.accountInfo == null) {
				openSelectorWaiting = true;
				showPreloader();
				deactivateScreen();
				var preGiftModel:PayTaskVO = new PayTaskVO(PayTaskVO.TASK_TYPE_PAY_GIFT_BY_UID);
				preGiftModel.from_uid = Auth.uid;
				preGiftModel.handleInCustomScreenName = "CreateGiftPopup";
				preGiftModel.to_uid = giftData.user.uid;
				preGiftModel.showNoAccountAlert = false;
				InvoiceManager.preProcessInvoce(preGiftModel);
			}*/
		}
		
		private function onAccountsDataReady():void 
		{
			if (isDisposed)
			{
				return;
			}
			if (currentState == STATE_GIFT_SENT)
			{
				if (giftData.currency == "DCO")
				{
					onAccountInfo();
				}
			}
			else if (currentState == STATE_NEW)
			{
				if (giftData != null && giftData.currency == "DCO")
				{
					selectAccount("DCO");
				} else {
					onWalletsReady();
				}
			}
			
		//	trace("onAccountsDataReady");
		}
		
		private function onTransferStart():void
		{
			if (isDisposed)
			{
				return;
			}
			if (preloaderShown == false)
			{
				showPreloader();
				deactivateScreen();
			}
		}
		
		private function callBackGetConfig():void
		{
			PayManager.callGetSystemOptions();
		}
		
		private function onSystemOptions():void
		{
			if (PayManager.systemOptions != null && "currencyList" in PayManager.systemOptions)
			{
				if (needShowCurrencies)
				{
					selectCurrency();
				}
				else
				{
					var str:String = "";
					str = "DCO";
					if (giftData != null && giftData.currency != null && giftData.currency == "DCO")
					{
						localSelectCurrency(str);
						selectAccount(str);
					}
					else
					{
						for each (str in PayManager.systemOptions.currencyList)
						{
							localSelectCurrency(str);
							selectAccount(str);
							break;
						}
					}
				}
				
				if (lockedAmount == false)
				{
					selectorCurrency.activate();
				}
			}
			else
			{
				hidePreloader();
				activateScreen();
				screenLocked = false;
				
				if (PayManager.accountInfo == null)
				{
					showPreloader();
					deactivateScreen();
					var preGiftModel:PayTaskVO = new PayTaskVO(PayTaskVO.TASK_TYPE_PAY_GIFT_BY_UID);
					preGiftModel.from_uid = Auth.uid;
					preGiftModel.handleInCustomScreenName = "CreateGiftPopup";
					preGiftModel.to_uid = giftData.user.uid;
					InvoiceManager.preProcessInvoce(preGiftModel);
				}
				
				ToastMessage.display(Lang.wrongTimeOnDevice);
			}
		}
		
		private function selectCurrencyTap():void
		{
			needShowCurrencies = true;
			selectCurrency();
		}
		
		private function selectCurrency(e:Event = null):void
		{
			// redraw view to full height to prevent soft keyboard view resizing bug
			//	saveTemp();
			//	deactivateScreen();
			
			/*if (selfTransfer)
			   {
			   return;
			   }*/
			
			if (selfTransfer)
			{
					if (PayAPIManager.hasSwissAccount == false)
					{
						DialogManager.alert(Lang.information, Lang.featureNoPaments, createPaymentsAccount, Lang.registrate, Lang.textCancel);
						return;
					}
				
				if (PayManager.systemOptions == null)
				{
					callBackGetConfig();
					return;
				}
				
				if (PayManager.accountInfo == null)
				{
					if (accountInfoLoading == false)
					{
						accountInfoLoading = true;
						
						showPreloader();
						deactivateScreen();
						var preGiftModel:PayTaskVO = new PayTaskVO(PayTaskVO.TASK_TYPE_PAY_GIFT_BY_UID);
						preGiftModel.from_uid = Auth.uid;
						preGiftModel.handleInCustomScreenName = "CreateGiftPopup";
						preGiftModel.to_uid = giftData.user.uid;
						
						InvoiceManager.preProcessInvoce(preGiftModel);
					}
				}
				else
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
				return;
			}
			
			if (PayManager.systemOptions != null && needShowCurrencies)
			{
				needShowCurrencies = false;
				
				var curr:Array = PayManager.systemOptions.currencyList.concat();
				if (accounts != null && accounts.ready && accounts.coinsAccounts != null && accounts.coinsAccounts.length > 0)
				{
					var currency:String = accounts.coinsAccounts[0].COIN;
					/*if (Lang[currency] != null)
					{
						currency = Lang[currency];
					}*/
					curr.unshift(currency)
				}
				
				DialogManager.showDialog(
					ListSelectionPopup,
					{
						items:curr,
						title:Lang.selectCurrency,
						renderer:ListPayCurrency,
						callback:callBackSelectCurrency
					}, ServiceScreenManager.TYPE_SCREEN
				);
				
			//	DialogManager.showDialog(ScreenPayDialog, {callback: callBackSelectCurrency, data: curr, itemClass: ListPayCurrency, label: Lang.selectCurrency});
			}
			
			onChangeInputValue();
		}
		
		private function localSelectCurrency(currency:String):void
		{
			if (selectorCurrency != null && lockedAmount == false)
			{
				if (giftData.type == GiftType.MONEY_TRANSFER_CALLBACK)
				{
					if (giftData != null && giftData.currency == null)
					{
						selectorCurrency.setValue(currency);
						selectorCurrency.activate();
					}
				}
				else
				{
					selectorCurrency.setValue(currency);
					selectorCurrency.activate();
				}
			}
			else
			{
				if (!selfTransfer)
				{
					selectCurrency();
				}
			}
		}
		
		private function callBackSelectCurrency(currency:String):void
		{
			if (selectorCurrency != null && currency != null && lockedAmount == false)
			{
				selectorCurrency.setValue(currency);
				if (selfTransfer || currency == "DCO")
				{
					selectAccount(currency);
				}
				else if (selectedAccount != null && "COIN" in selectedAccount && currency != "DCO")
				{
					selectAccount(currency);
				}
				else if (giftData != null && giftData.type == GiftType.GIFT_X)
				{
					selectAccount(currency);
				}
				checkCommision();
			}
			onChangeInputValue();
		}
		
		private function selectAccount(currency:String):void
		{
			if (PayManager.accountInfo && PayManager.accountInfo.accounts)
			{
				var defaultAccount:Object;
				
				var currencyNeeded:String = currency;
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
			if (currency == "DCO")
			{
				if (accounts != null && accounts.ready && accounts.coinsAccounts != null && accounts.coinsAccounts.length > 0)
				{
					defaultAccount = accounts.coinsAccounts[0];
					onWalletSelect(accounts.coinsAccounts[0]);
				}
			}
			else if(selectedAccount != null && "COIN" in selectedAccount)
			{
				//!TODO:;
			}
		}
		
		private function showToastMessage():void
		{
			ToastMessage.display(Lang.connectionError);
		}
		
		private function onChangeInputValue(updateCommission:Boolean = true):void
		{
			if (updateCommission == true)
			{
				checkCommision();
			}
			
			if (iAmount != null && isCurrrencySelected() && iAmount.value != null && iAmount.value != "" && !isNaN(Number(iAmount.value)) && Number(iAmount.value) > 0)
			{
				// walet selected only when payments account exists
				if (!isAccountAvaliable())
				{
					if (acceptButton != null)
					{
						acceptButton.activate();
						acceptButton.alpha = 1;
					}
				}
				else if (acceptButton != null && walletSelected == true)
				{
					acceptButton.activate();
					acceptButton.alpha = 1;
				}
			}
			else
			{
				if (acceptButton != null)
				{
					acceptButton.deactivate();
					acceptButton.alpha = 0.5;
				}
			}
			checkWarningSelection();
		}
		
		private function checkWarningSelection():void 
		{
			if (giftData != null && giftData.addConfirmDialog == true)
			{
				if (warningSwitcher != null)
				{
					if (warningSwitcher.isSelected == false)
					{
						acceptButton.deactivate();
						acceptButton.alpha = 0.5;
					}
				}
			}
		}
		
		private function isCurrrencySelected():Boolean
		{
			if (selectorCurrency != null && selectorCurrency.value != null && selectorCurrency.value != selectorCurrency.placeholder && selectorCurrency.value != "")
			{
				return true;
			}
			return false;
		}
		
		private function checkCommision(immidiate:Boolean = false):void
		{
			needShowPuspoose = false;
			_lastCommissionCallID = null;
			//trace("checkCommision", selectorCurrency.value);
			if (selfTransfer == true || (selectorCurrency != null && selectorCurrency.value == "DUK+"))
			{
				drawAccountText(" ");
				return;
			}
			
			currentCommision = 0;
			TweenMax.killDelayedCallsTo(checkCommision);
			
			var needUpdate:Boolean = true;
			
			if (giftData.type == GiftType.GIFT_X || giftData.type == GiftType.MONEY_TRANSFER || giftData.type == GiftType.FIXED_TIPS || giftData.type == GiftType.MONEY_TRANSFER_CALLBACK)
			{
				if (iAmount != null && isCurrrencySelected() && iAmount.value != null && iAmount.value != "" && !isNaN(Number(iAmount.value)) && Number(iAmount.value) > 0)
				{
					needUpdate = true;
				}
			}
			else
			{
				if (walletSelected)
				{
					needUpdate = true;
				}
			}
			
			if (walletSelected == false)
			{
				needUpdate = false;
			}
			if (selfTransfer && walletCreditSelected == false)
			{
				needUpdate = false;
			}
			
			if (!isAccountAvaliable())
			{
				needUpdate = false;
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
			else
			{
				needRecieveComission = false;
			}
		}
		
		private function onStopProcess():void{
			if (isDisposed)
				return;
			
			inPaymentProcess = false;
			hidePreloader();
			activateScreen();
		}
		
		private function onWalletsReady():void
		{
			if (isDisposed)
				return;
			
			if (selectorCurrency != null && (selectorCurrency.value == null || selectorCurrency.value == "" || selectorCurrency.value == selectorCurrency.placeholder || selectorCurrency.value == Lang.currency))
			{
				onSystemOptions();
			}
			
			activateScreen();
			hidePreloader();
			if (currentState == STATE_NEW)
			{
				setDefaultWallet();
			}
			
			InvoiceManager.S_ACCOUNT_READY.remove(onWalletsReady);
		}
		
		private function hidePreloader():void
		{
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
			if (defaultAccount != null && !selfTransfer)
			{
				if (giftData != null && giftData.currency == "DCO" && ("COIN" in defaultAccount) == false)
				{
					return;
				}
				
				onWalletSelect(defaultAccount);
			}
			else
			{
				if (currentState != STATE_GIFT_SENT)
				{
					if (openCreditSelectorWaiting)
					{
						openCreditSelectorWaiting = false;
						showWalletsCreditDialog();
					}
					else
					{
						if (openSelectorWaiting)
						{
							openSelectorWaiting = false
							showWalletsDialog();
						}
					}
				}
			}
		}
		
		private function drawAccountSelector():void
		{
			selectorDebitAccont.setSize(componentsWidth, Config.FINGER_SIZE * .8);
			if (selfTransfer)
			{
				selectorDebitAccont.setValue(Lang.from);
			}
			else
			{
				selectorDebitAccont.setValue(Lang.walletToCharge);
			}
			
			selectorDebitAccont.x = Config.DIALOG_MARGIN;
			
			if (!isAccountAvaliable() && isSimpleGift())
			{
				activateAcceptButton();
				selectorDebitAccont.visible = false;
				accountText.visible = false;
				secureCodeManager.view.visible = false;
			}
		}
		
		private function drawAccountCreditSelector():void
		{
			selectorCreditAccont.setSize(componentsWidth, Config.FINGER_SIZE * .8);
			selectorCreditAccont.setValue(Lang.to);
			selectorCreditAccont.x = Config.DIALOG_MARGIN;
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
			accountText.bitmapData = TextUtils.createTextFieldData(text, componentsWidth, 10, true, TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .27, true, 0xABB8C1, 0xffffff, false);
			
			accountText.x = int(_width * .5 - accountText.width * .5);
		}
		
		private function drawText():void
		{
			if (giftData.type == GiftType.GIFT_X || giftData.type == GiftType.MONEY_TRANSFER || giftData.type == GiftType.MONEY_TRANSFER_CALLBACK)
			{
				text.visible = false;
			}
			else
			{
				var str:String;
				
				if (giftData.type == GiftType.FIXED_TIPS)
				{
					str = Lang.rewardForAnswers;
				}
				else
				{
					str = Lang.youPraiseUserWith;
				}
				
				var userNameText:String;
				if (receiverSecret == true)
				{
					userNameText = Lang.textIncognito;
				}
				else
				{
					userNameText = userModel.getDisplayName();
				}
				
				if (giftData.type == GiftType.FIXED_TIPS)
				{
					str = LangManager.replace(Lang.regExtValue, str, "<font color='#2D384E'>" + giftData.getValue().toString() + " " + giftData.currency + "</font>");
					str = LangManager.replace(Lang.regExtValue, str, "<font color='#2D384E'>" + userNameText + "</font>");
				}
				else
				{
					str = LangManager.replace(Lang.regExtValue, str, "<font color='#2D384E'>" + userNameText + "</font>");
					str = LangManager.replace(Lang.regExtValue, str, "<font color='#2D384E'>€" + giftData.getValue().toString() + "</font>");
				}
				
				text.bitmapData = TextUtils.createTextFieldData(str, componentsWidth, 10, true, TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .3, true, 0xABB8C1, 0xffffff, false, true);
				
				text.x = int(_width * .5 - text.width * .5);
			}
		}
		
		private function drawFxName():void
		{
			if (receiverSecret == true)
				return;
			
			var fxNameText:String;
			if (userModel.phone != null && userModel.phone != "")
			{
				fxNameText = "+" + userModel.phone;
			}
			else if (userModel.login != null)
			{
				fxNameText = userModel.login;
			}
			
			if (fxNameText != null)
			{
				fxName.bitmapData = TextUtils.createTextFieldData(fxNameText, componentsWidth, 10, false, TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .30, false, /*0xDA2627*/ 0xcd3f43, 0xffffff, false);
				fxName.x = int(_width * .5 - fxName.width * .5);
			}
		}
		
		private function drawUserName():void
		{
			var userNameText:String;
			if (receiverSecret == true)
			{
				userNameText = Lang.textIncognito;
			}
			else
			{
				userNameText = userModel.getDisplayName();
			}
			
			userName.bitmapData = TextUtils.createTextFieldData(userNameText, componentsWidth, 10, false, TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .40, false, 0x3E4756, 0xffffff, false);
			
			userName.x = int(_width * .5 - userName.width * .5);
		}
		
		private function drawGift():void
		{
			var typeImage:int = giftType;
			if (giftType == GiftType.FIXED_TIPS)
			{
				typeImage = GiftType.MONEY_TRANSFER;
			}
			var imageSource:Sprite = Gifts.getGiftImage(typeImage);
			
			if (giftImage != null)
			{
				if (imageSource != null)
				{
					UI.scaleToFit(imageSource, Config.FINGER_SIZE * 4, Config.FINGER_SIZE * 1.6);
					
					giftImage.bitmapData = UI.getSnapshot(imageSource, StageQuality.HIGH, "DatingRegistrationPopup.image");
					UI.destroy(imageSource);
					imageSource = null;
				}
				
				giftImage.x = int(_width * .5 - giftImage.width * .5);
			}
		}
		
		override protected function drawView():void
		{
			if (_isDisposed == true)
				return;
			
			bg.width = _width;
			
			verticalMargin = Config.MARGIN * 1.5;
			
			if (currentTextEditor)
			{
				currentTextEditor.setSize(_width + Config.DOUBLE_MARGIN * 2, _height + Config.DOUBLE_MARGIN * 2);
			}
			
			var position:int;
			
			if (currentState == STATE_NEW)
			{
				position = verticalMargin + avatarSize * 2;
				
				userName.y = position;
				position += userName.height;
				
				if (userModel != null && userModel.login != null)
				{
					position += verticalMargin * .5;
					fxName.y = position;
					position += fxName.height;
				}
				position += verticalMargin * 2;
				
				if (giftImage.height > 0)
				{
					giftImage.y = position;
					position += giftImage.height + verticalMargin * 2;
				}
				
				if (giftData.type != GiftType.GIFT_X && giftData.type != GiftType.MONEY_TRANSFER && giftData.type != GiftType.MONEY_TRANSFER_CALLBACK)
				{
					text.y = position;
					position += text.height + verticalMargin * 1.5;
				}
				else
				{
					if (iAmount != null)
					{
						iAmount.view.y = position;
					}
					if (selectorCurrency != null)
					{
						selectorCurrency.y = position;
					}
					if (iAmount != null)
					{
						position += iAmount.height + verticalMargin * .3;
					}
				}
				
				if (warningSwitcher != null)
				{
					warningSwitcher.y = int(position + Config.FINGER_SIZE * .2);
				}
				
				if (isAccountAvaliable() == false && isSimpleGift() == true)
				{
					selectorDebitAccont.visible = false;
					accountText.visible = false;
				}
				else
				{
					selectorDebitAccont.y = position;
					position += selectorDebitAccont.height + verticalMargin * 1.6;
				}
				
				if (selectorCreditAccont)
				{
					selectorCreditAccont.y = position;
					position += selectorCreditAccont.height + verticalMargin * 1.6;
				}
				
				if (secureCodeManager != null && secureCodeManager.view != null && secureCodeManager.view.parent != null)
				{
					secureCodeManager.drawView(componentsWidth + Config.DOUBLE_MARGIN * 2);
					secureCodeManager.view.y = (position - Config.FINGER_SIZE * .2);
					secureCodeManager.view.x = Config.DIALOG_MARGIN;
					position += secureCodeManager.getRectangel().height;
				}
				
				accountText.y = position;
				position += accountText.height + verticalMargin * 1.8;
				
				acceptButton.y = position;
				backButton.y = position;
				position += acceptButton.height + verticalMargin * 1.8;
				
				bg.height = position - avatarSize;
				
				bg.y = avatarSize;
				
				container.y = _height - position;
			}
			else if (currentState == STATE_COMMENTS)
			{
				container.y = _height - bg.height - avatarSize;
			}
			
			if (userModel == null && preloader != null)
			{
				preloader.y = container.y + bg.y + bg.height * .5;
			}
		}
		
		private function isAccountAvaliable():Boolean
		{
			if (PayAPIManager.hasSwissAccount == false)
			{
				return false;
			}
			return true;
		}
		
		private function isSimpleGift():Boolean
		{
			//return false;
			if (giftType == GiftType.GIFT_1 || giftType == GiftType.GIFT_10 || giftType == GiftType.GIFT_25 || giftType == GiftType.GIFT_5 || giftType == GiftType.GIFT_50 || giftType == GiftType.GIFT_X)
			{
				return true;
			}
			//money transfer by card;
			if (giftType == GiftType.MONEY_TRANSFER)
			{
				return true;
			}
			return false;
		}
		
		override public function activateScreen():void
		{
			if (_isDisposed == true)
				return;
			
			if (currentTextEditor)
				return;
			
			if (inPaymentProcess)
				return;
			
			super.activateScreen();
			
			if (purposeSelector != null)
			{
				purposeSelector.activate();
			}
			if (warningSwitcher != null)
			{
				warningSwitcher.activate();
			}
			
			if (secureCodeManager != null && secureCodeManager.view != null && secureCodeManager.view.parent != null)
			{
				secureCodeManager.activate();
			}
			
			if (walletSelected == true)
			{
				if (giftType == GiftType.GIFT_X || giftType == GiftType.MONEY_TRANSFER || giftType == GiftType.MONEY_TRANSFER_CALLBACK)
				{
					if (selfTransfer)
					{
						if (walletCreditSelected && iAmount != null && iAmount.value != null && iAmount.value != "" && !isNaN(Number(iAmount.value)) && isCurrrencySelected())
						{
							acceptButton.activate();
							acceptButton.alpha = 1;
						}
					}
					else if (iAmount != null && iAmount.value != null && iAmount.value != "" && !isNaN(Number(iAmount.value)) && isCurrrencySelected())
					{
						acceptButton.activate();
						acceptButton.alpha = 1;
					}
				}
				else
				{
					acceptButton.activate();
					acceptButton.alpha = 1;
				}
				checkWarningSelection();
			}
			
			if (!isAccountAvaliable() && isSimpleGift())
			{
				activateAcceptButton();
			}
			
			if (backButton.visible)
			{
				backButton.activate();
			}
			
			if (selectorDebitAccont.visible)
			{
				selectorDebitAccont.activate();
			}
			if (selectorCreditAccont && selectorCreditAccont.visible)
			{
				selectorCreditAccont.activate();
			}
			
			if (iAmount != null && iAmount.view.visible && lockedAmount == false)
			{
				iAmount.activate();
			}
			
			if (selectorCurrency != null && selectorCurrency.visible && lockedAmount == false)
			{
				selectorCurrency.activate();
			}
			
			if (commentsBitmapContainer != null && commentsBitmapContainer.visible == true && currentState == STATE_COMMENTS)
			{
				PointerManager.removeTap(commentsBitmapContainer, editComment);
				PointerManager.addTap(commentsBitmapContainer, editComment);
			}
		}
		
		override public function deactivateScreen():void
		{
			if (_isDisposed == true)
				return;
			
			super.deactivateScreen();
			
			acceptButton.deactivate();
			backButton.deactivate();
			selectorDebitAccont.deactivate();
			if (selectorCreditAccont)
			{
				selectorCreditAccont.deactivate();
			}
			if (purposeSelector != null)
			{
				purposeSelector.deactivate();
			}
			if (warningSwitcher != null)
			{
				warningSwitcher.deactivate();
			}
			if (secureCodeManager != null && secureCodeManager.view != null && secureCodeManager.view.parent != null)
			{
				secureCodeManager.deactivate();
			}
			
			if (iAmount != null)
			{
				iAmount.deactivate();
			}
			
			if (selectorCurrency != null)
			{
				selectorCurrency.deactivate();
			}
			
			if (commentsBitmapContainer != null && commentsBitmapContainer.visible == true && currentState == STATE_COMMENTS)
			{
				PointerManager.removeTap(commentsBitmapContainer, editComment);
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
			
			if (currentTextEditor)
			{
				currentTextEditor.dispose();
				currentTextEditor = null;
			}
			
			PointerManager.removeTap(commentsBitmapContainer, editComment);
			
			TweenMax.killDelayedCallsTo(checkCommision);
			
			TweenMax.killTweensOf(avatar);
			TweenMax.killTweensOf(commentsBitmapContainer);
			TweenMax.killTweensOf(finishImage);
			TweenMax.killTweensOf(finishFooterMask);
			TweenMax.killTweensOf(finishImageMask);
			TweenMax.killTweensOf(acceptButton);
			TweenMax.killTweensOf(backButton);
			TweenMax.killTweensOf(giftImage);
			TweenMax.killTweensOf(backButton);
			if (warningSwitcher != null)
			{
				TweenMax.killTweensOf(warningSwitcher);
			}
			
			if (purposeSelector != null)
			{
				purposeSelector.dispose();
				purposeSelector = null;
			}
			
			if (iAmount != null)
			{
				TweenMax.killTweensOf(iAmount.view);
			}
			if (selectorCurrency != null)
			{
				TweenMax.killTweensOf(selectorCurrency);
			}
			if(secureCodeManager != null)
			{
				secureCodeManager.dispose();
				secureCodeManager = null;
			}
			
			TweenMax.killTweensOf(text);
			TweenMax.killTweensOf(accountText);
			TweenMax.killTweensOf(selectorDebitAccont);
			if (selectorCreditAccont)
			{
				TweenMax.killTweensOf(selectorCreditAccont);
			}
			TweenMax.killTweensOf(avatar);
			
			TweenMax.killDelayedCallsTo(onGiftSent);
			TweenMax.killDelayedCallsTo(hideElemetsFromState);
			
			if (selectorCurrency != null)
			{
				selectorCurrency.dispose();
				selectorCurrency = null;
			}
			
			if (finishImage != null)
			{
				UI.destroy(finishImage);
				finishImage = null;
			}
			if (footer != null)
			{
				UI.destroy(footer);
				footer = null;
			}
			if (finishImageMask != null)
			{
				UI.destroy(finishImageMask);
				finishImageMask = null;
			}
			if (finishFooterMask != null)
			{
				UI.destroy(finishFooterMask);
				finishFooterMask = null;
			}
			if (preloader != null)
			{
				preloader.dispose();
				preloader = null;
			}
			if (warningSwitcher != null)
			{
				warningSwitcher.dispose();
				warningSwitcher = null;
			}
			if (selectorDebitAccont != null)
			{
				selectorDebitAccont.dispose();
				selectorDebitAccont = null;
			}
			if (selectorCreditAccont != null)
			{
				selectorCreditAccont.dispose();
				selectorCreditAccont = null;
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
			if (giftImage != null)
			{
				UI.destroy(giftImage);
				giftImage = null;
			}
			if (avatar != null)
			{
				UI.destroy(avatar);
				avatar = null;
			}
			if (avatarBD != null)
			{
				avatarBD.dispose();
				avatarBD = null;
			}
			if (text != null)
			{
				UI.destroy(text);
				text = null;
			}
			if (fxName != null)
			{
				UI.destroy(fxName);
				fxName = null;
			}
			if (userName != null)
			{
				UI.destroy(userName);
				userName = null;
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
			userModel = null;
			giftData = null;
			
			UsersManager.S_USERS_FULL_DATA.add(onusersLoaded);
			
			if (PayManager.S_SEND_MONEY_COMMISSION_RESPOND != null)
			{
				PayManager.S_SEND_MONEY_COMMISSION_RESPOND.remove(onSendMoneyCommissionRespond);
			}
			
			InvoiceManager.S_TRANSFER_RESPOND.remove(onTransferRespond);
			InvoiceManager.S_PAY_TASK_COMPLETED.remove(onGiftSent);
			
			InvoiceManager.S_ACCOUNT_READY.remove(onWalletsReady);
			InvoiceManager.S_STOP_PROCESS_INVOICE.remove(onStopProcess);
			InvoiceManager.S_ERROR_PROCESS_INVOICE.remove(onStopProcess);
			InvoiceManager.S_START_TRANSFER.remove(onTransferStart);

			GD.S_PAYPASS_BACK_CLICK.remove(onPayPassBackClick);
			
			if (PayManager.S_SYSTEM_OPTIONS_READY != null)
				PayManager.S_SYSTEM_OPTIONS_READY.remove(onSystemOptions);
			if (PayManager.S_SYSTEM_OPTIONS_ERROR != null)
				PayManager.S_SYSTEM_OPTIONS_ERROR.remove(onSystemOptionsError);
			if (PayManager.S_ACCOUNT != null)
				PayManager.S_ACCOUNT.remove(onAccountInfo);
			accounts.dispose();
		}
	}
}