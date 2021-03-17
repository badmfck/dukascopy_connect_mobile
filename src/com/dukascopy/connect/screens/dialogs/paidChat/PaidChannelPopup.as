package com.dukascopy.connect.screens.dialogs.paidChat 
{
	import assets.IconOk2;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.gui.button.DDAccountButton;
	import com.dukascopy.connect.gui.chat.CircleAvatar;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.renderers.ListPayWalletItem;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.preloader.Preloader;
	import com.dukascopy.connect.screens.ChatScreen;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.dialogs.ScreenPayDialog;
	import com.dukascopy.connect.screens.payments.card.TypeCurrency;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.applicationShop.Shop;
	import com.dukascopy.connect.sys.applicationShop.product.ShopProduct;
	import com.dukascopy.connect.sys.applicationShop.serverTask.ShopServerTask;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.chatManager.typesManagers.ChannelsManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.payments.InvoiceManager;
	import com.dukascopy.connect.sys.payments.PayAPIManager;
	import com.dukascopy.connect.sys.payments.PayManager;
	import com.dukascopy.connect.sys.payments.PayRespond;
	import com.dukascopy.connect.sys.payments.advancedPayments.vo.PayTaskVO;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.type.ChatInitType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.connect.vo.ChatVO;
	import com.dukascopy.connect.vo.screen.ChatScreenData;
	import com.dukascopy.connect.vo.users.UserVO;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import fl.motion.Color;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Sergey Dobarin. Telefision TEAM Kiev.
	 */
	
	public class PaidChannelPopup extends BaseScreen
	{
		static public const STATE_RESULT:String = "stateResult";
		static public const STATE_NEW:String = "stateNew";
		
		protected var container:Sprite;
		private var bg:Shape;
		private var channelName:Bitmap;
		private var channelInfo:Bitmap;
		private var acceptButton:BitmapButton;
		private var avatar:CircleAvatar;
		private var chatVO:ChatVO;
		private var avatarSize:int;
		private var accountText:Bitmap;
		private var backButton:BitmapButton;
		private var selectorDebitAccont:DDAccountButton;
		private var preloader:Preloader;
		private var _lastCommissionCallID:String;
		private var screenLocked:Boolean;
		private var currentState:String = STATE_NEW;
		private var verticalMargin:Number;
		private var walletSelected:Boolean;
		private var selectedAccount:Object;
		private var currentCommision:Number = 0;
		private var currentRequestId:String;
		private var padding:int;
		private var subscriptionPriceText:Bitmap;
		private var successIcon:IconOk2;
		private var product:ShopProduct;
		protected var componentsWidth:int;
		
		public function PaidChannelPopup() {
			
		}
		
		override protected function createView():void {
			super.createView();
			container = new Sprite();
			
			padding = Config.DOUBLE_MARGIN;
			
			bg = new Shape();
			bg.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			var round:int = Config.FINGER_SIZE * .3;
			var round3:int = round * 3;
			bg.graphics.drawRect(0, 0, round3, round3);
			bg.scale9Grid = new Rectangle(round, round, round, round);
			container.addChild(bg);
			
			avatarSize = Config.FINGER_SIZE*.4;
			
			avatar = new CircleAvatar();
			container.addChild(avatar);
			
			channelName = new Bitmap();
			container.addChild(channelName);
			
			channelInfo = new Bitmap();
			container.addChild(channelInfo);
			
			subscriptionPriceText = new Bitmap();
			container.addChild(subscriptionPriceText);
			
			accountText = new Bitmap();
			container.addChild(accountText);
			
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
			container.addChild(selectorDebitAccont);
			
			_view.addChild(container);
		}
		
		override public function isModal():Boolean 
		{
			return true;
		}
		
		static private function createPaymentsAccount(val:int):void {
			if (val != 1) {
				return;
			}
			MobileGui.showRoadMap();
		}
		
		private function openWalletSelector(e:Event = null):void {
			if (PayAPIManager.hasSwissAccount == false) {
				DialogManager.alert(Lang.information, Lang.featureNoPaments, createPaymentsAccount, Lang.registrate, Lang.textCancel);
				return;
			}
			if (PayManager.accountInfo == null)	{
				showPreloader();
				deactivateScreen();
			} else {
				showWalletsDialog();
			}
			var banTask:PayTaskVO = new PayTaskVO(PayTaskVO.TASK_TYPE_PAY_MERCH);
			banTask.from_uid = Auth.uid;
			banTask.handleInCustomScreenName = "PaidChannelPopup";
			InvoiceManager.preProcessInvoce(banTask);
		}
		
		private function showWalletsDialog():void {
			DialogManager.showDialog(ScreenPayDialog, {callback: onWalletSelect, data: PayManager.accountInfo.accountsAll, itemClass: ListPayWalletItem/*ListPayAccount*/, label: Lang.TEXT_SELECT_ACCOUNT});
		}
		
		private function showPreloader():void {
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
			
			loadCommision();
		}
		
		private function loadCommision():void {
			drawAccountText(Lang.commisionWillBe + "...");
			
			_lastCommissionCallID = new Date().getTime().toString() + "gift";
			
			if (PayManager.S_SEND_MONEY_COMMISSION_RESPOND != null)  {
				PayManager.S_SEND_MONEY_COMMISSION_RESPOND.add(onSendMoneyCommissionRespond);
			}
			
			var currency:String = TypeCurrency.EUR;
			
			PayManager.callGetSendMoneyCommission(getAmount(), currency, _lastCommissionCallID);
		}
		
		private function getAmount():Number {
			return product.cost.value;
		}
		
		private function getCurrency():String {
			return product.cost.currency;
		}
		
		private function onSendMoneyCommissionRespond(respond:PayRespond):void {
			if (isDisposed)
				return;
			
			if (!respond.error)	{
				handleCommissionRespond(respond.savedRequestData.callID, respond.data);
			}
			else if (respond.hasAuthorizationError == false) {
				drawAccountText(Lang.textError + " " + respond.errorMsg);
			}
		}
		
		private function handleCommissionRespond(callID:String, data:Object):void {
			if (isDisposed)
				return;
			
			if (_lastCommissionCallID == callID) {
				if (data != null) {
					// poluchili kommisiiju
					var commissionObj:Array = data[0];
					
					if (data.length > 1) {
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
		
		override public function onBack(e:Event = null):void {
			if (screenLocked == false) {
				
				if (Config.isAdmin())
				{
					ServiceScreenManager.closeView();
				}
				else
				{
					if (MobileGui.centerScreen.currentScreenClass == ChatScreen)
					{
						MobileGui.centerScreen.currentScreen.onBack();
					}
					ChatManager.setCurrentChat(null);
					InvoiceManager.stopProcessInvoice();
					ServiceScreenManager.closeView();
				}
			}
		}
		
		private function backClick():void {
			
			onBack();
		}
		
		private function nextClick():void {
			if (currentState == STATE_NEW) {
				if (isNextButtonAvaliable() && selectedAccount != null) {
					lockScreen();
					
					currentRequestId = Math.random().toString();
					product.targetData = chatVO;
					Shop.S_PRODUCT_BUY_RESPONSE.add(onBuyRequestResponse);
					Shop.buyProduct(product, currentRequestId, selectedAccount.ACCOUNT_NUMBER);
				}
			}
			else if (currentState == STATE_RESULT) {
				InvoiceManager.stopProcessInvoice();
				
				if (MobileGui.centerScreen.currentScreenClass == ChatScreen && ChatManager.getCurrentChat() != null && ChatManager.getCurrentChat().uid == chatVO.uid)
				{
					ChatManager.activateChat();
				}
				else{
					var screenData:ChatScreenData = new ChatScreenData();
					screenData.type = ChatInitType.CHAT;
					screenData.chatUID = chatVO.uid;
					screenData.chatVO = chatVO;
					MobileGui.showChatScreen(screenData);
				}
				ServiceScreenManager.closeView();
			}
		}
		
		private function onBuyRequestResponse(success:Boolean, requestId:String = null, errorMessage:String = null, taskCanBeRequestedAgain:Boolean = true):void {
			if (isDisposed)
				return;
			
			if (currentRequestId != null && requestId != currentRequestId) {
				return;
			}
			
			if (taskCanBeRequestedAgain == true) {
				Shop.S_PRODUCT_BUY_RESPONSE.remove(onBuyRequestResponse);
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
				Shop.onFailedFinishRequest(ShopServerTask.BUY_SHOP_PRODUCT);
				DialogManager.alert(Lang.textError, Lang.somethingWentWrong);
				onBack();
			}
		}
		
		override public function clearView():void {
			super.clearView();
			InvoiceManager.stopProcessInvoice();
		}
		
		private function toState(newState:String):void {
			TweenMax.killDelayedCallsTo(checkCommision);
			
			var oldState:String = currentState;
			currentState = newState;
			
			screenLocked = true;
			
			acceptButton.deactivate();
			backButton.deactivate();
			
			if (newState == STATE_NEW) {
				
			}
			else if (newState == STATE_RESULT) {
				var hideTime:Number = 0.3;
				var showTime:Number = 0.3;
				TweenMax.to(selectorDebitAccont, hideTime, {alpha:0, onComplete:hideStartStateElements});
				TweenMax.to(subscriptionPriceText, hideTime, {alpha:0});
				TweenMax.to(acceptButton, hideTime, {alpha:0});
				TweenMax.to(backButton, hideTime, {alpha:0});
				
				TweenMax.to(acceptButton, showTime, {alpha:1, delay:hideTime, onComplete:activateNextButton});
				TweenMax.to(subscriptionPriceText, showTime, {alpha:1, delay:hideTime, onComplete:activateNextButton});
			}
		}
		
		private function activateNextButton():void {
			acceptButton.activate();
		}
		
		private function hideStartStateElements():void {
			container.removeChild(selectorDebitAccont);
		//	container.removeChild(subscriptionPriceText);
			container.removeChild(backButton);
			drawAcceptButton(Lang.open);
			acceptButton.x = int(_width * .5 - acceptButton.width * .5);
			drawBack();
			successIcon = new IconOk2();
			UI.scaleToFit(successIcon, Config.FINGER_SIZE * .5, Config.FINGER_SIZE * .5);
			container.addChild(successIcon);
			
			if (subscriptionPriceText.bitmapData != null) {
				subscriptionPriceText.bitmapData.dispose();
				subscriptionPriceText.bitmapData = null;
			}
			subscriptionPriceText.x = padding * 2 + successIcon.width;
			var text:String = Lang.youSubscribedToTheThannel + product.count + " " + product.duration.getLabel();
			subscriptionPriceText.bitmapData = TextUtils.createTextFieldData(text, componentsWidth - padding - successIcon.width, 10, 
															true, TextFormatAlign.LEFT, 
															TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .28, 
															true, 0x595F63, 0xFFFFFF);
			subscriptionPriceText.y = int(channelInfo.y + channelInfo.height + padding * 3.5);
			successIcon.y = int(subscriptionPriceText.y + subscriptionPriceText.height * .5 - successIcon.height * .5);
			successIcon.x = padding;
			subscriptionPriceText.x = padding * 2 + successIcon.width;
		}
		
		private function drawAvatar(user:UserVO):void {
			avatar.x = padding;
			avatar.y = padding;
			avatar.setData(user, avatarSize);
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			var chatUID:String;
			if (data != null && "chatUID" in data && data.chatUID != null) {
				chatUID = data.chatUID;
			}
			
			if (data != null && "product" in data && data.product != null) {
				product = data.product;
			}
			
			if (product != null && product.targetData != null && product.targetData is ChatVO)
			{
				chatVO = product.targetData as ChatVO;
			}
			
			if (chatVO == null)
			{
				chatVO = ChannelsManager.getChannel(chatUID);
			}
			
			if (chatVO != null && product == null)
			{
				product = chatVO.subscription;
			}
			
			if (chatVO == null) {
				ServiceScreenManager.closeView();
				ApplicationErrors.add("empty chat model");
				return;
			}
			
			componentsWidth = _width - padding * 2;
			
			var user:UserVO;
			if (chatVO.getUser(chatVO.ownerUID) != null)
			{
				user = chatVO.getUser(chatVO.ownerUID).userVO;
			}
			
			drawAvatar(user);
			drawChannelName(user);
			drawChannelInfo();
			drawSubscriptionPrice();
			drawAccountSelector();
			drawAccountText(Lang.chooseAccount);
			drawAcceptButton(Lang.subscribe);
			drawBackButton();
			
			updateButtonsState();
			
			InvoiceManager.S_ACCOUNT_READY.add(onWalletsReady);
			InvoiceManager.S_ERROR_PROCESS_INVOICE.add(onPayError);
			InvoiceManager.S_STOP_PROCESS_INVOICE.add(unlockScreen);
		}
		
		private function drawSubscriptionPrice():void {
			if (subscriptionPriceText.bitmapData != null) {
				subscriptionPriceText.bitmapData.dispose();
				subscriptionPriceText.bitmapData = null;
			}
			subscriptionPriceText.x = padding;
			subscriptionPriceText.bitmapData = TextUtils.createTextFieldData(getProductPrice(), componentsWidth, 10, 
															true, TextFormatAlign.LEFT, 
															TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .29, 
															true, 0x595F63, 0xFFFFFF);
		}
		
		private function getProductPrice():String 
		{
			if (chatVO != null && product != null)
			{
				return Lang.accessToThisChannelFor + " " + product.duration.getLabel() + ": " + product.cost.value + " " + product.cost.currency;
			}
			return "";
		}
		
		private function onPayError():void {
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
		
		private function drawChannelInfo():void {
			if (channelInfo.bitmapData != null) {
				channelInfo.bitmapData.dispose();
				channelInfo.bitmapData = null;
			}
			channelInfo.x = padding;
			var text:String = chatVO.settings.info;
			if (text != null && text.length > 600)
			{
				text = text.substr(0, 590);
			}
			channelInfo.bitmapData = TextUtils.createTextFieldData(text, componentsWidth, 10, 
															true, TextFormatAlign.LEFT, 
															TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .24, 
															true, 0x30383C, 0xE7F0FF);
		}
		
		private function onSystemOptions():void {
			if (isDisposed)
				return;
			
			if (PayManager.systemOptions != null && "currencyList" in PayManager.systemOptions) {
				
			}
			else {
				hidePreloader();
				activateScreen();
				screenLocked = false;
				
				if (PayManager.accountInfo == null)	{
					showPreloader();
					deactivateScreen();
					var preGiftModel:PayTaskVO = new PayTaskVO(PayTaskVO.TASK_TYPE_PAY_GIFT_BY_UID);
					preGiftModel.from_uid = Auth.uid;
					preGiftModel.handleInCustomScreenName = "CreateGiftPopup";
					InvoiceManager.preProcessInvoce(preGiftModel);
				}
				
				ToastMessage.display(Lang.wrongTimeOnDevice);
			}
		}
		
		private function checkCommision(immidiate:Boolean = false):void {
			currentCommision = 0;
			TweenMax.killDelayedCallsTo(checkCommision);
			
			var needUpdate:Boolean = true;
			
			if (walletSelected == false)
				needUpdate = false;
			
			if (needUpdate)	{
				drawAccountText(Lang.commisionWillBe + "...");
				
				if (immidiate) {
					loadCommision();
				}
				else {
					TweenMax.delayedCall(1, checkCommision, [true]);
				}
			}
		}
		
		private function onWalletsReady():void {
			if (isDisposed)
				return;
			
			onSystemOptions();
			
			activateScreen();
			hidePreloader();
			setDefaultWallet();
			
			InvoiceManager.S_ACCOUNT_READY.remove(onWalletsReady);
		}
		
		private function hidePreloader():void {
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
			if (PayManager.accountInfo == null) return;
			var defaultAccount:Object;
			
			var currencyNeeded:String = TypeCurrency.EUR;
			var wallets:Array = PayManager.accountInfo.accounts;
			var l:int = wallets.length;
			var walletItem:Object;
			for (var i:int = 0; i < l; i++) {
				walletItem = wallets[i];
				if (currencyNeeded == walletItem.CURRENCY) {
					defaultAccount = walletItem;
					break;
				}
			}
			/*if (defaultAccount != null) {
				onWalletSelect(defaultAccount);
			}
			else {
				if (currentState == STATE_NEW) {
					showWalletsDialog();
				}
			}*/
			showWalletsDialog();
		}
		
		private function drawAccountSelector():void {
			selectorDebitAccont.setSize(_width, Config.FINGER_SIZE * .8);
			selectorDebitAccont.setValue(Lang.walletToCharge);
		}
		
		private function drawAcceptButton(text:String):void {
			var textSettings:TextFieldSettings = new TextFieldSettings(text, 0xFFFFFF, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, 0x78C043, 1, Config.FINGER_SIZE * .8, NaN, (componentsWidth - padding) * .5);
			acceptButton.setBitmapData(buttonBitmap, true);
			acceptButton.x = int(acceptButton.width + padding * 2);
		}
		
		private function drawBackButton():void {
			var textSettings:TextFieldSettings = new TextFieldSettings(Lang.textBack, 0, Config.FINGER_SIZE * .3, TextFormatAlign.CENTER);
			var buttonBitmap:ImageBitmapData = TextUtils.createbutton(textSettings, 0x78C043, 0, Config.FINGER_SIZE * .8, 0x666666, (componentsWidth - padding) * .5);
			backButton.setBitmapData(buttonBitmap, true);
			backButton.x = padding;
		}
		
		private function drawAccountText(text:String):void {
			return;
			if (accountText.bitmapData != null) {
				accountText.bitmapData.dispose();
				accountText.bitmapData = null;
			}
			accountText.bitmapData = TextUtils.createTextFieldData(text, componentsWidth, 10, true, TextFormatAlign.CENTER, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .3, true, 0xABB8C1, 0xffffff, false);
			
			accountText.x = int(componentsWidth * .5 - accountText.width * .5);
		}
		
		private function drawChannelName(user:UserVO):void {
			if (channelName.bitmapData != null) {
				channelName.bitmapData.dispose();
				channelName.bitmapData = null;
			}
			
			channelName.bitmapData = TextUtils.createTextFieldData(
																	chatVO.title, 
																	componentsWidth - avatarSize * 2 - padding * 3, 
																	10, true, TextFormatAlign.LEFT, 
																	TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .33, 
																	true, 0x3E4756, 0xffffff, false);
			
			channelName.x = int(avatar.x + avatarSize * 2 + padding);
			channelName.y = avatar.y;
		}
		
		override protected function drawView():void {
			if (_isDisposed == true)
				return;
			
			verticalMargin = padding;
			
			var position:int;
			
			if (currentState == STATE_NEW) {
				position = verticalMargin;
				
				channelName.y = position;
				position += Math.max(channelName.height, avatarSize * 2);
				position += verticalMargin * 2;
				
				channelInfo.y = position;
				position += channelInfo.height + verticalMargin * 2;
				
				subscriptionPriceText.y = position;
				position += subscriptionPriceText.height + verticalMargin + 2;
				
				selectorDebitAccont.y = position;
				position += selectorDebitAccont.height + verticalMargin + 2;
				
			//	accountText.y = position;
			//	position += accountText.height + verticalMargin*1.8;
				
				acceptButton.y = position;
				backButton.y = position;
				
				drawBack();
				
				container.y = int(_height * .5 - bg.height * .5);
			}
		}
		
		private function drawBack():void 
		{
			var positionBack:int = 0;
			var radius:int = Config.FINGER_SIZE * .1;
			bg.graphics.clear();
			bg.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			positionBack += verticalMargin * 2 + Math.max(avatarSize * 2, channelName.height);
			bg.graphics.drawRoundRectComplex(0, 0, _width, positionBack, radius, radius, 0, 0);
			bg.graphics.endFill();
			
			bg.graphics.beginFill(0xE7F0FF);
			bg.graphics.drawRect(0, positionBack, _width, verticalMargin * 2 + channelInfo.height);
			positionBack += verticalMargin * 2 + channelInfo.height;
			bg.graphics.endFill();
			
			if (currentState == STATE_NEW)
			{
				bg.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
				bg.graphics.drawRect(0, positionBack, _width, verticalMargin * 2 + subscriptionPriceText.height);
				positionBack += verticalMargin * 2 + subscriptionPriceText.height;
				bg.graphics.endFill();
				
				bg.graphics.beginFill(0xE7F0FF);
				bg.graphics.drawRect(0, positionBack, _width, 2);
				positionBack += 2;
				bg.graphics.endFill();
				
				bg.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
				bg.graphics.drawRect(0, positionBack, _width, selectorDebitAccont.height);
				positionBack += selectorDebitAccont.height;
				bg.graphics.endFill();
				
				bg.graphics.beginFill(0xE7F0FF);
				bg.graphics.drawRect(0, positionBack, _width, 2);
				positionBack += 2;
				bg.graphics.endFill();
				
				bg.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
				bg.graphics.drawRoundRectComplex(0, positionBack, _width, acceptButton.height + verticalMargin * 2, 0, 0, radius, radius);
				bg.graphics.endFill();
			}
			else if (currentState == STATE_RESULT) {
				bg.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
				var heightNew:int = verticalMargin * 2 + subscriptionPriceText.height;
				heightNew += 2;
				heightNew += selectorDebitAccont.height;
				heightNew += 2;
				heightNew += acceptButton.height + verticalMargin * 2;
				bg.graphics.drawRoundRectComplex(0, positionBack, _width, heightNew, 0, 0, radius, radius);
				bg.graphics.endFill();
			}
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
			
			if (backButton.visible) {
				backButton.activate();
			}
			
			if (selectorDebitAccont.visible) {
				selectorDebitAccont.activate();
			}
		}
		
		private function isNextButtonAvaliable():Boolean {
			if (currentState == STATE_NEW) {
				return (walletSelected == true);
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
		}
		
		override public function dispose():void {
			if (_isDisposed == true)
				return;
			super.dispose();
			
			TweenMax.killDelayedCallsTo(checkCommision);
			TweenMax.killTweensOf(avatar);
			TweenMax.killTweensOf(acceptButton);
			TweenMax.killTweensOf(backButton);
			TweenMax.killTweensOf(channelInfo);
			TweenMax.killTweensOf(accountText);
			TweenMax.killTweensOf(selectorDebitAccont);
			
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
			if (channelInfo != null) {
				UI.destroy(channelInfo);
				channelInfo = null;
			}
			if (successIcon != null) {
				UI.destroy(successIcon);
				successIcon = null;
			}
			if (subscriptionPriceText != null) {
				UI.destroy(subscriptionPriceText);
				subscriptionPriceText = null;
			}
			if (channelName != null) {
				UI.destroy(channelName);
				channelName = null;
			}
			if (bg != null) {
				UI.destroy(bg);
				bg = null;
			}
			if (container != null) {
				UI.destroy(container);
				container = null;
			}
			chatVO = null;
			selectedAccount = null;
			product = null;
			
			Shop.S_PRODUCT_BUY_RESPONSE.remove(onBuyRequestResponse);
			InvoiceManager.S_ERROR_PROCESS_INVOICE.remove(onPayError);
			
			InvoiceManager.S_STOP_PROCESS_INVOICE.remove(unlockScreen);
			InvoiceManager.S_ACCOUNT_READY.remove(onWalletsReady);
			
			if (PayManager.S_SEND_MONEY_COMMISSION_RESPOND != null)
				PayManager.S_SEND_MONEY_COMMISSION_RESPOND.remove(onSendMoneyCommissionRespond);
			if (PayManager.S_SYSTEM_OPTIONS_READY != null)
				PayManager.S_SYSTEM_OPTIONS_READY.remove(onSystemOptions);
			if (PayManager.S_SYSTEM_OPTIONS_ERROR != null)
				PayManager.S_SYSTEM_OPTIONS_ERROR.remove(onSystemOptions);
		}
	}
}