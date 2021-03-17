package com.dukascopy.connect.screens.dialogs.paidChat 
{
	import assets.JailedIllustrationClip;
	import assets.PhotoShotIcon;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.data.PopupData;
	import com.dukascopy.connect.data.TextFieldSettings;
	import com.dukascopy.connect.data.coinMarketplace.PaymentsAccountsProvider;
	import com.dukascopy.connect.data.paidChat.PaidChatData;
	import com.dukascopy.connect.data.screenAction.IScreenAction;
	import com.dukascopy.connect.data.screenAction.customActions.OpenBankAccountAction;
	import com.dukascopy.connect.gui.button.DDAccountButton;
	import com.dukascopy.connect.gui.components.CirclePreloader;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.menuVideo.BitmapButton;
	import com.dukascopy.connect.gui.scrollPanel.ScrollPanel;
	import com.dukascopy.connect.gui.tools.HorizontalPreloader;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.serviceScreen.BottomPopupScreen;
	import com.dukascopy.connect.sys.applicationError.ApplicationErrors;
	import com.dukascopy.connect.sys.applicationShop.Shop;
	import com.dukascopy.connect.sys.applicationShop.serverTask.TransferMoneyServerTask;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.chatManager.ChatManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.imageManager.ImageManager;
	import com.dukascopy.connect.sys.serviceScreenManager.ServiceScreenManager;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.utils.TextUtils;
	import com.dukascopy.langs.Lang;
	import com.dukascopy.langs.LangManager;
	import com.greensock.TweenMax;
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
	
	public class OpenPaidChatPopup extends BaseScreen {
		
		static public const STATE_START:String = "stateStart";
		static public const STATE_PAY:String = "statePay";
		
		protected var container:Sprite;
		private var bg:Shape;
		private var acceptButton:BitmapButton;
		private var backButton:BitmapButton;
		private var scroll:ScrollPanel;
		private var componentsWidth:Number;
		private var photoSection:Sprite;
		private var smallText:int;
		private var titleName:Bitmap;
		private var titleDescription:Bitmap;
		private var titleCost:Bitmap;
		private var scrollStart:Sprite;
		private var loadedPhoto:Bitmap;
		private var photoLoader:CirclePreloader;
		private var horizontalLoader:HorizontalPreloader;
		private var paidChatData:PaidChatData;
		private var state:String;
		private var payDescription:Bitmap;
		private var disclaimer:Bitmap;
		private var accounts:PaymentsAccountsProvider;
		private var selectorDebitAccont:DDAccountButton;
		private var disclaimerClip:Sprite;
		private var scrollHeightData:Object;
		private var selectedAccount:Object;
		private var payTask:TransferMoneyServerTask;
		private var locked:Boolean;
		
		public function OpenPaidChatPopup() {
			
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
			
			acceptButton = new BitmapButton();
			acceptButton.setStandartButtonParams();
			acceptButton.setDownScale(1);
			acceptButton.setDownColor(0);
			acceptButton.tapCallback = nextClick;
			acceptButton.disposeBitmapOnDestroy = true;
			acceptButton.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
			container.addChild(acceptButton);
			
			photoSection = new Sprite();
			container.addChild(photoSection);
			
			loadedPhoto = new Bitmap();
			photoSection.addChild(loadedPhoto);
			
			backButton = new BitmapButton();
			backButton.setStandartButtonParams();
			backButton.setDownScale(1);
			backButton.setDownColor(0);
			backButton.tapCallback = backClick;
			backButton.disposeBitmapOnDestroy = true;
			backButton.setOverlay(HitZoneType.MENU_SIMPLE_ELEMENT);
			container.addChild(backButton);
			
			titleName = new Bitmap();
			scroll.addObject(titleName);
			
			titleDescription = new Bitmap();
			scroll.addObject(titleDescription);
			
			titleCost = new Bitmap();
			scroll.addObject(titleCost);
			
			horizontalLoader = new HorizontalPreloader(0x007CA6);
			container.addChild(horizontalLoader);
			
			_view.addChild(container);
			
			scrollStart = new Sprite();
			scroll.addObject(scrollStart);
			scrollStart.graphics.beginFill(0xFFFFFF);
			scrollStart.graphics.drawRect(0, 0, 1, 1);
			scrollStart.graphics.endFill();
			
			payDescription = new Bitmap();
			
			disclaimerClip = new Sprite();
			disclaimer = new Bitmap();
			disclaimerClip.addChild(disclaimer);
		}
		
		private function loadImage(imageId:String):void 
		{
			if (isDisposed)
			{
				return;
			}
			
			if (photoLoader == null)
			{
				photoLoader = new CirclePreloader();
				container.addChild(photoLoader);
				photoLoader.x = int(_width * .5);
				photoLoader.y = int(photoSection.y + photoSection.height * .5);
			}
			
			ImageManager.loadImage(Config.URL_PHP_CORE_SERVER_FILE + "?method=files.get&key=web&uid=" + imageId, onPhotoLoaded);
		}
		
		private function onPhotoLoaded(success:Boolean, image:ImageBitmapData):void 
		{
			if (photoLoader != null && container != null)
			{
				if (container.contains(photoLoader))
				{
					photoLoader.dispose();
					container.removeChild(photoLoader);
					photoLoader = null;
				}
			}
			
			if (isDisposed)
			{
				return;
			}
			
			if (success == true)
			{
				loadedPhoto.bitmapData = image;
				loadedPhoto.smoothing = true;
				var sectionHeight:int = _width * 0.76;
				loadedPhoto.width = _width;
				loadedPhoto.height = sectionHeight;
				
				loadedPhoto.alpha = 0;
				TweenMax.to(loadedPhoto, 0.3, {alpha:1});
			}
			else
			{
				//!TODO:;
			}
		}
		
		override public function onBack(e:Event = null):void {
			ChatManager.S_ERROR_CANT_OPEN_CHAT.invoke();
			ServiceScreenManager.closeView();
		}
		
		private function backClick():void {
			if (state == STATE_PAY)
			{
				changeStateStart();
			}
			else if (state == STATE_START)
			{
				onBack();
			}
		}
		
		private function changeStateStart():void 
		{
			lock();
			
			var scrollPosition:int = Config.FINGER_SIZE * .3;
			
			if (hasTitle(paidChatData))
			{
				scrollPosition += Config.FINGER_SIZE * .36 + Config.FINGER_SIZE * .3 + Config.FINGER_SIZE * .3 - 4;
			}
			
			if (titleName.width + titleCost.width + Config.FINGER_SIZE * .7 < _width - Config.DIALOG_MARGIN * 2)
			{
				
			}
			else
			{
				scrollPosition += titleCost.height + Config.FINGER_SIZE * .3;
			}
			
			if (hasDescription(paidChatData))
			{
				scrollPosition += titleDescription.height + Config.FINGER_SIZE*.5;
			}
			
			var maxScrollHeight:int = Math.max(_height - photoSection.height - Config.FINGER_SIZE * .6 - acceptButton.height, Config.FINGER_SIZE * 2) - Config.APPLE_BOTTOM_OFFSET;
			var targetScrollHeight:int = Math.min(maxScrollHeight, scrollPosition + Config.FINGER_SIZE * .1);
			scrollHeightData = new Object();
			scrollHeightData.targetHeight = targetScrollHeight;
			scrollHeightData.height = scroll.height;
			
			TweenMax.to(scrollHeightData, 0.4, {height:targetScrollHeight, onComplete:onScrollResizedToStartState, onUpdate:updateScrollHeight});
			TweenMax.to(scroll.view, 0.2, {alpha:0, onComplete:updateStartState});
		}
		
		private function updateStartState():void 
		{
			scroll.addObject(titleName);
			scroll.addObject(titleDescription);
			scroll.addObject(titleCost);
			
			scroll.removeObject(selectorDebitAccont);
			scroll.removeObject(payDescription);
			scroll.removeObject(disclaimerClip);
			
			var scrollPosition:int = Config.FINGER_SIZE * .3;
			
			if (hasTitle(paidChatData))
			{
				titleName.y = int(scrollPosition + Config.FINGER_SIZE * .36 - titleName.height);
				titleName.x = Config.DIALOG_MARGIN;
				scrollPosition += Config.FINGER_SIZE * .36 + Config.FINGER_SIZE * .3 + Config.FINGER_SIZE * .3 - 4;
			}
			if (titleName.width + titleCost.width + Config.FINGER_SIZE * .7 < _width - Config.DIALOG_MARGIN * 2)
			{
				titleCost.x = int(_width - Config.DIALOG_MARGIN - titleCost.width);
				titleCost.y = titleName.y + titleName.height - titleCost.height;
			}
			else
			{
				titleCost.x = int(_width - Config.DIALOG_MARGIN - titleCost.width);
				titleCost.y = int(titleName.y + titleName.height + Config.FINGER_SIZE * .3);
				scrollPosition += titleCost.height + Config.FINGER_SIZE * .3;
			}
			if (hasDescription(paidChatData))
			{
				titleDescription.y = scrollPosition;
				titleDescription.x = Config.DIALOG_MARGIN;
				scrollPosition += titleDescription.height + Config.FINGER_SIZE*.5;
			}
			
			TweenMax.to(scroll.view, 0.2, {alpha:1, onComplete:startStateShown});
			
			scrollStart.graphics.clear();
			
			if (hasTitle(paidChatData))
			{
				var pos:int = Math.max(titleName.y + titleName.height, titleCost.y + titleCost.height) + Config.FINGER_SIZE * .3;
				scrollStart.graphics.lineStyle(1, 0xDCE5EE);
				scrollStart.graphics.moveTo(0, pos);
				scrollStart.graphics.lineTo(_width, pos);
			}
			
			scrollStart.graphics.beginFill(0xFFFFFF);
			scrollStart.graphics.drawRect(0, 0, 1, 1);
			scrollStart.graphics.endFill();
		}
		
		private function startStateShown():void 
		{
			unlock();
		}
		
		private function onScrollResizedToStartState():void 
		{
			state = STATE_START;
			drawAcceptButton(Lang.textNext);
		}
		
		private function nextClick():void {
			if (locked == true)
			{
				return;
			}
			
			if (state == STATE_START)
			{
				if (Auth.bank_phase == "ACC_APPROVED")
				{
					lock();
					loadAccounts();
				}
				else
				{
					showPaymentsPopup();
				}
			}
			else if (state == STATE_PAY)
			{
				makeTransfer();
			}
		}
		
		private function makeTransfer():void 
		{
			lock();
			horizontalLoader.start();
			payTask = new TransferMoneyServerTask(paidChatData, selectedAccount.ACCOUNT_NUMBER);
			payTask.S_ACTION_FAIL.add(onTransferFailed);
			payTask.S_ACTION_SUCCESS.add(onTransferSuccess);
			payTask.execute();
		}
		
		private function onTransferSuccess(transactionId:String):void 
		{
			if (isDisposed == true)
			{
				return;
			}
			
			horizontalLoader.stop();
			unlock();
			
			if (payTask != null)
			{
				payTask.dispose();
				payTask = null;
			}
			//!TODO: save pending transaction id;
			
			Shop.addPaidChatPendingTransaction(paidChatData.userUid, transactionId);
			
			ChatManager.openChatByUserUIDs([paidChatData.userUid]);
			ServiceScreenManager.closeView();
		}
		
		private function onTransferFailed(error:String):void 
		{
			if (isDisposed == true)
			{
				return;
			}
			
			horizontalLoader.stop();
			unlock();
			
			if (payTask != null)
			{
				payTask.dispose();
				payTask = null;
			}
			ToastMessage.display(error);
		}
		
		private function showPaymentsPopup():void 
		{
			var popupData:PopupData = new PopupData();
			var action:IScreenAction = new OpenBankAccountAction();
			action.setData(Lang.openBankAccount);
			popupData.action = action;
			popupData.illustration = JailedIllustrationClip;
			popupData.text = Lang.noBankAccount;
			ServiceScreenManager.showScreen(ServiceScreenManager.TYPE_SCREEN, BottomPopupScreen, popupData);
		}
		
		private function loadAccounts():void 
		{
			accounts = new PaymentsAccountsProvider(onAccountsDataReady);
			
			if (accounts.ready == true)
			{
				onAccountsDataReady();
			}
			else
			{
				showLoader();
				accounts.getData();
			}
		}
		
		private function showLoader():void
		{
			horizontalLoader.y = photoSection.y + photoSection.height;
			horizontalLoader.setSize(_width, int(Config.FINGER_SIZE * .07));
			horizontalLoader.start();
		}
		
		private function onAccountsDataReady():void 
		{
			if (accounts.coinsAccounts != null && accounts.coinsAccounts.length > 0 && state != STATE_PAY)
			{
				horizontalLoader.stop();
				darwPayState();
			}
		}
		
		private function darwPayState():void 
		{
			lock();
			drawAccount();
			drawPayDescription();
			drawDisclamer();
			
			var scrollPosition:int = Config.FINGER_SIZE * .3;
			scrollPosition += payDescription.height + Config.FINGER_SIZE * .3;
			scrollPosition += selectorDebitAccont.height + Config.FINGER_SIZE * .3;
			scrollPosition += disclaimerClip.height + Config.FINGER_SIZE * .2;
			
			var maxScrollHeight:int = Math.max(_height - photoSection.height - Config.FINGER_SIZE * .6 - acceptButton.height, Config.FINGER_SIZE * 2) - Config.APPLE_BOTTOM_OFFSET;
			var targetScrollHeight:int = Math.min(maxScrollHeight, scrollPosition + Config.FINGER_SIZE * .1);
			scrollHeightData = new Object();
			scrollHeightData.targetHeight = targetScrollHeight;
			scrollHeightData.height = scroll.height;
			
			TweenMax.to(scrollHeightData, 0.4, {height:targetScrollHeight, onComplete:onScrollResized, onUpdate:updateScrollHeight});
			TweenMax.to(scroll.view, 0.2, {alpha:0, onComplete:updatePayState});
		}
		
		private function updateScrollHeight():void 
		{
			scroll.setWidthAndHeight(_width, scrollHeightData.height);
			
			var position:int = scroll.view.y + scroll.height + Config.FINGER_SIZE * .3;
			acceptButton.y = position;
			backButton.y = position;
			position += acceptButton.height + Config.FINGER_SIZE * .3;
			
			bg.graphics.clear();
			bg.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			bg.graphics.drawRect(0, 0, _width, position);
			bg.graphics.endFill();
			
			container.y = _height - position - Config.APPLE_BOTTOM_OFFSET;
		}
		
		private function onScrollResized():void 
		{
			state = STATE_PAY;
			var currency:String = paidChatData.currency;
			if (Lang[currency] != null)
			{
				currency = Lang[currency];
			}
			drawAcceptButton(Lang.pay + " " + paidChatData.cost + " " + currency);
		}
		
		private function updatePayState():void 
		{
			scroll.removeObject(titleName);
			scroll.removeObject(titleDescription);
			scroll.removeObject(titleCost);
			
			scroll.addObject(selectorDebitAccont);
			scroll.addObject(payDescription);
			scroll.addObject(disclaimerClip);
			
			var scrollPosition:int = Config.FINGER_SIZE * .3;
			payDescription.y = scrollPosition;
			scrollPosition += payDescription.height + Config.FINGER_SIZE * .3;
			selectorDebitAccont.y = scrollPosition;
			scrollPosition += selectorDebitAccont.height + Config.FINGER_SIZE * .3;
			disclaimerClip.y = scrollPosition;
			scrollPosition += disclaimerClip.height + Config.FINGER_SIZE * .2;
			
			payDescription.x = Config.DIALOG_MARGIN;
			selectorDebitAccont.x = Config.DIALOG_MARGIN;
			
			TweenMax.to(scroll.view, 0.2, {alpha:1, onComplete:payStateShown});
			
			scrollStart.graphics.clear();
			
			var pos:int = payDescription.y + payDescription.height + Config.FINGER_SIZE * .3;
			scrollStart.graphics.lineStyle(1, 0xDCE5EE);
			scrollStart.graphics.moveTo(0, pos);
			scrollStart.graphics.lineTo(_width, pos);
			scrollStart.graphics.beginFill(0xFFFFFF);
			scrollStart.graphics.drawRect(0, 0, 1, 1);
			scrollStart.graphics.endFill();
		}
		
		private function drawDisclamer():void 
		{
			disclaimer.bitmapData = TextUtils.createTextFieldData(
																Lang.paidChatDisclamer, _width - Config.DIALOG_MARGIN * 2, 10, true, 
																TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .32, true, 0x4C5762, 0xFFFFFF, false, true);
			disclaimer.x = Config.DIALOG_MARGIN;
			disclaimer.y = int(Config.FINGER_SIZE * .3);
			
			var clipHeight:int = int(disclaimer.height + Config.FINGER_SIZE * .6);
			
			disclaimerClip.graphics.beginFill(0xE9F3F9);
			disclaimerClip.graphics.drawRect(0, 0, _width, clipHeight);
			disclaimerClip.graphics.beginFill(0xFF6600);
			disclaimerClip.graphics.drawRect(0, 0, int(Config.FINGER_SIZE*.08), clipHeight);
			disclaimerClip.graphics.endFill();
		}
		
		private function drawPayDescription():void 
		{
			var text:String = Lang.paidChatPayDescription;
			var currency:String = paidChatData.currency;
			if (Lang[currency] != null)
			{
				currency = Lang[currency];
			}
			
			var costText:String = "<font color='#E07800'>" + paidChatData.cost + " " + currency + "</font>";
			text = LangManager.replace(Lang.regExtValue, text, costText);
			payDescription.bitmapData = TextUtils.createTextFieldData(
																text, _width - Config.DIALOG_MARGIN * 2, 10, true, 
																TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .32, true, 0x4C5762, 0xFFFFFF, false, true);
		}
		
		private function payStateShown():void 
		{
			unlock();
		}
		
		private function unlock():void 
		{
			locked = false;
		}
		
		private function drawAccount():void 
		{
			if (selectorDebitAccont == null)
			{
				selectedAccount = accounts.coinsAccounts[0];
				
				selectorDebitAccont = new DDAccountButton(null, null);
				selectorDebitAccont.setSize(_width - Config.DIALOG_MARGIN * 2, Config.FINGER_SIZE * .8);
				selectorDebitAccont.setValue(selectedAccount);
				selectorDebitAccont.x = Config.DIALOG_MARGIN;
			}
		}
		
		private function lock():void 
		{
			locked = true;
		}
		
		override public function clearView():void
		{
			super.clearView();
		}
		
		override public function initScreen(data:Object = null):void
		{
			super.initScreen(data);
			
			if (data != null && data is PaidChatData)
			{
				paidChatData = data as PaidChatData;
			}
			else
			{
				ApplicationErrors.add();
				ServiceScreenManager.closeView();
				ChatManager.S_ERROR_CANT_OPEN_CHAT.invoke("");
			}
			
			state = STATE_START;
			
			smallText = Config.FINGER_SIZE * .28;
			componentsWidth = _width - Config.DIALOG_MARGIN * 2;
			
			drawAcceptButton(Lang.textNext);
			acceptButton.deactivate();
			drawBackButton();
			drawPhotoSection();
			if (hasTitle(paidChatData))
			{
				drawTitleName();
			}
			if (hasDescription(paidChatData))
			{
				drawTitleDescription();
			}
			
			drawTitleCost();
			
			if (paidChatData.photo != null)
			{
				loadImage(paidChatData.photo);
			}
		}
		
		private function hasDescription(paidChatData:PaidChatData):Boolean 
		{
			return (paidChatData.description != null && paidChatData.description != "");
		}
		
		private function hasTitle(paidChatData:PaidChatData):Boolean 
		{
			return (paidChatData.title != null && paidChatData.title != "");
		}
		
		private function drawTitleName():void 
		{
			titleName.bitmapData = TextUtils.createTextFieldData(
																paidChatData.title, _width - Config.DIALOG_MARGIN * 2, 10, true, 
																TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .36, true, 0x4C5762);
		}
		
		private function drawTitleDescription():void 
		{
			titleDescription.bitmapData = TextUtils.createTextFieldData(
																paidChatData.description, _width - Config.DIALOG_MARGIN * 2, 10, true, 
																TextFormatAlign.LEFT, TextFieldAutoSize.LEFT, Config.FINGER_SIZE * .30, true, 0x6B7A8A);
		}
		
		private function drawTitleCost():void 
		{
			var text:String;
			var curency:String = paidChatData.currency;
			if (Lang[curency] != null)
			{
				curency = Lang[curency];
			}
			text = paidChatData.cost + " " + curency;
			titleCost.bitmapData = TextUtils.createTextFieldData(
																text, _width - Config.DIALOG_MARGIN * 2, 10, false, TextFormatAlign.LEFT, 
																TextFieldAutoSize.LEFT, Config.FINGER_SIZE*.36, false, 0x4C5762);
		}
		
		private function drawPhotoSection():void 
		{
			var sectionHeight:int = _width * 0.76;
			photoSection.graphics.beginFill(0xA5BECA);
			photoSection.graphics.drawRect(0, 0, _width, sectionHeight);
			photoSection.graphics.endFill();
			
			var icon:PhotoShotIcon = new PhotoShotIcon();
			UI.colorize(icon, 0xFFFFFF);
			UI.scaleToFit(icon, Config.FINGER_SIZE * 0.8, Config.FINGER_SIZE * 0.8);
			photoSection.addChild(icon);
			icon.x = int(photoSection.width * .5 - icon.width * .5);
			icon.y = int(photoSection.height * .5 - icon.height * .5);
			photoSection.setChildIndex(icon, 0);
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
			
			if (locked == true)
			{
				return;
			}
			
			if (state == STATE_START)
			{
				drawStateStart();
			}
			else if (state == STATE_PAY)
			{
				drawStatePay();
			}
		}
		
		private function drawStatePay():void 
		{
			
		}
		
		private function drawStateStart():void 
		{
			var position:int = 0;
			
			photoSection.y = position;
			position += photoSection.height;
			scroll.view.y = position;
			
			var scrollPosition:int = Config.FINGER_SIZE * .3;
			
			if (hasTitle(paidChatData))
			{
				titleName.y = int(scrollPosition + Config.FINGER_SIZE * .36 - titleName.height);
				titleName.x = Config.DIALOG_MARGIN;
				scrollPosition += Config.FINGER_SIZE * .36 + Config.FINGER_SIZE * .3 + Config.FINGER_SIZE * .3 - 4;
			}
			
			if (titleName.width + titleCost.width + Config.FINGER_SIZE * .7 < _width - Config.DIALOG_MARGIN * 2)
			{
				titleCost.x = int(_width - Config.DIALOG_MARGIN - titleCost.width);
				titleCost.y = titleName.y + titleName.height - titleCost.height;
			}
			else
			{
				titleCost.x = int(_width - Config.DIALOG_MARGIN - titleCost.width);
				titleCost.y = int(titleName.y + titleName.height + Config.FINGER_SIZE * .3);
				scrollPosition += titleCost.height + Config.FINGER_SIZE * .3;
			}
			
			if (hasDescription(paidChatData))
			{
				titleDescription.y = scrollPosition;
				titleDescription.x = Config.DIALOG_MARGIN;
				scrollPosition += titleDescription.height + Config.FINGER_SIZE*.5;
			}
			
			var maxScrollHeight:int = Math.max(_height - photoSection.height - Config.FINGER_SIZE * .6 - acceptButton.height, Config.FINGER_SIZE * 2) - Config.APPLE_BOTTOM_OFFSET;
			scroll.setWidthAndHeight(_width, Math.min(maxScrollHeight, scroll.itemsHeight + Config.FINGER_SIZE * .1));
			scroll.update();
			position += scroll.height + Config.FINGER_SIZE * .3;
			acceptButton.y = position;
			backButton.y = position;
			position += acceptButton.height + Config.FINGER_SIZE * .3;
			
			bg.graphics.clear();
			bg.graphics.beginFill(Style.color(Style.COLOR_BACKGROUND));
			bg.graphics.drawRect(0, 0, _width, position);
			bg.graphics.endFill();
			
			if (hasTitle(paidChatData))
			{
				var pos:int = Math.max(titleName.y + titleName.height, titleCost.y + titleCost.height) + Config.FINGER_SIZE * .3;
				scrollStart.graphics.lineStyle(1, 0xDCE5EE);
				scrollStart.graphics.moveTo(0, pos);
				scrollStart.graphics.lineTo(_width, pos);
			}
			
			container.y = _height - position - Config.APPLE_BOTTOM_OFFSET;
		}
		
		override public function activateScreen():void 
		{
			if (_isDisposed == true)
				return;
			
			super.activateScreen();
			
			scroll.enable();
			
			backButton.activate();
			acceptButton.activate();
		}
		
		override public function deactivateScreen():void 
		{
			if (_isDisposed == true)
				return;
			
			super.deactivateScreen();
			
			scroll.disable();
			
			backButton.deactivate();
			acceptButton.deactivate();
		}
		
		override public function dispose():void 
		{
			if (_isDisposed == true)
				return;
			super.dispose();
			
			if (scrollHeightData != null)
			{
				TweenMax.killTweensOf(scrollHeightData);
			}
			TweenMax.killTweensOf(scroll.view);
			TweenMax.killTweensOf(loadedPhoto);
			
			if (container != null)
			{
				UI.destroy(container);
				container = null;
			}
			if (bg != null)
			{
				UI.destroy(bg);
				bg = null;
			}
			if (photoSection != null)
			{
				UI.destroy(photoSection);
				photoSection = null;
			}
			if (titleName != null)
			{
				UI.destroy(titleName);
				titleName = null;
			}
			if (titleDescription != null)
			{
				UI.destroy(titleDescription);
				titleDescription = null;
			}
			if (titleCost != null)
			{
				UI.destroy(titleCost);
				titleCost = null;
			}
			if (loadedPhoto != null)
			{
				UI.destroy(loadedPhoto);
				loadedPhoto = null;
			}
			if (scrollStart != null)
			{
				UI.destroy(scrollStart);
				scrollStart = null;
			}
			if (payDescription != null)
			{
				UI.destroy(payDescription);
				payDescription = null;
			}
			if (disclaimer != null)
			{
				UI.destroy(disclaimer);
				disclaimer = null;
			}
			if (disclaimerClip != null)
			{
				UI.destroy(disclaimerClip);
				disclaimerClip = null;
			}
			if (payTask != null)
			{
				payTask.S_ACTION_FAIL.remove(onTransferFailed);
				payTask.S_ACTION_SUCCESS.remove(onTransferSuccess);
				
				payTask.dispose();
				payTask = null;
			}
			if (acceptButton != null)
			{
				acceptButton.dispose();
				acceptButton = null;
			}
			if (backButton != null)
			{
				backButton.dispose();
				backButton = null;
			}
			if (scroll != null)
			{
				scroll.dispose();
				scroll = null;
			}
			if (photoLoader != null)
			{
				photoLoader.dispose();
				photoLoader = null;
			}
			if (horizontalLoader != null)
			{
				horizontalLoader.dispose();
				horizontalLoader = null;
			}
			if (accounts != null)
			{
				accounts.dispose();
				accounts = null;
			}
			if (selectorDebitAccont != null)
			{
				selectorDebitAccont.dispose();
				selectorDebitAccont = null;
			}
			
			paidChatData = null;
		}
	}
}