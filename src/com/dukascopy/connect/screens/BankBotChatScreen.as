package com.dukascopy.connect.screens {
	
	import assets.FloatButtonSettings;
	import com.dukascopy.connect.Config;
	import com.dukascopy.connect.MobileGui;
	import com.dukascopy.connect.data.BackgroundModel;
	import com.dukascopy.connect.data.ChatBackgroundCollection;
	import com.dukascopy.connect.gui.chatInput.BankBotInput;
	import com.dukascopy.connect.gui.chatInput.ChatInputAndroid;
	import com.dukascopy.connect.gui.chatInput.ChatInputIOS;
	import com.dukascopy.connect.gui.chatInput.IChatInput;
	import com.dukascopy.connect.gui.components.message.ToastMessage;
	import com.dukascopy.connect.gui.lightbox.UI;
	import com.dukascopy.connect.gui.list.List;
	import com.dukascopy.connect.gui.list.ListItem;
	import com.dukascopy.connect.gui.list.renderers.ListLink;
	import com.dukascopy.connect.gui.list.renderers.bankAccountElements.ListBankAccount;
	import com.dukascopy.connect.gui.list.renderers.bankAccountElements.ListBankMessage;
	import com.dukascopy.connect.gui.menuVideo.HidableButton;
	import com.dukascopy.connect.gui.topBar.TopBarScreen;
	import com.dukascopy.connect.screens.base.BaseScreen;
	import com.dukascopy.connect.screens.base.ScreenManager;
	import com.dukascopy.connect.screens.dialogs.ScreenLinksDialog;
	import com.dukascopy.connect.screens.payments.settings.PaymentsSettingsScreen;
	import com.dukascopy.connect.sys.assets.Assets;
	import com.dukascopy.connect.sys.auth.Auth;
	import com.dukascopy.connect.sys.bankManager.BankManager;
	import com.dukascopy.connect.sys.dialogManager.DialogManager;
	import com.dukascopy.connect.sys.imageManager.ImageBitmapData;
	import com.dukascopy.connect.sys.payments.PaymentsManager;
	import com.dukascopy.connect.sys.speechControl.SpeechControl;
	import com.dukascopy.connect.sys.style.Style;
	import com.dukascopy.connect.type.ChatInitType;
	import com.dukascopy.connect.type.ChatMessageType;
	import com.dukascopy.connect.type.HitZoneType;
	import com.dukascopy.connect.vo.BankMessageVO;
	import com.dukascopy.connect.vo.screen.ChatScreenData;
	import com.dukascopy.langs.Lang;
	import com.greensock.TweenMax;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	/**
	 * ...
	 * @author Ilya Shcherbakov. Telefision TEAM Riga.
	 */
	
	public class BankBotChatScreen extends BaseScreen {
		
		private var actions:Array = [
			{ id:"settingsBtn", img:Style.icon(Style.ICON_SETTINGS), callback:onBottomButtonTap, imgColor:Style.color(Style.TOP_BAR_ICON_COLOR) },
			{ id:"refreshBtn", img:Style.icon(Style.ICON_REFRESH), callback:resetBot, imgColor:Style.color(Style.TOP_BAR_ICON_COLOR) }
		];
		
		private var topBar:TopBarScreen;
		private var list:List;
		private var input:BankBotInput;
		
		private var currentWidth:int;
		private var currentHeight:int;
		private var speech:SpeechControl;
		
		private var backgroundImage:Bitmap;
		private var backgroundBitmapData:ImageBitmapData;
		
		public function BankBotChatScreen() { }
		
		override protected function createView():void {
			super.createView();
			
			backgroundImage = new Bitmap();
			_view.addChild(backgroundImage);
			
			topBar = new TopBarScreen();
			
			list = new List("bankAccountList");
			list.newMessageAnimationTime = 0.3;
			list.view.y = topBar.trueHeight;
			
			input = new BankBotInput(Lang.startChatWithConsultant, true, BankManager.needToShowMenu, false);
			input.sendCallback = onInputSend;
			input.holdCallback = searchByKeywords;
			input.menuCallback = goToLastStep;
			input.homeCallback = onHomeTap;
			input.mpCallback = BankManager.openMarketPlace;
			
			_view.addChild(list.view);
			_view.addChild(topBar);
			_view.addChild(input);
		}
		
		private function onHomeTap():void {
			if (data == null || data.backScreen != MyAccountScreen) {
				MobileGui.openMyAccountIfExist();
				return
			}
			onBack();
		}
		
		private function searchByKeywords():void {
			if (Auth.companyID != "08A29C35B3")
				return;
			BankManager.preSendMessage( { 
				action:"app:showKeyword",
				command:"cmd:keyword"
			} );
		}
		
		private function openMyAccount():void {
			MobileGui.changeMainScreen(MyAccountScreen);
		}
		
		private function goToLastStep():void {
			input.stopBlinkMenu();
			BankManager.backToLastStep();
		}
		
		private function resetBot():void {
			BankManager.reset();
		}
		
		private function onInputSend():void {
			if (isActivated)
			{
				var chatScreenData:ChatScreenData = new ChatScreenData();
				chatScreenData.pid = Config.EP_VI_DEF;
				chatScreenData.type = ChatInitType.SUPPORT;
				chatScreenData.backScreen = MobileGui.centerScreen.currentScreenClass;
				chatScreenData.backScreenData = MobileGui.centerScreen.currentScreen.data;
				MobileGui.showChatScreen(chatScreenData);
			}
		}
		
		private function onBottomButtonTap():void {
			var bdata:Object={
				backScreen:MobileGui.centerScreen.currentScreenClass,
				backScreenData:MobileGui.centerScreen.currentScreen.data
			}
			MobileGui.changeMainScreen(PaymentsSettingsScreen,  bdata,ScreenManager.DIRECTION_RIGHT_LEFT);
		}
		
		override public function initScreen(data:Object = null):void {
			super.initScreen(data);
			
			topBar.setData(Lang.bankBot, true, actions);
			topBar.drawView(_width);
			
			list.setWidthAndHeight(_width, _height - topBar.trueHeight - input.getHeight());
			
			currentWidth = _width;
			currentHeight = _height;
			
			input.setWidth(currentWidth);
			input.y = _height - input.getHeight();
			
			if (BankManager.cryptoExists == true)
				input.setButtonsState(true, false, false);
			
			if (BankManager.getHistoryAccount() != null &&
				BankManager.getHistoryAccount() != "" &&
				BankManager.getHistoryAccount() != "all")
					input.setHomeButtonColor(0x3F6DCD);
			
			BankManager.S_ANSWER.add(appendItem);
			BankManager.S_ADDITIONAL_DATA_ENTERED.add(updateLastItem);
			BankManager.S_REMOVE_MAIN_MENU.add(removeLastMessages);
			BankManager.S_LAST_ACTIVATE.add(activateMenuButton);
			BankManager.S_MENU_HIDE.add(hideMenuButton);
			BankManager.S_PAYMENT_ERROR.add(onError);
			BankManager.S_ALL_DATA.add(onAccountExists);
			
			topBar.showAnimationOverButton("refreshBtn", false);
			
			BankManager.getAllData(true, true);
			
			addBackgroundImage();
		}
		
		private function onAccountExists(error:Boolean = false, local:Boolean = true):void {
			if (isDisposed == true)
				return;
			
			topBar.hideAnimation();
			BankManager.S_ALL_DATA.remove(onAccountExists);
			if (data != null && "command" in data == true && data.command != null) {
				if ("order" in data == true && data.order != null)
					BankManager.setSelectedData(data.order);
				BankManager.startBankChat(data.command);
			} else
				BankManager.startBankChat();
		}
		
		private function addBackgroundImage():void {
			var backId:String = Style.string(Style.BANK_BACKGROUND_ID);
			if (backId != null) {
				var backgroundModel:BackgroundModel = ChatBackgroundCollection.getBackground(backId);
				if (backgroundModel == null)
					return;
				if (backgroundImage != null && backgroundImage.bitmapData) {
					backgroundImage.bitmapData.dispose();
					backgroundImage.bitmapData = null;
				}
				backgroundBitmapData = Assets.getBackground(backgroundModel.big);
				backgroundImage.bitmapData = UI.drawAreaCentered(backgroundBitmapData, _width, _height);
			} else {
				if (list != null) {
					list.background = true;
					list.backgroundColor = Style.color(Style.CHAT_BACKGROUND);
				}
			}
		}
		
		private function hideMenuButton():void {
			input.setButtonsState(true, false, false);
		}
		
		private function activateMenuButton(val:Boolean):void {
			if (BankManager.cryptoExists == true)
				input.setButtonsState(true, true, false);
			else
				input.setButtonsState(true, true, false, false);
			if (val == true)
				input.startBlinkMenu();
			else
				input.stopBlinkMenu();
		}
		
		private function removeLastMessages():void {
			if (list == null || list.getStock().length < 2)
				return;
			list.removeLastItem(false);
			list.removeLastItem();
		}
		
		private function updateLastItem():void {
			if (_isDisposed == true)
				return;
			if (list == null)
				return;
			list.updateItemByIndex(list.getStock().length - 1, false);
		}
		
		private function appendItem(obj:Object):void {
			if (_isDisposed == true)
				return;
			if (list == null)
				return;
			if (list.data == null) {
				if (obj is BankMessageVO) {
					list.setData([obj], ListBankMessage);
				} else {
					list.setData([obj], ListBankAccount);
				}
				return;
			}
			list.appendItem(obj, ListBankMessage, null, false, true);
			list.scrollBottom(true);
		}
		
		override protected function drawView():void {
			if (_isDisposed == true)
				return;
			if (currentWidth == _width && currentHeight == _height)
				return;
			currentWidth = _width;
			currentHeight = _height;
			if (topBar != null)
				topBar.drawView(_width);
			if (list != null)
				list.setWidthAndHeight(_width, _height - topBar.trueHeight - input.getHeight());
			if (input != null) {
				input.setWidth(currentWidth);
				input.y = _height - input.getHeight();
			}
		}
		
		override public function activateScreen():void {
			if (_isDisposed == true)
				return;
			super.activateScreen();
			if (topBar != null)
				topBar.activate();
			if (list != null) {
				list.activate();
				list.S_ITEM_TAP.add(onItemTap);
			}
			if (input != null)
				input.activate();
			if (speech != null) {
				speech.activate();
			}
		}
		
		private function onError(val:Object = null):void {
			if (val is BankMessageVO) {
				if (val.text == BankManager.PWP_NOT_ENTERED) {
					onBack();
					return;
				}
				if (val.text == "@@1")
					ToastMessage.display("Server is busy, please try later.");
			} else if (val != BankManager.PWP_NOT_ENTERED) {
				ToastMessage.display("Server is busy, please try later.");
			} else {
				onBack();
				return;
			}
		}
		
		private function onItemTap(data:Object, n:int):void {
			var selectedItem:ListItem;
			var lastHitzoneObject:Object;
			var lhz:String;
			if (data is BankMessageVO == false) {
				selectedItem = list.getItemByNum(n);
				lastHitzoneObject =  selectedItem.getLastHitZoneObject();
				lhz = lastHitzoneObject != null ? lastHitzoneObject.type : null;
				if (lhz == HitZoneType.AVATAR) {
					if ("user" in data == true && data.user != null) {
						MobileGui.changeMainScreen(UserProfileScreen, {
							backScreen: MobileGui.centerScreen.currentScreenClass, 
							backScreenData: data, 
							data: data.user
						} );
					} else if ("bankBot" in data == true && data.bankBot == true) {
						BankManager.reset();
					}
				}
				return;
			}
			
			var bmVO:BankMessageVO = data as BankMessageVO;
			if (bmVO.disabled == true) {
				checkAvaClick(n,data);
				return;
			}
			
			selectedItem = list.getItemByNum(n);
			lastHitzoneObject =  selectedItem.getLastHitZoneObject();
			lhz = lastHitzoneObject != null ? lastHitzoneObject.type : null;
			if (lhz == null && bmVO.linksArray != null && bmVO.linksArray.length != 0) {
				DialogManager.showDialog(
					ScreenLinksDialog,
					{
						callback:function(data:Object):void {
							if (data.id == -1)
								return;
							navigateToURL(new URLRequest(data.shortLink));
						},
						data:bmVO.linksArray,
						itemClass:ListLink,
						title:Lang.chooseLinkToOpen
					}
				);
			}
			if (lhz == HitZoneType.BOT_MENU) {
				BankManager.preSendMessage(bmVO.menu[lastHitzoneObject.param]);
				if (_isDisposed == false)
					list.updateItemByIndex(n, false);
			}
			if (lhz == HitZoneType.BOT_MENU_BUTTON) {
				BankManager.preSendMessage(bmVO.buttons[lastHitzoneObject.param]);
				if (_isDisposed == false)
					list.updateItemByIndex(n, false);
			}
			if (lhz == HitZoneType.WALLET_SELECT) {
				bmVO.item.param = BankManager.getAccountByNumberAll(lastHitzoneObject.param);
				BankManager.preSendMessage(bmVO.item);
			}
			if (lhz == HitZoneType.WALLET) {
				if (bmVO.item.value == "SAVINGS")
					bmVO.item.param = BankManager.getSavingAccountByNumber(lastHitzoneObject.param);
				else
					bmVO.item.param = BankManager.getAccountByNumber(lastHitzoneObject.param);
				BankManager.preSendMessage(bmVO.item);
				if (_isDisposed == false)
					list.updateItemByIndex(n, false);
			}
			if (lhz == HitZoneType.CARD) {
				if (bmVO.item.type == "showCard")
					return;
				bmVO.item.param = BankManager.getAllCards()[lastHitzoneObject.param];
				BankManager.preSendMessage(bmVO.item);
				if (_isDisposed == false)
					list.updateItemByIndex(n, false);
			}
			if (lhz == HitZoneType.CRYPTO_DEAL) {
				bmVO.item.param = bmVO.additionalData[lastHitzoneObject.param];
				BankManager.preSendMessage(bmVO.item);
				if (_isDisposed == false)
					list.updateItemByIndex(n, false);
			}
			if (lhz == HitZoneType.INVESTMENT_ITEM) {
				bmVO.item.param = BankManager.getInvestmentByAccount(lastHitzoneObject.param);
				BankManager.preSendMessage(bmVO.item);
				if (_isDisposed == false)
					list.updateItemByIndex(n, false);
			}
			if (lhz == HitZoneType.CRYPTO_RD) {
				/*if (bmVO.item.type == "showRD" && bmVO.additionalData.storage_type == "BLOCKCHAIN") {
					navigateToURL(new URLRequest(Lang.textBlockchainInfoURL + bmVO.additionalData.storage_address));
					return;
				}*/
				bmVO.item.param = lastHitzoneObject.data;
				BankManager.preSendMessage(bmVO.item);
				if (_isDisposed == false)
					list.updateItemByIndex(n, false);
			}
			if (lhz == HitZoneType.AVATAR) {
				BankManager.showAllAcounts();
			}
		}
		
		private function checkAvaClick(n:int, data:Object):void{
			var si:ListItem = list.getItemByNum(n);
			if (si == null)
				return;
			var lhzo:Object =  si.getLastHitZoneObject();
			if (lhzo == null)
				return;
			var isBankbot:Boolean = lhzo.param == 'bankBot';
			if (!('bankBot' in lhzo.param))
				isBankbot = true;
			var l:String = lhzo != null ? lhzo.type : null;
			if (l != null && lhzo != null && l == 'av' && isBankbot)
				BankManager.reset();
		}
		
		override public function deactivateScreen():void {
			if (_isDisposed == true)
				return;
			super.deactivateScreen();
			if (topBar != null)
				topBar.deactivate();
			if (list != null) {
				list.deactivate();
				list.S_ITEM_TAP.remove(onItemTap);
			}
			if (input != null)
				input.deactivate();
			if (speech != null)
				speech.deactivate();
		}
		
		override public function dispose():void {
			super.dispose();
			
			Assets.removeBackground(backgroundBitmapData);
			UI.disposeBMD(backgroundBitmapData);
			backgroundBitmapData = null;
			
			if (backgroundImage) {
				UI.destroy(backgroundImage);
				backgroundImage = null;
			}
			
			if (list != null)
				list.dispose();
			list = null;
			
			if (topBar != null)
				topBar.dispose();
			topBar = null;
			
			if (input != null)
				input.dispose();
			input = null;
			
			actions = null;
			
			BankManager.S_ANSWER.remove(appendItem);
			BankManager.S_ADDITIONAL_DATA_ENTERED.remove(updateLastItem);
			BankManager.S_REMOVE_MAIN_MENU.remove(removeLastMessages);
			BankManager.S_LAST_ACTIVATE.remove(activateMenuButton);
			BankManager.S_MENU_HIDE.remove(hideMenuButton);
			BankManager.S_PAYMENT_ERROR.remove(onError);
			BankManager.S_ALL_DATA.remove(onAccountExists);
			
			BankManager.checkForProgress(true);
			
			if (speech != null) {
				speech.dispose();
				speech = null;
			}
		}
		
		override public function onBack(e:Event = null):void {
			super.onBack(e);
		}
	}
}